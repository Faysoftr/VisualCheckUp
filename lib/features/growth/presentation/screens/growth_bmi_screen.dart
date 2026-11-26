import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/growth/data/growth_calculator.dart';
import 'package:visualcheckup/features/growth/data/growth_repository.dart';
import 'package:visualcheckup/features/growth/domain/growth_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/widgets/trend_sparkline_card.dart';

class GrowthBmiScreen extends StatefulWidget {
  const GrowthBmiScreen({
    super.key,
    this.repository,
    this.initialTabIndex = 0,
  });

  final GrowthRepository? repository;
  final int initialTabIndex;

  @override
  State<GrowthBmiScreen> createState() => _GrowthBmiScreenState();
}

class _GrowthBmiScreenState extends State<GrowthBmiScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GrowthRepository _repo;

  List<AdultBodyMeasurement> _adultLogs = const [];
  List<ChildProfile> _children = const [];
  List<ChildGrowthMeasurement> _childLogs = const [];
  String? _selectedChildId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? GrowthRepository();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    )..addListener(() {
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
    final adult = await _repo.loadAdultMeasurements();
    final children = await _repo.loadChildren();
    final allChildLogs = await _repo.loadAllChildMeasurements();
    if (!mounted) return;
    setState(() {
      _adultLogs = adult;
      _children = children;
      _childLogs = allChildLogs;
      if (_selectedChildId == null ||
          !children.any((c) => c.id == _selectedChildId)) {
        _selectedChildId = children.isNotEmpty ? children.first.id : null;
      }
      _loading = false;
    });
  }

  ChildProfile? get _selectedChild {
    if (_selectedChildId == null) return null;
    for (final c in _children) {
      if (c.id == _selectedChildId) return c;
    }
    return null;
  }

  Future<void> _openAddAdultMeasurement() async {
    final last = _adultLogs.isNotEmpty ? _adultLogs.first : null;
    final created = await showModalBottomSheet<AdultBodyMeasurement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AddBodyMeasurementSheet(
        title: 'Boy & Kilo Ölçümü Ekle (Ben)',
        initialHeightCm: last?.heightCm,
        initialWeightKg: last?.weightKg,
        onBuild: (date, h, w, note) => AdultBodyMeasurement(
          id: 'adult_${DateTime.now().microsecondsSinceEpoch}',
          recordedAt: date,
          heightCm: h,
          weightKg: w,
          note: note,
        ),
      ),
    );
    if (created != null) {
      await _repo.saveAdultMeasurement(created);
      await _load();
    }
  }

  Future<void> _openAddChild() async {
    final created = await showModalBottomSheet<ChildProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _AddChildSheet(),
    );
    if (created != null) {
      await _repo.saveChild(created);
      setState(() => _selectedChildId = created.id);
      await _load();
    }
  }

  Future<void> _openAddChildMeasurement(ChildProfile child) async {
    final logs = _childLogs.where((m) => m.childId == child.id).toList();
    final last = logs.isNotEmpty ? logs.first : null;
    final created = await showModalBottomSheet<ChildGrowthMeasurement>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AddBodyMeasurementSheet<ChildGrowthMeasurement>(
        title: '${child.name} • Boy & Kilo Ölçümü',
        initialHeightCm: last?.heightCm,
        initialWeightKg: last?.weightKg,
        onBuild: (date, h, w, note) => ChildGrowthMeasurement(
          id: 'cg_${DateTime.now().microsecondsSinceEpoch}',
          childId: child.id,
          recordedAt: date,
          heightCm: h,
          weightKg: w,
          note: note,
        ),
      ),
    );
    if (created != null) {
      await _repo.saveChildMeasurement(created);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onAdultTab = _tabController.index == 0;
    final selectedChild = _selectedChild;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boy, Kilo & VKİ • Çocuklarım'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.monitor_weight_outlined, size: 18),
              text: 'Ben (VKİ)',
            ),
            Tab(
              icon: Icon(Icons.child_care_outlined, size: 18),
              text: 'Çocuklarım',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdultTab
            ? _openAddAdultMeasurement
            : (selectedChild != null
                ? () => _openAddChildMeasurement(selectedChild)
                : _openAddChild),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          onAdultTab
              ? 'Boy & Kilo Ekle'
              : (selectedChild != null ? 'Ölçüm Ekle' : 'Çocuk Ekle'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAdultTab(context),
                _buildChildrenTab(context),
              ],
            ),
    );
  }

  Widget _buildAdultTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    if (_adultLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.monitor_weight_outlined,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz boy & kilo kaydı yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Boy ve kilonuzu girerek Vücut Kitle İndeksinizi (VKİ), ideal kilo aralığınızı ve zaman içi değişiminizi takip edin.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _openAddAdultMeasurement,
                icon: const Icon(Icons.add_rounded),
                label: const Text('İlk Boy & Kilo Ölçümünü Ekle'),
              ),
            ],
          ),
        ),
      );
    }

    final latest = _adultLogs.first;
    final bmi = latest.bmi;
    final cat = GrowthCalculator.classifyAdultBmi(bmi);
    final ideal = GrowthCalculator.idealAdultWeightRange(latest.heightCm);
    final chronological = [..._adultLogs]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      children: [
        // BMI Hero Gauge Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Vücut Kitle İndeksi (VKİ)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        cat.label,
                        style: TextStyle(
                          color: cat.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cat.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'kg/m²  •  ${latest.heightCm.toStringAsFixed(0)} cm / ${latest.weightKg.toStringAsFixed(1)} kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _BmiScaleBar(bmi: bmi),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'İdeal Kilo Aralığınız (${latest.heightCm.toStringAsFixed(0)} cm): '
                    '${ideal.minKg.toStringAsFixed(1)} – ${ideal.maxKg.toStringAsFixed(1)} kg',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.advice,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (chronological.length >= 2) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kilo Değişim Grafiği (kg)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TrendLineChart(
                    points: chronological
                        .map(
                          (e) => TrendChartPoint(
                            date: e.recordedAt,
                            value: e.weightKg,
                          ),
                        )
                        .toList(),
                    primaryColor: AppTheme.primaryTeal,
                    normalMin: ideal.minKg,
                    normalMax: ideal.maxKg,
                    height: 112,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(
          'Ölçüm Geçmişi (${_adultLogs.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in _adultLogs)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: GrowthCalculator.classifyAdultBmi(item.bmi)
                    .color
                    .withValues(alpha: 0.14),
                child: Text(
                  item.bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: GrowthCalculator.classifyAdultBmi(item.bmi).color,
                  ),
                ),
              ),
              title: Text(
                '${item.weightKg.toStringAsFixed(1)} kg • ${item.heightCm.toStringAsFixed(0)} cm',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${df.format(item.recordedAt)} • VKİ: ${item.bmi.toStringAsFixed(1)} (${GrowthCalculator.classifyAdultBmi(item.bmi).label})',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () async {
                  await _repo.deleteAdultMeasurement(item.id);
                  await _load();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChildrenTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    if (_children.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.child_care_outlined,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Çocuklarınız için büyüme takibi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Çocuğunuzu (ad, doğum tarihi, cinsiyet) ekleyin; boy, kilo ve yaşa göre VKİ değerlerini WHO (0–18 yaş) persentil skalasına göre otomatik hesaplayalım.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _openAddChild,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('İlk Çocuğu Ekle'),
              ),
            ],
          ),
        ),
      );
    }

    final child = _selectedChild ?? _children.first;
    final logs = _childLogs.where((m) => m.childId == child.id).toList();
    final latest = logs.isNotEmpty ? logs.first : null;
    final eval = latest != null
        ? GrowthCalculator.evaluateChild(child: child, measurement: latest)
        : null;
    final chronological = [...logs]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      children: [
        // Child selector chips + Add child button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in _children) ...[
                ChoiceChip(
                  avatar: Icon(
                    c.gender == ChildGender.girl
                        ? Icons.girl_rounded
                        : Icons.boy_rounded,
                    size: 18,
                  ),
                  label: Text('${c.name} (${c.formattedAgeAt(DateTime.now())})'),
                  selected: c.id == child.id,
                  onSelected: (_) => setState(() => _selectedChildId = c.id),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Çocuk Ekle'),
                onPressed: _openAddChild,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (eval == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${child.name} için henüz ölçüm eklenmedi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Boy ve kilo girerek WHO 0–18 yaş persentil skalasını hemen hesaplayın.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => _openAddChildMeasurement(child),
                    icon: const Icon(Icons.straighten_outlined),
                    label: const Text('İlk Ölçümü Ekle'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Pediatric Percentile Scale Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${child.name} • Büyüme Skalası (WHO)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text('${child.gender.label} • ${eval.ageLabel}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PercentileScaleRow(
                    title: 'Boy (Yaşa Göre Boy)',
                    result: eval.heightPercentile,
                  ),
                  const Divider(height: 22),
                  _PercentileScaleRow(
                    title: 'Kilo (Yaşa Göre Kilo)',
                    result: eval.weightPercentile,
                  ),
                  const Divider(height: 22),
                  _PercentileScaleRow(
                    title: 'Çocuk VKİ (Yaşa Göre BMI)',
                    result: eval.bmiPercentile,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      eval.summaryNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (chronological.length >= 2) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${child.name} • Boy Gelişim Eğrisi (cm)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TrendLineChart(
                      points: chronological
                          .map(
                            (e) => TrendChartPoint(
                              date: e.recordedAt,
                              value: e.heightCm,
                            ),
                          )
                          .toList(),
                      primaryColor: AppTheme.primaryTeal,
                      height: 108,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${child.name} Ölçüm Geçmişi (${logs.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await _repo.deleteChild(child.id);
                  await _load();
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: colorScheme.error,
                ),
                label: Text(
                  'Profili Sil',
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final m in logs)
            Card(
              child: ListTile(
                title: Text(
                  '${m.heightCm.toStringAsFixed(1)} cm • ${m.weightKg.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${df.format(m.recordedAt)} (${child.formattedAgeAt(m.recordedAt)}) • VKİ: ${m.bmi.toStringAsFixed(1)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () async {
                    await _repo.deleteChildMeasurement(m.id);
                    await _load();
                  },
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _BmiScaleBar extends StatelessWidget {
  const _BmiScaleBar({required this.bmi});

  final double bmi;

  @override
  Widget build(BuildContext context) {
    final normalized = ((bmi - 14.0) / (40.0 - 14.0)).clamp(0.0, 1.0);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final markerX =
                (constraints.maxWidth * normalized).clamp(8.0, constraints.maxWidth - 8.0);
            return SizedBox(
              height: 24,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: const [
                        Expanded(flex: 17, child: ColoredBox(color: Color(0xFF2B7BBA), child: SizedBox(height: 10))),
                        Expanded(flex: 25, child: ColoredBox(color: Color(0xFF1B8A5A), child: SizedBox(height: 10))),
                        Expanded(flex: 19, child: ColoredBox(color: Color(0xFFD9822B), child: SizedBox(height: 10))),
                        Expanded(flex: 39, child: ColoredBox(color: Color(0xFFC93B3B), child: SizedBox(height: 10))),
                      ],
                    ),
                  ),
                  Positioned(
                    left: markerX - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GrowthCalculator.classifyAdultBmi(bmi).color,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('18.5', style: TextStyle(fontSize: 10.5)),
            Text('25.0', style: TextStyle(fontSize: 10.5)),
            Text('30.0', style: TextStyle(fontSize: 10.5)),
            Text('40+', style: TextStyle(fontSize: 10.5)),
          ],
        ),
      ],
    );
  }
}

class _PercentileScaleRow extends StatelessWidget {
  const _PercentileScaleRow({
    required this.title,
    required this.result,
  });

  final String title;
  final PercentileResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${result.value.toStringAsFixed(1)} ${result.unit} (~P${result.estimatedPercentile})',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: result.band.color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${result.band.label}  •  Medyan (P50): ${result.p50.toStringAsFixed(1)} ${result.unit}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final x = (constraints.maxWidth * result.normalizedScalePosition)
                .clamp(8.0, constraints.maxWidth - 8.0);
            return SizedBox(
              height: 22,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: const [
                        Expanded(flex: 15, child: ColoredBox(color: Color(0xFFD9822B), child: SizedBox(height: 9))),
                        Expanded(flex: 70, child: ColoredBox(color: Color(0xFF1B8A5A), child: SizedBox(height: 9))),
                        Expanded(flex: 15, child: ColoredBox(color: Color(0xFFD9822B), child: SizedBox(height: 9))),
                      ],
                    ),
                  ),
                  Positioned(
                    left: x - 7,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: result.band.color,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('P3: ${result.p3.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10.5)),
            Text('P50: ${result.p50.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
            Text('P97: ${result.p97.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10.5)),
          ],
        ),
      ],
    );
  }
}

class _AddBodyMeasurementSheet<T> extends StatefulWidget {
  const _AddBodyMeasurementSheet({
    required this.title,
    required this.onBuild,
    this.initialHeightCm,
    this.initialWeightKg,
  });

  final String title;
  final double? initialHeightCm;
  final double? initialWeightKg;
  final T Function(DateTime date, double heightCm, double weightKg, String? note)
      onBuild;

  @override
  State<_AddBodyMeasurementSheet<T>> createState() =>
      _AddBodyMeasurementSheetState<T>();
}

class _AddBodyMeasurementSheetState<T>
    extends State<_AddBodyMeasurementSheet<T>> {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.initialHeightCm?.toStringAsFixed(1) ?? '',
    );
    _weightController = TextEditingController(
      text: widget.initialWeightKg?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final h = double.tryParse(_heightController.text.trim().replaceAll(',', '.'));
    final w = double.tryParse(_weightController.text.trim().replaceAll(',', '.'));
    if (h == null || w == null || h < 30 || h > 250 || w < 1.5 || w > 300) {
      return;
    }
    Navigator.of(context).pop(widget.onBuild(_date, h, w, null));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Boy (cm)',
                    hintText: 'Örn: 172',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    hintText: 'Örn: 68.5',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2005),
                lastDate: DateTime.now(),
              );
              if (picked != null && mounted) {
                setState(() => _date = picked);
              }
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text('Ölçüm Tarihi: ${df.format(_date)}'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Kaydet ve Hesapla'),
          ),
        ],
      ),
    );
  }
}

