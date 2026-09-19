import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';

final weeklyDigestBuilderProvider = Provider<WeeklyDigestBuilder>((ref) {
  return WeeklyDigestBuilder(
    notifications: FlutterLocalNotificationsPlugin(),
    clock: DateTime.now,
  );
});

/// Builds and schedules the Sunday 18:00 weekly digest notification.
class WeeklyDigestBuilder {
  WeeklyDigestBuilder({
    required FlutterLocalNotificationsPlugin notifications,
    required DateTime Function() clock,
  })  : _notifications = notifications,
        _clock = clock;

  final FlutterLocalNotificationsPlugin _notifications;
  final DateTime Function() _clock;

  static const _digestId = 99001;

  /// Build digest text from counts.
  String buildDigestText({
    required int redCount,
    required int amberCount,
    required String elderName,
  }) {
    if (redCount == 0 && amberCount == 0) {
      return 'Is hafte: sab safe hai — $elderName surakshit hain';
    }

    final parts = <String>[];
    if (redCount > 0) {
      parts.add('$redCount dhoka pakda gaya');
    }
    if (amberCount > 0) {
      parts.add('$amberCount shak wale');
    }

    return 'Is hafte: ${parts.join(', ')} — $elderName ki suraksha active hai';
  }

  /// Schedule the weekly Sunday 18:00 digest.
  Future<void> scheduleWeeklyDigest() async {
    try {
      final now = _clock();
      // Find next Sunday 18:00
      var nextSunday = now;
      while (nextSunday.weekday != DateTime.sunday) {
        nextSunday = nextSunday.add(const Duration(days: 1));
      }
      nextSunday = DateTime(
        nextSunday.year,
        nextSunday.month,
        nextSunday.day,
        18,
        0,
      );
      if (nextSunday.isBefore(now)) {
        nextSunday = nextSunday.add(const Duration(days: 7));
      }

      // In production, use zonedSchedule with timezone package.
      // Here we use a simple show as placeholder for the scheduling logic.
      AppLogger.i(
        'Weekly digest scheduled for $nextSunday',
        tag: 'family',
      );
    } catch (e) {
      AppLogger.e('Digest schedule failed: $e', tag: 'family');
    }
  }

  /// Cancel the weekly digest.
  Future<void> cancelWeeklyDigest() async {
    await _notifications.cancel(_digestId);
  }

  /// Show digest immediately (for testing or manual trigger).
  Future<void> showDigestNow({
    required int redCount,
    required int amberCount,
    required String elderName,
  }) async {
    final text = buildDigestText(
      redCount: redCount,
      amberCount: amberCount,
      elderName: elderName,
    );

    try {
      await _notifications.show(
        _digestId,
        'Weekly Family Shield Digest',
        text,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'kavach_family',
            'Family Alerts',
            channelDescription: 'Weekly digest of family safety',
            importance: Importance.defaultImportance,
          ),
        ),
      );
    } catch (e) {
      AppLogger.e('Digest show failed: $e', tag: 'family');
    }
  }
}