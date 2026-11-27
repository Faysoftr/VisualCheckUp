import 'package:flutter/material.dart';

enum SobrietyTrackType {
  smoking,
  alcohol,
}

extension SobrietyTrackTypeX on SobrietyTrackType {
  String get title {
    switch (this) {
      case SobrietyTrackType.smoking:
        return 'Sigarayı Bırakma';
      case SobrietyTrackType.alcohol:
        return 'Alkolü Bırakma';
    }
  }

  IconData get icon {
    switch (this) {
      case SobrietyTrackType.smoking:
        return Icons.smoke_free_rounded;
      case SobrietyTrackType.alcohol:
        return Icons.no_drinks_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case SobrietyTrackType.smoking:
        return const Color(0xFF0D9488);
      case SobrietyTrackType.alcohol:
        return const Color(0xFF7C3AED);
    }
  }
}

class SobrietyState {
  const SobrietyState({
    this.smokeQuitAt,
    this.alcoholQuitAt,
    this.dailyCigarettes = 20,
    this.packPriceTry = 75.0,
    this.dailyAlcoholCostTry = 120.0,
    this.showOnProfile = true,
  });

  final DateTime? smokeQuitAt;
  final DateTime? alcoholQuitAt;
  final int dailyCigarettes;
  final double packPriceTry;
  final double dailyAlcoholCostTry;
  final bool showOnProfile;

  bool get isSmokingActive => smokeQuitAt != null;
  bool get isAlcoholActive => alcoholQuitAt != null;
  bool get isAnyActive => isSmokingActive || isAlcoholActive;

  /// Average daily money spent on cigarettes (based on 20 cigarettes per pack).
  double get dailySmokeSpendTry =>
      ((dailyCigarettes.clamp(1, 100)) / 20.0) * packPriceTry.clamp(0.0, 5000.0);

  double get monthlySmokeSpendTry => dailySmokeSpendTry * 30.0;

  double get monthlyAlcoholSpendTry =>
      dailyAlcoholCostTry.clamp(0.0, 10000.0) * 30.0;

  double get combinedDailySpendTry =>
      dailySmokeSpendTry + dailyAlcoholCostTry.clamp(0.0, 10000.0);

  double get combinedMonthlySpendTry => combinedDailySpendTry * 30.0;

  Duration smokeElapsedAt(DateTime now) {
    if (smokeQuitAt == null) return Duration.zero;
    final diff = now.difference(smokeQuitAt!);
    return diff.isNegative ? Duration.zero : diff;
  }

  Duration alcoholElapsedAt(DateTime now) {
    if (alcoholQuitAt == null) return Duration.zero;
    final diff = now.difference(alcoholQuitAt!);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Active day number (1-indexed once started: Day 1 starts immediately on Day 0..24h).
  int smokeCurrentDayNumber(DateTime now) {
    if (!isSmokingActive) return 0;
    return smokeElapsedAt(now).inDays + 1;
  }

  int alcoholCurrentDayNumber(DateTime now) {
    if (!isAlcoholActive) return 0;
    return alcoholElapsedAt(now).inDays + 1;
  }

  int maxActiveDayNumber(DateTime now) {
    final s = smokeCurrentDayNumber(now);
    final a = alcoholCurrentDayNumber(now);
    return s > a ? s : a;
  }

  double smokeMoneySavedAt(DateTime now) {
    if (!isSmokingActive) return 0.0;
    final minutes = smokeElapsedAt(now).inMinutes;
    return (minutes / 1440.0) * dailySmokeSpendTry;
  }

  double alcoholMoneySavedAt(DateTime now) {
    if (!isAlcoholActive) return 0.0;
    final minutes = alcoholElapsedAt(now).inMinutes;
    return (minutes / 1440.0) * dailyAlcoholCostTry;
  }

  double totalMoneySavedAt(DateTime now) =>
      smokeMoneySavedAt(now) + alcoholMoneySavedAt(now);

  /// Calculates how much money the user saved TODAY ("Bugün şu kadar kazandınız").
  double todayMoneySavedAt(DateTime now) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    double total = 0.0;
    if (smokeQuitAt != null && !smokeQuitAt!.isAfter(now)) {
      if (smokeQuitAt!.isBefore(startOfToday)) {
        total += dailySmokeSpendTry;
      } else {
        final mins = now.difference(smokeQuitAt!).inMinutes.clamp(1, 1440);
        total += (mins / 1440.0) * dailySmokeSpendTry;
      }
    }
    if (alcoholQuitAt != null && !alcoholQuitAt!.isAfter(now)) {
      if (alcoholQuitAt!.isBefore(startOfToday)) {
        total += dailyAlcoholCostTry;
      } else {
        final mins = now.difference(alcoholQuitAt!).inMinutes.clamp(1, 1440);
        total += (mins / 1440.0) * dailyAlcoholCostTry;
      }
    }
    return total;
  }

