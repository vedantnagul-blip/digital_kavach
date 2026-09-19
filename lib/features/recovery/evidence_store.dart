import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/app_logger.dart';

final evidenceStoreProvider = Provider<EvidenceStore>((ref) {
  return EvidenceStore(box: Hive.box('recovery'));
});

/// Persists the evidence checklist per recovery session.
class EvidenceStore {
  EvidenceStore({required Box box}) : _box = box;
  final Box _box;

  /// The five canonical evidence items.
  static const List<String> defaultKeys = [
    'screenshot_chat',
    'scammer_number',
    'utr_txn_id',
    'call_log',
    'app_notifications',
  ];

  String _key(String sessionId) => 'evidence_$sessionId';

  /// Save the checklist state for a session.
  Future<void> save(String sessionId, Map<String, bool> checks) async {
    try {
      await _box.put(_key(sessionId), jsonEncode(checks));
    } catch (e) {
      AppLogger.e('Evidence save failed: $e', tag: 'recovery');
    }
  }

  /// Load the checklist state for a session.
  Map<String, bool> load(String sessionId) {
    try {
      final raw = _box.get(_key(sessionId));
      if (raw is String) {
        return Map<String, bool>.from(jsonDecode(raw) as Map);
      }
    } catch (e) {
      AppLogger.e('Evidence load failed: $e', tag: 'recovery');
    }
    return {};
  }

  /// Clear evidence for a session.
  Future<void> clear(String sessionId) async {
    await _box.delete(_key(sessionId));
  }
}