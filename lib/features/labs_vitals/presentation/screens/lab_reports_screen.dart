import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/labs_vitals/data/gemini_lab_report_extractor.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_pdf_generator.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/widgets/trend_sparkline_card.dart';

class LabReportsScreen extends StatefulWidget {
  const LabReportsScreen({
    super.key,
    required this.repository,
    this.documentPicker = const DeviceLabDocumentPicker(),
    this.aiExtractor,
  });

  final LabsVitalsRepository repository;
  final LabDocumentPicker documentPicker;
  final LabDocumentAiExtractor? aiExtractor;

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  List<LabReportRecord> _reports = const [];
  bool _loading = true;
  bool _showComparisonTable = true;
  bool _onlyAbnormalInTable = false;

  LabDocumentAiExtractor get _effectiveAiExtractor =>
      widget.aiExtractor ?? GeminiLabReportExtractor();

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
      builder: (_) => _AddLabReportSheet(
        documentPicker: widget.documentPicker,
        aiExtractor: _effectiveAiExtractor,
      ),
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
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.96,
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
              if (report.hasAttachment) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      report.attachmentMimeType == 'application/pdf'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    label: Text(report.attachmentFileName!),
                  ),
                ),
              ],
              const SizedBox(height: 12),
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
              if (report.hospitalDiagnosis != null ||
                  report.userComplaintNote != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (report.hospitalDiagnosis != null) ...[
                          Text(
                            'Girilen Hastane / Doktor Teşhisi',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            report.hospitalDiagnosis!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (report.hospitalDiagnosis != null &&
                            report.userComplaintNote != null)
                          const Divider(height: 18),
                        if (report.userComplaintNote != null) ...[
                          Text(
                            'Şikayetiniz / Kendi Notunuz',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            report.userComplaintNote!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              if (report.contextualInterpretation != null &&
                  report.contextualInterpretation!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 19,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Anlaşılır Değerlendirme & Yorum',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.contextualInterpretation!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (report.items.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Parametre Tablosu & Değerlendirme (${report.items.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _ReportComparisonSummaryTable(
                  report: report,
                  previousReport: _findPreviousReport(report),
                ),
                const SizedBox(height: 10),
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
                                Expanded(
                                  child: Text(
                                    'Ref: ${item.referenceRangeText}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
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
              ],
              if (report.followUpQuestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              size: 19,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Doktorunuza Sorabileceğiniz Sorular',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final q in report.followUpQuestions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• $q',
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.38,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
                  try {
                    await LabReportPdfGenerator.saveAndShareSummaryPdf(
                      report: report,
                      previousReport: _findPreviousReport(report),
                    );
                  } catch (e) {
                    if (sheetContext.mounted) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text('PDF oluşturulamadı: $e'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Doktora Göster • Özet PDF Oluştur'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: LabReportAnalyzer.formatReportForDoctor(report),
                    ),
                  );
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Tahlil özeti metin olarak panoya kopyalandı.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Metin Olarak Kopyala'),
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
                'PDF veya JPG kan sonucunuzu yükleyin; isterseniz doktorun yazdığı teşhisi veya kendi şikayetinizi ekleyip sade Türkçe ile yorumlatın.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _openAddReport,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('İlk Tahlil / PDF Raporunu Ekle'),
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
                report.hasAttachment &&
                        report.attachmentMimeType == 'application/pdf'
                    ? Icons.picture_as_pdf_outlined
                    : report.abnormalCount == 0
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
                  '${df.format(report.reportDate)} • ${report.items.isEmpty ? report.source.label : '${report.items.length} parametre'}'
                  '${report.hospitalDiagnosis != null ? ' • Teşhisli' : ''}',
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

  LabReportRecord? _findPreviousReport(LabReportRecord current) {
    final earlier = _reports
        .where(
          (r) =>
              r.id != current.id &&
              r.items.isNotEmpty &&
              !r.reportDate.isAfter(current.reportDate),
        )
        .toList()
      ..sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return earlier.isEmpty ? null : earlier.first;
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
            'Kan tahlili raporlarınızı yüklediğinizde tüm parametreler tarih sırasıyla karşılaştırma tablosuna eklenir ve zaman içi değişim grafikleri burada oluşur.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    final datedReports = _reports.where((r) => r.items.isNotEmpty).toList()
      ..sort((a, b) => a.reportDate.compareTo(b.reportDate));
    final visibleTrends = _onlyAbnormalInTable
        ? trends.where((t) => t.latest.status.isAbnormal).toList()
        : trends;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.table_chart_outlined, size: 17),
                    label: Text('Kıyas Tablosu'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.show_chart_rounded, size: 17),
                    label: Text('Grafikler'),
                  ),
                ],
                selected: {_showComparisonTable},
                onSelectionChanged: (selection) {
                  setState(() => _showComparisonTable = selection.first);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_showComparisonTable) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${datedReports.length} rapor • ${visibleTrends.length} parametre',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilterChip(
                label: const Text('Sadece Referans Dışı'),
                selected: _onlyAbnormalInTable,
                onSelected: (v) => setState(() => _onlyAbnormalInTable = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MultiReportComparisonTable(
            reports: datedReports,
            trends: visibleTrends,
          ),
        ] else ...[
          for (final trend in visibleTrends) ...[
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
                            color: trend.latest.status.color
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${trend.latest.value.toStringAsFixed(trend.latest.value == trend.latest.value.roundToDouble() ? 0 : 1)} ${trend.unit}',
                            style: TextStyle(
                              color: trend.latest.status.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trend.points.length} kayıt • Değişim: ${trend.deltaSummary} • Son durum: ${trend.latest.status.label}',
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
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _AddLabReportSheet extends StatefulWidget {
  const _AddLabReportSheet({
    required this.documentPicker,
    required this.aiExtractor,
  });

  final LabDocumentPicker documentPicker;
  final LabDocumentAiExtractor aiExtractor;

  @override
  State<_AddLabReportSheet> createState() => _AddLabReportSheetState();
}

class _AddLabReportSheetState extends State<_AddLabReportSheet> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Kan Tahlili Sonucu');
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  DateTime _reportDate = DateTime.now();
  LabReportSource _source = LabReportSource.manual;
  LabParameterSpec _selectedSpec = LabReportAnalyzer.catalog.first;
  final Map<String, LabTestItem> _itemsByCode = <String, LabTestItem>{};
  PickedLabDocument? _attachedDocument;
  String? _parseFeedback;
  bool _pickingFile = false;
  bool _readingDocument = false;

  bool get _canSave =>
      !_readingDocument &&
      (_itemsByCode.isNotEmpty ||
          _attachedDocument != null ||
          _diagnosisController.text.trim().isNotEmpty ||
          _complaintController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _diagnosisController.addListener(_onOptionalTextChanged);
    _complaintController.addListener(_onOptionalTextChanged);
  }

  void _onOptionalTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _diagnosisController.removeListener(_onOptionalTextChanged);
    _complaintController.removeListener(_onOptionalTextChanged);
    _titleController.dispose();
    _pasteController.dispose();
    _valueController.dispose();
    _diagnosisController.dispose();
    _complaintController.dispose();
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

  Future<void> _pickPdfOrJpg() async {
    if (_pickingFile || _readingDocument) return;
    setState(() => _pickingFile = true);
    try {
      final doc = await widget.documentPicker.pickPdfOrImage();
      if (doc != null && mounted) {
        await _applyPickedDocument(doc);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _parseFeedback =
              'Dosya seçici açılamadı; rapor metnini yapıştırabilir veya değerleri manuel girebilirsiniz.';
        });
      }
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _pickCameraReport() async {
    if (_pickingFile || _readingDocument) return;
    setState(() => _pickingFile = true);
    try {
      final doc = await widget.documentPicker.pickCameraPhoto();
      if (doc != null && mounted) {
        await _applyPickedDocument(doc);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _parseFeedback =
              'Kamera açılamadı; PDF/JPG dosyası seçebilir veya metin yapıştırabilirsiniz.';
        });
      }
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _applyPickedDocument(PickedLabDocument doc) async {
    setState(() {
      _attachedDocument = doc;
      _source = doc.isPdf ? LabReportSource.pdfUpload : LabReportSource.photoScan;
      _readingDocument = true;
      _parseFeedback =
          '${doc.badgeLabel} (${doc.fileName}) okunuyor ve tüm tahlil değerleri çıkarılıyor...';
    });

    var extractedCount = 0;
    String feedback =
        '${doc.badgeLabel} yüklendi: ${doc.fileName} (${doc.sizeKb} KB).';

    // 1. On-device instant PDF text + geometric row + universal table extraction (0 cost)
    if (doc.isPdf) {
      final extracted = PdfTextExtractor.extractText(doc.bytes);
      if (extracted.isNotEmpty) {
        final parsed = LabReportAnalyzer.parseReportText(extracted);
        if (parsed.detectedDate != null) {
          _reportDate = parsed.detectedDate!;
        }
        if (parsed.detectedHospital != null &&
            _titleController.text.trim() == 'Kan Tahlili Sonucu') {
          _titleController.text = parsed.detectedHospital!;
        }
        for (final item in parsed.items) {
          _itemsByCode[item.code] = item;
        }
        extractedCount = parsed.items.length;
        if (extractedCount > 0) {
          final dateInfo = parsed.detectedDate != null
              ? ' • Tarih: ${DateFormat('dd.MM.yyyy').format(parsed.detectedDate!)}'
              : '';
          feedback =
              'PDF okundu (${doc.fileName}$dateInfo): $extractedCount tahlil değeri tabloya aktarıldı.';
        }
      }
    }

    // 2. Universal AI Document/Vision fallback when PDF is scanned (0 items),
    //    sparse (< 3 items on a multi-line hospital doc), or an image/photo is
    //    uploaded and Gemini AI is available.
    if ((extractedCount == 0 || (doc.isPdf && extractedCount < 3)) &&
        widget.aiExtractor.isAvailable) {
      try {
        final aiResult = await widget.aiExtractor.extractFromDocument(doc);
        if (!mounted) return;
        if (aiResult.detectedDate != null) {
          _reportDate = aiResult.detectedDate!;
        }
        if (aiResult.hospitalName != null &&
            _titleController.text.trim() == 'Kan Tahlili Sonucu') {
          _titleController.text = aiResult.hospitalName!;
        }
        if (aiResult.items.length > extractedCount) {
          for (final item in aiResult.items) {
            _itemsByCode[item.code] = item;
          }
          extractedCount = _itemsByCode.length;
          final dateInfo = aiResult.detectedDate != null
              ? ' • Tarih: ${DateFormat('dd.MM.yyyy').format(aiResult.detectedDate!)}'
              : '';
          feedback =
              'Yapay Zeka ile okundu (${doc.fileName}$dateInfo): $extractedCount tahlil değeri tabloya aktarıldı.';
        }
      } catch (_) {
        if (extractedCount == 0) {
          feedback = doc.isPdf
              ? 'PDF yüklendi (${doc.fileName}). Otomatik okunamadı; metni yapıştırabilir veya değer ekleyebilirsiniz.'
              : 'Görsel yüklendi (${doc.fileName}). Yapay zeka okuması şu an tamamlanamadı; değerleri aşağıdan ekleyebilirsiniz.';
        }
      }
    } else if (extractedCount == 0) {
      feedback = doc.isPdf
          ? 'PDF yüklendi (${doc.fileName}). Taranmış görsel PDF ise değerleri aşağıdan ekleyebilir veya teşhis/not ile kaydedebilirsiniz.'
          : 'JPG/Görsel yüklendi (${doc.fileName}). İsterseniz aşağıdan değerleri veya hastane teşhisini ekleyip değerlendirebilirsiniz.';
    }

    if (!mounted) return;
    setState(() {
      _readingDocument = false;
      _parseFeedback = feedback;
    });
  }

  Future<void> _reReadWithAi() async {
    final doc = _attachedDocument;
    if (doc == null || _readingDocument || !widget.aiExtractor.isAvailable) {
      return;
    }
    setState(() {
      _readingDocument = true;
      _parseFeedback = 'Belge Yapay Zeka (Gemini) ile yeniden okunuyor...';
    });
    try {
      final aiResult = await widget.aiExtractor.extractFromDocument(doc);
      if (!mounted) return;
      if (aiResult.detectedDate != null) {
        _reportDate = aiResult.detectedDate!;
      }
      if (aiResult.hospitalName != null &&
          _titleController.text.trim() == 'Kan Tahlili Sonucu') {
        _titleController.text = aiResult.hospitalName!;
      }
      for (final item in aiResult.items) {
        _itemsByCode[item.code] = item;
      }
      setState(() {
        _readingDocument = false;
        _parseFeedback =
            'Yapay Zeka ile okundu (${doc.fileName}): ${aiResult.items.length} tahlil değeri tabloya aktarıldı.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _readingDocument = false;
        _parseFeedback =
            'Yapay Zeka ile okuma tamamlanamadı; mevcut değerleri düzenleyip kaydedebilirsiniz.';
      });
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
      if (_attachedDocument == null) {
        _source = LabReportSource.pastedText;
      }
      _parseFeedback = parsed.items.isEmpty
          ? 'Tanınan parametre bulunamadı. Örn: "Hemoglobin: 11.4" veya "Glukoz 108" şeklinde girin.'
          : '${parsed.items.length} tahlil parametresi otomatik okundu ve değerlendirildi.';
    });
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
    if (!_canSave) return;
    final report = LabReportAnalyzer.buildReport(
      title: _titleController.text,
      reportDate: _reportDate,
      source: _source,
      items: _itemsByCode.values.toList(),
      rawReportText: _pasteController.text.trim().isEmpty
          ? null
          : _pasteController.text.trim(),
      hospitalDiagnosis: _diagnosisController.text,
      userComplaintNote: _complaintController.text,
      attachmentFileName: _attachedDocument?.fileName,
      attachmentMimeType: _attachedDocument?.mimeType,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                '1. PDF veya JPG Kan Sonucu Yükle',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _pickingFile ? null : _pickPdfOrJpg,
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: const Text('PDF veya JPG Yükle'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickingFile ? null : _pickCameraReport,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Kamerayla Çek'),
                  ),
                ],
              ),
              if (_attachedDocument != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InputChip(
                      avatar: Icon(
                        _attachedDocument!.isPdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.image_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        '${_attachedDocument!.badgeLabel} • ${_attachedDocument!.fileName}',
                      ),
                      onDeleted: _readingDocument
                          ? null
                          : () => setState(() => _attachedDocument = null),
                    ),
                    if (widget.aiExtractor.isAvailable)
                      ActionChip(
                        avatar: Icon(
                          Icons.auto_awesome_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        label: const Text('Yapay Zeka ile Oku'),
                        onPressed: _readingDocument ? null : _reReadWithAi,
                      ),
                  ],
                ),
              ],
              if (_readingDocument) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(),
              ],
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
              const SizedBox(height: 14),
              Text(
                '2. Hastane Teşhisi & Kendi Notunuz (İsteğe Bağlı)',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Doktorun verdiği teşhisi anlamakta zorlandıysanız ya da şikayetinizi eklemek isterseniz yazın; ikisini de boş bırakabilirsiniz.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Hastane / Doktor Teşhisi (Boş Bırakılabilir)',
                  hintText:
                      'Örn: Hipotiroidi, Demir eksikliği anemisi, Grade 2 hepatosteatoz...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _complaintController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Şikayetiniz / Kendi Metniniz (Boş Bırakılabilir)',
                  hintText:
                      'Örn: Çok halsizim ve saçlarım dökülüyor, bu sonuçlar ne anlama geliyor?',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '3. e-Nabız Metni Yapıştır veya Manuel Değer Ekle',
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
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _parsePastedText,
                  icon: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: const Text('Metni Oku ve Ayrıştır'),
                ),
              ),
              const SizedBox(height: 10),
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
                  'Okunan Değerler Tablosu (${_itemsByCode.length})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 48,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      columns: const [
                        DataColumn(label: Text('Parametre')),
                        DataColumn(label: Text('Sonuç')),
                        DataColumn(label: Text('Referans')),
                        DataColumn(label: Text('Durum')),
                        DataColumn(label: Text('')),
                      ],
                      rows: _itemsByCode.values.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.formattedValue,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: item.status.color,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.referenceRangeText,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.status.label,
                                style: TextStyle(
                                  color: item.status.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () => setState(
                                  () => _itemsByCode.remove(item.code),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: FilledButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Değerlendir ve Tarihli Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportComparisonSummaryTable extends StatelessWidget {
  const _ReportComparisonSummaryTable({
    required this.report,
    required this.previousReport,
  });

  final LabReportRecord report;
  final LabReportRecord? previousReport;

  @override
  Widget build(BuildContext context) {
    final prevByCode = <String, LabTestItem>{
      if (previousReport != null)
        for (final item in previousReport!.items) item.code: item,
    };
    final hasPrev = prevByCode.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 48,
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: [
            const DataColumn(label: Text('Parametre')),
            const DataColumn(label: Text('Sonuç')),
            const DataColumn(label: Text('Referans')),
            const DataColumn(label: Text('Durum')),
            if (hasPrev) const DataColumn(label: Text('Öncekiyle Kıyas')),
          ],
          rows: report.items.map((item) {
            final prev = prevByCode[item.code];
            final String deltaLabel;
            if (prev == null) {
              deltaLabel = '—';
            } else {
              final d = item.value - prev.value;
              if (d.abs() < 0.005) {
                deltaLabel = '= Sabit';
              } else {
                final arrow = d > 0 ? '▲ +' : '▼ ';
                deltaLabel = '$arrow${_fmtCompact(d)}';
              }
            }

            return DataRow(
              color: item.status.isAbnormal
                  ? WidgetStatePropertyAll(
                      item.status.color.withValues(alpha: 0.08),
                    )
                  : null,
              cells: [
                DataCell(
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.formattedValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: item.status.color,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.referenceRangeText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    item.status.label,
                    style: TextStyle(
                      color: item.status.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (hasPrev)
                  DataCell(
                    Text(
                      deltaLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MultiReportComparisonTable extends StatelessWidget {
  const _MultiReportComparisonTable({
    required this.reports,
    required this.trends,
  });

  final List<LabReportRecord> reports;
  final List<LabParameterTrend> trends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd.MM.yy');

    if (trends.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Seçili filtreye uyan tahlil parametresi yok.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final itemsByReport = reports
        .map((r) => {for (final i in r.items) i.code: i})
        .toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 42,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,
          columnSpacing: 16,
          horizontalMargin: 12,
          columns: [
            const DataColumn(label: Text('Parametre')),
            const DataColumn(label: Text('Referans')),
            for (final report in reports)
              DataColumn(label: Text(df.format(report.reportDate))),
            const DataColumn(label: Text('Değişim')),
          ],
          rows: trends.map((trend) {
            final refText = trend.refMin != null && trend.refMax != null
                ? '${_fmtCompact(trend.refMin!)}–${_fmtCompact(trend.refMax!)}'
                : trend.refMax != null
                    ? '< ${_fmtCompact(trend.refMax!)}'
                    : trend.refMin != null
                        ? '> ${_fmtCompact(trend.refMin!)}'
                        : '—';

            final d = trend.delta;
            final deltaText = d == null
                ? 'İlk'
                : d.abs() < 0.005
                    ? '='
                    : '${d > 0 ? '▲ +' : '▼ '}${_fmtCompact(d)}';

            return DataRow(
              color: trend.latest.status.isAbnormal
                  ? WidgetStatePropertyAll(
                      trend.latest.status.color.withValues(alpha: 0.07),
                    )
                  : null,
              cells: [
                DataCell(
                  Text(
                    '${trend.name}${trend.unit.isNotEmpty ? ' (${trend.unit})' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                DataCell(
                  Text(refText, style: const TextStyle(fontSize: 12)),
                ),
                for (final byCode in itemsByReport)
                  DataCell(
                    byCode[trend.code] == null
                        ? const Text('—')
                        : Text(
                            _fmtCompact(byCode[trend.code]!.value),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: byCode[trend.code]!.status.color,
                            ),
                          ),
                  ),
                DataCell(
                  Text(
                    deltaText,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: d == null || d.abs() < 0.005
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

String _fmtCompact(double v) {
  if ((v - v.roundToDouble()).abs() < 0.001) {
    return v.round().toString();
  }
  final two = v.toStringAsFixed(2);
  return two.endsWith('0') ? v.toStringAsFixed(1) : two;
}
