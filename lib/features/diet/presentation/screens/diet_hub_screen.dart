import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/photo_zoom_viewer.dart';
import 'package:visualcheckup/features/diet/data/ai_meal_calorie_analyzer.dart';
import 'package:visualcheckup/features/diet/data/diet_repository.dart';
import 'package:visualcheckup/features/diet/data/diet_template_catalog.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';
import 'package:visualcheckup/features/diet/presentation/widgets/weight_trend_chart.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';
import 'package:visualcheckup/features/subscription/presentation/screens/pro_paywall_screen.dart';

typedef PlatePhotoPicker = Future<Uint8List?> Function(ImageSource source);

/// Complete 4-tab Diet & AI Plate Calorie Hub:
/// 1. My Diet (Active Diet daily menu, date span, Uydum / Uymadım compliance)
/// 2. Diet Plans (6 ready-made clinical templates + Start Diet with custom dates)
/// 3. Weight (Diet weight tracking with trend chart & target weight line)
/// 4. AI Calories (Snap plate photo or type meal — works independently of any diet!)
class DietHubScreen extends StatefulWidget {
  const DietHubScreen({
    super.key,
    required this.repository,
    this.calorieAnalyzer,
    this.platePhotoPicker,
    this.subscriptionRepository,
    this.userId,
    this.userEmail,
    this.initialTabIndex = 0,
  });

  final DietRepository repository;
  final MealCalorieAnalyzer? calorieAnalyzer;
  final PlatePhotoPicker? platePhotoPicker;
  final SubscriptionRepository? subscriptionRepository;
  final String? userId;
  final String? userEmail;
  final int initialTabIndex;

  @override
  State<DietHubScreen> createState() => _DietHubScreenState();
}

