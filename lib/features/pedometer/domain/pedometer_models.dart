import 'package:flutter/material.dart';

enum WalkActivityMode {
  normal,
  running,
  mountainHiking,
}

extension WalkActivityModeX on WalkActivityMode {
  String get label {
    switch (this) {
      case WalkActivityMode.normal:
        return 'Normal Yürüyüş';
      case WalkActivityMode.running:
        return 'Koşu';
      case WalkActivityMode.mountainHiking:
        return 'Dağ Yürüyüşü';
    }
  }

  String get shortLabel {
    switch (this) {
      case WalkActivityMode.normal:
        return 'Normal';
      case WalkActivityMode.running:
        return 'Koşu';
      case WalkActivityMode.mountainHiking:
        return 'Dağ Yürüyüşü';
    }
  }

  IconData get icon {
    switch (this) {
      case WalkActivityMode.normal:
        return Icons.directions_walk_rounded;
      case WalkActivityMode.running:
        return Icons.directions_run_rounded;
      case WalkActivityMode.mountainHiking:
        return Icons.terrain_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case WalkActivityMode.normal:
        return const Color(0xFF0D9488);
      case WalkActivityMode.running:
        return const Color(0xFFEA580C);
      case WalkActivityMode.mountainHiking:
        return const Color(0xFF16A34A);
    }
  }

  /// Average stride length in meters for distance estimation.
  double get strideMeters {
    switch (this) {
      case WalkActivityMode.normal:
        return 0.74;
      case WalkActivityMode.running:
        return 0.98;
      case WalkActivityMode.mountainHiking:
        return 0.68;
    }
  }

  /// Calories burned per step for an average 72kg adult, adjusted by terrain/MET.
  double get kcalPerStep {
    switch (this) {
      case WalkActivityMode.normal:
        return 0.042;
      case WalkActivityMode.running:
        return 0.078;
      case WalkActivityMode.mountainHiking:
        return 0.068;
    }
  }

  /// Typical cadence (steps per minute) when live simulation / pace helper is active.
  int get cadenceStepsPerMinute {
    switch (this) {
      case WalkActivityMode.normal:
        return 105;
      case WalkActivityMode.running:
        return 160;
      case WalkActivityMode.mountainHiking:
        return 90;
    }
  }

  static WalkActivityMode fromName(String? raw) {
    for (final m in WalkActivityMode.values) {
      if (m.name == raw) return m;
    }
    return WalkActivityMode.normal;
  }
}

class WalkSessionRecord {
  const WalkSessionRecord({
    required this.id,
    required this.mode,
    required this.startedAt,
    required this.endedAt,
    required this.steps,
  });

  final String id;
  final WalkActivityMode mode;
  final DateTime startedAt;
  final DateTime endedAt;
  final int steps;

  Duration get duration {
    final diff = endedAt.difference(startedAt);
    return diff.isNegative ? Duration.zero : diff;
  }

  double get distanceKm => (steps * mode.strideMeters) / 1000.0;

  double get caloriesKcal => steps * mode.kcalPerStep;

  String get formattedDuration {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h}s ${m.toString().padLeft(2, '0')}dk';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.name,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'steps': steps,
      };

  factory WalkSessionRecord.fromJson(Map<String, dynamic> json) {
    return WalkSessionRecord(
      id: (json['id'] as String?) ?? '',
      mode: WalkActivityModeX.fromName(json['mode'] as String?),
      startedAt:
          DateTime.tryParse((json['startedAt'] as String?) ?? '') ?? DateTime.now(),
      endedAt:
          DateTime.tryParse((json['endedAt'] as String?) ?? '') ?? DateTime.now(),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
    );
  }
}

class ActiveInstantWalkSession {
  const ActiveInstantWalkSession({
    required this.mode,
    required this.startedAt,
    this.steps = 0,
  });

  final WalkActivityMode mode;
  final DateTime startedAt;
  final int steps;

  double get distanceKm => (steps * mode.strideMeters) / 1000.0;
  double get caloriesKcal => steps * mode.kcalPerStep;

  Duration elapsedAt(DateTime now) {
    final diff = now.difference(startedAt);
    return diff.isNegative ? Duration.zero : diff;
  }

