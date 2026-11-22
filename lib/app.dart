import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/theme_controller.dart';
import 'package:visualcheckup/features/auth/data/auth_service.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/auth/presentation/screens/login_screen.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/home_screen.dart';
import 'package:visualcheckup/features/labs_vitals/data/labs_vitals_repository.dart';

class VisualCheckUpApp extends StatefulWidget {
  const VisualCheckUpApp({
    super.key,
    this.authService,
    this.themeController,
    this.historyRepository,
    this.labsVitalsRepository,
    this.analyzer,
    this.initialUser,
  });

  final AuthService? authService;
  final ThemeController? themeController;
  final HistoryRepository? historyRepository;
  final LabsVitalsRepository? labsVitalsRepository;
  final ColorHealthAnalyzer? analyzer;
  final AuthUser? initialUser;

  @override
  State<VisualCheckUpApp> createState() => _VisualCheckUpAppState();
}

class _VisualCheckUpAppState extends State<VisualCheckUpApp> {
  late final AuthService _authService;
  late final ThemeController _themeController;
  late final bool _ownsThemeController;
  late final HistoryRepository _historyRepository;
  late final LabsVitalsRepository _labsVitalsRepository;
  late final ColorHealthAnalyzer _analyzer;

  AuthUser? _currentUser;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? const LocalAuthService();
    _ownsThemeController = widget.themeController == null;
    _themeController = widget.themeController ?? ThemeController();
    _historyRepository = widget.historyRepository ?? HistoryRepository();
    _labsVitalsRepository =
        widget.labsVitalsRepository ?? LabsVitalsRepository();
    _analyzer = widget.analyzer ?? ColorHealthAnalyzer();
    _currentUser = widget.initialUser;
    _bootstrapping = widget.initialUser == null;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _themeController.load();
    if (widget.initialUser == null) {
      final restoredUser = await _authService.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = restoredUser;
        _bootstrapping = false;
      });
    }
  }

  @override
  void dispose() {
    if (_ownsThemeController) {
      _themeController.dispose();
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
    await _historyRepository.clearAllUserData();
    await _labsVitalsRepository.clearAll();
    await _authService.deleteAccount();
    if (!mounted) return;
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) {
        final Widget home;
        if (_bootstrapping) {
          home = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (_currentUser == null) {
          home = LoginScreen(
            authService: _authService,
            onAuthenticated: _handleAuthenticated,
          );
        } else {
          home = HomeScreen(
            analyzer: _analyzer,
            historyRepository: _historyRepository,
            labsVitalsRepository: _labsVitalsRepository,
            currentUser: _currentUser!,
            themeController: _themeController,
            onSignOut: _handleSignOut,
            onDeleteAccount: _handleDeleteAccount,
          );
        }

        return MaterialApp(
          title: 'VisualCheckUp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: home,
        );
      },
    );
  }
}
