import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/info_chip.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/ai/gemma_plugin_service.dart';
import '../../../data/rules/rule_engine.dart';
import '../../../data/rules/score_aggregator.dart';
import '../../scanner/models/scan_request.dart';
import '../../scanner/models/verdict.dart';
import '../../scanner/verdict_card.dart';
import '../../scanner/verdict_ui_state.dart';

class AiPanelScreen extends ConsumerStatefulWidget {
  const AiPanelScreen({super.key});

  @override
  ConsumerState<AiPanelScreen> createState() => _AiPanelScreenState();
}

class _AiPanelScreenState extends ConsumerState<AiPanelScreen> {
  final TextEditingController _testInput = TextEditingController(
    text: 'प्रिय ग्राहक, तुमचे महावितरण वीज बिल थकीत आहे. आज रात्री ९ वाजता वीज पुरवठा खंडित केला जाईल. ताबडतोब या नंबरवर संपर्क करा: 9876543210',
  );

  final String _modelPath = '/data/local/tmp/gemma-2b-it-cpu-int4.bin';
  bool _checkingFile = false;
  bool _fileExists = false;
  int _fileSizeBytes = 0;
  String _statusMsg = '';

  VerdictUiState? _cardState;
  String _latencyStr = '';

  @override
  void initState() {
    super.initState();
    _checkModelFile();
  }

  Future<void> _checkModelFile() async {
    setState(() => _checkingFile = true);
    try {
      final file = File(_modelPath);
      final exists = await file.exists();
      int size = 0;
      if (exists) {
        size = await file.length();
      }
      setState(() {
        _fileExists = exists;
        _fileSizeBytes = size;
        _checkingFile = false;
        _statusMsg = exists
            ? 'Model file found (${(size / (1024 * 1024)).toStringAsFixed(1)} MB)'
            : 'Model file not found at $_modelPath';
      });
    } catch (e) {
      setState(() {
        _checkingFile = false;
        _statusMsg = 'Error checking model file: $e';
      });
    }
  }

  Future<void> _initializeGemma() async {
    setState(() => _statusMsg = 'Initializing Gemma 2B in device RAM...');
    final gemma = ref.read(gemmaPluginServiceProvider);
    final ok = await gemma.initModel(_modelPath);
    setState(() {
      _statusMsg = ok
          ? '⚡ Gemma 2B INT4 Initialized & Ready for 100% Offline Inference!'
          : 'Failed to initialize Gemma. Verify file permissions and RAM.';
    });
  }

  Future<void> _testInference() async {
    FocusScope.of(context).unfocus();
    final text = _testInput.text.trim();
    if (text.isEmpty) return;

    final gemma = ref.read(gemmaPluginServiceProvider);
    final sw = Stopwatch()..start();

    if (gemma.isReady) {
      final resp = await gemma.analyzeScam(text);
      sw.stop();

      final isCritical = resp != null &&
          (resp.toLowerCase().contains('critical') ||
              resp.toLowerCase().contains('high') ||
              resp.toLowerCase().contains('fraud'));

      final v = Verdict(
        verdict: isCritical ? VerdictLevel.red : VerdictLevel.amber,
        riskScore: isCritical ? 92 : 65,
        patternMatched: 'Edge AI Coercion Reasoning',
        confidence: 0.95,
        redFlags: isCritical
            ? <String>['Detected by local Gemma 2B INT4', resp ?? '']
            : <String>['Under verification'],
        explanationNative: resp ?? 'On-device semantic analysis completed.',
        recommendedActions: const <String>[
          'Do not transfer money or share OTPs',
          'Call 1930 Cyber Fraud Helpline',
        ],
        provider: const AiProviderInfo(
          provider: AiProvider.gemma,
          model: 'Gemma 2B INT4 (Local)',
        ),
      );

      setState(() {
        _latencyStr = '${sw.elapsedMilliseconds}ms (Local NPU/CPU)';
        _cardState = VerdictComplete(v);
      });
    } else {
      // Fall back to rule engine
      final ruleEngine = await ref.read(ruleEngineProvider.future);
      final tier1 = ruleEngine.run(ScanInput(
        text: text,
        source: ScanSource.paste,
        langCode: 'en',
      ));
      sw.stop();

      final v = VerdictBuild.fromTier1(
        hits: tier1.hits,
        score: tier1.score,
        level: tier1.level,
        langCode: 'en',
      );

      setState(() {
        _latencyStr = '${sw.elapsedMilliseconds}ms (Rules Engine)';
        _cardState = VerdictTier1Only(v);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final gemmaReady = ref.watch(gemmaPluginServiceProvider).isReady;

    return KavachScaffold(
      title: const Text('Local Edge AI Diagnostics'),
      scrollable: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Model Status',
          onPressed: _checkModelFile,
        )
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ===== LOCAL HARDWARE & MODEL STATUS =====
          const SectionHeader(
            title: 'On-Device Gemma 2B INT4',
            subtitle: '100% Offline AI · Zero Cloud Costs · Zero Data Leakage',
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.rL,
              border: Border.all(
                color: gemmaReady
                    ? AppColors.safe
                    : (_fileExists ? AppColors.warning : AppColors.danger),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      gemmaReady
                          ? Icons.bolt_rounded
                          : (_fileExists ? Icons.check_circle_outline : Icons.error_outline),
                      color: gemmaReady
                          ? AppColors.safe
                          : (_fileExists ? AppColors.warning : AppColors.danger),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gemmaReady
                          ? 'Gemma 2B: Active & Loaded'
                          : (_fileExists ? 'Weight File Detected (Not Loaded)' : 'Weight File Missing'),
                      style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Storage Path: $_modelPath',
                  style: t.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
                if (_statusMsg.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _statusMsg,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: gemmaReady ? AppColors.safe : t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (!_checkingFile && _fileExists && !gemmaReady)
                  KavachButton(
                    label: 'Initialize Gemma into Memory',
                    icon: Icons.memory_rounded,
                    onPressed: _initializeGemma,
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl24),

          // ===== INFERENCE TEST BENCH =====
          const SectionHeader(
            title: 'Local Scan Playground',
            subtitle: 'Test verncular scam reasoning offline',
          ),
          TextField(
            controller: _testInput,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Paste SMS/WhatsApp message...',
            ),
          ),
          const SizedBox(height: 12),
          KavachButton(
            label: gemmaReady ? 'Analyze with Local Gemma 2B' : 'Analyze with 570+ Rules Engine',
            icon: gemmaReady ? Icons.bolt_rounded : Icons.offline_bolt_outlined,
            onPressed: _testInference,
          ),

          if (_cardState != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                InfoChip(
                  label: gemmaReady ? 'Edge AI Verdict' : 'Rules Verdict',
                  icon: Icons.analytics_rounded,
                ),
                const Spacer(),
                Text(
                  _latencyStr,
                  style: t.textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VerdictCard(state: _cardState!),
          ],
        ],
      ),
    );
  }
}
