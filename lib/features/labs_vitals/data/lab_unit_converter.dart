import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';

class NormalizedLabMeasurement {
  const NormalizedLabMeasurement({
    required this.value,
    required this.unit,
    required this.refMin,
    required this.refMax,
    required this.wasConverted,
    this.originalUnit,
  });

  final double value;
  final String unit;
  final double? refMin;
  final double? refMax;
  final bool wasConverted;
  final String? originalUnit;
}

/// International clinical laboratory standardization engine.
///
/// Handles SI ↔ Conventional unit conversions (Mayo Clinic / LabCorp / Quest /
/// IFCC master equations) AND multilingual test-name synonyms across Turkey,
/// USA, UK (NHS), Germany (MVZ), France, Spain, Portugal, Russia (Invitro),
/// India, Arabic, and Chinese hospital reports so cross-country reports compare
/// accurately on one unified scale.
class LabUnitConverter {
  LabUnitConverter._();

  /// Curated core routine blood-check panel used to gently notify elderly/general
  /// users which common baseline tests were NOT included in an uploaded report.
  static const List<String> coreCheckupCodes = [
    'HGB',
    'WBC',
    'PLT',
    'GLU',
    'HBA1C',
    'CREA',
    'ALT',
    'TSH',
    'LDL',
    'CRP',
    'FERRITIN',
    'B12',
    'VITD',
  ];

