import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/labs_vitals/domain/lab_models.dart';
import 'package:visualcheckup/features/labs_vitals/domain/vital_models.dart';

/// Curated adult blood test reference catalog & offline hospital report parser.
///
/// Parses pasted Turkish / e-Nabız / standard lab text lines, classifies values
/// against general adult reference ranges, tracks longitudinal parameter trends,
/// and formats shareable doctor-visit summaries.
class LabReportAnalyzer {
  LabReportAnalyzer._();

  static const List<LabParameterSpec> catalog = [
    LabParameterSpec(
      code: 'HGB',
      name: 'Hemoglobin (HGB)',
      aliases: ['hemoglobin', 'hgb', 'hb'],
      unit: 'g/dL',
      minNormal: 12.0,
      maxNormal: 16.5,
      criticalLow: 8.0,
      criticalHigh: 19.5,
      lowNote:
          'Referansın altında (kansızlık / anemi eğilimi; demir, ferritin ve B12 ile birlikte değerlendirilebilir).',
      highNote:
          'Referansın üzerinde (sıvı azlığı, sigara veya kan yoğunlaşması açısından hekim kontrolü önerilir).',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'WBC',
      name: 'Lökosit (WBC)',
      aliases: ['lökosit', 'lokosit', 'wbc', 'beyaz küre', 'beyaz kure'],
      unit: '10³/µL',
      minNormal: 4.0,
      maxNormal: 10.5,
      criticalLow: 2.0,
      criticalHigh: 25.0,
      lowNote:
          'Lökosit düşüklüğü viral durumlar, ilaç etkileri veya bağışıklık değerlendirmesi gerektirebilir.',
      highNote:
          'Lökosit yüksekliği enfeksiyon, iltihap veya stres tepkisi ile ilişkili olabilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'PLT',
      name: 'Trombosit (PLT)',
      aliases: ['trombosit', 'plt', 'platelet'],
      unit: '10³/µL',
      minNormal: 150,
      maxNormal: 450,
      criticalLow: 50,
      criticalHigh: 800,
      lowNote:
          'Trombosit düşüklüğü kolay morarma/kanama eğilimi açısından hekim kontrolü gerektirir.',
      highNote:
          'Trombosit yüksekliği demir eksikliği veya iltihabi süreçlerle ilişkili olabilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'GLU',
      name: 'Açlık Glukoz (Kan Şekeri)',
      aliases: [
        'açlık kan şekeri',
        'aclik kan sekeri',
        'açlık glukoz',
        'aclik glukoz',
        'glukoz',
        'glikoz',
        'glucose',
        'akş',
      ],
      unit: 'mg/dL',
      minNormal: 70,
      maxNormal: 99,
      criticalLow: 55,
      criticalHigh: 250,
      lowNote: 'Düşük kan şekeri (hipoglisemi) eğilimi; hekim değerlendirmesi önerilir.',
      highNote:
          'Açlık kan şekeri referans üstünde (100–125 sınırda, 126+ diyabet açısından ileri değerlendirme gerekir).',
      specialtyHint: 'Dahiliye veya Endokrinoloji',
    ),
    LabParameterSpec(
      code: 'HBA1C',
      name: 'HbA1c (3 Aylık Şeker)',
      aliases: ['hba1c', 'hemoglobin a1c', 'a1c'],
      unit: '%',
      minNormal: 4.0,
      maxNormal: 5.6,
      criticalHigh: 9.0,
      lowNote: 'Referans aralığının altında ölçülmüş; hekiminizle teyit edin.',
      highNote:
          'Son 2–3 aylık ortalama şeker eğilimi yüksek (5.7–6.4 sınırda, 6.5+ diyabet değerlendirmesi gerektirir).',
      specialtyHint: 'Endokrinoloji veya Dahiliye',
    ),
    LabParameterSpec(
      code: 'FERRITIN',
      name: 'Ferritin (Demir Deposu)',
      aliases: ['ferritin'],
      unit: 'ng/mL',
      minNormal: 20,
      maxNormal: 200,
      criticalLow: 8,
      criticalHigh: 600,
      lowNote:
          'Demir depolarının azaldığına işaret edebilir (halsizlik, saç dökülmesi, tırnak kırılmasıyla ilişkili olabilir).',
      highNote:
          'Demir yükü veya iltihabi süreçlerde (akut faz) yükselebilir; hekime danışın.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'B12',
      name: 'Vitamin B12',
      aliases: ['vitamin b12', 'vit b12', 'b12 vitamini', 'b12'],
      unit: 'pg/mL',
      minNormal: 200,
      maxNormal: 900,
      criticalLow: 120,
      lowNote:
          'B12 düşüklüğü halsizlik, unutkanlık, uyuşma veya dil hassasiyeti ile ilişkili olabilir.',
      highNote: 'Genellikle takviye kullanımına bağlıdır; hekiminize danışın.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'VITD',
      name: 'Vitamin D (25-OH)',
      aliases: [
        '25-oh vitamin d',
        '25-oh d',
        'vitamin d',
        'd vitamini',
        'vit d',
        '25 hidroksi',
      ],
      unit: 'ng/mL',
      minNormal: 30,
      maxNormal: 100,
      criticalLow: 10,
      criticalHigh: 150,
      lowNote:
          'D vitamini eksikliği/yetersizliği kemik-kas ağrısı ve yorgunlukla ilişkili olabilir.',
      highNote: 'Yüksek doz takviye kullanımı varsa hekiminizle dozu gözden geçirin.',
      specialtyHint: 'Dahiliye veya Endokrinoloji',
    ),
    LabParameterSpec(
      code: 'TSH',
      name: 'TSH (Tiroid)',
      aliases: ['tsh', 'tiroid stimülan', 'tiroid stimulan'],
      unit: 'mIU/L',
      minNormal: 0.4,
      maxNormal: 4.2,
      criticalLow: 0.05,
      criticalHigh: 10.0,
      lowNote: 'Tiroid bezinin hızlı çalışması (hipertiroidi) açısından serbest T3/T4 ile değerlendirilebilir.',
      highNote:
          'Tiroid bezinin yavaş çalışması (hipotiroidi) açısından hekim değerlendirmesi önerilir.',
      specialtyHint: 'Endokrinoloji veya Dahiliye',
    ),
    LabParameterSpec(
      code: 'ALT',
      name: 'ALT (Karaciğer Enzimi)',
      aliases: ['alt', 'sgpt', 'alanin aminotransferaz'],
      unit: 'U/L',
      minNormal: 0,
      maxNormal: 45,
      criticalHigh: 200,
      lowNote: 'Düşük ALT genellikle klinik sorun oluşturmaz.',
      highNote:
          'Karaciğer yağlanması, ilaç etkisi veya karaciğer hassasiyeti açısından doktor kontrolü önerilir.',
      specialtyHint: 'Dahiliye veya Gastroenteroloji',
    ),
    LabParameterSpec(
      code: 'AST',
      name: 'AST (Karaciğer Enzimi)',
      aliases: ['ast', 'sgot', 'aspartat aminotransferaz'],
      unit: 'U/L',
      minNormal: 0,
      maxNormal: 40,
      criticalHigh: 200,
      lowNote: 'Düşük AST genellikle klinik sorun oluşturmaz.',
      highNote:
          'Karaciğer veya kas kaynaklı yükselme olabilir; ALT ile birlikte hekim tarafından değerlendirilmelidir.',
      specialtyHint: 'Dahiliye veya Gastroenteroloji',
    ),
    LabParameterSpec(
      code: 'CREA',
      name: 'Kreatinin',
      aliases: ['kreatinin', 'creatinine', 'crea'],
      unit: 'mg/dL',
      minNormal: 0.6,
      maxNormal: 1.2,
      criticalHigh: 2.5,
      lowNote: 'Düşük kas kütlesi veya gebelikte düşük çıkabilir.',
      highNote:
          'Böbrek süzme fonksiyonu ve sıvı durumu açısından (eGFR ile birlikte) doktor değerlendirmesi önemlidir.',
      specialtyHint: 'Dahiliye veya Nefroloji',
    ),
    LabParameterSpec(
      code: 'LDL',
      name: 'LDL Kolesterol',
      aliases: ['ldl kolesterol', 'ldl-kolesterol', 'ldl'],
      unit: 'mg/dL',
      minNormal: 0,
      maxNormal: 130,
      criticalHigh: 190,
      lowNote: 'Düşük LDL genellikle olumlu kabul edilir.',
      highNote:
          'Kardiyovasküler risk profili, beslenme ve egzersiz açısından doktor değerlendirmesi önerilir.',
      specialtyHint: 'Dahiliye veya Kardiyoloji',
    ),
    LabParameterSpec(
      code: 'TRIG',
      name: 'Trigliserid',
      aliases: ['trigliserid', 'trigliserit', 'triglyceride', 'tg'],
      unit: 'mg/dL',
      minNormal: 0,
      maxNormal: 150,
      criticalHigh: 500,
      lowNote: 'Düşük trigliserid genellikle sorun oluşturmaz.',
      highNote:
          'Beslenme, açlık süresi ve metabolik risk açısından hekime danışmanız önerilir.',
      specialtyHint: 'Dahiliye veya Kardiyoloji',
    ),
    LabParameterSpec(
      code: 'CRP',
      name: 'CRP (İltihap Belirteci)',
      aliases: ['crp', 'c-reaktif protein', 'c reaktif protein'],
      unit: 'mg/L',
      minNormal: 0,
      maxNormal: 5.0,
      criticalHigh: 50.0,
      lowNote: 'Normal aralıkta.',
      highNote:
          'Vücutta aktif enfeksiyon veya iltihabi süreç işareti olabilir; şikayetlerinizle birlikte doktor değerlendirmesi gerekir.',
      specialtyHint: 'Dahiliye',
    ),
  ];

