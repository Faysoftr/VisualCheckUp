import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Objective constitutive skin-tone categories derived from CIE L*a*b*
/// Individual Typology Angle (Chardon / Del Bino ISO-24444 standard):
/// `ITA° = atan((L* - 50) / b*) * (180 / π)`.
enum FitzpatrickPhototype {
  veryLight, // > 55° (Type I)
  light, // 41° .. 55° (Type II)
  intermediate, // 28° .. 41° (Type III)
  tan, // 10° .. 28° (Type IV)
  brown, // -30° .. 10° (Type V)
  dark, // < -30° (Type VI)
}

extension FitzpatrickPhototypeX on FitzpatrickPhototype {
  String get shortLabel {
    switch (this) {
      case FitzpatrickPhototype.veryLight:
        return 'Tip I (Çok Açık)';
      case FitzpatrickPhototype.light:
        return 'Tip II (Açık)';
      case FitzpatrickPhototype.intermediate:
        return 'Tip III (Buğday)';
      case FitzpatrickPhototype.tan:
        return 'Tip IV (Esmer)';
      case FitzpatrickPhototype.brown:
        return 'Tip V (Koyu Esmer)';
      case FitzpatrickPhototype.dark:
        return 'Tip VI (Çok Koyu)';
    }
  }

  /// Whether darker constitutive melanin requires relative contrast checks
  /// rather than absolute low-luminance / high-b* thresholds.
  bool get isDarkerSkinOfColor =>
      this == FitzpatrickPhototype.tan ||
      this == FitzpatrickPhototype.brown ||
      this == FitzpatrickPhototype.dark;
}

/// Perceptual CIE L*a*b* color (D65 reference white).
///
/// Separates lightness (L*) from chromaticity (a*: green-to-red,
/// b*: blue-to-yellow), making jaundice/redness/cyanosis cues far more stable
/// across exposure variations than raw RGB/HSV.
class LabColor {
  const LabColor({
    required this.l,
    required this.a,
    required this.b,
  });

  final double l; // 0..100
  final double a; // ~ -128..127 (green < 0 < red)
  final double b; // ~ -128..127 (blue < 0 < yellow)

  factory LabColor.fromColor(Color color) {
    return LabColor.fromRgb(
      (color.r * 255).round().clamp(0, 255),
      (color.g * 255).round().clamp(0, 255),
      (color.b * 255).round().clamp(0, 255),
    );
  }

  factory LabColor.fromRgb(int r, int g, int b) {
    final sr = _linearize(r / 255.0);
    final sg = _linearize(g / 255.0);
    final sb = _linearize(b / 255.0);

    // sRGB -> XYZ (D65)
    final x = (sr * 0.4124564 + sg * 0.3575761 + sb * 0.1804375) / 0.95047;
    final y = (sr * 0.2126729 + sg * 0.7151522 + sb * 0.0721750) / 1.00000;
    final z = (sr * 0.0193339 + sg * 0.1191920 + sb * 0.9503041) / 1.08883;

    final fx = _labF(x);
    final fy = _labF(y);
    final fz = _labF(z);

    return LabColor(
      l: (116.0 * fy) - 16.0,
      a: 500.0 * (fx - fy),
      b: 200.0 * (fy - fz),
    );
  }

  /// Perceptual chroma C* = sqrt(a*^2 + b*^2).
  double get chroma => math.sqrt(a * a + b * b);

  /// Individual Typology Angle (ITA°) in degrees for objective skin-tone
  /// quantification (Chardon et al., ISO 24444).
  double get individualTypologyAngle {
    final safeB = b.abs() < 0.5 ? (b >= 0 ? 0.5 : -0.5) : b;
    return math.atan((l - 50.0) / safeB) * (180.0 / math.pi);
  }

  /// Maps [individualTypologyAngle] to standard 6-tier skin phototype.
  FitzpatrickPhototype get fitzpatrickPhototype {
    final ita = individualTypologyAngle;
    if (ita > 55.0) return FitzpatrickPhototype.veryLight;
    if (ita > 41.0) return FitzpatrickPhototype.light;
    if (ita > 28.0) return FitzpatrickPhototype.intermediate;
    if (ita > 10.0) return FitzpatrickPhototype.tan;
    if (ita > -30.0) return FitzpatrickPhototype.brown;
    return FitzpatrickPhototype.dark;
  }

