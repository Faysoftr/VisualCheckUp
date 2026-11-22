import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/widgets/trend_sparkline_card.dart';

class LabReportsScreen extends StatefulWidget {
  const LabReportsScreen({
    super.key,
    required this.repository,
  });

  final LabsVitalsRepository repository;

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  List<LabReportRecord> _reports = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reports = await widget.repository.loadLabReports();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  Future<void> _openAddReport() async {
    final created = await showModalBottomSheet<LabReportRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _AddLabReportSheet(),
    );
    if (created != null) {
      await widget.repository.saveLabReport(created);
      await _load();
      if (mounted) {
        await _openReportDetail(created);
      }
    }
  }

  Future<void> _deleteReport(LabReportRecord report) async {
    await widget.repository.deleteLabReport(report.id);
    await _load();
  }

  Future<void> _openReportDetail(LabReportRecord report) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final df = DateFormat('dd.MM.yyyy');
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.biotech_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${df.format(report.reportDate)} • ${report.source.label}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                color: report.hasCritical
                    ? const Color(0xFFFFF4F4)
                    : colorScheme.primaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.overallSummary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Danışılabilecek Bölüm: ${report.suggestedSpecialty}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Parametre Değerlendirmesi (${report.items.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in report.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.status.color
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.status.label,
                                  style: TextStyle(
                                    color: item.status.color,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                item.formattedValue,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: item.status.color,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Ref: ${item.referenceRangeText}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.note,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                MedicalDisclaimer.shortBanner,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: LabReportAnalyzer.formatReportForDoctor(report),
                    ),
                  );
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Tahlil özeti panoya kopyalandı.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Doktora Göster • Özeti Kopyala'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trends = LabReportAnalyzer.computeParameterTrends(_reports);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tahlil & Hastane Raporları'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.description_outlined, size: 18),
                text: 'Raporlarım',
              ),
              Tab(
                icon: Icon(Icons.show_chart_rounded, size: 18),
                text: 'Değişim Takibi',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddReport,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Rapor / Kan Testi Ekle'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildReportsTab(context),
                  _buildTrendsTab(context, trends),
                ],
              ),
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_reports.isEmpty) {
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
                  Icons.biotech_outlined,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz kayıtlı kan tahlili yok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'e-Nabız veya hastane rapor metnini yapıştırarak ya da değerleri manuel girerek tarihli değerlendirme ve değişim takibi başlatın.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _openAddReport,
                icon: const Icon(Icons.add_rounded),
                label: const Text('İlk Tahlil Raporunu Ekle'),
              ),
            ],
          ),
        ),
      );
    }

    final df = DateFormat('dd.MM.yyyy');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      itemCount: _reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final report = _reports[index];
        final statusColor = report.hasCritical
            ? const Color(0xFFC93B3B)
            : report.abnormalCount > 0
                ? const Color(0xFFD9822B)
                : const Color(0xFF1B8A5A);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.14),
              child: Icon(
                report.abnormalCount == 0
                    ? Icons.check_circle_outline
                    : Icons.analytics_outlined,
                color: statusColor,
              ),
            ),
            title: Text(
              report.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  '${df.format(report.reportDate)} • ${report.items.length} parametre • ${report.abnormalCount == 0 ? 'Tümü normal aralıkta' : '${report.abnormalCount} referans dışı'}',
                ),
                const SizedBox(height: 4),
                Text(
                  report.overallSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: 'Raporu Sil',
              onPressed: () => _deleteReport(report),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
            onTap: () => _openReportDetail(report),
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab(
    BuildContext context,
    List<LabParameterTrend> trends,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (trends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            'Farklı tarihlerde kan testi kaydettiğinizde Hemoglobin, Ferritin, Glukoz, TSH, Vitamin D gibi değerlerin zaman içi değişim grafikleri burada oluşur.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      itemCount: trends.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trend = trends[index];
        final latest = trend.latest;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trend.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: latest.status.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${latest.value.toStringAsFixed(latest.value == latest.value.roundToDouble() ? 0 : 1)} ${trend.unit}',
                        style: TextStyle(
                          color: latest.status.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${trend.points.length} kayıt • Değişim: ${trend.deltaSummary} • Son durum: ${latest.status.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TrendLineChart(
                  points: trend.points
                      .map((p) => TrendChartPoint(date: p.date, value: p.value))
                      .toList(),
                  primaryColor: AppTheme.primaryTeal,
                  normalMin: trend.refMin,
                  normalMax: trend.refMax,
                  height: 112,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddLabReportSheet extends StatefulWidget {
  const _AddLabReportSheet();

  @override
  State<_AddLabReportSheet> createState() => _AddLabReportSheetState();
}

class _AddLabReportSheetState extends State<_AddLabReportSheet> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Kan Tahlili Sonucu');
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  DateTime _reportDate = DateTime.now();
  LabReportSource _source = LabReportSource.manual;
  LabParameterSpec _selectedSpec = LabReportAnalyzer.catalog.first;
  final Map<String, LabTestItem> _itemsByCode = <String, LabTestItem>{};
  String? _parseFeedback;
  String? _attachedPhotoName;

  @override
  void dispose() {
    _titleController.dispose();
    _pasteController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _reportDate = picked);
    }
  }

  void _parsePastedText() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;

    final parsed = LabReportAnalyzer.parseReportText(text);
    setState(() {
      if (parsed.detectedDate != null) {
        _reportDate = parsed.detectedDate!;
      }
      for (final item in parsed.items) {
        _itemsByCode[item.code] = item;
      }
      _source = LabReportSource.pastedText;
      _parseFeedback = parsed.items.isEmpty
          ? 'Tanınan parametre bulunamadı. Örn: "Hemoglobin: 11.4" veya "Glukoz 108" şeklinde girin.'
          : '${parsed.items.length} tahlil parametresi otomatik okundu ve değerlendirildi.';
    });
  }

  Future<void> _attachPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() {
          _attachedPhotoName = picked.name;
          _source = LabReportSource.photoScan;
          _parseFeedback =
              'Rapor görseli eklendi (${picked.name}). Bulut AI kapalıyken aşağıdaki metin veya hızlı girişle değerleri doğrulayıp kaydedebilirsiniz.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _parseFeedback = 'Galeri erişimi başlatılamadı; metin yapıştırma veya manuel girişi kullanabilirsiniz.';
      });
    }
  }

  void _addManualItem() {
    final raw = _valueController.text.trim().replaceAll(',', '.');
    final val = double.tryParse(raw);
    if (val == null || val < 0) return;

    final evaluated = LabReportAnalyzer.evaluateKnownParameter(
      spec: _selectedSpec,
      value: val,
    );
    setState(() {
      _itemsByCode[evaluated.code] = evaluated;
      _valueController.clear();
    });
  }

  void _save() {
    if (_itemsByCode.isEmpty) return;
    final report = LabReportAnalyzer.buildReport(
      title: _titleController.text,
      reportDate: _reportDate,
      source: _source,
      items: _itemsByCode.values.toList(),
      rawReportText: _pasteController.text.trim().isEmpty
          ? null
          : _pasteController.text.trim(),
    );
    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              Text(
                'Hastane Raporu / Kan Testi Ekle',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Rapor Başlığı',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(df.format(_reportDate)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '1. e-Nabız / Hastane Rapor Metnini Oku',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _pasteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Örn:\nHemoglobin: 11.2 g/dL\nFerritin: 14 ng/mL\nGlukoz: 118 mg/dL\nTSH: 5.1 mIU/L',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _parsePastedText,
                    icon: const Icon(Icons.document_scanner_outlined, size: 18),
                    label: const Text('Metni Oku ve Ayrıştır'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _attachPhoto,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(
                      _attachedPhotoName == null
                          ? 'Rapor Fotoğrafı Ekle'
                          : 'Fotoğraf Eklendi',
                    ),
                  ),
                ],
              ),
              if (_parseFeedback != null) ...[
                const SizedBox(height: 8),
                Text(
                  _parseFeedback!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '2. veya Tek Tek Kan Testi Değeri Ekle',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<LabParameterSpec>(
                initialValue: _selectedSpec,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tahlil Parametresi',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: LabReportAnalyzer.catalog
                    .map(
                      (spec) => DropdownMenuItem(
                        value: spec,
                        child: Text('${spec.name} (${spec.unit})'),
                      ),
                    )
                    .toList(),
                onChanged: (spec) {
                  if (spec != null) {
                    setState(() => _selectedSpec = spec);
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Değer (${_selectedSpec.unit})',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: _addManualItem,
                    child: const Text('+ Ekle'),
                  ),
                ],
              ),
              if (_itemsByCode.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Okunan Değerler (${_itemsByCode.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _itemsByCode.values.map((item) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: item.status.color,
                        radius: 6,
                      ),
                      label: Text(
                        '${item.code}: ${item.formattedValue} (${item.status.label})',
                      ),
                      onDeleted: () =>
                          setState(() => _itemsByCode.remove(item.code)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _itemsByCode.isEmpty ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Değerlendir ve Tarihli Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
