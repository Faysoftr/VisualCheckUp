import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

enum FollowUpDataSource {
  visualCheckup,
  bloodPressure,
  bloodSugar,
  labReport,
}

/// Recurring holistic wellness follow-up tracks spanning visual checkups
/// (eye, tongue, nail, face, skin/moles, urine, stool) as well as vitals
/// (blood pressure, blood sugar) and hospital lab reports.
enum FollowUpTrack {
  eyeWeekly,
  tongueWeekly,
  nailTongueWeekly,
  faceBiWeekly,
  skinMonthly,
  hydrationDaily,
  stoolWeekly,
  bloodPressureDaily,
  bloodSugarDaily,
  labReportQuarterly,
}

extension FollowUpTrackX on FollowUpTrack {
  String get id => name;

  FollowUpDataSource get dataSource {
    switch (this) {
      case FollowUpTrack.bloodPressureDaily:
        return FollowUpDataSource.bloodPressure;
      case FollowUpTrack.bloodSugarDaily:
        return FollowUpDataSource.bloodSugar;
      case FollowUpTrack.labReportQuarterly:
        return FollowUpDataSource.labReport;
      case FollowUpTrack.eyeWeekly:
      case FollowUpTrack.tongueWeekly:
      case FollowUpTrack.nailTongueWeekly:
      case FollowUpTrack.faceBiWeekly:
      case FollowUpTrack.skinMonthly:
      case FollowUpTrack.hydrationDaily:
      case FollowUpTrack.stoolWeekly:
        return FollowUpDataSource.visualCheckup;
    }
  }

