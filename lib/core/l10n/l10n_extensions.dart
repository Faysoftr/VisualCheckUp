import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/locale_controller.dart';
import 'package:visualcheckup/features/auth/domain/auth_user.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/follow_up_plan.dart';
import 'package:visualcheckup/features/checkup/domain/quick_color_swatch.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/diet/domain/diet_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';
import 'package:visualcheckup/features/medications/domain/medication_reminder.dart';
import 'package:visualcheckup/features/skin/domain/skin_check_context.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';
import 'package:visualcheckup/l10n/generated/app_localizations_tr.dart';

extension BuildContextL10n on BuildContext {
  /// Returns the active [AppLocalizations], falling back to Turkish in
  /// standalone widget tests that wrap a single screen in a bare [MaterialApp].
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsTr();
}

extension AuthProviderTypeL10n on AuthProviderType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case AuthProviderType.google:
        return 'Google';
      case AuthProviderType.apple:
        return 'Apple';
      case AuthProviderType.guest:
        return l10n.providerGuest;
    }
  }
}

extension RiskLevelL10n on RiskLevel {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case RiskLevel.normal:
        return l10n.riskNormal;
      case RiskLevel.attention:
        return l10n.riskAttention;
      case RiskLevel.urgent:
        return l10n.riskUrgent;
    }
  }
}

extension AnalysisResultL10n on AnalysisResult {
  static final RegExp _turkishPattern = RegExp(
    r'[çğıöşüÇĞİÖŞÜ]|\b(olağan|takip|uyarı|ipucu|görünüm|kızarıklık|sarılık|soluk|morluk|siğil|leke|idrar|dışkı|dil|tırnak|göz|cilt|doktor|değerlendirme|koyu|açık|sarı|kahverengi|kırmızı|beyaz|siyah|hidrasyon|normal\s+aralık)\b',
    caseSensitive: false,
  );

  /// Displays a properly localized summary title even for historical checks
  /// persisted in Turkish by the on-device analyzer.
  String localizedSummaryTitle(AppLocalizations l10n) {
    if (l10n.localeName == 'tr') {
      return summaryTitle;
    }
    if (summaryTitle.trim().isEmpty || _turkishPattern.hasMatch(summaryTitle)) {
      return l10n.recentSummaryFallback(
        category.localizedTitle(l10n),
        riskLevel.localizedLabel(l10n),
      );
    }
    return summaryTitle;
  }
}

extension CheckCategoryL10n on CheckCategory {
  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case CheckCategory.eye:
        return l10n.catEyeTitle;
      case CheckCategory.nail:
        return l10n.catNailTitle;
      case CheckCategory.tongue:
        return l10n.catTongueTitle;
      case CheckCategory.face:
        return l10n.catFaceTitle;
      case CheckCategory.skinCondition:
        return l10n.catSkinTitle;
      case CheckCategory.urine:
        return l10n.catUrineTitle;
      case CheckCategory.stool:
        return l10n.catStoolTitle;
    }
  }

  String localizedSubtitle(AppLocalizations l10n) {
    switch (this) {
      case CheckCategory.eye:
        return l10n.catEyeSubtitle;
      case CheckCategory.nail:
        return l10n.catNailSubtitle;
      case CheckCategory.tongue:
        return l10n.catTongueSubtitle;
      case CheckCategory.face:
        return l10n.catFaceSubtitle;
      case CheckCategory.skinCondition:
        return l10n.catSkinSubtitle;
      case CheckCategory.urine:
        return l10n.catUrineSubtitle;
      case CheckCategory.stool:
        return l10n.catStoolSubtitle;
    }
  }

  String localizedRecommendedSpecialty(AppLocalizations l10n) {
    switch (this) {
      case CheckCategory.eye:
        return l10n.specialtyEye;
      case CheckCategory.nail:
        return l10n.specialtyNail;
      case CheckCategory.tongue:
        return l10n.specialtyTongue;
      case CheckCategory.face:
      case CheckCategory.skinCondition:
        return l10n.specialtySkin;
      case CheckCategory.urine:
        return l10n.specialtyUrine;
      case CheckCategory.stool:
        return l10n.specialtyStool;
    }
  }
}