  int unsmokedCigarettesAt(DateTime now) {
    if (!isSmokingActive) return 0;
    final daysFraction = smokeElapsedAt(now).inMinutes / 1440.0;
    return (daysFraction * dailyCigarettes).floor();
  }

  /// Scientifically estimated life expectancy regained:
  /// - ~11 minutes per unsmoked cigarette (BMJ clinical longevity estimate)
  /// - ~45 minutes per alcohol-free 24h day (hepatic & cardiovascular risk reduction)
  Duration lifeRegainedAt(DateTime now) {
    double gainedMinutes = 0.0;
    if (isSmokingActive) {
      final cigsAvoided =
          (smokeElapsedAt(now).inMinutes / 1440.0) * dailyCigarettes;
      gainedMinutes += cigsAvoided * 11.0;
    }
    if (isAlcoholActive) {
      final alcDays = alcoholElapsedAt(now).inMinutes / 1440.0;
      gainedMinutes += alcDays * 45.0;
    }
    return Duration(minutes: gainedMinutes.round());
  }

  static String formatLifeRegained(Duration d) {
    if (d.inMinutes <= 0) return '0 dk';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    if (days > 0) {
      return '$days Gün $hours Saat';
    }
    if (hours > 0) {
      return '$hours Saat $mins Dk';
    }
    return '$mins Dakika';
  }

  static String formatTry(double amount) {
    if (amount >= 1000) {
      final whole = amount.round();
      final str = whole.toString();
      final buf = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
        buf.write(str[i]);
      }
      return '₺$buf';
    }
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  SobrietyState copyWith({
    DateTime? smokeQuitAt,
    bool clearSmoke = false,
    DateTime? alcoholQuitAt,
    bool clearAlcohol = false,
    int? dailyCigarettes,
    double? packPriceTry,
    double? dailyAlcoholCostTry,
    bool? showOnProfile,
  }) {
    return SobrietyState(
      smokeQuitAt: clearSmoke ? null : (smokeQuitAt ?? this.smokeQuitAt),
      alcoholQuitAt:
          clearAlcohol ? null : (alcoholQuitAt ?? this.alcoholQuitAt),
      dailyCigarettes: dailyCigarettes ?? this.dailyCigarettes,
      packPriceTry: packPriceTry ?? this.packPriceTry,
      dailyAlcoholCostTry: dailyAlcoholCostTry ?? this.dailyAlcoholCostTry,
      showOnProfile: showOnProfile ?? this.showOnProfile,
    );
  }

  Map<String, dynamic> toJson() => {
        'smokeQuitAt': smokeQuitAt?.toIso8601String() ?? '',
        'alcoholQuitAt': alcoholQuitAt?.toIso8601String() ?? '',
        'dailyCigarettes': dailyCigarettes,
        'packPriceTry': packPriceTry,
        'dailyAlcoholCostTry': dailyAlcoholCostTry,
        'showOnProfile': showOnProfile,
      };

  factory SobrietyState.fromJson(Map<String, dynamic> json) {
    DateTime? parseOpt(dynamic v) {
      if (v is String && v.trim().isNotEmpty) {
        return DateTime.tryParse(v.trim());
      }
      return null;
    }

    return SobrietyState(
      smokeQuitAt: parseOpt(json['smokeQuitAt']),
      alcoholQuitAt: parseOpt(json['alcoholQuitAt']),
      dailyCigarettes: (json['dailyCigarettes'] as num?)?.toInt() ?? 20,
      packPriceTry: (json['packPriceTry'] as num?)?.toDouble() ?? 75.0,
      dailyAlcoholCostTry:
          (json['dailyAlcoholCostTry'] as num?)?.toDouble() ?? 120.0,
      showOnProfile: (json['showOnProfile'] as bool?) ?? true,
    );
  }
}

