import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/ai/image_preprocessor.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Token-efficient hybrid analyzer pipeline:
///
/// 1. Runs 0-token [ImagePreprocessor] quality gate (rejects blurry, overly
///    dark, or blown-out frames locally so zero API tokens are wasted).
/// 2. Crops & resizes the image (512px/768px JPEG) and checks [cacheRepository]
///    by content fingerprint (0 tokens on duplicate gallery images).
/// 3. If [aiClient] is configured and [AnalysisOptions.allowCloudAi] is true,
///    sends the compressed JPEG + compact rubric + CIE Lab telemetry using
///    tiered model routing (Flash-Lite vs Flash).
/// 4. Transparently falls back to [fallbackAnalyzer] offline, on opt-out, or on
///    API error.
class HybridHealthAnalyzer implements HealthAnalyzer {
  const HybridHealthAnalyzer({
    required this.fallbackAnalyzer,
    this.aiClient,
    this.cacheRepository,
    this.skinContext,
  });

  final HealthAnalyzer fallbackAnalyzer;
  final VisionAiClient? aiClient;
  final HistoryRepository? cacheRepository;
  final SkinCheckContext? skinContext;

  @override
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
    AnalysisOptions options = const AnalysisOptions(),
  }) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw FormatException(
        options.languageCode == 'tr'
            ? 'Görüntü çözümlenemedi.'
            : 'Image could not be decoded.',
      );
    }

    final preprocessed = ImagePreprocessor.prepare(
      decoded: decoded,
      category: category,
      preserveWhiteRefStrip: options.useWhiteReference,
    );

    final sample = ColorCalibrator.sampleImage(
      image: decoded,
      useWhiteReference: options.useWhiteReference,
    );

    // 0-token local quality gate: never burn Vision AI tokens on unusable shots.
    if (!preprocessed.passesQualityGate) {
      return _buildQualityGateResult(
        category: category,
        issue: preprocessed.qualityIssue,
        dominantColorValue: sample.calibratedColor.toARGB32(),
        languageCode: options.languageCode,
      );
    }

    final client = aiClient;
    if (client == null || !options.allowCloudAi) {
      return fallbackAnalyzer.analyzeImage(
        category: category,
        imageBytes: imageBytes,
        options: options,
      );
    }

    // 0-token duplicate-image cache lookup
    final cache = cacheRepository;
    if (cache != null) {
      final cached = await cache.getCachedAiResult(
        preprocessed.contentFingerprint,
      );
      if (cached != null) {
        return cached;
      }
    }

    double? baselineDeltaE;
    String? baselineNote;
    if (options.baseline != null) {
      final comp = options.baseline!.compare(sample.lab);
      baselineDeltaE = comp.deltaE;
      baselineNote = comp.note;
    }

    final structural = StructuralFeatureAnalyzer.analyze(
      image: decoded,
      category: category,
      gains: sample.gains,
    );

    final request = AiVisionPromptBuilder.build(
      category: category,
      imageBytes: preprocessed.jpegBytes,
      mimeType: 'image/jpeg',
      languageCode: options.languageCode,
      calibratedSample: sample,
      structuralFeatures: structural,
      baseline: options.baseline,
      skinContext: skinContext,
    );

    final isTr = options.languageCode == 'tr';
    final aiClinicalMetrics = <String, String>{
      'CIE L* / a* / b*':
          '${sample.lab.l.toStringAsFixed(0)} / ${sample.lab.a.toStringAsFixed(0)} / ${sample.lab.b.toStringAsFixed(0)}',
      if (category == CheckCategory.face ||
          category == CheckCategory.skinCondition)
        isTr ? 'Fitzpatrick Fototip' : 'Fitzpatrick Phototype':
            '${sample.lab.fitzpatrickPhototype.shortLabel} (ITA ${sample.lab.individualTypologyAngle.toStringAsFixed(0)}°)',
      if (category == CheckCategory.eye &&
          options.eyeScanMode == EyeScanMode.palpebralConjunctiva)
        isTr ? 'Tarama Modu' : 'Scan Mode': isTr
            ? 'Alt Göz Kapağı (Anemi)'
            : 'Lower Eyelid (Anemia)',
    };

    try {
      final rawJson = await client.analyzeWithVisionAi(request);
      final parsed = AiVisionResponseParser.parse(
        rawResponse: rawJson,
        category: category,
        dominantColorValue: sample.calibratedColor.toARGB32(),
        whiteBalanceCalibrated: sample.whiteBalanceApplied,
        lightingNote: sample.lightingNote,
        baselineDeltaE: baselineDeltaE,
        baselineComparisonNote: baselineNote,
        clinicalMetrics: aiClinicalMetrics,
      );
      if (cache != null) {
        await cache.saveCachedAiResult(preprocessed.contentFingerprint, parsed);
      }
      return parsed;
    } catch (error) {
      debugPrint(
        'HybridHealthAnalyzer Vision AI failed (${category.name}), falling back to on-device analyzer: $error',
      );
      return fallbackAnalyzer.analyzeImage(
        category: category,
        imageBytes: imageBytes,
        options: options,
      );
    }
  }

  AnalysisResult _buildQualityGateResult({
    required CheckCategory category,
    required ImageQualityIssue issue,
    required int dominantColorValue,
    required String languageCode,
  }) {
    final now = DateTime.now();
    final id = '${category.id}_gate_${now.microsecondsSinceEpoch}';
    final copy = QualityGateLocalizedCopy.resolve(issue, languageCode);

    return AnalysisResult(
      id: id,
      category: category,
      // Quality-gate rejection is a neutral retake prompt, not a medical risk.
      riskLevel: RiskLevel.normal,
      summaryTitle: copy.title,
      summaryDetail: copy.detail,
      dominantColorValue: dominantColorValue,
      observations: copy.observations,
      recommendations: copy.recommendations,
      warningFlags: const [],
      confidence: issue == ImageQualityIssue.tooBlurry ? 0.20 : 0.22,
      createdAt: now,
    );
  }
}

