import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

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
    final sr = linearizeChannel(r / 255.0);
    final sg = linearizeChannel(g / 255.0);
    final sb = linearizeChannel(b / 255.0);

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

  /// ISO/CIE CIEDE2000 (ΔE00) perceptual color difference (Sharma, Wu, Dalal).
  ///
  /// Far more accurate than CIE76 Euclidean distance in yellow (jaundice/urine),
  /// pink/red mucosa (anemia/erythema), and darker skin phototypes.
  double deltaE2000(LabColor other) {
    final c1 = chroma;
    final c2 = other.chroma;
    final cBar = 0.5 * (c1 + c2);
    final cBar7 = math.pow(cBar, 7).toDouble();
    const pow25To7 = 6103515625.0; // 25^7
    final g = 0.5 * (1.0 - math.sqrt(cBar7 / (cBar7 + pow25To7)));

    final a1Prime = (1.0 + g) * a;
    final a2Prime = (1.0 + g) * other.a;
    final c1Prime = math.sqrt(a1Prime * a1Prime + b * b);
    final c2Prime = math.sqrt(a2Prime * a2Prime + other.b * other.b);

    double hueAngleDeg(double ap, double bp) {
      if (ap == 0.0 && bp == 0.0) return 0.0;
      var deg = math.atan2(bp, ap) * (180.0 / math.pi);
      if (deg < 0) deg += 360.0;
      return deg;
    }

    final h1Prime = hueAngleDeg(a1Prime, b);
    final h2Prime = hueAngleDeg(a2Prime, other.b);

    final dLPrime = other.l - l;
    final dCPrime = c2Prime - c1Prime;

    double dhPrime;
    if (c1Prime * c2Prime == 0.0) {
      dhPrime = 0.0;
    } else {
      final diff = h2Prime - h1Prime;
      if (diff.abs() <= 180.0) {
        dhPrime = diff;
      } else if (diff > 180.0) {
        dhPrime = diff - 360.0;
      } else {
        dhPrime = diff + 360.0;
      }
    }

    final dHPrime =
        2.0 * math.sqrt(c1Prime * c2Prime) * math.sin((dhPrime * 0.5) * math.pi / 180.0);

    final lBarPrime = 0.5 * (l + other.l);
    final cBarPrime = 0.5 * (c1Prime + c2Prime);

    double hBarPrime;
    if (c1Prime * c2Prime == 0.0) {
      hBarPrime = h1Prime + h2Prime;
    } else if ((h1Prime - h2Prime).abs() <= 180.0) {
      hBarPrime = 0.5 * (h1Prime + h2Prime);
    } else if (h1Prime + h2Prime < 360.0) {
      hBarPrime = 0.5 * (h1Prime + h2Prime + 360.0);
    } else {
      hBarPrime = 0.5 * (h1Prime + h2Prime - 360.0);
    }

    const degToRad = math.pi / 180.0;
    final t = 1.0 -
        0.17 * math.cos((hBarPrime - 30.0) * degToRad) +
        0.24 * math.cos((2.0 * hBarPrime) * degToRad) +
        0.32 * math.cos((3.0 * hBarPrime + 6.0) * degToRad) -
        0.20 * math.cos((4.0 * hBarPrime - 63.0) * degToRad);

    final deltaTheta =
        30.0 * math.exp(-math.pow((hBarPrime - 275.0) / 25.0, 2));
    final cBarPrime7 = math.pow(cBarPrime, 7).toDouble();
    final rc = 2.0 * math.sqrt(cBarPrime7 / (cBarPrime7 + pow25To7));

    final lBarMinus50Sq = (lBarPrime - 50.0) * (lBarPrime - 50.0);
    final sl = 1.0 + (0.015 * lBarMinus50Sq) / math.sqrt(20.0 + lBarMinus50Sq);
    final sc = 1.0 + 0.045 * cBarPrime;
    final sh = 1.0 + 0.015 * cBarPrime * t;
    final rt = -math.sin(2.0 * deltaTheta * degToRad) * rc;

    final dlTerm = dLPrime / sl;
    final dcTerm = dCPrime / sc;
    final dhTerm = dHPrime / sh;

    final val =
        dlTerm * dlTerm + dcTerm * dcTerm + dhTerm * dhTerm + rt * dcTerm * dhTerm;
    return math.sqrt(math.max(0.0, val));
  }

  /// sRGB [0..1] -> Linear RGB [0..1] (IEC 61966-2-1).
  static double linearizeChannel(double channel) {
    final c = channel.clamp(0.0, 1.0);
    if (c <= 0.04045) {
      return c / 12.92;
    }
    return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Linear RGB [0..1] -> sRGB [0..1] (IEC 61966-2-1).
  static double delinearizeChannel(double linear) {
    final l = linear.clamp(0.0, 1.0);
    if (l <= 0.0031308) {
      return 12.92 * l;
    }
    return (1.055 * math.pow(l, 1.0 / 2.4).toDouble()) - 0.055;
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
    this.isLinearSpace = true,
  });

  final double rGain;
  final double gGain;
  final double bGain;
  final Color referenceColor;
  final bool isLinearSpace;

  /// Applies Von Kries chromatic adaptation per-channel scaling.
  ///
  /// When [isLinearSpace] is true, sRGB is linearized first so multiplicative
  /// illuminant correction operates in physically linear light space without
  /// gamma-induced hue drift.
  (int, int, int) applyToRgb(int r, int g, int b) {
    if (!isLinearSpace) {
      final nr = (r * rGain).round().clamp(0, 255);
      final ng = (g * gGain).round().clamp(0, 255);
      final nb = (b * bGain).round().clamp(0, 255);
      return (nr, ng, nb);
    }
    final lr = LabColor.linearizeChannel(r / 255.0) * rGain;
    final lg = LabColor.linearizeChannel(g / 255.0) * gGain;
    final lb = LabColor.linearizeChannel(b / 255.0) * bGain;
    final nr = (LabColor.delinearizeChannel(lr) * 255.0).round().clamp(0, 255);
    final ng = (LabColor.delinearizeChannel(lg) * 255.0).round().clamp(0, 255);
    final nb = (LabColor.delinearizeChannel(lb) * 255.0).round().clamp(0, 255);
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
    this.autoColorConstancyApplied = false,
    this.whiteRefColor,
    this.gains,
    this.lightingNote,
  });

  final Color rawColor;
  final Color calibratedColor;
  final LabColor lab;
  final LightingCast lightingCast;
  final bool whiteBalanceApplied;
  final bool autoColorConstancyApplied;
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

