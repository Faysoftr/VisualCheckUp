import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// 0-token on-device 2D spatial & structural feature metrics extracted from
/// the target region of interest (ROI).
///
/// Complements average CIE L*a*b* / HSV color analysis by detecting localized
/// anatomical structures and clinical colorimetric biomarkers that barely
/// alter the global average color:
/// - **Tongue:** dark linear fissures/grooves (yarık/çatlak dil), white vs.
///   yellow coating coverage, geographic tongue (red patches rimmed by white
///   borders), and mucosal Erythema Index.
/// - **Eye:** localized red capillary blood vessels (kılcal kanlanma), compact
///   subconjunctival hemorrhage patches, BiliScreen-style scleral yellowness
///   index, and palpebral conjunctiva Erythema Index (Collings anemia cue).
/// - **Nail:** bright white spots/bands (lökoniki), distal splitting/cracks/
///   surface ridges, narrow dark vertical melanonychia bands, transverse Beau
///   grooves, Terry/Lindsay proximal-distal split, splinter hemorrhages, and
///   Mannino-style nailbed Erythema Index.
class StructuralFeatures {
  const StructuralFeatures({
    this.fissureGrooveRatio = 0.0,
    this.coatingPatchRatio = 0.0,
    this.yellowCoatingRatio = 0.0,
    this.geographicPatchScore = 0.0,
    this.mucosalErythemaIndex = 0.0,
    this.scleraVesselRatio = 0.0,
    this.scleraYellowRatio = 0.0,
    this.scleralBilirubinIndex = 0.0,
    this.hemorrhagePatchRatio = 0.0,
    this.conjunctivaErythemaIndex = 0.0,
    this.whiteLineSpotRatio = 0.0,
    this.fractureEdgeRoughness = 0.0,
    this.darkVerticalBandScore = 0.0,
    this.transverseGrooveScore = 0.0,
    this.proximalDistalSplitScore = 0.0,
    this.splinterStreakRatio = 0.0,
    this.nailErythemaIndex = 0.0,
    this.nailSkinEiDelta = 0.0,
    this.urineTurbidityScore = 0.0,
    this.faceMalarEiDelta = 0.0,
  });

  /// Fraction (0..1) of tongue ROI pixels forming dark narrow grooves/fissures.
  final double fissureGrooveRatio;

  /// Fraction (0..1) of tongue ROI covered by pale/whitish-yellow coating.
  final double coatingPatchRatio;

  /// Fraction (0..1) of tongue ROI covered specifically by yellowish coating.
  final double yellowCoatingRatio;

  /// Normalized (0..1) geographic tongue signature (smooth red depapillated
  /// islands adjacent to pale/whitish elevated rims).
  final double geographicPatchScore;

  /// Mean Erythema Index (`100 * (log10(R) - log10(G))`) of non-coated tongue
  /// mucosa pixels.
  final double mucosalErythemaIndex;

  /// Fraction (0..1) of eye ROI pixels showing fine red capillary vessels.
  final double scleraVesselRatio;

  /// Fraction (0..1) of eye ROI pixels showing localized yellow sclera tint.
  final double scleraYellowRatio;

  /// BiliScreen-inspired normalized yellow chrominance score (0..100) across
  /// segmented bright sclera pixels.
  final double scleralBilirubinIndex;

  /// Fraction (0..1) of sclera forming a compact, dense bright-red patch
  /// (subconjunctival hemorrhage vs diffuse fine capillaries).
  final double hemorrhagePatchRatio;

  /// Mean Collings Erythema Index across mucosal conjunctiva pixels.
  final double conjunctivaErythemaIndex;

  /// Fraction (0..1) of nail ROI pixels forming bright white spots/bands
  /// contrasting against the pink nail plate.
  final double whiteLineSpotRatio;

  /// Normalized (0..1) high-frequency edge roughness / fracture / ridge energy
  /// across the nail plate and free edge.
  final double fractureEdgeRoughness;

  /// Normalized (0..1) vertical dark-band contrast score on the nail plate
  /// (detects narrow dark longitudinal melanonychia streaks).
  final double darkVerticalBandScore;

