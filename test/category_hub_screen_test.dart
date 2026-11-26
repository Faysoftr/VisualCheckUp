import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/category_hub_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/photo_zoom_viewer.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

File _createTempPng(Directory dir, String name, int r, int g, int b) {
  final image = img.Image(width: 48, height: 48);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  final file = File('${dir.path}/$name.png');
  file.writeAsBytesSync(img.encodePng(image));
  return file;
}

void main() {
  group('CategoryHubScreen — Module Landing Hub, Past Scans Table, Zoom & 2-Scan Compare', () {
    late Directory tempDir;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      tempDir = Directory.systemTemp.createTempSync('vcu_hub_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets(
      'displays Start New Scan, Past Scans table with thumbnails, opens ResultScreen and PhotoZoomViewer on tap',
      (tester) async {
        final photo1 = _createTempPng(tempDir, 'tongue_1', 210, 120, 130);
        final photo2 = _createTempPng(tempDir, 'tongue_2', 235, 225, 210);

        final repo = HistoryRepository();
        await repo.saveResult(
          AnalysisResult(
            id: 'tongue_old',
            category: CheckCategory.tongue,
            riskLevel: RiskLevel.normal,
            summaryTitle: 'Dil Rengi Olağan',
            summaryDetail: 'Sağlıklı pembe dil görünümü.',
            dominantColorValue: const Color(0xFFD27882).toARGB32(),
            observations: const ['Doğal pembe ton.'],
            recommendations: const ['Su tüketimine devam edin.'],
            warningFlags: const [],
            confidence: 0.78,
            createdAt: DateTime(2026, 11, 10, 9, 30),
            imagePath: photo1.path,
            clinicalMetrics: const {'Eritem İndeksi (EI)': '44'},
          ),
        );
        await repo.saveResult(
          AnalysisResult(
            id: 'tongue_new',
            category: CheckCategory.tongue,
            riskLevel: RiskLevel.attention,
            summaryTitle: 'Beyazımsı Pas / Kaplama',
            summaryDetail: 'Dil yüzeyinde beyaz tabaka gözlendi.',
            dominantColorValue: const Color(0xFFEBE1D2).toARGB32(),
            observations: const ['Beyaz pas tabakası.'],
            recommendations: const ['Ağız hijyeni ve sıvı alımını artırın.'],
            warningFlags: const [],
            confidence: 0.72,
            createdAt: DateTime(2026, 11, 24, 14, 15),
            imagePath: photo2.path,
            clinicalMetrics: const {'Eritem İndeksi (EI)': '22'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CategoryHubScreen(
              category: CheckCategory.tongue,
              historyRepository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Top action button + Table headers + Both rows rendered
        expect(find.text('Yeni Tarama Başlat'), findsOneWidget);
        expect(find.text('Geçmiş Taramalar (2)'), findsOneWidget);
        expect(find.text('Fotoğraf'), findsOneWidget);
        expect(find.text('Tarih'), findsOneWidget);
        expect(find.text('Dil Rengi Olağan'), findsOneWidget);
        expect(find.text('Beyazımsı Pas / Kaplama'), findsOneWidget);
        // 1 module editorial header backdrop + 2 past scan thumbnails
        expect(find.byType(Image), findsNWidgets(3));

        // Filter to Attention/Urgent only -> hides normal scan
        await tester.tap(find.text('Uyarı / Takip'));
        await tester.pumpAndSettle();
        expect(find.text('Beyazımsı Pas / Kaplama'), findsOneWidget);
        expect(find.text('Dil Rengi Olağan'), findsNothing);

        // Reset filter to All
        await tester.tap(find.text('Tümü'));
        await tester.pumpAndSettle();

        // Tap newest row -> opens ResultScreen with captured photo + full report
        await tester.tap(find.byKey(const Key('hub_row_tongue_new')));
        await tester.pumpAndSettle();

        expect(find.byType(ResultScreen), findsOneWidget);
        expect(find.text('Beyazımsı Pas / Kaplama'), findsOneWidget);
        expect(find.text('Tam ekran büyütmek için fotoğrafa dokunun'), findsOneWidget);

        // Tap captured photo -> opens full-screen PhotoZoomViewer
        await tester.tap(find.byKey(Key('result_photo_${photo2.path.hashCode}')));
        await tester.pumpAndSettle();

        expect(find.byType(PhotoZoomViewer), findsOneWidget);
        expect(find.byType(InteractiveViewer), findsOneWidget);
      },
    );

    testWidgets(
      'Compare 2 Scans mode selects 2 past rows and displays side-by-side comparison with metrics',
      (tester) async {
        final photoOld = _createTempPng(tempDir, 'nail_old', 220, 175, 175);
        final photoNew = _createTempPng(tempDir, 'nail_new', 235, 165, 170);

        final repo = HistoryRepository();
        await repo.saveResult(
          AnalysisResult(
            id: 'nail_1',
            category: CheckCategory.nail,
            riskLevel: RiskLevel.attention,
            summaryTitle: 'Soluk Tırnak Yatağı',
            summaryDetail: 'Solukluk izlendi.',
            dominantColorValue: const Color(0xFFDCAFAF).toARGB32(),
            observations: const ['Solukluk.'],
            recommendations: const ['Hemogram önerilir.'],
            warningFlags: const [],
            confidence: 0.70,
            createdAt: DateTime(2026, 10, 1, 10, 0),
            imagePath: photoOld.path,
            clinicalMetrics: const {'Tırnak Yatağı Eritem İndeksi': '16'},
          ),
        );
        await repo.saveResult(
          AnalysisResult(
            id: 'nail_2',
            category: CheckCategory.nail,
            riskLevel: RiskLevel.normal,
            summaryTitle: 'Tırnak Tonu Olağan',
            summaryDetail: 'Canlı pembe tırnak yatağı.',
            dominantColorValue: const Color(0xFFEBA5AA).toARGB32(),
            observations: const ['Olağan ton.'],
            recommendations: const ['Bakıma devam edin.'],
            warningFlags: const [],
            confidence: 0.80,
            createdAt: DateTime(2026, 11, 20, 10, 0),
            imagePath: photoNew.path,
            clinicalMetrics: const {'Tırnak Yatağı Eritem İndeksi': '38'},
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CategoryHubScreen(
              category: CheckCategory.nail,
              historyRepository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter Compare Mode
        await tester.scrollUntilVisible(
          find.byKey(const Key('hub_compare_mode_btn')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(const Key('hub_compare_mode_btn')));
        await tester.pumpAndSettle();

        // Select both rows
        await tester.scrollUntilVisible(
          find.byKey(const Key('hub_row_nail_1')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(const Key('hub_row_nail_2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('hub_row_nail_1')));
        await tester.pumpAndSettle();

        // Tap Compare Side-by-Side
        await tester.ensureVisible(
          find.byKey(const Key('hub_compare_execute_btn')),
        );
        await tester.tap(find.byKey(const Key('hub_compare_execute_btn')));
        await tester.pumpAndSettle();

        expect(find.text('Yan Yana Tarama Karşılaştırması'), findsOneWidget);
        expect(find.text('Klinik Ölçüm Karşılaştırması'), findsOneWidget);
        expect(find.text('16'), findsOneWidget);
        expect(find.text('38'), findsOneWidget);
      },
    );

    testWidgets(
      'Eye Hub shows Sclera & Lower Eyelid mode chips, empty capture protocol, and localizes in English',
      (tester) async {
        final repo = HistoryRepository();
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CategoryHubScreen(
              category: CheckCategory.eye,
              historyRepository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Start New Scan'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Mode: Sclera (Jaundice)'), findsOneWidget);
        expect(find.text('Lower Eyelid (Anemia)'), findsOneWidget);
        expect(find.text('Past Scans (0)'), findsOneWidget);
        expect(find.text('Best Capture Protocol'), findsOneWidget);
      },
    );

    testWidgets(
      'ResultScreen delete button removes record and refreshes CategoryHubScreen table',
      (tester) async {
        final repo = HistoryRepository();
        await repo.saveResult(
          AnalysisResult(
            id: 'eye_del_1',
            category: CheckCategory.eye,
            riskLevel: RiskLevel.normal,
            summaryTitle: 'Göz Akı Tonu Olağan',
            summaryDetail: 'Olağan görünüm.',
            dominantColorValue: const Color(0xFFF5F3F0).toARGB32(),
            observations: const ['Olağan.'],
            recommendations: const ['Kontrol.'],
            warningFlags: const [],
            confidence: 0.75,
            createdAt: DateTime(2026, 11, 24, 18, 0),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CategoryHubScreen(
              category: CheckCategory.eye,
              historyRepository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Geçmiş Taramalar (1)'), findsOneWidget);

        await tester.tap(find.byKey(const Key('hub_row_eye_del_1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('result_delete_btn')));
        await tester.pumpAndSettle();

        expect(find.text('Bu tarama silinsin mi?'), findsOneWidget);
        await tester.tap(find.text('Sil'));
        await tester.pumpAndSettle();

        expect(find.text('Geçmiş Taramalar (0)'), findsOneWidget);
        expect(await repo.loadHistory(), isEmpty);
      },
    );

    test('all 7 CheckCategory editorial background assets exist on disk', () {
      for (final category in CheckCategory.values) {
        final assetFile = File(category.cardBackgroundAsset);
        expect(
          assetFile.existsSync(),
          isTrue,
          reason: 'Missing card background asset: ${category.cardBackgroundAsset}',
        );
        expect(assetFile.lengthSync(), greaterThan(5000));
      }
    });
  });
}
