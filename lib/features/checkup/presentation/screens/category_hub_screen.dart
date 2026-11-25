import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/doctor_report_builder.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/health_analyzer.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/quick_color_card_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_icon.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/doctor_summary_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/photo_zoom_viewer.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';
import 'package:visualcheckup/features/skin/presentation/screens/skin_check_screen.dart';

enum _HubFilter { all, attentionOnly, withPhotoOnly }

/// Unified landing hub for every visual checkup module (Eye, Nail, Tongue,
/// Face, Skin, Urine, Stool).
///
/// Displays a prominent "Start New Scan" action area at the top (tailored to
/// the module's workflow) and a chronological, thumbnail-equipped Past Scans
/// table below with filter chips, swipe-to-delete, 2-scan side-by-side
/// comparison mode, and tap-to-open detailed [ResultScreen].
class CategoryHubScreen extends StatefulWidget {
  const CategoryHubScreen({
    super.key,
    required this.category,
    required this.historyRepository,
    this.analyzer,
    this.labsVitalsRepository,
  });

  final CheckCategory category;
  final HistoryRepository historyRepository;
  final ColorHealthAnalyzer? analyzer;
  final LabsVitalsRepository? labsVitalsRepository;

  @override
  State<CategoryHubScreen> createState() => _CategoryHubScreenState();
}

