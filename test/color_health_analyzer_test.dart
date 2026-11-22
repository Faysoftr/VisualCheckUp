import 'package:flutter_test/flutter_test.dart';
import 'package:healthcheck/features/checkup/data/color_health_analyzer.dart';
import 'package:healthcheck/features/checkup/domain/analysis_result.dart';
import 'package:healthcheck/features/checkup/domain/check_category.dart';

void main() {
  final analyzer = ColorHealthAnalyzer();

  group('ColorHealthAnalyzer', () {
    test('flags yellowish eye sclera as urgent', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.eye,
        r: 235,
        g: 215,
        b: 110,
      );
      expect(result.riskLevel, RiskLevel.urgent);
    });

    test('treats neutral white eye sclera as normal', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.eye,
        r: 235,
        g: 235,
        b: 232,
      );
      expect(result.riskLevel, RiskLevel.normal);
    });

    test('treats pale straw urine as normal hydration', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.urine,
        r: 245,
        g: 238,
        b: 185,
      );
      expect(result.riskLevel, RiskLevel.normal);
    });

    test('flags reddish urine as urgent', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.urine,
        r: 210,
        g: 75,
        b: 85,
      );
      expect(result.riskLevel, RiskLevel.urgent);
    });

    test('flags very dark black stool as urgent', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.stool,
        r: 20,
        g: 18,
        b: 16,
      );
      expect(result.riskLevel, RiskLevel.urgent);
    });

    test('treats brown stool as normal', () {
      final result = analyzer.analyzeRgb(
        category: CheckCategory.stool,
        r: 120,
        g: 80,
        b: 50,
      );
      expect(result.riskLevel, RiskLevel.normal);
    });

    test('serializes and deserializes AnalysisResult cleanly', () {
      final original = analyzer.analyzeRgb(
        category: CheckCategory.nail,
        r: 220,
        g: 170,
        b: 165,
      );
      final restored = AnalysisResult.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.category, original.category);
      expect(restored.riskLevel, original.riskLevel);
      expect(restored.dominantColorValue, original.dominantColorValue);
    });
  });
}
