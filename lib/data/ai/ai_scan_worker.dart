import 'dart:async';

import 'package:digital_kavach/data/rules/rule_engine.dart';
import 'package:digital_kavach/features/scanner/models/scan_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/utils/app_logger.dart';
import '../../data/local/hive_boxes.dart';
import '../../data/local/verdict_cache.dart';
import '../../features/scanner/models/verdict.dart';
import 'ai_router.dart';

/// Background retry executor for failed AI scans.
///
/// Reads queued requests from Hive `queue` box, retries via [AiRouter],
/// and emits results on [aiResultsProvider] stream.
///
/// IMPORTANT: This runs in a headless Flutter engine (WorkManager callback).
/// It creates its OWN ProviderContainer — do NOT use the UI ProviderScope.

/// Broadcast stream of AI results from background retries.
/// Phase 05/07 consumers listen to this to update feed entries.
final aiResultsProvider = StreamProvider<({String entryId, Verdict verdict})>(
      (ref) => _aiResultsController.stream,
);

final _aiResultsController =
StreamController<({String entryId, Verdict verdict})>.broadcast();

/// WorkManager callback dispatcher.
/// Registered in main.dart: Workmanager().initialize(aiScanWorkerDispatcher)
@pragma('vm:entry-point')
void aiScanWorkerDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != 'aiScanRetry') return Future.value(true);

    final String? text = inputData?['text'] as String?;
    final String? hash = inputData?['hash'] as String?;

    if (text == null || hash == null) {
      AppLogger.e('aiScanWorker: missing text or hash', tag: 'worker');
      return Future.value(false);
    }

    try {
      // Initialize Hive in the background isolate
      await Hive.initFlutter();
      if (!Hive.isBoxOpen(HiveBoxes.cache)) {
        await Hive.openBox<dynamic>(HiveBoxes.cache);
      }
      if (!Hive.isBoxOpen(HiveBoxes.aiState)) {
        await Hive.openBox<dynamic>(HiveBoxes.aiState);
      }
      if (!Hive.isBoxOpen(HiveBoxes.prefs)) {
        await Hive.openBox<dynamic>(HiveBoxes.prefs);
      }

      // Check if already cached (another run may have succeeded)
      final cache = HiveVerdictCache(Hive.box<dynamic>(HiveBoxes.cache));
      final existing = await cache.byHash(hash);
      if (existing != null) {
        AppLogger.i('aiScanWorker: already cached, skipping', tag: 'worker');
        return Future.value(true);
      }

      // Create a standalone provider container for background use
      final container = ProviderContainer();
      try {
        final router = container.read(aiRouterProvider);

        // Build a minimal ScanRequest for retry
        final req = ScanRequest(
          text: text,
          source: ScanSource.notification,
        );

        final verdict = await router.analyze(req);

        // Emit result for UI consumers
        _aiResultsController.add((
        entryId: hash,
        verdict: verdict,
        ));

        AppLogger.i('aiScanWorker: retry succeeded for hash=${hash.substring(0, 8)}',
            tag: 'worker');
        return Future.value(true);
      } finally {
        container.dispose();
      }
    } catch (e) {
      AppLogger.e('aiScanWorker: retry failed — $e', tag: 'worker');
      return Future.value(false); // WorkManager will retry with backoff
    }
  });
}