class _CategoryHubScreenState extends State<CategoryHubScreen> {
  List<AnalysisResult> _history = const [];
  CategoryBaseline? _baseline;
  bool _loading = true;
  _HubFilter _filter = _HubFilter.all;
  EyeScanMode _eyeScanMode = EyeScanMode.sclera;
  bool _compareMode = false;
  final List<String> _selectedIdsForCompare = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allHistory = await widget.historyRepository.loadHistory();
    final baseline = await widget.historyRepository.getBaseline(widget.category);
    final categoryItems = allHistory
        .where((e) => e.category == widget.category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!mounted) return;
    setState(() {
      _history = categoryItems;
      _baseline = baseline;
      _loading = false;
      _selectedIdsForCompare.removeWhere(
        (id) => !categoryItems.any((e) => e.id == id),
      );
      if (categoryItems.length < 2) {
        _compareMode = false;
        _selectedIdsForCompare.clear();
      }
    });
  }

  List<AnalysisResult> get _filteredHistory {
    switch (_filter) {
      case _HubFilter.all:
        return _history;
      case _HubFilter.attentionOnly:
        return _history
            .where((e) => e.riskLevel != RiskLevel.normal)
            .toList();
      case _HubFilter.withPhotoOnly:
        return _history
            .where(
              (e) => e.imagePath != null && File(e.imagePath!).existsSync(),
            )
            .toList();
    }
  }

  Future<void> _startCameraScan({bool autoPickFromGallery = false}) async {
    final hybridAnalyzer = HybridHealthAnalyzer(
      fallbackAnalyzer: widget.analyzer ?? ColorHealthAnalyzer(),
      aiClient: GeminiVisionAiClient.fromEnvironment(),
      cacheRepository: widget.historyRepository,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: widget.category,
          analyzer: hybridAnalyzer,
          historyRepository: widget.historyRepository,
          initialEyeScanMode: _eyeScanMode,
          autoPickFromGallery: autoPickFromGallery,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _openQuickColorCard() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuickColorCardScreen(
          category: widget.category,
          historyRepository: widget.historyRepository,
          analyzer: widget.analyzer ?? ColorHealthAnalyzer(),
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _openSkinSetup({SkinConcernType? concern}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SkinCheckScreen(
          historyRepository: widget.historyRepository,
          initialConcern: concern,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _openDetail(AnalysisResult item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          result: item,
          historyRepository: widget.historyRepository,
          labsVitalsRepository: widget.labsVitalsRepository,
        ),
      ),
    );
    await _loadData();
  }

  Future<void> _deleteItem(String id) async {
    await widget.historyRepository.deleteResult(id);
    await _loadData();
  }

  void _openLatestDoctorSummary() {
    if (_history.isEmpty) return;
    final report = DoctorReportBuilder.build(
      currentResult: _history.first,
      allHistory: _history,
    );
    DoctorSummarySheet.show(context, report: report);
  }

  void _toggleCompareSelection(String id) {
    setState(() {
      if (_selectedIdsForCompare.contains(id)) {
        _selectedIdsForCompare.remove(id);
      } else if (_selectedIdsForCompare.length < 2) {
        _selectedIdsForCompare.add(id);
      } else {
        // Replace oldest selection so user can switch seamlessly
        _selectedIdsForCompare
          ..removeAt(0)
          ..add(id);
      }
    });
  }

  void _openSideBySideComparison() {
    if (_selectedIdsForCompare.length != 2) return;
    final first = _history.firstWhere((e) => e.id == _selectedIdsForCompare[0]);
    final second =
        _history.firstWhere((e) => e.id == _selectedIdsForCompare[1]);
    final ordered = [first, second]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, scrollController) => _ScanComparisonSheet(
          older: ordered[0],
          newer: ordered[1],
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final accent = widget.category.accentColor;
    final filtered = _filteredHistory;
    final spec = ModuleReferenceCatalog.forCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.localizedTitle(l10n)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _openLatestDoctorSummary,
              tooltip: l10n.hubDoctorSummaryBtn,
              icon: const Icon(Icons.assignment_outlined),
            ),
          IconButton(
            onPressed: () =>
                ModuleReferenceSheet.show(context, widget.category),
            tooltip: l10n.tooltipReferenceGuide,
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                children: [
                  // 1. Top Hero Action Card (New Scan Launchpad)
                  _buildActionLaunchpad(context, theme, colorScheme, accent),

                  // 2. Summary Stats Strip (when history exists)
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSummaryStrip(context, theme, colorScheme),
                  ],

                  const SizedBox(height: 18),

                  // 3. Past Scans Header + Compare Mode Toggle
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.hubPastScansTitle(_history.length),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (_history.length >= 2)
                        TextButton.icon(
                          key: const Key('hub_compare_mode_btn'),
                          onPressed: () {
                            setState(() {
                              _compareMode = !_compareMode;
                              _selectedIdsForCompare.clear();
                            });
                          },
                          icon: Icon(
                            _compareMode
                                ? Icons.close_rounded
                                : Icons.compare_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _compareMode
                                ? l10n.hubCompareCancelBtn
                                : l10n.hubCompareModeBtn,
                          ),
                        ),
                    ],
                  ),

                  // Compare Mode Selection Banner
                  if (_compareMode) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.compare_arrows_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.hubCompareSelectHint(
                                _selectedIdsForCompare.length,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_selectedIdsForCompare.length == 2) ...[
                            const SizedBox(width: 8),
                            FilledButton(
                              key: const Key('hub_compare_execute_btn'),
                              onPressed: _openSideBySideComparison,
                              child: Text(l10n.hubCompareActionBtn),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Filter Chips (when history exists)
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.hubFilterAll),
                          selected: _filter == _HubFilter.all,
                          onSelected: (_) =>
                              setState(() => _filter = _HubFilter.all),
                        ),
                        ChoiceChip(
                          label: Text(l10n.hubFilterAttention),
                          selected: _filter == _HubFilter.attentionOnly,
                          onSelected: (_) => setState(
                            () => _filter = _HubFilter.attentionOnly,
                          ),
                        ),
                        ChoiceChip(
                          label: Text(l10n.hubFilterWithPhoto),
                          selected: _filter == _HubFilter.withPhotoOnly,
                          onSelected: (_) => setState(
                            () => _filter = _HubFilter.withPhotoOnly,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // 4. Past Scans Table OR Guided Empty State
                  if (_history.isEmpty)
                    _buildEmptyState(context, theme, colorScheme, spec)
                  else if (filtered.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.historyEmpty,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    _buildPastScansTable(context, theme, colorScheme, filtered),
                ],
              ),
            ),
    );
  }

  Widget _buildActionLaunchpad(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Color accent,
  ) {
    final l10n = context.l10n;
    final spec = ModuleReferenceCatalog.forCategory(widget.category);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 136,
            child: IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.category.cardBackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: const [0.0, 0.55, 1.0],
                        colors: isDark
                            ? [
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.98),
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.78),
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.25),
                              ]
                            : [
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.96),
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.72),
                                colorScheme.surfaceContainerLow
                                    .withValues(alpha: 0.18),
                              ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.45, 1.0],
                        colors: [
                          theme.cardTheme.color ??
                              colorScheme.surfaceContainerLow,
                          (theme.cardTheme.color ??
                                  colorScheme.surfaceContainerLow)
                              .withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: CategoryIcon(
                        category: widget.category,
                        color: accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.localizedTitle(l10n),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.category.localizedSubtitle(l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

            if (_baseline != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _baseline!.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.cameraBaselineActive,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Eye-specific quick scan mode selector right before launching camera
            if (widget.category == CheckCategory.eye) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(l10n.cameraEyeModeSclera),
                    selected: _eyeScanMode == EyeScanMode.sclera,
                    onSelected: (_) =>
                        setState(() => _eyeScanMode = EyeScanMode.sclera),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.bloodtype_outlined, size: 16),
                    label: Text(l10n.cameraEyeModeConjunctiva),
                    selected:
                        _eyeScanMode == EyeScanMode.palpebralConjunctiva,
                    onSelected: (_) => setState(
                      () => _eyeScanMode = EyeScanMode.palpebralConjunctiva,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            // Primary + Secondary launch CTAs per module
            if (widget.category.supportsQuickColorCard) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('hub_quick_card_btn'),
                  onPressed: _openQuickColorCard,
                  icon: const Icon(Icons.palette_outlined),
                  label: Text(l10n.colorCardRecommendedTitle),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('hub_start_scan_btn'),
                      onPressed: () => _startCameraScan(),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: Text(l10n.quickCardUseCameraBtn),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _startCameraScan(autoPickFromGallery: true),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(l10n.hubPickFromGallery),
                  ),
                ],
              ),
            ] else if (widget.category == CheckCategory.skinCondition) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('hub_start_scan_btn'),
                  onPressed: () => _openSkinSetup(),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.hubStartNewScan),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final concern in const [
                    SkinConcernType.skinCancerRisk,
                    SkinConcernType.wart,
                    SkinConcernType.bruise,
                    SkinConcernType.facialSpot,
                  ])
                    ActionChip(
                      avatar: Icon(concern.icon, size: 15),
                      label: Text(
                        concern.localizedLabel(l10n),
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _openSkinSetup(concern: concern),
                    ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('hub_start_scan_btn'),
                      onPressed: () => _startCameraScan(),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.hubStartNewScan),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    key: const Key('hub_gallery_btn'),
                    onPressed: () =>
                        _startCameraScan(autoPickFromGallery: true),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(l10n.hubPickFromGallery),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      ModuleReferenceSheet.show(context, widget.category),
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                  label: Text(l10n.atlasFilterAll(spec.findings.length)),
                ),
                if (spec.selfTests.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => ModuleReferenceSheet.show(
                      context,
                      widget.category,
                      focusSelfTests: true,
                    ),
                    icon: const Icon(Icons.fact_check_outlined, size: 16),
                    label: Text(l10n.resultHomeSelfTestsBtn),
                  ),
              ],
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = context.l10n;
    final latest = _history.first;
    final dateFmt = DateFormat('dd.MM.yyyy');

    return Row(
      children: [
        Expanded(
          child: _StatMiniCard(
            label: l10n.hubTotalScansLabel,
            value: '${_history.length}',
            icon: Icons.history_rounded,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatMiniCard(
            label: l10n.hubLastScanLabel,
            value: dateFmt.format(latest.createdAt),
            icon: Icons.calendar_today_outlined,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatMiniCard(
            label: l10n.hubLatestStatusLabel,
            value: latest.riskLevel.localizedLabel(l10n),
            icon: latest.riskLevel.icon,
            color: latest.riskLevel.color,
          ),
        ),
      ],
    );
  }

  Widget _buildPastScansTable(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<AnalysisResult> items,
  ) {
    final l10n = context.l10n;
    final dateFmt = DateFormat('dd.MM.yy');
    final timeFmt = DateFormat('HH:mm');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table Column Header Row
          Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    l10n.hubColPhoto,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 68,
                  child: Text(
                    l10n.hubColDate,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.hubColFinding,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.hubColStatus,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 0.7,
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            _buildTableRow(
              context,
              theme,
              colorScheme,
              items[i],
              dateFmt,
              timeFmt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AnalysisResult item,
    DateFormat dateFmt,
    DateFormat timeFmt,
  ) {
    final l10n = context.l10n;
    final hasPhoto =
        item.imagePath != null && File(item.imagePath!).existsSync();
    final isSelected = _selectedIdsForCompare.contains(item.id);
    final firstMetric = item.clinicalMetrics.entries.firstOrNull;

    final rowContent = InkWell(
      key: Key('hub_row_${item.id}'),
      onTap: () {
        if (_compareMode) {
          _toggleCompareSelection(item.id);
        } else {
          _openDetail(item);
        }
      },
      child: Container(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.38)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Thumbnail (48x48 photo or dominant color tile)
            SizedBox(
              width: 52,
              child: Stack(
                children: [
                  if (hasPhoto)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(item.imagePath!),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.dominantColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: CategoryIcon(
                        category: widget.category,
                        size: 22,
                        color: item.dominantColor.computeLuminance() > 0.5
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                  if (_compareMode)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Date & Time column
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFmt.format(item.createdAt),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeFmt.format(item.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Finding Summary + Primary Metric column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedSummaryTitle(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (firstMetric != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${localizedClinicalMetricKey(firstMetric.key, l10n)}: ${firstMetric.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Risk Status Pill + Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.riskLevel.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.riskLevel.icon,
                        size: 13,
                        color: item.riskLevel.color,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.riskLevel.localizedLabel(l10n),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: item.riskLevel.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_compareMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (_compareMode) return rowContent;

    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteItem(item.id),
      child: rowContent,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic spec,
  ) {
    final l10n = context.l10n;
    final checklist = (spec.captureQualityChecklist as List<String>).take(3);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      widget.category.accentColor.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    color: widget.category.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.hubEmptyTitle(widget.category.localizedTitle(l10n)),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.hubEmptySubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (checklist.isNotEmpty) ...[
              const Divider(height: 22),
              Text(
                l10n.atlasCaptureProtocolTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              for (final tip in checklist)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
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
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanComparisonSheet extends StatelessWidget {
  const _ScanComparisonSheet({
    required this.older,
    required this.newer,
    required this.scrollController,
  });

  final AnalysisResult older;
  final AnalysisResult newer;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final df = DateFormat('dd.MM.yyyy HH:mm');

    final allMetricKeys = <String>{
      ...older.clinicalMetrics.keys,
      ...newer.clinicalMetrics.keys,
    }.toList();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Row(
          children: [
            Icon(Icons.compare_rounded, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.hubCompareSheetTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Side-by-Side Photos / Color Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CompareColumn(
                tag: l10n.hubCompareOlderLabel,
                result: older,
                dateText: df.format(older.createdAt),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompareColumn(
                tag: l10n.hubCompareNewerLabel,
                result: newer,
                dateText: df.format(newer.createdAt),
              ),
            ),
          ],
        ),

        // Quantitative Clinical Metrics Side-by-Side Table
        if (allMetricKeys.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            l10n.hubCompareMetricsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.65),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(flex: 2, child: SizedBox()),
                      Expanded(
                        child: Text(
                          l10n.hubCompareOlderLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.hubCompareNewerLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < allMetricKeys.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            localizedClinicalMetricKey(allMetricKeys[i], l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            older.clinicalMetrics[allMetricKeys[i]] ?? '—',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            newer.clinicalMetrics[allMetricKeys[i]] ?? '—',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
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
        ],
      ],
    );
  }
}

class _CompareColumn extends StatelessWidget {
  const _CompareColumn({
    required this.tag,
    required this.result,
    required this.dateText,
  });

  final String tag;
  final AnalysisResult result;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasPhoto =
        result.imagePath != null && File(result.imagePath!).existsSync();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  result.riskLevel.icon,
                  size: 16,
                  color: result.riskLevel.color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: hasPhoto
                  ? () => PhotoZoomViewer.show(
                        context,
                        imagePath: result.imagePath!,
                        title: result.localizedSummaryTitle(l10n),
                        subtitle: dateText,
                      )
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1.05,
                  child: hasPhoto
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(result.imagePath!),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.zoom_in_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: result.dominantColor,
                          alignment: Alignment.center,
                          child: Icon(
                            result.category.icon,
                            size: 32,
                            color: result.dominantColor.computeLuminance() > 0.5
                                ? Colors.black54
                                : Colors.white70,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              result.localizedSummaryTitle(l10n),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.riskLevel.localizedLabel(l10n),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: result.riskLevel.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
