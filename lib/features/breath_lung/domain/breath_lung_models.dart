import 'package:flutter/material.dart';

/// Test mode for respiratory breath-holding evaluation.
enum BreathTestMode {
  /// Standard voluntary maximum breath-holding capacity after a deep calm inhalation
  /// (Post-inspiratory BHT / Sabrasez clinical test principle).
  inspiratoryCapacity,

  /// Buteyko Control Pause (CP) measured after a gentle, normal exhalation
  /// until the first involuntary impulse to breathe.
  controlPause,
}

extension BreathTestModeX on BreathTestMode {
  String get label {
    switch (this) {
      case BreathTestMode.inspiratoryCapacity:
        return 'Derin Nefes Tutma (Kapasite Testi)';
      case BreathTestMode.controlPause:
        return 'Buteyko Kontrol Duraklaması (CP)';
    }
  }

  String get shortLabel {
    switch (this) {
      case BreathTestMode.inspiratoryCapacity:
        return 'Akciğer Kapasitesi';
      case BreathTestMode.controlPause:
        return 'Buteyko CP';
    }
  }

  String get guidance {
    switch (this) {
      case BreathTestMode.inspiratoryCapacity:
        return 'Rahatça dik oturun. 2 kez normal nefes alıp verin. 3. nefeste ciğerlerinizi tamamen doldurun, sayacı başlatıp nefesinizi tutun. Zorlanmadan bıraktığınız an durdurun.';
      case BreathTestMode.controlPause:
        return 'Sakin bir şekilde burnunuzdan normal nefes verin (ciğerleri sıkmayın). Sayacı başlatıp ilk İSTEMSİZ nefes alma isteğini hissedene kadar tutun. Ciğerleri tüketmeyin.';
    }
  }
}

/// Age-adjusted classification level of lung breath-holding reserve.
enum LungCapacityLevel {
  needsAttention,
  belowAverage,
  healthyNormal,
  good,
  excellentAthletic,
}

extension LungCapacityLevelX on LungCapacityLevel {
  String get label {
    switch (this) {
      case LungCapacityLevel.needsAttention:
        return 'Düşük Rezerv / Dikkat';
      case LungCapacityLevel.belowAverage:
        return 'Yaş Ortalamasının Altında';
      case LungCapacityLevel.healthyNormal:
        return 'Yaşına Göre Sağlıklı (Normal)';
      case LungCapacityLevel.good:
        return 'İyi / Güçlü Akciğer Rezervi';
      case LungCapacityLevel.excellentAthletic:
        return 'Mükemmel / Atletik Düzey';
    }
  }

  Color get color {
    switch (this) {
      case LungCapacityLevel.needsAttention:
        return const Color(0xFFEF4444); // Red
      case LungCapacityLevel.belowAverage:
        return const Color(0xFFF59E0B); // Amber
      case LungCapacityLevel.healthyNormal:
        return const Color(0xFF10B981); // Emerald Green
      case LungCapacityLevel.good:
        return const Color(0xFF06B6D4); // Cyan
      case LungCapacityLevel.excellentAthletic:
        return const Color(0xFF8B5CF6); // Purple/Violet
    }
  }

  IconData get icon {
    switch (this) {
      case LungCapacityLevel.needsAttention:
        return Icons.warning_amber_rounded;
      case LungCapacityLevel.belowAverage:
        return Icons.trending_down_rounded;
      case LungCapacityLevel.healthyNormal:
        return Icons.check_circle_outline_rounded;
      case LungCapacityLevel.good:
        return Icons.thumb_up_alt_rounded;
      case LungCapacityLevel.excellentAthletic:
        return Icons.military_tech_rounded;
    }
  }

