import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/photo_zoom_viewer.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_audio_player.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';

/// Action selected by the user on the full-screen ringing medication alarm.
enum MedicationAlarmAction {
  taken,
  snoozed,
  skipped,
  dismissed,
}

/// Full-screen, high-contrast, senior-friendly alarm overlay shown when a
/// medication reminder fires (or when testing an alarm preview).
///
/// Plays the reminder's selected alarm ringtone in a continuous loop on the
/// native alarm audio stream and displays the medicine's real photo prominently
/// alongside the reminder time, category badge, dosage, meal timing, and full
/// explanation note.
class MedicationAlarmRingScreen extends StatefulWidget {
  const MedicationAlarmRingScreen({
    super.key,
    required this.reminder,
    required this.repository,
    this.scheduler,
    this.audioPlayer,
    this.isPreview = false,
    this.persistActions = true,
    this.previewPhotoBytes,
  });

  final MedicationReminder reminder;
  final MedicationReminderRepository repository;
  final MedicationAlarmScheduler? scheduler;
  final MedicationAlarmAudioPlayer? audioPlayer;
  final bool isPreview;

  /// When false (e.g. unsaved draft preview inside the Add/Edit sheet),
  /// tapping Taken/Snooze/Skip closes the preview without mutating saved logs.
  final bool persistActions;

  /// Optional in-memory photo bytes for unsaved draft previews.
  final Uint8List? previewPhotoBytes;

  static Future<MedicationAlarmAction?> show(
    BuildContext context, {
    required MedicationReminder reminder,
    required MedicationReminderRepository repository,
    MedicationAlarmScheduler? scheduler,
    MedicationAlarmAudioPlayer? audioPlayer,
    bool isPreview = false,
    bool persistActions = true,
    Uint8List? previewPhotoBytes,
  }) {
    return Navigator.of(context).push<MedicationAlarmAction>(
      MaterialPageRoute<MedicationAlarmAction>(
        fullscreenDialog: true,
        builder: (_) => MedicationAlarmRingScreen(
          reminder: reminder,
          repository: repository,
          scheduler: scheduler,
          audioPlayer: audioPlayer,
          isPreview: isPreview,
          persistActions: persistActions,
          previewPhotoBytes: previewPhotoBytes,
        ),
      ),
    );
  }

  @override
  State<MedicationAlarmRingScreen> createState() =>
      _MedicationAlarmRingScreenState();
}

