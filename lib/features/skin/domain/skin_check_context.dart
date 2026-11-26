import 'package:flutter/material.dart';

/// Primary visual presentation selected by the user before skin capture.
enum SkinConcernType {
  skinCancerRisk,
  wart,
  bruise,
  facialSpot,
  rashRedness,
  molePigment,
  scalyDry,
  blisterPustule,
  general,
}

extension SkinConcernTypeX on SkinConcernType {
  String get label {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return 'Ben & Cilt Kanseri Risk';
      case SkinConcernType.wart:
        return 'Siğil Ön Kontrol';
      case SkinConcernType.bruise:
        return 'Morluk Takibi';
      case SkinConcernType.facialSpot:
        return 'Yüz Lekesi';
      case SkinConcernType.rashRedness:
        return 'Kızarıklık / Döküntü';
      case SkinConcernType.molePigment:
        return 'Ben / Koyu Leke';
      case SkinConcernType.scalyDry:
        return 'Pullu / Kuru Plak';
      case SkinConcernType.blisterPustule:
        return 'Kabarcık / Sivilce';
      case SkinConcernType.general:
        return 'Genel Cilt Kontrolü';
    }
  }

  String get shortCardSubtitle {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return 'ABCDE & iyileşmeyen yara ön taraması';
      case SkinConcernType.wart:
        return 'Pütürlü kabartı & siyah nokta ipucu';
      case SkinConcernType.bruise:
        return 'Renk evresi & darbesiz morluk uyarısı';
      case SkinConcernType.facialSpot:
        return 'Güneş lekesi, melazma & pigment takibi';
      case SkinConcernType.rashRedness:
        return 'Egzama, alerji ve tahriş';
      case SkinConcernType.molePigment:
        return 'Pigment ve simetri takibi';
      case SkinConcernType.scalyDry:
        return 'Kuruluk, sedef ve mantar ipucu';
      case SkinConcernType.blisterPustule:
        return 'Akne, folikülit ve kabarcık';
      case SkinConcernType.general:
        return 'Genel cilt tonu ve doku taraması';
    }
  }

  String get helperText {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return 'ABCDE kuralı ve iyileşmeyen yara belirtilerine göre dermatoloji (dermoskopi) öncesi risk farkındalığı sunar; kesin tanı yerine geçmez.';
      case SkinConcernType.wart:
        return 'Pütürlü/sert yüzey ve küçük siyah noktacık (kapiller) ipuçlarını değerlendirir; nasır veya diğer kabartılardan kesin ayrım için dermatoloji muayenesi gerekir.';
      case SkinConcernType.bruise:
        return 'Morluğun renk evresini (taze kırmızı-mor, orta lacivert, iyileşen yeşil-sarı) izler; darbesiz oluşan morluklarda hekim değerlendirmesi önerir.';
      case SkinConcernType.facialSpot:
        return 'Yüzdeki güneş lekesi, melazma, akne sonrası iz veya asimetrik koyu leke görünümünü çevre cilt tonuyla karşılaştırır.';
      case SkinConcernType.rashRedness:
        return 'Egzama, kontakt dermatit, ürtiker veya tahriş ön farkındalığı.';
      case SkinConcernType.molePigment:
        return 'ABCDE kriterlerine göre pigment, renk dağılımı ve simetri ön bakışı.';
      case SkinConcernType.scalyDry:
        return 'Kuruluk, sedef benzeri pullanma veya yüzeysel mantar ön kontrolü.';
      case SkinConcernType.blisterPustule:
        return 'Akne, folikülit, kabarcık veya ikincil enfeksiyon ipuçları.';
      case SkinConcernType.general:
        return 'Cilt yüzeyinde kızarıklık, leke veya ton farklılığı taraması.';
    }
  }

  IconData get icon {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return Icons.biotech_outlined;
      case SkinConcernType.wart:
        return Icons.grain_rounded;
      case SkinConcernType.bruise:
        return Icons.blur_circular_rounded;
      case SkinConcernType.facialSpot:
        return Icons.face_retouching_natural_outlined;
      case SkinConcernType.rashRedness:
        return Icons.flare_outlined;
      case SkinConcernType.molePigment:
        return Icons.circle_outlined;
      case SkinConcernType.scalyDry:
        return Icons.layers_outlined;
      case SkinConcernType.blisterPustule:
        return Icons.bubble_chart_outlined;
      case SkinConcernType.general:
        return Icons.healing_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case SkinConcernType.skinCancerRisk:
        return const Color(0xFFB83B3B);
      case SkinConcernType.wart:
        return const Color(0xFF3E7A67);
      case SkinConcernType.bruise:
        return const Color(0xFF5D54A4);
      case SkinConcernType.facialSpot:
        return const Color(0xFFC87D32);
      case SkinConcernType.rashRedness:
        return const Color(0xFFD65A6F);
      case SkinConcernType.molePigment:
        return const Color(0xFF7A4B3A);
      case SkinConcernType.scalyDry:
        return const Color(0xFF5E7E95);
      case SkinConcernType.blisterPustule:
        return const Color(0xFFD9822B);
      case SkinConcernType.general:
        return const Color(0xFF0B6E6E);
    }
  }

  /// Highlighted 4 dedicated dermatological sub-modules surfaced as quick cards.
  static const List<SkinConcernType> featuredSubModules = [
    SkinConcernType.skinCancerRisk,
    SkinConcernType.wart,
    SkinConcernType.bruise,
    SkinConcernType.facialSpot,
  ];

  /// Additional general skin concern chips shown below the 4 featured cards.
  static const List<SkinConcernType> generalConcerns = [
    SkinConcernType.rashRedness,
    SkinConcernType.scalyDry,
    SkinConcernType.blisterPustule,
    SkinConcernType.molePigment,
    SkinConcernType.general,
  ];
}

