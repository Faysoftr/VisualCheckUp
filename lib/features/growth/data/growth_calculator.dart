import 'package:visualcheckup/features/growth/domain/growth_models.dart';

/// Adult BMI / Ideal Weight calculator & WHO 0–18 year pediatric growth
/// percentile calculator (Height-for-Age, Weight-for-Age, BMI-for-Age)
/// separated by sex (Girl / Boy).
class GrowthCalculator {
  GrowthCalculator._();

  static BmiCategory classifyAdultBmi(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    if (bmi < 35.0) return BmiCategory.obese1;
    if (bmi < 40.0) return BmiCategory.obese2;
    return BmiCategory.obese3;
  }

  /// Returns WHO healthy adult weight range (BMI 18.5 – 24.9) for [heightCm].
  static ({double minKg, double maxKg}) idealAdultWeightRange(double heightCm) {
    final h = heightCm / 100.0;
    final h2 = h * h;
    return (minKg: 18.5 * h2, maxKg: 24.9 * h2);
  }

  /// Evaluates a child's Height, Weight, and BMI-for-Age against WHO 0–18 year
  /// reference curves (P3, P15, P50, P85, P97) using linear interpolation.
  static ChildGrowthEvaluation evaluateChild({
    required ChildProfile child,
    required ChildGrowthMeasurement measurement,
  }) {
    final ageMonths = child.ageInMonthsAt(measurement.recordedAt);
    final isBoy = child.gender == ChildGender.boy;

    final hRef = _interpolate(isBoy ? _boyHeight : _girlHeight, ageMonths);
    final wRef = _interpolate(isBoy ? _boyWeight : _girlWeight, ageMonths);

    // Derive BMI-for-age reference bands from WHO median/spread anchors
    final bmiRef = _interpolate(isBoy ? _boyBmi : _girlBmi, ageMonths);

    final hRes = _scoreAgainstCurve(measurement.heightCm, 'cm', hRef);
    final wRes = _scoreAgainstCurve(measurement.weightKg, 'kg', wRef);
    final bRes = _scoreAgainstCurve(measurement.bmi, 'kg/m²', bmiRef);

    final String summary;
    if (hRes.band == PercentileBand.veryLow ||
        wRes.band == PercentileBand.veryLow ||
        bRes.band == PercentileBand.veryLow) {
      summary =
          'En az bir büyüme ölçümü 3. persentilin altında görünüyor. Büyüme eğrisinin düzenli izlenmesi için çocuk doktorunuza (Pediatri) danışmanız önerilir.';
    } else if (wRes.band == PercentileBand.veryHigh ||
        bRes.band == PercentileBand.veryHigh) {
      summary =
          'Kilo veya yaşa göre VKİ 97. persentilin üzerinde. Dengeli beslenme ve fiziksel aktivite planı için çocuk doktoru değerlendirmesi faydalı olur.';
    } else if (hRes.band == PercentileBand.normal &&
        wRes.band == PercentileBand.normal &&
        bRes.band == PercentileBand.normal) {
      summary =
          'Boy, kilo ve yaşa göre VKİ değerlerinin tamamı WHO sağlıklı gelişim aralığında (P15 – P85) görünüyor.';
    } else {
      summary =
          'Gelişim değerleri genel sınırlar içinde ancak bir parametre alt/üst sınır bandında. Düzenli aralıklarla ölçüm ekleyerek büyüme eğrisini takip edebilirsiniz.';
    }

    return ChildGrowthEvaluation(
      ageLabel: child.formattedAgeAt(measurement.recordedAt),
      heightPercentile: hRes,
      weightPercentile: wRes,
      bmiPercentile: bRes,
      summaryNote: summary,
    );
  }

  static PercentileResult _scoreAgainstCurve(
    double value,
    String unit,
    _CurvePoint ref,
  ) {
    final int est;
    final PercentileBand band;

    if (value < ref.p3) {
      est = 2;
      band = PercentileBand.veryLow;
    } else if (value < ref.p15) {
      final ratio = (value - ref.p3) / (ref.p15 - ref.p3);
      est = (3 + ratio * 12).round().clamp(3, 14);
      band = PercentileBand.lowNormal;
    } else if (value <= ref.p50) {
      final ratio = (value - ref.p15) / (ref.p50 - ref.p15);
      est = (15 + ratio * 35).round().clamp(15, 50);
      band = PercentileBand.normal;
    } else if (value <= ref.p85) {
      final ratio = (value - ref.p50) / (ref.p85 - ref.p50);
      est = (50 + ratio * 35).round().clamp(50, 85);
      band = PercentileBand.normal;
    } else if (value <= ref.p97) {
      final ratio = (value - ref.p85) / (ref.p97 - ref.p85);
      est = (85 + ratio * 12).round().clamp(86, 97);
      band = PercentileBand.highNormal;
    } else {
      est = 98;
      band = PercentileBand.veryHigh;
    }

    return PercentileResult(
      value: value,
      unit: unit,
      estimatedPercentile: est,
      band: band,
      p3: ref.p3,
      p15: ref.p15,
      p50: ref.p50,
      p85: ref.p85,
      p97: ref.p97,
    );
  }

