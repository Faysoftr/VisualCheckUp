import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/preferences/feature_preferences_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/health_drawer_background.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_icon.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/home_social_showcase.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

/// Main side navigation drawer for VisualCheckUp — styled after Social Formula
/// Bank's airy pastel-icon menu with top gradient-ring profile header, direct
/// social shortcuts, and cleanly grouped visual checks & health trackers.
class AppDrawer extends StatefulWidget {
  const AppDrawer({
    super.key,
    required this.currentUser,
    required this.themeController,
    required this.onOpenSkinModule,
    required this.onOpenHistory,
    required this.onOpenReferenceGuide,
    required this.onOpenAiSettings,
    required this.onOpenDisclaimer,
    required this.onSignOut,
    required this.onDeleteAccount,
    this.localeController,
    this.featurePreferencesController,
    this.onOpenFeatureWizard,
    this.onOpenSettings,
    this.onOpenCategory,
    this.onOpenSkinConcern,
    this.onOpenFollowUpPlan,
    this.onOpenQuickColorCard,
    this.onOpenLabReports,
    this.onOpenVitalsTracker,
    this.onOpenMedicationReminders,
    this.onOpenDietMenu,
    this.onOpenAiCalorieScanner,
    this.onOpenMyProfile,
    this.onOpenHealthCommunity,
    this.onOpenCommunityMessages,
    this.onOpenCommunityWall,
    this.onOpenCommunityGroups,
    this.onOpenDoctorSearch,
    this.onOpenDoctorApplication,
    this.onOpenProSubscription,
    this.onOpenAdminPanel,
    this.onOpenDonate,
    this.onOpenGrowthBmi,
    this.onOpenChildrenGrowth,
    this.onOpenPedometer,
    this.onOpenSobriety,
    this.onOpenBreathLung,
    this.onOpenVeinAnalysis,
    this.onOpenWaterTracker,
    this.onOpenWidgetsManager,
  });

  final AuthUser currentUser;
  final ThemeController themeController;
  final LocaleController? localeController;
  final FeaturePreferencesController? featurePreferencesController;
  final VoidCallback? onOpenFeatureWizard;
  final VoidCallback? onOpenSettings;
  final VoidCallback onOpenSkinModule;
  final ValueChanged<CheckCategory>? onOpenCategory;
  final ValueChanged<SkinConcernType>? onOpenSkinConcern;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenReferenceGuide;
  final VoidCallback onOpenAiSettings;
  final VoidCallback onOpenDisclaimer;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;
  final VoidCallback? onOpenFollowUpPlan;
  final VoidCallback? onOpenQuickColorCard;
  final VoidCallback? onOpenLabReports;
  final VoidCallback? onOpenVitalsTracker;
  final VoidCallback? onOpenMedicationReminders;
  final VoidCallback? onOpenDietMenu;
  final VoidCallback? onOpenAiCalorieScanner;
  final VoidCallback? onOpenMyProfile;
  final VoidCallback? onOpenHealthCommunity;
  final VoidCallback? onOpenCommunityMessages;
  final VoidCallback? onOpenCommunityWall;
  final VoidCallback? onOpenCommunityGroups;
  final VoidCallback? onOpenDoctorSearch;
  final VoidCallback? onOpenDoctorApplication;
  final VoidCallback? onOpenProSubscription;
  final VoidCallback? onOpenAdminPanel;
  final VoidCallback? onOpenDonate;
  final VoidCallback? onOpenGrowthBmi;
  final VoidCallback? onOpenChildrenGrowth;
  final VoidCallback? onOpenPedometer;
  final VoidCallback? onOpenSobriety;
  final VoidCallback? onOpenBreathLung;
  final VoidCallback? onOpenVeinAnalysis;
  final VoidCallback? onOpenWaterTracker;
  final VoidCallback? onOpenWidgetsManager;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  AuthUser get currentUser => widget.currentUser;
  ThemeController get themeController => widget.themeController;
  LocaleController? get localeController => widget.localeController;
  VoidCallback? get onOpenSettings => widget.onOpenSettings;
  VoidCallback get onOpenSkinModule => widget.onOpenSkinModule;
  ValueChanged<CheckCategory>? get onOpenCategory => widget.onOpenCategory;
  ValueChanged<SkinConcernType>? get onOpenSkinConcern => widget.onOpenSkinConcern;
  VoidCallback get onOpenHistory => widget.onOpenHistory;
  VoidCallback get onOpenReferenceGuide => widget.onOpenReferenceGuide;
  VoidCallback get onOpenAiSettings => widget.onOpenAiSettings;
  VoidCallback get onOpenDisclaimer => widget.onOpenDisclaimer;
  VoidCallback get onSignOut => widget.onSignOut;
  VoidCallback get onDeleteAccount => widget.onDeleteAccount;
  VoidCallback? get onOpenFollowUpPlan => widget.onOpenFollowUpPlan;
  VoidCallback? get onOpenQuickColorCard => widget.onOpenQuickColorCard;
  VoidCallback? get onOpenLabReports => widget.onOpenLabReports;
  VoidCallback? get onOpenVitalsTracker => widget.onOpenVitalsTracker;
  VoidCallback? get onOpenMedicationReminders => widget.onOpenMedicationReminders;
  VoidCallback? get onOpenDietMenu => widget.onOpenDietMenu;
  VoidCallback? get onOpenAiCalorieScanner => widget.onOpenAiCalorieScanner;
  VoidCallback? get onOpenMyProfile => widget.onOpenMyProfile;
  VoidCallback? get onOpenHealthCommunity => widget.onOpenHealthCommunity;
  VoidCallback? get onOpenCommunityMessages => widget.onOpenCommunityMessages;
  VoidCallback? get onOpenCommunityWall => widget.onOpenCommunityWall;
  VoidCallback? get onOpenCommunityGroups => widget.onOpenCommunityGroups;
  VoidCallback? get onOpenDoctorSearch => widget.onOpenDoctorSearch;
  VoidCallback? get onOpenDoctorApplication => widget.onOpenDoctorApplication;
  VoidCallback? get onOpenProSubscription => widget.onOpenProSubscription;
  VoidCallback? get onOpenAdminPanel => widget.onOpenAdminPanel;
  VoidCallback? get onOpenDonate => widget.onOpenDonate;
  VoidCallback? get onOpenGrowthBmi => widget.onOpenGrowthBmi;
  VoidCallback? get onOpenChildrenGrowth => widget.onOpenChildrenGrowth;
  VoidCallback? get onOpenPedometer => widget.onOpenPedometer;
  VoidCallback? get onOpenSobriety => widget.onOpenSobriety;
  VoidCallback? get onOpenBreathLung => widget.onOpenBreathLung;
  VoidCallback? get onOpenVeinAnalysis => widget.onOpenVeinAnalysis;
  VoidCallback? get onOpenWaterTracker => widget.onOpenWaterTracker;
  VoidCallback? get onOpenWidgetsManager => widget.onOpenWidgetsManager;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeAndRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
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
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
      onDeleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final isAdmin = AdminUtils.isAdmin(
      email: currentUser.email,
      uid: currentUser.id,
    );

