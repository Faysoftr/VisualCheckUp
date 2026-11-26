import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Offline vector medical illustration widget rendering clinically recognizable
/// visual references (morphology, patterns, borders, vessels, grooves, bands)
/// for every [ReferenceFinding.id] across all 7 VisualCheckUp modules.
class ClinicalVisualIllustration extends StatelessWidget {
  const ClinicalVisualIllustration({
    super.key,
    required this.findingId,
    required this.category,
    required this.fallbackColor,
    this.size = 76,
    this.borderRadius = 16,
  });

  final String findingId;
  final CheckCategory category;
  final Color fallbackColor;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: CustomPaint(
          painter: _ClinicalIllustrationPainter(
            findingId: findingId,
            category: category,
            fallbackColor: fallbackColor,
          ),
        ),
      ),
    );
  }
}

class _ClinicalIllustrationPainter extends CustomPainter {
  const _ClinicalIllustrationPainter({
    required this.findingId,
    required this.category,
    required this.fallbackColor,
  });

  final String findingId;
  final CheckCategory category;
  final Color fallbackColor;

  @override
  void paint(Canvas canvas, Size size) {
    switch (category) {
      case CheckCategory.eye:
        _paintEye(canvas, size);
      case CheckCategory.nail:
        _paintNail(canvas, size);
      case CheckCategory.tongue:
        _paintTongue(canvas, size);
      case CheckCategory.skinCondition:
        _paintSkin(canvas, size);
      case CheckCategory.face:
        _paintFace(canvas, size);
      case CheckCategory.urine:
        _paintUrine(canvas, size);
      case CheckCategory.stool:
        _paintStool(canvas, size);
    }
  }

