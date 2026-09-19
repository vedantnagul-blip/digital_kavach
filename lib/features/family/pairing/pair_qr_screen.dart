import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';

/// Guardian generates a pair code displayed as large text + deep link.
class PairQrScreen extends StatelessWidget {
  const PairQrScreen({
    super.key,
    required this.pairCode,
    required this.familyId,
    required this.expiresAt,
    required this.onRegenerate,
    required this.onDone,
  });

  final String pairCode;
  final String familyId;
  final DateTime expiresAt;
  final VoidCallback onRegenerate;
  final VoidCallback onDone;

  String get _deepLink => 'kavach://pair?fam=$familyId&c=$pairCode';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = expiresAt.difference(DateTime.now());
    final minutesLeft = remaining.inMinutes.clamp(0, 15);

    return Scaffold(
      appBar: AppBar(title: const Text('Family Member Jodein')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl24),

            Text(
              'Yeh code apne elder ko dein',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Elder app me "Scan / Code" se yeh code daalein',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl32),

            // Giant 6-char code display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl24,
                vertical: AppSpacing.xl20,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    pairCode,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    '$minutesLeft min baaki',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: minutesLeft < 3
                          ? AppColors.danger
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l16),

            // Copy deep link
            KavachButton(
              label: 'Link copy karein',
              variant: KavachButtonVariant.tonal,
              icon: Icons.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _deepLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied!')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            KavachButton(
              label: 'Naya code banayein',
              variant: KavachButtonVariant.text,
              icon: Icons.refresh,
              onPressed: onRegenerate,
            ),

            const Spacer(),

            KavachButton(
              label: 'Ho gaya',
              variant: KavachButtonVariant.filled,
              onPressed: onDone,
            ),
            const SizedBox(height: AppSpacing.l16),
          ],
        ),
      ),
    );
  }
}