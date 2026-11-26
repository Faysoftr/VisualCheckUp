import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';

class _FakePermissionService implements CameraPermissionService {
  _FakePermissionService({
    required this.initialState,
  });

  final CameraPermissionState initialState;
  int requestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<CameraPermissionState> checkCamera() async => initialState;

  @override
  Future<CameraPermissionState> requestCamera() async {
    requestCount++;
    return initialState;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}

void main() {
  group('CameraCheckScreen runtime permissions', () {
    testWidgets('shows permission request button when camera is denied', (
      tester,
    ) async {
      final fakePermission = _FakePermissionService(
        initialState: CameraPermissionState.denied,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CameraCheckScreen(
            category: CheckCategory.skinCondition,
            analyzer: ColorHealthAnalyzer(),
            historyRepository: HistoryRepository(),
            permissionService: fakePermission,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePermission.requestCount, 1);
      expect(find.text('Kamera İzni Ver'), findsOneWidget);
      expect(find.text('Galeriden Fotoğraf Seç'), findsOneWidget);

      await tester.tap(find.text('Kamera İzni Ver'));
      await tester.pumpAndSettle();
      expect(fakePermission.requestCount, 2);
    });

    testWidgets('shows open settings button when permission is permanently denied', (
      tester,
    ) async {
      final fakePermission = _FakePermissionService(
        initialState: CameraPermissionState.permanentlyDenied,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CameraCheckScreen(
            category: CheckCategory.eye,
            analyzer: ColorHealthAnalyzer(),
            historyRepository: HistoryRepository(),
            permissionService: fakePermission,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(fakePermission.requestCount, 0);
      expect(find.text('Ayarları Aç'), findsOneWidget);

      await tester.tap(find.text('Ayarları Aç'));
      await tester.pumpAndSettle();
      expect(fakePermission.openSettingsCount, 1);
    });
  });
}
