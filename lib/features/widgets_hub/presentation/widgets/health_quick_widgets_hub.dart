import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/pedometer/data/pedometer_service.dart';
import 'package:visualcheckup/features/pedometer/domain/pedometer_models.dart';
import 'package:visualcheckup/features/sobriety/data/sobriety_repository.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';
import 'package:visualcheckup/features/widgets_hub/data/quick_widgets_preferences.dart';

class HealthQuickWidgetsHub extends StatefulWidget {
  const HealthQuickWidgetsHub({
    super.key,
    required this.onOpenPedometer,
    required this.onOpenSobriety,
    required this.onOpenVitals,
    required this.onOpenAlarms,
    this.pedometerService,
    this.sobrietyRepository,
    this.vitalsRepository,
    this.medicationRepository,
  });

  final VoidCallback onOpenPedometer;
  final VoidCallback onOpenSobriety;
  final VoidCallback onOpenVitals;
  final VoidCallback onOpenAlarms;
  final PedometerService? pedometerService;
  final SobrietyRepository? sobrietyRepository;
  final LabsVitalsRepository? vitalsRepository;
  final MedicationReminderRepository? medicationRepository;

  @override
  State<HealthQuickWidgetsHub> createState() => _HealthQuickWidgetsHubState();
}

class _HealthQuickWidgetsHubState extends State<HealthQuickWidgetsHub> {
  late final PedometerService _pedometer;
  late final SobrietyRepository _sobrietyRepo;
  late final LabsVitalsRepository _vitalsRepo;
  late final MedicationReminderRepository _medRepo;

  List<QuickWidgetType> _enabled = List<QuickWidgetType>.from(
    QuickWidgetsPreferences.defaultEnabled,
  );
  SobrietyState _sobriety = const SobrietyState();
  BloodPressureReading? _latestBp;
  BloodSugarReading? _latestSugar;
  List<MedicationReminder> _activeAlarms = const [];

  @override
  void initState() {
    super.initState();
    _pedometer = widget.pedometerService ?? PedometerService.instance;
    _sobrietyRepo = widget.sobrietyRepository ?? SobrietyRepository();
    _vitalsRepo = widget.vitalsRepository ?? LabsVitalsRepository();
    _medRepo = widget.medicationRepository ?? MedicationReminderRepository();

    _pedometer.addListener(_onPedometerUpdated);
    SobrietyRepository.revisionNotifier.addListener(_refreshAll);
    _pedometer.ensureLoaded();
    _refreshAll();
  }

  @override
  void dispose() {
    _pedometer.removeListener(_onPedometerUpdated);
    SobrietyRepository.revisionNotifier.removeListener(_refreshAll);
    super.dispose();
  }

