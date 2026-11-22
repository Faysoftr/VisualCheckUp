import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/home_screen.dart';

class VisualCheckUpApp extends StatelessWidget {
  const VisualCheckUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyzer = ColorHealthAnalyzer();
    final historyRepository = HistoryRepository();

    return MaterialApp(
      title: 'VisualCheckUp',
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