  String get shortDescription {
    switch (this) {
      case LungCapacityLevel.needsAttention:
        return 'Akciğer hava tutma süreniz yaş grubu standartlarının belirgin altında. Düzenli diyafram egzersizleri ve şikayetiniz varsa doktor kontrolü önerilir.';
      case LungCapacityLevel.belowAverage:
        return 'Kapasiteniz yaş grubunuzun biraz gerisinde. Günlük nefes egzersizleri ve hafif tempolu yürüyüşlerle hızla geliştirilebilir.';
      case LungCapacityLevel.healthyNormal:
        return 'Tebrikler! Nefes tutma süreniz dünya standartlarında yaş grubunuz için sağlıklı ve beklenen aralıktadır.';
      case LungCapacityLevel.good:
        return 'Harika! Akciğer hacminiz ve karbondioksit toleransınız yaş grubunuzun üzerinde oldukça kuvvetli.';
      case LungCapacityLevel.excellentAthletic:
        return 'Kusursuz! Atletik seviyede diyafram gücü ve yüksek kardiyopulmoner oksijen rezervine sahipsiniz.';
    }
  }
}

/// Normative reference values for a specific age bracket.
class AgeBreathNorm {
  const AgeBreathNorm({
    required this.minAge,
    required this.maxAge,
    required this.ageLabel,
    required this.cautionThresholdSec,
    required this.normalMinSec,
    required this.goodMinSec,
    required this.athleticMinSec,
    required this.averageExpectedSec,
  });

  final int minAge;
  final int maxAge;
  final String ageLabel;

  /// Below this is classified as needsAttention (reduced reserve threshold).
  final double cautionThresholdSec;

  /// Lower bound for healthy normal.
  final double normalMinSec;

  /// Lower bound for good.
  final double goodMinSec;

  /// Lower bound for excellent/athletic.
  final double athleticMinSec;

  /// Median healthy expected seconds for this demographic.
  final double averageExpectedSec;

  bool containsAge(int age) => age >= minAge && age <= maxAge;
}

/// World-recognized age-stratified norms for post-inspiratory breath-hold time (BHT).
const List<AgeBreathNorm> kAgeBreathNorms = [
  AgeBreathNorm(
    minAge: 8,
    maxAge: 17,
    ageLabel: '8–17 Yaş (Genç)',
    cautionThresholdSec: 18.0,
    normalMinSec: 28.0,
    goodMinSec: 42.0,
    athleticMinSec: 55.0,
    averageExpectedSec: 36.0,
  ),
  AgeBreathNorm(
    minAge: 18,
    maxAge: 29,
    ageLabel: '18–29 Yaş',
    cautionThresholdSec: 28.0,
    normalMinSec: 42.0,
    goodMinSec: 58.0,
    athleticMinSec: 70.0,
    averageExpectedSec: 50.0,
  ),
  AgeBreathNorm(
    minAge: 30,
    maxAge: 39,
    ageLabel: '30–39 Yaş',
    cautionThresholdSec: 26.0,
    normalMinSec: 38.0,
    goodMinSec: 52.0,
    athleticMinSec: 65.0,
    averageExpectedSec: 46.0,
  ),
  AgeBreathNorm(
    minAge: 40,
    maxAge: 49,
    ageLabel: '40–49 Yaş',
    cautionThresholdSec: 24.0,
    normalMinSec: 34.0,
    goodMinSec: 47.0,
    athleticMinSec: 58.0,
    averageExpectedSec: 41.0,
  ),
  AgeBreathNorm(
    minAge: 50,
    maxAge: 59,
    ageLabel: '50–59 Yaş',
    cautionThresholdSec: 20.0,
    normalMinSec: 30.0,
    goodMinSec: 42.0,
    athleticMinSec: 52.0,
    averageExpectedSec: 36.0,
  ),
  AgeBreathNorm(
    minAge: 60,
    maxAge: 69,
    ageLabel: '60–69 Yaş',
    cautionThresholdSec: 17.0,
    normalMinSec: 25.0,
    goodMinSec: 36.0,
    athleticMinSec: 45.0,
    averageExpectedSec: 31.0,
  ),
  AgeBreathNorm(
    minAge: 70,
    maxAge: 120,
    ageLabel: '70+ Yaş',
    cautionThresholdSec: 14.0,
    normalMinSec: 20.0,
    goodMinSec: 30.0,
    athleticMinSec: 40.0,
    averageExpectedSec: 25.0,
  ),
];

