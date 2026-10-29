import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/user_prefs.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import '../rules/rule_engine.dart';
import '../rules/score_aggregator.dart';
import 'ai_budget.dart';
import 'ai_keys_store.dart';
import 'ai_provider.dart';
import 'circuit_breaker.dart';
import 'gemini_provider.dart';
import 'gemma_plugin_service.dart';
import 'grok_provider.dart';
import 'threat_memory_store.dart';

final Provider<AiRouter> aiRouterProvider = Provider<AiRouter>((Ref ref) {
  final Box<dynamic> aiBox = Hive.box<dynamic>(HiveBoxes.aiState);
  final Box<dynamic> cacheBox = Hive.box<dynamic>(HiveBoxes.cache);
  return AiRouter(
    cache: cacheBox,
    keysStore: ref.watch(aiKeysStoreProvider),
    prefs: ref.watch(userPrefsProvider),
    grokBreaker: CircuitBreaker(aiBox, provider: 'grok'),
    geminiBreaker: CircuitBreaker(aiBox, provider: 'gemini'),
    budget: ref.watch(aiBudgetProvider),
    gemmaService: ref.watch(gemmaPluginServiceProvider),
  );
});

class HybridScanResult {
  const HybridScanResult({
    required this.finalVerdict,
    required this.tier1Result,
    this.aiVerdict,
    this.aiError,
    this.aiSkipped = false,
    this.aiSkipReason,
  });

  final Verdict finalVerdict;
  final Tier1Result tier1Result;
  final Verdict? aiVerdict;
  final KavachException? aiError;
  final bool aiSkipped;
  final String? aiSkipReason;

  Verdict get verdict => finalVerdict;
  bool get hasAi => aiVerdict != null;
  bool get tier1RedNeverDowngraded =>
      tier1Result.level == VerdictLevel.red &&
      finalVerdict.verdict == VerdictLevel.red;
}

class AiRouter {
  AiRouter({
    required this.cache,
    required this.keysStore,
    required this.prefs,
    required this.grokBreaker,
    required this.geminiBreaker,
    required this.budget,
    required this.gemmaService,
  });

  final Box<dynamic> cache;
  final AiKeysStore keysStore;
  final UserPrefs prefs;
  final CircuitBreaker grokBreaker;
  final CircuitBreaker geminiBreaker;
  final AiBudget budget;
  final GemmaPluginService gemmaService;

  static const String _offlineCachePrefix = 'cache_v2_';

  Future<HybridScanResult> hybridAnalyze(
    ScanRequest req,
    RuleEngine ruleEngine, {
    bool forceAi = false,
  }) async {
    // ── TIER 1: On-Device Heuristic Rule Engine (<5ms) ──
    final Tier1Result t1 = ruleEngine.evaluate(req.text, upiParams: req.upiParams);
    final String hash = _hashText(req.text);

    // If Tier 1 found Red risk, never downgrade
    if (t1.level == VerdictLevel.red && !forceAi) {
      final Verdict v = ScoreAggregator.buildTier1Verdict(t1, req.langCode);
      return HybridScanResult(
        finalVerdict: v,
        tier1Result: t1,
        aiSkipped: true,
        aiSkipReason: 'Tier 1 high-risk match (offline certified)',
      );
    }

    // ── TIER 2: 100% OFFLINE EDGE AI (Gemma INT4) ──
    if (gemmaService.isReady) {
      AppLogger.i('Invoking 100% Offline Edge AI: Gemma 2B INT4', tag: 'ai');
      try {
        final String? gemmaResp = await gemmaService.analyzeScam(req.text);
        if (gemmaResp != null && gemmaResp.isNotEmpty) {
          final isCritical = gemmaResp.toLowerCase().contains('critical') ||
              gemmaResp.toLowerCase().contains('high') ||
              gemmaResp.toLowerCase().contains('fraud');

          final Verdict gemmaVerdict = Verdict(
            verdict: isCritical ? VerdictLevel.red : (t1.level == VerdictLevel.amber ? VerdictLevel.amber : VerdictLevel.green),
            riskScore: isCritical ? 88 : t1.score,
            confidence: isCritical ? ConfidenceLevel.high : ConfidenceLevel.medium,
            category: 'Offline Edge AI (Gemma)',
            action: isCritical ? VerdictAction.blockReport : VerdictAction.safe,
            title: isCritical ? 'Suspicious Coercion Pattern' : 'Safe Content',
            explanationEn: gemmaResp,
            explanationNative: gemmaResp,
            provider: AiProvider.tier1,
            modelId: 'gemma-2b-int4-offline',
            cachedAt: DateTime.now(),
          );

          return HybridScanResult(
            finalVerdict: gemmaVerdict,
            tier1Result: t1,
            aiVerdict: gemmaVerdict,
          );
        }
      } catch (e) {
        AppLogger.w('Offline Gemma reasoning error, falling back to rules: $e', tag: 'ai');
      }
    }

    /*
    // ── CLOUD GEMINI DEEP SCAN DISABLED (100% OFFLINE GEMMA ONLY) ──
    // Commented out to ensure zero cloud dependence, zero secret exposure,
    // and full on-device privacy compliance for hackathon demonstration.
    /*
    if (config.geminiKey != null && config.geminiKey!.isNotEmpty && !geminiBreaker.isOpen()) {
      try {
        AppLogger.i('Attempting Cloud Gemini Scan', tag: 'ai');
        final AiProviderClient gemini = GeminiProvider(
          apiKey: config.geminiKey!,
          modelId: config.geminiModel,
        );
        final Verdict v = await gemini.analyze(req);
        return HybridScanResult(finalVerdict: v, tier1Result: t1, aiVerdict: v);
      } catch (e) {
        AppLogger.w('Cloud Gemini failed: $e', tag: 'ai');
      }
    }
    */
    */

    // Fallback directly to 570+ rules verdict
    final Verdict v = ScoreAggregator.buildTier1Verdict(t1, req.langCode);
    return HybridScanResult(
      finalVerdict: v,
      tier1Result: t1,
      aiSkipped: true,
      aiSkipReason: 'On-device rule execution (Cloud Gemini disabled)',
    );
  }

  String _hashText(String text) {
    return sha256.convert(utf8.encode(text)).toString();
  }
}
