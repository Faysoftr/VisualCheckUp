import 'package:flutter/material.dart';

/// Clinical CEAP Classification for Chronic Venous Disease (CVD).
enum CeapStage {
  c0, // No visible or palpable signs of venous disease (symptoms only: heaviness, ache)
  c1, // Telangiectasias or reticular veins (spider veins < 3mm)
  c2, // Varicose veins (enlarged, tortuous subcutaneous veins ≥ 3mm)
  c3, // Venous edema (swelling without skin changes, worse in evening)
  c4, // Skin and subcutaneous changes (pigmentation/stasis dermatitis, lipodermatosclerosis)
  c5, // Healed venous ulcer
  c6, // Active venous ulcer
}

extension CeapStageX on CeapStage {
  String get code {
    switch (this) {
      case CeapStage.c0:
        return 'C0';
      case CeapStage.c1:
        return 'C1';
      case CeapStage.c2:
        return 'C2';
      case CeapStage.c3:
        return 'C3';
      case CeapStage.c4:
        return 'C4';
      case CeapStage.c5:
        return 'C5';
      case CeapStage.c6:
        return 'C6';
    }
  }

  String get title {
    switch (this) {
      case CeapStage.c0:
        return 'C0 — Görünür Damar Yok (Erken Evre)';
      case CeapStage.c1:
        return 'C1 — Kılcal / Örümcek Damarlar (Telenjiektazi)';
      case CeapStage.c2:
        return 'C2 — Belirgin Kıvrımlı Varisler';
      case CeapStage.c3:
        return 'C3 — Bacak ve Ayak Bileği Ödemi (Şişlik)';
      case CeapStage.c4:
        return 'C4 — Cilt Rengi Değişimi & Staz Dermatiti';
      case CeapStage.c5:
        return 'C5 — İyileşmiş Venöz Yara/Ülser';
      case CeapStage.c6:
        return 'C6 — Aktif Venöz Ülser (Yara)';
    }
  }

  String get shortDescription {
    switch (this) {
      case CeapStage.c0:
        return 'Dışarıdan damar görünmez; ancak akşamları bacaklarda ağırlık, yorgunluk ve hafif yanma hissedilebilir.';
      case CeapStage.c1:
        return 'Cilt yüzeyinde kırmızı, mor veya mavi renkli ince örümcek ağı şeklinde kılcal damar çatlamaları (< 3 mm).';
      case CeapStage.c2:
        return 'Ciltte belirgin kabarıklık oluşturan, mavi-yeşil renkli kıvrımlı genişlemiş varis paketleri (≥ 3 mm).';
      case CeapStage.c3:
        return 'Özellikle günün sonunda veya uzun süre ayakta kalındığında ayak bileği çevresinde belirgin venöz ödem (şişlik).';
      case CeapStage.c4:
        return 'Ciltte kahverengi hemosiderin demir lekelenmesi, kaşıntılı egzama, sertleşme (lipodermatoskleroz) ve doku beslenme bozukluğu.';
      case CeapStage.c5:
        return 'Geçmişte açılıp kapanmış, skar dokusu bırakmış iyileşmiş venöz bacak yarası.';
      case CeapStage.c6:
        return 'Bilek veya baldır bölgesinde aktif, açık doku kaybı ve yara. Acil hekim müdahalesi gerektirir.';
    }
  }

  Color get color {
    switch (this) {
      case CeapStage.c0:
        return const Color(0xFF10B981); // Emerald
      case CeapStage.c1:
        return const Color(0xFF06B6D4); // Cyan
      case CeapStage.c2:
        return const Color(0xFFF59E0B); // Amber
      case CeapStage.c3:
        return const Color(0xFFF97316); // Orange
      case CeapStage.c4:
        return const Color(0xFFEF4444); // Red
      case CeapStage.c5:
      case CeapStage.c6:
        return const Color(0xFFB91C1C); // Deep Red
    }
  }

  IconData get icon {
    switch (this) {
      case CeapStage.c0:
        return Icons.verified_outlined;
      case CeapStage.c1:
        return Icons.grain_rounded;
      case CeapStage.c2:
        return Icons.alt_route_rounded;
      case CeapStage.c3:
        return Icons.waterfall_chart_rounded;
      case CeapStage.c4:
        return Icons.warning_amber_rounded;
      case CeapStage.c5:
      case CeapStage.c6:
        return Icons.local_hospital_rounded;
    }
  }
}