/// 15-language localized copy for image quality-gate retake prompts.
class QualityGateLocalizedCopy {
  const QualityGateLocalizedCopy({
    required this.title,
    required this.detail,
    required this.observations,
    required this.recommendations,
  });

  final String title;
  final String detail;
  final List<String> observations;
  final List<String> recommendations;

  static QualityGateLocalizedCopy resolve(
    ImageQualityIssue issue,
    String languageCode,
  ) {
    final lang = languageCode.toLowerCase();
    switch (issue) {
      case ImageQualityIssue.tooBlurry:
        if (lang == 'tr') {
          return const QualityGateLocalizedCopy(
            title: 'Görüntü Bulanık — Tekrar Çekin',
            detail:
                'Odak yeterince net olmadığı için yüzey detayları okunamadı. Gereksiz veri aktarımı yapılmadan analiz durduruldu.',
            observations: [
              'Kamerada hareket veya odak kaybı (bulanıklık) tespit edildi.',
            ],
            recommendations: [
              'Telefonu sabit tutun ve hedefe 10–15 cm mesafeden dokunarak odaklayın.',
              'Yeterli gün ışığı altında çekimi tekrarlayın.',
            ],
          );
        }
        return QualityGateLocalizedCopy(
          title: _blurTitle(lang),
          detail: _blurDetail(lang),
          observations: [_blurObs(lang)],
          recommendations: [_blurRec1(lang), _daylightRec(lang)],
        );

      case ImageQualityIssue.overexposed:
        if (lang == 'tr') {
          return const QualityGateLocalizedCopy(
            title: 'Aşırı Parlama / Flaş Yansıması',
            detail:
                'Görüntüde aşırı ışık parlaması olduğu için gerçek renk tonu okunamadı.',
            observations: [
              'Merkez bölgede yüksek oranda beyaz ışık patlaması saptandı.',
            ],
            recommendations: [
              'Flaşı kapatın ve doğrudan sert ışık yerine dolaylı gün ışığında tekrar çekin.',
            ],
          );
        }
        return QualityGateLocalizedCopy(
          title: _glareTitle(lang),
          detail: _glareDetail(lang),
          observations: [_glareObs(lang)],
          recommendations: [_glareRec(lang)],
        );

      case ImageQualityIssue.tooDark:
      case ImageQualityIssue.none:
        if (lang == 'tr') {
          return const QualityGateLocalizedCopy(
            title: 'Ortam Işığı Yetersiz',
            detail:
                'Görüntü çok karanlık olduğu için renk tonu ve detaylar güvenilir şekilde okunamadı.',
            observations: [
              'Merkez bölgede parlaklık eşik değerinin altında.',
            ],
            recommendations: [
              'Doğal gün ışığı alan aydınlık bir ortamda çekimi tekrarlayın.',
              'Gölge düşmemesine dikkat edin.',
            ],
          );
        }
        return QualityGateLocalizedCopy(
          title: lowLightTitle(lang),
          detail: lowLightDetail(lang),
          observations: [lowLightObs(lang)],
          recommendations: [_daylightRec(lang), _shadowRec(lang)],
        );
    }
  }

