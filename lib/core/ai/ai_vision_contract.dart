import 'dart:convert';
import 'dart:typed_data';

import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Structured payload sent to a multimodal Vision AI backend (Gemini, OpenAI,
/// or custom backend API).
class AiVisionRequest {
  const AiVisionRequest({
    required this.category,
    required this.imageBytes,
    required this.systemInstruction,
    required this.userPrompt,
    required this.allowedFindingIds,
  });

  final CheckCategory category;
  final Uint8List imageBytes;
  final String systemInstruction;
  final String userPrompt;
  final List<String> allowedFindingIds;
}

/// Abstract client that your backend / Vision AI SDK (e.g. Firebase Vertex AI,
/// Gemini API, or a private REST proxy) can implement to plug directly into
/// [HybridHealthAnalyzer].
abstract class VisionAiClient {
  Future<String> analyzeWithVisionAi(AiVisionRequest request);
}

/// Builds grounded, medically safe Vision AI prompts combining:
/// 1. The module's healthy vs. abnormal reference catalog,
/// 2. On-device CIE L*a*b* + white-balance calibration telemetry,
/// 3. User's optional personal baseline and skin symptom context,
/// 4. Strict JSON output schema.
class AiVisionPromptBuilder {
  AiVisionPromptBuilder._();

  static const String systemInstruction =
      'Sen VisualCheckUp uygulaması için çalışan görsel sağlık ön farkındalık asistanısın. '
      'Tıbbi cihaz değilsin ve kesin tıbbi teşhis koymazsın. '
      'Görevin, gönderilen fotoğrafı verilen SAĞLIKLI REFERANS ve SAĞLIKSIZ/UYARI BULGULARI kataloğu ile '
      'görsel olarak kıyaslamak, ortam ışığı/kalibrasyon telemetrisini dikkate almak ve yalnızca istenen JSON şemasında '
      'Türkçe ön değerlendirme döndürmektir. Görüntü bulanık, aşırı karanlık veya ilgisizse image_quality_ok=false döndür.';

  static AiVisionRequest build({
    required CheckCategory category,
    required Uint8List imageBytes,
    CalibratedSample? calibratedSample,
    CategoryBaseline? baseline,
    SkinCheckContext? skinContext,
  }) {
    final spec = ModuleReferenceCatalog.forCategory(category);
    final rubricPayload = {
      'module': category.id,
      'module_title': category.title,
      'healthy_summary': spec.healthySummary,
      'reference_findings': spec.findings.map((f) => f.toAiRubricMap()).toList(),
    };

    final telemetry = <String, dynamic>{};
    if (calibratedSample != null) {
      final c = calibratedSample.calibratedColor;
      telemetry['calibrated_rgb'] = [
        (c.r * 255).round().clamp(0, 255),
        (c.g * 255).round().clamp(0, 255),
        (c.b * 255).round().clamp(0, 255),
      ];
      telemetry['cie_lab'] = {
        'L': double.parse(calibratedSample.lab.l.toStringAsFixed(2)),
        'a': double.parse(calibratedSample.lab.a.toStringAsFixed(2)),
        'b': double.parse(calibratedSample.lab.b.toStringAsFixed(2)),
      };
      telemetry['white_balance_calibrated'] =
          calibratedSample.whiteBalanceApplied;
      telemetry['lighting_cast'] = calibratedSample.lightingCast.name;
      telemetry['glare_filtered_ratio'] =
          double.parse(calibratedSample.glareFilteredRatio.toStringAsFixed(3));
    }

    if (baseline != null && calibratedSample != null) {
      final comp = baseline.compare(calibratedSample.lab);
      telemetry['personal_baseline'] = {
        'baseline_lab': {
          'L': double.parse(baseline.labL.toStringAsFixed(2)),
          'a': double.parse(baseline.labA.toStringAsFixed(2)),
          'b': double.parse(baseline.labB.toStringAsFixed(2)),
        },
        'delta_e': double.parse(comp.deltaE.toStringAsFixed(2)),
        'comparison_note': comp.note,
      };
    }

    if (skinContext != null) {
      telemetry['skin_user_context'] = {
        'concern_type': skinContext.concernType.label,
        'symptoms': skinContext.symptoms.map((s) => s.label).toList(),
        if (skinContext.bodyArea != null) 'body_area': skinContext.bodyArea,
      };
    }

    final userPrompt = '''
Aşağıdaki görüntüyü verilen referans kataloğundaki SAĞLIKLI ve SAĞLIKSIZ bulgularla karşılaştır.

### REFERANS KATALOĞU (JSON)
${jsonEncode(rubricPayload)}

### CİHAZ İÇİ RENK KALİBRASYON TELEMETRİSİ
${jsonEncode(telemetry)}

### İSTENEN ÇIKTI FORMATI (Sadece geçerli JSON döndür, ek açıklama yazma)
{
  "image_quality_ok": true,
  "matched_finding_ids": ["finding_id_1"],
  "risk_level": "normal | attention | urgent",
  "summary_title": "Kısa başlık (Türkçe)",
  "summary_detail": "Sağlıklı referansla karşılaştırmalı, teşhis koymayan 2-3 cümlelik özet",
  "observations": ["Gözlem 1", "Gözlem 2"],
  "recommendations": ["Öneri 1", "Öneri 2"],
  "warning_flags": ["Varsa acil/doktor uyarısı"],
  "confidence": 0.78
}
''';

    return AiVisionRequest(
      category: category,
      imageBytes: imageBytes,
      systemInstruction: systemInstruction,
      userPrompt: userPrompt,
      allowedFindingIds: spec.findings.map((f) => f.id).toList(),
    );
  }
}

/// Parses raw Vision AI JSON text into a validated [AnalysisResult].
class AiVisionResponseParser {
  AiVisionResponseParser._();

  static AnalysisResult parse({
    required String rawResponse,
    required CheckCategory category,
    required int dominantColorValue,
    bool whiteBalanceCalibrated = false,
    String? lightingNote,
    double? baselineDeltaE,
    String? baselineComparisonNote,
    DateTime? now,
  }) {
    final cleaned = _stripCodeFences(rawResponse).trim();
    final decoded = jsonDecode(cleaned) as Map<String, dynamic>;

    final timestamp = now ?? DateTime.now();
    final id = '${category.id}_ai_${timestamp.microsecondsSinceEpoch}';
    final imageQualityOk = (decoded['image_quality_ok'] as bool?) ?? true;

    final riskLevel = imageQualityOk
        ? RiskLevelX.fromName(
            (decoded['risk_level'] as String?) ?? 'attention',
          )
        : RiskLevel.attention;

    final summaryTitle = (decoded['summary_title'] as String?)?.trim();
    final summaryDetail = (decoded['summary_detail'] as String?)?.trim();
    final observations = _stringList(decoded['observations']);
    final recommendations = _stringList(decoded['recommendations']);
    final warningFlags = _stringList(decoded['warning_flags']);
    final rawConfidence =
        ((decoded['confidence'] as num?)?.toDouble() ?? 0.65).clamp(0.15, 0.95);

    return AnalysisResult(
      id: id,
      category: category,
      riskLevel: riskLevel,
      summaryTitle: (summaryTitle != null && summaryTitle.isNotEmpty)
          ? summaryTitle
          : (imageQualityOk
              ? '${category.title} Ön Değerlendirmesi'
              : 'Görüntü Kalitesi Yetersiz'),
      summaryDetail: (summaryDetail != null && summaryDetail.isNotEmpty)
          ? summaryDetail
          : 'Görsel değerlendirme tamamlandı. Kesin tanı için bir hekime başvurun.',
      dominantColorValue: dominantColorValue,
      observations: observations,
      recommendations: recommendations.isNotEmpty
          ? recommendations
          : const ['Kesin değerlendirme için bir sağlık uzmanına danışın.'],
      warningFlags: warningFlags,
      confidence: imageQualityOk ? rawConfidence : 0.25,
      createdAt: timestamp,
      whiteBalanceCalibrated: whiteBalanceCalibrated,
      lightingNote: lightingNote,
      baselineDeltaE: baselineDeltaE,
      baselineComparisonNote: baselineComparisonNote,
    );
  }

  static String _stripCodeFences(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('```')) return trimmed;
    final lines = trimmed.split('\n');
    if (lines.length >= 2 && lines.last.trim().startsWith('```')) {
      return lines.sublist(1, lines.length - 1).join('\n');
    }
    return trimmed;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
