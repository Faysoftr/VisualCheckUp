import 'package:flutter/material.dart';
import 'package:visualcheckup/core/cloud/cloud_backup_service.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/core/profile/family_profile_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/auth/presentation/screens/login_screen.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/home_screen.dart';
import 'package:visualcheckup/features/diet/data/diet_repository.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_scheduler.dart';
import 'package:visualcheckup/features/medications/data/medication_alarm_watcher.dart';
import 'package:visualcheckup/features/medications/data/medication_reminder_repository.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/medications/presentation/screens/medication_alarm_ring_screen.dart';
import 'package:visualcheckup/features/splash/presentation/screens/splash_screen.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

class VisualCheckUpApp extends StatefulWidget {
  const VisualCheckUpApp({
    super.key,
    this.authService,
    this.themeController,
    this.localeController,
    this.historyRepository,
    this.labsVitalsRepository,
    this.medicationRepository,
    this.dietRepository,
    this.alarmScheduler,
    this.analyzer,
    this.initialUser,
    this.showSplash,
  });

  final AuthService? authService;
  final ThemeController? themeController;
  final LocaleController? localeController;
  final HistoryRepository? historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;
  final MedicationReminderRepository? medicationRepository;
  final DietRepository? dietRepository;
  final MedicationAlarmScheduler? alarmScheduler;
  final ColorHealthAnalyzer? analyzer;
  final AuthUser? initialUser;
  final bool? showSplash;

  @override
  State<VisualCheckUpApp> createState() => _VisualCheckUpAppState();
}

