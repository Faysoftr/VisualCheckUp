import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/labs_vitals/data/gemini_lab_report_extractor.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_document_picker.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_analyzer.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_report_pdf_generator.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_unit_converter.dart';
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
      builder: (_) => _SeniorFriendlyLabReportDetailSheet(
        report: report,
        previousReport: _findPreviousReport(report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trends = LabReportAnalyzer.computeParameterTrends(_reports);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.labScreenTitle),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.description_outlined, size: 18),
                text: l10n.labTabReports,
              ),
              Tab(
                icon: const Icon(Icons.show_chart_rounded, size: 18),
                text: l10n.labTabTrends,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddReport,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.labAddBtn),
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
    final l10n = context.l10n;

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
                l10n.labEmptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.labEmptyDesc,
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
                label: Text(l10n.labAddFirstBtn),
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
                  '${df.format(report.reportDate)} • ${report.items.isEmpty ? report.source.localizedLabel(l10n) : l10n.labParamsCount(report.items.length)}'
                  '${report.abnormalCount > 0 ? ' • ${l10n.labOutOfRangeCount(report.abnormalCount)}' : ''}',
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
              tooltip: l10n.clearBaselineBtn,
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
    final l10n = context.l10n;

    if (trends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            l10n.labTrendsEmptyDesc,
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
                segments: [
                  ButtonSegment<bool>(
                    value: true,
                    icon: const Icon(Icons.table_chart_outlined, size: 17),
                    label: Text(l10n.labTabReports),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: const Icon(Icons.show_chart_rounded, size: 17),
                    label: Text(l10n.labTabTrends),
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
                  '${l10n.homeLabsCardCount(datedReports.length)} • ${l10n.labParamsCount(visibleTrends.length)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilterChip(
                label: Text(l10n.labStatusHigh),
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
                      l10n.labTrendSummary(
                        trend.points.length,
                        trend.deltaSummary,
                        trend.latest.status.localizedLabel(l10n),
                      ),
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  DateTime _reportDate = DateTime.now();
  LabReportSource _source = LabReportSource.manual;
  LabParameterSpec _selectedSpec = LabReportAnalyzer.catalog.first;
  final Map<String, LabTestItem> _itemsByCode = <String, LabTestItem>{};
  PickedLabDocument? _attachedDocument;
  int _scannedPagesCount = 0;
  String? _parseFeedback;
  bool _pickingFile = false;
  bool _readingDocument = false;
  bool _initializedDefaultTitle = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedDefaultTitle) {
      _initializedDefaultTitle = true;
      _titleController.text = context.l10n.labDefaultReportTitle;
    }
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _parseFeedback = context.l10n.cameraAnalysisFailed(e.toString());
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _parseFeedback = context.l10n.cameraAnalysisFailed(e.toString());
        });
      }
    } finally {
      if (mounted) setState(() => _pickingFile = false);
    }
  }

  Future<void> _applyPickedDocument(PickedLabDocument doc) async {
    final l10n = context.l10n;
    final defaultTitle = l10n.labDefaultReportTitle;
    setState(() {
      _attachedDocument = doc;
      _scannedPagesCount += 1;
      _source = doc.isPdf ? LabReportSource.pdfUpload : LabReportSource.photoScan;
      _readingDocument = true;
      _parseFeedback = l10n.cameraAnalyzing;
    });

    var extractedCount = 0;
    String feedback = '${doc.badgeLabel}: ${doc.fileName} (${doc.sizeKb} KB)';

    // 1. On-device instant PDF text + geometric row + universal table extraction (0 cost)
    if (doc.isPdf) {
      final extracted = PdfTextExtractor.extractText(doc.bytes);
      if (extracted.isNotEmpty) {
        final parsed = LabReportAnalyzer.parseReportText(extracted);
        if (parsed.detectedDate != null) {
          _reportDate = parsed.detectedDate!;
        }
        if (parsed.detectedHospital != null &&
            _titleController.text.trim() == defaultTitle) {
          _titleController.text = parsed.detectedHospital!;
        }
        for (final item in parsed.items) {
          _itemsByCode[item.code] = item;
        }
        extractedCount = parsed.items.length;
        if (extractedCount > 0) {
          final dateInfo = parsed.detectedDate != null
              ? ' • ${DateFormat('dd.MM.yyyy').format(parsed.detectedDate!)}'
              : '';
          feedback = l10n.localeName == 'tr'
              ? 'PDF okundu (${doc.fileName}$dateInfo): ${_itemsByCode.length} tahlil değeri tabloya aktarıldı.'
              : '${doc.badgeLabel} (${doc.fileName}$dateInfo): ${l10n.labParamsCount(_itemsByCode.length)}';
        }
      }
    }

    // 2. Universal AI Document/Vision extraction for photographed paper reports,
    //    scanned PDFs (0 items), or sparse PDFs (< 3 items).
    if ((extractedCount == 0 || (doc.isPdf && extractedCount < 3)) &&
        widget.aiExtractor.isAvailable) {
      try {
        final aiResult = await widget.aiExtractor.extractFromDocument(doc);
        if (!mounted) return;
        if (aiResult.detectedDate != null) {
          _reportDate = aiResult.detectedDate!;
        }
        if (aiResult.hospitalName != null &&
            _titleController.text.trim() == defaultTitle) {
          _titleController.text = aiResult.hospitalName!;
        }
        if (aiResult.items.isNotEmpty) {
          for (final item in aiResult.items) {
            _itemsByCode[item.code] = item;
          }
          extractedCount = aiResult.items.length;
          final dateInfo = aiResult.detectedDate != null
              ? ' • ${DateFormat('dd.MM.yyyy').format(aiResult.detectedDate!)}'
              : '';
          feedback = l10n.localeName == 'tr'
              ? 'Yapay Zeka ile okundu (${doc.fileName}$dateInfo): toplam ${_itemsByCode.length} tahlil değeri tabloya aktarıldı.'
              : 'AI (${doc.fileName}$dateInfo): ${l10n.labParamsCount(_itemsByCode.length)}';
        }
      } catch (_) {
        // Keep base file-loaded feedback so user can enter values or notes.
      }
    } else if (doc.isImage && extractedCount == 0 && !widget.aiExtractor.isAvailable) {
      feedback = l10n.labPhotoOfflineHint;
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
    final l10n = context.l10n;
    final defaultTitle = l10n.labDefaultReportTitle;
    setState(() {
      _readingDocument = true;
      _parseFeedback = l10n.cameraAnalyzing;
    });
    try {
      final aiResult = await widget.aiExtractor.extractFromDocument(doc);
      if (!mounted) return;
      if (aiResult.detectedDate != null) {
        _reportDate = aiResult.detectedDate!;
      }
      if (aiResult.hospitalName != null &&
          _titleController.text.trim() == defaultTitle) {
        _titleController.text = aiResult.hospitalName!;
      }
      for (final item in aiResult.items) {
        _itemsByCode[item.code] = item;
      }
      setState(() {
        _readingDocument = false;
        _parseFeedback =
            'AI (${doc.fileName}): ${l10n.labParamsCount(_itemsByCode.length)}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _readingDocument = false;
        _parseFeedback = l10n.cameraAnalysisFailed(e.toString());
      });
    }
  }

  void _parsePastedText() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;

    final l10n = context.l10n;
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
      _parseFeedback = l10n.labParamsCount(parsed.items.length);
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
    final l10n = context.l10n;
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
                      l10n.labAddSheetTitle,
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
                            decoration: InputDecoration(
                              labelText: l10n.labReportTitleField,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                          ),
                          label: Text(df.format(_reportDate)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.labStep1Upload,
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
                          icon: const Icon(
                            Icons.upload_file_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.labUploadPdfJpgBtn),
                        ),
                        FilledButton.icon(
                          key: const Key('lab_camera_scan_btn'),
                          onPressed: _pickingFile ? null : _pickCameraReport,
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _scannedPagesCount > 0 &&
                                    _attachedDocument?.isImage == true
                                ? l10n.labAddAnotherPageBtn
                                : l10n.labCameraCaptureBtn,
                          ),
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
                              _scannedPagesCount > 1
                                  ? '${l10n.labPagesReadBadge(_scannedPagesCount)} • ${_attachedDocument!.fileName}'
                                  : '${_attachedDocument!.badgeLabel} • ${_attachedDocument!.fileName}',
                            ),
                            onDeleted: _readingDocument
                                ? null
                                : () => setState(() {
                                      _attachedDocument = null;
                                      _scannedPagesCount = 0;
                                    }),
                          ),
                          if (widget.aiExtractor.isAvailable)
                            ActionChip(
                              avatar: Icon(
                                Icons.auto_awesome_outlined,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              label: Text(l10n.menuAiSettings),
                              onPressed:
                                  _readingDocument ? null : _reReadWithAi,
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
                          height: 1.38,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      l10n.labStep2Context,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.labStep2ContextHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _diagnosisController,
                      decoration: InputDecoration(
                        labelText: l10n.labDiagnosisField,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _complaintController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.labComplaintField,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.labStep3PasteManual,
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
                            'Hemoglobin: 11.2 g/dL\nFerritin: 14 ng/mL\nGlucose: 118 mg/dL\nTSH: 5.1 mIU/L',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _parsePastedText,
                        icon: const Icon(
                          Icons.document_scanner_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.labParseTextBtn),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<LabParameterSpec>(
                      initialValue: _selectedSpec,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.labParamDropdown,
                        border: const OutlineInputBorder(),
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
                              labelText: l10n.labValueField(_selectedSpec.unit),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.tonal(
                          onPressed: _addManualItem,
                          child: Text(l10n.labAddValueBtn),
                        ),
                      ],
                    ),
                    if (_itemsByCode.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        l10n.labParsedValuesTitle(_itemsByCode.length),
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
                            columns: [
                              DataColumn(label: Text(l10n.labParamDropdown)),
                              const DataColumn(label: Text('#')),
                              const DataColumn(label: Text('Ref')),
                              const DataColumn(label: Text('•')),
                              const DataColumn(label: Text('')),
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
                                      item.status.localizedLabel(l10n),
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
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                      ),
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
                label: Text(l10n.labSaveEvaluateBtn),
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
    final l10n = context.l10n;
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
            DataColumn(label: Text(l10n.labParamDropdown)),
            const DataColumn(label: Text('#')),
            const DataColumn(label: Text('Ref')),
            const DataColumn(label: Text('•')),
            if (hasPrev) const DataColumn(label: Text('Δ')),
          ],
          rows: report.items.map((item) {
            final prev = prevByCode[item.code];
            final String deltaLabel;
            if (prev == null) {
              deltaLabel = '—';
            } else {
              final d = item.value - prev.value;
              if (d.abs() < 0.005) {
                deltaLabel = '=';
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
                    item.status.localizedLabel(l10n),
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
    final l10n = context.l10n;
    final df = DateFormat('dd.MM.yy');

    if (trends.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            l10n.labEmptyTitle,
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
            DataColumn(label: Text(l10n.labParamDropdown)),
            const DataColumn(label: Text('Ref')),
            for (final report in reports)
              DataColumn(label: Text(df.format(report.reportDate))),
            const DataColumn(label: Text('Δ')),
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
                ? '—'
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
                        ? Text(
                            l10n.labNotInReportBadge,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
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

/// Elderly-friendly, uncluttered, bullet-by-bullet lab report detail sheet.
///
/// Features a one-tap Large Text (`Aa+`) readability toggle, an at-a-glance
/// bulleted summary, out-of-range parameters explained first in plain everyday
/// language ("What it means" + "What you can do"), a calm green normal-values
/// list, an explicit "Not Included in This Report" section for absent core
/// tests, a comparison table, numbered doctor questions, and PDF/Copy export.
class _SeniorFriendlyLabReportDetailSheet extends StatefulWidget {
  const _SeniorFriendlyLabReportDetailSheet({
    required this.report,
    required this.previousReport,
  });

  final LabReportRecord report;
  final LabReportRecord? previousReport;

  @override
  State<_SeniorFriendlyLabReportDetailSheet> createState() =>
      _SeniorFriendlyLabReportDetailSheetState();
}

class _SeniorFriendlyLabReportDetailSheetState
    extends State<_SeniorFriendlyLabReportDetailSheet> {
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final df = DateFormat('dd.MM.yyyy');
    final media = MediaQuery.of(context);

    final criticalItems =
        report.items.where((i) => i.status.isCritical).toList();
    final abnormalItems =
        report.items.where((i) => i.status.isAbnormal).toList()
          ..sort((a, b) => (b.status.isCritical ? 1 : 0)
              .compareTo(a.status.isCritical ? 1 : 0));
    final normalItems =
        report.items.where((i) => !i.status.isAbnormal).toList();
    final missingCore = LabReportAnalyzer.findMissingCoreParameters(
      report.items,
    );

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(_largeText ? 1.22 : 1.0),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.90,
        minChildSize: 0.55,
        maxChildSize: 0.97,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            // Header + One-Tap Large Text Toggle (Aa+)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
                      Text(
                        '${df.format(report.reportDate)} • ${report.source.localizedLabel(l10n)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  key: const Key('lab_large_text_toggle'),
                  avatar: const Icon(Icons.text_fields_rounded, size: 16),
                  label: Text(
                    _largeText
                        ? l10n.labLargeTextOnBtn
                        : l10n.labLargeTextBtn,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  selected: _largeText,
                  onSelected: (v) => setState(() => _largeText = v),
                ),
              ],
            ),

            if (report.hasAttachment) ...[
              const SizedBox(height: 8),
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

            // 1. Senior-Friendly At-a-Glance Bulleted Overview Card
            Card(
              color: report.hasCritical
                  ? const Color(0xFFFFF2F2)
                  : colorScheme.primaryContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          report.hasCritical
                              ? Icons.priority_high_rounded
                              : Icons.fact_check_outlined,
                          color: report.hasCritical
                              ? const Color(0xFFC93B3B)
                              : colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.labSeniorOverviewTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (report.items.isNotEmpty) ...[
                      if (criticalItems.isNotEmpty)
                        _SummaryBulletRow(
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFC93B3B),
                          text: l10n
                              .labSeniorCriticalBullet(criticalItems.length),
                        ),
                      if (abnormalItems.isNotEmpty)
                        _SummaryBulletRow(
                          icon: Icons.info_outline_rounded,
                          color: const Color(0xFFD9822B),
                          text: l10n
                              .labSeniorAbnormalBullet(abnormalItems.length),
                        ),
                      if (normalItems.isNotEmpty)
                        _SummaryBulletRow(
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF1B8A5A),
                          text: l10n.labSeniorNormalBullet(normalItems.length),
                        ),
                      if (missingCore.isNotEmpty)
                        _SummaryBulletRow(
                          icon: Icons.assignment_late_outlined,
                          color: colorScheme.onSurfaceVariant,
                          text:
                              l10n.labSeniorMissingBullet(missingCore.length),
                        ),
                      const Divider(height: 18),
                    ],
                    Text(
                      report.overallSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.recommendedSpecialtyLabel(
                              report.suggestedSpecialty,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
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

            // Optional Hospital Diagnosis & Complaint Card
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
                          l10n.labEnteredDiagnosisTitle,
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
                          l10n.labEnteredComplaintTitle,
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

            // Plain-Language Contextual Interpretation (split cleanly into readable bullets)
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
                          Expanded(
                            child: Text(
                              l10n.labInterpretationTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final line in report.contextualInterpretation!
                          .split(RegExp(r'\n+'))
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!line.startsWith('•'))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    right: 8,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  line,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.48,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            // 2. Attention / Out-of-Range Items FIRST (Plain Bulleted Cards)
            if (report.items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    abnormalItems.isEmpty
                        ? Icons.verified_outlined
                        : Icons.error_outline_rounded,
                    color: abnormalItems.isEmpty
                        ? const Color(0xFF1B8A5A)
                        : const Color(0xFFD9822B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.labAttentionSectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (abnormalItems.isEmpty)
                Card(
                  color: const Color(0xFF1B8A5A).withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF1B8A5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.labAllValuesNormalMsg,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF166B46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final item in abnormalItems) ...[
                  _SeniorAbnormalItemCard(item: item),
                  const SizedBox(height: 10),
                ],

              // 3. Normal Values (Clean Bulleted Reassuring Card)
              if (normalItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF1B8A5A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.labNormalSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166B46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < normalItems.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 14,
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.45),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Color(0xFF1B8A5A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      normalItems[i].name,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Ref: ${normalItems[i].referenceRangeText}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                normalItems[i].formattedValue,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B8A5A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // 4. Core Tests NOT Included in This Report
              if (missingCore.isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_late_outlined,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.labMissingSectionTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.labMissingSectionExplain,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final spec in missingCore)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  '${spec.name} • ${l10n.labNotInReportBadge}',
                                  style: theme.textTheme.bodySmall?.copyWith(
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
                ),
              ],
            ],

            // Compact Comparison Summary Table
            if (report.items.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                l10n.labDetailParamsTitle(report.items.length),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _ReportComparisonSummaryTable(
                report: report,
                previousReport: widget.previousReport,
              ),
            ],

            // Numbered Questions for Doctor
            if (report.followUpQuestions.isNotEmpty) ...[
              const SizedBox(height: 14),
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
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.questionsForDoctorTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < report.followUpQuestions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.followUpQuestions[i],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.42,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              l10n.disclaimerShort,
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
                    previousReport: widget.previousReport,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.cameraAnalysisFailed(e.toString())),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(l10n.labExportPdfBtn),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: LabReportAnalyzer.formatReportForDoctor(report),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.labSummaryCopied),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(l10n.labCopyDoctorSummaryBtn),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBulletRow extends StatelessWidget {
  const _SummaryBulletRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.38,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeniorAbnormalItemCard extends StatelessWidget {
  const _SeniorAbnormalItemCard({required this.item});

  final LabTestItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isLow =
        item.status == LabStatus.low || item.status == LabStatus.criticalLow;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: item.status.color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLow
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: item.status.color,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.status.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.localizedLabel(l10n),
                    style: TextStyle(
                      color: item.status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  item.formattedValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: item.status.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ref: ${item.referenceRangeText}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Text(
              '• ${l10n.labWhatItMeansLabel}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.note,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.42),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${l10n.labWhatToDoLabel}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              LabUnitConverter.plainActionAdvice(item),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
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
