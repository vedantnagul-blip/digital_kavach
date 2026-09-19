import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/local/hive_boxes.dart';
import 'complaint_service.dart';
import 'evidence_store.dart';
import 'reminder_scheduler.dart';

/// The seven steps of the recovery wizard.
enum RecoveryStep {
  calm,
  call1930,
  questions,
  complaint,
  bank,
  evidence,
  done;

  /// Returns the persisted step identifier.
  String toJson() => name;

  /// Reads a persisted step, defaulting to the introduction.
  static RecoveryStep fromJson(String value) {
    return RecoveryStep.values.firstWhere(
          (RecoveryStep step) => step.name == value,
      orElse: () => RecoveryStep.calm,
    );
  }

  /// Whether the wizard allows backward navigation from this step.
  bool get canGoBack {
    return this != RecoveryStep.calm && this != RecoveryStep.done;
  }

  /// One-based position used by the progress indicator.
  int get position => index + 1;

  /// Number of wizard steps.
  static int get totalSteps => RecoveryStep.values.length;
}

/// Overall status of a recovery case.
enum RecoveryStatus {
  inProgress,
  filed,
  resolved,
}

/// Answers collected during the recovery questions.
@immutable
class RecoveryAnswers {
  /// Creates a collection of recovery answers.
  const RecoveryAnswers({
    this.incidentDate,
    this.amount,
    this.paymentApp,
    this.toWhom,
    this.scamFamily,
    this.description,
    this.complainantName,
    this.city,
    this.utrNumber,
  });

  /// Date and time of the incident.
  final DateTime? incidentDate;

  /// Amount reported by the user.
  final int? amount;

  /// Payment application used for the transaction.
  final String? paymentApp;

  /// Recipient identifier supplied by the user.
  final String? toWhom;

  /// Selected scam category.
  final String? scamFamily;

  /// User's description of the incident.
  final String? description;

  /// Name to include in the complaint.
  final String? complainantName;

  /// Complainant's city.
  final String? city;

  /// Transaction reference, when available.
  final String? utrNumber;

  /// Returns a copy with the supplied fields updated.
  RecoveryAnswers copyWith({
    DateTime? incidentDate,
    int? amount,
    String? paymentApp,
    String? toWhom,
    String? scamFamily,
    String? description,
    String? complainantName,
    String? city,
    String? utrNumber,
  }) {
    return RecoveryAnswers(
      incidentDate: incidentDate ?? this.incidentDate,
      amount: amount ?? this.amount,
      paymentApp: paymentApp ?? this.paymentApp,
      toWhom: toWhom ?? this.toWhom,
      scamFamily: scamFamily ?? this.scamFamily,
      description: description ?? this.description,
      complainantName: complainantName ?? this.complainantName,
      city: city ?? this.city,
      utrNumber: utrNumber ?? this.utrNumber,
    );
  }

  /// Converts answers into the existing recovery JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'incidentDate': incidentDate?.toIso8601String(),
      'amount': amount,
      'paymentApp': paymentApp,
      'toWhom': toWhom,
      'scamFamily': scamFamily,
      'description': description,
      'complainantName': complainantName,
      'city': city,
      'utrNumber': utrNumber,
    };
  }

  /// Restores answers from recovery JSON.
  factory RecoveryAnswers.fromJson(Map<String, dynamic> json) {
    final String? incidentDate = json['incidentDate'] as String?;

    return RecoveryAnswers(
      incidentDate:
      incidentDate == null ? null : DateTime.parse(incidentDate),
      amount: json['amount'] as int?,
      paymentApp: json['paymentApp'] as String?,
      toWhom: json['toWhom'] as String?,
      scamFamily: json['scamFamily'] as String?,
      description: json['description'] as String?,
      complainantName: json['complainantName'] as String?,
      city: json['city'] as String?,
      utrNumber: json['utrNumber'] as String?,
    );
  }
}

/// Persisted state of a recovery wizard session.
@immutable
class RecoverySession {
  /// Creates a recovery session.
  const RecoverySession({
    required this.id,
    required this.step,
    required this.deadline,
    required this.createdAt,
    this.questionIndex = 0,
    this.answers = const RecoveryAnswers(),
    this.draft,
    this.evidenceChecks = const <String, bool>{},
    this.status = RecoveryStatus.inProgress,
  });

