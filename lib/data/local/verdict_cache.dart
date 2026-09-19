import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../../core/errors/kavach_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../features/scanner/models/verdict.dart';

/// Cross-provider verdict cache keyed by SHA-256 of normalized text.
///
/// Consumed by Phase 04 [AiRouter] to short-circuit repeat scans.
abstract class VerdictCache {
  Future<Verdict?> byHash(String hash);
  Future<void> put(String hash, Verdict verdict);
  Future<void> clear();
  int get length;
}

class HiveVerdictCache implements VerdictCache {
  HiveVerdictCache(this._box, {this.maxEntries = 500, this.ttl = const Duration(days: 30)});

  final Box<dynamic> _box;
  final int maxEntries;
  final Duration ttl;

  static const String _kMeta = '__lru__';

  @override
  int get length => _box.keys.where((dynamic k) => k != _kMeta).length;

  @override
  Future<Verdict?> byHash(String hash) async {
    final dynamic raw = _box.get(hash);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> j = jsonDecode(raw as String) as Map<String, dynamic>;
      final int ts = (j['__ts'] as num).toInt();
      final DateTime saved = DateTime.fromMillisecondsSinceEpoch(ts);
      if (DateTime.now().difference(saved) > ttl) {
        await _box.delete(hash);
        return null;
      }
      return Verdict.fromJson(j['v'] as Map<String, dynamic>);
    } catch (e) {
      AppLogger.w('VerdictCache parse fail — evicting $hash: $e');
      await _box.delete(hash);
      return null;
    }
  }

  @override
  Future<void> put(String hash, Verdict verdict) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{
        '__ts': DateTime.now().millisecondsSinceEpoch,
        'v': verdict.toJson(),
      };
      await _box.put(hash, jsonEncode(payload));
      await _touchLru(hash);
    } catch (e, st) {
      AppLogger.e('VerdictCache put failed', error: e, stackTrace: st);
      throw StorageException(e.toString());
    }
  }

  Future<void> _touchLru(String hash) async {
    final List<String> order = ((_box.get(_kMeta) as List<dynamic>?) ?? <dynamic>[])
        .cast<String>()
        .toList();
    order.remove(hash);
    order.add(hash);
    while (order.length > maxEntries) {
      final String evict = order.removeAt(0);
      await _box.delete(evict);
    }
    await _box.put(_kMeta, order);
  }

  @override
  Future<void> clear() async => _box.clear();

  /// Compute canonical hash key from normalized text (used by callers).
  static String hashOf(String normalizedText) =>
      sha256.convert(utf8.encode(normalizedText)).toString();
}