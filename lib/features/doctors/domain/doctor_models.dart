import 'package:flutter/material.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Medical specialties for verified Doctors in VisualCheckUp.
enum DoctorSpecialty {
  internalMedicine,
  cardiology,
  dermatology,
  endocrinology,
  neurology,
  ophthalmology,
  pediatrics,
  familyMedicine,
  nutritionDietetics,
  psychiatry,
  pulmonology,
  nephrology,
}

extension DoctorSpecialtyX on DoctorSpecialty {
  String get id => name;

  static DoctorSpecialty fromId(String? value) {
    for (final s in DoctorSpecialty.values) {
      if (s.name == value) return s;
    }
    return DoctorSpecialty.internalMedicine;
  }

  IconData get icon {
    switch (this) {
      case DoctorSpecialty.internalMedicine:
        return Icons.medical_services_outlined;
      case DoctorSpecialty.cardiology:
        return Icons.monitor_heart_outlined;
      case DoctorSpecialty.dermatology:
        return Icons.face_retouching_natural_outlined;
      case DoctorSpecialty.endocrinology:
        return Icons.water_drop_outlined;
      case DoctorSpecialty.neurology:
        return Icons.psychology_outlined;
      case DoctorSpecialty.ophthalmology:
        return Icons.visibility_outlined;
      case DoctorSpecialty.pediatrics:
        return Icons.child_care_outlined;
      case DoctorSpecialty.familyMedicine:
        return Icons.family_restroom_outlined;
      case DoctorSpecialty.nutritionDietetics:
        return Icons.restaurant_menu_outlined;
      case DoctorSpecialty.psychiatry:
        return Icons.self_improvement_outlined;
      case DoctorSpecialty.pulmonology:
        return Icons.air_rounded;
      case DoctorSpecialty.nephrology:
        return Icons.biotech_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case DoctorSpecialty.internalMedicine:
        return const Color(0xFF0B6E6E);
      case DoctorSpecialty.cardiology:
        return const Color(0xFFDC2626);
      case DoctorSpecialty.dermatology:
        return const Color(0xFFEA580C);
      case DoctorSpecialty.endocrinology:
        return const Color(0xFF7C3AED);
      case DoctorSpecialty.neurology:
        return const Color(0xFF4F46E5);
      case DoctorSpecialty.ophthalmology:
        return const Color(0xFF0284C7);
      case DoctorSpecialty.pediatrics:
        return const Color(0xFF16A34A);
      case DoctorSpecialty.familyMedicine:
        return const Color(0xFF0D9488);
      case DoctorSpecialty.nutritionDietetics:
        return const Color(0xFF15803D);
      case DoctorSpecialty.psychiatry:
        return const Color(0xFF9333EA);
      case DoctorSpecialty.pulmonology:
        return const Color(0xFF0369A1);
      case DoctorSpecialty.nephrology:
        return const Color(0xFF0F766E);
    }
  }
}

/// Verified Doctor directory & patient follow-up membership plans.
enum DoctorPlanTier {
  standardMonthly,
  proFollowUpYearly,
}

extension DoctorPlanTierX on DoctorPlanTier {
  static DoctorPlanTier fromId(String? value) {
    for (final p in DoctorPlanTier.values) {
      if (p.name == value) return p;
    }
    return DoctorPlanTier.standardMonthly;
  }

  String get productId {
    switch (this) {
      case DoctorPlanTier.standardMonthly:
        return 'visualcheckup_doctor_monthly';
      case DoctorPlanTier.proFollowUpYearly:
        return 'visualcheckup_doctor_yearly';
    }
  }

  double get usdPrice {
    switch (this) {
      case DoctorPlanTier.standardMonthly:
        return 14.99;
      case DoctorPlanTier.proFollowUpYearly:
        return 119.99;
    }
  }

  String localizedPrice(String languageCode) {
    final code = languageCode.toLowerCase();
    switch (this) {
      case DoctorPlanTier.standardMonthly:
        if (code == 'tr') return '₺449,99';
        if (code == 'de' || code == 'es' || code == 'fr' || code == 'it' || code == 'nl' || code == 'pt') {
          return '€14,99';
        }
        if (code == 'sv') return '165 kr';
        return '\$14.99';
      case DoctorPlanTier.proFollowUpYearly:
        if (code == 'tr') return '₺3.499,99';
        if (code == 'de' || code == 'es' || code == 'fr' || code == 'it' || code == 'nl' || code == 'pt') {
          return '€119,99';
        }
        if (code == 'sv') return '1.290 kr';
        return '\$119.99';
    }
  }
}

