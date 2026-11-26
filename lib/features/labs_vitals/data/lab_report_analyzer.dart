import 'package:intl/intl.dart';
import 'package:visualcheckup/core/constants/medical_disclaimer.dart';
import 'package:visualcheckup/features/labs_vitals/data/lab_unit_converter.dart';
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
    LabParameterSpec(
      code: 'HDL',
      name: 'HDL Kolesterol',
      aliases: ['hdl kolesterol', 'hdl-kolesterol', 'hdl'],
      unit: 'mg/dL',
      minNormal: 50,
      maxNormal: 120,
      lowNote:
          'Koruyucu HDL kolesterol düşük görünüyor; düzenli egzersiz ve beslenme planı için doktorunuza danışabilirsiniz.',
      highNote: 'Yüksek HDL kolesterol genellikle kalp-damar sağlığı açısından koruyucu kabul edilir.',
      specialtyHint: 'Dahiliye veya Kardiyoloji',
    ),
    LabParameterSpec(
      code: 'TOTAL_CHOL',
      name: 'Total Kolesterol',
      aliases: ['total kolesterol', 'toplam kolesterol', 'total cholesterol', 'kolesterol'],
      unit: 'mg/dL',
      minNormal: 0,
      maxNormal: 200,
      criticalHigh: 300,
      lowNote: 'Referans aralığında.',
      highNote: 'Toplam kolesterol sınırın üzerinde; LDL, HDL ve trigliserit ile birlikte değerlendirilmelidir.',
      specialtyHint: 'Dahiliye veya Kardiyoloji',
    ),
    LabParameterSpec(
      code: 'IRON',
      name: 'Demir (Serum)',
      aliases: ['serum demir', 'demir (fe)', 'demir', 'iron'],
      unit: 'µg/dL',
      minNormal: 60,
      maxNormal: 180,
      lowNote: 'Serum demir düşük; ferritin ve tam kan sayımı ile birlikte demir eksikliği açısından değerlendirilebilir.',
      highNote: 'Serum demir yüksek; demir takviyesi veya karaciğer değerlendirmesi için hekime danışın.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'TIBC',
      name: 'Demir Bağlama Kapasitesi',
      aliases: ['demir bağlama kapasitesi', 'demir baglama kapasitesi', 'demir bağlama', 'demir baglama', 'tibc', 'uibc'],
      unit: 'µg/dL',
      minNormal: 155,
      maxNormal: 355,
      lowNote: 'Demir bağlama kapasitesi düşük; hekiminizle birlikte değerlendirin.',
      highNote: 'Yüksek demir bağlama kapasitesi sıklıkla demir eksikliğine eşlik edebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'FOLATE',
      name: 'Folat (Folik Asit)',
      aliases: ['folik asit', 'folat', 'folate'],
      unit: 'µg/L',
      minNormal: 3.2,
      maxNormal: 20.0,
      lowNote: 'Folat düşüklüğü kansızlık ve halsizlik ile ilişkili olabilir; B12 ile birlikte değerlendirilir.',
      highNote: 'Genellikle takviye kullanımına bağlıdır.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'UREA',
      name: 'Üre',
      aliases: ['kan üre', 'kan ure', 'üre', 'ure', 'urea', 'bun'],
      unit: 'mg/dL',
      minNormal: 17,
      maxNormal: 43,
      criticalHigh: 100,
      lowNote: 'Düşük üre çoğunlukla beslenme veya sıvı fazlalığıyla ilişkilidir.',
      highNote: 'Üre yüksekliği sıvı azlığı, yüksek protein alımı veya böbrek fonksiyonu açısından kreatinin ile değerlendirilir.',
      specialtyHint: 'Dahiliye veya Nefroloji',
    ),
    LabParameterSpec(
      code: 'EGFR',
      name: 'eGFR (Böbrek Süzme Hızı)',
      aliases: ['egfr', 'gfr', 'glomerüler filtrasyon'],
      unit: 'mL/dk/1.73m²',
      minNormal: 60,
      maxNormal: 150,
      criticalLow: 30,
      lowNote: 'Böbrek süzme hızı referansın altında; kreatinin ile birlikte doktor değerlendirmesi gerekir.',
      highNote: 'Normal böbrek süzme performansı.',
      specialtyHint: 'Dahiliye veya Nefroloji',
    ),
    LabParameterSpec(
      code: 'HCT',
      name: 'Hematokrit (HCT)',
      aliases: ['hematokrit', 'hct'],
      unit: '%',
      minNormal: 36,
      maxNormal: 48,
      criticalLow: 24,
      criticalHigh: 58,
      lowNote: 'Hematokrit düşük; hemoglobin ile birlikte anemi açısından değerlendirilir.',
      highNote: 'Hematokrit yüksek; sıvı azlığı veya kan yoğunlaşması açısından hekim kontrolü önerilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'RBC',
      name: 'Eritrosit (RBC)',
      aliases: ['eritrosit', 'rbc', 'kırmızı küre'],
      unit: '10^6/mm³',
      minNormal: 3.5,
      maxNormal: 5.5,
      lowNote: 'Kırmızı kan hücresi düşük; HGB ve ferritin ile birlikte değerlendirilebilir.',
      highNote: 'Kırmızı kan hücresi yüksek; hekim değerlendirmesi önerilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'MCV',
      name: 'MCV',
      aliases: ['mcv'],
      unit: 'fL',
      minNormal: 80,
      maxNormal: 100,
      lowNote: 'Küçük eritrosit hacmi (mikrositoz); demir eksikliği veya talasemi taşıyıcılığı ile ilişkili olabilir.',
      highNote: 'Büyük eritrosit hacmi (makrositoz); B12 veya folat eksikliği açısından değerlendirilebilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'MCH',
      name: 'MCH',
      aliases: ['mch'],
      unit: 'pg',
      minNormal: 27,
      maxNormal: 34,
      lowNote: 'Referansın altında; MCV ve demir depolarıyla birlikte yorumlanır.',
      highNote: 'Referansın üzerinde; B12 ve folat ile birlikte değerlendirilebilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'MCHC',
      name: 'MCHC',
      aliases: ['mchc'],
      unit: 'g/dL',
      minNormal: 32,
      maxNormal: 36,
      lowNote: 'Referansın altında; demir durumu ile birlikte değerlendirilir.',
      highNote: 'Referansın üzerinde; tam kan sayımı bütünüyle değerlendirilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'RDW',
      name: 'RDW',
      aliases: ['rdw-cv', 'rdw-sd', 'rdw'],
      unit: '%',
      minNormal: 11,
      maxNormal: 16,
      lowNote: 'Referans aralığında.',
      highNote: 'Eritrosit boyut dağılımı artmış; demir, B12 veya folat eksikliği başlangıcında yükselebilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'MPV',
      name: 'MPV',
      aliases: ['mpv'],
      unit: 'fL',
      minNormal: 6.5,
      maxNormal: 12.0,
      lowNote: 'Ortalama trombosit hacmi düşük; PLT ile birlikte yorumlanır.',
      highNote: 'Ortalama trombosit hacmi yüksek; PLT ile birlikte hekim tarafından değerlendirilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'PCT',
      name: 'PCT (Plateletkrit)',
      aliases: ['pct'],
      unit: '%',
      minNormal: 0.108,
      maxNormal: 0.282,
      lowNote: 'Trombosit hacim oranı düşük; PLT ile birlikte değerlendirilir.',
      highNote: 'Trombosit hacim oranı sınırın biraz üzerinde; PLT normal ise tek başına klinik anlamı sınırlı olabilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'PDW',
      name: 'PDW',
      aliases: ['pdw'],
      unit: '%',
      minNormal: 15,
      maxNormal: 17,
      lowNote: 'Trombosit dağılım genişliği düşük; PLT ile birlikte yorumlanır.',
      highNote: 'Trombosit dağılım genişliği yüksek; PLT ile birlikte yorumlanır.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'NEU_ABS',
      name: 'Nötrofil (NEU#)',
      aliases: ['neu#', 'neut#', 'nötrofil#', 'notrofil#'],
      unit: '10^3/mm³',
      minNormal: 2.0,
      maxNormal: 7.0,
      lowNote: 'Nötrofil sayısı düşük; enfeksiyon riski açısından hekim kontrolü önemlidir.',
      highNote: 'Nötrofil sayısı yüksek; enfeksiyon veya iltihabi yanıtla ilişkili olabilir.',
      specialtyHint: 'Dahiliye veya Hematoloji',
    ),
    LabParameterSpec(
      code: 'NEU_PCT',
      name: 'Nötrofil % (NEU%)',
      aliases: ['neu%', 'neut%', 'nötrofil%', 'notrofil%'],
      unit: '%',
      minNormal: 50,
      maxNormal: 70,
      lowNote: 'Nötrofil yüzdesi düşük; WBC ve NEU# ile birlikte değerlendirilir.',
      highNote: 'Nötrofil yüzdesi yüksek; hafif enfeksiyon, stres veya iltihabi süreçlerde görülebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'LYM_ABS',
      name: 'Lenfosit (LYM#)',
      aliases: ['lym#', 'lymph#', 'lenfosit#'],
      unit: '10^3/mm³',
      minNormal: 0.8,
      maxNormal: 4.0,
      lowNote: 'Lenfosit sayısı düşük; WBC ve klinik durumla birlikte değerlendirilir.',
      highNote: 'Lenfosit sayısı yüksek; viral enfeksiyonlar sonrası görülebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'LYM_PCT',
      name: 'Lenfosit % (LYM%)',
      aliases: ['lym%', 'lymph%', 'lenfosit%'],
      unit: '%',
      minNormal: 20,
      maxNormal: 40,
      lowNote: 'Lenfosit yüzdesi düşük; mutlak lenfosit (LYM#) normal ise genellikle göreceli bir değişikliktir.',
      highNote: 'Lenfosit yüzdesi yüksek; viral süreçler ve bağışıklık yanıtıyla ilişkili olabilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'MON_ABS',
      name: 'Monosit (MON#)',
      aliases: ['mon#', 'mono#', 'monosit#'],
      unit: '10^3/mm³',
      minNormal: 0.12,
      maxNormal: 1.20,
      lowNote: 'Referansın altında; WBC ile birlikte yorumlanır.',
      highNote: 'Referansın üzerinde; enfeksiyon iyileşme dönemi veya iltihabi süreçlerde görülebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'MON_PCT',
      name: 'Monosit % (MON%)',
      aliases: ['mon%', 'mono%', 'monosit%'],
      unit: '%',
      minNormal: 3,
      maxNormal: 12,
      lowNote: 'Referansın altında; MON# ile birlikte değerlendirilir.',
      highNote: 'Referansın üzerinde; MON# ile birlikte değerlendirilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'EOS_ABS',
      name: 'Eozinofil (EOS#)',
      aliases: ['eos#', 'eozinofil#'],
      unit: '10^3/mm³',
      minNormal: 0.02,
      maxNormal: 0.70,
      lowNote: 'Normal aralıkta kabul edilir.',
      highNote: 'Alerjik durumlar veya paraziter süreçlerle ilişkili olabilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'EOS_PCT',
      name: 'Eozinofil % (EOS%)',
      aliases: ['eos%', 'eozinofil%'],
      unit: '%',
      minNormal: 0.5,
      maxNormal: 7.0,
      lowNote: 'Genellikle klinik sorun oluşturmaz.',
      highNote: 'Alerjik eğilim açısından EOS# ile birlikte değerlendirilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'BAS_ABS',
      name: 'Bazofil (BAS#)',
      aliases: ['bas#', 'baso#', 'bazofil#'],
      unit: '10^3/mm³',
      minNormal: 0.0,
      maxNormal: 0.10,
      lowNote: 'Normal aralıkta.',
      highNote: 'Alerjik veya hematolojik değerlendirme açısından hekimle paylaşılabilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'BAS_PCT',
      name: 'Bazofil % (BAS%)',
      aliases: ['bas%', 'baso%', 'bazofil%'],
      unit: '%',
      minNormal: 0,
      maxNormal: 1,
      lowNote: 'Normal aralıkta.',
      highNote: 'BAS# ile birlikte değerlendirilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'GGT',
      name: 'GGT',
      aliases: ['ggt', 'gama glutamil transferaz'],
      unit: 'U/L',
      minNormal: 0,
      maxNormal: 55,
      lowNote: 'Normal aralıkta.',
      highNote: 'Safra yolları, karaciğer yağlanması veya ilaç etkisi açısından ALT/AST ile birlikte değerlendirilir.',
      specialtyHint: 'Dahiliye veya Gastroenteroloji',
    ),
    LabParameterSpec(
      code: 'URIC_ACID',
      name: 'Ürik Asit',
      aliases: ['ürik asit', 'urik asit', 'uric acid'],
      unit: 'mg/dL',
      minNormal: 2.6,
      maxNormal: 7.0,
      lowNote: 'Genellikle klinik sorun oluşturmaz.',
      highNote: 'Gut eğilimi, beslenme ve böbrek fonksiyonu açısından değerlendirilebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'NA',
      name: 'Sodyum (Na)',
      aliases: ['sodyum', 'sodium'],
      unit: 'mmol/L',
      minNormal: 136,
      maxNormal: 145,
      criticalLow: 125,
      criticalHigh: 155,
      lowNote: 'Sodyum düşüklüğü sıvı-elektrolit dengesi açısından doktor değerlendirmesi gerektirir.',
      highNote: 'Sodyum yüksekliği sıvı eksikliği açısından değerlendirilmelidir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'K',
      name: 'Potasyum (K)',
      aliases: ['potasyum', 'potassium'],
      unit: 'mmol/L',
      minNormal: 3.5,
      maxNormal: 5.1,
      criticalLow: 2.8,
      criticalHigh: 6.0,
      lowNote: 'Potasyum düşüklüğü kas güçsüzlüğü ve ritim açısından hekim kontrolü gerektirir.',
      highNote: 'Potasyum yüksekliği böbrek fonksiyonu ve kalp ritmi açısından acil değerlendirme gerektirebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'CA',
      name: 'Kalsiyum (Ca)',
      aliases: ['kalsiyum', 'calcium'],
      unit: 'mg/dL',
      minNormal: 8.6,
      maxNormal: 10.2,
      lowNote: 'Kalsiyum düşük; D vitamini ve paratiroid ile birlikte değerlendirilir.',
      highNote: 'Kalsiyum yüksek; hekim değerlendirmesi önerilir.',
      specialtyHint: 'Dahiliye veya Endokrinoloji',
    ),
    LabParameterSpec(
      code: 'TBIL',
      name: 'Total Bilirubin',
      aliases: ['total bilirubin', 'bilirubin total', 'bilirubin', 'tbil', 't. bili'],
      unit: 'mg/dL',
      minNormal: 0.1,
      maxNormal: 1.2,
      criticalHigh: 3.0,
      lowNote: 'Referans aralığında.',
      highNote:
          'Bilirubin yüksekliği göz/cilt sarılığı, safra yolları veya karaciğer açısından doktor değerlendirmesi gerektirir.',
      specialtyHint: 'Dahiliye veya Gastroenteroloji',
    ),
    LabParameterSpec(
      code: 'ALP',
      name: 'Alkalen Fosfataz (ALP)',
      aliases: ['alkalen fosfataz', 'alkaline phosphatase', 'alp'],
      unit: 'U/L',
      minNormal: 35,
      maxNormal: 130,
      lowNote: 'Genellikle klinik sorun oluşturmaz.',
      highNote:
          'Karaciğer, safra yolları veya kemik metabolizması açısından GGT ve kalsiyum ile birlikte değerlendirilir.',
      specialtyHint: 'Dahiliye veya Gastroenteroloji',
    ),
    LabParameterSpec(
      code: 'ALB',
      name: 'Albümin',
      aliases: ['albümin', 'albumin', 'alb'],
      unit: 'g/dL',
      minNormal: 3.5,
      maxNormal: 5.2,
      criticalLow: 2.5,
      lowNote:
          'Albümin düşüklüğü beslenme durumu, karaciğer veya böbrek protein kaybı açısından değerlendirilir.',
      highNote: 'Genellikle sıvı azlığına bağlı hafif yükselebilir.',
      specialtyHint: 'Dahiliye',
    ),
    LabParameterSpec(
      code: 'ESR',
      name: 'Sedimantasyon (ESR)',
      aliases: ['sedimantasyon', 'sedimentation', 'esr'],
      unit: 'mm/saat',
      minNormal: 0,
      maxNormal: 20,
      criticalHigh: 80,
      lowNote: 'Normal aralıkta.',
      highNote:
          'Vücutta iltihabi veya romatizmal süreçlere eşlik edebilir; CRP ile birlikte hekim tarafından değerlendirilir.',
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

  /// Returns core checkup parameters from [LabUnitConverter.coreCheckupCodes]
  /// that were NOT present in the uploaded/entered [items], so the UI can
  /// transparently tell elderly/general users "Not included in this report"
  /// rather than leaving silent gaps.
  static List<LabParameterSpec> findMissingCoreParameters(
    List<LabTestItem> items,
  ) {
    final presentCodes = items.map((e) => e.code.toUpperCase()).toSet();
    final missing = <LabParameterSpec>[];
    for (final code in LabUnitConverter.coreCheckupCodes) {
      if (!presentCodes.contains(code)) {
        final spec = specByCode(code);
        if (spec != null) missing.add(spec);
      }
    }
    return missing;
  }

  /// Evaluates a single known parameter against its adult reference spec
  /// (or hospital-supplied unit/reference range when provided).
  static LabTestItem evaluateKnownParameter({
    required LabParameterSpec spec,
    required double value,
    String? customUnit,
    double? customRefMin,
    double? customRefMax,
  }) {
    final hasCustomRange = customRefMin != null || customRefMax != null;
    final minRef = hasCustomRange ? customRefMin : spec.minNormal;
    final maxRef = hasCustomRange ? customRefMax : spec.maxNormal;
    final unit =
        (customUnit != null && customUnit.trim().isNotEmpty) ? customUnit.trim() : spec.unit;

    final LabStatus status;
    final String note;

    if (spec.criticalLow != null && value <= spec.criticalLow!) {
      status = LabStatus.criticalLow;
      note = '${spec.lowNote} Belirgin düşük değer; gecikmeden doktora başvurun.';
    } else if (spec.criticalHigh != null && value >= spec.criticalHigh!) {
      status = LabStatus.criticalHigh;
      note = '${spec.highNote} Belirgin yüksek değer; gecikmeden doktora başvurun.';
    } else if (minRef != null && value < minRef) {
      status = LabStatus.low;
      note = spec.lowNote;
    } else if (maxRef != null && value > maxRef) {
      status = LabStatus.high;
      note = spec.highNote;
    } else {
      status = LabStatus.normal;
      note = 'Referans aralığı içinde görünüyor.';
    }

    return LabTestItem(
      code: spec.code,
      name: spec.name,
      value: value,
      unit: unit,
      refMin: minRef,
      refMax: maxRef,
      status: status,
      note: note,
    );
  }

  /// Evaluates ANY extracted lab test row (known catalog OR custom/dynamic
  /// hospital parameter) into a normalized [LabTestItem] so cross-hospital
  /// and cross-country reports align automatically in the comparison table.
  static LabTestItem evaluateExtractedItem({
    required String rawName,
    required double value,
    String? unit,
    double? refMin,
    double? refMax,
  }) {
    final cleanName = _cleanLabel(rawName);
    final matchedSpec = _matchCatalogSpec(cleanName);
    final cleanUnit = (unit ?? '').trim();

    if (matchedSpec != null) {
      // Automatically convert international SI units (mmol/L, g/L, umol/L,
      // nmol/L, pmol/L, mmol/mol IFCC, /uL, BUN) into canonical conventional
      // units so thresholds and cross-country comparisons stay 100% consistent.
      final normalized = LabUnitConverter.normalizeToCanonical(
        code: matchedSpec.code,
        value: value,
        rawUnit: cleanUnit,
        canonicalUnit: matchedSpec.unit,
        rawName: cleanName,
        refMin: refMin,
        refMax: refMax,
      );

      // Special clinical safeguard for HDL: many Turkish e-Nabız reports print
      // "< 50 *" as the risk flag threshold rather than an upper limit (HDL < 50
      // is LOW for women, not high).
      var adjMin = normalized.refMin;
      var adjMax = normalized.refMax;
      if (matchedSpec.code == 'HDL' && adjMin == null && adjMax != null && adjMax <= 60) {
        adjMin = adjMax;
        adjMax = null;
      }

      return evaluateKnownParameter(
        spec: matchedSpec,
        value: normalized.value,
        customUnit: normalized.unit.isNotEmpty ? normalized.unit : null,
        customRefMin: adjMin,
        customRefMax: adjMax,
      );
    }

    // Dynamic / hospital-specific parameter not in the built-in catalog:
    final code = _canonicalDynamicCode(cleanName);
    final LabStatus status;
    final String note;
    if (refMin != null && value < refMin) {
      status = LabStatus.low;
      note = 'Hastane referans alt sınırının altında; doktorunuzla değerlendirin.';
    } else if (refMax != null && value > refMax) {
      status = LabStatus.high;
      note = 'Hastane referans üst sınırının üzerinde; doktorunuzla değerlendirin.';
    } else if (refMin != null || refMax != null) {
      status = LabStatus.normal;
      note = 'Hastane referans aralığı içinde görünüyor.';
    } else {
      status = LabStatus.normal;
      note = 'Rapordan okundu; önceki ve sonraki tahlillerinizle kıyaslanabilir.';
    }

    return LabTestItem(
      code: code,
      name: cleanName,
      value: value,
      unit: cleanUnit,
      refMin: refMin,
      refMax: refMax,
      status: status,
      note: note,
    );
  }

  /// Universal offline parser for hospital / e-Nabız / private-lab report text.
  ///
  /// Handles multi-line wrapped rows (e.g. e-Nabız PDFs where unit or reference
  /// range wraps to the next line), preserves hospital reference ranges and units,
  /// and captures BOTH known catalog parameters AND any unknown/custom test rows.
  static ({
    List<LabTestItem> items,
    DateTime? detectedDate,
    String? detectedHospital,
  }) parseReportText(
    String rawText,
  ) {
    final detectedDate = _extractDate(rawText);
    final detectedHospital = _extractHospitalName(rawText);
    final mergedLines = _preprocessReportLines(rawText);
    final byCode = <String, LabTestItem>{};

    // Pass 1 & 2 unified per line: extract <name> <value> <unit> <refRange>
    for (final line in mergedLines) {
      if (_isNoiseOrHeaderLine(line)) continue;

      final parsedRow = _parseStructuredRow(line);
      if (parsedRow != null) {
        final item = evaluateExtractedItem(
          rawName: parsedRow.name,
          value: parsedRow.value,
          unit: parsedRow.unit,
          refMin: parsedRow.refMin,
          refMax: parsedRow.refMax,
        );
        byCode[item.code] = item;
        continue;
      }

      // Fallback for free-form pasted text (e.g. "Hemoglobin: 11.4 g/dL; Ferritin = 14")
      final knownFallback = _parseKnownAliasFallback(line);
      if (knownFallback != null) {
        byCode[knownFallback.code] = knownFallback;
      }
    }

    return (
      items: byCode.values.toList(),
      detectedDate: detectedDate,
      detectedHospital: detectedHospital,
    );
  }

  /// Reassembles both horizontal multi-line wrapped rows AND vertical
  /// cell-per-line table exports (e.g. `Demir \n 127 \n ug/L \n 60 - 180`,
  /// `PCT 0,29 % \n 0,108 - 0,282`, `eGFR 111 mL/dk/1.73 \n m2 \n 60 - 120`).
  static List<String> _preprocessReportLines(String rawText) {
    final rawLines = rawText
        .split(RegExp(r'[\r\n;]+'))
        .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final standaloneNumberRegex = RegExp(r'^-?\d+(?:[.,]\d+)?$');
    final standaloneRefRegex = RegExp(
      r'^(?:[<>≤≥]\s*-?\d+(?:[.,]\d+)?(?:\s*\*)?|-?\d+(?:[.,]\d+)?\s*[-–—]\s*-?\d+(?:[.,]\d+)?(?:\s*\*)?)$',
    );
    final standaloneUnitContRegex = RegExp(
      r'^(?:m2|m²|mm\^?3|/L|/dL|/mL|/uL|/µL|/mm3|/dk/1\.73\s*m2)$',
      caseSensitive: false,
    );

    final merged = <String>[];
    var i = 0;
    while (i < rawLines.length) {
      final line = rawLines[i];

      // Case 1: Vertical cell-per-line row:
      //   Line i:   test label (e.g. "Demir", "HGB", "Demir Bağlama")
      //   Line i+1: pure numeric value (e.g. "127", "13,7")
      //   Line i+2 (optional): unit (e.g. "ug/L", "g/dL", "%", "10^3/mm^3")
      //   Line i+3 (optional): reference range (e.g. "60 - 180", "< 50 *")
      if (i + 1 < rawLines.length &&
          _looksLikeStandaloneTestLabel(line) &&
          standaloneNumberRegex.hasMatch(rawLines[i + 1])) {
        final buf = StringBuffer('$line ${rawLines[i + 1]}');
        var next = i + 2;
        if (next < rawLines.length && _isUnitToken(rawLines[next])) {
          buf.write(' ${rawLines[next]}');
          next++;
          if (next < rawLines.length &&
              standaloneUnitContRegex.hasMatch(rawLines[next])) {
            buf.write(' ${rawLines[next]}');
            next++;
          }
        }
        if (next < rawLines.length &&
            standaloneRefRegex.hasMatch(rawLines[next])) {
          buf.write(' ${rawLines[next]}');
          next++;
        }
        merged.add(buf.toString());
        i = next;
        continue;
      }

      // Case 2: Wrapped reference range or unit continuation belonging to the
      // previous line (e.g. "PCT 0,29 %" followed by "0,108 - 0,282").
      if (merged.isNotEmpty &&
          (standaloneRefRegex.hasMatch(line) ||
              standaloneUnitContRegex.hasMatch(line))) {
        merged[merged.length - 1] = '${merged.last} $line';
        i++;
        continue;
      }

      merged.add(line);
      i++;
    }
    return merged;
  }

  static bool _looksLikeStandaloneTestLabel(String line) {
    if (line.length < 2 || line.length > 56) return false;
    if (_isUnitToken(line)) return false;
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(line)) return false;
    final lower = _normalizeTr(line);
    const nonLabels = [
      'tarih',
      'tahlil',
      'sonuc',
      'sonuc birimi',
      'birimi',
      'referans',
      'referans degeri',
      'degeri',
      'sayfa',
      'cinsiyet',
      'adi/soyadi',
      'dogum tarihi',
      'saglik tesisi',
      'tam kan (hemogram)',
      'hemogram',
      'test',
      'result',
      'units',
      'reference interval',
      'reference range',
      'flag',
    ];
    if (nonLabels.contains(lower)) return false;
    if (lower.startsWith('sayfa ') || lower.contains('enabiz')) return false;
    return true;
  }

  /// Returns true when [text] is purely a laboratory measurement unit
  /// (so it is NEVER mistaken for a lab parameter name).
  static bool _isUnitToken(String text) {
    final s = text.trim();
    if (s.isEmpty || s.length > 24) return false;
    final norm = s
        .toLowerCase()
        .replaceAll('µ', 'u')
        .replaceAll('μ', 'u')
        .replaceAll('³', '^3')
        .replaceAll('²', '2')
        .replaceAll(' ', '');

    const exactUnits = {
      '%',
      'u/l',
      'iu/l',
      'iu/ml',
      'miu/l',
      'uiu/ml',
      'g/dl',
      'g/l',
      'mg/dl',
      'mg/l',
      'ug/dl',
      'ug/l',
      'ng/l',
      'ng/ml',
      'ng/dl',
      'pg/ml',
      'pg',
      'fl',
      'l/l',
      'mmol/l',
      'mmol/mol',
      'umol/l',
      'nmol/l',
      'pmol/l',
      'meq/l',
      'mm/saat',
      'mm/h',
      'mm/hr',
      'sn',
      'saniye',
      '10^3/mm^3',
      '10^6/mm^3',
      '10^3/ul',
      '10^6/ul',
      '10^9/l',
      '10^12/l',
      'k/ul',
      'm/ul',
      'th/ul',
      'mil/ul',
      '/ul',
      '/mm3',
      '/mm^3',
      'cells/ul',
      'ml/dk/1.73',
      'ml/dk/1.73m2',
      'ml/min/1.73m2',
      'm2',
    };
    if (exactUnits.contains(norm)) return true;

    // General pattern for ratio/power units like "10^3/mm^3", "x10^3/uL", "mg/g"
    if (RegExp(r'^(?:x?10\^\d+/|m?u?n?p?k?[gjl]/|m?i?u/)').hasMatch(norm)) {
      return true;
    }
    return false;
  }

  static bool _isNoiseOrHeaderLine(String line) {
    final lower = _normalizeTr(line);
    if (lower.length < 3) return true;

    // Skip metadata, headers, footers, phone numbers, page counters, dates
    const skipPrefixes = [
      'adi/soyadi',
      'adi soyadi',
      'hasta adi',
      'dogum tarihi',
      'cinsiyet',
      'saglik tesisi',
      't.c. saglik',
      't.c.saglik',
      'saglik bilgi',
      'tarih tahlil',
      'sayfa ',
      'enabiz',
      'protokol',
      'barkod',
      'tc kimlik',
      't.c. kimlik',
      'onay tarihi',
      'numune',
      'rapor tarihi',
      'tarih:',
      'doktor',
      'hekim',
      'patient name',
      'date of birth',
      'dob:',
      'accession',
      'page ',
      'collected:',
      'reported:',
    ];
    for (final prefix in skipPrefixes) {
      if (lower.startsWith(prefix)) return true;
    }

    if (lower.contains('enabiz.gov.tr') ||
        lower.contains('sayfa ') && RegExp(r'sayfa\s+\d+\s*/\s*\d+').hasMatch(lower)) {
      return true;
    }

    // Pure date / time or phone number lines
    if (RegExp(r'^\d{2}[./-]\d{2}[./-]\d{4}(?:\s+\d{2}:\d{2}(?::\d{2})?)?$')
        .hasMatch(line)) {
      return true;
    }
    if (RegExp(r'^\d{2}:\d{2}(?::\d{2})?$').hasMatch(line)) return true;
    if (RegExp(r'^0\s*\d{3}\s*\d{3}\s*\d{2}\s*\d{2}$').hasMatch(line)) return true;

    // Must contain at least one Unicode letter AND one digit to be a test result row
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(line)) return true;
    if (!RegExp(r'\d').hasMatch(line)) return true;

    return false;
  }

  /// Parses a general hospital table row in ANY international layout:
  ///   - Turkey e-Nabız: `Hemoglobin 13,8 g/dL 12,0 - 16,5`
  ///   - USA Quest/LabCorp: `Glucose 142 H mg/dL 70-99` / `Platelets 245,000 /uL 150,000-450,000`
  ///   - UK NHS / SI: `Haemoglobin 138 g/L (120 - 160)` / `HbA1c 42 mmol/mol (< 48)`
  ///   - Germany / EU: `Glukose 5,4 mmol/L [3,9 - 5,5]`
  ///   - Russia / Arabic / Chinese: `Гемоглобин 135 г/л 120-160`, `血糖 5.6 mmol/L 3.9-6.1`
  static ({
    String name,
    double value,
    String unit,
    double? refMin,
    double? refMax,
  })? _parseStructuredRow(String line) {
    // Strip leading date/time or bullet/status symbols if present on same line
    var cleaned = line
        .replaceFirst(
          RegExp(r'^\d{2}[./-]\d{2}[./-]\d{4}(?:\s+\d{2}:\d{2}(?::\d{2})?)?\s+'),
          '',
        )
        .replaceFirst(RegExp(r'^[✓✔!•\-\*]+\s*'), '')
        .trim();

    // Normalize thousands-separated integers like "245,000" or "6,500" -> "245000"
    // WITHOUT touching European/Turkish decimal commas like "0,282" or "13,8".
    final usesCommaDecimals = RegExp(r'(?<!\d)0,\d|(?<!\d)\d+,\d{1,2}(?!\d)').hasMatch(cleaned);
    if (!usesCommaDecimals) {
      cleaned = cleaned.replaceAllMapped(
        RegExp(r'(?<!\d)([1-9]\d{0,2}),(\d{3})(?!\d)'),
        (m) => '${m.group(1)}${m.group(2)}',
      );
    }

    // Match: <Unicode name> followed by whitespace or ':'/'=' and a standalone numeric result
    final rowRegex = RegExp(
      r'^([\p{L}0-9#%().,/\-\s]+?)(?:\s*[:=]\s*|\s+)(-?\d+(?:[.,]\d+)?)(?:\s+(.*))?$',
      unicode: true,
    );
    final match = rowRegex.firstMatch(cleaned);
    if (match == null) return null;

    final rawName = (match.group(1) ?? '').trim();
    final rawVal = (match.group(2) ?? '').replaceAll(',', '.');
    var tail = (match.group(3) ?? '').trim();

    if (rawName.length < 2 || rawName.length > 56) return null;
    if (_isUnitToken(rawName)) return null;
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(rawName)) return null;
    // Reject dates mistakenly split as "07.05" + "2026"
    if (RegExp(r'^\d+[./-]\d+$').hasMatch(rawName)) return null;

    final value = double.tryParse(rawVal);
    if (value == null) return null;

    // Strip leading Quest/LabCorp/EU abnormal flag between value & unit
    // e.g. "H mg/dL 70-99", "HIGH mg/dL (70-99)", "↑ mmol/L 3.9-5.5"
    tail = tail
        .replaceFirst(
          RegExp(
            r'^(?:\(?(?:H|L|HH|LL|HIGH|LOW|CRIT|ABNORMAL|Yüksek|Düşük|Yuksek|Dusuk|Выше|Ниже)\)?|[↑↓\*]+)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Strip trailing abnormal flag after reference range
    tail = tail
        .replaceFirst(
          RegExp(
            r'\s+(?:\(?(?:H|L|HH|LL|HIGH|LOW|Normal|Yüksek|Düşük|Yuksek|Dusuk|Выше|Ниже)\)?|[↑↓\*]+)$',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    // Extract reference range from tail:
    // supports "min - max", "(min - max)", "[min - max]", "min to max", "min..max",
    // "< max", "(< max)", "> min", "(>= min)"
    double? refMin;
    double? refMax;
    var unitPart = tail;

    final rangeMatch = RegExp(
      r'[\(\[]?\s*(-?\d+(?:[.,]\d+)?)\s*(?:[-–—]|\.\.|\bto\b)\s*(-?\d+(?:[.,]\d+)?)\s*\*?\s*[\)\]]?\s*$',
      caseSensitive: false,
    ).firstMatch(tail);
    if (rangeMatch != null) {
      refMin = double.tryParse(rangeMatch.group(1)!.replaceAll(',', '.'));
      refMax = double.tryParse(rangeMatch.group(2)!.replaceAll(',', '.'));
      unitPart = tail.substring(0, rangeMatch.start).trim();
    } else {
      final upperMatch = RegExp(
        r'[\(\[]?\s*(?:<=?|[<≤])\s*(-?\d+(?:[.,]\d+)?)\s*\*?\s*[\)\]]?\s*$',
      ).firstMatch(tail);
      if (upperMatch != null) {
        refMax = double.tryParse(upperMatch.group(1)!.replaceAll(',', '.'));
        unitPart = tail.substring(0, upperMatch.start).trim();
      } else {
        final lowerMatch = RegExp(
          r'[\(\[]?\s*(?:>=?|[>≥])\s*(-?\d+(?:[.,]\d+)?)\s*\*?\s*[\)\]]?\s*$',
        ).firstMatch(tail);
        if (lowerMatch != null) {
          refMin = double.tryParse(lowerMatch.group(1)!.replaceAll(',', '.'));
          unitPart = tail.substring(0, lowerMatch.start).trim();
        }
      }
    }

    // Clean any remaining status markers or Cyrillic unit equivalents
    unitPart = unitPart
        .replaceAll(
          RegExp(
            r'\s+(?:H|L|HH|LL|HIGH|LOW|\*|↑|↓|Normal|Yüksek|Düşük|Yuksek|Dusuk)$',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll('г/л', 'g/L')
        .replaceAll('г/дл', 'g/dL')
        .replaceAll('ммоль/л', 'mmol/L')
        .replaceAll('мкмоль/л', 'umol/L')
        .replaceAll('нмоль/л', 'nmol/L')
        .replaceAll('пмоль/л', 'pmol/L')
        .replaceAll('мг/дл', 'mg/dL')
        .replaceAll('мг/л', 'mg/L')
        .replaceAll('Ед/л', 'U/L')
        .replaceAll('ед/л', 'U/L')
        .trim();

    // If neither a known catalog match NOR a unit NOR a reference range exists,
    // be cautious about random prose lines (e.g. "Sayfa 1").
    final isKnown = _matchCatalogSpec(rawName) != null;
    if (!isKnown && unitPart.isEmpty && refMin == null && refMax == null) {
      return null;
    }

    return (
      name: rawName,
      value: value,
      unit: unitPart,
      refMin: refMin,
      refMax: refMax,
    );
  }

  static LabTestItem? _parseKnownAliasFallback(String line) {
    final lower = _normalizeTr(line);
    final aliasPairs = _allAliasPairs();

    final numRegex = RegExp(r'(-?\d+(?:[.,]\d+)?)');
    for (final (normAlias, spec) in aliasPairs) {
      final match = _matchAliasWithBoundaries(lower, normAlias);
      if (match == null) continue;

      final afterAlias = line.substring(match.end);
      final numMatch = numRegex.firstMatch(afterAlias);
      if (numMatch == null) continue;

      final parsed = double.tryParse(numMatch.group(1)!.replaceAll(',', '.'));
      if (parsed == null) continue;

      return evaluateKnownParameter(spec: spec, value: parsed);
    }
    return null;
  }

  static List<(String alias, LabParameterSpec spec)> _allAliasPairs() {
    final aliasPairs = <(String alias, LabParameterSpec spec)>[];
    for (final spec in catalog) {
      for (final alias in spec.aliases) {
        aliasPairs.add((_normalizeTr(alias), spec));
      }
      final intlAliases = LabUnitConverter.multilingualAliases[spec.code];
      if (intlAliases != null) {
        for (final alias in intlAliases) {
          aliasPairs.add((_normalizeTr(alias), spec));
        }
      }
    }
    aliasPairs.sort((a, b) => b.$1.length.compareTo(a.$1.length));
    return aliasPairs;
  }

  static RegExpMatch? _matchAliasWithBoundaries(String normText, String normAlias) {
    // Non-Latin scripts (Chinese/Arabic) may not use ASCII word spaces around names.
    final isNonLatin = RegExp(r'[\u0600-\u06FF\u4E00-\u9FFF]').hasMatch(normAlias);
    if (isNonLatin) {
      return RegExp(RegExp.escape(normAlias)).firstMatch(normText);
    }
    return RegExp(
      r'(^|[^\p{L}0-9#%])'
      '${RegExp.escape(normAlias)}'
      r'([^\p{L}0-9#%]|$)',
      unicode: true,
    ).firstMatch(normText);
  }

  static LabParameterSpec? _matchCatalogSpec(String rawName) {
    final norm = _normalizeTr(rawName)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (norm.isEmpty) return null;

    // Keep "LDL Kolesterol(Hesaplama)" distinct from direct "LDL Kolesterol"
    if (norm.contains('hesaplama')) return null;

    final aliasPairs = _allAliasPairs();

    // 1. Exact alias match first (catalog + international aliases)
    for (final (normAlias, spec) in aliasPairs) {
      if (norm == normAlias) return spec;
    }

    // 2. Boundary-aware longest alias match (respecting # and % suffixes!)
    for (final (normAlias, spec) in aliasPairs) {
      if (_matchAliasWithBoundaries(norm, normAlias) != null) return spec;
    }

    return null;
  }

  static String _cleanLabel(String raw) {
    var s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    // Balance unclosed parenthesis from OCR/PDF truncation like "LDL Kolesterol(Hesaplama"
    if (s.contains('(') && !s.contains(')')) {
      s = '$s)';
    }
    return s;
  }

  static String _canonicalDynamicCode(String name) {
    final normalized = _normalizeTr(name)
        .replaceAll('#', '_ABS')
        .replaceAll('%', '_PCT')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '')
        .toUpperCase();
    return normalized.isEmpty ? 'PARAM' : normalized;
  }

  static String? _extractHospitalName(String text) {
    final match = RegExp(
      r'(?:Sağlık\s+Tesisi|Saglik\s+Tesisi|Hastane|Laboratuvar)\s*:\s*([^\r\n]+)',
      caseSensitive: false,
    ).firstMatch(text);
    final name = match?.group(1)?.trim();
    if (name != null && name.length >= 3) {
      return name;
    }
    return null;
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
      buf.writeln(
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
      buf.writeln(
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

    // 3. Standalone overview when diagnosis & complaint are blank
    if (hospitalDiagnosis == null && userComplaintNote == null) {
      if (abnormal.isNotEmpty) {
        final details = abnormal
            .map((e) => '${e.name} (${e.formattedValue} — ${e.status.label})')
            .join(', ');
        paragraphs.add(
          '• Yalnızca kan sonuçlarına göre ön değerlendirme: $details değerleri referans aralığının dışında. Tek bir test tek başına tanı koymaz; şikayetleriniz ve önceki sonuçlarınızla birlikte doktor değerlendirmesi gerekir.',
        );
      } else if (items.isNotEmpty) {
        paragraphs.add(
          '• Yalnızca kan sonuçlarına göre ön değerlendirme: Okunan tüm değerler referans aralığında görünüyor. Şikayetiniz sürüyorsa doktorunuz farklı tetkikler önerebilir.',
        );
      } else if (attachmentFileName != null) {
        paragraphs.add(
          '• $attachmentFileName belgesi arşivlendi. Taranmış fotoğraf/PDF içeriğindeki sayılar otomatik okunamadıysa aşağıdan manuel değer ekleyebilir veya isteğe bağlı Bulut Yapay Zeka ile okutabilirsiniz.',
        );
      }
    }

    // 4. Multi-parameter clinical pattern correlations (always run when items exist)
    if (items.isNotEmpty) {
      final correlations = _buildClinicalCorrelations(byCode, items);
      paragraphs.addAll(correlations.insights);
      questions.addAll(correlations.questions);
      specialtyHint ??= correlations.specialtyHint;
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
      questions: questions.toSet().take(5).toList(),
      specialtyHint: specialtyHint,
    );
  }

  /// Evaluates combinations of lab parameters together (e.g. HGB + Demir/Ferritin,
  /// NEU% + LYM%, PCT + PLT, HDL + LDL/Trig, Glukoz + HbA1c, ALT + AST,
  /// Kreatinin + eGFR) to provide holistic, plain-Turkish clinical insights.
  static ({
    List<String> insights,
    List<String> questions,
    String? specialtyHint,
  }) _buildClinicalCorrelations(
    Map<String, LabTestItem> byCode,
    List<LabTestItem> items,
  ) {
    final insights = <String>[];
    final questions = <String>[];
    String? specialtyHint;

    bool isLow(String code) {
      final s = byCode[code]?.status;
      return s == LabStatus.low || s == LabStatus.criticalLow;
    }

    bool isHigh(String code) {
      final s = byCode[code]?.status;
      return s == LabStatus.high || s == LabStatus.criticalHigh;
    }

    bool isNormal(String code) => byCode[code]?.status == LabStatus.normal;

    // 1. Anemia & Iron / B12 / Folate pattern
    final lowHgbOrHct = isLow('HGB') || isLow('HCT') || isLow('RBC');
    final lowIronOrFerritin = isLow('IRON') || isLow('FERRITIN');
    final lowB12OrFolate = isLow('B12') || isLow('FOLATE');

    if (lowHgbOrHct && lowIronOrFerritin) {
      final parts = [
        if (byCode['HGB'] != null && isLow('HGB'))
          'HGB (${byCode['HGB']!.formattedValue})',
        if (byCode['HCT'] != null && isLow('HCT'))
          'HCT (${byCode['HCT']!.formattedValue})',
        if (byCode['IRON'] != null && isLow('IRON'))
          'Demir (${byCode['IRON']!.formattedValue})',
        if (byCode['FERRITIN'] != null && isLow('FERRITIN'))
          'Ferritin (${byCode['FERRITIN']!.formattedValue})',
      ].join(', ');
      insights.add(
        '• Demir Eksikliği Anemisi Eğilimi: $parts değerlerinin birlikte düşük olması demir eksikliğine bağlı kansızlık (anemi) ile uyumlu olabilir. Halsizlik, çabuk yorulma, üşüme, saç dökülmesi ve tırnak kırılmasına yol açabilir; doktorunuzla demir tedavisi ve altta yatan nedeni değerlendirmeniz önerilir.',
      );
      questions.add(
        'Hemoglobin ve demir/ferritin düşüklüğüm için demir takviyesi başlamalı mıyım ve nedeni araştırılmalı mı?',
      );
      specialtyHint ??= 'Dahiliye veya Hematoloji';
    } else if (lowHgbOrHct && lowB12OrFolate) {
      insights.add(
        '• B12 / Folat İlişkili Kansızlık Eğilimi: Kan değerleri (HGB/HCT) ile birlikte B12 veya Folat düşüklüğü görülüyor. Bu tablo yorgunluk, unutkanlık ve uyuşma yapabilir; hekim değerlendirmesiyle takviye planlanabilir.',
      );
      specialtyHint ??= 'Dahiliye veya Hematoloji';
    } else if (lowIronOrFerritin && isHigh('TIBC')) {
      insights.add(
        '• Demir Deposu Azalması: Demir/Ferritin düşükken Demir Bağlama Kapasitesinin (TIBC) yüksek olması, vücudun demire ihtiyaç duyduğunun tipik bir göstergesidir; HGB normal kalsa bile erken dönem demir eksikliği açısından hekime danışılabilir.',
      );
      specialtyHint ??= 'Dahiliye';
    } else if (lowHgbOrHct && isLow('MCV')) {
      insights.add(
        '• Mikrositer Anemi Eğilimi: Hemoglobin/Hematokrit ile birlikte MCV değerinin düşük olması sıklıkla demir eksikliği veya talasemi taşıyıcılığı ile ilişkilidir; ferritin ve demir profili ile birlikte hekimce değerlendirilmelidir.',
      );
      specialtyHint ??= 'Dahiliye veya Hematoloji';
    }

    // 2. White blood cell / Infection / Inflammation pattern (e.g. NEU% high + LYM% low)
    if (isHigh('NEU_PCT') && isLow('LYM_PCT')) {
      final wbcNormal = isNormal('WBC') && (byCode['NEU_ABS'] == null || isNormal('NEU_ABS'));
      insights.add(
        wbcNormal
            ? '• Nötrofil % Yüksek / Lenfosit % Düşük (WBC Normal): NEU% (${byCode['NEU_PCT']!.formattedValue}) yüksek ve LYM% (${byCode['LYM_PCT']!.formattedValue}) düşük görünüyor; ancak toplam lökosit (WBC) ve mutlak hücre sayıları normal aralıkta. Bu tablo sıklıkla yakın zamanda geçirilen hafif bir enfeksiyon, fiziksel/duygusal stres veya hafif iltihabi tepkide geçici olarak görülebilir.'
            : '• Enfeksiyon / İltihabi Yanıt Eğilimi: NEU% yüksekliği ile LYM% düşüklüğü birlikte görülüyor; aktif bir enfeksiyon veya iltihabi süreç açısından şikayetlerinizle birlikte doktor değerlendirmesi önerilir.',
      );
      questions.add(
        'NEU% yüksekliği ve LYM% düşüklüğü için yakın zamanda kontrol hemogram yaptırmam gerekir mi?',
      );
    } else if (isHigh('WBC') && isHigh('CRP')) {
      insights.add(
        '• Aktif Enfeksiyon / İltihap Bulgusu: Hem Lökosit (WBC) hem CRP değerinin birlikte yükselmesi vücutta aktif bir enfeksiyon veya iltihabi sürece işaret edebilir; gecikmeden hekim muayenesi önerilir.',
      );
      specialtyHint ??= 'Dahiliye';
    }

    // 3. Platelet / PCT pattern (e.g. PCT slightly high while PLT is normal)
    if (isHigh('PCT') && isNormal('PLT')) {
      insights.add(
        '• PCT Hafif Yüksek, Trombosit (PLT) Normal: PCT (${byCode['PCT']!.formattedValue}) referansın hemen üzerinde ancak ana trombosit sayısı (PLT: ${byCode['PLT']!.formattedValue}) normal aralıkta. Trombosit sayısı normalken tek başına hafif PCT yüksekliği çoğu zaman klinik olarak önemsiz kabul edilir.',
      );
    } else if (isLow('PLT')) {
      insights.add(
        '• Trombosit Düşüklüğü: PLT (${byCode['PLT']!.formattedValue}) referansın altında; kolay morarma veya kanama eğilimi açısından hekim kontrolü önemlidir.',
      );
      specialtyHint ??= 'Hematoloji veya Dahiliye';
    }

    // 4. Lipid / Cardiovascular pattern (HDL, LDL, Total Chol, Trig)
    if (isLow('HDL')) {
      final otherLipidsNormal =
          (byCode['LDL'] == null || isNormal('LDL')) &&
          (byCode['TOTAL_CHOL'] == null || isNormal('TOTAL_CHOL')) &&
          (byCode['TRIG'] == null || isNormal('TRIG'));
      insights.add(
        otherLipidsNormal
            ? '• Koruyucu HDL Kolesterol Sınırda Düşük: HDL (${byCode['HDL']!.formattedValue}) hedef sınırın hafif altında, buna karşılık LDL, Total Kolesterol ve Trigliserit değerleriniz normal. Düzenli tempolu yürüyüş/egzersiz ve zeytinyağı, balık, ceviz gibi sağlıklı yağlar HDL düzeyini yükseltmeye yardımcı olur.'
            : '• Kolesterol / Lipid Profili Dikkat Gerektiriyor: Koruyucu HDL düşük iken diğer kan yağlarında da yükselme mevcut; kalp-damar riski açısından doktorunuzla beslenme ve takip planı oluşturmanız önerilir.',
      );
      specialtyHint ??= 'Dahiliye veya Kardiyoloji';
    } else if (isHigh('LDL') && isHigh('TRIG')) {
      insights.add(
        '• Kan Yağlarında Birlikte Yükselme: Hem LDL hem Trigliserit referansın üzerinde; kardiyovasküler koruma için beslenme düzeni, hareket ve hekim değerlendirmesi önerilir.',
      );
      specialtyHint ??= 'Dahiliye veya Kardiyoloji';
    }

    // 5. Glucose & HbA1c metabolic pattern
    if (isHigh('GLU') && isHigh('HBA1C')) {
      insights.add(
        '• Kan Şekeri & HbA1c Birlikte Yüksek: Hem açlık şekeri hem 3 aylık ortalama (HbA1c) referans üstünde; insülin direnci, prediyabet veya diyabet takibi açısından Endokrinoloji/Dahiliye değerlendirmesi önemlidir.',
      );
      specialtyHint ??= 'Endokrinoloji veya Dahiliye';
    }

    // 6. Liver panel (ALT + AST)
    if (isHigh('ALT') && isHigh('AST')) {
      insights.add(
        '• Karaciğer Enzimlerinde Eş Zamanlı Yükselme: ALT ve AST birlikte yüksek; karaciğer yağlanması, kullanılan ilaçlar veya viral nedenler açısından hekim değerlendirmesi önerilir.',
      );
      specialtyHint ??= 'Dahiliye veya Gastroenteroloji';
    }

    // 7. Kidney panel (Creatinine + eGFR / Urea)
    if (isHigh('CREA') && (isLow('EGFR') || isHigh('UREA'))) {
      insights.add(
        '• Böbrek Fonksiyon Değerlendirmesi: Kreatinin yüksekliği ile birlikte eGFR düşüklüğü veya Üre yüksekliği görülüyor; sıvı alımı, tansiyon ve böbrek fonksiyonu açısından doktor kontrolü önemlidir.',
      );
      specialtyHint ??= 'Dahiliye veya Nefroloji';
    }

    // 8. Positive summary of normal major panels so the user sees the full picture
    final normalPanels = <String>[];
    if (isNormal('HGB') && (byCode['HCT'] == null || isNormal('HCT'))) {
      normalPanels.add('kan sayımı (HGB/HCT)');
    }
    if ((byCode['IRON'] != null && isNormal('IRON')) ||
        (byCode['FERRITIN'] != null && isNormal('FERRITIN'))) {
      if (!lowIronOrFerritin) normalPanels.add('demir depoları');
    }
    if ((byCode['B12'] != null && isNormal('B12')) ||
        (byCode['FOLATE'] != null && isNormal('FOLATE'))) {
      if (!lowB12OrFolate) normalPanels.add('B12/Folat');
    }
    if (isNormal('GLU') && (byCode['HBA1C'] == null || isNormal('HBA1C'))) {
      normalPanels.add('kan şekeri (Glukoz/HbA1c)');
    }
    if (isNormal('ALT') && isNormal('AST')) {
      normalPanels.add('karaciğer enzimleri (ALT/AST)');
    }
    if (isNormal('CREA') && (byCode['EGFR'] == null || isNormal('EGFR'))) {
      normalPanels.add('böbrek fonksiyonları (Kreatinin/eGFR)');
    }

    if (normalPanels.isNotEmpty) {
      insights.add(
        '• Olumlu / Normal Görünen Paneller: ${normalPanels.join(', ')} değerleriniz referans aralığı içinde görünüyor.',
      );
    }

    return (
      insights: insights,
      questions: questions,
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
    // 1. Prefer explicit report date labels (avoiding Doğum Tarihi / Birth Date)
    final labeled = RegExp(
      r'(?:^|[\r\n])\s*(?:Rapor\s+Tarihi|Onay\s+Tarihi|Numune\s+Tarihi|Tarih)\s*:\s*(\d{2})[./-](\d{2})[./-](\d{4})',
      caseSensitive: false,
    ).firstMatch(text);
    if (labeled != null) {
      final d = int.tryParse(labeled.group(1)!);
      final m = int.tryParse(labeled.group(2)!);
      final y = int.tryParse(labeled.group(3)!);
      if (d != null && m != null && y != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d);
      }
    }

    // 2. Fall back to first DD.MM.YYYY date not preceded by "Doğum"
    for (final dmy in RegExp(r'\b(\d{2})[./-](\d{2})[./-](\d{4})\b').allMatches(text)) {
      final prefixStart = (dmy.start - 24).clamp(0, text.length);
      final prefix = _normalizeTr(text.substring(prefixStart, dmy.start));
      if (prefix.contains('dogum') || prefix.contains('birth')) continue;
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

