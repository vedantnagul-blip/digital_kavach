import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:digital_kavach/features/home/home_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase/user_repo.dart';
import 'family_pairing_service.dart';
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
          members.any((member) => member.role == FamilyRole.guardian);

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
  }) {
    return FamilyState(
      family: family ?? this.family,
      members: members ?? this.members,
      recentEvents: recentEvents ?? this.recentEvents,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activePairCode: clearPairCode
          ? null
          : (activePairCode ?? this.activePairCode),
      activePairFamilyId: clearPairCode
          ? null
          : (activePairFamilyId ?? this.activePairFamilyId),
      pairCodeExpiry: clearPairCode
          ? null
          : (pairCodeExpiry ?? this.pairCodeExpiry),
      alertLevel: alertLevel ?? this.alertLevel,
      digestEnabled: digestEnabled ?? this.digestEnabled,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final familyControllerProvider =
StateNotifierProvider<FamilyController, FamilyState>((ref) {
  final repo = ref.read(familyRepoProvider);

  // Watch authentication so the controller is recreated when the user
  // signs in or signs out.
  final authUser = ref.watch(authUserStreamProvider).valueOrNull;

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
    if (currentUid != null) {
      loadFamily();
    }
  }

  final FamilyRepo _repo;
  final String? _currentUid;
  final GuardianAlertHandler _alertHandler;
  final WeeklyDigestBuilder _digestBuilder;
  final DateTime Function() _clock;

  StreamSubscription<List<FamilyEvent>>? _eventSub;

  // -------------------------------------------------------------------------
  // Load family
  // -------------------------------------------------------------------------

  Future<void> loadFamily() async {
    if (_currentUid == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final family = await _repo.getFamilyForUser(_currentUid!);

      if (!mounted) return;

      if (family == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final members = await _repo.resolveMembers(family.allUids);

      if (!mounted) return;

      final taggedMembers = members.map((member) {
        final role = family.guardianUids.contains(member.uid)
            ? FamilyRole.guardian
            : FamilyRole.elder;

        return FamilyMember(
          uid: member.uid,
          displayName: member.displayName,
          role: role,
          linkedAt: member.linkedAt,
          phoneNumber: member.phoneNumber,
        );
      }).toList();

      state = state.copyWith(
        family: family,
        members: taggedMembers,
        isLoading: false,
      );

      _startEventListener(family.id);
    } catch (_) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: 'Could not load Family Shield.',
      );
    }
  }

  // -------------------------------------------------------------------------
  // Pairing
  // -------------------------------------------------------------------------

  /// Creates an invitation through the trusted Cloud Function.
  Future<void> generatePairCode() async {
    if (_currentUid == null) {
      state = state.copyWith(
        clearPairCode: true,
        error: 'Please sign in before creating a family invitation.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearPairCode: true,
    );

    try {
      final invite = await FamilyPairingService().createInvite();

      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        activePairCode: invite.pairCode,
        activePairFamilyId: invite.familyId,
        pairCodeExpiry: invite.expiresAt,
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Could not create a family invitation.',
      );
    } catch (_) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: 'Could not create a family invitation.',
      );
    }
  }

  /// Joins a family through the trusted Cloud Function.
  Future<bool> joinWithCode(String familyId, String code) async {
    if (_currentUid == null) {
      state = state.copyWith(
        error: 'Please sign in before joining a family.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await FamilyPairingService().joinFamily(
        familyId: familyId,
        pairCode: code,
      );

      if (!mounted) return false;

      state = state.copyWith(
        isLoading: false,
        clearPairCode: true,
      );

      await loadFamily();

      return mounted;
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return false;

      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Could not join the family.',
      );
      return false;
    } catch (_) {
      if (!mounted) return false;

      state = state.copyWith(
        isLoading: false,
        error: 'Could not join the family.',
      );
      return false;
    }
  }

  /// The old client-side unpair method is incompatible with the proposed
  /// Firestore rules. A trusted backend unpair function is still required.
  Future<void> unpairMember(String memberUid) async {
    state = state.copyWith(
      error: 'Secure unpairing is not available yet.',
    );
  }

  void clearPairCode() {
    state = state.copyWith(clearPairCode: true);
  }

  // -------------------------------------------------------------------------
  // Family alerts
  // -------------------------------------------------------------------------

  /// Records an event. This method still needs to be connected to scan flows.
  Future<void> reportRed({
    required String pattern,
    required String severity,
  }) async {
    if (_currentUid == null || state.family == null) return;

    final event = FamilyEvent(
      id: '',
      familyId: state.family!.id,
      aboutUid: _currentUid!,
      severity: severity,
      pattern: pattern,
      ts: _clock(),
    );

    await _repo.writeEvent(event);
  }

  void _startEventListener(String familyId) {
    _eventSub?.cancel();

    final stream = state.alertLevel == AlertLevel.redOnly
        ? _repo.watchRedEvents(familyId)
        : _repo.watchAllEvents(familyId);

    _eventSub = stream.listen(
          (events) {
        if (!mounted) return;

        for (final event in events) {
          if (event.severity == 'RED' && event.aboutUid != _currentUid) {
            _alertHandler.handleEvent(event, state.members);
          }
        }

        state = state.copyWith(recentEvents: events);
      },
      onError: (_) {
        if (!mounted) return;

        state = state.copyWith(
          error: 'Could not load family alerts.',
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Preferences
  // -------------------------------------------------------------------------

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

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}