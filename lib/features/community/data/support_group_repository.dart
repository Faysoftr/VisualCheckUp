import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/safety/content_safety_service.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/domain/support_group_models.dart';

/// Repository powering Health & Chronic Condition Support Groups
/// (`support_groups/{groupId}` + `messages/{msgId}`).
class SupportGroupRepository {
  SupportGroupRepository({
    this.useFirebase = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool useFirebase;
  final DateTime Function() _clock;

  static const String _groupsKey = 'visualcheckup_support_groups_v1';
  static const String _msgsKeyPrefix = 'visualcheckup_support_group_msgs_v1_';

  bool get _canUseFirestore {
    if (!useFirebase) return false;
    try {
      return Firebase.apps.isNotEmpty &&
          fb.FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static List<HealthSupportGroup> starterGroups() {
    final base = DateTime(2026, 11, 18);
    return [
      HealthSupportGroup(
        id: 'grp_tr_diabetes',
        name: 'Tip 2 Diyabet & Dengeli Beslenme',
        description:
            'Glisemik indeks, sabah yürüyüşleri ve kan şekeri takibi deneyim paylaşım grubu.',
        condition: ChronicCondition.type2Diabetes,
        countryCode: 'TR',
        languageCode: 'tr',
        creatorUid: 'sample_tr_ayse',
        creatorName: 'Ayşe Demir',
        memberUids: const ['sample_tr_ayse', 'sample_tr_mehmet', 'u_demo_1'],
        isSampleGroup: true,
        createdAt: base,
      ),
      HealthSupportGroup(
        id: 'grp_global_bp',
        name: 'Hypertension & DASH Lifestyle',
        description:
            'Low-sodium meal swaps, home blood pressure tracking routines, and daily movement.',
        condition: ChronicCondition.hypertension,
        countryCode: 'DE',
        languageCode: 'de',
        creatorUid: 'sample_de_lukas',
        creatorName: 'Lukas Weber',
        memberUids: const ['sample_de_lukas', 'sample_tr_mehmet'],
        isSampleGroup: true,
        createdAt: base,
      ),
      HealthSupportGroup(
        id: 'grp_se_thyroid',
        name: 'Sköldkörtel & Energi (Nordic)',
        description:
            'Dela vardagsrutiner, sömn och återhämtning vid hypotyreos och Hashimoto.',
        condition: ChronicCondition.thyroidHashimoto,
        countryCode: 'SE',
        languageCode: 'sv',
        creatorUid: 'doc_se_erik',
        creatorName: 'Dr. Erik Lindqvist',
        memberUids: const ['doc_se_erik', 'sample_tr_ayse'],
        isSampleGroup: true,
        createdAt: base,
      ),
      HealthSupportGroup(
        id: 'grp_es_migraine',
        name: 'Migraña y Descanso Consciente',
        description:
            'Diario de desencadenantes, hidratación y rutinas de sueño reparador.',
        condition: ChronicCondition.migraine,
        countryCode: 'ES',
        languageCode: 'es',
        creatorUid: 'sample_es_elena',
        creatorName: 'Elena Ruiz',
        memberUids: const ['sample_es_elena', 'u_demo_2'],
        isSampleGroup: true,
        createdAt: base,
      ),
    ];
  }

  Future<Map<String, HealthSupportGroup>> _loadLocalGroups() async {
    final map = <String, HealthSupportGroup>{
      for (final g in starterGroups()) g.id: g,
    };
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groupsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            map[entry.key] = HealthSupportGroup.fromJson(
              entry.value as Map<String, dynamic>,
              fallbackId: entry.key,
            );
          }
        }
      } catch (_) {}
    }
    return map;
  }

