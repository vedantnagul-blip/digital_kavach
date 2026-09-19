import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../widgets/countdown_header.dart';

class CalmScreen extends StatelessWidget {
  const CalmScreen({
    super.key,
    required this.deadline,
    required this.countdownExplainer,
    required this.calmTitle,
    required this.calmBody,
    required this.onNext,
  });

  final DateTime deadline;
  final String countdownExplainer;
  final String calmTitle;
  final String calmBody;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(Icons.shield_outlined, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: AppSpacing.xl20),
          Text(
            calmTitle,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.l16),
          Text(
            calmBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl32),
          CountdownHeader(deadline: deadline, explainerText: countdownExplainer),
          const Spacer(flex: 3),
          KavachButton(
            label: 'Shuru karein',
            variant: KavachButtonVariant.filled,
            onPressed: onNext,
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}