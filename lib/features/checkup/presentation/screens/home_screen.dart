import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
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
  });

  final ColorHealthAnalyzer analyzer;
  final HistoryRepository historyRepository;
  final AuthUser currentUser;
  final ThemeController themeController;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<AnalysisResult> _allHistory = const [];
  Set<FollowUpTrack> _enabledTracks = FollowUpTrackX.defaultEnabled();

  List<AnalysisResult> get _recent => _allHistory.take(3).toList();

  @override
  void initState() {
    super.initState();
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
    if (!mounted) return;
    setState(() {
      _allHistory = history;
      _enabledTracks = tracks;
    });
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: category,
          analyzer: widget.analyzer,
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
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category.title} • Kontrol Yöntemi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fotoğraf çekmeden 2 saniyede renk kartından seçebilir veya kamera ölçümünü kullanabilirsiniz.',
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
                    title: const Text(
                      'Kamerasız Renk Kartı (Önerilen)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Fotoğraf çekmeden gizli ve hızlı kayıt (2 sn)',
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
                    title: const Text(
                      'Kamera ile Renk Ölçümü',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Beyaz referans kalibrasyonu ile otomatik ölçüm',
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamerasız Renk Kartı',
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
                      cat.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(cat.subtitle),
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
      onStartTrack: _startTrack,
    );
    await _loadDashboardData();
  }

  Future<void> _startTrack(FollowUpTrack track) async {
    if (track == FollowUpTrack.hydrationDaily) {
      await _openQuickColorCard(CheckCategory.urine);
      return;
    }
    await _openCategory(track.primaryCategory);
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
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              Text(
                'Görsel Referans Rehberi',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sağlıklı ve dikkat gerektiren görsel bulguları incelemek için modül seçin.',
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
                    category.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(category.subtitle),
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

  String _greetingText() {
    if (widget.currentUser.isGuest) {
      return 'Cilt & Görsel Sağlık Takibi';
    }
    final firstName = widget.currentUser.displayName.trim().split(' ').first;
    return 'Merhaba, $firstName';
  }

  FollowUpTrackStatus? _nextHighlightedTrack() {
    final active = FollowUpEvaluator.evaluate(
      enabledTracks: _enabledTracks,
      history: _allHistory,
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
    final nextTrack = _nextHighlightedTrack();

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentUser: widget.currentUser,
        themeController: widget.themeController,
        onOpenSkinModule: () => _openCategory(CheckCategory.skinCondition),
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
        title: const Text('VisualCheckUp'),
        actions: [
          IconButton(
            onPressed: _openHistory,
            tooltip: 'Geçmiş',
            icon: const Icon(Icons.history_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Hesap ve Menü',
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
      body: CustomScrollView(
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
                                _greetingText(),
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
                                MedicalDisclaimer.shortBanner,
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
                  if (nextTrack != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                        child: Row(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextTrack.track.title,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nextTrack.statusLabel,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: nextTrack.isDueNow
                                          ? colorScheme.primary
                                          : const Color(0xFF1B8A5A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => _startTrack(nextTrack.track),
                              child: const Text('Başla'),
                            ),
                            IconButton(
                              tooltip: 'Takip Planını Düzenle',
                              onPressed: _openFollowUpPlan,
                              icon: const Icon(
                                Icons.tune_rounded,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Kontrol Kategorileri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamera veya kamerasız renk kartı ile görsel değişim takibi yapın.',
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
          if (_recent.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Kontroller',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: _openHistory,
                      child: const Text('Tümünü Gör'),
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
    );
  }
}