  Future<void> _saveLocalGroups(Map<String, HealthSupportGroup> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _groupsKey,
      jsonEncode({for (final e in map.entries) e.key: e.value.toJson()}),
    );
  }

  Future<List<HealthSupportGroup>> loadGroups({
    ChronicCondition? conditionFilter,
    String countryFilter = 'ALL',
  }) async {
    final merged = await _loadLocalGroups();
    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('support_groups').limit(80).get();
        for (final doc in snap.docs) {
          final g = HealthSupportGroup.fromJson(doc.data(), fallbackId: doc.id);
          merged[g.id] = g;
        }
      } catch (_) {}
    }
    final list = merged.values.where((g) {
      if (conditionFilter != null && g.condition != conditionFilter) {
        return false;
      }
      if (countryFilter != 'ALL' &&
          g.countryCode.toUpperCase() != countryFilter.toUpperCase()) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.memberCount.compareTo(a.memberCount));
    return list;
  }

  Future<HealthSupportGroup?> createGroup({
    required String name,
    required String description,
    ChronicCondition? condition,
    required String countryCode,
    required String languageCode,
    required String creatorUid,
    required String creatorName,
  }) async {
    final safety = ContentSafetyService.checkText('$name $description');
    if (!safety.isSafe) return null;

    final now = _clock();
    final group = HealthSupportGroup(
      id: 'grp_${now.microsecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      condition: condition,
      countryCode: countryCode,
      languageCode: languageCode,
      creatorUid: creatorUid,
      creatorName: creatorName,
      memberUids: [creatorUid],
      createdAt: now,
    );

    final map = await _loadLocalGroups();
    map[group.id] = group;
    await _saveLocalGroups(map);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('support_groups')
            .doc(group.id)
            .set(group.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    return group;
  }

  Future<HealthSupportGroup?> toggleMembership({
    required String groupId,
    required String uid,
  }) async {
    final map = await _loadLocalGroups();
    final existing = map[groupId];
    if (existing == null) return null;

    final alreadyIn = existing.isMember(uid);
    final updatedMembers = List<String>.from(existing.memberUids);
    if (alreadyIn) {
      updatedMembers.remove(uid);
    } else {
      updatedMembers.add(uid);
    }
    final updated = existing.copyWith(memberUids: updatedMembers);
    map[groupId] = updated;
    await _saveLocalGroups(map);

    if (_canUseFirestore && !existing.isSampleGroup) {
      try {
        await _db.collection('support_groups').doc(groupId).update({
          'memberUids': alreadyIn
              ? FieldValue.arrayRemove([uid])
              : FieldValue.arrayUnion([uid]),
        });
      } catch (_) {}
    }
    return updated;
  }

  Future<List<SupportGroupMessage>> loadMessages(String groupId) async {
    final byId = <String, SupportGroupMessage>{};
    if (groupId == 'grp_tr_diabetes') {
      byId['seed_m1'] = SupportGroupMessage(
        id: 'seed_m1',
        groupId: groupId,
        senderUid: 'sample_tr_ayse',
        senderName: 'Ayşe Demir',
        text: 'Hoş geldiniz! Bugün sabah 30 dk yürüyüş sonrası şekerim çok dengeliydi.',
        sentAt: _clock().subtract(const Duration(hours: 1)),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_msgsKeyPrefix$groupId');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final m = SupportGroupMessage.fromJson(item);
            if (m.id.isNotEmpty) byId[m.id] = m;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('support_groups')
            .doc(groupId)
            .collection('messages')
            .orderBy('sentAt', descending: false)
            .limit(100)
            .get();
        for (final doc in snap.docs) {
          final m = SupportGroupMessage.fromJson(doc.data(), fallbackId: doc.id);
          byId[m.id] = m;
        }
      } catch (_) {}
    }

    final list = byId.values.toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  Future<SupportGroupMessage?> sendMessage({
    required String groupId,
    required String senderUid,
    required String senderName,
    required String text,
    bool isVerifiedDoctor = false,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final safety = ContentSafetyService.checkText(trimmed);
    if (!safety.isSafe) return null;

    final now = _clock();
    final msg = SupportGroupMessage(
      id: 'gm_${now.microsecondsSinceEpoch}',
      groupId: groupId,
      senderUid: senderUid,
      senderName: senderName,
      isVerifiedDoctor: isVerifiedDoctor,
      text: trimmed,
      sentAt: now,
    );

    final existing = await loadMessages(groupId);
    final updated = [...existing, msg];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_msgsKeyPrefix$groupId',
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );

    if (_canUseFirestore) {
      try {
        await _db
            .collection('support_groups')
            .doc(groupId)
            .collection('messages')
            .doc(msg.id)
            .set(msg.toJson());
      } catch (_) {}
    }
    return msg;
  }
}
