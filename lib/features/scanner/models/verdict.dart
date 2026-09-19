import 'package:flutter/foundation.dart';

import '../../../data/rules/rule.dart';
import '../../../data/rules/score_aggregator.dart';

/// Which engine produced this verdict.
enum AiProvider { tier1, gemini, grok, cached }

extension AiProviderX on AiProvider {
  String get wire {
    switch (this) {
      case AiProvider.tier1:  return 'tier1';
      case AiProvider.gemini: return 'gemini';
      case AiProvider.grok:   return 'grok';
      case AiProvider.cached: return 'cached';
    }
  }
  static AiProvider fromWire(String? s) {
    switch (s) {
      case 'gemini': return AiProvider.gemini;
      case 'grok':   return AiProvider.grok;
      case 'cached': return AiProvider.cached;
      default:       return AiProvider.tier1;
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
    if (model != null) 'model': model,
  };
}

/// **FROZEN CONTRACT** — byte-exact to blueprint §5.4 JSON schema.
///
/// Any new field must be optional in [fromJson] and MUST NOT change wire
/// keys. Consumed by Phase 04 (AI Router), Phase 05 (Scanner), Phase 06
/// (Sentinel bridge), Phase 07 (Recovery), Phase 08 (Family alerts).
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
  final int riskScore;
  final String patternMatched;
  final double confidence;
  final List<String> redFlags;
  final String explanationNative;
  final List<String> recommendedActions;
  final AiProviderInfo provider;

