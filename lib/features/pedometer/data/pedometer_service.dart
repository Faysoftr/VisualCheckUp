import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/pedometer/domain/pedometer_models.dart';

class PedometerService extends ChangeNotifier {
  PedometerService({this.profileId = 'self'});

  static final PedometerService instance = PedometerService();

  final String profileId;

  static const String _baseKey = 'visualcheckup_pedometer_state_v1';
  static const String widgetTodayStepsKey = 'vcu_widget_steps_today';
  static const String widgetGoalStepsKey = 'vcu_widget_steps_goal';
  static const String widgetModeLabelKey = 'vcu_widget_steps_mode';

  static const EventChannel _sensorChannel =
      EventChannel('com.faysoft.visualcheckup/step_events');
  static const MethodChannel _homeWidgetChannel =
      MethodChannel('com.faysoft.visualcheckup/home_widget');

  PedometerState _state = const PedometerState();
  bool _loaded = false;
  StreamSubscription<dynamic>? _sensorSub;
  int? _lastHardwareBootCount;

  PedometerState get state => _state;
  bool get isLoaded => _loaded;

  String get _storageKey =>
      profileId == 'self' ? _baseKey : '${_baseKey}_$profileId';

  Future<PedometerState> ensureLoaded() async {
    if (_loaded) return _state;
    return reload();
  }

