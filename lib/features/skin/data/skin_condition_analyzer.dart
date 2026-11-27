import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Visual cues extracted on-device by comparing the central lesion ROI against
/// the surrounding reference skin ring.
class SkinVisualMetrics {
  const SkinVisualMetrics({
    required this.centerColor,
    required this.centerHue,
    required this.centerSaturation,
    required this.centerValue,
    required this.erythemaDelta,
    required this.darknessDelta,
    required this.colorVariegation,
    required this.asymmetryScore,
    required this.scalingIndex,
    required this.yellowCrustRatio,
    this.bluePurpleRatio = 0.0,
    this.yellowGreenBruiseRatio = 0.0,
    this.roughTextureIndex = 0.0,
    this.blackDotRatio = 0.0,
    this.borderIrregularityIndex = 1.0,
    this.shapeAsymmetryScore = 0.0,
    this.dermoscopicColors = const [],
    this.surroundingSkinIta = 35.0,
    this.skinPhototype = FitzpatrickPhototype.intermediate,
    this.annularClearingIndex = 0.0,
    this.erythemaIndexDelta = 0.0,
    this.hairRemovedRatio = 0.0,
  });

  final Color centerColor;
  final double centerHue;
  final double centerSaturation;
  final double centerValue;

  /// Positive when central ROI is noticeably redder than surrounding skin.
  final double erythemaDelta;

  /// Positive when central ROI is darker than surrounding skin (0..1 scale).
  final double darknessDelta;

  /// Standard deviation / spread of luminance + saturation inside the ROI.
  final double colorVariegation;

  /// Difference between left/right and top/bottom halves of the central ROI.
  final double asymmetryScore;

  /// Ratio of pale/silvery flecks + texture variance inside the ROI.
  final double scalingIndex;

  /// Ratio of warm yellow-amber crust-like pixels inside the ROI.
  final double yellowCrustRatio;

  /// Ratio of blue-purple / plum pixels (fresh to mid-stage bruise ecchymosis).
  final double bluePurpleRatio;

  /// Ratio of olive-green / yellow-green pixels (healing-stage bruise).
  final double yellowGreenBruiseRatio;

  /// Mean neighbor luminance contrast inside ROI (rough hyperkeratotic wart surface).
  final double roughTextureIndex;

  /// Ratio of tiny dark pinpoint dots inside ROI (thrombosed wart capillaries).
  final double blackDotRatio;

  /// ABCD — Border Irregularity compactness index `P^2 / (4 * pi * A)`.
  /// Smooth round mole ≈ 1.0..1.35; jagged/notched border ≥ 1.80.
  final double borderIrregularityIndex;

  /// ABCD — Binary lesion-mask folding XOR asymmetry across centroid axes (0..1).
  final double shapeAsymmetryScore;

  /// ABCD — Distinct clinical dermoscopic colors detected inside the lesion
  /// mask from the 6-color standard palette (Light Brown, Dark Brown, Black,
  /// Red, White, Blue-Gray).
  final List<String> dermoscopicColors;

  /// Individual Typology Angle (ITA°) of the surrounding healthy skin ring.
  final double surroundingSkinIta;

  /// Objective Fitzpatrick skin phototype (I–VI) computed from surrounding skin.
  final FitzpatrickPhototype skinPhototype;

  /// Positive when outer lesion edge is markedly redder than inner core
  /// (central-clearing annular ringworm / tinea cue).
  final double annularClearingIndex;

  /// Collings log-ratio Erythema Index delta (lesion EI - surrounding skin EI).
  final double erythemaIndexDelta;

  /// Fraction (0..1) of ROI hair-strand pixels cleaned by DullRazor before
  /// lesion segmentation.
  final double hairRemovedRatio;

  bool get hasIrregularBorder => borderIrregularityIndex >= 1.80;
  bool get hasMultiDermoscopicColor =>
      dermoscopicColors.length >= 3 ||
      dermoscopicColors.contains('Mavi-Gri');
  bool get hasAnnularClearingRing => annularClearingIndex >= 0.06;
}

/// On-device dermatological pre-awareness analyzer.
///
/// Compares the central lesion region (35%..65%) with the surrounding border
/// ring (10%..25% & 75%..90%), applies optional Von Kries / Shades-of-Gray
/// color constancy, runs DullRazor hair removal and Otsu CIEDE2000 lesion
/// segmentation for quantitative ABCD (Asymmetry, Border compactness, 6-Color
/// dermoscopic palette), estimates Fitzpatrick ITA° phototype, and detects
/// annular ring clearing. This is NOT a medical diagnostic tool.
class SkinConditionAnalyzer implements HealthAnalyzer {
  const SkinConditionAnalyzer({
    this.skinContext = const SkinCheckContext(),
  });

  final SkinCheckContext skinContext;

