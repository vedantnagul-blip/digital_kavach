import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../core/errors/kavach_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/info_chip.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/ai/ai_keys_store.dart';
import '../../../data/ai/ai_router.dart';
import '../../../data/ai/circuit_breaker.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/local/user_prefs.dart';
import '../../../data/rules/rule_engine.dart';
import '../../../data/rules/score_aggregator.dart';
import '../../../features/scanner/dev_harness_screen.dart';
import '../../../features/scanner/models/scan_request.dart';
import '../../../features/scanner/models/verdict.dart';
import '../../../features/scanner/verdict_card.dart';
import '../../../features/scanner/verdict_ui_state.dart';

class AiPanelScreen extends ConsumerStatefulWidget {
  const AiPanelScreen({super.key});
  @override
  ConsumerState<AiPanelScreen> createState() => _AiPanelScreenState();
}

class _AiPanelScreenState extends ConsumerState<AiPanelScreen> {
  final TextEditingController _gKey = TextEditingController();
  final TextEditingController _gModel = TextEditingController();
  final TextEditingController _xKey = TextEditingController();
  final TextEditingController _xModel = TextEditingController();
  final TextEditingController _testInput = TextEditingController();

  bool _obscureGeminiKey = true;
  bool _obscureGrokKey = true;

  VerdictUiState? _cardState;
  HybridScanResult? _lastHybrid;
  String _latencyStr = '';

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final AiConfig cfg = await ref.read(aiKeysStoreProvider).getConfig();
    setState(() {
      _gKey.text = cfg.geminiKey ?? '';
      _gModel.text = (cfg.geminiModel != null && cfg.geminiModel!.isNotEmpty)
          ? cfg.geminiModel!
          : 'gemini-1.5-flash';
      _xKey.text = cfg.grokKey ?? '';
      _xModel.text = cfg.grokModel ?? 'grok-2-latest';
    });
  }

  Future<void> _saveKeys() async {
    await ref.read(aiKeysStoreProvider).saveLocalOverrides(
      AiConfig(
        geminiKey: _gKey.text.trim(),
        geminiModel: _gModel.text.trim(),
        grokKey: _xKey.text.trim(),
        grokModel: _xModel.text.trim(),
      ),
    );
  }

  /// HYBRID SCAN: Rules first, AI only when needed, then merge
  Future<void> _runHybridScan({bool forceAi = false}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _cardState = null;
      _lastHybrid = null;
    });

    await ref.read(userPrefsProvider).setConsentAi(true);
    await _saveKeys();
    CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'gemini')
        .resetForDev();
    CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'grok')
        .resetForDev();

    final RuleEngine engine = await ref.read(ruleEngineProvider.future);
    final ScanRequest req =
    ScanRequest(text: _testInput.text, source: ScanSource.paste);
    final Stopwatch sw = Stopwatch()..start();

    try {
      final HybridScanResult result = await ref
          .read(aiRouterProvider)
          .hybridAnalyze(req, engine, forceAi: forceAi);
      sw.stop();

      setState(() {
        _lastHybrid = result;
        _cardState = result.hasAi
            ? VerdictComplete(result.finalVerdict)
            : VerdictTier1Only(result.finalVerdict);
        _latencyStr = '${sw.elapsedMilliseconds}ms';
      });
    } on KavachException catch (e) {
      sw.stop();
      AppLogger.e('Hybrid scan failed', error: e);
      setState(() {
        _cardState = VerdictAiFailed(
          VerdictBuild.fromTier1(
            hits: const [],
            score: 0,
            level: VerdictLevel.green,
            langCode: 'en',
          ),
          e,
        );
        _latencyStr = '${sw.elapsedMilliseconds}ms (Failed)';
      });
    }
  }

  /// OFFLINE ONLY: Just rules, no AI call
  Future<void> _runOfflineOnly() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _cardState = null;
      _lastHybrid = null;
    });

    final RuleEngine engine = await ref.read(ruleEngineProvider.future);
    final Stopwatch sw = Stopwatch()..start();

    final Tier1Result tier1 = engine.run(ScanInput(
      text: _testInput.text,
      source: ScanSource.paste,
      langCode: 'en',
    ));
    sw.stop();

    final Verdict v = VerdictBuild.fromTier1(
      hits: tier1.hits,
      score: tier1.score,
      level: tier1.level,
      langCode: 'en',
    );

    setState(() {
      _cardState = VerdictTier1Only(v);
      _lastHybrid = HybridScanResult(
        finalVerdict: v,
        tier1Result: tier1,
        aiSkipped: true,
        aiSkipReason: 'Offline mode',
      );
      _latencyStr = '${sw.elapsedMilliseconds}ms (Offline)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return KavachScaffold(
      title: const Text('Dev · AI Layer'),
      scrollable: true,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.science_rounded),
          tooltip: 'Rules Harness',
          onPressed: () => context.push('/dev/rules'),
        )
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ===== API KEYS =====
          const SectionHeader(title: 'API Keys Config'),
          TextField(
            controller: _gKey,
            obscureText: _obscureGeminiKey,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              suffixIcon: IconButton(
                icon: Icon(_obscureGeminiKey
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: () =>
                    setState(() => _obscureGeminiKey = !_obscureGeminiKey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gModel,
            decoration: const InputDecoration(
              labelText: 'Gemini Model (gemini-1.5-flash)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _xKey,
            obscureText: _obscureGrokKey,
            decoration: InputDecoration(
              labelText: 'Grok API Key (Primary)',
              suffixIcon: IconButton(
                icon: Icon(_obscureGrokKey
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: () =>
                    setState(() => _obscureGrokKey = !_obscureGrokKey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _xModel,
            decoration: const InputDecoration(
              labelText: 'Grok Model (grok-2-latest)',
            ),
          ),
          const SizedBox(height: 12),
          KavachButton(
            label: 'Save Config',
            onPressed: () async {
              await _saveKeys();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keys saved locally')),
                );
              }
            },
          ),

          // ===== STATE CONTROL =====
          const SizedBox(height: AppSpacing.xxl24),
          const SectionHeader(title: 'State Control'),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ActionChip(
                label: const Text('Reset Breaker'),
                onPressed: () {
                  CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState),
                      provider: 'gemini')
                      .resetForDev();
                  CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState),
                      provider: 'grok')
                      .resetForDev();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All breakers reset')));
                },
              ),
              ActionChip(
                label: const Text('Clear Cache'),
                onPressed: () {
                  Hive.box<dynamic>(HiveBoxes.cache).clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')));
                },
              ),
            ],
          ),

          // ===== PLAYGROUND =====
          const SizedBox(height: AppSpacing.xxl24),
          const SectionHeader(
            title: 'Hybrid Playground',
            subtitle: 'Rules run first, AI only if needed',
          ),
          TextField(
            controller: _testInput,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Paste scam text to analyze...',
            ),
          ),
          const SizedBox(height: 12),

          // Three scan modes
          Row(
            children: <Widget>[
              Expanded(
                child: KavachButton(
                  label: 'Smart Hybrid',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: () => _runHybridScan(forceAi: false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KavachButton(
                  label: 'Force AI',
                  variant: KavachButtonVariant.tonal,
                  icon: Icons.psychology_rounded,
                  onPressed: () => _runHybridScan(forceAi: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          KavachButton(
            label: 'Offline Only (Rules)',
            variant: KavachButtonVariant.outlined,
            icon: Icons.bolt_rounded,
            expand: true,
            onPressed: _runOfflineOnly,
          ),

          // ===== RESULT DISPLAY =====
          if (_cardState != null) ...<Widget>[
            const SizedBox(height: 24),
            _buildScoreBreakdown(t),
            const SizedBox(height: 12),
            VerdictCard(state: _cardState!),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(ThemeData t) {
    if (_lastHybrid == null) return const SizedBox.shrink();
    final HybridScanResult r = _lastHybrid!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.rL,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const InfoChip(
                  label: 'Result', icon: Icons.analytics_rounded),
              const Spacer(),
              Text(
                _latencyStr,
                style: t.textTheme.labelMedium
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _scoreRow(t, '⚡ Offline Rules',
              '${r.tier1Result.score}/100 · ${r.tier1Result.level.wire}',
              _colorFor(r.tier1Result.level)),
          const SizedBox(height: 6),
          if (r.hasAi)
            _scoreRow(
              t,
              '🧠 AI Deep-Scan',
              '${r.aiVerdict!.riskScore}/100 · ${r.aiVerdict!.verdict.wire}',
              _colorFor(r.aiVerdict!.verdict),
            )
          else
            _scoreRow(
              t,
              '🧠 AI Deep-Scan',
              r.aiSkipReason ?? 'Not called',
              t.colorScheme.onSurfaceVariant,
            ),
          const Divider(height: 20),
          _scoreRow(
            t,
            '🎯 FINAL VERDICT',
            '${r.finalVerdict.riskScore}/100 · ${r.finalVerdict.verdict.wire}',
            _colorFor(r.finalVerdict.verdict),
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(ThemeData t, String label, String value, Color color,
      {bool bold = false}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: t.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _colorFor(VerdictLevel l) {
    switch (l) {
      case VerdictLevel.green:
        return AppColors.safe;
      case VerdictLevel.amber:
        return AppColors.warning;
      case VerdictLevel.red:
        return AppColors.danger;
    }
  }
}