/// Venous Risk & Symptoms Assessment.
class VeinSymptomAssessment {
  const VeinSymptomAssessment({
    this.hasHeavyLegsEvening = false,
    this.hasNightCramps = false,
    this.hasItchingOrBurning = false,
    this.standsOrSitsLongHours = false,
    this.hasFamilyHistory = false,
    this.hasAnkleSwelling = false,
    this.hasSuddenPainOrAsymmetricSwelling = false,
  });

  final bool hasHeavyLegsEvening;
  final bool hasNightCramps;
  final bool hasItchingOrBurning;
  final bool standsOrSitsLongHours;
  final bool hasFamilyHistory;
  final bool hasAnkleSwelling;

  /// Emergency Red flag for Deep Vein Thrombosis (DVT).
  final bool hasSuddenPainOrAsymmetricSwelling;

  int get riskScore {
    int score = 0;
    if (hasHeavyLegsEvening) score += 15;
    if (hasNightCramps) score += 15;
    if (hasItchingOrBurning) score += 15;
    if (standsOrSitsLongHours) score += 20;
    if (hasFamilyHistory) score += 15;
    if (hasAnkleSwelling) score += 20;
    return score.clamp(0, 100);
  }
}

/// Comprehensive evaluation result for Vein & Varicose health.
class VeinHealthEvaluation {
  const VeinHealthEvaluation({
    required this.stage,
    required this.symptomScore,
    required this.riskLevel,
    required this.headline,
    required this.clinicalSummary,
    required this.recommendations,
    required this.isDvtWarning,
    this.dvtEmergencyNotice,
    required this.recommendedSpecialty,
    required this.medicalDisclaimer,
  });

  final CeapStage stage;
  final int symptomScore;
  final String riskLevel;
  final String headline;
  final String clinicalSummary;
  final List<String> recommendations;
  final bool isDvtWarning;
  final String? dvtEmergencyNotice;
  final String recommendedSpecialty;
  final String medicalDisclaimer;
}

/// Pure clinical function to evaluate vein & varicose health according to CEAP & symptoms.
VeinHealthEvaluation evaluateVeinHealth({
  required CeapStage stage,
  required VeinSymptomAssessment symptoms,
  String? notes,
}) {
  final score = symptoms.riskScore;

  String riskLevel;
  if (stage.index >= CeapStage.c4.index || score >= 65) {
    riskLevel = 'Yüksek Venöz Risk / İleri Evre';
  } else if (stage.index >= CeapStage.c2.index || score >= 35) {
    riskLevel = 'Orta Düzey Venöz Yetmezlik Riski';
  } else if (stage == CeapStage.c1 || score > 0) {
    riskLevel = 'Hafif / Erken Evre (Koruyucu Dönem)';
  } else {
    riskLevel = 'Düşük Risk / Sağlıklı Damar Yapısı';
  }

  final bool isDvt = symptoms.hasSuddenPainOrAsymmetricSwelling;
  final String? dvtNotice = isDvt
      ? 'ACİL TIBBİ UYARI: Tek bacakta aniden gelişen şiddetli baldır ağrısı, belirgin şişlik, ısı artışı ve kızarıklık Derin Ven Trombozu (DVT - pıhtı) şüphesi doğurabilir. Vakit kaybetmeden en yakın acil servise veya Kalp ve Damar Cerrahisi (KDC) uzmanına başvurunuz.'
      : null;

  final recommendations = <String>[];

  // Specific clinical advice
  recommendations.add(
      'Baldır Kası Pompası Egzersizi: Gün içinde saat başı parmak ucunda 15-20 kez yükselip inerek bacak kaslarının kirli kanı yukarı pompalamasını sağlayın.');
  recommendations.add(
      'Bacak Elevasyonu (Yükseltme): Akşamları dinlenirken bacaklarınızı kalp seviyesinin 15-20 cm üzerine kaldırarak 15-20 dakika yer çekimi desteğiyle venöz drenajı rahatlatın.');

  if (stage.index >= CeapStage.c2.index || symptoms.hasAnkleSwelling) {
    recommendations.add(
        'Kademeli Basınçlı Varis Çorabı: Doktor önerisiyle (örneğin diz altı CCL1 veya CCL2) basınçlı çorap kullanımı kan göllenmesini ve ödemi belirgin şekilde önler.');
  }

  recommendations.add(
      'Sıcak Uygulamalardan Kaçının: Sıcak banyo, sauna, kaplıca ve direkt güneşlenme damarları genişleterek varis şikayetlerini artırır; duş bitiminde bacaklara soğuk su tutmak damar tonusunu artırır.');

  if (symptoms.standsOrSitsLongHours) {
    recommendations.add(
        'Hareketsizliği Kırın: 45 dakikadan uzun süre sabit ayakta durmaktan veya bacak bacak üstüne atarak oturmaktan kaçının.');
  }

  const medicalDisclaimer =
      'VisualCheckUp Damar & Varis Analizi genel farkındalık ve evreleme bilgilendirmesi amaçlıdır; Doppler Ultrasonografi (RDUS) muayenesinin yerini tutmaz.';

  return VeinHealthEvaluation(
    stage: stage,
    symptomScore: score,
    riskLevel: riskLevel,
    headline: '${stage.code} — ${stage.title}',
    clinicalSummary: stage.shortDescription,
    recommendations: recommendations,
    isDvtWarning: isDvt,
    dvtEmergencyNotice: dvtNotice,
    recommendedSpecialty: 'Kalp ve Damar Cerrahisi (KDC) veya Girişimsel Radyoloji',
    medicalDisclaimer: medicalDisclaimer,
  );
}

