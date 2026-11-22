import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/data/module_reference_catalog.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/module_reference.dart';

/// Bottom sheet displaying healthy reference vs. abnormal/warning visual
/// findings for a given [CheckCategory].
class ModuleReferenceSheet extends StatelessWidget {
  const ModuleReferenceSheet({
    super.key,
    required this.category,
  });

  final CheckCategory category;

  static Future<void> show(BuildContext context, CheckCategory category) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _ReferenceContent(
          category: category,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceContent(category: category);
  }
}

class _ReferenceContent extends StatelessWidget {
  const _ReferenceContent({
    required this.category,
    this.scrollController,
  });

  final CheckCategory category;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spec = ModuleReferenceCatalog.forCategory(category);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Row(
          children: [
            Icon(category.icon, color: category.accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${category.title} — Görsel Referanslar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
        const SizedBox(height: 16),

        // Healthy Reference section
        Text(
          'Sağlıklı Referans',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B8A5A),
          ),
        ),
        const SizedBox(height: 8),
        ...spec.healthyReferences.map((f) => _FindingCard(finding: f)),

        const SizedBox(height: 16),

        // Abnormal / warning findings section
        Text(
          'Dikkat Edilmesi Gereken / Sağlıksız Bulgular',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...spec.abnormalFindings.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FindingCard(finding: f),
          ),
        ),
      ],
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.finding});

  final ReferenceFinding finding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = finding.riskLevel.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: finding.swatchColor,
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
                        finding.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                              ? 'Sağlıklı Referans'
                              : finding.riskLevel.label,
                          style: TextStyle(
                            color: riskColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Görsel İşaret: ${finding.visualSignature}',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              'Olası Bağlam: ${finding.possibleAssociations}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (finding.redFlagNote != null) ...[
              const SizedBox(height: 6),
              Text(
                'Uyarı: ${finding.redFlagNote}',
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
    );
  }
}
