import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/photo_zoom_viewer.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_audio_player.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/medications/presentation/screens/medication_alarm_ring_screen.dart';

typedef MedicationPhotoPicker = Future<Uint8List?> Function(ImageSource source);

/// Main Medication & Health Alarm Reminder hub screen.
///
/// Offers a senior-friendly "Today" schedule with quick Taken checkboxes and an
/// "All Alarms" tab with weekday chips, medicine photo thumbnails, active
/// toggles, live "Test Alarm" preview, and full Add/Edit alarm modal.
class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({
    super.key,
    required this.repository,
    this.scheduler,
    this.audioPlayer,
    this.photoPicker,
  });

  final MedicationReminderRepository repository;
  final MedicationAlarmScheduler? scheduler;
  final MedicationAlarmAudioPlayer? audioPlayer;
  final MedicationPhotoPicker? photoPicker;

  @override
  State<MedicationRemindersScreen> createState() =>
      _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MedicationAlarmScheduler _scheduler;
  late final MedicationAlarmAudioPlayer _audioPlayer;
  List<MedicationReminder> _reminders = const [];
  Map<String, MedicationDoseLog> _todayStatuses = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scheduler = widget.scheduler ?? LocalMedicationAlarmScheduler.instance;
    _audioPlayer =
        widget.audioPlayer ?? PlatformMedicationAlarmAudioPlayer.instance;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final reminders = await widget.repository.loadReminders();
    final statuses = await widget.repository.getTodayStatusMap();
    if (!mounted) return;
    setState(() {
      _reminders = reminders;
      _todayStatuses = statuses;
      _loading = false;
    });
  }

  List<MedicationReminder> get _todayReminders {
    final todayWeekday = DateTime.now().weekday;
    return _reminders
        .where((r) => r.enabled && r.isScheduledForWeekday(todayWeekday))
        .toList();
  }

  int get _todayTakenCount => _todayReminders
      .where(
        (r) => _todayStatuses[r.id]?.status == MedicationDoseStatus.taken,
      )
      .length;

  ({MedicationReminder reminder, DateTime triggerAt})? _findNextUpcoming() {
    final now = DateTime.now();
    MedicationReminder? best;
    DateTime? bestTime;
    for (final reminder in _reminders) {
      final next = reminder.nextTriggerTime(now);
      if (next == null) continue;
      if (bestTime == null || next.isBefore(bestTime)) {
        best = reminder;
        bestTime = next;
      }
    }
    if (best == null || bestTime == null) return null;
    return (reminder: best, triggerAt: bestTime);
  }

  Future<void> _openAddEditSheet({
    MedicationReminder? existing,
    MedicationCategory? initialCategory,
  }) async {
    final saved = await showModalBottomSheet<MedicationReminder>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AddEditMedicationSheet(
        existing: existing,
        initialCategory: initialCategory,
        repository: widget.repository,
        scheduler: _scheduler,
        audioPlayer: _audioPlayer,
        photoPicker: widget.photoPicker,
      ),
    );

    if (saved == null || !mounted) return;
    final l10n = context.l10n;
    await widget.repository.saveReminder(saved);
    await _scheduler.requestPermissions();
    await _scheduler.scheduleReminder(
      saved,
      categoryLabel: saved.localizedCategoryLabel(l10n),
      mealTimingLabel: saved.mealTiming.localizedLabel(l10n),
    );
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.medAlarmSaved)),
    );
  }

  Future<void> _toggleEnabled(MedicationReminder reminder, bool enabled) async {
    final l10n = context.l10n;
    await widget.repository.toggleEnabled(reminder.id, enabled);
    final updated = reminder.copyWith(enabled: enabled);
    if (enabled) {
      await _scheduler.scheduleReminder(
        updated,
        categoryLabel: updated.localizedCategoryLabel(l10n),
        mealTimingLabel: updated.mealTiming.localizedLabel(l10n),
      );
    } else {
      await _scheduler.cancelReminder(reminder.id);
    }
    await _loadData();
  }

  Future<void> _confirmDelete(MedicationReminder reminder) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.medDeleteConfirmTitle),
        content: Text(l10n.medDeleteConfirmBody(reminder.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.medDeleteConfirmTitle),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _scheduler.cancelReminder(reminder.id);
    await widget.repository.deleteReminder(reminder.id);
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.medAlarmDeleted)),
    );
  }

  Future<void> _toggleTakenQuick(MedicationReminder reminder) async {
    final existing = _todayStatuses[reminder.id];
    if (existing?.status == MedicationDoseStatus.taken) {
      await widget.repository.clearTodayDoseStatus(reminder.id);
    } else {
      await widget.repository.logDoseStatus(
        reminderId: reminder.id,
        status: MedicationDoseStatus.taken,
      );
    }
    await _loadData();
  }

  Future<void> _previewAlarm(MedicationReminder reminder) async {
    final l10n = context.l10n;
    final action = await MedicationAlarmRingScreen.show(
      context,
      reminder: reminder,
      repository: widget.repository,
      scheduler: _scheduler,
      audioPlayer: _audioPlayer,
      isPreview: true,
    );
    await _loadData();
    if (!mounted) return;
    if (action == MedicationAlarmAction.taken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medRingTakenToast)),
      );
    } else if (action == MedicationAlarmAction.snoozed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medRingSnoozedToast)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayList = _todayReminders;
    final nextUpcoming = _findNextUpcoming();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.today_rounded, size: 19),
              text: '${l10n.medTabToday} (${todayList.length})',
            ),
            Tab(
              icon: const Icon(Icons.alarm_rounded, size: 19),
              text: '${l10n.medTabAll} (${_reminders.length})',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('med_add_alarm_fab'),
        onPressed: () => _openAddEditSheet(),
        icon: const Icon(Icons.add_alarm_rounded),
        label: Text(l10n.medAddAlarm),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _EmptyMedicationsState(
                  onAddWithCategory: (cat) =>
                      _openAddEditSheet(initialCategory: cat),
                )
              : Column(
                  children: [
                    // Senior-friendly daily summary banner
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _TodaySummaryBanner(
                        takenCount: _todayTakenCount,
                        totalCount: todayList.length,
                        nextUpcoming: nextUpcoming,
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Today's scheduled doses
                          todayList.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.event_available_rounded,
                                          size: 56,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.55),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.medNoTodayAlarms,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    6,
                                    16,
                                    96,
                                  ),
                                  itemCount: todayList.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = todayList[index];
                                    return _TodayDoseCard(
                                      reminder: item,
                                      log: _todayStatuses[item.id],
                                      onToggleTaken: () =>
                                          _toggleTakenQuick(item),
                                      onPreviewAlarm: () =>
                                          _previewAlarm(item),
                                      onEdit: () =>
                                          _openAddEditSheet(existing: item),
                                    );
                                  },
                                ),

                          // Tab 2: All alarms management
                          ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                            itemCount: _reminders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _reminders[index];
                              return _AllAlarmCard(
                                reminder: item,
                                onToggleEnabled: (v) =>
                                    _toggleEnabled(item, v),
                                onPreviewAlarm: () => _previewAlarm(item),
                                onEdit: () =>
                                    _openAddEditSheet(existing: item),
                                onDelete: () => _confirmDelete(item),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _TodaySummaryBanner extends StatelessWidget {
  const _TodaySummaryBanner({
    required this.takenCount,
    required this.totalCount,
    required this.nextUpcoming,
    required this.isDark,
  });

  final int takenCount;
  final int totalCount;
  final ({MedicationReminder reminder, DateTime triggerAt})? nextUpcoming;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = totalCount == 0 ? 0.0 : takenCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF123635), Color(0xFF0E2324)]
              : const [AppTheme.primaryTeal, AppTheme.secondaryMint],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medication_liquid_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.medTodayProgressTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  l10n.medHomeCardTodaySummary(takenCount, totalCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (nextUpcoming != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.alarm_on_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.medNextAlarmLabel(
                      nextUpcoming!.reminder.formattedTime,
                      nextUpcoming!.reminder.title,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MedicineThumbnail extends StatelessWidget {
  const _MedicineThumbnail({
    required this.reminder,
    this.size = 64,
  });

  final MedicationReminder reminder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photoPath = reminder.photoPath;
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();
    final accent = reminder.category.accentColor;

    return GestureDetector(
      onTap: hasPhoto
          ? () => PhotoZoomViewer.show(
                context,
                imagePath: photoPath,
                title: reminder.title,
                subtitle: reminder.formattedTime,
              )
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasPhoto
            ? Image.file(
                File(photoPath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  reminder.category.icon,
                  color: accent,
                  size: size * 0.45,
                ),
              )
            : Icon(
                reminder.category.icon,
                color: accent,
                size: size * 0.45,
              ),
      ),
    );
  }
}

class _TodayDoseCard extends StatelessWidget {
  const _TodayDoseCard({
    required this.reminder,
    required this.log,
    required this.onToggleTaken,
    required this.onPreviewAlarm,
    required this.onEdit,
  });

  final MedicationReminder reminder;
  final MedicationDoseLog? log;
  final VoidCallback onToggleTaken;
  final VoidCallback onPreviewAlarm;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTaken = log?.status == MedicationDoseStatus.taken;
    final isSkipped = log?.status == MedicationDoseStatus.skipped;
    final isSnoozed = log?.status == MedicationDoseStatus.snoozed;
    final accent = reminder.category.accentColor;

    final statusColor = isTaken
        ? const Color(0xFF16A34A)
        : isSnoozed
            ? const Color(0xFFD97706)
            : isSkipped
                ? colorScheme.outline
                : accent;
    final statusLabel = log != null
        ? log!.status.localizedLabel(l10n)
        : l10n.medStatusPending;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isTaken
              ? const Color(0xFF16A34A).withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
          width: isTaken ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MedicineThumbnail(reminder: reminder, size: 68),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                reminder.formattedTime,
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            decoration: isTaken
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            reminder.localizedCategoryLabel(l10n),
                            if (reminder.dosage.trim().isNotEmpty)
                              reminder.dosage.trim(),
                            if (reminder.mealTiming != MealTiming.anytime)
                              reminder.mealTiming.localizedLabel(l10n),
                          ].join(' • '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reminder.description.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reminder.description.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isTaken
                            ? colorScheme.surfaceContainerHighest
                            : const Color(0xFF16A34A),
                        foregroundColor: isTaken
                            ? colorScheme.onSurface
                            : Colors.white,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: onToggleTaken,
                      icon: Icon(
                        isTaken
                            ? Icons.undo_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      label: Text(
                        isTaken ? l10n.medActionUndo : l10n.medActionTaken,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onPreviewAlarm,
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 18),
                    label: Text(l10n.medActionPreviewAlarm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllAlarmCard extends StatelessWidget {
  const _AllAlarmCard({
    required this.reminder,
    required this.onToggleEnabled,
    required this.onPreviewAlarm,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicationReminder reminder;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onPreviewAlarm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = reminder.category.accentColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Opacity(
        opacity: reminder.enabled ? 1.0 : 0.62,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MedicineThumbnail(reminder: reminder, size: 62),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              reminder.formattedTime,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reminder.localizedCategoryLabel(l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.localizedDaysSummary(l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              reminder.soundEnabled
                                  ? reminder.alarmSound.icon
                                  : Icons.volume_off_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                reminder.soundEnabled
                                    ? reminder.alarmSound.localizedLabel(l10n)
                                    : l10n.medSoundSilent,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: reminder.enabled,
                    onChanged: onToggleEnabled,
                  ),
                ],
              ),
              if (reminder.description.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.description.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Compact weekday indicator bar
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (int day = 1; day <= 7; day++)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: reminder.isScheduledForWeekday(day)
                            ? accent.withValues(alpha: 0.16)
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        MedicationReminderL10n.localizedWeekdayShort(day, l10n),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: reminder.isScheduledForWeekday(day)
                              ? accent
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onPreviewAlarm,
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 18),
                    label: Text(l10n.medActionPreviewAlarm),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.medEditAlarm,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.medDeleteConfirmTitle,
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMedicationsState extends StatelessWidget {
  const _EmptyMedicationsState({required this.onAddWithCategory});

  final ValueChanged<MedicationCategory?> onAddWithCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_add_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.medEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.medEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  avatar: Icon(
                    MedicationCategory.diabetesInsulin.icon,
                    color: MedicationCategory.diabetesInsulin.accentColor,
                    size: 18,
                  ),
                  label: Text(l10n.medQuickPresetDiabetes),
                  onPressed: () =>
                      onAddWithCategory(MedicationCategory.diabetesInsulin),
                ),
                ActionChip(
                  avatar: Icon(
                    MedicationCategory.bloodPressure.icon,
                    color: MedicationCategory.bloodPressure.accentColor,
                    size: 18,
                  ),
                  label: Text(l10n.medQuickPresetBp),
                  onPressed: () =>
                      onAddWithCategory(MedicationCategory.bloodPressure),
                ),
                ActionChip(
                  avatar: Icon(
                    MedicationCategory.herbalTea.icon,
                    color: MedicationCategory.herbalTea.accentColor,
                    size: 18,
                  ),
                  label: Text(l10n.medQuickPresetHerbalTea),
                  onPressed: () =>
                      onAddWithCategory(MedicationCategory.herbalTea),
                ),
                ActionChip(
                  avatar: Icon(
                    MedicationCategory.vitamin.icon,
                    color: MedicationCategory.vitamin.accentColor,
                    size: 18,
                  ),
                  label: Text(l10n.medQuickPresetVitamin),
                  onPressed: () =>
                      onAddWithCategory(MedicationCategory.vitamin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditMedicationSheet extends StatefulWidget {
  const _AddEditMedicationSheet({
    required this.repository,
    this.existing,
    this.initialCategory,
    this.scheduler,
    this.audioPlayer,
    this.photoPicker,
  });

  final MedicationReminderRepository repository;
  final MedicationReminder? existing;
  final MedicationCategory? initialCategory;
  final MedicationAlarmScheduler? scheduler;
  final MedicationAlarmAudioPlayer? audioPlayer;
  final MedicationPhotoPicker? photoPicker;

  @override
  State<_AddEditMedicationSheet> createState() =>
      _AddEditMedicationSheetState();
}

class _AddEditMedicationSheetState extends State<_AddEditMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _dosageController;
  late final TextEditingController _descriptionController;
  late final MedicationAlarmAudioPlayer _audioPlayer;

  late MedicationCategory _category;
  late MealTiming _mealTiming;
  late TimeOfDay _time;
  late Set<int> _weekdays;
  late bool _soundEnabled;
  late bool _vibrateEnabled;
  late MedicationAlarmSound _alarmSound;

  MedicationAlarmSound? _previewingSound;
  Timer? _previewStopTimer;

  String? _existingPhotoPath;
  Uint8List? _pendingPhotoBytes;
  bool _photoRemoved = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _audioPlayer =
        widget.audioPlayer ?? PlatformMedicationAlarmAudioPlayer.instance;
    _titleController = TextEditingController(text: e?.title ?? '');
    _customCategoryController =
        TextEditingController(text: e?.customCategoryLabel ?? '');
    _dosageController = TextEditingController(text: e?.dosage ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? widget.initialCategory ?? MedicationCategory.pill;
    _mealTiming = e?.mealTiming ?? MealTiming.anytime;
    _time = e != null
        ? TimeOfDay(hour: e.hour, minute: e.minute)
        : const TimeOfDay(hour: 9, minute: 0);
    _weekdays = Set<int>.from(e?.weekdays ?? MedicationReminder.allWeekdays);
    _soundEnabled = e?.soundEnabled ?? true;
    _vibrateEnabled = e?.vibrateEnabled ?? true;
    _alarmSound = e?.alarmSound ?? MedicationAlarmSound.classicAlarm;
    _existingPhotoPath = e?.photoPath;
  }

  @override
  void dispose() {
    _previewStopTimer?.cancel();
    if (_previewingSound != null) {
      unawaited(_audioPlayer.stop());
    }
    _titleController.dispose();
    _customCategoryController.dispose();
    _dosageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _stopSoundPreview({bool updateState = true}) {
    _previewStopTimer?.cancel();
    _previewStopTimer = null;
    final wasPlaying = _previewingSound != null;
    if (wasPlaying) {
      unawaited(_audioPlayer.stop());
    }
    if (updateState && mounted && wasPlaying) {
      setState(() => _previewingSound = null);
    } else {
      _previewingSound = null;
    }
  }

  Future<void> _toggleSoundPreview(MedicationAlarmSound sound) async {
    if (_previewingSound == sound) {
      _stopSoundPreview();
      return;
    }
    _previewStopTimer?.cancel();
    setState(() {
      _alarmSound = sound;
      _previewingSound = sound;
    });
    await _audioPlayer.play(sound, loop: false);
    _previewStopTimer = Timer(const Duration(milliseconds: 5400), () {
      if (mounted && _previewingSound == sound) {
        setState(() => _previewingSound = null);
      }
    });
  }

  Future<void> _previewDraftAlarm() async {
    _stopSoundPreview();
    final l10n = context.l10n;
    final customCat = _category == MedicationCategory.other
        ? _customCategoryController.text.trim()
        : '';
    final enteredTitle = _titleController.text.trim();
    final fallbackTitle = customCat.isNotEmpty
        ? customCat
        : _category.localizedLabel(l10n);

    final draft = MedicationReminder(
      id: widget.existing?.id ?? 'draft_preview',
      title: enteredTitle.isNotEmpty ? enteredTitle : fallbackTitle,
      category: _category,
      customCategoryLabel: customCat,
      hour: _time.hour,
      minute: _time.minute,
      weekdays: Set<int>.from(_weekdays),
      dosage: _dosageController.text.trim(),
      description: _descriptionController.text.trim(),
      mealTiming: _mealTiming,
      photoPath: _photoRemoved ? null : _existingPhotoPath,
      enabled: true,
      soundEnabled: _soundEnabled,
      vibrateEnabled: _vibrateEnabled,
      alarmSound: _alarmSound,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    await MedicationAlarmRingScreen.show(
      context,
      reminder: draft,
      repository: widget.repository,
      scheduler: widget.scheduler,
      audioPlayer: _audioPlayer,
      isPreview: true,
      persistActions: false,
      previewPhotoBytes: _pendingPhotoBytes,
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      Uint8List? bytes;
      if (widget.photoPicker != null) {
        bytes = await widget.photoPicker!(source);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          imageQuality: 88,
        );
        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes == null || !mounted) return;
      setState(() {
        _pendingPhotoBytes = bytes;
        _photoRemoved = false;
      });
    } catch (_) {
      // Gracefully ignore camera/gallery cancellation or simulator errors.
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  void _toggleDay(int isoWeekday) {
    setState(() {
      if (_weekdays.contains(isoWeekday)) {
        if (_weekdays.length > 1) {
          _weekdays.remove(isoWeekday);
        }
      } else {
        _weekdays.add(isoWeekday);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    _stopSoundPreview(updateState: false);
    setState(() => _saving = true);

    final id = widget.existing?.id ??
        'med_${DateTime.now().microsecondsSinceEpoch}';

    String? finalPhotoPath = _photoRemoved ? null : _existingPhotoPath;
    if (_pendingPhotoBytes != null) {
      finalPhotoPath = await widget.repository.saveMedicationPhoto(
        reminderId: id,
        imageBytes: _pendingPhotoBytes!,
      );
    }

    final reminder = MedicationReminder(
      id: id,
      title: _titleController.text.trim(),
      category: _category,
      customCategoryLabel: _category == MedicationCategory.other
          ? _customCategoryController.text.trim()
          : '',
      hour: _time.hour,
      minute: _time.minute,
      weekdays: Set<int>.from(_weekdays),
      dosage: _dosageController.text.trim(),
      description: _descriptionController.text.trim(),
      mealTiming: _mealTiming,
      photoPath: finalPhotoPath,
      enabled: widget.existing?.enabled ?? true,
      soundEnabled: _soundEnabled,
      vibrateEnabled: _vibrateEnabled,
      alarmSound: _alarmSound,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(reminder);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = _category.accentColor;
    final hasSavedPhoto = !_photoRemoved &&
        _existingPhotoPath != null &&
        _existingPhotoPath!.isNotEmpty &&
        File(_existingPhotoPath!).existsSync();
    final hasAnyPhoto = _pendingPhotoBytes != null || hasSavedPhoto;
    final formattedTime =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('med_form_list_view'),
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                Text(
                  widget.existing == null
                      ? l10n.medAddAlarm
                      : l10n.medEditAlarm,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Category selector
                Text(
                  l10n.medFieldCategory,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final cat in MedicationCategory.values)
                      ChoiceChip(
                        avatar: Icon(
                          cat.icon,
                          size: 18,
                          color: _category == cat
                              ? Colors.white
                              : cat.accentColor,
                        ),
                        label: Text(cat.localizedLabel(l10n)),
                        selected: _category == cat,
                        selectedColor: cat.accentColor,
                        labelStyle: TextStyle(
                          color: _category == cat ? Colors.white : null,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setState(() => _category = cat),
                      ),
                  ],
                ),
                if (_category == MedicationCategory.other) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('med_custom_category_field'),
                    controller: _customCategoryController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.medFieldCustomCategory,
                      hintText: l10n.medFieldCustomCategoryHint,
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // 2. Medicine Photo Capture Box
                Text(
                  l10n.medFieldPhoto,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAnyPhoto) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: double.infinity,
                            height: 170,
                            child: _pendingPhotoBytes != null
                                ? Image.memory(
                                    _pendingPhotoBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_existingPhotoPath!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: accent.withValues(alpha: 0.14),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.medPhotoHint,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              key: const Key('med_take_photo_button'),
                              onPressed: () => _pickPhoto(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera_rounded,
                                  size: 18),
                              label: Text(l10n.medTakePhoto),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const Key('med_pick_gallery_button'),
                              onPressed: () => _pickPhoto(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_rounded,
                                  size: 18),
                              label: Text(l10n.medPickGallery),
                            ),
                          ),
                        ],
                      ),
                      if (hasAnyPhoto) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed: () => setState(() {
                              _pendingPhotoBytes = null;
                              _photoRemoved = true;
                            }),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            label: Text(
                              l10n.medRemovePhoto,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Medicine Name
                TextFormField(
                  key: const Key('med_name_field'),
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.medFieldName,
                    hintText: l10n.medFieldNameHint,
                    prefixIcon: Icon(_category.icon, color: accent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.medFieldNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 4. Dosage
                TextFormField(
                  key: const Key('med_dosage_field'),
                  controller: _dosageController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.medFieldDosage,
                    hintText: l10n.medFieldDosageHint,
                    prefixIcon: const Icon(Icons.scale_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 5. Reminder Description / Note (shown on alarm!)
                TextFormField(
                  key: const Key('med_description_field'),
                  controller: _descriptionController,
                  maxLines: 3,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.medFieldDescription,
                    hintText: l10n.medFieldDescriptionHint,
                    prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 6. Big Time Picker Card
                Text(
                  l10n.medFieldTime,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  key: const Key('med_time_picker_button'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alarm_rounded, color: accent, size: 30),
                        const SizedBox(width: 14),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.edit_rounded, color: accent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 7. Weekday selection + Quick Presets
                Row(
                  children: [
                    Text(
                      l10n.medFieldDays,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(
                        () => _weekdays =
                            Set<int>.from(MedicationReminder.allWeekdays),
                      ),
                      child: Text(l10n.medEveryDay),
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => _weekdays =
                            Set<int>.from(MedicationReminder.workWeekdays),
                      ),
                      child: Text(l10n.medWeekdays),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int day = 1; day <= 7; day++)
                      FilterChip(
                        key: Key('med_weekday_chip_$day'),
                        label: Text(
                          MedicationReminderL10n.localizedWeekdayShort(
                            day,
                            l10n,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        selected: _weekdays.contains(day),
                        onSelected: (_) => _toggleDay(day),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // 8. Meal Timing
                Text(
                  l10n.medFieldMealTiming,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final timing in MealTiming.values)
                      ChoiceChip(
                        avatar: Icon(timing.icon, size: 16),
                        label: Text(timing.localizedLabel(l10n)),
                        selected: _mealTiming == timing,
                        onSelected: (_) => setState(() => _mealTiming = timing),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // 9. Sound, Alarm Ringtone Picker & Vibration toggles
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: Text(l10n.medSoundToggle),
                  value: _soundEnabled,
                  onChanged: (v) {
                    if (!v) _stopSoundPreview();
                    setState(() => _soundEnabled = v);
                  },
                ),
                if (_soundEnabled) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.medFieldAlarmSound,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    key: const Key('med_alarm_sound_picker'),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < MedicationAlarmSound.values.length;
                            i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.45),
                            ),
                          _AlarmSoundOptionTile(
                            sound: MedicationAlarmSound.values[i],
                            selected:
                                _alarmSound == MedicationAlarmSound.values[i],
                            playing: _previewingSound ==
                                MedicationAlarmSound.values[i],
                            accent: accent,
                            onSelect: () {
                              final picked = MedicationAlarmSound.values[i];
                              if (_previewingSound != null &&
                                  _previewingSound != picked) {
                                _stopSoundPreview();
                              }
                              setState(() => _alarmSound = picked);
                            },
                            onTogglePreview: () => _toggleSoundPreview(
                              MedicationAlarmSound.values[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.vibration_rounded),
                  title: Text(l10n.medVibrateToggle),
                  value: _vibrateEnabled,
                  onChanged: (v) => setState(() => _vibrateEnabled = v),
                ),
                      ],
                    ),
                  ),
                ),
                // 10. Pinned senior-friendly Preview & Save action bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 54,
                          child: OutlinedButton.icon(
                            key: const Key('med_form_preview_alarm_button'),
                            onPressed: _saving ? null : _previewDraftAlarm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                              size: 20,
                            ),
                            label: Text(
                              l10n.medActionPreviewAlarm,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              key: const Key('med_save_alarm_button'),
                              onPressed: _saving ? null : _save,
                              icon: const Icon(Icons.check_rounded),
                              label: Text(
                                l10n.medSaveAlarm,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AlarmSoundOptionTile extends StatelessWidget {
  const _AlarmSoundOptionTile({
    required this.sound,
    required this.selected,
    required this.playing,
    required this.accent,
    required this.onSelect,
    required this.onTogglePreview,
  });

  final MedicationAlarmSound sound;
  final bool selected;
  final bool playing;
  final Color accent;
  final VoidCallback onSelect;
  final VoidCallback onTogglePreview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      key: Key('med_sound_option_${sound.name}'),
      onTap: onSelect,
      child: Container(
        color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? accent : colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (selected ? accent : colorScheme.primary)
                    .withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                sound.icon,
                size: 18,
                color: selected ? accent : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.localizedLabel(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    sound.localizedDescription(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              key: Key('med_sound_preview_${sound.name}'),
              style: FilledButton.styleFrom(
                backgroundColor: playing
                    ? accent
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: playing ? Colors.white : colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTogglePreview,
              icon: Icon(
                playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 18,
              ),
              label: Text(
                playing
                    ? l10n.medSoundPreviewStop
                    : l10n.medSoundPreviewPlay,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