  static _CurvePoint _interpolate(List<_CurvePoint> table, int ageMonths) {
    if (ageMonths <= table.first.months) return table.first;
    if (ageMonths >= table.last.months) return table.last;

    for (var i = 0; i < table.length - 1; i++) {
      final a = table[i];
      final b = table[i + 1];
      if (ageMonths >= a.months && ageMonths <= b.months) {
        final t = (ageMonths - a.months) / (b.months - a.months);
        double lerp(double x, double y) => x + (y - x) * t;
        return _CurvePoint(
          ageMonths,
          lerp(a.p3, b.p3),
          lerp(a.p15, b.p15),
          lerp(a.p50, b.p50),
          lerp(a.p85, b.p85),
          lerp(a.p97, b.p97),
        );
      }
    }
    return table.last;
  }

  // WHO Child Growth Standards & Reference (0–216 months): (months, P3, P15, P50, P85, P97)
  static const List<_CurvePoint> _boyHeight = [
    _CurvePoint(0, 46.3, 47.9, 49.9, 51.8, 53.4),
    _CurvePoint(6, 63.6, 65.4, 67.6, 69.8, 71.6),
    _CurvePoint(12, 71.3, 73.3, 75.7, 78.2, 80.2),
    _CurvePoint(24, 81.7, 84.1, 87.1, 90.2, 92.9),
    _CurvePoint(36, 89.0, 92.1, 96.1, 100.0, 103.1),
    _CurvePoint(48, 95.4, 98.9, 103.3, 107.8, 111.2),
    _CurvePoint(60, 101.2, 105.1, 110.0, 114.8, 118.7),
    _CurvePoint(72, 106.7, 110.9, 116.0, 121.2, 125.4),
    _CurvePoint(96, 116.6, 121.4, 127.3, 133.2, 138.0),
    _CurvePoint(120, 125.8, 131.2, 137.8, 144.4, 149.8),
    _CurvePoint(144, 135.6, 141.7, 149.1, 156.5, 162.6),
    _CurvePoint(168, 148.5, 155.3, 163.2, 171.1, 177.9),
    _CurvePoint(192, 159.4, 165.7, 173.4, 181.0, 187.3),
    _CurvePoint(216, 163.2, 169.3, 176.5, 183.8, 189.8),
  ];

  static const List<_CurvePoint> _girlHeight = [
    _CurvePoint(0, 45.6, 47.2, 49.1, 51.1, 52.7),
    _CurvePoint(6, 61.5, 63.4, 65.7, 68.1, 70.0),
    _CurvePoint(12, 69.2, 71.4, 74.0, 76.7, 78.9),
    _CurvePoint(24, 80.3, 82.9, 86.4, 89.8, 92.5),
    _CurvePoint(36, 87.9, 91.1, 95.1, 99.0, 102.2),
    _CurvePoint(48, 94.6, 98.2, 102.7, 107.2, 110.8),
    _CurvePoint(60, 100.5, 104.5, 109.4, 114.4, 118.4),
    _CurvePoint(72, 105.5, 109.8, 115.1, 120.4, 124.8),
    _CurvePoint(96, 115.7, 120.6, 126.6, 132.7, 137.6),
    _CurvePoint(120, 126.2, 131.8, 138.6, 145.4, 151.0),
    _CurvePoint(144, 138.3, 144.3, 151.2, 158.2, 164.1),
    _CurvePoint(168, 147.6, 153.3, 159.8, 166.3, 172.0),
    _CurvePoint(192, 150.7, 156.2, 162.5, 168.8, 174.3),
    _CurvePoint(216, 151.3, 156.8, 163.1, 169.4, 174.9),
  ];

