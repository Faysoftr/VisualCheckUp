import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

enum ImageQualityIssue {
  none,
  tooDark,
  overexposed,
  tooBlurry,
}

enum LiveQualityLevel {
  good,
  caution,
  poor,
}

/// Real-time capture guidance metrics computed from the camera preview stream.
class LiveCameraQuality {
  const LiveCameraQuality({
    required this.lightingLevel,
    required this.sharpnessLevel,
    required this.glareLevel,
    required this.meanLuminance,
    required this.tenengradScore,
    required this.blownRatio,
  });

  final LiveQualityLevel lightingLevel;
  final LiveQualityLevel sharpnessLevel;
  final LiveQualityLevel glareLevel;
  final double meanLuminance;
  final double tenengradScore;
  final double blownRatio;

  bool get isAllGood =>
      lightingLevel == LiveQualityLevel.good &&
      sharpnessLevel == LiveQualityLevel.good &&
      glareLevel == LiveQualityLevel.good;
}

class PreprocessedImage {
  const PreprocessedImage({
    required this.jpegBytes,
    required this.width,
    required this.height,
    required this.qualityIssue,
    required this.blurScore,
    required this.meanLuminance,
    required this.contentFingerprint,
    this.tenengradScore = 0.0,
    this.glareRatio = 0.0,
    this.colorCalibratedForAi = false,
  });

  /// Cropped, resized, JPEG-compressed bytes optimized for low Vision AI token
  /// usage and fast mobile upload.
  final Uint8List jpegBytes;
  final int width;
  final int height;
  final ImageQualityIssue qualityIssue;

  /// Variance of Laplacian in the central ROI (higher = sharper).
  final double blurScore;

  /// Mean Sobel Tenengrad gradient energy in the central ROI (robust to ISO noise).
  final double tenengradScore;

  /// Fraction of hard-blown highlight pixels in central ROI (0..1).
  final double glareRatio;
  final double meanLuminance;

  /// Whether color constancy / white-balance gains were baked into [jpegBytes].
  final bool colorCalibratedForAi;

  /// Deterministic content hash for 0-token duplicate-image caching.
  final String contentFingerprint;

  bool get passesQualityGate => qualityIssue == ImageQualityIssue.none;
}

/// 0-token on-device image quality gate and compression pipeline run before any
/// Vision AI request.
///
/// 1. Rejects overly dark, blown-out, or visibly out-of-focus captures locally
///    (combining Laplacian variance + Sobel Tenengrad gradient energy) so no
///    API tokens are wasted on unusable photos.
/// 2. Crops to the central frame, downscales to 512px (color-primary modules)
///    or 768px (skin/nail morphology modules), optionally bakes D65 color
///    constancy gains into the Vision AI crop, and encodes JPEG at quality 82.
/// 3. Computes a deterministic FNV-1a fingerprint for duplicate-request caching.
class ImagePreprocessor {
  ImagePreprocessor._();

  static int targetMaxDimension(CheckCategory category) {
    switch (category) {
      case CheckCategory.skinCondition:
      case CheckCategory.nail:
        return 768;
      case CheckCategory.eye:
      case CheckCategory.tongue:
      case CheckCategory.face:
      case CheckCategory.urine:
      case CheckCategory.stool:
        return 512;
    }
  }

  static bool _requiresSharpTexture(CheckCategory category) {
    switch (category) {
      case CheckCategory.skinCondition:
      case CheckCategory.nail:
      case CheckCategory.eye:
      case CheckCategory.tongue:
        return true;
      case CheckCategory.face:
      case CheckCategory.urine:
      case CheckCategory.stool:
        return false;
    }
  }

