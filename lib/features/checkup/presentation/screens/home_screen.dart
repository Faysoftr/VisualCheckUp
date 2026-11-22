import 'package:flutter/material.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/history_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_card.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/disclaimer_dialog.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.analyzer,
    required this.historyRepository,
  });

  final ColorHealthAnalyzer analyzer;
  final HistoryRepository historyRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AnalysisResult> _recent = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadRecent();
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

  Future<void> _loadRecent() async {
    final history = await widget.historyRepository.loadHistory();
    if (!mounted) return;
    setState(() {
      _recent = history.take(3).toList();
    });
  }

  Future<void> _openCategory(CheckCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: category,
          analyzer: widget.analyzer,
          historyRepository: widget.historyRepository,
        ),
      ),
    );
    await _loadRecent();
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(
          historyRepository: widget.historyRepository,
        ),
      ),
    );
    await _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisualCheckUp'),
        actions: [
          IconButton(
            onPressed: _openHistory,
            tooltip: 'Geçmiş',
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            onPressed: () => DisclaimerDialog.show(context),
            tooltip: 'Tıbbi Bilgilendirme',
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            MedicalDisclaimer.shortBanner,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kontrol Kategorileri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamera ile görsel ön değerlendirme yapmak istediğiniz alanı seçin.',
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
                            builder: (_) => ResultScreen(result: item),
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