class HarmInfoItem {
  const HarmInfoItem({
    required this.organTitle,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String organTitle;
  final String description;
  final IconData icon;
  final Color color;
}

class BodyRecoveryMilestone {
  const BodyRecoveryMilestone({
    required this.dayNumber,
    required this.dayLabel,
    required this.title,
    required this.smokingChange,
    required this.alcoholChange,
    required this.requiredHours,
  });

  final int dayNumber;
  final String dayLabel;
  final String title;
  final String smokingChange;
  final String alcoholChange;
  final int requiredHours;

  double progressFor(Duration elapsed) {
    if (requiredHours <= 0) return 1.0;
    final hours = elapsed.inMinutes / 60.0;
    return (hours / requiredHours).clamp(0.0, 1.0);
  }

  bool isCompletedFor(Duration elapsed) => progressFor(elapsed) >= 1.0;
}

class SobrietyTipItem {
  const SobrietyTipItem({
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
}

class SobrietyKnowledgeBase {
  SobrietyKnowledgeBase._();

  static const List<HarmInfoItem> smokingHarms = [
    HarmInfoItem(
      organTitle: 'Akciğerler & Solunum Yolu',
      description:
          'Sigara dumanındaki 7.000+ kimyasal ve katran, akciğer hava keseciklerini (alveolleri) tahrip ederek KOAH, kronik bronşit ve nefes darlığına yol açar.',
      icon: Icons.air_rounded,
      color: Color(0xFF0284C7),
    ),
    HarmInfoItem(
      organTitle: 'Kalp & Damar Sistemi',
      description:
          'Nikotin damarları büzüştürür, karbonmonoksit kandaki oksijeni düşürür. Kalp krizi, damar tıkanıklığı ve hipertansiyon riskini 2 ila 4 kat artırır.',
      icon: Icons.favorite_rounded,
      color: Color(0xFFE11D48),
    ),
    HarmInfoItem(
      organTitle: 'Beyin & İnme Riski',
      description:
          'Beyin damarlarında plak oluşumunu hızlandırarak pıhtı ve felç (inme) riskini yükseltir; odaklanma ve uyku kalitesini bozar.',
      icon: Icons.psychology_rounded,
      color: Color(0xFF7C3AED),
    ),
    HarmInfoItem(
      organTitle: 'Kanser & Hücresel Hasar',
      description:
          'Başta akciğer, gırtlak, ağız, yemek borusu, pankreas ve mesane olmak üzere 15’ten fazla kanser türünün birincil nedenidir.',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFD97706),
    ),
    HarmInfoItem(
      organTitle: 'Cilt, Diş & Erken Yaşlanma',
      description:
          'Kolajen üretimini yıkarak ciltte erken kırışıklık, solgunluk, diş eti çekilmesi ve tırnak/diş sararmasına neden olur.',
      icon: Icons.face_retouching_natural_rounded,
      color: Color(0xFF0D9488),
    ),
  ];

  static const List<HarmInfoItem> alcoholHarms = [
    HarmInfoItem(
      organTitle: 'Karaciğer Yağlanması & Siroz',
      description:
          'Karaciğer alkolü parçalamak için aşırı mesai yapar; zamanla yağlanma, alkolik hepatit, fibrozis ve geri dönüşü zor siroz gelişir.',
      icon: Icons.healing_rounded,
      color: Color(0xFFD97706),
    ),
    HarmInfoItem(
      organTitle: 'Beyin Hücreleri & Ruh Hali',
      description:
          'Nörotransmitter dengesini bozarak unutkanlık, anksiyete, depresif döngüler, refleks yavaşlaması ve derin REM uykusu kaybına yol açar.',
      icon: Icons.psychology_alt_rounded,
      color: Color(0xFF7C3AED),
    ),
    HarmInfoItem(
      organTitle: 'Kalp Kası & Yüksek Tansiyon',
      description:
          'Düzenli alkol tüketimi kan basıncını kronik olarak yükseltir, ritim bozukluğu (aritmi) ve kalp kası zayıflamasına zemin hazırlar.',
      icon: Icons.monitor_heart_rounded,
      color: Color(0xFFE11D48),
    ),
    HarmInfoItem(
      organTitle: 'Mide, Pankreas & Metabolizma',
      description:
          'Gastrit, reflü, ülser ve hayati risk taşıyan pankreatite neden olur; yüksek boş kalorisiyle insülin direnci ve göbek çevresi yağlanmasını artırır.',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF059669),
    ),
    HarmInfoItem(
      organTitle: 'Bağışıklık & Hücre Onarımı',
      description:
          'Beyaz kan hücrelerinin savunma gücünü baskılar, vücudun su ve elektrolit dengesini bozarak enfeksiyonlara açık hale getirir.',
      icon: Icons.shield_outlined,
      color: Color(0xFF2563EB),
    ),
  ];

  /// Complete day-by-day physiological recovery entries.
  /// IMPORTANT: Future days are NEVER shown ahead of time; only days `<= activeDay`
  /// are progressively revealed day by day as the user's streak advances!
  static const List<BodyRecoveryMilestone> dayByDayMilestones = [
    BodyRecoveryMilestone(
      dayNumber: 1,
      dayLabel: 'Gün 1',
      title: 'Oksijen ve Kan Şekeri Dengeleniyor',
      smokingChange:
          'Vücutta nabız ve tansiyon normale inmeye başladı; kandaki zehirli karbonmonoksit gazı yarı yarıya temizlendi ve hücrelere giden oksijen arttı.',
      alcoholChange:
          'Karaciğer kandaki alkol kalıntılarını temizledi, kan şekeri dalgalanmaları duruldu ve hücreler su dengesini yeniden kurmaya başladı.',
      requiredHours: 24,
    ),
    BodyRecoveryMilestone(
      dayNumber: 2,
      dayLabel: 'Gün 2',
      title: 'Sinir Uçları Canlanıyor, Tat & Koku Keskinleşiyor',
      smokingChange:
          'Nikotin vücuttan büyük ölçüde atıldı. Yıpranan sinir uçları kendini onarmaya başladı; yemeklerin tadı ve kokular daha net hissediliyor.',
      alcoholChange:
          'Mide asidi ve sindirim mukozası yatıştı; baş ağrısı, çarpıntı ve sisli zihin hissi dağılmaya başladı.',
      requiredHours: 48,
    ),
    BodyRecoveryMilestone(
      dayNumber: 3,
      dayLabel: 'Gün 3',
      title: 'Bronşlar Gevşiyor, Nefes Kapasitesi Açılıyor',
      smokingChange:
          'Akciğerlerdeki bronş tüpleri gevşedi, nefes alıp vermek belirgin biçimde rahatladı ve günlük fiziksel enerjiniz yükseldi.',
      alcoholChange:
          'Böbrek ve elektrolit dengesi toparlandı; yüzdeki ve vücuttaki alkol ödemi inmeye başladı.',
      requiredHours: 72,
    ),
    BodyRecoveryMilestone(
      dayNumber: 4,
      dayLabel: 'Gün 4',
      title: 'Fiziksel Nikotin Çekilmesi Geriliyor & Zihin Berraklaşıyor',
      smokingChange:
          'Kandaki nikotin tamamen sıfırlandı; beyin reseptörleri nikotinsiz düzene uyum sağlamaya başladı.',
      alcoholChange:
          'Karaciğer detoks enzimleri rahatladı, gün içi odaklanma ve dikkat süreniz gözle görülür şekilde arttı.',
      requiredHours: 96,
    ),
    BodyRecoveryMilestone(
      dayNumber: 5,
      dayLabel: 'Gün 5',
      title: 'Kılcal Kan Dolaşımı ve REM Uykusu Güçleniyor',
      smokingChange:
          'El ve ayak uçlarındaki kılcal kan dolaşımı hızlandı; sabah yorgunluğu azalmaya başladı.',
      alcoholChange:
          'Kesintili uyku yerine gerçek dinlendirici REM uykusu geri döndü; sabahları çok daha dinç uyanıyorsunuz.',
      requiredHours: 120,
    ),
    BodyRecoveryMilestone(
      dayNumber: 6,
      dayLabel: 'Gün 6',
      title: 'Antioksidan Savunması ve Mide Onarımı',
      smokingChange:
          'Kandaki koruyucu antioksidan ve C vitamini seviyeleri yükselmeye başladı; boğazdaki tahriş yatıştı.',
      alcoholChange:
          'Mide duvarındaki hassasiyet ve reflü eğilimi azaldı, sindirim sistemi düzenli ritmine kavuştu.',
      requiredHours: 144,
    ),
    BodyRecoveryMilestone(
      dayNumber: 7,
      dayLabel: 'Gün 7 (1. Hafta)',
      title: 'İlk Hafta Zaferi: Hücresel Yenilenme',
      smokingChange:
          'Akciğerlerdeki mukus temizleyici tüycükler (siliyalar) yeniden canlandı; akciğerler kendi kendini temizlemeye başladı.',
      alcoholChange:
          'Karaciğer yağlanması gerileme sürecine girdi, cildiniz nemini geri kazandı ve binlerce boş kaloriden kurtuldunuz.',
      requiredHours: 168,
    ),
    BodyRecoveryMilestone(
      dayNumber: 10,
      dayLabel: 'Gün 10',
      title: 'Diş Eti, Cilt Dolaşımı ve Ruh Hali Dengesi',
      smokingChange:
          'Diş etlerine ve yüz cildine giden kan akışı normale döndü; solgun görünüm yerini canlılığa bırakıyor.',
      alcoholChange:
          'Serotonin ve dopamin dengesi toparlanıyor; ani sinirlilik ve kaygı dalgaları belirgin biçimde azaldı.',
      requiredHours: 240,
    ),
    BodyRecoveryMilestone(
      dayNumber: 14,
      dayLabel: 'Gün 14 (2. Hafta)',
      title: 'Yürüyüş Kondisyonu ve Damar Esnekliği Artıyor',
      smokingChange:
          'Damar esnekliği ve kalp pompası verimi iyileşti; merdiven çıkarken veya yürürken nefes nefese kalma azaldı.',
      alcoholChange:
          'Kan basıncı (tansiyon) ve kalp ritmi daha sağlıklı ve dengeli bir çizgiye oturdu.',
      requiredHours: 336,
    ),
    BodyRecoveryMilestone(
      dayNumber: 21,
      dayLabel: 'Gün 21 (3. Hafta)',
      title: 'Yeni Alışkanlık Sinir Ağları Kalıcılaşıyor',
      smokingChange:
          'Beyindeki bağımlılık tetikleyicileri zayıfladı; günlük rutinleriniz sigarasız olarak otomatikleşmeye başladı.',
      alcoholChange:
          'Bağışıklık hücreleriniz güçlendi, bel çevresi ödemi ve karaciğer yükü belirgin biçimde hafifledi.',
      requiredHours: 504,
    ),
    BodyRecoveryMilestone(
      dayNumber: 30,
      dayLabel: 'Gün 30 (1. Ay)',
      title: '1 Aylık Dönüşüm: Temiz Akciğer & Dinç Karaciğer',
      smokingChange:
          'Akciğer siliyaları hızla yenilendi, balgam ve kronik öksürük ciddi oranda azaldı, enfeksiyonlara karşı direnç arttı.',
      alcoholChange:
          'Karaciğer yağ oranı %15-20 oranında azaldı; zihinsel berraklık, hafıza ve uyku kalitesi zirveye çıktı.',
      requiredHours: 720,
    ),
    BodyRecoveryMilestone(
      dayNumber: 60,
      dayLabel: 'Gün 60 (2. Ay)',
      title: '2 Aylık Güçlenme: Cilt Kolajeni & Metabolik Denge',
      smokingChange:
          'Cilt elastikiyeti koruma altına girdi, hırıltılı solunum geriledi ve egzersiz kapasiteniz belirgin ölçüde yükseldi.',
      alcoholChange:
          'İnsülin duyarlılığı ve kan yağları (trigliserit) çok daha sağlıklı seviyelere indi.',
      requiredHours: 1440,
    ),
    BodyRecoveryMilestone(
      dayNumber: 90,
      dayLabel: 'Gün 90 (3. Ay)',
      title: 'Akciğer Kapasitesinde %30’a Varan Artış',
      smokingChange:
          'Akciğer fonksiyonları %30’a kadar güçlendi; doğal dopamin dengesi tamamen geri kazanıldı.',
      alcoholChange:
          'Karaciğer enzimleri (ALT/AST) büyük oranda ideal aralığa geriledi, bağışıklık ve hormon dengesi güçlendi.',
      requiredHours: 2160,
    ),
    BodyRecoveryMilestone(
      dayNumber: 180,
      dayLabel: 'Gün 180 (6. Ay)',
      title: 'Yarım Yıllık Özgürlük ve Kalıcı Kondisyon',
      smokingChange:
          'Hava yollarındaki kronik iltihap büyük ölçüde söndü; stres anlarında sigarasız baş etme refleksi kalıcı hale geldi.',
      alcoholChange:
          'Kalp kası, tansiyon ve metabolizma uzun vadeli koruma altına girdi.',
      requiredHours: 4320,
    ),
    BodyRecoveryMilestone(
      dayNumber: 365,
      dayLabel: 'Gün 365 (1. Yıl)',
      title: 'Kalp Krizi Riski Yarı Yarıya Azaldı! 🏆',
      smokingChange:
          'Koroner kalp hastalığı ve kalp krizi riskiniz, içmeye devam eden birine göre tam %50 oranında azaldı!',
      alcoholChange:
          'Karaciğer hasarı, hipertansiyon ve alkole bağlı metabolik hastalık riskleriniz dramatik biçimde düştü!',
      requiredHours: 8760,
    ),
  ];

  /// Generates a specific day's body recovery entry for ANY day `1..N`, so every
  /// passing day (`Gün 1`, `Gün 2`, ..., `Gün 8`, `Gün 9`, ...) has its own live card entry!
  static BodyRecoveryMilestone changeForExactDay(int day) {
    final clamped = day < 1 ? 1 : day;
    for (final m in dayByDayMilestones) {
      if (m.dayNumber == clamped) return m;
    }
    // Find the most recent milestone <= clamped to contextualize intermediate days
    BodyRecoveryMilestone latest = dayByDayMilestones.first;
    for (final m in dayByDayMilestones) {
      if (m.dayNumber <= clamped) {
        latest = m;
      } else {
        break;
      }
    }
    return BodyRecoveryMilestone(
      dayNumber: clamped,
      dayLabel: 'Gün $clamped',
      title: '$clamped. Günde Hücresel İyileşme Devam Ediyor',
      smokingChange:
          '${latest.smokingChange} ($clamped. günde akciğer dokusu ve damar esnekliği her saat daha da güçleniyor.)',
      alcoholChange:
          '${latest.alcoholChange} ($clamped. günde karaciğer onarımı ve sinir sistemi dengesi istikrarla ilerliyor.)',
      requiredHours: clamped * 24,
    );
  }

  /// Returns ONLY the day-by-day entries that the user has ACTUALLY reached (`1..activeDay`),
  /// ordered newest day first (`Gün N` down to `Gün 1`), NEVER revealing future days!
  static List<BodyRecoveryMilestone> unlockedDailyFeed(int activeDay) {
    if (activeDay <= 0) return const [];
    final list = <BodyRecoveryMilestone>[];
    // For the most recent 14 days, include every single consecutive day; for older history, include milestone days + recent days so the list stays crisp and fast!
    for (int d = activeDay; d >= 1; d--) {
      final isRecent = (activeDay - d) < 14;
      final isLandmark = dayByDayMilestones.any((m) => m.dayNumber == d);
      if (isRecent || isLandmark) {
        list.add(changeForExactDay(d));
      }
    }
    return list;
  }

  static const List<SobrietyTipItem> recommendations = [
    SobrietyTipItem(
      title: '5 Dakika Kuralı & 4-7-8 Nefesi',
      body:
          'Şiddetli sigara veya alkol isteği ortalama 3-5 dakika sürer. İstek geldiğinde saate bakın, 4 sn nefes alıp 7 sn tutun ve 8 sn’de verin; dalga kendiliğinden geçecektir.',
      icon: Icons.self_improvement_rounded,
      accentColor: Color(0xFF0D9488),
    ),
    SobrietyTipItem(
      title: 'Büyük Bir Bardak Su & Doğal Ferahlık',
      body:
          'Ağız alışkanlığı veya istek anında yudum yudum soğuk su için; tarçın çubuğu, karanfil veya şekersiz naneli sakız sinir uçlarını hızla yatıştırır.',
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF0284C7),
    ),
    SobrietyTipItem(
      title: 'Kazanılan Parayı Görünür Kılın',
      body:
          'Sigara ve alkole vermediğiniz günlük parayı ayrı bir birikim hesabına aktarın ve ay sonunda kendinize sağlıklı bir ödül alın.',
      icon: Icons.savings_rounded,
      accentColor: Color(0xFF16A34A),
    ),
    SobrietyTipItem(
      title: 'Tetikleyici Rutinleri Kırın',
      body:
          'Yemek sonrası veya kahve yanındaki eski alışkanlığı kırmak için kahveyi bitki çayıyla değiştirin veya yemekten hemen sonra 10 dakikalık kısa bir yürüyüşe çıkın.',
      icon: Icons.directions_walk_rounded,
      accentColor: Color(0xFFD97706),
    ),
    SobrietyTipItem(
      title: 'Ücretsiz Uzman Destek Hatları',
      body:
          'Zorlandığınız her an ALO 171 Sigara Bırakma Danışma Hattı veya Yeşilay YEDAM (115) üzerinden ücretsiz psikolojik ve tıbbi destek alabilirsiniz.',
      icon: Icons.support_agent_rounded,
      accentColor: Color(0xFF7C3AED),
    ),
  ];
}