  void _onPedometerUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshAll() async {
    final results = await Future.wait<dynamic>([
      QuickWidgetsPreferences.loadEnabledWidgets(),
      _sobrietyRepo.loadState(),
      _vitalsRepo.loadBloodPressureReadings(),
      _vitalsRepo.loadBloodSugarReadings(),
      _medRepo.loadReminders(),
    ]);

    if (!mounted) return;
    final enabled = results[0] as List<QuickWidgetType>;
    final sob = results[1] as SobrietyState;
    final bps = results[2] as List<BloodPressureReading>;
    final sugars = results[3] as List<BloodSugarReading>;
    final alarms = (results[4] as List<MedicationReminder>)
        .where((r) => r.enabled)
        .toList();

    final bpText = bps.isNotEmpty ? bps.first.formatted : '--/-- mmHg';
    final sugarText =
        sugars.isNotEmpty ? sugars.first.formatted : '-- mg/dL';
    final alarmText = alarms.isNotEmpty
        ? '${alarms.first.formattedTime} • ${alarms.first.title}'
        : 'Aktif alarm yok';

    await QuickWidgetsPreferences.syncVitalsAndAlarmWidgetCache(
      vitalsSummary: 'Tansiyon: $bpText | Şeker: $sugarText',
      alarmSummary: alarmText,
    );

    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _sobriety = sob;
      _latestBp = bps.isNotEmpty ? bps.first : null;
      _latestSugar = sugars.isNotEmpty ? sugars.first : null;
      _activeAlarms = alarms;
    });
  }

  Future<void> _openCustomizeSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        var working = List<QuickWidgetType>.from(_enabled);
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.widgets_rounded, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sağlık Widget’larını Yönet',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yürüyüş, alarm, sigara/alkol bırakma ve şeker/tansiyon takibi için istediğiniz widget’ları ana ekrana ekleyin veya gizleyin.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  for (final type in QuickWidgetType.values)
                    CheckboxListTile(
                      key: Key('widget_toggle_${type.name}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      secondary: CircleAvatar(
                        radius: 17,
                        backgroundColor:
                            type.accentColor.withValues(alpha: 0.14),
                        child: Icon(
                          type.icon,
                          color: type.accentColor,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        type.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        type.subtitle,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      value: working.contains(type),
                      onChanged: (checked) {
                        setModalState(() {
                          if (checked == true) {
                            if (!working.contains(type)) working.add(type);
                          } else {
                            working.remove(type);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('pin_native_home_widget_btn'),
                      onPressed: () async {
                        final pinned = await QuickWidgetsPreferences
                            .requestPinNativeHomeWidget();
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              pinned
                                  ? 'Telefon ana ekranına VisualCheckUp widget isteği gönderildi!'
                                  : 'Telefonunuzun ana ekranına basılı tutup Widget’lar menüsünden "VisualCheckUp Sağlık" widget’ını da ekleyebilirsiniz.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_to_home_screen_rounded),
                      label: const Text('Telefon Ana Ekranına Widget Sabitle'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('save_quick_widgets_btn'),
                      onPressed: () async {
                        await QuickWidgetsPreferences.saveEnabledWidgets(
                          working,
                        );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        if (mounted) {
                          setState(() => _enabled = working);
                        }
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Widget Düzenini Kaydet'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openQuickVitalEntrySheet() async {
    final sysCtrl = TextEditingController(text: '120');
    final diaCtrl = TextEditingController(text: '80');
    final sugarCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı Tansiyon & Şeker Kaydı',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sysCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Büyük (Sistolik)',
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: diaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Küçük (Diyastolik)',
                        suffixText: 'mmHg',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sugarCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kan Şekeri (İsteğe Bağlı)',
                  hintText: 'Örn: 96',
                  suffixText: 'mg/dL',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final sys = int.tryParse(sysCtrl.text.trim());
                    final dia = int.tryParse(diaCtrl.text.trim());
                    final sug = double.tryParse(sugarCtrl.text.trim());
                    if (sys != null && dia != null && sys > 40 && dia > 25) {
                      await _vitalsRepo.saveBloodPressure(
                        BloodPressureReading(
                          id: 'bp_${now.microsecondsSinceEpoch}',
                          recordedAt: now,
                          systolic: sys,
                          diastolic: dia,
                        ),
                      );
                    }
                    if (sug != null && sug > 20) {
                      await _vitalsRepo.saveBloodSugar(
                        BloodSugarReading(
                          id: 'bs_${now.microsecondsSinceEpoch}',
                          recordedAt: now,
                          valueMgDl: sug,
                          measurementType: SugarMeasurementType.random,
                        ),
                      );
                    }
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    await _refreshAll();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Column(
      key: const Key('health_quick_widgets_hub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.widgets_outlined, size: 19, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Hızlı Takip Widget’larım',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('customize_quick_widgets_btn'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: _openCustomizeSheet,
              icon: const Icon(Icons.add_box_outlined, size: 17),
              label: const Text('Widget Ekle / Düzenle'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_enabled.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: _openCustomizeSheet,
              leading: const Icon(Icons.widgets_rounded),
              title: const Text('Henüz aktif widget seçilmedi'),
              subtitle: const Text(
                'Yürüyüş, alarm, bırakma sayacı veya şeker/tansiyon widget’ı eklemek için dokunun.',
              ),
              trailing: const Icon(Icons.add_rounded),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _enabled.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 142,
            ),
            itemBuilder: (context, index) {
              final type = _enabled[index];
              switch (type) {
                case QuickWidgetType.pedometer:
                  return _buildPedometerMiniWidget(now, theme);
                case QuickWidgetType.sobriety:
                  return _buildSobrietyMiniWidget(now, theme);
                case QuickWidgetType.vitals:
                  return _buildVitalsMiniWidget(theme);
                case QuickWidgetType.alarms:
                  return _buildAlarmsMiniWidget(theme);
              }
            },
          ),
      ],
    );
  }

  Widget _buildPedometerMiniWidget(DateTime now, ThemeData theme) {
    final st = _pedometer.state;
    final today = st.todayStepsAt(now);
    final goal = st.dailyStepGoal.clamp(1, 100000);
    final ratio = (today / goal).clamp(0.0, 1.0);
    final accent = QuickWidgetType.pedometer.accentColor;

    return _MiniWidgetShell(
      key: const Key('quick_widget_pedometer'),
      accent: accent,
      icon: Icons.directions_walk_rounded,
      title: 'Yürüyüş & Adım',
      badge: st.isInstantSessionRunning
          ? 'Anlık'
          : (st.isContinuousMode ? 'Sürekli' : 'Başlat'),
      primaryValue: '${NumberFormat.decimalPattern('tr').format(today)} adım',
      secondaryText:
          'Hedef: %${(ratio * 100).round()} • ${st.selectedMode.shortLabel}',
      onTap: widget.onOpenPedometer,
    );
  }

  Widget _buildSobrietyMiniWidget(DateTime now, ThemeData theme) {
    final accent = QuickWidgetType.sobriety.accentColor;
    final active = _sobriety.isAnyActive;
    final todayTry = SobrietyState.formatTry(_sobriety.todayMoneySavedAt(now));
    final lifeStr =
        SobrietyState.formatLifeRegained(_sobriety.lifeRegainedAt(now));

    return _MiniWidgetShell(
      key: const Key('quick_widget_sobriety'),
      accent: accent,
      icon: Icons.smoke_free_rounded,
      title: 'Sigara & Alkol',
      badge: active ? 'Gün ${_sobriety.maxActiveDayNumber(now)}' : 'Başlat',
      primaryValue: active ? 'Bugün $todayTry' : 'Özgürlüğe Başla',
      secondaryText: active
          ? 'Ömür: +$lifeStr'
          : 'Ort: ${SobrietyState.formatTry(_sobriety.combinedMonthlySpendTry)}/ay',
      onTap: widget.onOpenSobriety,
    );
  }

  Widget _buildVitalsMiniWidget(ThemeData theme) {
    final accent = QuickWidgetType.vitals.accentColor;
    final bpStr = _latestBp?.formatted ?? '--/-- mmHg';
    final sugarStr = _latestSugar?.formatted ?? '-- mg/dL';

    return _MiniWidgetShell(
      key: const Key('quick_widget_vitals'),
      accent: accent,
      icon: Icons.monitor_heart_rounded,
      title: 'Şeker & Tansiyon',
      badge: '+ Hızlı',
      primaryValue: bpStr,
      secondaryText: 'Şeker: $sugarStr',
      onTap: widget.onOpenVitals,
      onBadgeTap: _openQuickVitalEntrySheet,
    );
  }

  Widget _buildAlarmsMiniWidget(ThemeData theme) {
    final accent = QuickWidgetType.alarms.accentColor;
    final next = _activeAlarms.isNotEmpty ? _activeAlarms.first : null;

    return _MiniWidgetShell(
      key: const Key('quick_widget_alarms'),
      accent: accent,
      icon: Icons.alarm_on_rounded,
      title: 'İlaç & Alarm',
      badge: '${_activeAlarms.length} Aktif',
      primaryValue: next != null ? next.formattedTime : 'Alarm Kur',
      secondaryText:
          next != null ? next.title : 'Su & ilaç hatırlatıcısı ekleyin',
      onTap: widget.onOpenAlarms,
    );
  }
}

class _MiniWidgetShell extends StatelessWidget {
  const _MiniWidgetShell({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.badge,
    required this.primaryValue,
    required this.secondaryText,
    required this.onTap,
    this.onBadgeTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String badge;
  final String primaryValue;
  final String secondaryText;
  final VoidCallback onTap;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.28)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: accent.withValues(alpha: 0.14),
                    child: Icon(icon, color: accent, size: 17),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onBadgeTap ?? onTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      primaryValue,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    secondaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
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