  /// Normalized (0..1) horizontal dark-groove valley score across the nail
  /// plate (Beau's transverse lines).
  final double transverseGrooveScore;

  /// Normalized (0..1) proximal-white vs distal-pink/brown band contrast
  /// (Terry's nails / Lindsay's half-and-half nails).
  final double proximalDistalSplitScore;

  /// Fraction (0..1) of nail ROI showing thin dark-red longitudinal splinter
  /// hemorrhage micro-streaks.
  final double splinterStreakRatio;

  /// Mean Mannino-style nailbed Erythema Index (`100 * (log10(R) - log10(G))`).
  final double nailErythemaIndex;

  /// Relative Mannino nailbed-to-surrounding-finger-skin Erythema Index delta
  /// (`nailEI - fingerSkinEI`), reducing lighting and skin-phototype drift.
  final double nailSkinEiDelta;

  /// Local texture/cloudiness turbidity score (0..1) for urine clarity cues.
  final double urineTurbidityScore;

  /// Cheek-vs-forehead Erythema Index delta (`cheekEI - foreheadEI`) for malar
  /// / facial flushing cues.
  final double faceMalarEiDelta;

  bool get hasTongueFissures => fissureGrooveRatio >= 0.032;
  bool get hasTongueCoatingPatch => coatingPatchRatio >= 0.24;
  bool get hasTongueYellowCoating => yellowCoatingRatio >= 0.20;
  bool get hasGeographicTongueCue => geographicPatchScore >= 0.14;
  bool get hasEyeRedVessels => scleraVesselRatio >= 0.025;
  bool get hasEyeYellowPatch => scleraYellowRatio >= 0.08;
  bool get hasSubconjunctivalHemorrhage => hemorrhagePatchRatio >= 0.035;
  bool get hasNailWhiteLinesOrSpots => whiteLineSpotRatio >= 0.022;
  bool get hasNailCracksOrRoughness => fractureEdgeRoughness >= 0.24;
  bool get hasNailDarkVerticalBand => darkVerticalBandScore >= 0.22;
  bool get hasNailTransverseGroove => transverseGrooveScore >= 0.25;
  bool get hasTerryOrLindsaySplit => proximalDistalSplitScore >= 0.30;
  bool get hasSplinterHemorrhage => splinterStreakRatio >= 0.012;
  bool get hasCloudyUrineCue => urineTurbidityScore >= 0.28;
  bool get hasFaceMalarRedness => faceMalarEiDelta >= 6.5;

  String toCompactTelemetry(CheckCategory category) {
    switch (category) {
      case CheckCategory.tongue:
        return 'fissure=${(fissureGrooveRatio * 100).toStringAsFixed(1)}% '
            'coating=${(coatingPatchRatio * 100).toStringAsFixed(1)}% '
            'yellow=${(yellowCoatingRatio * 100).toStringAsFixed(1)}% '
            'geo=${(geographicPatchScore * 100).toStringAsFixed(0)}% '
            'ei=${mucosalErythemaIndex.toStringAsFixed(1)}';
      case CheckCategory.eye:
        return 'vessels=${(scleraVesselRatio * 100).toStringAsFixed(1)}% '
            'hemorrhage=${(hemorrhagePatchRatio * 100).toStringAsFixed(1)}% '
            'yellow_patch=${(scleraYellowRatio * 100).toStringAsFixed(1)}% '
            'bili=${scleralBilirubinIndex.toStringAsFixed(1)} '
            'conj_ei=${conjunctivaErythemaIndex.toStringAsFixed(1)}';
      case CheckCategory.nail:
        return 'white_lines=${(whiteLineSpotRatio * 100).toStringAsFixed(1)}% '
            'cracks_rough=${(fractureEdgeRoughness * 100).toStringAsFixed(1)}% '
            'dark_vband=${(darkVerticalBandScore * 100).toStringAsFixed(1)}% '
            'beau=${(transverseGrooveScore * 100).toStringAsFixed(0)}% '
            'terry=${(proximalDistalSplitScore * 100).toStringAsFixed(0)}% '
            'splinter=${(splinterStreakRatio * 100).toStringAsFixed(1)}% '
            'ei=${nailErythemaIndex.toStringAsFixed(1)} '
            'd_ei=${nailSkinEiDelta.toStringAsFixed(1)}';
      case CheckCategory.urine:
        return 'turbidity=${(urineTurbidityScore * 100).toStringAsFixed(0)}%';
      case CheckCategory.face:
        return 'malar_dei=${faceMalarEiDelta.toStringAsFixed(1)} '
            'roughness=${(fractureEdgeRoughness * 100).toStringAsFixed(1)}%';
      default:
        return 'roughness=${(fractureEdgeRoughness * 100).toStringAsFixed(1)}%';
    }
  }
}

