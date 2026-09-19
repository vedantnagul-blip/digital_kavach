import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sentinel_controller.dart';

class UptimeSnapshot {
  const UptimeSnapshot({
    required this.uptime7d,
    required this.lastGapMinutes,
    required this.totalGaps,
  });

  final double uptime7d; // 0.0 to 1.0
  final int lastGapMinutes;
  final int totalGaps;
}

/// Computes uptime % from Kotlin gap telemetry log.
final FutureProvider<UptimeSnapshot> uptimeProvider =
FutureProvider<UptimeSnapshot>((Ref ref) async {
  final SentinelStatus? status =
      ref.watch(sentinelControllerProvider).valueOrNull;
  if (status == null) {
    return const UptimeSnapshot(
        uptime7d: 0.0, lastGapMinutes: 0, totalGaps: 0);
  }

  try {
    final List<dynamic> gaps = jsonDecode(status.gapLog) as List<dynamic>;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    final int cutoff = nowMs - sevenDaysMs;

    int totalGapMs = 0;
    int lastGapMs = 0;
    int gapCount = 0;

    for (final dynamic item in gaps) {
      final Map<String, dynamic> g = item as Map<String, dynamic>;
      final int from = (g['from'] as num).toInt();
      final int to = (g['to'] as num).toInt();
      final int gapMs = (g['gap_ms'] as num).toInt();

      if (to >= cutoff) {
        totalGapMs += gapMs;
        gapCount++;
        if (from > (nowMs - lastGapMs)) lastGapMs = gapMs;
      }
    }

    final int windowMs = nowMs > cutoff ? sevenDaysMs : (nowMs - cutoff);
    final double uptime = windowMs > 0
        ? ((windowMs - totalGapMs) / windowMs).clamp(0.0, 1.0)
        : 1.0;

    return UptimeSnapshot(
      uptime7d: uptime,
      lastGapMinutes: (lastGapMs / 60000).round(),
      totalGaps: gapCount,
    );
  } catch (e) {
    return const UptimeSnapshot(
        uptime7d: 1.0, lastGapMinutes: 0, totalGaps: 0);
  }
});