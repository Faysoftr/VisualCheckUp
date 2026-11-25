import 'package:flutter/material.dart';

/// Categories of health & medication alarms supported by VisualCheckUp.
enum MedicationCategory {
  pill,
  diabetesInsulin,
  bloodPressure,
  herbalTea,
  vitamin,
  dropsCream,
  checkup,
  other,
}

extension MedicationCategoryX on MedicationCategory {
  String get id => name;

  static MedicationCategory fromId(String? value) {
    for (final cat in MedicationCategory.values) {
      if (cat.name == value) return cat;
    }
    return MedicationCategory.pill;
  }

  IconData get icon {
    switch (this) {
      case MedicationCategory.pill:
        return Icons.medication_rounded;
      case MedicationCategory.diabetesInsulin:
        return Icons.vaccines_rounded;
      case MedicationCategory.bloodPressure:
        return Icons.favorite_rounded;
      case MedicationCategory.herbalTea:
        return Icons.emoji_food_beverage_rounded;
      case MedicationCategory.vitamin:
        return Icons.wb_sunny_rounded;
      case MedicationCategory.dropsCream:
        return Icons.water_drop_rounded;
      case MedicationCategory.checkup:
        return Icons.monitor_heart_rounded;
      case MedicationCategory.other:
        return Icons.alarm_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case MedicationCategory.pill:
        return const Color(0xFF0F766E);
      case MedicationCategory.diabetesInsulin:
        return const Color(0xFFC8553D);
      case MedicationCategory.bloodPressure:
        return const Color(0xFFDC2626);
      case MedicationCategory.herbalTea:
        return const Color(0xFF15803D);
      case MedicationCategory.vitamin:
        return const Color(0xFFD97706);
      case MedicationCategory.dropsCream:
        return const Color(0xFF2563EB);
      case MedicationCategory.checkup:
        return const Color(0xFF7C3AED);
      case MedicationCategory.other:
        return const Color(0xFF475569);
    }
  }
}

/// Relationship between a medication dose and meals / sleep.
enum MealTiming {
  anytime,
  beforeMeal,
  afterMeal,
  withMeal,
  bedtime,
}

extension MealTimingX on MealTiming {
  static MealTiming fromId(String? value) {
    for (final timing in MealTiming.values) {
      if (timing.name == value) return timing;
    }
    return MealTiming.anytime;
  }

  IconData get icon {
    switch (this) {
      case MealTiming.anytime:
        return Icons.schedule_rounded;
      case MealTiming.beforeMeal:
        return Icons.no_meals_rounded;
      case MealTiming.afterMeal:
        return Icons.restaurant_rounded;
      case MealTiming.withMeal:
        return Icons.lunch_dining_rounded;
      case MealTiming.bedtime:
        return Icons.bedtime_rounded;
    }
  }
}

/// Daily intake status for a scheduled medication dose.
enum MedicationDoseStatus {
  taken,
  snoozed,
  skipped,
}

extension MedicationDoseStatusX on MedicationDoseStatus {
  static MedicationDoseStatus fromId(String? value) {
    for (final s in MedicationDoseStatus.values) {
      if (s.name == value) return s;
    }
    return MedicationDoseStatus.taken;
  }
}

/// A recurring alarm-style medication or health checkup reminder with optional
/// medicine photo, selected weekdays, dosage, meal timing, custom category,
/// and explanation note.
class MedicationReminder {
  const MedicationReminder({
    required this.id,
    required this.title,
    required this.category,
    this.customCategoryLabel = '',
    required this.hour,
    required this.minute,
    required this.weekdays,
    this.dosage = '',
    this.description = '',
    this.mealTiming = MealTiming.anytime,
    this.photoPath,
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrateEnabled = true,
    required this.createdAt,
  });

  /// All 7 ISO weekdays (1 = Monday .. 7 = Sunday).
  static const Set<int> allWeekdays = {1, 2, 3, 4, 5, 6, 7};
  static const Set<int> workWeekdays = {1, 2, 3, 4, 5};
  static const Set<int> weekendDays = {6, 7};

  final String id;
  final String title;
  final MedicationCategory category;

  /// Optional user-entered category label (e.g. "Probiyotik", "Su İçme").
  final String customCategoryLabel;
  final int hour;
  final int minute;

  /// ISO weekday numbers: 1 = Mon, 2 = Tue, ..., 7 = Sun.
  final Set<int> weekdays;
  final String dosage;
  final String description;
  final MealTiming mealTiming;
  final String? photoPath;
  final bool enabled;
  final bool soundEnabled;
  final bool vibrateEnabled;
  final DateTime createdAt;

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  int get minutesFromMidnight => hour * 60 + minute;

