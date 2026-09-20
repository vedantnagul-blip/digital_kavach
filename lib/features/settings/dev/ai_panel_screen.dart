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
import '../../../data/ai/ai_provider.dart';
import '../../../data/ai/ai_router.dart';
import '../../../data/ai/circuit_breaker.dart';
import '../../../data/ai/threat_memory_store.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/local/user_prefs.dart';
import '../../../data/rules/rule_engine.dart';
import '../../../data/rules/score_aggregator.dart';
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
  final TextEditingController _testInput = TextEditingController();

  bool _testingHybrid = false;
  VerdictUiState? _cardState;
  HybridScanResult? _lastHybrid;
  String _latencyStr = '';

  @override
  void initState() {
    super.initState();
    _testInput.text =
        'DCP Cyber Crime Delhi Police: An FIR has been registered against your Aadhaar card for money laundering. You are under digital arrest. Transfer Rs 98,500 security deposit immediately.';
  }

  @override
  void dispose() {
    _testInput.dispose();
    super.dispose();
  }

  /// Run full Smart Hybrid Scan (Tier 1 offline rules + AI if needed)
  Future<void> _runHybridScan({bool forceAi = false}) async {
    FocusScope.of(context).unfocus();
    if (_testInput.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select sample scam text to scan!')),
      );
      return;
    }

    setState(() {
      _testingHybrid = true;
      _cardState = null;
      _lastHybrid = null;
    });

    await ref.read(userPrefsProvider).setConsentAi(true);

    CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'gemini').resetForDev();
    CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'grok').resetForDev();

    final RuleEngine engine = await ref.read(ruleEngineProvider.future);
    final ScanRequest req = ScanRequest(text: _testInput.text.trim(), source: ScanSource.paste);
    final Stopwatch sw = Stopwatch()..start();

    try {
      final HybridScanResult result = await ref
          .read(aiRouterProvider)
          .hybridAnalyze(req, engine, forceAi: forceAi);
      sw.stop();

      setState(() {
        _lastHybrid = result;
        if (result.hasAi) {
          _cardState = VerdictComplete(result.finalVerdict);
        } else if (result.aiError != null) {
          _cardState = VerdictAiFailed(result.finalVerdict, result.aiError!);
        } else {
          _cardState = VerdictTier1Only(result.finalVerdict);
        }
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
    } finally {
      if (mounted) setState(() => _testingHybrid = false);
    }
  }

  /// OFFLINE ONLY: Just rules, no AI call
  Future<void> _runOfflineOnly() async {
    FocusScope.of(context).unfocus();
    if (_testInput.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or select sample scam text to scan!')),
      );
      return;
    }

    setState(() {
      _cardState = null;
      _lastHybrid = null;
    });

    final RuleEngine engine = await ref.read(ruleEngineProvider.future);
    final Stopwatch sw = Stopwatch()..start();

    final Tier1Result tier1 = engine.run(ScanInput(
      text: _testInput.text.trim(),
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

  void _setPreset(String text) {
    setState(() {
      _testInput.text = text;
      _cardState = null;
      _lastHybrid = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final threatStore = ref.watch(threatMemoryStoreProvider);
    final learnedCount = threatStore.getAllLearnedThreats().length;

    return KavachScaffold(
      title: const Text('Dev · Agentic AI Layer'),
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
          // ===== SECURITY SHIELD OVERVIEW (NO RAW KEYS IN UI) =====
          const SectionHeader(
            title: 'AI Security & Threat Intelligence',
            subtitle: 'Zero client-side key exposure • Build-time cryptographic protection',
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.safeContainer,
              borderRadius: AppRadius.rL,
              border: Border.all(color: AppColors.safe, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.verified_user_rounded,
                        color: AppColors.safe, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Client Key Exposure Eliminated',
                        style: t.textTheme.titleMedium?.copyWith(
                          color: AppColors.onSafeContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'In production releases, API credentials are never displayed, entered, or stored in plaintext on client devices. LLM credentials are securely compiled at build time, protecting against reverse engineering and quota abuse.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSafeContainer,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Security Architecture Badges
          Row(
            children: <Widget>[
              Expanded(
                child: _EngineBadge(
                  icon: Icons.shield_rounded,
                  title: 'Tier-1 Offline',
                  subtitle: '107 Scam Rules',
                  color: AppColors.safe,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EngineBadge(
                  icon: Icons.psychology_rounded,
                  title: 'Tier-2 AI',
                  subtitle: 'Gemini & Groq',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EngineBadge(
                  icon: Icons.memory_rounded,
                  title: 'Threat Memory',
                  subtitle: '$learnedCount Signatures',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),

          // ===== STATE CONTROL =====
          const SizedBox(height: AppSpacing.xxl24),
          const SectionHeader(
            title: 'State & Cache Controls',
            subtitle: 'Reset circuit breakers and local verdict memory',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ActionChip(
                avatar: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Breakers'),
                onPressed: () {
                  CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'gemini')
                      .resetForDev();
                  CircuitBreaker(Hive.box<dynamic>(HiveBoxes.aiState), provider: 'grok')
                      .resetForDev();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gemini & Grok circuit breakers reset.')),
                  );
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.cleaning_services_rounded, size: 16),
                label: const Text('Clear Verdict Cache'),
                onPressed: () {
                  Hive.box<dynamic>(HiveBoxes.cache).clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline verdict cache cleared.')),
                  );
                },
              ),
            ],
          ),

          // ===== PLAYGROUND =====
          const SizedBox(height: AppSpacing.xxl24),
          const SectionHeader(
            title: 'Hybrid ReAct Playground',
            subtitle: 'Test offline regex + cloud LLM arbitration',
          ),
          const SizedBox(height: 8),

          Text('Quick Scam Presets:', style: t.textTheme.labelMedium),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollToDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ActionChip(
                  avatar: const Text('🚨', style: TextStyle(fontSize: 14)),
                  label: const Text('Digital Arrest'),
                  onPressed: () => _setPreset(
                    'Supreme Court & Mumbai Police Notice: Arrest warrant issued against Aadhaar #4928-1029-4820 for illegal drug parcel. Join Skype video interrogation room immediately or police raid in 30 minutes.',
                  ),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Text('⚡', style: TextStyle(fontSize: 14)),
                  label: const Text('Electricity Bill'),
                  onPressed: () => _setPreset(
                    'Dear Consumer, Your electricity power supply will be disconnected tonight at 9:30 PM because previous month bill was not updated. Please immediately contact electricity officer Mr. Sharma at 9876543210.',
                  ),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Text('💸', style: TextStyle(fontSize: 14)),
                  label: const Text('UPI Refund'),
                  onPressed: () => _setPreset(
                    'Dear Customer, Rs 4,999 cash bonus credited to your PhonePe wallet. Open upi://pay?pa=refund@ybl&am=4999&pn=PhonePeBonus to accept payment into your bank.',
                  ),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Text('🚗', style: TextStyle(fontSize: 14)),
                  label: const Text('e-Challan APK'),
                  onPressed: () => _setPreset(
                    'Traffic Police Alert: Pending traffic challan of Rs 1,000 on your vehicle MH12AB1234. Download official Parivahan app from http://echallan-parivahan-vahan.apk to pay fine before court notice.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          TextField(
            controller: _testInput,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Scam message to analyze',
              hintText: 'Paste suspicious SMS, WhatsApp message, or notice...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: KavachButton(
                  label: 'Smart Hybrid Scan',
                  icon: Icons.auto_awesome_rounded,
                  loading: _testingHybrid,
                  onPressed: () => _runHybridScan(forceAi: false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KavachButton(
                  label: 'Offline Only (5ms)',
                  icon: Icons.bolt_rounded,
                  variant: KavachButtonVariant.tonal,
                  onPressed: _runOfflineOnly,
                ),
              ),
            ],
          ),

          if (_latencyStr.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(Icons.timer_outlined, size: 16, color: t.colorScheme.outline),
                const SizedBox(width: 4),
                Text('Scan Latency: $_latencyStr', style: t.textTheme.bodySmall),
                const Spacer(),
                if (_lastHybrid != null) ...<Widget>[
                  Text(
                    _lastHybrid!.hasAi ? 'Engine: Tier-1 + AI' : 'Engine: Tier-1 Offline',
                    style: t.textTheme.bodySmall?.copyWith(
                      color: _lastHybrid!.hasAi ? AppColors.primary : AppColors.safe,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],

          if (_cardState != null) ...<Widget>[
            const SizedBox(height: 16),
            VerdictCard(state: _cardState!),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _EngineBadge extends StatelessWidget {
  const _EngineBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: AppRadius.rM,
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: t.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: t.textTheme.bodySmall?.copyWith(fontSize: 10, color: t.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