  static LabParameterSpec? specByCode(String code) {
    final upper = code.trim().toUpperCase();
    for (final spec in catalog) {
      if (spec.code == upper) return spec;
    }
    return null;
  }

  /// Evaluates a single known parameter against its adult reference spec.
  static LabTestItem evaluateKnownParameter({
    required LabParameterSpec spec,
    required double value,
    double? customRefMin,
    double? customRefMax,
  }) {
    final minRef = customRefMin ?? spec.minNormal;
    final maxRef = customRefMax ?? spec.maxNormal;

    final LabStatus status;
    final String note;

    if (spec.criticalLow != null && value <= spec.criticalLow!) {
      status = LabStatus.criticalLow;
      note = '${spec.lowNote} Belirgin düşük değer; gecikmeden doktora başvurun.';
    } else if (spec.criticalHigh != null && value >= spec.criticalHigh!) {
      status = LabStatus.criticalHigh;
      note = '${spec.highNote} Belirgin yüksek değer; gecikmeden doktora başvurun.';
    } else if (value < minRef) {
      status = LabStatus.low;
      note = spec.lowNote;
    } else if (value > maxRef) {
      status = LabStatus.high;
      note = spec.highNote;
    } else {
      status = LabStatus.normal;
      note = 'Genel yetişkin referans aralığı içinde görünüyor.';
    }

    return LabTestItem(
      code: spec.code,
      name: spec.name,
      value: value,
      unit: spec.unit,
      refMin: minRef,
      refMax: maxRef,
      status: status,
      note: note,
    );
  }

