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
      final comp = options.baseline!.compare(LabColor.fromColor(metrics.centerColor));
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
    int centerCount = 0;

    for (int y = cStartY; y < cEndY; y += stepY) {
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

        centerCount++;
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

    final lrDiff = ((leftV / math.max(1, leftN)) - (rightV / math.max(1, rightN)))
        .abs();
    final tbDiff = ((topV / math.max(1, topN)) - (bottomV / math.max(1, bottomN)))
        .abs();
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
    );
  }

  AnalysisResult analyzeMetrics(SkinVisualMetrics m) {
    final now = DateTime.now();
    final id = '${CheckCategory.skinCondition.id}_${now.microsecondsSinceEpoch}';
    final areaPrefix = skinContext.bodyArea != null
        ? 'Seçilen bölge: ${skinContext.bodyArea}. '
        : '';

    // Guard for underexposed image unless user specifically checks a dark mole
    if (m.centerValue < 0.12 &&
        m.darknessDelta < 0.15 &&
        skinContext.concernType != SkinConcernType.molePigment) {
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

    final isDarkPigmented =
        m.darknessDelta >= 0.22 || (m.centerValue < 0.34 && m.darknessDelta >= 0.12);
    final isVariegatedOrAsymmetric =
        m.colorVariegation >= 0.28 || m.asymmetryScore >= 0.14;
    final isStrongRedness = m.erythemaDelta >= 0.08 ||
        ((m.centerHue <= 16 || m.centerHue >= 342) && m.centerSaturation >= 0.46);
    final hasYellowCrust = m.yellowCrustRatio >= 0.18;
    final hasScaling = m.scalingIndex >= 0.26;

    // 1. Urgent ABCDE pigment / mole red flag
    if ((isDarkPigmented && (isVariegatedOrAsymmetric || skinContext.hasAbcdeRedFlag)) ||
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
        (isStrongRedness || hasYellowCrust || skinContext.concernType == SkinConcernType.blisterPustule)) {
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
        (skinContext.concernType == SkinConcernType.blisterPustule && isStrongRedness)) {
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
    if (isStrongRedness || skinContext.concernType == SkinConcernType.rashRedness) {
      return AnalysisResult(
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
    if (isDarkPigmented || skinContext.concernType == SkinConcernType.molePigment) {
      return AnalysisResult(
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
          : '$areaPrefixÖrneklenen cilt bölgesinde belirgin kızarıklık kontrastı, koyu pigment karmaşası veya yoğun pullanma tonu saptanmadı.',
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

  List<String> _symptomObservations() {
    if (skinContext.symptoms.isEmpty) return const [];
    final labels = skinContext.symptoms.map((s) => s.label).join(', ');
    return ['Bildirilen belirtiler: $labels.'];
  }
}