  String get title {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return 'Haftalık Göz (Sklera) Kontrolü';
      case FollowUpTrack.tongueWeekly:
        return 'Haftalık Dil Gözlemi';
      case FollowUpTrack.nailTongueWeekly:
        return 'Haftalık Tırnak Gözlemi';
      case FollowUpTrack.faceBiWeekly:
        return '2 Haftalık Yüz & Cilt Tonu';
      case FollowUpTrack.skinMonthly:
        return 'Aylık Cilt, Ben & Siğil Kontrolü';
      case FollowUpTrack.hydrationDaily:
        return 'Günlük Hidrasyon (İdrar) Takibi';
      case FollowUpTrack.stoolWeekly:
        return 'Haftalık Dışkı Rengi Takibi';
      case FollowUpTrack.bloodPressureDaily:
        return 'Günlük Tansiyon Ölçümü';
      case FollowUpTrack.bloodSugarDaily:
        return 'Günlük Kan Şekeri Takibi';
      case FollowUpTrack.labReportQuarterly:
        return '3 Aylık Kan Tahlili & Rapor';
    }
  }

  String get subtitle {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return 'Göz akında kızarıklık veya sarılık değişimini izle';
      case FollowUpTrack.tongueWeekly:
        return 'Dil rengi, beyaz/sarı kaplama ve doku değişimlerini takip et';
      case FollowUpTrack.nailTongueWeekly:
        return 'Tırnak yatağı solukluğu, morarma veya sararma kontrolü';
      case FollowUpTrack.faceBiWeekly:
        return 'Yüzde solgunluk, kızarıklık ve ton değişimini kıyasla';
      case FollowUpTrack.skinMonthly:
        return 'Ben, siğil, morluk ve yüz lekelerinde 30 günlük değişimi izle';
      case FollowUpTrack.hydrationDaily:
        return 'Kamerasız renk kartıyla 2 saniyede su dengeni kaydet';
      case FollowUpTrack.stoolWeekly:
        return 'Sindirim ve renk uyarılarını düzenli takip et';
      case FollowUpTrack.bloodPressureDaily:
        return 'Büyük/küçük tansiyon ve nabız trendini günlük kaydet';
      case FollowUpTrack.bloodSugarDaily:
        return 'Açlık veya tokluk kan şekeri değerlerini izle';
      case FollowUpTrack.labReportQuarterly:
        return 'Hastane/kan testi raporlarını yükleyip dönemsel karşılaştır';
    }
  }

  int get intervalDays {
    switch (this) {
      case FollowUpTrack.hydrationDaily:
      case FollowUpTrack.bloodPressureDaily:
      case FollowUpTrack.bloodSugarDaily:
        return 1;
      case FollowUpTrack.eyeWeekly:
      case FollowUpTrack.tongueWeekly:
      case FollowUpTrack.nailTongueWeekly:
      case FollowUpTrack.stoolWeekly:
        return 7;
      case FollowUpTrack.faceBiWeekly:
        return 14;
      case FollowUpTrack.skinMonthly:
        return 30;
      case FollowUpTrack.labReportQuarterly:
        return 90;
    }
  }

  CheckCategory get primaryCategory {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return CheckCategory.eye;
      case FollowUpTrack.tongueWeekly:
        return CheckCategory.tongue;
      case FollowUpTrack.nailTongueWeekly:
        return CheckCategory.nail;
      case FollowUpTrack.faceBiWeekly:
        return CheckCategory.face;
      case FollowUpTrack.skinMonthly:
        return CheckCategory.skinCondition;
      case FollowUpTrack.hydrationDaily:
        return CheckCategory.urine;
      case FollowUpTrack.stoolWeekly:
        return CheckCategory.stool;
      case FollowUpTrack.bloodPressureDaily:
      case FollowUpTrack.bloodSugarDaily:
      case FollowUpTrack.labReportQuarterly:
        return CheckCategory.eye;
    }
  }

  List<CheckCategory> get matchingCategories {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return const [CheckCategory.eye];
      case FollowUpTrack.tongueWeekly:
        return const [CheckCategory.tongue];
      case FollowUpTrack.nailTongueWeekly:
        return const [CheckCategory.nail];
      case FollowUpTrack.faceBiWeekly:
        return const [CheckCategory.face];
      case FollowUpTrack.skinMonthly:
        return const [CheckCategory.skinCondition];
      case FollowUpTrack.hydrationDaily:
        return const [CheckCategory.urine];
      case FollowUpTrack.stoolWeekly:
        return const [CheckCategory.stool];
      case FollowUpTrack.bloodPressureDaily:
      case FollowUpTrack.bloodSugarDaily:
      case FollowUpTrack.labReportQuarterly:
        return const [];
    }
  }

  IconData get icon {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return Icons.visibility_outlined;
      case FollowUpTrack.tongueWeekly:
        return Icons.record_voice_over_outlined;
      case FollowUpTrack.nailTongueWeekly:
        return Icons.back_hand_outlined;
      case FollowUpTrack.faceBiWeekly:
        return Icons.face_retouching_natural_outlined;
      case FollowUpTrack.skinMonthly:
        return Icons.healing_outlined;
      case FollowUpTrack.hydrationDaily:
        return Icons.water_drop_outlined;
      case FollowUpTrack.stoolWeekly:
        return Icons.health_and_safety_outlined;
      case FollowUpTrack.bloodPressureDaily:
        return Icons.monitor_heart_outlined;
      case FollowUpTrack.bloodSugarDaily:
        return Icons.bloodtype_outlined;
      case FollowUpTrack.labReportQuarterly:
        return Icons.biotech_outlined;
    }
  }

  String get actionButtonLabel {
    switch (dataSource) {
      case FollowUpDataSource.bloodPressure:
      case FollowUpDataSource.bloodSugar:
        return 'Ölçüm Gir';
      case FollowUpDataSource.labReport:
        return 'Rapor Ekle';
      case FollowUpDataSource.visualCheckup:
        return 'Şimdi Kontrol Et';
    }
  }

  static Set<FollowUpTrack> defaultEnabled() => const {
        FollowUpTrack.eyeWeekly,
        FollowUpTrack.skinMonthly,
        FollowUpTrack.hydrationDaily,
        FollowUpTrack.bloodPressureDaily,
        FollowUpTrack.bloodSugarDaily,
      };

  static FollowUpTrack? tryFromId(String id) {
    for (final track in FollowUpTrack.values) {
      if (track.id == id) return track;
    }
    return null;
  }
}

class FollowUpTrackStatus {
  const FollowUpTrackStatus({
    required this.track,
    required this.enabled,
    required this.lastCheckedAt,
    required this.isDueNow,
    required this.daysRemaining,
    this.latestValueSummary,
    this.latestBp,
    this.latestSugar,
    this.latestLab,
    this.latestCheck,
  });

  final FollowUpTrack track;
  final bool enabled;
  final DateTime? lastCheckedAt;
  final bool isDueNow;
  final int daysRemaining;
  final String? latestValueSummary;
  final BloodPressureReading? latestBp;
  final BloodSugarReading? latestSugar;
  final LabReportRecord? latestLab;
  final AnalysisResult? latestCheck;

