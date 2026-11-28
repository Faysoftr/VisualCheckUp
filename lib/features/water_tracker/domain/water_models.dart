import 'package:flutter/material.dart';

class WaterLogEntry {
  const WaterLogEntry({
    required this.id,
    required this.timestamp,
    required this.amountMl,
  });

  final String id;
  final DateTime timestamp;
  final int amountMl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountMl': amountMl,
      };

  factory WaterLogEntry.fromJson(Map<String, dynamic> json) {
    return WaterLogEntry(
      id: json['id'] as String? ?? UniqueKey().toString(),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      amountMl: (json['amountMl'] as num?)?.toInt() ?? 200,
    );
  }
}

class DailyWaterSummary {
  const DailyWaterSummary({
    required this.date,
    required this.consumedMl,
    required this.targetMl,
    required this.entries,
  });

  final DateTime date;
  final int consumedMl;
  final int targetMl;
  final List<WaterLogEntry> entries;

  double get progressRatio =>
      targetMl > 0 ? (consumedMl / targetMl).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progressRatio * 100).round();

  int get remainingMl => (targetMl - consumedMl).clamp(0, targetMl);

  bool get isGoalAchieved => consumedMl >= targetMl;

  static int calculateRecommendedTarget({int? weightKg, bool isActive = false}) {
    if (weightKg == null || weightKg <= 30) {
      return 2500; // standard adult default
    }
    // 33 ml per kg + 500 ml if active
    int target = weightKg * 33;
    if (isActive) target += 500;
    return target.clamp(1500, 4500);
  }
}
