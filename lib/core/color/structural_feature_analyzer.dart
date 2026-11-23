import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// 0-token on-device 2D spatial & structural feature metrics extracted from
/// the target region of interest (ROI).
///
/// Complements average CIE L*a*b* / HSV color analysis by detecting localized
/// anatomical structures that barely alter the global average color:
/// - **Tongue:** dark linear fissures/grooves (yarık/çatlak dil), white/yellow
///   coating coverage ratio.
/// - **Eye:** localized red capillary blood vessels (kılcal kanlanma) on white
///   sclera, yellow sclera patches.
/// - **Nail:** bright white spots/bands (lökoniki / beyaz çizgiler), distal
///   splitting/cracks/surface ridges (kırık / soyulma / oluklanma), and narrow
///   dark vertical bands (melanoniki).
class StructuralFeatures {
  const StructuralFeatures({
    this.fissureGrooveRatio = 0.0,
    this.coatingPatchRatio = 0.0,
    this.scleraVesselRatio = 0.0,
    this.scleraYellowRatio = 0.0,
    this.whiteLineSpotRatio = 0.0,
    this.fractureEdgeRoughness = 0.0,
    this.darkVerticalBandScore = 0.0,
  });

  /// Fraction (0..1) of tongue ROI pixels forming dark narrow grooves/fissures.
  final double fissureGrooveRatio;

  /// Fraction (0..1) of tongue ROI covered by pale/whitish-yellow coating.
  final double coatingPatchRatio;

  /// Fraction (0..1) of eye ROI pixels showing fine red capillary vessels.
  final double scleraVesselRatio;

  /// Fraction (0..1) of eye ROI pixels showing localized yellow sclera tint.
  final double scleraYellowRatio;

  /// Fraction (0..1) of nail ROI pixels forming bright white spots/bands
  /// contrasting against the pink nail plate.
  final double whiteLineSpotRatio;

  /// Normalized (0..1) high-frequency edge roughness / fracture / ridge energy
  /// across the nail plate and free edge.
  final double fractureEdgeRoughness;

  /// Normalized (0..1) vertical dark-band contrast score on the nail plate
  /// (detects narrow dark longitudinal melanonychia streaks).
  final double darkVerticalBandScore;

  bool get hasTongueFissures => fissureGrooveRatio >= 0.032;
  bool get hasTongueCoatingPatch => coatingPatchRatio >= 0.24;
  bool get hasEyeRedVessels => scleraVesselRatio >= 0.025;
  bool get hasEyeYellowPatch => scleraYellowRatio >= 0.08;
  bool get hasNailWhiteLinesOrSpots => whiteLineSpotRatio >= 0.022;
  bool get hasNailCracksOrRoughness => fractureEdgeRoughness >= 0.24;
  bool get hasNailDarkVerticalBand => darkVerticalBandScore >= 0.22;

  String toCompactTelemetry(CheckCategory category) {
    switch (category) {
      case CheckCategory.tongue:
        return 'fissure=${(fissureGrooveRatio * 100).toStringAsFixed(1)}% '
            'coating=${(coatingPatchRatio * 100).toStringAsFixed(1)}%';
      case CheckCategory.eye:
        return 'vessels=${(scleraVesselRatio * 100).toStringAsFixed(1)}% '
            'yellow_patch=${(scleraYellowRatio * 100).toStringAsFixed(1)}%';
      case CheckCategory.nail:
        return 'white_lines=${(whiteLineSpotRatio * 100).toStringAsFixed(1)}% '
            'cracks_rough=${(fractureEdgeRoughness * 100).toStringAsFixed(1)}% '
            'dark_vband=${(darkVerticalBandScore * 100).toStringAsFixed(1)}%';
      default:
        return 'roughness=${(fractureEdgeRoughness * 100).toStringAsFixed(1)}%';
    }
  }
}

/// Pure-Dart, 0-token 2D computer vision analyzer for localized clinical
/// structures (fissures, capillary vessels, white nail lines, cracks, bands).
class StructuralFeatureAnalyzer {
  StructuralFeatureAnalyzer._();

  static const int _gridSize = 96;

