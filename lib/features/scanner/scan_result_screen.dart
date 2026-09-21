import 'dart:io';

import 'package:digital_kavach/features/scanner/models/qr_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/info_chip.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import '../../data/ai/ai_router.dart';
import '../../data/rules/score_aggregator.dart';
import 'models/qr_payload.dart';
import 'scanner_service.dart';
import 'verdict_card.dart';
import 'verdict_ui_state.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late HybridScanResult _currentResult;
  bool _deepScanning = false;

  @override
  void initState() {
    super.initState();
    _currentResult = widget.scanResult;
  }

  void _shareResult() {
    final String verdictStr = _currentResult.finalVerdict.verdict.wire;
    final String text = '🛡️ Digital Kavach Scan Verdict: $verdictStr (${_currentResult.finalVerdict.riskScore}/100)\n\n'
        'Explanation: ${_currentResult.finalVerdict.explanationNative}\n\n'
        'Stay safe from scams!';
    Share.share(text);
  }

  Future<void> _runForcedAiDeepScan() async {
    setState(() => _deepScanning = true);
    try {
      final scanner = ref.read(scannerServiceProvider);
      HybridScanResult updated;

      if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        final res = await scanner.scanImage(widget.imagePath!, forceAi: true);
        updated = res.result;
      } else if (widget.inputText != null && widget.inputText!.isNotEmpty) {
        updated = await scanner.scanText(
          widget.inputText!,
          forceAi: true,
          upiParams: widget.qrPayload?.toRuleParams(),
        );
      } else {
        return;
      }

      if (mounted) {
        setState(() {
          _currentResult = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Deep-Scan failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deepScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final AppLocale locale = ref.watch(localeProvider);

    final String screenTitle = <String, String>{
      'en': 'Scan Verdict',
      'hi': 'जाँच परिणाम',
      'mr': 'तपासणी निकाल',
      'ta': 'ஸ்கேன் முடிவு',
      'te': 'స్కాన్ ఫలితం',
      'bn': 'স্ক্যান ফলাফল',
      'gu': 'સ્કેન પરિણામ',
      'kn': 'ಸ್ಕ್ಯಾನ್ ಫಲಿತಾಂಶ',
      'ml': 'സ്കാൻ ഫലം',
      'pa': 'ਸਕੈਨ ਨਤੀਜਾ',
    }[locale.code] ?? 'Scan Verdict';

    final VerdictUiState cardState;
    if (_currentResult.hasAi) {
      cardState = VerdictComplete(_currentResult.finalVerdict);
    } else if (_currentResult.aiError != null) {
      cardState = VerdictAiFailed(
        _currentResult.finalVerdict,
        _currentResult.aiError!,
      );
    } else {
      cardState = VerdictTier1Only(_currentResult.finalVerdict);
    }

    final bool hasNoKeys = _currentResult.aiError is NoProviderException;

    return KavachScaffold(
      title: Text(screenTitle),
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
          if (widget.qrPayload != null && widget.qrPayload!.isUpi)
            QrGuardCard(payload: widget.qrPayload!),

          VerdictCard(
            state: cardState,
            onRetry: _runForcedAiDeepScan,
          ),

          // If AI was skipped or not called yet, show explicit Deep-Scan trigger
          if (!_currentResult.hasAi) ...<Widget>[
            const SizedBox(height: AppSpacing.m12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.rM,
                border: Border.all(color: t.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.psychology_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Reasoning Status',
                        style: t.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentResult.aiSkipped
                        ? (_currentResult.aiSkipReason ??
                            'Fast on-device Tier-1 rules verified this verdict.')
                        : (_currentResult.aiError != null
                            ? (_currentResult.aiError is NoProviderException
                                ? 'Cloud AI is currently offline. Your verdict is fully secured by the on-device Kavach Rule Engine.'
                                : 'Cloud AI check encountered a network timeout. On-device verdict active.')
                            : 'AI deep scan was not triggered.'),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (hasNoKeys)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.safeContainer,
                        borderRadius: AppRadius.rM,
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.shield_rounded, color: AppColors.safe, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'On-Device Protection Active (107 Threat Rules)',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSafeContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    KavachButton(
                      label: 'Deep-Scan with Gemini AI',
                      icon: Icons.auto_awesome_rounded,
                      loading: _deepScanning,
                      variant: KavachButtonVariant.tonal,
                      expand: true,
                      onPressed: _runForcedAiDeepScan,
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
              if (widget.imagePath != null) ...<Widget>[
                ClipRRect(
                  borderRadius: AppRadius.rM,
                  child: Image.file(
                    File(widget.imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.inputText != null && widget.inputText!.isNotEmpty)
                SelectableText(
                  widget.inputText!,
                  style: t.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
