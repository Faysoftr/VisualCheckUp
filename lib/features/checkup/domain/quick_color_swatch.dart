import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// A single curated color swatch for camera-free rapid visual logging
/// (urine hydration chart and stool awareness chart).
class QuickColorSwatch {
  const QuickColorSwatch({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.riskLevel,
    required this.summaryDetail,
    required this.observations,
    required this.recommendations,
    this.warningFlags = const [],
    this.canBeBenignFoodOrMed = false,
    this.referenceFindingId,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final RiskLevel riskLevel;
  final String summaryDetail;
  final List<String> observations;
  final List<String> recommendations;
  final List<String> warningFlags;
  final bool canBeBenignFoodOrMed;
  final String? referenceFindingId;
}

class QuickContextOption {
  const QuickContextOption({
    required this.id,
    required this.label,
    required this.note,
    this.isFoodOrMedication = false,
    this.isRedFlagSymptom = false,
  });

  final String id;
  final String label;
  final String note;
  final bool isFoodOrMedication;
  final bool isRedFlagSymptom;
}

/// Standard gastroenterology Bristol Stool Form Scale (Types 1–7).
class BristolStoolType {
  const BristolStoolType({
    required this.typeNumber,
    required this.title,
    required this.detail,
    required this.clinicalCue,
    this.isAbnormal = false,
  });

  final int typeNumber;
  final String title;
  final String detail;
  final String clinicalCue;
  final bool isAbnormal;
}

class QuickColorCardCatalog {
  QuickColorCardCatalog._();

  static const List<BristolStoolType> bristolScale = [
    BristolStoolType(
      typeNumber: 1,
      title: 'Tip 1 • Sert Topaklar',
      detail: 'Ayrı sert topaklar (fındık gibi)',
      clinicalCue: 'Belirgin kabızlık — su ve lif alımını artırın.',
      isAbnormal: true,
    ),
    BristolStoolType(
      typeNumber: 2,
      title: 'Tip 2 • Topaklı Sert',
      detail: 'Topaklı, sert ve sosis şeklinde',
      clinicalCue: 'Hafif kabızlık eğilimi — hareket ve lif önerilir.',
      isAbnormal: true,
    ),
    BristolStoolType(
      typeNumber: 3,
      title: 'Tip 3 • Çatlaklı Şekilli',
      detail: 'Yüzeyinde ince çatlaklar olan şekilli',
      clinicalCue: 'İdeal bağırsak geçişi aralığı.',
    ),
    BristolStoolType(
      typeNumber: 4,
      title: 'Tip 4 • Pürüzsüz Yumuşak',
      detail: 'Pürüzsüz, yumuşak ve kolay geçişli',
      clinicalCue: 'En ideal sindirim ve hidrasyon dengesi.',
    ),
    BristolStoolType(
      typeNumber: 5,
      title: 'Tip 5 • Yumuşak Parçalar',
      detail: 'Keskin kenarlı yumuşak parçalar',
      clinicalCue: 'Lif azlığı veya hafif hızlı geçiş.',
    ),
    BristolStoolType(
      typeNumber: 6,
      title: 'Tip 6 • Lapa / Dağınık',
      detail: 'Pürüzlü kenarlı yumuşak lapa kıvamı',
      clinicalCue: 'Hafif ishal eğilimi — sıvı alımını artırın.',
      isAbnormal: true,
    ),
    BristolStoolType(
      typeNumber: 7,
      title: 'Tip 7 • Tamamen Sulu',
      detail: 'Katı parça içermeyen tamamen sıvı',
      clinicalCue: 'Akut ishal — sıvı/elektrolit desteği ve 48+ saat sürerse hekim kontrolü gerekir.',
      isAbnormal: true,
    ),
  ];

  static List<QuickColorSwatch> swatchesFor(CheckCategory category) {
    switch (category) {
      case CheckCategory.urine:
        return _urineSwatches;
      case CheckCategory.stool:
        return _stoolSwatches;
      default:
        return const [];
    }
  }

  static List<QuickContextOption> contextOptionsFor(CheckCategory category) {
    switch (category) {
      case CheckCategory.urine:
        return _urineContextOptions;
      case CheckCategory.stool:
        return _stoolContextOptions;
      default:
        return const [];
    }
  }

  static String? _resolveFindingId(QuickColorSwatch swatch) {
    if (swatch.referenceFindingId != null) return swatch.referenceFindingId;
    return switch (swatch.id) {
      'urine_clear' => 'urine_clear_overhydrated',
      'urine_straw' => 'urine_healthy_pale_straw',
      'urine_amber' => 'urine_dark_yellow_dehydration',
      'urine_cloudy' => 'urine_cloudy_foamy',
      'urine_tea' => 'urine_dark_amber_tea',
      'urine_pink_red' => 'urine_pink_red_hematuria',
      'stool_brown' => 'stool_healthy_brown',
      'stool_green' => 'stool_greenish',
      'stool_yellow' => 'stool_yellow_greasy',
      'stool_pale_clay' => 'stool_pale_clay_white',
      'stool_black_tar' => 'stool_black_tarry_melena',
      'stool_red' => 'stool_bright_red_blood',
      _ => null,
    };
  }

  static AnalysisResult buildResult({
    required CheckCategory category,
    required QuickColorSwatch swatch,
    Set<String> selectedContextIds = const {},
    BristolStoolType? bristolType,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final options = contextOptionsFor(category);
    final selectedOptions =
        options.where((o) => selectedContextIds.contains(o.id)).toList();

    final hasFoodOrMed = selectedOptions.any((o) => o.isFoodOrMedication);
    final hasRedFlag = selectedOptions.any((o) => o.isRedFlagSymptom);

    var riskLevel = swatch.riskLevel;
    if (hasRedFlag && riskLevel == RiskLevel.normal) {
      riskLevel = RiskLevel.attention;
    } else if (hasRedFlag && riskLevel == RiskLevel.attention) {
      riskLevel = RiskLevel.urgent;
    }
    if (bristolType != null &&
        bristolType.isAbnormal &&
        riskLevel == RiskLevel.normal) {
      riskLevel = RiskLevel.attention;
    }

    final observations = <String>[
      'Kamerasız renk kartı seçimi: ${swatch.title}',
      ...swatch.observations,
      if (bristolType != null)
        'Bristol Kıvam Skalası: ${bristolType.title} — ${bristolType.clinicalCue}',
      for (final opt in selectedOptions) opt.note,
    ];

    final recommendations = <String>[...swatch.recommendations];
    final warningFlags = <String>[...swatch.warningFlags];

    if (hasFoodOrMed && swatch.canBeBenignFoodOrMed) {
      recommendations.insert(
        0,
        'Seçtiğiniz gıda/ilaç/takviye geçici renk değişimi yapabilir; 24–48 saat içinde normale dönmezse doktora danışın.',
      );
    }

    if (hasRedFlag) {
      warningFlags.add(
        'Eşlik eden rahatsızlık belirtisi işaretlendi; gecikmeden bir sağlık uzmanına başvurmanız önerilir.',
      );
    }

    final refId = _resolveFindingId(swatch);
    final metrics = <String, String>{
      'Yöntem': 'Standart Renk Kartı',
      if (bristolType != null)
        'Bristol Kıvamı': 'Tip ${bristolType.typeNumber} (${bristolType.title.split('•').last.trim()})',
    };

    return AnalysisResult(
      id: 'quick_${category.id}_${timestamp.microsecondsSinceEpoch}',
      category: category,
      riskLevel: riskLevel,
      summaryTitle: swatch.title,
      summaryDetail: swatch.summaryDetail,
      dominantColorValue: swatch.color.toARGB32(),
      observations: observations,
      recommendations: recommendations,
      warningFlags: warningFlags,
      confidence: 0.90,
      createdAt: timestamp,
      whiteBalanceCalibrated: false,
      lightingNote:
          'Fotoğraf çekmeden standart renk kartı üzerinden doğrudan kullanıcı seçimiyle kaydedildi.',
      matchedFindingIds: refId != null ? [refId] : const [],
      clinicalMetrics: metrics,
    );
  }

  static const List<QuickColorSwatch> _urineSwatches = [
    QuickColorSwatch(
      id: 'urine_clear',
      title: 'Çok Açık / Şeffaf',
      subtitle: 'Çok yüksek sıvı alımı',
      color: Color(0xFFF6F8E8),
      riskLevel: RiskLevel.normal,
      summaryDetail:
          'Oldukça açık ve berrak idrar genellikle bol su tüketimini gösterir.',
      observations: [
        'Renk neredeyse şeffaf / çok açık tonda.',
        'Sıvı alımınız yüksek görünüyor.',
      ],
      recommendations: [
        'Susama hissine göre dengeli su içmeye devam edin; aşırı sıvı yüklenmesinden kaçının.',
      ],
    ),
    QuickColorSwatch(
      id: 'urine_straw',
      title: 'Açık Saman Sarısı',
      subtitle: 'İdeal hidrasyon aralığı',
      color: Color(0xFFF3E49A),
      riskLevel: RiskLevel.normal,
      summaryDetail:
          'Açık saman sarısı, günlük sıvı dengesinin sağlıklı aralıkta olduğuna işaret eden olağan görünümdür.',
      observations: [
        'İdeal hidrasyon skalasına uyumlu açık sarı ton.',
      ],
      recommendations: [
        'Mevcut su tüketim alışkanlığınızı sürdürün.',
      ],
    ),
    QuickColorSwatch(
      id: 'urine_amber',
      title: 'Koyu Sarı / Kehribar',
      subtitle: 'Sıvı alımı azalmış olabilir',
      color: Color(0xFFDCA62A),
      riskLevel: RiskLevel.attention,
      summaryDetail:
          'Yoğun sarı veya kehribar tonu sıklıkla yetersiz su tüketimine ya da B vitamini kullanımına bağlıdır.',
      observations: [
        'Yoğun sarı / kehribar tonu seçildi.',
      ],
      recommendations: [
        'Gün içinde 2–3 bardak su içtikten sonra rengin açılıp açılmadığını tekrar kontrol edin.',
        'Su tüketimine rağmen koyuluk sürerse Dahiliye veya Üroloji uzmanına danışın.',
      ],
      canBeBenignFoodOrMed: true,
    ),
    QuickColorSwatch(
      id: 'urine_cloudy',
      title: 'Bulanık / Köpüklü',
      subtitle: 'Tekrarlıyorsa kontrol önerilir',
      color: Color(0xFFE0D5A6),
      riskLevel: RiskLevel.attention,
      summaryDetail:
          'Tekrarlayan bulanıklık veya kalıcı köpüklenme idrar yolu enfeksiyonu ya da protein kaçağı açısından basit bir idrar tahlili gerektirebilir.',
      observations: [
        'Bulanık veya köpüklü görünüm seçildi.',
      ],
      recommendations: [
        'Durum birkaç kez tekrarlıyorsa tam idrar tahlili (TİT) için doktora başvurun.',
        'Yanma, ateş veya yan ağrısı varsa beklemeyin.',
      ],
      warningFlags: [
        'Kalıcı bulanıklık veya köpüklenme tekrarlıyorsa idrar tahlili önerilir.',
      ],
    ),
    QuickColorSwatch(
      id: 'urine_tea',
      title: 'Çay / Kola Kahverengisi',
      subtitle: 'Doktor değerlendirmesi önerilir',
      color: Color(0xFF8B4F24),
      riskLevel: RiskLevel.urgent,
      summaryDetail:
          'Çay veya kola rengindeki koyu kahverengi idrar; yoğun sıvı kaybı, karaciğer/safra yolu veya kas yıkımı gibi tıbbi değerlendirme gerektiren durumlarla ilişkili olabilir.',
      observations: [
        'Belirgin koyu kahverengi / çay tonu seçildi.',
      ],
      recommendations: [
        'Kısa sürede Dahiliye veya Üroloji uzmanına başvurarak idrar ve kan tahlili yaptırın.',
        'Göz akında sararma veya halsizlik eşlik ediyorsa gecikmeyin.',
      ],
      warningFlags: [
        'Koyu çay/kola rengi idrar mutlaka hekim değerlendirmesi gerektirir.',
      ],
      canBeBenignFoodOrMed: true,
    ),
    QuickColorSwatch(
      id: 'urine_pink_red',
      title: 'Pembe / Kırmızımsı',
      subtitle: 'Hekim değerlendirmesi önerilir',
      color: Color(0xFFC94B57),
      riskLevel: RiskLevel.urgent,
      summaryDetail:
          'Pembe veya kırmızımsı idrar pancar/böğürtlen gibi gıdalardan kaynaklanabilse de idrarda kan (hematüri) olasılığının dışlanması için doktor kontrolü önemlidir.',
      observations: [
        'Pembe / kırmızımsı renk tonu seçildi.',
      ],
      recommendations: [
        'Yakın zamanda renk veren gıda tüketmediyseniz vakit kaybetmeden Üroloji veya Dahiliye uzmanına başvurun.',
        'Ağrı, yanma veya pıhtı varsa acil değerlendirme alın.',
      ],
      warningFlags: [
        'Gıda/ilaç kaynaklı değilse idrarda kan olasılığı mutlaka araştırılmalıdır.',
      ],
      canBeBenignFoodOrMed: true,
    ),
  ];

  static const List<QuickContextOption> _urineContextOptions = [
    QuickContextOption(
      id: 'urine_food_med',
      label: 'Pancar / B vitamini / renk veren ilaç kullandım',
      note: 'Ek bilgi: Renk değiştirebilen gıda, vitamin veya ilaç kullanımı işaretlendi.',
      isFoodOrMedication: true,
    ),
    QuickContextOption(
      id: 'urine_low_water',
      label: 'Bugün normalden az su içtim',
      note: 'Ek bilgi: Gün içinde düşük su tüketimi belirtildi.',
    ),
    QuickContextOption(
      id: 'urine_burning',
      label: 'Yanma, ağrı veya sık idrar var',
      note: 'Ek bilgi: İdrar yaparken yanma/ağrı veya sık idrar belirtisi işaretlendi.',
      isRedFlagSymptom: true,
    ),
  ];

  static const List<QuickColorSwatch> _stoolSwatches = [
    QuickColorSwatch(
      id: 'stool_brown',
      title: 'Normal Kahverengi',
      subtitle: 'Olağan görünüm',
      color: Color(0xFF7B4F2C),
      riskLevel: RiskLevel.normal,
      summaryDetail:
          'Açık ile koyu kahverengi arası tonlar normal sindirim ve safra akışına uyumlu olağan görünümdür.',
      observations: [
        'Standart kahverengi skalaya uyumlu seçim.',
      ],
      recommendations: [
        'Eşlik eden şikayet yoksa olağan takibe devam edebilirsiniz.',
      ],
    ),
    QuickColorSwatch(
      id: 'stool_green',
      title: 'Yeşilimsi',
      subtitle: 'Diyet veya hızlı bağırsak geçişi',
      color: Color(0xFF567346),
      riskLevel: RiskLevel.attention,
      summaryDetail:
          'Yeşil yapraklı sebzeler, demir takviyeleri veya ishal gibi hızlı bağırsak geçişi geçici yeşil tona yol açabilir.',
      observations: [
        'Yeşilimsi ton seçildi.',
      ],
      recommendations: [
        'Diyet kaynaklı değilse ve birkaç günden uzun sürerse Gastroenteroloji veya Dahiliye uzmanına danışın.',
      ],
      canBeBenignFoodOrMed: true,
    ),
    QuickColorSwatch(
      id: 'stool_yellow',
      title: 'Sarı / Yağlı Görünüm',
      subtitle: 'Sürerse sindirim değerlendirmesi',
      color: Color(0xFFC8A03E),
      riskLevel: RiskLevel.attention,
      summaryDetail:
          'Tekrarlayan sarı, kötü kokulu veya yağlı görünüm emilim/sindirim değerlendirmesi gerektirebilir.',
      observations: [
        'Sarımsı / yağlı görünüm tonu seçildi.',
      ],
      recommendations: [
        'Birkaç gün içinde düzelmezse veya kilo kaybı/şişkinlik eşlik ediyorsa Gastroenteroloji uzmanına başvurun.',
      ],
    ),
    QuickColorSwatch(
      id: 'stool_pale_clay',
      title: 'Açık Kil / Beyazımsı',
      subtitle: 'Safra akışı için doktor kontrolü',
      color: Color(0xFFD5CCB8),
      riskLevel: RiskLevel.urgent,
      summaryDetail:
          'Açık kil, macun veya beyazımsı dışkı safra akışında azalma olasılığı açısından tıbbi değerlendirme gerektirir.',
      observations: [
        'Açık kil / soluk ton seçildi.',
      ],
      recommendations: [
        'Koyu idrar veya ciltte/gözde sararma eşlik ediyorsa vakit kaybetmeden bir sağlık kuruluşuna başvurun.',
      ],
      warningFlags: [
        'Açık kil veya beyazımsı dışkı safra/karaciğer değerlendirmesi gerektirir.',
      ],
    ),
    QuickColorSwatch(
      id: 'stool_black_tar',
      title: 'Siyah / Katran Rengi',
      subtitle: 'Demir/bizmut yoksa acil kontrol',
      color: Color(0xFF232020),
      riskLevel: RiskLevel.urgent,
      summaryDetail:
          'Demir takviyesi veya bizmut içeren mide ilacı kullanmıyorsanız siyah, yapışkan (katranımsı) dışkı üst sindirim sistemi kanaması açısından acil tıbbi değerlendirme gerektirir.',
      observations: [
        'Çok koyu siyah / katran rengi seçildi.',
      ],
      recommendations: [
        'Demir veya bizmut ilacı kullanmıyorsanız aynı gün içinde acil veya Gastroenteroloji değerlendirmesi alın.',
        'Baş dönmesi, halsizlik veya karın ağrısı varsa acil servise başvurun.',
      ],
      warningFlags: [
        'İlaç kaynaklı olmayan siyah/katran dışkı acil tıbbi değerlendirme gerektirir.',
      ],
      canBeBenignFoodOrMed: true,
    ),
    QuickColorSwatch(
      id: 'stool_red',
      title: 'Parlak Kırmızı / Kanlı',
      subtitle: 'Doktor değerlendirmesi önerilir',
      color: Color(0xFFA82C32),
      riskLevel: RiskLevel.urgent,
      summaryDetail:
          'Parlak kırmızı görünüm pancar gibi gıdalardan kaynaklanabilse de hemoroid, çatlak veya alt sindirim sistemi kanamasının değerlendirilmesi için doktor muayenesi gerekir.',
      observations: [
        'Parlak kırmızı / kanlı görünüm tonu seçildi.',
      ],
      recommendations: [
        'Gıda kaynaklı olduğundan emin değilseniz Gastroenteroloji veya Genel Cerrahi uzmanına başvurun.',
        'Aktif kanama, baygınlık hissi veya şiddetli ağrıda acil servise gidin.',
      ],
      warningFlags: [
        'Kırmızı/kanlı dışkı göz ardı edilmemeli ve hekim tarafından değerlendirilmelidir.',
      ],
      canBeBenignFoodOrMed: true,
    ),
  ];

  static const List<QuickContextOption> _stoolContextOptions = [
    QuickContextOption(
      id: 'stool_iron_bismuth',
      label: 'Demir veya bizmut (mide) ilacı kullandım',
      note: 'Ek bilgi: Demir veya bizmut içeren ilaç kullanımı işaretlendi.',
      isFoodOrMedication: true,
    ),
    QuickContextOption(
      id: 'stool_food',
      label: 'Pancar, ıspanak veya koyu renkli gıda tükettim',
      note: 'Ek bilgi: Renk değiştirebilen gıda tüketimi işaretlendi.',
      isFoodOrMedication: true,
    ),
    QuickContextOption(
      id: 'stool_pain_dizzy',
      label: 'Karın ağrısı, halsizlik veya baş dönmesi var',
      note: 'Ek bilgi: Karın ağrısı, halsizlik veya baş dönmesi belirtisi işaretlendi.',
      isRedFlagSymptom: true,
    ),
  ];
}
