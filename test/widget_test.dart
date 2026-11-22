import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthcheck/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('HealthCheckApp renders home screen with 6 categories', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'healthcheck_disclaimer_v1': true,
    });

    await tester.pumpWidget(const HealthCheckApp());
    await tester.pumpAndSettle();

    expect(find.text('HealthCheck'), findsOneWidget);
    expect(find.text('Göz (Sklera)'), findsOneWidget);
    expect(find.text('Tırnak'), findsOneWidget);
    expect(find.text('Dil'), findsOneWidget);
    expect(find.text('Yüz & Cilt'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Dışkı Rengi'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('İdrar Rengi'), findsOneWidget);
    expect(find.text('Dışkı Rengi'), findsOneWidget);
  });
}