  /// Parses raw pasted hospital / e-Nabız report text into evaluated items
  /// and optionally detects a date written inside the report.
  static ({List<LabTestItem> items, DateTime? detectedDate}) parseReportText(
    String rawText,
  ) {
    final detectedDate = _extractDate(rawText);
    final lines = rawText.split(RegExp(r'[\r\n;]+'));
    final byCode = <String, LabTestItem>{};

    // Sort aliases longest-first so "25-oh vitamin d" matches before "d".
    final aliasPairs = <(String alias, LabParameterSpec spec)>[];
    for (final spec in catalog) {
      for (final alias in spec.aliases) {
        aliasPairs.add((alias.toLowerCase(), spec));
      }
    }
    aliasPairs.sort((a, b) => b.$1.length.compareTo(a.$1.length));

    final numRegex = RegExp(r'(-?\d+(?:[.,]\d+)?)');

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final lower = _normalizeTr(line);

      for (final (alias, spec) in aliasPairs) {
        final normAlias = _normalizeTr(alias);
        final match = RegExp(
          '(^|[^a-z0-9])${RegExp.escape(normAlias)}([^a-z0-9]|\$)',
        ).firstMatch(lower);
        if (match == null) continue;

        final afterAlias = line.substring(match.end);
        final numMatch = numRegex.firstMatch(afterAlias);
        if (numMatch == null) continue;

        final rawNum = numMatch.group(1)!.replaceAll(',', '.');
        final parsed = double.tryParse(rawNum);
        if (parsed == null) continue;

        byCode[spec.code] = evaluateKnownParameter(
          spec: spec,
          value: parsed,
        );
        break;
      }
    }

