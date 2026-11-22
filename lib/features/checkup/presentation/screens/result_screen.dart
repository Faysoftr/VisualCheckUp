import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/checkup/data/doctor_report_builder.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/category_baseline.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/doctor_summary_sheet.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    this.historyRepository,
  });

  final AnalysisResult result;
  final HistoryRepository? historyRepository;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  CategoryBaseline? _savedBaseline;
  List<AnalysisResult> _allHistory = const [];
  bool _savingBaseline = false;

  @override
  void initState() {
    super.initState();
    _loadContextData();
  }

  Future<void> _loadContextData() async {
    final repo = widget.historyRepository;
    if (repo == null) return;
    final baseline = await repo.getBaseline(widget.result.category);
    final history = await repo.loadHistory();
    if (!mounted) return;
    setState(() {
      _savedBaseline = baseline;
      _allHistory = history;
    });
  }

  Future<void> _openDoctorSummary() async {
    final report = DoctorReportBuilder.build(
      currentResult: widget.result,
      allHistory: _allHistory,
    );
    await DoctorSummarySheet.show(context, report: report);
  }

  Future<void> _saveAsPersonalBaseline() async {
    final repo = widget.historyRepository;
    if (repo == null || _savingBaseline) return;
    setState(() => _savingBaseline = true);

    final baseline = CategoryBaseline.fromColor(
      category: widget.result.category,
      color: widget.result.dominantColor,
      calibratedWithWhiteRef: widget.result.whiteBalanceCalibrated,
    );
    await repo.saveBaseline(baseline);

    if (!mounted) return;
    setState(() {
      _savedBaseline = baseline;
      _savingBaseline = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.result.category.title} için kişisel normal tonunuz kaydedildi.',
        ),
      ),
    );
  }

  Future<void> _clearPersonalBaseline() async {
    final repo = widget.historyRepository;
    if (repo == null || _savingBaseline) return;
    setState(() => _savingBaseline = true);
    await repo.deleteBaseline(widget.result.category);
    if (!mounted) return;
    setState(() {
      _savedBaseline = null;
      _savingBaseline = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.result.category.title} kişisel normal kaydı kaldırıldı.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final theme = Theme.of(context);
    final riskColor = result.riskLevel.color;
    final dateText = DateFormat('dd.MM.yyyy HH:mm').format(result.createdAt);
    final previousInCategory = _allHistory
        .where((e) => e.category == result.category && e.id != result.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text('${result.category.title} Sonucu'),
        actions: [
          IconButton(
            onPressed: _openDoctorSummary,
            tooltip: 'Doktora Göster Özeti',
            icon: const Icon(Icons.assignment_outlined),
          ),
          IconButton(
            onPressed: () => ModuleReferenceSheet.show(context, result.category),
            tooltip: 'Referans Rehberi',
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Status Hero Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.riskLevel.icon,
                              size: 16,
                              color: riskColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              result.riskLevel.label,
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.summaryTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.summaryDetail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: result.dominantColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.whiteBalanceCalibrated
                                  ? 'Kalibre Edilmiş Renk Tonu'
                                  : 'Örneklenen Baskın Renk Tonu',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Ön değerlendirme güveni: %${(result.confidence * 100).round()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (result.whiteBalanceCalibrated ||
                      result.lightingNote != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: result.whiteBalanceCalibrated
                            ? const Color(0xFF1B8A5A).withValues(alpha: 0.10)
                            : const Color(0xFFD9822B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            result.whiteBalanceCalibrated
                                ? Icons.wb_auto_rounded
                                : Icons.wb_incandescent_outlined,
                            size: 16,
                            color: result.whiteBalanceCalibrated
                                ? const Color(0xFF1B8A5A)
                                : const Color(0xFFD9822B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.lightingNote ??
                                  'Beyaz referans ile renk dengelendi.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.riskLevel != RiskLevel.normal) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Danışılabilecek bölüm: ${result.category.recommendedSpecialty}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (previousInCategory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timeline_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Zaman İçi Değişim Karşılaştırması',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SwatchBadge(
                          color: previousInCategory.first.dominantColor,
                          label: DateFormat('dd.MM')
                              .format(previousInCategory.first.createdAt),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.arrow_forward_rounded, size: 16),
                        ),
                        _SwatchBadge(
                          color: result.dominantColor,
                          label: 'Bugün',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Önceki kayıt: "${previousInCategory.first.summaryTitle}" (${previousInCategory.first.riskLevel.label}). Toplam ${previousInCategory.length + 1} kayıt takip ediliyor.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.38,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (result.baselineComparisonNote != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kişisel Normal Karşılaştırması',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (_savedBaseline != null) ...[
                          _SwatchBadge(
                            color: _savedBaseline!.color,
                            label: 'Normaliniz',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded, size: 16),
                          ),
                        ],
                        _SwatchBadge(
                          color: result.dominantColor,
                          label: 'Bugün',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.baselineComparisonNote!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (result.warningFlags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF4F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: const Color(0xFFC93B3B).withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFC93B3B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Dikkat Edilmesi Gereken Belirtiler',
                          style: TextStyle(
                            color: Color(0xFFC93B3B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...result.warningFlags.map(
                      (flag) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $flag',
                          style: const TextStyle(
                            color: Color(0xFF7D2020),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (result.observations.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Gözlemler',
              icon: Icons.visibility_outlined,
              items: result.observations,
            ),
          ],

          if (result.recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Öneriler',
              icon: Icons.tips_and_updates_outlined,
              items: result.recommendations,
            ),
          ],

          if (widget.historyRepository != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kişisel Normal (Bazal) Kalibrasyon',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kendinizi sağlıklı hissettiğiniz bir günde bu ölçümü kişisel normaliniz olarak kaydedin; telefonunuzun kamera sensörüne özel sapmaları azaltır.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed:
                              _savingBaseline ? null : _saveAsPersonalBaseline,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            _savedBaseline == null
                                ? 'Kişisel Normalim Olarak Kaydet'
                                : 'Kişisel Normalimi Güncelle',
                          ),
                        ),
                        if (_savedBaseline != null)
                          TextButton.icon(
                            onPressed:
                                _savingBaseline ? null : _clearPersonalBaseline,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Kaydı Sil'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    MedicalDisclaimer.shortBanner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openDoctorSummary,
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Doktora Göster • Özet Hazırla'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Ana Ekrana Dön'),
          ),
        ],
      ),
    );
  }
}

class _SwatchBadge extends StatelessWidget {
  const _SwatchBadge({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
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
