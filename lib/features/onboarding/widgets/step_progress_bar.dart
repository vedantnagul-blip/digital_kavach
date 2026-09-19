import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../onboarding_controller.dart';

/// Animated 5-segment progress indicator across the onboarding flow.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({required this.step, super.key});
  final OnboardingStep step;

  int get _index {
    switch (step) {
      case OnboardingStep.language:
        return 0;
      case OnboardingStep.mode:
        return 1;
      case OnboardingStep.signIn:
        return 2;
      case OnboardingStep.consent:
        return 3;
      case OnboardingStep.sentinelSetup:
      case OnboardingStep.done:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Row(
      children: List<Widget>.generate(5, (int i) {
        final bool filled = i <= _index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 4 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 6,
              decoration: BoxDecoration(
                color: filled
                    ? s.primary
                    : s.surfaceContainerHighest,
                borderRadius: AppRadius.rPill,
              ),
            ),
          ),
        );
      }),
    );
  }
}