/// Optional accompanying symptoms that raise dermatological triage awareness.
enum SkinSymptomFlag {
  itching,
  painOrWarmth,
  rapidChange,
  bleedingOrOozing,
  spreading,
  fever,
  nonHealingSore,
  over6mmOrIrregular,
  spontaneousNoTrauma,
  roughBlackDots,
  sunOrHormoneHistory,
}

extension SkinSymptomFlagX on SkinSymptomFlag {
  String get label {
    switch (this) {
      case SkinSymptomFlag.itching:
        return 'Kaşıntı';
      case SkinSymptomFlag.painOrWarmth:
        return 'Ağrı / Isı artışı';
      case SkinSymptomFlag.rapidChange:
        return 'Hızlı büyüme / şekil değişimi';
      case SkinSymptomFlag.bleedingOrOozing:
        return 'Kanama / Sızıntı / İltihap';
      case SkinSymptomFlag.spreading:
        return 'Hızla yayılıyor';
      case SkinSymptomFlag.fever:
        return 'Ateş eşlik ediyor';
      case SkinSymptomFlag.nonHealingSore:
        return '4+ haftadır iyileşmeyen yara/kabuk';
      case SkinSymptomFlag.over6mmOrIrregular:
        return '6 mm üstü veya düzensiz kenar';
      case SkinSymptomFlag.spontaneousNoTrauma:
        return 'Darbe olmadan kendiliğinden çıktı';
      case SkinSymptomFlag.roughBlackDots:
        return 'Pütürlü yüzey / küçük siyah noktalar';
      case SkinSymptomFlag.sunOrHormoneHistory:
        return 'Güneş, hormon veya akne sonrası leke';
    }
  }

  bool get isHighPriority {
    switch (this) {
      case SkinSymptomFlag.painOrWarmth:
      case SkinSymptomFlag.rapidChange:
      case SkinSymptomFlag.bleedingOrOozing:
      case SkinSymptomFlag.spreading:
      case SkinSymptomFlag.fever:
      case SkinSymptomFlag.nonHealingSore:
      case SkinSymptomFlag.over6mmOrIrregular:
      case SkinSymptomFlag.spontaneousNoTrauma:
        return true;
      case SkinSymptomFlag.itching:
      case SkinSymptomFlag.roughBlackDots:
      case SkinSymptomFlag.sunOrHormoneHistory:
        return false;
    }
  }

  /// Returns the most relevant symptoms ordered first for a chosen sub-module.
  static List<SkinSymptomFlag> orderedFor(SkinConcernType concern) {
    switch (concern) {
      case SkinConcernType.skinCancerRisk:
      case SkinConcernType.molePigment:
        return const [
          SkinSymptomFlag.rapidChange,
          SkinSymptomFlag.over6mmOrIrregular,
          SkinSymptomFlag.bleedingOrOozing,
          SkinSymptomFlag.nonHealingSore,
          SkinSymptomFlag.itching,
          SkinSymptomFlag.sunOrHormoneHistory,
        ];
      case SkinConcernType.wart:
        return const [
          SkinSymptomFlag.roughBlackDots,
          SkinSymptomFlag.painOrWarmth,
          SkinSymptomFlag.spreading,
          SkinSymptomFlag.bleedingOrOozing,
          SkinSymptomFlag.rapidChange,
          SkinSymptomFlag.nonHealingSore,
        ];
      case SkinConcernType.bruise:
        return const [
          SkinSymptomFlag.spontaneousNoTrauma,
          SkinSymptomFlag.painOrWarmth,
          SkinSymptomFlag.spreading,
          SkinSymptomFlag.bleedingOrOozing,
          SkinSymptomFlag.fever,
        ];
      case SkinConcernType.facialSpot:
        return const [
          SkinSymptomFlag.sunOrHormoneHistory,
          SkinSymptomFlag.rapidChange,
          SkinSymptomFlag.over6mmOrIrregular,
          SkinSymptomFlag.bleedingOrOozing,
          SkinSymptomFlag.nonHealingSore,
          SkinSymptomFlag.itching,
        ];
      case SkinConcernType.rashRedness:
      case SkinConcernType.scalyDry:
      case SkinConcernType.blisterPustule:
      case SkinConcernType.general:
        return const [
          SkinSymptomFlag.itching,
          SkinSymptomFlag.painOrWarmth,
          SkinSymptomFlag.rapidChange,
          SkinSymptomFlag.bleedingOrOozing,
          SkinSymptomFlag.spreading,
          SkinSymptomFlag.fever,
        ];
    }
  }
}

