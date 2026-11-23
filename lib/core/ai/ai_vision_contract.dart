import 'dart:convert';
import 'dart:typed_data';

import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

enum AiModelTier {
  lite,
  standard,
}

/// Structured, token-optimized payload sent to a multimodal Vision AI backend
/// (Firebase AI Logic / Gemini API / custom REST proxy).
class AiVisionRequest {
  const AiVisionRequest({
    required this.category,
    required this.imageBytes,
    required this.mimeType,
    required this.modelTier,
    required this.recommendedModel,
    required this.maxOutputTokens,
    required this.thinkingLevel,
    required this.systemInstruction,
    required this.userPrompt,
    required this.allowedFindingIds,
  });

  final CheckCategory category;
  final Uint8List imageBytes;
  final String mimeType;
  final AiModelTier modelTier;

  /// Tiered Gemini model ID (cost-efficient Flash-Lite for color-primary
  /// modules; Flash for high-detail skin & nail morphology).
  final String recommendedModel;

  /// Hard cap on output tokens to prevent verbose, costly responses.
  final int maxOutputTokens;

  /// Recommended thinking level ('minimal' or 'low') to avoid hidden thinking
  /// token spikes on classification tasks.
  final String thinkingLevel;

  final String systemInstruction;
  final String userPrompt;
  final List<String> allowedFindingIds;
}

/// Abstract client that Firebase AI Logic (`firebase_ai`) or a backend proxy
/// implements to plug directly into [HybridHealthAnalyzer].
abstract class VisionAiClient {
  Future<String> analyzeWithVisionAi(AiVisionRequest request);
}

/// Builds compact, low-token Vision AI prompts grounded in:
/// 1. Only the active module's healthy vs. abnormal reference rubric,
/// 2. On-device CIE L*a*b* + white-balance calibration telemetry,
/// 3. Optional personal baseline ΔE and skin symptom flags,
/// 4. Strict minimal JSON output schema.
class AiVisionPromptBuilder {
  AiVisionPromptBuilder._();

  static const String liteModelId = 'gemini-3.5-flash-lite';
  static const String standardModelId = 'gemini-3.8-flash';

  /// Constant system instruction kept identical across all calls so Gemini's
  /// automatic implicit context caching maximizes input-token savings.
  static const String systemInstruction =
      'VisualCheckUp görsel ön farkındalık asistanısın. Tıbbi teşhis koymazsın. '
      'Fotoğrafı verilen modülün sağlıklı/sağlıksız referanslarıyla, renk ve ince yapı/doku '
      'telemetrisiyle (dilde yarık/çatlak ve pas, gözde kılcal kanlanma veya sararma, '
      'tırnakta beyaz nokta/çizgi, kırık/soyulma, oluk, koyu dikey bant) kıyasla. '
      'Yalnızca geçerli, kısa Türkçe JSON döndür: '
      '{"image_quality_ok":bool,"matched_finding_ids":[str],'
      '"risk_level":"normal|attention|urgent","summary_title":str,'
      '"summary_detail":str,"observations":[str],"recommendations":[str],'
      '"warning_flags":[str],"confidence":0..1}. '
      'Görüntü net değilse image_quality_ok=false ver.';

  static AiModelTier tierForCategory(CheckCategory category) {
    switch (category) {
      case CheckCategory.skinCondition:
      case CheckCategory.nail:
        return AiModelTier.standard;
      case CheckCategory.eye:
      case CheckCategory.tongue:
      case CheckCategory.face:
      case CheckCategory.urine:
      case CheckCategory.stool:
        return AiModelTier.lite;
    }
  }

  static String modelForCategory(CheckCategory category) {
    return tierForCategory(category) == AiModelTier.standard
        ? standardModelId
        : liteModelId;
  }

  static AiVisionRequest build({
    required CheckCategory category,
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
    String languageCode = 'tr',
    CalibratedSample? calibratedSample,
    StructuralFeatures? structuralFeatures,
    CategoryBaseline? baseline,
    SkinCheckContext? skinContext,
  }) {
    final spec = ModuleReferenceCatalog.forCategory(category);
    final tier = tierForCategory(category);

    // Compact pipe-delimited rubric cuts ~55% of prompt tokens vs verbose JSON.
    final rubricLines = spec.findings
        .map(
          (f) =>
              '- ${f.id}|${f.isHealthyReference ? 'healthy' : f.riskLevel.name}: ${f.title} (${f.visualSignature})',
        )
        .join('\n');

    final telemetryParts = <String>[];
    if (calibratedSample != null) {
      final c = calibratedSample.calibratedColor;
      final r = (c.r * 255).round().clamp(0, 255);
      final g = (c.g * 255).round().clamp(0, 255);
      final b = (c.b * 255).round().clamp(0, 255);
      telemetryParts.add(
        'rgb=($r,$g,$b) cie_lab=(L:${calibratedSample.lab.l.toStringAsFixed(1)},'
        'a:${calibratedSample.lab.a.toStringAsFixed(1)},'
        'b:${calibratedSample.lab.b.toStringAsFixed(1)}) '
        'wb=${calibratedSample.whiteBalanceApplied ? 1 : 0} '
        'cast=${calibratedSample.lightingCast.name}',
      );
    }

    if (structuralFeatures != null) {
      telemetryParts.add(
        'struct=(${structuralFeatures.toCompactTelemetry(category)})',
      );
    }

    if (baseline != null && calibratedSample != null) {
      final comp = baseline.compare(calibratedSample.lab);
      telemetryParts.add(
        'baseline_deltaE=${comp.deltaE.toStringAsFixed(1)} (${comp.note})',
      );
    }

    if (skinContext != null) {
      final sym = skinContext.symptoms.map((s) => s.label).join(',');
      final area = skinContext.bodyArea ?? '-';
      telemetryParts.add(
        'skin_concern=${skinContext.concernType.label};area=$area;symptoms=${sym.isEmpty ? 'yok' : sym}',
      );
    }

    final userPrompt = '''
Modül: ${category.title} (${category.id})
Yanıt dili (ISO-639-1): $languageCode
Referanslar:
$rubricLines
Telemetri: ${telemetryParts.isEmpty ? 'yok' : telemetryParts.join(' | ')}
Kural: Sadece listedeki matched_finding_ids kullan, tüm metin alanlarını $languageCode dilinde yaz, en fazla 2 gözlem ve 2 öneri yaz, yalnızca JSON döndür.''';

    return AiVisionRequest(
      category: category,
      imageBytes: imageBytes,
      mimeType: mimeType,
      modelTier: tier,
      recommendedModel: modelForCategory(category),
      maxOutputTokens: 320,
      thinkingLevel: tier == AiModelTier.standard ? 'low' : 'minimal',
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
