import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';

/// On-device CIE L*a*b* + HSV color analyzer with optional white-reference
/// chromatic adaptation (Von Kries), glare/shadow filtering, lighting-cast
/// detection, and personal baseline comparison.
class ColorHealthAnalyzer implements HealthAnalyzer {
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

    final sample = ColorCalibrator.sampleImage(
      image: decoded,
      useWhiteReference: options.useWhiteReference,
    );

    final c = sample.calibratedColor;
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);

    var result = analyzeRgb(
      category: category,
      r: r,
      g: g,
      b: b,
      baseline: options.baseline,
    );

    final extraObservations = <String>[];
    var adjustedConfidence = result.confidence;

    if (sample.whiteBalanceApplied) {
      adjustedConfidence = (adjustedConfidence + 0.08).clamp(0.25, 0.92);
      extraObservations.add(
        'Beyaz referans kutusu ile cihaz ve ortam ışığı dengelendi.',
      );
    } else if (sample.lightingCast == LightingCast.warmYellow ||
        sample.lightingCast == LightingCast.coolBlue) {
      adjustedConfidence = (adjustedConfidence - 0.12).clamp(0.25, 0.90);
      if (sample.lightingNote != null) {
        extraObservations.add(sample.lightingNote!);
      }
    }

    if (sample.glareFilteredRatio >= 0.12) {
      extraObservations.add(
        'Islak/parlak yüzey yansıması otomatik filtrelenerek ölçüldü.',
      );
    }

    result = result.copyWith(
      confidence: adjustedConfidence,
      whiteBalanceCalibrated: sample.whiteBalanceApplied,
      lightingNote: sample.lightingNote,
      observations: [...result.observations, ...extraObservations],
    );

    return result;
  }

  AnalysisResult analyzeRgb({
    required CheckCategory category,
    required int r,
    required int g,
    required int b,
    CategoryBaseline? baseline,
  }) {
    final color = Color.fromARGB(255, r, g, b);
    final hsv = HSVColor.fromColor(color);
    final lab = LabColor.fromRgb(r, g, b);
    final h = hsv.hue; // 0..360
    final s = hsv.saturation; // 0..1
    final v = hsv.value; // 0..1

    final now = DateTime.now();
    final id = '${category.id}_${now.microsecondsSinceEpoch}';

    // Lighting quality guard (except stool where dark tones are clinically relevant)
    if (category != CheckCategory.stool && v < 0.18) {
      return AnalysisResult(
        id: id,
        category: category,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Ortam Işığı Yetersiz',
        summaryDetail:
            'Görüntü çok karanlık olduğu için renk tonu güvenilir şekilde okunamadı.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Örneklenen merkez bölgede parlaklık çok düşük.',
        ],
        recommendations: const [
          'Doğal gün ışığı alan aydınlık bir ortamda çekimi tekrarlayın.',
          'Gölge düşmemesine ve kameranın odaklanmasına dikkat edin.',
        ],
        warningFlags: const [],
        confidence: 0.25,
        createdAt: now,
      );
    }

    AnalysisResult result;
    switch (category) {
      case CheckCategory.eye:
        result = _evaluateEye(id, color, h, s, v, lab, now);
      case CheckCategory.nail:
        result = _evaluateNail(id, color, h, s, v, lab, now);
      case CheckCategory.tongue:
        result = _evaluateTongue(id, color, h, s, v, lab, now);
      case CheckCategory.face:
      case CheckCategory.skinCondition:
        result = _evaluateFace(id, color, h, s, v, lab, now);
      case CheckCategory.urine:
        result = _evaluateUrine(id, color, h, s, v, lab, now);
      case CheckCategory.stool:
        result = _evaluateStool(id, color, h, s, v, now);
    }

    if (baseline != null) {
      final comparison = baseline.compare(lab);
      final updatedObservations = [
        ...result.observations,
        comparison.note,
      ];
      // Escalate normal -> attention when a significant personal shift occurs.
      final updatedRisk =
          result.riskLevel == RiskLevel.normal && comparison.isSignificantShift
              ? RiskLevel.attention
              : result.riskLevel;
      result = result.copyWith(
        riskLevel: updatedRisk,
        baselineDeltaE: comparison.deltaE,
        baselineComparisonNote: comparison.note,
        observations: updatedObservations,
      );
    }

    return result;
  }

  AnalysisResult _evaluateEye(
    String id,
    Color color,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    // Yellowish sclera check (HSV hue + perceptual Lab b* yellow channel)
    if ((h >= 38 && h <= 68 && s >= 0.25) || (lab.b >= 18.0 && lab.l >= 55.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.eye,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Göz Akında Sarımsı Ton Algılandı',
        summaryDetail:
            'Örneklenen bölgede belirgin sarımsı renk tonu saptandı. Sarı ışık altında çekilmediyse değerlendirme önemlidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Sklera bölgesinde sarımsı renk kayması tespit edildi.',
          'Ortam ışığının sıcak (sarı ampul) olması sonucu etkileyebilir.',
        ],
        recommendations: const [
          'Doğal gün ışığında tekrar kontrol edin.',
          'Göz akında gerçek bir sararma görüyorsanız gecikmeden bir doktora başvurun.',
        ],
        warningFlags: const [
          'Ciltte sararma, koyu idrar veya halsizlik eşlik ediyorsa acil değerlendirme önerilir.',
        ],
        confidence: 0.68,
        createdAt: now,
      );
    }

    // Redness check
    if ((h <= 20 || h >= 340) && s >= 0.30) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.eye,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Kızarıklık / Hassasiyet İpucu',
        summaryDetail:
            'Göz bölgesinde pembe-kırmızı ton ağırlığı görüldü. Yorgunluk, kuruluk veya tahriş kaynaklı olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Kırmızı kanal baskınlığı normal beyaz sklera tonunun üzerinde.',
        ],
        recommendations: const [
          'Ekran molası verin ve gözlerinizi dinlendirin.',
          'Gözlerinizi ovalamaktan kaçının; şikayet sürerse göz hekimine danışın.',
        ],
        warningFlags: const [
          'Ağrı, ışığa hassasiyet, çapaklanma veya görme bulanıklığı varsa doktora başvurun.',
        ],
        confidence: 0.65,
        createdAt: now,
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.eye,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Göz Akı Tonu Olağan Görünüyor',
      summaryDetail:
          'Örneklenen bölgede belirgin sararma veya yoğun kızarıklık tonu saptanmadı.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Renk doygunluğu düşük ve nötr/açık ton aralığında.',
      ],
      recommendations: const [
        'Düzenli uyku ve yeterli su tüketimi göz sağlığını destekler.',
        'Herhangi bir görme veya ağrı şikayetiniz varsa yine de uzman görüşü alın.',
      ],
      warningFlags: const [],
      confidence: 0.72,
      createdAt: now,
    );
  }

  AnalysisResult _evaluateNail(
    String id,
    Color color,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    // Bluish / cyanotic tint (HSV hue + Lab negative b* blue channel)
    if ((h >= 190 && h <= 275 && s >= 0.22) || lab.b <= -10.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Tırnakta Morumsu / Mavimsi Ton',
        summaryDetail:
            'Soğuk hava kaynaklı değilse tırnak yatağındaki morarma dolaşım veya oksijenlenme açısından değerlendirilmelidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Mavi-mor renk spektrumunda belirgin ton saptandı.',
        ],
        recommendations: const [
          'Elleriniz üşümüşse ısıttıktan sonra gün ışığında tekrar bakın.',
          'Morarma kalıcıysa bir sağlık kuruluşuna başvurun.',
        ],
        warningFlags: const [
          'Nefes darlığı, göğüs ağrısı veya baş dönmesi eşlik ediyorsa acil yardım alın.',
        ],
        confidence: 0.66,
        createdAt: now,
      );
    }

    // Yellowish nail
    if ((h >= 38 && h <= 68 && s >= 0.32) || (lab.b >= 24.0 && lab.a < 15.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Tırnakta Sararma Eğilimi',
        summaryDetail:
            'Sarımsı tırnak tonu oje kalıntısı, mantar enfeksiyonu veya vitamin/mineral dengesizlikleri ile ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Tırnak yüzeyinde sarı ton doygunluğu yüksek.',
        ],
        recommendations: const [
          'Tırnakta kalınlaşma veya kırılma eşlik ediyorsa dermatoloğa danışın.',
        ],
        warningFlags: const [],
        confidence: 0.64,
        createdAt: now,
      );
    }

    // Very pale nail bed
    if (s < 0.14 && v > 0.72) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Soluk Tırnak Tonu',
        summaryDetail:
            'Tırnak yatağı normal pembe tona göre oldukça soluk görünüyor. Işık yansıması değilse demir/kansızlık açısından takip edilebilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Düşük renk doygunluğu ve yüksek parlaklık (soluk görünüm).',
        ],
        recommendations: const [
          'Halsizlik veya çabuk yorulma yaşıyorsanız kan sayımı için doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.60,
        createdAt: now,
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.nail,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Tırnak Tonu Olağan Aralığında',
      summaryDetail:
          'Tırnak yatağı sağlıklı pembe/doğal ton aralığına yakın görünüyor.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Belirgin morarma, aşırı solukluk veya yoğun sararma görülmedi.',
      ],
      recommendations: const [
        'Tırnak bakımı ve dengeli beslenmeye devam edin.',
      ],
      warningFlags: const [],
      confidence: 0.70,
      createdAt: now,
    );
  }

  AnalysisResult _evaluateTongue(
    String id,
    Color color,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    // Whitish coating
    if (s < 0.18 && v > 0.68) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Dilde Beyazımsı Tabaka İpucu',
        summaryDetail:
            'Dil yüzeyinde açık/beyazımsı ton baskın. Ağız kuruluğu, yetersiz su tüketimi veya ağız hijyeni ile ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Pembe dil tonuna kıyasla düşük doygunluk ve açık renk gözlemlendi.',
        ],
        recommendations: const [
          'Gün içinde su tüketiminizi artırın ve dil temizliğini ihmal etmeyin.',
          'Tabaka silinmiyor veya ağrı yapıyorsa diş hekimi/doktora görünün.',
        ],
        warningFlags: const [],
        confidence: 0.64,
        createdAt: now,
      );
    }

    // Yellowish coating (HSV + Lab b* channel)
    if ((h >= 35 && h <= 70 && s >= 0.25) || (lab.b >= 22.0 && lab.a < 18.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Dilde Sarımsı Ton',
        summaryDetail:
            'Kahve/çay tüketimi, ağız kuruluğu veya sindirim hassasiyeti dilde sarımsı tabakaya yol açabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Dil yüzeyinde sarımsı renk ağırlığı tespit edildi.',
        ],
        recommendations: const [
          'Ağız bakımınızı düzenli yapın ve bol su tüketin.',
          'Uzun süre geçmezse bir hekime danışın.',
        ],
        warningFlags: const [],
        confidence: 0.62,
        createdAt: now,
      );
    }

    // Intense red tongue
    if ((h <= 15 || h >= 345) && s >= 0.58) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yoğun Kırmızı Dil Tonu',
        summaryDetail:
            'Dil rengi normal pembeden daha yoğun kırmızı görünüyor. Sıcak yiyecek tahrişi, B vitamini eksikliği veya ateşle ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Kırmızı renk doygunluğu yüksek ölçüldü.',
        ],
        recommendations: const [
          'Yanma, ağrı veya şişlik eşlik ediyorsa doktor değerlendirmesi alın.',
        ],
        warningFlags: const [
          'Dil şişmesi veya yutma güçlüğü varsa acil tıbbi destek alın.',
        ],
        confidence: 0.65,
        createdAt: now,
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.tongue,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Dil Rengi Olağan Pembe Tonda',
      summaryDetail:
          'Dil yüzeyinde belirgin yoğun beyaz, sarı veya aşırı kırmızı ton saptanmadı.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Renk tonu doğal pembe aralığında.',
      ],
      recommendations: const [
        'Düzenli ağız hijyeni ve yeterli sıvı alımını sürdürün.',
      ],
      warningFlags: const [],
      confidence: 0.70,
      createdAt: now,
    );
  }

  AnalysisResult _evaluateFace(
    String id,
    Color color,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    if ((h >= 40 && h <= 65 && s >= 0.42) || (lab.b >= 34.0 && lab.a < 18.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Ciltte Sarımsı Ton Algılandı',
        summaryDetail:
            'Ortam ışığı sarı değilse ciltte belirgin sararma tıbbi değerlendirme gerektirir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Yüz bölgesinde sarı spektrum ağırlığı yüksek.',
        ],
        recommendations: const [
          'Göz akınızı da gün ışığında kontrol edin.',
          'Gerçek bir sararma fark ediyorsanız hekime başvurun.',
        ],
        warningFlags: const [
          'Göz akında sararma veya halsizlik eşlik ediyorsa gecikmeden doktora başvurun.',
        ],
        confidence: 0.62,
        createdAt: now,
      );
    }

    if (((h <= 15 || h >= 345) && s >= 0.48) || lab.a >= 32.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yüzde Kızarıklık / Sıcaklık İpucu',
        summaryDetail:
            'Cilt tonunda belirgin kızarıklık saptandı. Güneş, egzersiz, hassasiyet veya ateş kaynaklı olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Yüz bölgesinde kırmızı ton yoğunluğu yüksek.',
        ],
        recommendations: const [
          'Ateş, kaşıntı veya döküntü varsa takip edin ve gerekirse doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.64,
        createdAt: now,
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.face,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Cilt Tonu Olağan Görünüyor',
      summaryDetail:
          'Yüz bölgesinde aşırı kızarıklık veya belirgin renk sapması tespit edilmedi.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Cilt tonu dengeli ve doğal aralıkta.',
      ],
      recommendations: const [
        'Güneş koruyucu kullanımı ve yeterli su alımı cilt sağlığını destekler.',
      ],
      warningFlags: const [],
      confidence: 0.68,
      createdAt: now,
    );
  }

  AnalysisResult _evaluateUrine(
    String id,
    Color color,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    // Reddish / pinkish -> possible hematuria (or beetroot/medication)
    if (((h <= 18 || h >= 335) && s >= 0.30) || (lab.a >= 24.0 && lab.b < 28.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.urine,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Pembe / Kırmızımsı İdrar Tonu',
        summaryDetail:
            'Pancar gibi gıdalar veya bazı ilaçlar tüketilmediyse pembe/kırmızı idrar mutlaka tıbbi olarak değerlendirilmelidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'İdrar örneğinde kırmızı/pembe spektrum ağırlığı saptandı.',
        ],
        recommendations: const [
          'Son 24 saatte pancar, böğürtlen veya renk veren ilaç tüketip tüketmediğinizi kontrol edin.',
          'Gıda/ilaç kaynaklı değilse en kısa sürede bir doktora başvurun.',
        ],
        warningFlags: const [
          'Yanma, yan/kasık ağrısı veya ateş eşlik ediyorsa acil değerlendirme önerilir.',
        ],
        confidence: 0.72,
        createdAt: now,
      );
    }

    // Dark amber / brown -> strong dehydration or liver/bile signal
    if ((h >= 18 && h <= 45 && v < 0.58 && s >= 0.45) ||
        (lab.l < 48.0 && lab.b >= 22.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.urine,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Koyu Kehribar / Kahverengimsi İdrar',
        summaryDetail:
            'Belirgin sıvı kaybı (dehidrasyon) veya karaciğer/safra yolu kaynaklı renk koyulaşması olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Düşük parlaklık ve yüksek doygunlukta koyu amber/kahverengi ton.',
        ],
        recommendations: const [
          'Öncelikle yeterli su için ve bir sonraki idrar rengini gözlemleyin.',
          'Su içmenize rağmen koyu renk devam ediyorsa doktora başvurun.',
        ],
        warningFlags: const [
          'Gözlerde sararma veya açık renkli dışkı eşlik ediyorsa gecikmeden hekime başvurun.',
        ],
        confidence: 0.70,
        createdAt: now,
      );
    }

    // Saturated yellow -> mild/moderate dehydration
    if ((h >= 38 && h <= 68 && s >= 0.45) || lab.b >= 38.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.urine,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Koyu Sarı Ton — Sıvı İhtiyacı Olabilir',
        summaryDetail:
            'İdrar rengi yoğun sarı görünüyor. Genellikle yetersiz su tüketimine veya B vitamini takviyelerine işaret eder.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Sarı renk doygunluğu ideal açık saman sarısının üzerinde.',
        ],
        recommendations: const [
          'Gün boyunca düzenli aralıklarla su tüketiminizi artırın.',
          'B vitamini takviyesi kullanıyorsanız parlak sarı renk normal olabilir.',
        ],
        warningFlags: const [],
        confidence: 0.76,
        createdAt: now,
      );
    }

    // Pale straw / light yellow -> well hydrated
    return AnalysisResult(
      id: id,
      category: CheckCategory.urine,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Açık Saman Sarısı — İyi Hidrasyon',
      summaryDetail:
          'İdrar rengi sağlıklı hidrasyon göstergesi olan açık sarı/berrak tonda görünüyor.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Düşük-orta doygunlukta açık ton saptandı.',
      ],
      recommendations: const [
        'Mevcut su tüketim düzeninizi koruyun.',
      ],
      warningFlags: const [],
      confidence: 0.78,
      createdAt: now,
    );
  }

  AnalysisResult _evaluateStool(
    String id,
    Color color,
    double h,
    double s,
    double v,
    DateTime now,
  ) {
    // Very dark / black (melena warning unless iron/bismuth)
    if (v < 0.16) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.stool,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Çok Koyu / Siyah Dışkı Uyarısı',
        summaryDetail:
            'Demir ilacı, aktif kömür veya bizmut kullanmıyorsanız siyah/katran renkli dışkı mutlaka tıbbi olarak değerlendirilmelidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Örneklenen bölgede çok düşük parlaklık (siyah ton) saptandı.',
        ],
        recommendations: const [
          'Demir takviyesi veya koyu renkli gıda/ilaç kullanımınızı gözden geçirin.',
          'İlaç kaynaklı değilse ve ışık yeterliyse gecikmeden doktora başvurun.',
        ],
        warningFlags: const [
          'Baş dönmesi, halsizlik, karın ağrısı veya katran kıvamı varsa acil servise başvurun.',
        ],
        confidence: 0.68,
        createdAt: now,
      );
    }

    // Pale / clay / white stool
    if (s < 0.16 && v > 0.72) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.stool,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Çok Açık / Kil Rengi Dışkı Uyarısı',
        summaryDetail:
            'Beyazımsı veya kil rengi dışkı safra akışı ile ilgili sorunların işareti olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Normal kahverengi pigmentasyonun oldukça altında açık/gri-beyaz ton.',
        ],
        recommendations: const [
          'Tekrarlıyorsa gastroenteroloji veya dahiliye uzmanına başvurun.',
        ],
        warningFlags: const [
          'Koyu idrar, karın ağrısı veya sarılık eşlik ediyorsa acil değerlendirme gerekir.',
        ],
        confidence: 0.70,
        createdAt: now,
      );
    }

    // Reddish stool
    if ((h <= 15 || h >= 340) && s >= 0.45 && v >= 0.25) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.stool,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Kırmızımsı Dışkı Tonu',
        summaryDetail:
            'Pancar, domates sosu veya kırmızı gıda boyası tüketilmediyse kırmızı renk alt sindirim sistemi kanaması açısından değerlendirilmelidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Kırmızı renk spektrumunda belirgin yoğunluk tespit edildi.',
        ],
        recommendations: const [
          'Son öğünlerinizi kontrol edin; gıda kaynaklı değilse doktora başvurun.',
        ],
        warningFlags: const [
          'Aktif kanama, şiddetli ağrı veya halsizlik varsa acil yardım alın.',
        ],
        confidence: 0.70,
        createdAt: now,
      );
    }

    // Greenish stool
    if (h >= 75 && h <= 165 && s >= 0.25) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.stool,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yeşilimsi Dışkı Tonu',
        summaryDetail:
            'Genellikle ıspanak gibi yeşil yapraklı sebzeler, demir takviyeleri veya hızlı bağırsak geçişi ile ilişkilidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Yeşil renk tonu baskın ölçüldü.',
        ],
        recommendations: const [
          'Beslenmenizi gözden geçirin; ishal eşlik ediyorsa bol sıvı tüketin.',
          'Birkaç günden uzun sürerse doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.68,
        createdAt: now,
      );
    }

    // Yellowish / greasy possible
    if (h >= 42 && h <= 74 && s >= 0.35 && v >= 0.45) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.stool,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Sarımsı Dışkı Tonu',
        summaryDetail:
            'Beslenme değişiklikleri veya yağ emilimi hassasiyetleri sarımsı renge neden olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Sarı spektrum baskınlığı gözlendi.',
        ],
        recommendations: const [
          'Yağlı/kötü kokulu dışkılama veya kilo kaybı eşlik ediyorsa hekime başvurun.',
        ],
        warningFlags: const [],
        confidence: 0.65,
        createdAt: now,
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.stool,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Kahverengi Ton — Olağan Görünüm',
      summaryDetail:
          'Dışkı rengi sağlıklı sindirim sistemi için olağan kabul edilen kahverengi ton aralığında görünüyor.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Renk tonu doğal kahverengi spektrumunda.',
      ],
      recommendations: const [
        'Lifli beslenme ve düzenli su tüketimini sürdürün.',
      ],
      warningFlags: const [],
      confidence: 0.74,
      createdAt: now,
    );
  }
}