class SkinCheckContext {
  const SkinCheckContext({
    this.concernType = SkinConcernType.general,
    this.symptoms = const {},
    this.bodyArea,
  });

  final SkinConcernType concernType;
  final Set<SkinSymptomFlag> symptoms;
  final String? bodyArea;

  bool get hasInfectionRedFlag =>
      symptoms.contains(SkinSymptomFlag.fever) ||
      symptoms.contains(SkinSymptomFlag.bleedingOrOozing) ||
      (symptoms.contains(SkinSymptomFlag.painOrWarmth) &&
          symptoms.contains(SkinSymptomFlag.spreading));

  bool get hasAbcdeRedFlag =>
      symptoms.contains(SkinSymptomFlag.rapidChange) ||
      symptoms.contains(SkinSymptomFlag.bleedingOrOozing) ||
      symptoms.contains(SkinSymptomFlag.nonHealingSore) ||
      symptoms.contains(SkinSymptomFlag.over6mmOrIrregular);

  bool get hasUnexplainedBruiseRedFlag =>
      symptoms.contains(SkinSymptomFlag.spontaneousNoTrauma);
}

class SkinAbcdeGuide {
  SkinAbcdeGuide._();

  static const List<({String letter, String title, String detail})> items = [
    (
      letter: 'A',
      title: 'Asimetri',
      detail: 'Benin bir yarısı diğer yarısıyla şekil veya renk olarak uyuşmuyorsa.',
    ),
    (
      letter: 'B',
      title: 'Border (Sınır)',
      detail: 'Kenarlar düzensiz, girintili çıkıntılı veya bulanık görünüyorsa.',
    ),
    (
      letter: 'C',
      title: 'Color (Renk)',
      detail: 'Tek lezyon içinde siyah, kahverengi, kırmızı, beyaz gibi birden fazla ton varsa.',
    ),
    (
      letter: 'D',
      title: 'Diameter (Çap)',
      detail: 'Çapı 6 mm\'den (yaklaşık bir kurşun kalem silgisi) büyükse.',
    ),
    (
      letter: 'E',
      title: 'Evolving (Değişim)',
      detail: 'Haftalar/aylar içinde boyut, renk, kabarıklık değişiyor, kanıyor veya 4 haftadır iyileşmiyorsa.',
    ),
  ];
}

class SkinBruiseGuide {
  SkinBruiseGuide._();

  static const List<({Color color, String stage, String detail})> stages = [
    (
      color: Color(0xFFA83A5E),
      stage: '0–2 Gün (Taze Evre)',
      detail: 'Kırmızımsı veya koyu mor ton. Darbe sonrası ilk 24–48 saatte soğuk kompres şişliği azaltabilir.',
    ),
    (
      color: Color(0xFF4F467A),
      stage: '3–6 Gün (Orta Evre)',
      detail: 'Koyu mavi-mor veya lacivert ton. Hemoglobin parçalanmaya başlar.',
    ),
    (
      color: Color(0xFF8C9A4B),
      stage: '7–14 Gün (İyileşme Evresi)',
      detail: 'Yeşilimsi, sarı veya açık kahverengi ton. Genellikle 2 hafta içinde solarak kaybolur.',
    ),
  ];
}

class SkinWartGuide {
  SkinWartGuide._();

  static const List<String> tips = [
    'Yaygın siğiller genellikle pütürlü/karnabahar benzeri yüzeye sahiptir ve ortasında küçük siyah noktalar (pıhtılaşmış kılcal damarlar) görülebilir.',
    'Yüz, genital bölge, tırnak çevresi veya diyabet/dolaşım sorununuz varsa kesinlikle reçetesiz siğil asidi/bandı kullanmayın; dermatoloğa başvurun.',
    'Siğili koparmak, törpülemek veya tırnak makasını ortak kullanmak virüsün (HPV) yayılmasına yol açabilir.',
  ];
}
