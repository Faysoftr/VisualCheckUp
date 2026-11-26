import 'package:flutter/material.dart';

/// Meal time slots in a daily diet plan or standalone calorie scan.
enum MealSlot {
  breakfast,
  morningSnack,
  lunch,
  afternoonSnack,
  dinner,
}

extension MealSlotX on MealSlot {
  static MealSlot fromId(String? value) {
    for (final slot in MealSlot.values) {
      if (slot.name == value) return slot;
    }
    return MealSlot.lunch;
  }

  IconData get icon {
    switch (this) {
      case MealSlot.breakfast:
        return Icons.free_breakfast_rounded;
      case MealSlot.morningSnack:
        return Icons.apple_rounded;
      case MealSlot.lunch:
        return Icons.lunch_dining_rounded;
      case MealSlot.afternoonSnack:
        return Icons.local_cafe_rounded;
      case MealSlot.dinner:
        return Icons.dinner_dining_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case MealSlot.breakfast:
        return const Color(0xFFD97706);
      case MealSlot.morningSnack:
        return const Color(0xFF16A34A);
      case MealSlot.lunch:
        return const Color(0xFF0F766E);
      case MealSlot.afternoonSnack:
        return const Color(0xFF7C3AED);
      case MealSlot.dinner:
        return const Color(0xFF2563EB);
    }
  }
}

/// Diet goal / clinical template classification.
enum DietGoalType {
  mediterranean,
  diabetesFriendly,
  heartDash,
  weightLoss,
  intermittentFasting,
  highProtein,
}

extension DietGoalTypeX on DietGoalType {
  static DietGoalType fromId(String? value) {
    for (final goal in DietGoalType.values) {
      if (goal.name == value) return goal;
    }
    return DietGoalType.mediterranean;
  }

  Color get accentColor {
    switch (this) {
      case DietGoalType.mediterranean:
        return const Color(0xFF0F766E);
      case DietGoalType.diabetesFriendly:
        return const Color(0xFFC8553D);
      case DietGoalType.heartDash:
        return const Color(0xFFDC2626);
      case DietGoalType.weightLoss:
        return const Color(0xFF16A34A);
      case DietGoalType.intermittentFasting:
        return const Color(0xFF7C3AED);
      case DietGoalType.highProtein:
        return const Color(0xFF2563EB);
    }
  }

  IconData get icon {
    switch (this) {
      case DietGoalType.mediterranean:
        return Icons.eco_rounded;
      case DietGoalType.diabetesFriendly:
        return Icons.bloodtype_rounded;
      case DietGoalType.heartDash:
        return Icons.favorite_rounded;
      case DietGoalType.weightLoss:
        return Icons.local_fire_department_rounded;
      case DietGoalType.intermittentFasting:
        return Icons.schedule_rounded;
      case DietGoalType.highProtein:
        return Icons.fitness_center_rounded;
    }
  }
}

/// Whether the user followed or missed a specific diet meal ("Uydum" / "Uymadım").
enum MealComplianceStatus {
  followed,
  notFollowed,
  pending,
}

extension MealComplianceStatusX on MealComplianceStatus {
  static MealComplianceStatus fromId(String? value) {
    for (final s in MealComplianceStatus.values) {
      if (s.name == value) return s;
    }
    return MealComplianceStatus.pending;
  }
}

/// One planned meal inside a [DietDayPlan].
class DietMealItem {
  const DietMealItem({
    required this.slot,
    required this.title,
    required this.portion,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.alternatives = '',
  });

  final MealSlot slot;
  final String title;
  final String portion;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String alternatives;

  Map<String, dynamic> toJson() => {
        'slot': slot.name,
        'title': title,
        'portion': portion,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'alternatives': alternatives,
      };

  factory DietMealItem.fromJson(Map<String, dynamic> json) {
    return DietMealItem(
      slot: MealSlotX.fromId(json['slot'] as String?),
      title: (json['title'] as String?) ?? '',
      portion: (json['portion'] as String?) ?? '',
      calories: (json['calories'] as num?)?.round() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      alternatives: (json['alternatives'] as String?) ?? '',
    );
  }
}

/// One day's complete menu inside a diet template or active diet plan.
class DietDayPlan {
  const DietDayPlan({
    required this.dayIndex,
    required this.meals,
    this.waterLiters = 2.0,
    this.dailyTip = '',
  });

  /// 1-based rotating day index (1..N).
  final int dayIndex;
  final List<DietMealItem> meals;
  final double waterLiters;
  final String dailyTip;

  int get totalCalories => meals.fold<int>(0, (sum, m) => sum + m.calories);

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'meals': meals.map((m) => m.toJson()).toList(),
        'waterLiters': waterLiters,
        'dailyTip': dailyTip,
      };

  factory DietDayPlan.fromJson(Map<String, dynamic> json) {
    final rawMeals = (json['meals'] as List<dynamic>?) ?? const [];
    return DietDayPlan(
      dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 1,
      meals: rawMeals
          .whereType<Map<String, dynamic>>()
          .map(DietMealItem.fromJson)
          .toList(),
      waterLiters: (json['waterLiters'] as num?)?.toDouble() ?? 2.0,
      dailyTip: (json['dailyTip'] as String?) ?? '',
    );
  }
}

