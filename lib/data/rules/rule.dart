import 'package:flutter/foundation.dart';

/// The 10 scam families supported in v2.0 (blueprint §5.1).
///
/// Serialize using [name]. `other` is a catch-all reserved for AI-only
/// verdicts (Tier-1 rules should never emit `other`).
enum ScamFamily {
  digital_arrest,
  fake_kyc,
  upi_collect_trap,
  fake_challan,
  lottery,
  fake_payment_screenshot,
  phishing_link,
  qr_impersonation,
  investment_group,
  sim_swap,
  other,
}

extension ScamFamilyX on ScamFamily {
  String get wireName => name;
  static ScamFamily fromWire(String s) {
    for (final ScamFamily f in ScamFamily.values) {
      if (f.name == s) return f;
    }
    return ScamFamily.other;
  }
}

/// Rule type — controls how [Rule.pattern] is interpreted.
enum RuleType {
  regex,
  keyword_proximity,
  url_domain_rule,
  upi_rule,
  structure_rule,
}

extension RuleTypeX on RuleType {
  String get wire => name;
  static RuleType fromWire(String s) =>
      RuleType.values.firstWhere((RuleType r) => r.name == s,
          orElse: () => RuleType.regex);
}

/// Immutable rule definition loaded from `assets/rules.json`.
@immutable
class Rule {
  const Rule({
    required this.id,
    required this.family,
    required this.type,
    required this.pattern,
    required this.weight,
    required this.localizedHint,
    required this.description,
    this.flags = 'i',
    this.proximityChars = 30,
    this.secondaryPattern,
    this.allowlist = const <String>[],
  });

  /// Stable, globally-unique rule identifier. Kotlin FastRuleEngine mirrors
  /// a subset of these ids verbatim — never rename after ship.
  final String id;
  final ScamFamily family;
  final RuleType type;

  /// Primary pattern (regex source, keyword, or URL rule marker).
  final String pattern;

  /// For [RuleType.keyword_proximity] — the second keyword.
  final String? secondaryPattern;

  /// Regex flags: `i` = case-insensitive.
  final String flags;

  /// Character window for [RuleType.keyword_proximity].
  final int proximityChars;

  /// Domains that suppress a [RuleType.url_domain_rule] hit.
  final List<String> allowlist;

  /// Weighting for scoring (see [ScoreAggregator]).
  final int weight;

  /// Short native-language reason surfaced in [Verdict.redFlags].
  /// Keys: `en`, `hi`, `mr`. Fallback: en.
  final Map<String, String> localizedHint;

  /// Internal, English, dev-facing description (not shown to users).
  final String description;

  factory Rule.fromJson(Map<String, dynamic> j) {
    return Rule(
      id: j['id'] as String,
      family: ScamFamilyX.fromWire(j['family'] as String),
      type: RuleTypeX.fromWire(j['type'] as String),
      pattern: j['pattern'] as String,
      secondaryPattern: j['secondaryPattern'] as String?,
      flags: (j['flags'] as String?) ?? 'i',
      proximityChars: (j['proximityChars'] as int?) ?? 30,
      allowlist: ((j['allowlist'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>(),
      weight: j['weight'] as int,
      localizedHint: (j['localizedHint'] as Map<dynamic, dynamic>)
          .map<String, String>(
              (dynamic k, dynamic v) => MapEntry<String, String>(
            k as String,
            v as String,
          )),
      description: (j['description'] as String?) ?? '',
    );
  }

  String hintFor(String langCode) =>
      localizedHint[langCode] ?? localizedHint['en'] ?? description;
}

/// A single rule that matched during a scan.
@immutable
class RuleHit {
  const RuleHit({
    required this.ruleId,
    required this.family,
    required this.weight,
    required this.matchedSnippet,
    required this.hint,
  });

  final String ruleId;
  final ScamFamily family;
  final int weight;

  /// A ≤60-char, privacy-safe excerpt of what matched.
  final String matchedSnippet;

  /// Localized reason string (already resolved for the user's language).
  final String hint;
}