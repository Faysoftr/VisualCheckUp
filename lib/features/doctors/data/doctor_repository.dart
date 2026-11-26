import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';

/// Repository for VisualCheckUp's Verified Doctors Directory (by country &
/// specialty), Doctor Applications, Admin Approval, and Patient Follow-Up
/// requests.
class DoctorRepository {
  DoctorRepository({
    this.useFirebase = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final bool useFirebase;
  final DateTime Function() _clock;

  static const String _doctorsKey = 'visualcheckup_doctors_v1';
  static const String _applicationsKey = 'visualcheckup_doctor_apps_v1';
  static const String _followUpsKey = 'visualcheckup_doctor_followups_v1';

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

  /// Curated global sample verified doctors across key countries so country
  /// search and patient follow-up work seamlessly immediately.
  static List<DoctorProfile> starterVerifiedDoctors() {
    final base = DateTime(2026, 11, 20);
    return [
      DoctorProfile(
        uid: 'doc_tr_selim',
        fullName: 'Selim Arslan',
        title: 'Uzm. Dr.',
        specialty: DoctorSpecialty.internalMedicine,
        countryCode: 'TR',
        city: 'İstanbul',
        hospitalOrClinic: 'Anadolu Sağlık Polikliniği',
        licenseNumber: 'TR-MD-48219',
        yearsExperience: 12,
        spokenLanguages: const ['tr', 'en'],
        bio:
            'Kronik hastalık yönetimi, diyabet ve hipertansiyon takibi ile kan tahlili değerlendirme alanında uzman.',
        acceptsPatientFollowUp: true,
        isOnline: true,
        isVerified: true,
        planTier: DoctorPlanTier.proFollowUpYearly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
      DoctorProfile(
        uid: 'doc_tr_derya',
        fullName: 'Derya Karahan',
        title: 'Doç. Dr.',
        specialty: DoctorSpecialty.dermatology,
        countryCode: 'TR',
        city: 'Ankara',
        hospitalOrClinic: 'Başkent Dermatoloji Merkezi',
        licenseNumber: 'TR-MD-61904',
        yearsExperience: 14,
        spokenLanguages: const ['tr', 'en', 'de'],
        bio:
            'Cilt lezyonları, egzama, sedef ve ben takibi üzerine klinik deneyim ve uzaktan rehberlik.',
        acceptsPatientFollowUp: true,
        isOnline: true,
        isVerified: true,
        planTier: DoctorPlanTier.proFollowUpYearly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
      DoctorProfile(
        uid: 'doc_de_hannah',
        fullName: 'Hannah Schneider',
        title: 'Dr. med.',
        specialty: DoctorSpecialty.cardiology,
        countryCode: 'DE',
        city: 'Berlin',
        hospitalOrClinic: 'Herz & Kreislauf Praxis Berlin',
        licenseNumber: 'DE-AEK-90312',
        yearsExperience: 11,
        spokenLanguages: const ['de', 'en'],
        bio:
            'Präventive Kardiologie, Bluthochdruck-Langzeitbegleitung und individuelle Lebensstilberatung.',
        acceptsPatientFollowUp: true,
        isOnline: true,
        isVerified: true,
        planTier: DoctorPlanTier.proFollowUpYearly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
      DoctorProfile(
        uid: 'doc_se_erik',
        fullName: 'Erik Lindqvist',
        title: 'Dr.',
        specialty: DoctorSpecialty.endocrinology,
        countryCode: 'SE',
        city: 'Stockholm',
        hospitalOrClinic: 'Nordic Metabolic Clinic',
        licenseNumber: 'SE-HOSP-22418',
        yearsExperience: 9,
        spokenLanguages: const ['sv', 'en'],
        bio:
            'Specialist i endokrinologi, typ 1/2-diabetes och sköldkörteluppföljning med digital patientkontakt.',
        acceptsPatientFollowUp: true,
        isOnline: true,
        isVerified: true,
        planTier: DoctorPlanTier.proFollowUpYearly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
      DoctorProfile(
        uid: 'doc_es_carlos',
        fullName: 'Carlos Mendoza',
        title: 'Dr.',
        specialty: DoctorSpecialty.familyMedicine,
        countryCode: 'ES',
        city: 'Madrid',
        hospitalOrClinic: 'Clínica Salud Integral Madrid',
        licenseNumber: 'ES-COL-77401',
        yearsExperience: 10,
        spokenLanguages: const ['es', 'en'],
        bio:
            'Medicina familiar, seguimiento preventivo de análisis clínicos y control de enfermedades crónicas.',
        acceptsPatientFollowUp: true,
        isOnline: false,
        isVerified: true,
        planTier: DoctorPlanTier.standardMonthly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
      DoctorProfile(
        uid: 'doc_us_maya',
        fullName: 'Maya Patel',
        title: 'MD',
        specialty: DoctorSpecialty.pediatrics,
        countryCode: 'US',
        city: 'Boston',
        hospitalOrClinic: 'Harbor Pediatric Wellness',
        licenseNumber: 'US-MA-55190',
        yearsExperience: 8,
        spokenLanguages: const ['en', 'hi'],
        bio:
            'Child growth percentile guidance, preventive pediatrics, and family nutrition counseling.',
        acceptsPatientFollowUp: true,
        isOnline: true,
        isVerified: true,
        planTier: DoctorPlanTier.proFollowUpYearly,
        status: DoctorApplicationStatus.approved,
        isSampleDoctor: true,
        createdAt: base,
      ),
    ];
  }

  Future<Map<String, DoctorProfile>> _loadLocalDoctors() async {
    final map = <String, DoctorProfile>{
      for (final d in starterVerifiedDoctors()) d.uid: d,
    };
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_doctorsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            map[entry.key] = DoctorProfile.fromJson(
              entry.value as Map<String, dynamic>,
              fallbackUid: entry.key,
            );
          }
        }
      } catch (_) {}
    }
    return map;
  }

  Future<void> _saveLocalDoctors(Map<String, DoctorProfile> map) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {for (final e in map.entries) e.key: e.value.toJson()};
    await prefs.setString(_doctorsKey, jsonEncode(payload));
  }

  Future<List<DoctorProfile>> searchDoctors({
    String? countryCode,
    DoctorSpecialty? specialty,
    bool followUpOnly = false,
    bool onlineOnly = false,
    String searchQuery = '',
  }) async {
    final merged = await _loadLocalDoctors();

    if (_canUseFirestore) {
      try {
        final snap = await _db
            .collection('doctor_profiles')
            .where('isVerified', isEqualTo: true)
            .limit(100)
            .get();
        for (final doc in snap.docs) {
          final p = DoctorProfile.fromJson(doc.data(), fallbackUid: doc.id);
          merged[p.uid] = p;
        }
      } catch (_) {}
    }

    final q = searchQuery.trim().toLowerCase();
    final list = merged.values.where((d) {
      if (!d.isVerified || d.status != DoctorApplicationStatus.approved) {
        return false;
      }
      if (countryCode != null &&
          countryCode.isNotEmpty &&
          countryCode != 'ALL' &&
          d.countryCode.toUpperCase() != countryCode.toUpperCase()) {
        return false;
      }
      if (specialty != null && d.specialty != specialty) return false;
      if (followUpOnly && !d.acceptsPatientFollowUp) return false;
      if (onlineOnly && !d.isOnline) return false;
      if (q.isNotEmpty) {
        final hay = [
          d.displayTitleName,
          d.city,
          d.country.label,
          d.hospitalOrClinic,
          d.bio,
          d.specialty.name,
        ].join(' ').toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    // Priority ranking: Pro Follow-Up Yearly doctors + online doctors first
    list.sort((a, b) {
      final aPro = a.planTier == DoctorPlanTier.proFollowUpYearly ? 1 : 0;
      final bPro = b.planTier == DoctorPlanTier.proFollowUpYearly ? 1 : 0;
      if (aPro != bPro) return bPro.compareTo(aPro);
      final aOn = a.isOnline ? 1 : 0;
      final bOn = b.isOnline ? 1 : 0;
      if (aOn != bOn) return bOn.compareTo(aOn);
      return b.yearsExperience.compareTo(a.yearsExperience);
    });
    return list;
  }

  // ---------------------------------------------------------------------------
  // Doctor Applications & Admin Approval
  // ---------------------------------------------------------------------------

  Future<List<DoctorProfile>> loadApplicationsForAdmin() async {
    final byId = <String, DoctorProfile>{};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_applicationsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final d = DoctorProfile.fromJson(item);
            if (d.uid.isNotEmpty) byId[d.uid] = d;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        final snap = await _db.collection('doctor_applications').limit(100).get();
        for (final doc in snap.docs) {
          final d = DoctorProfile.fromJson(doc.data(), fallbackUid: doc.id);
          byId[d.uid] = d;
        }
      } catch (_) {}
    }

    final list = byId.values.toList()
      ..sort((a, b) {
        if (a.status == DoctorApplicationStatus.pending &&
            b.status != DoctorApplicationStatus.pending) {
          return -1;
        }
        if (a.status != DoctorApplicationStatus.pending &&
            b.status == DoctorApplicationStatus.pending) {
          return 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
    return list;
  }

  Future<void> _saveLocalApplications(List<DoctorProfile> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _applicationsKey,
      jsonEncode(list.map((d) => d.toJson()).toList()),
    );
  }

  Future<DoctorProfile> submitApplication(DoctorProfile application) async {
    final normalized = application.copyWith(
      status: DoctorApplicationStatus.pending,
      isVerified: false,
    );
    final list = await loadApplicationsForAdmin();
    list.removeWhere((d) => d.uid == normalized.uid);
    list.insert(0, normalized);
    await _saveLocalApplications(list);

    if (_canUseFirestore) {
      try {
        await _db
            .collection('doctor_applications')
            .doc(normalized.uid)
            .set(normalized.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    return normalized;
  }

  Future<DoctorProfile?> loadMyApplication(String uid) async {
    final apps = await loadApplicationsForAdmin();
    for (final a in apps) {
      if (a.uid == uid) return a;
    }
    return null;
  }

  Future<void> markApplicationPaid(
    String uid, {
    String? purchasedPackage,
  }) async {
    final apps = await loadApplicationsForAdmin();
    final index = apps.indexWhere((a) => a.uid == uid);
    if (index != -1) {
      apps[index] = apps[index].copyWith(
        isPaid: true,
        purchasedPackage: purchasedPackage ?? apps[index].purchasedPackage,
      );
      await _saveLocalApplications(apps);
      if (_canUseFirestore) {
        try {
          await _db.collection('doctor_applications').doc(uid).set({
            'isPaid': true,
            'purchasedPackage': purchasedPackage ?? apps[index].purchasedPackage,
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    }
  }

  Future<void> reviewApplication({
    required String doctorUid,
    required bool approve,
  }) async {
    final apps = await loadApplicationsForAdmin();
    DoctorProfile? target;
    final updatedApps = <DoctorProfile>[];
    for (final app in apps) {
      if (app.uid == doctorUid) {
        target = app.copyWith(
          status: approve
              ? DoctorApplicationStatus.approved
              : DoctorApplicationStatus.rejected,
          isVerified: approve,
          isOnline: approve,
        );
        updatedApps.add(target);
      } else {
        updatedApps.add(app);
      }
    }
    await _saveLocalApplications(updatedApps);

    if (target != null && approve) {
      final doctors = await _loadLocalDoctors();
      doctors[doctorUid] = target;
      await _saveLocalDoctors(doctors);
    }

    if (_canUseFirestore && target != null) {
      try {
        await _db
            .collection('doctor_applications')
            .doc(doctorUid)
            .set(target.toJson(), SetOptions(merge: true));
        if (approve) {
          await _db
              .collection('doctor_profiles')
              .doc(doctorUid)
              .set(target.toJson(), SetOptions(merge: true));
        } else {
          await _db.collection('doctor_profiles').doc(doctorUid).delete();
        }
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Patient Follow-Up Requests (`doctor_followups`)
  // ---------------------------------------------------------------------------

  Future<List<PatientFollowUpRequest>> loadFollowUpRequests({
    String? patientUid,
    String? doctorUid,
  }) async {
    final byId = <String, PatientFollowUpRequest>{};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_followUpsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final req = PatientFollowUpRequest.fromJson(item);
            if (req.id.isNotEmpty) byId[req.id] = req;
          }
        }
      } catch (_) {}
    }

    if (_canUseFirestore) {
      try {
        Query<Map<String, dynamic>> query = _db.collection('doctor_followups');
        if (patientUid != null && patientUid.isNotEmpty) {
          query = query.where('patientUid', isEqualTo: patientUid);
        } else if (doctorUid != null && doctorUid.isNotEmpty) {
          query = query.where('doctorUid', isEqualTo: doctorUid);
        }
        final snap = await query.limit(100).get();
        for (final doc in snap.docs) {
          final req = PatientFollowUpRequest.fromJson(
            doc.data(),
            fallbackId: doc.id,
          );
          byId[req.id] = req;
        }
      } catch (_) {}
    }

    final list = byId.values.where((r) {
      if (patientUid != null && r.patientUid != patientUid) return false;
      if (doctorUid != null && r.doctorUid != doctorUid) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<PatientFollowUpRequest> requestPatientFollowUp({
    required DoctorProfile doctor,
    required String patientUid,
    required String patientName,
    String chronicSummary = '',
    String note = '',
  }) async {
    final now = _clock();
    final req = PatientFollowUpRequest(
      id: 'fu_${patientUid}_${doctor.uid}_${now.microsecondsSinceEpoch}',
      doctorUid: doctor.uid,
      doctorName: doctor.displayTitleName,
      patientUid: patientUid,
      patientName: patientName,
      chronicSummary: chronicSummary,
      note: note,
      status: 'pending',
      createdAt: now,
    );

    final all = await loadFollowUpRequests();
    all.insert(0, req);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _followUpsKey,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );

    if (_canUseFirestore) {
      try {
        await _db
            .collection('doctor_followups')
            .doc(req.id)
            .set(req.toJson(), SetOptions(merge: true));
      } catch (_) {}
    }
    return req;
  }

  Future<void> respondToFollowUp({
    required String requestId,
    required String status,
    String doctorNote = '',
  }) async {
    final all = await loadFollowUpRequests();
    final updated = all.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(status: status, doctorNote: doctorNote);
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _followUpsKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );

    if (_canUseFirestore) {
      try {
        await _db.collection('doctor_followups').doc(requestId).update({
          'status': status,
          if (doctorNote.trim().isNotEmpty) 'doctorNote': doctorNote.trim(),
        });
      } catch (_) {}
    }
  }
}