/// Verification status for a doctor application.
enum DoctorApplicationStatus {
  pending,
  approved,
  rejected,
}

extension DoctorApplicationStatusX on DoctorApplicationStatus {
  static DoctorApplicationStatus fromId(String? value) {
    for (final s in DoctorApplicationStatus.values) {
      if (s.name == value) return s;
    }
    return DoctorApplicationStatus.pending;
  }
}

/// Verified Doctor profile / application record (`doctor_profiles/{uid}` and
/// `doctor_applications/{uid}`).
class DoctorProfile {
  const DoctorProfile({
    required this.uid,
    required this.fullName,
    this.title = 'Dr.',
    this.specialty = DoctorSpecialty.internalMedicine,
    this.countryCode = 'TR',
    this.city = '',
    this.hospitalOrClinic = '',
    this.licenseNumber = '',
    this.yearsExperience = 5,
    this.spokenLanguages = const ['tr', 'en'],
    this.bio = '',
    this.photoUrl,
    this.documentUrl,
    this.documentKey,
    this.acceptsPatientFollowUp = true,
    this.isOnline = false,
    this.isVerified = false,
    this.planTier = DoctorPlanTier.standardMonthly,
    this.status = DoctorApplicationStatus.pending,
    this.isSampleDoctor = false,
    this.aiVerificationStatus = 'unverified',
    this.aiConfidence = 0.0,
    this.aiNotes = '',
    this.purchasedPackage,
    this.isPaid = false,
    required this.createdAt,
  });

  final String uid;
  final String fullName;
  final String title;
  final DoctorSpecialty specialty;
  final String countryCode;
  final String city;
  final String hospitalOrClinic;
  final String licenseNumber;
  final int yearsExperience;
  final List<String> spokenLanguages;
  final String bio;
  final String? photoUrl;
  final String? documentUrl;
  final String? documentKey;
  final bool acceptsPatientFollowUp;
  final bool isOnline;
  final bool isVerified;
  final DoctorPlanTier planTier;
  final DoctorApplicationStatus status;
  final bool isSampleDoctor;
  final String aiVerificationStatus;
  final double aiConfidence;
  final String aiNotes;
  final String? purchasedPackage;
  final bool isPaid;
  final DateTime createdAt;

  String get displayTitleName =>
      title.trim().isEmpty ? fullName.trim() : '${title.trim()} ${fullName.trim()}';