  static const List<_CurvePoint> _boyWeight = [
    _CurvePoint(0, 2.5, 2.9, 3.3, 3.9, 4.3),
    _CurvePoint(6, 6.4, 7.1, 7.9, 8.9, 9.7),
    _CurvePoint(12, 7.8, 8.6, 9.6, 10.8, 11.8),
    _CurvePoint(24, 9.8, 10.8, 12.2, 13.7, 15.1),
    _CurvePoint(36, 11.4, 12.7, 14.3, 16.3, 18.0),
    _CurvePoint(48, 12.9, 14.4, 16.3, 18.7, 20.9),
    _CurvePoint(60, 14.3, 16.0, 18.3, 21.1, 23.8),
    _CurvePoint(72, 16.0, 18.0, 20.5, 23.8, 27.1),
    _CurvePoint(96, 19.8, 22.2, 25.4, 29.8, 34.4),
    _CurvePoint(120, 24.3, 27.4, 31.4, 37.3, 43.8),
    _CurvePoint(144, 30.2, 34.5, 40.5, 48.8, 57.6),
    _CurvePoint(168, 39.8, 45.4, 52.5, 62.6, 73.2),
    _CurvePoint(192, 48.2, 54.4, 62.2, 73.1, 84.5),
    _CurvePoint(216, 53.0, 59.4, 67.6, 78.6, 90.0),
  ];

  static const List<_CurvePoint> _girlWeight = [
    _CurvePoint(0, 2.4, 2.8, 3.2, 3.7, 4.2),
    _CurvePoint(6, 5.8, 6.4, 7.3, 8.3, 9.2),
    _CurvePoint(12, 7.1, 7.9, 8.9, 10.2, 11.3),
    _CurvePoint(24, 9.2, 10.2, 11.5, 13.1, 14.6),
    _CurvePoint(36, 11.0, 12.2, 13.9, 15.9, 17.8),
    _CurvePoint(48, 12.5, 14.0, 16.1, 18.6, 21.1),
    _CurvePoint(60, 14.0, 15.8, 18.2, 21.3, 24.4),
    _CurvePoint(72, 15.5, 17.5, 20.2, 23.8, 27.5),
    _CurvePoint(96, 19.3, 21.8, 25.0, 29.8, 34.9),
    _CurvePoint(120, 24.1, 27.5, 31.9, 38.4, 45.4),
    _CurvePoint(144, 31.5, 36.1, 41.9, 50.2, 59.0),
    _CurvePoint(168, 39.2, 44.3, 50.5, 59.6, 69.2),
    _CurvePoint(192, 43.2, 48.2, 54.5, 63.8, 73.5),
    _CurvePoint(216, 44.8, 49.8, 56.2, 65.4, 75.0),
  ];

  static const List<_CurvePoint> _boyBmi = [
    _CurvePoint(0, 11.3, 12.2, 13.4, 14.8, 16.1),
    _CurvePoint(12, 14.5, 15.5, 16.8, 18.2, 19.5),
    _CurvePoint(24, 13.8, 14.8, 16.0, 17.3, 18.6),
    _CurvePoint(36, 13.5, 14.4, 15.6, 16.9, 18.1),
    _CurvePoint(60, 13.1, 14.0, 15.2, 16.6, 18.1),
    _CurvePoint(96, 13.4, 14.4, 15.7, 17.5, 19.7),
    _CurvePoint(120, 13.9, 15.0, 16.4, 18.6, 21.4),
    _CurvePoint(144, 14.7, 15.9, 17.5, 20.0, 23.3),
    _CurvePoint(168, 15.8, 17.1, 19.0, 21.9, 25.4),
    _CurvePoint(192, 17.0, 18.4, 20.5, 23.6, 27.3),
    _CurvePoint(216, 17.9, 19.4, 21.7, 24.9, 28.6),
  ];

  static const List<_CurvePoint> _girlBmi = [
    _CurvePoint(0, 11.2, 12.1, 13.3, 14.6, 15.9),
    _CurvePoint(12, 14.0, 15.0, 16.4, 17.9, 19.3),
    _CurvePoint(24, 13.5, 14.4, 15.7, 17.1, 18.5),
    _CurvePoint(36, 13.3, 14.2, 15.4, 16.8, 18.1),
    _CurvePoint(60, 12.9, 13.9, 15.2, 16.9, 18.6),
    _CurvePoint(96, 13.2, 14.3, 15.7, 17.8, 20.2),
    _CurvePoint(120, 13.8, 14.9, 16.6, 19.0, 21.9),
    _CurvePoint(144, 14.7, 16.0, 18.0, 20.8, 24.1),
    _CurvePoint(168, 15.8, 17.3, 19.6, 22.7, 26.2),
    _CurvePoint(192, 16.6, 18.2, 20.7, 24.1, 27.8),
    _CurvePoint(216, 17.0, 18.6, 21.3, 24.8, 28.6),
  ];
}

class _CurvePoint {
  const _CurvePoint(
    this.months,
    this.p3,
    this.p15,
    this.p50,
    this.p85,
    this.p97,
  );

  final int months;
  final double p3;
  final double p15;
  final double p50;
  final double p85;
  final double p97;
}
