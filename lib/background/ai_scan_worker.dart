import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_kavach/data/rules/rule_engine.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../core/utils/app_logger.dart';
import '../data/ai/ai_router.dart';
import '../data/local/hive_boxes.dart';
import '../features/scanner/models/scan_request.dart';
import '../features/scanner/models/verdict.dart';

final StreamController<({String entryId, Verdict v})> _aiResultsController =
StreamController<({String entryId, Verdict v})>.broadcast();

final StreamProvider<({String entryId, Verdict v})> aiResultsProvider =
StreamProvider<({String entryId, Verdict v})>((Ref ref) {
  return _aiResultsController.stream;
});

@pragma('vm:entry-point')
void aiScanWorkerDispatcher() {
  Workmanager().executeTask((String task, Map<String, dynamic>? inputData) async {
    AppLogger.i('WorkManager: $task started');

    if (task != 'aiScanRetry' || inputData == null) return true;

    try {
      // Headless initialization
      await Firebase.initializeApp();
      await HiveBoxes.openAll();

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          // FireStore instance mapping for headless headless container
        ],
      );

      final AiRouter router = container.read(aiRouterProvider);
      final String text = inputData['text'] as String;
      final String hash = inputData['hash'] as String;

      final ScanRequest req = ScanRequest(text: text, source: ScanSource.notification);
      final Verdict verdict = await router.analyze(req);

      // Emit to UI if active
      _aiResultsController.add((entryId: hash, v: verdict));
      AppLogger.i('WorkManager: Retry success for $hash');

      return true;
    } catch (e, st) {
      AppLogger.e('WorkManager: Retry failed', error: e, stackTrace: st);
      // Retur false triggers WorkManager's exponential backoff
      return false;
    }
  });
}