  CommunityCountryOption get country => CommunityCountryOption.byCode(countryCode);

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'DR';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  DoctorProfile copyWith({
    String? fullName,
    String? title,
    DoctorSpecialty? specialty,
    String? countryCode,
    String? city,
    String? hospitalOrClinic,
    String? licenseNumber,
    int? yearsExperience,
    List<String>? spokenLanguages,
    String? bio,
    String? photoUrl,
    String? documentUrl,
    String? documentKey,
    bool? acceptsPatientFollowUp,
    bool? isOnline,
    bool? isVerified,
    DoctorPlanTier? planTier,
    DoctorApplicationStatus? status,
    String? aiVerificationStatus,
    double? aiConfidence,
    String? aiNotes,
    String? purchasedPackage,
    bool? isPaid,
  }) {
    return DoctorProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      hospitalOrClinic: hospitalOrClinic ?? this.hospitalOrClinic,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      spokenLanguages: spokenLanguages ?? this.spokenLanguages,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      documentKey: documentKey ?? this.documentKey,
      acceptsPatientFollowUp:
          acceptsPatientFollowUp ?? this.acceptsPatientFollowUp,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      planTier: planTier ?? this.planTier,
      status: status ?? this.status,
      isSampleDoctor: isSampleDoctor,
      aiVerificationStatus:
          aiVerificationStatus ?? this.aiVerificationStatus,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiNotes: aiNotes ?? this.aiNotes,
      purchasedPackage: purchasedPackage ?? this.purchasedPackage,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName.trim(),
        'title': title.trim(),
        'specialty': specialty.id,
        'countryCode': countryCode.toUpperCase(),
        'city': city.trim(),
        'hospitalOrClinic': hospitalOrClinic.trim(),
        'licenseNumber': licenseNumber.trim(),
        'yearsExperience': yearsExperience,
        'spokenLanguages': spokenLanguages,
        'bio': bio.trim(),
        if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
        if (documentUrl != null && documentUrl!.isNotEmpty)
          'documentUrl': documentUrl,
        if (documentKey != null && documentKey!.isNotEmpty)
          'documentKey': documentKey,
        'acceptsPatientFollowUp': acceptsPatientFollowUp,
        'isOnline': isOnline,
        'isVerified': isVerified,
        'planTier': planTier.name,
        'status': status.name,
        'aiVerificationStatus': aiVerificationStatus,
        'aiConfidence': aiConfidence,
        'aiNotes': aiNotes,
        if (purchasedPackage != null) 'purchasedPackage': purchasedPackage,
        'isPaid': isPaid,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DoctorProfile.fromJson(
    Map<String, dynamic> json, {
    String? fallbackUid,
  }) {
    return DoctorProfile(
      uid: (json['uid'] as String?) ?? fallbackUid ?? '',
      fullName: (json['fullName'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Dr.',
      specialty: DoctorSpecialtyX.fromId(json['specialty'] as String?),
      countryCode: (json['countryCode'] as String?) ?? 'TR',
      city: (json['city'] as String?) ?? '',
      hospitalOrClinic: (json['hospitalOrClinic'] as String?) ?? '',
      licenseNumber: (json['licenseNumber'] as String?) ?? '',
      yearsExperience: (json['yearsExperience'] as num?)?.toInt() ?? 5,
      spokenLanguages: (json['spokenLanguages'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const ['en'],
      bio: (json['bio'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      documentUrl: json['documentUrl'] as String?,
      documentKey: json['documentKey'] as String?,
      acceptsPatientFollowUp:
          (json['acceptsPatientFollowUp'] as bool?) ?? true,
      isOnline: (json['isOnline'] as bool?) ?? false,
      isVerified: (json['isVerified'] as bool?) ?? false,
      planTier: DoctorPlanTierX.fromId(json['planTier'] as String?),
      status: DoctorApplicationStatusX.fromId(json['status'] as String?),
      isSampleDoctor: (json['isSampleDoctor'] as bool?) ?? false,
      aiVerificationStatus:
          (json['aiVerificationStatus'] as String?) ?? 'unverified',
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble() ?? 0.0,
      aiNotes: (json['aiNotes'] as String?) ?? '',
      purchasedPackage: json['purchasedPackage'] as String?,
      isPaid: (json['isPaid'] as bool?) ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

/// Patient follow-up request sent by a member to a verified doctor
/// (`doctor_followups/{requestId}`).
class PatientFollowUpRequest {
  const PatientFollowUpRequest({
    required this.id,
    required this.doctorUid,
    required this.doctorName,
    required this.patientUid,
    required this.patientName,
    this.chronicSummary = '',
    this.note = '',
    this.status = 'pending',
    this.doctorNote = '',
    required this.createdAt,
  });

  final String id;
  final String doctorUid;
  final String doctorName;
  final String patientUid;
  final String patientName;
  final String chronicSummary;
  final String note;
  final String status; // pending | accepted | declined
  final String doctorNote;
  final DateTime createdAt;

  PatientFollowUpRequest copyWith({
    String? status,
    String? doctorNote,
  }) {
    return PatientFollowUpRequest(
      id: id,
      doctorUid: doctorUid,
      doctorName: doctorName,
      patientUid: patientUid,
      patientName: patientName,
      chronicSummary: chronicSummary,
      note: note,
      status: status ?? this.status,
      doctorNote: doctorNote ?? this.doctorNote,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorUid': doctorUid,
        'doctorName': doctorName,
        'patientUid': patientUid,
        'patientName': patientName,
        'chronicSummary': chronicSummary.trim(),
        'note': note.trim(),
        'status': status,
        if (doctorNote.trim().isNotEmpty) 'doctorNote': doctorNote.trim(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory PatientFollowUpRequest.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return PatientFollowUpRequest(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      doctorUid: (json['doctorUid'] as String?) ?? '',
      doctorName: (json['doctorName'] as String?) ?? '',
      patientUid: (json['patientUid'] as String?) ?? '',
      patientName: (json['patientName'] as String?) ?? '',
      chronicSummary: (json['chronicSummary'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'pending',
      doctorNote: (json['doctorNote'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
