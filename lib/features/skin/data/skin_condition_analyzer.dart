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
}

/// On-device dermatological pre-awareness analyzer.
///
/// Compares the central lesion region (35%..65%) with the surrounding border
/// ring (10%..25% & 75%..90%), applies optional Von Kries white-balance
/// calibration, and combines visual cues with optional user symptom context
/// and personal baseline. This is NOT a medical diagnostic tool.
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
    } else if (calibratedSample.lightingCast == LightingCast.warmYellow ||
        calibratedSample.lightingCast == LightingCast.coolBlue) {
      confidence = (confidence - 0.10).clamp(0.25, 0.90);
      if (calibratedSample.lightingNote != null) {
        extraObservations.add(calibratedSample.lightingNote!);
      }
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
    double ringR = 0, ringG = 0, ringV = 0;
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
        ringV += math.max(r, math.max(g, b)) / 255.0;
        ringCount++;
      }
    }

    final safeRing = math.max(1, ringCount);
    final avgRingR = ringR / safeRing;
    final avgRingG = ringG / safeRing;
    final avgRingV = ringV / safeRing;

    final centerRedness = (avgR - avgG) / 255.0;
    final ringRedness = (avgRingR - avgRingG) / 255.0;
    final erythemaDelta = centerRedness - ringRedness;
    final darknessDelta = avgRingV - meanV;

    final scalingIndex = (paleFleckCount / safeCenter) + math.sqrt(varV) * 0.75;
    final yellowCrustRatio = yellowCrustCount / safeCenter;
    final bluePurpleRatio = bluePurpleCount / safeCenter;
    final yellowGreenBruiseRatio = yellowGreenBruiseCount / safeCenter;
    final roughTextureIndex =
        roughGradN > 0 ? roughGradSum / roughGradN : 0.0;
    // Pinpoint black dots only count when overall surface isn't uniformly pitch-black.
    final blackDotRatio = meanV > 0.30 ? (darkDotCount / safeCenter) : 0.0;

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

    final isDarkPigmented = m.darknessDelta >= 0.22 ||
        (m.centerValue < 0.34 && m.darknessDelta >= 0.12);
    final isVariegatedOrAsymmetric =
        m.colorVariegation >= 0.28 || m.asymmetryScore >= 0.14;
    final isStrongRedness = m.erythemaDelta >= 0.08 ||
        ((m.centerHue <= 16 || m.centerHue >= 342) && m.centerSaturation >= 0.46);
    final hasYellowCrust = m.yellowCrustRatio >= 0.18;
    final hasScaling = m.scalingIndex >= 0.26;

    // Dedicated sub-module routing for the 4 focused dermatological screens.
    switch (skinContext.concernType) {
      case SkinConcernType.skinCancerRisk:
        return _analyzeSkinCancerRisk(
          id: id,
          now: now,
          areaPrefix: areaPrefix,
          m: m,
          isDarkPigmented: isDarkPigmented,
          isVariegatedOrAsymmetric: isVariegatedOrAsymmetric,
        );
      case SkinConcernType.bruise:
        return _analyzeBruise(
          id: id,
          now: now,
          areaPrefix: areaPrefix,
          m: m,
        );
      case SkinConcernType.wart:
        return _analyzeWart(
          id: id,
          now: now,
          areaPrefix: areaPrefix,
          m: m,
        );
      case SkinConcernType.facialSpot:
        return _analyzeFacialSpot(
          id: id,
          now: now,
          areaPrefix: areaPrefix,
          m: m,
          isDarkPigmented: isDarkPigmented,
          isVariegatedOrAsymmetric: isVariegatedOrAsymmetric,
          isStrongRedness: isStrongRedness,
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
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Ben / Koyu Leke — Dermatolog Değerlendirmesi Önerilir',
        summaryDetail:
            '${areaPrefix}Koyu pigmentli alanda renk heterojenliği, asimetri veya hızlı değişim belirtisi saptandı. Dermoskopik muayene önemlidir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (isDarkPigmented)
            'Merkez lezyon çevresindeki cilt tonuna göre belirgin derecede koyu ölçüldü.',
          if (m.colorVariegation >= 0.28)
            'Lezyon içinde birden fazla renk/parlaklık tonu (ABCDE - Renk çeşitliliği) gözlendi.',
          if (m.asymmetryScore >= 0.14)
            'Örneklenen alanda belirgin simetri farkı (ABCDE - Asimetri) tespit edildi.',
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
        confidence: 0.68,
        createdAt: now,
      );
    }

    // 2. Urgent infection / severe inflammatory red flag
    if (skinContext.hasInfectionRedFlag &&
        (isStrongRedness ||
            hasYellowCrust ||
            skinContext.concernType == SkinConcernType.blisterPustule)) {
      return AnalysisResult(
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
      );
    }

    // 3. Yellowish crust / pustular cue -> attention
    if (hasYellowCrust ||
        (skinContext.concernType == SkinConcernType.blisterPustule &&
            isStrongRedness)) {
      return AnalysisResult(
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
      );
    }

    // 4. Scaly / dry plaque cue (eczema, psoriasis, superficial fungal awareness)
    if (hasScaling ||
        (skinContext.concernType == SkinConcernType.scalyDry &&
            (isStrongRedness || m.colorVariegation >= 0.16))) {
      return AnalysisResult(
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
      );
    }

    // 5. Localized erythema / rash (dermatitis, allergy, urticaria, irritation)
    if (isStrongRedness ||
        skinContext.concernType == SkinConcernType.rashRedness) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Bölgesel Kızarıklık / Döküntü İpucu',
        summaryDetail:
            '${areaPrefix}Örneklenen cilt bölgesinde çevresine kıyasla kızarıklık/pembe ton artışı gözlendi. Kontakt dermatit, alerjik döküntü, egzama veya mekanik/güneş tahrişi kaynaklı olabilir.',
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
          'Bölgeyi kaşımaktan ve çok sıcak su temasından kaçının; ılık/serin kompres rahatlatabilir.',
          'Döküntü 48–72 saat içinde gerilemez veya yayılırsa cildiye uzmanına danışın.',
        ],
        warningFlags: const [
          'Dudak/göz kapağı şişmesi, nefes darlığı veya yaygın kurdeşen eşlik ediyorsa acil servise başvurun.',
        ],
        confidence: 0.66,
        createdAt: now,
      );
    }

    // 6. Uniform dark mole / pigment tracking
    if (isDarkPigmented ||
        skinContext.concernType == SkinConcernType.molePigment) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Pigmentli Leke / Ben — Düzenli Takip Önerilir',
        summaryDetail:
            '${areaPrefix}Çevre cilde göre daha koyu pigmentli bir alan gözlendi. Mevcut görüntüde yoğun renk karmaşası saptanmasa da benlerin düzenli aralıklarla takip edilmesi önerilir.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          'Merkez bölgede pigment yoğunluğu çevre cilde göre daha koyu.',
          'Belirgin çok renklilik veya şiddetli asimetri saptanmadı (yalnızca görsel ön taramadır).',
          ..._symptomObservations(),
        ],
        recommendations: const [
          'Güneş koruyucu (SPF 30+) kullanın ve benlerinizi ABCDE kuralına göre birkaç ayda bir kontrol edin.',
          'Yeni oluşan, büyüyen veya rengi değişen tüm benler için dermatoloji muayenesi yaptırın.',
        ],
        warningFlags: const [],
        confidence: 0.62,
        createdAt: now,
      );
    }

    // 7. Normal / uniform skin appearance
    return AnalysisResult(
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
          : '${areaPrefix}Örneklenen cilt bölgesinde belirgin kızarıklık kontrastı, koyu pigment karmaşası veya yoğun pullanma tonu saptanmadı.',
      dominantColorValue: m.centerColor.toARGB32(),
      observations: [
        'Merkez ve çevre cilt tonları birbirine yakın ve dengeli.',
        ..._symptomObservations(),
      ],
      recommendations: const [
        'Düzenli nemlendirme ve güneş koruyucu kullanımı cilt bariyerini destekler.',
        'Fotoğrafta belirgin olmayan kaşıntı, ağrı veya kabartı şikayetiniz sürüyorsa dermatoloğa danışın.',
      ],
      warningFlags: const [],
      confidence: 0.68,
      createdAt: now,
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
    final highRisk =
        (isDarkPigmented && isVariegatedOrAsymmetric) ||
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
            '${areaPrefix}ABCDE kriterleri (asimetri, çok renklilik, hızlı değişim/6 mm+) veya iyileşmeyen yara/kanama belirtisi saptandı. Bu bir kesin kanser teşhisi değildir; ancak güvenli dışlama için dermoskopik muayene şarttır.',
        dominantColorValue: m.centerColor.toARGB32(),
        observations: [
          if (isDarkPigmented)
            'Lezyon çevre cilde göre belirgin koyu pigment yoğunluğu gösteriyor.',
          if (m.colorVariegation >= 0.28)
            'Tek lezyon içinde çoklu renk/ton farklılığı (ABCDE - C) ölçüldü.',
          if (m.asymmetryScore >= 0.14)
            'Merkez alanda belirgin yarı-simetri farkı (ABCDE - A) saptandı.',
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
        confidence: 0.70,
        createdAt: now,
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
    );
  }

  AnalysisResult _analyzeWart({
    required String id,
    required DateTime now,
    required String areaPrefix,
    required SkinVisualMetrics m,
  }) {
    final hasRedFlags = skinContext.symptoms.contains(SkinSymptomFlag.bleedingOrOozing) ||
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
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.attention,
      summaryTitle: 'Siğil Benzeri Pütürlü Kabartı — Ön Değerlendirme',
      summaryDetail:
          '${areaPrefix}${hasRoughSurface || hasBlackDots ? 'Pütürlü yüzey dokusu veya koyu noktacık ipuçları yaygın siğil (verruka) veya nasır görünümüyle uyumlu olabilir.' : 'Görüntüde hafif doku/ton farkı gözlendi; siğil, nasır veya keratoz ayrımı için yakından dermatoloji muayenesi gerekir.'}',
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
    final suspiciousPigment =
        (isDarkPigmented && isVariegatedOrAsymmetric) ||
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
          if (m.colorVariegation >= 0.28)
            'Leke içinde birden fazla kahverengi/koyu ton dağılımı gözlendi.',
          if (m.asymmetryScore >= 0.14)
            'Leke alanında belirgin asimetri farkı saptandı.',
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
            '${areaPrefix}Çevre cilde göre daha koyu ancak nispeten dengeli pigment tonu gözlendi. Güneş lekesi (solar lentigo), melazma veya akne sonrası leke (PIH) ile uyumlu olabilir.',
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
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.skinCondition,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Yüz Cilt Tonu Dengeli Görünüyor',
      summaryDetail:
          '${areaPrefix}Örneklenen alanda belirgin koyu pigment kontrastı veya yoğun kızarıklık farkı saptanmadı.',
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
    );
  }

  List<String> _symptomObservations() {
    if (skinContext.symptoms.isEmpty) return const [];
    final labels = skinContext.symptoms.map((s) => s.label).join(', ');
    return ['Bildirilen belirtiler: $labels.'];
  }
}
