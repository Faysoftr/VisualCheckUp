import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/ai/image_preprocessor.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/ai_settings_sheet.dart';

class _CountingVisionAiClient implements VisionAiClient {
  int callCount = 0;
  AiVisionRequest? lastRequest;

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    callCount++;
    lastRequest = request;
    return jsonEncode({
      'image_quality_ok': true,
      'matched_finding_ids': [request.allowedFindingIds.first],
      'risk_level': 'normal',
      'summary_title': 'AI Ön Değerlendirme',
      'summary_detail': 'Referans aralığında görünüyor.',
      'observations': ['Net görüntü işlendi.'],
      'recommendations': ['Takibe devam edin.'],
      'warning_flags': <String>[],
      'confidence': 0.84,
    });
  }
}

img.Image _buildSharpStripedImage(int width, int height) {
  final image = img.Image(width: width, height: height);
  final cx = width ~/ 2;
  final cy = height ~/ 2;
  final rx = width ~/ 5;
  final ry = height ~/ 5;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final inSubject = (x - cx).abs() < rx && (y - cy).abs() < ry;
      if (inSubject) {
        final ridge = (x % 6 == 0) ? -18 : 0;
        image.setPixelRgb(x, y, 220 + ridge, 165 + ridge, 160 + ridge);
      } else {
        image.setPixelRgb(x, y, 90, 75, 72);
      }
    }
  }
  return image;
}

void main() {
  group('ImagePreprocessor (0-token quality gate & compression)', () {
    test('crops and resizes large photos to 512px (urine) and 768px (skin)', () {
      final large = _buildSharpStripedImage(1600, 1200);

      final urinePrep = ImagePreprocessor.prepare(
        decoded: large,
        category: CheckCategory.urine,
      );
      expect(urinePrep.passesQualityGate, isTrue);
      expect(urinePrep.width, lessThanOrEqualTo(512));
      expect(urinePrep.height, lessThanOrEqualTo(512));
      expect(urinePrep.jpegBytes, isNotEmpty);

      final skinPrep = ImagePreprocessor.prepare(
        decoded: large,
        category: CheckCategory.skinCondition,
      );
      expect(skinPrep.passesQualityGate, isTrue);
      expect(skinPrep.width, lessThanOrEqualTo(768));
      expect(skinPrep.height, lessThanOrEqualTo(768));
    });

    test('detects heavily blurred nail image while passing sharp image', () {
      final sharp = _buildSharpStripedImage(240, 240);
      final sharpPrep = ImagePreprocessor.prepare(
        decoded: sharp,
        category: CheckCategory.nail,
      );
      expect(sharpPrep.passesQualityGate, isTrue);

      final blurred = img.gaussianBlur(sharp.clone(), radius: 10);
      final blurPrep = ImagePreprocessor.prepare(
        decoded: blurred,
        category: CheckCategory.nail,
      );
      expect(blurPrep.qualityIssue, ImageQualityIssue.tooBlurry);
      expect(blurPrep.passesQualityGate, isFalse);
    });

    test('blocks dark image for nail but allows pitch-black stool (melena)', () {
      final dark = img.Image(width: 100, height: 100);
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          dark.setPixelRgb(x, y, 12, 12, 12);
        }
      }

      final nailPrep = ImagePreprocessor.prepare(
        decoded: dark,
        category: CheckCategory.nail,
      );
      expect(nailPrep.qualityIssue, ImageQualityIssue.tooDark);

      final stoolPrep = ImagePreprocessor.prepare(
        decoded: dark,
        category: CheckCategory.stool,
      );
      expect(stoolPrep.passesQualityGate, isTrue);
    });
  });

  group('Tiered model routing, 0-token gate, and duplicate hash cache', () {
    test('routes urine to flash-lite and skin/nail to flash with token caps', () {
      final bytes = Uint8List.fromList(
        img.encodeJpg(_buildSharpStripedImage(120, 120), quality: 80),
      );

      final urineReq = AiVisionPromptBuilder.build(
        category: CheckCategory.urine,
        imageBytes: bytes,
      );
      expect(urineReq.modelTier, AiModelTier.lite);
      expect(urineReq.recommendedModel, AiVisionPromptBuilder.liteModelId);
      expect(urineReq.thinkingLevel, 'minimal');
      expect(urineReq.maxOutputTokens, 320);

      final skinReq = AiVisionPromptBuilder.build(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );
      expect(skinReq.modelTier, AiModelTier.standard);
      expect(skinReq.recommendedModel, AiVisionPromptBuilder.standardModelId);
      expect(skinReq.thinkingLevel, 'low');
    });

    test('HybridHealthAnalyzer skips AI on blurry shot, respects opt-out, and caches duplicates', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = HistoryRepository();
      final aiClient = _CountingVisionAiClient();
      final hybrid = HybridHealthAnalyzer(
        fallbackAnalyzer: ColorHealthAnalyzer(),
        aiClient: aiClient,
        cacheRepository: repo,
      );

      // 1. Blurry shot -> 0 AI calls!
      final sharp = _buildSharpStripedImage(240, 240);
      final blurredBytes = Uint8List.fromList(
        img.encodePng(img.gaussianBlur(sharp.clone(), radius: 10)),
      );
      final blurResult = await hybrid.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: blurredBytes,
        options: const AnalysisOptions(allowCloudAi: true),
      );
      expect(aiClient.callCount, 0);
      expect(blurResult.summaryTitle, contains('Bulanık'));

      // 2. Opt-out (allowCloudAi: false) -> 0 AI calls!
      final sharpBytes = Uint8List.fromList(img.encodePng(sharp));
      await hybrid.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: sharpBytes,
        options: const AnalysisOptions(allowCloudAi: false),
      );
      expect(aiClient.callCount, 0);

      // 3. First allowed sharp call -> 1 AI call with compressed JPEG
      final firstAi = await hybrid.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: sharpBytes,
        options: const AnalysisOptions(allowCloudAi: true),
      );
      expect(aiClient.callCount, 1);
      expect(aiClient.lastRequest?.mimeType, 'image/jpeg');
      expect(firstAi.summaryTitle, 'AI Ön Değerlendirme');

      // 4. Exact same image again -> served from hash cache, still 1 AI call!
      final cachedAi = await hybrid.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: sharpBytes,
        options: const AnalysisOptions(allowCloudAi: true),
      );
      expect(aiClient.callCount, 1);
      expect(cachedAi.summaryTitle, 'AI Ön Değerlendirme');
    });

    testWidgets('AiSettingsSheet persists Cloud AI opt-in toggle', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = HistoryRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiSettingsSheet(historyRepository: repo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(await repo.isCloudAiEnabled(), isFalse);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(await repo.isCloudAiEnabled(), isTrue);
    });
  });
}
