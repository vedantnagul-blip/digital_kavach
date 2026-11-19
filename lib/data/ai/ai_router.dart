// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
// import 'package:workmanager/workmanager.dart';
//
// import '../../core/errors/kavach_exception.dart';
// import '../../core/utils/app_logger.dart';
// import '../../data/local/hive_boxes.dart';
// import '../../data/local/user_prefs.dart';
// import '../../data/local/verdict_cache.dart';
// import '../../data/rules/rule_engine.dart';
// import '../../data/rules/score_aggregator.dart';
// import '../../features/scanner/models/scan_request.dart';
// import '../../features/scanner/models/verdict.dart';
// import 'ai_keys_store.dart';
// import 'ai_provider.dart';
// import 'budget_guard.dart';
// import 'chatgpt_provider.dart';
// import 'circuit_breaker.dart';
// import 'gemini_provider.dart';
// import 'grok_provider.dart';
// import 'threat_memory_store.dart';
//
// final Provider<AiRouter> aiRouterProvider = Provider<AiRouter>((Ref ref) {
//   final Box<dynamic> aiBox = Hive.box<dynamic>(HiveBoxes.aiState);
//   return AiRouter(
//     cache: HiveVerdictCache(Hive.box<dynamic>(HiveBoxes.cache)),
//     keysStore: ref.watch(aiKeysStoreProvider),
//     prefs: ref.watch(userPrefsProvider),
//     grokBreaker: CircuitBreaker(aiBox, provider: 'grok'),
//     geminiBreaker: CircuitBreaker(aiBox, provider: 'gemini'),
//     chatgptBreaker: CircuitBreaker(aiBox, provider: 'chatgpt'),
//     budget: BudgetGuard(aiBox),
//     firestore: FirebaseFirestore.instance,
//   );
// });
//
// /// Hybrid scan result — includes both Tier-1 and AI verdicts.
// class HybridScanResult {
//   const HybridScanResult({
//     required this.finalVerdict,
//     required this.tier1Result,
//     this.aiVerdict,
//     this.aiError,
//     this.aiSkipped = false,
//     this.aiSkipReason,
//   });
//
//   final Verdict finalVerdict;
//   final Tier1Result tier1Result;
//   final Verdict? aiVerdict;
//   final KavachException? aiError;
//   final bool aiSkipped;
//   final String? aiSkipReason;
//
//   bool get hasAi => aiVerdict != null;
//   bool get tier1RedNeverDowngraded =>
//       tier1Result.level == VerdictLevel.red &&
//           finalVerdict.verdict == VerdictLevel.red;
// }
//
// class AiRouter {
//   AiRouter({
//     required this.cache,
//     required this.keysStore,
//     required this.prefs,
//     required this.grokBreaker,
//     required this.geminiBreaker,
//     required this.chatgptBreaker,
//     required this.budget,
//     required this.firestore,
//   });
//
//   final VerdictCache cache;
//   final AiKeysStore keysStore;
//   final UserPrefs prefs;
//   final CircuitBreaker grokBreaker;
//   final CircuitBreaker geminiBreaker;
//   final CircuitBreaker chatgptBreaker;
//   final BudgetGuard budget;
//   final FirebaseFirestore firestore;
//
//   /// SMART HYBRID SCAN:
//   /// 1. Always run offline rules first (5 ms)
//   /// 2. Call AI only if:
//   ///    - AMBER (needs second opinion), OR
//   ///    - RED with < 80 confidence (want AI to confirm), OR
//   ///    - Novel link/pattern detected, OR
//   ///    - User explicitly requested AI deep-scan
//   /// 3. Merge results (Tier-1 RED never downgraded)
//   Future<HybridScanResult> hybridAnalyze(
//       ScanRequest req,
//       RuleEngine ruleEngine, {
//         bool forceAi = false,
//       }) async {
//     // ============================================================
//     // STEP 1: OFFLINE RULES (always, 0 cost, ~5 ms)
//     // ============================================================
//     final Tier1Result tier1 = ruleEngine.run(ScanInput(
//       text: req.text,
//       source: req.source,
//       langCode: req.langCode,
//       senderTitle: req.senderTitle,
//       upiParams: req.upiParams,
//     ));
//
//     final Verdict tier1Verdict = VerdictBuild.fromTier1(
//       hits: tier1.hits,
//       score: tier1.score,
//       level: tier1.level,
//       langCode: req.langCode,
//     );
//
//     AppLogger.i(
//       'Hybrid: Tier-1 score=${tier1.score} level=${tier1.level.wire} '
//           'hits=${tier1.hits.length}',
//     );
//
//     // ============================================================
//     // STEP 2: DECIDE IF AI IS NEEDED
//     // ============================================================
//     final bool hasImage = req.imageBytes != null && req.imageBytes!.isNotEmpty;
//     final bool shouldCallAi = _shouldCallAi(tier1, forceAi, hasImage: hasImage, rawText: req.text);
//     if (!shouldCallAi) {
//       return HybridScanResult(
//         finalVerdict: tier1Verdict,
//         tier1Result: tier1,
//         aiSkipped: true,
//         aiSkipReason: _skipReason(tier1, forceAi, hasImage: hasImage),
//       );
//     }
//
//     // ============================================================
//     // STEP 3: AI DEEP-SCAN (only if needed)
//     // ============================================================
//     if (prefs.consentAi == false) {
//       return HybridScanResult(
//         finalVerdict: tier1Verdict,
//         tier1Result: tier1,
//         aiSkipped: true,
//         aiSkipReason: 'AI disabled by user consent',
//       );
//     }
//
//     // Graceful Production Fallback:
//     final AiConfig config = await keysStore.getConfig();
//     final bool hasCloudKey = (config.geminiKey != null && config.geminiKey!.trim().isNotEmpty) ||
//         (config.chatgptKey != null && config.chatgptKey!.trim().isNotEmpty) ||
//         (config.grokKey != null && config.grokKey!.trim().isNotEmpty);
//
//     if (!hasCloudKey && !forceAi) {
//       AppLogger.i('Hybrid: No cloud keys configured; relying on on-device Tier-1 RuleEngine');
//       return HybridScanResult(
//         finalVerdict: tier1Verdict,
//         tier1Result: tier1,
//         aiSkipped: true,
//         aiSkipReason: 'On-device Kavach Guard verified (107 offline threat rules active)',
//       );
//     }
//
//     // Pass Tier-1 hints to AI for better context
//     final ScanRequest enrichedReq = ScanRequest(
//       text: req.text,
//       source: req.source,
//       senderTitle: req.senderTitle,
//       imageBytes: req.imageBytes,
//       imageMime: req.imageMime,
//       upiParams: req.upiParams,
//       langCode: req.langCode,
//       tier1Hints: tier1.hits,
//     );
//
//     try {
//       final Verdict aiVerdict = await analyze(enrichedReq);
//       final Verdict merged =
//       VerdictBuild.mergeTier1AndAi(tier1Verdict, aiVerdict);
//
//       AppLogger.i(
//         'Hybrid: MERGED verdict=${merged.verdict.wire} '
//             'score=${merged.riskScore} (tier1=${tier1.score}, ai=${aiVerdict.riskScore})',
//       );
//
//       return HybridScanResult(
//         finalVerdict: merged,
//         tier1Result: tier1,
//         aiVerdict: aiVerdict,
//       );
//     } on KavachException catch (e) {
//       AppLogger.w('Hybrid: AI failed, using Tier-1 result: $e');
//       if (!forceAi) {
//         return HybridScanResult(
//           finalVerdict: tier1Verdict,
//           tier1Result: tier1,
//           aiSkipped: true,
//           aiSkipReason: 'Verified by on-device Kavach Guard',
//         );
//       }
//       return HybridScanResult(
//         finalVerdict: tier1Verdict,
//         tier1Result: tier1,
//         aiError: e,
//       );
//     }
//   }
//
//   bool _shouldCallAi(
//       Tier1Result tier1,
//       bool forceAi, {
//         bool hasImage = false,
//         String? rawText,
//       }) {
//     if (forceAi) return true;
//
//     if (hasImage && !(tier1.level == VerdictLevel.red && tier1.score >= 80)) {
//       return true;
//     }
//
//     if (tier1.level == VerdictLevel.amber) return true;
//     if (tier1.level == VerdictLevel.red && tier1.score < 80) return true;
//     if (tier1.level == VerdictLevel.red && tier1.score >= 80) return false;
//
//     if (rawText != null) {
//       final String lower = rawText.toLowerCase();
//       final bool hasExternalLink = lower.contains('http://') ||
//           lower.contains('https://') ||
//           lower.contains('www.') ||
//           lower.contains('.apk') ||
//           lower.contains('wa.me') ||
//           lower.contains('t.me') ||
//           lower.contains('bit.ly') ||
//           lower.contains('tinyurl.com') ||
//           lower.contains('.xyz') ||
//           lower.contains('.site') ||
//           lower.contains('.top') ||
//           lower.contains('.online');
//       if (hasExternalLink) return true;
//     }
//
//     if (tier1.level == VerdictLevel.green && tier1.score < 15) return false;
//
//     return true;
//   }
//
//   String _skipReason(Tier1Result tier1, bool forceAi, {bool hasImage = false}) {
//     if (forceAi) return 'Force AI enabled';
//     if (tier1.level == VerdictLevel.red && tier1.score >= 80) {
//       return 'High-confidence offline RED (${tier1.score}/100) — AI not needed';
//     }
//     if (tier1.level == VerdictLevel.green && tier1.score < 15) {
//       return 'Clear offline SAFE (${tier1.score}/100) — AI skipped to save latency';
//     }
//     return 'AI not required';
//   }
//
//   /// Direct AI scan (cascades: Gemini -> ChatGPT -> Grok/Groq)
//   Future<Verdict> analyze(ScanRequest req) async {
//     if (prefs.consentAi == false) {
//       throw const NoProviderException('AI disabled by user consent');
//     }
//
//     final String hash = HiveVerdictCache.hashOf(req.text);
//
//     // ── STEP 1: Local cache check ──
//     final Verdict? localHit = await cache.byHash(hash);
//     if (localHit != null) {
//       AppLogger.i('CacheHit(Local)', tag: 'ai');
//       return localHit.copyWith(
//         provider: const AiProviderInfo(provider: AiProvider.cached),
//       );
//     }
//
//     final AiConfig config = await keysStore.getConfig();
//     KavachException? lastError;
//
//     // ── STEP 2: Gemini (PRIMARY) ──
//     if (config.geminiKey != null &&
//         config.geminiKey!.isNotEmpty &&
//         !geminiBreaker.isOpen()) {
//       try {
//         AppLogger.i('Attempting Primary AI: Gemini', tag: 'ai');
//         final AiProviderClient gemini = GeminiProvider(
//           apiKey: config.geminiKey!,
//           modelId: config.geminiModel,
//         );
//         final Verdict v = await gemini.analyze(req);
//         await geminiBreaker.recordSuccess();
//         await _saveVerdictLocal(hash, v, req.text);
//         AppLogger.i('Gemini SUCCESS', tag: 'ai');
//         return v;
//       } on KavachException catch (e) {
//         AppLogger.w('Gemini primary failed: $e', tag: 'ai');
//         await geminiBreaker.recordFailure();
//         lastError = e;
//       }
//     }
//
//     // ── STEP 3: ChatGPT / OpenAI (FALLBACK 1) ──
//     if (config.chatgptKey != null &&
//         config.chatgptKey!.isNotEmpty &&
//         !chatgptBreaker.isOpen()) {
//       try {
//         AppLogger.i('Attempting Fallback AI: ChatGPT', tag: 'ai');
//         final AiProviderClient chatgpt = ChatGptProvider(
//           apiKey: config.chatgptKey!,
//           modelId: config.chatgptModel,
//         );
//         final Verdict v = await chatgpt.analyze(req);
//         await chatgptBreaker.recordSuccess();
//         await _saveVerdictLocal(hash, v, req.text);
//         AppLogger.i('ChatGPT SUCCESS', tag: 'ai');
//         return v;
//       } on KavachException catch (e) {
//         AppLogger.w('ChatGPT fallback failed: $e', tag: 'ai');
//         await chatgptBreaker.recordFailure();
//         lastError = e;
//       }
//     }
//
//     // ── STEP 4: Grok / Groq (FALLBACK 2) ──
//     if (config.grokKey != null &&
//         config.grokKey!.isNotEmpty &&
//         budget.canCall() &&
//         !grokBreaker.isOpen()) {
//       try {
//         AppLogger.i('Attempting Fallback AI: Grok/Groq', tag: 'ai');
//         final AiProviderClient grok = GrokProvider(
//           apiKey: config.grokKey!,
//           modelId: config.grokModel,
//         );
//         final Verdict v = await grok.analyze(req);
//         await grokBreaker.recordSuccess();
//         await budget.recordCall();
//         await _saveVerdictLocal(hash, v, req.text);
//         AppLogger.i('Grok/Groq FALLBACK SUCCESS', tag: 'ai');
//         return v;
//       } on KavachException catch (e) {
//         AppLogger.w('Grok fallback failed: $e', tag: 'ai');
//         await grokBreaker.recordFailure();
//         lastError = e;
//       }
//     }
//
//     // ── STEP 5: Enqueue background retry ──
//     try {
//       await Workmanager().registerOneOffTask(
//         'ai_retry_$hash',
//         'aiScanRetry',
//         inputData: <String, dynamic>{'text': req.text, 'hash': hash},
//         constraints: Constraints(networkType: NetworkType.connected),
//         backoffPolicy: BackoffPolicy.exponential,
//         initialDelay: const Duration(minutes: 1),
//       );
//     } catch (_) {}
//
//     throw lastError ?? const NoProviderException('No configured providers');
//   }
//
//   Future<void> _saveVerdictLocal(String hash, Verdict v, [String? originalText]) async {
//     await cache.put(hash, v);
//
//     if (v.verdict == VerdictLevel.red && originalText != null && originalText.trim().isNotEmpty) {
//       try {
//         if (Hive.isBoxOpen(HiveBoxes.cache)) {
//           final threatStore = ThreatMemoryStore(Hive.box<dynamic>(HiveBoxes.cache));
//           await threatStore.learnPattern(
//             text: originalText,
//             family: v.patternMatched,
//             redFlags: v.redFlags,
//             isScam: true,
//           );
//         }
//       } catch (e) {
//         AppLogger.w('Failed to index threat memory: $e');
//       }
//     }
//   }
//
//   Future<void> _saveVerdict(String hash, Verdict v) async {
//     await cache.put(hash, v);
//     try {
//       await firestore.collection('verdicts').doc(hash).set(v.toJson());
//     } catch (_) {}
//   }
//
//   Future<bool> secondOpinion(ScanRequest req, Verdict primaryVerdict) async {
//     if (primaryVerdict.provider.provider != AiProvider.grok) {
//       return false;
//     }
//     final AiConfig config = await keysStore.getConfig();
//     if (config.geminiKey == null ||
//         config.geminiKey!.isEmpty ||
//         geminiBreaker.isOpen()) {
//       return false;
//     }
//
//     try {
//       final AiProviderClient gemini = GeminiProvider(
//         apiKey: config.geminiKey!,
//         modelId: config.geminiModel,
//       );
//       final Verdict v = await gemini.analyze(req);
//       return v.verdict == VerdictLevel.red &&
//           primaryVerdict.verdict == VerdictLevel.red;
//     } catch (_) {
//       return false;
//     }
//   }
// }
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
    // STEP 2: FAST-PATH - HIGH CONFIDENCE TIER-1 RED
    // ============================================================
    // If Tier-1 detects RED with score >= 85, return immediately
    // without invoking LLM (saves time and resources)
    if (tier1.level == VerdictLevel.red && tier1.score >= 85 && !forceAi) {
      return HybridScanResult(
        finalVerdict: tier1Verdict,
        tier1Result: tier1,
        aiSkipped: true,
        aiSkipReason: 'Tier-1 High Confidence Offline Red',
      );
    }

    // ============================================================
    // STEP 3: ON-DEVICE GEMMA 2B EDGE AI (Deep Analysis)
    // ============================================================
    if (gemmaService.isReady) {
      AppLogger.i('Invoking 100% Offline Edge AI: Gemma 2B INT4', tag: 'ai');
      try {
        final String? gemmaResp = await gemmaService.analyzeScam(req.text);
        if (gemmaResp != null && gemmaResp.isNotEmpty) {
          // Check for critical/scam indicators in Gemma's response
          final isCritical = gemmaResp.toLowerCase().contains('critical') ||
              gemmaResp.toLowerCase().contains('high') ||
              gemmaResp.toLowerCase().contains('fraud') ||
              gemmaResp.toLowerCase().contains('scam');

          final Verdict gemmaVerdict = Verdict(
            verdict: isCritical
                ? VerdictLevel.red
                : (tier1.level == VerdictLevel.amber
                ? VerdictLevel.amber
                : VerdictLevel.green),
            riskScore: isCritical ? 88 : tier1.score,
            patternMatched: isCritical
                ? 'Edge AI Coercion Pattern'
                : 'Safe Content Pattern',
            confidence: isCritical ? 0.95 : 0.70,
            redFlags: isCritical
                ? <String>['Detected by on-device Gemma Edge AI', gemmaResp]
                : <String>[],
            explanationNative: gemmaResp,
            recommendedActions: isCritical
                ? <String>['Do not send money or click links', 'Call 1930 Cyber Helpline']
                : <String>['No immediate action needed'],
            provider: const AiProviderInfo(
              provider: AiProvider.gemma,
              model: 'Gemma 2B INT4 (Local)',
            ),
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
    // STEP 4: CLOUD AI (GEMINI / CHATGPT / GROK) - COMMENTED OUT
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

    // ============================================================
    // STEP 5: FALLBACK - TIER-1 RULES ONLY
    // ============================================================
    return HybridScanResult(
      finalVerdict: tier1Verdict,
      tier1Result: tier1,
      aiSkipped: true,
      aiSkipReason: 'Local Kavach Rules Mode Active',
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