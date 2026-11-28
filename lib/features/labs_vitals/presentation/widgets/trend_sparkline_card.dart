import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';

class TrendChartPoint {
  const TrendChartPoint({
    required this.date,
    required this.value,
    this.secondaryValue,
  });

  final DateTime date;
  final double value;
  final double? secondaryValue;
}

/// Lightweight custom-painted trend line chart with optional shaded normal
/// reference band and optional second series (e.g. systolic & diastolic BP).
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.points,
    required this.primaryColor,
    this.secondaryColor,
    this.normalMin,
    this.normalMax,
    this.height = 136,
  });

  /// Chronologically sorted oldest -> newest.
  final List<TrendChartPoint> points;
  final Color primaryColor;
  final Color? secondaryColor;
  final double? normalMin;
  final double? normalMax;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            context.l10n.chartAddReadingHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final firstDate = DateFormat('dd.MM').format(points.first.date);
    final lastDate = DateFormat('dd.MM').format(points.last.date);

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendPainter(
              points: points,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              normalMin: normalMin,
              normalMax: normalMax,
              gridColor: colorScheme.outlineVariant.withValues(alpha: 0.45),
              labelColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              firstDate,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (points.length > 1)
              Text(
                lastDate,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.points,
    required this.primaryColor,
    required this.gridColor,
    required this.labelColor,
    this.secondaryColor,
    this.normalMin,
    this.normalMax,
  });

  final List<TrendChartPoint> points;
  final Color primaryColor;
  final Color? secondaryColor;
  final double? normalMin;
  final double? normalMax;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const padLeft = 6.0;
    const padRight = 6.0;
    const padTop = 10.0;
    const padBottom = 10.0;

    final chartW = math.max(1.0, size.width - padLeft - padRight);
    final chartH = math.max(1.0, size.height - padTop - padBottom);

    final allValues = <double>[
      for (final p in points) p.value,
      for (final p in points)
        if (p.secondaryValue != null) p.secondaryValue!,
      ?normalMin,
      ?normalMax,
    ];

    var minY = allValues.reduce(math.min);
    var maxY = allValues.reduce(math.max);
    if ((maxY - minY).abs() < 1.0) {
      minY -= 5;
      maxY += 5;
    } else {
      final margin = (maxY - minY) * 0.14;
      minY -= margin;
      maxY += margin;
    }

    double yFor(double v) {
      final ratio = (v - minY) / (maxY - minY);
      return padTop + chartH * (1 - ratio.clamp(0.0, 1.0));
    }

    double xFor(int index) {
      if (points.length == 1) return padLeft + chartW / 2;
      return padLeft + (chartW * index / (points.length - 1));
    }

    // Horizontal reference grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 0; i <= 2; i++) {
      final y = padTop + chartH * (i / 2);
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(padLeft + chartW, y),
        gridPaint,
      );
    }

    // Shaded normal reference band
    if (normalMin != null && normalMax != null) {
      final topY = yFor(normalMax!);
      final bottomY = yFor(normalMin!);
      final bandPaint = Paint()
        ..color = const Color(0xFF1B8A5A).withValues(alpha: 0.11);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(padLeft, topY, padLeft + chartW, bottomY),
          const Radius.circular(6),
        ),
        bandPaint,
      );
    }

    // Secondary series (e.g. diastolic BP)
    if (secondaryColor != null &&
        points.any((p) => p.secondaryValue != null)) {
      _drawSeries(
        canvas: canvas,
        color: secondaryColor!,
        coords: [
          for (int i = 0; i < points.length; i++)
            if (points[i].secondaryValue != null)
              Offset(xFor(i), yFor(points[i].secondaryValue!)),
        ],
      );
    }

    // Primary series
    _drawSeries(
      canvas: canvas,
      color: primaryColor,
      coords: [
        for (int i = 0; i < points.length; i++)
          Offset(xFor(i), yFor(points[i].value)),
      ],
    );
  }

  void _drawSeries({
    required Canvas canvas,
    required Color color,
    required List<Offset> coords,
  }) {
    if (coords.isEmpty) return;

    if (coords.length >= 2) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(coords.first.dx, coords.first.dy);
      for (int i = 1; i < coords.length; i++) {
        path.lineTo(coords[i].dx, coords[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    final fillPaint = Paint()..color = color;
    final haloPaint = Paint()..color = Colors.white;
    for (final c in coords) {
      canvas.drawCircle(c, 5.2, haloPaint);
      canvas.drawCircle(c, 3.8, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
