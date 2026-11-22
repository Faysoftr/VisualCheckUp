import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/history_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/quick_color_card_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/ai_settings_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/app_drawer.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_card.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/disclaimer_dialog.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/follow_up_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/vitals_tracker_screen.dart';
import 'package:visualcheckup/features/settings/presentation/screens/settings_screen.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';
import 'package:visualcheckup/features/skin/presentation/screens/skin_check_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.analyzer,
    required this.historyRepository,
    required this.currentUser,
    required this.themeController,
    required this.onSignOut,
    required this.onDeleteAccount,
    this.localeController,
    this.labsVitalsRepository,
  });

  final ColorHealthAnalyzer analyzer;
  final HistoryRepository historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;
  final AuthUser currentUser;
  final ThemeController themeController;
  final LocaleController? localeController;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LabsVitalsRepository _labsVitalsRepository;
  List<AnalysisResult> _allHistory = const [];
  List<LabReportRecord> _labReports = const [];
  List<BloodPressureReading> _bpReadings = const [];
  List<BloodSugarReading> _sugarReadings = const [];
  Set<FollowUpTrack> _enabledTracks = FollowUpTrackX.defaultEnabled();

  int get _labReportCount => _labReports.length;
  int get _vitalsCount => _bpReadings.length + _sugarReadings.length;

  List<AnalysisResult> get _recent => _allHistory.take(3).toList();

  @override
  void initState() {
    super.initState();
    _labsVitalsRepository =
        widget.labsVitalsRepository ?? LabsVitalsRepository();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadDashboardData();
    final accepted = await widget.historyRepository.isDisclaimerAccepted();
    if (!accepted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ok = await DisclaimerDialog.show(context);
        if (ok) {
          await widget.historyRepository.setDisclaimerAccepted();
        }
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final history = await widget.historyRepository.loadHistory();
    final tracks = await widget.historyRepository.loadFollowUpTracks();
    final labs = await _labsVitalsRepository.loadLabReports();
    final bp = await _labsVitalsRepository.loadBloodPressureReadings();
    final sugar = await _labsVitalsRepository.loadBloodSugarReadings();
    if (!mounted) return;
    setState(() {
      _allHistory = history;
      _enabledTracks = tracks;
      _labReports = labs;
      _bpReadings = bp;
      _sugarReadings = sugar;
    });
  }

  Future<void> _openLabReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LabReportsScreen(repository: _labsVitalsRepository),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openVitalsTracker({int initialTabIndex = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VitalsTrackerScreen(
          repository: _labsVitalsRepository,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openSkinSubModule(SkinConcernType concern) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SkinCheckScreen(
          historyRepository: widget.historyRepository,
          initialConcern: concern,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openCategory(CheckCategory category) async {
    if (category == CheckCategory.skinCondition) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SkinCheckScreen(
            historyRepository: widget.historyRepository,
          ),
        ),
      );
      await _loadDashboardData();
      return;
    }

    if (category.supportsQuickColorCard) {
      await _showColorCardOrCameraChoice(category);
      return;
    }

    await _openCameraFor(category);
  }

  Future<void> _openCameraFor(CheckCategory category) async {
    final hybridAnalyzer = HybridHealthAnalyzer(
      fallbackAnalyzer: widget.analyzer,
      aiClient: GeminiVisionAiClient.fromEnvironment(),
      cacheRepository: widget.historyRepository,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: category,
          analyzer: hybridAnalyzer,
          historyRepository: widget.historyRepository,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openQuickColorCard(CheckCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuickColorCardScreen(
          category: category,
          historyRepository: widget.historyRepository,
          analyzer: widget.analyzer,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _showColorCardOrCameraChoice(CheckCategory category) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        final sheetL10n = sheetContext.l10n;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetL10n.checkMethodTitle(
                    category.localizedTitle(sheetL10n),
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sheetL10n.checkMethodSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: const Icon(
                        Icons.palette_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      sheetL10n.colorCardRecommendedTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      sheetL10n.colorCardRecommendedSubtitle,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(sheetContext).pop('card'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.photo_camera_outlined,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      sheetL10n.cameraMeasureTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      sheetL10n.cameraMeasureSubtitle,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(sheetContext).pop('camera'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;
    if (choice == 'card') {
      await _openQuickColorCard(category);
    } else if (choice == 'camera') {
      await _openCameraFor(category);
    }
  }

  Future<void> _openQuickColorCardPicker() async {
    final selected = await showModalBottomSheet<CheckCategory>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final sheetL10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheetL10n.menuQuickColorCard,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                for (final cat in const [
                  CheckCategory.urine,
                  CheckCategory.stool,
                ])
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: cat.accentColor.withValues(alpha: 0.14),
                      child: Icon(cat.icon, color: cat.accentColor),
                    ),
                    title: Text(
                      cat.localizedTitle(sheetL10n),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(cat.localizedSubtitle(sheetL10n)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(sheetContext).pop(cat),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      await _openQuickColorCard(selected);
    }
  }

  Future<void> _openFollowUpPlan() async {
    await FollowUpSheet.show(
      context,
      historyRepository: widget.historyRepository,
      history: _allHistory,
      bloodPressureReadings: _bpReadings,
      bloodSugarReadings: _sugarReadings,
      labReports: _labReports,
      onStartTrack: _startTrack,
    );
    await _loadDashboardData();
  }

  Future<void> _startTrack(FollowUpTrack track) async {
    switch (track) {
      case FollowUpTrack.hydrationDaily:
        await _openQuickColorCard(CheckCategory.urine);
        return;
      case FollowUpTrack.stoolWeekly:
        await _openQuickColorCard(CheckCategory.stool);
        return;
      case FollowUpTrack.bloodPressureDaily:
        await _openVitalsTracker(initialTabIndex: 0);
        return;
      case FollowUpTrack.bloodSugarDaily:
        await _openVitalsTracker(initialTabIndex: 1);
        return;
      case FollowUpTrack.labReportQuarterly:
        await _openLabReports();
        return;
      case FollowUpTrack.eyeWeekly:
      case FollowUpTrack.tongueWeekly:
      case FollowUpTrack.nailTongueWeekly:
      case FollowUpTrack.faceBiWeekly:
      case FollowUpTrack.skinMonthly:
        await _openCategory(track.primaryCategory);
        return;
    }
  }

  Future<void> _openSettings() async {
    final controller = widget.localeController ?? LocaleController();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          themeController: widget.themeController,
          localeController: controller,
          historyRepository: widget.historyRepository,
          labsVitalsRepository: _labsVitalsRepository,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(
          historyRepository: widget.historyRepository,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openReferenceGuidePicker() async {
    final selected = await showModalBottomSheet<CheckCategory>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final sheetL10n = sheetContext.l10n;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              Text(
                sheetL10n.menuReferenceGuide,
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                sheetL10n.referenceGuideSubtitle,
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              for (final category in CheckCategory.values)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: category.accentColor.withValues(alpha: 0.14),
                    child: Icon(
                      category.icon,
                      color: category.accentColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category.localizedTitle(sheetL10n),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(category.localizedSubtitle(sheetL10n)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(sheetContext).pop(category),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      await ModuleReferenceSheet.show(context, selected);
    }
  }

  String _greetingText(BuildContext context) {
    final l10n = context.l10n;
    if (widget.currentUser.isGuest) {
      return l10n.guestGreeting;
    }
    final firstName = widget.currentUser.displayName.trim().split(' ').first;
    return l10n.userGreeting(firstName);
  }

  FollowUpTrackStatus? _nextHighlightedTrack() {
    final active = FollowUpEvaluator.evaluate(
      enabledTracks: _enabledTracks,
      history: _allHistory,
      bloodPressureReadings: _bpReadings,
      bloodSugarReadings: _sugarReadings,
      labReports: _labReports,
    ).where((s) => s.enabled).toList();
    if (active.isEmpty) return null;
    for (final status in active) {
      if (status.isDueNow) return status;
    }
    return active.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final nextTrack = _nextHighlightedTrack();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentUser: widget.currentUser,
        themeController: widget.themeController,
        localeController: widget.localeController,
        onOpenSettings: _openSettings,
        onOpenCategory: _openCategory,
        onOpenSkinConcern: _openSkinSubModule,
        onOpenSkinModule: () => _openCategory(CheckCategory.skinCondition),
        onOpenLabReports: _openLabReports,
        onOpenVitalsTracker: _openVitalsTracker,
        onOpenQuickColorCard: _openQuickColorCardPicker,
        onOpenFollowUpPlan: _openFollowUpPlan,
        onOpenHistory: _openHistory,
        onOpenReferenceGuide: _openReferenceGuidePicker,
        onOpenAiSettings: () => AiSettingsSheet.show(
          context,
          historyRepository: widget.historyRepository,
        ),
        onOpenDisclaimer: () => DisclaimerDialog.show(context),
        onSignOut: widget.onSignOut,
        onDeleteAccount: widget.onDeleteAccount,
      ),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.jpg',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openHistory,
            tooltip: l10n.tooltipHistory,
            icon: const Icon(Icons.history_rounded),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Tooltip(
              message: l10n.tooltipAccountMenu,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: isDark
                      ? colorScheme.primaryContainer
                      : AppTheme.primaryTeal.withValues(alpha: 0.14),
                  child: Text(
                    widget.currentUser.initials,
                    style: TextStyle(
                      color: isDark
                          ? colorScheme.onPrimaryContainer
                          : AppTheme.primaryTeal,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/app_bg.jpg',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCanvas.withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          CustomScrollView(
            slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                          : AppTheme.softMintTint,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _greetingText(context),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? colorScheme.onSurface
                                      : const Color(0xFF0E3434),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(
                                  alpha: isDark ? 0.2 : 0.85,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 13,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.currentUser.provider.label,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: colorScheme.primary,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.disclaimerShort,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? colorScheme.onSurfaceVariant
                                      : const Color(0xFF1F4D4D),
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_repeat_rounded,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.followUpCardTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _openFollowUpPlan,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                icon: const Icon(Icons.tune_rounded, size: 16),
                                label: Text(l10n.followUpSelectEdit),
                              ),
                            ],
                          ),
                          const Divider(height: 14),
                          if (nextTrack != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(
                                    nextTrack.track.icon,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nextTrack.track.localizedTitle(l10n),
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        nextTrack.localizedStatusLabel(l10n),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: nextTrack.isDueNow
                                              ? colorScheme.primary
                                              : const Color(0xFF1B8A5A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (nextTrack.latestValueSummary !=
                                          null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          nextTrack.latestValueSummary!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: () =>
                                      _startTrack(nextTrack.track),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  child: Text(l10n.followUpStart),
                                ),
                              ],
                            )
                          else
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _openFollowUpPlan,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_task_rounded,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.followUpEmptyHint,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
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
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeCategoriesTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeCategoriesSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = CheckCategory.values[index];
                  return CategoryCard(
                    category: category,
                    onTap: () => _openCategory(category),
                  );
                },
                childCount: CheckCategory.values.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeLabsVitalsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeLabsVitalsSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DashboardModuleCard(
                          icon: Icons.biotech_outlined,
                          accentColor: AppTheme.primaryTeal,
                          title: l10n.homeLabsCardTitle,
                          subtitle: _labReportCount == 0
                              ? l10n.homeLabsCardEmpty
                              : l10n.homeLabsCardCount(_labReportCount),
                          onTap: _openLabReports,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DashboardModuleCard(
                          icon: Icons.monitor_heart_outlined,
                          accentColor: const Color(0xFFC8553D),
                          title: l10n.homeVitalsCardTitle,
                          subtitle: _vitalsCount == 0
                              ? l10n.homeVitalsCardEmpty
                              : l10n.homeVitalsCardCount(_vitalsCount),
                          onTap: () => _openVitalsTracker(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_recent.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.homeRecentChecks,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: _openHistory,
                      child: Text(l10n.seeAll),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: _recent.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _recent[index];
                  final dateText =
                      DateFormat('dd.MM HH:mm').format(item.createdAt);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: item.dominantColor,
                        radius: 18,
                      ),
                      title: Text(
                        item.summaryTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${item.category.title} • $dateText'),
                      trailing: Icon(
                        item.riskLevel.icon,
                        color: item.riskLevel.color,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ResultScreen(
                              result: item,
                              historyRepository: widget.historyRepository,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ] else
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
        ],
      ),
    );
  }
}

class _DashboardModuleCard extends StatelessWidget {
  const _DashboardModuleCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: accentColor.withValues(alpha: 0.14),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