  static String _blurTitle(String lang) => switch (lang) {
        'de' => 'Bild unscharf — Bitte erneut aufnehmen',
        'es' => 'Imagen borrosa — Vuelva a capturar',
        'fr' => 'Image floue — Veuillez reprendre la photo',
        'it' => 'Immagine sfocata — Scatta di nuovo',
        'nl' => 'Beeld onscherp — Maak opnieuw een foto',
        'sv' => 'Suddig bild — Ta bilden igen',
        'pt' => 'Imagem desfocada — Tire novamente',
        'ru' => 'Снимок размыт — Сделайте фото повторно',
        'ar' => 'الصورة غير واضحة — يرجى إعادة الالتقاط',
        'zh' => '图像模糊 — 请重新拍摄',
        'hi' => 'छवि धुंधली है — कृपया पुनः फ़ोटो लें',
        'bn' => 'ছবি ঝাপসা — অনুগ্রহ করে আবার তুলুন',
        'ur' => 'تصویر دھندلی ہے — براہ کرم دوبارہ کھینچیں',
        _ => 'Image Blurry — Please Retake',
      };

  static String _blurDetail(String lang) => switch (lang) {
        'de' =>
          'Oberflächendetails konnten mangels Schärfe nicht zuverlässig gelesen werden.',
        'es' =>
          'No se pudieron leer los detalles por falta de enfoque nítido.',
        'fr' =>
          'Les détails de surface ne sont pas lisibles en raison du flou.',
        'ru' =>
          'Детали поверхности не удалось прочитать из-за недостаточной резкости.',
        'ar' => 'تعذر قراءة تفاصيل السطح بسبب عدم وضوح التركيز.',
        'zh' => '由于对焦不清晰，无法可靠读取表面细节。',
        _ =>
          'Surface details could not be read reliably due to insufficient focus.',
      };

  static String _blurObs(String lang) => switch (lang) {
        'de' => 'Bewegungsunschärfe oder Fokusverlust erkannt.',
        'es' => 'Se detectó desenfoque o movimiento de la cámara.',
        'fr' => 'Flou de mouvement ou perte de mise au point détecté.',
        'ru' => 'Обнаружено смазывание или потеря фокуса.',
        'ar' => 'تم رصد اهتزاز الكاميرا أو فقدان التركيز.',
        'zh' => '检测到相机晃动或失焦。',
        _ => 'Camera motion blur or focus loss detected.',
      };

  static String _blurRec1(String lang) => switch (lang) {
        'de' =>
          'Halten Sie das Telefon ruhig und tippen Sie aus 10–15 cm Entfernung zum Fokussieren.',
        'es' =>
          'Mantenga el teléfono firme y toque para enfocar a 10–15 cm de distancia.',
        'fr' =>
          'Tenez le téléphone immobile et touchez pour faire la mise au point à 10–15 cm.',
        'ru' =>
          'Держите телефон неподвижно и коснитесь экрана для фокусировки с 10–15 см.',
        'ar' => 'ثبّت الهاتف والمس الشاشة للتركيز من مسافة 10–15 سم.',
        'zh' => '请保持手机稳定，距离10–15厘米点击屏幕对焦。',
        _ => 'Hold the phone steady and tap to focus from 10–15 cm away.',
      };

  static String _glareTitle(String lang) => switch (lang) {
        'de' => 'Starke Blendung / Blitzreflexion',
        'es' => 'Brillo excesivo / Reflejo del flash',
        'fr' => 'Reflet excessif / Éblouissement du flash',
        'it' => 'Riflesso eccessivo / Bagliore del flash',
        'nl' => 'Overmatige schittering / Flitsreflectie',
        'sv' => 'Stark bländning / Blixtreflektion',
        'pt' => 'Brilho excessivo / Reflexo do flash',
        'ru' => 'Сильный блик / Отражение вспышки',
        'ar' => 'وهج شديد / انعكاس الفلاش',
        'zh' => '强光反光 / 闪光灯眩光',
        'hi' => 'अत्यधिक चमक / फ़्लैश परावर्तन',
        'bn' => 'অতিরিক্ত ঝলকানি / ফ্ল্যাশ প্রতিফলন',
        'ur' => 'شدید چمک / فلیش کا عکس',
        _ => 'Excessive Glare / Flash Reflection',
      };