/// Ready-made or user-created diet template that users can preview and start
/// with custom dates.
class DietTemplate {
  const DietTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.goalType,
    required this.recommendedDays,
    required this.dailyTargetCalories,
    required this.tags,
    required this.rules,
    required this.days,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DietGoalType goalType;
  final int recommendedDays;
  final int dailyTargetCalories;
  final List<String> tags;
  final List<String> rules;
  final List<DietDayPlan> days;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'goalType': goalType.name,
        'recommendedDays': recommendedDays,
        'dailyTargetCalories': dailyTargetCalories,
        'tags': tags,
        'rules': rules,
        'days': days.map((d) => d.toJson()).toList(),
        'isCustom': isCustom,
      };

  factory DietTemplate.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List<dynamic>?) ?? const [];
    return DietTemplate(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      goalType: DietGoalTypeX.fromId(json['goalType'] as String?),
      recommendedDays: (json['recommendedDays'] as num?)?.toInt() ?? 14,
      dailyTargetCalories:
          (json['dailyTargetCalories'] as num?)?.round() ?? 1600,
      tags: ((json['tags'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      rules: ((json['rules'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      days: rawDays
          .whereType<Map<String, dynamic>>()
          .map(DietDayPlan.fromJson)
          .toList(),
      isCustom: (json['isCustom'] as bool?) ?? true,
    );
  }
}

/// User's currently active (or archived) diet plan with start/end dates and
/// weight targets.
class ActiveDietPlan {
  const ActiveDietPlan({
    required this.id,
    required this.templateId,
    required this.title,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    required this.dailyTargetCalories,
    this.startWeightKg,
    this.targetWeightKg,
    this.isActive = true,
    required this.days,
    required this.createdAt,
  });

  final String id;
  final String templateId;
  final String title;
  final DietGoalType goalType;
  final DateTime startDate;
  final DateTime endDate;
  final int dailyTargetCalories;
  final double? startWeightKg;
  final double? targetWeightKg;
  final bool isActive;
  final List<DietDayPlan> days;
  final DateTime createdAt;

  static String dateKeyFor(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  DateTime get _startOnly =>
      DateTime(startDate.year, startDate.month, startDate.day);
  DateTime get _endOnly => DateTime(endDate.year, endDate.month, endDate.day);

  int get totalDays {
    final diff = _endOnly.difference(_startOnly).inDays + 1;
    return diff < 1 ? 1 : diff;
  }

  int currentDayNumber(DateTime now) {
    final dayOnly = DateTime(now.year, now.month, now.day);
    final diff = dayOnly.difference(_startOnly).inDays + 1;
    return diff.clamp(1, totalDays);
  }

  int remainingDays(DateTime now) {
    final dayOnly = DateTime(now.year, now.month, now.day);
    final diff = _endOnly.difference(dayOnly).inDays;
    return diff < 0 ? 0 : diff;
  }

  double progressRatio(DateTime now) =>
      (currentDayNumber(now) / totalDays).clamp(0.0, 1.0);

  /// Returns the rotating [DietDayPlan] assigned to [date].
  DietDayPlan planForDate(DateTime date) {
    if (days.isEmpty) {
      return const DietDayPlan(dayIndex: 1, meals: []);
    }
    final dayOnly = DateTime(date.year, date.month, date.day);
    final diff = dayOnly.difference(_startOnly).inDays;
    final idx = ((diff % days.length) + days.length) % days.length;
    return days[idx];
  }

  ActiveDietPlan copyWith({
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? dailyTargetCalories,
    double? startWeightKg,
    double? targetWeightKg,
  }) {
    return ActiveDietPlan(
      id: id,
      templateId: templateId,
      title: title,
      goalType: goalType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyTargetCalories: dailyTargetCalories ?? this.dailyTargetCalories,
      startWeightKg: startWeightKg ?? this.startWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      isActive: isActive ?? this.isActive,
      days: days,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'title': title,
        'goalType': goalType.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'dailyTargetCalories': dailyTargetCalories,
        if (startWeightKg != null) 'startWeightKg': startWeightKg,
        if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
        'isActive': isActive,
        'days': days.map((d) => d.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ActiveDietPlan.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List<dynamic>?) ?? const [];
    return ActiveDietPlan(
      id: (json['id'] as String?) ?? '',
      templateId: (json['templateId'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      goalType: DietGoalTypeX.fromId(json['goalType'] as String?),
      startDate: DateTime.tryParse((json['startDate'] as String?) ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse((json['endDate'] as String?) ?? '') ??
          DateTime.now().add(const Duration(days: 20)),
      dailyTargetCalories:
          (json['dailyTargetCalories'] as num?)?.round() ?? 1600,
      startWeightKg: (json['startWeightKg'] as num?)?.toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      isActive: (json['isActive'] as bool?) ?? true,
      days: rawDays
          .whereType<Map<String, dynamic>>()
          .map(DietDayPlan.fromJson)
          .toList(),
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Logs whether the user followed ("Uydum") or missed ("Uymadım") a planned
/// meal on a specific date.
class DietMealComplianceLog {
  const DietMealComplianceLog({
    required this.id,
    required this.planId,
    required this.dateKey,
    required this.slot,
    required this.status,
    this.note = '',
    required this.loggedAt,
  });

  final String id;
  final String planId;
  final String dateKey;
  final MealSlot slot;
  final MealComplianceStatus status;
  final String note;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'dateKey': dateKey,
        'slot': slot.name,
        'status': status.name,
        'note': note,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory DietMealComplianceLog.fromJson(Map<String, dynamic> json) {
    return DietMealComplianceLog(
      id: (json['id'] as String?) ?? '',
      planId: (json['planId'] as String?) ?? '',
      dateKey: (json['dateKey'] as String?) ?? '',
      slot: MealSlotX.fromId(json['slot'] as String?),
      status: MealComplianceStatusX.fromId(json['status'] as String?),
      note: (json['note'] as String?) ?? '',
      loggedAt: DateTime.tryParse((json['loggedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Aggregated compliance stats for an active diet plan.
class DietComplianceSummary {
  const DietComplianceSummary({
    required this.followedCount,
    required this.notFollowedCount,
  });

  final int followedCount;
  final int notFollowedCount;

  int get totalLogged => followedCount + notFollowedCount;

  int get compliancePercent =>
      totalLogged == 0 ? 0 : ((followedCount / totalLogged) * 100).round();
}

/// A single body weight entry tracked during (or independently of) a diet plan.
class DietWeightEntry {
  const DietWeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
    this.planId,
    this.note = '',
  });

  final String id;
  final double weightKg;
  final DateTime date;
  final String? planId;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'weightKg': weightKg,
        'date': date.toIso8601String(),
        if (planId != null) 'planId': planId,
        'note': note,
      };

  factory DietWeightEntry.fromJson(Map<String, dynamic> json) {
    return DietWeightEntry(
      id: (json['id'] as String?) ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      planId: json['planId'] as String?,
      note: (json['note'] as String?) ?? '',
    );
  }
}

/// One detected food component on a scanned plate.
class PlateFoodItem {
  const PlateFoodItem({
    required this.name,
    required this.portion,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final String name;
  final String portion;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  PlateFoodItem scaled(double factor) => PlateFoodItem(
        name: name,
        portion: factor == 1.0 ? portion : '$portion (${factor}x)',
        calories: (calories * factor).round(),
        proteinG: double.parse((proteinG * factor).toStringAsFixed(1)),
        carbsG: double.parse((carbsG * factor).toStringAsFixed(1)),
        fatG: double.parse((fatG * factor).toStringAsFixed(1)),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };

  factory PlateFoodItem.fromJson(Map<String, dynamic> json) {
    return PlateFoodItem(
      name: (json['name'] as String?) ?? '',
      portion: (json['portion'] as String?) ?? '',
      calories: (json['calories'] as num?)?.round() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Logged AI plate photo or text-based calorie scan (works independently of
/// any diet OR linked to an active diet).
class CalorieScanEntry {
  const CalorieScanEntry({
    required this.id,
    required this.createdAt,
    required this.dateKey,
    required this.mealSlot,
    required this.dishName,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    required this.items,
    this.healthScore = 7,
    this.healthComment = '',
    this.photoPath,
    this.analyzedByAi = false,
    this.linkedDietPlanId,
  });

  final String id;
  final DateTime createdAt;
  final String dateKey;
  final MealSlot mealSlot;
  final String dishName;
  final int totalCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final List<PlateFoodItem> items;
  final int healthScore;
  final String healthComment;
  final String? photoPath;
  final bool analyzedByAi;
  final String? linkedDietPlanId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'dateKey': dateKey,
        'mealSlot': mealSlot.name,
        'dishName': dishName,
        'totalCalories': totalCalories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
        'items': items.map((i) => i.toJson()).toList(),
        'healthScore': healthScore,
        'healthComment': healthComment,
        if (photoPath != null) 'photoPath': photoPath,
        'analyzedByAi': analyzedByAi,
        if (linkedDietPlanId != null) 'linkedDietPlanId': linkedDietPlanId,
      };

  factory CalorieScanEntry.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    return CalorieScanEntry(
      id: (json['id'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      dateKey: (json['dateKey'] as String?) ?? '',
      mealSlot: MealSlotX.fromId(json['mealSlot'] as String?),
      dishName: (json['dishName'] as String?) ?? '',
      totalCalories: (json['totalCalories'] as num?)?.round() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      fiberG: (json['fiberG'] as num?)?.toDouble() ?? 0,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(PlateFoodItem.fromJson)
          .toList(),
      healthScore: ((json['healthScore'] as num?)?.toInt() ?? 7).clamp(1, 10),
      healthComment: (json['healthComment'] as String?) ?? '',
      photoPath: json['photoPath'] as String?,
      analyzedByAi: (json['analyzedByAi'] as bool?) ?? false,
      linkedDietPlanId: json['linkedDietPlanId'] as String?,
    );
  }
}
