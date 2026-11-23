import 'dart:typed_data';

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
      throw const FormatException('Görüntü çözümlenemedi.');
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
      );
      if (cache != null) {
        await cache.saveCachedAiResult(preprocessed.contentFingerprint, parsed);
      }
      return parsed;
    } catch (_) {
      // Graceful offline / API-failure fallback to on-device analyzer.
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
  }) {
    final now = DateTime.now();
    final id = '${category.id}_gate_${now.microsecondsSinceEpoch}';

    switch (issue) {
      case ImageQualityIssue.tooBlurry:
        return AnalysisResult(
          id: id,
          category: category,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Görüntü Bulanık — Tekrar Çekin',
          summaryDetail:
              'Odak yeterince net olmadığı için yüzey detayları okunamadı. Gereksiz veri aktarımı yapılmadan analiz durduruldu.',
          dominantColorValue: dominantColorValue,
          observations: const [
            'Kamerada hareket veya odak kaybı (bulanıklık) tespit edildi.',
          ],
          recommendations: const [
            'Telefonu sabit tutun ve hedefe 10–15 cm mesafeden dokunarak odaklayın.',
            'Yeterli gün ışığı altında çekimi tekrarlayın.',
          ],
          warningFlags: const [],
          confidence: 0.20,
          createdAt: now,
        );
      case ImageQualityIssue.overexposed:
        return AnalysisResult(
          id: id,
          category: category,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Aşırı Parlama / Flaş Yansıması',
          summaryDetail:
              'Görüntüde aşırı ışık parlaması olduğu için gerçek renk tonu okunamadı.',
          dominantColorValue: dominantColorValue,
          observations: const [
            'Merkez bölgede yüksek oranda beyaz ışık patlaması saptandı.',
          ],
          recommendations: const [
            'Flaşı kapatın ve doğrudan sert ışık yerine dolaylı gün ışığında tekrar çekin.',
          ],
          warningFlags: const [],
          confidence: 0.22,
          createdAt: now,
        );
      case ImageQualityIssue.tooDark:
      case ImageQualityIssue.none:
        return AnalysisResult(
          id: id,
          category: category,
          riskLevel: RiskLevel.attention,
          summaryTitle: 'Ortam Işığı Yetersiz',
          summaryDetail:
              'Görüntü çok karanlık olduğu için renk tonu ve detaylar güvenilir şekilde okunamadı.',
          dominantColorValue: dominantColorValue,
          observations: const [
            'Merkez bölgede parlaklık eşik değerinin altında.',
          ],
          recommendations: const [
            'Doğal gün ışığı alan aydınlık bir ortamda çekimi tekrarlayın.',
            'Gölge düşmemesine dikkat edin.',
          ],
          warningFlags: const [],
          confidence: 0.22,
          createdAt: now,
        );
    }
  }
}
