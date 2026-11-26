import 'package:flutter/material.dart';

enum BloodPressureCategory {
  low,
  normal,
  elevated,
  highStage1,
  highStage2,
  crisis,
}

extension BloodPressureCategoryX on BloodPressureCategory {
  String get label {
    switch (this) {
      case BloodPressureCategory.low:
        return 'Düşük Tansiyon';
      case BloodPressureCategory.normal:
        return 'Normal Aralık';
      case BloodPressureCategory.elevated:
        return 'Yüksek-Normal';
      case BloodPressureCategory.highStage1:
        return 'Evre 1 Yüksek';
      case BloodPressureCategory.highStage2:
        return 'Belirgin Yüksek';
      case BloodPressureCategory.crisis:
        return 'Acil Yüksek Tansiyon';
    }
  }

  String get guidance {
    switch (this) {
      case BloodPressureCategory.low:
        return 'Baş dönmesi, göz kararması veya baygınlık hissi varsa uzanın, sıvı alın ve hekime danışın.';
      case BloodPressureCategory.normal:
        return 'Tansiyon değeriniz ideal aralıkta görünüyor. Düzenli aralıklarla takibe devam edin.';
      case BloodPressureCategory.elevated:
        return 'Sınırın hafif üzerinde. Tuz tüketimi, uyku ve stres dengenizi izleyerek farklı günlerde tekrar ölçün.';
      case BloodPressureCategory.highStage1:
        return 'Tekrarlayan ölçümlerde bu aralık görülüyorsa kayıtlarınızla birlikte Dahiliye veya Kardiyoloji uzmanına danışın.';
      case BloodPressureCategory.highStage2:
        return 'Belirgin yüksek değer. 5 dakika dinlenip tekrar ölçün; yüksek kalıyorsa hekime başvurun.';
      case BloodPressureCategory.crisis:
        return 'Çok yüksek tansiyon değeri! Göğüs ağrısı, nefes darlığı, şiddetli baş ağrısı veya görme/konuşma bozukluğu varsa derhal acil servise başvurun.';
    }
  }

  Color get color {
    switch (this) {
      case BloodPressureCategory.normal:
        return const Color(0xFF1B8A5A);
      case BloodPressureCategory.low:
      case BloodPressureCategory.elevated:
        return const Color(0xFFD9822B);
      case BloodPressureCategory.highStage1:
        return const Color(0xFFD96B27);
      case BloodPressureCategory.highStage2:
      case BloodPressureCategory.crisis:
        return const Color(0xFFC93B3B);
    }
  }
}

class BloodPressureReading {
  const BloodPressureReading({
    required this.id,
    required this.recordedAt,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.note,
  });

  final String id;
  final DateTime recordedAt;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? note;

  BloodPressureCategory get category {
    if (systolic >= 180 || diastolic >= 120) {
      return BloodPressureCategory.crisis;
    }
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.highStage2;
    }
    if (systolic >= 130 || diastolic >= 80) {
      return BloodPressureCategory.highStage1;
    }
    if (systolic < 90 || diastolic < 60) {
      return BloodPressureCategory.low;
    }
    if (systolic >= 120) {
      return BloodPressureCategory.elevated;
    }
    return BloodPressureCategory.normal;
  }

  String get formatted => '$systolic/$diastolic mmHg';

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'systolic': systolic,
        'diastolic': diastolic,
        if (pulse != null) 'pulse': pulse,
        if (note != null) 'note': note,
      };

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      id: json['id'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      systolic: (json['systolic'] as num).round(),
      diastolic: (json['diastolic'] as num).round(),
      pulse: (json['pulse'] as num?)?.round(),
      note: json['note'] as String?,
    );
  }
}

enum SugarMeasurementType {
  fasting,
  postMeal,
  random,
}

extension SugarMeasurementTypeX on SugarMeasurementType {
  String get label {
    switch (this) {
      case SugarMeasurementType.fasting:
        return 'Açlık';
      case SugarMeasurementType.postMeal:
        return 'Tokluk (2. saat)';
      case SugarMeasurementType.random:
        return 'Rastgele';
    }
  }

