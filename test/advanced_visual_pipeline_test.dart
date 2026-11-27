import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/ai/ai_vision_contract.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/ai/image_preprocessor.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/skin/data/skin_condition_analyzer.dart';

class _StubVisionAiClient implements VisionAiClient {
  _StubVisionAiClient(this.riskLevel);

  final String riskLevel;
  AiVisionRequest? lastRequest;

  @override
  Future<String> analyzeWithVisionAi(AiVisionRequest request) async {
    lastRequest = request;
    return jsonEncode({
      'image_quality_ok': true,
      'matched_finding_ids': [request.allowedFindingIds.first],
      'risk_level': riskLevel,
      'summary_title': 'AI Değerlendirmesi',
      'summary_detail': 'Görsel ön değerlendirme tamamlandı.',
      'observations': ['Görüntü işlendi.'],
      'recommendations': ['Takibe devam edin.'],
      'warning_flags': <String>[],
      'confidence': 0.80,
    });
  }
}

void main() {
  group('CIEDE2000 & Linear Shades-of-Gray Color Constancy', () {
    test('deltaE2000 matches Sharma-Wu-Dalal (2005) ISO reference values', () {
      const pair1a = LabColor(l: 50.0, a: 2.6772, b: -79.7751);
      const pair1b = LabColor(l: 50.0, a: 0.0, b: -82.7485);
      expect(pair1a.deltaE2000(pair1b), closeTo(2.0425, 0.02));

      const pair2a = LabColor(l: 50.0, a: 3.1571, b: -77.2803);
      const pair2b = LabColor(l: 50.0, a: 0.0, b: -82.7485);
      expect(pair2a.deltaE2000(pair2b), closeTo(2.8615, 0.02));

      expect(pair1a.deltaE2000(pair1a), closeTo(0.0, 0.0001));
    });

    test(
      'Shades-of-Gray (p=6) corrects warm bulb cast on multi-tonal scene while guarding uniform close-ups',
      () {
        // 1. Multi-tonal realistic scene under warm tungsten bulb (dark shadows + midtones + bright neutral surface)
        final roomPhoto = img.Image(width: 120, height: 120);
        for (var y = 0; y < 120; y++) {
          for (var x = 0; x < 120; x++) {
            if (y < 30) {
              // Dark shadow region
              roomPhoto.setPixelRgb(x, y, 42, 34, 22);
            } else if (x >= 36 && x < 84 && y >= 36 && y < 84) {
              // White sclera tinted warm by tungsten bulb
              roomPhoto.setPixelRgb(x, y, 236, 206, 152);
            } else {
              // Midtone skin/surrounding under same warm bulb
              roomPhoto.setPixelRgb(x, y, 165, 132, 92);
            }
          }
        }

        final sample = ColorCalibrator.sampleImage(
          image: roomPhoto,
          useWhiteReference: false,
          category: CheckCategory.eye,
        );
        expect(sample.autoColorConstancyApplied, isTrue);
        // Raw yellow b* is significantly reduced after Shades-of-Gray neutralization
        final rawLab = LabColor.fromColor(sample.rawColor);
        expect(sample.lab.b, lessThan(rawLab.b - 6.0));

        // 2. Uniform single-color yellow close-up -> clinical safety guard refuses auto neutralization
        final uniformYellow = img.Image(width: 100, height: 100);
        for (var y = 0; y < 100; y++) {
          for (var x = 0; x < 100; x++) {
            uniformYellow.setPixelRgb(x, y, 235, 210, 115);
          }
        }
        final uniformSample = ColorCalibrator.sampleImage(
          image: uniformYellow,
          useWhiteReference: false,
          category: CheckCategory.eye,
        );
        expect(uniformSample.autoColorConstancyApplied, isFalse);
      },
    );

    test(
      'anatomical foreground gating ignores dark pupil/eyelashes on eye sclera and wet glare on tongue',
      () {
        // Eye frame with dark pupil occupying 35% of central ROI + white sclera
        final eye = img.Image(width: 100, height: 100);
        for (var y = 0; y < 100; y++) {
          for (var x = 0; x < 100; x++) {
            final inPupil = (x - 50) * (x - 50) + (y - 50) * (y - 50) <= 13 * 13;
            if (inPupil) {
              eye.setPixelRgb(x, y, 18, 16, 16);
            } else {
              eye.setPixelRgb(x, y, 232, 230, 228);
            }
          }
        }
        final eyeSample = ColorCalibrator.sampleImage(
          image: eye,
          category: CheckCategory.eye,
        );
        // Dark pupil pixels excluded -> sampled sclera stays bright (> 215)
        expect((eyeSample.calibratedColor.r * 255).round(), greaterThan(215));

        // Healthy pink tongue with wet saliva highlight band (L*>86, C*<11)
        final tongue = img.Image(width: 100, height: 100);
        for (var y = 0; y < 100; y++) {
          for (var x = 0; x < 100; x++) {
            if (y >= 44 && y <= 50 && x >= 35 && x <= 65) {
              // Wet specular saliva highlight (glossy near-white glint)
              tongue.setPixelRgb(x, y, 247, 246, 246);
            } else {
              tongue.setPixelRgb(x, y, 204, 128, 134);
            }
          }
        }
        final features = StructuralFeatureAnalyzer.analyze(
          image: tongue,
          category: CheckCategory.tongue,
        );
        // Wet glare should NOT trigger false white tongue coating patch
        expect(features.hasTongueCoatingPatch, isFalse);
      },
    );
  });

  group('DullRazor Hair Removal & Otsu CIEDE2000 Skin Lesion Pipeline', () {
    test('removes thin dark hair strands on normal skin without erasing solid dark moles', () {
      // 1. Healthy warm beige skin with thin dark 1-2px hair strands
      final hairySkin = img.Image(width: 120, height: 120);
      for (var y = 0; y < 120; y++) {
        for (var x = 0; x < 120; x++) {
          hairySkin.setPixelRgb(x, y, 212, 174, 146);
        }
      }
      // Draw 3 thin diagonal/vertical dark hair strands across center
      for (var i = 20; i < 100; i++) {
        hairySkin.setPixelRgb(48, i, 32, 24, 20);
        hairySkin.setPixelRgb(64, i, 35, 28, 22);
        if (i < 100) {
          hairySkin.setPixelRgb(i, (i * 0.8 + 10).round().clamp(0, 119), 30, 22, 18);
        }
      }

      final cleanedRes = SkinConditionAnalyzer.removeHairDullRazor(hairySkin);
      expect(cleanedRes.hairRatio, greaterThan(0.01));
      // Previously dark hair pixel at (48, 60) should now be inpainted close to skin tone
      final repaired = cleanedRes.cleaned.getPixel(48, 60);
      expect(repaired.r, greaterThan(170));

      // 2. Solid dark circular mole (radius 18px) must NOT be erased by DullRazor
      final moleImg = img.Image(width: 120, height: 120);
      for (var y = 0; y < 120; y++) {
        for (var x = 0; x < 120; x++) {
          final d2 = (x - 60) * (x - 60) + (y - 60) * (y - 60);
          if (d2 <= 18 * 18) {
            moleImg.setPixelRgb(x, y, 48, 32, 26);
          } else {
            moleImg.setPixelRgb(x, y, 212, 174, 146);
          }
        }
      }
      final moleAfter = SkinConditionAnalyzer.removeHairDullRazor(moleImg);
      final moleCenter = moleAfter.cleaned.getPixel(60, 60);
      expect(moleCenter.r, lessThan(65));
    });
  });

  group('Armstrong Urine Scale, Nail-Skin ΔEI, Live Tenengrad & AI Safety Consensus', () {
    test('Armstrong CIEDE2000 hydration scale, urine turbidity & nail-skin ΔEI work accurately', () {
      final paleStraw = LabColor.fromRgb(245, 242, 200);
      final amber = LabColor.fromRgb(185, 118, 28);
      expect(ColorHealthAnalyzer.armstrongHydrationLevel(paleStraw), lessThanOrEqualTo(2));
      expect(ColorHealthAnalyzer.armstrongHydrationLevel(amber), greaterThanOrEqualTo(6));

      // Pale nailbed in center surrounded by normal pink finger skin border
      final nailImg = img.Image(width: 100, height: 100);
      for (var y = 0; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          final inNail = x >= 26 && x <= 74 && y >= 26 && y <= 74;
          if (inNail) {
            nailImg.setPixelRgb(x, y, 224, 218, 214); // pale nailbed
          } else {
            nailImg.setPixelRgb(x, y, 215, 152, 142); // normal pink finger skin
          }
        }
      }
      final nailStruct = StructuralFeatureAnalyzer.analyze(
        image: nailImg,
        category: CheckCategory.nail,
      );
      // Nailbed is markedly paler than surrounding skin -> negative relative ΔEI
      expect(nailStruct.nailSkinEiDelta, lessThan(-5.0));
    });

    test('LiveCameraQuality Tenengrad flags dark and blurry frames while passing sharp well-lit frames', () {
      const w = 96;
      const h = 96;
      // 1. Dark frame
      final darkPlane = Uint8List(w * h)..fillRange(0, w * h, 20);
      final darkQ = ImagePreprocessor.assessLiveLuminancePlane(
        bytes: darkPlane,
        width: w,
        height: h,
        bytesPerRow: w,
        pixelStride: 1,
        category: CheckCategory.nail,
      );
      expect(darkQ.lightingLevel, LiveQualityLevel.poor);

      // 2. Sharp well-lit textured frame
      final sharpPlane = Uint8List(w * h);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          sharpPlane[y * w + x] = ((x ~/ 3) % 2 == 0) ? 165 : 115;
        }
      }
      final sharpQ = ImagePreprocessor.assessLiveLuminancePlane(
        bytes: sharpPlane,
        width: w,
        height: h,
        bytesPerRow: w,
        pixelStride: 1,
        category: CheckCategory.nail,
      );
      expect(sharpQ.isAllGood, isTrue);
    });

    test(
      'HybridHealthAnalyzer Safety Consensus escalates when local flags urgent and AI returns normal',
      () async {
        // Strong yellow sclera image (local analyzer flags URGENT jaundice)
        final yellowEye = img.Image(width: 140, height: 140);
        for (var y = 0; y < 140; y++) {
          for (var x = 0; x < 140; x++) {
            final tex = ((x + y) % 5 == 0) ? -14 : 0;
            yellowEye.setPixelRgb(x, y, 238 + tex, 212 + tex, 90);
          }
        }
        final bytes = Uint8List.fromList(img.encodePng(yellowEye));

        final aiReturnsNormal = _StubVisionAiClient('normal');
        final hybrid = HybridHealthAnalyzer(
          fallbackAnalyzer: ColorHealthAnalyzer(),
          aiClient: aiReturnsNormal,
        );

        final fused = await hybrid.analyzeImage(
          category: CheckCategory.eye,
          imageBytes: bytes,
          options: const AnalysisOptions(allowCloudAi: true),
        );

        // Must NOT silently drop urgent local jaundice to normal!
        expect(fused.riskLevel, RiskLevel.attention);
        expect(
          fused.clinicalMetrics['Hibrit Doğrulama'],
          'Çift Katmanlı Güvenlik Kontrolü',
        );
        expect(aiReturnsNormal.lastRequest?.recommendedModel, 'gemini-2.5-flash-lite');
      },
    );
  });
}
