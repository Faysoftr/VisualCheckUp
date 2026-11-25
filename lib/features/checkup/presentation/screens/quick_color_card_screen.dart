import 'package:flutter/material.dart';
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/checkup/data/color_health_analyzer.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/quick_color_swatch.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/result_screen.dart';

/// Camera-free 2-second color chart picker for privacy-sensitive categories
/// (urine hydration and stool awareness + Bristol Scale) with optional
/// food/medication context.
class QuickColorCardScreen extends StatefulWidget {
  const QuickColorCardScreen({
    super.key,
    required this.category,
    required this.historyRepository,
    this.analyzer,
  });

  final CheckCategory category;
  final HistoryRepository historyRepository;
  final ColorHealthAnalyzer? analyzer;

  @override
  State<QuickColorCardScreen> createState() => _QuickColorCardScreenState();
}

class _QuickColorCardScreenState extends State<QuickColorCardScreen> {
  late final List<QuickColorSwatch> _swatches;
  late final List<QuickContextOption> _contextOptions;
  String? _selectedSwatchId;
  BristolStoolType? _selectedBristol;
  final Set<String> _selectedContexts = <String>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _swatches = QuickColorCardCatalog.swatchesFor(widget.category);
    _contextOptions = QuickColorCardCatalog.contextOptionsFor(widget.category);
  }

  QuickColorSwatch? get _selectedSwatch {
    if (_selectedSwatchId == null) return null;
    for (final s in _swatches) {
      if (s.id == _selectedSwatchId) return s;
    }
    return null;
  }

  Future<void> _saveAndShowResult() async {
    final swatch = _selectedSwatch;
    if (swatch == null || _saving) return;

    setState(() => _saving = true);
    final result = QuickColorCardCatalog.buildResult(
      category: widget.category,
      swatch: swatch,
      selectedContextIds: _selectedContexts,
      bristolType: _selectedBristol,
    );
    await widget.historyRepository.saveResult(result);

    if (!mounted) return;
    setState(() => _saving = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          result: result,
          historyRepository: widget.historyRepository,
        ),
      ),
    );
  }

  Future<void> _switchToCamera() async {
    final hybrid = HybridHealthAnalyzer(
      fallbackAnalyzer: widget.analyzer ?? ColorHealthAnalyzer(),
      aiClient: GeminiVisionAiClient.fromEnvironment(),
      cacheRepository: widget.historyRepository,
    );
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: widget.category,
          analyzer: hybrid,
          historyRepository: widget.historyRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickCardTitle(widget.category.localizedTitle(l10n))),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                  : AppTheme.softMintTint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.no_photography_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.quickCardPrivacyBanner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.quickCardChooseShade,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _swatches.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final swatch = _swatches[index];
              final selected = swatch.id == _selectedSwatchId;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _selectedSwatchId = swatch.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: selected ? 2.2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: swatch.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(6),
                          child: selected
                              ? CircleAvatar(
                                  radius: 11,
                                  backgroundColor: colorScheme.primary,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        swatch.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        swatch.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.category == CheckCategory.stool) ...[
            const SizedBox(height: 20),
            Text(
              'Bristol Dışkı Kıvam Skalası (Opsiyonel • Tip 1–7)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: QuickColorCardCatalog.bristolScale.map((item) {
                final selected =
                    _selectedBristol?.typeNumber == item.typeNumber;
                return ChoiceChip(
                  selected: selected,
                  label: Text(item.title),
                  onSelected: (val) {
                    setState(() {
                      _selectedBristol = val ? item : null;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedBristol != null) ...[
              const SizedBox(height: 6),
              Text(
                '${_selectedBristol!.detail} — ${_selectedBristol!.clinicalCue}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ],
          if (_contextOptions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.quickCardExtraContext,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _contextOptions.map((option) {
                final active = _selectedContexts.contains(option.id);
                return FilterChip(
                  selected: active,
                  label: Text(option.label),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedContexts.add(option.id);
                      } else {
                        _selectedContexts.remove(option.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: (_selectedSwatch == null || _saving)
                ? null
                : _saveAndShowResult,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text(l10n.quickCardSaveViewBtn),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _switchToCamera,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.quickCardUseCameraBtn),
          ),
        ],
      ),
    );
  }
}
