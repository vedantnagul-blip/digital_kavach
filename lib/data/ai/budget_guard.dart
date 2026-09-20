import 'package:hive/hive.dart';

/// Limits expensive fallback (Grok) calls per day.
class BudgetGuard {
  BudgetGuard(this._box, {this.maxCallsPerDay = 25});

  final Box<dynamic> _box;
  final int maxCallsPerDay;

  String get _dateKey => _box.get('budget_date', defaultValue: '') as String;

  int get _calls {
    final String today = _today();
    if (_dateKey != today) {
      return 0;
    }
    return _box.get('budget_calls', defaultValue: 0) as int;
  }

  static String _today() =>
      DateTime.now().toIso8601String().substring(0, 10);

  bool canCall() {
    return _calls < maxCallsPerDay;
  }

  Future<void> recordCall() async {
    final String today = _today();
    final int current = (_dateKey == today)
        ? (_box.get('budget_calls', defaultValue: 0) as int)
        : 0;

    await _box.put('budget_date', today);
    await _box.put('budget_calls', current + 1);
  }
}
