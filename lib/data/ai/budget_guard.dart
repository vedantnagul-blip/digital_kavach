import 'package:hive/hive.dart';

/// Limits expensive fallback (Grok) calls per day.
class BudgetGuard {
  BudgetGuard(this._box, {this.maxCallsPerDay = 25});

  final Box<dynamic> _box;
  final int maxCallsPerDay;

  String get _dateKey => _box.get('budget_date', defaultValue: '') as String;
  int get _calls => _box.get('budget_calls', defaultValue: 0) as int;

  bool canCall() {
    _maybeReset();
    return _calls < maxCallsPerDay;
  }

  Future<void> recordCall() async {
    _maybeReset();
    await _box.put('budget_calls', _calls + 1);
  }

  void _maybeReset() {
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    if (_dateKey != today) {
      _box.put('budget_date', today);
      _box.put('budget_calls', 0);
    }
  }
}