  static String _glareDetail(String lang) => switch (lang) {
        'de' =>
          'Durch starke Lichtreflexion konnte der wahre Farbton nicht bestimmt werden.',
        'es' =>
          'El brillo intenso impidió leer con precisión el tono de color real.',
        'fr' =>
          'Un reflet lumineux intense empêche la lecture précise de la teinte.',
        'ru' => 'Из-за сильного засвета не удалось определить истинный оттенок.',
        'ar' => 'تعذرت قراءة درجة اللون الحقيقية بسبب شدة انعكاس الضوء.',
        'zh' => '由于光线过强反光，无法准确读取真实色调。',
        _ =>
          'True color tone could not be read reliably due to specular glare.',
      };

  static String _glareObs(String lang) => switch (lang) {
        'de' => 'Hohe Überbelichtung im zentralen Messbereich erkannt.',
        'es' => 'Se detectó sobreexposición blanca en la zona central.',
        'fr' => 'Surexposition lumineuse détectée au centre.',
        _ => 'High specular highlight saturation detected in the center region.',
      };

  static String _glareRec(String lang) => switch (lang) {
        'de' =>
          'Schalten Sie den Blitz aus und fotografieren Sie bei indirektem Tageslicht.',
        'es' => 'Apague el flash y repita la toma con luz natural indirecta.',
        'fr' =>
          'Désactivez le flash et reprenez la photo à la lumière naturelle indirecte.',
        _ => 'Turn off the flash and retake under soft, indirect daylight.',
      };

  static String lowLightTitle(String lang) => switch (lang) {
        'tr' => 'Ortam Işığı Yetersiz',
        'de' => 'Unzureichendes Umgebungslicht',
        'es' => 'Iluminación ambiental insuficiente',
        'fr' => 'Luminosité ambiante insuffisante',
        'it' => 'Illuminazione ambientale insufficiente',
        'nl' => 'Onvoldoende omgevingslicht',
        'sv' => 'Otillräckligt omgivningsljus',
        'pt' => 'Iluminação ambiente insuficiente',
        'ru' => 'Недостаточное освещение',
        'ar' => 'الإضاءة المحيطة غير كافية',
        'zh' => '环境光线不足',
        'hi' => 'अपर्याप्त परिवेश प्रकाश',
        'bn' => 'পর্যাপ্ত আলোর অভাব',
        'ur' => 'روشنی ناکافی ہے',
        _ => 'Insufficient Ambient Lighting',
      };

  static String lowLightDetail(String lang) => switch (lang) {
        'tr' =>
          'Görüntü çok karanlık olduğu için renk tonu güvenilir şekilde okunamadı.',
        'de' =>
          'Das Bild ist zu dunkel, um den Farbton zuverlässig auszuwerten.',
        'es' =>
          'La imagen es demasiado oscura para evaluar el tono con fiabilidad.',
        'fr' =>
          'L\'image est trop sombre pour évaluer la couleur de façon fiable.',
        'ru' => 'Изображение слишком тёмное для надёжной оценки оттенка.',
        'ar' => 'الصورة مظلمة جداً بحيث يتعذر قراءة درجة اللون بدقة.',
        'zh' => '图像过暗，无法可靠读取颜色色调。',
        _ => 'The image is too dark to evaluate color tone reliably.',
      };

  static String lowLightObs(String lang) => switch (lang) {
        'tr' => 'Örneklenen merkez bölgede parlaklık çok düşük.',
        'de' => 'Die Helligkeit im Messbereich liegt unter dem Schwellenwert.',
        'es' => 'El brillo en la región central está por debajo del umbral.',
        'fr' => 'La luminosité centrale est inférieure au seuil requis.',
        _ => 'Brightness in the sampled center region is below threshold.',
      };

  static String _daylightRec(String lang) => switch (lang) {
        'de' => 'Wiederholen Sie die Aufnahme bei hellem Tageslicht.',
        'es' => 'Repita la captura en un lugar bien iluminado con luz natural.',
        'fr' => 'Reprenez la photo dans un endroit bien éclairé à la lumière du jour.',
        'ru' => 'Повторите съёмку при хорошем дневном освещении.',
        'ar' => 'أعد الالتقاط في مكان مضاء جيداً بضوء النهار الطبيعي.',
        'zh' => '请在自然光线充足的环境下重新拍摄。',
        _ => 'Retake the photo in a well-lit area with natural daylight.',
      };

  static String _shadowRec(String lang) => switch (lang) {
        'de' => 'Achten Sie darauf, keinen Schatten auf den Bereich zu werfen.',
        'es' => 'Evite proyectar sombras sobre el área evaluada.',
        'fr' => 'Évitez les ombres directes sur la zone photographiée.',
        _ => 'Avoid casting shadows over the target area.',
      };
}
