import 'dart:convert';

import 'package:digital_kavach/data/rules/score_aggregator.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../features/scanner/models/verdict.dart';

/// Parses AI responses into [Verdict] with hostile-input hardening.
///
/// Handles: markdown fences, prose before/after JSON, wrong-typed fields,
/// unknown keys, missing fields, out-of-range values.
///
/// One self-repair attempt: if parse fails, caller can retry with
/// "Return ONLY minified JSON" appended to the prompt.
class VerdictParser {
  const VerdictParser._();

  /// Known scam families from rules.json. Anything else → 'other'.
  static const Set<String> _knownFamilies = {
    'digital_arrest',
    'fake_kyc',
    'upi_collect_trap',
    'fake_challan',
    'lottery',
    'fake_payment_screenshot',
    'phishing_link',
    'qr_impersonation',
    'investment_group',
    'sim_swap',
    'other',
  };

  /// Valid verdict levels.
  static const Set<String> _validVerdicts = {'SCAM', 'SUSPICIOUS', 'SAFE'};

  /// Parse an AI response string into a [Verdict].
  ///
  /// [rawResponse] may contain markdown fences, prose, or garbage.
  /// [provider] and [model] are stamped from RESPONSE metadata, not request.
  static Verdict parse(String rawResponse, AiProvider provider, String model) {
    try {
      final String jsonStr = _extractJson(rawResponse);
      final Map<String, dynamic> j =
      jsonDecode(jsonStr) as Map<String, dynamic>;

      // ── Validate & sanitize every field ──

      // verdict: must be SCAM | SUSPICIOUS | SAFE
      String verdict = _asString(j['verdict'] ?? j['verdict_level'] ?? '');
      verdict = verdict.toUpperCase().trim();
      if (!_validVerdicts.contains(verdict)) {
        AppLogger.w('VerdictParser: invalid verdict "$verdict", defaulting to SUSPICIOUS');
        verdict = 'SUSPICIOUS';
      }

      // riskScore: 0–100, clamp
      int riskScore = _asInt(j['riskScore'] ?? j['risk_score'] ?? 50);
      riskScore = riskScore.clamp(0, 100);

      // patternMatched: known family or 'other'
      String pattern = _asString(j['patternMatched'] ?? j['pattern_matched'] ?? 'other');
      pattern = pattern.toLowerCase().trim();
      if (!_knownFamilies.contains(pattern)) {
        pattern = 'other';
      }

      // confidence: 0.0–1.0, clamp
      double confidence = _asDouble(j['confidence'] ?? 0.5);
      confidence = confidence.clamp(0.0, 1.0);

      // redFlags: must be List<String>, coerce if not
      List<String> redFlags = _asStringList(j['redFlags'] ?? j['red_flags'] ?? []);
      if (redFlags.length > 5) redFlags = redFlags.sublist(0, 5);

      // explanationNative: string, fallback
      String explanation = _asString(
        j['explanationNative'] ?? j['explanation_native'] ?? '',
      );
      if (explanation.isEmpty) {
        explanation = redFlags.isNotEmpty
            ? redFlags.join('\n')
            : 'No explanation provided by AI.';
      }

      // recommendedActions: must be List<String>
      List<String> actions = _asStringList(
        j['recommendedActions'] ?? j['recommended_actions'] ?? [],
      );
      if (actions.isEmpty) {
        actions = ['Call 1930 helpline', 'Do not respond to the sender'];
      }

      // Build the sanitized Verdict
      return Verdict(
        verdict: _mapVerdictLevel(verdict),
        riskScore: riskScore,
        patternMatched: pattern,
        confidence: confidence,
        redFlags: redFlags,
        explanationNative: explanation,
        recommendedActions: actions,
        provider: AiProviderInfo(provider: provider, model: model),
      );
    } on FormatException catch (e) {
      AppLogger.w('VerdictParser: invalid JSON format — ${e.message}');
      throw AiParseException('Invalid JSON from AI: ${e.message}');
    } on AiParseException {
      rethrow;
    } catch (e) {
      AppLogger.w('VerdictParser: unexpected error — $e');
      throw AiParseException('Parse failure: $e');
    }
  }

  /// Extract the first balanced `{...}` block from potentially messy output.
  static String _extractJson(String text) {
    String clean = text.trim();

    // Strip markdown code fences
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
      if (clean.endsWith('```')) clean = clean.substring(0, clean.length - 3);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
      if (clean.endsWith('```')) clean = clean.substring(0, clean.length - 3);
    }

    clean = clean.trim();

    // Extract first balanced JSON object
    final int start = clean.indexOf('{');
    final int end = clean.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return clean.substring(start, end + 1);
    }

    // Last resort: return as-is and let jsonDecode throw
    return clean;
  }

  /// Self-repair prompt suffix — append to user message on retry.
  static const String selfRepairSuffix =
      '\n\nCRITICAL: Return ONLY minified JSON. No prose, no markdown, no explanation.';

  // ── Type coercion helpers (hostile-input safe) ──

  static String _asString(dynamic v) {
    if (v is String) return v;
    if (v == null) return '';
    return v.toString();
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v) ?? 50;
    return 50;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.5;
    return 0.5;
  }

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e is String ? e : e.toString()).toList();
    }
    if (v is String && v.isNotEmpty) return [v];
    return [];
  }

  static VerdictLevel _mapVerdictLevel(String v) {
    switch (v) {
      case 'SCAM':
        return VerdictLevel.red;
      case 'SUSPICIOUS':
        return VerdictLevel.amber;
      case 'SAFE':
        return VerdictLevel.green;
      default:
        return VerdictLevel.amber;
    }
  }
}