  /// CIE76 perceptual color distance.
  double deltaE(LabColor other) {
    final dl = l - other.l;
    final da = a - other.a;
    final db = b - other.b;
    return math.sqrt(dl * dl + da * da + db * db);
  }

  static double _linearize(double channel) {
    if (channel <= 0.04045) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _labF(double t) {
    const epsilon = 0.008856;
    const kappa = 903.3;
    if (t > epsilon) {
      return math.pow(t, 1.0 / 3.0).toDouble();
    }
    return (kappa * t + 16.0) / 116.0;
  }
}

enum LightingCast {
  neutral,
  warmYellow,
  coolBlue,
  tooDark,
}

class WhiteBalanceGains {
  const WhiteBalanceGains({
    required this.rGain,
    required this.gGain,
    required this.bGain,
    required this.referenceColor,
  });

  final double rGain;
  final double gGain;
  final double bGain;
  final Color referenceColor;

  /// Applies Von Kries per-channel scaling to an RGB triplet.
  (int, int, int) applyToRgb(int r, int g, int b) {
    final nr = (r * rGain).round().clamp(0, 255);
    final ng = (g * gGain).round().clamp(0, 255);
    final nb = (b * bGain).round().clamp(0, 255);
    return (nr, ng, nb);
  }

  Color applyToColor(Color color) {
    final (nr, ng, nb) = applyToRgb(
      (color.r * 255).round().clamp(0, 255),
      (color.g * 255).round().clamp(0, 255),
      (color.b * 255).round().clamp(0, 255),
    );
    return Color.fromARGB(255, nr, ng, nb);
  }
}

class CalibratedSample {
  const CalibratedSample({
    required this.rawColor,
    required this.calibratedColor,
    required this.lab,
    required this.lightingCast,
    required this.whiteBalanceApplied,
    required this.glareFilteredRatio,
    this.whiteRefColor,
    this.gains,
    this.lightingNote,
  });

  final Color rawColor;
  final Color calibratedColor;
  final LabColor lab;
  final LightingCast lightingCast;
  final bool whiteBalanceApplied;
  final double glareFilteredRatio;
  final Color? whiteRefColor;
  final WhiteBalanceGains? gains;
  final String? lightingNote;
}

class NormalizedBox {
  const NormalizedBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// On-device color normalization and glare/shadow filtering utilities.
class ColorCalibrator {
  ColorCalibrator._();

  /// Central target sampling frame (matching the main reticle).
  static const NormalizedBox mainTargetBox = NormalizedBox(
    left: 0.30,
    top: 0.30,
    right: 0.70,
    bottom: 0.70,
  );

  /// Secondary white reference box directly below the main reticle.
  static const NormalizedBox whiteReferenceBox = NormalizedBox(
    left: 0.35,
    top: 0.74,
    right: 0.65,
    bottom: 0.88,
  );

  /// Samples the target ROI with trimmed-median glare/shadow rejection and
  /// optional Von Kries white-balance calibration from [whiteReferenceBox].
  static CalibratedSample sampleImage({
    required img.Image image,
    NormalizedBox targetBox = mainTargetBox,
    bool useWhiteReference = false,
    NormalizedBox whiteBox = whiteReferenceBox,
  }) {
    final targetStats = _sampleTrimmedBox(image, targetBox);
    final rawColor = targetStats.color;

    WhiteBalanceGains? gains;
    Color? whiteRefColor;
    var whiteBalanceApplied = false;
    LightingCast lightingCast = LightingCast.neutral;
    String? lightingNote;

    if (useWhiteReference) {
      final refStats = _sampleTrimmedBox(image, whiteBox);
      whiteRefColor = refStats.color;
      lightingCast = _detectCastFromWhiteRgb(
        refStats.r,
        refStats.g,
        refStats.b,
      );
      gains = computeWhiteBalanceGains(refStats.r, refStats.g, refStats.b);
      if (gains != null) {
        whiteBalanceApplied = true;
        lightingNote = switch (lightingCast) {
          LightingCast.warmYellow =>
            'Sarı ortam ışığı algılandı ve beyaz referans ile dengelendi.',
          LightingCast.coolBlue =>
            'Soğuk/mavi ortam ışığı algılandı ve beyaz referans ile dengelendi.',
          LightingCast.neutral =>
            'Beyaz referans ile renk dengesi kalibre edildi.',
          LightingCast.tooDark =>
            'Beyaz referans alanı karanlık; kalibrasyon sınırlı uygulandı.',
        };
      } else {
        lightingNote =
            'Beyaz referans kutusu yeterince beyaz veya aydınlık değildi; ham görüntü kullanıldı.';
      }
    } else {
      // Estimate ambient lighting cast from brightest 10% pixels across frame.
      final bright = _sampleBrightestHighlights(image);
      lightingCast = _detectCastFromWhiteRgb(bright.$1, bright.$2, bright.$3);
      if (lightingCast == LightingCast.warmYellow) {
        lightingNote =
            'Sıcak (sarı) ortam ışığı algılandı; renk tonu olduğundan daha sarı görünebilir.';
      } else if (lightingCast == LightingCast.coolBlue) {
        lightingNote =
            'Soğuk (mavi) ortam ışığı algılandı; renk tonu olduğundan daha soğuk/morumsu görünebilir.';
      }
    }

    final calibratedColor =
        gains != null ? gains.applyToColor(rawColor) : rawColor;
    final lab = LabColor.fromColor(calibratedColor);

    return CalibratedSample(
      rawColor: rawColor,
      calibratedColor: calibratedColor,
      lab: lab,
      lightingCast: lightingCast,
      whiteBalanceApplied: whiteBalanceApplied,
      glareFilteredRatio: targetStats.glareRatio,
      whiteRefColor: whiteRefColor,
      gains: gains,
      lightingNote: lightingNote,
    );
  }

