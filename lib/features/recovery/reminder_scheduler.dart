import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/app_logger.dart';

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    notifications: FlutterLocalNotificationsPlugin(),
    clock: DateTime.now,
  );
});

/// Schedules follow-up reminders after the recovery wizard completes.
class ReminderScheduler {
  ReminderScheduler({
    required FlutterLocalNotificationsPlugin notifications,
    required DateTime Function() clock,
  })  : _notifications = notifications,
        _clock = clock;

  final FlutterLocalNotificationsPlugin _notifications;
  final DateTime Function() _clock;

  int _id6h(String sessionId) => sessionId.hashCode.abs() % 100000 + 6000;
  int _id24h(String sessionId) => sessionId.hashCode.abs() % 100000 + 24000;

  Future<void> scheduleFollowUps({
    required String sessionId,
    required DateTime from,
  }) async {
    try {
      await _scheduleOne(
        id: _id6h(sessionId),
        scheduledAt: from.add(const Duration(hours: 6)),
        title: 'Bank ne jawab diya?',
        body: '6 ghante ho gaye. Bank se confirmation aaya kya? Tap to check.',
      );
      await _scheduleOne(
        id: _id24h(sessionId),
        scheduledAt: from.add(const Duration(hours: 24)),
        title: 'Acknowledgment mila?',
        body:
        '24 ghante ho gaye. Cyber cell / bank ka acknowledgment check karein.',
      );
      AppLogger.i('Reminders scheduled for session $sessionId', tag: 'recovery');
    } catch (e) {
      AppLogger.e('Reminder scheduling failed: $e', tag: 'recovery');
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    if (scheduledAt.isBefore(_clock())) return;
    try {
      tz.TZDateTime tzDate;
      try {
        tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
      } catch (_) {
        // timezone not initialized (e.g. tests) — fall back to UTC
        tzDate = tz.TZDateTime.utc(
          scheduledAt.year, scheduledAt.month, scheduledAt.day,
          scheduledAt.hour, scheduledAt.minute,
        );
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'kavach_recovery',
            'Recovery Reminders',
            channelDescription: 'Follow-up reminders for fraud recovery',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      AppLogger.i('Reminder $id scheduled inexact: $e', tag: 'recovery');
    }
  }

  Future<void> cancelAll(String sessionId) async {
    await _notifications.cancel(_id6h(sessionId));
    await _notifications.cancel(_id24h(sessionId));
  }
}