  // ---------------------------------------------------------------------------
  // EYE (Sclera, Conjunctiva, Vessels, Jaundice, Hemorrhage, Leukocoria)
  // ---------------------------------------------------------------------------
  void _paintEye(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Soft skin backdrop around eye
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF3DDD0),
    );

    if (findingId == 'eye_conjunctiva_pallor') {
      // Lower eyelid pulled down showing pale inner palpebral conjunctiva
      final eyePath = Path()
        ..moveTo(w * 0.08, cy * 0.82)
        ..quadraticBezierTo(cx, h * 0.16, w * 0.92, cy * 0.82)
        ..quadraticBezierTo(cx, h * 0.62, w * 0.08, cy * 0.82);
      canvas.drawPath(eyePath, Paint()..color = const Color(0xFFF6F7F5));
      canvas.drawCircle(
        Offset(cx, h * 0.44),
        w * 0.15,
        Paint()..color = const Color(0xFF5D4638),
      );
      canvas.drawCircle(
        Offset(cx, h * 0.44),
        w * 0.065,
        Paint()..color = const Color(0xFF1A1A1A),
      );

      // Pulled lower eyelid inner palpebral conjunctiva (pale pinkish-white)
      final conjPath = Path()
        ..moveTo(w * 0.12, h * 0.56)
        ..quadraticBezierTo(cx, h * 0.68, w * 0.88, h * 0.56)
        ..quadraticBezierTo(cx, h * 0.92, w * 0.12, h * 0.56);
      canvas.drawPath(conjPath, Paint()..color = const Color(0xFFF1D4D4));
      canvas.drawPath(
        conjPath,
        Paint()
          ..color = const Color(0xFFD9A3A3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // Downward arrow cue
      final arrowPaint = Paint()
        ..color = const Color(0xFF9C5454)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, h * 0.78), Offset(cx, h * 0.91), arrowPaint);
      canvas.drawLine(
        Offset(cx - 4, h * 0.86),
        Offset(cx, h * 0.91),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(cx + 4, h * 0.86),
        Offset(cx, h * 0.91),
        arrowPaint,
      );
      return;
    }

    // Standard almond sclera contour
    final eyePath = Path()
      ..moveTo(w * 0.06, cy)
      ..quadraticBezierTo(cx, h * 0.14, w * 0.94, cy)
      ..quadraticBezierTo(cx, h * 0.86, w * 0.06, cy)
      ..close();

    final scleraColor = switch (findingId) {
      'eye_jaundice_sclera' => const Color(0xFFEEDB72),
      'eye_mild_redness' => const Color(0xFFF7E7E7),
      _ => const Color(0xFFF5F6F4),
    };

    canvas.save();
    canvas.clipPath(eyePath);
    canvas.drawRect(Offset.zero & size, Paint()..color = scleraColor);

    if (findingId == 'eye_mild_redness') {
      // Branching red capillary vessels from corners toward iris
      final vesselPaint = Paint()
        ..color = const Color(0xFFD64545)
        ..strokeWidth = 1.35
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (final yOff in [-0.08, 0.02, 0.10]) {
        final pLeft = Path()
          ..moveTo(w * 0.08, cy + h * yOff)
          ..quadraticBezierTo(
            w * 0.22,
            cy + h * (yOff - 0.05),
            w * 0.34,
            cy + h * (yOff * 0.6),
          );
        final pRight = Path()
          ..moveTo(w * 0.92, cy + h * yOff)
          ..quadraticBezierTo(
            w * 0.78,
            cy + h * (yOff + 0.05),
            w * 0.66,
            cy + h * (yOff * 0.6),
          );
        canvas.drawPath(pLeft, vesselPaint);
        canvas.drawPath(pRight, vesselPaint);
      }
    } else if (findingId == 'eye_subconjunctival_hemorrhage') {
      // Sharp-bordered bright red blood patch on temporal sclera
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.74, cy + h * 0.03),
          width: w * 0.30,
          height: h * 0.28,
        ),
        Paint()..color = const Color(0xFFC8232C),
      );
    } else if (findingId == 'eye_localized_yellow_spot') {
      // Localized triangular yellowish pinguecula near limbus
      final ping = Path()
        ..moveTo(w * 0.66, cy - h * 0.08)
        ..quadraticBezierTo(w * 0.80, cy, w * 0.66, cy + h * 0.09)
        ..close();
      canvas.drawPath(ping, Paint()..color = const Color(0xFFE2CA6A));
    }

    // Iris + pupil
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.20,
      Paint()..color = const Color(0xFF5D4638),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.17,
      Paint()..color = const Color(0xFF7B5D4A),
    );

    final isLeukocoria = findingId == 'eye_pediatric_leukocoria';
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.085,
      Paint()
        ..color = isLeukocoria
            ? const Color(0xFFF2F0E2)
            : const Color(0xFF141414),
    );
    if (!isLeukocoria) {
      canvas.drawCircle(
        Offset(cx - w * 0.04, cy - h * 0.04),
        w * 0.025,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
    canvas.restore();

    // Eyelid outline
    canvas.drawPath(
      eyePath,
      Paint()
        ..color = const Color(0xFF6B4C3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  // ---------------------------------------------------------------------------
  // NAIL (Color, Bands, Grooves, Terry/Lindsay, Clubbing/Schamroth, Spoon)
  // ---------------------------------------------------------------------------
  void _paintNail(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF3F6F6),
    );

    // Side-profile illustrations for clubbing (Schamroth) and koilonychia (spoon)
    if (findingId == 'nail_clubbing_hippocratic') {
      // Side profile showing drumstick bulbous fingertip + domed watch-glass nail
      final finger = Path()
        ..moveTo(w * 0.08, h * 0.72)
        ..lineTo(w * 0.45, h * 0.72)
        ..quadraticBezierTo(w * 0.86, h * 0.76, w * 0.86, h * 0.50)
        ..quadraticBezierTo(w * 0.86, h * 0.24, w * 0.48, h * 0.34)
        ..lineTo(w * 0.08, h * 0.38)
        ..close();
      canvas.drawPath(finger, Paint()..color = const Color(0xFFE7BEA7));

      // Highly convex watch-glass domed nail (>180° Lovibond angle)
      final dome = Path()
        ..moveTo(w * 0.42, h * 0.35)
        ..quadraticBezierTo(w * 0.76, h * 0.14, w * 0.88, h * 0.48)
        ..quadraticBezierTo(w * 0.70, h * 0.38, w * 0.42, h * 0.40)
        ..close();
      canvas.drawPath(dome, Paint()..color = const Color(0xFFDF9E99));
      canvas.drawPath(
        dome,
        Paint()
          ..color = const Color(0xFFA05B57)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      return;
    }

    if (findingId == 'nail_spoon_koilonychia') {
      // Side profile showing concave spoon-shaped dipped nail plate
      final finger = Path()
        ..moveTo(w * 0.08, h * 0.72)
        ..lineTo(w * 0.78, h * 0.72)
        ..quadraticBezierTo(w * 0.90, h * 0.56, w * 0.80, h * 0.40)
        ..lineTo(w * 0.08, h * 0.40)
        ..close();
      canvas.drawPath(finger, Paint()..color = const Color(0xFFE7BEA7));
      final spoon = Path()
        ..moveTo(w * 0.36, h * 0.40)
        ..quadraticBezierTo(w * 0.62, h * 0.56, w * 0.86, h * 0.34);
      canvas.drawPath(
        spoon,
        Paint()
          ..color = const Color(0xFFC87F7A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
      // Tiny water drop indicator inside spoon dip
      canvas.drawCircle(
        Offset(w * 0.62, h * 0.40),
        w * 0.055,
        Paint()..color = const Color(0xFF56A8D8).withValues(alpha: 0.75),
      );
      return;
    }

    // Standard top-down finger + nail plate
    final fingerRect = RRect.fromLTRBAndCorners(
      w * 0.16,
      h * 0.08,
      w * 0.84,
      h * 1.02,
      topLeft: Radius.circular(w * 0.34),
      topRight: Radius.circular(w * 0.34),
    );
    canvas.drawRRect(fingerRect, Paint()..color = const Color(0xFFE6BCA4));

    if (findingId == 'nail_paronychia_inflamed') {
      // Bright red swollen periungual fold
      final foldRect = RRect.fromLTRBAndCorners(
        w * 0.17,
        h * 0.14,
        w * 0.83,
        h * 0.86,
        topLeft: Radius.circular(w * 0.28),
        topRight: Radius.circular(w * 0.28),
        bottomLeft: Radius.circular(w * 0.18),
        bottomRight: Radius.circular(w * 0.18),
      );
      canvas.drawRRect(
        foldRect,
        Paint()..color = const Color(0xFFD63B4B).withValues(alpha: 0.65),
      );
    }

    final plateRect = RRect.fromLTRBAndCorners(
      w * 0.25,
      h * 0.18,
      w * 0.75,
      h * 0.78,
      topLeft: Radius.circular(w * 0.18),
      topRight: Radius.circular(w * 0.18),
      bottomLeft: Radius.circular(w * 0.14),
      bottomRight: Radius.circular(w * 0.14),
    );

    final basePlateColor = switch (findingId) {
      'nail_pale_bed' => const Color(0xFFF0E4E2),
      'nail_terry_or_half_and_half' => const Color(0xFFF3EFEA),
      'nail_yellow_thickened' => const Color(0xFFD8BE67),
      'nail_green_pseudomonas' => const Color(0xFF8CA66B),
      'nail_cyanotic_blue' => const Color(0xFF7B85B8),
      _ => const Color(0xFFE8B0AC),
    };

    canvas.save();
    canvas.clipRRect(plateRect);
    canvas.drawRect(Offset.zero & size, Paint()..color = basePlateColor);

    // Free distal white nail edge (top)
    canvas.drawRect(
      Rect.fromLTRB(w * 0.24, h * 0.18, w * 0.76, h * 0.26),
      Paint()
        ..color = findingId == 'nail_yellow_thickened'
            ? const Color(0xFFC4A84E)
            : const Color(0xFFF7F4EE),
    );

    // Proximal lunula half-moon (bottom)
    if (findingId != 'nail_terry_or_half_and_half' &&
        findingId != 'nail_pale_bed') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.78),
          width: w * 0.34,
          height: h * 0.16,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }

    // Specific clinical nail signs
    switch (findingId) {
      case 'nail_terry_or_half_and_half':
        // Distal narrow pink-brown band below free edge
        canvas.drawRect(
          Rect.fromLTRB(w * 0.25, h * 0.25, w * 0.75, h * 0.36),
          Paint()..color = const Color(0xFFC87D7B),
        );
      case 'nail_white_spots_leukonychia':
        final spotPaint = Paint()..color = const Color(0xFFFAF9F7);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.34, h * 0.42, w * 0.32, h * 0.05),
            const Radius.circular(3),
          ),
          spotPaint,
        );
        canvas.drawCircle(Offset(w * 0.44, h * 0.58), w * 0.045, spotPaint);
        canvas.drawCircle(Offset(w * 0.60, h * 0.54), w * 0.032, spotPaint);
      case 'nail_pitting_or_ridges':
        // Transverse Beau's groove + pinhead pits
        final groovePaint = Paint()
          ..color = const Color(0xFF9E6B67)
          ..strokeWidth = 2.6;
        canvas.drawLine(
          Offset(w * 0.25, h * 0.48),
          Offset(w * 0.75, h * 0.48),
          groovePaint,
        );
        final pitPaint = Paint()..color = const Color(0xFFA97570);
        for (final pt in [
          Offset(w * 0.36, h * 0.35),
          Offset(w * 0.48, h * 0.38),
          Offset(w * 0.60, h * 0.34),
          Offset(w * 0.42, h * 0.60),
          Offset(w * 0.56, h * 0.62),
        ]) {
          canvas.drawCircle(pt, 2.0, pitPaint);
        }
      case 'nail_onycholysis':
        // Irregular white/yellowish separation creeping down from free edge
        final sep = Path()
          ..moveTo(w * 0.25, h * 0.18)
          ..lineTo(w * 0.75, h * 0.18)
          ..lineTo(w * 0.75, h * 0.44)
          ..quadraticBezierTo(w * 0.56, h * 0.56, w * 0.42, h * 0.40)
          ..quadraticBezierTo(w * 0.32, h * 0.48, w * 0.25, h * 0.38)
          ..close();
        canvas.drawPath(sep, Paint()..color = const Color(0xFFF2E6C8));
      case 'nail_brittle_splitting_vertical':
        final ridgePaint = Paint()
          ..color = const Color(0xFFB5807A)
          ..strokeWidth = 1.1;
        for (final x in [0.34, 0.44, 0.54, 0.64]) {
          canvas.drawLine(
            Offset(w * x, h * 0.24),
            Offset(w * x, h * 0.74),
            ridgePaint,
          );
        }
        // Distal jagged split
        canvas.drawLine(
          Offset(w * 0.50, h * 0.18),
          Offset(w * 0.53, h * 0.36),
          Paint()
            ..color = const Color(0xFF6B3E3A)
            ..strokeWidth = 1.8,
        );
      case 'nail_dark_vertical_band':
        // Longitudinal melanonychia dark band (>3mm) + Hutchinson cuticle cue
        canvas.drawRect(
          Rect.fromLTRB(w * 0.45, h * 0.18, w * 0.57, h * 0.78),
          Paint()..color = const Color(0xFF3A241E),
        );
        canvas.drawRect(
          Rect.fromLTRB(w * 0.49, h * 0.18, w * 0.54, h * 0.78),
          Paint()..color = const Color(0xFF1C100D),
        );
      case 'nail_splinter_hemorrhage':
        // Thin dark-red longitudinal splinter micro-lines
        final sp = Paint()
          ..color = const Color(0xFF8C1D24)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w * 0.38, h * 0.30), Offset(w * 0.38, h * 0.44), sp);
        canvas.drawLine(Offset(w * 0.52, h * 0.34), Offset(w * 0.52, h * 0.48), sp);
        canvas.drawLine(Offset(w * 0.62, h * 0.28), Offset(w * 0.62, h * 0.40), sp);
    }

    canvas.restore();

    // Hutchinson's sign dark pigment spilling onto cuticle for melanonychia
    if (findingId == 'nail_dark_vertical_band') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.51, h * 0.81),
          width: w * 0.16,
          height: h * 0.07,
        ),
        Paint()..color = const Color(0xFF3E2721).withValues(alpha: 0.78),
      );
    }

    canvas.drawRRect(
      plateRect,
      Paint()
        ..color = const Color(0xFF9C726B).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  // ---------------------------------------------------------------------------
  // TONGUE (Healthy, White/Yellow/Green/Black Coating, Geographic, Fissured, etc.)
  // ---------------------------------------------------------------------------
  void _paintTongue(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF3B2428),
    );

    final tonguePath = Path()
      ..moveTo(w * 0.20, h * 0.10)
      ..lineTo(w * 0.80, h * 0.10)
      ..quadraticBezierTo(w * 0.86, h * 0.64, w * 0.50, h * 0.90)
      ..quadraticBezierTo(w * 0.14, h * 0.64, w * 0.20, h * 0.10)
      ..close();

    final bodyColor = switch (findingId) {
      'tongue_pale_anemic' => const Color(0xFFE6C6CB),
      'tongue_strawberry_or_atrophic_red' => const Color(0xFFC93747),
      'tongue_cyanotic_purple_blue' => const Color(0xFF7B5B8C),
      'tongue_swelling_or_nonhealing_ulcer' => const Color(0xFFD06A78),
      _ => const Color(0xFFDC8590),
    };

    canvas.save();
    canvas.clipPath(tonguePath);
    canvas.drawRect(Offset.zero & size, Paint()..color = bodyColor);

    // Subtle median sulcus
    canvas.drawLine(
      Offset(w * 0.50, h * 0.14),
      Offset(w * 0.50, h * 0.76),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..strokeWidth = 1.4,
    );

    switch (findingId) {
      case 'tongue_thick_white_coating':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.44),
            width: w * 0.46,
            height: h * 0.54,
          ),
          Paint()..color = const Color(0xFFF3EFEA).withValues(alpha: 0.90),
        );
      case 'tongue_leukoplakia_plaque':
        // Thick non-wipeable lateral white plaque
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.28, h * 0.48),
            width: w * 0.18,
            height: h * 0.32,
          ),
          Paint()..color = const Color(0xFFF8F6F2),
        );
      case 'tongue_yellow_orange_coating':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.42),
            width: w * 0.44,
            height: h * 0.50,
          ),
          Paint()..color = const Color(0xFFDDB852).withValues(alpha: 0.88),
        );
      case 'tongue_greenish_coating':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.42),
            width: w * 0.44,
            height: h * 0.48,
          ),
          Paint()..color = const Color(0xFF9BB47B).withValues(alpha: 0.88),
        );
      case 'tongue_black_hairy':
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.40),
            width: w * 0.36,
            height: h * 0.44,
          ),
          Paint()..color = const Color(0xFF3E3028).withValues(alpha: 0.92),
        );
      case 'tongue_strawberry_or_atrophic_red':
        // Glossy specular sheen + red papilla dots
        final dotPaint = Paint()..color = const Color(0xFF961D2C);
        for (final pt in [
          Offset(w * 0.38, h * 0.32),
          Offset(w * 0.56, h * 0.30),
          Offset(w * 0.44, h * 0.48),
          Offset(w * 0.60, h * 0.46),
          Offset(w * 0.48, h * 0.64),
        ]) {
          canvas.drawCircle(pt, 2.0, dotPaint);
        }
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.40, h * 0.28),
            width: w * 0.16,
            height: h * 0.08,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.32),
        );
      case 'tongue_geographic_patches':
        // Map-like smooth red depapillated patches rimmed by crisp white borders
        final patch1 = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(w * 0.38, h * 0.42),
              width: w * 0.24,
              height: h * 0.22,
            ),
          );
        final patch2 = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(w * 0.60, h * 0.58),
              width: w * 0.22,
              height: h * 0.18,
            ),
          );
        final redFill = Paint()..color = const Color(0xFFC23E52);
        final whiteRim = Paint()
          ..color = const Color(0xFFF6F2EC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6;
        canvas.drawPath(patch1, redFill);
        canvas.drawPath(patch1, whiteRim);
        canvas.drawPath(patch2, redFill);
        canvas.drawPath(patch2, whiteRim);
      case 'tongue_fissured_grooves':
        // Deep central & branching fissures
        final groove = Paint()
          ..color = const Color(0xFF6B2834)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w * 0.50, h * 0.18), Offset(w * 0.50, h * 0.78), groove);
        canvas.drawLine(Offset(w * 0.50, h * 0.34), Offset(w * 0.30, h * 0.28), groove);
        canvas.drawLine(Offset(w * 0.50, h * 0.46), Offset(w * 0.70, h * 0.38), groove);
        canvas.drawLine(Offset(w * 0.50, h * 0.56), Offset(w * 0.32, h * 0.52), groove);
        canvas.drawLine(Offset(w * 0.50, h * 0.64), Offset(w * 0.66, h * 0.60), groove);
      case 'tongue_swelling_or_nonhealing_ulcer':
        // Lateral sore/ulcer crater + red halo
        canvas.drawCircle(
          Offset(w * 0.66, h * 0.52),
          w * 0.09,
          Paint()..color = const Color(0xFFA61F31),
        );
        canvas.drawCircle(
          Offset(w * 0.66, h * 0.52),
          w * 0.045,
          Paint()..color = const Color(0xFFF4EBD0),
        );
    }

    canvas.restore();
    canvas.drawPath(
      tonguePath,
      Paint()
        ..color = const Color(0xFF8C4652)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ---------------------------------------------------------------------------
  // SKIN & MOLES (ABCDE Melanoma, Ringworm, Psoriasis, Wart, Bruise, Diascopy)
  // ---------------------------------------------------------------------------
  void _paintSkin(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Healthy skin background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE7C2A8),
    );

    switch (findingId) {
      case 'skin_healthy_intact':
        // Subtle natural skin-pore texture
        final pore = Paint()..color = const Color(0xFFD6AE92);
        for (var y = 0.2; y < 0.85; y += 0.2) {
          for (var x = 0.2; x < 0.85; x += 0.2) {
            canvas.drawCircle(Offset(w * x, h * y), 1.0, pore);
          }
        }
      case 'skin_abcde_suspicious_mole':
        // Asymmetric, notched border, multi-color melanoma illustration
        final mole = Path()
          ..moveTo(w * 0.22, h * 0.44)
          ..quadraticBezierTo(w * 0.32, h * 0.18, w * 0.58, h * 0.24)
          ..quadraticBezierTo(w * 0.84, h * 0.30, w * 0.78, h * 0.56)
          ..quadraticBezierTo(w * 0.72, h * 0.82, w * 0.46, h * 0.76)
          ..quadraticBezierTo(w * 0.34, h * 0.68, w * 0.26, h * 0.64)
          ..quadraticBezierTo(w * 0.16, h * 0.56, w * 0.22, h * 0.44)
          ..close();
        canvas.drawPath(mole, Paint()..color = const Color(0xFF6B422C));
        canvas.save();
        canvas.clipPath(mole);
        // Dark brown / black eccentric core
        canvas.drawCircle(
          Offset(w * 0.58, h * 0.44),
          w * 0.22,
          Paint()..color = const Color(0xFF231613),
        );
        // Blue-gray veil + reddish flare
        canvas.drawCircle(
          Offset(w * 0.40, h * 0.58),
          w * 0.13,
          Paint()..color = const Color(0xFF566B7A).withValues(alpha: 0.75),
        );
        canvas.drawCircle(
          Offset(w * 0.66, h * 0.62),
          w * 0.09,
          Paint()..color = const Color(0xFFB5413B).withValues(alpha: 0.7),
        );
        canvas.restore();
        // Dashed asymmetry guide line
        final dash = Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..strokeWidth = 1.2;
        for (double y = h * 0.16; y < h * 0.84; y += 6) {
          canvas.drawLine(Offset(cx, y), Offset(cx, y + 3), dash);
        }
      case 'skin_ring_fungal_cue':
        // Annular ringworm: active raised red scaly ring with clear skin center
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.33,
          Paint()
            ..color = const Color(0xFFC94B43)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.09,
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.33,
          Paint()
            ..color = const Color(0xFFF3E4DA).withValues(alpha: 0.65)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      case 'skin_scaly_plaque_psoriasis_cue':
        // Well-demarcated red plaque topped with silvery-white flakes
        final plaque = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: w * 0.62, height: h * 0.50),
          Radius.circular(w * 0.16),
        );
        canvas.drawRRect(plaque, Paint()..color = const Color(0xFFD25B54));
        final scale = Paint()..color = const Color(0xFFF4F3F1).withValues(alpha: 0.86);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - w * 0.08, cy - h * 0.05), width: w * 0.28, height: h * 0.16),
          scale,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + w * 0.10, cy + h * 0.07), width: w * 0.24, height: h * 0.14),
          scale,
        );
      case 'skin_eczema_dermatitis_cue':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: w * 0.66, height: h * 0.54),
          Paint()..color = const Color(0xFFD8685E).withValues(alpha: 0.72),
        );
        final bump = Paint()..color = const Color(0xFFB5413A);
        for (final pt in [
          Offset(w * 0.36, h * 0.42),
          Offset(w * 0.52, h * 0.38),
          Offset(w * 0.60, h * 0.52),
          Offset(w * 0.44, h * 0.58),
        ]) {
          canvas.drawCircle(pt, 2.4, bump);
        }
      case 'skin_urticaria_hives_cue':
        // Raised wheals with pink halo and paler center
        for (final rect in [
          Rect.fromCenter(center: Offset(w * 0.42, h * 0.42), width: w * 0.36, height: h * 0.24),
          Rect.fromCenter(center: Offset(w * 0.62, h * 0.60), width: w * 0.32, height: h * 0.22),
        ]) {
          canvas.drawOval(rect.inflate(3), Paint()..color = const Color(0xFFE16A6C));
          canvas.drawOval(rect, Paint()..color = const Color(0xFFF3C6C1));
        }
      case 'skin_pustule_yellow_crust_cue':
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.28,
          Paint()..color = const Color(0xFFD3564A).withValues(alpha: 0.75),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.17,
          Paint()..color = const Color(0xFFE0B146),
        );
        canvas.drawCircle(
          Offset(cx - 2, cy - 2),
          w * 0.08,
          Paint()..color = const Color(0xFFF6E3A6),
        );
      case 'skin_spreading_cellulitis_warning':
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = const RadialGradient(
              colors: [Color(0xFFC42828), Color(0xFFE26658), Color(0xFFE7C2A8)],
              stops: [0.0, 0.58, 1.0],
            ).createShader(Offset.zero & size),
        );
      case 'skin_non_healing_cancer_cue':
        // Pearly rolled border nodule with central ulcerated crust
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.26,
          Paint()..color = const Color(0xFFF0D4CC),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.26,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0,
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.13,
          Paint()..color = const Color(0xFF9C302B),
        );
      case 'skin_wart_rough_dots_cue':
        // Hyperkeratotic wart dome with pinpoint black thrombosed capillaries
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.26,
          Paint()..color = const Color(0xFFCBB194),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.26,
          Paint()
            ..color = const Color(0xFF9B8269)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        final dot = Paint()..color = const Color(0xFF231C18);
        for (final pt in [
          Offset(cx - 6, cy - 4),
          Offset(cx + 5, cy - 5),
          Offset(cx, cy + 1),
          Offset(cx - 4, cy + 6),
          Offset(cx + 6, cy + 5),
        ]) {
          canvas.drawCircle(pt, 1.8, dot);
        }
      case 'skin_bruise_ecchymosis_cue':
        // Multi-stage ecchymosis gradient: purple center -> navy -> olive-yellow rim
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.34,
          Paint()..color = const Color(0xFFB5B257).withValues(alpha: 0.55),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.25,
          Paint()..color = const Color(0xFF544B86).withValues(alpha: 0.78),
        );
        canvas.drawCircle(
          Offset(cx - 2, cy - 2),
          w * 0.14,
          Paint()..color = const Color(0xFF7D2E55).withValues(alpha: 0.85),
        );
      case 'skin_facial_hyperpigmentation_cue':
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: w * 0.52, height: h * 0.38),
          Paint()..color = const Color(0xFFB37D52).withValues(alpha: 0.80),
        );
      case 'skin_non_blanching_petechiae':
        // Pinpoint purple-red petechiae remaining visible under clear glass ring
        final pDot = Paint()..color = const Color(0xFF8C1E35);
        for (final pt in [
          Offset(w * 0.34, h * 0.38),
          Offset(w * 0.46, h * 0.34),
          Offset(w * 0.56, h * 0.44),
          Offset(w * 0.42, h * 0.52),
          Offset(w * 0.58, h * 0.58),
          Offset(w * 0.38, h * 0.62),
        ]) {
          canvas.drawCircle(pt, 2.5, pDot);
        }
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.34,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      default:
        canvas.drawCircle(Offset(cx, cy), w * 0.25, Paint()..color = fallbackColor);
    }
  }

  // ---------------------------------------------------------------------------
  // FACE (Balanced, Pallor, Flushing, Jaundice, Perioral Cyanosis)
  // ---------------------------------------------------------------------------
  void _paintFace(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEFF4F4),
    );

    final skinColor = switch (findingId) {
      'face_pallor' => const Color(0xFFEDE2DA),
      'face_jaundice_tint' => const Color(0xFFE5CC6C),
      _ => const Color(0xFFE4B99B),
    };

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.62, height: h * 0.76),
      Paint()..color = skinColor,
    );

    if (findingId == 'face_flushing_erythema') {
      final blush = Paint()..color = const Color(0xFFDF5C56).withValues(alpha: 0.58);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.35, h * 0.52), width: w * 0.18, height: h * 0.14),
        blush,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.65, h * 0.52), width: w * 0.18, height: h * 0.14),
        blush,
      );
    }

    // Minimalist eyes
    final eyePaint = Paint()..color = const Color(0xFF4A3830);
    canvas.drawCircle(Offset(w * 0.39, h * 0.42), 2.3, eyePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.42), 2.3, eyePaint);

    // Lips (normal coral vs cyanotic purple-blue)
    final lipColor = findingId == 'face_perioral_cyanosis'
        ? const Color(0xFF716194)
        : (findingId == 'face_pallor'
            ? const Color(0xFFD6B0AD)
            : const Color(0xFFC96F70));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.68), width: w * 0.22, height: h * 0.08),
        const Radius.circular(6),
      ),
      Paint()..color = lipColor,
    );
  }

  // ---------------------------------------------------------------------------
  // URINE (Hydration droplet + foam / clarity cue)
  // ---------------------------------------------------------------------------
  void _paintUrine(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF6F9F9),
    );

    final drop = Path()
      ..moveTo(cx, h * 0.14)
      ..quadraticBezierTo(w * 0.80, h * 0.54, w * 0.74, h * 0.68)
      ..arcToPoint(
        Offset(w * 0.26, h * 0.68),
        radius: Radius.circular(w * 0.24),
      )
      ..quadraticBezierTo(w * 0.20, h * 0.54, cx, h * 0.14)
      ..close();

    canvas.drawPath(drop, Paint()..color = fallbackColor);

    if (findingId == 'urine_cloudy_foamy') {
      final foam = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(w * 0.42, h * 0.58), 4.5, foam);
      canvas.drawCircle(Offset(w * 0.52, h * 0.54), 5.5, foam);
      canvas.drawCircle(Offset(w * 0.60, h * 0.60), 4.0, foam);
    } else {
      // Liquid highlight reflection
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.40, h * 0.58),
          width: w * 0.08,
          height: h * 0.18,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }

    canvas.drawPath(
      drop,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  // ---------------------------------------------------------------------------
  // STOOL (Clinical color swatch disc with warning/healthy ring)
  // ---------------------------------------------------------------------------
  void _paintStool(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF5F4F2),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.32,
      Paint()..color = fallbackColor,
    );
    if (findingId == 'stool_bright_red_blood') {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.26),
        -math.pi * 0.2,
        math.pi * 0.8,
        false,
        Paint()
          ..color = const Color(0xFFD92D2D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.32,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _ClinicalIllustrationPainter oldDelegate) {
    return oldDelegate.findingId != findingId ||
        oldDelegate.category != category ||
        oldDelegate.fallbackColor != fallbackColor;
  }
}

/// Visual reference strip showing Fitzpatrick Skin Phototypes I–VI with
/// standard Individual Typology Angle (ITA°) thresholds.
class FitzpatrickScaleCard extends StatelessWidget {
  const FitzpatrickScaleCard({super.key});

  static const _tiers = [
    (type: 'I', label: 'Çok Açık', ita: '>55°', color: Color(0xFFF6DFCF)),
    (type: 'II', label: 'Açık', ita: '41–55°', color: Color(0xFFEDCBB1)),
    (type: 'III', label: 'Buğday', ita: '28–41°', color: Color(0xFFDCAD88)),
    (type: 'IV', label: 'Esmer', ita: '10–28°', color: Color(0xFFC18B60)),
    (type: 'V', label: 'Koyu', ita: '-30–10°', color: Color(0xFF8C5A3C)),
    (type: 'VI', label: 'Çok Koyu', ita: '<-30°', color: Color(0xFF4F3122)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.fitzpatrickScaleTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.fitzpatrickScaleSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final t in _tiers)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: t.color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.14),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: t.type == 'V' || t.type == 'VI'
                                    ? Colors.white
                                    : const Color(0xFF2D241E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.ita,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
