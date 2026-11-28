import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/color/organ_isolator.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class _DeniedCameraPermService implements CameraPermissionService {
  const _DeniedCameraPermService();
  @override
  Future<CameraPermissionState> checkCamera() async =>
      CameraPermissionState.denied;
  @override
  Future<CameraPermissionState> requestCamera() async =>
      CameraPermissionState.denied;
  @override
  Future<bool> openSettings() async => false;
}

Uint8List _buildFullFaceAndNeckTonguePhoto() {
  final photo = img.Image(width: 240, height: 280);
  // Warm beige face, neck & cheeks filling the frame
  for (var y = 0; y < 280; y++) {
    for (var x = 0; x < 240; x++) {
      photo.setPixelRgb(x, y, 226, 184, 150);
    }
  }
  // Dark mouth opening + upper white teeth
  for (var y = 60; y < 210; y++) {
    for (var x = 55; x < 185; x++) {
      photo.setPixelRgb(x, y, 30, 18, 18);
    }
  }
  for (var y = 62; y < 86; y++) {
    for (var x = 68; x < 172; x++) {
      photo.setPixelRgb(x, y, 248, 246, 236);
    }
  }
  // Healthy rose-pink tongue in the middle
  for (var y = 92; y < 224; y++) {
    for (var x = 76; x < 164; x++) {
      photo.setPixelRgb(x, y, 228, 178, 182);
    }
  }
  return Uint8List.fromList(img.encodePng(photo));
}

Uint8List _buildHandWithNailPhoto() {
  final photo = img.Image(width: 240, height: 240);
  // Surrounding hand / palm / table background
  for (var y = 0; y < 240; y++) {
    for (var x = 0; x < 240; x++) {
      photo.setPixelRgb(x, y, 198, 148, 112);
    }
  }
  // Central pink nail plate
  for (var y = 70; y < 170; y++) {
    for (var x = 84; x < 156; x++) {
      photo.setPixelRgb(x, y, 226, 176, 180);
    }
  }
  return Uint8List.fromList(img.encodePng(photo));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OrganIsolatorService — Body Removal & Macro Magnification', () {
    test('Isolates tongue away from face, teeth & neck and masks exterior to dark studio bg', () {
      final rawBytes = _buildFullFaceAndNeckTonguePhoto();
      final res = OrganIsolatorService.isolate(
        imageBytes: rawBytes,
        category: CheckCategory.tongue,
      );

      expect(res.zoomFactor, greaterThan(1.5));
      expect(res.organLabelTr, contains('Dil'));

      final outImg = img.decodeImage(res.isolatedImageBytes)!;
      // Top-left corner of isolated image must be dark studio backdrop (#080E12), NOT beige face skin!
      final corner = outImg.getPixel(2, 2);
      expect(corner.r, lessThan(25));
      expect(corner.g, lessThan(25));
      expect(corner.b, lessThan(30));

      // Center of isolated image must preserve the healthy pink tongue!
      final center = outImg.getPixel(outImg.width ~/ 2, outImg.height ~/ 2);
      expect(center.r, greaterThan(180));
      expect(center.r - center.g, greaterThan(25));

      // Also verify on uploaded real stock photo if present in workspace
      final realFile = File(
        '/home/antigravity/depositphotos_24782785-stock-photo-healthy-tongue.jpg',
      );
      if (realFile.existsSync()) {
        final realIsolated = OrganIsolatorService.isolate(
          imageBytes: realFile.readAsBytesSync(),
          category: CheckCategory.tongue,
        );
        expect(realIsolated.zoomFactor, greaterThan(1.6));
        File(
          '/home/antigravity/.gemini/jetski/brain/v1/default/jetski_remote_agents_3p_devbox/a2d01b57-cc54-4e1a-a5a6-b4e1c0a94d19/scratch/isolated_tongue_real.png',
        ).writeAsBytesSync(realIsolated.isolatedImageBytes);
      }
    });

    test('Isolates nail, eye, skin lesion, urine, and stool with macro zoom & dark surround', () {
      final handBytes = _buildHandWithNailPhoto();
      for (final cat in CheckCategory.values) {
        final isolated = OrganIsolatorService.isolate(
          imageBytes: handBytes,
          category: cat,
        );
        expect(isolated.zoomFactor, greaterThan(1.2));
        final decoded = img.decodeImage(isolated.isolatedImageBytes)!;
        final topCorner = decoded.getPixel(1, 1);
        expect(topCorner.r, lessThan(25), reason: 'Category $cat corner should be masked');
      }
    });
  });

  group('CameraCheckScreen -> OrganScannerOverlay -> ResultScreen Flow', () {
    testWidgets(
      'Isolates organ, displays macro zoom & up/down laser scan animation, then opens ResultScreen report',
      (tester) async {
        final tongueBytes = _buildFullFaceAndNeckTonguePhoto();
        final historyRepo = HistoryRepository();

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CameraCheckScreen(
              category: CheckCategory.tongue,
              analyzer: ColorHealthAnalyzer(),
              historyRepository: historyRepo,
              permissionService: const _DeniedCameraPermService(),
              minScanDuration: const Duration(milliseconds: 900),
              galleryImageBytesProvider: () async => tongueBytes,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Gallery button to submit the full face+neck+tongue photo
        await tester.tap(find.byKey(const Key('camera_pick_gallery_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));

        // Scanner overlay is active, showing isolated organ + up/down scan!
        expect(find.byKey(const Key('organ_scanner_overlay')), findsOneWidget);
        expect(find.byKey(const Key('organ_scanner_viewport')), findsOneWidget);
        expect(find.textContaining('Dil Dokusu İzole Edildi'), findsOneWidget);
        expect(find.text('Analiz Ediliyor...'), findsOneWidget);

        // Advance mid-scan -> laser sweeps and status updates
        await tester.pump(const Duration(milliseconds: 450));
        expect(find.byKey(const Key('organ_scanner_overlay')), findsOneWidget);

        // Complete scan -> allow real dart:io isolated photo save to flush & open ResultScreen!
        await tester.pump(const Duration(milliseconds: 600));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('organ_scanner_overlay')), findsNothing);
        expect(find.text('Dil Rengi Olağan Pembe Tonda'), findsOneWidget);
      },
    );
  });
}