  /// Multilingual test-name synonyms mapped to canonical catalog codes.
  /// Keys should be lowercased; diacritics/Unicode are preserved and matched.
  static const Map<String, List<String>> multilingualAliases = {
    'HGB': [
      'haemoglobin',
      'hämoglobin',
      'hamoglobin',
      'hémoglobine',
      'hemoglobine',
      'hemoglobina',
      'гемоглобин',
      'الهيموجلوبين',
      'خضاب الدم',
      '血红蛋白',
    ],
    'WBC': [
      'white blood cell',
      'white blood cells',
      'white cell count',
      'leukocytes',
      'leukozyten',
      'leucocytes',
      'leucocitos',
      'лейкоциты',
      'كريات الدم البيضاء',
      '白细胞',
      '白细胞计数',
      'tlc',
      'total leukocyte count',
    ],
    'PLT': [
      'platelets',
      'platelet count',
      'thrombozyten',
      'plaquettes',
      'plaquetas',
      'тромбоциты',
      'الصفائح الدموية',
      '血小板',
      '血小板计数',
    ],
    'RBC': [
      'red blood cell',
      'red blood cells',
      'erythrozyten',
      'hématies',
      'hematies',
      'eritrocitos',
      'эритроциты',
      'كريات الدم الحمراء',
      '红细胞',
    ],
    'HCT': [
      'haematocrit',
      'hematocrit',
      'hämatokrit',
      'hématocrite',
      'hematocrito',
      'гематокрит',
      'pcv',
      'packed cell volume',
      '红细胞压积',
    ],
    'GLU': [
      'fasting glucose',
      'fasting blood glucose',
      'fasting blood sugar',
      'blood glucose',
      'plasma glucose',
      'serum glucose',
      'fbs',
      'fbg',
      'glu',
      'blutzucker',
      'nüchternglukose',
      'glycémie',
      'glycemie',
      'glucosa',
      'glicemia',
      'глюкоза',
      'الجلوكوز',
      'سكر الدم',
      '血糖',
      '空腹血糖',
    ],
    'HBA1C': [
      'glycated hemoglobin',
      'glycated haemoglobin',
      'glycosylated hemoglobin',
      'hb a1c',
      'glycohemoglobin',
      'гликированный гемоглобин',
      'السكر التراكمي',
      '糖化血红蛋白',
    ],
    'FERRITIN': [
      'serum ferritin',
      'ferritine',
      'ferritina',
      'ферритин',
      'الفيريتين',
      '铁蛋白',
    ],
    'IRON': [
      'serum iron',
      'eisen',
      'fer sérique',
      'fer serique',
      'hierro',
      'ferro',
      'железо',
      'الحديد',
      '血清铁',
    ],
    'B12': [
      'cobalamin',
      'cyanocobalamin',
      'vitamine b12',
      'vitamina b12',
      'витамин b12',
      'витамин в12',
      'فيتامين ب12',
      '维生素b12',
    ],
    'VITD': [
      '25-hydroxy vitamin d',
      '25-hydroxyvitamin d',
      '25(oh)d',
      '25-oh-vitamin d',
      'vitamine d',
      'vitamina d',
      'витамин d',
      'витамин д',
      'فيتامين د',
      '维生素d',
    ],
    'FOLATE': [
      'folic acid',
      'folsäure',
      'folsaure',
      'acide folique',
      'ácido fólico',
      'acido folico',
      'фолиевая кислота',
      'حمض الفوليك',
      '叶酸',
    ],
    'TSH': [
      'thyroid stimulating hormone',
      'thyrotropin',
      'ттг',
      'тиреотропный гормон',
      'هرمون الغدة الدرقية',
      '促甲状腺激素',
    ],
    'ALT': [
      'alat',
      'gpt',
      'alanine aminotransferase',
      'alanine transaminase',
      'алт',
      'аланинаминотрансфераза',
      '谷丙转氨酶',
    ],
    'AST': [
      'asat',
      'got',
      'aspartate aminotransferase',
      'aspartate transaminase',
      'аст',
      'аспартатаминотрансфераза',
      '谷草转氨酶',
    ],
    'GGT': [
      'gamma-gt',
      'gamma gt',
      'γ-gt',
      'ggtp',
      'ггт',
      'ггтп',
      '谷氨酰转肽酶',
    ],
    'CREA': [
      'serum creatinine',
      'kreatinin',
      'créatinine',
      'creatinina',
      'креатинин',
      'الكرياتينين',
      '肌酐',
      'cr',
    ],
    'UREA': [
      'blood urea nitrogen',
      'blood urea',
      'serum urea',
      'harnstoff',
      'urée',
      'uree',
      'мочевина',
      'اليوريا',
      '尿素',
    ],
    'EGFR': [
      'estimated gfr',
      'скф',
      'dfg',
    ],
    'TOTAL_CHOL': [
      'cholesterol',
      'cholesterol, total',
      'cholesterin',
      'cholestérol total',
      'colesterol total',
      'холестерин',
      'холестерин общий',
      'الكوليسترول الكلي',
      '总胆固醇',
    ],
    'LDL': [
      'ldl cholesterol',
      'ldl-cholesterol',
      'ldl-cholesterin',
      'colesterol ldl',
      'лпнп',
      '低密度脂蛋白',
    ],
    'HDL': [
      'hdl cholesterol',
      'hdl-cholesterol',
      'hdl-cholesterin',
      'colesterol hdl',
      'лпвп',
      '高密度脂蛋白',
    ],
    'TRIG': [
      'triglycerides',
      'triglyzeride',
      'triglycérides',
      'triglicéridos',
      'triglicerideos',
      'триглицериды',
      'الدهون الثلاثية',
      '甘油三酯',
    ],
    'CRP': [
      'c-reactive protein',
      'c reactive protein',
      'hs-crp',
      'protéine c-réactive',
      'proteína c reactiva',
      'срб',
      'с-реактивный белок',
      'البروتين التفاعلي',
      'c反应蛋白',
    ],
    'URIC_ACID': [
      'harnsäure',
      'harnsaure',
      'acide urique',
      'ácido úrico',
      'acido urico',
      'мочевая кислота',
      'حمض اليوريك',
      '尿酸',
    ],
    'NA': [
      'natrium',
      'sodio',
      'натрий',
      'الصوديوم',
      '钠',
    ],
    'K': [
      'kalium',
      'potasio',
      'potássio',
      'калий',
      'البوتاسيوم',
      '钾',
    ],
    'CA': [
      'kalzium',
      'calcio',
      'cálcio',
      'кальций',
      'الكالسيوم',
      '钙',
    ],
    'TBIL': [
      'total bilirubin',
      'bilirubin total',
      'bilirubin, total',
      't. bili',
      'tbil',
      'total bil',
      'bilirrubina total',
      'bilirubine totale',
      'билирубин общий',
      'البيليروبين الكلي',
      '总胆红素',
    ],
    'ALP': [
      'alkaline phosphatase',
      'alkalen fosfataz',
      'alkalische phosphatase',
      'fosfatasa alcalina',
      'щелочная фосфатаза',
      '碱性磷酸酶',
    ],
    'ALB': [
      'albumin',
      'albümin',
      'albumine',
      'albúmina',
      'альбумин',
      'الألبومين',
      '白蛋白',
    ],
    'ESR': [
      'sedimantasyon',
      'sedimentation',
      'erythrocyte sedimentation rate',
      'bsg',
      'vsg',
      'соэ',
      '血沉',
    ],
    'ZN': [
      'zinc',
      'zink',
      'serum zinc',
      'cinko',
      'çinko',
      'цинковый',
      'цинк',
      'الزنك',
      '锌',
    ],
    'MG': [
      'magnesium',
      'magnésium',
      'magnesio',
      'magnezyum',
      'serum magnesium',
      'магний',
      'المغنيسيوم',
      '镁',
    ],
    'CL': [
      'chloride',
      'chlorure',
      'cloruro',
      'klor',
      'klorür',
      'chlorid',
      'хлор',
      'хлорид',
      'الكلوريد',
      '氯',
    ],
    'P': [
      'phosphorus',
      'phosphate',
      'phosphor',
      'inorganic phosphorus',
      'inorganik fosfor',
      'fosfor',
      'phosphate inorganique',
      'фосфор',
      'الفوسفور',
      '磷',
    ],
    'DBIL': [
      'direct bilirubin',
      'conjugated bilirubin',
      'bilirubin direct',
      'bilirubin, direct',
      'direkt bilirubin',
      'direk bilirubin',
      'bilirubine directe',
      'bilirrubina directa',
      'd. bili',
      'dbil',
      'прямой билирубин',
      'البيليروبين المباشر',
      '直接胆红素',
    ],
    'TP': [
      'total protein',
      'total proteins',
      'serum total protein',
      'toplam protein',
      'gesamteiweiß',
      'gesamteiweiss',
      'protéines totales',
      'proteínas totales',
      'общий белок',
      'البروتين الكلي',
      '总蛋白',
    ],
  };

