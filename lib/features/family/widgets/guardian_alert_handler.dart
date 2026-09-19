import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_logger.dart';
import '../family_repo.dart';

final guardianAlertHandlerProvider = Provider<GuardianAlertHandler>((ref) {
  return GuardianAlertHandler(
    notifications: FlutterLocalNotificationsPlugin(),
    clock: DateTime.now,
  );
});

/// Handles incoming RED events and shows guardian heads-up notifications.
///
/// Rate-limit: max 1 alert per elder per 10 minutes.
/// Privacy: notification contains pattern + time ONLY — never message content.
class GuardianAlertHandler {
  GuardianAlertHandler({
    required FlutterLocalNotificationsPlugin notifications,
    required DateTime Function() clock,
  })  : _notifications = notifications,
        _clock = clock;

  final FlutterLocalNotificationsPlugin _notifications;
  final DateTime Function() _clock;

  /// Tracks last alert time per elder UID for rate-limiting.
  final Map<String, DateTime> _lastAlertTime = {};

  /// Set of event IDs already alerted (dedup).
  final Set<String> _alertedEventIds = {};

  /// Handle a new RED event.
  void handleEvent(FamilyEvent event, List<FamilyMember> members) {
    // Dedup by event ID
    if (_alertedEventIds.contains(event.id)) return;

    // Rate-limit: 1 per elder per 10 min
    final lastAlert = _lastAlertTime[event.aboutUid];
    if (lastAlert != null &&
        _clock().difference(lastAlert).inMinutes < 10) {
      AppLogger.i(
        'Rate-limited alert for ${event.aboutUid}',
        tag: 'family',
      );
      return;
    }

    _alertedEventIds.add(event.id);
    _lastAlertTime[event.aboutUid] = _clock();

    // Find elder's name
    final elder = members
        .where((m) => m.uid == event.aboutUid)
        .firstOrNull;
    final elderName = elder?.displayName ?? 'Family member';

    // Pattern label (localized in production via L10n)
    final patternLabel = _humanizePattern(event.pattern);
    final minutesAgo = _clock().difference(event.ts).inMinutes;
    final timeLabel = minutesAgo < 1 ? 'abhi' : '$minutesAgo min pehle';

    _showNotification(
      id: event.id.hashCode.abs() % 100000,
      title: '$elderName ko $patternLabel message mila',
      body: '$timeLabel — call kar lo?',
      elderPhone: elder?.phoneNumber,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? elderPhone,
  }) async {
    try {
      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'kavach_family',
            'Family Alerts',
            channelDescription: 'Red alerts from family members',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      AppLogger.e('Family notification failed: $e', tag: 'family');
    }
  }

  String _humanizePattern(String pattern) {
    return pattern
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  /// Reset rate-limit state (for testing).
  void reset() {
    _lastAlertTime.clear();
    _alertedEventIds.clear();
  }
}