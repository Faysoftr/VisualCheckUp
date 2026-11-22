import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Hybrid analyzer that runs on-device color calibration first, sends the
/// calibrated image + telemetry + module reference rubric to [aiClient] when
/// available, and transparently falls back to [fallbackAnalyzer] offline or on
/// error.
class HybridHealthAnalyzer implements HealthAnalyzer {
  const HybridHealthAnalyzer({
    required this.fallbackAnalyzer,
    this.aiClient,
    this.skinContext,
  });

  final HealthAnalyzer fallbackAnalyzer;
  final VisionAiClient? aiClient;
  final SkinCheckContext? skinContext;

  @override
  Future<AnalysisResult> analyzeImage({
    required CheckCategory category,
    required Uint8List imageBytes,
    AnalysisOptions options = const AnalysisOptions(),
  }) async {
    final client = aiClient;
    if (client == null) {
      return fallbackAnalyzer.analyzeImage(
        category: category,
        imageBytes: imageBytes,
        options: options,
      );
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Görüntü çözümlenemedi.');
    }

    final sample = ColorCalibrator.sampleImage(
      image: decoded,
      useWhiteReference: options.useWhiteReference,
    );

    double? baselineDeltaE;
    String? baselineNote;
    if (options.baseline != null) {
      final comp = options.baseline!.compare(sample.lab);
      baselineDeltaE = comp.deltaE;
      baselineNote = comp.note;
    }

    final request = AiVisionPromptBuilder.build(
      category: category,
      imageBytes: imageBytes,
      calibratedSample: sample,
      baseline: options.baseline,
      skinContext: skinContext,
    );

    try {
      final rawJson = await client.analyzeWithVisionAi(request);
      return AiVisionResponseParser.parse(
        rawResponse: rawJson,
        category: category,
        dominantColorValue: sample.calibratedColor.toARGB32(),
        whiteBalanceCalibrated: sample.whiteBalanceApplied,
        lightingNote: sample.lightingNote,
        baselineDeltaE: baselineDeltaE,
        baselineComparisonNote: baselineNote,
      );
    } catch (_) {
      // Graceful offline / API-failure fallback to on-device analyzer.
      return fallbackAnalyzer.analyzeImage(
        category: category,
        imageBytes: imageBytes,
        options: options,
      );
    }
  }
}
