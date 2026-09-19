import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_controller.dart';
import 'screens/consent_screen.dart';
import 'screens/language_screen.dart';
import 'screens/mode_screen.dart';
import 'screens/sentinel_setup_screen.dart';
import 'screens/signin_screen.dart';

/// Renders the current onboarding step with animated slide + fade
/// transitions. Attached to router path `/onboarding`.
class OnboardingHost extends ConsumerWidget {
  const OnboardingHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStep step =
    ref.watch(onboardingControllerProvider.select((OnboardingState s) => s.step));

    final Widget child;
    switch (step) {
      case OnboardingStep.language:
        child = const LanguageScreen(key: ValueKey<String>('lang'));
        break;
      case OnboardingStep.mode:
        child = const ModeScreen(key: ValueKey<String>('mode'));
        break;
      case OnboardingStep.signIn:
        child = const SignInScreen(key: ValueKey<String>('signin'));
        break;
      case OnboardingStep.consent:
        child = const ConsentScreen(key: ValueKey<String>('consent'));
        break;
      case OnboardingStep.sentinelSetup:
      case OnboardingStep.done:
        child = const SentinelSetupScreen(key: ValueKey<String>('sentinel'));
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget widget, Animation<double> animation) {
        final Animation<Offset> offset = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: widget),
        );
      },
      child: child,
    );
  }
}