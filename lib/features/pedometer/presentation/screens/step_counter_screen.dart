import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/pedometer/data/pedometer_service.dart';
import 'package:visualcheckup/features/pedometer/domain/pedometer_models.dart';
import 'package:visualcheckup/features/widgets_hub/data/quick_widgets_preferences.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({
    super.key,
    this.service,
    this.communityRepository,
    this.currentUserId,
    this.currentUserDisplayName,
  });

  final PedometerService? service;
  final HealthCommunityRepository? communityRepository;
  final String? currentUserId;
  final String? currentUserDisplayName;

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late final PedometerService _service;
  Timer? _uiClockTimer;
  Timer? _paceSimTimer;
  bool _paceSimActive = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PedometerService.instance;
    _service.addListener(_onServiceChanged);
    _service.ensureLoaded();
    _uiClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _service.state.isInstantSessionRunning) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiClockTimer?.cancel();
    _paceSimTimer?.cancel();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) {
      setState(() {});
    }
    _syncToCommunityProfile();
  }

  Future<void> _syncToCommunityProfile() async {
    final commRepo = widget.communityRepository;
    final uid = widget.currentUserId;
    if (commRepo == null || uid == null || uid.isEmpty) return;

    final now = DateTime.now();
    final st = _service.state;
    try {
      final existing = await commRepo.loadMyProfile(uid);
      if (existing != null) {
        final updated = existing.copyWith(
          showStepsOnProfile: st.showOnProfile,
          todayStepsCount: st.todayStepsAt(now),
          weekStepsCount: st.thisWeekStepsAt(now),
          monthStepsCount: st.thisMonthStepsAt(now),
          dailyStepGoal: st.dailyStepGoal,
          updatedAt: now,
        );
        await commRepo.saveMyProfile(updated);
      }
    } catch (_) {}
  }

  void _togglePaceSim(bool enabled) {
    _paceSimTimer?.cancel();
    setState(() => _paceSimActive = enabled);
    if (enabled) {
      _paceSimTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (!mounted) return;
        final mode = _service.state.activeSession?.mode ??
            _service.state.selectedMode;
        final stepsPer2Sec = ((mode.cadenceStepsPerMinute) / 30.0).round().clamp(2, 12);
        _service.recordSteps(stepsPer2Sec);
      });
    }
  }

  Future<void> _openGoalDialog() async {
    final ctrl = TextEditingController(
      text: _service.state.dailyStepGoal.toString(),
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Günlük Adım Hedefi'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Hedef Adım Sayısı',
            helperText: 'Örn: 8000, 10000, 12000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text.trim()) ?? 10000;
              Navigator.of(ctx).pop();
              _service.setDailyGoal(val);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _formatSteps(int value) {
    return NumberFormat.decimalPattern('tr').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final st = _service.state;
    final now = DateTime.now();

    final todaySteps = st.todayStepsAt(now);
    final weekSteps = st.thisWeekStepsAt(now);
    final monthSteps = st.thisMonthStepsAt(now);
    final progress =
        (todaySteps / st.dailyStepGoal.clamp(1, 100000)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adım Sayar & Yürüyüş'),
        actions: [
          IconButton(
            key: const Key('pedometer_pin_android_widget_btn'),
            tooltip: 'Android Ana Ekrana Widget Ekle',
            onPressed: () async {
              final pinned =
                  await QuickWidgetsPreferences.requestPinNativeHomeWidget(
                widgetType: 'pedometer',
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    pinned
                        ? '📱 Adım Sayar widget’ı Android ana ekranına gönderildi!'
                        : 'Telefon ana ekranına basılı tutup Widget’lar > VisualCheckUp altından "Adım Sayar" widget’ını ekleyebilirsiniz.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_to_home_screen_rounded),
          ),
          IconButton(
            tooltip: 'Günlük Adım Hedefi',
            onPressed: _openGoalDialog,
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // 1. Mode Selector (Normal / Koşu / Dağ Yürüyüşü)
          _buildModeSelectorCard(context, st, theme),
          const SizedBox(height: 12),

          // 2. Continuous Mode Card + Bugün / Bu Hafta / Bu Ay Summary
          _buildContinuousModeCard(
            context,
            st: st,
            todaySteps: todaySteps,
            weekSteps: weekSteps,
            monthSteps: monthSteps,
            progress: progress,
            now: now,
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),

          // 3. Instant Walk Session Card (Anlık Mod)
          _buildInstantSessionCard(context, st, now, theme),
          const SizedBox(height: 12),

          // 4. Profile Visibility Toggle
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              key: const Key('pedometer_profile_visibility_switch'),
              dense: true,
              secondary: Icon(
                st.showOnProfile
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_outlined,
                color: colorScheme.primary,
              ),
              title: const Text(
                'Adım Sayar Kartını Profilimde Göster',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                st.showOnProfile
                    ? 'Bugün, bu hafta ve bu ay adım istatistikleriniz profilinizde görünür.'
                    : 'Gizli: Profil ziyaretçileriniz adım sayınızı göremez.',
                style: theme.textTheme.bodySmall,
              ),
              value: st.showOnProfile,
              onChanged: (v) => _service.setShowOnProfile(v),
            ),
          ),
          const SizedBox(height: 18),

          // 5. Stacked Session History Table (Alt Alta Yürüyüş Tablosu)
          _buildSessionsHistoryTable(context, st, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildModeSelectorCard(
    BuildContext context,
    PedometerState st,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yürüyüş & Aktivite Modu Seçin',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adım boyu (mesafe) ve yakılan kalori seçtiğiniz moda göre otomatik hesaplanır.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (int i = 0; i < WalkActivityMode.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _ModeChoiceTile(
                      mode: WalkActivityMode.values[i],
                      selected: st.selectedMode == WalkActivityMode.values[i],
                      onTap: () =>
                          _service.setSelectedMode(WalkActivityMode.values[i]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinuousModeCard(
    BuildContext context, {
    required PedometerState st,
    required int todaySteps,
    required int weekSteps,
    required int monthSteps,
    required double progress,
    required DateTime now,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final accent = st.selectedMode.accentColor;
    return Container(
      key: const Key('pedometer_continuous_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: st.isContinuousMode
              ? [accent, accent.withValues(alpha: 0.78)]
              : [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainer,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.all_inclusive_rounded,
                color: st.isContinuousMode ? Colors.white : accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sürekli Mod (Gün Boyu Takip)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: st.isContinuousMode ? Colors.white : null,
                      ),
                    ),
                    Text(
                      st.isContinuousMode
                          ? 'Açık: Anlık yürüyüşleriniz de otomatik eklenerek devam ediyor.'
                          : 'Kapalı: Günlük, haftalık ve aylık toplam için açabilirsiniz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: st.isContinuousMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('pedometer_continuous_switch'),
                value: st.isContinuousMode,
                onChanged: (v) => _service.setContinuousMode(v),
              ),
            ],
          ),
          if (st.isContinuousMode || todaySteps > 0 || weekSteps > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PeriodStepsBox(
                    key: const Key('pedometer_today_box'),
                    title: 'Bugün',
                    stepsFormatted: _formatSteps(todaySteps),
                    subLabel:
                        '${st.todayDistanceKmAt(now).toStringAsFixed(2)} km • ${st.todayCaloriesAt(now).round()} kcal',
                    inverted: st.isContinuousMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PeriodStepsBox(
                    key: const Key('pedometer_week_box'),
                    title: 'Bu Hafta',
                    stepsFormatted: _formatSteps(weekSteps),
                    subLabel: 'Son 7 Gün',
                    inverted: st.isContinuousMode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PeriodStepsBox(
                    key: const Key('pedometer_month_box'),
                    title: 'Bu Ay',
                    stepsFormatted: _formatSteps(monthSteps),
                    subLabel: 'Aylık Toplam',
                    inverted: st.isContinuousMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlük Hedef: ${_formatSteps(todaySteps)} / ${_formatSteps(st.dailyStepGoal)} Adım',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: st.isContinuousMode ? Colors.white : null,
                  ),
                ),
                Text(
                  '%${(progress * 100).round()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: st.isContinuousMode ? Colors.white : accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: st.isContinuousMode
                    ? Colors.white.withValues(alpha: 0.24)
                    : colorScheme.surfaceContainerHighest,
                color: st.isContinuousMode ? Colors.white : accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstantSessionCard(
    BuildContext context,
    PedometerState st,
    DateTime now,
    ThemeData theme,
  ) {
    final active = st.activeSession;
    final mode = active?.mode ?? st.selectedMode;
    final accent = mode.accentColor;
    final elapsed = active?.elapsedAt(now) ?? Duration.zero;
    final mm = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final hh = elapsed.inHours;
    final timeStr = hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';

    return Card(
      key: const Key('pedometer_instant_card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: active != null
              ? accent.withValues(alpha: 0.65)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: active != null ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.14),
                  child: Icon(mode.icon, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anlık Mod (${mode.label})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        active != null
                            ? 'Yürüyüş devam ediyor • Süre: $timeStr'
                            : 'Başlattığınızda bu yürüyüşe özel adımlar sayılır, durdurduğunuzda aşağıdaki tabloya eklenir.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (active != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InstantMetricPill(
                      label: 'Anlık Adım',
                      value: _formatSteps(active.steps),
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InstantMetricPill(
                      label: 'Mesafe',
                      value: '${active.distanceKm.toStringAsFixed(2)} km',
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InstantMetricPill(
                      label: 'Kalori',
                      value: '${active.caloriesKcal.round()} kcal',
                      accent: accent,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (active == null)
                  FilledButton.icon(
                    key: const Key('pedometer_start_instant_btn'),
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    onPressed: () => _service.startInstantSession(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Anlık Modu Başlat'),
                  )
                else
                  FilledButton.icon(
                    key: const Key('pedometer_stop_instant_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                    ),
                    onPressed: () async {
                      _togglePaceSim(false);
                      final saved = await _service.stopInstantSession();
                      if (!context.mounted || saved == null) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ ${saved.mode.label} tamamlandı: ${saved.steps} adım tabloya eklendi.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Durdur & Tabloya Kaydet'),
                  ),
                if (active != null || st.isContinuousMode) ...[
                  OutlinedButton.icon(
                    key: const Key('pedometer_add_100_steps_btn'),
                    onPressed: () => _service.recordSteps(100),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('+100 Adım'),
                  ),
                  FilterChip(
                    selected: _paceSimActive,
                    label: const Text('Tempo Simülatörü'),
                    avatar: const Icon(Icons.bolt_rounded, size: 16),
                    onSelected: _togglePaceSim,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsHistoryTable(
    BuildContext context,
    PedometerState st,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      key: const Key('pedometer_sessions_table_card'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anlık Yürüyüş Kayıtları Tablosu (${st.sessions.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (st.sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Henüz tamamlanmış bir anlık yürüyüş kaydınız yok. Anlık modu başlatıp durdurduğunuzda adımlarınız burada alt alta tablo olarak listelenir.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  horizontalMargin: 4,
                  headingRowHeight: 38,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 52,
                  columns: const [
                    DataColumn(label: Text('Tarih')),
                    DataColumn(label: Text('Mod')),
                    DataColumn(label: Text('Süre')),
                    DataColumn(numeric: true, label: Text('Adım')),
                    DataColumn(numeric: true, label: Text('Km / Kcal')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final s in st.sessions)
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              DateFormat('dd.MM HH:mm').format(s.endedAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  s.mode.icon,
                                  size: 15,
                                  color: s.mode.accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  s.mode.shortLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: s.mode.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              s.formattedDuration,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatSteps(s.steps),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${s.distanceKm.toStringAsFixed(2)} km • ${s.caloriesKcal.round()} kcal',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline, size: 17),
                              onPressed: () => _service.deleteSession(s.id),
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
    );
  }
}

class _ModeChoiceTile extends StatelessWidget {
  const _ModeChoiceTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final WalkActivityMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = mode.accentColor;
    return InkWell(
      key: Key('pedometer_mode_${mode.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(mode.icon, color: accent, size: 22),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                mode.shortLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? accent : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodStepsBox extends StatelessWidget {
  const _PeriodStepsBox({
    super.key,
    required this.title,
    required this.stepsFormatted,
    required this.subLabel,
    required this.inverted,
  });

  final String title;
  final String stepsFormatted;
  final String subLabel;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: inverted
                  ? Colors.white70
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stepsFormatted,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: inverted ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: inverted
                  ? Colors.white70
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstantMetricPill extends StatelessWidget {
  const _InstantMetricPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
