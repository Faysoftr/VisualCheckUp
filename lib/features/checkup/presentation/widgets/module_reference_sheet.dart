import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/module_reference.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/clinical_visual_illustration.dart';

/// Visual clinical reference atlas displaying illustrated healthy vs. abnormal
/// findings, capture protocol, Fitzpatrick scale (where applicable), and
/// evidence-based bedside self-tests for a given [CheckCategory].
class ModuleReferenceSheet extends StatelessWidget {
  const ModuleReferenceSheet({
    super.key,
    required this.category,
    this.initialFocusSelfTests = false,
  });

  final CheckCategory category;
  final bool initialFocusSelfTests;

  static Future<void> show(
    BuildContext context,
    CheckCategory category, {
    bool focusSelfTests = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, scrollController) => _ReferenceContent(
          category: category,
          scrollController: scrollController,
          initialFocusSelfTests: focusSelfTests,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceContent(
      category: category,
      initialFocusSelfTests: initialFocusSelfTests,
    );
  }
}

enum _AtlasFilter { all, urgentOnly, selfTests }

class _ReferenceContent extends StatefulWidget {
  const _ReferenceContent({
    required this.category,
    this.scrollController,
    this.initialFocusSelfTests = false,
  });

  final CheckCategory category;
  final ScrollController? scrollController;
  final bool initialFocusSelfTests;

  @override
  State<_ReferenceContent> createState() => _ReferenceContentState();
}

class _ReferenceContentState extends State<_ReferenceContent> {
  late _AtlasFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFocusSelfTests
        ? _AtlasFilter.selfTests
        : _AtlasFilter.all;
  }

