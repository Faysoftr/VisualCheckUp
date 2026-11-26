import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';

Uint8List _buildDualBoxImage({
  required (int, int, int) targetRgb,
  required (int, int, int) whiteRefRgb,
  double glareFraction = 0.0,
}) {
  final image = img.Image(width: 100, height: 100);
  int centerPixelIndex = 0;
  final totalCenterPixels = 40 * 40;
  final glarePixels = (totalCenterPixels * glareFraction).round();

  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 100; x++) {
      final inWhiteBox = x >= 35 && x < 65 && y >= 74 && y < 88;
      final inTarget = x >= 30 && x < 70 && y >= 30 && y < 70;
      if (inWhiteBox) {
        image.setPixelRgb(x, y, whiteRefRgb.$1, whiteRefRgb.$2, whiteRefRgb.$3);
      } else if (inTarget) {
        if (centerPixelIndex < glarePixels) {
          image.setPixelRgb(x, y, 255, 255, 255);
        } else {
          image.setPixelRgb(x, y, targetRgb.$1, targetRgb.$2, targetRgb.$3);
        }
        centerPixelIndex++;
      } else {
        image.setPixelRgb(x, y, whiteRefRgb.$1, whiteRefRgb.$2, whiteRefRgb.$3);
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('LabColor & ColorCalibrator', () {
    test('converts neutral white and yellow accurately to CIE L*a*b*', () {
      final white = LabColor.fromRgb(255, 255, 255);
      expect(white.l, closeTo(100.0, 0.5));
      expect(white.a, closeTo(0.0, 0.5));
      expect(white.b, closeTo(0.0, 0.5));

      final yellow = LabColor.fromRgb(240, 225, 90);
      expect(yellow.b, greaterThan(45.0));

      final blue = LabColor.fromRgb(90, 120, 220);
      expect(blue.b, lessThan(-30.0));

      expect(white.deltaE(white), closeTo(0.0, 0.001));
      expect(white.deltaE(yellow), greaterThan(40.0));
    });

    test(
      'Von Kries white-reference calibration corrects warm bulb cast on normal eye sclera',
      () async {
        // Under a warm yellow bulb, true white sclera & white paper both shift
        // heavily toward yellow (240, 210, 145).
        final bytes = _buildDualBoxImage(
          targetRgb: (238, 208, 145),
          whiteRefRgb: (242, 212, 148),
        );

        final analyzer = ColorHealthAnalyzer();

        // Without calibration, the warm cast triggers a false yellow warning.
        final uncalibrated = await analyzer.analyzeImage(
          category: CheckCategory.eye,
          imageBytes: bytes,
          options: const AnalysisOptions(useWhiteReference: false),
        );
        expect(uncalibrated.whiteBalanceCalibrated, isFalse);
        expect(uncalibrated.riskLevel, RiskLevel.urgent);
        expect(uncalibrated.lightingNote, contains('Sıcak'));

        // With white reference enabled, Von Kries restores neutral sclera!
        final calibrated = await analyzer.analyzeImage(
          category: CheckCategory.eye,
          imageBytes: bytes,
          options: const AnalysisOptions(useWhiteReference: true),
        );
        expect(calibrated.whiteBalanceCalibrated, isTrue);
        expect(calibrated.riskLevel, RiskLevel.normal);
        expect(calibrated.confidence, greaterThan(uncalibrated.confidence));
      },
    );

    test('trimmed-median sampling filters specular glare pixels', () {
      final bytes = _buildDualBoxImage(
        targetRgb: (200, 120, 120),
        whiteRefRgb: (240, 240, 240),
        glareFraction: 0.14,
      );
      final decoded = img.decodeImage(bytes)!;
      final sample = ColorCalibrator.sampleImage(image: decoded);

      expect(sample.glareFilteredRatio, greaterThanOrEqualTo(0.12));
      // True underlying color (200, 120, 120) should remain intact despite 14% glare
      expect((sample.rawColor.r * 255).round(), closeTo(200, 4));
      expect((sample.rawColor.g * 255).round(), closeTo(120, 4));
      expect((sample.rawColor.b * 255).round(), closeTo(120, 4));
    });

    test('evaluates ambient lighting quality accurately (ideal, dark, and warm yellow)', () {
      // 1. Ideal neutral daylight
      final idealImg = img.Image(width: 100, height: 100);
      img.fill(idealImg, color: img.ColorRgb8(210, 205, 200));
      final idealReport = ColorCalibrator.evaluateLightingQuality(idealImg);
      expect(idealReport.isOptimal, isTrue);
      expect(idealReport.status, LightingQualityStatus.ideal);

      // 2. Insufficient / underexposed dark lighting
      final darkImg = img.Image(width: 100, height: 100);
      img.fill(darkImg, color: img.ColorRgb8(20, 20, 22));
      final darkReport = ColorCalibrator.evaluateLightingQuality(darkImg);
      expect(darkReport.isOptimal, isFalse);
      expect(darkReport.status, LightingQualityStatus.insufficientLight);

      // 3. Warm incandescent / yellow bulb
      final warmImg = img.Image(width: 100, height: 100);
      img.fill(warmImg, color: img.ColorRgb8(235, 175, 95));
      final warmReport = ColorCalibrator.evaluateLightingQuality(warmImg);
      expect(warmReport.isOptimal, isFalse);
      expect(warmReport.status, LightingQualityStatus.warmYellow);
    });
  });

  group('Personal CategoryBaseline persistence & comparison', () {
    test('saves, loads, and detects significant personal color shift', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = HistoryRepository();

      final baseline = CategoryBaseline.fromColor(
        category: CheckCategory.nail,
        color: const Color.fromARGB(255, 225, 175, 170),
        calibratedWithWhiteRef: true,
      );
      await repo.saveBaseline(baseline);

      final restored = await repo.getBaseline(CheckCategory.nail);
      expect(restored, isNotNull);
      expect(restored!.calibratedWithWhiteRef, isTrue);

      final analyzer = ColorHealthAnalyzer();
      final nearNormal = analyzer.analyzeRgb(
        category: CheckCategory.nail,
        r: 222,
        g: 173,
        b: 168,
        baseline: restored,
      );
      expect(nearNormal.baselineDeltaE, lessThan(6.0));
      expect(nearNormal.baselineComparisonNote, contains('çok yakın'));

      final shiftedYellow = analyzer.analyzeRgb(
        category: CheckCategory.nail,
        r: 225,
        g: 205,
        b: 130,
        baseline: restored,
      );
      expect(shiftedYellow.baselineDeltaE, greaterThan(13.0));
      expect(shiftedYellow.baselineComparisonNote, contains('daha sarı'));
    });

    testWidgets('ResultScreen allows saving and clearing personal baseline', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = HistoryRepository();
      final result = ColorHealthAnalyzer().analyzeRgb(
        category: CheckCategory.urine,
        r: 245,
        g: 238,
        b: 190,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            result: result,
            historyRepository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Kişisel Normalim Olarak Kaydet'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Kişisel Normalim Olarak Kaydet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kişisel Normalim Olarak Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('Kişisel Normalimi Güncelle'), findsOneWidget);
      expect(await repo.getBaseline(CheckCategory.urine), isNotNull);

      await tester.ensureVisible(find.text('Kaydı Sil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaydı Sil'));
      await tester.pumpAndSettle();
      expect(await repo.getBaseline(CheckCategory.urine), isNull);
    });
  });
}