/// On-device color normalization, Shades-of-Gray automatic color constancy,
/// perceptual specular glare rejection, and module-aware foreground sampling.
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

  /// Detects hard-clipped white or glossy mirror specular highlight glints
  /// (`R,G,B >= 248` or `maxC >= 244 && sat <= 0.06`) that distort wet mucosa
  /// (tongue), glossy nail plates, oily skin, and liquid cups — while
  /// preserving matte white biological tissues (geographic-tongue rims,
  /// pale anemic nailbeds, white thrush plaques, and eye sclera).
  static bool isSpecularGlare(
    int r,
    int g,
    int b, {
    bool allowBrightWhite = false,
  }) {
    if (r >= 248 && g >= 248 && b >= 248) return true;
    if (allowBrightWhite) return false;
    final maxC = math.max(r, math.max(g, b));
    if (maxC < 244) return false;
    final minC = math.min(r, math.min(g, b));
    final sat = maxC > 0 ? (maxC - minC) / maxC : 0.0;
    return sat <= 0.06;
  }

  /// Samples the target ROI with trimmed-median glare/shadow rejection,
  /// optional module-aware foreground gating ([category]), explicit Von Kries
  /// white-reference calibration ([useWhiteReference]), or automatic
  /// Shades-of-Gray (p=6) color constancy when scene diversity is sufficient.
  static CalibratedSample sampleImage({
    required img.Image image,
    NormalizedBox targetBox = mainTargetBox,
    bool useWhiteReference = false,
    NormalizedBox whiteBox = whiteReferenceBox,
    CheckCategory? category,
    bool enableAutoColorConstancy = true,
  }) {
    final targetStats = _sampleTrimmedBox(
      image,
      targetBox,
      category: category,
    );
    final rawColor = targetStats.color;

    WhiteBalanceGains? gains;
    Color? whiteRefColor;
    var whiteBalanceApplied = false;
    var autoColorConstancyApplied = false;
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

      // Apply bounded Shades-of-Gray (Minkowski p=6) automatic color constancy
      // ONLY on multi-tonal non-skin-closeup scenes so skin-filled frames
      // (already illumination-normalized via lesion-vs-ring differential) and
      // uniform pathology close-ups are never color-shifted into gray.
      final allowAutoForCategory = category != CheckCategory.skinCondition;
      if (enableAutoColorConstancy &&
          allowAutoForCategory &&
          (lightingCast == LightingCast.warmYellow ||
              lightingCast == LightingCast.coolBlue)) {
        final autoGains = estimateShadesOfGrayGains(image);
        if (autoGains != null) {
          gains = autoGains;
          autoColorConstancyApplied = true;
        }
      }

      if (lightingCast == LightingCast.warmYellow) {
        lightingNote = autoColorConstancyApplied
            ? 'Sıcak (sarı) ortam ışığı algılandı; Shades-of-Gray otomatik renk sabitliği uygulandı.'
            : 'Sıcak (sarı) ortam ışığı algılandı; renk tonu olduğundan daha sarı görünebilir.';
      } else if (lightingCast == LightingCast.coolBlue) {
        lightingNote = autoColorConstancyApplied
            ? 'Soğuk (mavi) ortam ışığı algılandı; Shades-of-Gray otomatik renk sabitliği uygulandı.'
            : 'Soğuk (mavi) ortam ışığı algılandı; renk tonu olduğundan daha soğuk/morumsu görünebilir.';
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
      autoColorConstancyApplied: autoColorConstancyApplied,
      glareFilteredRatio: targetStats.glareRatio,
      whiteRefColor: whiteRefColor,
      gains: gains,
      lightingNote: lightingNote,
    );
  }

  /// Computes linear-space Von Kries channel gains from a sampled
  /// white-reference RGB.
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

    final lr = math.max(0.01, LabColor.linearizeChannel(rw / 255.0));
    final lg = math.max(0.01, LabColor.linearizeChannel(gw / 255.0));
    final lb = math.max(0.01, LabColor.linearizeChannel(bw / 255.0));

    // Preserve neutral luminance while balancing RGB channels in linear light.
    final targetLinear = ((lr + lg + lb) / 3.0).clamp(0.45, 0.90);
    final rGain = (targetLinear / lr).clamp(0.45, 2.25);
    final gGain = (targetLinear / lg).clamp(0.45, 2.25);
    final bGain = (targetLinear / lb).clamp(0.45, 2.25);

    return WhiteBalanceGains(
      rGain: rGain,
      gGain: gGain,
      bGain: bGain,
      referenceColor: Color.fromARGB(255, rw, gw, bw),
      isLinearSpace: true,
    );
  }

  /// Finlayson & Trezzi "Shades of Gray" automatic illuminant estimation
  /// (Minkowski norm `p = 6` in linear RGB).
  ///
  /// Clinical safety guard: requires real multi-tonal scene diversity
  /// (`lumStd >= 18` and distinct luminance range >= 55) so single-color close-up
  /// pathology photos (e.g. yellow sclera or pale nail) are never over-corrected.
  static WhiteBalanceGains? estimateShadesOfGrayGains(
    img.Image image, {
    double p = 6.0,
    double strength = 0.72,
  }) {
    if (image.width < 16 || image.height < 16) return null;
    final stepX = math.max(1, (image.width / 36).round());
    final stepY = math.max(1, (image.height / 36).round());

    double sumRp = 0, sumGp = 0, sumBp = 0;
    double sumLum = 0, sumLum2 = 0;
    double minLum = 255, maxLum = 0;
    int count = 0;

    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final px = image.getPixel(x, y);
        final r = px.r.round().clamp(0, 255);
        final g = px.g.round().clamp(0, 255);
        final b = px.b.round().clamp(0, 255);
        // Ignore pure clipped white and deep black sensor noise
        if ((r >= 252 && g >= 252 && b >= 252) ||
            (r <= 8 && g <= 8 && b <= 8)) {
          continue;
        }
        final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        sumLum += lum;
        sumLum2 += lum * lum;
        if (lum < minLum) minLum = lum;
        if (lum > maxLum) maxLum = lum;

        final lr = LabColor.linearizeChannel(r / 255.0);
        final lg = LabColor.linearizeChannel(g / 255.0);
        final lb = LabColor.linearizeChannel(b / 255.0);
        sumRp += math.pow(lr, p).toDouble();
        sumGp += math.pow(lg, p).toDouble();
        sumBp += math.pow(lb, p).toDouble();
        count++;
      }
    }

    if (count < 24) return null;
    final meanLum = sumLum / count;
    final lumStd = math.sqrt(math.max(0.0, (sumLum2 / count) - meanLum * meanLum));
    if (lumStd < 18.0 || (maxLum - minLum) < 55.0) {
      // Scene is too uniform — unsafe to assume illuminant vs. true tissue tint.
      return null;
    }

    final invP = 1.0 / p;
    final er = math.pow(sumRp / count, invP).toDouble();
    final eg = math.pow(sumGp / count, invP).toDouble();
    final eb = math.pow(sumBp / count, invP).toDouble();
    final eMean = (er + eg + eb) / 3.0;
    if (eMean < 0.04) return null;

    // Blend gently toward neutral illuminant using [strength] and safe clamps.
    final rawR = eMean / math.max(0.01, er);
    final rawG = eMean / math.max(0.01, eg);
    final rawB = eMean / math.max(0.01, eb);
    final rGain = (1.0 + (rawR - 1.0) * strength).clamp(0.72, 1.55);
    final gGain = (1.0 + (rawG - 1.0) * strength).clamp(0.78, 1.35);
    final bGain = (1.0 + (rawB - 1.0) * strength).clamp(0.72, 1.65);

    // Skip trivial no-op corrections (< 4% deviation).
    if ((rGain - 1.0).abs() < 0.04 &&
        (gGain - 1.0).abs() < 0.04 &&
        (bGain - 1.0).abs() < 0.04) {
      return null;
    }

    final estR = (LabColor.delinearizeChannel(er) * 255.0).round().clamp(0, 255);
    final estG = (LabColor.delinearizeChannel(eg) * 255.0).round().clamp(0, 255);
    final estB = (LabColor.delinearizeChannel(eb) * 255.0).round().clamp(0, 255);

    return WhiteBalanceGains(
      rGain: rGain,
      gGain: gGain,
      bGain: bGain,
      referenceColor: Color.fromARGB(255, estR, estG, estB),
      isLinearSpace: true,
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

  /// Samples pixels in [box], removes perceptual specular glare & darkest 15%
  /// shadows, optionally applies anatomical foreground gating for [category],
  /// and returns the interquartile mean RGB.
  static ({int r, int g, int b, Color color, double glareRatio})
      _sampleTrimmedBox(
    img.Image image,
    NormalizedBox box, {
    CheckCategory? category,
  }) {
    final startX = (image.width * box.left).round().clamp(0, image.width - 1);
    final endX =
        (image.width * box.right).round().clamp(startX + 1, image.width);
    final startY = (image.height * box.top).round().clamp(0, image.height - 1);
    final endY =
        (image.height * box.bottom).round().clamp(startY + 1, image.height);

    final stepX = math.max(1, ((endX - startX) / 36).round());
    final stepY = math.max(1, ((endY - startY) / 36).round());

    final allSamples = <({int r, int g, int b, double lum})>[];
    final foregroundSamples = <({int r, int g, int b, double lum})>[];
    int specularCount = 0;

    final allowBrightWhite =
        category == null || category == CheckCategory.eye;

    for (int y = startY; y < endY; y += stepY) {
      for (int x = startX; x < endX; x += stepX) {
        final p = image.getPixel(x, y);
        final r = p.r.round().clamp(0, 255);
        final g = p.g.round().clamp(0, 255);
        final b = p.b.round().clamp(0, 255);
        final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        final isGlare = isSpecularGlare(
          r,
          g,
          b,
          allowBrightWhite: allowBrightWhite,
        );
        if (isGlare) {
          specularCount++;
        }
        final entry = (r: r, g: g, b: b, lum: lum);
        allSamples.add(entry);

        if (category != null && !isGlare) {
          final keep = switch (category) {
            // Exclude dark pupil/iris/eyelashes so sclera color stays pure
            CheckCategory.eye => lum >= 78.0,
            // Exclude dark oral cavity shadow so tongue mucosa/coating dominates
            CheckCategory.tongue => lum >= 46.0,
            // Exclude dark background gap around nail plate
            CheckCategory.nail => lum >= 44.0,
            // Exclude dark cup rims/shadows
            CheckCategory.urine => lum >= 36.0,
            _ => true,
          };
          if (keep) {
            foregroundSamples.add(entry);
          }
        }
      }
    }

    if (allSamples.isEmpty) {
      return (r: 0, g: 0, b: 0, color: Colors.black, glareRatio: 0.0);
    }

    final totalCount = allSamples.length;
    final glareRatio = specularCount / totalCount;

    // Prefer anatomically gated foreground pixels when >= 15% of ROI matches;
    // otherwise safely fall back to all ROI pixels (e.g. uniform dark melena or
    // pure white sclera test swatches).
    final samples = (category != null &&
            foregroundSamples.length >= math.max(12, (totalCount * 0.15).round()))
        ? foregroundSamples
        : allSamples;

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
