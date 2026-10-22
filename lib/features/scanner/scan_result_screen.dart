import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import 'models/qr_payload.dart';
import 'models/scam_verdict.dart';
import 'models/verdict.dart';
import 'qr_guard_card.dart';
import 'scanner_strings.dart';
import 'verdict_card.dart';
import 'widgets/scam_bait_dialog.dart';

class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({
    super.key,
    required this.verdict,
    required this.inputPreview,
    this.qrPayload,
  });

  final ScanVerdict verdict;
  final String inputPreview;
  final UpiQrPayload? qrPayload;

  void _shareResult() {
    final String text =
        'Digital Kavach Threat Alert:\nVerdict: ${verdict.confidence.name.toUpperCase()}\n'
        'Reason: ${verdict.title}\n\nStay protected with Digital Kavach.';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final AppLocale locale = ref.watch(localeProvider);
    final ScannerStrings s = ref.watch(scannerStringsProvider);

    final VerdictCardState cardState =
        VerdictPresentationMapper.fromScanVerdict(verdict, locale);

    final bool isDangerous = verdict.riskTier == RiskTier.critical ||
        verdict.riskTier == RiskTier.high ||
        verdict.confidence == ConfidenceLevel.phishing ||
        verdict.confidence == ConfidenceLevel.malicious;

    return KavachScaffold(
      title: s.verdictTitle,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.share_rounded),
          tooltip: 'Share Verdict',
          onPressed: _shareResult,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (qrPayload != null && qrPayload!.isUpi)
            QrGuardCard(payload: qrPayload!),

          VerdictCard(state: cardState),

          if (isDangerous) ...[
            const SizedBox(height: AppSpacing.l16),
            Container(
              padding: const EdgeInsets.all(AppSpacing.l16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: AppRadius.rM,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Hackathon Feature: AI ScamBaiter',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs4),
                  Text(
                    'Deploy an on-device decoy persona to waste scammer time & trick them into sharing bank/UPI details.',
                    style: t.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.m12),
                  KavachButton(
                    label: '🎣 Deploy AI Bait-Trap Bot',
                    variant: KavachButtonVariant.filled,
                    onPressed: () => ScamBaitDialog.show(
                      context,
                      scamType: verdict.title,
                      originalText: inputPreview,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl24),
          _buildInputPreview(t),
          const SizedBox(height: AppSpacing.l16),

          KavachButton(
            label: 'Done / Back to Home',
            variant: KavachButtonVariant.outlined,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPreview(ThemeData t) {
    return ExpansionTile(
      title: Text('View Scanned Content', style: t.textTheme.titleSmall),
      leading: const Icon(Icons.find_in_page_rounded),
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.rM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SelectableText(
                inputPreview,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
