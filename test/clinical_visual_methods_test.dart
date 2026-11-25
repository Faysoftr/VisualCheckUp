import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/core/color/structural_feature_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/cross_module_correlator.dart';
import 'package:visualcheckup/features/checkup/data/doctor_report_builder.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/domain/quick_color_swatch.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/clinical_visual_illustration.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/skin/data/skin_condition_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

img.Image _solid(int r, int g, int b, {int size = 160}) {
  final image = img.Image(width: size, height: size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      image.setPixelRgb(x, y, r, g, b);
    }
  }
  return image;
}

void main() {
  group('Clinical Colorimetry — ITA° Fitzpatrick Phototype & Erythema Index', () {
    test('classifies Fitzpatrick I to VI accurately via CIE Lab ITA°', () {
      final veryLight = LabColor.fromRgb(245, 224, 210);
      final tan = LabColor.fromRgb(186, 134, 96);
      final dark = LabColor.fromRgb(74, 46, 32);

      expect(veryLight.fitzpatrickPhototype, FitzpatrickPhototype.veryLight);
      expect(tan.fitzpatrickPhototype, FitzpatrickPhototype.tan);
      expect(
        dark.fitzpatrickPhototype == FitzpatrickPhototype.brown ||
            dark.fitzpatrickPhototype == FitzpatrickPhototype.dark,
        isTrue,
      );
      expect(dark.fitzpatrickPhototype.isDarkerSkinOfColor, isTrue);
      expect(veryLight.fitzpatrickPhototype.isDarkerSkinOfColor, isFalse);
    });

    test('Erythema Index separates vascular pink mucosa from pale anemic tissue', () {
      final healthyConjEi = ColorCalibrator.erythemaIndex(215, 118);
      final paleConjEi = ColorCalibrator.erythemaIndex(234, 214);
      expect(healthyConjEi, greaterThan(20.0));
      expect(paleConjEi, lessThan(6.0));
    });
  });

  group('Deep Clinical 2D Structural Detections (Eye, Nail, Tongue)', () {
    final analyzer = ColorHealthAnalyzer();

    test('Eye palpebral conjunctiva mode flags pale mucosa for anemia and passes healthy pink', () async {
      final paleLid = _solid(232, 206, 206);
      final paleRes = await analyzer.analyzeImage(
        category: CheckCategory.eye,
        imageBytes: Uint8List.fromList(img.encodePng(paleLid)),
        options: const AnalysisOptions(
          eyeScanMode: EyeScanMode.palpebralConjunctiva,
        ),
      );
      expect(paleRes.riskLevel, RiskLevel.attention);
      expect(paleRes.matchedFindingIds, contains('eye_conjunctiva_pallor'));
      expect(paleRes.clinicalMetrics.keys, contains('Konjonktiva Eritem İndeksi'));

      final healthyLid = _solid(212, 112, 118);
      final healthyRes = await analyzer.analyzeImage(
        category: CheckCategory.eye,
        imageBytes: Uint8List.fromList(img.encodePng(healthyLid)),
        options: const AnalysisOptions(
          eyeScanMode: EyeScanMode.palpebralConjunctiva,
        ),
      );
      expect(healthyRes.riskLevel, RiskLevel.normal);
    });

    test('Eye detects compact bright-red subconjunctival hemorrhage as urgent', () async {
      final sclera = _solid(238, 238, 236);
      for (var y = 60; y < 96; y++) {
        for (var x = 78; x < 114; x++) {
          sclera.setPixelRgb(x, y, 204, 28, 32);
        }
      }
      final feat = StructuralFeatureAnalyzer.analyze(
        image: sclera,
        category: CheckCategory.eye,
      );
      expect(feat.hasSubconjunctivalHemorrhage, isTrue);

      final res = await analyzer.analyzeImage(
        category: CheckCategory.eye,
        imageBytes: Uint8List.fromList(img.encodePng(sclera)),
      );
      expect(res.riskLevel, RiskLevel.urgent);
      expect(res.matchedFindingIds, contains('eye_subconjunctival_hemorrhage'));
    });

    test('Nail detects transverse Beau grooves and Terry/Lindsay proximal-distal split', () async {
      // Beau's transverse dark horizontal groove across pink nail
      final beauNail = _solid(214, 152, 154);
      for (var y = 76; y < 83; y++) {
        for (var x = 42; x < 118; x++) {
          beauNail.setPixelRgb(x, y, 118, 72, 74);
        }
      }
      final beauFeat = StructuralFeatureAnalyzer.analyze(
        image: beauNail,
        category: CheckCategory.nail,
      );
      expect(beauFeat.hasNailTransverseGroove, isTrue);

      // Terry's / Lindsay's nail: white proximal 65%, pink-brown distal 25%
      final terryNail = _solid(236, 234, 232);
      for (var y = 96; y < 130; y++) {
        for (var x = 32; x < 128; x++) {
          terryNail.setPixelRgb(x, y, 186, 112, 110);
        }
      }
      final terryFeat = StructuralFeatureAnalyzer.analyze(
        image: terryNail,
        category: CheckCategory.nail,
      );
      expect(terryFeat.hasTerryOrLindsaySplit, isTrue);
    });

    test('Tongue detects geographic tongue (red patches rimmed by white borders)', () async {
      final tongue = _solid(212, 132, 140);
      // Draw smooth red depapillated island rimmed by white border
      for (var y = 50; y < 110; y++) {
        for (var x = 50; x < 110; x++) {
          final dx = x - 80;
          final dy = y - 80;
          final r = math.sqrt(dx * dx + dy * dy);
          if (r <= 18) {
            tongue.setPixelRgb(x, y, 198, 62, 74);
          } else if (r <= 24) {
            tongue.setPixelRgb(x, y, 240, 238, 234);
          }
        }
      }
      final feat = StructuralFeatureAnalyzer.analyze(
        image: tongue,
        category: CheckCategory.tongue,
      );
      expect(feat.hasGeographicTongueCue, isTrue);

      final res = await analyzer.analyzeImage(
        category: CheckCategory.tongue,
        imageBytes: Uint8List.fromList(img.encodePng(tongue)),
      );
      expect(res.riskLevel, RiskLevel.attention);
      expect(res.matchedFindingIds, contains('tongue_geographic_patches'));
    });
  });

  group('SkinConditionAnalyzer — Quantitative ABCDE, Fitzpatrick Fairness & Ringworm', () {
    test('extracts border irregularity, 6-color dermoscopic palette, and clinicalMetrics for suspicious mole', () async {
      // Fair surrounding skin with notched, star-like multi-color dark lesion
      final imgSkin = _solid(228, 192, 168, size: 180);
      for (var y = 48; y < 132; y++) {
        for (var x = 48; x < 132; x++) {
          final dx = x - 90.0;
          final dy = y - 90.0;
          final angle = math.atan2(dy, dx);
          final radius = 22.0 + 12.0 * math.sin(6.0 * angle);
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist <= radius) {
            if (dx < -4 && dy < 0) {
              imgSkin.setPixelRgb(x, y, 24, 18, 16); // Black
            } else if (dx >= 4 && dy < 0) {
              imgSkin.setPixelRgb(x, y, 88, 108, 128); // Blue-Gray
            } else if (dy >= 0 && dx < 0) {
              imgSkin.setPixelRgb(x, y, 178, 56, 52); // Red
            } else {
              imgSkin.setPixelRgb(x, y, 118, 72, 42); // Dark/Light Brown
            }
          }
        }
      }

      const skinAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(concernType: SkinConcernType.skinCancerRisk),
      );
      final metrics = skinAnalyzer.extractMetrics(imgSkin);
      expect(metrics.dermoscopicColors.length, greaterThanOrEqualTo(3));
      expect(metrics.hasMultiDermoscopicColor, isTrue);
      expect(metrics.borderIrregularityIndex, greaterThan(1.3));

      final res = await skinAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: Uint8List.fromList(img.encodePng(imgSkin)),
      );
      expect(res.riskLevel, RiskLevel.urgent);
      expect(res.matchedFindingIds, contains('skin_abcde_suspicious_mole'));
      expect(res.clinicalMetrics.keys, contains('Fitzpatrick Fototip'));
      expect(res.clinicalMetrics.keys, contains('B — Sınır Düzensizliği'));
      expect(res.clinicalMetrics.keys, contains('C — Renk Sayısı'));
    });

    test('detects annular central-clearing ringworm (tinea) and warns against steroid cream', () async {
      final ringImg = _solid(225, 190, 165, size: 160);
      for (var y = 32; y < 128; y++) {
        for (var x = 32; x < 128; x++) {
          final dist = math.sqrt((x - 80) * (x - 80) + (y - 80) * (y - 80));
          if (dist >= 22 && dist <= 36) {
            ringImg.setPixelRgb(x, y, 206, 86, 82); // Active red outer ring
          }
        }
      }
      const skinAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(concernType: SkinConcernType.scalyDry),
      );
      final metrics = skinAnalyzer.extractMetrics(ringImg);
      expect(metrics.hasAnnularClearingRing, isTrue);

      final res = await skinAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: Uint8List.fromList(img.encodePng(ringImg)),
      );
      expect(res.riskLevel, RiskLevel.attention);
      expect(res.matchedFindingIds, contains('skin_ring_fungal_cue'));
      expect(res.recommendations.join(' ').toLowerCase(), contains('kortizon'));
    });

    test('Fitzpatrick V/VI uniform darker skin is NOT falsely flagged as a dark mole', () async {
      final darkHealthy = _solid(98, 66, 48, size: 160);
      const skinAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(concernType: SkinConcernType.general),
      );
      final res = await skinAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: Uint8List.fromList(img.encodePng(darkHealthy)),
      );
      expect(res.riskLevel, RiskLevel.normal);
      expect(res.matchedFindingIds, contains('skin_healthy_intact'));
    });
  });

  group('Bristol Stool Scale, Cross-Module Visual Triads & Doctor Report Export', () {
    test('Bristol Type 7 escalates normal brown stool and records clinical metric', () {
      final brown = QuickColorCardCatalog.swatchesFor(CheckCategory.stool).first;
      final type7 = QuickColorCardCatalog.bristolScale.last;
      final res = QuickColorCardCatalog.buildResult(
        category: CheckCategory.stool,
        swatch: brown,
        bristolType: type7,
      );
      expect(res.riskLevel, RiskLevel.attention);
      expect(res.clinicalMetrics['Bristol Kıvamı'], contains('Tip 7'));
      expect(res.matchedFindingIds, contains('stool_healthy_brown'));
    });

    test('CrossModuleHealthCorrelator detects Jaundice triad and Multi-site Anemia triad', () {
      final now = DateTime(2026, 11, 24, 10, 0);
      final yellowEye = AnalysisResult(
        id: 'eye_1',
        category: CheckCategory.eye,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Göz Akında Sarımsı Ton Algılandı',
        summaryDetail: 'Sklera sararması',
        dominantColorValue: const Color(0xFFEAD776).toARGB32(),
        observations: const [],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.72,
        createdAt: now,
        matchedFindingIds: const ['eye_jaundice_sclera'],
      );
      final darkUrine = AnalysisResult(
        id: 'urine_1',
        category: CheckCategory.urine,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Koyu Kehribar / Çay-Kola Rengi',
        summaryDetail: 'Koyu idrar',
        dominantColorValue: const Color(0xFF8B5723).toARGB32(),
        observations: const [],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.85,
        createdAt: now.subtract(const Duration(days: 1)),
        matchedFindingIds: const ['urine_dark_amber_tea'],
      );

      final jaundiceInsights = CrossModuleHealthCorrelator.correlate(
        visualResult: yellowEye,
        labReports: const [],
        visualHistory: [yellowEye, darkUrine],
      );
      expect(
        jaundiceInsights.any((i) => i.title.contains('Sarılık')),
        isTrue,
      );

      final paleNail = AnalysisResult(
        id: 'nail_1',
        category: CheckCategory.nail,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Soluk / Yaygın Beyaz Tırnak Tonu',
        summaryDetail: 'Soluk tırnak',
        dominantColorValue: const Color(0xFFEEE4E2).toARGB32(),
        observations: const [],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.68,
        createdAt: now,
        matchedFindingIds: const ['nail_pale_bed'],
        clinicalMetrics: const {'Tırnak Eritem İndeksi (Anemi)': '3.8'},
      );
      final paleConj = AnalysisResult(
        id: 'eye_conj_1',
        category: CheckCategory.eye,
        riskLevel: RiskLevel.attention,
        summaryTitle: 'Alt Göz Kapağı İçinde Belirgin Solukluk (Anemi Ön İpucu)',
        summaryDetail: 'Soluk konjonktiva',
        dominantColorValue: const Color(0xFFF1D4D4).toARGB32(),
        observations: const [],
        recommendations: const [],
        warningFlags: const [],
        confidence: 0.72,
        createdAt: now.subtract(const Duration(hours: 2)),
        matchedFindingIds: const ['eye_conjunctiva_pallor'],
      );

      final anemiaInsights = CrossModuleHealthCorrelator.correlate(
        visualResult: paleNail,
        labReports: const [],
        visualHistory: [paleNail, paleConj],
      );
      expect(
        anemiaInsights.any((i) => i.title.contains('Anemi')),
        isTrue,
      );

      final report = DoctorReportBuilder.build(currentResult: paleNail);
      expect(report.toShareableText(), contains('Tırnak Eritem İndeksi (Anemi): 3.8'));
    });
  });

  group('Visual Clinical Reference Atlas & ResultScreen Side-by-Side Comparison', () {
    testWidgets('ClinicalVisualIllustration renders for every finding in ModuleReferenceCatalog', (
      tester,
    ) async {
      final allCards = <Widget>[];
      for (final spec in ModuleReferenceCatalog.all) {
        expect(spec.selfTests, isNotEmpty);
        for (final f in spec.findings) {
          allCards.add(
            ClinicalVisualIllustration(
              findingId: f.id,
              category: spec.category,
              fallbackColor: f.swatchColor,
              size: 40,
            ),
          );
        }
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Wrap(children: allCards),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ClinicalVisualIllustration), findsWidgets);
    });

    testWidgets('ModuleReferenceSheet switches to Evde Klinik Testler and shows Schamroth Test', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModuleReferenceSheet(category: CheckCategory.nail),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Evde Klinik Testler'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Schamroth Pencere Testi'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('ABCDEF Kuralı'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('ABCDEF Kuralı'), findsOneWidget);
    });

    testWidgets('ResultScreen renders visual reference comparison card and clinical biomarkers card', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final res = AnalysisResult(
        id: 'skin_test_1',
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Ben / Koyu Leke — Dermatolog Değerlendirmesi Önerilir',
        summaryDetail: 'ABCDE bulgusu saptandı.',
        dominantColorValue: const Color(0xFF47302A).toARGB32(),
        observations: const ['Çoklu renk gözlendi.'],
        recommendations: const ['Dermatoloğa başvurun.'],
        warningFlags: const ['Hızlı büyüme uyarısı.'],
        confidence: 0.72,
        createdAt: DateTime(2026, 11, 24, 12, 0),
        matchedFindingIds: const ['skin_abcde_suspicious_mole'],
        clinicalMetrics: const {
          'Fitzpatrick Fototip': 'Tip II (Açık) (ITA 46°)',
          'A — Asimetri': '%32',
          'B — Sınır Düzensizliği': '2.15',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResultScreen(result: res),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resimli Klinik Referans Kıyaslaması'), findsOneWidget);
      expect(find.byType(ClinicalVisualIllustration), findsNWidgets(2));
      await tester.scrollUntilVisible(
        find.text('Kantitatif Klinik Ölçümler'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Kantitatif Klinik Ölçümler'), findsOneWidget);
      expect(find.text('Tip II (Açık) (ITA 46°)'), findsOneWidget);
    });

    testWidgets('Visual Atlas and ResultScreen clinical cards localize cleanly into English and Arabic', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ModuleReferenceSheet(category: CheckCategory.nail),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Illustrated Atlas'), findsOneWidget);
      expect(find.textContaining('Home Clinical Tests'), findsOneWidget);

      final res = AnalysisResult(
        id: 'skin_i18n_en',
        category: CheckCategory.skinCondition,
        riskLevel: RiskLevel.urgent,
        summaryTitle: 'Suspicious Mole',
        summaryDetail: 'ABCDE finding.',
        dominantColorValue: const Color(0xFF47302A).toARGB32(),
        observations: const ['Variegated pigment'],
        recommendations: const ['See dermatologist'],
        warningFlags: const [],
        confidence: 0.72,
        createdAt: DateTime(2026, 11, 25, 12, 0),
        matchedFindingIds: const ['skin_abcde_suspicious_mole'],
        clinicalMetrics: const {
          'Fitzpatrick Fototip': 'Type II (ITA 46°)',
          'A — Asimetri': '32%',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResultScreen(result: res),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مقارنة المرجع السريري المصور'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('القياسات السريرية الكمية'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('القياسات السريرية الكمية'), findsOneWidget);
      expect(find.text('نمط فيتزباتريك للبشرة'), findsOneWidget);
      expect(find.text('A — عدم التماثل'), findsOneWidget);
    });
  });
}
