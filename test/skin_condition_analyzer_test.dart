import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
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

Uint8List _buildRoughWartImage() {
  final image = img.Image(width: 100, height: 100);
  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 100; x++) {
      final inCenter = x >= 35 && x < 65 && y >= 35 && y < 65;
      if (!inCenter) {
        image.setPixelRgb(x, y, 220, 188, 168);
      } else if ((x % 7 == 0) && (y % 7 == 0)) {
        // Pinpoint dark thrombosed capillary dots
        image.setPixelRgb(x, y, 28, 22, 20);
      } else if ((x + y) % 2 == 0) {
        image.setPixelRgb(x, y, 224, 212, 196);
      } else {
        image.setPixelRgb(x, y, 168, 152, 138);
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('SkinConditionAnalyzer — core & general concerns', () {
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

  group('SkinConditionAnalyzer — 4 dedicated sub-modules (Cancer Risk, Wart, Bruise, Facial Spot)', () {
    test('skinCancerRisk flags non-healing sore as urgent with dermoscopy guidance', () async {
      final bytes = _buildSyntheticSkinImage(
        outerRgb: (220, 188, 168),
        centerLeftRgb: (170, 95, 85),
        centerRightRgb: (165, 92, 82),
      );
      const analyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.skinCancerRisk,
          symptoms: {SkinSymptomFlag.nonHealingSore},
          bodyArea: 'Yüz / Boyun',
        ),
      );

      final result = await analyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: bytes,
      );

      expect(result.riskLevel, RiskLevel.urgent);
      expect(result.summaryTitle, contains('Dermoskopi'));
      expect(result.summaryDetail, contains('kesin kanser teşhisi değildir'));
    });

    test('bruise detects fresh blue-purple stage, healing green-yellow stage, and escalates spontaneous bruise', () async {
      final purpleBruise = _buildSyntheticSkinImage(
        outerRgb: (220, 188, 168),
        centerLeftRgb: (96, 72, 136),
        centerRightRgb: (92, 68, 130),
      );
      const freshAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.bruise,
          bodyArea: 'Bacak / Ayak',
        ),
      );
      final freshResult = await freshAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: purpleBruise,
      );
      expect(freshResult.riskLevel, RiskLevel.attention);
      expect(freshResult.summaryTitle, contains('Taze / Orta Evre'));

      const spontaneousAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.bruise,
          symptoms: {SkinSymptomFlag.spontaneousNoTrauma},
        ),
      );
      final spontaneousResult = await spontaneousAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: purpleBruise,
      );
      expect(spontaneousResult.riskLevel, RiskLevel.urgent);
      expect(spontaneousResult.summaryTitle, contains('Darbesiz Morluk'));

      final healingBruise = _buildSyntheticSkinImage(
        outerRgb: (220, 188, 168),
        centerLeftRgb: (152, 165, 84),
        centerRightRgb: (158, 168, 88),
      );
      final healingResult = await freshAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: healingBruise,
      );
      expect(healingResult.riskLevel, RiskLevel.normal);
      expect(healingResult.summaryTitle, contains('İyileşme Evresi'));
    });

    test('wart detects rough textured surface + pinpoint dots and warns against facial OTC acid', () async {
      final wartBytes = _buildRoughWartImage();
      const wartAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.wart,
          bodyArea: 'Yüz / Boyun',
        ),
      );

      final result = await wartAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: wartBytes,
      );

      expect(result.riskLevel, RiskLevel.attention);
      expect(result.summaryTitle, contains('Siğil'));
      expect(
        result.recommendations.any((r) => r.contains('reçetesiz siğil asidi')),
        isTrue,
      );
    });

    test('facialSpot distinguishes uniform sunspot pigment from suspicious asymmetric facial dark lesion', () async {
      final sunspotBytes = _buildSyntheticSkinImage(
        outerRgb: (226, 196, 174),
        centerLeftRgb: (172, 134, 108),
        centerRightRgb: (170, 132, 106),
      );
      const facialAnalyzer = SkinConditionAnalyzer(
        skinContext: SkinCheckContext(
          concernType: SkinConcernType.facialSpot,
          symptoms: {SkinSymptomFlag.sunOrHormoneHistory},
          bodyArea: 'Yüz / Boyun',
        ),
      );

      final sunspotResult = await facialAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: sunspotBytes,
      );
      expect(sunspotResult.riskLevel, RiskLevel.attention);
      expect(sunspotResult.summaryTitle, contains('Güneş / Melazma'));

      final suspiciousFacialBytes = _buildSyntheticSkinImage(
        outerRgb: (226, 196, 174),
        centerLeftRgb: (44, 30, 24),
        centerRightRgb: (140, 96, 72),
      );
      final suspiciousResult = await facialAnalyzer.analyzeImage(
        category: CheckCategory.skinCondition,
        imageBytes: suspiciousFacialBytes,
      );
      expect(suspiciousResult.riskLevel, RiskLevel.urgent);
      expect(suspiciousResult.summaryTitle, contains('Dermoskopi'));
    });

    testWidgets('Drawer Cilt category launches SkinCheckScreen directly into Morluk Takibi', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      await tester.pumpWidget(
        const VisualCheckUpApp(
          initialUser: AuthUser(
            id: 'u_skin',
            displayName: 'Ece Arslan',
            provider: AuthProviderType.apple,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open left drawer and expand Visual Checks accordion, then Cilt (Ben, Siğil, Morluk, Leke)
      final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawerScrollable = find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ).first;

      final visualAccordion = find.byKey(const Key('drawer_group_visual'));
      await tester.scrollUntilVisible(
        visualAccordion,
        150,
        scrollable: drawerScrollable,
      );
      await tester.ensureVisible(visualAccordion);
      await tester.pumpAndSettle();
      await tester.tap(visualAccordion);
      await tester.pumpAndSettle();

      expect(find.text('Göz (Sklera)'), findsAtLeastNWidgets(1));
      expect(find.text('Dil'), findsAtLeastNWidgets(1));
      expect(find.text('Tırnak'), findsAtLeastNWidgets(1));

      final ciltTile = find.text('Cilt (Ben, Siğil, Morluk, Leke)');
      await tester.scrollUntilVisible(
        ciltTile,
        200,
        scrollable: drawerScrollable,
      );
      await tester.ensureVisible(ciltTile);
      await tester.pumpAndSettle();
      await tester.tap(ciltTile);
      await tester.pumpAndSettle();

      final morlukTile = find.text('Morluk Takibi');
      await tester.scrollUntilVisible(
        morlukTile,
        200,
        scrollable: drawerScrollable,
      );
      await tester.ensureVisible(morlukTile);
      await tester.pumpAndSettle();
      await tester.tap(morlukTile);
      await tester.pumpAndSettle();

      expect(find.text('Cilt Hastalıkları Ön Kontrol'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Morluk Renk Evreleri Rehberi'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Morluk Renk Evreleri Rehberi'), findsOneWidget);
      expect(find.text('Darbe olmadan kendiliğinden çıktı'), findsOneWidget);
    });
  });
}