  String get statusLabel {
    if (lastCheckedAt == null) {
      return 'İlk kayıt bekleniyor';
    }
    if (isDueNow) {
      return 'Kontrol zamanı geldi';
    }
    if (track.intervalDays == 1) {
      return 'Bugün tamamlandı';
    }
    return 'Sonraki kontrol: $daysRemaining gün sonra';
  }
}

class FollowUpEvaluator {
  FollowUpEvaluator._();

  static List<FollowUpTrackStatus> evaluate({
    required Set<FollowUpTrack> enabledTracks,
    required List<AnalysisResult> history,
    List<BloodPressureReading> bloodPressureReadings = const [],
    List<BloodSugarReading> bloodSugarReadings = const [],
    List<LabReportRecord> labReports = const [],
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();

    final sortedBp = List<BloodPressureReading>.from(bloodPressureReadings)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final sortedSugar = List<BloodSugarReading>.from(bloodSugarReadings)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final sortedLabs = List<LabReportRecord>.from(labReports)
      ..sort((a, b) => b.reportDate.compareTo(a.reportDate));

    return FollowUpTrack.values.map((track) {
      DateTime? lastAt;
      String? summary;
      BloodPressureReading? latestBp;
      BloodSugarReading? latestSugar;
      LabReportRecord? latestLab;
      AnalysisResult? latestCheck;

      switch (track.dataSource) {
        case FollowUpDataSource.bloodPressure:
          if (sortedBp.isNotEmpty) {
            final latest = sortedBp.first;
            latestBp = latest;
            lastAt = latest.recordedAt;
            final pulseText =
                latest.pulse != null ? ' • Nabız ${latest.pulse}' : '';
            summary =
                'Son ölçüm: ${latest.systolic}/${latest.diastolic} mmHg$pulseText (${latest.category.label})';
          }
          break;
        case FollowUpDataSource.bloodSugar:
          if (sortedSugar.isNotEmpty) {
            final latest = sortedSugar.first;
            latestSugar = latest;
            lastAt = latest.recordedAt;
            summary =
                'Son ölçüm: ${latest.formatted} (${latest.category.label})';
          }
          break;
        case FollowUpDataSource.labReport:
          if (sortedLabs.isNotEmpty) {
            final latest = sortedLabs.first;
            latestLab = latest;
            lastAt = latest.reportDate;
            final abnormalCount =
                latest.items.where((i) => i.status.isAbnormal).length;
            summary = abnormalCount == 0
                ? 'Son rapor: ${latest.title} (tümü olağan)'
                : 'Son rapor: ${latest.title} ($abnormalCount referans dışı)';
          }
          break;
        case FollowUpDataSource.visualCheckup:
          final matching = history
              .where((item) => track.matchingCategories.contains(item.category))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (matching.isNotEmpty) {
            final latest = matching.first;
            latestCheck = latest;
            lastAt = latest.createdAt;
            summary = 'Son kayıt: ${latest.summaryTitle}';
          }
          break;
      }

      if (lastAt == null) {
        return FollowUpTrackStatus(
          track: track,
          enabled: enabledTracks.contains(track),
          lastCheckedAt: null,
          isDueNow: true,
          daysRemaining: 0,
          latestValueSummary: null,
        );
      }

      final bool isDue;
      final int remainingDays;

      if (track.intervalDays == 1) {
        // Daily tracks (hydration, blood pressure, blood sugar) reset cleanly per calendar day
        final isSameCalendarDay = lastAt.year == current.year &&
            lastAt.month == current.month &&
            lastAt.day == current.day;
        isDue = !isSameCalendarDay;
        remainingDays = isDue ? 0 : 1;
      } else {
        final elapsedHours = current.difference(lastAt).inHours;
        final requiredHours = track.intervalDays * 24;
        isDue = elapsedHours >= requiredHours;
        remainingDays = isDue
            ? 0
            : ((requiredHours - elapsedHours) / 24).ceil().clamp(1, 365);
      }

      return FollowUpTrackStatus(
        track: track,
        enabled: enabledTracks.contains(track),
        lastCheckedAt: lastAt,
        isDueNow: isDue,
        daysRemaining: remainingDays,
        latestValueSummary: summary,
        latestBp: latestBp,
        latestSugar: latestSugar,
        latestLab: latestLab,
        latestCheck: latestCheck,
      );
    }).toList();
  }
}