class _MedicationAlarmRingScreenState extends State<MedicationAlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final MedicationAlarmAudioPlayer _audioPlayer;
  Timer? _vibrateTimer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer =
        widget.audioPlayer ?? PlatformMedicationAlarmAudioPlayer.instance;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _startAlertLoop();
  }

  void _startAlertLoop() {
    if (widget.reminder.soundEnabled) {
      unawaited(
        _audioPlayer.play(widget.reminder.alarmSound, loop: true),
      );
    }
    if (widget.reminder.vibrateEnabled) {
      _triggerVibrationPulse();
      _vibrateTimer = Timer.periodic(
        const Duration(milliseconds: 1800),
        (_) => _triggerVibrationPulse(),
      );
    }
  }

  void _triggerVibrationPulse() {
    if (!mounted) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {
      // Ignore on desktop/test hosts without platform haptic channels.
    }
  }

  void _stopAlertLoop() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    unawaited(_audioPlayer.stop());
  }

  @override
  void dispose() {
    _stopAlertLoop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleTaken() async {
    if (_busy) return;
    setState(() => _busy = true);
    _stopAlertLoop();
    if (widget.persistActions) {
      await widget.repository.logDoseStatus(
        reminderId: widget.reminder.id,
        status: MedicationDoseStatus.taken,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(MedicationAlarmAction.taken);
  }

  Future<void> _handleSnooze() async {
    if (_busy) return;
    setState(() => _busy = true);
    _stopAlertLoop();
    if (widget.persistActions) {
      final l10n = context.l10n;
      await widget.repository.logDoseStatus(
        reminderId: widget.reminder.id,
        status: MedicationDoseStatus.snoozed,
      );
      final scheduler =
          widget.scheduler ?? LocalMedicationAlarmScheduler.instance;
      await scheduler.scheduleSnooze(
        widget.reminder,
        minutes: 10,
        categoryLabel: widget.reminder.localizedCategoryLabel(l10n),
        snoozeBody: l10n.medRingSnoozedToast,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(MedicationAlarmAction.snoozed);
  }

  Future<void> _handleSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
    _stopAlertLoop();
    if (widget.persistActions) {
      await widget.repository.logDoseStatus(
        reminderId: widget.reminder.id,
        status: MedicationDoseStatus.skipped,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(MedicationAlarmAction.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reminder = widget.reminder;
    final accent = reminder.category.accentColor;
    final photoPath = reminder.photoPath;
    final hasFilePhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();
    final hasMemoryPhoto = widget.previewPhotoBytes != null &&
        widget.previewPhotoBytes!.isNotEmpty;
    final hasPhoto = hasMemoryPhoto || hasFilePhoto;

    final detailChips = <String>[
      if (reminder.dosage.trim().isNotEmpty) reminder.dosage.trim(),
      if (reminder.mealTiming != MealTiming.anytime)
        reminder.mealTiming.localizedLabel(l10n),
    ];

    return PopScope(
      canPop: !_busy,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _stopAlertLoop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(accent, const Color(0xFF0A161A), 0.72)!,
                const Color(0xFF0B1418),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top bar with pulsing alarm icon & close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 4),
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.12).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.28),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.medRingHeader,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                                if (widget.isPreview) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.28),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.amber.shade200
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.medPreviewModeBadge,
                                      style: TextStyle(
                                        color: Colors.amber.shade100,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              reminder.formattedTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _busy
                            ? null
                            : () {
                                _stopAlertLoop();
                                Navigator.of(context)
                                    .pop(MedicationAlarmAction.dismissed);
                              },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable center: Large Medicine Photo + Title + Reminder Explanation
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        // Category & Active Alarm Sound Badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    reminder.category.icon,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    reminder.localizedCategoryLabel(l10n),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    reminder.soundEnabled
                                        ? reminder.alarmSound.icon
                                        : Icons.volume_off_rounded,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    reminder.soundEnabled
                                        ? reminder.alarmSound
                                            .localizedLabel(l10n)
                                        : l10n.medSoundSilent,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Prominent Medicine Photo Card
                        GestureDetector(
                          onTap: hasFilePhoto
                              ? () => PhotoZoomViewer.show(
                                    context,
                                    imagePath: photoPath,
                                    title: reminder.title,
                                    subtitle: reminder.formattedTime,
                                  )
                              : null,
                          child: Container(
                            width: double.infinity,
                            height: 230,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: hasPhoto
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (hasMemoryPhoto)
                                        Image.memory(
                                          widget.previewPhotoBytes!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _NoPhotoFallback(
                                            accent: accent,
                                            icon: reminder.category.icon,
                                            label: l10n.medRingNoPhoto,
                                          ),
                                        )
                                      else
                                        Image.file(
                                          File(photoPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _NoPhotoFallback(
                                            accent: accent,
                                            icon: reminder.category.icon,
                                            label: l10n.medRingNoPhoto,
                                          ),
                                        ),
                                      if (hasFilePhoto)
                                        Positioned(
                                          right: 12,
                                          bottom: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.62),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.zoom_in_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  l10n.medRingTapZoom,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : _NoPhotoFallback(
                                    accent: accent,
                                    icon: reminder.category.icon,
                                    label: l10n.medRingNoPhoto,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Big Medicine Name
                        Text(
                          reminder.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),

                        // Dosage & Meal Timing Pills
                        if (detailChips.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final chip in detailChips)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    chip,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],

                        // Prominent Reminder Explanation Card
                        if (reminder.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sticky_note_2_rounded,
                                      color: Colors.amber.shade200,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.medRingNoteTitle,
                                      style: TextStyle(
                                        color: Colors.amber.shade200,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reminder.description.trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Senior-Friendly Large Action Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton.icon(
                          key: const Key('alarm_ring_taken_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: _busy ? null : _handleTaken,
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 28,
                          ),
                          label: Text(l10n.medActionTaken),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                key: const Key('alarm_ring_snooze_button'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.amber.shade200,
                                  side: BorderSide(
                                    color: Colors.amber.shade200
                                        .withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: _busy ? null : _handleSnooze,
                                icon: const Icon(Icons.snooze_rounded),
                                label: Text(l10n.medActionSnooze),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 52,
                            child: TextButton(
                              key: const Key('alarm_ring_skip_button'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _busy ? null : _handleSkip,
                              child: Text(
                                l10n.medActionSkip,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoPhotoFallback extends StatelessWidget {
  const _NoPhotoFallback({
    required this.accent,
    required this.icon,
    required this.label,
  });

  final Color accent;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.35),
            accent.withValues(alpha: 0.14),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
