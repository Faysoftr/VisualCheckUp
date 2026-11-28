import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FeatureGroupCategory {
  clinical,
  dailyWellness,
  specialized,
}

extension FeatureGroupCategoryX on FeatureGroupCategory {
  String localizedTitle(String langCode) {
    switch (this) {
      case FeatureGroupCategory.clinical:
        return langCode == 'tr'
            ? 'Klinik & Tahlil Takibi'
            : 'Clinical & Lab Tracking';
      case FeatureGroupCategory.dailyWellness:
        return langCode == 'tr'
            ? 'Günlük Yaşam & Beslenme'
            : 'Daily Wellness & Nutrition';
      case FeatureGroupCategory.specialized:
        return langCode == 'tr'
            ? 'Özel Programlar & Sosyal'
            : 'Specialized & Community';
    }
  }

  IconData get icon {
    switch (this) {
      case FeatureGroupCategory.clinical:
        return Icons.biotech_rounded;
      case FeatureGroupCategory.dailyWellness:
        return Icons.favorite_border_rounded;
      case FeatureGroupCategory.specialized:
        return Icons.auto_awesome_mosaic_outlined;
    }
  }

  Color get color {
    switch (this) {
      case FeatureGroupCategory.clinical:
        return const Color(0xFF0284C7);
      case FeatureGroupCategory.dailyWellness:
        return const Color(0xFF0D9488);
      case FeatureGroupCategory.specialized:
        return const Color(0xFF7C3AED);
    }
  }
}

/// Optional health/wellness modules that users can enable or hide via the
/// startup Feature Selection Wizard or anytime in Settings.
///
/// Core Camera Visual Checks remain always available as the primary identity
/// of VisualCheckUp.
enum PersonalHealthFeature {
  // 1. Clinical & Lab Tracking
  labReports,
  vitalsTracker,
  medicationAlarms,
  followUpPlan,

  // 2. Daily Wellness & Nutrition
  waterTracker,
  pedometer,
  dietAndCalorie,
  growthBmi,

  // 3. Specialized & Community
  breathLung,
  sobriety,
  childrenGrowth,
  communitySocial,
}

extension PersonalHealthFeatureX on PersonalHealthFeature {
  FeatureGroupCategory get group {
    switch (this) {
      case PersonalHealthFeature.labReports:
      case PersonalHealthFeature.vitalsTracker:
      case PersonalHealthFeature.medicationAlarms:
      case PersonalHealthFeature.followUpPlan:
        return FeatureGroupCategory.clinical;
      case PersonalHealthFeature.waterTracker:
      case PersonalHealthFeature.pedometer:
      case PersonalHealthFeature.dietAndCalorie:
      case PersonalHealthFeature.growthBmi:
        return FeatureGroupCategory.dailyWellness;
      case PersonalHealthFeature.breathLung:
      case PersonalHealthFeature.sobriety:
      case PersonalHealthFeature.childrenGrowth:
      case PersonalHealthFeature.communitySocial:
        return FeatureGroupCategory.specialized;
    }
  }

  IconData get icon {
    switch (this) {
      case PersonalHealthFeature.labReports:
        return Icons.biotech_outlined;
      case PersonalHealthFeature.vitalsTracker:
        return Icons.monitor_heart_outlined;
      case PersonalHealthFeature.medicationAlarms:
        return Icons.alarm_on_rounded;
      case PersonalHealthFeature.followUpPlan:
        return Icons.event_repeat_rounded;
      case PersonalHealthFeature.waterTracker:
        return Icons.water_drop_rounded;
      case PersonalHealthFeature.pedometer:
        return Icons.directions_walk_rounded;
      case PersonalHealthFeature.dietAndCalorie:
        return Icons.restaurant_menu_rounded;
      case PersonalHealthFeature.growthBmi:
        return Icons.monitor_weight_outlined;
      case PersonalHealthFeature.breathLung:
        return Icons.air_rounded;
      case PersonalHealthFeature.sobriety:
        return Icons.smoke_free_rounded;
      case PersonalHealthFeature.childrenGrowth:
        return Icons.child_care_outlined;
      case PersonalHealthFeature.communitySocial:
        return Icons.groups_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case PersonalHealthFeature.labReports:
        return const Color(0xFF0284C7);
      case PersonalHealthFeature.vitalsTracker:
        return const Color(0xFFEF4444);
      case PersonalHealthFeature.medicationAlarms:
        return const Color(0xFFC8553D);
      case PersonalHealthFeature.followUpPlan:
        return const Color(0xFF0B6E6E);
      case PersonalHealthFeature.waterTracker:
        return const Color(0xFF0284C7);
      case PersonalHealthFeature.pedometer:
        return const Color(0xFF0D9488);
      case PersonalHealthFeature.dietAndCalorie:
        return const Color(0xFF16A34A);
      case PersonalHealthFeature.growthBmi:
        return const Color(0xFF2B7BBA);
      case PersonalHealthFeature.breathLung:
        return const Color(0xFF0D9488);
      case PersonalHealthFeature.sobriety:
        return const Color(0xFF16A34A);
      case PersonalHealthFeature.childrenGrowth:
        return const Color(0xFF7B5EA7);
      case PersonalHealthFeature.communitySocial:
        return const Color(0xFF06B6D4);
    }
  }

