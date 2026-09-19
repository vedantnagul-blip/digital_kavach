import 'package:intl/intl.dart';

/// Formatting helpers used across scan history, feed timestamps, etc.
class KavachDateUtils {
  const KavachDateUtils._();

  static String relativeShort(DateTime ts, {DateTime? now}) {
    final DateTime n = now ?? DateTime.now();
    final Duration d = n.difference(ts);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return DateFormat('d MMM').format(ts);
  }

  static String isoDate(DateTime ts) => DateFormat('yyyy-MM-dd').format(ts);

  static String prettyDateTime(DateTime ts) =>
      DateFormat('d MMM y, hh:mm a').format(ts);
}