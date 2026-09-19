import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../copilot_controller.dart';

/// Horizontal progress indicator showing the 7 wizard steps.
class StepChecklist extends StatelessWidget {
  const StepChecklist({
    super.key,
    required this.currentStep,
  });

  final RecoveryStep currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l16,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        children: RecoveryStep.values.map((step) {
          final isCompleted = step.index < currentStep.index;
          final isCurrent = step == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.safe
                          : isCurrent
                          ? AppColors.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (step != RecoveryStep.done)
                  const SizedBox(width: 2),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}