    return (items: byCode.values.toList(), detectedDate: detectedDate);
  }

  /// Builds a complete storable [LabReportRecord] with overall clinical-awareness
  /// summary and specialty recommendation.
  static LabReportRecord buildReport({
    required String title,
    required DateTime reportDate,
    required LabReportSource source,
    required List<LabTestItem> items,
    String? rawReportText,
    String? notes,
  }) {
    final criticalItems = items.where((i) => i.status.isCritical).toList();
    final abnormalItems = items.where((i) => i.status.isAbnormal).toList();

    final String summary;
    if (items.isEmpty) {
      summary = 'Raporda ayrıştırılmış sayısal parametre bulunamadı.';
    } else if (criticalItems.isNotEmpty) {
      final names = criticalItems.map((e) => e.name).join(', ');
      summary =
          '${items.length} değer incelendi. Kritik aralıkta bulgu var ($names). Vakit kaybetmeden hekiminize başvurmanız önerilir.';
    } else if (abnormalItems.isNotEmpty) {
      final names = abnormalItems.map((e) => e.code).join(', ');
      summary =
          '${items.length} değerden ${abnormalItems.length} tanesi referans dışı ($names). Sonuçlarınızı önceki tahlillerinizle birlikte doktorunuza göstermeniz faydalı olur.';
    } else {
      summary =
          'Girilen ${items.length} tahlil değerinin tamamı genel yetişkin referans aralıkları içinde görünüyor.';
    }

    var specialty = 'Dahiliye';
    for (final item in [...criticalItems, ...abnormalItems]) {
      final spec = specByCode(item.code);
      if (spec != null && spec.specialtyHint != 'Dahiliye') {
        specialty = spec.specialtyHint;
        break;
      }
    }

    return LabReportRecord(
      id: 'lab_${reportDate.millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Kan Tahlili & Rapor' : title.trim(),
      reportDate: reportDate,
      source: source,
      items: items,
      overallSummary: summary,
      suggestedSpecialty: specialty,
      rawReportText: rawReportText,
      notes: notes,
    );
  }

  /// Aggregates dated reports into chronological trends per lab parameter.
  static List<LabParameterTrend> computeParameterTrends(
    List<LabReportRecord> reports,
  ) {
    final sortedReports = [...reports]
      ..sort((a, b) => a.reportDate.compareTo(b.reportDate));

    final grouped = <String, List<LabTrendPoint>>{};
    final meta = <String, LabTestItem>{};

    for (final report in sortedReports) {
      for (final item in report.items) {
        meta[item.code] = item;
        grouped.putIfAbsent(item.code, () => []).add(
              LabTrendPoint(
                date: report.reportDate,
                value: item.value,
                status: item.status,
              ),
            );
      }
    }

    final trends = grouped.entries.map((entry) {
      final lastItem = meta[entry.key]!;
      return LabParameterTrend(
        code: entry.key,
        name: lastItem.name,
        unit: lastItem.unit,
        refMin: lastItem.refMin,
        refMax: lastItem.refMax,
        points: entry.value,
      );
    }).toList();

    // Show parameters with multiple readings and abnormal values first.
    trends.sort((a, b) {
      final abA = a.latest.status.isAbnormal ? 0 : 1;
      final abB = b.latest.status.isAbnormal ? 0 : 1;
      if (abA != abB) return abA.compareTo(abB);
      return b.points.length.compareTo(a.points.length);
    });

    return trends;
  }

  /// Generates a clean doctor-shareable text summary for a saved lab report.
  static String formatReportForDoctor(LabReportRecord report) {
    final df = DateFormat('dd.MM.yyyy');
    final buf = StringBuffer()
      ..writeln('=== VisualCheckUp • Tahlil Değerlendirme Özeti ===')
      ..writeln('Rapor: ${report.title}')
      ..writeln('Tarih: ${df.format(report.reportDate)}')
      ..writeln('Danışılabilecek Bölüm: ${report.suggestedSpecialty}')
      ..writeln('Özet: ${report.overallSummary}')
      ..writeln('\nDeğerler:');

    for (final item in report.items) {
      buf.writeln(
        '- ${item.name}: ${item.formattedValue} [${item.status.label}] (Ref: ${item.referenceRangeText})',
      );
    }

    buf
      ..writeln('\n---')
      ..writeln(MedicalDisclaimer.shortBanner);
    return buf.toString().trim();
  }

  /// Generates a clean doctor-shareable text summary for dated BP & sugar logs.
  static String formatVitalsForDoctor({
    required List<BloodPressureReading> bpReadings,
    required List<BloodSugarReading> sugarReadings,
  }) {
    final df = DateFormat('dd.MM.yyyy HH:mm');
    final buf = StringBuffer()
      ..writeln('=== VisualCheckUp • Tansiyon & Şeker Takip Özeti ===');

    if (bpReadings.isNotEmpty) {
      final avgSys =
          bpReadings.map((e) => e.systolic).reduce((a, b) => a + b) /
              bpReadings.length;
      final avgDia =
          bpReadings.map((e) => e.diastolic).reduce((a, b) => a + b) /
              bpReadings.length;
      buf
        ..writeln(
          '\nTansiyon (${bpReadings.length} ölçüm • Ortalama: ${avgSys.round()}/${avgDia.round()} mmHg):',
        );
      for (final bp in bpReadings.take(10)) {
        final pulseText = bp.pulse != null ? ' • Nabız ${bp.pulse}' : '';
        buf.writeln(
          '- ${df.format(bp.recordedAt)}: ${bp.formatted}$pulseText (${bp.category.label})',
        );
      }
    }

    if (sugarReadings.isNotEmpty) {
      final avgSugar =
          sugarReadings.map((e) => e.valueMgDl).reduce((a, b) => a + b) /
              sugarReadings.length;
      buf
        ..writeln(
          '\nKan Şekeri (${sugarReadings.length} ölçüm • Ortalama: ${avgSugar.round()} mg/dL):',
        );
      for (final s in sugarReadings.take(10)) {
        buf.writeln(
          '- ${df.format(s.recordedAt)}: ${s.formatted} [${s.measurementType.label}] (${s.category.label})',
        );
      }
    }

    buf
      ..writeln('\n---')
      ..writeln(MedicalDisclaimer.shortBanner);
    return buf.toString().trim();
  }

  /// Token-compact prompt ready for Gemini Vision when reading photographed
  /// hospital / blood test reports with Cloud AI enabled.
  static String buildVisionExtractionPrompt() {
    return 'Fotoğraftaki hastane/kan tahlili raporundaki sayısal değerleri çıkar. '
        'Yalnızca şu JSON formatında yanıt ver: '
        '{"title":"Kan Tahlili","reportDate":"YYYY-MM-DD","items":[{"code":"HGB|WBC|PLT|GLU|HBA1C|FERRITIN|B12|VITD|TSH|ALT|AST|CREA|LDL|TRIG|CRP","value":0.0}]}. '
        'Okunamayan değerleri uydurma.';
  }

  static DateTime? _extractDate(String text) {
    final dmy = RegExp(r'\b(\d{2})[./-](\d{2})[./-](\d{4})\b').firstMatch(text);
    if (dmy != null) {
      final d = int.tryParse(dmy.group(1)!);
      final m = int.tryParse(dmy.group(2)!);
      final y = int.tryParse(dmy.group(3)!);
      if (d != null && m != null && y != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d);
      }
    }
    final ymd = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b').firstMatch(text);
    if (ymd != null) {
      final y = int.tryParse(ymd.group(1)!);
      final m = int.tryParse(ymd.group(2)!);
      final d = int.tryParse(ymd.group(3)!);
      if (d != null && m != null && y != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  static String _normalizeTr(String input) {
    return input
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g');
  }
}