/// Buteyko Control Pause norms (measured after gentle exhalation).
const AgeBreathNorm kButeykoControlPauseNorm = AgeBreathNorm(
  minAge: 8,
  maxAge: 120,
  ageLabel: 'Tüm Yaşlar (Buteyko CP)',
  cautionThresholdSec: 15.0,
  normalMinSec: 25.0,
  goodMinSec: 35.0,
  athleticMinSec: 45.0,
  averageExpectedSec: 30.0,
);

/// Comprehensive evaluation result of a breath-holding test.
class LungHealthEvaluation {
  const LungHealthEvaluation({
    required this.age,
    required this.holdSeconds,
    required this.mode,
    required this.score,
    required this.level,
    required this.norm,
    required this.deltaFromAverageSec,
    required this.headline,
    required this.summary,
    required this.recommendations,
    required this.hasClinicalWarning,
    this.clinicalWarning,
    required this.medicalDisclaimer,
  });

  final int age;
  final double holdSeconds;
  final BreathTestMode mode;

  /// Overall health score 0 to 100 normalized to age bracket.
  final int score;
  final LungCapacityLevel level;
  final AgeBreathNorm norm;

  /// Difference from age median: positive = better than average, negative = below average.
  final double deltaFromAverageSec;

  final String headline;
  final String summary;
  final List<String> recommendations;

  final bool hasClinicalWarning;
  final String? clinicalWarning;
  final String medicalDisclaimer;
}