  /// Computes Von Kries channel gains from a sampled white-reference RGB.
  ///
  /// Returns `null` if the reference region is too dark or too saturated to be
  /// a valid white/neutral surface, protecting against calibration distortion.
  static WhiteBalanceGains? computeWhiteBalanceGains(int rw, int gw, int bw) {
    final maxC = math.max(rw, math.max(gw, bw));
    final minC = math.min(rw, math.min(gw, bw));

    // Must be reasonably bright (not a dark shadow)
    if (maxC < 105) return null;

    // Must not be an intensely saturated non-white object (e.g. red cloth)
    final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
    if (saturation > 0.45) return null;

    // Normalize toward neutral target preserving overall luminance cleanly.
    final target = ((rw + gw + bw) / 3.0).clamp(180.0, 245.0);
    final rGain = (target / math.max(1, rw)).clamp(0.55, 1.85);
    final gGain = (target / math.max(1, gw)).clamp(0.55, 1.85);
    final bGain = (target / math.max(1, bw)).clamp(0.55, 1.85);

    return WhiteBalanceGains(
      rGain: rGain,
      gGain: gGain,
      bGain: bGain,
      referenceColor: Color.fromARGB(255, rw, gw, bw),
    );
  }

  static LightingCast _detectCastFromWhiteRgb(int r, int g, int b) {
    final maxC = math.max(r, math.max(g, b));
    if (maxC < 65) return LightingCast.tooDark;

    final safeB = math.max(1, b);
    final safeR = math.max(1, r);

    // Warm incandescent / yellow bulb strongly boosts R relative to B
    if (r / safeB >= 1.22 && r > g * 1.04) {
      return LightingCast.warmYellow;
    }
    // Cool bluish LED / shade boosts B relative to R
    if (b / safeR >= 1.18 && b > g * 1.03) {
      return LightingCast.coolBlue;
    }
    return LightingCast.neutral;
  }

