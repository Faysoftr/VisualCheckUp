import 'package:flutter/material.dart';
import 'package:visualcheckup/core/color/color_calibrator.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// User's personal healthy baseline color for a specific check category,
/// recorded on their own device to neutralize camera sensor and skin-tone
/// differences across future checkups.
class CategoryBaseline {
  const CategoryBaseline({
    required this.category,
    required this.colorValue,
    required this.labL,
    required this.labA,
    required this.labB,
    required this.calibratedWithWhiteRef,
    required this.savedAt,
  });

  final CheckCategory category;
  final int colorValue;
  final double labL;
  final double labA;
  final double labB;
  final bool calibratedWithWhiteRef;
  final DateTime savedAt;

  Color get color => Color(colorValue);
  LabColor get lab => LabColor(l: labL, a: labA, b: labB);

  factory CategoryBaseline.fromColor({
    required CheckCategory category,
    required Color color,
    required bool calibratedWithWhiteRef,
    DateTime? savedAt,
  }) {
    final lab = LabColor.fromColor(color);
    return CategoryBaseline(
      category: category,
      colorValue: color.toARGB32(),
      labL: lab.l,
      labA: lab.a,
      labB: lab.b,
      calibratedWithWhiteRef: calibratedWithWhiteRef,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  /// Compares a newly sampled [currentLab] against this personal baseline.
  ({double deltaE, String note, bool isSignificantShift}) compare(
    LabColor currentLab,
  ) {
    final deltaE = lab.deltaE(currentLab);
    final dl = currentLab.l - labL;
    final da = currentLab.a - labA;
    final db = currentLab.b - labB;

    final directions = <String>[];
    if (db >= 5.0) {
      directions.add('daha sarı');
    } else if (db <= -5.0) {
      directions.add('daha mavimsi/soğuk');
    }
    if (da >= 5.0) {
      directions.add('daha kırmızı');
    } else if (da <= -5.0) {
      directions.add('daha soluk');
    }
    if (dl <= -7.0) {
      directions.add('daha koyu');
    } else if (dl >= 7.0) {
      directions.add('daha açık');
    }

    final dirText = directions.isEmpty ? '' : ' (${directions.join(', ')})';
    final rounded = deltaE.toStringAsFixed(1);

    if (deltaE < 6.0) {
      return (
        deltaE: deltaE,
        note: 'Kişisel normalinize çok yakın (ΔE: $rounded).',
        isSignificantShift: false,
      );
    }
    if (deltaE < 13.0) {
      return (
        deltaE: deltaE,
        note: 'Kişisel normalinizden hafif ton farkı (ΔE: $rounded)$dirText.',
        isSignificantShift: false,
      );
    }
    return (
      deltaE: deltaE,
      note: 'Kişisel normalinizden belirgin sapma (ΔE: $rounded)$dirText.',
      isSignificantShift: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.id,
        'colorValue': colorValue,
        'labL': labL,
        'labA': labA,
        'labB': labB,
        'calibratedWithWhiteRef': calibratedWithWhiteRef,
        'savedAt': savedAt.toIso8601String(),
      };

  factory CategoryBaseline.fromJson(Map<String, dynamic> json) {
    return CategoryBaseline(
      category: CheckCategoryX.fromId(json['category'] as String),
      colorValue: json['colorValue'] as int,
      labL: (json['labL'] as num).toDouble(),
      labA: (json['labA'] as num).toDouble(),
      labB: (json['labB'] as num).toDouble(),
      calibratedWithWhiteRef:
          (json['calibratedWithWhiteRef'] as bool?) ?? false,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