  /// Normalizes a measurement from international SI or alternate units to the
  /// canonical conventional unit used by [LabReportAnalyzer.catalog].
  ///
  /// Both [value] and any hospital-supplied [refMin]/[refMax] are converted
  /// together so clinical evaluation and multi-date comparisons stay 100% consistent.
  static NormalizedLabMeasurement normalizeToCanonical({
    required String code,
    required double value,
    required String rawUnit,
    required String canonicalUnit,
    String? rawName,
    double? refMin,
    double? refMax,
  }) {
    final u = _normalizeUnit(rawUnit);
    final upperCode = code.toUpperCase();
    final lowerName = (rawName ?? '').toLowerCase();

    double round2(double v) => double.parse(v.toStringAsFixed(2));
    double round1(double v) => double.parse(v.toStringAsFixed(1));

    NormalizedLabMeasurement linear(double factor, {bool oneDecimal = false}) {
      final fmt = oneDecimal ? round1 : round2;
      return NormalizedLabMeasurement(
        value: fmt(value * factor),
        unit: canonicalUnit,
        refMin: refMin != null ? fmt(refMin * factor) : null,
        refMax: refMax != null ? fmt(refMax * factor) : null,
        wasConverted: true,
        originalUnit: rawUnit.trim(),
      );
    }

    switch (upperCode) {
      case 'GLU':
        if (u == 'mmol/l') return linear(18.018, oneDecimal: true);
      case 'TOTAL_CHOL':
      case 'LDL':
      case 'HDL':
        if (u == 'mmol/l') return linear(38.67, oneDecimal: true);
      case 'TRIG':
        if (u == 'mmol/l') return linear(88.57, oneDecimal: true);
      case 'HGB':
        if (u == 'g/l') return linear(0.1, oneDecimal: true);
        if (u == 'mmol/l') return linear(1.6114, oneDecimal: true);
      case 'HBA1C':
        if (u == 'mmol/mol') {
          double toNgsp(double ifcc) => round1(0.09148 * ifcc + 2.152);
          return NormalizedLabMeasurement(
            value: toNgsp(value),
            unit: '%',
            refMin: refMin != null ? toNgsp(refMin) : null,
            refMax: refMax != null ? toNgsp(refMax) : null,
            wasConverted: true,
            originalUnit: rawUnit.trim(),
          );
        }
      case 'CREA':
        if (u == 'umol/l') return linear(1 / 88.4);
      case 'TBIL':
        if (u == 'umol/l') return linear(1 / 17.104);
      case 'DBIL':
        if (u == 'umol/l') return linear(1 / 17.104);
      case 'URIC_ACID':
        if (u == 'umol/l') return linear(1 / 59.48);
        if (u == 'mmol/l') return linear(16.81);
      case 'IRON':
        if (u == 'umol/l') return linear(5.585, oneDecimal: true);
      case 'ZN':
        if (u == 'umol/l') return linear(6.538, oneDecimal: true);
      case 'MG':
        if (u == 'mmol/l') return linear(2.4305, oneDecimal: true);
        if (u == 'meq/l') return linear(1.215, oneDecimal: true);
      case 'P':
        if (u == 'mmol/l') return linear(3.097, oneDecimal: true);
      case 'TP':
        if (u == 'g/l') return linear(0.1, oneDecimal: true);
      case 'VITD':
        if (u == 'nmol/l') return linear(1 / 2.496, oneDecimal: true);
      case 'B12':
        if (u == 'pmol/l') return linear(1.3554, oneDecimal: true);
      case 'CA':
        if (u == 'mmol/l') return linear(4.008);
      case 'UREA':
        if (u == 'mmol/l') return linear(6.006, oneDecimal: true);
        if ((lowerName.contains('bun') || lowerName.contains('urea nitrogen')) &&
            (u == 'mg/dl' || u.isEmpty)) {
          return linear(2.1428, oneDecimal: true);
        }
      case 'CRP':
        if (u == 'mg/dl') return linear(10.0);
      case 'HCT':
        if (u == 'l/l' || (u.isEmpty && value > 0 && value < 1.0)) {
          return linear(100.0, oneDecimal: true);
        }
      case 'WBC':
        if ((u == '/ul' || u == '/mm3' || u == 'cells/ul' || u == '/mcl') &&
            value >= 100) {
          return linear(0.001);
        }
      case 'PLT':
        if ((u == '/ul' || u == '/mm3' || u == 'cells/ul' || u == '/mcl') &&
            value >= 1000) {
          return linear(0.001, oneDecimal: true);
        }
    }

    return NormalizedLabMeasurement(
      value: value,
      unit: rawUnit.trim().isNotEmpty ? rawUnit.trim() : canonicalUnit,
      refMin: refMin,
      refMax: refMax,
      wasConverted: false,
    );
  }