extension SkinConcernTypeL10n on SkinConcernType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return l10n.skinCancerRisk;
      case SkinConcernType.wart:
        return l10n.skinWart;
      case SkinConcernType.bruise:
        return l10n.skinBruise;
      case SkinConcernType.facialSpot:
        return l10n.skinFacialSpot;
      case SkinConcernType.rashRedness:
        return l10n.skinConcernRash;
      case SkinConcernType.molePigment:
        return l10n.skinConcernMole;
      case SkinConcernType.scalyDry:
        return l10n.skinConcernScaly;
      case SkinConcernType.blisterPustule:
        return l10n.skinConcernBlister;
      case SkinConcernType.general:
        return l10n.skinConcernGeneral;
    }
  }
}

extension SkinSymptomFlagL10n on SkinSymptomFlag {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SkinSymptomFlag.itching:
        return l10n.symptomItching;
      case SkinSymptomFlag.painOrWarmth:
        return l10n.symptomPainWarmth;
      case SkinSymptomFlag.rapidChange:
        return l10n.symptomRapidChange;
      case SkinSymptomFlag.bleedingOrOozing:
        return l10n.symptomBleeding;
      case SkinSymptomFlag.spreading:
        return l10n.symptomSpreading;
      case SkinSymptomFlag.fever:
        return l10n.symptomFever;
      case SkinSymptomFlag.nonHealingSore:
        return l10n.symptomNonHealing;
      case SkinSymptomFlag.over6mmOrIrregular:
        return l10n.symptomOver6mm;
      case SkinSymptomFlag.spontaneousNoTrauma:
        return l10n.symptomNoTrauma;
      case SkinSymptomFlag.roughBlackDots:
        return l10n.symptomRoughDots;
      case SkinSymptomFlag.sunOrHormoneHistory:
        return l10n.symptomSunHormone;
    }
  }
}

extension LabStatusL10n on LabStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case LabStatus.criticalLow:
        return l10n.labStatusCriticalLow;
      case LabStatus.low:
        return l10n.labStatusLow;
      case LabStatus.normal:
        return l10n.labStatusNormal;
      case LabStatus.high:
        return l10n.labStatusHigh;
      case LabStatus.criticalHigh:
        return l10n.labStatusCriticalHigh;
    }
  }
}

extension LabReportSourceL10n on LabReportSource {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case LabReportSource.manual:
        return l10n.labSourceManual;
      case LabReportSource.pastedText:
        return l10n.labSourcePasted;
      case LabReportSource.photoScan:
        return l10n.labSourcePhoto;
      case LabReportSource.pdfUpload:
        return l10n.labSourcePdf;
    }
  }
}

extension BloodPressureCategoryL10n on BloodPressureCategory {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case BloodPressureCategory.low:
        return l10n.bpLow;
      case BloodPressureCategory.normal:
        return l10n.bpNormal;
      case BloodPressureCategory.elevated:
        return l10n.bpElevated;
      case BloodPressureCategory.highStage1:
        return l10n.bpStage1;
      case BloodPressureCategory.highStage2:
        return l10n.bpStage2;
      case BloodPressureCategory.crisis:
        return l10n.bpCrisis;
    }
  }
}

extension BloodSugarCategoryL10n on BloodSugarCategory {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case BloodSugarCategory.hypoglycemia:
        return l10n.sugarLow;
      case BloodSugarCategory.normal:
        return l10n.sugarNormal;
      case BloodSugarCategory.borderline:
        return l10n.sugarBorderline;
      case BloodSugarCategory.high:
        return l10n.sugarHigh;
      case BloodSugarCategory.veryHigh:
        return l10n.sugarVeryHigh;
    }
  }
}

extension SugarMeasurementTypeL10n on SugarMeasurementType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case SugarMeasurementType.fasting:
        return l10n.sugarTypeFasting;
      case SugarMeasurementType.postMeal:
        return l10n.sugarTypePostMeal;
      case SugarMeasurementType.random:
        return l10n.sugarTypeRandom;
    }
  }
}