  static StructuralFeatures analyze({
    required img.Image image,
    required CheckCategory category,
  }) {
    if (image.width < 12 || image.height < 12) {
      return const StructuralFeatures();
    }

    // Extract central 60% ROI where the target organ sits inside the camera guide.
    final cropW = (image.width * 0.60).round().clamp(12, image.width);
    final cropH = (image.height * 0.60).round().clamp(12, image.height);
    final startX = ((image.width - cropW) / 2).round();
    final startY = ((image.height - cropH) / 2).round();

    final cropped = img.copyCrop(
      image,
      x: startX,
      y: startY,
      width: cropW,
      height: cropH,
    );
    final roi = img.copyResize(
      cropped,
      width: _gridSize,
      height: _gridSize,
      interpolation: img.Interpolation.linear,
    );

    switch (category) {
      case CheckCategory.tongue:
        return _analyzeTongue(roi);
      case CheckCategory.eye:
        return _analyzeEye(roi);
      case CheckCategory.nail:
        return _analyzeNail(roi);
      default:
        return StructuralFeatures(
          fractureEdgeRoughness: _computeEdgeRoughness(roi),
        );
    }
  }

  static StructuralFeatures _analyzeTongue(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    final luma = List<double>.filled(w * h, 0);
    var coatingCount = 0;
    var validCount = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        luma[y * w + x] = l;

        // Ignore specular wet glare highlights
        if (l > 246) continue;
        validCount++;

        // Whitish/yellowish matte coating: high luminance, low redness excess
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        final redExcess = r - g;
        if (l >= 165 && sat <= 0.24 && redExcess < 22) {
          coatingCount++;
        }
      }
    }

    // Detect dark linear valleys (fissures/grooves):
    // A fissure pixel is significantly darker than its surrounding 7x7 ring
    // while sitting on a reasonably lit tongue surface (not in deep shadow).
    var fissurePixels = 0;
    var interiorPixels = 0;
    const radius = 3;

    for (var y = radius; y < h - radius; y++) {
      for (var x = radius; x < w - radius; x++) {
        final center = luma[y * w + x];
        if (center > 235) continue; // glare
        interiorPixels++;

        var ringSum = 0.0;
        var ringCount = 0;
        for (var dy = -radius; dy <= radius; dy += radius) {
          for (var dx = -radius; dx <= radius; dx += radius) {
            if (dx == 0 && dy == 0) continue;
            ringSum += luma[(y + dy) * w + (x + dx)];
            ringCount++;
          }
        }
        final localMean = ringSum / ringCount;

        // Sharp local dark groove (at least 22 luma units darker than neighbors)
        // AND elongated valley check (darker than perpendicular neighbors)
        if (localMean >= 75 && (localMean - center) >= 22.0) {
          final hDip =
              ((luma[y * w + (x - 2)] + luma[y * w + (x + 2)]) * 0.5) - center;
          final vDip =
              ((luma[(y - 2) * w + x] + luma[(y + 2) * w + x]) * 0.5) - center;
          if (hDip >= 18.0 || vDip >= 18.0) {
            fissurePixels++;
          }
        }
      }
    }

    return StructuralFeatures(
      fissureGrooveRatio:
          interiorPixels > 0 ? (fissurePixels / interiorPixels).clamp(0.0, 1.0) : 0.0,
      coatingPatchRatio:
          validCount > 0 ? (coatingCount / validCount).clamp(0.0, 1.0) : 0.0,
    );
  }

  static StructuralFeatures _analyzeEye(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    var scleraPixels = 0;
    var redVesselPixels = 0;
    var yellowPatchPixels = 0;

    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final p = roi.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;

        // Focus on sclera-like bright pixels (exclude dark pupil/iris/eyelashes)
        if (l < 85 || l > 250) continue;
        scleraPixels++;

        // Localized red capillary / bloodshot vessel pixel:
        // True crimson/red vessels have R >> G ≈ B (distinguishing them from
        // warm yellow lighting where G >> B).
        final redExcess = r - ((g + b) * 0.5);
        if (redExcess >= 36.0 && r >= 120 && (r - g) >= 34.0 && (g - b) <= 28.0) {
          redVesselPixels++;
        }

        // Localized yellow sclera patch (jaundice): R & G high, B noticeably low
        if (r >= 150 && g >= 135 && ((r + g) * 0.5 - b) >= 34.0 && (r - g).abs() <= 35.0) {
          yellowPatchPixels++;
        }
      }
    }

    if (scleraPixels < 40) {
      return const StructuralFeatures();
    }

    return StructuralFeatures(
      scleraVesselRatio: (redVesselPixels / scleraPixels).clamp(0.0, 1.0),
      scleraYellowRatio: (yellowPatchPixels / scleraPixels).clamp(0.0, 1.0),
    );
  }

  static StructuralFeatures _analyzeNail(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    final luma = List<double>.filled(w * h, 0);
    final satList = List<double>.filled(w * h, 0);
    final sortedLuma = <double>[];

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final s = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        luma[y * w + x] = l;
        satList[y * w + x] = s;
        if (l > 30 && l < 245) sortedLuma.add(l);
      }
    }

    if (sortedLuma.length < 40) {
      return const StructuralFeatures();
    }
    sortedLuma.sort();
    final medianL = sortedLuma[sortedLuma.length ~/ 2];

    // 1. White spots / transverse white bands (leukonychia / Muehrcke lines):
    //    Bright, low-saturation pixels significantly brighter than the nail
    //    plate median, excluding tiny 1px specular reflections.
    var whiteSpotPixels = 0;
    var platePixels = 0;
    for (var y = 2; y < h - 2; y++) {
      for (var x = 2; x < w - 2; x++) {
        final idx = y * w + x;
        final l = luma[idx];
        final s = satList[idx];
        if (l < 30) continue;
        platePixels++;

        final isWhiteContrast =
            l >= 198 && l < 252 && s <= 0.13 && (l - medianL) >= 24.0;
        if (isWhiteContrast) {
          // Confirm it's part of a spot/line (at least 2 bright neighbors)
          var brightNeighbors = 0;
          if (luma[idx - 1] >= 195) brightNeighbors++;
          if (luma[idx + 1] >= 195) brightNeighbors++;
          if (luma[idx - w] >= 195) brightNeighbors++;
          if (luma[idx + w] >= 195) brightNeighbors++;
          if (brightNeighbors >= 2) {
            whiteSpotPixels++;
          }
        }
      }
    }

    // 2. Dark longitudinal vertical band (melanonychia):
    //    Compute column-wise median luminance across the middle 60% height.
    //    A dark vertical streak causes a narrow contiguous band of columns to
    //    drop sharply below the plate median.
    final colMedians = <double>[];
    final yStart = (h * 0.20).round();
    final yEnd = (h * 0.80).round();
    for (var x = 4; x < w - 4; x++) {
      final colVals = <double>[];
      for (var y = yStart; y < yEnd; y++) {
        colVals.add(luma[y * w + x]);
      }
      colVals.sort();
      colMedians.add(colVals[colVals.length ~/ 2]);
    }

    var darkBandScore = 0.0;
    if (colMedians.length >= 10 && medianL >= 95) {
      final sortedCols = [...colMedians]..sort();
      final plateColMedian = sortedCols[sortedCols.length ~/ 2];
      var maxDip = 0.0;
      var dipWidth = 0;
      var curWidth = 0;
      for (final cm in colMedians) {
        final dip = plateColMedian - cm;
        if (dip >= 36.0 && cm < 95.0) {
          curWidth++;
          if (dip > maxDip) maxDip = dip;
          if (curWidth > dipWidth) dipWidth = curWidth;
        } else {
          curWidth = 0;
        }
      }
      // A true longitudinal band is narrow-to-medium (2..35% of nail width)
      if (dipWidth >= 2 && dipWidth <= (colMedians.length * 0.40)) {
        darkBandScore = ((maxDip - 30.0) / 90.0).clamp(0.0, 1.0);
      }
    }

    // 3. Surface cracks, peeling, splitting, Beau grooves (high-frequency edge energy)
    final roughness = _computeEdgeRoughness(roi);

    return StructuralFeatures(
      whiteLineSpotRatio:
          platePixels > 0 ? (whiteSpotPixels / platePixels).clamp(0.0, 1.0) : 0.0,
      fractureEdgeRoughness: roughness,
      darkVerticalBandScore: darkBandScore,
    );
  }

  /// Computes normalized high-frequency Sobel gradient energy (0..1) to detect
  /// nail cracks, peeling/splitting edges, deep transverse ridges, or rough
  /// surface texture.
  static double _computeEdgeRoughness(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    final luma = List<double>.filled(w * h, 0);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        luma[y * w + x] = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      }
    }

    var strongEdges = 0;
    var count = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final gx = -luma[(y - 1) * w + (x - 1)] +
            luma[(y - 1) * w + (x + 1)] -
            2 * luma[y * w + (x - 1)] +
            2 * luma[y * w + (x + 1)] -
            luma[(y + 1) * w + (x - 1)] +
            luma[(y + 1) * w + (x + 1)];
        final gy = -luma[(y - 1) * w + (x - 1)] -
            2 * luma[(y - 1) * w + x] -
            luma[(y - 1) * w + (x + 1)] +
            luma[(y + 1) * w + (x - 1)] +
            2 * luma[(y + 1) * w + x] +
            luma[(y + 1) * w + (x + 1)];
        final mag = math.sqrt(gx * gx + gy * gy);
        count++;
        if (mag >= 95.0) {
          strongEdges++;
        }
      }
    }

    return count > 0 ? (strongEdges / count).clamp(0.0, 1.0) : 0.0;
  }
}
