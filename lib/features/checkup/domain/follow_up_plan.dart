import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Recurring visual-wellness follow-up tracks designed to turn one-time checks
/// into meaningful longitudinal self-awareness routines.
enum FollowUpTrack {
  skinMonthly,
  hydrationDaily,
  nailTongueWeekly,
}

extension FollowUpTrackX on FollowUpTrack {
  String get id => name;

  String get title {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return 'Aylık Cilt & Ben Kontrolü';
      case FollowUpTrack.hydrationDaily:
        return 'Günlük Hidrasyon (İdrar) Takibi';
      case FollowUpTrack.nailTongueWeekly:
        return 'Haftalık Tırnak & Dil Gözlemi';
    }
  }

  String get subtitle {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return 'Ben ve cilt lekelerinde 30 günlük değişimi karşılaştır';
      case FollowUpTrack.hydrationDaily:
        return 'Kamerasız renk kartıyla 2 saniyede su dengeni kaydet';
      case FollowUpTrack.nailTongueWeekly:
        return 'Solukluk, sararma veya tabaka değişimlerini haftalık izle';
    }
  }

  int get intervalDays {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return 30;
      case FollowUpTrack.hydrationDaily:
        return 1;
      case FollowUpTrack.nailTongueWeekly:
        return 7;
    }
  }

  CheckCategory get primaryCategory {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return CheckCategory.skinCondition;
      case FollowUpTrack.hydrationDaily:
        return CheckCategory.urine;
      case FollowUpTrack.nailTongueWeekly:
        return CheckCategory.nail;
    }
  }

  List<CheckCategory> get matchingCategories {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return const [CheckCategory.skinCondition];
      case FollowUpTrack.hydrationDaily:
        return const [CheckCategory.urine];
      case FollowUpTrack.nailTongueWeekly:
        return const [CheckCategory.nail, CheckCategory.tongue];
    }
  }

  IconData get icon {
    switch (this) {
      case FollowUpTrack.skinMonthly:
        return Icons.healing_outlined;
      case FollowUpTrack.hydrationDaily:
        return Icons.water_drop_outlined;
      case FollowUpTrack.nailTongueWeekly:
        return Icons.back_hand_outlined;
    }
  }

  static Set<FollowUpTrack> defaultEnabled() => const {
        FollowUpTrack.skinMonthly,
        FollowUpTrack.hydrationDaily,
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
  });

  final FollowUpTrack track;
  final bool enabled;
  final DateTime? lastCheckedAt;
  final bool isDueNow;
  final int daysRemaining;

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
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();

    return FollowUpTrack.values.map((track) {
      final matching = history
          .where((item) => track.matchingCategories.contains(item.category))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final lastAt = matching.isEmpty ? null : matching.first.createdAt;
      if (lastAt == null) {
        return FollowUpTrackStatus(
          track: track,
          enabled: enabledTracks.contains(track),
          lastCheckedAt: null,
          isDueNow: true,
          daysRemaining: 0,
        );
      }

      final elapsedHours = current.difference(lastAt).inHours;
      final requiredHours = track.intervalDays * 24;
      final isDue = elapsedHours >= requiredHours;
      final remainingDays = isDue
          ? 0
          : ((requiredHours - elapsedHours) / 24).ceil().clamp(1, 365);

      return FollowUpTrackStatus(
        track: track,
        enabled: enabledTracks.contains(track),
        lastCheckedAt: lastAt,
        isDueNow: isDue,
        daysRemaining: remainingDays,
      );
    }).toList();
  }
}
