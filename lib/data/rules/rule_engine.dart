import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import 'rule.dart';
import 'score_aggregator.dart';
import 'text_normalizer.dart';
import 'url_utils.dart';

enum ScanSource { notification, shareText, shareImage, qr, paste }

/// Input to the on-device rule engine.
class ScanInput {
  const ScanInput({
    required this.text,
    required this.source,
    this.senderTitle,
    this.upiParams,
    this.langCode = 'en',
  });

  final String text;
  final String? senderTitle;
  final Map<String, String>? upiParams; // pa/pn/am/tn from QR
  final ScanSource source;
  final String langCode;
}

/// Full deterministic Tier-1 output.
class Tier1Result {
  const Tier1Result({
    required this.hits,
    required this.score,
    required this.level,
    required this.familyBonus,
    required this.latencyMicros,
    required this.normalized,
  });

  final List<RuleHit> hits;
  final int score;
  final VerdictLevel level;
  final int familyBonus;
  final int latencyMicros;
  final NormalizedText normalized;
}

/// Pure-Dart, offline scam-pattern engine.
///
/// Load rules once via [instance] then call [RuleEngine.run].
class RuleEngine {
  RuleEngine._(this._rules, this._compiled);

  final List<Rule> _rules;
  final Map<String, RegExp> _compiled;

  static RuleEngine? _cached;

  /// Async loader — reads `assets/rules.json`.
  static Future<RuleEngine> instance() async {
    if (_cached != null) return _cached!;
    try {
      final String raw = await rootBundle.loadString('assets/rules.json');
      _cached = _fromRawJson(raw);
      AppLogger.i('RuleEngine loaded ${_cached!._rules.length} rules');
      return _cached!;
    } catch (e, st) {
      AppLogger.e('RuleEngine load failed', error: e, stackTrace: st);
      throw StorageException('rules.json load failed: $e');
    }
  }

  /// Synchronous constructor from raw JSON (used by tests & Kotlin parity).
  static RuleEngine fromJsonString(String raw) => _fromRawJson(raw);