  /// Wire JSON per blueprint §5.4.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'verdict': verdict.wire, // SCAM | SUSPICIOUS | SAFE
    'risk_score': riskScore,
    'pattern_matched': patternMatched,
    'confidence': confidence,
    'red_flags': redFlags,
    'explanation_native': explanationNative,
    'recommended_actions': recommendedActions,
    'provider': provider.provider.wire,
    if (provider.model != null) 'model': provider.model,
  };

  factory Verdict.fromJson(Map<String, dynamic> j) {
    return Verdict(
      verdict: VerdictLevelX.fromWire((j['verdict'] as String?) ?? 'SAFE'),
      riskScore: (j['risk_score'] as num?)?.toInt() ?? 0,
      patternMatched: (j['pattern_matched'] as String?) ?? 'other',
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0.0,
      redFlags: ((j['red_flags'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>(),
      explanationNative: (j['explanation_native'] as String?) ?? '',
      recommendedActions:
      ((j['recommended_actions'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>(),
      provider: AiProviderInfo(
        provider: AiProviderX.fromWire(j['provider'] as String?),
        model: j['model'] as String?,
      ),
    );
  }

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
}

extension VerdictBuild on Verdict {
  /// Build a Tier-1-only [Verdict] from local rule output.
  ///
  /// - `confidence` = clamp(hits×0.15, 0..1)
  /// - `explanationNative` = up to 3 hint bullets joined with `\n`
  /// - Recommended actions are family-generic + always include "call 1930"
  ///   for red verdicts.
  static Verdict fromTier1({
    required List<RuleHit> hits,
    required int score,
    required VerdictLevel level,
    required String langCode,
  }) {
    final List<String> flags = hits
        .take(5)
        .map<String>((RuleHit h) => h.hint)
        .toList(growable: false);
    final String explanation = hits.take(3).map((RuleHit h) => '• ${h.hint}').join('\n');

    final ScamFamily topFamily = hits.isNotEmpty ? hits.first.family : ScamFamily.other;

    final List<String> actions = <String>[];
    if (level == VerdictLevel.red) {
      actions.add(_localAction(langCode, 'reply_never'));
      actions.add(_localAction(langCode, 'call_1930'));
      actions.add(_localAction(langCode, 'do_not_share_otp'));
    } else if (level == VerdictLevel.amber) {
      actions.add(_localAction(langCode, 'verify_offline'));
      actions.add(_localAction(langCode, 'do_not_share_otp'));
    } else {
      actions.add(_localAction(langCode, 'stay_alert'));
    }

    final double conf =
    (hits.length * 0.15).clamp(0.0, 1.0).toDouble();

    return Verdict(
      verdict: level,
      riskScore: score,
      patternMatched: topFamily.wireName,
      confidence: conf,
      redFlags: flags,
      explanationNative: explanation.isEmpty
          ? _defaultExplanation(langCode, level)
          : explanation,
      recommendedActions: actions,
      provider: AiProviderInfo.tier1(),
    );
  }

  /// Merge Tier-1 + AI verdicts. Blueprint §3.2:
  /// "Tier 1 🔴 can never be downgraded by Tier 2."
  static Verdict mergeTier1AndAi(Verdict tier1, Verdict ai) {
    final int mergedScore =
    tier1.riskScore > ai.riskScore ? tier1.riskScore : ai.riskScore;
    final VerdictLevel mergedLevel = _maxLevel(tier1.verdict, ai.verdict);

    final String pattern =
    tier1.verdict == VerdictLevel.red ? tier1.patternMatched : ai.patternMatched;

    final Set<String> flags = <String>{
      ...tier1.redFlags,
      ...ai.redFlags,
    };
    final List<String> mergedFlags = flags.take(5).toList(growable: false);

    return ai.copyWith(
      verdict: mergedLevel,
      riskScore: mergedScore,
      patternMatched: pattern,
      redFlags: mergedFlags,
    );
  }

  static VerdictLevel _maxLevel(VerdictLevel a, VerdictLevel b) {
    int rank(VerdictLevel v) {
      switch (v) {
        case VerdictLevel.green: return 0;
        case VerdictLevel.amber: return 1;
        case VerdictLevel.red:   return 2;
      }
    }
    return rank(a) >= rank(b) ? a : b;
  }

  static String _localAction(String lang, String key) {
    const Map<String, Map<String, String>> table = <String, Map<String, String>>{
      'reply_never': <String, String>{
        'en': 'Do not reply to this message',
        'hi': 'इस संदेश का जवाब मत दो',
        'mr': 'या संदेशाला उत्तर देऊ नका',
      },
      'call_1930': <String, String>{
        'en': 'Call 1930 (cyber-crime helpline)',
        'hi': '1930 पर कॉल करें (साइबर-क्राइम)',
        'mr': '1930 वर कॉल करा (सायबर-क्राईम)',
      },
      'do_not_share_otp': <String, String>{
        'en': 'Never share OTP, PIN or card details',
        'hi': 'OTP / PIN / कार्ड details कभी शेयर मत करो',
        'mr': 'OTP / PIN / कार्ड तपशील कधीही शेअर करू नका',
      },
      'verify_offline': <String, String>{
        'en': 'Verify through the official app or a known number',
        'hi': 'आधिकारिक ऐप या जाने-पहचाने नंबर से पुष्टि करें',
        'mr': 'अधिकृत अ‍ॅप किंवा ओळखीच्या नंबरवरून खात्री करा',
      },
      'stay_alert': <String, String>{
        'en': 'Message looks safe — stay alert anyway',
        'hi': 'संदेश सुरक्षित लगता है — फिर भी सावधान रहें',
        'mr': 'संदेश सुरक्षित दिसतो — तरीही सावध राहा',
      },
    };
    return table[key]?[lang] ?? table[key]?['en'] ?? key;
  }

  static String _defaultExplanation(String lang, VerdictLevel level) {
    switch (level) {
      case VerdictLevel.red:
        return <String, String>{
          'en': '• Multiple scam markers detected',
          'hi': '• कई घोटाला संकेत मिले',
          'mr': '• अनेक फसवणूक संकेत आढळले',
        }[lang] ??
            '• Multiple scam markers detected';
      case VerdictLevel.amber:
        return <String, String>{
          'en': '• Some suspicious markers — verify before acting',
          'hi': '• कुछ संदिग्ध संकेत — कार्रवाई से पहले पुष्टि करें',
          'mr': '• काही संशयास्पद संकेत — कृती करण्यापूर्वी खात्री करा',
        }[lang] ??
            '• Some suspicious markers — verify before acting';
      case VerdictLevel.green:
        return <String, String>{
          'en': '• No known scam patterns matched',
          'hi': '• कोई ज्ञात घोटाला पैटर्न नहीं',
          'mr': '• कोणताही ज्ञात फसवणूक पॅटर्न नाही',
        }[lang] ??
            '• No known scam patterns matched';
    }
  }
}