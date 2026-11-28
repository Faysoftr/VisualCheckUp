import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/vein_varicose/domain/vein_models.dart';

/// Result of camera / photo visual screening for leg veins & varicosities.
class VeinVisualScanResult {
  const VeinVisualScanResult({
    required this.suggestedStage,
    required this.confidence,
    required this.summaryTitle,
    required this.summaryDetail,
    required this.visualFindings,
    required this.capillaryDensityPercent,
    required this.prominentVeinContrastPercent,
    required this.pigmentationChangePercent,
    required this.lightingQualityOk,
    required this.usedCloudAi,
  });

  final CeapStage suggestedStage;
  final double confidence;
  final String summaryTitle;
  final String summaryDetail;
  final List<String> visualFindings;
  final int capillaryDensityPercent;
  final int prominentVeinContrastPercent;
  final int pigmentationChangePercent;
  final bool lightingQualityOk;
  final bool usedCloudAi;
}

/// Hybrid (On-Device Vascular Chromophore + Optional Gemini Vision AI)
/// analyzer for leg spider veins, reticular/varicose veins, and stasis skin signs.
class VeinVisualAnalyzer {
  VeinVisualAnalyzer({
    VisionAiClient? aiClient,
  }) : _aiClient = aiClient ?? GeminiVisionAiClient.fromEnvironment();

  final VisionAiClient? _aiClient;

  Future<VeinVisualScanResult> analyzePhoto(Uint8List imageBytes) async {
    final local = analyzeOnDevice(imageBytes);
    final client = _aiClient;
    if (client == null || !local.lightingQualityOk) {
      return local;
    }

    try {
      final request = AiVisionRequest(
        category: CheckCategory.skinCondition,
        imageBytes: imageBytes,
        mimeType: 'image/jpeg',
        modelTier: AiModelTier.standard,
        recommendedModel: AiVisionPromptBuilder.standardModelId,
        maxOutputTokens: 450,
        thinkingLevel: 'low',
        systemInstruction:
            'VisualCheckUp bacak damar ve varis görsel ön tarama asistanısın. '
            'Tıbbi teşhis koymazsın; CEAP (C0-C6) görsel sınıflamasına göre ön farkındalık sunarsın. '
            'Işık yansımalarını veya tüyleri damar sayma. Yalnızca geçerli Türkçe JSON döndür: '
            '{"image_quality_ok":bool,"ceap_stage":"c0|c1|c2|c3|c4|c5|c6",'
            '"summary_title":str,"summary_detail":str,"findings":[str],"confidence":0..1}.',
        userPrompt:
            'Bacak fotoğrafını kılcal damar (C1), belirgin kıvrımlı varis (C2), '
            'ödem/şişlik (C3), staz pigmentasyonu (C4) ve ülser (C5-C6) açısından incele. '
            'Cihaz telemetrisi: kılcal=%${local.capillaryDensityPercent}, '
            'mavi-yeşil ven kontrastı=%${local.prominentVeinContrastPercent}, '
            'pigmentasyon=%${local.pigmentationChangePercent}.',
        allowedFindingIds: const ['c0', 'c1', 'c2', 'c3', 'c4', 'c5', 'c6'],
      );

      final rawJson = await client.analyzeWithVisionAi(request);
      final parsed = jsonDecode(rawJson) as Map<String, dynamic>;
      final qualityOk = parsed['image_quality_ok'] as bool? ?? true;
      final stageCode = (parsed['ceap_stage'] as String? ?? '').toLowerCase();
      final aiStage = CeapStage.values.firstWhere(
        (s) => s.name == stageCode,
        orElse: () => local.suggestedStage,
      );
      final findingsRaw = parsed['findings'] as List<dynamic>? ?? const [];
      final aiFindings = findingsRaw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return VeinVisualScanResult(
        suggestedStage: aiStage,
        confidence:
            ((parsed['confidence'] as num?)?.toDouble() ?? local.confidence)
                .clamp(0.35, 0.96),
        summaryTitle:
            (parsed['summary_title'] as String?)?.trim().isNotEmpty == true
                ? (parsed['summary_title'] as String).trim()
                : local.summaryTitle,
        summaryDetail:
            (parsed['summary_detail'] as String?)?.trim().isNotEmpty == true
                ? (parsed['summary_detail'] as String).trim()
                : local.summaryDetail,
        visualFindings:
            aiFindings.isNotEmpty ? aiFindings : local.visualFindings,
        capillaryDensityPercent: local.capillaryDensityPercent,
        prominentVeinContrastPercent: local.prominentVeinContrastPercent,
        pigmentationChangePercent: local.pigmentationChangePercent,
        lightingQualityOk: qualityOk,
        usedCloudAi: true,
      );
    } catch (_) {
      return local;
    }
  }

