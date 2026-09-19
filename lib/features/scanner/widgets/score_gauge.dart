import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../data/rules/score_aggregator.dart';

class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    required this.score,
    required this.level,
    this.animate = true,
    super.key,
  });

  final int score;
  final VerdictLevel level;
  final bool animate;

  Color _colorFor(BuildContext ctx) {
    switch (level) {
      case VerdictLevel.green: return AppColors.safe;
      case VerdictLevel.amber: return AppColors.warning;
      case VerdictLevel.red:   return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color fg = _colorFor(context);
    final double frac = (score.clamp(0, 100)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: score.toDouble()),
              duration: animate
                  ? const Duration(milliseconds: 500)
                  : Duration.zero,
              builder: (BuildContext c, double v, _) => Text(
                v.round().toString(),
                style: t.textTheme.displaySmall
                    ?.copyWith(color: fg, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 4),
            Text('/100',
                style: t.textTheme.titleMedium
                    ?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadius.rPill,
          child: Container(
            height: 10,
            color: t.colorScheme.surfaceContainerHighest,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: frac),
              duration: animate
                  ? const Duration(milliseconds: 500)
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              builder: (BuildContext c, double v, _) => FractionallySizedBox(
                widthFactor: v.clamp(0.0, 1.0),
                child: Container(color: fg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}