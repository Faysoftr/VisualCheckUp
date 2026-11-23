import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/growth/data/growth_calculator.dart';
import 'package:visualcheckup/features/growth/data/growth_repository.dart';
import 'package:visualcheckup/features/growth/domain/growth_models.dart';
import 'package:visualcheckup/features/growth/presentation/screens/growth_bmi_screen.dart';

void main() {
  group('GrowthCalculator — Adult BMI & WHO 0-18y Pediatric Percentiles', () {
    test('calculates adult BMI, WHO category, and ideal weight range accurately', () {
      final m = AdultBodyMeasurement(
        id: 'a1',
        recordedAt: DateTime(2026, 5, 10),
        heightCm: 170,
        weightKg: 65,
      );
      expect(m.bmi, closeTo(22.49, 0.05));
      expect(GrowthCalculator.classifyAdultBmi(m.bmi), BmiCategory.normal);
      expect(GrowthCalculator.classifyAdultBmi(17.5), BmiCategory.underweight);
      expect(GrowthCalculator.classifyAdultBmi(27.2), BmiCategory.overweight);
      expect(GrowthCalculator.classifyAdultBmi(32.0), BmiCategory.obese1);

      final ideal = GrowthCalculator.idealAdultWeightRange(170);
      expect(ideal.minKg, closeTo(53.46, 0.1));
      expect(ideal.maxKg, closeTo(71.96, 0.1));
    });

    test('computes WHO pediatric percentiles for Girl & Boy across height, weight, and BMI', () {
      // 5-year-old boy right near WHO P50 median (110 cm, 18.3 kg)
      final boy = ChildProfile(
        id: 'c1',
        name: 'Ali',
        birthDate: DateTime(2021, 5, 10),
        gender: ChildGender.boy,
      );
      final evalNormal = GrowthCalculator.evaluateChild(
        child: boy,
        measurement: ChildGrowthMeasurement(
          id: 'm1',
          childId: boy.id,
          recordedAt: DateTime(2026, 5, 10),
          heightCm: 110.0,
          weightKg: 18.3,
        ),
      );
      expect(evalNormal.ageLabel, '5 yaş');
      expect(evalNormal.heightPercentile.band, PercentileBand.normal);
      expect(evalNormal.heightPercentile.estimatedPercentile, inInclusiveRange(45, 55));
      expect(evalNormal.weightPercentile.band, PercentileBand.normal);
      expect(evalNormal.bmiPercentile.band, PercentileBand.normal);

      // 4-year-old girl below P3 weight (11.2 kg)
      final girl = ChildProfile(
        id: 'c2',
        name: 'Zeynep',
        birthDate: DateTime(2022, 5, 10),
        gender: ChildGender.girl,
      );
      final evalLow = GrowthCalculator.evaluateChild(
        child: girl,
        measurement: ChildGrowthMeasurement(
          id: 'm2',
          childId: girl.id,
          recordedAt: DateTime(2026, 5, 10),
          heightCm: 102.0,
          weightKg: 11.2,
        ),
      );
      expect(evalLow.weightPercentile.band, PercentileBand.veryLow);
      expect(evalLow.summaryNote, contains('3. persentilin altında'));
    });

    testWidgets('GrowthBmiScreen logs adult BMI and child WHO percentile scale', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final repo = GrowthRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: GrowthBmiScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Add Adult Height & Weight
      await tester.tap(find.text('İlk Boy & Kilo Ölçümünü Ekle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '175');
      await tester.enterText(find.byType(TextField).at(1), '70');
      await tester.tap(find.text('Kaydet ve Hesapla'));
      await tester.pumpAndSettle();

      expect(find.text('Vücut Kitle İndeksi (VKİ)'), findsOneWidget);
      expect(find.text('22.9'), findsWidgets);
      expect(find.text('Normal (İdeal)'), findsOneWidget);

      // 2. Switch to Çocuklarım tab and add a child + measurement
      await tester.tap(find.text('Çocuklarım'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İlk Çocuğu Ekle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Elif');
      await tester.tap(find.text('Çocuğu Kaydet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('İlk Ölçümü Ekle'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '103');
      await tester.enterText(find.byType(TextField).at(1), '16.2');
      await tester.tap(find.text('Kaydet ve Hesapla'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Elif • Büyüme Skalası (WHO)'), findsOneWidget);
      expect(find.text('Boy (Yaşa Göre Boy)'), findsOneWidget);
      expect(find.text('Kilo (Yaşa Göre Kilo)'), findsOneWidget);
      expect(find.text('Çocuk VKİ (Yaşa Göre BMI)'), findsOneWidget);
    });
  });
}
