import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/app_logger.dart';

@immutable
class FeedEntry {
  final String id;
  final DateTime ts;
  final String source; // notification | share | qr | paste
  final String level;  // RED | AMBER | GREEN
  final int score;
  final String pattern;
  final String provider;
  final String? titleMeta;
  final bool isMuted;

  const FeedEntry({
    required this.id,
    required this.ts,
    required this.source,
    required this.level,
    required this.score,
    required this.pattern,
    required this.provider,
    this.titleMeta,
    this.isMuted = false,
  });

  FeedEntry copyWith({
    bool? isMuted,
  }) =>
      FeedEntry(
        id: id,
        ts: ts,
        source: source,
        level: level,
        score: score,
        pattern: pattern,
        provider: provider,
        titleMeta: titleMeta,
        isMuted: isMuted ?? this.isMuted,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ts': ts.toIso8601String(),
    'source': source,
    'level': level,
    'score': score,
    'pattern': pattern,
    'provider': provider,
    'titleMeta': titleMeta,
    'isMuted': isMuted,
  };

  factory FeedEntry.fromJson(Map<String, dynamic> j) => FeedEntry(
    id: j['id'] as String,
    ts: DateTime.parse(j['ts'] as String),
    source: j['source'] as String? ?? 'unknown',
    level: j['level'] as String? ?? 'GREEN',
    score: j['score'] as int? ?? 0,
    pattern: j['pattern'] as String? ?? 'general',
    provider: j['provider'] as String? ?? 'tier1',
    titleMeta: j['titleMeta'] as String?,
    isMuted: j['isMuted'] as bool? ?? false,
  );
}

enum FeedFilter { all, red, amber }

@immutable
class FeedState {
  final List<FeedEntry> entries;
  final FeedFilter filter;
  final String searchQuery;
  final bool isLoading;

  const FeedState({
    this.entries = const [],
    this.filter = FeedFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<FeedEntry> get filteredEntries {
    return entries.where((e) {
      if (filter == FeedFilter.red && e.level != 'RED') return false;
      if (filter == FeedFilter.amber && e.level != 'AMBER') return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchPattern = e.pattern.toLowerCase().contains(q);
        final matchTitle = e.titleMeta?.toLowerCase().contains(q) ?? false;
        if (!matchPattern && !matchTitle) return false;
      }
      return true;
    }).toList();
  }

  FeedState copyWith({
    List<FeedEntry>? entries,
    FeedFilter? filter,
    String? searchQuery,
    bool? isLoading,
  }) =>
      FeedState(
        entries: entries ?? this.entries,
        filter: filter ?? this.filter,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );
}

final feedControllerProvider =
StateNotifierProvider<FeedController, FeedState>((ref) {
  final box = Hive.isBoxOpen('feed') ? Hive.box('feed') : null;
  return FeedController(box: box);
});

class FeedController extends StateNotifier<FeedState> {
  FeedController({required Box? box})
      : _box = box,
        super(const FeedState()) {
    loadEntries();
  }

  final Box? _box;
  FeedEntry? _lastDismissed;
  int? _lastDismissedIndex;

  void loadEntries() {
    if (_box == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = <FeedEntry>[];
      for (var i = 0; i < _box.length; i++) {
        final raw = _box.getAt(i);
        if (raw is String) {
          list.add(FeedEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>));
        } else if (raw is Map) {
          list.add(FeedEntry.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
      list.sort((a, b) => b.ts.compareTo(a.ts));
      state = state.copyWith(entries: list, isLoading: false);
    } catch (e) {
      AppLogger.e('Failed to load feed entries: $e', tag: 'feed');
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(FeedFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addEntry(FeedEntry entry) {
    if (_box == null) return;
    _box.put(entry.id, jsonEncode(entry.toJson()));
    state = state.copyWith(entries: [entry, ...state.entries]);
  }

  void dismissEntry(String id) {
    final idx = state.entries.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    _lastDismissed = state.entries[idx];
    _lastDismissedIndex = idx;

    final updated = List<FeedEntry>.from(state.entries)..removeAt(idx);
    state = state.copyWith(entries: updated);
    _box?.delete(id);
  }

  void undoDismiss() {
    if (_lastDismissed == null || _lastDismissedIndex == null) return;
    final updated = List<FeedEntry>.from(state.entries);
    final insertIdx = _lastDismissedIndex!.clamp(0, updated.length);
    updated.insert(insertIdx, _lastDismissed!);

    _box?.put(_lastDismissed!.id, jsonEncode(_lastDismissed!.toJson()));
    state = state.copyWith(entries: updated);

    _lastDismissed = null;
    _lastDismissedIndex = null;
  }

  void toggleMute(String id) {
    final updated = state.entries.map((e) {
      if (e.id == id) {
        final m = e.copyWith(isMuted: !e.isMuted);
        _box?.put(id, jsonEncode(m.toJson()));
        return m;
      }
      return e;
    }).toList();
    state = state.copyWith(entries: updated);
  }

  void clearAll() {
    _box?.clear();
    state = state.copyWith(entries: []);
  }
}