  ActiveInstantWalkSession copyWith({
    WalkActivityMode? mode,
    DateTime? startedAt,
    int? steps,
  }) {
    return ActiveInstantWalkSession(
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'startedAt': startedAt.toIso8601String(),
        'steps': steps,
      };

  factory ActiveInstantWalkSession.fromJson(Map<String, dynamic> json) {
    return ActiveInstantWalkSession(
      mode: WalkActivityModeX.fromName(json['mode'] as String?),
      startedAt:
          DateTime.tryParse((json['startedAt'] as String?) ?? '') ?? DateTime.now(),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
    );
  }
}

class PedometerState {
  const PedometerState({
    this.isContinuousMode = false,
    this.selectedMode = WalkActivityMode.normal,
    this.dailyStepGoal = 10000,
    this.showOnProfile = true,
    this.dailyStepsByDate = const {},
    this.sessions = const [],
    this.activeSession,
  });

  final bool isContinuousMode;
  final WalkActivityMode selectedMode;
  final int dailyStepGoal;
  final bool showOnProfile;
  final Map<String, int> dailyStepsByDate;
  final List<WalkSessionRecord> sessions;
  final ActiveInstantWalkSession? activeSession;

  bool get isInstantSessionRunning => activeSession != null;

  static String dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  int todayStepsAt(DateTime now) {
    return dailyStepsByDate[dateKey(now)] ?? 0;
  }

  /// Sum of steps for the last 7 days (inclusive of today).
  int thisWeekStepsAt(DateTime now) {
    int sum = 0;
    final today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 7; i++) {
      final d = today.subtract(Duration(days: i));
      sum += dailyStepsByDate[dateKey(d)] ?? 0;
    }
    return sum;
  }

  /// Sum of steps in the current calendar month.
  int thisMonthStepsAt(DateTime now) {
    final prefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-';
    int sum = 0;
    dailyStepsByDate.forEach((k, v) {
      if (k.startsWith(prefix)) sum += v;
    });
    return sum;
  }

  double todayDistanceKmAt(DateTime now) =>
      (todayStepsAt(now) * selectedMode.strideMeters) / 1000.0;

  double todayCaloriesAt(DateTime now) =>
      todayStepsAt(now) * selectedMode.kcalPerStep;

  PedometerState copyWith({
    bool? isContinuousMode,
    WalkActivityMode? selectedMode,
    int? dailyStepGoal,
    bool? showOnProfile,
    Map<String, int>? dailyStepsByDate,
    List<WalkSessionRecord>? sessions,
    ActiveInstantWalkSession? activeSession,
    bool clearActiveSession = false,
  }) {
    return PedometerState(
      isContinuousMode: isContinuousMode ?? this.isContinuousMode,
      selectedMode: selectedMode ?? this.selectedMode,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      showOnProfile: showOnProfile ?? this.showOnProfile,
      dailyStepsByDate: dailyStepsByDate ?? this.dailyStepsByDate,
      sessions: sessions ?? this.sessions,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
    );
  }

  Map<String, dynamic> toJson() => {
        'isContinuousMode': isContinuousMode,
        'selectedMode': selectedMode.name,
        'dailyStepGoal': dailyStepGoal,
        'showOnProfile': showOnProfile,
        'dailyStepsByDate': dailyStepsByDate,
        'sessions': sessions.map((s) => s.toJson()).toList(),
        if (activeSession != null) 'activeSession': activeSession!.toJson(),
      };

  factory PedometerState.fromJson(Map<String, dynamic> json) {
    final rawDaily = <String, int>{};
    if (json['dailyStepsByDate'] is Map) {
      (json['dailyStepsByDate'] as Map).forEach((k, v) {
        if (k is String && v is num) {
          rawDaily[k] = v.toInt();
        }
      });
    }
    final rawSessions = (json['sessions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(WalkSessionRecord.fromJson)
            .toList() ??
        const <WalkSessionRecord>[];

    ActiveInstantWalkSession? parsedActive;
    if (json['activeSession'] is Map<String, dynamic>) {
      parsedActive = ActiveInstantWalkSession.fromJson(
        json['activeSession'] as Map<String, dynamic>,
      );
    }

    return PedometerState(
      isContinuousMode: (json['isContinuousMode'] as bool?) ?? false,
      selectedMode:
          WalkActivityModeX.fromName(json['selectedMode'] as String?),
      dailyStepGoal: (json['dailyStepGoal'] as num?)?.toInt() ?? 10000,
      showOnProfile: (json['showOnProfile'] as bool?) ?? true,
      dailyStepsByDate: rawDaily,
      sessions: rawSessions,
      activeSession: parsedActive,
    );
  }
}
