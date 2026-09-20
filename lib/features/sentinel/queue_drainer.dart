import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/utils/app_logger.dart';
import '../../data/ai/ai_router.dart';
import '../../data/firebase/auth_repo.dart';
import '../../data/firebase/user_repo.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/rules/rule_engine.dart';
import '../../data/rules/score_aggregator.dart';
import '../../features/family/family_repo.dart';
import '../../features/scanner/dev_harness_screen.dart';
import '../../features/scanner/models/scan_request.dart';
import '../../features/scanner/models/verdict.dart';
import '../../features/scanner/scanner_service.dart';
import 'feed/feed_controller.dart';
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
    if (processed > 0) {
      try {
        _ref.read(feedControllerProvider.notifier).loadEntries();
      } catch (_) {}
    }
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

    // 1. Write to Activity Feed
    try {
      if (Hive.isBoxOpen(HiveBoxes.feed)) {
        final Box<dynamic> feedBox = Hive.box<dynamic>(HiveBoxes.feed);
        final FeedEntry feedEntry = FeedEntry(
          id: entry.id,
          ts: DateTime.fromMillisecondsSinceEpoch(entry.ts),
          source: 'notification',
          level: result.finalVerdict.verdict.wire,
          score: result.finalVerdict.riskScore,
          pattern: result.finalVerdict.patternMatched,
          provider: result.finalVerdict.provider.provider.name,
          titleMeta: entry.titleMeta.isNotEmpty ? entry.titleMeta : entry.pkg,
        );
        await feedBox.put(entry.id, jsonEncode(feedEntry.toJson()));
      }
    } catch (e) {
      AppLogger.w('QueueDrainer feed write error: $e');
    }

    // 2. Family Alert hook if RED
    if (result.finalVerdict.verdict == VerdictLevel.red) {
      try {
        final AuthRepo authRepo = _ref.read(authRepoProvider);
        final UserRepo userRepo = _ref.read(userRepoProvider);
        final currentUser = authRepo.currentUser;
        if (currentUser != null) {
          final userDoc = await userRepo.getUserDoc(currentUser.uid);
          final familyId = userDoc?['familyId'] as String?;
          if (familyId != null && familyId.isNotEmpty) {
            final familyRepo = _ref.read(familyRepoProvider);
            final event = FamilyEvent(
              id: entry.id,
              familyId: familyId,
              aboutUid: currentUser.uid,
              severity: 'RED',
              pattern: result.finalVerdict.patternMatched,
              ts: DateTime.now(),
            );
            await familyRepo.writeEvent(event);
          }
        }
      } catch (e) {
        AppLogger.w('QueueDrainer family alert dispatch: $e');
      }
    }
  }
}

final Provider<QueueDrainer> queueDrainerProvider =
    Provider<QueueDrainer>((Ref ref) => QueueDrainer(ref));