/// Clinically guided vein & circulation exercises.
class VeinExercise {
  const VeinExercise({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instruction,
    required this.benefit,
    required this.durationSec,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String instruction;
  final String benefit;
  final int durationSec;
  final IconData icon;
}

final List<VeinExercise> kVeinExercises = [
  const VeinExercise(
    id: 'calf_pump',
    title: 'Baldır Kası Pompası (Parmak Ucu Yükselme)',
    subtitle: 'Venöz dolaşımın ikinci kalbi',
    instruction: 'Ayakta dik durun. Parmak uçlarınızda yavaşça yükselin, 2 saniye tepe noktada bekleyin ve topuklarınızı yere indirin. 20 tekrar yapın.',
    benefit: 'Gastroknemius ve soleus kasları kasılarak bacak derin venlerindeki kanı yer çekimine karşı kalbe pompalar.',
    durationSec: 60,
    icon: Icons.directions_walk_rounded,
  ),
  const VeinExercise(
    id: 'ankle_circles',
    title: 'Ayak Bileği Çemberi & Pedallama',
    subtitle: 'Masa başı ve otururken venöz akış',
    instruction: 'Otururken bir ayağınızı havaya kaldırın. Ayak bileğinizi saat yönünde 10 kez, tersine 10 kez dairesel döndürün. Ardından pedala basar gibi öne-arkaya esnetin.',
    benefit: 'Ayak bileği eklem hareket açıklığını korur ve kanın bilek çevresinde göllenmesini engeller.',
    durationSec: 60,
    icon: Icons.replay_circle_filled_rounded,
  ),
  const VeinExercise(
    id: 'leg_elevation',
    title: 'Bacak Elevasyonu (90° Duvar Desteği)',
    subtitle: 'Günün yorgunluğunu ve ödemi boşaltma',
    instruction: 'Sırt üstü yere veya yatağa uzanın. Bacaklarınızı duvara yaslayarak yukarı kaldırın. Derin ve sakin nefesler alarak 5-10 dakika bekleyin.',
    benefit: 'Yer çekimi bacaklardaki kan ve lenf sıvısının kalbe geri dönüşünü hızlandırır, şişlik ve ağırlık hissini anında yatıştırır.',
    durationSec: 180,
    icon: Icons.airline_seat_legroom_extra_rounded,
  ),
];

/// Persistent record of a vein checkup.
class VeinCheckRecord {
  const VeinCheckRecord({
    required this.id,
    required this.recordedAt,
    required this.stage,
    required this.symptomScore,
    this.notes,
  });

  final String id;
  final DateTime recordedAt;
  final CeapStage stage;
  final int symptomScore;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'stage': stage.name,
        'symptomScore': symptomScore,
        if (notes != null) 'notes': notes,
      };

  factory VeinCheckRecord.fromJson(Map<String, dynamic> json) {
    return VeinCheckRecord(
      id: json['id'] as String? ?? UniqueKey().toString(),
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '') ??
          DateTime.now(),
      stage: CeapStage.values.firstWhere(
        (s) => s.name == json['stage'],
        orElse: () => CeapStage.c0,
      ),
      symptomScore: (json['symptomScore'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );
  }
}
