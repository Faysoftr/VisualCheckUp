import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';

class _StubVisionAiClient implements VisionAiClient {
  _StubVisionAiClient({this.response, this.shouldThrow = false});

  final String? response;
  final bool shouldThrow;
  AiVisionRequest? lastRequest;

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    lastRequest = request;
    if (shouldThrow) {
      throw Exception('Network unavailable');
    }
    return response!;
  }
}

Uint8List _solidPng(int r, int g, int b) {
  final image = img.Image(width: 60, height: 60);
  for (int y = 0; y < 60; y++) {
    for (int x = 0; x < 60; x++) {
      image.setPixelRgb(x, y, r, g, b);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('ModuleReferenceCatalog', () {
    test('provides healthy reference and multiple abnormal findings for all 7 modules', () {
      for (final category in CheckCategory.values) {
        final spec = ModuleReferenceCatalog.forCategory(category);
        expect(spec.category, category);
        expect(spec.healthySummary, isNotEmpty);
        expect(spec.healthyReferences, isNotEmpty);
        expect(spec.abnormalFindings.length, greaterThanOrEqualTo(4));

        // Ensure unique finding IDs within each module
        final ids = spec.findings.map((f) => f.id).toSet();
        expect(ids.length, spec.findings.length);
      }

      // Spot check nail module includes key clinical signs
      final nailIds = ModuleReferenceCatalog.forCategory(CheckCategory.nail)
          .findings
          .map((f) => f.id)
          .toSet();
      expect(nailIds, contains('nail_healthy_pink'));
      expect(nailIds, contains('nail_pale_bed'));
      expect(nailIds, contains('nail_cyanotic_blue'));
      expect(nailIds, contains('nail_dark_vertical_band'));
      expect(nailIds, contains('nail_spoon_koilonychia'));
    });
  });

  group('AiVisionPromptBuilder, Parser & HybridHealthAnalyzer', () {
    test('builds prompt containing rubric findings and CIE Lab telemetry', () {
      final bytes = _solidPng(225, 175, 170);
      final sample = ColorCalibrator.sampleImage(
        image: img.decodeImage(bytes)!,
      );

      final request = AiVisionPromptBuilder.build(
        category: CheckCategory.nail,
        imageBytes: bytes,
        calibratedSample: sample,
      );

      expect(request.allowedFindingIds, contains('nail_healthy_pink'));
      expect(request.allowedFindingIds, contains('nail_dark_vertical_band'));
      expect(request.userPrompt, contains('nail_cyanotic_blue'));
      expect(request.userPrompt, contains('cie_lab'));
      expect(request.userPrompt, contains('matched_finding_ids'));
    });

    test('parses fenced Vision AI JSON into AnalysisResult', () {
      final raw = '''
```json
{
  "image_quality_ok": true,
  "matched_finding_ids": ["nail_pale_bed"],
  "risk_level": "attention",
  "summary_title": "Soluk Tırnak Yatağı İpucu",
  "summary_detail": "Sağlıklı pembe tırnak referansına kıyasla daha soluk ton gözlendi.",
  "observations": ["Tırnak yatağı soluk pembe tonda."],
  "recommendations": ["Halsizlik varsa kan sayımı için doktora danışın."],
  "warning_flags": [],
  "confidence": 0.81
}
```
''';

      final result = AiVisionResponseParser.parse(
        rawResponse: raw,
        category: CheckCategory.nail,
        dominantColorValue: const Color(0xFFEEE4E2).toARGB32(),
        whiteBalanceCalibrated: true,
      );

      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, 'Soluk Tırnak Yatağı İpucu');
      expect(result.whiteBalanceCalibrated, isTrue);
      expect(result.confidence, closeTo(0.81, 0.001));
    });

    test('HybridHealthAnalyzer uses VisionAiClient and falls back offline gracefully', () async {
      final bytes = _solidPng(230, 180, 175);
      final aiPayload = jsonEncode({
        'image_quality_ok': true,
        'matched_finding_ids': ['nail_healthy_pink'],
        'risk_level': 'normal',
        'summary_title': 'AI: Sağlıklı Pembe Tırnak',
        'summary_detail': 'Referans pembe tırnak tonuyla uyumlu.',
        'observations': ['Yüzey pürüzsüz ve pembe.'],
        'recommendations': ['Mevcut bakımı sürdürün.'],
        'warning_flags': <String>[],
        'confidence': 0.86,
      });

      final stubClient = _StubVisionAiClient(response: aiPayload);
      final hybridOnline = HybridHealthAnalyzer(
        fallbackAnalyzer: ColorHealthAnalyzer(),
        aiClient: stubClient,
      );

      final aiResult = await hybridOnline.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: bytes,
      );
      expect(stubClient.lastRequest, isNotNull);
      expect(aiResult.summaryTitle, 'AI: Sağlıklı Pembe Tırnak');
      expect(aiResult.riskLevel, RiskLevel.normal);

      // Offline / error fallback -> uses ColorHealthAnalyzer seamlessly
      final failingClient = _StubVisionAiClient(shouldThrow: true);
      final hybridOffline = HybridHealthAnalyzer(
        fallbackAnalyzer: ColorHealthAnalyzer(),
        aiClient: failingClient,
      );
      final fallbackResult = await hybridOffline.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: bytes,
      );
      expect(fallbackResult.category, CheckCategory.nail);
      expect(fallbackResult.riskLevel, RiskLevel.normal);
    });

    testWidgets('ModuleReferenceSheet displays healthy and unhealthy nail findings', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModuleReferenceSheet(category: CheckCategory.nail),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tırnak — Görsel Referanslar'), findsOneWidget);
      expect(find.text('Sağlıklı Pembe Tırnak'), findsOneWidget);
      expect(find.text('Soluk / Beyazımsı Tırnak Yatağı'), findsOneWidget);
    });
  });
}