extension FollowUpTrackL10n on FollowUpTrack {
  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return l10n.trackEyeTitle;
      case FollowUpTrack.tongueWeekly:
        return l10n.trackTongueTitle;
      case FollowUpTrack.nailTongueWeekly:
        return l10n.trackNailTitle;
      case FollowUpTrack.faceBiWeekly:
        return l10n.trackFaceTitle;
      case FollowUpTrack.skinMonthly:
        return l10n.trackSkinTitle;
      case FollowUpTrack.hydrationDaily:
        return l10n.trackHydrationTitle;
      case FollowUpTrack.stoolWeekly:
        return l10n.trackStoolTitle;
      case FollowUpTrack.bloodPressureDaily:
        return l10n.trackBpTitle;
      case FollowUpTrack.bloodSugarDaily:
        return l10n.trackSugarTitle;
      case FollowUpTrack.labReportQuarterly:
        return l10n.trackLabTitle;
    }
  }

  String localizedSubtitle(AppLocalizations l10n) {
    switch (this) {
      case FollowUpTrack.eyeWeekly:
        return l10n.trackEyeSubtitle;
      case FollowUpTrack.tongueWeekly:
        return l10n.trackTongueSubtitle;
      case FollowUpTrack.nailTongueWeekly:
        return l10n.trackNailSubtitle;
      case FollowUpTrack.faceBiWeekly:
        return l10n.trackFaceSubtitle;
      case FollowUpTrack.skinMonthly:
        return l10n.trackSkinSubtitle;
      case FollowUpTrack.hydrationDaily:
        return l10n.trackHydrationSubtitle;
      case FollowUpTrack.stoolWeekly:
        return l10n.trackStoolSubtitle;
      case FollowUpTrack.bloodPressureDaily:
        return l10n.trackBpSubtitle;
      case FollowUpTrack.bloodSugarDaily:
        return l10n.trackSugarSubtitle;
      case FollowUpTrack.labReportQuarterly:
        return l10n.trackLabSubtitle;
    }
  }

  String localizedActionLabel(AppLocalizations l10n) {
    switch (dataSource) {
      case FollowUpDataSource.bloodPressure:
      case FollowUpDataSource.bloodSugar:
        return l10n.actionLogReading;
      case FollowUpDataSource.labReport:
        return l10n.actionAddReport;
      case FollowUpDataSource.visualCheckup:
        return l10n.actionCheckNow;
    }
  }
}

extension FollowUpTrackStatusL10n on FollowUpTrackStatus {
  String localizedStatusLabel(AppLocalizations l10n) {
    if (lastCheckedAt == null) return l10n.statusFirstPending;
    if (isDueNow) return l10n.statusDueNow;
    if (track.intervalDays == 1) return l10n.statusDoneToday;
    return l10n.statusNextDays(daysRemaining);
  }

  String? localizedLatestValueSummary(AppLocalizations l10n) {
    if (latestBp != null) {
      final bp = latestBp!;
      final pulseText =
          bp.pulse != null ? l10n.vitalsLastPulse(bp.pulse!) : '';
      return l10n.latestSummaryPrefix(
        '${bp.systolic}/${bp.diastolic} mmHg$pulseText (${bp.category.localizedLabel(l10n)})',
      );
    }
    if (latestSugar != null) {
      final sugar = latestSugar!;
      return l10n.latestSummaryPrefix(
        '${sugar.valueMgDl.round()} mg/dL • ${sugar.measurementType.localizedLabel(l10n)} (${sugar.category.localizedLabel(l10n)})',
      );
    }
    if (latestLab != null) {
      final lab = latestLab!;
      final abnormal = lab.items.where((i) => i.status.isAbnormal).length;
      if (abnormal == 0) {
        return l10n.latestLabAllNormal(lab.items.length);
      }
      return l10n.latestLabValuesSummary(lab.items.length, abnormal);
    }
    if (latestCheck != null) {
      return l10n.latestSummaryPrefix(
        latestCheck!.localizedSummaryTitle(l10n),
      );
    }
    return latestValueSummary;
  }
}

