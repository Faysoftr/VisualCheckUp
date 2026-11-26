import 'package:flutter/material.dart';

enum ChildGender {
  girl,
  boy,
}

extension ChildGenderX on ChildGender {
  String get label => this == ChildGender.girl ? 'Kız' : 'Erkek';

  static ChildGender fromName(String name) {
    return name == 'girl' ? ChildGender.girl : ChildGender.boy;
  }
}

enum BmiCategory {
  underweight,
  normal,
  overweight,
  obese1,
  obese2,
  obese3,
}

extension BmiCategoryX on BmiCategory {
  String get label {
    switch (this) {
      case BmiCategory.underweight:
        return 'Zayıf';
      case BmiCategory.normal:
        return 'Normal (İdeal)';
      case BmiCategory.overweight:
        return 'Fazla Kilolu';
      case BmiCategory.obese1:
        return 'Obez (1. Derece)';
      case BmiCategory.obese2:
        return 'Obez (2. Derece)';
      case BmiCategory.obese3:
        return 'İleri Obez (3. Derece)';
    }
  }

  String get advice {
    switch (this) {
      case BmiCategory.underweight:
        return 'Vücut kitle indeksiniz ideal aralığın altında. Dengeli protein/kalori alımı ve gerekirse beslenme uzmanı/dahiliye değerlendirmesi faydalı olabilir.';
      case BmiCategory.normal:
        return 'Vücut kitle indeksiniz Dünya Sağlık Örgütü (WHO) sağlıklı yetişkin aralığında (18.5 – 24.9). Mevcut dengeli düzeninizi koruyun.';
      case BmiCategory.overweight:
        return 'İdeal aralığın hafif üzerindesiniz. Düzenli yürüyüş, porsiyon dengesi ve uyku düzeni sağlıklı kiloya inmenize yardımcı olur.';
      case BmiCategory.obese1:
        return 'Kardiyometabolik sağlık açısından kilo kontrolü önemlidir; dahiliye ve diyetisyen desteğiyle sürdürülebilir bir plan oluşturmanız önerilir.';
      case BmiCategory.obese2:
      case BmiCategory.obese3:
        return 'Yüksek VKİ tansiyon, şeker ve eklem sağlığını etkileyebilir. Kişiselleştirilmiş tıbbi takip için dahiliye/endokrinoloji uzmanına danışmanız önerilir.';
    }
  }

  Color get color {
    switch (this) {
      case BmiCategory.underweight:
        return const Color(0xFF2B7BBA);
      case BmiCategory.normal:
        return const Color(0xFF1B8A5A);
      case BmiCategory.overweight:
        return const Color(0xFFD9822B);
      case BmiCategory.obese1:
        return const Color(0xFFD96B27);
      case BmiCategory.obese2:
      case BmiCategory.obese3:
        return const Color(0xFFC93B3B);
    }
  }
}

enum PercentileBand {
  veryLow,
  lowNormal,
  normal,
  highNormal,
  veryHigh,
}

extension PercentileBandX on PercentileBand {
  String get label {
    switch (this) {
      case PercentileBand.veryLow:
        return '< P3 • Çok Düşük';
      case PercentileBand.lowNormal:
        return 'P3 – P15 • Alt Sınır';
      case PercentileBand.normal:
        return 'P15 – P85 • Normal Gelişim';
      case PercentileBand.highNormal:
        return 'P85 – P97 • Üst Sınır';
      case PercentileBand.veryHigh:
        return '> P97 • Belirgin Yüksek';
    }
  }

  Color get color {
    switch (this) {
      case PercentileBand.normal:
        return const Color(0xFF1B8A5A);
      case PercentileBand.lowNormal:
      case PercentileBand.highNormal:
        return const Color(0xFFD9822B);
      case PercentileBand.veryLow:
      case PercentileBand.veryHigh:
        return const Color(0xFFC93B3B);
    }
  }
}

class AdultBodyMeasurement {
  const AdultBodyMeasurement({
    required this.id,
    required this.recordedAt,
    required this.heightCm,
    required this.weightKg,
    this.note,
  });

  final String id;
  final DateTime recordedAt;
  final double heightCm;
  final double weightKg;
  final String? note;

  double get bmi {
    final hMeters = heightCm / 100.0;
    if (hMeters <= 0) return 0;
    return weightKg / (hMeters * hMeters);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        if (note != null && note!.trim().isNotEmpty) 'note': note,
      };

  factory AdultBodyMeasurement.fromJson(Map<String, dynamic> json) {
    return AdultBodyMeasurement(
      id: json['id'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
  });

  final String id;
  final DateTime birthDate;
  final String name;
  final ChildGender gender;

  int ageInMonthsAt(DateTime date) {
    var months = (date.year - birthDate.year) * 12 + (date.month - birthDate.month);
    if (date.day < birthDate.day) months--;
    return months.clamp(0, 216);
  }

  String formattedAgeAt(DateTime date) {
    final totalMonths = ageInMonthsAt(date);
    if (totalMonths < 24) {
      return '$totalMonths aylık';
    }
    final years = totalMonths ~/ 12;
    final remMonths = totalMonths % 12;
    return remMonths == 0 ? '$years yaş' : '$years yaş $remMonths ay';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender.name,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: ChildGenderX.fromName(json['gender'] as String),
    );
  }
}

class ChildGrowthMeasurement {
  const ChildGrowthMeasurement({
    required this.id,
    required this.childId,
    required this.recordedAt,
    required this.heightCm,
    required this.weightKg,
    this.note,
  });

  final String id;
  final String childId;
  final DateTime recordedAt;
  final double heightCm;
  final double weightKg;
  final String? note;

  double get bmi {
    final hMeters = heightCm / 100.0;
    if (hMeters <= 0) return 0;
    return weightKg / (hMeters * hMeters);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'recordedAt': recordedAt.toIso8601String(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        if (note != null && note!.trim().isNotEmpty) 'note': note,
      };

  factory ChildGrowthMeasurement.fromJson(Map<String, dynamic> json) {
    return ChildGrowthMeasurement(
      id: json['id'] as String,
      childId: json['childId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}

class PercentileResult {
  const PercentileResult({
    required this.value,
    required this.unit,
    required this.estimatedPercentile,
    required this.band,
    required this.p3,
    required this.p15,
    required this.p50,
    required this.p85,
    required this.p97,
  });

  final double value;
  final String unit;
  final int estimatedPercentile;
  final PercentileBand band;
  final double p3;
  final double p15;
  final double p50;
  final double p85;
  final double p97;

  /// Normalized 0..1 position along the P3..P97 scale for UI gauge rendering.
  double get normalizedScalePosition {
    if (p97 <= p3) return 0.5;
    return ((value - p3) / (p97 - p3)).clamp(0.0, 1.0);
  }
}

class ChildGrowthEvaluation {
  const ChildGrowthEvaluation({
    required this.ageLabel,
    required this.heightPercentile,
    required this.weightPercentile,
    required this.bmiPercentile,
    required this.summaryNote,
  });

  final String ageLabel;
  final PercentileResult heightPercentile;
  final PercentileResult weightPercentile;
  final PercentileResult bmiPercentile;
  final String summaryNote;
}