  static PreprocessedImage prepare({
    required img.Image decoded,
    required CheckCategory category,
    bool preserveWhiteRefStrip = false,
    WhiteBalanceGains? colorCalibrationGains,
    int jpegQuality = 82,
  }) {
    final quality = assessQuality(decoded: decoded, category: category);

    // Crop away noisy outer room edges while preserving subject + surrounding
    // reference ring (and bottom white-reference box if enabled).
    final cropX = (decoded.width * 0.12).round().clamp(0, decoded.width - 1);
    final cropY = (decoded.height * 0.12).round().clamp(0, decoded.height - 1);
    final cropRight =
        (decoded.width * 0.88).round().clamp(cropX + 1, decoded.width);
    final bottomRatio = preserveWhiteRefStrip ? 0.92 : 0.88;
    final cropBottom =
        (decoded.height * bottomRatio).round().clamp(cropY + 1, decoded.height);

    final cropped = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: cropRight - cropX,
      height: cropBottom - cropY,
    );

    final maxDim = targetMaxDimension(category);
    img.Image resized = cropped;
    if (cropped.width > maxDim || cropped.height > maxDim) {
      if (cropped.width >= cropped.height) {
        resized = img.copyResize(
          cropped,
          width: maxDim,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resized = img.copyResize(
          cropped,
          height: maxDim,
          interpolation: img.Interpolation.linear,
        );
      }
    }

    // Bake color constancy / white balance gains into the resized AI payload
    // so Vision AI sees true D65 tissue hues rather than warm/cool room bulbs.
    var colorCalibratedForAi = false;
    if (colorCalibrationGains != null) {
      resized = ColorCalibrator.applyGainsToImage(
        resized,
        colorCalibrationGains,
      );
      colorCalibratedForAi = true;
    }

    final jpegBytes = Uint8List.fromList(
      img.encodeJpg(resized, quality: jpegQuality),
    );
    final fingerprint = computeFingerprint(
      bytes: jpegBytes,
      category: category,
      useWhiteReference: preserveWhiteRefStrip,
    );

    return PreprocessedImage(
      jpegBytes: jpegBytes,
      width: resized.width,
      height: resized.height,
      qualityIssue: quality.issue,
      blurScore: quality.blurScore,
      tenengradScore: quality.tenengradScore,
      glareRatio: quality.glareRatio,
      meanLuminance: quality.meanLuminance,
      colorCalibratedForAi: colorCalibratedForAi,
      contentFingerprint: fingerprint,
    );
  }