/// Pure-Dart, 0-token 2D computer vision analyzer for localized clinical
/// structures (fissures, geographic patches, capillary vessels, subconjunctival
/// hemorrhage, white nail lines, cracks, Beau grooves, Terry/Lindsay splits,
/// splinter hemorrhages, and melanonychia bands).
class StructuralFeatureAnalyzer {
  StructuralFeatureAnalyzer._();

  static const int _gridSize = 96;

  static StructuralFeatures analyze({
    required img.Image image,
    required CheckCategory category,
    WhiteBalanceGains? gains,
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
    var roi = img.copyResize(
      cropped,
      width: _gridSize,
      height: _gridSize,
      interpolation: img.Interpolation.linear,
    );
    if (gains != null) {
      roi = ColorCalibrator.applyGainsToImage(roi, gains);
    }

    switch (category) {
      case CheckCategory.tongue:
        return _analyzeTongue(roi);
      case CheckCategory.eye:
        return _analyzeEye(roi);
      case CheckCategory.nail:
        return _analyzeNail(roi);
      case CheckCategory.urine:
        return _analyzeUrine(roi);
      case CheckCategory.face:
        return _analyzeFace(roi);
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
    // Pixel class tags for geographic tongue boundary analysis:
    // 0 = other, 1 = deep red depapillated patch, 2 = pale/white rim
    final pixelClass = List<int>.filled(w * h, 0);
    var coatingCount = 0;
    var yellowCoatingCount = 0;
    var validCount = 0;
    var redPatchCount = 0;
    var whiteRimCount = 0;
    var mucosaEiSum = 0.0;
    var mucosaEiCount = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final r = ri.toDouble();
        final g = gi.toDouble();
        final b = bi.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final idx = y * w + x;
        luma[idx] = l;

        // Ignore wet saliva specular glare highlights & dark mouth cavity shadow
        if (l < 36 || ColorCalibrator.isSpecularGlare(ri, gi, bi)) continue;
        validCount++;

        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        final redExcess = r - g;

        // Whitish matte coating: high luminance, low redness excess
        if (l >= 165 && sat <= 0.24 && redExcess < 22) {
          coatingCount++;
          if (l >= 188 && sat <= 0.18) {
            pixelClass[idx] = 2;
            whiteRimCount++;
          }
        } else if (r >= 145 &&
            g >= 120 &&
            ((r + g) * 0.5 - b) >= 34 &&
            redExcess <= 38) {
          // Yellowish-orange coating patch
          yellowCoatingCount++;
          coatingCount++;
        } else if (l >= 55) {
          mucosaEiSum += ColorCalibrator.erythemaIndex(ri, gi);
          mucosaEiCount++;
          // Smooth deep-red depapillated island candidate
          if (r >= 135 && redExcess >= 58 && (r - b) >= 48) {
            pixelClass[idx] = 1;
            redPatchCount++;
          }
        }
      }
    }

    // Geographic tongue signature: significant red islands AND white rims
    // with frequent spatial adjacency (red patches directly rimmed by white).
    var geographicScore = 0.0;
    if (validCount > 0 &&
        redPatchCount >= (validCount * 0.06) &&
        whiteRimCount >= (validCount * 0.03)) {
      var borderHits = 0;
      for (var y = 2; y < h - 2; y++) {
        for (var x = 2; x < w - 2; x++) {
          if (pixelClass[y * w + x] != 1) continue;
          var nearWhite = false;
          for (var dy = -2; dy <= 2 && !nearWhite; dy++) {
            for (var dx = -2; dx <= 2; dx++) {
              if (pixelClass[(y + dy) * w + (x + dx)] == 2) {
                nearWhite = true;
                break;
              }
            }
          }
          if (nearWhite) borderHits++;
        }
      }
      geographicScore = (borderHits / math.max(1, redPatchCount) * 0.75 +
              (whiteRimCount / validCount).clamp(0.0, 0.25))
          .clamp(0.0, 1.0);
      // Require meaningful actual border length
      if (borderHits < 20) {
        geographicScore = 0.0;
      }
    }

    // Detect dark linear valleys (fissures/grooves):
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
      fissureGrooveRatio: interiorPixels > 0
          ? (fissurePixels / interiorPixels).clamp(0.0, 1.0)
          : 0.0,
      coatingPatchRatio:
          validCount > 0 ? (coatingCount / validCount).clamp(0.0, 1.0) : 0.0,
      yellowCoatingRatio: validCount > 0
          ? (yellowCoatingCount / validCount).clamp(0.0, 1.0)
          : 0.0,
      geographicPatchScore: geographicScore,
      mucosalErythemaIndex:
          mucosaEiCount > 0 ? mucosaEiSum / mucosaEiCount : 0.0,
    );
  }

  static StructuralFeatures _analyzeEye(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    var scleraPixels = 0;
    var redVesselPixels = 0;
    var yellowPatchPixels = 0;
    var biliSum = 0.0;
    var conjEiSum = 0.0;
    var conjEiCount = 0;

    final denseRedMask = List<bool>.filled(w * h, false);

    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final r = ri.toDouble();
        final g = gi.toDouble();
        final b = bi.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;

        // Track mucosal Erythema Index for lower-eyelid conjunctiva screening
        if (l >= 70 && l <= 245 && r >= g) {
          conjEiSum += ColorCalibrator.erythemaIndex(ri, gi);
          conjEiCount++;
        }

        // Dense crimson subconjunctival hemorrhage pixels have lower luminance
        // (~55-85 because pure red carries 0.299 weight) than white sclera,
        // so detect them before the bright-sclera luminance cutoff.
        final isDenseCrimson =
            l >= 45 && r >= 140 && (r - g) >= 70.0 && (r - b) >= 70.0;

        // Focus on sclera-like bright pixels (exclude dark pupil/iris/eyelashes)
        if (!isDenseCrimson && (l < 85 || l > 250)) continue;
        scleraPixels++;

        // BiliScreen-style normalized scleral yellowness (b* positive channel)
        final lab = LabColor.fromRgb(ri, gi, bi);
        biliSum += math.max(0.0, lab.b);

        // Localized red capillary / bloodshot vessel pixel:
        // True crimson/red vessels have R >> G ≈ B (distinguishing them from
        // warm yellow lighting where G >> B).
        final redExcess = r - ((g + b) * 0.5);
        if (isDenseCrimson ||
            (redExcess >= 36.0 &&
                r >= 120 &&
                (r - g) >= 34.0 &&
                (g - b) <= 28.0)) {
          redVesselPixels++;
          if (isDenseCrimson) {
            denseRedMask[y * w + x] = true;
          }
        }

        // Localized yellow sclera patch (jaundice): R & G high, B noticeably low
        if (r >= 150 &&
            g >= 135 &&
            ((r + g) * 0.5 - b) >= 34.0 &&
            (r - g).abs() <= 35.0) {
          yellowPatchPixels++;
        }
      }
    }

    // Compact dense red patch detection (subconjunctival hemorrhage):
    // A hemorrhage pixel is surrounded by >= 7 dense red neighbors in its 3x3
    // neighborhood, whereas thin 1-2px capillaries have <= 5 red neighbors.
    var compactHemorrhagePixels = 0;
    for (var y = 2; y < h - 2; y++) {
      for (var x = 2; x < w - 2; x++) {
        if (!denseRedMask[y * w + x]) continue;
        var neighbors = 0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            if (denseRedMask[(y + dy) * w + (x + dx)]) neighbors++;
          }
        }
        if (neighbors >= 7) {
          compactHemorrhagePixels++;
        }
      }
    }

    if (scleraPixels < 40) {
      return StructuralFeatures(
        conjunctivaErythemaIndex:
            conjEiCount > 0 ? conjEiSum / conjEiCount : 0.0,
      );
    }

    return StructuralFeatures(
      scleraVesselRatio: (redVesselPixels / scleraPixels).clamp(0.0, 1.0),
      scleraYellowRatio: (yellowPatchPixels / scleraPixels).clamp(0.0, 1.0),
      scleralBilirubinIndex: (biliSum / scleraPixels).clamp(0.0, 100.0),
      hemorrhagePatchRatio:
          (compactHemorrhagePixels / scleraPixels).clamp(0.0, 1.0),
      conjunctivaErythemaIndex:
          conjEiCount > 0 ? conjEiSum / conjEiCount : 0.0,
    );
  }

  static StructuralFeatures _analyzeNail(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    final luma = List<double>.filled(w * h, 0);
    final satList = List<double>.filled(w * h, 0);
    final redExcessGrid = List<double>.filled(w * h, 0);
    final sortedLuma = <double>[];
    var eiSum = 0.0;
    var eiCount = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final r = ri.toDouble();
        final g = gi.toDouble();
        final b = bi.toDouble();
        final l = 0.299 * r + 0.587 * g + 0.114 * b;
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final s = maxC > 0 ? (maxC - minC) / maxC : 0.0;
        final idx = y * w + x;
        luma[idx] = l;
        satList[idx] = s;
        redExcessGrid[idx] = r - ((g + b) * 0.5);
        if (l > 30 && l < 245) {
          sortedLuma.add(l);
          eiSum += ColorCalibrator.erythemaIndex(ri, gi);
          eiCount++;
        }
      }
    }

    if (sortedLuma.length < 40) {
      return const StructuralFeatures();
    }
    sortedLuma.sort();
    final medianL = sortedLuma[sortedLuma.length ~/ 2];

    // 1. White spots / transverse white bands (leukonychia / Muehrcke lines)
    var whiteSpotPixels = 0;
    var platePixels = 0;
    var splinterPixels = 0;
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
          var brightNeighbors = 0;
          if (luma[idx - 1] >= 195) brightNeighbors++;
          if (luma[idx + 1] >= 195) brightNeighbors++;
          if (luma[idx - w] >= 195) brightNeighbors++;
          if (luma[idx + w] >= 195) brightNeighbors++;
          if (brightNeighbors >= 2) {
            whiteSpotPixels++;
          }
        }

        // Splinter hemorrhage micro-streak: dark reddish pixel markedly darker
        // than horizontal left/right neighbors while continuing vertically.
        final re = redExcessGrid[idx];
        if (medianL >= 115 && l < medianL - 35 && re >= 28.0) {
          final hContrast =
              ((luma[idx - 2] + luma[idx + 2]) * 0.5) - l;
          final vContinuity =
              (luma[idx - w] - l).abs() <= 24.0 &&
              (luma[idx + w] - l).abs() <= 24.0;
          if (hContrast >= 32.0 && vContinuity) {
            splinterPixels++;
          }
        }
      }
    }

    // 2. Dark longitudinal vertical band (melanonychia)
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
      if (dipWidth >= 2 && dipWidth <= (colMedians.length * 0.40)) {
        darkBandScore = ((maxDip - 30.0) / 90.0).clamp(0.0, 1.0);
      }
    }

    // 3. Transverse horizontal grooves (Beau's lines):
    //    Compute row-wise median luminance across middle 60% width; a true
    //    Beau's groove produces a narrow horizontal dark band (2..18% height)
    //    spanning the nail plate.
    final rowMedians = <double>[];
    final xStart = (w * 0.20).round();
    final xEnd = (w * 0.80).round();
    for (var y = 6; y < h - 6; y++) {
      final rowVals = <double>[];
      for (var x = xStart; x < xEnd; x++) {
        rowVals.add(luma[y * w + x]);
      }
      rowVals.sort();
      rowMedians.add(rowVals[rowVals.length ~/ 2]);
    }

    var transverseGrooveScore = 0.0;
    if (rowMedians.length >= 12 && medianL >= 100) {
      final sortedRows = [...rowMedians]..sort();
      final plateRowMedian = sortedRows[sortedRows.length ~/ 2];
      var maxRowDip = 0.0;
      var dipHeight = 0;
      var curHeight = 0;
      for (final rm in rowMedians) {
        final dip = plateRowMedian - rm;
        if (dip >= 26.0) {
          curHeight++;
          if (dip > maxRowDip) maxRowDip = dip;
          if (curHeight > dipHeight) dipHeight = curHeight;
        } else {
          curHeight = 0;
        }
      }
      if (dipHeight >= 2 && dipHeight <= (rowMedians.length * 0.20)) {
        transverseGrooveScore = ((maxRowDip - 20.0) / 70.0).clamp(0.0, 1.0);
      }
    }

    // 4. Terry's / Lindsay's (half-and-half) proximal-distal band split:
    //    Proximal 55% is markedly paler/whiter (high L, low S) while distal
    //    25% shows a darker pink/brown band (lower L, higher saturation).
    double proxL = 0, proxS = 0, distL = 0, distS = 0;
    int proxN = 0, distN = 0;
    for (var y = (h * 0.15).round(); y < (h * 0.65).round(); y++) {
      for (var x = xStart; x < xEnd; x++) {
        final idx = y * w + x;
        proxL += luma[idx];
        proxS += satList[idx];
        proxN++;
      }
    }
    for (var y = (h * 0.72).round(); y < (h * 0.92).round(); y++) {
      for (var x = xStart; x < xEnd; x++) {
        final idx = y * w + x;
        distL += luma[idx];
        distS += satList[idx];
        distN++;
      }
    }
    var proximalDistalSplitScore = 0.0;
    if (proxN > 0 && distN > 0) {
      final avgProxL = proxL / proxN;
      final avgProxS = proxS / proxN;
      final avgDistL = distL / distN;
      final avgDistS = distS / distN;
      final lDiff = avgProxL - avgDistL;
      final sDiff = avgDistS - avgProxS;
      if (avgProxL >= 195 && avgProxS <= 0.14 && lDiff >= 26.0 && sDiff >= 0.10) {
        proximalDistalSplitScore =
            (((lDiff - 20.0) / 60.0) * 0.6 + ((sDiff - 0.08) / 0.30) * 0.4)
                .clamp(0.0, 1.0);
      }
    }

    // 5. Mannino relative nailbed vs. surrounding finger skin Erythema Index
    //    delta (central 25%..75% vs outer border 0..14% & 86%..100%).
    double innerEiSum = 0, outerEiSum = 0;
    int innerEiN = 0, outerEiN = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final l = 0.299 * ri + 0.587 * gi + 0.114 * bi;
        if (l < 35 || ColorCalibrator.isSpecularGlare(ri, gi, bi)) continue;
        final ei = ColorCalibrator.erythemaIndex(ri, gi);
        final isInner =
            x >= w * 0.25 && x <= w * 0.75 && y >= h * 0.25 && y <= h * 0.75;
        final isOuter =
            x < w * 0.15 || x > w * 0.85 || y < h * 0.15 || y > h * 0.85;
        if (isInner) {
          innerEiSum += ei;
          innerEiN++;
        } else if (isOuter) {
          outerEiSum += ei;
          outerEiN++;
        }
      }
    }
    final nailSkinEiDelta = (innerEiN >= 16 && outerEiN >= 16)
        ? ((innerEiSum / innerEiN) - (outerEiSum / outerEiN))
        : 0.0;

    // 6. Surface cracks, peeling, splitting (high-frequency edge energy)
    final roughness = _computeEdgeRoughness(roi);

    return StructuralFeatures(
      whiteLineSpotRatio: platePixels > 0
          ? (whiteSpotPixels / platePixels).clamp(0.0, 1.0)
          : 0.0,
      fractureEdgeRoughness: roughness,
      darkVerticalBandScore: darkBandScore,
      transverseGrooveScore: transverseGrooveScore,
      proximalDistalSplitScore: proximalDistalSplitScore,
      splinterStreakRatio: platePixels > 0
          ? (splinterPixels / platePixels).clamp(0.0, 1.0)
          : 0.0,
      nailErythemaIndex: eiCount > 0 ? eiSum / eiCount : 0.0,
      nailSkinEiDelta: nailSkinEiDelta,
    );
  }

  /// Evaluates urine sample clarity/turbidity from local luminance variance
  /// and micro-texture (clear translucent liquid = smooth; cloudy/foamy = high
  /// local texture + muted saturation patches).
  static StructuralFeatures _analyzeUrine(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    final luma = List<double>.filled(w * h, 0);
    int hazyPixels = 0;
    int validPixels = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final l = 0.299 * ri + 0.587 * gi + 0.114 * bi;
        luma[y * w + x] = l;
        if (l < 30 || ColorCalibrator.isSpecularGlare(ri, gi, bi)) continue;
        validPixels++;
        final lab = LabColor.fromRgb(ri, gi, bi);
        // Milky / hazy cloudy urine exhibits mid-high L* with muted chroma
        if (lab.l >= 55.0 && lab.l <= 88.0 && lab.chroma <= 24.0) {
          hazyPixels++;
        }
      }
    }

    double gradSum = 0;
    int gradN = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final c = luma[y * w + x];
        final diff =
            ((c - luma[y * w + (x + 1)]).abs() + (c - luma[(y + 1) * w + x]).abs()) *
                0.5;
        gradSum += diff;
        gradN++;
      }
    }

    final localTexture = gradN > 0 ? (gradSum / gradN / 22.0).clamp(0.0, 1.0) : 0.0;
    final hazyRatio = validPixels > 0 ? (hazyPixels / validPixels).clamp(0.0, 1.0) : 0.0;
    final turbidity = (localTexture * 0.65 + hazyRatio * 0.35).clamp(0.0, 1.0);

    return StructuralFeatures(
      urineTurbidityScore: turbidity,
      fractureEdgeRoughness: _computeEdgeRoughness(roi),
    );
  }

  /// Evaluates facial cheek-vs-forehead Erythema Index delta (malar flushing
  /// cue) while normalizing for constitutive skin tone.
  static StructuralFeatures _analyzeFace(img.Image roi) {
    final w = roi.width;
    final h = roi.height;
    double foreheadEi = 0, cheekEi = 0;
    int foreheadN = 0, cheekN = 0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final ri = p.r.round().clamp(0, 255);
        final gi = p.g.round().clamp(0, 255);
        final bi = p.b.round().clamp(0, 255);
        final l = 0.299 * ri + 0.587 * gi + 0.114 * bi;
        if (l < 35 || ColorCalibrator.isSpecularGlare(ri, gi, bi)) continue;
        final ei = ColorCalibrator.erythemaIndex(ri, gi);

        if (y >= h * 0.12 && y <= h * 0.34 && x >= w * 0.25 && x <= w * 0.75) {
          foreheadEi += ei;
          foreheadN++;
        } else if (y >= h * 0.45 &&
            y <= h * 0.72 &&
            ((x >= w * 0.12 && x <= w * 0.38) ||
                (x >= w * 0.62 && x <= w * 0.88))) {
          cheekEi += ei;
          cheekN++;
        }
      }
    }

    final malarDelta = (foreheadN >= 16 && cheekN >= 16)
        ? ((cheekEi / cheekN) - (foreheadEi / foreheadN))
        : 0.0;

    return StructuralFeatures(
      faceMalarEiDelta: malarDelta,
      fractureEdgeRoughness: _computeEdgeRoughness(roi),
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