  String localizedTitle(String langCode) {
    final isTr = langCode == 'tr';
    switch (this) {
      case PersonalHealthFeature.labReports:
        return isTr ? 'Tahlil & Hastane Raporları' : 'Lab & Hospital Reports';
      case PersonalHealthFeature.vitalsTracker:
        return isTr ? 'Tansiyon & Kan Şekeri' : 'Blood Pressure & Sugar';
      case PersonalHealthFeature.medicationAlarms:
        return isTr ? 'İlaç & Alarm Hatırlatıcı' : 'Medication & Pill Alarms';
      case PersonalHealthFeature.followUpPlan:
        return isTr ? 'Düzenli Görsel Takip Planı' : 'Scheduled Check-Up Plan';
      case PersonalHealthFeature.waterTracker:
        return isTr ? 'Su Takibi & Hidrasyon' : 'Water & Hydration Tracker';
      case PersonalHealthFeature.pedometer:
        return isTr ? 'Adım Sayar & Yürüyüş' : 'Step Counter & Walking';
      case PersonalHealthFeature.dietAndCalorie:
        return isTr ? 'Diyet Listeleri & AI Kalori' : 'Diet Plans & AI Calorie';
      case PersonalHealthFeature.growthBmi:
        return isTr ? 'Boy, Kilo & VKİ' : 'Height, Weight & BMI';
      case PersonalHealthFeature.breathLung:
        return isTr ? 'Nefes & Akciğer Testi' : 'Breath & Lung Capacity';
      case PersonalHealthFeature.sobriety:
        return isTr ? 'Sigara & Alkol Bırakma' : 'Quit Smoking & Alcohol';
      case PersonalHealthFeature.childrenGrowth:
        return isTr ? 'Çocuklarım (0–18 Yaş Büyüme)' : 'Child Growth (0–18 yrs)';
      case PersonalHealthFeature.communitySocial:
        return isTr ? 'Sağlık Topluluğu & Doktorlar' : 'Health Community & Doctors';
    }
  }

  String localizedSubtitle(String langCode) {
    final isTr = langCode == 'tr';
    switch (this) {
      case PersonalHealthFeature.labReports:
        return isTr
            ? 'PDF/fotoğraf kan tahlili yükleme ve yapay zeka yorumu'
            : 'Upload PDF/photo blood tests for AI insights';
      case PersonalHealthFeature.vitalsTracker:
        return isTr
            ? 'Günlük tansiyon, nabız ve açlık/tokluk şeker grafikleri'
            : 'Daily blood pressure, pulse, and glucose trends';
      case PersonalHealthFeature.medicationAlarms:
        return isTr
            ? 'Tam ekran çalan ilaç saatleri ve doz takibi'
            : 'Full-screen medication reminders and dose logs';
      case PersonalHealthFeature.followUpPlan:
        return isTr
            ? 'Haftalık/aylık göz, cilt ve tırnak kontrol hatırlatmaları'
            : 'Periodic visual check-up schedules';
      case PersonalHealthFeature.waterTracker:
        return isTr
            ? 'Kilonuza göre günlük su hedefi ve bardak kaydı'
            : 'Weight-based daily hydration goal and quick logging';
      case PersonalHealthFeature.pedometer:
        return isTr
            ? 'Günlük adım hedefi, mesafe ve yakılan kalori'
            : 'Daily step goal, distance, and active calories';
      case PersonalHealthFeature.dietAndCalorie:
        return isTr
            ? 'Hazır diyet programları ve yemek fotoğrafından kalori hesabı'
            : 'Guided diet plans and camera meal calorie estimation';
      case PersonalHealthFeature.growthBmi:
        return isTr
            ? 'Yetişkin kilo değişimi ve vücut kitle indeksi analizi'
            : 'Adult weight history and BMI tracking';
      case PersonalHealthFeature.breathLung:
        return isTr
            ? 'Nefes tutma kapasitesi ve rahatlama egzersizleri'
            : 'Breath-hold test and guided breathing exercises';
      case PersonalHealthFeature.sobriety:
        return isTr
            ? 'Temiz geçen gün, tasarruf edilen para ve sağlık kazanımı'
            : 'Smoke/alcohol-free days, money saved & recovery milestones';
      case PersonalHealthFeature.childrenGrowth:
        return isTr
            ? 'DSÖ persentil eğrileriyle bebek/çocuk gelişim takibi'
            : 'WHO percentile curves for infant and child growth';
      case PersonalHealthFeature.communitySocial:
        return isTr
            ? 'Doğrulanmış doktorlar, sağlık grupları ve deneyim paylaşımı'
            : 'Verified doctors, support groups, and wellness wall';
    }
  }