  static ({
    ImageQualityIssue issue,
    double blurScore,
    double tenengradScore,
    double glareRatio,
    double meanLuminance,
  }) assessQuality({
    required img.Image decoded,
    required CheckCategory category,
  }) {
    // Work on a compact grayscale center ROI (~160px) for fast (<10ms) metrics.
    final roiX = (decoded.width * 0.25).round().clamp(0, decoded.width - 1);
    final roiY = (decoded.height * 0.25).round().clamp(0, decoded.height - 1);
    final roiW =
        (decoded.width * 0.50).round().clamp(1, decoded.width - roiX);
    final roiH =
        (decoded.height * 0.50).round().clamp(1, decoded.height - roiY);

    var roi = img.copyCrop(
      decoded,
      x: roiX,
      y: roiY,
      width: roiW,
      height: roiH,
    );
    if (roi.width > 160) {
      roi = img.copyResize(roi, width: 160);
    }

    final w = roi.width;
    final h = roi.height;
    final gray = Float64List(w * h);

    double sumLum = 0;
    double sumLum2 = 0;
    int blownWhite = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = roi.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b; // 0..255
        gray[y * w + x] = lum;
        sumLum += lum;
        sumLum2 += lum * lum;
        if (r >= 250 && g >= 250 && b >= 250) {
          blownWhite++;
        }
      }
    }

    final n = math.max(1, w * h);
    final meanLum255 = sumLum / n;
    final meanLum = meanLum255 / 255.0;
    final lumStd = math.sqrt(math.max(0.0, (sumLum2 / n) - meanLum255 * meanLum255));
    final blownRatio = blownWhite / n;

    // 1. Darkness check (except stool where pitch-black melena is clinically valid)
    if (category != CheckCategory.stool && meanLum < 0.14) {
      return (
        issue: ImageQualityIssue.tooDark,
        blurScore: 0.0,
        tenengradScore: 0.0,
        glareRatio: blownRatio,
        meanLuminance: meanLum,
      );
    }

    // 2. Severe overexposure / flash blowout (except bright eye sclera)
    if (category != CheckCategory.eye && meanLum > 0.96 && blownRatio > 0.75) {
      return (
        issue: ImageQualityIssue.overexposed,
        blurScore: 0.0,
        tenengradScore: 0.0,
        glareRatio: blownRatio,
        meanLuminance: meanLum,
      );
    }

    // 3. Dual-metric sharpness: 4-neighbor Laplacian variance + Sobel Tenengrad
    double lapSum = 0;
    double lapSum2 = 0;
    double tenengradSum = 0;
    int gradCount = 0;

    if (w >= 3 && h >= 3) {
      for (int y = 1; y < h - 1; y++) {
        for (int x = 1; x < w - 1; x++) {
          final c = gray[y * w + x];
          final lap = (4.0 * c) -
              gray[y * w + (x - 1)] -
              gray[y * w + (x + 1)] -
              gray[(y - 1) * w + x] -
              gray[(y + 1) * w + x];
          lapSum += lap;
          lapSum2 += lap * lap;

          final gx = -gray[(y - 1) * w + (x - 1)] +
              gray[(y - 1) * w + (x + 1)] -
              2.0 * gray[y * w + (x - 1)] +
              2.0 * gray[y * w + (x + 1)] -
              gray[(y + 1) * w + (x - 1)] +
              gray[(y + 1) * w + (x + 1)];
          final gy = -gray[(y - 1) * w + (x - 1)] -
              2.0 * gray[(y - 1) * w + x] -
              gray[(y - 1) * w + (x + 1)] +
              gray[(y + 1) * w + (x - 1)] +
              2.0 * gray[(y + 1) * w + x] +
              gray[(y + 1) * w + (x + 1)];
          tenengradSum += (gx * gx + gy * gy);
          gradCount++;
        }
      }
    }

    final safeGrad = math.max(1, gradCount);
    final lapMean = lapSum / safeGrad;
    final blurScore = math.max(0.0, (lapSum2 / safeGrad) - lapMean * lapMean);
    final tenengradScore = math.sqrt(tenengradSum / safeGrad);

    // Trigger blur gate only when a detail-sensitive category has visible
    // tonal contrast (edges exist) yet very low high-frequency sharpness.
    if (_requiresSharpTexture(category) &&
        lumStd >= 2.5 &&
        (blurScore < 18.0 || (blurScore < 28.0 && tenengradScore < 22.0))) {
      return (
        issue: ImageQualityIssue.tooBlurry,
        blurScore: blurScore,
        tenengradScore: tenengradScore,
        glareRatio: blownRatio,
        meanLuminance: meanLum,
      );
    }

    return (
      issue: ImageQualityIssue.none,
      blurScore: blurScore,
      tenengradScore: tenengradScore,
      glareRatio: blownRatio,
      meanLuminance: meanLum,
    );
  }

  /// Ultra-fast (< 2ms) real-time quality assessment directly on a camera
  /// preview Y-plane (YUV420 / BGRA luma bytes) for live capture guidance.
  static LiveCameraQuality assessLiveLuminancePlane({
    required Uint8List bytes,
    required int width,
    required int height,
    required int bytesPerRow,
    required int pixelStride,
    required CheckCategory category,
  }) {
    if (width < 24 || height < 24 || bytes.isEmpty) {
      return const LiveCameraQuality(
        lightingLevel: LiveQualityLevel.good,
        sharpnessLevel: LiveQualityLevel.good,
        glareLevel: LiveQualityLevel.good,
        meanLuminance: 0.5,
        tenengradScore: 60.0,
        blownRatio: 0.0,
      );
    }

    // Subsample central 50% ROI onto a compact 48x48 grid (< 2304 ops).
    const grid = 48;
    final startX = (width * 0.25).round();
    final startY = (height * 0.25).round();
    final roiW = math.max(1, (width * 0.50).round());
    final roiH = math.max(1, (height * 0.50).round());

    final gray = Float64List(grid * grid);
    double sumLum = 0;
    int blown = 0;

    for (int gy = 0; gy < grid; gy++) {
      final sy = (startY + (gy * roiH) ~/ grid).clamp(0, height - 1);
      final rowOffset = sy * bytesPerRow;
      for (int gx = 0; gx < grid; gx++) {
        final sx = (startX + (gx * roiW) ~/ grid).clamp(0, width - 1);
        final idx = rowOffset + sx * pixelStride;
        final yVal = idx < bytes.length ? bytes[idx].toDouble() : 128.0;
        gray[gy * grid + gx] = yVal;
        sumLum += yVal;
        if (yVal >= 248.0) blown++;
      }
    }

    const total = grid * grid;
    final meanLum = (sumLum / total) / 255.0;
    final blownRatio = blown / total;

    double tenSum = 0;
    int gradN = 0;
    for (int y = 1; y < grid - 1; y++) {
      for (int x = 1; x < grid - 1; x++) {
        final gx = -gray[(y - 1) * grid + (x - 1)] +
            gray[(y - 1) * grid + (x + 1)] -
            2.0 * gray[y * grid + (x - 1)] +
            2.0 * gray[y * grid + (x + 1)] -
            gray[(y + 1) * grid + (x - 1)] +
            gray[(y + 1) * grid + (x + 1)];
        final gy = -gray[(y - 1) * grid + (x - 1)] -
            2.0 * gray[(y - 1) * grid + x] -
            gray[(y - 1) * grid + (x + 1)] +
            gray[(y + 1) * grid + (x - 1)] +
            2.0 * gray[(y + 1) * grid + x] +
            gray[(y + 1) * grid + (x + 1)];
        tenSum += gx * gx + gy * gy;
        gradN++;
      }
    }
    final tenengrad = gradN > 0 ? math.sqrt(tenSum / gradN) : 0.0;

    final lightingLevel = category == CheckCategory.stool
        ? (meanLum > 0.92 ? LiveQualityLevel.poor : LiveQualityLevel.good)
        : meanLum < 0.18 || meanLum > 0.92
            ? LiveQualityLevel.poor
            : (meanLum < 0.28 || meanLum > 0.85)
                ? LiveQualityLevel.caution
                : LiveQualityLevel.good;

    final sharpnessLevel = !_requiresSharpTexture(category)
        ? LiveQualityLevel.good
        : tenengrad < 22.0
            ? LiveQualityLevel.poor
            : tenengrad < 40.0
                ? LiveQualityLevel.caution
                : LiveQualityLevel.good;

    final glareLevel = category == CheckCategory.eye
        ? (blownRatio > 0.45 ? LiveQualityLevel.caution : LiveQualityLevel.good)
        : blownRatio > 0.25
            ? LiveQualityLevel.poor
            : blownRatio > 0.10
                ? LiveQualityLevel.caution
                : LiveQualityLevel.good;

    return LiveCameraQuality(
      lightingLevel: lightingLevel,
      sharpnessLevel: sharpnessLevel,
      glareLevel: glareLevel,
      meanLuminance: meanLum,
      tenengradScore: tenengrad,
      blownRatio: blownRatio,
    );
  }

  /// Fast deterministic 64-bit FNV-1a fingerprint scoped to category & options.
  static String computeFingerprint({
    required Uint8List bytes,
    required CheckCategory category,
    required bool useWhiteReference,
  }) {
    var hash = 0xcbf29ce484222325;
    const prime = 0x100000001b3;
    const mask = 0x7fffffffffffffff;

    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * prime) & mask;
    }

    return '${category.id}_${useWhiteReference ? 'wb1' : 'wb0'}_${bytes.length}_${hash.toRadixString(16)}';
  }
}
