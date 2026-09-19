import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';

/// Shown after successful pairing.
class PairSuccessScreen extends StatelessWidget {
  const PairSuccessScreen({
    super.key,
    required this.guardianName,
    required this.elderName,
    required this.onDone,
  });

  final String guardianName;
  final String elderName;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.safeContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.family_restroom,
                size: 56,
                color: AppColors.safe,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl24),
            Text(
              'Family Shield active!',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.safe,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m12),
            Text(
              '$guardianName aur $elderName ab jude hue hain.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Ab jab bhi koi khatarnak message aayega, '
                  'guardian ko turant pata chalega.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl32),
            KavachButton(
              label: 'Shuru karein',
              variant: KavachButtonVariant.filled,
              onPressed: onDone,
            ),
          ],
        ),
      ),
    );
  }
}