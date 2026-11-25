import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/app.dart';

void main() {
  testWidgets(
    'VisualCheckUpApp boots to login, enters home screen with 7 categories, and opens skin module',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('tr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({
        'visualcheckup_disclaimer_v1': true,
      });

      await tester.pumpWidget(const VisualCheckUpApp());
      await tester.pumpAndSettle();

      // Login screen shows Apple, Google, Guest options and mandatory terms checkbox.
      expect(find.text('Apple ile Devam Et'), findsOneWidget);
      expect(find.text('Google ile Devam Et'), findsOneWidget);
      expect(find.text('Misafir Olarak Devam Et'), findsOneWidget);
      expect(find.byKey(const Key('login_terms_checkbox')), findsOneWidget);

      // Attempting sign-in before accepting terms stays on LoginScreen.
      await tester.ensureVisible(find.text('Misafir Olarak Devam Et'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Misafir Olarak Devam Et'));
      await tester.pumpAndSettle();
      expect(find.text('Misafir Olarak Devam Et'), findsOneWidget);

      // Accept mandatory Terms of Use & Medical Notice, then enter as Guest.
      await tester.ensureVisible(find.byKey(const Key('login_terms_checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_terms_checkbox')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Misafir Olarak Devam Et'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Misafir Olarak Devam Et'));
      await tester.pumpAndSettle();

      expect(find.text('VisualCheckUp'), findsOneWidget);
      expect(find.text('Göz (Sklera)'), findsOneWidget);
      expect(find.text('Tırnak'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dil'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Dil'), findsOneWidget);
      expect(find.text('Yüz & Cilt'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Dışkı Rengi'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Cilt Hastalıkları'), findsOneWidget);
      expect(find.text('İdrar Rengi'), findsOneWidget);
      expect(find.text('Dışkı Rengi'), findsOneWidget);

      await tester.ensureVisible(find.text('Cilt Hastalıkları'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cilt Hastalıkları'));
      await tester.pumpAndSettle();

      // CategoryHubScreen opens first with Start New Scan + Past Scans table.
      expect(find.text('Yeni Tarama Başlat'), findsOneWidget);
      await tester.tap(find.text('Yeni Tarama Başlat'));
      await tester.pumpAndSettle();

      expect(find.text('Cilt Hastalıkları Ön Kontrol'), findsOneWidget);
      expect(find.text('Ben & Cilt Kanseri Risk'), findsOneWidget);
      expect(find.text('Siğil Ön Kontrol'), findsOneWidget);
      expect(find.text('Morluk Takibi'), findsOneWidget);
      expect(find.text('Yüz Lekesi'), findsOneWidget);

      final skinListScrollable = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Kamera ile Cilt Kontrolünü Başlat'),
        300,
        scrollable: skinListScrollable,
      );
      expect(find.text('Benler İçin ABCDE Kontrol Rehberi'), findsOneWidget);
      expect(find.text('Kamera ile Cilt Kontrolünü Başlat'), findsOneWidget);
    },
  );
}