  /// Deterministic on-device pixel chromophore & linear vessel contrast scan.
  VeinVisualScanResult analyzeOnDevice(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null || decoded.width < 16 || decoded.height < 16) {
      return const VeinVisualScanResult(
        suggestedStage: CeapStage.c0,
        confidence: 0.40,
        summaryTitle: 'Görüntü Okunamadı — Daha Net Fotoğraf Çekin',
        summaryDetail:
            'Fotoğraf çözümlenemedi veya çok düşük çözünürlüklü. Gün ışığında bacak bölgesini net şekilde çerçeveleyerek tekrar deneyin.',
        visualFindings: [
          'Yeterli çözünürlükte görüntü alınamadı.',
        ],
        capillaryDensityPercent: 0,
        prominentVeinContrastPercent: 0,
        pigmentationChangePercent: 0,
        lightingQualityOk: false,
        usedCloudAi: false,
      );
    }

    final sample = decoded.width > 240
        ? img.copyResize(decoded, width: 240)
        : decoded;

    // Analyze central 76% ROI (avoid outer background edges).
    final x0 = (sample.width * 0.12).round();
    final x1 = math.max(x0 + 1, (sample.width * 0.88).round());
    final y0 = (sample.height * 0.12).round();
    final y1 = math.max(y0 + 1, (sample.height * 0.88).round());

    double sumR = 0;
    double sumG = 0;
    double sumB = 0;
    double sumLuma = 0;
    int total = 0;

    for (int y = y0; y < y1; y++) {
      for (int x = x0; x < x1; x++) {
        final p = sample.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        sumR += r;
        sumG += g;
        sumB += b;
        sumLuma += 0.299 * r + 0.587 * g + 0.114 * b;
        total++;
      }
    }

    if (total == 0) {
      return const VeinVisualScanResult(
        suggestedStage: CeapStage.c0,
        confidence: 0.45,
        summaryTitle: 'Görünür Belirgin Damar Saptanmadı (C0)',
        summaryDetail: 'Merkez bölgede belirgin vasküler kontrast izlenmedi.',
        visualFindings: ['Cilt tonu homojen görünüyor.'],
        capillaryDensityPercent: 0,
        prominentVeinContrastPercent: 0,
        pigmentationChangePercent: 0,
        lightingQualityOk: true,
        usedCloudAi: false,
      );
    }

    final meanR = sumR / total;
    final meanG = sumG / total;
    final meanB = sumB / total;
    final meanLuma = sumLuma / total;
    final lightingOk = meanLuma >= 38 && meanLuma <= 242;

    int capillaryPixels = 0;
    int blueVeinPixels = 0;
    int pigmentationPixels = 0;
    int linearEdgePixels = 0;

    for (int y = y0; y < y1 - 1; y++) {
      for (int x = x0; x < x1 - 1; x++) {
        final p = sample.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final luma = 0.299 * r + 0.587 * g + 0.114 * b;

        final pRight = sample.getPixel(x + 1, y);
        final pDown = sample.getPixel(x, y + 1);
        final lumaRight =
            0.299 * pRight.r + 0.587 * pRight.g + 0.114 * pRight.b;
        final lumaDown =
            0.299 * pDown.r + 0.587 * pDown.g + 0.114 * pDown.b;
        final edgeGrad = (luma - lumaRight).abs() + (luma - lumaDown).abs();

        if (edgeGrad > 22) {
          linearEdgePixels++;
        }

        // 1. Red-purple / magenta spider-vein chromophore contrast vs baseline skin
        final redMagentaExcess = (r - g) - (meanR - meanG);
        final purpleShift = (b - g) - (meanB - meanG);
        if ((redMagentaExcess > 14 || (redMagentaExcess > 7 && purpleShift > 6)) &&
            luma < meanLuma - 6) {
          capillaryPixels++;
        }

        // 2. Blue-green / cyan tortuous subcutaneous vein shift vs surrounding skin
        final blueCyanShift = ((b + g * 0.6) - r) - ((meanB + meanG * 0.6) - meanR);
        if (blueCyanShift > 13 && luma < meanLuma - 8) {
          blueVeinPixels++;
        }

        // 3. Dark brownish-ochre stasis pigmentation / erythema patches
        if (luma < meanLuma - 28 && r > b + 12 && (r - g) > 8) {
          pigmentationPixels++;
        }
      }
    }