class _DietHubScreenState extends State<DietHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MealCalorieAnalyzer _calorieAnalyzer;
  late final SubscriptionRepository _subscriptionRepository;

  bool _loading = true;
  ActiveDietPlan? _activePlan;
  List<DietTemplate> _customTemplates = const [];
  DateTime _selectedDate = DateTime.now();
  Map<MealSlot, DietMealComplianceLog> _dayCompliance = const {};
  DietComplianceSummary _complianceSummary = const DietComplianceSummary(
    followedCount: 0,
    notFollowedCount: 0,
  );
  List<DietWeightEntry> _weightEntries = const [];
  List<CalorieScanEntry> _calorieScans = const [];
  UserSubscriptionState _subscription = const UserSubscriptionState();

  // AI Plate Scanner tab state
  final TextEditingController _foodDescController = TextEditingController();
  MealSlot _scanMealSlot = MealSlot.lunch;
  Uint8List? _pendingPlateBytes;
  CalorieAnalysisResult? _pendingResult;
  double _portionScale = 1.0;
  bool _analyzingPlate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _calorieAnalyzer = widget.calorieAnalyzer ?? GeminiMealCalorieAnalyzer();
    _subscriptionRepository =
        widget.subscriptionRepository ?? SubscriptionRepository();
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _foodDescController.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    String? email = widget.userEmail;
    String? uid = widget.userId;
    if (email == null) {
      try {
        email = fb.FirebaseAuth.instance.currentUser?.email;
        uid ??= fb.FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {}
    }
    return AdminUtils.isAdmin(email: email, uid: uid);
  }

  int get _usedScansToday =>
      _subscriptionRepository.countPlateCalorieScansToday(_calorieScans);

  int get _dailyScanLimit => _subscriptionRepository.dailyPlateCalorieLimit(
        subscription: _subscription,
        isAdmin: _isAdmin,
      );

  int get _remainingScansToday =>
      _subscriptionRepository.remainingPlateCalorieScansToday(
        scans: _calorieScans,
        subscription: _subscription,
        isAdmin: _isAdmin,
      );

  bool get _canScanPlateCalorie => _subscriptionRepository.canScanPlateCalorie(
        scans: _calorieScans,
        subscription: _subscription,
        isAdmin: _isAdmin,
      );

  Future<void> _openProPaywall({bool triggeredByLimit = false}) async {
    final upgraded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProPaywallScreen(
          repository: _subscriptionRepository,
          userId: widget.userId,
          triggeredByLabLimit: triggeredByLimit,
        ),
      ),
    );
    if (upgraded == true) {
      await _loadAll();
    }
  }

  Future<void> _showPlateCalorieQuotaExceededSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPro = _subscription.isPro;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.no_meals_rounded,
                  size: 32,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Günlük Tabak Kalori Limiti Doldu',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isPro
                    ? 'Pro üyelikte günlük 20 tabak kalori analizi hakkınızı doldurdunuz. Haklarınız her gece yarısı sıfırlanır.'
                    : 'Ücretsiz planda günde en fazla 2 tabak kalori analizi yapabilirsiniz. Bugünkü 2 hakkınızı kullandınız.\n\nVisualCheckUp Pro ile günde 20 tabağa kadar AI kalori analizi yapabilir, sınırsız tahlil analizi ve reklamsız deneyimin tadını çıkarabilirsiniz.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              if (!isPro) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    key: const Key('diet_upgrade_pro_button'),
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      _openProPaywall(triggeredByLimit: true);
                    },
                    icon: const Icon(Icons.workspace_premium_rounded),
                    label: const Text(
                      'Pro\'ya Yükselt (Günde 20 Hak)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  child: const Text('Anladım'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadAll() async {
    final plan = await widget.repository.loadActivePlan();
    final customTemplates = await widget.repository.loadCustomTemplates();
    final weights = await widget.repository.loadWeightEntries();
    final scans = await widget.repository.loadCalorieScans();
    final sub =
        await _subscriptionRepository.loadSubscription(uid: widget.userId);
    Map<MealSlot, DietMealComplianceLog> dayMap = const {};
    DietComplianceSummary summary = const DietComplianceSummary(
      followedCount: 0,
      notFollowedCount: 0,
    );
    if (plan != null) {
      dayMap = await widget.repository.getDayComplianceMap(
        planId: plan.id,
        date: _selectedDate,
      );
      summary = await widget.repository.getComplianceSummary(plan.id);
    }

    if (!mounted) return;
    setState(() {
      _activePlan = plan;
      _customTemplates = customTemplates;
      _weightEntries = weights;
      _calorieScans = scans;
      _dayCompliance = dayMap;
      _complianceSummary = summary;
      _subscription = sub;
      _loading = false;
    });
  }

  Future<void> _openCreateCustomDietSheet() async {
    final latestWeight =
        _weightEntries.isNotEmpty ? _weightEntries.first.weightKg : null;
    final created = await showModalBottomSheet<
        ({DietTemplate template, ActiveDietPlan plan})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CreateCustomDietSheet(
        initialWeightKg: latestWeight,
      ),
    );
    if (created == null || !mounted) return;
    await widget.repository.saveCustomTemplate(created.template);
    await widget.repository.saveActivePlan(created.plan);
    if (created.plan.startWeightKg != null) {
      await widget.repository.addWeightEntry(
        DietWeightEntry(
          id: 'w_start_${created.plan.id}',
          weightKg: created.plan.startWeightKg!,
          date: created.plan.startDate,
          planId: created.plan.id,
          note: created.plan.title,
        ),
      );
    }
    setState(() => _selectedDate = DateTime.now());
    await _loadAll();
    if (!mounted) return;
    _tabController.animateTo(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.dietStartedToast)),
    );
  }

  Future<void> _changeSelectedDate(int deltaDays) async {
    final next = _selectedDate.add(Duration(days: deltaDays));
    setState(() => _selectedDate = next);
    if (_activePlan != null) {
      final dayMap = await widget.repository.getDayComplianceMap(
        planId: _activePlan!.id,
        date: next,
      );
      if (!mounted) return;
      setState(() => _dayCompliance = dayMap);
    }
  }

  Future<void> _markMealCompliance(
    MealSlot slot,
    MealComplianceStatus status,
  ) async {
    final plan = _activePlan;
    if (plan == null) return;
    final current = _dayCompliance[slot]?.status;
    final nextStatus =
        current == status ? MealComplianceStatus.pending : status;
    await widget.repository.setMealCompliance(
      planId: plan.id,
      date: _selectedDate,
      slot: slot,
      status: nextStatus,
    );
    await _loadAll();
  }

  Future<void> _openStartDietSheet(DietTemplate template) async {
    final latestWeight =
        _weightEntries.isNotEmpty ? _weightEntries.first.weightKg : null;
    final result = await showModalBottomSheet<ActiveDietPlan>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _StartDietModalSheet(
        template: template,
        initialWeightKg: latestWeight,
      ),
    );
    if (result == null || !mounted) return;
    await widget.repository.saveActivePlan(result);
    if (result.startWeightKg != null) {
      await widget.repository.addWeightEntry(
        DietWeightEntry(
          id: 'w_start_${result.id}',
          weightKg: result.startWeightKg!,
          date: result.startDate,
          planId: result.id,
          note: result.title,
        ),
      );
    }
    setState(() => _selectedDate = DateTime.now());
    await _loadAll();
    if (!mounted) return;
    _tabController.animateTo(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.dietStartedToast)),
    );
  }

  Future<void> _confirmEndDiet() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dietEndDiet),
        content: Text(l10n.dietEndDietConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dietEndDiet),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.repository.endActivePlan();
    await _loadAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dietEndedToast)),
    );
  }

  Future<void> _openAddWeightDialog() async {
    final l10n = context.l10n;
    final saved = await showDialog<DietWeightEntry>(
      context: context,
      builder: (_) => _AddWeightDialog(
        initialWeightKg:
            _weightEntries.isNotEmpty ? _weightEntries.first.weightKg : null,
        activePlanId: _activePlan?.id,
      ),
    );

    if (saved == null || !mounted) return;
    await widget.repository.addWeightEntry(saved);
    await _loadAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.dietWeightSaved)),
    );
  }

  // ── AI Plate Calorie Scanner Actions ──────────────────────────────────────

  Future<void> _pickAndAnalyzePlate(ImageSource source) async {
    if (!_canScanPlateCalorie) {
      await _showPlateCalorieQuotaExceededSheet(context);
      return;
    }
    try {
      Uint8List? bytes;
      if (widget.platePhotoPicker != null) {
        bytes = await widget.platePhotoPicker!(source);
      } else {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          imageQuality: 85,
        );
        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes == null || !mounted) return;
      setState(() {
        _pendingPlateBytes = bytes;
        _analyzingPlate = true;
        _portionScale = 1.0;
      });
      final lang = Localizations.localeOf(context).languageCode;
      final res = await _calorieAnalyzer.analyzePlate(
        imageBytes: bytes,
        foodDescription: _foodDescController.text.trim(),
        mealSlot: _scanMealSlot,
        languageCode: lang,
      );
      if (!mounted) return;
      setState(() {
        _pendingResult = res;
        _analyzingPlate = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _analyzingPlate = false);
    }
  }

  Future<void> _analyzeFromTextOnly() async {
    final desc = _foodDescController.text.trim();
    if (desc.isEmpty && _pendingPlateBytes == null) return;
    if (!_canScanPlateCalorie) {
      await _showPlateCalorieQuotaExceededSheet(context);
      return;
    }
    setState(() {
      _analyzingPlate = true;
      _portionScale = 1.0;
    });
    final lang = Localizations.localeOf(context).languageCode;
    final res = await _calorieAnalyzer.analyzePlate(
      imageBytes: _pendingPlateBytes,
      foodDescription: desc,
      mealSlot: _scanMealSlot,
      languageCode: lang,
    );
    if (!mounted) return;
    setState(() {
      _pendingResult = res;
      _analyzingPlate = false;
    });
  }

  Future<void> _savePendingCalorieScan() async {
    final base = _pendingResult;
    if (base == null) return;
    final scaled = base.scaled(_portionScale);
    final now = DateTime.now();
    final id = 'scan_${now.microsecondsSinceEpoch}';

    String? photoPath;
    if (_pendingPlateBytes != null) {
      photoPath = await widget.repository.savePlatePhoto(
        scanId: id,
        imageBytes: _pendingPlateBytes!,
      );
    }

    final entry = CalorieScanEntry(
      id: id,
      createdAt: now,
      dateKey: ActiveDietPlan.dateKeyFor(now),
      mealSlot: _scanMealSlot,
      dishName: scaled.dishName,
      totalCalories: scaled.totalCalories,
      proteinG: scaled.proteinG,
      carbsG: scaled.carbsG,
      fatG: scaled.fatG,
      fiberG: scaled.fiberG,
      items: scaled.items,
      healthScore: scaled.healthScore,
      healthComment: scaled.healthComment,
      photoPath: photoPath,
      analyzedByAi: scaled.analyzedByAi,
      linkedDietPlanId: _activePlan?.id,
    );

    await widget.repository.saveCalorieScan(entry);
    if (!mounted) return;
    setState(() {
      _pendingPlateBytes = null;
      _pendingResult = null;
      _portionScale = 1.0;
      _foodDescController.clear();
    });
    await _loadAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.dietMealLoggedToast)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dietMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              icon: const Icon(Icons.restaurant_menu_rounded, size: 19),
              text: l10n.dietTabActive,
            ),
            Tab(
              icon: const Icon(Icons.auto_stories_rounded, size: 19),
              text: l10n.dietTabTemplates,
            ),
            Tab(
              icon: const Icon(Icons.monitor_weight_outlined, size: 19),
              text: l10n.dietTabWeight,
            ),
            Tab(
              icon: const Icon(Icons.camera_enhance_rounded, size: 19),
              text: l10n.dietTabCalories,
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveDietTab(context),
                _buildTemplatesTab(context),
                _buildWeightTab(context),
                _buildAiCaloriesTab(context),
              ],
            ),
    );
  }

  // ── TAB 1: Active Diet & Daily Compliance (Uydum / Uymadım) ──────────────

  Widget _buildActiveDietTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = _activePlan;

    if (plan == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 56,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.dietNoActiveTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.dietNoActiveBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const Key('diet_browse_templates_button'),
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.auto_stories_rounded),
                label: Text(l10n.dietBrowseTemplates),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _openCreateCustomDietSheet,
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.dietCreateCustom),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _tabController.animateTo(3),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(l10n.dietCalorieQuickTitle),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final dayPlan = plan.planForDate(_selectedDate);
    final accent = plan.goalType.accentColor;
    final dateFmt = DateFormat('dd.MM.yyyy');
    final isToday = ActiveDietPlan.dateKeyFor(_selectedDate) ==
        ActiveDietPlan.dateKeyFor(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // Active Diet Summary Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, accent.withValues(alpha: 0.78)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(plan.goalType.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'change') {
                        _tabController.animateTo(1);
                      } else if (value == 'end') {
                        _confirmEndDiet();
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'change',
                        child: Text(l10n.dietRestartOrChange),
                      ),
                      PopupMenuItem(
                        value: 'end',
                        child: Text(l10n.dietEndDiet),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${dateFmt.format(plan.startDate)} → ${dateFmt.format(plan.endDate)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: plan.progressRatio(now),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BannerChip(
                    label: l10n.dietDayProgress(
                      plan.currentDayNumber(now),
                      plan.totalDays,
                    ),
                  ),
                  _BannerChip(
                    label: l10n.dietDaysLeft(plan.remainingDays(now)),
                  ),
                  _BannerChip(
                    label: l10n.dietComplianceRate(
                      _complianceSummary.compliancePercent,
                    ),
                  ),
                  _BannerChip(
                    label: '${plan.dailyTargetCalories} kcal',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Date switcher + Water target
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _changeSelectedDate(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isToday
                            ? '${l10n.dietTodayLabel} • ${dateFmt.format(_selectedDate)}'
                            : dateFmt.format(_selectedDate),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${dayPlan.totalCalories} kcal • ${l10n.dietWaterTarget(dayPlan.waterLiters.toStringAsFixed(1))}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _changeSelectedDate(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ),

        if (dayPlan.dailyTip.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dayPlan.dailyTip,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Meals with Big "Uydum" / "Uymadım" Compliance Buttons
        for (final meal in dayPlan.meals) ...[
          _DietMealCard(
            meal: meal,
            status:
                _dayCompliance[meal.slot]?.status ?? MealComplianceStatus.pending,
            onFollow: () =>
                _markMealCompliance(meal.slot, MealComplianceStatus.followed),
            onMiss: () => _markMealCompliance(
              meal.slot,
              MealComplianceStatus.notFollowed,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Quick jump to AI Plate Calorie Photo Scanner
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _tabController.animateTo(3),
          icon: const Icon(Icons.camera_alt_rounded),
          label: Text(l10n.dietCalorieQuickTitle),
        ),
      ],
    );
  }

  // ── TAB 2: Ready-Made & Custom Diet Templates ("Hazır Diyetler") ─────────

  Widget _buildTemplatesTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildTemplateCard(DietTemplate tpl) {
      final accent = tpl.goalType.accentColor;
      final isCurrent = _activePlan?.templateId == tpl.id;
      final sampleDay = tpl.days.isNotEmpty
          ? tpl.days.first
          : const DietDayPlan(dayIndex: 1, meals: []);

      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isCurrent
                ? accent
                : colorScheme.outlineVariant.withValues(alpha: 0.55),
            width: isCurrent ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.16),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: accent.withValues(alpha: 0.18),
                        child: Icon(
                          tpl.isCustom
                              ? Icons.edit_note_rounded
                              : tpl.goalType.icon,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tpl.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.dietDurationDays(tpl.recommendedDays)} • ~${tpl.dailyTargetCalories} kcal',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (tpl.isCustom)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: colorScheme.error,
                          ),
                          onPressed: () async {
                            await widget.repository.deleteCustomTemplate(tpl.id);
                            await _loadAll();
                          },
                        ),
                    ],
                  ),
                  if (tpl.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      tpl.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (tpl.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in tpl.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Expandable Rules & Sample Menu Preview
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  tpl.rules.isNotEmpty
                      ? '${l10n.dietSampleMenuTitle} & ${l10n.dietRulesTitle}'
                      : l10n.dietSampleMenuTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (final rule in tpl.rules)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (tpl.rules.isNotEmpty) const Divider(height: 16),
                  for (final m in sampleDay.meals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              m.slot.localizedLabel(l10n),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              m.calories > 0
                                  ? '${m.title} (${m.calories} kcal)'
                                  : m.title,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Start Diet CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  key: Key('start_diet_${tpl.id}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _openStartDietSheet(tpl),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    l10n.dietStartDiet,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // Prominent "Create My Own Diet" card
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryTeal, AppTheme.secondaryMint],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              key: const Key('diet_create_custom_button'),
              borderRadius: BorderRadius.circular(22),
              onTap: _openCreateCustomDietSheet,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dietCreateCustom,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.dietCreateCustomSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (_customTemplates.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.dietCustomTemplatesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final tpl in _customTemplates) buildTemplateCard(tpl),
          const SizedBox(height: 6),
        ],

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.dietReadyTemplatesTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final tpl in DietTemplateCatalog.templates) buildTemplateCard(tpl),
      ],
    );
  }

  // ── TAB 3: Diet Weight Tracking ("Kilo Takibi") ──────────────────────────

  Widget _buildWeightTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = _activePlan;
    final latestWeight =
        _weightEntries.isNotEmpty ? _weightEntries.first.weightKg : null;
    final startWeight = plan?.startWeightKg ??
        (_weightEntries.isNotEmpty ? _weightEntries.last.weightKg : null);
    final targetWeight = plan?.targetWeightKg;
    final delta = (latestWeight != null && startWeight != null)
        ? latestWeight - startWeight
        : null;
    final dateFmt = DateFormat('dd.MM.yyyy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        // KPI Summary Row
        Row(
          children: [
            Expanded(
              child: _WeightStatTile(
                label: l10n.dietWeightCurrent,
                value: latestWeight != null
                    ? '${latestWeight.toStringAsFixed(1)} kg'
                    : '—',
                accent: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WeightStatTile(
                label: l10n.dietWeightTarget,
                value: targetWeight != null
                    ? '${targetWeight.toStringAsFixed(1)} kg'
                    : '—',
                accent: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WeightStatTile(
                label: l10n.dietWeightChange,
                value: delta != null
                    ? '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg'
                    : '—',
                accent: delta != null && delta <= 0
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFC8553D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_weightEntries.isNotEmpty) ...[
          WeightTrendChart(
            entries: _weightEntries,
            targetWeightKg: targetWeight,
            accentColor: plan?.goalType.accentColor ?? AppTheme.primaryTeal,
          ),
          const SizedBox(height: 14),
        ],

        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            key: const Key('diet_add_weight_button'),
            onPressed: _openAddWeightDialog,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              l10n.dietWeightAdd,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_weightEntries.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: 44,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.dietWeightEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (int i = 0; i < _weightEntries.length; i++) ...[
            Builder(
              builder: (context) {
                final entry = _weightEntries[i];
                final prev =
                    i + 1 < _weightEntries.length ? _weightEntries[i + 1] : null;
                final diff = prev != null ? entry.weightKg - prev.weightKg : null;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryTeal.withValues(alpha: 0.14),
                      child: const Icon(
                        Icons.monitor_weight_rounded,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${entry.weightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        if (diff != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (diff <= 0
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFC8553D))
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: diff <= 0
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFC8553D),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      entry.note.isNotEmpty
                          ? '${dateFmt.format(entry.date)} • ${entry.note}'
                          : dateFmt.format(entry.date),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      onPressed: () async {
                        await widget.repository.deleteWeightEntry(entry.id);
                        await _loadAll();
                      },
                    ),
                  ),
                );
              },
            ),
          ],
      ],
    );
  }

  Widget _buildCalorieQuotaBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_isAdmin) {
      return Container(
        key: const Key('diet_plate_calorie_quota_badge'),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_rounded, size: 20, color: Color(0xFFD97706)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Yönetici Hesabı: Sınırsız AI Tabak Kalori Analizi 👑',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isPro = _subscription.isPro;
    final limit = _dailyScanLimit;
    final used = _usedScansToday;
    final remaining = _remainingScansToday;

    final badgeColor =
        isPro ? const Color(0xFF0F766E) : const Color(0xFF2563EB);

    return Container(
      key: const Key('diet_plate_calorie_quota_badge'),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPro ? Icons.workspace_premium_rounded : Icons.flash_on_rounded,
            size: 20,
            color: badgeColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro
                      ? 'Pro Üyelik: Günlük Tabak Analizi'
                      : 'Ücretsiz Plan: Günlük Tabak Analizi',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark
                        ? colorScheme.onSurface
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kalan Hak: $remaining / $limit (Bugün $used yapıldı)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isPro)
            TextButton(
              key: const Key('diet_quota_upgrade_chip'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              ),
              onPressed: () => _openProPaywall(triggeredByLimit: false),
              child: Text(
                'Pro (20/gün) ↗',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── TAB 4: AI Plate Calorie Calculator (Works with OR without a Diet!) ───

  Widget _buildAiCaloriesTab(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final todayKey = ActiveDietPlan.dateKeyFor(DateTime.now());
    final todayScans =
        _calorieScans.where((s) => s.dateKey == todayKey).toList();
    final todayKcal =
        todayScans.fold<int>(0, (sum, s) => sum + s.totalCalories);
    final todayProtein =
        todayScans.fold<double>(0, (sum, s) => sum + s.proteinG);
    final todayCarbs = todayScans.fold<double>(0, (sum, s) => sum + s.carbsG);
    final todayFat = todayScans.fold<double>(0, (sum, s) => sum + s.fatG);
    final targetKcal = _activePlan?.dailyTargetCalories ?? 2000;
    final scaledPreview = _pendingResult?.scaled(_portionScale);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
      children: [
        _buildCalorieQuotaBadge(context),
        // Today's Calorie & Macro Summary Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F766E), Color(0xFF1A9E96)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.dietTodayTotalCalories,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$todayKcal / $targetKcal kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (todayKcal / targetKcal).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  Text(
                    '${l10n.dietProtein}: ${todayProtein.round()}g',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${l10n.dietCarbs}: ${todayCarbs.round()}g',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${l10n.dietFat}: ${todayFat.round()}g',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Scanner Input Card (Independent or Diet-linked)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dietCalorieTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dietCalorieSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Meal slot selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final slot in const [
                        MealSlot.breakfast,
                        MealSlot.lunch,
                        MealSlot.afternoonSnack,
                        MealSlot.dinner,
                      ])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            avatar: Icon(slot.icon, size: 16),
                            label: Text(slot.localizedLabel(l10n)),
                            selected: _scanMealSlot == slot,
                            onSelected: (_) =>
                                setState(() => _scanMealSlot = slot),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Camera & Gallery Plate Photo Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          key: const Key('diet_snap_plate_camera_button'),
                          onPressed: _analyzingPlate
                              ? null
                              : () => _pickAndAnalyzePlate(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_rounded),
                          label: Text(l10n.dietSnapPlateCamera),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          key: const Key('diet_pick_plate_gallery_button'),
                          onPressed: _analyzingPlate
                              ? null
                              : () => _pickAndAnalyzePlate(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(l10n.dietPickPlateGallery),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Optional meal description / text calculator
                TextField(
                  key: const Key('diet_food_desc_field'),
                  controller: _foodDescController,
                  decoration: InputDecoration(
                    labelText: l10n.dietFoodDescLabel,
                    hintText: l10n.dietFoodDescHint,
                    prefixIcon: const Icon(Icons.restaurant_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.tonalIcon(
                    key: const Key('diet_calculate_text_button'),
                    onPressed: _analyzingPlate ? null : _analyzeFromTextOnly,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(l10n.dietCalculateFromText),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Loading indicator
        if (_analyzingPlate) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.dietAnalyzingPlate,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // AI Analysis Preview Result Card
        if (scaledPreview != null && !_analyzingPlate) ...[
          const SizedBox(height: 16),
          Card(
            key: const Key('diet_calorie_result_card'),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: AppTheme.primaryTeal.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        scaledPreview.analyzedByAi
                            ? Icons.auto_awesome_rounded
                            : Icons.analytics_outlined,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scaledPreview.analyzedByAi
                              ? l10n.dietAiPoweredBadge
                              : l10n.dietOnDeviceBadge,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.primaryTeal,
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
                          color: const Color(0xFF16A34A).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.dietHealthScore(scaledPreview.healthScore),
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_pendingPlateBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 170,
                        child: Image.memory(
                          _pendingPlateBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          scaledPreview.dishName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${scaledPreview.totalCalories} kcal',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC8553D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Macro breakdown row
                  Row(
                    children: [
                      Expanded(
                        child: _MacroChip(
                          label: l10n.dietProtein,
                          grams: scaledPreview.proteinG,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroChip(
                          label: l10n.dietCarbs,
                          grams: scaledPreview.carbsG,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroChip(
                          label: l10n.dietFat,
                          grams: scaledPreview.fatG,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroChip(
                          label: l10n.dietFiber,
                          grams: scaledPreview.fiberG,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Portion scale selector
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.dietPortionScale,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      for (final factor in const [0.5, 1.0, 1.5, 2.0])
                        ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          label: Text('${factor}x'),
                          selected: _portionScale == factor,
                          onSelected: (_) =>
                              setState(() => _portionScale = factor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── INGREDIENTS BREAKDOWN LIST ──
                  Container(
                    key: const Key('diet_meal_ingredients_card'),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 18,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yemekteki Malzemeler (${scaledPreview.items.length})',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Porsiyon ve kalori dökümü',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // List of individual ingredients
                        for (int i = 0; i < scaledPreview.items.length; i++) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F766E)
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scaledPreview.items[i].name,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${scaledPreview.items[i].portion} • P:${scaledPreview.items[i].proteinG.round()}g K:${scaledPreview.items[i].carbsG.round()}g Y:${scaledPreview.items[i].fatG.round()}g',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC8553D)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${scaledPreview.items[i].calories} kcal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFFC8553D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (i < scaledPreview.items.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                height: 1,
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── PROMINENT TOTAL CALORIES SUMMARY ──
                  Container(
                    key: const Key('diet_total_calories_summary'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF0F766E)
                                    .withValues(alpha: 0.35),
                                const Color(0xFF134E4A)
                                    .withValues(alpha: 0.45),
                              ]
                            : [
                                const Color(0xFFF0FDFA),
                                const Color(0xFFCCFBF1),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            const Color(0xFF0D9488).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calculate_rounded,
                              size: 22,
                              color: Color(0xFF0D9488),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOPLAM KALORİ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                  Text(
                                    '${scaledPreview.items.length} malzemenin toplamı',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC8553D),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC8553D)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Toplam: ${scaledPreview.totalCalories} kcal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(
                          height: 1,
                          color: const Color(0xFF0D9488)
                              .withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MacroItem(
                              label: l10n.dietProtein,
                              value: '${scaledPreview.proteinG.round()}g',
                              color: const Color(0xFF2563EB),
                            ),
                            _MacroItem(
                              label: l10n.dietCarbs,
                              value: '${scaledPreview.carbsG.round()}g',
                              color: const Color(0xFFD97706),
                            ),
                            _MacroItem(
                              label: l10n.dietFat,
                              value: '${scaledPreview.fatG.round()}g',
                              color: const Color(0xFFDC2626),
                            ),
                            _MacroItem(
                              label: l10n.dietFiber,
                              value: '${scaledPreview.fiberG.round()}g',
                              color: const Color(0xFF16A34A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (scaledPreview.healthComment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        scaledPreview.healthComment,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      key: const Key('diet_save_meal_log_button'),
                      onPressed: _savePendingCalorieScan,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        l10n.dietSaveMealLog,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        Text(
          l10n.dietRecentScans,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),

        if (_calorieScans.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.dietNoScansYet,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final scan in _calorieScans.take(25))
            _CalorieScanHistoryTile(
              scan: scan,
              onDelete: () async {
                await widget.repository.deleteCalorieScan(scan.id);
                await _loadAll();
              },
            ),
      ],
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DietMealCard extends StatelessWidget {
  const _DietMealCard({
    required this.meal,
    required this.status,
    required this.onFollow,
    required this.onMiss,
  });

  final DietMealItem meal;
  final MealComplianceStatus status;
  final VoidCallback onFollow;
  final VoidCallback onMiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFollowed = status == MealComplianceStatus.followed;
    final isMissed = status == MealComplianceStatus.notFollowed;
    final borderColor = isFollowed
        ? const Color(0xFF16A34A)
        : isMissed
            ? const Color(0xFFDC2626)
            : colorScheme.outlineVariant.withValues(alpha: 0.55);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor.withValues(alpha: isFollowed || isMissed ? 0.65 : 1),
          width: isFollowed || isMissed ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      meal.slot.accentColor.withValues(alpha: 0.14),
                  child: Icon(
                    meal.slot.icon,
                    color: meal.slot.accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    meal.slot.localizedLabel(l10n),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: meal.slot.accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meal.portion,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (meal.alternatives.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.dietAlternativesLabel}: ${meal.alternatives}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: Key('meal_follow_${meal.slot.name}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isFollowed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF16A34A).withValues(alpha: 0.12),
                      foregroundColor:
                          isFollowed ? Colors.white : const Color(0xFF16A34A),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onFollow,
                    icon: const Icon(Icons.check_circle_rounded, size: 19),
                    label: Text(
                      l10n.dietFollowed,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: Key('meal_miss_${meal.slot.name}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isMissed
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFDC2626).withValues(alpha: 0.10),
                      foregroundColor:
                          isMissed ? Colors.white : const Color(0xFFDC2626),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onMiss,
                    icon: const Icon(Icons.cancel_rounded, size: 19),
                    label: Text(
                      l10n.dietNotFollowed,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
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

class _WeightStatTile extends StatelessWidget {
  const _WeightStatTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${grams.toStringAsFixed(0)}g',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CalorieScanHistoryTile extends StatelessWidget {
  const _CalorieScanHistoryTile({
    required this.scan,
    required this.onDelete,
  });

  final CalorieScanEntry scan;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final photoPath = scan.photoPath;
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();
    final timeStr = DateFormat('dd.MM HH:mm').format(scan.createdAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: hasPhoto
              ? () => PhotoZoomViewer.show(
                    context,
                    imagePath: photoPath,
                    title: scan.dishName,
                    subtitle: '${scan.totalCalories} kcal',
                  )
              : null,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: scan.mealSlot.accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? Image.file(File(photoPath), fit: BoxFit.cover)
                : Icon(
                    scan.mealSlot.icon,
                    color: scan.mealSlot.accentColor,
                  ),
          ),
        ),
        title: Text(
          scan.dishName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${scan.mealSlot.localizedLabel(l10n)} • $timeStr',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'P:${scan.proteinG.round()}g  K:${scan.carbsG.round()}g  Y:${scan.fatG.round()}g',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (scan.items.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Malzemeler: ${scan.items.map((i) => '${i.name} (${i.calories} kcal)').join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF5EEAD4)
                      : const Color(0xFF0F766E),
                ),
              ),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${scan.totalCalories} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFFC8553D),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartDietModalSheet extends StatefulWidget {
  const _StartDietModalSheet({
    required this.template,
    this.initialWeightKg,
  });

  final DietTemplate template;
  final double? initialWeightKg;

  @override
  State<_StartDietModalSheet> createState() => _StartDietModalSheetState();
}

class _StartDietModalSheetState extends State<_StartDietModalSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _startWeightCtrl;
  late final TextEditingController _targetWeightCtrl;
  late final TextEditingController _caloriesCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate =
        _startDate.add(Duration(days: widget.template.recommendedDays - 1));
    _startWeightCtrl = TextEditingController(
      text: widget.initialWeightKg != null
          ? widget.initialWeightKg!.toStringAsFixed(1)
          : '',
    );
    _targetWeightCtrl = TextEditingController();
    _caloriesCtrl = TextEditingController(
      text: widget.template.dailyTargetCalories.toString(),
    );
  }

  @override
  void dispose() {
    _startWeightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStart ? DateTime(2024) : _startDate,
      lastDate: DateTime(2032),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate
              .add(Duration(days: widget.template.recommendedDays - 1));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _confirmStart() {
    final startW = double.tryParse(
      _startWeightCtrl.text.trim().replaceAll(',', '.'),
    );
    final targetW = double.tryParse(
      _targetWeightCtrl.text.trim().replaceAll(',', '.'),
    );
    final kcal = int.tryParse(_caloriesCtrl.text.trim()) ??
        widget.template.dailyTargetCalories;

    final plan = ActiveDietPlan(
      id: 'diet_${DateTime.now().microsecondsSinceEpoch}',
      templateId: widget.template.id,
      title: widget.template.title,
      goalType: widget.template.goalType,
      startDate: _startDate,
      endDate: _endDate,
      dailyTargetCalories: kcal.clamp(900, 4500),
      startWeightKg: startW,
      targetWeightKg: targetW,
      isActive: true,
      days: widget.template.days,
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(plan);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd.MM.yyyy');
    final totalDays = _endDate.difference(_startDate).inDays + 1;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.template.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.dietDurationDays(totalDays < 1 ? 1 : totalDays),
              style: theme.textTheme.labelLarge?.copyWith(
                color: widget.template.goalType.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Start & End Date Pickers
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(
                      '${l10n.dietStartDate}\n${dateFmt.format(_startDate)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.event_available_rounded, size: 18),
                    label: Text(
                      '${l10n.dietEndDate}\n${dateFmt.format(_endDate)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Start Weight & Target Weight
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('start_diet_weight_field'),
                    controller: _startWeightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.dietStartWeight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    key: const Key('start_diet_target_weight_field'),
                    controller: _targetWeightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.dietTargetWeight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _caloriesCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.dietDailyCalorieTarget,
                prefixIcon: const Icon(Icons.local_fire_department_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                key: const Key('confirm_start_diet_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.template.goalType.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _confirmStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  l10n.dietStartDiet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWeightDialog extends StatefulWidget {
  const _AddWeightDialog({
    this.initialWeightKg,
    this.activePlanId,
  });

  final double? initialWeightKg;
  final String? activePlanId;

  @override
  State<_AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<_AddWeightDialog> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _noteCtrl;
  DateTime _pickedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.initialWeightKg != null
          ? widget.initialWeightKg!.toStringAsFixed(1)
          : '',
    );
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.dietWeightAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('diet_weight_input'),
            controller: _weightCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.dietWeightField,
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              labelText: l10n.dietWeightNote,
              hintText: l10n.dietWeightNoteHint,
              prefixIcon: const Icon(Icons.note_alt_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_rounded, size: 20),
            title: Text(DateFormat('dd.MM.yyyy').format(_pickedDate)),
            trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _pickedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (d != null && mounted) {
                setState(() => _pickedDate = d);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('diet_weight_save_button'),
          onPressed: () {
            final parsed = double.tryParse(
              _weightCtrl.text.trim().replaceAll(',', '.'),
            );
            if (parsed == null || parsed < 20 || parsed > 300) return;
            Navigator.of(context).pop(
              DietWeightEntry(
                id: 'w_${DateTime.now().microsecondsSinceEpoch}',
                weightKg: parsed,
                date: _pickedDate,
                planId: widget.activePlanId,
                note: _noteCtrl.text.trim(),
              ),
            );
          },
          child: Text(l10n.dietWeightAdd),
        ),
      ],
    );
  }
}

class _CreateCustomDietSheet extends StatefulWidget {
  const _CreateCustomDietSheet({this.initialWeightKg});

  final double? initialWeightKg;

  @override
  State<_CreateCustomDietSheet> createState() => _CreateCustomDietSheetState();
}

class _CreateCustomDietSheetState extends State<_CreateCustomDietSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _startWeightCtrl;
  late final TextEditingController _targetWeightCtrl;
  late final TextEditingController _caloriesCtrl;
  late final Map<MealSlot, TextEditingController> _mealTitleCtrls;
  late final Map<MealSlot, TextEditingController> _mealCalCtrls;

  late DateTime _startDate;
  late DateTime _endDate;
  String? _mealError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 13));
    _nameCtrl = TextEditingController();
    _startWeightCtrl = TextEditingController(
      text: widget.initialWeightKg != null
          ? widget.initialWeightKg!.toStringAsFixed(1)
          : '',
    );
    _targetWeightCtrl = TextEditingController();
    _caloriesCtrl = TextEditingController(text: '1600');
    _mealTitleCtrls = {
      for (final slot in MealSlot.values) slot: TextEditingController(),
    };
    _mealCalCtrls = {
      for (final slot in MealSlot.values) slot: TextEditingController(),
    };
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startWeightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _caloriesCtrl.dispose();
    for (final c in _mealTitleCtrls.values) {
      c.dispose();
    }
    for (final c in _mealCalCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime(2024) : _startDate,
      lastDate: DateTime(2032),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 13));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final meals = <DietMealItem>[];
    for (final slot in MealSlot.values) {
      final text = _mealTitleCtrls[slot]!.text.trim();
      if (text.isEmpty) continue;
      final kcal = int.tryParse(_mealCalCtrls[slot]!.text.trim()) ?? 0;
      meals.add(
        DietMealItem(
          slot: slot,
          title: text,
          portion: '',
          calories: kcal,
          proteinG: 0,
          carbsG: 0,
          fatG: 0,
        ),
      );
    }

    if (meals.isEmpty) {
      setState(() => _mealError = l10n.dietCustomAtLeastOneMeal);
      return;
    }

    final totalDays = (_endDate.difference(_startDate).inDays + 1).clamp(1, 365);
    final sumMealCals = meals.fold<int>(0, (s, m) => s + m.calories);
    final dailyTarget = int.tryParse(_caloriesCtrl.text.trim()) ??
        (sumMealCals > 0 ? sumMealCals : 1600);
    final startW = double.tryParse(
      _startWeightCtrl.text.trim().replaceAll(',', '.'),
    );
    final targetW = double.tryParse(
      _targetWeightCtrl.text.trim().replaceAll(',', '.'),
    );

    final dayPlan = DietDayPlan(
      dayIndex: 1,
      meals: meals,
      waterLiters: 2.0,
    );
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final tplId = 'tpl_custom_$stamp';
    final name = _nameCtrl.text.trim();

    final template = DietTemplate(
      id: tplId,
      title: name,
      subtitle: meals.map((m) => m.title).take(2).join(' • '),
      goalType: DietGoalType.mediterranean,
      recommendedDays: totalDays,
      dailyTargetCalories: dailyTarget.clamp(900, 4500),
      tags: const [],
      rules: const [],
      days: [dayPlan],
      isCustom: true,
    );

    final plan = ActiveDietPlan(
      id: 'diet_$stamp',
      templateId: tplId,
      title: name,
      goalType: DietGoalType.mediterranean,
      startDate: _startDate,
      endDate: _endDate,
      dailyTargetCalories: dailyTarget.clamp(900, 4500),
      startWeightKg: startW,
      targetWeightKg: targetW,
      isActive: true,
      days: [dayPlan],
      createdAt: DateTime.now(),
    );

    Navigator.of(context).pop((template: template, plan: plan));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFmt = DateFormat('dd.MM.yyyy');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.dietCreateCustom,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dietCreateCustomSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Diet Plan Name
                        TextFormField(
                          key: const Key('custom_diet_name_field'),
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.dietCustomNameLabel,
                            hintText: l10n.dietCustomNameHint,
                            prefixIcon: const Icon(Icons.restaurant_menu_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.dietCustomNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Start & End Date Pickers
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isStart: true),
                                icon: const Icon(Icons.event_rounded, size: 18),
                                label: Text(
                                  '${l10n.dietStartDate}\n${dateFmt.format(_startDate)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(isStart: false),
                                icon: const Icon(
                                  Icons.event_available_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  '${l10n.dietEndDate}\n${dateFmt.format(_endDate)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Start & Target Weight + Daily Target Calories
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _startWeightCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.dietStartWeight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _targetWeightCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.dietTargetWeight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _caloriesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.dietDailyCalorieTarget,
                            prefixIcon:
                                const Icon(Icons.local_fire_department_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Meal Inputs for Each Meal Slot
                        for (final slot in MealSlot.values) ...[
                          Row(
                            children: [
                              Icon(
                                slot.icon,
                                size: 18,
                                color: slot.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slot.localizedLabel(l10n),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: slot.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  key: Key('custom_meal_${slot.name}_field'),
                                  controller: _mealTitleCtrls[slot],
                                  onChanged: (_) {
                                    if (_mealError != null) {
                                      setState(() => _mealError = null);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: l10n.dietCustomMealHint,
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _mealCalCtrls[slot],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'kcal',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (_mealError != null) ...[
                          Text(
                            _mealError!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                // Pinned Start Diet Button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        key: const Key('save_custom_diet_button'),
                        onPressed: _submit,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          l10n.dietStartDiet,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