  bool get isEveryDay =>
      weekdays.length == 7 && allWeekdays.every(weekdays.contains);

  bool get isWeekdaysOnly =>
      weekdays.length == 5 && workWeekdays.every(weekdays.contains);

  bool get isWeekendsOnly =>
      weekdays.length == 2 && weekendDays.every(weekdays.contains);

  bool isScheduledForWeekday(int isoWeekday) {
    if (weekdays.isEmpty) return true;
    return weekdays.contains(isoWeekday);
  }

  /// Computes the next upcoming [DateTime] when this alarm should ring after
  /// [from]. Returns `null` if [enabled] is false or [weekdays] is empty.
  DateTime? nextTriggerTime(DateTime from) {
    if (!enabled) return null;
    final activeDays = weekdays.isEmpty ? allWeekdays : weekdays;
    for (int offset = 0; offset <= 7; offset++) {
      final candidateDay = DateTime(from.year, from.month, from.day + offset);
      if (!activeDays.contains(candidateDay.weekday)) continue;
      final candidate = DateTime(
        candidateDay.year,
        candidateDay.month,
        candidateDay.day,
        hour,
        minute,
      );
      if (candidate.isAfter(from)) {
        return candidate;
      }
    }
    return null;
  }

  static String dateKeyFor(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  MedicationReminder copyWith({
    String? id,
    String? title,
    MedicationCategory? category,
    String? customCategoryLabel,
    int? hour,
    int? minute,
    Set<int>? weekdays,
    String? dosage,
    String? description,
    MealTiming? mealTiming,
    String? photoPath,
    bool clearPhotoPath = false,
    bool? enabled,
    bool? soundEnabled,
    bool? vibrateEnabled,
    DateTime? createdAt,
  }) {
    return MedicationReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      customCategoryLabel: customCategoryLabel ?? this.customCategoryLabel,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      dosage: dosage ?? this.dosage,
      description: description ?? this.description,
      mealTiming: mealTiming ?? this.mealTiming,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    final sortedDays = weekdays.toList()..sort();
    return {
      'id': id,
      'title': title,
      'category': category.id,
      if (customCategoryLabel.trim().isNotEmpty)
        'customCategoryLabel': customCategoryLabel.trim(),
      'hour': hour,
      'minute': minute,
      'weekdays': sortedDays,
      'dosage': dosage,
      'description': description,
      'mealTiming': mealTiming.name,
      if (photoPath != null) 'photoPath': photoPath,
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'vibrateEnabled': vibrateEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['weekdays'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .where((d) => d >= 1 && d <= 7)
            .toSet() ??
        allWeekdays;

    return MedicationReminder(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      category: MedicationCategoryX.fromId(json['category'] as String?),
      customCategoryLabel: (json['customCategoryLabel'] as String?) ?? '',
      hour: ((json['hour'] as num?)?.toInt() ?? 8).clamp(0, 23),
      minute: ((json['minute'] as num?)?.toInt() ?? 0).clamp(0, 59),
      weekdays: rawDays.isEmpty ? allWeekdays : rawDays,
      dosage: (json['dosage'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      mealTiming: MealTimingX.fromId(json['mealTiming'] as String?),
      photoPath: json['photoPath'] as String?,
      enabled: (json['enabled'] as bool?) ?? true,
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      vibrateEnabled: (json['vibrateEnabled'] as bool?) ?? true,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Logs whether a scheduled medication dose was taken, snoozed, or skipped on a
/// specific calendar date.
class MedicationDoseLog {
  const MedicationDoseLog({
    required this.id,
    required this.reminderId,
    required this.dateKey,
    required this.status,
    required this.actionAt,
  });

  final String id;
  final String reminderId;
  final String dateKey;
  final MedicationDoseStatus status;
  final DateTime actionAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'reminderId': reminderId,
        'dateKey': dateKey,
        'status': status.name,
        'actionAt': actionAt.toIso8601String(),
      };

  factory MedicationDoseLog.fromJson(Map<String, dynamic> json) {
    return MedicationDoseLog(
      id: (json['id'] as String?) ?? '',
      reminderId: (json['reminderId'] as String?) ?? '',
      dateKey: (json['dateKey'] as String?) ?? '',
      status: MedicationDoseStatusX.fromId(json['status'] as String?),
      actionAt: DateTime.tryParse((json['actionAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