/// Evaluates breath-hold duration against age-stratified international cardiopulmonary norms.
LungHealthEvaluation evaluateBreathHoldByAge({
  required int age,
  required double holdSeconds,
  BreathTestMode mode = BreathTestMode.inspiratoryCapacity,
  String? gender,
}) {
  final safeAge = age.clamp(8, 105);
  final safeHoldSec = holdSeconds < 0 ? 0.0 : (holdSeconds > 300.0 ? 300.0 : holdSeconds);

  final AgeBreathNorm norm = mode == BreathTestMode.controlPause
      ? kButeykoControlPauseNorm
      : kAgeBreathNorms.firstWhere(
          (n) => n.containsAge(safeAge),
          orElse: () => kAgeBreathNorms[1], // default 18-29
        );

  final delta = safeHoldSec - norm.averageExpectedSec;

  // Determine Level
  final LungCapacityLevel level;
  if (safeHoldSec < norm.cautionThresholdSec) {
    level = LungCapacityLevel.needsAttention;
  } else if (safeHoldSec < norm.normalMinSec) {
    level = LungCapacityLevel.belowAverage;
  } else if (safeHoldSec < norm.goodMinSec) {
    level = LungCapacityLevel.healthyNormal;
  } else if (safeHoldSec < norm.athleticMinSec) {
    level = LungCapacityLevel.good;
  } else {
    level = LungCapacityLevel.excellentAthletic;
  }

  // Calculate normalized 0-100 score
  int computedScore;
  if (safeHoldSec <= 0) {
    computedScore = 0;
  } else if (safeHoldSec < norm.cautionThresholdSec) {
    // 0 to 45
    computedScore = ((safeHoldSec / norm.cautionThresholdSec) * 45).round();
  } else if (safeHoldSec < norm.normalMinSec) {
    // 46 to 64
    final ratio = (safeHoldSec - norm.cautionThresholdSec) /
        (norm.normalMinSec - norm.cautionThresholdSec);
    computedScore = 46 + (ratio * 18).round();
  } else if (safeHoldSec < norm.goodMinSec) {
    // 65 to 84
    final ratio =
        (safeHoldSec - norm.normalMinSec) / (norm.goodMinSec - norm.normalMinSec);
    computedScore = 65 + (ratio * 19).round();
  } else if (safeHoldSec < norm.athleticMinSec) {
    // 85 to 94
    final ratio = (safeHoldSec - norm.goodMinSec) /
        (norm.athleticMinSec - norm.goodMinSec);
    computedScore = 85 + (ratio * 9).round();
  } else {
    // 95 to 100
    final extra = (safeHoldSec - norm.athleticMinSec) / 20.0;
    computedScore = (95 + (extra * 5).round()).clamp(95, 100);
  }

  // Headline
  final String headline;
  final formattedSec = safeHoldSec.toStringAsFixed(1);
  final formattedAvg = norm.averageExpectedSec.toStringAsFixed(0);
  switch (level) {
    case LungCapacityLevel.needsAttention:
      headline = '$formattedSec sn — Yaş Grubunun Belirgin Altında';
      break;
    case LungCapacityLevel.belowAverage:
      headline = '$formattedSec sn — Geliştirilmeye Açık Kapasite';
      break;
    case LungCapacityLevel.healthyNormal:
      headline = '$formattedSec sn — Yaşına Göre Sağlıklı Akciğer';
      break;
    case LungCapacityLevel.good:
      headline = '$formattedSec sn — Güçlü Akciğer Rezervi';
      break;
    case LungCapacityLevel.excellentAthletic:
      headline = '$formattedSec sn — Üstün / Atletik Kapasite';
      break;
  }

  // Summary
  final deltaText = delta >= 0
      ? '+${delta.toStringAsFixed(1)} sn yaş ortalamasının üzerinde'
      : '${delta.abs().toStringAsFixed(1)} sn yaş ortalamasının altında';

  final summary =
      '${norm.ageLabel} için sağlıklı beklenen ortalama nefes tutma süresi $formattedAvg saniyedir. '
      'Ölçülen süreniz ($formattedSec sn) $deltaText bir performans gösteriyor. '
      '${level.shortDescription}';

  // Recommendations
  final recommendations = <String>[];
  if (level == LungCapacityLevel.needsAttention ||
      level == LungCapacityLevel.belowAverage) {
    recommendations.add(
        'Büzük Dudak Nefesi (Pursed-Lip): Günde 2 kez 5 dakika uygulayarak hava hapsini azaltın ve akciğer tabanını havalandırın.');
    recommendations.add(
        'Diyafram Egzersizi: Sırt üstü veya dik oturarak karın nefesiyle diyafram kasınızı güçlendirin.');
    recommendations.add(
        'Hafif Tempolu Yürüyüş: Günlük 20-30 dakika tempolu yürüyüş vital akciğer kapasitesini (FVC) artırır.');
    recommendations.add(
        'Sigara / Tütün Dumanı: Aktif veya pasif içicilik alveol elastikiyetini azaltır; dumansız ortam akciğer rejenerasyonunu hızlandırır.');
  } else {
    recommendations.add(
        'Kutu Nefesi (Box Breathing): 4-4-4-4 saniye ritmiyle stres anında CO₂ toleransınızı ve zihinsel odağınızı koruyun.');
    recommendations.add(
        'Aerobik Egzersiz: Koşu, yüzme veya bisiklet ile elde ettiğiniz güçlü kardiyopulmoner rezervi sürdürün.');
    recommendations.add(
        '4-7-8 Nefes Tekniği: Akşamları parasempatik sinir sistemini uyararak uyku kalitenizi ve oksijenlenmeyi destekleyin.');
  }

  // Red-flag clinical warning check (Sabrasez <20-25s threshold)
  final bool hasClinicalWarning =
      mode == BreathTestMode.inspiratoryCapacity && safeHoldSec < 20.0;
  final String? clinicalWarning = hasClinicalWarning
      ? 'Önemli Uyarı: 20 saniyenin altındaki derin nefes tutma süresi azalmış kardiyopulmoner rezerve işaret edebilir. İstirahatte nefes darlığı, geçmeyen öksürük veya göğüste hırıltı hissediyorsanız Göğüs Hastalıkları uzmanına danışarak Spirometri (Solunum Fonksiyon Testi - SFT) yaptırmanız önerilir.'
      : null;

  const medicalDisclaimer =
      'VisualCheckUp Nefes & Akciğer Testi genel zindelik ve fonksiyonel farkındalık amaçlıdır; tıbbi tanı (spirometri/SFT) yerine geçmez. '
      'Test sırasında asla kendinizi bayılacak veya başınız dönecek kadar zorlamayınız. Asla su içinde uygulamayınız.';

  return LungHealthEvaluation(
    age: safeAge,
    holdSeconds: safeHoldSec,
    mode: mode,
    score: computedScore,
    level: level,
    norm: norm,
    deltaFromAverageSec: delta,
    headline: headline,
    summary: summary,
    recommendations: recommendations,
    hasClinicalWarning: hasClinicalWarning,
    clinicalWarning: clinicalWarning,
    medicalDisclaimer: medicalDisclaimer,
  );
}