  /// Unique recovery session identifier.
  final String id;

  /// Current wizard step.
  final RecoveryStep step;

  /// Current question within the questions step.
  final int questionIndex;

  /// Collected incident details.
  final RecoveryAnswers answers;

  /// Generated or user-edited complaint.
  final RecoveryDraft? draft;

  /// Persisted countdown deadline.
  final DateTime deadline;

  /// Completion state of evidence checklist items.
  final Map<String, bool> evidenceChecks;

  /// User-reported case status.
  final RecoveryStatus status;

  /// Time at which the session was created.
  final DateTime createdAt;

  /// Returns a copy with the supplied fields updated.
  RecoverySession copyWith({
    RecoveryStep? step,
    int? questionIndex,
    RecoveryAnswers? answers,
    RecoveryDraft? draft,
    DateTime? deadline,
    Map<String, bool>? evidenceChecks,
    RecoveryStatus? status,
  }) {
    return RecoverySession(
      id: id,
      step: step ?? this.step,
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      draft: draft ?? this.draft,
      deadline: deadline ?? this.deadline,
      evidenceChecks: evidenceChecks ?? this.evidenceChecks,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// Converts the session into its persisted JSON representation.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'step': step.toJson(),
      'questionIndex': questionIndex,
      'answers': answers.toJson(),
      'draft': draft?.toJson(),
      'deadline': deadline.toIso8601String(),
      'evidenceChecks': evidenceChecks,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Restores a session from persisted JSON.
  factory RecoverySession.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> answersJson =
    Map<String, dynamic>.from(
      json['answers'] as Map? ?? <String, dynamic>{},
    );

    final Object? draftJson = json['draft'];

    return RecoverySession(
      id: json['id'] as String,
      step: RecoveryStep.fromJson(json['step'] as String),
      questionIndex: json['questionIndex'] as int? ?? 0,
      answers: RecoveryAnswers.fromJson(answersJson),
      draft: draftJson is Map
          ? RecoveryDraft.fromJson(
        Map<String, dynamic>.from(draftJson),
      )
          : null,
      deadline: DateTime.parse(json['deadline'] as String),
      evidenceChecks: Map<String, bool>.from(
        json['evidenceChecks'] as Map? ?? <String, bool>{},
      ),
      status: RecoveryStatus.values.firstWhere(
            (RecoveryStatus value) => value.name == json['status'],
        orElse: () => RecoveryStatus.inProgress,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Provides the recovery controller after Hive initialization.
final StateNotifierProvider<CopilotController, RecoverySession?>
copilotControllerProvider =
StateNotifierProvider<CopilotController, RecoverySession?>((ref) {
  if (!Hive.isBoxOpen(HiveBoxes.recovery)) {
    // StorageException accepts ONE optional positional message.
    throw const StorageException(
      'Recovery Hive box is not open. '
          'Await HiveBoxes.openAll() before opening the recovery wizard.',
    );
  }

  return CopilotController(
    box: HiveBoxes.recoveryBox,
    complaintService: ref.read(complaintServiceProvider),
    evidenceStore: ref.read(evidenceStoreProvider),
    reminderScheduler: ref.read(reminderSchedulerProvider),
    clock: DateTime.now,
  );
});

/// Controls navigation, answers, drafts, and local recovery persistence.
///
/// Each mutation requests a Hive write. Persistence errors are caught and
/// logged without including complaint content or the user's answers.
class CopilotController extends StateNotifier<RecoverySession?> {
  /// Creates the controller and restores the saved session, if available.
  CopilotController({
    required Box<dynamic> box,
    required ComplaintService complaintService,
    required EvidenceStore evidenceStore,
    required ReminderScheduler reminderScheduler,
    required DateTime Function() clock,
  })  : _box = box,
        _complaintService = complaintService,
        _evidenceStore = evidenceStore,
        _reminderScheduler = reminderScheduler,
        _clock = clock,
        super(null) {
    _restore();

    // A process may have stopped while the complaint was being generated.
    final RecoverySession? restored = state;
    if (restored != null &&
        restored.step == RecoveryStep.complaint &&
        restored.draft == null) {
      unawaited(_buildDraft());
    }
  }

  static const String _key = 'current';

  final Box<dynamic> _box;
  final ComplaintService _complaintService;
  final EvidenceStore _evidenceStore;
  final ReminderScheduler _reminderScheduler;
  final DateTime Function() _clock;

  int _draftRequest = 0;

  void _restore() {
    try {
      final Object? raw = _box.get(_key);

      if (raw is String) {
        state = RecoverySession.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      AppLogger.e(
        'Failed to restore the recovery session.',
        tag: 'recovery',
      );
    }
  }

  Future<void> _persist() async {
    final RecoverySession? session = state;
    if (session == null) return;

    try {
      await _box.put(
        _key,
        jsonEncode(session.toJson()),
      );
    } catch (_) {
      AppLogger.e(
        'Failed to persist the recovery session.',
        tag: 'recovery',
      );
    }
  }

  Future<void> _deleteCurrent() async {
    try {
      await _box.delete(_key);
    } catch (_) {
      AppLogger.e(
        'Failed to remove the saved recovery session.',
        tag: 'recovery',
      );
    }
  }

  /// Starts a new session with a persisted 24-hour countdown.
  void startNew({
    String? userName,
    String? userCity,
  }) {
    _draftRequest++;

    final DateTime now = _clock();

    state = RecoverySession(
      id: const Uuid().v4(),
      step: RecoveryStep.calm,
      deadline: now.add(const Duration(hours: 24)),
      createdAt: now,
      answers: RecoveryAnswers(
        complainantName: userName,
        city: userCity,
        incidentDate: now,
      ),
    );

    unawaited(_persist());
  }

  /// Whether the saved case remains in progress.
  bool get hasActiveSession {
    return state != null &&
        state!.status == RecoveryStatus.inProgress;
  }

  /// Advances one question or one wizard step.
  ///
  /// Returns false when there is no session or the final step is reached.
  bool nextStep() {
    final RecoverySession? session = state;
    if (session == null) return false;

    if (session.step == RecoveryStep.questions &&
        session.questionIndex < 4) {
      state = session.copyWith(
        questionIndex: session.questionIndex + 1,
      );

      unawaited(_persist());
      return true;
    }

    final int nextIndex = session.step.index + 1;
    if (nextIndex >= RecoveryStep.values.length) {
      return false;
    }

    final RecoveryStep next = RecoveryStep.values[nextIndex];

    state = session.copyWith(
      step: next,
      questionIndex: 0,
    );

    unawaited(_persist());

    if (next == RecoveryStep.complaint && state!.draft == null) {
      unawaited(_buildDraft());
    }

    if (next == RecoveryStep.done) {
      unawaited(_scheduleReminders());
    }

    return true;
  }

  /// Moves backward one question or one wizard step.
  bool previousStep() {
    final RecoverySession? session = state;

    if (session == null || !session.step.canGoBack) {
      return false;
    }

    if (session.step == RecoveryStep.questions &&
        session.questionIndex > 0) {
      state = session.copyWith(
        questionIndex: session.questionIndex - 1,
      );

      unawaited(_persist());
      return true;
    }

    final int previousIndex = session.step.index - 1;
    if (previousIndex < 0) return false;

    final RecoveryStep previous = RecoveryStep.values[previousIndex];

    state = session.copyWith(
      step: previous,
      questionIndex: previous == RecoveryStep.questions ? 4 : 0,
    );

    unawaited(_persist());
    return true;
  }

  /// Selects a step for an existing session.
  void goToStep(RecoveryStep step) {
    final RecoverySession? session = state;
    if (session == null) return;

    state = session.copyWith(
      step: step,
      questionIndex: 0,
    );

    unawaited(_persist());
  }

  /// Updates answers and requests persistence immediately.
  void updateAnswers(
      RecoveryAnswers Function(RecoveryAnswers) updater,
      ) {
    final RecoverySession? session = state;
    if (session == null) return;

    // Prevent a pending draft for older answers from replacing newer work.
    _draftRequest++;

    state = session.copyWith(
      answers: updater(session.answers),
    );

    unawaited(_persist());
  }

  Future<void> _buildDraft() async {
    final RecoverySession? session = state;
    if (session == null) return;

    final int request = ++_draftRequest;

    try {
      final RecoveryDraft draft =
      await _complaintService.buildDraft(session.answers);

      if (!mounted || request != _draftRequest) return;

      final RecoverySession? current = state;
      if (current == null || current.id != session.id) return;

      state = current.copyWith(draft: draft);
      await _persist();
    } catch (_) {
      AppLogger.e(
        'Failed to generate the recovery draft.',
        tag: 'recovery',
      );
    }
  }

  /// Regenerates the draft from the current answers.
  ///
  /// The existing draft remains available until its replacement is ready.
  Future<void> regenerateDraft() async {
    if (state == null) return;
    await _buildDraft();
  }

  /// Saves the user's edited draft.
  void updateDraft(RecoveryDraft updated) {
    final RecoverySession? session = state;
    if (session == null) return;

    // Do not let an older generation request overwrite a manual edit.
    _draftRequest++;

    state = session.copyWith(draft: updated);
    unawaited(_persist());
  }

  /// Updates an evidence checkbox and saves the checklist.
  void toggleEvidence(String key, bool checked) {
    final RecoverySession? session = state;
    if (session == null) return;

    final Map<String, bool> checks =
    Map<String, bool>.from(session.evidenceChecks);

    checks[key] = checked;

    state = session.copyWith(evidenceChecks: checks);

    unawaited(_persist());
    unawaited(_saveEvidence(session.id, checks));
  }

  Future<void> _saveEvidence(
      String sessionId,
      Map<String, bool> checks,
      ) async {
    try {
      await _evidenceStore.save(sessionId, checks);
    } catch (_) {
      AppLogger.e(
        'Failed to save the evidence checklist.',
        tag: 'recovery',
      );
    }
  }

  /// Whether all canonical evidence items are checked.
  bool get allEvidenceChecked {
    final RecoverySession? session = state;
    if (session == null) return false;

    return EvidenceStore.defaultKeys.every(
          (String key) => session.evidenceChecks[key] == true,
    );
  }

  /// Records that the user has filed the complaint.
  void markFiled() {
    final RecoverySession? session = state;
    if (session == null) return;

    state = session.copyWith(status: RecoveryStatus.filed);
    unawaited(_persist());
  }

  /// Records that the user has resolved the case.
  void markResolved() {
    final RecoverySession? session = state;
    if (session == null) return;

    state = session.copyWith(status: RecoveryStatus.resolved);
    unawaited(_persist());
  }

  /// Returns the case status to in-progress.
  void undoStatus() {
    final RecoverySession? session = state;
    if (session == null) return;

    state = session.copyWith(status: RecoveryStatus.inProgress);
    unawaited(_persist());
  }

  Future<void> _scheduleReminders() async {
    final RecoverySession? session = state;
    if (session == null) return;

    try {
      await _reminderScheduler.scheduleFollowUps(
        sessionId: session.id,
        from: _clock(),
      );
    } catch (_) {
      AppLogger.e(
        'Failed to schedule recovery follow-up reminders.',
        tag: 'recovery',
      );
    }
  }

  /// Remaining time calculated from the injected clock.
  Duration get remainingTime {
    final RecoverySession? session = state;
    if (session == null) return Duration.zero;

    final Duration remaining = session.deadline.difference(_clock());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Whether the countdown has reached zero.
  bool get isDeadlineExpired => remainingTime == Duration.zero;

  /// Removes the current session after explicit user confirmation.
  void abandon() {
    _draftRequest++;

    AppLogger.i(
      'Recovery session abandoned.',
      tag: 'recovery',
    );

    state = null;
    unawaited(_deleteCurrent());
  }

  /// Clears the current session when the completion screen is closed.
  void clearCompleted() {
    if (state == null) return;

    _draftRequest++;
    state = null;

    unawaited(_deleteCurrent());
  }
}