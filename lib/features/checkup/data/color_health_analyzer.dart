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

    final structural = StructuralFeatureAnalyzer.analyze(
      image: decoded,
      category: category,
    );
    result = _applyStructuralFindings(
      result: result,
      category: category,
      structural: structural,
      whiteBalanceApplied: sample.whiteBalanceApplied,
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
      );
    }

    // Very pale / white nail bed (anemia / Terry / Lindsay)
    if (s < 0.14 && v > 0.72) {
      return AnalysisResult(
        id: id,
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Soluk / Yaygın Beyaz Tırnak Tonu',
        summaryDetail:
            'Tırnak yatağı normal pembe tona göre oldukça soluk veya beyaz görünüyor. Işık yansıması değilse demir eksikliği anemisi; tüm tırnaklarda yaygın beyazlaşma varsa karaciğer, böbrek veya albümin/protein düzeyleri açısından değerlendirilebilir.',
        dominantColorValue: color.toARGB32(),
        observations: const [
          'Düşük renk doygunluğu ve yüksek parlaklık (soluk/beyaz görünüm).',
        ],
        recommendations: const [
          'Halsizlik, çabuk yorulma veya birden fazla tırnakta yaygın beyazlaşma varsa kan sayımı ve biyokimya için doktora danışın.',
        ],
        warningFlags: const [],
        confidence: 0.62,
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
        'Belirgin morarma, yeşerme, aşırı solukluk veya yoğun sararma görülmedi.',
      ],
      recommendations: const [
        'Tırnak bakımı ve dengeli beslenmeye devam edin.',
        'Renk normal görünse bile çomaklaşma (saat camı bombeleşmesi), kaşık tırnak, enine derin oluk veya yeni dikey koyu çizgi fark ederseniz dermatoloğa danışın.',
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

  /// Merges 2D structural/texture findings (tongue fissures, eye capillary
  /// redness, nail white lines/spots, nail cracks/roughness, dark vertical
  /// nail bands) into the color-based [AnalysisResult].
  AnalysisResult _applyStructuralFindings({
    required AnalysisResult result,
    required CheckCategory category,
    required StructuralFeatures structural,
    bool whiteBalanceApplied = false,
  }) {
    final obs = [...result.observations];
    final recs = [...result.recommendations];
    final warns = [...result.warningFlags];
    var risk = result.riskLevel;
    var title = result.summaryTitle;
    var detail = result.summaryDetail;

    switch (category) {
      case CheckCategory.tongue:
        if (structural.hasTongueFissures) {
          obs.add(
            'Dil yüzeyinde çizgisel yarık / çatlak dokusu (fissür oranı %${(structural.fissureGrooveRatio * 100).toStringAsFixed(1)}) saptandı.',
          );
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
        if (structural.hasTongueCoatingPatch && risk == RiskLevel.normal) {
          obs.add(
            'Dil üzerinde bölgesel açık renkli pas/tabaka kaplaması (%${(structural.coatingPatchRatio * 100).toStringAsFixed(0)}) gözlendi.',
          );
          risk = RiskLevel.attention;
          title = 'Dilde Bölgesel Beyaz/Sarı Pas Tabakası İpucu';
          detail =
              'Dil yüzeyinin bir bölümünde açık renkli tabaka tespit edildi. Susuzluk, ağız kuruluğu veya geçici oral flora değişikliğine bağlı olabilir.';
        }
      case CheckCategory.eye:
        if (structural.hasEyeRedVessels) {
          obs.add(
            'Göz akında (sklera) kılcal damar kanlanması / kızarıklık (%${(structural.scleraVesselRatio * 100).toStringAsFixed(1)}) tespit edildi.',
          );
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
          risk = RiskLevel.attention;
          title = 'Göz Akında Bölgesel Sarımsı Ton İpucu';
          detail =
              'Göz akının bir kısmında sarımsı renk kayması saptandı. Doğal gün ışığında tekrar kontrol edilmesi ve sürüyorsa hekime danışılması önerilir.';
        }
      case CheckCategory.nail:
        if (structural.hasNailDarkVerticalBand) {
          obs.add(
            'Tırnak plağında dar dikey koyu pigment bandı (skor %${(structural.darkVerticalBandScore * 100).toStringAsFixed(0)}) saptandı.',
          );
          risk = RiskLevel.urgent;
          title = 'Tırnakta Dikey Koyu Çizgi (Melanoniki Uyarısı)';
          detail =
              'Tırnak boyunca uzanan koyu kahverengi/siyah dikey bant algılandı. Travma veya ilaç kaynaklı olabileceği gibi özellikle tek tırnakta genişliyorsa cilt kanseri (melanom) açısından dermatolojik inceleme gerekir.';
          recs.add(
            'Bilinen bir darbe yoksa vakit kaybetmeden bir Dermatoloji (Cildiye) uzmanına muayene olun.',
          );
          warns.add(
            'Koyu çizgi 3 mm’den genişse, düzensiz koyulaşıyorsa veya tırnak dibi etine taşıyorsa acil dermatoloji değerlendirmesi önerilir.',
          );
        } else {
          if (structural.hasNailWhiteLinesOrSpots) {
            obs.add(
              'Tırnak plağında beyaz nokta / yatay beyaz çizgi kontrastı (%${(structural.whiteLineSpotRatio * 100).toStringAsFixed(1)}) tespit edildi.',
            );
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

    return result.copyWith(
      riskLevel: risk,
      summaryTitle: title,
      summaryDetail: detail,
      observations: obs.toSet().toList(),
      recommendations: recs.toSet().toList(),
      warningFlags: warns.toSet().toList(),
    );
  }
}
