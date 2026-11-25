import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Custom anatomical vector icon for every [CheckCategory] so each module
/// (especially Tongue, Nail, Skin/Mole, and Digestion/Stool) is immediately
/// recognizable at a glance for all ages, including elderly users.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
    this.color = Colors.white,
  });

  final CheckCategory category;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: category.title,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CategoryIconPainter(
            category: category,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CategoryIconPainter extends CustomPainter {
  const _CategoryIconPainter({
    required this.category,
    required this.color,
  });

  final CheckCategory category;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeW = (w * 0.085).clamp(1.6, 3.0);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thinStroke = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (strokeW * 0.72).clamp(1.2, 2.2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final softFill = Paint()
      ..color = color.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;

    switch (category) {
      case CheckCategory.eye:
        _paintEye(canvas, w, h, stroke, thinStroke, fill, softFill);
      case CheckCategory.nail:
        _paintNail(canvas, w, h, stroke, thinStroke, softFill);
      case CheckCategory.tongue:
        _paintTongue(canvas, w, h, stroke, thinStroke, softFill);
      case CheckCategory.face:
        _paintFace(canvas, w, h, stroke, thinStroke, fill, softFill);
      case CheckCategory.skinCondition:
        _paintSkinDermatoscope(canvas, w, h, stroke, thinStroke, fill, softFill);
      case CheckCategory.urine:
        _paintUrineDroplet(canvas, w, h, stroke, thinStroke, softFill);
      case CheckCategory.stool:
        _paintDigestiveGut(canvas, w, h, stroke, softFill);
    }
  }

  /// Anatomical eye with sclera almond contour, iris ring, pupil & specular glint.
  void _paintEye(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint fill,
    Paint softFill,
  ) {
    final eyePath = Path()
      ..moveTo(w * 0.08, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.14, w * 0.92, h * 0.52)
      ..quadraticBezierTo(w * 0.50, h * 0.90, w * 0.08, h * 0.52)
      ..close();
    canvas.drawPath(eyePath, softFill);
    canvas.drawPath(eyePath, stroke);

    // Iris circle
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.20, stroke);
    // Pupil
    canvas.drawCircle(Offset(w * 0.50, h * 0.52), w * 0.09, fill);

    // Subtle upper eyelashes for instant recognition
    canvas.drawLine(
      Offset(w * 0.50, h * 0.22),
      Offset(w * 0.50, h * 0.12),
      thinStroke,
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.27),
      Offset(w * 0.24, h * 0.18),
      thinStroke,
    );
    canvas.drawLine(
      Offset(w * 0.70, h * 0.27),
      Offset(w * 0.76, h * 0.18),
      thinStroke,
    );
  }

  /// Close-up fingertip with unmistakable nail plate and curved lunula half-moon.
  void _paintNail(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint softFill,
  ) {
    // Fingertip silhouette rising from bottom
    final finger = Path()
      ..moveTo(w * 0.19, h * 0.92)
      ..lineTo(w * 0.19, h * 0.42)
      ..cubicTo(
        w * 0.19,
        h * 0.12,
        w * 0.81,
        h * 0.12,
        w * 0.81,
        h * 0.42,
      )
      ..lineTo(w * 0.81, h * 0.92);
    canvas.drawPath(finger, stroke);

    // Distinct rounded nail plate
    final nailRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.30, h * 0.23, w * 0.70, h * 0.70),
      topLeft: Radius.circular(w * 0.17),
      topRight: Radius.circular(w * 0.17),
      bottomLeft: Radius.circular(w * 0.14),
      bottomRight: Radius.circular(w * 0.14),
    );
    canvas.drawRRect(nailRect, softFill);
    canvas.drawRRect(nailRect, stroke);

    // Signature lunula half-moon arc at base of nail
    final lunula = Path()
      ..moveTo(w * 0.35, h * 0.67)
      ..quadraticBezierTo(w * 0.50, h * 0.55, w * 0.65, h * 0.67);
    canvas.drawPath(lunula, thinStroke);

    // Subtle gloss streak along upper-left nail plate
    canvas.drawLine(
      Offset(w * 0.40, h * 0.33),
      Offset(w * 0.40, h * 0.47),
      thinStroke,
    );
  }

  /// Friendly open smiling mouth with unmistakable rounded tongue & median groove.
  void _paintTongue(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint softFill,
  ) {
    // Upper lip / open smile curve across the top
    final mouthTop = Path()
      ..moveTo(w * 0.10, h * 0.32)
      ..quadraticBezierTo(w * 0.50, h * 0.48, w * 0.90, h * 0.32);
    canvas.drawPath(mouthTop, stroke);

    // Subtle corner dimples
    canvas.drawLine(
      Offset(w * 0.10, h * 0.27),
      Offset(w * 0.10, h * 0.37),
      thinStroke,
    );
    canvas.drawLine(
      Offset(w * 0.90, h * 0.27),
      Offset(w * 0.90, h * 0.37),
      thinStroke,
    );

    // Prominent U-shaped tongue extending downward from the mouth
    final tongue = Path()
      ..moveTo(w * 0.24, h * 0.38)
      ..lineTo(w * 0.24, h * 0.62)
      ..cubicTo(
        w * 0.24,
        h * 0.92,
        w * 0.76,
        h * 0.92,
        w * 0.76,
        h * 0.62,
      )
      ..lineTo(w * 0.76, h * 0.38);
    canvas.drawPath(tongue, softFill);
    canvas.drawPath(tongue, stroke);

    // Iconic central median groove down the tongue
    canvas.drawLine(
      Offset(w * 0.50, h * 0.43),
      Offset(w * 0.50, h * 0.70),
      stroke,
    );
  }

  /// Serene human face contour with gentle hairline, eyes, and calm smile.
  void _paintFace(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint fill,
    Paint softFill,
  ) {
    final faceRect = Rect.fromLTRB(w * 0.17, h * 0.14, w * 0.83, h * 0.88);
    canvas.drawOval(faceRect, softFill);
    canvas.drawOval(faceRect, stroke);

    // Soft hairline curve across forehead
    final hair = Path()
      ..moveTo(w * 0.20, h * 0.37)
      ..quadraticBezierTo(w * 0.42, h * 0.34, w * 0.52, h * 0.20)
      ..quadraticBezierTo(w * 0.66, h * 0.31, w * 0.80, h * 0.37);
    canvas.drawPath(hair, thinStroke);

    // Two gentle eyes
    canvas.drawCircle(Offset(w * 0.39, h * 0.51), w * 0.042, fill);
    canvas.drawCircle(Offset(w * 0.61, h * 0.51), w * 0.042, fill);

    // Calm smile
    final smile = Path()
      ..moveTo(w * 0.39, h * 0.67)
      ..quadraticBezierTo(w * 0.50, h * 0.75, w * 0.61, h * 0.67);
    canvas.drawPath(smile, stroke);
  }

  /// Dermatoscope magnifying lens inspecting a mole/spot on skin.
  void _paintSkinDermatoscope(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint fill,
    Paint softFill,
  ) {
    final lensCenter = Offset(w * 0.44, h * 0.44);
    final lensR = w * 0.31;

    // Magnifying lens circle
    canvas.drawCircle(lensCenter, lensR, softFill);
    canvas.drawCircle(lensCenter, lensR, stroke);

    // Magnifying glass handle
    final handleStart = Offset(
      lensCenter.dx + lensR * math.cos(math.pi / 4),
      lensCenter.dy + lensR * math.sin(math.pi / 4),
    );
    canvas.drawLine(
      handleStart,
      Offset(w * 0.88, h * 0.88),
      stroke..strokeWidth = stroke.strokeWidth * 1.15,
    );

    // Mole / skin spot inside the lens + ABCDE border inspection arc
    canvas.drawCircle(lensCenter, w * 0.095, fill);
    canvas.drawArc(
      Rect.fromCircle(center: lensCenter, radius: w * 0.19),
      -math.pi * 0.85,
      math.pi * 0.65,
      false,
      thinStroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: lensCenter, radius: w * 0.19),
      math.pi * 0.15,
      math.pi * 0.65,
      false,
      thinStroke,
    );
  }

  /// Clinical hydration/urine droplet with liquid level wave and highlight.
  void _paintUrineDroplet(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint thinStroke,
    Paint softFill,
  ) {
    final drop = Path()
      ..moveTo(w * 0.50, h * 0.10)
      ..cubicTo(
        w * 0.76,
        h * 0.44,
        w * 0.82,
        h * 0.62,
        w * 0.82,
        h * 0.64,
      )
      ..arcToPoint(
        Offset(w * 0.18, h * 0.64),
        radius: Radius.circular(w * 0.32),
        clockwise: true,
      )
      ..cubicTo(
        w * 0.18,
        h * 0.62,
        w * 0.24,
        h * 0.44,
        w * 0.50,
        h * 0.10,
      )
      ..close();

    // Fill lower liquid portion inside clipped droplet
    canvas.save();
    canvas.clipPath(drop);
    canvas.drawRect(
      Rect.fromLTRB(0, h * 0.54, w, h),
      softFill,
    );
    final wave = Path()
      ..moveTo(w * 0.16, h * 0.56)
      ..quadraticBezierTo(w * 0.36, h * 0.50, w * 0.52, h * 0.56)
      ..quadraticBezierTo(w * 0.68, h * 0.62, w * 0.84, h * 0.55);
    canvas.drawPath(wave, thinStroke);
    canvas.restore();

    canvas.drawPath(drop, stroke);

    // Crisp gloss highlight on bottom-left curve
    final highlight = Path()
      ..moveTo(w * 0.33, h * 0.66)
      ..quadraticBezierTo(w * 0.35, h * 0.76, w * 0.44, h * 0.80);
    canvas.drawPath(highlight, thinStroke);
  }

  /// Hygienic, unmistakably clinical digestive/colon wave icon for Stool check.
  void _paintDigestiveGut(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint softFill,
  ) {
    // Clean continuous tubular S-loop representing intestinal/digestive tract
    final gutPath = Path()
      ..moveTo(w * 0.24, h * 0.26)
      ..lineTo(w * 0.68, h * 0.26)
      ..cubicTo(w * 0.86, h * 0.26, w * 0.86, h * 0.50, w * 0.68, h * 0.50)
      ..lineTo(w * 0.32, h * 0.50)
      ..cubicTo(w * 0.14, h * 0.50, w * 0.14, h * 0.74, w * 0.32, h * 0.74)
      ..lineTo(w * 0.62, h * 0.74)
      ..quadraticBezierTo(w * 0.74, h * 0.74, w * 0.74, h * 0.88);

    // Subtle soft tube backdrop
    final backdrop = Paint()
      ..color = color.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.19).clamp(3.6, 6.2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(gutPath, backdrop);
    canvas.drawPath(gutPath, stroke);
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.category != category || oldDelegate.color != color;
  }
}
