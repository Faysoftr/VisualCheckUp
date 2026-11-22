import 'package:flutter/material.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/core/services/camera_permission_service.dart';
import 'package:visualcheckup/features/checkup/data/history_repository.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/screens/camera_check_screen.dart';
import 'package:visualcheckup/features/skin/data/skin_condition_analyzer.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';

class SkinCheckScreen extends StatefulWidget {
  const SkinCheckScreen({
    super.key,
    required this.historyRepository,
    this.permissionService = const PermissionHandlerCameraService(),
  });

  final HistoryRepository historyRepository;
  final CameraPermissionService permissionService;

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

  SkinConcernType _concernType = SkinConcernType.rashRedness;
  final Set<SkinSymptomFlag> _selectedSymptoms = <SkinSymptomFlag>{};
  String? _selectedBodyArea;

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
    final accent = CheckCategory.skinCondition.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cilt Hastalıkları Ön Kontrol'),
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
                Icon(Icons.healing_outlined, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Görsel Dermatoloji Ön Farkındalık',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Döküntü, kızarıklık, pullanma veya ben/leke görünümünü çevre cilt tonuyla karşılaştırarak ön ipuçları sunar. Tıbbi teşhis koymaz; görüntüler cihazınızdan çıkmaz.',
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

          const SizedBox(height: 20),

          // Step 1: Concern type
          Text(
            '1. İncelemek İstediğiniz Görünüm',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SkinConcernType.values.map((type) {
              final selected = _concernType == type;
              return ChoiceChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (_) => setState(() => _concernType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _concernType.helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // Step 2: Optional symptoms
          Text(
            '2. Eşlik Eden Belirtiler (Opsiyonel)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Varsa ilgili belirtileri seçin; uyarı önceliği buna göre değerlendirilir.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SkinSymptomFlag.values.map((flag) {
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

          const SizedBox(height: 20),

          // ABCDE mole self-check education card
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: _concernType == SkinConcernType.molePigment,
              leading: Icon(Icons.menu_book_outlined, color: accent),
              title: Text(
                'Benler İçin ABCDE Kontrol Rehberi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Dermatologların ben takibinde kullandığı 5 temel işaret',
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
