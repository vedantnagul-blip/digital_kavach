import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../models/qr_payload.dart';
import '../models/upi_spoof_detector.dart';

class UpiSpoofSheet extends StatelessWidget {
  const UpiSpoofSheet({
    super.key,
    required this.payload,
    required this.analysis,
    required this.onProceedAnyway,
  });

  final UpiQrPayload payload;
  final UpiRiskAnalysis analysis;
  final VoidCallback onProceedAnyway;

  static void show(
    BuildContext context, {
    required UpiQrPayload payload,
    required VoidCallback onProceedAnyway,
  }) {
    final analysis = UpiSpoofDetector.analyze(payload);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpiSpoofSheet(
        payload: payload,
        analysis: analysis,
        onProceedAnyway: onProceedAnyway,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCritical = analysis.level == UpiRiskLevel.critical;
    final isWarning = analysis.level == UpiRiskLevel.warning;

    final bannerColor = isCritical
        ? AppColors.danger
        : (isWarning ? AppColors.warning : AppColors.safe);

    final containerColor = isCritical
        ? AppColors.dangerContainer
        : (isWarning ? AppColors.warningContainer : AppColors.safeContainer);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: containerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCritical ? Icons.gpp_bad_rounded : (isWarning ? Icons.warning_amber_rounded : Icons.verified_user_rounded),
                  color: bannerColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                child: Text(
                  analysis.headline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: bannerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l16),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m12),
            decoration: BoxDecoration(
              color: containerColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bannerColor.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Claimed Payee Name', analysis.claimedIdentity, theme),
                const Divider(),
                _buildField('Actual Bank VPA (pa)', analysis.actualVpa, theme, isMonospace: true),
                if (payload.amount != null) ...[
                  const Divider(),
                  _buildField('Requested Amount', '₹${payload.amount}', theme),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          Text(
            'Risk Findings:',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs4),
          ...analysis.reasons.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(r, style: theme.textTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.l16),
          if (isCritical)
            KavachButton(
              label: '🛑 Abort Payment (Safety Recommended)',
              variant: KavachButtonVariant.filled,
              onPressed: () => Navigator.pop(context),
            )
          else
            KavachButton(
              label: 'Done / OK',
              variant: KavachButtonVariant.filled,
              onPressed: () => Navigator.pop(context),
            ),
          const SizedBox(height: AppSpacing.s8),
          if (isCritical)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onProceedAnyway();
              },
              child: const Text('I understand the risk, proceed to scan result anyway'),
            ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, ThemeData theme, {bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            style: isMonospace
                ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
