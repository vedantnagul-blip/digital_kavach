import 'dart:io';

import 'package:digital_kavach/features/scanner/models/qr_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../../data/ai/ai_router.dart';
import '../../data/rules/score_aggregator.dart';
import 'models/qr_payload.dart';
import 'verdict_card.dart';
import 'verdict_ui_state.dart';

class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({
    required this.scanResult,
    this.inputText,
    this.imagePath,
    this.qrPayload,
    super.key,
  });

  final HybridScanResult scanResult;
  final String? inputText;
  final String? imagePath;
  final UpiQrPayload? qrPayload;

  void _shareResult() {
    final String verdictStr = scanResult.finalVerdict.verdict.wire;
    final String text = '🛡️ Digital Kavach Scan Verdict: $verdictStr (${scanResult.finalVerdict.riskScore}/100)\n\n'
        'Explanation: ${scanResult.finalVerdict.explanationNative}\n\n'
        'Stay safe from scams!';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData t = Theme.of(context);
    final VerdictUiState cardState = scanResult.hasAi
        ? VerdictComplete(scanResult.finalVerdict)
        : VerdictTier1Only(scanResult.finalVerdict);

    return KavachScaffold(
      title: const Text('Scan Verdict'),
      scrollable: true,
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
              if (imagePath != null) ...<Widget>[
                ClipRRect(
                  borderRadius: AppRadius.rM,
                  child: Image.file(
                    File(imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (inputText != null && inputText!.isNotEmpty)
                SelectableText(
                  inputText!,
                  style: t.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
}