class _VisualCheckUpAppState extends State<VisualCheckUpApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthService _authService;
  late final ThemeController _themeController;
  late final bool _ownsThemeController;
  late final LocaleController _localeController;
  late final bool _ownsLocaleController;
  late final FamilyProfileController _profileController;
  late final HistoryRepository? _injectedHistoryRepository;
  late final LabsVitalsRepository? _injectedLabsVitalsRepository;
  late final MedicationReminderRepository? _injectedMedicationRepository;
  late final DietRepository? _injectedDietRepository;
  late final MedicationAlarmScheduler _alarmScheduler;
  late final MedicationAlarmWatcher _alarmWatcher;
  late final ColorHealthAnalyzer _analyzer;

  HistoryRepository get _activeHistoryRepository =>
      _injectedHistoryRepository ??
      HistoryRepository(profileId: _profileController.value.id);

  LabsVitalsRepository get _activeLabsVitalsRepository =>
      _injectedLabsVitalsRepository ??
      LabsVitalsRepository(profileId: _profileController.value.id);

  MedicationReminderRepository get _activeMedicationRepository =>
      _injectedMedicationRepository ??
      MedicationReminderRepository(profileId: _profileController.value.id);

  DietRepository get _activeDietRepository =>
      _injectedDietRepository ??
      DietRepository(profileId: _profileController.value.id);

  AuthUser? _currentUser;
  bool _bootstrapping = true;
  bool _splashCompleted = false;
  bool _showingAlarmScreen = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? const LocalAuthService();
    _ownsThemeController = widget.themeController == null;
    _themeController = widget.themeController ?? ThemeController();
    _ownsLocaleController = widget.localeController == null;
    _localeController = widget.localeController ?? LocaleController();
    _profileController = FamilyProfileController();
    _injectedHistoryRepository = widget.historyRepository;
    _injectedLabsVitalsRepository = widget.labsVitalsRepository;
    _injectedMedicationRepository = widget.medicationRepository;
    _injectedDietRepository = widget.dietRepository;
    _alarmScheduler =
        widget.alarmScheduler ?? LocalMedicationAlarmScheduler.instance;
    _alarmWatcher = MedicationAlarmWatcher(
      repositoryProvider: () => _activeMedicationRepository,
      onAlarmTriggered: _openRingingAlarm,
    );
    _analyzer = widget.analyzer ?? ColorHealthAnalyzer();
    _currentUser = widget.initialUser;
    _bootstrapping = widget.initialUser == null;
    final shouldShowSplash = widget.showSplash ?? (widget.initialUser == null);
    _splashCompleted = !shouldShowSplash;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _themeController.load();
    await _localeController.load();
    await _profileController.load();
    await _alarmScheduler.initialize(
      onAlarmNotificationTap: _handleAlarmNotificationTap,
    );
    if (widget.initialUser == null) {
      final restoredUser = await _authService.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = restoredUser;
        _bootstrapping = false;
      });
    }
    _alarmWatcher.start();

    final launchReminderId = await _alarmScheduler.getLaunchReminderId();
    if (launchReminderId != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAlarmNotificationTap(launchReminderId);
      });
    }
  }

  Future<void> _handleAlarmNotificationTap(String reminderId) async {
    if (!mounted) return;
    final reminder = await _activeMedicationRepository.findById(reminderId);
    if (reminder == null || !mounted) return;
    _openRingingAlarm(reminder);
  }

  void _openRingingAlarm(MedicationReminder reminder) {
    if (_showingAlarmScreen || !mounted) return;
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return;
    _showingAlarmScreen = true;
    MedicationAlarmRingScreen.show(
      navContext,
      reminder: reminder,
      repository: _activeMedicationRepository,
      scheduler: _alarmScheduler,
    ).whenComplete(() {
      _showingAlarmScreen = false;
    });
  }

  @override
  void dispose() {
    _alarmWatcher.dispose();
    _profileController.dispose();
    if (_ownsThemeController) {
      _themeController.dispose();
    }
    if (_ownsLocaleController) {
      _localeController.dispose();
    }
    super.dispose();
  }

  void _handleAuthenticated(AuthUser user) {
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
    setState(() {
      _currentUser = null;
    });
  }

  Future<void> _handleDeleteAccount() async {
    await const CloudBackupService().deleteAllCloudData();
    await _activeHistoryRepository.clearAllUserData();
    await _activeLabsVitalsRepository.clearAll();
    await _activeMedicationRepository.clearAll();
    await _activeDietRepository.clearAll();
    await _authService.deleteAccount();
    if (!mounted) return;
    setState(() {
      _currentUser = null;
    });
  }

  void _handleSplashComplete() {
    if (!mounted) return;
    setState(() {
      _splashCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: _localeController,
          builder: (context, locale, _) {
            final Widget home;
            if (!_splashCompleted) {
              home = SplashScreen(onComplete: _handleSplashComplete);
            } else if (_bootstrapping) {
              home = const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (_currentUser == null) {
              home = LoginScreen(
                authService: _authService,
                localeController: _localeController,
                onAuthenticated: _handleAuthenticated,
              );
            } else {
              home = ValueListenableBuilder<FamilyProfile>(
                valueListenable: _profileController,
                builder: (context, activeProfile, _) {
                  return HomeScreen(
                    key: ValueKey<String>('home_${activeProfile.id}'),
                    analyzer: _analyzer,
                    historyRepository: _activeHistoryRepository,
                    labsVitalsRepository: _activeLabsVitalsRepository,
                    medicationRepository: _activeMedicationRepository,
                    dietRepository: _activeDietRepository,
                    alarmScheduler: _alarmScheduler,
                    currentUser: _currentUser!,
                    themeController: _themeController,
                    localeController: _localeController,
                    profileController: _profileController,
                    onSignOut: _handleSignOut,
                    onDeleteAccount: _handleDeleteAccount,
                  );
                },
              );
            }

            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'VisualCheckUp',
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: KeyedSubtree(
                  key: ValueKey<String>(
                    !_splashCompleted
                        ? 'splash'
                        : _bootstrapping
                            ? 'bootstrapping'
                            : _currentUser == null
                                ? 'login'
                                : 'home',
                  ),
                  child: home,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
