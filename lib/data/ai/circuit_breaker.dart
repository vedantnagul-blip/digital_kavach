import 'package:hive/hive.dart';

import '../../core/utils/app_logger.dart';

/// Prevents cascading failures. 3 fails → open for 10 mins.
class CircuitBreaker {
  CircuitBreaker(this._box, {this.provider = 'gemini'});

  final Box<dynamic> _box;
  final String provider;

  static const int _maxFailures = 3;
  static const Duration _openDuration = Duration(minutes: 10);

  String get _failKey => 'circuit_${provider}_fails';
  String get _tsKey => 'circuit_${provider}_open_ts';

  bool isOpen() {
    final int? openTs = _box.get(_tsKey) as int?;
    if (openTs != null) {
      final DateTime openedAt = DateTime.fromMillisecondsSinceEpoch(openTs);
      if (DateTime.now().difference(openedAt) < _openDuration) {
        return true;
      }
      // Half-open / reset
      _reset();
    }
    return false;
  }

  Future<void> recordFailure() async {
    final int fails = (_box.get(_failKey, defaultValue: 0) as int) + 1;
    if (fails >= _maxFailures) {
      AppLogger.w('Circuit breaker OPEN for $provider');
      await _box.put(_tsKey, DateTime.now().millisecondsSinceEpoch);
      await _box.put(_failKey, 0); // reset counter while open
    } else {
      await _box.put(_failKey, fails);
    }
  }

  Future<void> recordSuccess() async {
    if ((_box.get(_failKey) as int?) != 0) {
      await _reset();
    }
  }

  Future<void> _reset() async {
    await _box.delete(_tsKey);
    await _box.put(_failKey, 0);
  }

  // Dev tools
  Future<void> resetForDev() => _reset();
  int get currentFailures => _box.get(_failKey, defaultValue: 0) as int;
}