  @override
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
    AnalysisOptions options = const AnalysisOptions(),
  }) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Görüntü çözümlenemedi.');
    }

    final calibratedSample = ColorCalibrator.sampleImage(
      image: decoded,
      useWhiteReference: options.useWhiteReference,
      category: CheckCategory.skinCondition,
    );

    final metrics = extractMetrics(decoded, gains: calibratedSample.gains);
    var result = analyzeMetrics(metrics);

    final extraObservations = <String>[];
    var confidence = result.confidence;

    if (calibratedSample.whiteBalanceApplied) {
      confidence = (confidence + 0.08).clamp(0.25, 0.92);
      extraObservations.add(
        'Beyaz referans kutusu ile cihaz ve ortam ışığı dengelendi.',
      );
    } else if (calibratedSample.autoColorConstancyApplied) {
      extraObservations.add(
        'Ortam ışığı Shades-of-Gray otomatik renk sabitliği ile dengelendi.',
      );
    } else if (calibratedSample.lightingCast == LightingCast.warmYellow ||
        calibratedSample.lightingCast == LightingCast.coolBlue) {
      confidence = (confidence - 0.10).clamp(0.25, 0.90);
      if (calibratedSample.lightingNote != null) {
        extraObservations.add(calibratedSample.lightingNote!);
      }
    }

    if (metrics.hairRemovedRatio >= 0.015) {
      extraObservations.add(
        'DullRazor kıl/tüy filtresi uygulanarak lezyon sınırları arındırıldı.',
      );
    }

    double? baselineDeltaE;
    String? baselineNote;
    var riskLevel = result.riskLevel;

    if (options.baseline != null) {
      final comp =
          options.baseline!.compare(LabColor.fromColor(metrics.centerColor));
      baselineDeltaE = comp.deltaE;
      baselineNote = comp.note;
      extraObservations.add(comp.note);
      if (riskLevel == RiskLevel.normal && comp.isSignificantShift) {
        riskLevel = RiskLevel.attention;
      }
    }

    result = result.copyWith(
      riskLevel: riskLevel,
      confidence: confidence,
      whiteBalanceCalibrated: calibratedSample.whiteBalanceApplied,
      lightingNote: calibratedSample.lightingNote,
      baselineDeltaE: baselineDeltaE,
      baselineComparisonNote: baselineNote,
      observations: [...result.observations, ...extraObservations],
    );

    return result;
  }

  SkinVisualMetrics extractMetrics(
    img.Image decoded, {
    WhiteBalanceGains? gains,
  }) {
    final w = decoded.width;
    final h = decoded.height;

    final cStartX = (w * 0.35).round().clamp(0, w - 1);
    final cEndX = (w * 0.65).round().clamp(cStartX + 1, w);
    final cStartY = (h * 0.35).round().clamp(0, h - 1);
    final cEndY = (h * 0.65).round().clamp(cStartY + 1, h);

    final stepX = math.max(1, ((cEndX - cStartX) / 32).round());
    final stepY = math.max(1, ((cEndY - cStartY) / 32).round());
    final midX = (cStartX + cEndX) ~/ 2;
    final midY = (cStartY + cEndY) ~/ 2;

    double sumR = 0, sumG = 0, sumB = 0;
    double sumV = 0, sumV2 = 0, sumS = 0, sumS2 = 0;
    double leftV = 0, rightV = 0, topV = 0, bottomV = 0;
    int leftN = 0, rightN = 0, topN = 0, bottomN = 0;
    int paleFleckCount = 0;
    int yellowCrustCount = 0;
    int bluePurpleCount = 0;
    int yellowGreenBruiseCount = 0;
    int darkDotCount = 0;
    double roughGradSum = 0;
    int roughGradN = 0;
    int centerCount = 0;

    final gridValues = <List<double>>[];

    for (int y = cStartY; y < cEndY; y += stepY) {
      final rowValues = <double>[];
      for (int x = cStartX; x < cEndX; x += stepX) {
        final p = decoded.getPixel(x, y);
        var ri = p.r.round().clamp(0, 255);
        var gi = p.g.round().clamp(0, 255);
        var bi = p.b.round().clamp(0, 255);
        // Skip pure specular glare spots on shiny skin
        if (ri >= 250 && gi >= 250 && bi >= 250) continue;
        if (gains != null) {
          final (nr, ng, nb) = gains.applyToRgb(ri, gi, bi);
          ri = nr;
          gi = ng;
          bi = nb;
        }
        final r = ri.toDouble();
        final g = gi.toDouble();
        final b = bi.toDouble();
        sumR += r;
        sumG += g;
        sumB += b;

        final hsv = HSVColor.fromColor(Color.fromARGB(255, ri, gi, bi));
        final v = hsv.value;
        final s = hsv.saturation;
        final hue = hsv.hue;

        rowValues.add(v);
        sumV += v;
        sumV2 += v * v;
        sumS += s;
        sumS2 += s * s;

        if (x < midX) {
          leftV += v;
          leftN++;
        } else {
          rightV += v;
          rightN++;
        }
        if (y < midY) {
          topV += v;
          topN++;
        } else {
          bottomV += v;
          bottomN++;
        }

        if (s < 0.14 && v > 0.78) {
          paleFleckCount++;
        }
        if (hue >= 34 && hue <= 62 && s >= 0.42 && v >= 0.40) {
          yellowCrustCount++;
        }
        // Bruise blue-violet / plum / deep purple range
        if (((hue >= 200 && hue <= 335 && s >= 0.16 && v <= 0.78) ||
            (bi > gi + 14 && ri >= gi && v <= 0.68))) {
          bluePurpleCount++;
        }
        // Healing bruise olive-green / yellow-green range
        if (hue >= 48 && hue <= 155 && s >= 0.18 && v >= 0.25 && v <= 0.85) {
          yellowGreenBruiseCount++;
        }
        // Tiny dark pinpoint capillary dots (common in plantar/common warts)
        if (v < 0.22) {
          darkDotCount++;
        }

        centerCount++;
      }
      if (rowValues.isNotEmpty) {
        gridValues.add(rowValues);
      }
    }

    // Compute local texture roughness from adjacent sampled grid cells.
    for (int gy = 0; gy < gridValues.length; gy++) {
      final row = gridValues[gy];
      for (int gx = 0; gx < row.length; gx++) {
        if (gx + 1 < row.length) {
          roughGradSum += (row[gx] - row[gx + 1]).abs();
          roughGradN++;
        }
        if (gy + 1 < gridValues.length && gx < gridValues[gy + 1].length) {
          roughGradSum += (row[gx] - gridValues[gy + 1][gx]).abs();
          roughGradN++;
        }
      }
    }

    final safeCenter = math.max(1, centerCount);
    final avgR = sumR / safeCenter;
    final avgG = sumG / safeCenter;
    final avgB = sumB / safeCenter;
    final centerColor = Color.fromARGB(
      255,
      avgR.round().clamp(0, 255),
      avgG.round().clamp(0, 255),
      avgB.round().clamp(0, 255),
    );
    final centerHsv = HSVColor.fromColor(centerColor);

    final meanV = sumV / safeCenter;
    final varV = math.max(0.0, (sumV2 / safeCenter) - meanV * meanV);
    final meanS = sumS / safeCenter;
    final varS = math.max(0.0, (sumS2 / safeCenter) - meanS * meanS);
    final colorVariegation = math.sqrt(varV) + math.sqrt(varS);

    final lrDiff =
        ((leftV / math.max(1, leftN)) - (rightV / math.max(1, rightN))).abs();
    final tbDiff =
        ((topV / math.max(1, topN)) - (bottomV / math.max(1, bottomN))).abs();
    final asymmetryScore = math.max(lrDiff, tbDiff);

    // Sample surrounding skin ring (outer margin 10%..25% & 75%..90%)
    final ringStepX = math.max(1, (w / 40).round());
    final ringStepY = math.max(1, (h / 40).round());
    double ringR = 0, ringG = 0, ringB = 0, ringV = 0;
    int ringCount = 0;

    for (int y = (h * 0.10).round(); y < (h * 0.90).round(); y += ringStepY) {
      for (int x = (w * 0.10).round(); x < (w * 0.90).round(); x += ringStepX) {
        final inInner = x >= (w * 0.25) &&
            x <= (w * 0.75) &&
            y >= (h * 0.25) &&
            y <= (h * 0.75);
        if (inInner) continue;
        if (gains != null && y >= (h * 0.72)) continue;
        final p = decoded.getPixel(x, y);
        var ri = p.r.round().clamp(0, 255);
        var gi = p.g.round().clamp(0, 255);
        var bi = p.b.round().clamp(0, 255);
        if (gains != null) {
          final (nr, ng, nb) = gains.applyToRgb(ri, gi, bi);
          ri = nr;
          gi = ng;
          bi = nb;
        }
        final r = ri.toDouble();
        final g = gi.toDouble();
        final b = bi.toDouble();
        ringR += r;
        ringG += g;
        ringB += b;
        ringV += math.max(r, math.max(g, b)) / 255.0;
        ringCount++;
      }
    }

    final safeRing = math.max(1, ringCount);
    final avgRingR = ringR / safeRing;
    final avgRingG = ringG / safeRing;
    final avgRingB = ringB / safeRing;
    final avgRingV = ringV / safeRing;

    final ringLab = LabColor.fromRgb(
      avgRingR.round().clamp(0, 255),
      avgRingG.round().clamp(0, 255),
      avgRingB.round().clamp(0, 255),
    );
    final surroundingSkinIta = ringLab.individualTypologyAngle;
    final skinPhototype = ringLab.fitzpatrickPhototype;

    final centerRedness = (avgR - avgG) / 255.0;
    final ringRedness = (avgRingR - avgRingG) / 255.0;
    final erythemaDelta = centerRedness - ringRedness;
    final darknessDelta = avgRingV - meanV;
    final erythemaIndexDelta = ColorCalibrator.erythemaIndex(
          avgR.round().clamp(0, 255),
          avgG.round().clamp(0, 255),
        ) -
        ColorCalibrator.erythemaIndex(
          avgRingR.round().clamp(0, 255),
          avgRingG.round().clamp(0, 255),
        );

    final scalingIndex = (paleFleckCount / safeCenter) + math.sqrt(varV) * 0.75;
    final yellowCrustRatio = yellowCrustCount / safeCenter;
    final bluePurpleRatio = bluePurpleCount / safeCenter;
    final yellowGreenBruiseRatio = yellowGreenBruiseCount / safeCenter;
    final roughTextureIndex =
        roughGradN > 0 ? roughGradSum / roughGradN : 0.0;
    // Pinpoint black dots only count when overall surface isn't uniformly pitch-black.
    final blackDotRatio = meanV > 0.30 ? (darkDotCount / safeCenter) : 0.0;

    // Quantitative ABCD lesion segmentation on a compact 64x64 central crop
    // (20%..80%) using CIE ΔE distance from surrounding healthy skin [ringLab].
    final abcd = _extractQuantitativeAbcdAndRing(
      decoded: decoded,
      ringLab: ringLab,
      gains: gains,
    );

    return SkinVisualMetrics(
      centerColor: centerColor,
      centerHue: centerHsv.hue,
      centerSaturation: centerHsv.saturation,
      centerValue: centerHsv.value,
      erythemaDelta: erythemaDelta,
      darknessDelta: darknessDelta,
      colorVariegation: colorVariegation,
      asymmetryScore: asymmetryScore,
      scalingIndex: scalingIndex,
      yellowCrustRatio: yellowCrustRatio,
      bluePurpleRatio: bluePurpleRatio,
      yellowGreenBruiseRatio: yellowGreenBruiseRatio,
      roughTextureIndex: roughTextureIndex,
      blackDotRatio: blackDotRatio,
      borderIrregularityIndex: abcd.borderIrregularityIndex,
      shapeAsymmetryScore: abcd.shapeAsymmetryScore,
      dermoscopicColors: abcd.dermoscopicColors,
      surroundingSkinIta: surroundingSkinIta,
      skinPhototype: skinPhototype,
      annularClearingIndex: abcd.annularClearingIndex,
      erythemaIndexDelta: erythemaIndexDelta,
      hairRemovedRatio: abcd.hairRemovedRatio,
    );
  }

  /// Lee et al. DullRazor / SharpRazor morphological hair-artifact removal.
  ///
  /// Detects thin dark linear hair strands (strong local luminance dip with
  /// brighter skin on BOTH sides across horizontal, vertical, or diagonal axes)
  /// and inpaints them from surrounding non-hair neighbors — while strictly
  /// preserving solid dark moles/lesions whose neighbors are also dark.
  static ({img.Image cleaned, double hairRatio}) removeHairDullRazor(
    img.Image roi,
  ) {
    final w = roi.width;
    final h = roi.height;
    if (w < 9 || h < 9) return (cleaned: roi, hairRatio: 0.0);

    final luma = List<double>.filled(w * h, 0.0);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        luma[y * w + x] = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      }
    }

    final hairMask = List<bool>.filled(w * h, false);
    var hairPixels = 0;

    // Check 4 orientations (0°, 90°, 45°, 135°) at half-width offset r=2..3.
    const dirs = [
      (2, 0),
      (0, 2),
      (2, 2),
      (2, -2),
    ];

    for (var y = 3; y < h - 3; y++) {
      for (var x = 3; x < w - 3; x++) {
        final c = luma[y * w + x];
        if (c > 150.0) continue; // hair strands are noticeably darker than skin
        var isThinDarkStrand = false;
        for (final (dx, dy) in dirs) {
          final l1 = luma[(y - dy) * w + (x - dx)];
          final l2 = luma[(y + dy) * w + (x + dx)];
          // Require BOTH opposite sides to be markedly brighter than center
          // (thin linear strand, NOT a solid dark mole interior or edge!).
          if ((l1 - c) >= 24.0 && (l2 - c) >= 24.0) {
            // Also verify longitudinal continuity along the orthogonal axis
            // so isolated pinpoint wart capillary dots are NOT mistaken for hair.
            final ox = -dy ~/ 2;
            final oy = dx ~/ 2;
            final along1 = luma[(y + oy) * w + (x + ox)];
            final along2 = luma[(y - oy) * w + (x - ox)];
            if ((along1 - c).abs() <= 28.0 || (along2 - c).abs() <= 28.0) {
              isThinDarkStrand = true;
              break;
            }
          }
        }
        if (isThinDarkStrand) {
          hairMask[y * w + x] = true;
          hairPixels++;
        }
      }
    }

    if (hairPixels == 0) {
      return (cleaned: roi, hairRatio: 0.0);
    }

    final out = roi.clone();
    for (var y = 2; y < h - 2; y++) {
      for (var x = 2; x < w - 2; x++) {
        if (!hairMask[y * w + x]) continue;
        double sr = 0, sg = 0, sb = 0;
        var cnt = 0;
        for (var dy = -2; dy <= 2; dy++) {
          for (var dx = -2; dx <= 2; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (hairMask[ny * w + nx]) continue;
            final np = roi.getPixel(nx, ny);
            sr += np.r;
            sg += np.g;
            sb += np.b;
            cnt++;
          }
        }
        if (cnt > 0) {
          out.setPixelRgb(
            x,
            y,
            (sr / cnt).round().clamp(0, 255),
            (sg / cnt).round().clamp(0, 255),
            (sb / cnt).round().clamp(0, 255),
          );
        }
      }
    }

    return (
      cleaned: out,
      hairRatio: (hairPixels / (w * h)).clamp(0.0, 1.0),
    );
  }

  /// Computes Otsu's optimal between-class variance threshold on a scalar map
  /// quantized into [bins] over `[0, maxVal]`.
  static double _computeOtsuThreshold(
    List<double> values, {
    double maxVal = 50.0,
    int bins = 50,
  }) {
    if (values.isEmpty) return 13.0;
    final hist = List<int>.filled(bins, 0);
    for (final v in values) {
      final b = ((v / maxVal) * (bins - 1)).round().clamp(0, bins - 1);
      hist[b]++;
    }
    final total = values.length;
    double sumAll = 0;
    for (var i = 0; i < bins; i++) {
      sumAll += i * hist[i];
    }

    double sumB = 0;
    var wB = 0;
    var bestVar = -1.0;
    var bestBin = 13;

    for (var i = 0; i < bins; i++) {
      wB += hist[i];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;
      sumB += i * hist[i];
      final mB = sumB / wB;
      final mF = (sumAll - sumB) / wF;
      final betweenVar = wB.toDouble() * wF.toDouble() * (mB - mF) * (mB - mF);
      if (betweenVar > bestVar) {
        bestVar = betweenVar;
        bestBin = i;
      }
    }
    return (bestBin / (bins - 1)) * maxVal;
  }

  /// Retains the single largest 4-connected foreground component that overlaps
  /// the central target area, eliminating isolated background speckles.
  static List<bool> _retainLargestCentralComponent(List<bool> rawMask, int n) {
    final visited = List<bool>.filled(n * n, false);
    List<int> bestComponent = const [];
    final queue = <int>[];

    for (var idx = 0; idx < n * n; idx++) {
      if (!rawMask[idx] || visited[idx]) continue;
      final comp = <int>[];
      var touchesCenter = false;
      queue.clear();
      queue.add(idx);
      visited[idx] = true;

      var head = 0;
      while (head < queue.length) {
        final cur = queue[head++];
        comp.add(cur);
        final cx = cur % n;
        final cy = cur ~/ n;
        if (cx >= n * 0.25 &&
            cx <= n * 0.75 &&
            cy >= n * 0.25 &&
            cy <= n * 0.75) {
          touchesCenter = true;
        }
        if (cx > 0 && rawMask[cur - 1] && !visited[cur - 1]) {
          visited[cur - 1] = true;
          queue.add(cur - 1);
        }
        if (cx < n - 1 && rawMask[cur + 1] && !visited[cur + 1]) {
          visited[cur + 1] = true;
          queue.add(cur + 1);
        }
        if (cy > 0 && rawMask[cur - n] && !visited[cur - n]) {
          visited[cur - n] = true;
          queue.add(cur - n);
        }
        if (cy < n - 1 && rawMask[cur + n] && !visited[cur + n]) {
          visited[cur + n] = true;
          queue.add(cur + n);
        }
      }

      if (touchesCenter && comp.length > bestComponent.length) {
        bestComponent = comp;
      }
    }

    final clean = List<bool>.filled(n * n, false);
    for (final idx in bestComponent) {
      clean[idx] = true;
    }
    return clean;
  }

  /// Segments the central lesion against surrounding healthy skin [ringLab] via
  /// DullRazor hair removal + Otsu CIEDE2000 ΔE00 thresholding + largest
  /// central connected component to compute:
  /// - Border Irregularity compactness `P^2 / (4 * pi * A)`
  /// - Folding shape asymmetry across centroid axes
  /// - 6-color dermoscopic palette presence
  /// - Annular ring clearing index (outer ring redness - inner core redness)
  ({
    double borderIrregularityIndex,
    double shapeAsymmetryScore,
    List<String> dermoscopicColors,
    double annularClearingIndex,
    double hairRemovedRatio,
  }) _extractQuantitativeAbcdAndRing({
    required img.Image decoded,
    required LabColor ringLab,
    WhiteBalanceGains? gains,
  }) {
    if (decoded.width < 20 || decoded.height < 20) {
      return (
        borderIrregularityIndex: 1.0,
        shapeAsymmetryScore: 0.0,
        dermoscopicColors: const [],
        annularClearingIndex: 0.0,
        hairRemovedRatio: 0.0,
      );
    }

    const n = 64;
    final cropX = (decoded.width * 0.20).round();
    final cropY = (decoded.height * 0.20).round();
    final cropW = (decoded.width * 0.60).round().clamp(12, decoded.width - cropX);
    final cropH = (decoded.height * 0.60).round().clamp(12, decoded.height - cropY);
    var roi = img.copyResize(
      img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH),
      width: n,
      height: n,
      interpolation: img.Interpolation.linear,
    );
    if (gains != null) {
      roi = ColorCalibrator.applyGainsToImage(roi, gains);
    }

    // 1. DullRazor morphological hair removal prior to lesion segmentation
    final hairResult = removeHairDullRazor(roi);
    roi = hairResult.cleaned;

    // 2. Per-pixel CIEDE2000 ΔE00 distance map from healthy surrounding skin
    final dEMap = List<double>.filled(n * n, 0.0);
    final rgbCache = List<(int, int, int)>.filled(n * n, (0, 0, 0));
    final labCache = List<LabColor>.filled(
      n * n,
      const LabColor(l: 0, a: 0, b: 0),
    );

    // Annular ringworm check: inner core (r < 0.18*n) vs outer ring (0.24..0.40*n)
    double coreRedSum = 0, edgeRedSum = 0;
    int coreN = 0, edgeN = 0;
    const centerF = (n - 1) / 2.0;

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final idx = y * n + x;
        rgbCache[idx] = (ri, gi, bi);

        final redness = (ri - gi) / 255.0;
        final dist = math.sqrt(
          (x - centerF) * (x - centerF) + (y - centerF) * (y - centerF),
        );
        if (dist <= n * 0.18) {
          coreRedSum += redness;
          coreN++;
        } else if (dist >= n * 0.24 && dist <= n * 0.40) {
          edgeRedSum += redness;
          edgeN++;
        }

        final lab = LabColor.fromRgb(ri, gi, bi);
        labCache[idx] = lab;
        dEMap[idx] = lab.deltaE2000(ringLab);
      }
    }

    final annularClearingIndex = (coreN > 0 && edgeN > 0)
        ? ((edgeRedSum / edgeN) - (coreRedSum / coreN))
        : 0.0;

    // 3. Otsu adaptive threshold bounded safely to prevent noise masks on clear skin
    final otsuT = _computeOtsuThreshold(dEMap).clamp(10.5, 20.0);
    final rawMask = List<bool>.filled(n * n, false);
    for (var i = 0; i < n * n; i++) {
      if (dEMap[i] >= otsuT) {
        rawMask[i] = true;
      }
    }

    // 4. Keep only the dominant central connected lesion component
    final mask = _retainLargestCentralComponent(rawMask, n);

    var lesionArea = 0;
    double sumX = 0, sumY = 0;

    // 6-color dermoscopic counters inside segmented lesion
    int cLightBrown = 0;
    int cDarkBrown = 0;
    int cBlack = 0;
    int cRed = 0;
    int cWhite = 0;
    int cBlueGray = 0;

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final idx = y * n + x;
        if (!mask[idx]) continue;
        lesionArea++;
        sumX += x;
        sumY += y;

        final (ri, gi, bi) = rgbCache[idx];
        final lab = labCache[idx];
        final hsv = HSVColor.fromColor(Color.fromARGB(255, ri, gi, bi));
        final h = hsv.hue;
        final s = hsv.saturation;
        final v = hsv.value;

        if (v < 0.20) {
          cBlack++;
        } else if (s < 0.14 && v > 0.78) {
          cWhite++;
        } else if ((h >= 185 && h <= 265 && s >= 0.12 && v <= 0.65) ||
            (lab.b <= -4.0 && lab.l <= 62.0)) {
          cBlueGray++;
        } else if (((h <= 14 || h >= 342) && s >= 0.35 && v >= 0.30) ||
            (lab.a >= 24.0 && lab.b < 24.0)) {
          cRed++;
        } else if (h >= 12 && h <= 46 && v < 0.42) {
          cDarkBrown++;
        } else if (h >= 14 && h <= 52 && v >= 0.42 && s >= 0.22) {
          cLightBrown++;
        }
      }
    }

    if (lesionArea < 36) {
      return (
        borderIrregularityIndex: 1.0,
        shapeAsymmetryScore: 0.0,
        dermoscopicColors: const [],
        annularClearingIndex: annularClearingIndex,
        hairRemovedRatio: hairResult.hairRatio,
      );
    }

    // Perimeter count (4-connected boundary pixels)
    var perimeter = 0;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (!mask[y * n + x]) continue;
        final isEdge = x == 0 ||
            y == 0 ||
            x == n - 1 ||
            y == n - 1 ||
            !mask[y * n + (x - 1)] ||
            !mask[y * n + (x + 1)] ||
            !mask[(y - 1) * n + x] ||
            !mask[(y + 1) * n + x];
        if (isEdge) perimeter++;
      }
    }

    // Isoperimetric compactness P^2 / (4 * pi * A), scaled by pi/4 grid correction
    final rawCompactness =
        (perimeter * perimeter) / (4.0 * math.pi * lesionArea);
    final borderIrregularityIndex = (rawCompactness * 0.785).clamp(1.0, 6.0);

    // Folding XOR shape asymmetry across lesion centroid (horizontal + vertical)
    final cx = (sumX / lesionArea).round();
    final cy = (sumY / lesionArea).round();
    var hMismatch = 0;
    var vMismatch = 0;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final cur = mask[y * n + x];
        final mx = (2 * cx - x);
        final my = (2 * cy - y);
        final hMirror = (mx >= 0 && mx < n) ? mask[y * n + mx] : false;
        final vMirror = (my >= 0 && my < n) ? mask[my * n + x] : false;
        if (cur != hMirror) hMismatch++;
        if (cur != vMirror) vMismatch++;
      }
    }
    final shapeAsymmetryScore = (math.max(hMismatch, vMismatch) /
            (2.0 * lesionArea))
        .clamp(0.0, 1.0);

    final minColorPixels = math.max(4, (lesionArea * 0.04).round());
    final colors = <String>[
      if (cLightBrown >= minColorPixels) 'Açık Kahve',
      if (cDarkBrown >= minColorPixels) 'Koyu Kahve',
      if (cBlack >= minColorPixels) 'Siyah',
      if (cRed >= minColorPixels) 'Kırmızı',
      if (cWhite >= minColorPixels) 'Beyaz',
      if (cBlueGray >= minColorPixels) 'Mavi-Gri',
    ];

    return (
      borderIrregularityIndex: borderIrregularityIndex,
      shapeAsymmetryScore: shapeAsymmetryScore,
      dermoscopicColors: colors,
      annularClearingIndex: annularClearingIndex,
      hairRemovedRatio: hairResult.hairRatio,
    );
  }

  AnalysisResult analyzeMetrics(SkinVisualMetrics m) {
    final now = DateTime.now();
    final id = '${CheckCategory.skinCondition.id}_${now.microsecondsSinceEpoch}';
    final areaPrefix = skinContext.bodyArea != null
        ? 'Seçilen bölge: ${skinContext.bodyArea}. '
        : '';

    final allowsDarkTarget =
        skinContext.concernType == SkinConcernType.molePigment ||
            skinContext.concernType == SkinConcernType.skinCancerRisk ||
            skinContext.concernType == SkinConcernType.bruise;

    // Guard for underexposed image unless user checks a dark mole/bruise
    if (m.centerValue < 0.12 && m.darknessDelta < 0.15 && !allowsDarkTarget) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Ortam Işığı Cilt Analizi İçin Yetersiz',
        summaryDetail:
            'Görüntü çok karanlık olduğu için cilt tonu ve lezyon sınırları güvenilir okunamadı.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: const [
          'Örneklenen cilt bölgesinde parlaklık çok düşük.',
        ],
        recommendations: const [
          'Doğal gün ışığı alan aydınlık bir ortamda, gölge düşmeden tekrar çekin.',
          'Lezyona 10–15 cm mesafeden odaklanarak net bir görüntü alın.',
        ],
        warningFlags: const [],
        confidence: 0.25,
        createdAt: now,
      );
    }

    // Fitzpatrick ITA° phototype fairness: on darker skin tones (Types IV–VI),
    // constitutive melanin naturally lowers centerValue; rely on relative
    // darknessDelta contrast against surrounding skin to avoid false flags.
    final isDarkPigmented = m.skinPhototype.isDarkerSkinOfColor
        ? m.darknessDelta >= 0.22
        : (m.darknessDelta >= 0.22 ||
            (m.centerValue < 0.34 && m.darknessDelta >= 0.12));
    final effectiveAsymmetry = math.max(m.asymmetryScore, m.shapeAsymmetryScore);
    final isVariegatedOrAsymmetric = m.colorVariegation >= 0.28 ||
        effectiveAsymmetry >= 0.14 ||
        m.hasIrregularBorder ||
        m.hasMultiDermoscopicColor;
    final isStrongRedness = m.erythemaDelta >= 0.08 ||
        m.erythemaIndexDelta >= 7.5 ||
        ((m.centerHue <= 16 || m.centerHue >= 342) && m.centerSaturation >= 0.46);
    final hasYellowCrust = m.yellowCrustRatio >= 0.18;
    final hasScaling = m.scalingIndex >= 0.26;
    final hasAnnularRing = m.hasAnnularClearingRing &&
        (m.erythemaDelta >= 0.03 ||
            isStrongRedness ||
            hasScaling ||
            skinContext.concernType == SkinConcernType.scalyDry ||
            skinContext.concernType == SkinConcernType.rashRedness);

    final skinMetrics = _buildSkinMetrics(m);

    AnalysisResult attachMetrics(AnalysisResult r) =>
        r.copyWith(clinicalMetrics: skinMetrics);

    // Dedicated sub-module routing for the 4 focused dermatological screens.
    switch (skinContext.concernType) {
      case SkinConcernType.skinCancerRisk:
        return attachMetrics(
          _analyzeSkinCancerRisk(
            id: id,
            now: now,
            areaPrefix: areaPrefix,
            m: m,
            isDarkPigmented: isDarkPigmented,
            isVariegatedOrAsymmetric: isVariegatedOrAsymmetric,
          ),
        );
      case SkinConcernType.bruise:
        return attachMetrics(
          _analyzeBruise(
            id: id,
            now: now,
            areaPrefix: areaPrefix,
            m: m,
          ),
        );
      case SkinConcernType.wart:
        return attachMetrics(
          _analyzeWart(
            id: id,
            now: now,
            areaPrefix: areaPrefix,
            m: m,
          ),
        );
      case SkinConcernType.facialSpot:
        return attachMetrics(
          _analyzeFacialSpot(
            id: id,
            now: now,
            areaPrefix: areaPrefix,
            m: m,
            isDarkPigmented: isDarkPigmented,
            isVariegatedOrAsymmetric: isVariegatedOrAsymmetric,
            isStrongRedness: isStrongRedness,
          ),
        );
      case SkinConcernType.rashRedness:
      case SkinConcernType.molePigment:
      case SkinConcernType.scalyDry:
      case SkinConcernType.blisterPustule:
      case SkinConcernType.general:
        break;
    }

    // 1. Urgent ABCDE pigment / mole red flag
    if ((isDarkPigmented &&
            (isVariegatedOrAsymmetric || skinContext.hasAbcdeRedFlag)) ||
        (skinContext.concernType == SkinConcernType.molePigment &&
            skinContext.hasAbcdeRedFlag)) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.urgent,
          summaryTitle: 'Ben / Koyu Leke — Dermatolog Değerlendirmesi Önerilir',
          summaryDetail:
              '${areaPrefix}Koyu pigmentli alanda renk heterojenliği, asimetri, kenar düzensizliği veya hızlı değişim belirtisi saptandı. Dermoskopik muayene önemlidir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            if (isDarkPigmented)
              'Merkez lezyon çevresindeki cilt tonuna göre belirgin derecede koyu ölçüldü.',
            if (m.colorVariegation >= 0.28 || m.hasMultiDermoscopicColor)
              'Lezyon içinde birden fazla dermoskopik renk tonu (${m.dermoscopicColors.isEmpty ? 'çoklu ton' : m.dermoscopicColors.join(', ')}) gözlendi (ABCDE — C).',
            if (effectiveAsymmetry >= 0.14)
              'Örneklenen alanda belirgin simetri farkı (ABCDE — A: %${(effectiveAsymmetry * 100).toStringAsFixed(0)}) tespit edildi.',
            if (m.hasIrregularBorder)
              'Lezyon sınırında girintili/düzensiz kenar yapısı (ABCDE — B: ${m.borderIrregularityIndex.toStringAsFixed(2)}) saptandı.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'En kısa sürede bir dermatoloji (cildiye) uzmanına dermoskopik kontrol için başvurun.',
            'Lezyonu kaşımayın, koparmayın veya üzerine rastgele krem/asit uygulamayın.',
            'Kontrole giderken varsa önceki fotoğraflarınızı da yanınızda bulundurun.',
          ],
          warningFlags: const [
            'Hızlı büyüme, kenar düzensizliği, renk koyulaşması, kanama veya kabuklanma varsa gecikmeden cildiye uzmanına başvurun.',
          ],
          confidence: 0.70,
          createdAt: now,
          matchedFindingIds: const ['skin_abcde_suspicious_mole'],
        ),
      );
    }

    // 2. Urgent infection / severe inflammatory red flag
    if (skinContext.hasInfectionRedFlag &&
        (isStrongRedness ||
            hasYellowCrust ||
            skinContext.concernType == SkinConcernType.blisterPustule)) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.urgent,
          summaryTitle: 'Enfeksiyon / Şiddetli İnflamasyon Uyarısı',
          summaryDetail:
              '${areaPrefix}Kızarıklık veya kabuklanma bulgularına ağrı, ısı artışı, akıntı, yayılma veya ateş gibi uyarı belirtileri eşlik ediyor.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            if (isStrongRedness)
              'Çevre cilde kıyasla belirgin kızarıklık (eritem) artışı saptandı.',
            if (hasYellowCrust)
              'Yüzeyde sarımsı kabuklanma/akıntı ile uyumlu tonlar gözlendi.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Gecikmeden bir hekime veya dermatoloji uzmanına başvurun.',
            'Bölgeyi temiz ve kuru tutun; kabarcık veya sivilceleri kesinlikle sıkmayın.',
            'Kızarıklığın sınırını takip ederek büyüyüp büyümediğini gözlemleyin.',
          ],
          warningFlags: const [
            'Ateş, titreme, hızla genişleyen kızarıklık veya şiddetli ağrı varsa acil tıbbi değerlendirme gerekir.',
          ],
          confidence: 0.72,
          createdAt: now,
          matchedFindingIds: const ['skin_spreading_cellulitis_warning'],
        ),
      );
    }

    // 3. Yellowish crust / pustular cue -> attention
    if (hasYellowCrust ||
        (skinContext.concernType == SkinConcernType.blisterPustule &&
            isStrongRedness)) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Kabarcık / Sarımsı Kabuklanma İpucu',
          summaryDetail:
              '${areaPrefix}Cilt yüzeyinde kızarıklıkla birlikte sarımsı/kabuklu tonlar veya püstüler görünüm ipucu saptandı. Folikülit, akne veya yüzeysel cilt enfeksiyonu açısından değerlendirilebilir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            if (hasYellowCrust)
              'Merkez bölgede sarı-kehribar kabuklanma/iltihap benzeri renk oranı yüksek.',
            if (isStrongRedness)
              'Bölgede kızarıklık ve hassasiyet tonu mevcut.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Bölgeyi sıkmaktan veya kabuğu kaldırmaktan kaçının.',
            'Havlularınızı ve temas eden eşyaları ortak kullanmayın.',
            'Şikayet artıyorsa veya birkaç günde gerilemiyorsa doktora danışın.',
          ],
          warningFlags: const [
            'Sıcaklık artışı, zonklayıcı ağrı, ateş veya hızla yayılma gelişirse acil değerlendirme alın.',
          ],
          confidence: 0.65,
          createdAt: now,
          matchedFindingIds: const ['skin_pustule_yellow_crust_cue'],
        ),
      );
    }

    // 3.5. Annular central-clearing ring cue (tinea / fungal ringworm)
    if (hasAnnularRing) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Halka Şeklinde Kenarı Kızarık Lezyon (Yüzeysel Mantar İpucu)',
          summaryDetail:
              '${areaPrefix}Lezyonun kenar halkası orta kısmına kıyasla daha kızarık ve belirgin ölçüldü (halka deseni). Bu görünüm yüzeysel cilt mantarı (tinea) veya halka şeklinde dermatit açısından dermatoloji değerlendirmesi gerektirir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            'Kenar halkada orta merkeze kıyasla belirgin kızarıklık farkı (merkezi açılma / anüler desen) saptandı.',
            if (hasScaling) 'Kenar boyunca kuruluk / pullanma kontrastı eşlik ediyor.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Dermatolog muayenesi olmadan kesinlikle kortizonlu krem sürmeyin — kortizon mantar enfeksiyonunu gizleyip yayabilir (tinea incognito).',
            'Bölgeyi kuru tutun; havlu ve kıyafetleri ortak kullanmayın.',
            'Doğru antifungal veya dermatolojik tedavi için cildiye uzmanına başvurun.',
          ],
          warningFlags: const [],
          confidence: 0.66,
          createdAt: now,
          matchedFindingIds: const ['skin_ring_fungal_cue'],
        ),
      );
    }

    // 4. Scaly / dry plaque cue (eczema, psoriasis, superficial fungal awareness)
    if (hasScaling ||
        (skinContext.concernType == SkinConcernType.scalyDry &&
            (isStrongRedness || m.colorVariegation >= 0.16))) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Pullu / Kuru Plak Görünümü İpucu',
          summaryDetail:
              '${areaPrefix}Cilt yüzeyinde kuruluk, açık renkli pullanma veya doku düzensizliği gözlendi. Egzama, seboreik dermatit, sedef veya yüzeysel mantar gibi durumlar açısından dermatolog değerlendirmesi faydalı olabilir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            'Merkez alanda parlak/pullu doku kontrastı normal pürüzsüz cildin üzerinde ölçüldü.',
            if (isStrongRedness)
              'Pullanmaya eşlik eden kızarıklık (eritem) tonu mevcut.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Doktor değerlendirmesi olmadan kortizonlu veya mantar karşıtı krem kullanmayın; bu kremler klinik görünümü maskeleyebilir.',
            'Parfümsüz, nazik bir temizleyici ve bariyer onarıcı nemlendirici ile cildi tahrişten koruyun.',
            'Plaklar yayılıyor, kaşıntı yaşam kalitenizi etkiliyorsa dermatoloğa başvurun.',
          ],
          warningFlags: const [],
          confidence: 0.64,
          createdAt: now,
          matchedFindingIds: const ['skin_scaly_plaque_psoriasis_cue'],
        ),
      );
    }

    // 5. Localized erythema / rash (dermatitis, allergy, urticaria, irritation)
    if (isStrongRedness ||
        skinContext.concernType == SkinConcernType.rashRedness) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Bölgesel Kızarıklık / Döküntü İpucu',
          summaryDetail:
              '$areaPrefixÖrneklenen cilt bölgesinde çevresine kıyasla kızarıklık/pembe ton artışı gözlendi. Kontakt dermatit, alerjik döküntü, egzama veya mekanik/güneş tahrişi kaynaklı olabilir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            if (m.erythemaDelta >= 0.08)
              'Merkez bölge çevre sağlıklı cilde göre daha kırmızı ölçüldü.',
            if (m.erythemaDelta < 0.08)
              'Kırmızı/pembe renk spektrumu ağırlıklı ton gözlendi.',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Yeni kullanılan kozmetik, deterjan, ilaç veya gıda temasını gözden geçirin.',
            'Şeffaf bardak (diaskopi) testiyle kızarıklığın bastırınca solup solmadığını gözlemleyin; solmayan morumsu noktacıklarda acil tıbbi destek alın.',
            'Döküntü 48–72 saat içinde gerilemez veya yayılırsa cildiye uzmanına danışın.',
          ],
          warningFlags: const [
            'Dudak/göz kapağı şişmesi, nefes darlığı, ateş veya bastırmakla solmayan (cam testi pozitif) mor noktacıklar varsa acil servise başvurun.',
          ],
          confidence: 0.66,
          createdAt: now,
          matchedFindingIds: const ['skin_eczema_dermatitis_cue'],
        ),
      );
    }

    // 6. Uniform dark mole / pigment tracking
    if (isDarkPigmented ||
        skinContext.concernType == SkinConcernType.molePigment) {
      return attachMetrics(
        AnalysisResult(
          id: id,
          category: CheckCategory.skinCondition,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Pigmentli Leke / Ben — Düzenli Takip Önerilir',
          summaryDetail:
              '$areaPrefixÇevre cilde göre daha koyu pigmentli bir alan gözlendi. Mevcut görüntüde yoğun renk karmaşası saptanmasa da benlerin düzenli aralıklarla takip edilmesi önerilir.',
          dominantColorValue: m.centerColor.toARGB32(),
          observations: [
            'Merkez bölgede pigment yoğunluğu çevre cilde göre daha koyu.',
            'Belirgin çok renklilik veya şiddetli asimetri saptanmadı (yalnızca görsel ön taramadır).',
            ..._symptomObservations(),
          ],
          recommendations: const [
            'Güneş koruyucu (SPF 30+) kullanın ve benlerinizi ABCDE + "Çirkin Ördek Yavrusu" kuralına göre birkaç ayda bir kontrol edin.',
            'Yeni oluşan, büyüyen veya rengi değişen tüm benler için dermatoloji muayenesi yaptırın.',
          ],
          warningFlags: const [],
          confidence: 0.62,
          createdAt: now,
          matchedFindingIds: const ['skin_abcde_suspicious_mole'],
        ),
      );
    }

    // 7. Normal / uniform skin appearance
    return attachMetrics(
      AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: skinContext.symptoms.any((s) => s.isHighPriority)
            ? RiskLevel.attention
            : RiskLevel.normal,
        summaryTitle: skinContext.symptoms.any((s) => s.isHighPriority)
            ? 'Görsel Ton Dengeli Ancak Belirti Takibi Önerilir'
            : 'Cilt Yüzeyi Tonu Olağan Görünüyor',
        summaryDetail: skinContext.symptoms.any((s) => s.isHighPriority)
            ? '${areaPrefix}Renk farkı belirgin olmasa da bildirdiğiniz belirtiler nedeniyle bir sağlık uzmanına danışmanız önerilir.'
            : '$areaPrefixÖrneklenen cilt bölgesinde belirgin kızarıklık kontrastı, koyu pigment karmaşası veya yoğun pullanma tonu saptanmadı.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          'Merkez ve çevre cilt tonları birbirine yakın ve dengeli (Fitzpatrick ${m.skinPhototype.shortLabel}).',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Düzenli nemlendirme ve güneş koruyucu kullanımı cilt bariyerini destekler.',
          'Fotoğrafta belirgin olmayan kaşıntı, ağrı veya kabartı şikayetiniz sürüyorsa dermatoloğa danışın.',
        ],
        warningFlags: const [],
        confidence: 0.68,
        createdAt: now,
        matchedFindingIds: const ['skin_healthy_intact'],
      ),
    );
  }

  AnalysisResult _analyzeSkinCancerRisk({
    required String id,
    required DateTime now,
    required String areaPrefix,
    required SkinVisualMetrics m,
    required bool isDarkPigmented,
    required bool isVariegatedOrAsymmetric,
  }) {
    final hasNonHealingSore =
        skinContext.symptoms.contains(SkinSymptomFlag.nonHealingSore);
    final effectiveAsymmetry = math.max(m.asymmetryScore, m.shapeAsymmetryScore);
    final highRisk = (isDarkPigmented && isVariegatedOrAsymmetric) ||
        skinContext.hasAbcdeRedFlag ||
        hasNonHealingSore;

    if (highRisk) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle:
            'Cilt Kanseri Risk Ön Tarama — Acil Dermatoloji (Dermoskopi) Önerilir',
        summaryDetail:
            '${areaPrefix}ABCDE kriterleri (asimetri, kenar düzensizliği, çok renklilik, hızlı değişim/6 mm+) veya iyileşmeyen yara/kanama belirtisi saptandı. Bu bir kesin kanser teşhisi değildir; ancak güvenli dışlama için dermoskopik muayene şarttır.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (isDarkPigmented)
            'Lezyon çevre cilde göre belirgin koyu pigment yoğunluğu gösteriyor.',
          if (m.colorVariegation >= 0.28 || m.hasMultiDermoscopicColor)
            'Tek lezyon içinde çoklu renk/ton farklılığı (${m.dermoscopicColors.isEmpty ? 'çoklu ton' : m.dermoscopicColors.join(', ')}) ölçüldü (ABCDE — C).',
          if (effectiveAsymmetry >= 0.14)
            'Merkez alanda belirgin yarı-simetri farkı (%${(effectiveAsymmetry * 100).toStringAsFixed(0)}) saptandı (ABCDE — A).',
          if (m.hasIrregularBorder)
            'Kenar düzensizliği / girintili sınır indeksi yüksek (${m.borderIrregularityIndex.toStringAsFixed(2)}) ölçüldü (ABCDE — B).',
          if (hasNonHealingSore)
            '4 haftadan uzun süren iyileşmeyen yara/kabuklanma (BCC/SCC açısından uyarı işareti) bildirildi.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Gecikmeden bir dermatoloji (cildiye) uzmanına dermoskopik kontrol için başvurun.',
          'Sonuç ekranındaki "Doktora Göster" özetini kaydederek tarihli değişimi hekiminizle paylaşın.',
          'Lezyonu koparmayın, yakmayın ve üzerine kendi başınıza asit/krem sürmeyin.',
        ],
        warningFlags: const [
          'Bu ön tarama kesin teşhis koymaz; asimetrik, çok renkli, büyüyen, kanayan veya 4+ haftadır iyileşmeyen lezyonlar mutlaka dermoskopi ile incelenmelidir.',
        ],
        confidence: 0.72,
        createdAt: now,
        matchedFindingIds: [
          if (hasNonHealingSore)
            'skin_non_healing_cancer_cue'
          else
            'skin_abcde_suspicious_mole',
        ],
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.attention,
      summaryTitle: 'Ben & Lezyon Ön Tarama — Düzenli ABCDE Takibi Önerilir',
      summaryDetail:
          '${areaPrefix}Mevcut görüntüde yüksek renk karmaşası veya belirgin asimetri öne çıkmadı. Ancak hiçbir telefon fotoğrafı cilt kanserini tek başına dışlayamaz; düzenli takip ve yıllık dermatoloji muayenesi önerilir.',
      dominantColorValue: m.centerColor.toARGB32(),
      observations: [
        if (isDarkPigmented)
          'Çevre cilde göre daha koyu, nispeten tek tonlu pigment alanı gözlendi.'
        else
          'Belirgin koyu pigment veya çok renklilik öne çıkmadı.',
        'Fotoğraf bazlı ön tarama derin dermal yapıları göremez; periyodik kıyas önemlidir.',
        ..._symptomObservations(),
      ],
      recommendations: const [
        'Aynı aydınlatma altında aylık karşılaştırma yaparak boyut/renk değişimini izleyin.',
        'Güneş koruyucu (SPF 30–50+) kullanın ve yılda bir kez cildiye kontrolü yaptırın.',
      ],
      warningFlags: const [],
      confidence: 0.62,
      createdAt: now,
      matchedFindingIds: const ['skin_abcde_suspicious_mole'],
    );
  }

  AnalysisResult _analyzeBruise({
    required String id,
    required DateTime now,
    required String areaPrefix,
    required SkinVisualMetrics m,
  }) {
    final isFreshOrMid = m.bluePurpleRatio >= 0.14 ||
        (m.erythemaDelta >= 0.08 && m.darknessDelta >= 0.08);
    final isHealing = m.yellowGreenBruiseRatio >= 0.14;

    if (skinContext.hasUnexplainedBruiseRedFlag) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle:
            'Darbesiz Morluk Uyarısı — Dahiliye / Hematoloji Değerlendirmesi Önerilir',
        summaryDetail:
            '${areaPrefix}Bilinen bir çarpma veya darbe olmadan kendiliğinden oluşan morluklar; trombosit/pıhtılaşma dengesi, damar hassasiyeti veya kan sulandırıcı ilaç etkileri açısından doktor değerlendirmesi gerektirir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (isFreshOrMid)
            'Taze/orta evre morlukla uyumlu koyu mor-lacivert veya kırmızımsı ton ölçüldü.',
          if (isHealing)
            'İyileşme evresiyle uyumlu yeşilimsi-sarı tonlar gözlendi.',
          'Darbe olmadan kendiliğinden oluşma öyküsü işaretlendi.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Kısa sürede Dahiliye uzmanına başvurarak tam kan sayımı ve pıhtılaşma değerlerinizi kontrol ettirin.',
          'Kan sulandırıcı, aspirin veya yeni bir ilaç/takviye kullanıyorsanız doktorunuza mutlaka bildirin.',
          'Morluğun boyutunu ve sayısını tarihli olarak takip edin.',
        ],
        warningFlags: const [
          'Diş eti/burun kanaması, ateş, halsizlik veya vücutta birden fazla darbesiz morluk varsa gecikmeden sağlık kuruluşuna başvurun.',
        ],
        confidence: 0.72,
        createdAt: now,
        matchedFindingIds: const ['skin_bruise_ecchymosis_cue'],
      );
    }

    if (isFreshOrMid) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Morluk Takibi — Taze / Orta Evre (Kırmızı-Mor / Lacivert)',
        summaryDetail:
            '${areaPrefix}Cilt altında kan birikimi (ekimoz) ile uyumlu koyu mor, kırmızımsı veya lacivert tonlar gözlendi. Darbe sonrası genellikle ilk 0–5 gün içinde bu renk evresi görülür.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          'Merkez bölgede mor-lacivert/koyu kırmızı renk oranı belirgin.',
          'İyileşme sürecinde rengin yeşil-sarıya doğru açılması beklenir.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Darbe sonrası ilk 24–48 saatte havluya sarılı soğuk kompres (15 dk aralıklarla) şişliği azaltmaya yardımcı olur.',
          '48 saatten sonra ılık kompres iyileşme dolaşımını destekleyebilir.',
          'Morluk 2 haftada açılmazsa, giderek büyüyorsa veya altında sert ağrılı kitle oluşursa doktora başvurun.',
        ],
        warningFlags: const [
          'Şiddetli şişlik, hareket kısıtlılığı, uyuşma veya kan sulandırıcı kullanımı varsa hekim değerlendirmesi alın.',
        ],
        confidence: 0.68,
        createdAt: now,
        matchedFindingIds: const ['skin_bruise_ecchymosis_cue'],
      );
    }

    if (isHealing) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.normal,
        summaryTitle: 'Morluk Takibi — İyileşme Evresi (Yeşil / Sarı Ton)',
        summaryDetail:
            '${areaPrefix}Yeşilimsi, zeytin veya sarı-kahverengi tonlar morluğun parçalanarak iyileşme evresine (yaklaşık 7–14. gün) geçtiğini gösterir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          'Merkez bölgede iyileşen morlukla uyumlu yeşil-sarı pigment tonu baskın.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Rengin önümüzdeki birkaç gün içinde tamamen açılmasını takip edin.',
          '3 haftayı geçen kalıcı morluklarda doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.67,
        createdAt: now,
        matchedFindingIds: const ['skin_bruise_ecchymosis_cue'],
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.attention,
      summaryTitle: 'Hafif / Solmakta Olan Morluk Takibi',
      summaryDetail:
          '${areaPrefix}Görüntüde yoğun mor-lacivert veya belirgin yeşil-sarı kontrastı saptanmadı; morluk çok hafif olabilir veya ortam ışığı renk tonunu zayıflatmış olabilir.',
      dominantColorValue: m.centerColor.toARGB32(),
      observations: [
        'Renk kontrastı düşük düzeyde ölçüldü.',
        ..._symptomObservations(),
      ],
      recommendations: const [
        'Doğal gün ışığında tekrar çekerek birkaç gün arayla renk değişimini karşılaştırın.',
        'Ağrı artışı, şişlik veya yeni morluklar oluşursa hekime danışın.',
      ],
      warningFlags: const [],
      confidence: 0.56,
      createdAt: now,
      matchedFindingIds: const ['skin_bruise_ecchymosis_cue'],
    );
  }

  AnalysisResult _analyzeWart({
    required String id,
    required DateTime now,
    required String areaPrefix,
    required SkinVisualMetrics m,
  }) {
    final hasRedFlags =
        skinContext.symptoms.contains(SkinSymptomFlag.bleedingOrOozing) ||
            skinContext.symptoms.contains(SkinSymptomFlag.rapidChange) ||
            skinContext.symptoms.contains(SkinSymptomFlag.nonHealingSore);
    final isSensitiveArea = skinContext.bodyArea == 'Yüz / Boyun';
    final hasRoughSurface = m.roughTextureIndex >= 0.05 || m.scalingIndex >= 0.22;
    final hasBlackDots = m.blackDotRatio >= 0.012 ||
        skinContext.symptoms.contains(SkinSymptomFlag.roughBlackDots);

    if (hasRedFlags) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle:
            'Kanayan / Hızla Değişen Kabartı — Dermatolog Muayenesi Önerilir',
        summaryDetail:
            '${areaPrefix}Siğil sanılan bazı kanamalı, iyileşmeyen veya hızla büyüyen kabartılar farklı cilt lezyonları (skuamöz hücreli lezyonlar dahil) olabilir. Kesin ayrım için dermatoloji muayenesi gerekir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (hasRoughSurface)
            'Yüzeyde belirgin pütürlü/düzensiz doku kontrastı ölçüldü.',
          if (hasBlackDots)
            'Yüzeyde koyu noktacık (kapiller veya kabuk) görünümü saptandı.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Kesinlikle kendi başınıza siğil asidi, kesme veya yakma yöntemi uygulamayın.',
          'Kısa sürede bir dermatoloji uzmanına muayene olun.',
        ],
        warningFlags: const [
          'Kanama, hızlı büyüme veya iyileşmeyen yara görünümü olan kabartılar hekim tarafından değerlendirilmelidir.',
        ],
        confidence: 0.70,
        createdAt: now,
        matchedFindingIds: const ['skin_non_healing_cancer_cue'],
      );
    }

    final wartDetail = hasRoughSurface || hasBlackDots
        ? 'Pütürlü yüzey dokusu veya koyu noktacık ipuçları yaygın siğil (verruka) veya nasır görünümüyle uyumlu olabilir.'
        : 'Görüntüde hafif doku/ton farkı gözlendi; siğil, nasır veya keratoz ayrımı için yakından dermatoloji muayenesi gerekir.';

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.attention,
      summaryTitle: 'Siğil Benzeri Pütürlü Kabartı — Ön Değerlendirme',
      summaryDetail: '$areaPrefix$wartDetail',
      dominantColorValue: m.centerColor.toARGB32(),
      observations: [
        if (hasRoughSurface)
          'Merkez alanda pürüzsüz çevre cilde kıyasla pütürlü/hiperkeratotik doku kontrastı ölçüldü.',
        if (hasBlackDots)
          'Merkezde siğillerde sık görülen küçük koyu noktacık (pıhtılaşmış kapiller) ipucu saptandı.',
        if (isSensitiveArea)
          'Yüz/boyun bölgesi hassas alan olduğundan ev tipi asitli ürünler önerilmez.',
        ..._symptomObservations(),
      ],
      recommendations: [
        if (isSensitiveArea)
          'Yüz/boyun bölgesindeki kabartılarda reçetesiz siğil asidi/bandı kullanmayın; dermatoloji uzmanına başvurun.'
        else
          'Doğru tedavi (kriyoterapi veya doktor önerili solüsyon) için cildiye uzmanına danışın.',
        'Diyabetiniz, dolaşım sorununuz veya bağışıklık baskılanmanız varsa ayak/el lezyonlarına asla evde müdahale etmeyin.',
        'Yayılımı önlemek için lezyonu koparmayın; tırnak makası, törpü ve havluları ortak kullanmayın.',
      ],
      warningFlags: const [
        'Yüz, genital bölge veya diyabetik ayaktaki kabartılar mutlaka doktor kontrolünde tedavi edilmelidir.',
      ],
      confidence: hasRoughSurface || hasBlackDots ? 0.66 : 0.56,
      createdAt: now,
      matchedFindingIds: const ['skin_wart_rough_dots_cue'],
    );
  }

  AnalysisResult _analyzeFacialSpot({
    required String id,
    required DateTime now,
    required String areaPrefix,
    required SkinVisualMetrics m,
    required bool isDarkPigmented,
    required bool isVariegatedOrAsymmetric,
    required bool isStrongRedness,
  }) {
    final suspiciousPigment = (isDarkPigmented && isVariegatedOrAsymmetric) ||
        skinContext.hasAbcdeRedFlag;

    if (suspiciousPigment) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle:
            'Yüzde Asimetrik / Değişen Koyu Leke — Dermatoloji (Dermoskopi) Önerilir',
        summaryDetail:
            '${areaPrefix}Güneşe açık yüz bölgesinde asimetrik, çok tonlu veya değişen koyu lekeler sıradan güneş lekesi olabileceği gibi atipik pigment lezyonları (lentigo maligna vb.) açısından dermoskopik muayene gerektirir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (isDarkPigmented)
            'Leke çevre yüz cildine göre belirgin derecede koyu ölçüldü.',
          if (m.colorVariegation >= 0.28 || m.hasMultiDermoscopicColor)
            'Leke içinde birden fazla kahverengi/koyu ton dağılımı gözlendi.',
          if (math.max(m.asymmetryScore, m.shapeAsymmetryScore) >= 0.14)
            'Leke alanında belirgin asimetri farkı saptandı.',
          if (m.hasIrregularBorder)
            'Leke sınırında girintili/düzensiz kenar yapısı ölçüldü.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Leke açıcı krem, peeling veya lazer işlemi yaptırmadan önce mutlaka bir dermatoloğa dermoskopi ile muayene olun.',
          'Her gün geniş spektrumlu SPF 50+ güneş koruyucu kullanın.',
        ],
        warningFlags: const [
          'Büyüyen, koyulaşan, sınırları düzensizleşen veya kanayan yüz lekeleri dermatoloji muayenesi gerektirir.',
        ],
        confidence: 0.69,
        createdAt: now,
        matchedFindingIds: const ['skin_abcde_suspicious_mole'],
      );
    }

    if (isStrongRedness) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yüzde Kızarık Leke / Hassasiyet İpucu',
        summaryDetail:
            '${areaPrefix}Yüzde çevre cilde kıyasla pembe-kırmızı ton artışı gözlendi. Akne sonrası kızarıklık (PIE), rozasea, güneş hassasiyeti veya kozmetik tahrişi ile uyumlu olabilir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          'Örneklenen yüz bölgesinde kızarıklık (eritem) artışı saptandı.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Tahriş edici asit/peeling ürünlerine ara verin; nazik temizleyici ve SPF 50+ güneş koruyucu kullanın.',
          'Kızarıklık kalıcıysa, yanma/batma yapıyorsa dermatoloji uzmanına danışın.',
        ],
        warningFlags: const [],
        confidence: 0.65,
        createdAt: now,
        matchedFindingIds: const ['skin_eczema_dermatitis_cue'],
      );
    }

    final hasTanPigment = m.darknessDelta >= 0.08 ||
        skinContext.symptoms.contains(SkinSymptomFlag.sunOrHormoneHistory);
    if (hasTanPigment) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle:
            'Yüz Lekesi / Pigmentasyon Ön Kontrol (Güneş / Melazma İpucu)',
        summaryDetail:
            '$areaPrefixÇevre cilde göre daha koyu ancak nispeten dengeli pigment tonu gözlendi. Güneş lekesi (solar lentigo), melazma veya akne sonrası leke (PIH) ile uyumlu olabilir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (m.darknessDelta >= 0.08)
            'Merkez alanda çevre yüz tonuna kıyasla lokalize pigment koyulaşması ölçüldü.',
          'Belirgin çok renklilik veya şiddetli asimetri saptanmadı.',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Yaz-kış düzenli SPF 50+ (tercihen görünür ışığa karşı renkli/mineral filtreli) güneş koruyucu kullanın.',
          'Reçetesiz yüksek oranlı leke açıcı asitler lekeyi koyulaştırabilir; hedefe yönelik bakım için dermatoloğa danışın.',
          'Aylık fotoğraflarla lekenin solma veya koyulaşma seyrini takip edin.',
        ],
        warningFlags: const [],
        confidence: 0.64,
        createdAt: now,
        matchedFindingIds: const ['skin_facial_hyperpigmentation_cue'],
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Yüz Cilt Tonu Dengeli Görünüyor',
      summaryDetail:
          '$areaPrefixÖrneklenen alanda belirgin koyu pigment kontrastı veya yoğun kızarıklık farkı saptanmadı.',
      dominantColorValue: m.centerColor.toARGB32(),
      observations: [
        'Merkez ve çevre yüz tonları birbirine yakın ve homojen.',
        ..._symptomObservations(),
      ],
      recommendations: const [
        'Günlük güneş koruyucu ve düzenli nemlendirme leke oluşumunu önlemeye yardımcı olur.',
      ],
      warningFlags: const [],
      confidence: 0.66,
      createdAt: now,
      matchedFindingIds: const ['skin_healthy_intact'],
    );
  }

  Map<String, String> _buildSkinMetrics(SkinVisualMetrics m) {
    final effectiveAsymmetry = math.max(m.asymmetryScore, m.shapeAsymmetryScore);
    return {
      'Fitzpatrick Fototip':
          '${m.skinPhototype.shortLabel} (ITA ${m.surroundingSkinIta.toStringAsFixed(0)}°)',
      'A — Asimetri': '%${(effectiveAsymmetry * 100).toStringAsFixed(0)}',
      'B — Sınır Düzensizliği': m.borderIrregularityIndex.toStringAsFixed(2),
      'C — Renk Sayısı': m.dermoscopicColors.isEmpty
          ? '1 (Homojen)'
          : '${m.dermoscopicColors.length} (${m.dermoscopicColors.join(', ')})',
      'Eritem İndeksi Farkı':
          '${m.erythemaIndexDelta >= 0 ? '+' : ''}${m.erythemaIndexDelta.toStringAsFixed(1)}',
      if (m.hasAnnularClearingRing) 'Anüler Halka Skoru': 'Belirgin',
    };
  }

  List<String> _symptomObservations() {
    if (skinContext.symptoms.isEmpty) return const [];
    final labels = skinContext.symptoms.map((s) => s.label).join(', ');
    return ['Bildirilen belirtiler: $labels.'];
  }
}