  static SugarMeasurementType fromName(String name) {
    return SugarMeasurementType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => SugarMeasurementType.fasting,
    );
  }
}

enum BloodSugarCategory {
  hypoglycemia,
  normal,
  borderline,
  high,
  veryHigh,
}

extension BloodSugarCategoryX on BloodSugarCategory {
  String get label {
    switch (this) {
      case BloodSugarCategory.hypoglycemia:
        return 'Düşük Şeker (Hipoglisemi)';
      case BloodSugarCategory.normal:
        return 'Normal Aralık';
      case BloodSugarCategory.borderline:
        return 'Sınırda Yüksek';
      case BloodSugarCategory.high:
        return 'Yüksek Kan Şekeri';
      case BloodSugarCategory.veryHigh:
        return 'Çok Yüksek Şeker';
    }
  }

  String get guidance {
    switch (this) {
      case BloodSugarCategory.hypoglycemia:
        return '70 mg/dL altı düşük kan şekeridir. Terleme, titreme veya halsizlik varsa hızlı etkili karbonhidrat alın ve 15 dk sonra tekrar ölçün; düzelmezse acil destek alın.';
      case BloodSugarCategory.normal:
        return 'Ölçümünüz seçilen zamana göre olağan aralıkta görünüyor.';
      case BloodSugarCategory.borderline:
        return 'Sınırda değer. Farklı günlerde tekrar ölçerek kayıtlarınızı Dahiliye veya Endokrinoloji doktorunuzla paylaşın.';
      case BloodSugarCategory.high:
        return 'Yüksek kan şekeri eğilimi. Su tüketin, ölçümleri tarihli kaydedin ve hekiminizle görüşün.';
      case BloodSugarCategory.veryHigh:
        return 'Çok yüksek kan şekeri değeri! Bulantı, kusma, karın ağrısı, hızlı solunum veya bilinç bulanıklığı varsa derhal acil servise başvurun.';
    }
  }

  Color get color {
    switch (this) {
      case BloodSugarCategory.normal:
        return const Color(0xFF1B8A5A);
      case BloodSugarCategory.borderline:
        return const Color(0xFFD9822B);
      case BloodSugarCategory.hypoglycemia:
      case BloodSugarCategory.high:
      case BloodSugarCategory.veryHigh:
        return const Color(0xFFC93B3B);
    }
  }
}

class BloodSugarReading {
  const BloodSugarReading({
    required this.id,
    required this.recordedAt,
    required this.valueMgDl,
    required this.measurementType,
    this.note,
  });

  final String id;
  final DateTime recordedAt;
  final double valueMgDl;
  final SugarMeasurementType measurementType;
  final String? note;

  BloodSugarCategory get category {
    if (valueMgDl < 70) return BloodSugarCategory.hypoglycemia;
    if (valueMgDl >= 250) return BloodSugarCategory.veryHigh;

    switch (measurementType) {
      case SugarMeasurementType.fasting:
        if (valueMgDl < 100) return BloodSugarCategory.normal;
        if (valueMgDl < 126) return BloodSugarCategory.borderline;
        return BloodSugarCategory.high;
      case SugarMeasurementType.postMeal:
      case SugarMeasurementType.random:
        if (valueMgDl < 140) return BloodSugarCategory.normal;
        if (valueMgDl < 200) return BloodSugarCategory.borderline;
        return BloodSugarCategory.high;
    }
  }

  String get formatted => '${valueMgDl.round()} mg/dL';

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'valueMgDl': valueMgDl,
        'measurementType': measurementType.name,
        if (note != null) 'note': note,
      };

  factory BloodSugarReading.fromJson(Map<String, dynamic> json) {
    return BloodSugarReading(
      id: json['id'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      valueMgDl: (json['valueMgDl'] as num).toDouble(),
      measurementType:
          SugarMeasurementTypeX.fromName(json['measurementType'] as String),
      note: json['note'] as String?,
    );
  }
}
