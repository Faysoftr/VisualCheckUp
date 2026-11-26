import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyProfile {
  const FamilyProfile({
    required this.id,
    required this.name,
    required this.relation,
  });

  static const FamilyProfile self = FamilyProfile(
    id: 'self',
    name: 'Ben',
    relation: 'Ana Profil',
  );

  final String id;
  final String name;
  final String relation;

  bool get isSelf => id == 'self';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'B';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
      };

  factory FamilyProfile.fromJson(Map<String, dynamic> json) {
    return FamilyProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      relation: (json['relation'] as String?) ?? 'Aile Üyesi',
    );
  }
}

/// Manages multiple family member profiles (e.g. Ben, Annem, Babam) so each
/// person's lab reports, vitals, and visual checks are tracked separately.
class FamilyProfileController extends ValueNotifier<FamilyProfile> {
  FamilyProfileController() : super(FamilyProfile.self);

  static const String _profilesKey = 'visualcheckup_family_profiles_v1';
  static const String _activeProfileKey = 'visualcheckup_active_profile_v1';

  List<FamilyProfile> _profiles = const [FamilyProfile.self];
  List<FamilyProfile> get profiles => List.unmodifiable(_profiles);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey);
    final loaded = <FamilyProfile>[FamilyProfile.self];
    if (raw != null) {
      for (final entry in raw) {
        try {
          final p = FamilyProfile.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          );
          if (!p.isSelf && !loaded.any((e) => e.id == p.id)) {
            loaded.add(p);
          }
        } catch (_) {}
      }
    }
    _profiles = loaded;

    final activeId = prefs.getString(_activeProfileKey) ?? 'self';
    value = _profiles.firstWhere(
      (p) => p.id == activeId,
      orElse: () => FamilyProfile.self,
    );
  }

  Future<void> selectProfile(FamilyProfile profile) async {
    value = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profile.id);
  }

  Future<FamilyProfile> addProfile({
    required String name,
    required String relation,
  }) async {
    final profile = FamilyProfile(
      id: 'fam_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      relation: relation.trim().isEmpty ? 'Aile Üyesi' : relation.trim(),
    );
    _profiles = [..._profiles, profile];
    await _persistProfiles();
    await selectProfile(profile);
    return profile;
  }

  Future<void> removeProfile(String id) async {
    if (id == 'self') return;
    _profiles = _profiles.where((p) => p.id != id).toList();
    await _persistProfiles();
    if (value.id == id) {
      await selectProfile(FamilyProfile.self);
    } else {
      notifyListeners();
    }
  }

  Future<void> _persistProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = _profiles.where((p) => !p.isSelf).toList();
    await prefs.setStringList(
      _profilesKey,
      custom.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}

class FamilyProfileSheet {
  FamilyProfileSheet._();

  static Future<void> show(
    BuildContext context, {
    required FamilyProfileController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _FamilyProfileSheetBody(controller: controller),
    );
  }
}

class _FamilyProfileSheetBody extends StatefulWidget {
  const _FamilyProfileSheetBody({required this.controller});

  final FamilyProfileController controller;

  @override
  State<_FamilyProfileSheetBody> createState() =>
      _FamilyProfileSheetBodyState();
}

class _FamilyProfileSheetBodyState extends State<_FamilyProfileSheetBody> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedRelation = 'Anne';

  static const _relations = ['Anne', 'Baba', 'Eş', 'Çocuk', 'Diğer'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await widget.controller.addProfile(
      name: name,
      relation: _selectedRelation,
    );
    _nameController.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: ValueListenableBuilder<FamilyProfile>(
          valueListenable: widget.controller,
          builder: (context, active, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Aile Profilleri',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kendi ölçümlerinizle anne, baba veya eşinizin kan tahlili, tansiyon ve görsel kontrollerini ayrı profillerde güvenle takip edin.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                for (final profile in widget.controller.profiles)
                  Card(
                    color: profile.id == active.id
                        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          profile.initials,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        profile.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(profile.relation),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (profile.id == active.id)
                            Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                            ),
                          if (!profile.isSelf)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              onPressed: () async {
                                await widget.controller.removeProfile(profile.id);
                                if (mounted) setState(() {});
                              },
                            ),
                        ],
                      ),
                      onTap: () async {
                        await widget.controller.selectProfile(profile);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  'Yeni Aile Üyesi Ekle',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _relations.map((rel) {
                    return ChoiceChip(
                      label: Text(rel),
                      selected: _selectedRelation == rel,
                      onSelected: (_) => setState(() => _selectedRelation = rel),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad / Profil Adı (Örn: Annem)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _add,
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