  /// Samples pixels in [box], removes specular glare & darkest 15% shadows,
  /// and returns the interquartile mean RGB.
  static ({int r, int g, int b, Color color, double glareRatio})
      _sampleTrimmedBox(img.Image image, NormalizedBox box) {
    final startX = (image.width * box.left).round().clamp(0, image.width - 1);
    final endX =
        (image.width * box.right).round().clamp(startX + 1, image.width);
    final startY = (image.height * box.top).round().clamp(0, image.height - 1);
    final endY =
        (image.height * box.bottom).round().clamp(startY + 1, image.height);

    final stepX = math.max(1, ((endX - startX) / 36).round());
    final stepY = math.max(1, ((endY - startY) / 36).round());

    final samples = <({int r, int g, int b, double lum})>[];
    int specularCount = 0;

    for (int y = startY; y < endY; y += stepY) {
      for (int x = startX; x < endX; x += stepX) {
        final p = image.getPixel(x, y);
        final r = p.r.round().clamp(0, 255);
        final g = p.g.round().clamp(0, 255);
        final b = p.b.round().clamp(0, 255);
        final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        if (r >= 250 && g >= 250 && b >= 250) {
          specularCount++;
        }
        samples.add((r: r, g: g, b: b, lum: lum));
      }
    }

    if (samples.isEmpty) {
      return (r: 0, g: 0, b: 0, color: Colors.black, glareRatio: 0.0);
    }

    final totalCount = samples.length;
    final glareRatio = specularCount / totalCount;

    // Sort by luminance and trim bottom 15% (shadows) & top 15% (glare).
    samples.sort((a, b) => a.lum.compareTo(b.lum));
    final trim = (samples.length * 0.15).floor();
    final low = trim;
    final high = math.max(low + 1, samples.length - trim);

    double sumR = 0, sumG = 0, sumB = 0;
    final used = high - low;
    for (int i = low; i < high; i++) {
      sumR += samples[i].r;
      sumG += samples[i].g;
      sumB += samples[i].b;
    }

    final avgR = (sumR / used).round().clamp(0, 255);
    final avgG = (sumG / used).round().clamp(0, 255);
    final avgB = (sumB / used).round().clamp(0, 255);

    return (
      r: avgR,
      g: avgG,
      b: avgB,
      color: Color.fromARGB(255, avgR, avgG, avgB),
      glareRatio: glareRatio,
    );
  }

  /// Estimates the illuminant color from the top ~10% brightest non-clipped
  /// pixels across the full frame (classic Gray-World / Max-RGB hybrid).
  static (int, int, int) _sampleBrightestHighlights(img.Image image) {
    final stepX = math.max(1, (image.width / 32).round());
    final stepY = math.max(1, (image.height / 32).round());
    final pixels = <({int r, int g, int b, double lum})>[];

    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final p = image.getPixel(x, y);
        final r = p.r.round().clamp(0, 255);
        final g = p.g.round().clamp(0, 255);
        final b = p.b.round().clamp(0, 255);
        // Skip hard-clipped pure white where cast information is lost
        if (r >= 253 && g >= 253 && b >= 253) continue;
        final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        pixels.add((r: r, g: g, b: b, lum: lum));
      }
    }

    if (pixels.isEmpty) return (245, 245, 245);
    pixels.sort((a, b) => b.lum.compareTo(a.lum));
    final take = math.max(1, (pixels.length * 0.10).ceil());

    double sumR = 0, sumG = 0, sumB = 0;
    for (int i = 0; i < take; i++) {
      sumR += pixels[i].r;
      sumG += pixels[i].g;
      sumB += pixels[i].b;
    }
    return (
      (sumR / take).round().clamp(0, 255),
      (sumG / take).round().clamp(0, 255),
      (sumB / take).round().clamp(0, 255),
    );
  }

  /// Collings / Mannino Erythema Index (EI):
  /// `EI = 100 * (log10(max(1, R)) - log10(max(1, G)))`.
  ///
  /// Because it is a log-ratio of red-to-green reflectance, EI is robust to
  /// overall brightness shifts and strongly correlates with mucosal/nailbed
  /// hemoglobin concentration (anemia pallor screening) and skin erythema.
  static double erythemaIndex(int r, int g) {
    final safeR = math.max(1, r).toDouble();
    final safeG = math.max(1, g).toDouble();
    return 100.0 * ((math.log(safeR) - math.log(safeG)) / math.ln10);
  }

  /// Melanin Index (MI): `100 * log10(255 / max(1, R))`.
  static double melaninIndex(int r) {
    final safeR = math.max(1, r).toDouble();
    return 100.0 * ((math.log(255.0) - math.log(safeR)) / math.ln10);
  }

  /// Applies Von Kries [gains] to every pixel of [roi] (typically a small
  /// resized 96x96 ROI) so downstream 2D structural detectors run on
  /// white-balance-calibrated pixels.
  static img.Image applyGainsToImage(img.Image roi, WhiteBalanceGains gains) {
    final out = img.Image(width: roi.width, height: roi.height);
    for (int y = 0; y < roi.height; y++) {
      for (int x = 0; x < roi.width; x++) {
        final p = roi.getPixel(x, y);
        final (nr, ng, nb) = gains.applyToRgb(
          p.r.round().clamp(0, 255),
          p.g.round().clamp(0, 255),
          p.b.round().clamp(0, 255),
        );
        out.setPixelRgb(x, y, nr, ng, nb);
      }
    }
    return out;
  }
}
