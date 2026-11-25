import 'dart:async';

import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';

/// Watches active medication alarms while the app is in the foreground so that
/// when an alarm's scheduled weekday + HH:mm is reached, the full-screen
/// ringing alarm overlay with the medicine photo and description opens
/// immediately.
class MedicationAlarmWatcher {
  MedicationAlarmWatcher({
    required this.repositoryProvider,
    required this.onAlarmTriggered,
    this.pollInterval = const Duration(seconds: 15),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MedicationReminderRepository Function() repositoryProvider;
  final void Function(MedicationReminder reminder) onAlarmTriggered;
  final Duration pollInterval;
  final DateTime Function() _clock;

  Timer? _timer;
  final Set<String> _firedMinuteKeys = <String>{};
  bool _checking = false;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => checkNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _firedMinuteKeys.clear();
  }

  /// Checks whether any enabled alarm matches the current weekday & HH:mm and
  /// hasn't already been taken/skipped today or rung during this minute.
  Future<void> checkNow() async {
    if (_checking) return;
    _checking = true;
    try {
      final now = _clock();
      final repo = repositoryProvider();
      final reminders = await repo.loadReminders();
      if (reminders.isEmpty) return;
      final todayStatuses = await repo.getTodayStatusMap(now: now);
      final dateKey = MedicationReminder.dateKeyFor(now);

      for (final reminder in reminders) {
        if (!reminder.enabled) continue;
        if (!reminder.isScheduledForWeekday(now.weekday)) continue;
        if (reminder.hour != now.hour || reminder.minute != now.minute) continue;

        final existingLog = todayStatuses[reminder.id];
        if (existingLog != null &&
            (existingLog.status == MedicationDoseStatus.taken ||
                existingLog.status == MedicationDoseStatus.skipped)) {
          continue;
        }

        final minuteKey =
            '${reminder.id}_${dateKey}_${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        if (_firedMinuteKeys.contains(minuteKey)) continue;

        _firedMinuteKeys.add(minuteKey);
        onAlarmTriggered(reminder);
        break;
      }
    } catch (_) {
      // Never crash background polling.
    } finally {
      _checking = false;
    }
  }
}
