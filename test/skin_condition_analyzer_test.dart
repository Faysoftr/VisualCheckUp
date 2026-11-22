import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/skin/data/skin_condition_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

Uint8List _buildSyntheticSkinImage({
  required (int, int, int) outerRgb,
  required (int, int, int) centerLeftRgb,
  required (int, int, int) centerRightRgb,
}) {
  final image = img.Image(width: 100, height: 100);
  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 100; x++) {
      final inCenter = x >= 35 && x < 65 && y >= 35 && y < 65;
      if (!inCenter) {
        image.setPixelRgb(x, y, outerRgb.$1, outerRgb.$2, outerRgb.$3);
      } else if (x < 50) {
        image.setPixelRgb(
          x,
          y,
          centerLeftRgb.$1,
          centerLeftRgb.$2,
          centerLeftRgb.$3,
        );
      } else {
        image.setPixelRgb(
          x,
          y,
          centerRightRgb.$1,
          centerRightRgb.$2,
          centerRightRgb.$3,
        );
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('SkinConditionAnalyzer', () {
    test('flags dark asymmetric variegated mole as urgent (ABCDE)', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (220, 185, 165),
        centerLeftRgb: (40, 28, 24),
        centerRightRgb: (125, 85, 65),
      );
      const analyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.molePigment,
          bodyArea: 'Kol / El',
        ),
      );

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.category, CheckCategory.skinCondition);
      expect(result.riskLevel, RiskLevel.urgent);
      expect(result.warningFlags, isNotEmpty);
    });

    test('flags strong redness with infection symptoms as urgent', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (220, 190, 170),
        centerLeftRgb: (215, 70, 70),
        centerRightRgb: (210, 68, 72),
      );
      const analyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.rashRedness,
          symptoms: {
            SkinSymptomFlag.painOrWarmth,
            SkinSymptomFlag.spreading,
          },
        ),
      );

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.riskLevel, RiskLevel.urgent);
      expect(result.summaryTitle, contains('Enfeksiyon'));
    });

    test('flags localized redness without red flags as attention', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (222, 192, 172),
        centerLeftRgb: (212, 110, 108),
        centerRightRgb: (214, 112, 110),
      );
      const analyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.rashRedness,
          symptoms: {SkinSymptomFlag.itching},
        ),
      );

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Kızarıklık'));
    });

    test('flags scaly bright-flecked patch as attention', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (215, 182, 162),
        centerLeftRgb: (238, 234, 232),
        centerRightRgb: (205, 140, 130),
      );
      const analyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.scalyDry,
        ),
      );

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Pullu'));
    });

    test('treats uniform healthy skin as normal', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (220, 188, 168),
        centerLeftRgb: (218, 186, 166),
        centerRightRgb: (221, 189, 169),
      );
      const analyzer = SkinConditionAnalyzer();

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.riskLevel, RiskLevel.normal);
    });
  });
}
