import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// Minimal dependency-free shimmer skeleton (no `shimmer` package needed).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    required this.width,
    required this.height,
    this.radius = AppRadius.rM,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.radius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _c.value, -0.5),
              end: Alignment(1.0 + 2 * _c.value, 0.5),
              colors: <Color>[
                s.surfaceContainerHighest,
                s.surfaceContainerHighest.withOpacity(0.6),
                s.surfaceContainerHighest,
              ],
              stops: const <double>[0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built list skeleton — matches typical Activity Feed item shape.
class ShimmerListSkeleton extends StatelessWidget {
  const ShimmerListSkeleton({this.itemCount = 4, super.key});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int i) => Row(
        children: const <Widget>[
          ShimmerBox(width: 48, height: 48, radius: AppRadius.rM),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(width: 200, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 140, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}