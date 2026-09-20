import 'package:flutter/foundation.dart';

import '../../../data/rules/rule.dart';
import '../../../data/rules/score_aggregator.dart';

/// Which engine produced this verdict.
enum AiProvider { tier1, gemini, grok, chatgpt, cached }

extension AiProviderX on AiProvider {
  String get wire {
    switch (this) {
      case AiProvider.tier1:   return 'tier1';
      case AiProvider.gemini:  return 'gemini';
      case AiProvider.grok:    return 'grok';
      case AiProvider.chatgpt: return 'chatgpt';
      case AiProvider.cached:  return 'cached';
    }
  }
  static AiProvider fromWire(String? s) {
    switch (s) {
      case 'gemini':  return AiProvider.gemini;
      case 'grok':    return AiProvider.grok;
      case 'chatgpt':
      case 'openai':  return AiProvider.chatgpt;
      case 'cached':  return AiProvider.cached;
      default:        return AiProvider.tier1;
    }
  }
}

@immutable
class AiProviderInfo {
  const AiProviderInfo({required this.provider, this.model});
  final AiProvider provider;
  final String? model;

  factory AiProviderInfo.tier1() =>
      const AiProviderInfo(provider: AiProvider.tier1, model: 'on-device');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'provider': provider.wire,
        'model': model,
      };

  factory AiProviderInfo.fromJson(Map<String, dynamic> j) => AiProviderInfo(
        provider: AiProviderX.fromWire(j['provider'] as String?),
        model: j['model'] as String?,
      );
}

/// The final verdict emitted by either Tier-1 (offline) or Tier-2 (AI).
@immutable
class Verdict {
  const Verdict({
    required this.verdict,
    required this.riskScore,
    required this.patternMatched,
    required this.confidence,
    required this.redFlags,
    required this.explanationNative,
    required this.recommendedActions,
    required this.provider,
  });

  final VerdictLevel verdict;
  final int riskScore; // 0..100
  final String patternMatched; // Rule family or novel scam name
  final double confidence; // 0.0..1.0
  final List<String> redFlags;
  final String explanationNative;
  final List<String> recommendedActions;
  final AiProviderInfo provider;

  Verdict copyWith({
    VerdictLevel? verdict,
    int? riskScore,
    String? patternMatched,
    double? confidence,
    List<String>? redFlags,
    String? explanationNative,
    List<String>? recommendedActions,
    AiProviderInfo? provider,
  }) =>
      Verdict(
        verdict: verdict ?? this.verdict,
        riskScore: riskScore ?? this.riskScore,
        patternMatched: patternMatched ?? this.patternMatched,
        confidence: confidence ?? this.confidence,
        redFlags: redFlags ?? this.redFlags,
        explanationNative: explanationNative ?? this.explanationNative,
        recommendedActions: recommendedActions ?? this.recommendedActions,
        provider: provider ?? this.provider,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'verdict': verdict.wire,
        'riskScore': riskScore,
        'patternMatched': patternMatched,
        'confidence': confidence,
        'redFlags': redFlags,
        'explanationNative': explanationNative,
        'recommendedActions': recommendedActions,
        'provider': provider.toJson(),
      };

  factory Verdict.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic>? prov =
        j['provider'] as Map<String, dynamic>?;
    return Verdict(
      verdict: VerdictLevelX.fromWire(j['verdict'] as String?),
      riskScore: (j['riskScore'] as num?)?.toInt() ?? 0,
      patternMatched: j['patternMatched'] as String? ?? 'Unknown',
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0.0,
      redFlags: (j['redFlags'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      explanationNative: j['explanationNative'] as String? ?? '',
      recommendedActions: (j['recommendedActions'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      provider: prov != null
          ? AiProviderInfo.fromJson(prov)
          : AiProviderInfo.tier1(),
    );
  }
}

/// Utility builder for Tier-1 verdicts and hybrid mergers.
class VerdictBuild {
  static Verdict fromTier1({
    required List<RuleHit> hits,
    required int score,
    required VerdictLevel level,
    required String langCode,
  }) {
    final String pattern = hits.isNotEmpty ? hits.first.family : 'None';
    final List<String> flags =
        hits.map((RuleHit h) => h.matchedSnippet).toList();
    final List<String> actions = _actionsFor(level);

    return Verdict(
      verdict: level,
      riskScore: score,
      patternMatched: pattern,
      confidence: 1.0,
      redFlags: flags,
      explanationNative: _explanationFor(level, langCode),
      recommendedActions: actions,
      provider: AiProviderInfo.tier1(),
    );
  }

  static Verdict mergeTier1AndAi(Verdict tier1, Verdict ai) {
    if (tier1.verdict == VerdictLevel.red) {
      return ai.copyWith(
        verdict: VerdictLevel.red,
        riskScore: ai.riskScore > tier1.riskScore ? ai.riskScore : tier1.riskScore,
      );
    }
    return ai;
  }

  static List<String> _actionsFor(VerdictLevel level) {
    switch (level) {
      case VerdictLevel.red:
        return <String>[
          'Do not reply to this message',
          'Call 1930 (cyber-crime helpline)',
          'Never share OTP, PIN or card details',
        ];
      case VerdictLevel.amber:
        return <String>[
          'Verify sender identity independently',
          'Do not click links or install apps',
        ];
      case VerdictLevel.green:
        return <String>[
          'Safe to proceed',
        ];
    }
  }

  static String _explanationFor(VerdictLevel level, String langCode) {
    switch (level) {
      case VerdictLevel.red:
        return 'High risk scam indicators detected in this message.';
      case VerdictLevel.amber:
        return 'Suspicious patterns detected. Please proceed with caution.';
      case VerdictLevel.green:
        return 'No known scam patterns detected.';
    }
  }
}
