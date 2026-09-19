import 'package:hive_flutter/hive_flutter.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';

/// Names and initialization helpers for application Hive boxes.
class HiveBoxes {
  const HiveBoxes._();

  /// User preferences and onboarding state.
  static const String prefs = 'prefs';

  /// Cached verdicts.
  static const String cache = 'cache';

  /// Activity feed metadata.
  static const String feed = 'feed';

  /// Pending background work.
  static const String queue = 'queue';

  /// AI circuit-breaker and budget state.
  static const String aiState = 'ai_state';

  /// Recovery sessions and evidence checklists.
  static const String recovery = 'recovery';

  /// Initializes Hive and opens the application's required boxes.
  ///
  /// Call and await this before widgets read synchronous Hive providers.
  /// An initialization failure is reported as a [StorageException].
  ///
  /// This method does not create an in-memory fallback.
  static Future<void> openAll() async {
    try {
      await Hive.initFlutter();

      await Future.wait<Box<dynamic>>(
        <Future<Box<dynamic>>>[
          Hive.openBox<dynamic>(prefs),
          Hive.openBox<dynamic>(cache),
          Hive.openBox<dynamic>(feed),
          Hive.openBox<dynamic>(queue),
          Hive.openBox<dynamic>(aiState),
          Hive.openBox<dynamic>(recovery),
        ],
      );

      AppLogger.i(
        'Application Hive boxes opened successfully.',
        tag: 'storage',
      );
    } catch (error) {
      AppLogger.e(
        'Failed to initialize application storage.',
        tag: 'storage',
      );

      // StorageException accepts ONE optional positional message.
      throw StorageException('Failed to open Hive boxes: $error');
    }
  }

  /// Returns the recovery box after [openAll] has completed successfully.
  static Box<dynamic> get recoveryBox {
    if (!Hive.isBoxOpen(recovery)) {
      throw const StorageException(
        'Recovery Hive box is not open. '
            'Await HiveBoxes.openAll() before accessing recovery storage.',
      );
    }

    return Hive.box<dynamic>(recovery);
  }
}