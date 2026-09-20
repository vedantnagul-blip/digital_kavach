import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../data/firebase/user_repo.dart';
import '../../data/local/user_prefs.dart';
import 'onboarding_strings.dart';

/// Discrete steps in the onboarding flow (blueprint §8 S1).
enum OnboardingStep { language, mode, signIn, consent, sentinelSetup, done }

/// A serializable placeholder for Phase 06's real Sentinel wizard result.
@immutable
class SentinelSetupStatus {
  const SentinelSetupStatus({
    this.notifAccessGranted = false,
    this.batteryExempt = false,
    this.postNotifGranted = false,
    this.skipped = false,
  });

  final bool notifAccessGranted;
  final bool batteryExempt;
  final bool postNotifGranted;
  final bool skipped;

  bool get isDone =>
      skipped ||
          (notifAccessGranted && batteryExempt && postNotifGranted);
}

@immutable
class OnboardingState {
  const OnboardingState({
    required this.step,
    this.langCode,
    this.modeCode,
    this.signedIn = false,
    this.isGuest = false,
    this.consentAi,
    this.sentinelStatus = const SentinelSetupStatus(),
  });

  final OnboardingStep step;
  final String? langCode;
  final String? modeCode; // 'standard' | 'elder'
  final bool signedIn;
  final bool isGuest;
  final bool? consentAi;
  final SentinelSetupStatus sentinelStatus;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? langCode,
    String? modeCode,
    bool? signedIn,
    bool? isGuest,
    bool? consentAi,
    SentinelSetupStatus? sentinelStatus,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        langCode: langCode ?? this.langCode,
        modeCode: modeCode ?? this.modeCode,
        signedIn: signedIn ?? this.signedIn,
        isGuest: isGuest ?? this.isGuest,
        consentAi: consentAi ?? this.consentAi,
        sentinelStatus: sentinelStatus ?? this.sentinelStatus,
      );
}

const int kConsentVersion = 1;

/// State machine + persistence orchestrator for onboarding.
class OnboardingController extends Notifier<OnboardingState> {
  UserPrefs get _prefs => ref.read(userPrefsProvider);

  @override
  OnboardingState build() {
    final OnboardingState loaded = _computeInitial();
    if (loaded.langCode != null) {
      final SupportedLanguage lang =
      SupportedLanguage.byCode(loaded.langCode!);
      Future<void>.microtask(() {
        ref.read(localeProvider.notifier).state = lang.toAppLocale();
      });
    }
    if (loaded.modeCode == 'elder') {
      Future<void>.microtask(() {
        ref.read(elderModeProvider.notifier).setEnabled(true);
      });
    }
    return loaded;
  }

  OnboardingState _computeInitial() {
    final UserPrefs p = _prefs;
    final String? lang = p.langCode;
    final String? mode = p.modeCode;
    final bool signIn = p.signInDone;
    final bool guest = p.isGuest;
    final bool? consent = p.consentAi;
    final bool sentinelDone = p.sentinelSetupDone;

    OnboardingStep step;
    if (lang == null) {
      step = OnboardingStep.language;
    } else if (mode == null) {
      step = OnboardingStep.mode;
    } else if (!signIn) {
      step = OnboardingStep.signIn;
    } else if (consent == null) {
      step = OnboardingStep.consent;
    } else if (!sentinelDone) {
      step = OnboardingStep.sentinelSetup;
    } else {
      step = OnboardingStep.done;
    }

    return OnboardingState(
      step: step,
      langCode: lang,
      modeCode: mode,
      signedIn: signIn,
      isGuest: guest,
      consentAi: consent,
      sentinelStatus: SentinelSetupStatus(skipped: sentinelDone),
    );
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setLangCode(code);
    final SupportedLanguage lang = SupportedLanguage.byCode(code);
    ref.read(localeProvider.notifier).state = lang.toAppLocale();
    state = state.copyWith(langCode: code, step: OnboardingStep.mode);
    AppLogger.i('Onboarding: language set to $code');
  }

  Future<void> setMode(String mode) async {
    assert(mode == 'standard' || mode == 'elder', 'invalid mode');
    await _prefs.setModeCode(mode);
    ref.read(elderModeProvider.notifier).setEnabled(mode == 'elder');
    state = state.copyWith(modeCode: mode, step: OnboardingStep.signIn);
    AppLogger.i('Onboarding: mode set to $mode');
  }

  Future<void> markSignedIn({required AppUser user}) async {
    await _prefs.setSignInDone(true);
    await _prefs.setIsGuest(user.isGuest);
    state = state.copyWith(
      signedIn: true,
      isGuest: user.isGuest,
      step: OnboardingStep.consent,
    );
    AppLogger.i('Onboarding: signed in (guest=${user.isGuest})');
  }

  Future<void> setConsent({required bool allow}) async {
    final DateTime now = DateTime.now();
    await _prefs.setConsentAi(allow);
    await _prefs.setConsentTs(now);
    await _prefs.setConsentVersion(kConsentVersion);
    state = state.copyWith(
      consentAi: allow,
      step: OnboardingStep.sentinelSetup,
    );
    AppLogger.i('Onboarding: consent=$allow v=$kConsentVersion');
  }

  Future<void> completeSentinelSetup(SentinelSetupStatus status) async {
    await _prefs.setSentinelSetupDone(true);
    state = state.copyWith(
      sentinelStatus: status,
      step: OnboardingStep.done,
    );
    AppLogger.i('Onboarding: sentinel-setup done (skipped=${status.skipped})');
  }

  Future<void> completeAll() async {
    await _prefs.setOnboarded(true);
    ref.read(onboardedProvider.notifier).state = true;
    AppLogger.i('Onboarding: completeAll — user is now onboarded');
  }

  bool get canGoBack =>
      state.step != OnboardingStep.language &&
      state.step != OnboardingStep.done;

  void back() {
    switch (state.step) {
      case OnboardingStep.mode:
        state = state.copyWith(step: OnboardingStep.language);
      case OnboardingStep.signIn:
        state = state.copyWith(step: OnboardingStep.mode);
      case OnboardingStep.consent:
        state = state.copyWith(step: OnboardingStep.signIn);
      case OnboardingStep.sentinelSetup:
        state = state.copyWith(step: OnboardingStep.consent);
      default:
        break;
    }
  }

  Future<void> reset() async {
    await _prefs.clearAll();
    ref.read(onboardedProvider.notifier).state = false;
    state = const OnboardingState(step: OnboardingStep.language);
  }
}

final NotifierProvider<OnboardingController, OnboardingState>
onboardingControllerProvider =
NotifierProvider<OnboardingController, OnboardingState>(
    OnboardingController.new);