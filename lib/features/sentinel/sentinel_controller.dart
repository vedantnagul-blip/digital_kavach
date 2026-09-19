import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';

/// Snapshot of Sentinel Mode's current status.
@immutable
class SentinelStatus {
  const SentinelStatus({
    required this.enabled,
    required this.listenerGranted,
    required this.batteryExempted,
    required this.lastConnectedTs,
    required this.queueSize,
    required this.gapLog,
    required this.packageAllowlist,
  });

  final bool enabled;
  final bool listenerGranted;
  final bool batteryExempted;
  final int lastConnectedTs;
  final int queueSize;
  final String gapLog;
  final List<String> packageAllowlist;

  static const SentinelStatus empty = SentinelStatus(
    enabled: false,
    listenerGranted: false,
    batteryExempted: false,
    lastConnectedTs: 0,
    queueSize: 0,
    gapLog: '[]',
    packageAllowlist: <String>[],
  );

  bool get isFullyReady => enabled && listenerGranted && batteryExempted;

  factory SentinelStatus.fromMap(Map<dynamic, dynamic> map) {
    return SentinelStatus(
      enabled: map['enabled'] as bool? ?? false,
      listenerGranted: map['listenerGranted'] as bool? ?? false,
      batteryExempted: map['batteryExempted'] as bool? ?? false,
      lastConnectedTs: (map['lastConnectedTs'] as num?)?.toInt() ?? 0,
      queueSize: (map['queueSize'] as num?)?.toInt() ?? 0,
      gapLog: map['gapLog'] as String? ?? '[]',
      packageAllowlist:
      (map['packageAllowlist'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
    );
  }
}

class SentinelController extends AsyncNotifier<SentinelStatus> {
  static const MethodChannel _channel = MethodChannel('kavach/sentinel');

  @override
  Future<SentinelStatus> build() async {
    return _fetchStatus();
  }

  Future<SentinelStatus> _fetchStatus() async {
    try {
      final Map<dynamic, dynamic>? result =
      await _channel.invokeMapMethod<dynamic, dynamic>('getStatus');
      if (result == null) return SentinelStatus.empty;
      return SentinelStatus.fromMap(result);
    } on PlatformException catch (e) {
      AppLogger.w('SentinelController status fetch failed: ${e.message}');
      return SentinelStatus.empty;
    } catch (e) {
      AppLogger.e('SentinelController unexpected error', error: e);
      return SentinelStatus.empty;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue<SentinelStatus>.loading();
    state = AsyncValue<SentinelStatus>.data(await _fetchStatus());
  }

  Future<void> openListenerSettings() async {
    try {
      await _channel.invokeMethod<bool>('openListenerSettings');
    } on PlatformException catch (e) {
      AppLogger.w('openListenerSettings failed: ${e.message}');
    }
  }

  Future<void> requestBatteryExemption() async {
    try {
      await _channel.invokeMethod<bool>('requestBatteryExemption');
    } on PlatformException catch (e) {
      AppLogger.w('requestBatteryExemption failed: ${e.message}');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod<bool>('setEnabled', <String, dynamic>{
        'enabled': enabled,
      });
      await refresh();
    } on PlatformException catch (e) {
      AppLogger.w('setEnabled failed: ${e.message}');
    }
  }

  Future<void> updatePackageAllowlist(List<String> packages) async {
    try {
      await _channel.invokeMethod<bool>('updatePackageAllowlist',
          <String, dynamic>{'packages': packages});
      await refresh();
    } on PlatformException catch (e) {
      AppLogger.w('updatePackageAllowlist failed: ${e.message}');
    }
  }

  Future<void> updateQuietHours(int start, int end) async {
    try {
      await _channel.invokeMethod<bool>('updateQuietHours', <String, dynamic>{
        'start': start,
        'end': end,
      });
    } on PlatformException catch (e) {
      AppLogger.w('updateQuietHours failed: ${e.message}');
    }
  }

  Future<String> getQueuedEntriesJson() async {
    try {
      final String? raw =
      await _channel.invokeMethod<String>('getQueuedEntries');
      return raw ?? '[]';
    } on PlatformException catch (e) {
      AppLogger.w('getQueuedEntries failed: ${e.message}');
      return '[]';
    }
  }

  Future<void> deleteQueueEntry(String entryId) async {
    try {
      await _channel.invokeMethod<bool>(
          'deleteQueueEntry', <String, dynamic>{'entryId': entryId});
    } on PlatformException catch (e) {
      AppLogger.w('deleteQueueEntry failed: ${e.message}');
    }
  }
}

final AsyncNotifierProvider<SentinelController, SentinelStatus>
sentinelControllerProvider =
AsyncNotifierProvider<SentinelController, SentinelStatus>(
    SentinelController.new);