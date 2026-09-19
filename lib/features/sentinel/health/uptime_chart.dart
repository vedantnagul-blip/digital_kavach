import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UptimeChart extends StatelessWidget {
  const UptimeChart({super.key, required this.uptimePercentages});
  final List<double> uptimePercentages; // 7 days (0.0 - 1.0)

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _UptimeChartPainter(
          uptimeData: uptimePercentages.isEmpty
              ? [1.0, 1.0, 0.95, 1.0, 0.88, 1.0, 1.0]
              : uptimePercentages,
          barColor: AppColors.safe,
          gapColor: AppColors.danger,
        ),
      ),
    );
  }
}

class _UptimeChartPainter extends CustomPainter {
  _UptimeChartPainter({
    required this.uptimeData,
    required this.barColor,
    required this.gapColor,
  });

  final List<double> uptimeData;
  final Color barColor;
  final Color gapColor;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (uptimeData.length * 2);
    final maxBarHeight = size.height - 20;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < uptimeData.length; i++) {
      final val = uptimeData[i].clamp(0.0, 1.0);
      final left = (i * 2 + 0.5) * barWidth;
      final barHeight = maxBarHeight * val;
      final top = size.height - 20 - barHeight;

      paint.color = val > 0.90 ? barColor : gapColor;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}