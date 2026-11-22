import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/widgets/trend_sparkline_card.dart';

class VitalsTrackerScreen extends StatefulWidget {
  const VitalsTrackerScreen({
    super.key,
    required this.repository,
    this.initialTabIndex = 0,
  });

  final LabsVitalsRepository repository;
  final int initialTabIndex;

  @override
  State<VitalsTrackerScreen> createState() => _VitalsTrackerScreenState();
}

class _VitalsTrackerScreenState extends State<VitalsTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<BloodPressureReading> _bpReadings = const [];
  List<BloodSugarReading> _sugarReadings = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final bp = await widget.repository.loadBloodPressureReadings();
    final sugar = await widget.repository.loadBloodSugarReadings();
    if (!mounted) return;
    setState(() {
      _bpReadings = bp;
      _sugarReadings = sugar;
      _loading = false;
    });
  }

  Future<void> _addBloodPressure() async {
    final created = await showModalBottomSheet<BloodPressureReading>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _AddBloodPressureSheet(),
    );
    if (created != null) {
      await widget.repository.saveBloodPressure(created);
      await _load();
    }
  }

  Future<void> _addBloodSugar() async {
    final created = await showModalBottomSheet<BloodSugarReading>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _AddBloodSugarSheet(),
    );
    if (created != null) {
      await widget.repository.saveBloodSugar(created);
      await _load();
    }
  }

  Future<void> _copyDoctorSummary() async {
    if (_bpReadings.isEmpty && _sugarReadings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Özet oluşturmak için önce tansiyon veya şeker ekleyin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final text = LabReportAnalyzer.formatVitalsForDoctor(
      bpReadings: _bpReadings,
      sugarReadings: _sugarReadings,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tansiyon & şeker takip özeti panoya kopyalandı.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onBpTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tansiyon & Şeker Takibi'),
        actions: [
          IconButton(
            onPressed: _copyDoctorSummary,
            tooltip: 'Doktora Göster Özeti Kopyala',
            icon: const Icon(Icons.assignment_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite_outline, size: 18), text: 'Tansiyon'),
            Tab(icon: Icon(Icons.water_drop_outlined, size: 18), text: 'Kan Şekeri'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onBpTab ? _addBloodPressure : _addBloodSugar,
        icon: const Icon(Icons.add_rounded),
        label: Text(onBpTab ? 'Tansiyon Ekle' : 'Şeker Ekle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBpTab(context),
                _buildSugarTab(context),
              ],
            ),
    );
  }

  Widget _buildBpTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_bpReadings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.favorite_outline,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Henüz tansiyon ölçümü yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Büyük/küçük tansiyon ve nabız değerlerinizi tarihli kaydederek değişim grafiğini izleyin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _addBloodPressure,
                icon: const Icon(Icons.add_rounded),
                label: const Text('İlk Tansiyon Ölçümünü Ekle'),
              ),
            ],
          ),
        ),
      );
    }

    final latest = _bpReadings.first;
    final avgSys =
        _bpReadings.map((e) => e.systolic).reduce((a, b) => a + b) /
            _bpReadings.length;
    final avgDia =
        _bpReadings.map((e) => e.diastolic).reduce((a, b) => a + b) /
            _bpReadings.length;
    final chronological = [..._bpReadings]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      latest.formatted,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: latest.category.color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: latest.category.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        latest.category.label,
                        style: TextStyle(
                          color: latest.category.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Ortalama (${_bpReadings.length} ölçüm): ${avgSys.round()}/${avgDia.round()} mmHg${latest.pulse != null ? ' • Son nabız: ${latest.pulse} bpm' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  latest.category.guidance,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.38),
                ),
                const SizedBox(height: 14),
                TrendLineChart(
                  points: chronological
                      .map(
                        (e) => TrendChartPoint(
                          date: e.recordedAt,
                          value: e.systolic.toDouble(),
                          secondaryValue: e.diastolic.toDouble(),
                        ),
                      )
                      .toList(),
                  primaryColor: AppTheme.primaryTeal,
                  secondaryColor: const Color(0xFF5D54A4),
                  normalMin: 60,
                  normalMax: 120,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tarihli Tansiyon Kayıtları',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in _bpReadings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.category.color.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: item.category.color,
                    size: 18,
                  ),
                ),
                title: Text(
                  '${item.formatted}${item.pulse != null ? ' • Nabız ${item.pulse}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${df.format(item.recordedAt)} • ${item.category.label}${item.note != null ? '\n${item.note}' : ''}',
                ),
                trailing: IconButton(
                  tooltip: 'Sil',
                  onPressed: () async {
                    await widget.repository.deleteBloodPressure(item.id);
                    await _load();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSugarTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_sugarReadings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Henüz kan şekeri ölçümü yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Açlık, tokluk (2. saat) veya rastgele şeker ölçümlerinizi tarihli kaydederek eğilimi takip edin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _addBloodSugar,
                icon: const Icon(Icons.add_rounded),
                label: const Text('İlk Şeker Ölçümünü Ekle'),
              ),
            ],
          ),
        ),
      );
    }

    final latest = _sugarReadings.first;
    final avg =
        _sugarReadings.map((e) => e.valueMgDl).reduce((a, b) => a + b) /
            _sugarReadings.length;
    final chronological = [..._sugarReadings]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final df = DateFormat('dd.MM.yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      latest.formatted,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: latest.category.color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: latest.category.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        latest.category.label,
                        style: TextStyle(
                          color: latest.category.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${latest.measurementType.label} • Ortalama (${_sugarReadings.length} ölçüm): ${avg.round()} mg/dL',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  latest.category.guidance,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.38),
                ),
                const SizedBox(height: 14),
                TrendLineChart(
                  points: chronological
                      .map(
                        (e) => TrendChartPoint(
                          date: e.recordedAt,
                          value: e.valueMgDl,
                        ),
                      )
                      .toList(),
                  primaryColor: const Color(0xFFD9822B),
                  normalMin: 70,
                  normalMax: latest.measurementType == SugarMeasurementType.fasting
                      ? 100
                      : 140,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tarihli Şeker Kayıtları',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in _sugarReadings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.category.color.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: item.category.color,
                    size: 18,
                  ),
                ),
                title: Text(
                  '${item.formatted} • ${item.measurementType.label}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${df.format(item.recordedAt)} • ${item.category.label}${item.note != null ? '\n${item.note}' : ''}',
                ),
                trailing: IconButton(
                  tooltip: 'Sil',
                  onPressed: () async {
                    await widget.repository.deleteBloodSugar(item.id);
                    await _load();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddBloodPressureSheet extends StatefulWidget {
  const _AddBloodPressureSheet();

  @override
  State<_AddBloodPressureSheet> createState() => _AddBloodPressureSheetState();
}

class _AddBloodPressureSheetState extends State<_AddBloodPressureSheet> {
  final TextEditingController _sysController = TextEditingController();
  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _recordedAt = DateTime.now();

  @override
  void dispose() {
    _sysController.dispose();
    _diaController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _recordedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _recordedAt.hour,
          _recordedAt.minute,
        );
      });
    }
  }

  void _save() {
    final sys = int.tryParse(_sysController.text.trim());
    final dia = int.tryParse(_diaController.text.trim());
    final pulse = int.tryParse(_pulseController.text.trim());
    if (sys == null || dia == null || sys < 50 || sys > 280 || dia < 30 || dia > 180) {
      return;
    }

    Navigator.of(context).pop(
      BloodPressureReading(
        id: 'bp_${DateTime.now().microsecondsSinceEpoch}',
        recordedAt: _recordedAt,
        systolic: sys,
        diastolic: dia,
        pulse: pulse,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Yeni Tansiyon Ölçümü',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 15),
                    label: Text(df.format(_recordedAt)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Büyük (Sistolik)',
                        hintText: '120',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _diaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Küçük (Diyastolik)',
                        hintText: '80',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pulseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nabız (bpm — Opsiyonel)',
                  hintText: '72',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (Opsiyonel — ör. sabah dinlenmiş)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Tansiyonu Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBloodSugarSheet extends StatefulWidget {
  const _AddBloodSugarSheet();

  @override
  State<_AddBloodSugarSheet> createState() => _AddBloodSugarSheetState();
}

class _AddBloodSugarSheetState extends State<_AddBloodSugarSheet> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  SugarMeasurementType _type = SugarMeasurementType.fasting;
  DateTime _recordedAt = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _recordedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _recordedAt.hour,
          _recordedAt.minute,
        );
      });
    }
  }

  void _save() {
    final val = double.tryParse(_valueController.text.trim().replaceAll(',', '.'));
    if (val == null || val < 20 || val > 700) return;

    Navigator.of(context).pop(
      BloodSugarReading(
        id: 'sugar_${DateTime.now().microsecondsSinceEpoch}',
        recordedAt: _recordedAt,
        valueMgDl: val,
        measurementType: _type,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Yeni Kan Şekeri Ölçümü',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 15),
                    label: Text(df.format(_recordedAt)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<SugarMeasurementType>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: SugarMeasurementType.fasting,
                    label: Text('Açlık'),
                  ),
                  ButtonSegment(
                    value: SugarMeasurementType.postMeal,
                    label: Text('Tokluk'),
                  ),
                  ButtonSegment(
                    value: SugarMeasurementType.random,
                    label: Text('Rastgele'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (sel) {
                  if (sel.isNotEmpty) setState(() => _type = sel.first);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Kan Şekeri (mg/dL)',
                  hintText: '95',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (Opsiyonel — ör. kahvaltıdan 2 saat sonra)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Kan Şekerini Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
