import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/utils/app_logger.dart';
import '../local/hive_boxes.dart';

/// Represents a learned scam or safe pattern signature in the active memory.
class LearnedThreat {
  const LearnedThreat({
    required this.id,
    required this.family,
    required this.sampleSnippet,
    required this.redFlags,
    required this.isScam,
    required this.timestamp,
  });

  final String id;
  final String family;
  final String sampleSnippet;
  final List<String> redFlags;
  final bool isScam;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'family': family,
        'sampleSnippet': sampleSnippet,
        'redFlags': redFlags,
        'isScam': isScam,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LearnedThreat.fromJson(Map<String, dynamic> j) {
    return LearnedThreat(
      id: j['id'] as String? ?? '',
      family: j['family'] as String? ?? 'other',
      sampleSnippet: j['sampleSnippet'] as String? ?? '',
      redFlags: (j['redFlags'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          <String>[],
      isScam: j['isScam'] as bool? ?? true,
      timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

final Provider<ThreatMemoryStore> threatMemoryStoreProvider =
    Provider<ThreatMemoryStore>((Ref ref) {
  return ThreatMemoryStore(Hive.box<dynamic>(HiveBoxes.cache));
});

/// Production Active Learning Threat Memory.
///
/// Implements Handbook Section 8 (Memory) & Section 10 (RAG):
/// Remembers confirmed scam patterns across scans so the AI dynamically
/// "trains" and improves without waiting for offline model updates.
class ThreatMemoryStore {
  ThreatMemoryStore(this._box);

  final Box<dynamic> _box;
  static const String _storageKey = 'learned_threat_signatures_v1';

  /// Pre-seeded baseline threat signatures from real-world Indian cyber crime cases.
  static final List<LearnedThreat> _baselineThreats = <LearnedThreat>[
    LearnedThreat(
      id: 'baseline_electricity_01',
      family: 'electricity_bill',
      sampleSnippet:
          'Electricity will be disconnected tonight at 9:30 PM because previous month bill not updated. Call electricity officer at 9876543210',
      redFlags: <String>[
        'Urgent power cut ultimatum tonight',
        'Personal 10-digit mobile number for electricity officer',
        'Demands payment/APK outside official portal',
      ],
      isScam: true,
      timestamp: DateTime(2026, 1, 1),
    ),
    LearnedThreat(
      id: 'baseline_digital_arrest_01',
      family: 'digital_arrest',
      sampleSnippet:
          'Supreme Court and CBI arrest warrant notice. Aadhaar used for money laundering. Join video call within 20 minutes',
      redFlags: <String>[
        'Fabricated Digital Arrest claim (no legal existence in India)',
        'Forced appearance on WhatsApp/Skype video call',
        'Threat of imminent police raid under 20 minutes',
      ],
      isScam: true,
      timestamp: DateTime(2026, 1, 1),
    ),
    LearnedThreat(
      id: 'baseline_bank_kyc_01',
      family: 'fake_kyc',
      sampleSnippet:
          'SBI YONO account blocked today due to pending KYC update. Click here to verify Aadhaar and download APK',
      redFlags: <String>[
        'Account blocked panic trigger',
        'Malicious third-party APK link',
        'Unofficial domain mimicking SBI/YONO',
      ],
      isScam: true,
      timestamp: DateTime(2026, 1, 1),
    ),
  ];

  /// Retrieve all stored threat patterns (baseline + dynamically learned).
  List<LearnedThreat> getAllLearnedThreats() {
    try {
      final dynamic raw = _box.get(_storageKey);
      if (raw == null) return _baselineThreats;
      final List<dynamic> list = jsonDecode(raw as String) as List<dynamic>;
      final List<LearnedThreat> userLearned = list
          .map((dynamic e) => LearnedThreat.fromJson(e as Map<String, dynamic>))
          .toList();
      return <LearnedThreat>[..._baselineThreats, ...userLearned];
    } catch (e) {
      AppLogger.w('ThreatMemoryStore load failed: $e');
      return _baselineThreats;
    }
  }

  /// "Train" the AI on a new scam or safe message:
  /// Indexes the message signature into persistent memory.
  Future<void> learnPattern({
    required String text,
    required String family,
    required List<String> redFlags,
    required bool isScam,
  }) async {
    try {
      final List<LearnedThreat> current = getAllLearnedThreats();

      // Don't duplicate identical snippets
      final String snippet = text.length > 120 ? text.substring(0, 120) : text;
      if (current.any((t) => t.sampleSnippet == snippet)) return;

      final LearnedThreat newThreat = LearnedThreat(
        id: 'learned_${DateTime.now().millisecondsSinceEpoch}',
        family: family,
        sampleSnippet: snippet,
        redFlags: redFlags,
        isScam: isScam,
        timestamp: DateTime.now(),
      );

      final List<LearnedThreat> updated = <LearnedThreat>[
        newThreat,
        ...current.where((t) => !t.id.startsWith('baseline_')),
      ];

      // Keep up to 50 learned signatures to avoid storage bloat
      if (updated.length > 50) updated.removeRange(50, updated.length);

      await _box.put(
        _storageKey,
        jsonEncode(updated.map((t) => t.toJson()).toList()),
      );

      AppLogger.i('ThreatMemoryStore: successfully learned new threat signature [${newThreat.family}]');
    } catch (e) {
      AppLogger.e('ThreatMemoryStore: learnPattern failed: $e');
    }
  }

  /// Finds the most relevant learned threat memories for the given query text.
  /// Formats them for dynamic few-shot injection into the prompt.
  String getDynamicThreatContext(String queryText) {
    final List<LearnedThreat> all = getAllLearnedThreats();
    final String lower = queryText.toLowerCase();

    // Score threats by keyword relevance
    final List<({LearnedThreat threat, int score})> scored = [];
    for (final t in all) {
      int score = 0;
      final String tSnippet = t.sampleSnippet.toLowerCase();
      final words = tSnippet.split(RegExp(r'\s+')).where((w) => w.length > 3);
      for (final w in words) {
        if (lower.contains(w)) score++;
      }
      if (lower.contains(t.family.toLowerCase())) score += 3;
      if (score > 0) scored.add((threat: t, score: score));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    final topThreats = scored.take(2).map((e) => e.threat).toList();
    if (topThreats.isEmpty) {
      return '';
    }

    final StringBuffer sb = StringBuffer();
    sb.writeln('DYNAMIC THREAT MEMORY (RECENTLY CONFIRMED SCAMS):');
    for (final t in topThreats) {
      sb.writeln(
        '- Pattern: ${t.family.toUpperCase()} | Is Scam: ${t.isScam}\n'
        '  Sample Indicators: "${t.sampleSnippet}"\n'
        '  Observed Red Flags: ${t.redFlags.join(', ')}',
      );
    }
    return sb.toString();
  }
}
