import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

enum ImageQualityIssue {
  none,
  tooDark,
  overexposed,
  tooBlurry,
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
  });

  /// Cropped, resized, JPEG-compressed bytes optimized for low Vision AI token
  /// usage and fast mobile upload.
  final Uint8List jpegBytes;
  final int width;
  final int height;
  final ImageQualityIssue qualityIssue;

  /// Variance of Laplacian in the central ROI (higher = sharper).
  final double blurScore;
  final double meanLuminance;

  /// Deterministic content hash for 0-token duplicate-image caching.
  final String contentFingerprint;

  bool get passesQualityGate => qualityIssue == ImageQualityIssue.none;
}

/// 0-token on-device image quality gate and compression pipeline run before any
/// Vision AI request.
///
/// 1. Rejects overly dark, blown-out, or visibly out-of-focus captures locally
///    so no API tokens are wasted on unusable photos.
/// 2. Crops to the central 70% x 70% frame (keeping lesion + surrounding ring)
///    and downscales to 512px (color-primary modules) or 768px (skin/nail
///    morphology modules) at JPEG quality 80.
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
    int jpegQuality = 80,
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
      meanLuminance: quality.meanLuminance,
      contentFingerprint: fingerprint,
    );
  }

  static ({
    ImageQualityIssue issue,
    double blurScore,
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
        meanLuminance: meanLum,
      );
    }

    // 2. Severe overexposure / flash blowout (except bright eye sclera)
    if (category != CheckCategory.eye && meanLum > 0.96 && blownRatio > 0.75) {
      return (
        issue: ImageQualityIssue.overexposed,
        blurScore: 0.0,
        meanLuminance: meanLum,
      );
    }

    // 3. Variance of discrete 4-neighbor Laplacian for focus sharpness
    double lapSum = 0;
    double lapSum2 = 0;
    int lapCount = 0;

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
          lapCount++;
        }
      }
    }

    final safeLap = math.max(1, lapCount);
    final lapMean = lapSum / safeLap;
    final blurScore = math.max(0.0, (lapSum2 / safeLap) - lapMean * lapMean);

    // Trigger blur gate only when a detail-sensitive category has visible
    // tonal contrast (edges exist) yet very low high-frequency sharpness.
    if (_requiresSharpTexture(category) && lumStd >= 2.5 && blurScore < 18.0) {
      return (
        issue: ImageQualityIssue.tooBlurry,
        blurScore: blurScore,
        meanLuminance: meanLum,
      );
    }

    return (
      issue: ImageQualityIssue.none,
      blurScore: blurScore,
      meanLuminance: meanLum,
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