/// Modal bottom sheet for selecting any of the 11 supported languages
/// (10 most spoken global languages + Turkish) or System Default.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({
    super.key,
    required this.localeController,
  });

  final LocaleController localeController;

  static Future<void> show(
    BuildContext context, {
    required LocaleController localeController,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.9,
        builder: (_, scrollController) => LanguagePickerSheet(
          localeController: localeController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current = localeController.value;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                l10n.menuLanguage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            selected: current == null,
            selectedTileColor:
                colorScheme.primaryContainer.withValues(alpha: 0.45),
            leading: const Icon(Icons.phonelink_setup_rounded),
            title: Text(
              l10n.languageSystem,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: current == null
                ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                : null,
            onTap: () {
              localeController.setLocale(null);
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 16),
          for (final lang in LocaleController.supportedLanguages)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              selected: current?.languageCode == lang.code,
              selectedTileColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.45),
              leading: CircleAvatar(
                radius: 16,
                backgroundColor:
                    colorScheme.primaryContainer.withValues(alpha: 0.6),
                child: Text(
                  lang.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              title: Text(
                lang.nativeName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                lang.isRtl ? '${lang.englishName} • RTL' : lang.englishName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: current?.languageCode == lang.code
                  ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                localeController.setLocale(lang.locale);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

extension BristolStoolTypeL10n on BristolStoolType {
  String localizedTitle(AppLocalizations l10n) {
    switch (typeNumber) {
      case 1:
        return l10n.bristolType1Title;
      case 2:
        return l10n.bristolType2Title;
      case 3:
        return l10n.bristolType3Title;
      case 4:
        return l10n.bristolType4Title;
      case 5:
        return l10n.bristolType5Title;
      case 6:
        return l10n.bristolType6Title;
      case 7:
        return l10n.bristolType7Title;
      default:
        return title;
    }
  }
}

/// Maps canonical clinical biomarker keys emitted by on-device analyzers to
/// localized labels across all 11 supported languages.
String localizedClinicalMetricKey(String rawKey, AppLocalizations l10n) {
  switch (rawKey) {
    case 'Fitzpatrick Fototip':
      return l10n.metricFitzpatrickPhototype;
    case 'A — Asimetri':
      return l10n.metricAbcdeAsymmetry;
    case 'B — Sınır Düzensizliği':
      return l10n.metricAbcdeBorder;
    case 'C — Dermoskopik Renk':
      return l10n.metricAbcdeColors;
    case 'Eritem İndeksi Δ':
      return l10n.metricErythemaDelta;
    case 'Halka Merkez Açılması':
      return l10n.metricAnnularClearing;
    case 'Eritem İndeksi (EI)':
      return l10n.metricErythemaIndex;
    case 'Sklera Bilirubin İndeksi':
      return l10n.metricScleraBilirubin;
    case 'Kompakt Kanama Alanı':
      return l10n.metricHemorrhagePatch;
    case 'Tırnak Yatağı Eritem İndeksi':
      return l10n.metricNailErythema;
    case 'Beau Yatay Oluk Skoru':
      return l10n.metricBeauGroove;
    case 'Proksimal/Distal Ayrım':
      return l10n.metricTerryLindsaySplit;
    case 'Kıymık Çizgisi Oranı':
      return l10n.metricSplinterStreak;
    case 'Harita Dil Skoru':
      return l10n.metricGeographicTongue;
    case 'Sarı Pas Oranı':
      return l10n.metricYellowCoating;
    case 'Bristol Skalası':
      return l10n.metricBristolScale;
    default:
      return rawKey;
  }
}

extension MedicationCategoryL10n on MedicationCategory {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MedicationCategory.pill:
        return l10n.medCatPill;
      case MedicationCategory.diabetesInsulin:
        return l10n.medCatDiabetes;
      case MedicationCategory.bloodPressure:
        return l10n.medCatBloodPressure;
      case MedicationCategory.herbalTea:
        return l10n.medCatHerbalTea;
      case MedicationCategory.vitamin:
        return l10n.medCatVitamin;
      case MedicationCategory.dropsCream:
        return l10n.medCatDropsCream;
      case MedicationCategory.checkup:
        return l10n.medCatCheckup;
      case MedicationCategory.other:
        return l10n.medCatCustom;
    }
  }
}

extension MealTimingL10n on MealTiming {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MealTiming.anytime:
        return l10n.medMealAnytime;
      case MealTiming.beforeMeal:
        return l10n.medMealBefore;
      case MealTiming.afterMeal:
        return l10n.medMealAfter;
      case MealTiming.withMeal:
        return l10n.medMealWith;
      case MealTiming.bedtime:
        return l10n.medMealBedtime;
    }
  }
}

extension MedicationDoseStatusL10n on MedicationDoseStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MedicationDoseStatus.taken:
        return l10n.medStatusTaken;
      case MedicationDoseStatus.snoozed:
        return l10n.medStatusSnoozed;
      case MedicationDoseStatus.skipped:
        return l10n.medStatusSkipped;
    }
  }
}