/// A specific phase within a guided breathing exercise.
enum BreathPhaseType {
  inhale,
  hold,
  exhale,
  rest,
}

extension BreathPhaseTypeX on BreathPhaseType {
  String get labelTr {
    switch (this) {
      case BreathPhaseType.inhale:
        return 'Nefes Al';
      case BreathPhaseType.hold:
        return 'Nefesini Tut';
      case BreathPhaseType.exhale:
        return 'Yavaşça Ver';
      case BreathPhaseType.rest:
        return 'Boşta Bekle';
    }
  }

  Color get color {
    switch (this) {
      case BreathPhaseType.inhale:
        return const Color(0xFF06B6D4); // Cyan
      case BreathPhaseType.hold:
        return const Color(0xFF8B5CF6); // Purple
      case BreathPhaseType.exhale:
        return const Color(0xFF10B981); // Emerald Green
      case BreathPhaseType.rest:
        return const Color(0xFF64748B); // Slate
    }
  }
}

class BreathPhase {
  const BreathPhase({
    required this.type,
    required this.durationSeconds,
    required this.instruction,
  });

  final BreathPhaseType type;
  final int durationSeconds;
  final String instruction;
}

/// Clinically proven guided breathing exercise model.
class GuidedBreathingExercise {
  const GuidedBreathingExercise({
    required this.id,
    required this.title,
    required this.badge,
    required this.purpose,
    required this.clinicalBenefit,
    required this.phases,
    required this.recommendedCycles,
    required this.accentColor,
    required this.icon,
  });

  final String id;
  final String title;
  final String badge;
  final String purpose;
  final String clinicalBenefit;
  final List<BreathPhase> phases;
  final int recommendedCycles;
  final Color accentColor;
  final IconData icon;

  int get totalCycleSeconds =>
      phases.fold(0, (sum, p) => sum + p.durationSeconds);
}