    final capRatio = capillaryPixels / total;
    final veinRatio = blueVeinPixels / total;
    final pigRatio = pigmentationPixels / total;
    final edgeRatio = linearEdgePixels / total;

    final capPct = (capRatio * 320).round().clamp(0, 100);
    final veinPct = ((veinRatio * 340) + (edgeRatio * 45)).round().clamp(0, 100);
    final pigPct = (pigRatio * 260).round().clamp(0, 100);

    CeapStage stage;
    String title;
    String detail;
    final findings = <String>[];

    if (!lightingOk) {
      findings.add(
        meanLuma < 38
            ? 'Ortam ışığı düşük algılandı; gün ışığında çekim doğruluğu artırır.'
            : 'Aşırı parlama tespit edildi; doğrudan flaş yansımasından kaçının.',
      );
    }

    if (pigPct >= 38 && (veinPct >= 22 || capPct >= 22)) {
      stage = CeapStage.c4;
      title = 'Ciltte Staz Renk Değişimi & Damar Kontrastı (C4 Ön Bulgusu)';
      detail =
          'Fotoğrafta belirgin kahverengi/kızarık renk koyulaşması ve vasküler izler saptandı. Kronik venöz staz açısından uzman değerlendirmesi önerilir.';
      findings.add(
        'Çevre cilt tonuna göre belirgin pigmentasyon / renk koyulaşması (%$pigPct) izlendi.',
      );
      findings.add(
        'Yüzeyel damar kontrastı (%$veinPct) ve kılcal ağ izleri (%$capPct) eşlik ediyor.',
      );
    } else if (veinPct >= 26) {
      stage = CeapStage.c2;
      title = 'Belirgin Yüzeyel Ven / Varis Kontrastı (C2 Ön Bulgusu)';
      detail =
          'Cilt altında mavi-yeşil tonlu belirgin damar hattı ve kenar kontrastı algılandı. CEAP C2 evresiyle uyumlu olabilir.';
      findings.add(
        'Mavi-yeşil yüzeyel ven kontrastı (%$veinPct) normal cilt homojenliğinin üzerinde.',
      );
      if (capPct >= 15) {
        findings.add(
          'Çevrede ince kırmızı-mor kılcal damar (telenjiektazi) yoğunluğu (%$capPct) mevcut.',
        );
      }
    } else if (capPct >= 16 || veinPct >= 14) {
      stage = CeapStage.c1;
      title = 'İnce Kılcal / Retiküler Damar İzleri (C1 Ön Bulgusu)';
      detail =
          'Cilt yüzeyinde hafif kırmızı-mor kılcal damar veya ince retiküler ağ kontrastı saptandı. Erken koruyucu evre (C1) ile uyumlu görünüyor.';
      findings.add(
        'Yüzeyel ince kılcal / örümcek damar kontrastı (%$capPct) tespit edildi.',
      );
      findings.add(
        'Derin kıvrımlı varis paketi veya ileri staz lekelenmesi ön planda değil.',
      );
    } else {
      stage = CeapStage.c0;
      title = 'Belirgin Yüzeyel Varis Saptanmadı (C0 Ön Bulgusu)';
      detail =
          'Fotoğraftaki cilt bölgesinde belirgin kılcal çatlama veya kabarık varis kontrastı izlenmedi. Ağrı/ağırlık şikayetiniz varsa aşağıdaki semptom formunu işaretleyin.';
      findings.add(
        'Cilt renk dağılımı dengeli; belirgin mavi-mor damar ağı görülmedi.',
      );
    }

    final confidence = lightingOk ? 0.78 : 0.54;

    return VeinVisualScanResult(
      suggestedStage: stage,
      confidence: confidence,
      summaryTitle: title,
      summaryDetail: detail,
      visualFindings: findings,
      capillaryDensityPercent: capPct,
      prominentVeinContrastPercent: veinPct,
      pigmentationChangePercent: pigPct,
      lightingQualityOk: lightingOk,
      usedCloudAi: false,
    );
  }
}
