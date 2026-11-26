import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:visualcheckup/features/diet/domain/diet_models.dart';

/// Clean visual weight trend line chart with an optional horizontal dashed
/// target-weight line for diet progress tracking.
class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({
    super.key,
    required this.entries,
    this.targetWeightKg,
    this.accentColor = const Color(0xFF0F766E),
  });

  final List<DietWeightEntry> entries;
  final double? targetWeightKg;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chronological = List<DietWeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (chronological.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: CustomPaint(
        painter: _WeightTrendPainter(
          entries: chronological,
          targetWeightKg: targetWeightKg,
          accentColor: accentColor,
          labelColor: colorScheme.onSurfaceVariant,
          gridColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _WeightTrendPainter extends CustomPainter {
  _WeightTrendPainter({
    required this.entries,
    required this.targetWeightKg,
    required this.accentColor,
    required this.labelColor,
    required this.gridColor,
  });

  final List<DietWeightEntry> entries;
  final double? targetWeightKg;
  final Color accentColor;
  final Color labelColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 40.0;
    const rightPad = 14.0;
    const topPad = 12.0;
    const bottomPad = 24.0;

    final chartRect = Rect.fromLTWH(
      leftPad,
      topPad,
      math.max(10, size.width - leftPad - rightPad),
      math.max(10, size.height - topPad - bottomPad),
    );

    final weights = entries.map((e) => e.weightKg).toList();
    if (targetWeightKg != null) weights.add(targetWeightKg!);

    double minW = weights.reduce(math.min);
    double maxW = weights.reduce(math.max);
    if ((maxW - minW).abs() < 1.5) {
      minW -= 1.5;
      maxW += 1.5;
    } else {
      final pad = (maxW - minW) * 0.15;
      minW -= pad;
      maxW += pad;
    }

    double yFor(double w) {
      final ratio = (w - minW) / (maxW - minW);
      return chartRect.bottom - ratio * chartRect.height;
    }

    // Horizontal grid lines + Y-axis labels
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 2; i++) {
      final t = i / 2.0;
      final value = minW + (maxW - minW) * t;
      final y = yFor(value);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
      _drawText(
        canvas,
        value.toStringAsFixed(1),
        Offset(0, y - 7),
        TextStyle(fontSize: 10.5, color: labelColor, fontWeight: FontWeight.w600),
      );
    }

    // Target weight dashed line
    if (targetWeightKg != null) {
      final ty = yFor(targetWeightKg!);
      final targetPaint = Paint()
        ..color = const Color(0xFF16A34A)
        ..strokeWidth = 1.6;
      const dash = 6.0;
      const gap = 4.0;
      double x = chartRect.left;
      while (x < chartRect.right) {
        final endX = math.min(x + dash, chartRect.right);
        canvas.drawLine(Offset(x, ty), Offset(endX, ty), targetPaint);
        x += dash + gap;
      }
    }

    // Compute plotted points
    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = entries.length == 1
          ? chartRect.center.dx
          : chartRect.left + (i / (entries.length - 1)) * chartRect.width;
      points.add(Offset(x, yFor(entries[i].weightKg)));
    }

    // Fill area under curve
    if (points.length >= 2) {
      final fillPath = Path()..moveTo(points.first.dx, chartRect.bottom);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath
        ..lineTo(points.last.dx, chartRect.bottom)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.24),
            accentColor.withValues(alpha: 0.02),
          ],
        ).createShader(chartRect);
      canvas.drawPath(fillPath, fillPaint);

      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      final linePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots
    final dotFill = Paint()..color = accentColor;
    final dotStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotFill);
      canvas.drawCircle(p, 4.5, dotStroke);
    }

    // X-axis first & last date labels
    final dateFmt = DateFormat('dd.MM');
    _drawText(
      canvas,
      dateFmt.format(entries.first.date),
      Offset(chartRect.left, chartRect.bottom + 6),
      TextStyle(fontSize: 10.5, color: labelColor, fontWeight: FontWeight.w600),
    );
    if (entries.length > 1) {
      final lastLabel = dateFmt.format(entries.last.date);
      _drawText(
        canvas,
        lastLabel,
        Offset(chartRect.right - 34, chartRect.bottom + 6),
        TextStyle(
          fontSize: 10.5,
          color: labelColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WeightTrendPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.targetWeightKg != targetWeightKg ||
      oldDelegate.accentColor != accentColor;
}