/// Standard 4 clinically guided breathing exercises.
final List<GuidedBreathingExercise> kGuidedBreathingExercises = [
  const GuidedBreathingExercise(
    id: 'pursed_lip',
    title: 'Büzük Dudak Nefesi',
    badge: 'KOAH & Nefes Darlığı',
    purpose: 'Hapsolmuş havayı boşaltır, bronşiolleri açık tutar ve nefes darlığını hızla yatıştırır.',
    clinicalBenefit: 'Bronşiyal hava yollarının erken çökmesini önleyerek akciğerlerdeki karbondioksitin tam atılmasını sağlar.',
    accentColor: Color(0xFF0D9488),
    icon: Icons.air_rounded,
    recommendedCycles: 6,
    phases: [
      BreathPhase(
        type: BreathPhaseType.inhale,
        durationSeconds: 2,
        instruction: 'Burnunuzdan sakin ve derin nefes alın',
      ),
      BreathPhase(
        type: BreathPhaseType.exhale,
        durationSeconds: 4,
        instruction: 'Dudaklarınızı ıslık çalar gibi büzerek havayı çok yavaşça üfleyin',
      ),
    ],
  ),
  const GuidedBreathingExercise(
    id: 'diaphragmatic',
    title: 'Diyafram (Karın) Nefesi',
    badge: 'Akciğer Tabanı Güçlendirme',
    purpose: 'Göğüs kafesi yerine diyafram kasını aktive ederek akciğer alt loblarını havalandırır.',
    clinicalBenefit: 'Solunum iş yükünü azaltır, alveol ventilasyonunu ve vital akciğer kapasitesini geliştirir.',
    accentColor: Color(0xFF2563EB),
    icon: Icons.accessibility_new_rounded,
    recommendedCycles: 5,
    phases: [
      BreathPhase(
        type: BreathPhaseType.inhale,
        durationSeconds: 4,
        instruction: 'Burnunuzdan karnınızı bir balon gibi şişirerek derin nefes alın',
      ),
      BreathPhase(
        type: BreathPhaseType.hold,
        durationSeconds: 2,
        instruction: 'Oksijenin akciğer tabanına yayılması için hafifçe tutun',
      ),
      BreathPhase(
        type: BreathPhaseType.exhale,
        durationSeconds: 6,
        instruction: 'Ağzınızdan karnınız inerken havayı yavaş ve pürüzsüzce boşaltın',
      ),
    ],
  ),
  const GuidedBreathingExercise(
    id: 'box_breathing',
    title: 'Kutu Nefesi (4-4-4-4)',
    badge: 'CO₂ Toleransı & Odak',
    purpose: 'Kolluk kuvvetleri ve sporcular tarafından kullanılan otonom sinir sistemi dengeleyicisi.',
    clinicalBenefit: 'Kandaki karbondioksit duyarlılığını normalize eder ve kalp atım hızı değişkenliğini (HRV) artırır.',
    accentColor: Color(0xFF7C3AED),
    icon: Icons.crop_square_rounded,
    recommendedCycles: 4,
    phases: [
      BreathPhase(
        type: BreathPhaseType.inhale,
        durationSeconds: 4,
        instruction: '4 saniye boyunca burnunuzdan pürüzsüzce nefes alın',
      ),
      BreathPhase(
        type: BreathPhaseType.hold,
        durationSeconds: 4,
        instruction: '4 saniye boyunca akciğerler dolu halde nefesinizi tutun',
      ),
      BreathPhase(
        type: BreathPhaseType.exhale,
        durationSeconds: 4,
        instruction: '4 saniye boyunca ağzınızdan kontrollü şekilde nefes verin',
      ),
      BreathPhase(
        type: BreathPhaseType.rest,
        durationSeconds: 4,
        instruction: '4 saniye boyunca akciğerler boşta sakin bir şekilde bekleyin',
      ),
    ],
  ),
  const GuidedBreathingExercise(
    id: 'relax_478',
    title: '4-7-8 Derin Rahatlama Nefesi',
    badge: 'Stres & Uyku Desteği',
    purpose: 'Dr. Andrew Weil tarafından geliştirilen doğal sinir sistemi gevşetme ve gevşeme protokolü.',
    clinicalBenefit: 'Vagus sinirini güçlü şekilde uyararak kalp hızını yavaşlatır ve parasempatik aktivasyonu başlatır.',
    accentColor: Color(0xFFDB2777),
    icon: Icons.nightlight_round,
    recommendedCycles: 4,
    phases: [
      BreathPhase(
        type: BreathPhaseType.inhale,
        durationSeconds: 4,
        instruction: 'Burnunuzdan sessizce 4 saniye nefes alın',
      ),
      BreathPhase(
        type: BreathPhaseType.hold,
        durationSeconds: 7,
        instruction: '7 saniye boyunca nefesinizi rahatça tutun',
      ),
      BreathPhase(
        type: BreathPhaseType.exhale,
        durationSeconds: 8,
        instruction: 'Dudaklarınızı büzerek 8 saniye boyunca "vuuş" sesiyle verin',
      ),
    ],
  ),
];

/// Persistent record of a completed breath-hold test.
class BreathHoldRecord {
  const BreathHoldRecord({
    required this.id,
    required this.recordedAt,
    required this.age,
    required this.holdSeconds,
    required this.mode,
    required this.score,
    required this.level,
    this.notes,
  });

  final String id;
  final DateTime recordedAt;
  final int age;
  final double holdSeconds;
  final BreathTestMode mode;
  final int score;
  final LungCapacityLevel level;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'age': age,
        'holdSeconds': holdSeconds,
        'mode': mode.name,
        'score': score,
        'level': level.name,
        if (notes != null) 'notes': notes,
      };

  factory BreathHoldRecord.fromJson(Map<String, dynamic> json) {
    return BreathHoldRecord(
      id: json['id'] as String? ?? UniqueKey().toString(),
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
      age: (json['age'] as num?)?.toInt() ?? 30,
      holdSeconds: (json['holdSeconds'] as num?)?.toDouble() ?? 0.0,
      mode: BreathTestMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => BreathTestMode.inspiratoryCapacity,
      ),
      score: (json['score'] as num?)?.toInt() ?? 50,
      level: LungCapacityLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => LungCapacityLevel.healthyNormal,
      ),
      notes: json['notes'] as String?,
    );
  }
}
