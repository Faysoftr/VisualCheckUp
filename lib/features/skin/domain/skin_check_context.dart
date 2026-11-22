/// Primary visual presentation selected by the user before skin capture.
enum SkinConcernType {
  rashRedness,
  molePigment,
  scalyDry,
  blisterPustule,
  general,
}

extension SkinConcernTypeX on SkinConcernType {
  String get label {
    switch (this) {
      case SkinConcernType.rashRedness:
        return 'Kızarıklık / Döküntü';
      case SkinConcernType.molePigment:
        return 'Ben / Koyu Leke';
      case SkinConcernType.scalyDry:
        return 'Pullu / Kuru Plak';
      case SkinConcernType.blisterPustule:
        return 'Kabarcık / Sivilce / Şişlik';
      case SkinConcernType.general:
        return 'Genel Cilt Kontrolü';
    }
  }

  String get helperText {
    switch (this) {
      case SkinConcernType.rashRedness:
        return 'Egzama, kontakt dermatit, ürtiker veya tahriş ön farkındalığı';
      case SkinConcernType.molePigment:
        return 'ABCDE kriterlerine göre pigment, renk dağılımı ve simetri ön bakışı';
      case SkinConcernType.scalyDry:
        return 'Kuruluk, sedef benzeri pullanma veya yüzeysel mantar ön kontrolü';
      case SkinConcernType.blisterPustule:
        return 'Akne, folikülit, kabarcık veya ikincil enfeksiyon ipuçları';
      case SkinConcernType.general:
        return 'Cilt yüzeyinde kızarıklık, leke veya ton farklılığı taraması';
    }
  }
}

/// Optional accompanying symptoms that raise dermatological triage awareness.
enum SkinSymptomFlag {
  itching,
  painOrWarmth,
  rapidChange,
  bleedingOrOozing,
  spreading,
  fever,
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
    }
  }

  bool get isHighPriority {
    switch (this) {
      case SkinSymptomFlag.painOrWarmth:
      case SkinSymptomFlag.rapidChange:
      case SkinSymptomFlag.bleedingOrOozing:
      case SkinSymptomFlag.spreading:
      case SkinSymptomFlag.fever:
        return true;
      case SkinSymptomFlag.itching:
        return false;
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
      symptoms.contains(SkinSymptomFlag.bleedingOrOozing);
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
      detail: 'Haftalar/aylar içinde boyut, renk, kabarıklık değişiyor veya kanıyorsa.',
    ),
  ];
}