  static RuleEngine _fromRawJson(String raw) {
    final Map<String, dynamic> j = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> arr = (j['rules'] as List<dynamic>?) ?? <dynamic>[];
    final List<Rule> rules = arr
        .map<Rule>((dynamic e) => Rule.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final Map<String, RegExp> compiled = <String, RegExp>{};
    for (final Rule r in rules) {
      if (r.type == RuleType.regex ||
          r.type == RuleType.keyword_proximity) {
        try {
          compiled[r.id] = RegExp(
            r.pattern,
            caseSensitive: !r.flags.contains('i'),
            multiLine: true,
            unicode: true,
          );
          if (r.secondaryPattern != null) {
            compiled['${r.id}::sec'] = RegExp(
              r.secondaryPattern!,
              caseSensitive: !r.flags.contains('i'),
              multiLine: true,
              unicode: true,
            );
          }
        } catch (e) {
          AppLogger.w('Rule ${r.id} regex invalid: $e');
        }
      }
    }
    return RuleEngine._(rules, compiled);
  }

  /// Main entry point. Deterministic; throws nothing.
  Tier1Result run(ScanInput input) {
    final Stopwatch sw = Stopwatch()..start();
    final List<String> urls = UrlUtils.extract(input.text);
    final NormalizedText norm =
    TextNormalizer.normalize(input.text, urls: urls);

    final List<RuleHit> hits = <RuleHit>[];
    for (final Rule r in _rules) {
      final RuleHit? hit = _evaluate(r, norm, input);
      if (hit != null) hits.add(hit);
    }
    final ScoreResult sr = ScoreAggregator.score(hits);
    sw.stop();

    return Tier1Result(
      hits: sr.dedupedHits,
      score: sr.score,
      level: sr.level,
      familyBonus: sr.familyBonusApplied,
      latencyMicros: sw.elapsedMicroseconds,
      normalized: norm,
    );
  }

  RuleHit? _evaluate(Rule r, NormalizedText n, ScanInput input) {
    switch (r.type) {
      case RuleType.regex:
        return _matchRegex(r, n, input);
      case RuleType.keyword_proximity:
        return _matchProximity(r, n, input);
      case RuleType.url_domain_rule:
        return _matchUrl(r, n, input);
      case RuleType.upi_rule:
        return _matchUpi(r, n, input);
      case RuleType.structure_rule:
        return _matchStructure(r, n, input);
    }
  }

  RuleHit? _matchRegex(Rule r, NormalizedText n, ScanInput input) {
    final RegExp? re = _compiled[r.id];
    if (re == null) return null;
    final Match? m = re.firstMatch(n.normalized);
    if (m == null) return null;
    return _hit(r, input, _snippet(n.normalized, m.start, m.end));
  }

  RuleHit? _matchProximity(Rule r, NormalizedText n, ScanInput input) {
    final RegExp? a = _compiled[r.id];
    final RegExp? b = _compiled['${r.id}::sec'];
    if (a == null || b == null) return null;

    final List<RegExpMatch> as = a.allMatches(n.normalized).toList();
    if (as.isEmpty) return null;
    final List<RegExpMatch> bs = b.allMatches(n.normalized).toList();
    if (bs.isEmpty) return null;

    for (final RegExpMatch am in as) {
      for (final RegExpMatch bm in bs) {
        final int dist = (am.start - bm.start).abs();
        if (dist <= r.proximityChars) {
          final int s = am.start < bm.start ? am.start : bm.start;
          final int e = am.end > bm.end ? am.end : bm.end;
          return _hit(r, input, _snippet(n.normalized, s, e));
        }
      }
    }
    return null;
  }

  RuleHit? _matchUrl(Rule r, NormalizedText n, ScanInput input) {
    if (n.urls.isEmpty) return null;
    final String lower = n.lowercased;

    switch (r.pattern) {
      case 'any_link_with_login_or_pay_keyword':
        final bool sensitive = RegExp(
          r'\b(login|log[\s-]?in|verify|pay|payment|kyc|otp|password|reset)\b',
          caseSensitive: false,
        ).hasMatch(lower);
        if (!sensitive) return null;
        for (final String u in n.urls) {
          if (UrlUtils.isAllowlisted(u)) continue;
          if (!UrlUtils.isHttps(u) || UrlUtils.isSuspiciousTld(u)) {
            return _hit(r, input, u.substring(0, u.length.clamp(0, 60)));
          }
        }
        return null;

      case 'suspicious_tld_present':
        for (final String u in n.urls) {
          if (UrlUtils.isSuspiciousTld(u) && !UrlUtils.isAllowlisted(u)) {
            return _hit(r, input, u.substring(0, u.length.clamp(0, 60)));
          }
        }
        return null;

      case 'http_not_https_with_sensitive_word':
        final bool sensitive = RegExp(
          r'\b(bank|account|verify|kyc|login|otp)\b',
          caseSensitive: false,
        ).hasMatch(lower);
        if (!sensitive) return null;
        for (final String u in n.urls) {
          if (u.toLowerCase().startsWith('http://') &&
              !UrlUtils.isAllowlisted(u)) {
            return _hit(r, input, u.substring(0, u.length.clamp(0, 60)));
          }
        }
        return null;

      case 'challan_link_not_in_allowlist':
        final bool hasChallanWord =
        RegExp(r'\b(challan|chalan|चालान|चलान)\b', caseSensitive: false)
            .hasMatch(n.normalized);
        if (!hasChallanWord) return null;
        for (final String u in n.urls) {
          if (!UrlUtils.isAllowlisted(u)) {
            return _hit(r, input, u.substring(0, u.length.clamp(0, 60)));
          }
        }
        return null;
    }
    return null;
  }

  RuleHit? _matchUpi(Rule r, NormalizedText n, ScanInput input) {
    final Map<String, String>? p = input.upiParams;
    if (p == null || p.isEmpty) return null;

    switch (r.pattern) {
      case 'claimed_name_mismatch':
        final String? claimed = input.senderTitle?.trim();
        final String? pn = p['pn']?.trim();
        if (claimed == null || pn == null || claimed.isEmpty || pn.isEmpty) {
          return null;
        }
        if (_normLoose(claimed) != _normLoose(pn)) {
          return _hit(r, input, 'sticker="$claimed" ≠ upi="$pn"');
        }
        return null;

      case 'collect_intent_marked_as_receive':
      // If the QR is a `upi://pay` intent but the sender's message frames
      // it as "scan to receive", flag it.
        if (p.containsKey('pa') &&
            RegExp(r'(receive|collect|get\s*money|पैसे\s*पाने)',
                caseSensitive: false)
                .hasMatch(n.normalized)) {
          return _hit(r, input, 'pa=${p['pa']}');
        }
        return null;
    }
    return null;
  }

  RuleHit? _matchStructure(Rule r, NormalizedText n, ScanInput input) {
    switch (r.pattern) {
      case 'utr_digits_not_12':
        final RegExpMatch? m = RegExp(
          r'\bUTR[:\s#]*([0-9]{6,20})\b',
          caseSensitive: false,
        ).firstMatch(n.normalized);
        if (m == null) return null;
        final String digits = m.group(1)!;
        if (digits.length != 12) {
          return _hit(r, input, 'UTR len=${digits.length}');
        }
        return null;
    }
    return null;
  }

  static String _normLoose(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u0900-\u097F]+'), '');

  RuleHit _hit(Rule r, ScanInput input, String snippet) => RuleHit(
    ruleId: r.id,
    family: r.family,
    weight: r.weight,
    matchedSnippet: snippet.length > 60 ? snippet.substring(0, 60) : snippet,
    hint: r.hintFor(input.langCode),
  );

  String _snippet(String text, int start, int end) {
    final int s = (start - 8).clamp(0, text.length);
    final int e = (end + 8).clamp(0, text.length);
    return text.substring(s, e).replaceAll('\n', ' ');
  }
}