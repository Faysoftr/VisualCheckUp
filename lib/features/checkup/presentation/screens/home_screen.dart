import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/profile/family_profile_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/health_drawer_background.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:visualcheckup/features/admin/presentation/widgets/global_announcement_and_promo_banners.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/category_hub_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/history_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/quick_color_card_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/ai_settings_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/app_drawer.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_card.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/disclaimer_dialog.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/follow_up_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/home_social_showcase.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/data/wellness_wall_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/domain/wellness_wall_models.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_community_hub_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/health_profile_detail_screen.dart';
import 'package:visualcheckup/features/community/presentation/screens/my_health_profile_screen.dart';
import 'package:visualcheckup/features/diet/data/diet_repository.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';
import 'package:visualcheckup/features/diet/presentation/screens/diet_hub_screen.dart';
import 'package:visualcheckup/features/doctors/data/doctor_repository.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_application_screen.dart';
import 'package:visualcheckup/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';
import 'package:visualcheckup/features/growth/presentation/screens/growth_bmi_screen.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/lab_reports_screen.dart';
import 'package:visualcheckup/features/labs_vitals/presentation/screens/vitals_tracker_screen.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/medications/presentation/screens/medication_reminders_screen.dart';
import 'package:visualcheckup/features/settings/presentation/screens/settings_screen.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';
import 'package:visualcheckup/features/skin/presentation/screens/skin_check_screen.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/presentation/screens/pro_paywall_screen.dart';
import 'package:visualcheckup/features/support/presentation/widgets/donation_support_dialog.dart';

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
    this.profileController,
    this.labsVitalsRepository,
    this.medicationRepository,
    this.dietRepository,
    this.alarmScheduler,
    this.adminRepository,
    this.doctorRepository,
    this.subscriptionRepository,
  });

  final ColorHealthAnalyzer analyzer;
  final HistoryRepository historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;
  final MedicationReminderRepository? medicationRepository;
  final DietRepository? dietRepository;
  final MedicationAlarmScheduler? alarmScheduler;
  final AdminRepository? adminRepository;
  final DoctorRepository? doctorRepository;
  final SubscriptionRepository? subscriptionRepository;
  final AuthUser currentUser;
  final ThemeController themeController;
  final LocaleController? localeController;
  final FamilyProfileController? profileController;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LabsVitalsRepository _labsVitalsRepository;
  late final MedicationReminderRepository _medicationRepository;
  late final DietRepository _dietRepository;
  List<AnalysisResult> _allHistory = const [];
  List<LabReportRecord> _labReports = const [];
  List<BloodPressureReading> _bpReadings = const [];
  List<BloodSugarReading> _sugarReadings = const [];
  List<MedicationReminder> _medReminders = const [];
  Map<String, MedicationDoseLog> _todayMedStatuses = const {};
  ActiveDietPlan? _activeDietPlan;
  DietComplianceSummary _dietCompliance = const DietComplianceSummary(
    followedCount: 0,
    notFollowedCount: 0,
  );
  Set<FollowUpTrack> _enabledTracks = FollowUpTrackX.defaultEnabled();

  int get _labReportCount => _labReports.length;
  int get _vitalsCount => _bpReadings.length + _sugarReadings.length;

  List<MedicationReminder> get _todayMedReminders {
    final weekday = DateTime.now().weekday;
    return _medReminders
        .where((r) => r.enabled && r.isScheduledForWeekday(weekday))
        .toList();
  }

  int get _todayMedTakenCount => _todayMedReminders
      .where(
        (r) => _todayMedStatuses[r.id]?.status == MedicationDoseStatus.taken,
      )
      .length;

  int get _activeMedCount => _medReminders.where((r) => r.enabled).length;

  List<AnalysisResult> get _recent => _allHistory.take(3).toList();

  List<DoctorProfile> _featuredDoctors =
      DoctorRepository.starterVerifiedDoctors();
  List<HealthCommunityProfile> _communityMembers =
      HealthCommunityRepository.starterGlobalProfiles();
  List<WellnessWallPost> _latestWallPosts = WellnessWallRepository.starterPosts();

  @override
  void initState() {
    super.initState();
    _labsVitalsRepository =
        widget.labsVitalsRepository ?? LabsVitalsRepository();
    _medicationRepository =
        widget.medicationRepository ?? MedicationReminderRepository();
    _dietRepository = widget.dietRepository ?? DietRepository();
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(HealthDrawerBackground.lightAssetPath), context);
    precacheImage(const AssetImage(HealthDrawerBackground.darkAssetPath), context);
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
    final meds = await _medicationRepository.loadReminders();
    final medStatuses = await _medicationRepository.getTodayStatusMap();
    final activeDiet = await _dietRepository.loadActivePlan();
    final dietSummary = activeDiet != null
        ? await _dietRepository.getComplianceSummary(activeDiet.id)
        : const DietComplianceSummary(followedCount: 0, notFollowedCount: 0);
    final doctorRepo = widget.doctorRepository ?? DoctorRepository();
    final doctors = await doctorRepo.searchDoctors();
    final commRepo = HealthCommunityRepository();
    final members = await commRepo.discoverProfiles(myUid: widget.currentUser.id);
    final wallPosts = await WellnessWallRepository().loadPosts();
    if (!mounted) return;
    setState(() {
      _allHistory = history;
      _enabledTracks = tracks;
      _labReports = labs;
      _bpReadings = bp;
      _sugarReadings = sugar;
      _medReminders = meds;
      _todayMedStatuses = medStatuses;
      _activeDietPlan = activeDiet;
      _dietCompliance = dietSummary;
      if (doctors.isNotEmpty) _featuredDoctors = doctors;
      if (members.isNotEmpty) _communityMembers = members;
      if (wallPosts.isNotEmpty) _latestWallPosts = wallPosts;
    });
  }

  Future<void> _openDietHub({int initialTabIndex = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DietHubScreen(
          repository: _dietRepository,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openMedicationReminders() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicationRemindersScreen(
          repository: _medicationRepository,
          scheduler: widget.alarmScheduler,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openMyProfile() async {
    final isAdmin = AdminUtils.isAdmin(
      email: widget.currentUser.email,
      uid: widget.currentUser.id,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyHealthProfileScreen(
          currentUser: widget.currentUser,
          repository: HealthCommunityRepository(),
          adminRepository: widget.adminRepository,
          onOpenAdminPanel: isAdmin ? _openAdminPanel : null,
        ),
      ),
    );
  }

  Future<void> _openMemberProfile(HealthCommunityProfile member) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthProfileDetailScreen(
          profile: member,
          myUid: widget.currentUser.id,
          myDisplayName: widget.currentUser.displayName,
          repository: HealthCommunityRepository(),
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openHealthCommunity({int initialTabIndex = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthCommunityHubScreen(
          currentUser: widget.currentUser,
          repository: HealthCommunityRepository(),
          adminRepository: widget.adminRepository,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openAdminPanel() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminPanelScreen(
          repository: widget.adminRepository ?? AdminRepository(),
          doctorRepository: widget.doctorRepository,
        ),
      ),
    );
  }

  Future<void> _openDoctorSearch({String initialCountryCode = 'ALL'}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorSearchScreen(
          currentUser: widget.currentUser,
          repository: widget.doctorRepository ?? DoctorRepository(),
          initialCountryCode: initialCountryCode,
        ),
      ),
    );
  }

  Future<void> _openDoctorApplication() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorApplicationScreen(
          currentUser: widget.currentUser,
          repository: widget.doctorRepository ?? DoctorRepository(),
        ),
      ),
    );
  }

  Future<void> _openProSubscription() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProPaywallScreen(
          repository: widget.subscriptionRepository ?? SubscriptionRepository(),
          userId: widget.currentUser.id,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openLabReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LabReportsScreen(
          repository: _labsVitalsRepository,
          subscriptionRepository: widget.subscriptionRepository,
          userId: widget.currentUser.id,
        ),
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

  Future<void> _openGrowthBmi({int initialTabIndex = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GrowthBmiScreen(initialTabIndex: initialTabIndex),
      ),
    );
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryHubScreen(
          category: category,
          historyRepository: widget.historyRepository,
          analyzer: widget.analyzer,
          labsVitalsRepository: _labsVitalsRepository,
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
          profileController: widget.profileController,
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
        onOpenMedicationReminders: _openMedicationReminders,
        onOpenDietMenu: () => _openDietHub(initialTabIndex: 0),
        onOpenAiCalorieScanner: () => _openDietHub(initialTabIndex: 3),
        onOpenMyProfile: _openMyProfile,
        onOpenHealthCommunity: () => _openHealthCommunity(initialTabIndex: 0),
        onOpenCommunityMessages: () => _openHealthCommunity(initialTabIndex: 3),
        onOpenCommunityWall: () => _openHealthCommunity(initialTabIndex: 1),
        onOpenCommunityGroups: () => _openHealthCommunity(initialTabIndex: 2),
        onOpenDoctorSearch: () => _openDoctorSearch(),
        onOpenDoctorApplication: _openDoctorApplication,
        onOpenProSubscription: _openProSubscription,
        onOpenAdminPanel: AdminUtils.isAdmin(
          email: widget.currentUser.email,
          uid: widget.currentUser.id,
        )
            ? _openAdminPanel
            : null,
        onOpenDonate: () => DonationSupportDialog.show(context),
        onOpenGrowthBmi: () => _openGrowthBmi(initialTabIndex: 0),
        onOpenChildrenGrowth: () => _openGrowthBmi(initialTabIndex: 1),
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
        backgroundColor: isDark
            ? AppTheme.darkCanvas
            : const Color(0xFFEFF7F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 96,
        titleSpacing: 6,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FrostedCircleAction(
                isDark: isDark,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 38, height: 38),
                  icon: const Icon(Icons.menu_rounded, size: 21),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              const SizedBox(width: 6),
              _FrostedCircleAction(
                isDark: isDark,
                child: IconButton(
                  key: const Key('home_donate_appbar_button'),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 38, height: 38),
                  icon: const Icon(
                    Icons.volunteer_activism_rounded,
                    size: 20,
                    color: Color(0xFFE11D48),
                  ),
                  tooltip: l10n.donateTooltip,
                  onPressed: () => DonationSupportDialog.show(context),
                ),
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/app_logo.jpg',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF0E2929),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _FrostedCircleAction(
            isDark: isDark,
            child: IconButton(
              key: const Key('home_med_alarm_appbar_button'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 38, height: 38),
              onPressed: _openMedicationReminders,
              tooltip: l10n.medMenuTitle,
              icon: const Icon(
                Icons.alarm_on_rounded,
                size: 20,
                color: Color(0xFFC8553D),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _FrostedCircleAction(
            isDark: isDark,
            child: IconButton(
              key: const Key('home_messages_appbar_button'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 38, height: 38),
              onPressed: () => _openHealthCommunity(initialTabIndex: 3),
              tooltip: l10n.sfbMyMessages,
              icon: const Icon(Icons.mail_outline_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: Tooltip(
              message: l10n.tooltipAccountMenu,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryTeal, AppTheme.secondaryMint],
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: isDark
                        ? const Color(0xFF122323)
                        : Colors.white,
                    child: Text(
                      widget.currentUser.initials,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6CE5DC)
                            : AppTheme.primaryTeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppTheme.darkCanvas.withValues(alpha: 0.86),
                        AppTheme.darkCanvas.withValues(alpha: 0.94),
                      ]
                    : [
                        const Color(0xFFEFF7F6).withValues(alpha: 0.72),
                        const Color(0xFFF5F9F8).withValues(alpha: 0.78),
                      ],
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 0. Admin-managed Global Announcement & Top Health Banner
                      GlobalAnnouncementBanner(
                        repository: widget.adminRepository,
                        margin: const EdgeInsets.only(bottom: 10),
                      ),
                      HealthPromotionBanner(
                        placement: PromotionPlacement.homeTop,
                        repository: widget.adminRepository,
                        margin: const EdgeInsets.only(bottom: 10),
                      ),

                      // 1. Signature Deep-Teal Gradient Hero Card
                      _HeroWellnessCard(
                        greeting: _greetingText(context),
                        providerLabel:
                            widget.currentUser.provider.localizedLabel(l10n),
                        disclaimer: l10n.disclaimerShort,
                        checksCount: _allHistory.length,
                        labsCount: _labReportCount,
                        vitalsCount: _vitalsCount,
                        checksLabel: l10n.menuHistory,
                        labsLabel: l10n.menuLabReports,
                        vitalsLabel: l10n.menuVitalsTracker,
                        onTapChecks: _openHistory,
                        onTapLabs: _openLabReports,
                        onTapVitals: () => _openVitalsTracker(),
                      ),
                      const SizedBox(height: 12),

                      // 2. Elevated Modern Follow-Up Plan Card
                      _FollowUpModernCard(
                        title: l10n.followUpCardTitle,
                        editLabel: l10n.followUpSelectEdit,
                        startLabel: l10n.followUpStart,
                        emptyHint: l10n.followUpEmptyHint,
                        nextTrack: nextTrack,
                        trackTitle: nextTrack?.track.localizedTitle(l10n),
                        statusLabel: nextTrack?.localizedStatusLabel(l10n),
                        onEdit: _openFollowUpPlan,
                        onStart: nextTrack == null
                            ? null
                            : () => _startTrack(nextTrack.track),
                      ),
                      const SizedBox(height: 12),

                      // 2b. Prominent Medication & Alarm Reminder Banner Card
                      _MedicationQuickBanner(
                        title: l10n.medTitle,
                        subtitle: _activeMedCount == 0
                            ? l10n.medHomeCardEmpty
                            : _todayMedReminders.isNotEmpty
                                ? l10n.medHomeCardTodaySummary(
                                    _todayMedTakenCount,
                                    _todayMedReminders.length,
                                  )
                                : l10n.medHomeCardActiveCount(_activeMedCount),
                        badgeCount: _activeMedCount,
                        onTap: _openMedicationReminders,
                      ),
                      const SizedBox(height: 18),

                      // 3. Editorial Section Header for Categories
                      _SectionHeader(
                        title: l10n.homeCategoriesTitle,
                        subtitle: l10n.homeCategoriesSubtitle,
                        badgeText: '${CheckCategory.values.length}',
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Floating Porcelain 2-Column Category Grid
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
                    mainAxisSpacing: 13,
                    crossAxisSpacing: 13,
                    childAspectRatio: 1.04,
                  ),
                ),
              ),

              // 5. Doctors by Country, Pro & Labs/Vitals Bento Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 5a. Birthday & Glowing Daily Health Tip Card (SFB "Tarihte Bugün" style)
                      BirthdayCelebrationCard(
                        displayName: widget.currentUser.displayName,
                      ),
                      const SfbDailyHealthTipCard(),
                      const SizedBox(height: 12),

                      // 5b. VisualCheckUp Pro Quick Banner
                      Card(
                        key: const Key('home_pro_card'),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onTap: _openProSubscription,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.16),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          title: Text(
                            l10n.proMenuTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            l10n.proMenuSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _SectionHeader(
                        title: l10n.homeLabsVitalsTitle,
                        subtitle: l10n.homeLabsVitalsSubtitle,
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
                          const SizedBox(width: 13),
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
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardModuleCard(
                              icon: Icons.monitor_weight_outlined,
                              accentColor: const Color(0xFF2B7BBA),
                              title: 'Boy, Kilo & VKİ',
                              subtitle: 'Vücut kitle indeksi & ideal kilo',
                              onTap: () => _openGrowthBmi(initialTabIndex: 0),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: _DashboardModuleCard(
                              icon: Icons.child_care_outlined,
                              accentColor: const Color(0xFF7B5EA7),
                              title: 'Çocuklarım',
                              subtitle: '0–18 yaş boy & kilo skalası',
                              onTap: () => _openGrowthBmi(initialTabIndex: 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardModuleCard(
                              icon: Icons.restaurant_menu_rounded,
                              accentColor: const Color(0xFF16A34A),
                              title: l10n.dietHomeCardTitle,
                              subtitle: _activeDietPlan == null
                                  ? l10n.dietHomeCardEmpty
                                  : l10n.dietHomeCardActive(
                                      _activeDietPlan!
                                          .currentDayNumber(DateTime.now()),
                                      _activeDietPlan!.totalDays,
                                      _dietCompliance.compliancePercent,
                                    ),
                              onTap: () => _openDietHub(
                                initialTabIndex:
                                    _activeDietPlan == null ? 1 : 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: _DashboardModuleCard(
                              icon: Icons.camera_enhance_rounded,
                              accentColor: const Color(0xFFD97706),
                              title: l10n.dietCalorieQuickTitle,
                              subtitle: l10n.dietCalorieQuickSubtitle,
                              onTap: () => _openDietHub(initialTabIndex: 3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      _DashboardModuleCard(
                        icon: Icons.public_rounded,
                        accentColor: AppTheme.primaryTeal,
                        title: l10n.commMenuTitle,
                        subtitle: l10n.commHomeSubtitle,
                        onTap: () => _openHealthCommunity(initialTabIndex: 0),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Recent Checks Timeline
              if (_recent.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SectionHeader(
                            title: l10n.homeRecentChecks,
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.separated(
                    itemCount: _recent.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _recent[index];
                      final dateText =
                          DateFormat('dd.MM HH:mm').format(item.createdAt);
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF162323).withValues(alpha: 0.94)
                              : Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? colorScheme.outlineVariant
                                    .withValues(alpha: 0.3)
                                : Colors.white,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: item.riskLevel.color
                                      .withValues(alpha: 0.45),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: item.dominantColor,
                                radius: 16,
                              ),
                            ),
                            title: Text(
                              item.localizedSummaryTitle(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            subtitle: Text(
                              '${item.category.localizedTitle(l10n)} • $dateText',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: item.riskLevel.color
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.riskLevel.icon,
                                size: 18,
                                color: item.riskLevel.color,
                              ),
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
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 7. Social Formula Bank Community & Doctors Live Showcase Feed
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SfbVerifiedDoctorsSection(
                        doctors: _featuredDoctors,
                        onSeeAll: () => _openDoctorSearch(),
                        onApplyDoctor: _openDoctorApplication,
                        onTapCountry: (code) =>
                            _openDoctorSearch(initialCountryCode: code),
                      ),
                      const SizedBox(height: 14),
                      SfbNewMembersSection(
                        members: _communityMembers,
                        onTapMember: _openMemberProfile,
                        onSeeAll: () => _openHealthCommunity(initialTabIndex: 0),
                      ),
                      const SizedBox(height: 14),
                      SfbActiveMembersSection(
                        members: _communityMembers,
                        onTapMember: _openMemberProfile,
                      ),
                      const SizedBox(height: 14),
                      SfbLatestPostsSection(
                        posts: _latestWallPosts,
                        onOpenWall: () =>
                            _openHealthCommunity(initialTabIndex: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrostedCircleAction extends StatelessWidget {
  const _FrostedCircleAction({
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppTheme.primaryTeal.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroWellnessCard extends StatelessWidget {
  const _HeroWellnessCard({
    required this.greeting,
    required this.providerLabel,
    required this.disclaimer,
    required this.checksCount,
    required this.labsCount,
    required this.vitalsCount,
    required this.checksLabel,
    required this.labsLabel,
    required this.vitalsLabel,
    required this.onTapChecks,
    required this.onTapLabs,
    required this.onTapVitals,
  });

  final String greeting;
  final String providerLabel;
  final String disclaimer;
  final int checksCount;
  final int labsCount;
  final int vitalsCount;
  final String checksLabel;
  final String labsLabel;
  final String vitalsLabel;
  final VoidCallback onTapChecks;
  final VoidCallback onTapLabs;
  final VoidCallback onTapVitals;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0D3B3D), Color(0xFF105453), Color(0xFF126B67)]
              : const [Color(0xFF085457), Color(0xFF0C7473), Color(0xFF169D93)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Soft ambient decorative orbs
            Positioned(
              top: -36,
              right: -24,
              child: IgnorePointer(
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -44,
              left: -26,
              child: IgnorePointer(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              providerLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Compact interactive frosted stats strip
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStatChip(
                          icon: Icons.camera_alt_outlined,
                          count: checksCount,
                          label: checksLabel,
                          onTap: onTapChecks,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HeroStatChip(
                          icon: Icons.biotech_outlined,
                          count: labsCount,
                          label: labsLabel,
                          onTap: onTapLabs,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HeroStatChip(
                          icon: Icons.monitor_heart_outlined,
                          count: vitalsCount,
                          label: vitalsLabel,
                          onTap: onTapVitals,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white.withValues(alpha: 0.88),
                          size: 15,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            disclaimer,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.90),
                              fontSize: 11.5,
                              height: 1.32,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.92)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpModernCard extends StatelessWidget {
  const _FollowUpModernCard({
    required this.title,
    required this.editLabel,
    required this.startLabel,
    required this.emptyHint,
    required this.nextTrack,
    required this.trackTitle,
    required this.statusLabel,
    required this.onEdit,
    required this.onStart,
  });

  final String title;
  final String editLabel;
  final String startLabel;
  final String emptyHint;
  final FollowUpTrackStatus? nextTrack;
  final String? trackTitle;
  final String? statusLabel;
  final VoidCallback onEdit;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF162323).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? colorScheme.primary.withValues(alpha: 0.24)
              : Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 11, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(
                        alpha: isDark ? 0.25 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_repeat_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF6CE5DC)
                              : AppTheme.primaryTeal,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF6CE5DC)
                                  : AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          editLabel,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (nextTrack != null)
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryTeal.withValues(alpha: 0.16),
                          AppTheme.secondaryMint.withValues(alpha: 0.24),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      nextTrack!.track.icon,
                      color: isDark
                          ? const Color(0xFF6CE5DC)
                          : AppTheme.primaryTeal,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trackTitle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nextTrack!.isDueNow
                                    ? AppTheme.secondaryMint
                                    : const Color(0xFF1B8A5A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                statusLabel ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: nextTrack!.isDueNow
                                      ? colorScheme.primary
                                      : const Color(0xFF1B8A5A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (nextTrack!.latestValueSummary != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            nextTrack!.latestValueSummary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          startLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 15),
                      ],
                    ),
                  ),
                ],
              )
            else
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
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
                          emptyHint,
                          style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.badgeText,
  });

  final String title;
  final String? subtitle;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryTeal, AppTheme.secondaryMint],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.25 : 0.11,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFF6CE5DC)
                        : AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.32,
              ),
            ),
          ),
        ],
      ],
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
    final isDark = theme.brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(accentColor);
    final lighterAccent = hsl
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 0.85))
        .toColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF162323).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? accentColor.withValues(alpha: 0.22)
              : Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.14 : 0.09),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: accentColor.withValues(alpha: 0.12),
            child: Stack(
              children: [
                Positioned(
                  top: -24,
                  right: -24,
                  child: IgnorePointer(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                            accentColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [accentColor, lighterAccent],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.26),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 21),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isDark ? 0.18 : 0.10,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicationQuickBanner extends StatelessWidget {
  const _MedicationQuickBanner({
    required this.title,
    required this.subtitle,
    required this.badgeCount,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accent = Color(0xFFC8553D);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2424).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          key: const Key('home_medication_quick_banner'),
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent,
                        accent.withValues(alpha: 0.78),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.alarm_on_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



