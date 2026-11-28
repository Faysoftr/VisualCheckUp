import 'package:flutter/material.dart';
import 'package:visualcheckup/core/preferences/feature_preferences_controller.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';

/// Spacious, full-viewport Feature Personalization Wizard where intro & presets
/// scroll naturally with the list so feature selection gets maximum screen space.
class FeatureSelectionWizard extends StatefulWidget {
  const FeatureSelectionWizard({
    super.key,
    required this.controller,
    this.isInitialSetup = false,
  });

  final FeaturePreferencesController controller;
  final bool isInitialSetup;

  static Future<bool> show(
    BuildContext context, {
    required FeaturePreferencesController controller,
    bool isInitialSetup = false,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: !isInitialSetup,
      enableDrag: !isInitialSetup,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 680),
      backgroundColor: Colors.transparent,
      builder: (_) => FeatureSelectionWizard(
        controller: controller,
        isInitialSetup: isInitialSetup,
      ),
    );
    return saved ?? false;
  }

  @override
  State<FeatureSelectionWizard> createState() => _FeatureSelectionWizardState();
}

class _FeatureSelectionWizardState extends State<FeatureSelectionWizard> {
  late Set<PersonalHealthFeature> _selected;

  @override
  void initState() {
    super.initState();
    if (widget.isInitialSetup && !widget.controller.isWizardCompleted) {
      _selected = Set<PersonalHealthFeature>.from(
        PersonalHealthFeatureX.recommendedStarterSet,
      );
    } else {
      _selected = Set<PersonalHealthFeature>.from(widget.controller.value);
    }
  }

  void _toggle(PersonalHealthFeature feature) {
    setState(() {
      if (_selected.contains(feature)) {
        _selected.remove(feature);
      } else {
        _selected.add(feature);
      }
    });
  }

  void _applyPreset(Set<PersonalHealthFeature> preset) {
    setState(() {
      _selected = Set<PersonalHealthFeature>.from(preset);
    });
  }

  Future<void> _saveAndClose() async {
    await widget.controller.saveSelection(_selected);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _enableAllAndClose() async {
    await widget.controller.saveSelection(PersonalHealthFeatureX.allFeatures);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  bool _setEquals(Set<PersonalHealthFeature> a, Set<PersonalHealthFeature> b) {
    return a.length == b.length && a.containsAll(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final isTr = langCode == 'tr';

    final recommended = PersonalHealthFeatureX.recommendedStarterSet;
    final clinical = PersonalHealthFeatureX.clinicalPreset;
    final wellness = PersonalHealthFeatureX.wellnessPreset;
    final all = PersonalHealthFeatureX.allFeatures;
    final totalCount = PersonalHealthFeature.values.length;

    return Container(
      key: const Key('feature_selection_wizard_sheet'),
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1B1C) : const Color(0xFFF6FAFA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Slim compact top title bar ONLY (~50px) so the list gets full room
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryTeal, AppTheme.secondaryMint],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTr
                        ? 'Uygulamanızı Kişiselleştirin'
                        : 'Personalize Your Health Hub',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selected.length}/$totalCount',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                if (!widget.isInitialSetup) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),

          // Full-height scrollable body (intro + presets + categories scroll together!)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                // Short, concise helper text inside scroll view
                Text(
                  isTr
                      ? 'Kameralı Görsel Kontroller sabit olarak açıktır. Ekran kalabalığını önlemek için yalnızca kullanacağınız ek sağlık araçlarını seçin (Ayarlar\'dan her zaman değiştirebilirsiniz).'
                      : 'Camera Visual Checks stay active. Select only the extra health tools you want to see (changeable anytime in Settings).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Presets Wrap (scrolls away naturally as user browses)
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: [
                    _PresetChip(
                      chipKey: const Key('wizard_preset_recommended'),
                      label: isTr ? 'Önerilen' : 'Recommended',
                      icon: Icons.star_rounded,
                      selected: _setEquals(_selected, recommended),
                      onTap: () => _applyPreset(recommended),
                    ),
                    _PresetChip(
                      chipKey: const Key('wizard_preset_clinical'),
                      label: isTr ? 'Klinik & İlaç' : 'Clinical & Meds',
                      icon: Icons.medical_services_outlined,
                      selected: _setEquals(_selected, clinical),
                      onTap: () => _applyPreset(clinical),
                    ),
                    _PresetChip(
                      chipKey: const Key('wizard_preset_wellness'),
                      label: isTr ? 'Su, Adım & Form' : 'Daily Fitness',
                      icon: Icons.directions_walk_rounded,
                      selected: _setEquals(_selected, wellness),
                      onTap: () => _applyPreset(wellness),
                    ),
                    _PresetChip(
                      chipKey: const Key('wizard_preset_all'),
                      label: isTr ? 'Tümünü Aç' : 'Enable All',
                      icon: Icons.select_all_rounded,
                      selected: _setEquals(_selected, all),
                      onTap: () => _applyPreset(all),
                    ),
                    _PresetChip(
                      chipKey: const Key('wizard_preset_minimal'),
                      label: isTr ? 'Sadece Kamera' : 'Camera Only',
                      icon: Icons.camera_alt_outlined,
                      selected: _selected.isEmpty,
                      onTap: () => _applyPreset(<PersonalHealthFeature>{}),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Categorized Selectable Feature Cards
                for (final group in FeatureGroupCategory.values) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 7),
                    child: Row(
                      children: [
                        Icon(group.icon, size: 16, color: group.color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            group.localizedTitle(langCode),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: group.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final feature in PersonalHealthFeature.values
                      .where((f) => f.group == group))
                    _FeatureToggleTile(
                      key: Key('wizard_toggle_${feature.name}'),
                      feature: feature,
                      langCode: langCode,
                      selected: _selected.contains(feature),
                      isDark: isDark,
                      onTap: () => _toggle(feature),
                    ),
                ],
              ],
            ),
          ),

          // Slim single-row sticky bottom action bar (~64px)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132425) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.isInitialSetup) ...[
                  TextButton(
                    key: const Key('wizard_enable_all_btn'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _enableAllAndClose,
                    child: Text(
                      isTr ? 'Tümünü Aç' : 'Enable All',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('wizard_save_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _saveAndClose,
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isTr
                          ? 'Kaydet ve Başla (${_selected.length}/$totalCount)'
                          : 'Save (${_selected.length}/$totalCount)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.chipKey,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      key: chipKey,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(
        icon,
        size: 15,
        color: selected ? Colors.white : AppTheme.primaryTeal,
      ),
      backgroundColor: selected
          ? AppTheme.primaryTeal
          : (isDark ? const Color(0xFF172B2C) : Colors.white),
      side: BorderSide(
        color: selected
            ? AppTheme.primaryTeal
            : AppTheme.primaryTeal.withValues(alpha: 0.25),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          color: selected
              ? Colors.white
              : (isDark ? Colors.white : const Color(0xFF0E2929)),
        ),
      ),
      onPressed: onTap,
    );
  }
}

class _FeatureToggleTile extends StatelessWidget {
  const _FeatureToggleTile({
    super.key,
    required this.feature,
    required this.langCode,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final PersonalHealthFeature feature;
  final String langCode;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = feature.accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.20 : 0.09)
            : (isDark ? const Color(0xFF152526) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? accent
                    : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(feature.icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.localizedTitle(langCode),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        feature.localizedSubtitle(langCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? accent
                      : (isDark ? Colors.white30 : Colors.black26),
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
