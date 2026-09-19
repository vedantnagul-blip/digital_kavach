import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/kavach_button.dart';
import '../copilot_controller.dart';
import '../widgets/countdown_header.dart';

/// Step 7: Summary and status management.
class DoneScreen extends StatelessWidget {
  const DoneScreen({
    super.key,
    required this.session,
    required this.onMarkFiled,
    required this.onMarkResolved,
    required this.onUndoStatus,
    required this.onClose,
  });

  final RecoverySession session;
  final VoidCallback onMarkFiled;
  final VoidCallback onMarkResolved;
  final VoidCallback onUndoStatus;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = session.status;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl24),

          // Celebration icon
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.safe.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 64, color: AppColors.safe),
          ),
          const SizedBox(height: AppSpacing.xl20),

          Text(
            'Aapne sab kuch kar liya',
            style: theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Ab bas bank aur cyber cell ka jawab ka intezaar karein.',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl24),

          // Countdown
          CountdownHeader(
            deadline: session.deadline,
            explainerText: 'Bank ko 24 ghante me jawab dena zaruri hai',
          ),
          const SizedBox(height: AppSpacing.xxl24),

          // Summary card
          _SummaryCard(session: session, theme: theme),
          const SizedBox(height: AppSpacing.l16),

          // Reminders info
          Container(
            padding: const EdgeInsets.all(AppSpacing.m12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active,
                    color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    'Reminders set: 6 ghante aur 24 ghante baad',
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Status actions
          if (status == RecoveryStatus.inProgress) ...[
            KavachButton(
              label: 'File ho gaya',
              variant: KavachButtonVariant.tonal,
              icon: Icons.check,
              onPressed: onMarkFiled,
            ),
            const SizedBox(height: AppSpacing.s8),
            KavachButton(
              label: 'Paise wapas mil gaye',
              variant: KavachButtonVariant.filled,
              icon: Icons.celebration,
              onPressed: onMarkResolved,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.m12),
              decoration: BoxDecoration(
                color: (status == RecoveryStatus.resolved
                    ? AppColors.safe
                    : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    status == RecoveryStatus.resolved
                        ? Icons.celebration
                        : Icons.check_circle,
                    color: status == RecoveryStatus.resolved
                        ? AppColors.safe
                        : AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      status == RecoveryStatus.resolved
                          ? 'Case resolved'
                          : 'Complaint filed',
                      style: theme.textTheme.titleMedium!,
                    ),
                  ),
                  TextButton(
                    onPressed: onUndoStatus,
                    child: const Text('Undo'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
          KavachButton(
            label: 'Band karein',
            variant: KavachButtonVariant.text,
            onPressed: onClose,
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.session, required this.theme});
  final RecoverySession session;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final a = session.answers;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aapki case summary',
            style: theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          _row(theme, 'Amount', a.amount != null ? '₹${a.amount}' : '—'),
          _row(theme, 'App', a.paymentApp ?? '—'),
          _row(theme, 'Type', a.scamFamily ?? '—'),
          _row(
            theme,
            'Reported to',
            '1930 + Cyber Cell + Bank',
          ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs4),
      child: Row(
        children: [
          Text(
            '$k: ',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}