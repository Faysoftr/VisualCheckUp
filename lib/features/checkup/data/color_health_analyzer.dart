import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
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
      category: category,
    );

    final c = sample.calibratedColor;
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);

    final structural = StructuralFeatureAnalyzer.analyze(
      image: decoded,
      category: category,
      gains: sample.gains,
    );

    AnalysisResult result;
    if (category == CheckCategory.eye &&
        options.eyeScanMode == EyeScanMode.palpebralConjunctiva) {
      result = _evaluatePalpebralConjunctiva(
        color: c,
        r: r,
        g: g,
        b: b,
        lab: sample.lab,
        structural: structural,
        baseline: options.baseline,
      );
    } else {
      result = analyzeRgb(
        category: category,
        r: r,
        g: g,
        b: b,
        baseline: options.baseline,
      );
      result = _applyStructuralFindings(
        result: result,
        category: category,
        structural: structural,
        whiteBalanceApplied: sample.whiteBalanceApplied,
      );
    }

    final extraObservations = <String>[];
    var adjustedConfidence = result.confidence;

    if (sample.whiteBalanceApplied) {
      adjustedConfidence = (adjustedConfidence + 0.08).clamp(0.25, 0.92);
      extraObservations.add(
        'Beyaz referans kutusu ile cihaz ve ortam ışığı dengelendi.',
      );
    } else if (sample.autoColorConstancyApplied) {
      adjustedConfidence = (adjustedConfidence + 0.02).clamp(0.25, 0.90);
      if (sample.lightingNote != null) {
        extraObservations.add(sample.lightingNote!);
      }
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

    final mergedMetrics = <String, String>{
      ...result.clinicalMetrics,
      ..._buildColorAndStructuralMetrics(
        category: category,
        r: r,
        g: g,
        b: b,
        lab: sample.lab,
        structural: structural,
        eyeScanMode: options.eyeScanMode,
      ),
    };

    result = result.copyWith(
      confidence: adjustedConfidence,
      whiteBalanceCalibrated: sample.whiteBalanceApplied,
      lightingNote: sample.lightingNote,
      observations: [...result.observations, ...extraObservations],
      clinicalMetrics: mergedMetrics,
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
        result = _evaluateNail(id, color, r, g, h, s, v, lab, now);
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
        matchedFindingIds: const ['eye_jaundice_sclera'],
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
        matchedFindingIds: const ['eye_mild_redness'],
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
      matchedFindingIds: const ['eye_healthy_white'],
    );
  }

  AnalysisResult _evaluateNail(
    String id,
    Color color,
    int r,
    int g,
    double h,
    double s,
    double v,
    LabColor lab,
    DateTime now,
  ) {
    final nailEi = ColorCalibrator.erythemaIndex(r, g);

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
        matchedFindingIds: const ['nail_cyanotic_blue'],
      );
    }

    // Dark brown / black pigment (melanonychia / subungual hematoma)
    if (v >= 0.18 && v < 0.34 && s < 0.55) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Tırnakta Koyu Kahverengi / Siyah Ton (Melanoniki Uyarısı)',
        summaryDetail:
            'Yeterli ışıkta çekildiyse koyu tırnak altı lekesi veya dikey siyah/kahverengi bant; darbe kaynaklı kanama olabileceği gibi cilt kanseri (melanom) açısından dermatolojik inceleme gerektirir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Tırnak bölgesinde belirgin düşük parlaklıkta koyu kahverengi/siyah ton saptandı.',
        ],
        recommendations: const [
          'Bilinen bir çarpma/darbe yoksa ve özellikle tek tırnakta >3 mm genişlikte dikey çizgi görüyorsanız dermatoloji muayenesi alın.',
        ],
        warningFlags: const [
          'Koyu çizgi genişliyorsa, düzensiz koyulaşıyorsa veya tırnak dibi etine taşıyorsa (Hutchinson işareti) acil dermatoloji değerlendirmesi gerekir.',
        ],
        confidence: 0.64,
        createdAt: now,
        matchedFindingIds: const ['nail_dark_vertical_band'],
      );
    }

    // Greenish nail (Pseudomonas / chloronychia / fungal)
    if (h >= 72 && h <= 165 && s >= 0.20) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Tırnakta Yeşilimsi Renklenme (Kloronişi İpucu)',
        summaryDetail:
            'Tırnak plağındaki yeşilimsi ton çoğunlukla Pseudomonas bakteriyel enfeksiyonu veya mantar enfeksiyonu ile ilişkilidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Tırnak yüzeyinde yeşil renk spektrumunda belirgin ton saptandı.',
        ],
        recommendations: const [
          'Tırnağı kuru tutun, nemli/kimyasal teması azaltın ve uygun tedavi için dermatoloji uzmanına danışın.',
        ],
        warningFlags: const [
          'Ağrı, şişlik, akıntı veya tırnak ayrılması eşlik ediyorsa gecikmeden doktora başvurun.',
        ],
        confidence: 0.65,
        createdAt: now,
        matchedFindingIds: const ['nail_green_pseudomonas'],
      );
    }

    // Yellowish nail
    if ((h >= 38 && h <= 68 && s >= 0.32) || (lab.b >= 24.0 && lab.a < 15.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Tırnakta Sararma / Kalınlaşma Eğilimi',
        summaryDetail:
            'Sarımsı tırnak tonu en sık tırnak mantarı (onikomikoz) veya sürekli oje/sigara kullanımına bağlıdır; nadiren lenfödem, kronik akciğer veya tiroid sorunlarıyla ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Tırnak yüzeyinde sarı ton doygunluğu yüksek.',
        ],
        recommendations: const [
          'Kalınlaşma, ufalanma veya tırnak yatağından ayrılma eşlik ediyorsa dermatoloğa danışın.',
        ],
        warningFlags: const [],
        confidence: 0.65,
        createdAt: now,
        matchedFindingIds: const ['nail_yellow_thickened'],
      );
    }

    // Intense redness (paronychia / nail fold inflammation)
    if (((h <= 14 || h >= 346) && s >= 0.55) || lab.a >= 36.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Tırnak Çevresinde Yoğun Kızarıklık İpucu',
        summaryDetail:
            'Tırnak veya tırnak etinde belirgin kızarıklık saptandı. Tırnak eti iltihabı (paronişi), batık tırnak veya tahriş ile ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Kırmızı renk yoğunluğu doğal pembe tırnak yatağının üzerinde.',
        ],
        recommendations: const [
          'Tırnak etlerini koparmaktan kaçının; şişlik, ağrı veya akıntı varsa dermatoloji uzmanına başvurun.',
        ],
        warningFlags: const [
          'Zonklayan ağrı, iltihap akıntısı veya diyabet öyküsü varsa gecikmeden tıbbi değerlendirme alın.',
        ],
        confidence: 0.63,
        createdAt: now,
        matchedFindingIds: const ['nail_paronychia_inflamed'],
      );
    }

    // Very pale / white nail bed (Mannino anemia EI + low saturation / high lightness)
    if ((s < 0.14 && v > 0.72) || (nailEi < 5.2 && lab.l > 74.0 && lab.a < 7.5)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Soluk / Yaygın Beyaz Tırnak Tonu',
        summaryDetail:
            'Tırnak yatağı normal pembe tona göre oldukça soluk veya beyaz görünüyor (Eritem İndeksi: ${nailEi.toStringAsFixed(1)}). Işık yansıması değilse demir eksikliği anemisi; tüm tırnaklarda yaygın beyazlaşma varsa karaciğer, böbrek veya albümin/protein düzeyleri açısından değerlendirilebilir.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Düşük renk doygunluğu ve düşük tırnak yatağı Eritem İndeksi (EI=${nailEi.toStringAsFixed(1)} — solukluk ipucu).',
        ],
        recommendations: const [
          'Halsizlik, çabuk yorulma veya birden fazla tırnakta yaygın beyazlaşma varsa tam kan sayımı (hemogram, ferritin, B12) için doktora danışın.',
          'Alt göz kapağı içi (konjonktiva) ve dil kontrolüyle birlikte çoklu solukluk kontrolü yapabilirsiniz.',
        ],
        warningFlags: const [],
        confidence: 0.65,
        createdAt: now,
        matchedFindingIds: const ['nail_pale_bed'],
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
        'Belirgin morarma, yeşerme, aşırı solukluk veya yoğun sararma görülmedi.',
      ],
      recommendations: const [
        'Tırnak bakımı ve dengeli beslenmeye devam edin.',
        'Renk normal görünse bile çomaklaşma (Schamroth pencere testi), kaşık tırnak, enine derin oluk veya yeni dikey koyu çizgi fark ederseniz dermatoloğa danışın.',
      ],
      warningFlags: const [],
      confidence: 0.70,
      createdAt: now,
      matchedFindingIds: const ['nail_healthy_pink'],
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
    // Purple / bluish tongue (central cyanosis / low oxygen / circulation)
    if (h >= 195 && h <= 305 && s >= 0.18) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Mor / Mavimsi Dil Tonu (Siyanoz Uyarısı)',
        summaryDetail:
            'Renkli yiyecek/içecek kaynaklı değilse dilde mor veya mavi renk, kanda oksijen azlığı (siyanoz) ya da dolaşım sorunlarına işaret edebilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Mavi-mor spektrumda doğal pembe mukozadan sapma saptandı.',
        ],
        recommendations: const [
          'Son 30 dakikada boyayıcı gıda/içecek tüketmediyseniz doğal gün ışığında tekrar kontrol edin.',
          'Kalıcı morarma veya mavilik görüyorsanız gecikmeden bir sağlık kuruluşuna başvurun.',
        ],
        warningFlags: const [
          'Nefes darlığı, göğüs ağrısı, baş dönmesi veya dudak morarması eşlik ediyorsa acil servise başvurun.',
        ],
        confidence: 0.68,
        createdAt: now,
        matchedFindingIds: const ['tongue_cyanotic_purple_blue'],
      );
    }

    // Dark brown / black hairy tongue (lingua villosa nigra)
    if (v >= 0.18 && v < 0.34 && s < 0.45) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Koyu Kahverengi / Siyahımsı Dil Tabakası',
        summaryDetail:
            'Yeterli ışık altında çekildiyse bu görünüm çoğunlukla iyi huylu kıllı dil (keratin birikimi), bizmut içeren mide ilaçları, antibiyotik veya tütün/kahve ile ilişkilidir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Dil yüzeyinde düşük parlaklıkta koyu kahverengi/siyah ton ölçüldü.',
        ],
        recommendations: const [
          'Nazik dil fırçalama, bol su tüketimi ve tetikleyici ilaç/tütün gözden geçirmesi genellikle düzelme sağlar.',
          'Renk değişimi 2 haftadan uzun sürüyorsa diş hekimi veya KBB uzmanına danışın.',
        ],
        warningFlags: const [],
        confidence: 0.60,
        createdAt: now,
        matchedFindingIds: const ['tongue_black_hairy'],
      );
    }

    // Greenish coating
    if (h >= 75 && h <= 165 && s >= 0.20) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Dilde Yeşilimsi Kaplama İpucu',
        summaryDetail:
            'Gıda boyası kaynaklı değilse yeşilimsi tabaka bakteri/mantar biyofilm artışı, ağız hijyeni yetersizliği, sigara veya antibiyotik sonrası flora değişimiyle ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Dil yüzeyinde yeşil renk spektrumunda belirgin ton saptandı.',
        ],
        recommendations: const [
          'Düzenli diş ve dil temizliği yapın, yeterli su tüketin.',
          '1–2 hafta içinde gerilemiyorsa veya ağızda yanma/koku eşlik ediyorsa hekime başvurun.',
        ],
        warningFlags: const [],
        confidence: 0.62,
        createdAt: now,
        matchedFindingIds: const ['tongue_greenish_coating'],
      );
    }

    // Whitish coating (oral thrush / dry mouth / hygiene / reflux / leukoplakia)
    if (s < 0.18 && v > 0.68) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Dilde Beyaz Tabaka / Kaplama İpucu',
        summaryDetail:
            'Dil yüzeyinde beyazımsı ton baskın. Ağız kuruluğu, yetersiz su tüketimi, ağız hijyeni, sigara, reflü/sindirim hassasiyeti veya oral mantar (pamukçuk) ile ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Doğal pembe dil tonuna kıyasla düşük doygunluk ve açık beyazımsı yüzey gözlemlendi.',
        ],
        recommendations: const [
          'Su tüketiminizi artırın ve yumuşak fırçayla dil temizliği yapın.',
          'Silinmeyen/kazınmayan kalın beyaz plaklar (lökoplaki riski) veya ağrı varsa diş hekimi/KBB uzmanına görünün.',
        ],
        warningFlags: const [
          'Beyaz tabaka/plak 2 haftadan uzun sürüyorsa veya silinmiyorsa tıbbi değerlendirme gerekir.',
        ],
        confidence: 0.65,
        createdAt: now,
        matchedFindingIds: const ['tongue_thick_white_coating'],
      );
    }

    // Yellow / orange coating (HSV + Lab b* channel)
    if ((h >= 20 && h <= 70 && s >= 0.25) || (lab.b >= 22.0 && lab.a < 18.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Dilde Sarı / Turuncu Kaplama İpucu',
        summaryDetail:
            'Ağız kuruluğu, bakteri/keratin birikimi, çay/kahve/sigara, antibiyotik kullanımı veya reflü/sindirim sistemi hassasiyetleri sarı-turuncu pas tabakasına yol açabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Dil yüzeyinde sarı-turuncu renk ağırlığı tespit edildi.',
        ],
        recommendations: const [
          'Ağız bakımınızı düzenli yapın, bol su tüketin ve 30 dk yeme-içme sonrası gün ışığında tekrar bakın.',
          '2 haftadan uzun süre geçmezse veya mide/reflü şikayetleri eşlik ediyorsa hekime danışın.',
        ],
        warningFlags: const [],
        confidence: 0.63,
        createdAt: now,
        matchedFindingIds: const ['tongue_yellow_orange_coating'],
      );
    }

    // Pale / dull tongue (anemia screening cue)
    if (s < 0.20 && v >= 0.48 && v <= 0.68) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Soluk / Mat Dil Görünümü',
        summaryDetail:
            'Dil tonu canlı doğal pembeden daha soluk görünüyor. Işık kaynaklı değilse demir, B12 veya folik asit eksikliği (kansızlık) açısından takip edilebilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Pembe mukoza doygunluğu olağan aralığın altında ölçüldü.',
        ],
        recommendations: const [
          'Halsizlik, çabuk yorulma veya baş dönmesi eşlik ediyorsa kan sayımı ve vitamin düzeyleri için doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.60,
        createdAt: now,
        matchedFindingIds: const ['tongue_pale_anemic'],
      );
    }

    // Intense red / strawberry / atrophic glossy tongue
    if (((h <= 15 || h >= 345) && s >= 0.55) || lab.a >= 36.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.tongue,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yoğun Kırmızı / Çilek veya Pürüzsüz Dil İpucu',
        summaryDetail:
            'Dil rengi normal pembeden daha yoğun kırmızı görünüyor. B12, folik asit veya demir eksikliği (atrofik glossit), kızıl/ateşli enfeksiyonlar (çilek dil), alerji veya sıcak tahrişiyle ilişkili olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Kırmızı renk yoğunluğu (HSV/CIE a*) doğal pembe aralığın üzerinde ölçüldü.',
        ],
        recommendations: const [
          'Pürüzsüz parlak görünüm, yanma veya ağrı varsa vitamin/kan değerleri için hekime başvurun.',
          '2 haftadan uzun süren kızarıklık veya hassasiyette KBB/diş hekimi muayenesi önerilir.',
        ],
        warningFlags: const [
          'Dil şişmesi, yüksek ateş, yutma/konuşma veya nefes alma güçlüğü varsa acil tıbbi destek alın.',
        ],
        confidence: 0.66,
        createdAt: now,
        matchedFindingIds: const ['tongue_strawberry_or_atrophic_red'],
      );
    }

    return AnalysisResult(
      id: id,
      category: CheckCategory.tongue,
      riskLevel: RiskLevel.normal,
      summaryTitle: 'Dil Rengi Olağan Pembe Tonda',
      summaryDetail:
          'Dil yüzeyinde belirgin beyaz/sarı/yeşil kaplama, morarma veya aşırı kızarıklık saptanmadı.',
      dominantColorValue: color.toARGB32(),
      observations: const [
        'Renk tonu doğal pembe aralığında.',
      ],
      recommendations: const [
        'Düzenli ağız hijyeni ve yeterli sıvı alımını sürdürün.',
        '2 haftadan uzun süren yara, çatlak ağrısı, şişlik veya sertlik fark ederseniz renk normal görünse bile hekime başvurun.',
      ],
      warningFlags: const [],
      confidence: 0.70,
      createdAt: now,
      matchedFindingIds: const ['tongue_healthy_pink'],
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
    final phototype = lab.fitzpatrickPhototype;
    final ita = lab.individualTypologyAngle;

    // Perioral / facial cyanosis (bluish-purple tint)
    if ((h >= 200 && h <= 295 && s >= 0.20) || lab.b <= -8.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Dudak / Yüz Çevresinde Morarma İpucu (Siyanoz)',
        summaryDetail:
            'Soğuk ortam dışı mavimsi-morumsu cilt/dudak tonu oksijenlenme veya dolaşım açısından tıbbi değerlendirme gerektirir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Mavi-mor renk ekseninde belirgin kayma saptandı.',
        ],
        recommendations: const [
          'Doğal gün ışığında dudak ve tırnak renginizi birlikte kontrol edin.',
          'Morarma kalıcıysa gecikmeden sağlık kuruluşuna başvurun.',
        ],
        warningFlags: const [
          'Nefes darlığı, göğüs ağrısı veya baş dönmesi eşlik ediyorsa acil servise başvurun.',
        ],
        confidence: 0.66,
        createdAt: now,
        matchedFindingIds: const ['face_perioral_cyanosis'],
      );
    }

    // Fitzpatrick-adaptive jaundice threshold: darker skin phototypes (IV-VI)
    // naturally have higher b* warm golden undertones; raise b* threshold to
    // prevent false jaundice flags on healthy darker skin.
    final jaundiceBThreshold = phototype.isDarkerSkinOfColor ? 42.0 : 34.0;
    if ((h >= 40 && h <= 65 && s >= 0.42 && !phototype.isDarkerSkinOfColor) ||
        (lab.b >= jaundiceBThreshold && lab.a < 18.0)) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Ciltte Sarımsı Ton Algılandı',
        summaryDetail:
            'Ortam ışığı sarı değilse ciltte belirgin sararma tıbbi değerlendirme gerektirir.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Yüz bölgesinde sarı spektrum ağırlığı yüksek (CIE b*=${lab.b.toStringAsFixed(1)}, ITA=${ita.toStringAsFixed(0)}°).',
        ],
        recommendations: const [
          'Göz akınızı (sklera) da gün ışığında kontrol edin; sarılık sklerada cilt tonundan bağımsız olarak çok daha erken görülür.',
          'Gerçek bir sararma fark ediyorsanız hekime başvurun.',
        ],
        warningFlags: const [
          'Göz akında sararma, koyu idrar veya halsizlik eşlik ediyorsa gecikmeden doktora başvurun.',
        ],
        confidence: 0.62,
        createdAt: now,
        matchedFindingIds: const ['face_jaundice_tint'],
      );
    }

    if (((h <= 15 || h >= 345) && s >= 0.48) || lab.a >= 32.0) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yüzde Kızarıklık / Sıcaklık İpucu',
        summaryDetail:
            'Cilt tonunda belirgin kızarıklık saptandı. Güneş, egzersiz, rozasea, hassasiyet veya ateş kaynaklı olabilir.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Yüz bölgesinde kırmızı ton yoğunluğu yüksek (CIE a*=${lab.a.toStringAsFixed(1)}).',
        ],
        recommendations: const [
          'Ateş, kaşıntı veya döküntü varsa takip edin ve gerekirse doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.64,
        createdAt: now,
        matchedFindingIds: const ['face_flushing_erythema'],
      );
    }

    // Noticeable pallor on fair/intermediate tones
    if (lab.l >= 82.0 && lab.a < 5.5 && s < 0.14) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.face,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Yüzde Solgunluk / Matlık İpucu',
        summaryDetail:
            'Yüz tonunda canlılık/kırmızılık düşük ve belirgin solukluk gözlendi. Yorgunluk, susuzluk veya kansızlık açısından takip edilebilir.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Düşük kırmızı doygunluk ve yüksek açıklık (L*=${lab.l.toStringAsFixed(1)}, a*=${lab.a.toStringAsFixed(1)}).',
        ],
        recommendations: const [
          'Alt göz kapağı içi (konjonktiva) ve tırnak yatağı kontrolünü de birlikte yapabilirsiniz.',
          'Halsizlik veya baş dönmesi eşlik ediyorsa kan sayımı için hekime danışın.',
        ],
        warningFlags: const [],
        confidence: 0.60,
        createdAt: now,
        matchedFindingIds: const ['face_pallor'],
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
      observations: [
        'Cilt tonu dengeli ve doğal aralıkta (Fitzpatrick ${phototype.shortLabel}, ITA ${ita.toStringAsFixed(0)}°).',
      ],
      recommendations: const [
        'Güneş koruyucu kullanımı ve yeterli su alımı cilt sağlığını destekler.',
      ],
      warningFlags: const [],
      confidence: 0.68,
      createdAt: now,
      matchedFindingIds: const ['face_healthy_balanced'],
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
        matchedFindingIds: const ['urine_pink_red_hematuria'],
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
        matchedFindingIds: const ['urine_dark_amber_tea'],
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
        matchedFindingIds: const ['urine_dark_yellow_dehydration'],
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
      matchedFindingIds: const ['urine_healthy_pale_straw'],
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
        matchedFindingIds: const ['stool_black_tarry_melena'],
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
        matchedFindingIds: const ['stool_pale_clay_white'],
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
        matchedFindingIds: const ['stool_bright_red_blood'],
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
        matchedFindingIds: const ['stool_greenish'],
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
        matchedFindingIds: const ['stool_yellow_greasy'],
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
      matchedFindingIds: const ['stool_healthy_brown'],
    );
  }

  /// Dedicated Collings-style lower-eyelid palpebral conjunctiva anemia
  /// screening using hemoglobin Erythema Index (`100 * (log10(R) - log10(G))`)
  /// and CIE `a*`.
  AnalysisResult _evaluatePalpebralConjunctiva({
    required Color color,
    required int r,
    required int g,
    required int b,
    required LabColor lab,
    required StructuralFeatures structural,
    CategoryBaseline? baseline,
  }) {
    final now = DateTime.now();
    final id = 'eye_conj_${now.microsecondsSinceEpoch}';
    final ei = structural.conjunctivaErythemaIndex > 0
        ? structural.conjunctivaErythemaIndex
        : ColorCalibrator.erythemaIndex(r, g);

    // Collings et al. (PLOS ONE): low palpebral conjunctival EI and low CIE a*
    // strongly correlate with hemoglobin < 11.5 g/dL (anemia pallor).
    final isMarkedPallor = ei < 8.5 || (lab.a < 10.5 && lab.l > 66.0);
    final isMildPallor = ei < 13.0 || (lab.a < 15.5 && lab.l > 62.0);

    AnalysisResult res;
    if (isMarkedPallor) {
      res = AnalysisResult(
        id: id,
        category: CheckCategory.eye,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Alt Göz Kapağı İçinde Belirgin Solukluk (Anemi Ön İpucu)',
        summaryDetail:
            'Alt göz kapağı iç mukozası (palpebral konjonktiva) sağlıklı canlı pembe-kırmızı tondan belirgin şekilde soluk ölçüldü (Eritem İndeksi: ${ei.toStringAsFixed(1)}, CIE a*: ${lab.a.toStringAsFixed(1)}). Demir, B12 veya folik asit eksikliğine bağlı kansızlık (anemi) açısından kan tahliliyle değerlendirilmesi önerilir.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Konjonktiva Eritem İndeksi düşük (EI=${ei.toStringAsFixed(1)} — normal referans ≥13).',
          'Mukoza kırmızı kanlanma bileşeni düşük (CIE a*=${lab.a.toStringAsFixed(1)}).',
        ],
        recommendations: const [
          'Halsizlik, çabuk yorulma, üşüme veya baş dönmesi eşlik ediyorsa Dahiliye uzmanına başvurarak tam kan sayımı (HGB, Ferritin, B12) yaptırın.',
          'Tırnak yatağı ve dil kontrolünü de ekleyerek çoklu bölge anemi ön farkındalığını kontrol edebilirsiniz.',
        ],
        warningFlags: const [
          'Şiddetli halsizlik, çarpıntı, nefes darlığı veya baygınlık hissi varsa gecikmeden sağlık kuruluşuna başvurun.',
        ],
        confidence: 0.72,
        createdAt: now,
        matchedFindingIds: const ['eye_conjunctiva_pallor'],
      );
    } else if (isMildPallor) {
      res = AnalysisResult(
        id: id,
        category: CheckCategory.eye,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Alt Göz Kapağı İçinde Hafif Solukluk Eğilimi',
        summaryDetail:
            'Palpebral konjonktiva tonu sınırda/hafif soluk aralıkta ölçüldü (Eritem İndeksi: ${ei.toStringAsFixed(1)}). Doğal gün ışığında tekrar kontrol etmeniz ve şikayetiniz varsa kan değerlerinizi takip etmeniz faydalı olur.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Konjonktiva Eritem İndeksi sınırda (EI=${ei.toStringAsFixed(1)}).',
        ],
        recommendations: const [
          'Doğal gün ışığında tekrar çekim yapın; yorgunluk veya solukluk sürerse hemogram/ferritin kontrolü için doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.66,
        createdAt: now,
        matchedFindingIds: const ['eye_conjunctiva_pallor'],
      );
    } else {
      res = AnalysisResult(
        id: id,
        category: CheckCategory.eye,
        riskLevel: RiskLevel.normal,
        summaryTitle: 'Alt Göz Kapağı (Konjonktiva) Tonu Canlı ve Olağan',
        summaryDetail:
            'Palpebral konjonktiva sağlıklı pembe-kırmızı kanlanma aralığında görünüyor (Eritem İndeksi: ${ei.toStringAsFixed(1)}). Belirgin anemi solukluğu saptanmadı.',
        dominantColorValue: color.toARGB32(),
        observations: [
          'Konjonktiva Eritem İndeksi canlı aralıkta (EI=${ei.toStringAsFixed(1)}, CIE a*=${lab.a.toStringAsFixed(1)}).',
        ],
        recommendations: const [
          'Görsel ön tarama kesin kan sayımı yerine geçmez; halsizlik şikayetiniz varsa rutin kan testi yaptırın.',
        ],
        warningFlags: const [],
        confidence: 0.74,
        createdAt: now,
        matchedFindingIds: const ['eye_healthy_white'],
      );
    }

    if (baseline != null) {
      final comp = baseline.compare(lab);
      res = res.copyWith(
        baselineDeltaE: comp.deltaE,
        baselineComparisonNote: comp.note,
        observations: [...res.observations, comp.note],
      );
    }
    return res;
  }

  /// Merges 2D structural/texture findings (tongue fissures, geographic tongue,
  /// yellow/white coating, eye capillary redness, subconjunctival hemorrhage,
  /// nail white lines/spots, cracks, Beau grooves, Terry/Lindsay split,
  /// splinter hemorrhages, dark vertical nail bands) into [AnalysisResult].
  AnalysisResult _applyStructuralFindings({
    required AnalysisResult result,
    required CheckCategory category,
    required StructuralFeatures structural,
    bool whiteBalanceApplied = false,
  }) {
    final obs = [...result.observations];
    final recs = [...result.recommendations];
    final warns = [...result.warningFlags];
    final findings = [...result.matchedFindingIds];
    var risk = result.riskLevel;
    var title = result.summaryTitle;
    var detail = result.summaryDetail;

    switch (category) {
      case CheckCategory.tongue:
        if (structural.hasGeographicTongueCue) {
          obs.add(
            'Dil yüzeyinde beyaz kenarlı düzensiz kırmızı yamalar — Coğrafi Dil deseni (skor %${(structural.geographicPatchScore * 100).toStringAsFixed(0)}) saptandı.',
          );
          findings.add('tongue_geographic_patches');
          if (risk == RiskLevel.normal) {
            risk = RiskLevel.attention;
            title = 'Coğrafi Dil (Benign Migrator Glossit) Deseni İpucu';
            detail =
                'Dil sırtında beyazımsı kenarlarla çevrili düzensiz kırmızı adacıklar gözlendi. Çoğunlukla tamamen iyi huylu bir varyasyondur; baharatlı/asitli gıdalarda hassasiyet yapabilir.';
            recs.add(
              'Harita benzeri lekelerin günler içinde yer değiştirip değiştirmediğini izleyin; ağrı, yanma veya 2 haftadan uzun süren sabit lezyon varsa diş hekimi/KBB uzmanına danışın.',
            );
          }
        }
        if (structural.hasTongueFissures) {
          obs.add(
            'Dil yüzeyinde çizgisel yarık / çatlak dokusu (fissür oranı %${(structural.fissureGrooveRatio * 100).toStringAsFixed(1)}) saptandı.',
          );
          findings.add('tongue_fissured_grooves');
          if (risk == RiskLevel.normal) {
            risk = RiskLevel.attention;
            title = 'Dilde Yarık / Çatlak Görünümü (Fissürlü Dil İpucu)';
            detail =
                'Dil yüzeyinde belirgin oluk/yarık dokusu algılandı. Çoğunlukla zararsız (coğrafi/fissürlü dil) olabilse de ağız kuruluğu, susuzluk veya B vitamini/demir eksiklikleriyle ilişkili olabilir.';
            recs.add(
              'Günlük su tüketimini artırın, dil yüzeyini nazikçe fırçalayın ve yanma/ağrı varsa dahiliye veya diş hekimine danışın.',
            );
          }
        }
        if (structural.hasTongueYellowCoating && risk == RiskLevel.normal) {
          obs.add(
            'Dil üzerinde bölgesel sarımsı pas/biyofilm tabakası (%${(structural.yellowCoatingRatio * 100).toStringAsFixed(0)}) gözlendi.',
          );
          findings.add('tongue_yellow_orange_coating');
          risk = RiskLevel.attention;
          title = 'Dilde Bölgesel Sarımsı Pas Tabakası İpucu';
          detail =
              'Dil yüzeyinin bir bölümünde sarımsı tabaka tespit edildi. Ağız kuruluğu, kahve/çay/sigara, antibiyotik veya reflü hassasiyetine bağlı olabilir.';
        } else if (structural.hasTongueCoatingPatch && risk == RiskLevel.normal) {
          obs.add(
            'Dil üzerinde bölgesel açık renkli pas/tabaka kaplaması (%${(structural.coatingPatchRatio * 100).toStringAsFixed(0)}) gözlendi.',
          );
          findings.add('tongue_thick_white_coating');
          risk = RiskLevel.attention;
          title = 'Dilde Bölgesel Beyaz/Sarı Pas Tabakası İpucu';
          detail =
              'Dil yüzeyinin bir bölümünde açık renkli tabaka tespit edildi. Susuzluk, ağız kuruluğu veya geçici oral flora değişikliğine bağlı olabilir.';
        }
      case CheckCategory.eye:
        if (structural.hasSubconjunctivalHemorrhage) {
          obs.add(
            'Sklera üzerinde keskin sınırlı yoğun parlak kırmızı kanama alanı (%${(structural.hemorrhagePatchRatio * 100).toStringAsFixed(1)}) saptandı.',
          );
          findings.add('eye_subconjunctival_hemorrhage');
          risk = RiskLevel.urgent;
          title = 'Göz Akında Odaklanmış Kanama Lekesi (Subkonjonktival Kanama İpucu)';
          detail =
              'Göz akında yaygın ince damarlanmadan farklı olarak yoğun, keskin sınırlı parlak kırmızı bir alan tespit edildi. Öksürük/zorlanma veya yüksek tansiyon kaynaklı subkonjonktival kanama olabilir.';
          recs.add(
            'Tansiyonunuzu ölçün ve gözünüzü ovalamayın; kan sulandırıcı kullanıyorsanız veya travma olduysa göz hekimine başvurun.',
          );
          warns.add(
            'Görme bulanıklığı, şiddetli göz ağrısı, travma veya tekrarlayan kanamalar varsa acil göz muayenesi gerekir.',
          );
        } else if (structural.hasEyeRedVessels) {
          obs.add(
            'Göz akında (sklera) kılcal damar kanlanması / kızarıklık (%${(structural.scleraVesselRatio * 100).toStringAsFixed(1)}) tespit edildi.',
          );
          findings.add('eye_mild_redness');
          if (risk == RiskLevel.normal) {
            risk = RiskLevel.attention;
            title = 'Göz Akında Kılcal Kanlanma / Kızarıklık İpucu';
            detail =
                'Beyaz sklera üzerinde belirgin kırmızı damarlanma/kanlanma algılandı. Göz yorgunluğu, kuruluk, alerji, uykusuzluk veya konjonktivit ile ilişkili olabilir.';
            recs.add(
              'Ekran molası verin, gözlerinizi ovalamayın; kanlanma 24–48 saat içinde geçmezse göz hekimine başvurun.',
            );
            warns.add(
              'Göz ağrısı, ışığa hassasiyet, görme bulanıklığı veya akıntı eşlik ediyorsa gecikmeden göz doktoruna görünün.',
            );
          }
        }
        if (structural.hasEyeYellowPatch &&
            !whiteBalanceApplied &&
            structural.scleraYellowRatio < 0.85 &&
            risk == RiskLevel.normal) {
          obs.add(
            'Sklera kenarlarında bölgesel sarımsı ton artışı (%${(structural.scleraYellowRatio * 100).toStringAsFixed(1)}) gözlendi.',
          );
          findings.add('eye_localized_yellow_spot');
          risk = RiskLevel.attention;
          title = 'Göz Akında Bölgesel Sarımsı Ton İpucu';
          detail =
              'Göz akının bir kısmında sarımsı renk kayması saptandı. Güneş kaynaklı pinguekula olabileceği gibi doğal gün ışığında tekrar kontrol edilmesi ve sürüyorsa hekime danışılması önerilir.';
        }
      case CheckCategory.nail:
        if (structural.hasNailDarkVerticalBand) {
          obs.add(
            'Tırnak plağında dar dikey koyu pigment bandı (skor %${(structural.darkVerticalBandScore * 100).toStringAsFixed(0)}) saptandı.',
          );
          findings.add('nail_dark_vertical_band');
          risk = RiskLevel.urgent;
          title = 'Tırnakta Dikey Koyu Çizgi (Melanoniki Uyarısı)';
          detail =
              'Tırnak boyunca uzanan koyu kahverengi/siyah dikey bant algılandı. Travma veya ilaç kaynaklı olabileceği gibi özellikle tek tırnakta genişliyorsa cilt kanseri (melanom) açısından dermatolojik inceleme gerekir.';
          recs.add(
            'Bilinen bir darbe yoksa vakit kaybetmeden bir Dermatoloji (Cildiye) uzmanına muayene olun.',
          );
          warns.add(
            'Koyu çizgi 3 mm’den genişse, düzensiz koyulaşıyorsa veya tırnak dibi etine taşıyorsa (Hutchinson işareti) acil dermatoloji değerlendirmesi önerilir.',
          );
        } else if (structural.hasSplinterHemorrhage) {
          obs.add(
            'Tırnak altında ince dikey koyu kırmızı kıymık benzeri çizgiler (oran %${(structural.splinterStreakRatio * 100).toStringAsFixed(1)}) saptandı.',
          );
          findings.add('nail_splinter_hemorrhage');
          risk = RiskLevel.urgent;
          title = 'Tırnak Altında İnce Kırmızı/Kahverengi Kıymık Çizgileri İpucu';
          detail =
              'Tırnak plağı altında uzunlamasına uzanan ince kıymık benzeri kırmızı-kahverengi mikro çizgiler algılandı. Tek tırnakta darbe kaynaklı olabilir; birden fazla tırnakta travmasız görülüyorsa dahiliye değerlendirmesi önemlidir.';
          recs.add(
            'Yakın zamanda tırnak travması yaşamadıysanız ve birden fazla tırnakta görülüyorsa Dahiliye veya Dermatoloji uzmanına başvurun.',
          );
          warns.add(
            'Ateş, halsizlik veya birden fazla tırnakta kendiliğinden kıymık kanamaları eşlik ediyorsa gecikmeden doktora başvurun.',
          );
        } else {
          if (structural.hasTerryOrLindsaySplit) {
            obs.add(
              'Tırnak kökünde yaygın beyazlık ve uçta koyu pembe/kahverengi bant ayrımı (Terry/Lindsay skoru %${(structural.proximalDistalSplitScore * 100).toStringAsFixed(0)}) gözlendi.',
            );
            findings.add('nail_terry_or_half_and_half');
            if (risk == RiskLevel.normal) {
              risk = RiskLevel.attention;
              title = 'Yaygın Beyaz / Yarım-Yarım Tırnak Deseni (Terry / Lindsay İpucu)';
              detail =
                  'Tırnağın gövdesinde belirgin beyazlaşma ve uç kısmında daha koyu şerit ayrımı algılandı. Birden fazla tırnakta görülüyorsa karaciğer, böbrek veya protein/albümin düzeyleri açısından Dahiliye kontrolü önerilir.';
              recs.add(
                'Tüm el tırnaklarınızda benzer görünüm varsa karaciğer/böbrek biyokimyası ve tam kan sayımı için Dahiliye uzmanına danışın.',
              );
            }
          }
          if (structural.hasNailTransverseGroove) {
            obs.add(
              'Tırnak boyunca enine derin çöküntü / oluk (Beau çizgisi skoru %${(structural.transverseGrooveScore * 100).toStringAsFixed(0)}) tespit edildi.',
            );
            findings.add('nail_pitting_or_ridges');
            if (risk == RiskLevel.normal) {
              risk = RiskLevel.attention;
              title = 'Tırnakta Enine Oluklanma (Beau Çizgisi İpucu)';
              detail =
                  'Tırnak plağını yatay kesen derin oluk/çöküntü dokusu saptandı. Geçirilmiş yüksek ateşli enfeksiyon, yoğun stres, beslenme/çinko eksikliği veya sistemik hastalık sonrası geçici tırnak büyüme duraksamasına işaret edebilir.';
              recs.add(
                'Birden fazla tırnakta aynı hizada enine oluk görüyorsanız son 2–3 aydaki sağlık öykünüzle birlikte Dahiliye veya Dermatoloji uzmanına danışın.',
              );
            }
          }
          if (structural.hasNailWhiteLinesOrSpots) {
            obs.add(
              'Tırnak plağında beyaz nokta / yatay beyaz çizgi kontrastı (%${(structural.whiteLineSpotRatio * 100).toStringAsFixed(1)}) tespit edildi.',
            );
            findings.add('nail_white_spots_leukonychia');
            if (risk == RiskLevel.normal) {
              risk = RiskLevel.attention;
              title = 'Tırnakta Beyaz Çizgi / Nokta (Lökoniki İpucu)';
              detail =
                  'Pembe tırnak yüzeyi üzerinde belirgin beyaz nokta veya enine beyaz çizgi algılandı. Küçük noktalar çoğunlukla hafif darbelere bağlıdır; yaygın/enine beyaz bantlar çinko, protein veya mineral eksikliği açısından değerlendirilebilir.';
              recs.add(
                'Tırnağı darbelerden koruyun; birden fazla tırnakta tekrarlayan beyaz çizgiler varsa kan tahlili (çinko, ferritin, B12, albümin) için hekime danışın.',
              );
            }
          }
          if (structural.hasNailCracksOrRoughness) {
            obs.add(
              'Tırnak yüzeyinde/ucunda kırılma, soyulma veya pürüzlü oluk dokusu (pürüzlülük %${(structural.fractureEdgeRoughness * 100).toStringAsFixed(0)}) saptandı.',
            );
            findings.add('nail_brittle_splitting_vertical');
            if (risk == RiskLevel.normal) {
              risk = RiskLevel.attention;
              title = 'Tırnakta Kırılma / Soyulma / Yüzey Pürüzlülüğü';
              detail =
                  'Tırnak plağında veya serbest kenarda kırık, katmanlı soyulma ya da enine oluklanma (Beau çizgisi/pürüzlülük) dokusu algılandı. Sık su/kimyasal teması dışında demir, biyotin, çinko, B12 eksikliği veya tiroid sorunlarıyla ilişkili olabilir.';
              recs.add(
                'Temizlikte eldiven kullanın, tırnak ve etlerini düzenli nemlendirin; kırılma yaygın ve kalıcıysa dermatoloji veya dahiliye değerlendirmesi alın.',
              );
            }
          }
        }
      default:
        break;
    }

    // If an abnormal finding was added, remove generic healthy fallback IDs.
    final deduplicatedFindings = findings.toSet().toList();
    if (risk != RiskLevel.normal && deduplicatedFindings.length > 1) {
      deduplicatedFindings.removeWhere((id) => id.contains('_healthy_'));
    }

    return result.copyWith(
      riskLevel: risk,
      summaryTitle: title,
      summaryDetail: detail,
      observations: obs.toSet().toList(),
      recommendations: recs.toSet().toList(),
      warningFlags: warns.toSet().toList(),
      matchedFindingIds: deduplicatedFindings,
    );
  }

  Map<String, String> _buildColorAndStructuralMetrics({
    required CheckCategory category,
    required int r,
    required int g,
    required int b,
    required LabColor lab,
    required StructuralFeatures structural,
    required EyeScanMode eyeScanMode,
  }) {
    final ei = ColorCalibrator.erythemaIndex(r, g);
    switch (category) {
      case CheckCategory.eye:
        if (eyeScanMode == EyeScanMode.palpebralConjunctiva) {
          final conjEi = structural.conjunctivaErythemaIndex > 0
              ? structural.conjunctivaErythemaIndex
              : ei;
          return {
            'Tarama Modu': 'Alt Göz Kapağı (Anemi)',
            'Konjonktiva Eritem İndeksi': conjEi.toStringAsFixed(1),
            'CIE a* (Kırmızılık)': lab.a.toStringAsFixed(1),
            'CIE L* (Aydınlık)': lab.l.toStringAsFixed(1),
          };
        }
        return {
          'Sklera Sarılık (b*)': lab.b.toStringAsFixed(1),
          'BiliScreen İndeksi': structural.scleralBilirubinIndex.toStringAsFixed(1),
          'Kılcal Damar Oranı':
              '%${(structural.scleraVesselRatio * 100).toStringAsFixed(1)}',
          if (structural.hemorrhagePatchRatio > 0)
            'Kanama Odağı':
                '%${(structural.hemorrhagePatchRatio * 100).toStringAsFixed(1)}',
        };
      case CheckCategory.nail:
        final nailEi =
            structural.nailErythemaIndex > 0 ? structural.nailErythemaIndex : ei;
        return {
          'Tırnak Eritem İndeksi (Anemi)': nailEi.toStringAsFixed(1),
          if (structural.nailSkinEiDelta != 0)
            'Tırnak–Deri Bağıl ΔEI':
                structural.nailSkinEiDelta.toStringAsFixed(1),
          'Beyaz Nokta/Çizgi':
              '%${(structural.whiteLineSpotRatio * 100).toStringAsFixed(1)}',
          'Yüzey Pürüzlülük':
              '%${(structural.fractureEdgeRoughness * 100).toStringAsFixed(0)}',
          if (structural.darkVerticalBandScore > 0)
            'Dikey Bant Skoru':
                '%${(structural.darkVerticalBandScore * 100).toStringAsFixed(0)}',
          if (structural.transverseGrooveScore > 0)
            'Beau Enine Oluk':
                '%${(structural.transverseGrooveScore * 100).toStringAsFixed(0)}',
          if (structural.proximalDistalSplitScore > 0)
            'Terry/Lindsay Ayrım':
                '%${(structural.proximalDistalSplitScore * 100).toStringAsFixed(0)}',
        };
      case CheckCategory.tongue:
        return {
          'Fissür / Çatlak Oranı':
              '%${(structural.fissureGrooveRatio * 100).toStringAsFixed(1)}',
          'Pas / Kaplama Oranı':
              '%${(structural.coatingPatchRatio * 100).toStringAsFixed(0)}',
          'Mukoza Eritem İndeksi': (structural.mucosalErythemaIndex > 0
                  ? structural.mucosalErythemaIndex
                  : ei)
              .toStringAsFixed(1),
          if (structural.geographicPatchScore > 0)
            'Coğrafi Dil Deseni':
                '%${(structural.geographicPatchScore * 100).toStringAsFixed(0)}',
        };
      case CheckCategory.face:
        return {
          'Fitzpatrick Fototip': lab.fitzpatrickPhototype.shortLabel,
          'ITA° Açısı': '${lab.individualTypologyAngle.toStringAsFixed(0)}°',
          'Eritem İndeksi': ei.toStringAsFixed(1),
          if (structural.faceMalarEiDelta != 0)
            'Yanak–Alın ΔEI': structural.faceMalarEiDelta.toStringAsFixed(1),
          'CIE b* (Sarı Eksen)': lab.b.toStringAsFixed(1),
        };
      case CheckCategory.urine:
        final level = armstrongHydrationLevel(lab);
        return {
          'Armstrong Hidrasyon Skalası': '$level / 8',
          'Bulanıklık Skoru':
              '%${(structural.urineTurbidityScore * 100).toStringAsFixed(0)}',
          'CIE L* / a* / b*':
              '${lab.l.toStringAsFixed(0)} / ${lab.a.toStringAsFixed(0)} / ${lab.b.toStringAsFixed(0)}',
        };
      case CheckCategory.stool:
      case CheckCategory.skinCondition:
        return {
          'CIE L* / a* / b*':
              '${lab.l.toStringAsFixed(0)} / ${lab.a.toStringAsFixed(0)} / ${lab.b.toStringAsFixed(0)}',
        };
    }
  }

  /// Matches a calibrated urine [LabColor] to the 8-step Armstrong Clinical
  /// Urine Hydration Chart (1 = very pale hydrated .. 8 = dark amber/brownish)
  /// using ISO/CIE CIEDE2000 perceptual distance.
  static int armstrongHydrationLevel(LabColor lab) {
    const prototypes = <LabColor>[
      LabColor(l: 96, a: -2, b: 8), // 1: Very pale straw (well hydrated)
      LabColor(l: 94, a: -3, b: 22), // 2: Pale straw (hydrated)
      LabColor(l: 91, a: -2, b: 38), // 3: Light yellow (normal)
      LabColor(l: 86, a: 1, b: 54), // 4: Yellow (mild dehydration)
      LabColor(l: 79, a: 6, b: 64), // 5: Deep yellow (dehydrated)
      LabColor(l: 69, a: 14, b: 62), // 6: Amber (noticeably dehydrated)
      LabColor(l: 56, a: 18, b: 50), // 7: Dark amber
      LabColor(l: 42, a: 16, b: 32), // 8: Brownish dark amber
    ];
    var bestIdx = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < prototypes.length; i++) {
      final d = lab.deltaE2000(prototypes[i]);
      if (d < bestDist) {
        bestDist = d;
        bestIdx = i;
      }
    }
    return bestIdx + 1;
  }
}
