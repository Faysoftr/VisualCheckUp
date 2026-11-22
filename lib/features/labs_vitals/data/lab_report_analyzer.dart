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

  /// Builds a complete storable [LabReportRecord] combining blood test values
  /// with optional [hospitalDiagnosis], optional [userComplaintNote], and
  /// optional uploaded PDF/JPG attachment metadata.
  static LabReportRecord buildReport({
    required String title,
    required DateTime reportDate,
    required LabReportSource source,
    required List<LabTestItem> items,
    String? rawReportText,
    String? notes,
    String? hospitalDiagnosis,
    String? userComplaintNote,
    String? attachmentFileName,
    String? attachmentMimeType,
  }) {
    final cleanDiagnosis = _cleanOptional(hospitalDiagnosis);
    final cleanComplaint = _cleanOptional(userComplaintNote);
    final cleanFileName = _cleanOptional(attachmentFileName);
    final criticalItems = items.where((i) => i.status.isCritical).toList();
    final abnormalItems = items.where((i) => i.status.isAbnormal).toList();

    final String summary;
    if (items.isEmpty) {
      if (cleanDiagnosis != null) {
        summary =
            'Hastane teşhis notu ("$cleanDiagnosis") sade Türkçe ile açıklandı${cleanFileName != null ? ' ve $cleanFileName belgesi tarihli kaydedildi' : ''}.';
      } else if (cleanFileName != null) {
        summary =
            '$cleanFileName belgesi tarihli kaydedildi. Otomatik metin ayrıştırılamayan taranmış görsellerde değerleri manuel ekleyebilir veya Bulut AI analizini kullanabilirsiniz.';
      } else {
        summary = 'Raporda ayrıştırılmış sayısal parametre bulunamadı.';
      }
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

    final contextEval = _evaluateContext(
      items: items,
      hospitalDiagnosis: cleanDiagnosis,
      userComplaintNote: cleanComplaint,
      attachmentFileName: cleanFileName,
    );

    var specialty = contextEval.specialtyHint ?? 'Dahiliye';
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
      hospitalDiagnosis: cleanDiagnosis,
      userComplaintNote: cleanComplaint,
      attachmentFileName: cleanFileName,
      attachmentMimeType: attachmentMimeType,
      contextualInterpretation: contextEval.interpretation,
      followUpQuestions: contextEval.questions,
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
      ..writeln('Danışılabilecek Bölüm: ${report.suggestedSpecialty}');

    if (report.hasAttachment) {
      buf.writeln('Ekli Belge: ${report.attachmentFileName}');
    }
    if (report.hospitalDiagnosis != null) {
      buf.writeln('Hastane / Doktor Teşhisi: ${report.hospitalDiagnosis}');
    }
    if (report.userComplaintNote != null) {
      buf.writeln('Hasta Notu / Şikayet: ${report.userComplaintNote}');
    }
    buf.writeln('Özet: ${report.overallSummary}');

    if (report.contextualInterpretation != null) {
      buf
        ..writeln('\nAnlaşılır Değerlendirme:')
        ..writeln(report.contextualInterpretation);
    }

    if (report.items.isNotEmpty) {
      buf.writeln('\nDeğerler:');
      for (final item in report.items) {
        buf.writeln(
          '- ${item.name}: ${item.formattedValue} [${item.status.label}] (Ref: ${item.referenceRangeText})',
        );
      }
    }

    if (report.followUpQuestions.isNotEmpty) {
      buf.writeln('\nDoktorunuza Sorabileceğiniz Sorular:');
      for (final q in report.followUpQuestions) {
        buf.writeln('? $q');
      }
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
  /// or PDF hospital / blood test reports with Cloud AI enabled.
  static String buildVisionExtractionPrompt() {
    return 'Belgedeki (PDF veya fotoğraf) hastane/kan tahlili raporundaki sayısal değerleri çıkar. '
        'Yalnızca şu JSON formatında yanıt ver: '
        '{"title":"Kan Tahlili","reportDate":"YYYY-MM-DD","items":[{"code":"HGB|WBC|PLT|GLU|HBA1C|FERRITIN|B12|VITD|TSH|ALT|AST|CREA|LDL|TRIG|CRP","value":0.0}]}. '
        'Okunamayan değerleri uydurma.';
  }

  /// Builds a token-compact contextual Gemini AI prompt combining uploaded
  /// blood results (and optional PDF/JPG) with the patient's optional hospital
  /// diagnosis and/or own symptom text.
  static String buildContextualAiPrompt({
    required List<LabTestItem> items,
    String? hospitalDiagnosis,
    String? userComplaintNote,
    String? attachmentFileName,
  }) {
    final buf = StringBuffer()
      ..writeln(
        'Aşağıdaki kan tahlili sonuçlarını sade, anlaşılır ve korkutmayan Türkçe ile açıkla. Kesin tedavi/ilaç önerme; doktor kontrolüne hazırlık amaçlı özet sun.',
      );

    final diag = _cleanOptional(hospitalDiagnosis);
    final complaint = _cleanOptional(userComplaintNote);
    if (diag != null) {
      buf.writeln('Hastane/Doktor Teşhisi: "$diag" (Bu tıbbi terimin günlük dilde ne anlama geldiğini ve kan sonuçlarıyla ilişkisini açıkla.)');
    }
    if (complaint != null) {
      buf.writeln('Kullanıcı Şikayeti/Notu: "$complaint"');
    }
    if (attachmentFileName != null && attachmentFileName.isNotEmpty) {
      buf.writeln('Yüklenen Belge: $attachmentFileName');
    }
    if (items.isNotEmpty) {
      final compact = items
          .map((i) => '${i.code}=${i.formattedValue} [${i.status.label}]')
          .join(', ');
      buf.writeln('Kan Değerleri: $compact');
    }
    buf.writeln(
      'Yanıtta 3 kısa bölüm olsun: 1) Teşhis/Sonuç Sade Açıklaması, 2) Öne Çıkan Değerler, 3) Doktora Sorulabilecek 2-3 Soru.',
    );
    return buf.toString().trim();
  }

  static ({
    String interpretation,
    List<String> questions,
    String? specialtyHint,
  }) _evaluateContext({
    required List<LabTestItem> items,
    String? hospitalDiagnosis,
    String? userComplaintNote,
    String? attachmentFileName,
  }) {
    final byCode = {for (final i in items) i.code: i};
    final abnormal = items.where((i) => i.status.isAbnormal).toList();
    final paragraphs = <String>[];
    final questions = <String>[];
    String? specialtyHint;

    // 1. Plain-Turkish explanation of optional hospital diagnosis + blood correlation
    if (hospitalDiagnosis != null) {
      final normDiag = _normalizeTr(hospitalDiagnosis);
      final matched = _diagnosisGuides
          .where((g) => g.keywords.any((kw) => normDiag.contains(kw)))
          .toList();

      if (matched.isNotEmpty) {
        for (final guide in matched) {
          specialtyHint ??= guide.specialty;
          final linkedItems = guide.relatedCodes
              .map((c) => byCode[c])
              .whereType<LabTestItem>()
              .toList();

          final correlation = StringBuffer()
            ..write('• "${guide.displayTitle}" açıklaması: ${guide.plainExplanation}');

          if (linkedItems.isNotEmpty) {
            final abnormalLinked =
                linkedItems.where((e) => e.status.isAbnormal).toList();
            if (abnormalLinked.isNotEmpty) {
              final detail = abnormalLinked
                  .map((e) => '${e.name} (${e.formattedValue} — ${e.status.label})')
                  .join(', ');
              correlation.write(
                ' Yüklediğiniz kan sonucundaki $detail değeri bu teşhisle uyumlu görünüyor.',
              );
            } else {
              final detail =
                  linkedItems.map((e) => '${e.code}: ${e.formattedValue}').join(', ');
              correlation.write(
                ' İlgili kan değerleriniz ($detail) şu an genel referans aralığında görünüyor; kontrol veya tedavi sonrası dengelenmiş olabilir.',
              );
            }
          }
          paragraphs.add(correlation.toString());
          questions.add(guide.doctorQuestion);
        }
      } else {
        paragraphs.add(
          '• Hastane teşhisi ("$hospitalDiagnosis"): Bu tanı ifadesi farklı alt nedenlere bağlı olabilir. '
          '${abnormal.isNotEmpty ? 'Tahlilinizde öne çıkan ${abnormal.map((e) => '${e.code} (${e.status.label})').join(', ')} değerleriyle bağlantısını doktorunuzdan sade biçimde açıklamasını isteyebilirsiniz.' : 'Girilen kan değerleriniz genel referans aralığında görünse de tanınız görüntüleme, muayene veya farklı bir teste dayanıyor olabilir.'}',
        );
        questions.add(
          'Raporda yazan "$hospitalDiagnosis" tanısı günlük hayatımda ne anlama geliyor ve nelere dikkat etmeliyim?',
        );
      }
    }

    // 2. Optional user complaint / own note correlation with blood test
    if (userComplaintNote != null) {
      final normNote = _normalizeTr(userComplaintNote);
      final matchedNotes = <String>[];
      for (final link in _complaintLinks) {
        if (link.keywords.any((kw) => normNote.contains(kw))) {
          final abnormalMatches = link.relatedCodes
              .map((c) => byCode[c])
              .whereType<LabTestItem>()
              .where((i) => i.status.isAbnormal)
              .toList();
          if (abnormalMatches.isNotEmpty) {
            final joined = abnormalMatches
                .map((e) => '${e.name} (${e.formattedValue} — ${e.status.label})')
                .join(', ');
            matchedNotes.add(
              'Belirttiğiniz ${link.topicLabel} şikayeti, tahlilinizdeki $joined bulgusuyla ilişkili olabilir.',
            );
          } else {
            matchedNotes.add(
              'Belirttiğiniz ${link.topicLabel} şikayeti için kan sayımı ve ilgili parametrelerin doktorunuzca birlikte değerlendirilmesi faydalı olur.',
            );
          }
        }
      }

      if (matchedNotes.isNotEmpty) {
        paragraphs.add('• Şikayetinizle ilişki: ${matchedNotes.join(' ')}');
      } else {
        paragraphs.add(
          '• Kendi notunuz ("$userComplaintNote") rapora eklendi. Doktor muayenesinde bu şikayetlerin mevcut kan sonuçlarınızla bağlantısını sorabilirsiniz.',
        );
      }
    }

    // 3. Standalone blood test evaluation when diagnosis & complaint are blank
    if (hospitalDiagnosis == null && userComplaintNote == null) {
      if (abnormal.isNotEmpty) {
        final details = abnormal
            .map((e) => '${e.name} (${e.formattedValue} — ${e.status.label})')
            .join(', ');
        paragraphs.add(
          '• Yalnızca kan sonuçlarına göre ön değerlendirme: $details değerleri genel yetişkin referans aralığının dışında. Tek bir test tek başına tanı koymaz; şikayetleriniz ve önceki sonuçlarınızla birlikte doktor değerlendirmesi gerekir.',
        );
      } else if (items.isNotEmpty) {
        paragraphs.add(
          '• Yalnızca kan sonuçlarına göre ön değerlendirme: Girilen tüm değerler genel yetişkin referans aralığında görünüyor. Şikayetiniz sürüyorsa doktorunuz farklı tetkikler önerebilir.',
        );
      } else if (attachmentFileName != null) {
        paragraphs.add(
          '• $attachmentFileName belgesi arşivlendi. Taranmış fotoğraf/PDF içeriğindeki sayılar otomatik okunamadıysa aşağıdan manuel değer ekleyebilir veya isteğe bağlı Bulut Yapay Zeka ile okutabilirsiniz.',
        );
      }
    }

    // Standard helpful follow-up questions
    if (abnormal.isNotEmpty) {
      questions.add(
        'Referans dışı görünen ${abnormal.map((e) => e.code).join(', ')} değerlerim için ne zaman kontrol tahlili yaptırmalıyım?',
      );
    }
    questions.add(
      'Beslenme, su tüketimi veya kullandığım ilaç/takviyelerde değiştirmem gereken bir şey var mı?',
    );

    return (
      interpretation: paragraphs.join('\n\n'),
      questions: questions.toSet().take(4).toList(),
      specialtyHint: specialtyHint,
    );
  }

  static const List<_DiagnosisGuide> _diagnosisGuides = [
    _DiagnosisGuide(
      displayTitle: 'Anemi / Demir Eksikliği',
      keywords: ['anemi', 'kansizlik', 'demir eksikl', 'mikrositer'],
      plainExplanation:
          'Vücuda oksijen taşıyan kırmızı kan hücrelerinin veya demir depolarının azalması anlamına gelir; sıklıkla halsizlik, çabuk yorulma ve üşüme yapabilir.',
      relatedCodes: ['HGB', 'FERRITIN', 'B12'],
      specialty: 'Dahiliye veya Hematoloji',
      doctorQuestion:
          'Kansızlığımın/demir düşüklüğümün altında yatan neden araştırılmalı mı ve takviye ne kadar sürmeli?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Hipotiroidi / Tiroid Yavaşlaması',
      keywords: ['hipotiroid', 'hashimoto', 'tiroid yetmezl', 'subklinik hipo'],
      plainExplanation:
          'Tiroid bezinin metabolizmayı düzenleyen hormonları normalden az üretmesidir; yorgunluk, üşüme, kilo artışı ve cilt kuruluğuna yol açabilir.',
      relatedCodes: ['TSH'],
      specialty: 'Endokrinoloji veya Dahiliye',
      doctorQuestion:
          'TSH değerime göre ilaç dozu veya serbest T4 / tiroid antikoru takibi ne sıklıkla yapılmalı?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Hipertiroidi / Tiroid Fazla Çalışması',
      keywords: ['hipertiroid', 'tirotoksikoz', 'zehirli guatr', 'graves'],
      plainExplanation:
          'Tiroid bezinin gereğinden fazla hormon üretmesidir; çarpıntı, terleme, kilo kaybı ve huzursuzluk yapabilir.',
      relatedCodes: ['TSH'],
      specialty: 'Endokrinoloji veya Dahiliye',
      doctorQuestion:
          'Düşük TSH için tiroid ultrasonu veya sintigrafi gibi ek bir inceleme gerekiyor mu?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Prediyabet / İnsülin Direnci / Diyabet',
      keywords: [
        'prediyabet',
        'diyabet',
        'seker hastal',
        'insulin direnc',
        'tip 2',
        'hiperglisemi',
      ],
      plainExplanation:
          'Kan şekerinin hücreler tarafından verimli kullanılmasında zorlanma veya kan şekerinin normalin üzerinde seyretmesidir; beslenme, hareket ve doktor takibiyle yönetilebilir.',
      relatedCodes: ['GLU', 'HBA1C', 'TRIG'],
      specialty: 'Endokrinoloji veya Dahiliye',
      doctorQuestion:
          'Açlık/tokluk şekeri ve HbA1c hedef aralığım ne olmalı, evde hangi sıklıkla şeker ölçmeliyim?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Hepatosteatoz / Karaciğer Yağlanması',
      keywords: ['hepatosteatoz', 'karaciger yaglan', 'steatoz', 'transaminaz'],
      plainExplanation:
          'Karaciğer hücrelerinde normalden fazla yağ birikmesidir (Grade 1 hafif, Grade 2 orta, Grade 3 ileri düzey). Çoğunlukla beslenme düzeni, kilo kontrolü ve egzersizle gerileyebilir.',
      relatedCodes: ['ALT', 'AST', 'TRIG', 'GLU'],
      specialty: 'Dahiliye veya Gastroenteroloji',
      doctorQuestion:
          'Karaciğer enzimlerime göre yaşam tarzı değişikliği yeterli mi yoksa ek karaciğer testi gerekir mi?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Hiperlipidemi / Kolesterol Yüksekliği',
      keywords: ['hiperlipidemi', 'dislipidemi', 'kolesterol', 'trigliserid'],
      plainExplanation:
          'Kandaki yağ (LDL kolesterol veya trigliserid) düzeylerinin hedeflenen sınırın üzerinde olmasıdır; uzun vadede damar sağlığı için takip edilir.',
      relatedCodes: ['LDL', 'TRIG'],
      specialty: 'Dahiliye veya Kardiyoloji',
      doctorQuestion:
          'Kardiyovasküler risk profilime göre LDL ve trigliserid hedef değerim kaç olmalı?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Enfeksiyon / İltihabi Süreç',
      keywords: ['enfeksiyon', 'iye', 'idrar yolu', 'lokositoz', 'iltihap', 'bron', 'farenjit'],
      plainExplanation:
          'Bağışıklık sisteminin bakteri veya virüs gibi bir etkene karşı verdiği savunma yanıtıdır; bu süreçte WBC ve CRP geçici olarak yükselebilir.',
      relatedCodes: ['WBC', 'CRP'],
      specialty: 'Dahiliye',
      doctorQuestion:
          'Tedavim bittikten sonra CRP/WBC kontrol tahlili yaptırmam gerekiyor mu?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Vitamin Eksikliği (D Vitamini / B12)',
      keywords: ['vitamin eksikl', 'b12 eksikl', 'd vitamini eksikl', 'hipovitaminoz'],
      plainExplanation:
          'Sinir sistemi, enerji metabolizması veya kemik-kas sağlığı için gerekli vitamin depolarının düşmesidir; hekim önerili dozlarda takviyeyle genellikle hızla toparlanır.',
      relatedCodes: ['VITD', 'B12', 'FERRITIN'],
      specialty: 'Dahiliye',
      doctorQuestion:
          'Hangi dozda ve ne kadar süre vitamin takviyesi kullanıp tekrar kontrol ettirmeliyim?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Trombositopeni / Pıhtılaşma Takibi',
      keywords: ['trombositopeni', 'trombosit dusuk', 'koagul'],
      plainExplanation:
          'Kanın pıhtılaşmasını sağlayan trombosit hücrelerinin referansın altında olmasıdır; kolay morarma veya diş eti kanaması açısından takip edilir.',
      relatedCodes: ['PLT', 'HGB'],
      specialty: 'Hematoloji veya Dahiliye',
      doctorQuestion:
          'Trombosit değerim için periferik yayma veya ileri hematoloji değerlendirmesi gerekir mi?',
    ),
    _DiagnosisGuide(
      displayTitle: 'Böbrek Fonksiyon Takibi',
      keywords: ['bobrek', 'kreatinin', 'nefropati', 'egfr'],
      plainExplanation:
          'Böbreklerin kandaki atıkları süzme performansının izlenmesidir; su tüketimi, tansiyon ve ağrı kesici kullanımı bu değerleri etkileyebilir.',
      relatedCodes: ['CREA'],
      specialty: 'Dahiliye veya Nefroloji',
      doctorQuestion:
          'Kreatinin ve eGFR değerime göre günlük su tüketimi ve ağrı kesici kullanımında nelere dikkat etmeliyim?',
    ),
  ];

  static const List<_ComplaintLink> _complaintLinks = [
    _ComplaintLink(
      topicLabel: 'halsizlik / yorgunluk',
      keywords: ['halsiz', 'yorgun', 'bitkin', 'uykulu', 'enerji'],
      relatedCodes: ['HGB', 'FERRITIN', 'B12', 'VITD', 'TSH'],
    ),
    _ComplaintLink(
      topicLabel: 'saç dökülmesi / tırnak kırılması',
      keywords: ['sac dok', 'tirnak', 'dokulme'],
      relatedCodes: ['FERRITIN', 'B12', 'VITD', 'TSH'],
    ),
    _ComplaintLink(
      topicLabel: 'üşüme / kilo değişimi',
      keywords: ['usu', 'kilo', 'odem', 'siskin'],
      relatedCodes: ['TSH', 'GLU', 'HBA1C'],
    ),
    _ComplaintLink(
      topicLabel: 'çarpıntı / baş dönmesi',
      keywords: ['carpinti', 'bas don', 'nefes'],
      relatedCodes: ['HGB', 'FERRITIN', 'TSH'],
    ),
    _ComplaintLink(
      topicLabel: 'susama / sık idrar',
      keywords: ['susa', 'agiz kuru', 'sik idrar', 'seker'],
      relatedCodes: ['GLU', 'HBA1C'],
    ),
    _ComplaintLink(
      topicLabel: 'morarma / kanama',
      keywords: ['morar', 'kanama', 'morluk'],
      relatedCodes: ['PLT', 'HGB'],
    ),
    _ComplaintLink(
      topicLabel: 'ateş / enfeksiyon belirtisi',
      keywords: ['ates', 'yanma', 'bogaz', 'oksuruk', 'agri'],
      relatedCodes: ['WBC', 'CRP'],
    ),
  ];

  static String? _cleanOptional(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
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

class _DiagnosisGuide {
  const _DiagnosisGuide({
    required this.displayTitle,
    required this.keywords,
    required this.plainExplanation,
    required this.relatedCodes,
    required this.specialty,
    required this.doctorQuestion,
  });

  final String displayTitle;
  final List<String> keywords;
  final String plainExplanation;
  final List<String> relatedCodes;
  final String specialty;
  final String doctorQuestion;
}

class _ComplaintLink {
  const _ComplaintLink({
    required this.topicLabel,
    required this.keywords,
    required this.relatedCodes,
  });

  final String topicLabel;
  final List<String> keywords;
  final List<String> relatedCodes;
}

