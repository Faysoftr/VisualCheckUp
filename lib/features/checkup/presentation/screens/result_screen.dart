import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/data/cross_module_correlator.dart';
import 'package:visualcheckup/features/checkup/data/doctor_report_builder.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/module_reference.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/clinical_visual_illustration.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/doctor_summary_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    this.historyRepository,
    this.labsVitalsRepository,
  });

  final AnalysisResult result;
  final HistoryRepository? historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  CategoryBaseline? _savedBaseline;
  List<AnalysisResult> _allHistory = const [];
  List<CrossModuleInsight> _crossInsights = const [];
  bool _savingBaseline = false;

  @override
  void initState() {
    super.initState();
    _loadContextData();
  }

  Future<void> _loadContextData() async {
    final repo = widget.historyRepository;
    final labsRepo = widget.labsVitalsRepository ?? LabsVitalsRepository();
    final baseline =
        repo != null ? await repo.getBaseline(widget.result.category) : null;
    final history = repo != null ? await repo.loadHistory() : const <AnalysisResult>[];
    final labs = await labsRepo.loadLabReports();
    final bp = await labsRepo.loadBloodPressureReadings();
    final sugar = await labsRepo.loadBloodSugarReadings();
    final cross = CrossModuleHealthCorrelator.correlate(
      visualResult: widget.result,
      labReports: labs,
      bpReadings: bp,
      sugarReadings: sugar,
      visualHistory: history,
    );
    if (!mounted) return;
    setState(() {
      _savedBaseline = baseline;
      _allHistory = history;
      _crossInsights = cross;
    });
  }

  Future<void> _openDoctorSummary() async {
    final report = DoctorReportBuilder.build(
      currentResult: widget.result,
      allHistory: _allHistory,
    );
    await DoctorSummarySheet.show(context, report: report);
  }

  Future<void> _saveAsPersonalBaseline() async {
    final repo = widget.historyRepository;
    if (repo == null || _savingBaseline) return;
    final l10n = context.l10n;
    setState(() => _savingBaseline = true);

    final baseline = CategoryBaseline.fromColor(
      category: widget.result.category,
      color: widget.result.dominantColor,
      calibratedWithWhiteRef: widget.result.whiteBalanceCalibrated,
    );
    await repo.saveBaseline(baseline);

    if (!mounted) return;
    setState(() {
      _savedBaseline = baseline;
      _savingBaseline = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.baselineSavedMsg(widget.result.category.localizedTitle(l10n)),
        ),
      ),
    );
  }

  Future<void> _clearPersonalBaseline() async {
    final repo = widget.historyRepository;
    if (repo == null || _savingBaseline) return;
    final l10n = context.l10n;
    setState(() => _savingBaseline = true);
    await repo.deleteBaseline(widget.result.category);
    if (!mounted) return;
    setState(() {
      _savedBaseline = null;
      _savingBaseline = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.baselineClearedMsg(widget.result.category.localizedTitle(l10n)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final riskColor = result.riskLevel.color;
    final dateText = DateFormat('dd.MM.yyyy HH:mm').format(result.createdAt);
    final previousInCategory = _allHistory
        .where((e) => e.category == result.category && e.id != result.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.resultScreenTitle(result.category.localizedTitle(l10n)),
        ),
        actions: [
          IconButton(
            onPressed: _openDoctorSummary,
            tooltip: l10n.tooltipDoctorSummary,
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            onPressed: () => ModuleReferenceSheet.show(context, result.category),
            tooltip: l10n.tooltipReferenceGuide,
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Before / After Visual Photo Comparison Card
          if (result.imagePath != null &&
              File(result.imagePath!).existsSync()) ...[
            _BeforeAfterPhotoCard(
              currentResult: result,
              previousWithPhoto: previousInCategory
                  .where(
                    (e) =>
                        e.imagePath != null && File(e.imagePath!).existsSync(),
                  )
                  .firstOrNull,
            ),
            const SizedBox(height: 12),
          ],

          // Cross-Module Lab + Vitals + Visual Correlation Card
          if (_crossInsights.isNotEmpty) ...[
            Card(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.45),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.hub_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tahlil & Ölçümlerle Çapraz Bağlantı',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final insight in _crossInsights) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              insight.sourceLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (insight != _crossInsights.last)
                        const Divider(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Status Hero Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.riskLevel.icon,
                              size: 16,
                              color: riskColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              result.riskLevel.localizedLabel(l10n),
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.localizedSummaryTitle(l10n),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.summaryDetail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: result.dominantColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.whiteBalanceCalibrated
                                  ? l10n.calibratedColorTone
                                  : l10n.sampledColorTone,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              l10n.confidenceLabel(
                                (result.confidence * 100).round(),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (result.whiteBalanceCalibrated ||
                      result.lightingNote != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: result.whiteBalanceCalibrated
                            ? const Color(0xFF1B8A5A).withValues(alpha: 0.10)
                            : const Color(0xFFD9822B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            result.whiteBalanceCalibrated
                                ? Icons.wb_auto_rounded
                                : Icons.wb_incandescent_outlined,
                            size: 16,
                            color: result.whiteBalanceCalibrated
                                ? const Color(0xFF1B8A5A)
                                : const Color(0xFFD9822B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.lightingNote ??
                                  l10n.whiteBalanceDefaultNote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.riskLevel != RiskLevel.normal) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.recommendedSpecialtyLabel(
                                result.category
                                    .localizedRecommendedSpecialty(l10n),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
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

          if (result.matchedFindingIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MatchedVisualReferenceCard(
              result: result,
              onOpenAtlas: () =>
                  ModuleReferenceSheet.show(context, result.category),
              onOpenSelfTests: () => ModuleReferenceSheet.show(
                context,
                result.category,
                focusSelfTests: true,
              ),
            ),
          ],

          if (result.clinicalMetrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ClinicalBiomarkersCard(metrics: result.clinicalMetrics),
          ],

          if (previousInCategory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timeline_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.timelineComparisonTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SwatchBadge(
                          color: previousInCategory.first.dominantColor,
                          label: DateFormat('dd.MM')
                              .format(previousInCategory.first.createdAt),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.arrow_forward_rounded, size: 16),
                        ),
                        _SwatchBadge(
                          color: result.dominantColor,
                          label: l10n.todayLabel,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.previousRecordSummary(
                              previousInCategory.first
                                  .localizedSummaryTitle(l10n),
                              previousInCategory.first.riskLevel
                                  .localizedLabel(l10n),
                              previousInCategory.length + 1,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.38,
                              color: theme.colorScheme.onSurfaceVariant,
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

          if (result.baselineComparisonNote != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.personalBaselineComparisonTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (_savedBaseline != null) ...[
                          _SwatchBadge(
                            color: _savedBaseline!.color,
                            label: l10n.yourBaselineLabel,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded, size: 16),
                          ),
                        ],
                        _SwatchBadge(
                          color: result.dominantColor,
                          label: l10n.todayLabel,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.baselineComparisonNote!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
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

          if (result.warningFlags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF4F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: const Color(0xFFC93B3B).withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFC93B3B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.warningFlagsTitle,
                            style: const TextStyle(
                              color: Color(0xFFC93B3B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...result.warningFlags.map(
                      (flag) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $flag',
                          style: const TextStyle(
                            color: Color(0xFF7D2020),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (result.observations.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.observationsTitle,
              icon: Icons.visibility_outlined,
              items: result.observations,
            ),
          ],

          if (result.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.recommendationsTitle,
              icon: Icons.tips_and_updates_outlined,
              items: result.recommendations,
            ),
          ],

          if (widget.historyRepository != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.personalBaselineCardTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.personalBaselineCardDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              _savingBaseline ? null : _saveAsPersonalBaseline,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            _savedBaseline == null
                                ? l10n.saveBaselineBtn
                                : l10n.updateBaselineBtn,
                          ),
                        ),
                        if (_savedBaseline != null)
                          TextButton.icon(
                            onPressed:
                                _savingBaseline ? null : _clearPersonalBaseline,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(l10n.clearBaselineBtn),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.disclaimerShort,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openDoctorSummary,
            icon: const Icon(Icons.assignment_outlined),
            label: Text(l10n.doctorSummaryBtn),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.returnHomeBtn),
          ),
        ],
      ),
    );
  }
}

class _SwatchBadge extends StatelessWidget {
  const _SwatchBadge({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeAfterPhotoCard extends StatelessWidget {
  const _BeforeAfterPhotoCard({
    required this.currentResult,
    required this.previousWithPhoto,
  });

  final AnalysisResult currentResult;
  final AnalysisResult? previousWithPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd.MM.yyyy');
    final hasBefore = previousWithPhoto != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_rounded,
                  size: 19,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasBefore
                        ? 'Önce / Sonra Görsel Kıyaslama'
                        : 'Kaydedilen Kontrol Fotoğrafı',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (hasBefore) ...[
                  Expanded(
                    child: _PhotoTile(
                      path: previousWithPhoto!.imagePath!,
                      caption: 'Önce • ${df.format(previousWithPhoto!.createdAt)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: _PhotoTile(
                    path: currentResult.imagePath!,
                    caption:
                        '${hasBefore ? 'Sonra • ' : ''}${df.format(currentResult.createdAt)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.path,
    required this.caption,
  });

  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _MatchedVisualReferenceCard extends StatelessWidget {
  const _MatchedVisualReferenceCard({
    required this.result,
    required this.onOpenAtlas,
    required this.onOpenSelfTests,
  });

  final AnalysisResult result;
  final VoidCallback onOpenAtlas;
  final VoidCallback onOpenSelfTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final spec = ModuleReferenceCatalog.forCategory(result.category);
    final healthyRef = spec.healthyReferences.firstOrNull;
    final matchedFindings = <ReferenceFinding>[];
    for (final id in result.matchedFindingIds) {
      final f = ModuleReferenceCatalog.findById(id, category: result.category);
      if (f != null) matchedFindings.add(f);
    }
    if (matchedFindings.isEmpty) return const SizedBox.shrink();

    final primary = matchedFindings.first;
    final showHealthySide =
        healthyRef != null && !primary.isHealthyReference;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.resultVisualCompareTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHealthySide) ...[
                  Column(
                    children: [
                      ClinicalVisualIllustration(
                        findingId: healthyRef.id,
                        category: result.category,
                        fallbackColor: healthyRef.swatchColor,
                        size: 74,
                        borderRadius: 14,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.resultHealthyShort,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B8A5A),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 28),
                    child: Icon(Icons.compare_arrows_rounded, size: 18),
                  ),
                ],
                Column(
                  children: [
                    ClinicalVisualIllustration(
                      findingId: primary.id,
                      category: result.category,
                      fallbackColor: primary.swatchColor,
                      size: 74,
                      borderRadius: 14,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      primary.isHealthyReference
                          ? l10n.resultHealthyShort
                          : l10n.resultMatchedShort,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary.riskLevel.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primary.title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        primary.visualSignature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenAtlas,
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                  label: Text(l10n.resultViewFullAtlasBtn),
                ),
                if (spec.selfTests.isNotEmpty)
                  TextButton.icon(
                    onPressed: onOpenSelfTests,
                    icon: const Icon(Icons.fact_check_outlined, size: 16),
                    label: Text(l10n.resultHomeSelfTestsBtn),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicalBiomarkersCard extends StatelessWidget {
  const _ClinicalBiomarkersCard({required this.metrics});

  final Map<String, String> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.resultClinicalBiomarkersTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: metrics.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizedClinicalMetricKey(entry.key, l10n),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