  void _openComparisonModal(
    BuildContext context,
    ReferenceFinding finding,
    ReferenceFinding? healthyRef,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          finding.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (healthyRef != null && !finding.isHealthyReference)
                    Column(
                      children: [
                        ClinicalVisualIllustration(
                          findingId: healthyRef.id,
                          category: widget.category,
                          fallbackColor: healthyRef.swatchColor,
                          size: 112,
                          borderRadius: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.healthyReferenceLabel,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B8A5A),
                          ),
                        ),
                      ],
                    ),
                  Column(
                    children: [
                      ClinicalVisualIllustration(
                        findingId: finding.id,
                        category: widget.category,
                        fallbackColor: finding.swatchColor,
                        size: 112,
                        borderRadius: 18,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        finding.isHealthyReference
                            ? l10n.healthyReferenceLabel
                            : finding.riskLevel.localizedLabel(l10n),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: finding.riskLevel.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                l10n.atlasVisualCueLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                finding.visualSignature,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.atlasClinicalContextLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                finding.possibleAssociations,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (finding.redFlagNote != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC93B3B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l10n.atlasWarningPrefix}: ${finding.redFlagNote}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFC93B3B),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.atlasCloseBtn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final spec = ModuleReferenceCatalog.forCategory(widget.category);
    final healthyRef = spec.healthyReferences.firstOrNull;
    final urgentFindings = spec.abnormalFindings
        .where((f) => f.riskLevel == RiskLevel.urgent)
        .toList();

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Row(
          children: [
            Icon(widget.category.icon, color: widget.category.accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.referenceSheetTitle(widget.category.localizedTitle(l10n)),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          spec.healthySummary,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),

        // Interactive Atlas Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: Text(l10n.atlasFilterAll(spec.findings.length)),
              selected: _filter == _AtlasFilter.all,
              onSelected: (_) => setState(() => _filter = _AtlasFilter.all),
            ),
            if (urgentFindings.isNotEmpty)
              ChoiceChip(
                label: Text(l10n.atlasFilterUrgent(urgentFindings.length)),
                selected: _filter == _AtlasFilter.urgentOnly,
                onSelected: (_) =>
                    setState(() => _filter = _AtlasFilter.urgentOnly),
              ),
            if (spec.selfTests.isNotEmpty)
              ChoiceChip(
                label: Text(l10n.atlasFilterSelfTests(spec.selfTests.length)),
                selected: _filter == _AtlasFilter.selfTests,
                onSelected: (_) =>
                    setState(() => _filter = _AtlasFilter.selfTests),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (_filter == _AtlasFilter.selfTests) ...[
          for (final test in spec.selfTests) ...[
            _SelfTestCard(test: test),
            const SizedBox(height: 10),
          ],
          if (spec.captureQualityChecklist.isNotEmpty) ...[
            const SizedBox(height: 6),
            _CaptureProtocolCard(checklist: spec.captureQualityChecklist),
          ],
        ] else ...[
          if (_filter == _AtlasFilter.all) ...[
            // Healthy Reference section
            Text(
              l10n.healthyReferenceLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B8A5A),
              ),
            ),
            const SizedBox(height: 6),
            ...spec.healthyReferences.map(
              (f) => _FindingCard(
                finding: f,
                category: widget.category,
                onTap: () => _openComparisonModal(context, f, healthyRef),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Abnormal / warning findings section
          Text(
            _filter == _AtlasFilter.urgentOnly
                ? l10n.atlasUrgentSectionTitle
                : l10n.abnormalFindingsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.atlasTapToCompareHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final f in (_filter == _AtlasFilter.urgentOnly
              ? urgentFindings
              : spec.abnormalFindings))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FindingCard(
                finding: f,
                category: widget.category,
                onTap: () => _openComparisonModal(context, f, healthyRef),
              ),
            ),

          if ((widget.category == CheckCategory.face ||
                  widget.category == CheckCategory.skinCondition) &&
              _filter == _AtlasFilter.all) ...[
            const SizedBox(height: 4),
            const FitzpatrickScaleCard(),
            const SizedBox(height: 12),
          ],

          if (spec.clinicalMethodSummary != null &&
              _filter == _AtlasFilter.all) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      spec.clinicalMethodSummary!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (spec.captureQualityChecklist.isNotEmpty &&
              _filter == _AtlasFilter.all) ...[
            _CaptureProtocolCard(checklist: spec.captureQualityChecklist),
            const SizedBox(height: 12),
          ],

          if (spec.selfTests.isNotEmpty && _filter == _AtlasFilter.all) ...[
            const SizedBox(height: 4),
            Text(
              l10n.atlasHomeSelfTestsSectionTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final test in spec.selfTests) ...[
              _SelfTestCard(test: test),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ],
    );
  }
}

class _CaptureProtocolCard extends StatelessWidget {
  const _CaptureProtocolCard({required this.checklist});

  final List<String> checklist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_enhance_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.atlasCaptureProtocolTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final tip in checklist)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
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

class _SelfTestCard extends StatelessWidget {
  const _SelfTestCard({required this.test});

  final ClinicalSelfTest test;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.14),
                  child: Icon(
                    test.icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    test.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              test.purpose,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.38,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < test.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        fontSize: 12.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        test.steps[i],
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF1B8A5A).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${l10n.atlasSelfTestNormalPrefix}: ${test.normalResult}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF166B46),
                  fontWeight: FontWeight.w600,
                  height: 1.32,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFC93B3B).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${l10n.atlasSelfTestWarningPrefix}: ${test.warningResult}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFA62626),
                  fontWeight: FontWeight.w600,
                  height: 1.32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({
    required this.finding,
    required this.category,
    required this.onTap,
  });

  final ReferenceFinding finding;
  final CheckCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final riskColor = finding.riskLevel.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClinicalVisualIllustration(
                    findingId: finding.id,
                    category: category,
                    fallbackColor: finding.swatchColor,
                    size: 72,
                    borderRadius: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          finding.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                finding.isHealthyReference
                                    ? l10n.healthyReferenceLabel
                                    : finding.riskLevel.localizedLabel(l10n),
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.zoom_out_map_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${l10n.atlasVisualCueLabel}: ${finding.visualSignature}',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.atlasPossibleContextShort}: ${finding.possibleAssociations}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (finding.redFlagNote != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${l10n.atlasWarningPrefix}: ${finding.redFlagNote}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFC93B3B),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
