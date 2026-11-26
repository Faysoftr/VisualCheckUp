import 'package:flutter/material.dart';
import 'package:visualcheckup/core/ai/gemini_vision_ai_client.dart';
import 'package:visualcheckup/core/ai/hybrid_health_analyzer.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/module_reference_sheet.dart';
import 'package:visualcheckup/features/skin/data/skin_condition_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

class SkinCheckScreen extends StatefulWidget {
  const SkinCheckScreen({
    super.key,
    required this.historyRepository,
    this.permissionService = const PermissionHandlerCameraService(),
    this.initialConcern,
  });

  final HistoryRepository historyRepository;
  final CameraPermissionService permissionService;
  final SkinConcernType? initialConcern;

  @override
  State<SkinCheckScreen> createState() => _SkinCheckScreenState();
}

enum _BodyAreaKey { faceNeck, armHand, torso, legFoot, scalp, other }

class _SkinCheckScreenState extends State<SkinCheckScreen> {
  late SkinConcernType _concernType;
  final Set<SkinSymptomFlag> _selectedSymptoms = <SkinSymptomFlag>{};
  _BodyAreaKey? _selectedBodyArea;

  @override
  void initState() {
    super.initState();
    _concernType = widget.initialConcern ?? SkinConcernType.skinCancerRisk;
    if (_concernType == SkinConcernType.facialSpot) {
      _selectedBodyArea = _BodyAreaKey.faceNeck;
    }
  }

  String _bodyAreaLabel(_BodyAreaKey key, BuildContext context) {
    final l10n = context.l10n;
    switch (key) {
      case _BodyAreaKey.faceNeck:
        return l10n.bodyAreaFaceNeck;
      case _BodyAreaKey.armHand:
        return l10n.bodyAreaArmHand;
      case _BodyAreaKey.torso:
        return l10n.bodyAreaTorso;
      case _BodyAreaKey.legFoot:
        return l10n.bodyAreaLegFoot;
      case _BodyAreaKey.scalp:
        return l10n.bodyAreaScalp;
      case _BodyAreaKey.other:
        return l10n.bodyAreaOther;
    }
  }

  void _selectConcern(SkinConcernType type) {
    setState(() {
      _concernType = type;
      if (type == SkinConcernType.facialSpot && _selectedBodyArea == null) {
        _selectedBodyArea = _BodyAreaKey.faceNeck;
      }
    });
  }

  Future<void> _startCameraScan() async {
    final skinContext = SkinCheckContext(
      concernType: _concernType,
      symptoms: Set<SkinSymptomFlag>.unmodifiable(_selectedSymptoms),
      bodyArea: _selectedBodyArea == null
          ? null
          : _bodyAreaLabel(_selectedBodyArea!, context),
    );

    final analyzer = HybridHealthAnalyzer(
      fallbackAnalyzer: SkinConditionAnalyzer(skinContext: skinContext),
      aiClient: GeminiVisionAiClient.fromEnvironment(),
      cacheRepository: widget.historyRepository,
      skinContext: skinContext,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraCheckScreen(
          category: CheckCategory.skinCondition,
          analyzer: analyzer,
          historyRepository: widget.historyRepository,
          permissionService: widget.permissionService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final accent = _concernType.accentColor;
    final relevantSymptoms = SkinSymptomFlagX.orderedFor(_concernType);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.skinScreenTitle),
        actions: [
          IconButton(
            onPressed: () => ModuleReferenceSheet.show(
              context,
              CheckCategory.skinCondition,
            ),
            tooltip: l10n.tooltipReferenceGuide,
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Intro banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_concernType.icon, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.skinIntroTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.skinIntroDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Step 1: Featured 4 sub-module cards
          Text(
            l10n.skinStep1Title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: SkinConcernTypeX.featuredSubModules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.38,
            ),
            itemBuilder: (context, index) {
              final type = SkinConcernTypeX.featuredSubModules[index];
              final selected = _concernType == type;
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _selectConcern(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? type.accentColor.withValues(alpha: 0.12)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? type.accentColor
                          : colorScheme.outlineVariant,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                type.accentColor.withValues(alpha: 0.15),
                            child: Icon(
                              type.icon,
                              size: 18,
                              color: type.accentColor,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: type.accentColor,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        type.localizedLabel(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (l10n.localeName == 'tr') ...[
                        const SizedBox(height: 2),
                        Text(
                          type.shortCardSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Text(
            l10n.skinOtherConcernsLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SkinConcernTypeX.generalConcerns.map((type) {
              final selected = _concernType == type;
              return ChoiceChip(
                label: Text(type.localizedLabel(l10n)),
                selected: selected,
                onSelected: (_) => _selectConcern(type),
              );
            }).toList(),
          ),
          if (l10n.localeName == 'tr') ...[
            const SizedBox(height: 8),
            Text(
              _concernType.helperText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.38,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Step 2: Contextual symptoms
          Text(
            l10n.skinStep2Title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: relevantSymptoms.map((flag) {
              final selected = _selectedSymptoms.contains(flag);
              return FilterChip(
                label: Text(flag.localizedLabel(l10n)),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedSymptoms.add(flag);
                    } else {
                      _selectedSymptoms.remove(flag);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Step 3: Optional body area
          Text(
            l10n.skinStep3Title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _BodyAreaKey.values.map((area) {
              final selected = _selectedBodyArea == area;
              return ChoiceChip(
                label: Text(_bodyAreaLabel(area, context)),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    _selectedBodyArea = value ? area : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Contextual guide for Bruise
          if (_concernType == SkinConcernType.bruise) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.blur_circular_rounded,
                          color: SkinConcernType.bruise.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.bruiseGuideTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final stage in SkinBruiseGuide.stages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: stage.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage.stage,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    stage.detail,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Contextual guide for Wart
          if (_concernType == SkinConcernType.wart) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grain_rounded,
                          color: SkinConcernType.wart.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.wartGuideTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final tip in SkinWartGuide.tips)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $tip',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.38,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ABCDE mole / skin cancer risk education card
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: _concernType == SkinConcernType.skinCancerRisk ||
                  _concernType == SkinConcernType.molePigment,
              leading: Icon(Icons.menu_book_outlined, color: accent),
              title: Text(
                l10n.abcdeGuideTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                l10n.abcdeGuideSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: SkinAbcdeGuide.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: accent.withValues(alpha: 0.14),
                        child: Text(
                          item.letter,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item.detail,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Disclaimer note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.disclaimerShort,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: _startCameraScan,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(l10n.skinStartCameraBtn),
          ),
        ],
      ),
    );
  }
}
