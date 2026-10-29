import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/user_prefs.dart';
import '../../data/local/verdict_cache.dart';
import '../../data/rules/rule_engine.dart';
import '../../data/rules/score_aggregator.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import 'ai_keys_store.dart';
import 'ai_provider.dart';
import 'budget_guard.dart';
import 'chatgpt_provider.dart';
import 'circuit_breaker.dart';
import 'gemini_provider.dart';
import 'gemma_plugin_service.dart';
import 'grok_provider.dart';
import 'threat_memory_store.dart';

final Provider<AiRouter> aiRouterProvider = Provider<AiRouter>((Ref ref) {
  final Box<dynamic> aiBox = Hive.box<dynamic>(HiveBoxes.aiState);
  return AiRouter(
    cache: HiveVerdictCache(Hive.box<dynamic>(HiveBoxes.cache)),
    keysStore: ref.watch(aiKeysStoreProvider),
    prefs: ref.watch(userPrefsProvider),
    grokBreaker: CircuitBreaker(aiBox, provider: 'grok'),
    geminiBreaker: CircuitBreaker(aiBox, provider: 'gemini'),
    chatgptBreaker: CircuitBreaker(aiBox, provider: 'chatgpt'),
    budget: BudgetGuard(aiBox),
    firestore: FirebaseFirestore.instance,
    gemmaService: ref.watch(gemmaPluginServiceProvider),
  );
});

/// Hybrid scan result — includes both Tier-1 and AI verdicts.
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
    required this.chatgptBreaker,
    required this.budget,
    required this.firestore,
    required this.gemmaService,
  });

  final VerdictCache cache;
  final AiKeysStore keysStore;
  final UserPrefs prefs;
  final CircuitBreaker grokBreaker;
  final CircuitBreaker geminiBreaker;
  final CircuitBreaker chatgptBreaker;
  final BudgetGuard budget;
  final FirebaseFirestore firestore;
  final GemmaPluginService gemmaService;

  /// SMART HYBRID SCAN:
  /// 1. Always run offline rules first (5 ms)
  /// 2. If Gemma on-device model is active, run 100% offline Gemma analysis
  /// 3. Cloud AI (Gemini / ChatGPT / Grok) is commented out
  Future<HybridScanResult> hybridAnalyze(
      ScanRequest req,
      RuleEngine ruleEngine, {
        bool forceAi = false,
      }) async {
    // ============================================================
    // STEP 1: OFFLINE RULES (always, 0 cost, ~5 ms)
    // ============================================================
    final Tier1Result tier1 = ruleEngine.run(ScanInput(
      text: req.text,
      source: req.source,
      langCode: req.langCode,
      senderTitle: req.senderTitle,
      upiParams: req.upiParams,
    ));

    final Verdict tier1Verdict = VerdictBuild.fromTier1(
      hits: tier1.hits,
      score: tier1.score,
      level: tier1.level,
      langCode: req.langCode,
    );

    AppLogger.i(
      'Hybrid: Tier-1 score=${tier1.score} level=${tier1.level.wire} '
          'hits=${tier1.hits.length}',
    );

    // ============================================================
    // STEP 2: 100% OFFLINE GEMMA ON-DEVICE AI
    // ============================================================
    if (gemmaService.isReady) {
      AppLogger.i('Invoking 100% Offline Edge AI: Gemma 2B INT4', tag: 'ai');
      try {
        final String? gemmaResp = await gemmaService.analyzeScam(req.text);
        if (gemmaResp != null && gemmaResp.isNotEmpty) {
          final isCritical = gemmaResp.toLowerCase().contains('critical') ||
              gemmaResp.toLowerCase().contains('high') ||
              gemmaResp.toLowerCase().contains('fraud');

          final Verdict gemmaVerdict = Verdict(
            verdict: isCritical ? VerdictLevel.red : (tier1.level == VerdictLevel.amber ? VerdictLevel.amber : VerdictLevel.green),
            riskScore: isCritical ? 88 : tier1.score,
            confidence: isCritical ? ConfidenceLevel.high : ConfidenceLevel.medium,
            category: 'Offline Edge AI (Gemma)',
            action: isCritical ? VerdictAction.blockReport : VerdictAction.safe,
            title: isCritical ? 'Suspicious Coercion Pattern' : 'Safe Content',
            explanationEn: gemmaResp,
            explanationNative: gemmaResp,
            provider: const AiProviderInfo(provider: AiProvider.tier1),
            modelId: 'gemma-2b-int4-offline',
            cachedAt: DateTime.now(),
          );

          return HybridScanResult(
            finalVerdict: gemmaVerdict,
            tier1Result: tier1,
            aiVerdict: gemmaVerdict,
          );
        }
      } catch (e) {
        AppLogger.w('Offline Gemma reasoning error, falling back to rules: $e', tag: 'ai');
      }
    }

    // ============================================================
    // STEP 3: CLOUD AI (GEMINI / CHATGPT / GROK) COMMENTED OUT
    // ============================================================
    /*
    // ── CLOUD GEMINI / CHATGPT / GROK DEEP SCAN DISABLED ──
    // Commented out to ensure zero cloud dependence, zero secret exposure,
    // and full on-device privacy compliance for hackathon demonstration.
    /*
    final AiConfig config = await keysStore.getConfig();
    if (config.geminiKey != null && config.geminiKey!.isNotEmpty && !geminiBreaker.isOpen()) {
      try {
        final AiProviderClient gemini = GeminiProvider(
          apiKey: config.geminiKey!,
          modelId: config.geminiModel,
        );
        final Verdict v = await gemini.analyze(req);
        return HybridScanResult(finalVerdict: v, tier1Result: tier1, aiVerdict: v);
      } catch (e) {
        AppLogger.w('Cloud Gemini failed: $e', tag: 'ai');
      }
    }
    */
    */

    // Return the offline Tier-1 rules verdict
    return HybridScanResult(
      finalVerdict: tier1Verdict,
      tier1Result: tier1,
      aiSkipped: true,
      aiSkipReason: 'On-device Kavach Guard verified (Offline Mode Active)',
    );
  }

  /// Direct AI scan (Disabled in offline mode — returns cached or throws)
  Future<Verdict> analyze(ScanRequest req) async {
    final String hash = HiveVerdictCache.hashOf(req.text);

    // Local cache check
    final Verdict? localHit = await cache.byHash(hash);
    if (localHit != null) {
      AppLogger.i('CacheHit(Local)', tag: 'ai');
      return localHit.copyWith(
        provider: const AiProviderInfo(provider: AiProvider.cached),
      );
    }

    /*
    // ── CLOUD PROVIDER CALLS COMMENTED OUT (OFFLINE ONLY) ──
    */

    throw const NoProviderException('Cloud AI disabled — running purely on on-device Gemma Edge AI');
  }

  Future<void> _saveVerdictLocal(String hash, Verdict v, [String? originalText]) async {
    await cache.put(hash, v);

    if (v.verdict == VerdictLevel.red && originalText != null && originalText.trim().isNotEmpty) {
      try {
        if (Hive.isBoxOpen(HiveBoxes.cache)) {
          final threatStore = ThreatMemoryStore(Hive.box<dynamic>(HiveBoxes.cache));
          await threatStore.learnPattern(
            text: originalText,
            family: v.patternMatched,
            redFlags: v.redFlags,
            isScam: true,
          );
        }
      } catch (e) {
        AppLogger.w('Failed to index threat memory: $e');
      }
    }
  }

  Future<bool> secondOpinion(ScanRequest req, Verdict primaryVerdict) async {
    return false;
  }
}
