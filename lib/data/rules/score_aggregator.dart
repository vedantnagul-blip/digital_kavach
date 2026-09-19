import 'rule.dart';

enum VerdictLevel { green, amber, red }

extension VerdictLevelX on VerdictLevel {
  String get wire {
    switch (this) {
      case VerdictLevel.green: return 'SAFE';
      case VerdictLevel.amber: return 'SUSPICIOUS';
      case VerdictLevel.red:   return 'SCAM';
    }
  }

  static VerdictLevel fromWire(String s) {
    switch (s.toUpperCase()) {
      case 'SCAM':       return VerdictLevel.red;
      case 'SUSPICIOUS': return VerdictLevel.amber;
      case 'SAFE':       return VerdictLevel.green;
      default:           return VerdictLevel.green;
    }
  }
}

class ScoreResult {
  const ScoreResult({
    required this.score,
    required this.level,
    required this.dedupedHits,
    required this.familyBonusApplied,
  });

  final int score;
  final VerdictLevel level;
  final List<RuleHit> dedupedHits;
  final int familyBonusApplied;
}

/// Aggregation:
///  - Score = clamp(Σ weights, 0..100)
///  - **Family cap**: within a single family, the summed weight can never
///    exceed 70 (prevents a stack of same-family rules dominating).
///  - **Urgency bonus**: +10 if ≥2 pressure markers (r_urgency_* or
///    proximity family=digital_arrest with weight ≤ 20). Capped by 100.
///  - Level thresholds: ≥60 red, 25–59 amber, <25 green.
class ScoreAggregator {
  const ScoreAggregator._();

  static const int _familyCap = 70;
  static const int _urgencyBonus = 10;

  static ScoreResult score(List<RuleHit> hits) {
    if (hits.isEmpty) {
      return const ScoreResult(
        score: 0,
        level: VerdictLevel.green,
        dedupedHits: <RuleHit>[],
        familyBonusApplied: 0,
      );
    }

    // Dedup by ruleId (a rule shouldn't count twice).
    final Map<String, RuleHit> byId = <String, RuleHit>{};
    for (final RuleHit h in hits) {
      byId.putIfAbsent(h.ruleId, () => h);
    }
    final List<RuleHit> deduped = byId.values.toList(growable: false);

    // Apply family cap.
    final Map<ScamFamily, int> perFamily = <ScamFamily, int>{};
    for (final RuleHit h in deduped) {
      perFamily.update(h.family, (int v) => v + h.weight,
          ifAbsent: () => h.weight);
    }

    int total = 0;
    for (final MapEntry<ScamFamily, int> e in perFamily.entries) {
      total += e.value > _familyCap ? _familyCap : e.value;
    }

    // Urgency bonus.
    final int pressureCount = deduped
        .where((RuleHit h) => h.ruleId.startsWith('r_urgency_'))
        .length;
    int bonus = 0;
    if (pressureCount >= 2) bonus = _urgencyBonus;
    total += bonus;

    if (total < 0) total = 0;
    if (total > 100) total = 100;

    VerdictLevel level;
    if (total >= 60) {
      level = VerdictLevel.red;
    } else if (total >= 25) {
      level = VerdictLevel.amber;
    } else {
      level = VerdictLevel.green;
    }

    return ScoreResult(
      score: total,
      level: level,
      dedupedHits: deduped,
      familyBonusApplied: bonus,
    );
  }
}