extension MedicationAlarmSoundL10n on MedicationAlarmSound {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MedicationAlarmSound.classicAlarm:
        return l10n.medAlarmSoundClassic;
      case MedicationAlarmSound.gentleChime:
        return l10n.medAlarmSoundGentle;
      case MedicationAlarmSound.radarPulse:
        return l10n.medAlarmSoundRadar;
      case MedicationAlarmSound.vitalBell:
        return l10n.medAlarmSoundBell;
      case MedicationAlarmSound.urgentAlarm:
        return l10n.medAlarmSoundUrgent;
      case MedicationAlarmSound.systemAlarm:
        return l10n.medAlarmSoundSystem;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case MedicationAlarmSound.classicAlarm:
        return l10n.medAlarmSoundClassicDesc;
      case MedicationAlarmSound.gentleChime:
        return l10n.medAlarmSoundGentleDesc;
      case MedicationAlarmSound.radarPulse:
        return l10n.medAlarmSoundRadarDesc;
      case MedicationAlarmSound.vitalBell:
        return l10n.medAlarmSoundBellDesc;
      case MedicationAlarmSound.urgentAlarm:
        return l10n.medAlarmSoundUrgentDesc;
      case MedicationAlarmSound.systemAlarm:
        return l10n.medAlarmSoundSystemDesc;
    }
  }
}

extension MedicationReminderL10n on MedicationReminder {
  String localizedCategoryLabel(AppLocalizations l10n) {
    if (customCategoryLabel.trim().isNotEmpty) {
      return customCategoryLabel.trim();
    }
    return category.localizedLabel(l10n);
  }

  static String localizedWeekdayShort(int isoWeekday, AppLocalizations l10n) {
    switch (isoWeekday) {
      case 1:
        return l10n.medDayMon;
      case 2:
        return l10n.medDayTue;
      case 3:
        return l10n.medDayWed;
      case 4:
        return l10n.medDayThu;
      case 5:
        return l10n.medDayFri;
      case 6:
        return l10n.medDaySat;
      case 7:
        return l10n.medDaySun;
      default:
        return l10n.medDayMon;
    }
  }

  String localizedDaysSummary(AppLocalizations l10n) {
    if (isEveryDay) return l10n.medEveryDay;
    if (isWeekdaysOnly) return l10n.medWeekdays;
    if (isWeekendsOnly) return l10n.medWeekends;
    final sorted = weekdays.toList()..sort();
    return sorted.map((d) => localizedWeekdayShort(d, l10n)).join(', ');
  }
}

extension MealSlotL10n on MealSlot {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MealSlot.breakfast:
        return l10n.dietSlotBreakfast;
      case MealSlot.morningSnack:
        return l10n.dietSlotMorningSnack;
      case MealSlot.lunch:
        return l10n.dietSlotLunch;
      case MealSlot.afternoonSnack:
        return l10n.dietSlotAfternoonSnack;
      case MealSlot.dinner:
        return l10n.dietSlotDinner;
    }
  }
}

extension MealComplianceStatusL10n on MealComplianceStatus {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case MealComplianceStatus.followed:
        return l10n.dietFollowed;
      case MealComplianceStatus.notFollowed:
        return l10n.dietNotFollowed;
      case MealComplianceStatus.pending:
        return l10n.dietPending;
    }
  }
}

extension HealthGoalTagL10n on HealthGoalTag {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case HealthGoalTag.diabetes:
        return l10n.commGoalDiabetes;
      case HealthGoalTag.bloodPressure:
        return l10n.commGoalBloodPressure;
      case HealthGoalTag.weightDiet:
        return l10n.commGoalWeightDiet;
      case HealthGoalTag.healthyLiving:
        return l10n.commGoalHealthyLiving;
      case HealthGoalTag.herbalWellness:
        return l10n.commGoalHerbalWellness;
      case HealthGoalTag.parentingGrowth:
        return l10n.commGoalParentingGrowth;
      case HealthGoalTag.skinCare:
        return l10n.commGoalSkinCare;
      case HealthGoalTag.fitnessWalk:
        return l10n.commGoalFitnessWalk;
      case HealthGoalTag.sleepStress:
        return l10n.commGoalSleepStress;
    }
  }
}

extension CommunityReportReasonL10n on CommunityReportReason {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case CommunityReportReason.inappropriate:
        return l10n.commReportReasonInappropriate;
      case CommunityReportReason.spam:
        return l10n.commReportReasonSpam;
      case CommunityReportReason.harassment:
        return l10n.commReportReasonHarassment;
      case CommunityReportReason.medicalMisinformation:
        return l10n.commReportReasonMisinfo;
      case CommunityReportReason.other:
        return l10n.commReportReasonOther;
    }
  }
}



