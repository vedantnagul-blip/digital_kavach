import 'package:digital_kavach/core/theme/app_colors.dart';
import 'package:digital_kavach/core/theme/app_radius.dart';
import 'package:digital_kavach/core/theme/app_spacing.dart';
import 'package:digital_kavach/features/scanner/models/qr_payload.dart';
import 'package:flutter/material.dart';
/// QR Guard comparison card showing "Claims vs Actually Pays".
class QrGuardCard extends StatelessWidget {
  const QrGuardCard({
    required this.payload,
    this.claimedName,
    super.key,
  });

  final UpiQrPayload payload;
  final String? claimedName;

  @override
  Widget build(BuildContext context) {
    if (!payload.isUpi) return const SizedBox.shrink();

    final ThemeData t = Theme.of(context);
    final String actualName = payload.payeeName ?? 'Unknown / Not Provided';
    final String vpa = payload.payeeVpa ?? 'Missing VPA';
    final bool hasMismatch = claimedName != null &&
        claimedName!.trim().isNotEmpty &&
        _norm(claimedName!) != _norm(actualName);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l16),
      padding: const EdgeInsets.all(AppSpacing.l16),
      decoration: BoxDecoration(
        color: hasMismatch
            ? AppColors.dangerContainer
            : t.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.rXl,
        border: Border.all(
          color: hasMismatch ? AppColors.danger : t.colorScheme.outlineVariant,
          width: hasMismatch ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                hasMismatch
                    ? Icons.gpp_bad_rounded
                    : Icons.qr_code_2_rounded,
                color: hasMismatch ? AppColors.danger : t.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'UPI QR Guard Analysis',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasMismatch ? AppColors.danger : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (claimedName != null && claimedName!.isNotEmpty) ...<Widget>[
            _infoRow(t, 'Claimed Sender / Sticker:', claimedName!, false),
            const SizedBox(height: 6),
          ],
          _infoRow(t, 'Actual UPI Payee Name:', actualName, hasMismatch),
          const SizedBox(height: 6),
          _infoRow(t, 'Payee VPA (Address):', vpa, false),
          if (payload.amount != null) ...<Widget>[
            const SizedBox(height: 6),
            _infoRow(t, 'Amount Requested:', '₹${payload.amount}', false),
          ],
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: AppRadius.rM,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GOLDEN RULE: UPI PIN is ONLY needed to SEND money. '
                        'Entering a PIN to RECEIVE money is ALWAYS a scam!',
                    style: t.textTheme.labelMedium?.copyWith(
                      color: AppColors.onWarningContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData t, String label, String value, bool highlight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.danger : null,
            ),
          ),
        ),
      ],
    );
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}