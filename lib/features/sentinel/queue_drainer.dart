import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../data/ai/ai_router.dart';
import '../../data/rules/rule_engine.dart';
import '../../features/scanner/dev_harness_screen.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import '../../features/scanner/scanner_service.dart';
import 'sentinel_controller.dart';

/// Represents a single Sentinel queue entry drained from Kotlin.
@immutable
class SentinelQueueEntry {
  const SentinelQueueEntry({
    required this.id,
    required this.ts,
    required this.pkg,
    required this.titleMeta,
    required this.line,
    required this.score,
    required this.family,
    required this.ruleId,
  });

  final String id;
  final int ts;
  final String pkg;
  final String titleMeta;
  final String line;
  final int score;
  final String family;
  final String ruleId;

  factory SentinelQueueEntry.fromJson(Map<String, dynamic> j) {
    return SentinelQueueEntry(
      id: j['id'] as String,
      ts: (j['ts'] as num).toInt(),
      pkg: j['pkg'] as String,
      titleMeta: j['titleMeta'] as String? ?? '',
      line: j['line'] as String,
      score: (j['score'] as num).toInt(),
      family: j['family'] as String? ?? 'other',
      ruleId: j['ruleId'] as String? ?? '',
    );
  }
}

/// Drains Kotlin's Sentinel queue → runs AI upgrade → writes to feed.
class QueueDrainer {
  QueueDrainer(this._ref);
  final Ref _ref;

  Future<int> drainAll() async {
    final SentinelController ctrl =
    _ref.read(sentinelControllerProvider.notifier);
    final String rawJson = await ctrl.getQueuedEntriesJson();

    late final List<dynamic> raw;
    try {
      raw = jsonDecode(rawJson) as List<dynamic>;
    } catch (e) {
      AppLogger.w('QueueDrainer: bad JSON, skipping');
      return 0;
    }

    if (raw.isEmpty) return 0;

    int processed = 0;
    for (final dynamic item in raw) {
      try {
        final SentinelQueueEntry entry =
        SentinelQueueEntry.fromJson(item as Map<String, dynamic>);

        // Run AI upgrade for red/amber entries
        await _processEntry(entry);
        await ctrl.deleteQueueEntry(entry.id);
        processed++;
      } catch (e, st) {
        AppLogger.e('QueueDrainer entry failed', error: e, stackTrace: st);
        // Continue with next entry
      }
    }
    AppLogger.i('QueueDrainer: processed $processed entries');
    return processed;
  }

  Future<void> _processEntry(SentinelQueueEntry entry) async {
    final RuleEngine engine = await _ref.read(ruleEngineProvider.future);
    final AiRouter router = _ref.read(aiRouterProvider);

    final ScanRequest req = ScanRequest(
      text: entry.line,
      source: ScanSource.notification,
      senderTitle: entry.titleMeta,
    );

    final HybridScanResult result =
    await router.hybridAnalyze(req, engine);

    AppLogger.i(
      'QueueDrainer: entry=${entry.id} score=${result.finalVerdict.riskScore} '
          'verdict=${result.finalVerdict.verdict.name}',
    );

    // TODO(phase-08): Trigger family alert hook if RED
    // await onRedEvent(entry, result);
  }
}

final Provider<QueueDrainer> queueDrainerProvider =
Provider<QueueDrainer>((Ref ref) => QueueDrainer(ref));