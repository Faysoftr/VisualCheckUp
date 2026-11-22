import 'package:flutter/material.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
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

class _SkinCheckScreenState extends State<SkinCheckScreen> {
  static const List<String> _bodyAreas = [
    'Yüz / Boyun',
    'Kol / El',
    'Gövde',
    'Bacak / Ayak',
    'Saçlı Deri',
    'Diğer',
  ];

  late SkinConcernType _concernType;
  final Set<SkinSymptomFlag> _selectedSymptoms = <SkinSymptomFlag>{};
  String? _selectedBodyArea;

  @override
  void initState() {
    super.initState();
    _concernType = widget.initialConcern ?? SkinConcernType.skinCancerRisk;
    if (_concernType == SkinConcernType.facialSpot) {
      _selectedBodyArea = 'Yüz / Boyun';
    }
  }

  void _selectConcern(SkinConcernType type) {
    setState(() {
      _concernType = type;
      if (type == SkinConcernType.facialSpot && _selectedBodyArea == null) {
        _selectedBodyArea = 'Yüz / Boyun';
      }
    });
  }

  Future<void> _startCameraScan() async {
    final skinContext = SkinCheckContext(
      concernType: _concernType,
      symptoms: Set<SkinSymptomFlag>.unmodifiable(_selectedSymptoms),
      bodyArea: _selectedBodyArea,
    );

    final analyzer = SkinConditionAnalyzer(skinContext: skinContext);

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
    final accent = _concernType.accentColor;
    final relevantSymptoms = SkinSymptomFlagX.orderedFor(_concernType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cilt Hastalıkları Ön Kontrol'),
        actions: [
          IconButton(
            onPressed: () => ModuleReferenceSheet.show(
              context,
              CheckCategory.skinCondition,
            ),
            tooltip: 'Cilt Referans Rehberi',
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
                        'Görsel Dermatoloji Ön Tarama',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ben/cilt kanseri risk işaretleri, siğil, morluk ve yüz lekeleri için çevre cilt kıyaslı ön değerlendirme sunar. Kesin teşhis koymaz; dermatoloğa hazırlık amaçlıdır.',
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
            '1. Özel Cilt Ön Tarama Modülü Seçin',
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
                        type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Text(
            'Diğer Cilt Görünümleri',
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
                label: Text(type.label),
                selected: selected,
                onSelected: (_) => _selectConcern(type),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _concernType.helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.38,
            ),
          ),

          const SizedBox(height: 20),

          // Step 2: Contextual symptoms
          Text(
            '2. Eşlik Eden Belirtiler (Opsiyonel)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Varsa ilgili belirtileri seçin; risk önceliği buna göre uyarlanır.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: relevantSymptoms.map((flag) {
              final selected = _selectedSymptoms.contains(flag);
              return FilterChip(
                label: Text(flag.label),
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
            '3. Vücut Bölgesi (Opsiyonel)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bodyAreas.map((area) {
              final selected = _selectedBodyArea == area;
              return ChoiceChip(
                label: Text(area),
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
                        Text(
                          'Morluk Renk Evreleri Rehberi',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
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
                        Text(
                          'Siğil Ön Kontrol & Güvenlik Rehberi',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
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
                'Benler İçin ABCDE Kontrol Rehberi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Dermatologların ben ve cilt kanseri ön taramasında kullandığı 5 işaret',
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
                    MedicalDisclaimer.shortBanner,
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
            label: const Text('Kamera ile Cilt Kontrolünü Başlat'),
          ),
        ],
      ),
    );
  }
}