    const nonSkinCategories = [
      CheckCategory.eye,
      CheckCategory.tongue,
      CheckCategory.nail,
      CheckCategory.face,
      CheckCategory.urine,
      CheckCategory.stool,
    ];

    final activeLangLabel = localeController?.value == null
        ? l10n.languageSystem
        : LocaleController.optionForCode(
            localeController!.value!.languageCode,
          ).nativeName;

    return Drawer(
      clipBehavior: Clip.none,
      child: HealthDrawerBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Social Formula Bank-inspired Top Profile Header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('drawer_profile_header_card'),
                  onTap: onOpenMyProfile != null
                      ? () => _closeAndRun(context, onOpenMyProfile!)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF15292B).withValues(alpha: 0.95),
                                const Color(0xFF0E1D1F).withValues(alpha: 0.95),
                              ]
                            : [
                                const Color(0xFFF3F0FF).withValues(alpha: 0.92),
                                const Color(0xFFECFEFF).withValues(alpha: 0.88),
                              ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: isDark ? 0.35 : 0.65),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SfbGradientRingAvatar(
                          initials: currentUser.initials,
                          radius: 26,
                          ringWidth: 2.5,
                          isOnline: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      currentUser.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                  ),
                                  if (isAdmin) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.verified_user_rounded,
                                            size: 11,
                                            color: Colors.black87,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            l10n.sfbAdminBadge,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentUser.email ?? l10n.localOnlyLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (onOpenMyProfile != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.account_circle_outlined,
                                          size: 14,
                                          color: Color(0xFF0284C7),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${l10n.sfbGoToProfile} >',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF0284C7),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _providerIcon(currentUser.provider),
                                          size: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            l10n.accountTypeLabel(
                                              currentUser.provider
                                                  .localizedLabel(l10n),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<Set<PersonalHealthFeature>>(
                  valueListenable: widget.featurePreferencesController ??
                      ValueNotifier<Set<PersonalHealthFeature>>(
                        PersonalHealthFeatureX.allFeatures,
                      ),
                  builder: (context, enabledFeatures, _) {
                    final langCode = Localizations.localeOf(context).languageCode;
                    final isTr = langCode == 'tr';
                    bool isFeatureOn(PersonalHealthFeature f) =>
                        enabledFeatures.contains(f);

                    final query = _searchQuery.trim().toLowerCase();
                    if (query.isNotEmpty) {
                      final searchableItems = <_SearchableDrawerEntry>[
                        for (final category in nonSkinCategories)
                          if (onOpenCategory != null)
                            _SearchableDrawerEntry(
                              label: category.localizedTitle(l10n),
                              icon: category.icon,
                              accentColor: category.accentColor,
                              onTap: () => _closeAndRun(
                                context,
                                () => onOpenCategory!(category),
                              ),
                            ),
                        if (onOpenVeinAnalysis != null)
                          _SearchableDrawerEntry(
                            label: _localizedVeinTitle(langCode),
                            icon: Icons.airline_seat_legroom_extra_rounded,
                            accentColor: const Color(0xFF0284C7),
                            onTap: () =>
                                _closeAndRun(context, onOpenVeinAnalysis!),
                          ),
                        if (onOpenQuickColorCard != null)
                          _SearchableDrawerEntry(
                            label: l10n.menuQuickColorCard,
                            icon: Icons.palette_outlined,
                            accentColor: const Color(0xFFF59E0B),
                            onTap: () =>
                                _closeAndRun(context, onOpenQuickColorCard!),
                          ),
                        _SearchableDrawerEntry(
                          label: l10n.menuSkinGeneral,
                          icon: Icons.dashboard_customize_outlined,
                          accentColor: CheckCategory.skinCondition.accentColor,
                          onTap: () => _closeAndRun(context, onOpenSkinModule),
                        ),
                        if (onOpenLabReports != null)
                          _SearchableDrawerEntry(
                            label: l10n.menuLabReports,
                            icon: Icons.biotech_outlined,
                            accentColor: const Color(0xFF0284C7),
                            onTap: () => _closeAndRun(context, onOpenLabReports!),
                          ),
                        if (onOpenVitalsTracker != null)
                          _SearchableDrawerEntry(
                            label: l10n.menuVitalsTracker,
                            icon: Icons.monitor_heart_outlined,
                            accentColor: const Color(0xFFEF4444),
                            onTap: () =>
                                _closeAndRun(context, onOpenVitalsTracker!),
                          ),
                        if (onOpenMedicationReminders != null)
                          _SearchableDrawerEntry(
                            label: l10n.medMenuTitle,
                            icon: Icons.alarm_on_rounded,
                            accentColor: const Color(0xFFC8553D),
                            onTap: () => _closeAndRun(
                              context,
                              onOpenMedicationReminders!,
                            ),
                          ),
                        if (onOpenWaterTracker != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.waterTracker
                                .localizedTitle(langCode),
                            icon: Icons.water_drop_rounded,
                            accentColor: const Color(0xFF0284C7),
                            onTap: () =>
                                _closeAndRun(context, onOpenWaterTracker!),
                          ),
                        if (onOpenPedometer != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.pedometer
                                .localizedTitle(langCode),
                            icon: Icons.directions_walk_rounded,
                            accentColor: const Color(0xFF0D9488),
                            onTap: () => _closeAndRun(context, onOpenPedometer!),
                          ),
                        if (onOpenDietMenu != null)
                          _SearchableDrawerEntry(
                            label: l10n.dietMenuTitle,
                            icon: Icons.restaurant_menu_rounded,
                            accentColor: const Color(0xFF16A34A),
                            onTap: () => _closeAndRun(context, onOpenDietMenu!),
                          ),
                        if (onOpenBreathLung != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.breathLung
                                .localizedTitle(langCode),
                            icon: Icons.air_rounded,
                            accentColor: const Color(0xFF0D9488),
                            onTap: () => _closeAndRun(context, onOpenBreathLung!),
                          ),
                        if (onOpenSobriety != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.sobriety
                                .localizedTitle(langCode),
                            icon: Icons.smoke_free_rounded,
                            accentColor: const Color(0xFF16A34A),
                            onTap: () => _closeAndRun(context, onOpenSobriety!),
                          ),
                        if (onOpenGrowthBmi != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.growthBmi
                                .localizedTitle(langCode),
                            icon: Icons.monitor_weight_outlined,
                            accentColor: const Color(0xFF2B7BBA),
                            onTap: () => _closeAndRun(context, onOpenGrowthBmi!),
                          ),
                        if (onOpenChildrenGrowth != null)
                          _SearchableDrawerEntry(
                            label: PersonalHealthFeature.childrenGrowth
                                .localizedTitle(langCode),
                            icon: Icons.child_care_outlined,
                            accentColor: const Color(0xFF7B5EA7),
                            onTap: () =>
                                _closeAndRun(context, onOpenChildrenGrowth!),
                          ),
                        if (widget.onOpenFeatureWizard != null)
                          _SearchableDrawerEntry(
                            label: isTr
                                ? 'Özellik Seçim Sihirbazı'
                                : 'Feature Selection Wizard',
                            icon: Icons.tune_rounded,
                            accentColor: AppTheme.primaryTeal,
                            onTap: () => _closeAndRun(
                              context,
                              widget.onOpenFeatureWizard!,
                            ),
                          ),
                      ];

                      final matches = searchableItems
                          .where((e) => e.label.toLowerCase().contains(query))
                          .toList();

                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        children: [
                          _buildSearchBar(isDark, isTr),
                          const SizedBox(height: 8),
                          if (matches.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                isTr
                                    ? 'Aranan modül bulunamadı.'
                                    : 'No matching module found.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else
                            for (final m in matches)
                              _DrawerTile(
                                icon: m.icon,
                                label: m.label,
                                accentColor: m.accentColor,
                                onTap: m.onTap,
                              ),
                        ],
                      );
                    }

                    final trackingTilesCount = [
                      if (onOpenLabReports != null &&
                          isFeatureOn(PersonalHealthFeature.labReports))
                        1,
                      if (onOpenVitalsTracker != null &&
                          isFeatureOn(PersonalHealthFeature.vitalsTracker))
                        1,
                      if (onOpenMedicationReminders != null &&
                          isFeatureOn(PersonalHealthFeature.medicationAlarms))
                        1,
                      if (onOpenFollowUpPlan != null &&
                          isFeatureOn(PersonalHealthFeature.followUpPlan))
                        1,
                      1, // History
                      1, // Reference Guide
                      if (onOpenWaterTracker != null &&
                          isFeatureOn(PersonalHealthFeature.waterTracker))
                        1,
                      if (onOpenPedometer != null &&
                          isFeatureOn(PersonalHealthFeature.pedometer))
                        1,
                      if (onOpenDietMenu != null &&
                          isFeatureOn(PersonalHealthFeature.dietAndCalorie))
                        1,
                      if (onOpenAiCalorieScanner != null &&
                          isFeatureOn(PersonalHealthFeature.dietAndCalorie))
                        1,
                      if (onOpenGrowthBmi != null &&
                          isFeatureOn(PersonalHealthFeature.growthBmi))
                        1,
                      if (onOpenBreathLung != null &&
                          isFeatureOn(PersonalHealthFeature.breathLung))
                        1,
                      if (onOpenSobriety != null &&
                          isFeatureOn(PersonalHealthFeature.sobriety))
                        1,
                      if (onOpenChildrenGrowth != null &&
                          isFeatureOn(PersonalHealthFeature.childrenGrowth))
                        1,
                      if (onOpenWidgetsManager != null) 1,
                      if (onOpenProSubscription != null) 1,
                    ].length;

                    final hiddenCount =
                        PersonalHealthFeature.values.length - enabledFeatures.length;

                    return ListView(
                      cacheExtent: 900,
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
                      children: [
                        _buildSearchBar(isDark, isTr),
                        const SizedBox(height: 4),
                        // 1. Ana Ekran (En Üstte)
                        _DrawerTile(
                          key: const Key('drawer_home_tile'),
                          icon: Icons.grid_view_rounded,
                          label: l10n.menuHome,
                          accentColor: const Color(0xFF3B82F6),
                          selected: true,
                          showDotDivider: true,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        // 2. Bağış Yap Banner
                        if (onOpenDonate != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 3, 4, 5),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE11D48)
                                        .withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                                child: InkWell(
                                  key: const Key('drawer_donate_button'),
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () =>
                                      _closeAndRun(context, onOpenDonate!),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.22),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.volunteer_activism_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.donateMenuLabel,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                l10n.donateMenuSubtitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // 3. Profilim
                        if (onOpenMyProfile != null)
                          _DrawerTile(
                            key: const Key('drawer_my_profile_tile'),
                            icon: Icons.person_outline_rounded,
                            label: l10n.commTabMyProfile,
                            accentColor: const Color(0xFFD946EF),
                            showDotDivider: true,
                            onTap: () =>
                                _closeAndRun(context, onOpenMyProfile!),
                          ),
                        // 4. Sağlık Topluluğu (Keşfet)
                        if (onOpenHealthCommunity != null &&
                            isFeatureOn(PersonalHealthFeature.communitySocial))
                          _DrawerTile(
                            key: const Key('drawer_community_tile'),
                            icon: Icons.search_rounded,
                            label: l10n.commMenuTitle,
                            accentColor: const Color(0xFF06B6D4),
                            showDotDivider: true,
                            onTap: () =>
                                _closeAndRun(context, onOpenHealthCommunity!),
                          ),
                        const SizedBox(height: 6),
                        // ──── 1. Grup: Görsel Kontroller (Akordeon — Ana Vitrin) ────
                        _DrawerAccordionGroup(
                          key: const Key('drawer_group_visual'),
                          title: l10n.menuSectionVisualChecks,
                          icon: Icons.visibility_outlined,
                          accentColor: AppTheme.primaryTeal,
                          badgeText:
                              '${nonSkinCategories.length + 1 + (onOpenQuickColorCard != null ? 1 : 0) + (onOpenVeinAnalysis != null ? 1 : 0)}',
                          initiallyExpanded: false,
                          children: [
                            for (final category in nonSkinCategories)
                              if (onOpenCategory != null)
                                _DrawerTile(
                                  icon: category.icon,
                                  leadingWidget: CategoryIcon(
                                    category: category,
                                    color: category.accentColor,
                                    size: 20,
                                  ),
                                  label: category.localizedTitle(l10n),
                                  accentColor: category.accentColor,
                                  onTap: () => _closeAndRun(
                                    context,
                                    () => onOpenCategory!(category),
                                  ),
                                ),
                            if (onOpenVeinAnalysis != null)
                              _DrawerTile(
                                key: const Key('drawer_item_vein_analysis'),
                                icon: Icons.airline_seat_legroom_extra_rounded,
                                label: _localizedVeinTitle(langCode),
                                accentColor: const Color(0xFF0284C7),
                                onTap: () =>
                                    _closeAndRun(context, onOpenVeinAnalysis!),
                              ),
                            if (onOpenQuickColorCard != null)
                              _DrawerTile(
                                key: const Key('drawer_quick_color_card_tile'),
                                icon: Icons.palette_outlined,
                                label: l10n.menuQuickColorCard,
                                accentColor: const Color(0xFFF59E0B),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenQuickColorCard!,
                                ),
                              ),
                            Theme(
                              data: theme.copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                childrenPadding:
                                    const EdgeInsetsDirectional.only(start: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                leading: _PastelIconBox(
                                  color: CheckCategory.skinCondition.accentColor,
                                  child: CategoryIcon(
                                    category: CheckCategory.skinCondition,
                                    color:
                                        CheckCategory.skinCondition.accentColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  l10n.menuSkinGroup,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                children: [
                                  _DrawerTile(
                                    icon: Icons.dashboard_customize_outlined,
                                    label: l10n.menuSkinGeneral,
                                    accentColor:
                                        CheckCategory.skinCondition.accentColor,
                                    onTap: () =>
                                        _closeAndRun(context, onOpenSkinModule),
                                  ),
                                  if (onOpenSkinConcern != null)
                                    for (final concern
                                        in SkinConcernTypeX.featuredSubModules)
                                      _DrawerTile(
                                        icon: concern.icon,
                                        label: concern.localizedLabel(l10n),
                                        accentColor: concern.accentColor,
                                        onTap: () => _closeAndRun(
                                          context,
                                          () => onOpenSkinConcern!(concern),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ──── 2. Grup: Sağlık Topluluğu & Sosyal (Akordeon) ────
                        if (isFeatureOn(PersonalHealthFeature.communitySocial))
                          _DrawerAccordionGroup(
                            key: const Key('drawer_group_community'),
                            title: l10n.commMenuTitle,
                            icon: Icons.forum_outlined,
                            accentColor: const Color(0xFF06B6D4),
                            badgeText: '5',
                            children: [
                              if (onOpenCommunityMessages != null)
                                _DrawerTile(
                                  key: const Key('drawer_messages_tile'),
                                  icon: Icons.mail_outline_rounded,
                                  label: l10n.sfbMyMessages,
                                  accentColor: const Color(0xFFF59E0B),
                                  showDotDivider: true,
                                  onTap: () => _closeAndRun(
                                    context,
                                    onOpenCommunityMessages!,
                                  ),
                                ),
                              if (onOpenMyProfile != null)
                                _DrawerTile(
                                  key: const Key('drawer_friends_tile'),
                                  icon: Icons.people_outline_rounded,
                                  label: l10n.sfbMyFriends,
                                  accentColor: const Color(0xFF10B981),
                                  showDotDivider: true,
                                  onTap: () =>
                                      _closeAndRun(context, onOpenMyProfile!),
                                ),
                              if (onOpenCommunityWall != null)
                                _DrawerTile(
                                  key: const Key('drawer_wall_tile'),
                                  icon: Icons.forum_outlined,
                                  label: l10n.commWallTitle,
                                  accentColor: const Color(0xFFEC4899),
                                  showDotDivider: true,
                                  onTap: () => _closeAndRun(
                                    context,
                                    onOpenCommunityWall!,
                                  ),
                                ),
                              if (onOpenCommunityGroups != null)
                                _DrawerTile(
                                  key: const Key('drawer_groups_tile'),
                                  icon: Icons.groups_outlined,
                                  label: l10n.commGroupsTitle,
                                  accentColor: const Color(0xFF14B8A6),
                                  showDotDivider: true,
                                  onTap: () => _closeAndRun(
                                    context,
                                    onOpenCommunityGroups!,
                                  ),
                                ),
                              if (onOpenDoctorSearch != null)
                                _DrawerTile(
                                  key: const Key('drawer_doctor_search_tile'),
                                  icon: Icons.workspace_premium_outlined,
                                  label: l10n.doctorSearchTitle,
                                  accentColor: const Color(0xFFEAB308),
                                  showDotDivider: true,
                                  onTap: () => _closeAndRun(
                                    context,
                                    onOpenDoctorSearch!,
                                  ),
                                ),
                            ],
                          ),

                        // ──── 3. Grup: Takip & Sağlık Araçları (3 Alt Başlık + Kişisel Seçim) ────
                        _DrawerAccordionGroup(
                          key: const Key('drawer_group_tracking'),
                          title: l10n.menuSectionTracking,
                          icon: Icons.monitor_heart_outlined,
                          accentColor: const Color(0xFFEF4444),
                          badgeText: '$trackingTilesCount',
                          children: [
                            // Alt Grup 3A: Günlük Yaşam & Beslenme
                            if ((onOpenWaterTracker != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.waterTracker,
                                    )) ||
                                (onOpenPedometer != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.pedometer,
                                    )) ||
                                (onOpenDietMenu != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.dietAndCalorie,
                                    )) ||
                                (onOpenGrowthBmi != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.growthBmi,
                                    )))
                              _DrawerSubGroupHeader(
                                label: isTr
                                    ? 'Günlük Yaşam & Beslenme'
                                    : 'Daily Wellness & Diet',
                                color: const Color(0xFF0D9488),
                              ),
                            if (onOpenWaterTracker != null &&
                                isFeatureOn(PersonalHealthFeature.waterTracker))
                              _DrawerTile(
                                key: const Key('drawer_item_water_tracker'),
                                icon: Icons.water_drop_rounded,
                                label: PersonalHealthFeature.waterTracker
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF0284C7),
                                onTap: () =>
                                    _closeAndRun(context, onOpenWaterTracker!),
                              ),
                            if (onOpenPedometer != null &&
                                isFeatureOn(PersonalHealthFeature.pedometer))
                              _DrawerTile(
                                key: const Key('drawer_pedometer_tile'),
                                icon: Icons.directions_walk_rounded,
                                label: PersonalHealthFeature.pedometer
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF0D9488),
                                onTap: () =>
                                    _closeAndRun(context, onOpenPedometer!),
                              ),
                            if (onOpenDietMenu != null &&
                                isFeatureOn(
                                  PersonalHealthFeature.dietAndCalorie,
                                ))
                              _DrawerTile(
                                icon: Icons.restaurant_menu_rounded,
                                label: l10n.dietMenuTitle,
                                accentColor: const Color(0xFF16A34A),
                                onTap: () =>
                                    _closeAndRun(context, onOpenDietMenu!),
                              ),
                            if (onOpenAiCalorieScanner != null &&
                                isFeatureOn(
                                  PersonalHealthFeature.dietAndCalorie,
                                ))
                              _DrawerTile(
                                icon: Icons.camera_enhance_rounded,
                                label: l10n.dietCalorieQuickTitle,
                                accentColor: const Color(0xFFD97706),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenAiCalorieScanner!,
                                ),
                              ),
                            if (onOpenGrowthBmi != null &&
                                isFeatureOn(PersonalHealthFeature.growthBmi))
                              _DrawerTile(
                                icon: Icons.monitor_weight_outlined,
                                label: PersonalHealthFeature.growthBmi
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF2B7BBA),
                                onTap: () =>
                                    _closeAndRun(context, onOpenGrowthBmi!),
                              ),

                            // Alt Grup 3B: Özel Programlar
                            if ((onOpenBreathLung != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.breathLung,
                                    )) ||
                                (onOpenSobriety != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.sobriety,
                                    )) ||
                                (onOpenChildrenGrowth != null &&
                                    isFeatureOn(
                                      PersonalHealthFeature.childrenGrowth,
                                    )))
                              _DrawerSubGroupHeader(
                                label: isTr
                                    ? 'Özel Programlar'
                                    : 'Specialized Programs',
                                color: const Color(0xFF7C3AED),
                              ),
                            if (onOpenBreathLung != null &&
                                isFeatureOn(PersonalHealthFeature.breathLung))
                              _DrawerTile(
                                key: const Key('drawer_item_breath_lung'),
                                icon: Icons.air_rounded,
                                label: PersonalHealthFeature.breathLung
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF0D9488),
                                onTap: () =>
                                    _closeAndRun(context, onOpenBreathLung!),
                              ),
                            if (onOpenSobriety != null &&
                                isFeatureOn(PersonalHealthFeature.sobriety))
                              _DrawerTile(
                                key: const Key('drawer_sobriety_tile'),
                                icon: Icons.smoke_free_rounded,
                                label: PersonalHealthFeature.sobriety
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF16A34A),
                                onTap: () =>
                                    _closeAndRun(context, onOpenSobriety!),
                              ),
                            if (onOpenChildrenGrowth != null &&
                                isFeatureOn(
                                  PersonalHealthFeature.childrenGrowth,
                                ))
                              _DrawerTile(
                                icon: Icons.child_care_outlined,
                                label: PersonalHealthFeature.childrenGrowth
                                    .localizedTitle(langCode),
                                accentColor: const Color(0xFF7B5EA7),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenChildrenGrowth!,
                                ),
                              ),

                            // Alt Grup 3C: Klinik, Tahlil & Arşiv
                            _DrawerSubGroupHeader(
                              label: isTr
                                  ? 'Klinik & Tahlil'
                                  : 'Clinical & Labs',
                              color: const Color(0xFF0284C7),
                            ),
                            if (onOpenLabReports != null &&
                                isFeatureOn(PersonalHealthFeature.labReports))
                              _DrawerTile(
                                icon: Icons.biotech_outlined,
                                label: l10n.menuLabReports,
                                accentColor: const Color(0xFF0284C7),
                                onTap: () =>
                                    _closeAndRun(context, onOpenLabReports!),
                              ),
                            if (onOpenVitalsTracker != null &&
                                isFeatureOn(PersonalHealthFeature.vitalsTracker))
                              _DrawerTile(
                                icon: Icons.monitor_heart_outlined,
                                label: l10n.menuVitalsTracker,
                                accentColor: const Color(0xFFEF4444),
                                onTap: () =>
                                    _closeAndRun(context, onOpenVitalsTracker!),
                              ),
                            if (onOpenMedicationReminders != null &&
                                isFeatureOn(
                                  PersonalHealthFeature.medicationAlarms,
                                ))
                              _DrawerTile(
                                icon: Icons.alarm_on_rounded,
                                label: l10n.medMenuTitle,
                                accentColor: const Color(0xFFC8553D),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenMedicationReminders!,
                                ),
                              ),
                            if (onOpenFollowUpPlan != null &&
                                isFeatureOn(PersonalHealthFeature.followUpPlan))
                              _DrawerTile(
                                icon: Icons.event_repeat_rounded,
                                label: l10n.menuFollowUpPlan,
                                accentColor: AppTheme.primaryTeal,
                                onTap: () =>
                                    _closeAndRun(context, onOpenFollowUpPlan!),
                              ),
                            _DrawerTile(
                              icon: Icons.history_rounded,
                              label: l10n.menuHistory,
                              accentColor: const Color(0xFF64748B),
                              onTap: () => _closeAndRun(context, onOpenHistory),
                            ),
                            _DrawerTile(
                              icon: Icons.menu_book_rounded,
                              label: l10n.menuReferenceGuide,
                              accentColor: const Color(0xFF0F766E),
                              onTap: () =>
                                  _closeAndRun(context, onOpenReferenceGuide),
                            ),
                            if (onOpenWidgetsManager != null)
                              _DrawerTile(
                                key: const Key('drawer_widgets_manager_tile'),
                                icon: Icons.widgets_rounded,
                                label: isTr
                                    ? 'Widget Merkezi (Aç/Kapat)'
                                    : 'Widgets Manager',
                                accentColor: const Color(0xFF2563EB),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenWidgetsManager!,
                                ),
                              ),
                            if (onOpenDoctorApplication != null)
                              _DrawerTile(
                                key: const Key('drawer_doctor_apply_tile'),
                                icon: Icons.verified_user_outlined,
                                label: l10n.doctorApplyCta,
                                accentColor: const Color(0xFF0F766E),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenDoctorApplication!,
                                ),
                              ),
                            if (onOpenProSubscription != null)
                              _DrawerTile(
                                key: const Key('drawer_pro_tile'),
                                icon: Icons.workspace_premium_rounded,
                                label: l10n.proMenuTitle,
                                accentColor: const Color(0xFFD97706),
                                onTap: () => _closeAndRun(
                                  context,
                                  onOpenProSubscription!,
                                ),
                              ),
                            if (widget.onOpenFeatureWizard != null)
                              _DrawerTile(
                                key: const Key('drawer_customize_features_tile'),
                                icon: Icons.tune_rounded,
                                label: hiddenCount > 0
                                    ? (isTr
                                        ? '+ Özellikleri Düzenle ($hiddenCount gizli)'
                                        : '+ Edit Active Tools ($hiddenCount hidden)')
                                    : (isTr
                                        ? 'Özellikleri Seç / Gizle'
                                        : 'Choose Active Tools'),
                                accentColor: AppTheme.primaryTeal,
                                onTap: () => _closeAndRun(
                                  context,
                                  widget.onOpenFeatureWizard!,
                                ),
                              ),
                          ],
                        ),

                        // ──── 4. Grup: Ayarlar & Sistem (Akordeon) ────
                        _DrawerAccordionGroup(
                          key: const Key('drawer_group_settings'),
                          title: l10n.menuSectionSettings,
                          icon: Icons.settings_outlined,
                          accentColor: const Color(0xFF8B5CF6),
                          badgeText:
                              widget.onOpenFeatureWizard != null ? '6' : '5',
                          initiallyExpanded: false,
                          children: [
                            if (widget.onOpenFeatureWizard != null)
                              _DrawerTile(
                                key: const Key('drawer_settings_wizard_tile'),
                                icon: Icons.tune_rounded,
                                label: isTr
                                    ? 'Özellik Seçim Sihirbazı'
                                    : 'Feature Selection Wizard',
                                accentColor: AppTheme.primaryTeal,
                                onTap: () => _closeAndRun(
                                  context,
                                  widget.onOpenFeatureWizard!,
                                ),
                              ),
                            if (onOpenSettings != null)
                              _DrawerTile(
                                icon: Icons.settings_outlined,
                                label: l10n.menuSettings,
                                accentColor: const Color(0xFF64748B),
                                onTap: () =>
                                    _closeAndRun(context, onOpenSettings!),
                              ),
                            if (localeController != null)
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                leading: const _PastelIconBox(
                                  color: Color(0xFF0284C7),
                                  child: Icon(
                                    Icons.language_rounded,
                                    size: 19,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                                title: Text(
                                  l10n.menuLanguage,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                trailing: Text(
                                  activeLangLabel,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onTap: () => LanguagePickerSheet.show(
                                  context,
                                  localeController: localeController!,
                                ),
                              ),
                            _DrawerTile(
                              icon: Icons.auto_awesome_outlined,
                              label: l10n.menuAiSettings,
                              accentColor: const Color(0xFF8B5CF6),
                              onTap: () =>
                                  _closeAndRun(context, onOpenAiSettings),
                            ),
                            _DrawerTile(
                              icon: Icons.info_outline_rounded,
                              label: l10n.menuDisclaimer,
                              accentColor: const Color(0xFF64748B),
                              onTap: () =>
                                  _closeAndRun(context, onOpenDisclaimer),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.menuTheme,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ValueListenableBuilder<ThemeMode>(
                                    valueListenable: themeController,
                                    builder: (context, mode, _) {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: SegmentedButton<ThemeMode>(
                                          showSelectedIcon: false,
                                          style: const ButtonStyle(
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          segments: [
                                            ButtonSegment<ThemeMode>(
                                              value: ThemeMode.system,
                                              label: Text(l10n.themeSystem),
                                            ),
                                            ButtonSegment<ThemeMode>(
                                              value: ThemeMode.light,
                                              label: Text(l10n.themeLight),
                                            ),
                                            ButtonSegment<ThemeMode>(
                                              value: ThemeMode.dark,
                                              label: Text(l10n.themeDark),
                                            ),
                                          ],
                                          selected: {mode},
                                          onSelectionChanged: (selection) {
                                            if (selection.isNotEmpty) {
                                              themeController.setThemeMode(
                                                selection.first,
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 12,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: isDark ? 0.35 : 0.6,
                          ),
                        ),
                        if (currentUser.isGuest)
                          _DrawerTile(
                            icon: Icons.login_rounded,
                            label: l10n.signInGoogleOrApple,
                            accentColor: colorScheme.primary,
                            onTap: () => _closeAndRun(context, onSignOut),
                          )
                        else ...[
                          _DrawerTile(
                            icon: Icons.logout_rounded,
                            label: l10n.signOut,
                            accentColor: const Color(0xFF64748B),
                            onTap: () => _closeAndRun(context, onSignOut),
                          ),
                          _DrawerTile(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.deleteAccount,
                            accentColor: colorScheme.error,
                            onTap: () => _confirmDeleteAccount(context),
                          ),
                        ],
                        if (isAdmin && onOpenAdminPanel != null) ...[
                          Divider(
                            height: 8,
                            thickness: 0.5,
                            color: colorScheme.outlineVariant.withValues(
                              alpha: isDark ? 0.35 : 0.6,
                            ),
                          ),
                          _DrawerTile(
                            key: const Key('drawer_admin_panel_tile'),
                            icon: Icons.admin_panel_settings_rounded,
                            label: l10n.adminPanelTitle,
                            accentColor: const Color(0xFFD97706),
                            onTap: () =>
                                _closeAndRun(context, onOpenAdminPanel!),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, bool isTr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
      child: TextField(
        key: const Key('drawer_search_field'),
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.80),
          hintText: isTr
              ? 'Modül ara (Varis, Tahlil, Su...)'
              : 'Search module (Vein, Lab, Water...)',
          hintStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 34),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
        ),
      ),
    );
  }

  IconData _providerIcon(AuthProviderType provider) {
    switch (provider) {
      case AuthProviderType.apple:
        return Icons.apple;
      case AuthProviderType.google:
        return Icons.g_mobiledata_rounded;
      case AuthProviderType.guest:
        return Icons.person_outline_rounded;
    }
  }
}

class _SearchableDrawerEntry {
  const _SearchableDrawerEntry({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
}

class _DrawerSubGroupHeader extends StatelessWidget {
  const _DrawerSubGroupHeader({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 3),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PastelIconBox extends StatelessWidget {
  const _PastelIconBox({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.11),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.32 : 0.24),
        ),
      ),
      child: child,
    );
  }
}

/// Expandable accordion section for Drawer categories (Visual Checks, Community,
/// Health Tracking, Settings) styled in Social Formula Bank pastel/neon aesthetic.
class _DrawerAccordionGroup extends StatelessWidget {
  const _DrawerAccordionGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
    this.badgeText,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;
  final String? badgeText;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: accentColor.withValues(alpha: 0.12),
          highlightColor: accentColor.withValues(alpha: 0.06),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.24 : 0.18),
              width: 0.9,
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            childrenPadding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: _PastelIconBox(
              color: accentColor,
              child: Icon(icon, color: accentColor, size: 19),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: 0.2,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Icon(
                  Icons.expand_more_rounded,
                  color: isDark ? Colors.white60 : Colors.black45,
                  size: 20,
                ),
              ],
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.leadingWidget,
    this.accentColor,
    this.selected = false,
    this.showDotDivider = false,
  });

  final IconData icon;
  final Widget? leadingWidget;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool selected;
  final bool showDotDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tint = accentColor ?? AppTheme.primaryTeal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          selected: selected,
          selectedTileColor: tint.withValues(alpha: 0.08),
          leading: _PastelIconBox(
            color: tint,
            child: leadingWidget ?? Icon(icon, size: 18, color: tint),
          ),
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              fontSize: 13.5,
              color: selected ? tint : colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          onTap: onTap,
        ),
        if (showDotDivider)
          Padding(
            padding: const EdgeInsets.fromLTRB(54, 0, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 0.8,
                    color: tint.withValues(alpha: 0.14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _localizedVeinTitle(String langCode) {
  switch (langCode) {
    case 'tr':
      return 'Damar & Varis Analizi';
    case 'de':
      return 'Venen- & Krampfadern-Analyse';
    case 'es':
      return 'Análisis de Venas y Varices';
    case 'fr':
      return 'Analyse des Veines et Varices';
    case 'it':
      return 'Analisi Vene e Varici';
    case 'nl':
      return 'Ader- & Spataderanalyse';
    case 'sv':
      return 'Ven- & Åderbråcksanalys';
    case 'pt':
      return 'Análise de Veias e Varizes';
    case 'ru':
      return 'Анализ вен и варикоза';
    case 'ar':
      return 'تحليل الأوردة والدوالي';
    case 'zh':
      return '静脉与静脉曲张分析';
    case 'hi':
      return 'नस और वैरिकोज़ विश्लेषण';
    case 'bn':
      return 'শিরা ও ভেরিকোজ বিশ্লেষণ';
    case 'ur':
      return 'رگوں اور ویریکوز کا تجزیہ';
    default:
      return 'Vein & Varicose Analysis';
  }
}

