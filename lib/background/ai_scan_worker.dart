import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_kavach/data/rules/rule_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:workmanager/workmanager.dart';

import '../core/utils/app_logger.dart';
import '../data/ai/ai_router.dart';
import '../data/firebase/user_repo.dart';
import '../data/local/hive_boxes.dart';
import '../data/rules/score_aggregator.dart';
import '../features/scanner/models/scan_request.dart';
import '../features/scanner/models/verdict.dart';
import '../features/sentinel/feed/feed_controller.dart';

final StreamController<({String entryId, Verdict v})> _aiResultsController =
    StreamController<({String entryId, Verdict v})>.broadcast();

final StreamProvider<({String entryId, Verdict v})> aiResultsProvider =
    StreamProvider<({String entryId, Verdict v})>((Ref ref) {
  return _aiResultsController.stream;
});

@pragma('vm:entry-point')
void aiScanWorkerDispatcher() {
  Workmanager().executeTask(
      (String task, Map<String, dynamic>? inputData) async {
    AppLogger.i('WorkManager: $task started');

    if (task != 'aiScanRetry' || inputData == null) return true;

    ProviderContainer? container;
    try {
      // Headless initialization
      await Firebase.initializeApp();
      await HiveBoxes.openAll();

      container = ProviderContainer(
        overrides: <Override>[
          userRepoProvider.overrideWithValue(
            UserRepo(FirebaseFirestore.instance),
          ),
        ],
      );

      final AiRouter router = container.read(aiRouterProvider);
      final String text = inputData['text'] as String;
      final String hash = inputData['hash'] as String;

      final ScanRequest req =
          ScanRequest(text: text, source: ScanSource.notification);
      final Verdict verdict = await router.analyze(req);

      // Persist to feed box so the UI sees the result even across isolates
      if (Hive.isBoxOpen(HiveBoxes.feed)) {
        final Box<dynamic> feedBox = Hive.box<dynamic>(HiveBoxes.feed);
        final FeedEntry entry = FeedEntry(
          id: hash,
          ts: DateTime.now(),
          source: 'notification',
          level: verdict.verdict.wire,
          score: verdict.riskScore,
          pattern: verdict.patternMatched,
          provider: verdict.provider.provider.name,
          titleMeta: 'Background Scan',
        );
        await feedBox.put(hash, jsonEncode(entry.toJson()));
      }

      // Emit to stream controller for cases where same isolate is listening
      try {
        _aiResultsController.add((entryId: hash, v: verdict));
      } catch (_) {}

      AppLogger.i('WorkManager: Retry success for $hash');
      return true;
    } catch (e, st) {
      AppLogger.e('WorkManager: Retry failed', error: e, stackTrace: st);
      // Return false triggers WorkManager's exponential backoff
      return false;
    } finally {
      container?.dispose();
    }
  });
}
