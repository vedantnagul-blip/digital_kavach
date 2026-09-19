import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// 24-hour Golden Hour countdown with color transitions.
class CountdownHeader extends StatefulWidget {
  const CountdownHeader({
    super.key,
    required this.deadline,
    this.explainerText,
  });

  final DateTime deadline;
  final String? explainerText;

  @override
  State<CountdownHeader> createState() => _CountdownHeaderState();
}

class _CountdownHeaderState extends State<CountdownHeader> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _calcRemaining());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _calcRemaining() {
    final diff = widget.deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Color get _color {
    final hours = _remaining.inHours;
    if (hours < 2) return AppColors.danger;
    if (hours < 6) return AppColors.warning;
    return AppColors.safe;
  }

  String get _label {
    if (_remaining == Duration.zero) return 'EXPIRED';
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Countdown timer: ${_remaining.inHours} hours remaining',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l16,
          vertical: AppSpacing.m12,
        ),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              _label,
              style: theme.textTheme.displayLarge?.copyWith(
                color: _color,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              semanticsLabel: 'Time remaining: $_label',
            ),
            if (widget.explainerText != null) ...[
              const SizedBox(height: AppSpacing.xs4),
              Text(
                widget.explainerText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}