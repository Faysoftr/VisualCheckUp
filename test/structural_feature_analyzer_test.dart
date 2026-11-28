import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

img.Image _solidImage(int r, int g, int b, {int size = 160}) {
  final image = img.Image(width: size, height: size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      image.setPixelRgb(x, y, r, g, b);
    }
  }
  return image;
}

void main() {
  group('StructuralFeatureAnalyzer & ColorHealthAnalyzer deep visual detection', () {
    final analyzer = ColorHealthAnalyzer();

    test('detects tongue fissures/cracks on an otherwise normal pink tongue', () async {
      final smoothTongue = _solidImage(212, 130, 140);
      final smoothFeat = StructuralFeatureAnalyzer.analyze(
        image: smoothTongue,
        category: CheckCategory.tongue,
      );
      expect(smoothFeat.hasTongueFissures, isFalse);

      // Draw realistic dark linear fissures/cracks across the center pink tongue
      final fissuredTongue = _solidImage(212, 130, 140);
      for (var y = 38; y < 122; y++) {
        // Central deep vertical fissure
        fissuredTongue.setPixelRgb(79, y, 85, 38, 44);
        fissuredTongue.setPixelRgb(80, y, 75, 32, 38);
      }
      for (final branchY in [54, 72, 90, 108]) {
        for (var x = 52; x < 108; x++) {
          fissuredTongue.setPixelRgb(x, branchY, 82, 35, 42);
        }
      }

      final feat = StructuralFeatureAnalyzer.analyze(
        image: fissuredTongue,
        category: CheckCategory.tongue,
      );
      expect(feat.hasTongueFissures, isTrue);

      final result = await analyzer.analyzeImage(
        category: CheckCategory.tongue,
        imageBytes: Uint8List.fromList(img.encodePng(fissuredTongue)),
      );
      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Yarık'));
    });

    test(
      'does NOT false-positive fissures on a healthy open-mouth tongue with teeth, oral cavity shadows, mouth corners, papillae, or median sulcus',
      () async {
        // Build a realistic 200x220 open-mouth healthy tongue photo:
        // - Beige face outside
        // - Upper white teeth + dark interdental gaps
        // - Dark oral/pharyngeal cavity behind & at lateral mouth corners
        // - Healthy rose-pink tongue dorsum + subtle papillae + mild midline sulcus
        final photo = img.Image(width: 200, height: 220);
        for (var y = 0; y < 220; y++) {
          for (var x = 0; x < 200; x++) {
            photo.setPixelRgb(x, y, 232, 194, 168); // facial skin
          }
        }
        // Dark mouth opening (x: 38..162, y: 40..175)
        for (var y = 40; y < 175; y++) {
          for (var x = 38; x < 162; x++) {
            photo.setPixelRgb(x, y, 28, 16, 16);
          }
        }
        // Upper white teeth + dark interdental vertical gaps (y: 40..62)
        for (var y = 40; y < 62; y++) {
          for (var x = 48; x < 152; x++) {
            if (x % 18 == 0) {
              photo.setPixelRgb(x, y, 42, 28, 24);
            } else {
              photo.setPixelRgb(x, y, 244, 238, 218);
            }
          }
        }
        // Healthy pink tongue body (x: 56..144, y: 66..188)
        for (var y = 66; y < 188; y++) {
          for (var x = 56; x < 144; x++) {
            // Subtle natural papillae micro-variation
            final pap = ((x * 7 + y * 13) % 5 == 0) ? -10 : 0;
            photo.setPixelRgb(x, y, 224 + pap, 174 + pap, 172 + pap);
          }
        }
        // Mild physiological median lingual sulcus along x = 100
        for (var y = 85; y < 165; y++) {
          photo.setPixelRgb(100, y, 192, 142, 142);
        }

        final syntheticRes = await analyzer.analyzeImage(
          category: CheckCategory.tongue,
          imageBytes: Uint8List.fromList(img.encodePng(photo)),
        );
        expect(syntheticRes.riskLevel, RiskLevel.normal);
        expect(syntheticRes.matchedFindingIds, contains('tongue_healthy_pink'));
        expect(
          syntheticRes.matchedFindingIds,
          isNot(contains('tongue_fissured_grooves')),
        );

        final uploadedSample = File(
          '/home/antigravity/depositphotos_24782785-stock-photo-healthy-tongue.jpg',
        );
        if (uploadedSample.existsSync()) {
          final realRes = await analyzer.analyzeImage(
            category: CheckCategory.tongue,
            imageBytes: uploadedSample.readAsBytesSync(),
          );
          expect(realRes.riskLevel, RiskLevel.normal);
          expect(realRes.matchedFindingIds, contains('tongue_healthy_pink'));
          expect(
            realRes.matchedFindingIds,
            isNot(contains('tongue_fissured_grooves')),
          );
        }
      },
    );

    test('detects fine red capillary blood vessels on white sclera', () async {
      final cleanEye = _solidImage(236, 236, 234);
      expect(
        StructuralFeatureAnalyzer.analyze(
          image: cleanEye,
          category: CheckCategory.eye,
        ).hasEyeRedVessels,
        isFalse,
      );

      // Draw fine red bloodshot capillaries across the white sclera
      final bloodshotEye = _solidImage(236, 236, 234);
      for (final y in [48, 62, 78, 94, 110]) {
        for (var x = 42; x < 118; x++) {
          bloodshotEye.setPixelRgb(x, y, 210, 52, 54);
          bloodshotEye.setPixelRgb(x, y + 1, 198, 64, 66);
        }
      }

      final feat = StructuralFeatureAnalyzer.analyze(
        image: bloodshotEye,
        category: CheckCategory.eye,
      );
      expect(feat.hasEyeRedVessels, isTrue);

      final result = await analyzer.analyzeImage(
        category: CheckCategory.eye,
        imageBytes: Uint8List.fromList(img.encodePng(bloodshotEye)),
      );
      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Kanlanma'));
    });

    test('detects white lines/spots (leukonychia) on a pink nail', () async {
      final healthyNail = _solidImage(212, 148, 152);
      expect(
        StructuralFeatureAnalyzer.analyze(
          image: healthyNail,
          category: CheckCategory.nail,
        ).hasNailWhiteLinesOrSpots,
        isFalse,
      );

      // Draw transverse white bands / spots on the pink nail plate
      final whiteLineNail = _solidImage(212, 148, 152);
      for (final bandY in [64, 88]) {
        for (var y = bandY; y < bandY + 4; y++) {
          for (var x = 46; x < 114; x++) {
            whiteLineNail.setPixelRgb(x, y, 240, 238, 238);
          }
        }
      }

      final feat = StructuralFeatureAnalyzer.analyze(
        image: whiteLineNail,
        category: CheckCategory.nail,
      );
      expect(feat.hasNailWhiteLinesOrSpots, isTrue);

      final result = await analyzer.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: Uint8List.fromList(img.encodePng(whiteLineNail)),
      );
      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Beyaz Çizgi'));
    });

    test('detects nail cracks, peeling, and surface ridges via edge roughness', () async {
      final crackedNail = _solidImage(208, 146, 150);
      // Draw high-contrast layered cracks, peeling ridges, and jagged splits
      for (var y = 40; y < 120; y += 5) {
        for (var x = 40; x < 120; x++) {
          final dark = (x + y) % 6 < 2;
          if (dark) {
            crackedNail.setPixelRgb(x, y, 120, 76, 80);
            crackedNail.setPixelRgb(x, y + 1, 235, 198, 200);
          }
        }
      }

      final feat = StructuralFeatureAnalyzer.analyze(
        image: crackedNail,
        category: CheckCategory.nail,
      );
      expect(feat.hasNailCracksOrRoughness, isTrue);

      final result = await analyzer.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: Uint8List.fromList(img.encodePng(crackedNail)),
      );
      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Kırılma'));
    });

    test('detects narrow dark vertical melanonychia band on a pink nail as urgent', () async {
      final bandNail = _solidImage(212, 152, 154);
      for (var y = 36; y < 124; y++) {
        for (var x = 76; x < 84; x++) {
          bandNail.setPixelRgb(x, y, 42, 28, 24);
        }
      }

      final feat = StructuralFeatureAnalyzer.analyze(
        image: bandNail,
        category: CheckCategory.nail,
      );
      expect(feat.hasNailDarkVerticalBand, isTrue);

      final result = await analyzer.analyzeImage(
        category: CheckCategory.nail,
        imageBytes: Uint8List.fromList(img.encodePng(bandNail)),
      );
      expect(result.riskLevel, RiskLevel.urgent);
      expect(result.summaryTitle, contains('Dikey Koyu Çizgi'));
    });
  });
}
