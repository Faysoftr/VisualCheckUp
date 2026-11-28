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
import 'package:visualcheckup/features/widgets_hub/presentation/screens/widgets_manager_screen.dart';

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

  bool _hubVisible = true;
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
    LabsVitalsRepository.revisionNotifier.addListener(_refreshAll);
    MedicationReminderRepository.revisionNotifier.addListener(_refreshAll);
    QuickWidgetsPreferences.revisionNotifier.addListener(_refreshAll);
    _pedometer.ensureLoaded();
    _refreshAll();
    QuickWidgetsPreferences.bindWidgetDeepLinkHandler(_handleWidgetDeepLink);
  }

  @override
  void dispose() {
    _pedometer.removeListener(_onPedometerUpdated);
    SobrietyRepository.revisionNotifier.removeListener(_refreshAll);
    LabsVitalsRepository.revisionNotifier.removeListener(_refreshAll);
    MedicationReminderRepository.revisionNotifier.removeListener(_refreshAll);
    QuickWidgetsPreferences.revisionNotifier.removeListener(_refreshAll);
    super.dispose();
  }

  void _handleWidgetDeepLink(String target) {
    if (!mounted) return;
    switch (target) {
      case 'pedometer':
        widget.onOpenPedometer();
        break;
      case 'sobriety':
        widget.onOpenSobriety();
        break;
      case 'vitals':
        widget.onOpenVitals();
        break;
      case 'alarms':
        widget.onOpenAlarms();
        break;
    }
  }

  void _onPedometerUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshAll() async {
    final results = await Future.wait<dynamic>([
      QuickWidgetsPreferences.isHubVisible(),
      QuickWidgetsPreferences.loadEnabledWidgets(),
      _sobrietyRepo.loadState(),
      _vitalsRepo.loadBloodPressureReadings(),
      _vitalsRepo.loadBloodSugarReadings(),
      _medRepo.loadReminders(),
    ]);

    if (!mounted) return;
    final hubVisible = results[0] as bool;
    final enabled = results[1] as List<QuickWidgetType>;
    final sob = results[2] as SobrietyState;
    final bps = results[3] as List<BloodPressureReading>;
    final sugars = results[4] as List<BloodSugarReading>;
    final alarms = (results[5] as List<MedicationReminder>)
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
      _hubVisible = hubVisible;
      _enabled = enabled;
      _sobriety = sob;
      _latestBp = bps.isNotEmpty ? bps.first : null;
      _latestSugar = sugars.isNotEmpty ? sugars.first : null;
      _activeAlarms = alarms;
    });
  }

  Future<void> _closeEntireHub() async {
    await QuickWidgetsPreferences.setHubVisible(false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Hızlı Widget Paneli kapatıldı. Menü > Widget Merkezi’nden dilediğiniz zaman tekrar açabilirsiniz.',
        ),
        action: SnackBarAction(
          label: 'Geri Aç',
          onPressed: () => QuickWidgetsPreferences.setHubVisible(true),
        ),
      ),
    );
  }

  Future<void> _closeSingleCard(QuickWidgetType type) async {
    await QuickWidgetsPreferences.closeSingleWidget(type);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.title} gizlendi.'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            final current = await QuickWidgetsPreferences.loadEnabledWidgets();
            if (!current.contains(type)) {
              current.add(type);
              await QuickWidgetsPreferences.saveEnabledWidgets(current);
            }
          },
        ),
      ),
    );
  }

  Future<void> _pinNativeWidgetWithFeedback(
    BuildContext ctx,
    String widgetType,
    String label,
  ) async {
    final pinned = await QuickWidgetsPreferences.requestPinNativeHomeWidget(
      widgetType: widgetType,
    );
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          pinned
              ? '📱 "$label" Android ana ekranına gönderildi! Açılan sistem penceresinden onaylayın.'
              : 'Telefonunuzun ana ekranına basılı tutup Widget’lar > VisualCheckUp altından "$label" widget’ını ekleyebilirsiniz.',
        ),
      ),
    );
  }

  Future<void> _openCustomizeSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        var working = List<QuickWidgetType>.from(_enabled);
        var workingHubVisible = _hubVisible;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
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
                            'Android & Ana Sayfa Widget’ları',
                            style:
                                Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const WidgetsManagerScreen(),
                              ),
                            );
                          },
                          child: const Text('Tam Ekran Aç'),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      key: const Key('sheet_hub_visibility_switch'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Uygulama Ana Sayfasında Widget Panelini Göster',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: const Text(
                        'Kapatırsanız uygulama içindeki widget alanı tamamen gizlenir.',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      value: workingHubVisible,
                      onChanged: (v) {
                        setModalState(() => workingHubVisible = v);
                      },
                    ),
                    const Divider(height: 12),
                    Text(
                      'Tek tıkla sağdaki telefon simgesine basarak istediğiniz widget’ı doğrudan Android telefonunuzun ana ekranına ekleyebilirsiniz:',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (final type in QuickWidgetType.values)
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
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
                                    if (!working.contains(type)) {
                                      working.add(type);
                                    }
                                  } else {
                                    working.remove(type);
                                  }
                                });
                              },
                            ),
                          ),
                          FilledButton.tonalIcon(
                            key: Key('pin_widget_${type.name}_btn'),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onPressed: () => _pinNativeWidgetWithFeedback(
                              ctx,
                              type.name,
                              type.title,
                            ),
                            icon: const Icon(
                              Icons.add_to_home_screen_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Android',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('pin_native_home_widget_btn'),
                        onPressed: () => _pinNativeWidgetWithFeedback(
                          ctx,
                          'all',
                          'VisualCheckUp • Tümü Bir Arada',
                        ),
                        icon: const Icon(Icons.android_rounded),
                        label: const Text(
                          'Tümü Bir Arada Widget’ı Android’e Ekle',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('save_quick_widgets_btn'),
                        onPressed: () async {
                          await QuickWidgetsPreferences.setHubVisible(
                            workingHubVisible,
                          );
                          await QuickWidgetsPreferences.saveEnabledWidgets(
                            working,
                          );
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Widget Düzenini Kaydet'),
                      ),
                    ),
                  ],
                ),
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

    if (!_hubVisible || _enabled.isEmpty) {
      return Align(
        alignment: Alignment.centerRight,
        child: ActionChip(
          key: const Key('reopen_quick_widgets_hub_btn'),
          visualDensity: VisualDensity.compact,
          avatar: Icon(
            Icons.widgets_outlined,
            size: 15,
            color: colorScheme.primary,
          ),
          label: const Text(
            '+ Hızlı Widget’ları Göster',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
          onPressed: () async {
            await QuickWidgetsPreferences.setHubVisible(true);
            if (_enabled.isEmpty) {
              await QuickWidgetsPreferences.saveEnabledWidgets(
                QuickWidgetsPreferences.defaultEnabled,
              );
            }
          },
        ),
      );
    }

    final now = DateTime.now();

    return Column(
      key: const Key('health_quick_widgets_hub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.widgets_outlined, size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Hızlı Takip Widget’larım',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('customize_quick_widgets_btn'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              onPressed: _openCustomizeSheet,
              icon: const Icon(Icons.add_to_home_screen_rounded, size: 15),
              label: const Text(
                'Android / Düzenle',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              key: const Key('close_quick_widgets_hub_btn'),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              tooltip: 'Widget Panelini Kapat',
              onPressed: _closeEntireHub,
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_enabled.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              dense: true,
              onTap: _openCustomizeSheet,
              leading: const Icon(Icons.widgets_rounded),
              title: const Text('Tüm kartlar gizlendi'),
              subtitle: const Text(
                'Widget eklemek için dokunun veya sağ üstteki ✕ ile paneli tamamen kapatın.',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _closeEntireHub,
              ),
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
              mainAxisExtent: 144,
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
      closeKey: const Key('close_widget_pedometer_btn'),
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
      onClose: () => _closeSingleCard(QuickWidgetType.pedometer),
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
      closeKey: const Key('close_widget_sobriety_btn'),
      accent: accent,
      icon: Icons.smoke_free_rounded,
      title: 'Sigara & Alkol',
      badge: active ? 'Gün ${_sobriety.maxActiveDayNumber(now)}' : 'Başlat',
      primaryValue: active ? 'Bugün $todayTry' : 'Özgürlüğe Başla',
      secondaryText: active
          ? 'Ömür: +$lifeStr'
          : 'Ort: ${SobrietyState.formatTry(_sobriety.combinedMonthlySpendTry)}/ay',
      onTap: widget.onOpenSobriety,
      onClose: () => _closeSingleCard(QuickWidgetType.sobriety),
    );
  }

  Widget _buildVitalsMiniWidget(ThemeData theme) {
    final accent = QuickWidgetType.vitals.accentColor;
    final bpStr = _latestBp?.formatted ?? '--/-- mmHg';
    final sugarStr = _latestSugar?.formatted ?? '-- mg/dL';

    return _MiniWidgetShell(
      key: const Key('quick_widget_vitals'),
      closeKey: const Key('close_widget_vitals_btn'),
      accent: accent,
      icon: Icons.monitor_heart_rounded,
      title: 'Şeker & Tansiyon',
      badge: '+ Hızlı',
      primaryValue: bpStr,
      secondaryText: 'Şeker: $sugarStr',
      onTap: widget.onOpenVitals,
      onBadgeTap: _openQuickVitalEntrySheet,
      onClose: () => _closeSingleCard(QuickWidgetType.vitals),
    );
  }

  Widget _buildAlarmsMiniWidget(ThemeData theme) {
    final accent = QuickWidgetType.alarms.accentColor;
    final next = _activeAlarms.isNotEmpty ? _activeAlarms.first : null;

    return _MiniWidgetShell(
      key: const Key('quick_widget_alarms'),
      closeKey: const Key('close_widget_alarms_btn'),
      accent: accent,
      icon: Icons.alarm_on_rounded,
      title: 'İlaç & Alarm',
      badge: '${_activeAlarms.length} Aktif',
      primaryValue: next != null ? next.formattedTime : 'Alarm Kur',
      secondaryText:
          next != null ? next.title : 'Su & ilaç hatırlatıcısı ekleyin',
      onTap: widget.onOpenAlarms,
      onClose: () => _closeSingleCard(QuickWidgetType.alarms),
    );
  }
}

class _MiniWidgetShell extends StatelessWidget {
  const _MiniWidgetShell({
    super.key,
    required this.closeKey,
    required this.accent,
    required this.icon,
    required this.title,
    required this.badge,
    required this.primaryValue,
    required this.secondaryText,
    required this.onTap,
    required this.onClose,
    this.onBadgeTap,
  });

  final Key closeKey;
  final Color accent;
  final IconData icon;
  final String title;
  final String badge;
  final String primaryValue;
  final String secondaryText;
  final VoidCallback onTap;
  final VoidCallback onClose;
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
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: accent.withValues(alpha: 0.14),
                    child: Icon(icon, color: accent, size: 16),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onBadgeTap ?? onTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    key: closeKey,
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
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