  /// Calm, plain-language next-step advice for elderly and everyday readers.
  static String plainActionAdvice(LabTestItem item) {
    if (item.status.isCritical) {
      return 'Bu sonuç normal sınırdan belirgin derecede farklıdır. Beklemeden doktorunuza veya sağlık kuruluşuna göstermeniz önemlidir.';
    }
    switch (item.code) {
      case 'HGB':
      case 'FERRITIN':
      case 'IRON':
      case 'B12':
      case 'FOLATE':
        if (item.status == LabStatus.low) {
          return 'Kansızlık veya vitamin/demir eksikliği açısından bu sonucu Dahiliye doktorunuzla paylaşın; kendi başınıza yüksek doz takviye başlamayın.';
        }
      case 'GLU':
      case 'HBA1C':
        if (item.status == LabStatus.high) {
          return 'Tahlili aç karnına verip vermediğinizi not edin; şeker takibi ve beslenme planı için doktorunuza danışın.';
        }
      case 'CREA':
      case 'UREA':
      case 'EGFR':
        return 'Günlük su tüketiminizi gözden geçirin ve kullandığınız ağrı kesici/düzenli ilaçların listesini doktorunuza gösterin.';
      case 'LDL':
      case 'TOTAL_CHOL':
      case 'TRIG':
      case 'HDL':
        return 'Beslenme, yürüyüş ve varsa kolesterol ilaçlarınızın dozu konusunda doktorunuzdan görüş alın.';
      case 'TSH':
        return 'Tiroid ilacı kullanıyorsanız doz ayarlaması, kullanmıyorsanız ek tiroid testi (sT4) için doktorunuza başvurun.';
      case 'VITD':
        if (item.status == LabStatus.low) {
          return 'D vitamini damla veya takviye dozunu doktorunuza sorarak planlayabilirsiniz.';
        }
      case 'ALT':
      case 'AST':
      case 'GGT':
      case 'TBIL':
      case 'DBIL':
        return 'Kullandığınız ilaçlar ve bitkisel takviyeleri listeleyerek doktorunuzla değerlendirin.';
      case 'ZN':
      case 'MG':
      case 'CL':
      case 'P':
        return 'Mineral ve elektrolit dengesi açısından doktorunuza danışınız; hekim reçetesi olmadan mineral takviyesi almayınız.';
      case 'TP':
      case 'ALB':
        return 'Beslenme durumu ve protein dengesi açısından doktorunuzla değerlendiriniz.';
      case 'CRP':
      case 'WBC':
      case 'ESR':
        if (item.status == LabStatus.high) {
          return 'Ateş, öksürük, idrar yanması veya eklem ağrısı gibi şikayetleriniz varsa doktorunuza mutlaka belirtin.';
        }
    }
    return 'Bir sonraki muayenenizde bu sonucu önceki tahlillerinizle birlikte doktorunuza gösterin.';
  }

  static String _normalizeUnit(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll('µ', 'u')
        .replaceAll('μ', 'u')
        .replaceAll('³', '3')
        .replaceAll('^3', '3')
        .replaceAll(' ', '');
  }
}