  Future<PedometerState> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _state = PedometerState.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _state = const PedometerState();
      }
    } else {
      _state = const PedometerState();
    }
    _loaded = true;
    _syncSensorSubscription();
    notifyListeners();
    return _state;
  }

  Future<void> _persist({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_state.toJson()));

    final ref = now ?? DateTime.now();
    await prefs.setInt(widgetTodayStepsKey, _state.todayStepsAt(ref));
    await prefs.setInt(widgetGoalStepsKey, _state.dailyStepGoal);
    await prefs.setString(
      widgetModeLabelKey,
      _state.activeSession != null
          ? '${_state.activeSession!.mode.shortLabel} (Anlık Aktif)'
          : (_state.isContinuousMode ? 'Sürekli Mod Açık' : 'Hazır'),
    );

    notifyListeners();
    unawaited(_refreshNativeWidgetSafe());
  }

  static Future<void> _refreshNativeWidgetSafe() async {
    try {
      await _homeWidgetChannel.invokeMethod<void>('refreshWidget');
    } catch (_) {}
  }

  Future<void> requestSensorPermissionIfNeeded() async {
    if (kIsWeb) return;
    try {
      final status = await Permission.activityRecognition.status;
      if (status.isDenied) {
        await Permission.activityRecognition.request();
      }
    } catch (_) {
      // Safe no-op in headless test environments.
    }
  }

  void _syncSensorSubscription() {
    final shouldListen =
        _state.isContinuousMode || _state.activeSession != null;
    if (shouldListen && _sensorSub == null) {
      try {
        _sensorSub = _sensorChannel.receiveBroadcastStream().listen(
          (dynamic event) {
            if (event is int) {
              _onHardwareBootStepCount(event);
            } else if (event is num) {
              _onHardwareBootStepCount(event.toInt());
            } else if (event is Map && event['delta'] is num) {
              recordSteps((event['delta'] as num).toInt());
            }
          },
          onError: (_) {},
        );
      } catch (_) {
        // Channel unavailable in unit tests or unsupported platforms.
      }
    } else if (!shouldListen && _sensorSub != null) {
      _sensorSub?.cancel();
      _sensorSub = null;
      _lastHardwareBootCount = null;
    }
  }

  void _onHardwareBootStepCount(int bootSteps) {
    if (_lastHardwareBootCount == null) {
      _lastHardwareBootCount = bootSteps;
      return;
    }
    final delta = bootSteps - _lastHardwareBootCount!;
    _lastHardwareBootCount = bootSteps;
    if (delta > 0 && delta < 5000) {
      recordSteps(delta);
    }
  }

  Future<void> setContinuousMode(bool enabled, {DateTime? now}) async {
    await ensureLoaded();
    _state = _state.copyWith(isContinuousMode: enabled);
    _syncSensorSubscription();
    await _persist(now: now);
    if (enabled) {
      unawaited(requestSensorPermissionIfNeeded());
    }
  }

  Future<void> setSelectedMode(WalkActivityMode mode) async {
    await ensureLoaded();
    ActiveInstantWalkSession? updatedActive = _state.activeSession;
    if (updatedActive != null) {
      updatedActive = updatedActive.copyWith(mode: mode);
    }
    _state = _state.copyWith(
      selectedMode: mode,
      activeSession: updatedActive,
    );
    await _persist();
  }

  Future<void> setDailyGoal(int goal) async {
    await ensureLoaded();
    _state = _state.copyWith(dailyStepGoal: goal.clamp(1000, 100000));
    await _persist();
  }

  Future<void> setShowOnProfile(bool show) async {
    await ensureLoaded();
    _state = _state.copyWith(showOnProfile: show);
    await _persist();
  }

  Future<void> startInstantSession({
    WalkActivityMode? mode,
    DateTime? now,
  }) async {
    await ensureLoaded();
    final ref = now ?? DateTime.now();
    final chosenMode = mode ?? _state.selectedMode;
    _state = _state.copyWith(
      selectedMode: chosenMode,
      activeSession: ActiveInstantWalkSession(
        mode: chosenMode,
        startedAt: ref,
        steps: 0,
      ),
    );
    _syncSensorSubscription();
    await _persist(now: ref);
    unawaited(requestSensorPermissionIfNeeded());
  }

  /// Records newly detected steps.
  /// - If an instant session is active, increments the session's step count.
  /// - If Continuous Mode (`isContinuousMode`) is enabled, ALSO adds the steps
  ///   to today's continuous total (`dailyStepsByDate[today]`) seamlessly!
  Future<void> recordSteps(int deltaSteps, {DateTime? now}) async {
    if (deltaSteps <= 0) return;
    await ensureLoaded();
    final ref = now ?? DateTime.now();

    ActiveInstantWalkSession? updatedActive = _state.activeSession;
    if (updatedActive != null) {
      updatedActive = updatedActive.copyWith(
        steps: updatedActive.steps + deltaSteps,
      );
    }

    final updatedDaily = Map<String, int>.from(_state.dailyStepsByDate);
    if (_state.isContinuousMode) {
      final key = PedometerState.dateKey(ref);
      updatedDaily[key] = (updatedDaily[key] ?? 0) + deltaSteps;
    }

    _state = _state.copyWith(
      dailyStepsByDate: updatedDaily,
      activeSession: updatedActive,
    );
    await _persist(now: ref);
  }

  /// Stops the active instant walk session, computes total steps/distance/calories,
  /// and appends a row to the session history table (`sessions`).
  Future<WalkSessionRecord?> stopInstantSession({DateTime? now}) async {
    await ensureLoaded();
    final active = _state.activeSession;
    if (active == null) return null;

    final ref = now ?? DateTime.now();
    final record = WalkSessionRecord(
      id: 'walk_${ref.microsecondsSinceEpoch}',
      mode: active.mode,
      startedAt: active.startedAt,
      endedAt: ref.isBefore(active.startedAt) ? active.startedAt : ref,
      steps: active.steps,
    );

    final updatedSessions = <WalkSessionRecord>[
      record,
      ..._state.sessions,
    ].take(200).toList();

    _state = _state.copyWith(
      sessions: updatedSessions,
      clearActiveSession: true,
    );
    _syncSensorSubscription();
    await _persist(now: ref);
    return record;
  }

  Future<void> deleteSession(String id) async {
    await ensureLoaded();
    _state = _state.copyWith(
      sessions: _state.sessions.where((s) => s.id != id).toList(),
    );
    await _persist();
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    super.dispose();
  }
}