class _AddChildSheet extends StatefulWidget {
  const _AddChildSheet();

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  final TextEditingController _nameController = TextEditingController();
  ChildGender _gender = ChildGender.girl;
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 4));

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      ChildProfile(
        id: 'child_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        birthDate: _birthDate,
        gender: _gender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM.yyyy');
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Çocuk Profili Ekle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Çocuğun Adı',
              hintText: 'Örn: Zeynep, Ali...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<ChildGender>(
            segments: const [
              ButtonSegment(
                value: ChildGender.girl,
                icon: Icon(Icons.girl_rounded),
                label: Text('Kız'),
              ),
              ButtonSegment(
                value: ChildGender.boy,
                icon: Icon(Icons.boy_rounded),
                label: Text('Erkek'),
              ),
            ],
            selected: {_gender},
            onSelectionChanged: (s) => setState(() => _gender = s.first),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _birthDate,
                firstDate: DateTime(2006),
                lastDate: DateTime.now(),
              );
              if (picked != null && mounted) {
                setState(() => _birthDate = picked);
              }
            },
            icon: const Icon(Icons.cake_outlined, size: 16),
            label: Text('Doğum Tarihi: ${df.format(_birthDate)}'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Çocuğu Kaydet'),
          ),
        ],
      ),
    );
  }
}
