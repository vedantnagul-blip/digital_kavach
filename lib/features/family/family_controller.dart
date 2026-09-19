import 'dart:async';

import 'package:digital_kavach/features/home/home_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/firebase/user_repo.dart';
import 'family_repo.dart';
import 'widgets/guardian_alert_handler.dart';
import 'widgets/weekly_digest_builder.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
class FamilyState {
  final FamilyGroup? family;
  final List<FamilyMember> members;
  final List<FamilyEvent> recentEvents;
  final bool isLoading;
  final String? error;
  final String? activePairCode;
  final String? activePairFamilyId;
  final DateTime? pairCodeExpiry;
  final AlertLevel alertLevel;
  final bool digestEnabled;

  const FamilyState({
    this.family,
    this.members = const [],
    this.recentEvents = const [],
    this.isLoading = false,
    this.error,
    this.activePairCode,
    this.activePairFamilyId,
    this.pairCodeExpiry,
    this.alertLevel = AlertLevel.redOnly,
    this.digestEnabled = true,
  });

  bool get hasFamily => family != null && family!.status == 'active';
  bool get isGuardian =>
      family != null &&
          members.any((m) => m.role == FamilyRole.guardian);

  FamilyState copyWith({
    FamilyGroup? family,
    List<FamilyMember>? members,
    List<FamilyEvent>? recentEvents,
    bool? isLoading,
    String? error,
    String? activePairCode,
    String? activePairFamilyId,
    DateTime? pairCodeExpiry,
    AlertLevel? alertLevel,
    bool? digestEnabled,
    bool clearPairCode = false,
    bool clearError = false,
  }) =>
      FamilyState(
        family: family ?? this.family,
        members: members ?? this.members,
        recentEvents: recentEvents ?? this.recentEvents,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        activePairCode: clearPairCode ? null : (activePairCode ?? this.activePairCode),
        activePairFamilyId:
        clearPairCode ? null : (activePairFamilyId ?? this.activePairFamilyId),
        pairCodeExpiry:
        clearPairCode ? null : (pairCodeExpiry ?? this.pairCodeExpiry),
        alertLevel: alertLevel ?? this.alertLevel,
        digestEnabled: digestEnabled ?? this.digestEnabled,
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final familyControllerProvider =
StateNotifierProvider<FamilyController, FamilyState>((ref) {
  final repo = ref.read(familyRepoProvider);
  final authUser = ref.read(authUserStreamProvider).valueOrNull;
  final alertHandler = ref.read(guardianAlertHandlerProvider);
  final digestBuilder = ref.read(weeklyDigestBuilderProvider);
  return FamilyController(
    repo: repo,
    currentUid: authUser?.uid,
    alertHandler: alertHandler,
    digestBuilder: digestBuilder,
    clock: DateTime.now,
  );
});

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Manages family pairing, event listening, and alert propagation.
class FamilyController extends StateNotifier<FamilyState> {
  FamilyController({
    required FamilyRepo repo,
    required String? currentUid,
    required GuardianAlertHandler alertHandler,
    required WeeklyDigestBuilder digestBuilder,
    required DateTime Function() clock,
  })  : _repo = repo,
        _currentUid = currentUid,
        _alertHandler = alertHandler,
        _digestBuilder = digestBuilder,
        _clock = clock,
        super(const FamilyState()) {
    if (currentUid != null) loadFamily();
  }

  final FamilyRepo _repo;
  final String? _currentUid;
  final GuardianAlertHandler _alertHandler;
  final WeeklyDigestBuilder _digestBuilder;
  final DateTime Function() _clock;
  StreamSubscription<List<FamilyEvent>>? _eventSub;

  // -- Load -----------------------------------------------------------------

  Future<void> loadFamily() async {
    if (_currentUid == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final family = await _repo.getFamilyForUser(_currentUid!);
      if (family == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final allUids = family.allUids;
      final members = await _repo.resolveMembers(allUids);

      // Tag roles correctly
      final taggedMembers = members.map((m) {
        final role = family.guardianUids.contains(m.uid)
            ? FamilyRole.guardian
            : FamilyRole.elder;
        return FamilyMember(
          uid: m.uid,
          displayName: m.displayName,
          role: role,
          linkedAt: m.linkedAt,
          phoneNumber: m.phoneNumber,
        );
      }).toList();

      state = state.copyWith(
        family: family,
        members: taggedMembers,
        isLoading: false,
      );

      _startEventListener(family.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // -- Pairing --------------------------------------------------------------

  /// Guardian generates a pair code.
  Future<void> generatePairCode() async {
    if (_currentUid == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final code = _repo.generatePairCode();
      final familyId = await _repo.createFamilyDraft(
        guardianUid: _currentUid!,
        pairCode: code,
      );

      state = state.copyWith(
        isLoading: false,
        activePairCode: code,
        activePairFamilyId: familyId,
        pairCodeExpiry: _clock().add(const Duration(minutes: 15)),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Elder scans/enters a pair code to join.
  Future<bool> joinWithCode(String familyId, String code) async {
    if (_currentUid == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.joinFamily(
        familyId: familyId,
        pairCode: code,
        elderUid: _currentUid!,
      );
      state = state.copyWith(isLoading: false, clearPairCode: true);
      await loadFamily();
      return true;
    } on ValidationException catch (e) {
      state = state.copyWith(isLoading: false, error: e.code);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Unpair a member.
  Future<void> unpairMember(String memberUid) async {
    if (_currentUid == null || state.family == null) return;
    state = state.copyWith(isLoading: true);

    try {
      await _repo.unpair(
        familyId: state.family!.id,
        memberUid: memberUid,
        callerUid: _currentUid!,
      );
      await loadFamily();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearPairCode() {
    state = state.copyWith(clearPairCode: true);
  }

  // -- Red-alert reporting (called from queue drainer + manual scan) --------

  /// Report a RED event to the family.
  /// This is the `onRedEvent` callback wired into Phase 06's queue drainer.
  Future<void> reportRed({
    required String pattern,
    required String severity,
  }) async {
    if (_currentUid == null || state.family == null) return;

    final event = FamilyEvent(
      id: '', // auto-generated by Firestore
      familyId: state.family!.id,
      aboutUid: _currentUid!,
      severity: severity,
      pattern: pattern,
      ts: _clock(),
    );

    await _repo.writeEvent(event);
  }

  // -- Event listening (guardian side) --------------------------------------

  void _startEventListener(String familyId) {
    _eventSub?.cancel();

    final stream = state.alertLevel == AlertLevel.redOnly
        ? _repo.watchRedEvents(familyId)
        : _repo.watchAllEvents(familyId);

    _eventSub = stream.listen((events) {
      if (!mounted) return;

      // Notify guardian of new RED events
      for (final event in events) {
        if (event.severity == 'RED' && event.aboutUid != _currentUid) {
          _alertHandler.handleEvent(event, state.members);
        }
      }

      state = state.copyWith(recentEvents: events);
    });
  }

  // -- Preferences ----------------------------------------------------------

  void setAlertLevel(AlertLevel level) {
    state = state.copyWith(alertLevel: level);
    if (state.family != null) {
      _startEventListener(state.family!.id);
    }
  }

  void setDigestEnabled(bool enabled) {
    state = state.copyWith(digestEnabled: enabled);
    if (enabled) {
      _digestBuilder.scheduleWeeklyDigest();
    } else {
      _digestBuilder.cancelWeeklyDigest();
    }
  }

  // -- Cleanup --------------------------------------------------------------

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}