  /// Balanced starter set pre-selected when the onboarding wizard opens,
  /// keeping niche modules (like Quit Smoking or Child Growth) opt-in.
  static Set<PersonalHealthFeature> get recommendedStarterSet => {
        PersonalHealthFeature.labReports,
        PersonalHealthFeature.vitalsTracker,
        PersonalHealthFeature.medicationAlarms,
        PersonalHealthFeature.waterTracker,
        PersonalHealthFeature.pedometer,
        PersonalHealthFeature.dietAndCalorie,
        PersonalHealthFeature.communitySocial,
      };

  static Set<PersonalHealthFeature> get clinicalPreset => {
        PersonalHealthFeature.labReports,
        PersonalHealthFeature.vitalsTracker,
        PersonalHealthFeature.medicationAlarms,
        PersonalHealthFeature.followUpPlan,
      };

  static Set<PersonalHealthFeature> get wellnessPreset => {
        PersonalHealthFeature.waterTracker,
        PersonalHealthFeature.pedometer,
        PersonalHealthFeature.dietAndCalorie,
        PersonalHealthFeature.growthBmi,
        PersonalHealthFeature.breathLung,
      };

  static Set<PersonalHealthFeature> get allFeatures =>
      PersonalHealthFeature.values.toSet();
}

/// Manages persisted user preferences for which optional health modules are
/// displayed across HomeScreen, Tracking Hub, and AppDrawer.
class FeaturePreferencesController
    extends ValueNotifier<Set<PersonalHealthFeature>> {
  FeaturePreferencesController({
    Set<PersonalHealthFeature>? initialFeatures,
  }) : super(initialFeatures ?? PersonalHealthFeatureX.allFeatures);

  static final FeaturePreferencesController instance =
      FeaturePreferencesController();

  static const String prefKeyEnabledFeatures =
      'visualcheckup_enabled_features_v1';
  static const String prefKeyWizardCompleted =
      'visualcheckup_feature_wizard_done_v1';

  bool _wizardCompleted = false;
  bool _loaded = false;

  bool get isWizardCompleted => _wizardCompleted;
  bool get isLoaded => _loaded;

  bool isEnabled(PersonalHealthFeature feature) => value.contains(feature);

  int get hiddenCount => PersonalHealthFeature.values.length - value.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _wizardCompleted = prefs.getBool(prefKeyWizardCompleted) ?? false;
    final stored = prefs.getStringList(prefKeyEnabledFeatures);

    if (stored != null) {
      final parsed = <PersonalHealthFeature>{};
      for (final raw in stored) {
        for (final candidate in PersonalHealthFeature.values) {
          if (candidate.name == raw) {
            parsed.add(candidate);
            break;
          }
        }
      }
      value = Set<PersonalHealthFeature>.unmodifiable(parsed);
    } else {
      value = Set<PersonalHealthFeature>.unmodifiable(
        PersonalHealthFeatureX.allFeatures,
      );
    }
    _loaded = true;
  }

  Future<void> saveSelection(Set<PersonalHealthFeature> selected) async {
    final normalized = Set<PersonalHealthFeature>.unmodifiable(selected);
    value = normalized;
    _wizardCompleted = true;
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKeyWizardCompleted, true);
    await prefs.setStringList(
      prefKeyEnabledFeatures,
      normalized.map((f) => f.name).toList(),
    );
  }

  Future<void> toggleFeature(PersonalHealthFeature feature) async {
    final next = Set<PersonalHealthFeature>.from(value);
    if (next.contains(feature)) {
      next.remove(feature);
    } else {
      next.add(feature);
    }
    await saveSelection(next);
  }
}
