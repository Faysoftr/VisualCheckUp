import 'package:flutter/material.dart';
import 'package:healthcheck/core/theme/app_theme.dart';
import 'package:healthcheck/features/checkup/data/color_health_analyzer.dart';
import 'package:healthcheck/features/checkup/data/history_repository.dart';
import 'package:healthcheck/features/checkup/presentation/screens/home_screen.dart';

class HealthCheckApp extends StatelessWidget {
  const HealthCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyzer = ColorHealthAnalyzer();
    final historyRepository = HistoryRepository();

    return MaterialApp(
      title: 'HealthCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(
        analyzer: analyzer,
        historyRepository: historyRepository,
      ),
    );
  }
}
