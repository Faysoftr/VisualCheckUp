import 'package:flutter/material.dart';
import 'package:visualcheckup/features/checkup/domain/analysis_result.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/domain/module_reference.dart';

/// Structured visual reference catalog for all 7 VisualCheckUp modules.
///
/// Serves two purposes:
/// 1. In-app visual guide comparing healthy vs. abnormal findings.
/// 2. Ground-truth visual rubric injected into background Vision AI prompts.
class ModuleReferenceCatalog {
  ModuleReferenceCatalog._();

  static ModuleReferenceSpec forCategory(CheckCategory category) {
    return _specs[category]!;
  }

  /// Looks up a [ReferenceFinding] by its stable snake_case [id] across all
  /// modules (or optionally scoped to [category]).
  static ReferenceFinding? findById(String id, {CheckCategory? category}) {
    if (category != null) {
      for (final f in forCategory(category).findings) {
        if (f.id == id) return f;
      }
      return null;
    }
    for (final spec in _specs.values) {
      for (final f in spec.findings) {
        if (f.id == id) return f;
      }
    }
    return null;
  }

  static List<ModuleReferenceSpec> get all =>
      CheckCategory.values.map(forCategory).toList();

  static const Map<CheckCategory, ModuleReferenceSpec> _specs = {
    CheckCategory.eye: ModuleReferenceSpec(
      category: CheckCategory.eye,
      clinicalMethodSummary:
          'BiliScreen benzeri CIE L*a*b* b* sklera sarılık indeksi, 2D kılcal damar / subkonjonktival kanama ayrımı ve alt göz kapağı içi (palpebral konjonktiva) Collings Eritem İndeksi ile anemi ön farkındalığı.',
      healthySummary:
          'Sağlıklı göz akı (sklera) pürüzsüz, parlak, nötr porselen beyazı tondadır; yaygın sarılık, belirgin kanlanma veya odaklanmış kanama lekesi bulunmaz. Alt göz kapağı içi ise canlı pembe-kırmızıdır.',
      captureQualityChecklist: [
        'Doğal gün ışığında çekim yapın; sarı ampul altında sklera olduğundan sarı görünebilir.',
        'Flaş kullanmayın; göz kapağını nazikçe aralayarak skleranın net görünmesini sağlayın.',
        'Anemi ön kontrolü için kamera üst çubuğundan "Alt Göz Kapağı (Anemi)" modunu seçip alt kapağı nazikçe aşağı çekin.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'eye_lower_eyelid_pallor',
          title: 'Alt Göz Kapağı İçi (Konjonktiva) Anemi Kontrolü',
          purpose:
              'Palpebral konjonktiva melanin pigmenti içermediği için tüm ten renklerinde kansızlık (anemi) solukluğunu en objektif gösteren bölgelerden biridir.',
          steps: [
            'Doğal gün ışığı alan bir ayna karşısına geçin.',
            'Temiz bir parmakla alt göz kapağınızı nazikçe aşağı doğru çekin ve yukarı bakın.',
            'Kamera ekranında "Alt Göz Kapağı" modunu açıp iç mukozayı çerçeveleyin.',
          ],
          normalResult:
              'İç mukoza canlı pembe-kırmızı ve ince damarlı görünür (Eritem İndeksi ≥ 13).',
          warningResult:
              'Belirgin soluk pembe veya beyazımsı görünüm kansızlık (HGB/Ferritin düşüklüğü) ipucu olabilir; tam kan sayımı önerilir.',
          icon: Icons.visibility_outlined,
        ),
        ClinicalSelfTest(
          id: 'eye_pediatric_red_reflex',
          title: 'Çocuklarda Kırmızı Göz Reflesi (Lökokori) Farkındalığı',
          purpose:
              'Flaşlı normal fotoğraflarda gözbebeğinde beyaz/sarı parlama görülmesi (lökokori) erken göz muayenesi gerektirir.',
          steps: [
            'Çocuğunuzun flaşlı normal fotoğraflarında iki gözbebeğinin simetrik göründüğüne dikkat edin.',
            'Bir gözbebeğinde tekrarlayıcı biçimde parlak beyaz veya sarımsı yansıma varsa not alın.',
          ],
          normalResult: 'Her iki gözbebeği koyu veya simetrik kırmızı refle verir.',
          warningResult:
              'Tek veya iki gözde tekrarlayan beyaz gözbebeği yansıması görürseniz gecikmeden Çocuk Göz Hastalıkları uzmanına başvurun.',
          icon: Icons.child_care_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'eye_healthy_white',
          title: 'Sağlıklı Beyaz Sklera',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFF3F4F2),
          visualSignature:
              'Porselen/nötr beyaz zemin, minimal ince kılcal damar, sarılaşma veya koyu kızarıklık yok.',
          possibleAssociations: 'Olağan göz yüzeyi görünümü.',
        ),
        ReferenceFinding(
          id: 'eye_mild_redness',
          title: 'Hafif Kızarıklık / Damarlanma',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE8A2A2),
          visualSignature:
              'Sklerada belirginleşmiş pembe-kırmızı ince damar ağı veya hafif yaygın kızarıklık.',
          possibleAssociations:
              'Göz kuruluğu, uzun ekran süresi, uykusuzluk, alerjik konjonktivit veya kontakt lens tahrişi.',
          redFlagNote:
              'Ağrı, bulanık görme, ışığa hassasiyet veya çapaklanma varsa göz hekimine başvurun.',
        ),
        ReferenceFinding(
          id: 'eye_conjunctiva_pallor',
          title: 'Alt Göz Kapağı İçi Solukluğu',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFF1D4D4),
          visualSignature:
              'Alt göz kapağı iç mukozasının canlı pembe-kırmızı yerine belirgin soluk pembe/beyazımsı görünmesi.',
          possibleAssociations:
              'Demir eksikliği veya kansızlık (anemi) açısından ön farkındalık işareti olabilir.',
        ),
        ReferenceFinding(
          id: 'eye_localized_yellow_spot',
          title: 'Lokalize Sarımsı Kabartı (Pinguekula İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE7DA9C),
          visualSignature:
              'Skleranın tamamı beyazken yalnızca kornea kenarında küçük, sınırlı sarımsı bir leke/kabartı.',
          possibleAssociations:
              'Güneş (UV), rüzgâr veya toz maruziyetiyle ilişkili iyi huylu pinguekula/pterjium ön ipucu.',
        ),
        ReferenceFinding(
          id: 'eye_jaundice_sclera',
          title: 'Yaygın Sarımsı Sklera (Sarılık / İkter)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFEAD776),
          visualSignature:
              'Göz akının geniş alanında belirgin limon/saman sarısı renk değişimi (gün ışığında doğrulanmış).',
          possibleAssociations:
              'Kanda bilirubin yükselmesi, karaciğer veya safra yolu hassasiyetleri açısından tıbbi değerlendirme gerekir.',
          redFlagNote:
              'Koyu idrar, açık renkli dışkı, ciltte sararma veya halsizlik eşlik ediyorsa gecikmeden doktora başvurun.',
        ),
        ReferenceFinding(
          id: 'eye_subconjunctival_hemorrhage',
          title: 'Parlak Kırmızı Kanama Lekesi / Şiddetli Kızarıklık',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFC93232),
          visualSignature:
              'Sklera üzerinde keskin sınırlı parlak kırmızı kan birikimi veya yoğun koyu kırmızı inflamasyon.',
          possibleAssociations:
              'Subkonjonktival kanama, tansiyon yükselmesi, göz travması veya akut enfeksiyon/üveit.',
          redFlagNote:
              'Travma, görme kaybı, şiddetli ağrı veya yüksek tansiyon öyküsü varsa acil değerlendirme alın.',
        ),
        ReferenceFinding(
          id: 'eye_pediatric_leukocoria',
          title: 'Gözbebeğinde Beyaz Refle (Lökokori Farkındalığı)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFEFECE0),
          visualSignature:
              'Flaşlı fotoğraflarda bir veya iki gözbebeğinin siyah/kırmızı yerine parlak beyaz veya sarımsı görünmesi.',
          possibleAssociations:
              'Çocuklarda doğumsal katarakt, retina hassasiyetleri veya erken göz muayenesi gerektiren durumların önemli uyarı bulgusudur.',
          redFlagNote:
              'Fotoğraflarda tekrarlayan beyaz gözbebeği yansıması görülürse gecikmeden Göz Hastalıkları uzmanına başvurun.',
        ),
      ],
    ),
    CheckCategory.nail: ModuleReferenceSpec(
      category: CheckCategory.nail,
      clinicalMethodSummary:
          'Mannino (Nature Comm.) tırnak yatağı Eritem İndeksi ile anemi ön taraması, beyaz kağıt Von Kries kalibrasyonu, 2D dikey melanoniki bandı, Beau enine oluk, Terry/Lindsay ayrım ve kıymık kanama analizi.',
      healthySummary:
          'Sağlıklı tırnak plağı pürüzsüz, yarı saydam, esnek ve hafif kavisli yapıdadır; altındaki tırnak yatağı canlı doğal pembe tondadır, belirgin sararma, yeşerme, morarma, yaygın beyazlaşma, çökme, saat camı bombeleşmesi, ayrılma veya koyu dikey bant içermez. Kesin tanı için dermatoloji muayenesi ve kan testleri gerekir.',
      captureQualityChecklist: [
        'Tırnakta oje, cila veya kalıcı jel bulunmamalıdır.',
        'Eller oda sıcaklığındayken (üşümemişken) beyaz bir kâğıt/zemin üzerinde, doğal gün ışığında çekin.',
        'Çomak parmak (bombeleşme) veya kaşık tırnak şüphesinde tırnağı hem üstten hem yandan inceleyin.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'nail_schamroth_window',
          title: 'Schamroth Pencere Testi (Çomak Parmak Kontrolü)',
          purpose:
              'Tırnak taban açısındaki (Lovibond açısı) artışı ve erken evre çomaklaşmayı (kalp/akciğer bulgusu) 5 saniyede kontrol eder.',
          steps: [
            'Her iki elinizin işaret parmaklarının tırnak yüzeylerini sırt sırta birleştirin.',
            'Tırnak köklerinin birleştiği noktaya ışık önünde yandan bakın.',
          ],
          normalResult:
              'İki tırnak dibi arasında küçük, elmas (baklava) şeklinde ince bir ışık boşluğu ("Schamroth penceresi") görünür.',
          warningResult:
              'Elmas şeklindeki boşluk tamamen kaybolmuşsa ve tırnaklar saat camı gibi bombeliyse Dahiliye veya Göğüs Hastalıkları uzmanına başvurun.',
          icon: Icons.back_hand_outlined,
        ),
        ClinicalSelfTest(
          id: 'nail_abcdef_melanoma',
          title: 'Tırnak Altı Koyu Çizgi — ABCDEF Kuralı',
          purpose:
              'Tek tırnaktaki dikey kahverengi/siyah çizginin (melanoniki) dermatoloji (dermoskopi) aciliyetini değerlendirir.',
          steps: [
            'A (Age): 50 yaş üzeri erişkinlerde yeni oluşan koyu bantlar daha dikkatli izlenir.',
            'B (Band): Kahverengi-siyah bant genişliği >3 mm veya düzensiz bulanık kenarlı mı?',
            'C (Change): Bant zamanla genişliyor veya koyulaşıyor mu?',
            'D (Digit): Tek bir tırnakta (özellikle başparmak, işaret veya ayak başparmağı) mı?',
            'E (Extension): Koyu pigment tırnak dibi etine taşıyor mu? (Hutchinson işareti)',
            'F (Family): Kişisel veya ailede melanom öyküsü var mı?',
          ],
          normalResult:
              'Bilinen darbe sonrası oluşan hematom tırnak uzadıkça uca doğru ilerleyip 4–6 ayda kaybolur.',
          warningResult:
              'Darbesiz, tek tırnakta >3 mm genişlikte, büyüyen veya tırnak etine taşan çizgilerde gecikmeden Dermatoloji muayenesi gerekir.',
          icon: Icons.biotech_outlined,
        ),
        ClinicalSelfTest(
          id: 'nail_capillary_refill',
          title: 'Kapiller Dolum Süresi (Periferik Dolaşım Testi)',
          purpose:
              'Parmak ucu mikro dolaşımını ve soğuk kaynaklı geçici solukluğu hızlıca test eder.',
          steps: [
            'Oda sıcaklığında tırnak plağının ortasına 3 saniye hafifçe bastırın (tırnak beyazlar).',
            'Parmağınızı bırakın ve pembe rengin tamamen geri gelme süresini sayın.',
          ],
          normalResult: 'Pembe renk 2 saniye veya daha kısa sürede geri döner.',
          warningResult:
              'Sıcak ortamda 3 saniyeden uzun süren gecikme veya morarma kalıcıysa dolaşım değerlendirmesi için doktora danışın.',
          icon: Icons.timer_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'nail_healthy_pink',
          title: 'Sağlıklı Pembe Tırnak',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFE7B6B2),
          visualSignature:
              'Pürüzsüz yüzey, eşit canlı pembe tırnak yatağı, düzenli beyaz uç ve hafif yarımay (lunula).',
          possibleAssociations: 'Olağan tırnak ve dolaşım görünümü.',
        ),
        ReferenceFinding(
          id: 'nail_pale_bed',
          title: 'Soluk Tırnak Yatağı',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFEEE4E2),
          visualSignature:
              'Normal pembe tona kıyasla belirgin derecede soluk, kansız görünümlü tırnak yatağı.',
          possibleAssociations:
              'Demir eksikliği anemisi (kansızlık), periferik dolaşım yavaşlığı veya beslenme eksiklikleri açısından kan sayımıyla değerlendirilebilir.',
        ),
        ReferenceFinding(
          id: 'nail_terry_or_half_and_half',
          title: 'Yaygın Beyaz (Terry) veya Yarım-Yarım (Lindsay) Tırnak',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFF3EFEA),
          visualSignature:
              'Tırnağın büyük kısmının opak beyaz olup ucunda ince pembe şerit kalması (Terry), yarı beyaz / yarı kahverengi-pembe görünüm (Lindsay) veya enine beyaz bantlar (Muehrcke/Mees çizgileri).',
          possibleAssociations:
              'Karaciğer hastalıkları (siroz), kronik böbrek yetmezliği, kandaki albümin/protein düşüklüğü, diyabet veya kalp yetmezliği açısından dahiliye değerlendirmesi önerilir.',
        ),
        ReferenceFinding(
          id: 'nail_yellow_thickened',
          title: 'Sararma ve Kalınlaşma',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD8BE67),
          visualSignature:
              'Tırnak plağında sarımsı-mat renklenme, kalınlaşma, ufalanma veya yavaş büyüme.',
          possibleAssociations:
              'En sık tırnak mantarı (onikomikoz) veya sürekli oje/sigara kullanımı; nadiren lenfödem, kronik akciğer hastalıkları, sedef veya tiroid sorunları.',
        ),
        ReferenceFinding(
          id: 'nail_green_pseudomonas',
          title: 'Yeşilimsi Tırnak (Kloronişi / Yeşil Tırnak Sendromu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFF8CA66B),
          visualSignature:
              'Tırnak plağında lokalize veya yaygın sarı-yeşil ya da koyu yeşil renk değişimi.',
          possibleAssociations:
              'Pseudomonas bakteriyel enfeksiyonu veya mantar enfeksiyonu (özellikle sık su/nem teması ve tırnak ayrılması sonrası).',
          redFlagNote:
              'Ağrı, akıntı veya yayılma varsa dermatoloji muayenesi ile uygun tedavi gerekir.',
        ),
        ReferenceFinding(
          id: 'nail_white_spots_leukonychia',
          title: 'Beyaz Noktalar (Lökonişi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFF4F1EC),
          visualSignature:
              'Tırnak plağı içinde küçük, noktasal beyaz bulutlanmalar.',
          possibleAssociations:
              'Çoğunlukla tırnağa alınan hafif darbeler (mikro travma) veya manikür kaynaklıdır; yaygın olduğunda çinko/protein dengesi değerlendirilebilir.',
        ),
        ReferenceFinding(
          id: 'nail_pitting_or_ridges',
          title: 'Yüzük Yüksüğü Çukurları (Pitting) & Enine Oluklar (Beau Çizgileri)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD6B4AE),
          visualSignature:
              'Tırnak yüzeyinde toplu iğne başı gibi küçük çukurcuklar (pitting) veya tırnağı enine kesen derin çöküntüler (Beau çizgileri).',
          possibleAssociations:
              'Çukurcuklar sedef (psöriyazis), egzama veya alopesi areata ile; enine Beau çizgileri ağır enfeksiyon, yüksek ateş, kontrolsüz diyabet veya kemoterapi sonrası geçici büyüme duraksamasıyla ilişkilidir.',
        ),
        ReferenceFinding(
          id: 'nail_spoon_koilonychia',
          title: 'Kaşık Tırnak (Koilonişi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE3C9C4),
          visualSignature:
              'Tırnak orta kısmının içe doğru çukurlaşıp kenarlarının yukarı kalkması ve plağın incelmesi.',
          possibleAssociations:
              'Klasik olarak demir eksikliği anemisi ve hipotiroidi (tiroid bezinin az çalışması) ile ilişkilendirilir.',
        ),
        ReferenceFinding(
          id: 'nail_onycholysis',
          title: 'Tırnak Yatağından Ayrılma (Onikoliz)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFEBD9B7),
          visualSignature:
              'Tırnağın uç kısmından başlayarak alttaki pembe yataktan boşalması ve ayrılan alanın beyaz/sarımsı görünmesi.',
          possibleAssociations:
              'Travma, tırnak mantarı, sedef hastalığı (psöriyazis), kimyasal/su teması veya tiroid (özellikle hipertiroidi) hastalıkları.',
        ),
        ReferenceFinding(
          id: 'nail_brittle_splitting_vertical',
          title: 'Kırılma, Soyulma, İncelme & Dikey Çizgiler',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE2C6BF),
          visualSignature:
              'Tırnak ucunda katman katman soyulma, kolay kırılma, kuruluk veya tırnak boyunca ince dikey çizgilenmeler.',
          possibleAssociations:
              'Sık su/deterjan teması ve yaşlanma dışında demir, çinko, biyotin, B12 eksikliği ve tiroid hormon bozukluklarında sık görülür.',
        ),
        ReferenceFinding(
          id: 'nail_clubbing_hippocratic',
          title: 'Çomak Parmak (Hipokrat Tırnağı / Saat Camı Bombeleşmesi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFDCA69E),
          visualSignature:
              'Tırnakların saat camı gibi belirgin bombeli hâle gelmesi ve parmak uçlarının genişleyip yumuşaması.',
          possibleAssociations:
              'Kronik akciğer hastalıkları, doğumsal kalp rahatsızlıkları, kalp yetmezliği, karaciğer veya inflamatuvar bağırsak hastalıklarının önemli bir bulgusudur.',
          redFlagNote:
              'Nefes darlığı, kronik öksürük veya çabuk yorulma eşlik ediyorsa gecikmeden Dahiliye, Göğüs Hastalıkları veya Kardiyoloji değerlendirmesi alın.',
        ),
        ReferenceFinding(
          id: 'nail_cyanotic_blue',
          title: 'Morumsu / Mavimsi Tırnak (Siyanoz)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF7B85B8),
          visualSignature:
              'Tırnak yatağında soğuk ortam dışı kalıcı mavi-mor veya kurşuni renk değişimi.',
          possibleAssociations:
              'Düşük kan oksijen düzeyi (hipoksemi), Raynaud fenomeni, kalp-akciğer veya periferik dolaşım sorunları açısından değerlendirme gerekir.',
          redFlagNote:
              'Nefes darlığı, göğüs ağrısı, dudak morarması veya baş dönmesi varsa acil tıbbi yardım alın.',
        ),
        ReferenceFinding(
          id: 'nail_dark_vertical_band',
          title: 'Koyu Kahverengi / Siyah Dikey Bant veya Leke (Melanoniki)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF42312C),
          visualSignature:
              'Tırnak kökünden ucuna uzanan koyu kahverengi/siyah dikey şerit (özellikle tek tırnakta, 3 mm’den geniş, düzensiz koyulaşan veya tırnak dibine taşan — Hutchinson işareti) ya da travmasız koyu tırnak altı lekesi.',
          possibleAssociations:
              'Darbe sonrası kanama (hematom) veya ilaç yan etkisi olabileceği gibi cilt kanseri (subungual melanom) açısından acil dermoskopik dermatoloji muayenesi gerekir.',
          redFlagNote:
              'Bilinen darbe yoksa, tek tırnakta >3 mm genişlikteyse, giderek koyulaşıyorsa veya tırnak etine taşıyorsa vakit kaybetmeden dermatoloğa başvurun.',
        ),
        ReferenceFinding(
          id: 'nail_splinter_hemorrhage',
          title: 'Kıymık Şeklinde İnce Kırmızı/Kahverengi Çizgiler',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF8B3434),
          visualSignature:
              'Tırnak altında uzunlamasına uzanan çok ince, kıymık benzeri koyu kırmızı veya kahverengi çizgiler.',
          possibleAssociations:
              'Tek tırnakta darbe kaynaklı olabilir; birden fazla tırnakta travmasız görülüyorsa sedef, damar iltihabı veya kalp kapak enfeksiyonu (endokardit) açısından tıbbi değerlendirme gerekir.',
          redFlagNote:
              'Ateş, halsizlik veya birden fazla tırnakta kendiliğinden oluşuyorsa gecikmeden hekime başvurun.',
        ),
        ReferenceFinding(
          id: 'nail_paronychia_inflamed',
          title: 'Tırnak Çevresinde Kızarıklık, Şişlik veya Akıntı (Paronişi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFC94A5A),
          visualSignature:
              'Tırnak etinde (katlantıda) parlak kırmızı şişlik, hassasiyet, sıcaklık veya iltihaplı akıntı.',
          possibleAssociations:
              'Bakteriyel veya mantar kaynaklı tırnak eti enfeksiyonu (paronişi), batık tırnak ya da nadiren bağ dokusu hastalıkları.',
          redFlagNote:
              'Şiddetli ağrı, zonklama, iltihap akıntısı veya diyabet öykünüz varsa vakit kaybetmeden dermatoloji/sağlık kuruluşuna başvurun.',
        ),
      ],
    ),
    CheckCategory.tongue: ModuleReferenceSpec(
      category: CheckCategory.tongue,
      clinicalMethodSummary:
          '2D yarık/fissür derinlik analizi, beyaz vs. sarı pas ayrımı, coğrafi dil kırmızı-beyaz sınır kontrastı ve mukoza Eritem İndeksi ile kanıta dayalı oral mukoza ön değerlendirmesi.',
      healthySummary:
          'Sağlıklı dil nemli, esnek, doğal canlı pembe tonda ve üzerinde çok ince şeffaf/hafif beyazımsı fizyolojik bir tabaka bulunur; kalın pas, yoğun kızarıklık, morarma, pürüzsüz parlaklık veya 2 haftadan uzun süren yara/plak yoktur. (Kanıta dayalı modern tıbbi değerlendirme esas alınır; geleneksel organ haritası yaklaşımları tanı aracı değildir.)',
      captureQualityChecklist: [
        'Kahve, çay, renkli yiyecek, sigara veya ağız gargarası sonrası en az 30 dakika bekleyin.',
        'Doğal gün ışığında dilinizi aşırı germeden dışarı çıkararak üst yüzeyi ve mümkünse kenarları net çerçeveleyin.',
        'Sarı ampul altında dil olduğundan daha sarı/turuncu görünebilir; mümkünse beyaz referans kalibrasyonu kullanın.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'tongue_gentle_wipe_test',
          title: 'Nazik Silme Testi (Pamukçuk vs. Lökoplaki Ayrımı)',
          purpose:
              'Beyaz tabakanın ağız kuruluğu/pamukçuk mu yoksa silinmeyen sabit beyaz plak (lökoplaki) mı olduğunu anlamaya yardımcı olur.',
          steps: [
            'Temiz bir gazlı bez veya yumuşak dil fırçasıyla beyaz alanı zorlamadan nazikçe silin.',
            'Tabakanın çıkıp çıkmadığını ve altındaki dokunun rengini gözlemleyin.',
          ],
          normalResult:
              'İnce fizyolojik pas su tüketimi ve nazik fırçalamayla kolayca azalır, altta sağlıklı pembe doku görünür.',
          warningResult:
              'Silinince altı kızarık/kanamalı kalıyorsa mantar (kandida); hiç silinmeyen sert beyaz plak varsa (lökoplaki riski) diş hekimi veya KBB muayenesi gerekir.',
          icon: Icons.cleaning_services_outlined,
        ),
        ClinicalSelfTest(
          id: 'tongue_two_week_rule',
          title: '2 Hafta Kuralı (Dil Kenarı & Yara Kontrolü)',
          purpose:
              'İyileşmeyen oral ülserlerin ve yan kenar lezyonlarının erken KBB/diş hekimi değerlendirmesini sağlar.',
          steps: [
            'Dilinizi sağa ve sola doğru uzatarak iki yan kenarını ve alt yüzeyini de aynada kontrol edin.',
            'Herhangi bir yara, sertlik veya kırmızı-beyaz yamanın başlangıç tarihini not alın.',
          ],
          normalResult: 'Basit ısırma veya aftlar 7–14 gün içinde tamamen iyileşir.',
          warningResult:
              '14 günü geçen iyileşmeyen yara, sertleşmiş kenar, kanama veya geçmeyen beyaz/kırmızı plak varsa gecikmeden KBB veya Diş Hekimine başvurun.',
          icon: Icons.event_available_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'tongue_healthy_pink',
          title: 'Sağlıklı Pembe Dil',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFDC8D96),
          visualSignature:
              'Nemli, eşit doğal pembe yüzey, düzenli ince papilla dokusu; kalın tabaka, belirgin renk kayması veya yara yok.',
          possibleAssociations: 'Olağan ağız ve dil mukozası görünümü.',
        ),
        ReferenceFinding(
          id: 'tongue_thick_white_coating',
          title: 'Beyaz Dil / Kalın Beyaz Tabaka (Pamukçuk & Ağız Kuruluğu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFECE6E2),
          visualSignature:
              'Dil sırtını kaplayan kalın beyazımsı-kremsi tabaka veya fırçalama/silme ile kısmen kalkabilen peynirimsi beyaz plaklar.',
          possibleAssociations:
              'Ağız kuruluğu, yetersiz su tüketimi, ağız hijyeni yetersizliği, sigara, reflü/gastrit kaynaklı ağız ortamı değişimi veya oral mantar enfeksiyonu (kandida/pamukçuk).',
          redFlagNote:
              'Silinmeyen beyaz plaklar 2 haftadan uzun sürüyorsa veya yutma güçlüğü/ağrı eşlik ediyorsa diş hekimi ya da KBB uzmanına başvurun.',
        ),
        ReferenceFinding(
          id: 'tongue_leukoplakia_plaque',
          title: 'Silinmeyen Kalın Beyaz Plak (Lökoplaki / Liken Planus İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFF3F0EB),
          visualSignature:
              'Dil üstünde veya özellikle yan kenarlarında kazınmakla/silinmekle çıkmayan kalın, sertleşmiş beyaz plak veya dantel görünümlü beyaz çizgiler.',
          possibleAssociations:
              'Lökoplaki (sigara/kronik tahriş ile ilişkili, bazı formları premalign olabileceğinden izlem gerekir) veya oral liken planus.',
          redFlagNote:
              'Silinmeyen beyaz veya kırmızı-beyaz karışık lezyonlar 2 haftadan uzun sürüyorsa kesin değerlendirme için diş hekimi/KBB muayenesi gerekir.',
        ),
        ReferenceFinding(
          id: 'tongue_yellow_orange_coating',
          title: 'Sarı / Turuncu Kaplama',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD9B65B),
          visualSignature:
              'Özellikle dil arka-orta bölgesinde sarımsı veya turuncuya çalan pas tabakası ve belirginleşmiş papillalar.',
          possibleAssociations:
              'Ağız kuruluğu, ağız hijyeni yetersizliği, bakteri/keratin birikimi, sigara, çay/kahve, antibiyotik kullanımı, beta-karoten içeren gıdalar veya reflü/sindirim hassasiyeti.',
        ),
        ReferenceFinding(
          id: 'tongue_greenish_coating',
          title: 'Yeşilimsi Kaplama',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFA2B986),
          visualSignature:
              'Dil yüzeyinde soluk yeşil veya sarı-yeşil renkte birikim/tabaka.',
          possibleAssociations:
              'Bakteri veya mantar biyofilm artışı, ağız hijyeni yetersizliği, tütün kullanımı, antibiyotik sonrası oral flora değişimi veya gıda boyaları.',
          redFlagNote:
              'Düzenli dil fırçalama ve sıvı alımına rağmen 1–2 hafta içinde düzelmiyorsa hekime danışın.',
        ),
        ReferenceFinding(
          id: 'tongue_black_hairy',
          title: 'Siyah / Koyu Kahverengi Kıllı Dil (Lingua Villosa Nigra)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFF4B3D36),
          visualSignature:
              'Dil ortasında ve arkasında uzamış filiform papillalara bağlı tüylü/halımsı koyu kahverengi veya siyah görünüm.',
          possibleAssociations:
              'Çoğunlukla iyi huylu keratin birikimi; bizmut içeren mide ilaçları, antibiyotikler, yoğun kahve/çay, sigara veya ağız kuruluğu ile ilişkilidir.',
        ),
        ReferenceFinding(
          id: 'tongue_pale_anemic',
          title: 'Soluk / Mat Dil',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE5C4C8),
          visualSignature:
              'Canlı doğal pembe yerine belirgin soluk, mat veya kansız görünümlü dil mukozası.',
          possibleAssociations:
              'Demir, B12 vitamini veya folik asit eksikliğine bağlı kansızlık (anemi) ve genel beslenme eksiklikleri açısından kan sayımıyla değerlendirilebilir.',
        ),
        ReferenceFinding(
          id: 'tongue_strawberry_or_atrophic_red',
          title: 'Kırmızı, Çilek Görünümlü veya Pürüzsüz Parlak Dil (Atrofik Glossit)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFC93D4C),
          visualSignature:
              'Parlak-koyu kırmızı renk; papillaların silinmesiyle pürüzsüz ve parlak yüzey (atrofik glossit) ya da belirgin kabarcıklı "çilek" görünümü.',
          possibleAssociations:
              'Demir, B12 veya folik asit eksikliği (atrofik glossit), kızıl, Kawasaki hastalığı, ateşli enfeksiyonlar, alerjik reaksiyon veya sıcak yiyecek tahrişi.',
          redFlagNote:
              'Yüksek ateş, döküntü, şiddetli yanma veya dil şişliği eşlik ediyorsa gecikmeden doktora başvurun.',
        ),
        ReferenceFinding(
          id: 'tongue_geographic_patches',
          title: 'Coğrafi Dil (Benign Migrator Glossit)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD26D7B),
          visualSignature:
              'Yükseltili beyazımsı/gri kenarlı, ortası pürüzsüz pembe-kırmızı, günler içinde yer değiştirebilen harita benzeri düzensiz adacıklar.',
          possibleAssociations:
              'Genellikle tamamen iyi huylu (benign) kronik varyasyon; bazen sedef hastalığı (psöriyazis), stres veya baharatlı/asitli gıdalara yanma hassasiyeti eşlik edebilir.',
        ),
        ReferenceFinding(
          id: 'tongue_fissured_grooves',
          title: 'Çatlak / Yarık Dil (Lingua Plicata)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD47B86),
          visualSignature:
              'Dil sırtında ve kenarlarında tek orta hat veya çoklu derin oluklar/yarıklar.',
          possibleAssociations:
              'Çoğunlukla doğuştan veya yaşla belirginleşen iyi huylu anatomik varyasyondur; nadiren B vitamini/demir/çinko eksikliği, sedef hastalığı, sindirim hassasiyetleri veya Melkersson-Rosenthal sendromu ile birlikte görülebilir. Olukların nazikçe temizlenmesi tahrişi önler.',
        ),
        ReferenceFinding(
          id: 'tongue_cyanotic_purple_blue',
          title: 'Mor / Mavi Dil (Siyanoz / Dolaşım Uyarısı)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF7B5B8C),
          visualSignature:
              'Gıda boyası olmaksızın dil mukozasında belirgin mor, eflatun veya mavimsi renk değişimi (santral siyanoz).',
          possibleAssociations:
              'Kanda düşük oksijen düzeyi (hipoksemi), kalp-akciğer veya dolaşım sistemi sorunları ya da ileri B2/B12 eksikliği açısından tıbbi değerlendirme gerekir.',
          redFlagNote:
              'Ani başlayan mavi/mor dil, nefes darlığı, göğüs ağrısı veya baş dönmesi acil tıbbi müdahale gerektirir.',
        ),
        ReferenceFinding(
          id: 'tongue_swelling_or_nonhealing_ulcer',
          title: 'Belirgin Şişlik, Sert Kitle veya İyileşmeyen Yara',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF9C3B4F),
          visualSignature:
              'Dilde belirgin ödem/büyüme, kenarlarda derin diş izleriyle şişlik, kanamalı/sert kenarlı ülser veya 2 haftadan uzun süren yara/kitle.',
          possibleAssociations:
              'Alerjik reaksiyon/anjiyoödem, travma/sürtünme, aft, viral enfeksiyonlar, tiroid/sistemik ödem veya erken tanı gerektiren oral mukoza lezyonları.',
          redFlagNote:
              'Dil şişmesi, yutma/konuşma veya nefes alma güçlüğü varsa derhal acil servise; 2 haftadan uzun süren yara, kanama veya sertlik varsa KBB/diş hekimine başvurun.',
        ),
      ],
    ),
    CheckCategory.face: ModuleReferenceSpec(
      category: CheckCategory.face,
      clinicalMethodSummary:
          'ISO-24444 Individual Typology Angle (ITA°) ile Fitzpatrick I–VI fototip uyarlamalı renk dengesi, Eritem İndeksi ve kişisel normal (bazal ΔE) karşılaştırması.',
      healthySummary:
          'Sağlıklı yüz cildi kişinin doğal ten alt tonuyla uyumlu, dengeli renktedir; ani sararma, belirgin solgunluk, yaygın kızarıklık veya dudak çevresi morarması yoktur.',
      captureQualityChecklist: [
        'Makyajsız, filtresiz ve doğrudan gün ışığı alan bir ortamda çekim yapın.',
        'Kişisel normal (bazal) kaydınız varsa aynı ışıkta kıyaslama çok daha doğru olur.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'face_daylight_baseline',
          title: 'Doğal Gün Işığı & Kişisel Bazal Kıyas Protokolü',
          purpose:
              'Her bireyin doğal cilt alt tonu (Fitzpatrick I–VI) farklıdır; en doğru değerlendirme sağlıklı gününüzde kaydettiğiniz bazal ton ile ΔE farkıdır.',
          steps: [
            'Pencere kenarında, makyajsız ve filtresiz olarak yüzünüzün doğal bir fotoğrafını kaydedin.',
            'Sonuç ekranından "Kişisel Normalim Olarak Kaydet" seçeneğini işaretleyin.',
            'Şüpheli günlerde göz akı ve dudak rengiyle birlikte tekrar çekin.',
          ],
          normalResult: 'Bazal kaydınıza göre renk sapması ΔE < 8 aralığında kalır.',
          warningResult:
              'Ani sararma (özellikle göz akıyla birlikte), belirgin solgunluk veya dudak morarması görülürse hekime başvurun.',
          icon: Icons.face_retouching_natural_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'face_healthy_balanced',
          title: 'Dengeli Doğal Cilt Tonu',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFE4B99B),
          visualSignature:
              'Kişinin doğal alt tonuyla uyumlu, aşırı kızarıklık veya sarı/gri kayma göstermeyen görünüm.',
          possibleAssociations: 'Olağan cilt görünümü.',
        ),
        ReferenceFinding(
          id: 'face_pallor',
          title: 'Belirgin Solgunluk / Matlık',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFEDE0D6),
          visualSignature:
              'Kişinin olağan ten rengine kıyasla dudak ve yanaklarda belirgin solukluk/renk kaybı.',
          possibleAssociations:
              'Kansızlık (anemi), yorgunluk, düşük tansiyon, sıvı eksikliği veya vitamin eksiklikleri.',
        ),
        ReferenceFinding(
          id: 'face_flushing_erythema',
          title: 'Yaygın Yüz Kızarıklığı / Sıcaklık',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFDF7E72),
          visualSignature:
              'Yanaklarda, burun köprüsünde veya tüm yüzde belirgin pembe-kırmızı ton artışı.',
          possibleAssociations:
              'Ateş, güneş maruziyeti, egzersiz, rozasea/hassas cilt, alerji veya tansiyon dalgalanması.',
        ),
        ReferenceFinding(
          id: 'face_jaundice_tint',
          title: 'Ciltte Sarımsı Ton (Sarılık Şüphesi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFE3C968),
          visualSignature:
              'Gün ışığında yüz ve ciltte belirgin sarı/sarı-yeşil renk değişimi.',
          possibleAssociations:
              'Sklera sarılığı da eşlik ediyorsa bilirubin artışı, karaciğer veya safra yolu değerlendirmesi gerekir.',
          redFlagNote:
              'Göz akında sararma, koyu idrar veya halsizlik varsa gecikmeden doktora başvurun.',
        ),
        ReferenceFinding(
          id: 'face_perioral_cyanosis',
          title: 'Dudak / Ağız Çevresi Morarması',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF8C7BA6),
          visualSignature:
              'Dudaklarda veya ağız çevresinde soğuk dışı mavimsi-morumsu renk değişimi.',
          possibleAssociations:
              'Solunum veya dolaşım kaynaklı oksijen düşüklüğü uyarısı.',
          redFlagNote:
              'Nefes darlığı veya göğüs ağrısı varsa acil tıbbi destek alın.',
        ),
      ],
    ),
    CheckCategory.skinCondition: ModuleReferenceSpec(
      category: CheckCategory.skinCondition,
      clinicalMethodSummary:
          'CIE ΔE lezyon segmentasyonu, kantitatif ABCDE (Asimetri, Sınır kompaktlık indeksi P²/4πA, 6-renkli dermoskopik palet), çevre deri Fitzpatrick ITA° uyarlaması ve anüler halka (mantar) analizi.',
      healthySummary:
          'Sağlıklı cilt yüzeyi homojen renkli, pürüzsüz ve bütünlüğü korunmuş durumdadır; çevre ciltten keskin biçimde ayrılan kızarık plak, pullanma, akıntı veya asimetrik çok renkli lezyon bulunmaz.',
      captureQualityChecklist: [
        'Lezyonu 10–15 cm mesafeden net odaklayın ve çevresinde sağlıklı deriden küçük bir alan bırakın.',
        'Doğal gün ışığında çekin; krem/merhem sürülü değilken görüntü alın.',
        'Ben çapını izlemek için yanına küçük bir cetvel veya 6 mm kurşun kalem silgisi koyarak karşılaştırma yapabilirsiniz.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'skin_glass_diascopy_test',
          title: 'Şeffaf Bardak (Diaskopi) Testi — Döküntü Aciliyet Kontrolü',
          purpose:
              'Kızarıklığın basit damar genişlemesi/alerji mi yoksa cilt altı kanaması (peteşi/purpura) mı olduğunu ayırt eder.',
          steps: [
            'Temiz, şeffaf bir cam bardağın kenarını kızarık/mor döküntünün üzerine hafifçe bastırın.',
            'Camın içinden bakarak kızarıklığın baskı altında solup solmadığını izleyin.',
          ],
          normalResult:
              'Döküntü baskı altında beyazlaşıp soluyorsa ("blanching") genellikle basit kızarıklık, egzama veya ürtikerdir.',
          warningResult:
              'Baskıya rağmen hiç solmayan toplu iğne başı kırmızı-mor noktacıklar (peteşi/purpura) — özellikle ateş veya halsizlik varsa — ACİL tıbbi değerlendirme gerektirir!',
          icon: Icons.science_outlined,
        ),
        ClinicalSelfTest(
          id: 'skin_abcde_ugly_duckling',
          title: 'ABCDE + "Çirkin Ördek Yavrusu" & EFG Kuralı',
          purpose:
              'Benlerde melanom ve melanom dışı nodüler cilt kanserleri açısından dermoskopi önceliğini belirler.',
          steps: [
            'A-B-C-D-E: Asimetri, düzensiz sınır (Border), 2+ renk (Color), >6 mm çap (Diameter) veya değişim (Evolving) var mı?',
            'Çirkin Ördek Yavrusu: Bu ben vücudunuzdaki diğer tüm benlerden belirgin şekilde farklı mı?',
            'EFG (Nodüler Lezyon): Kabarık (Elevated), sert (Firm) ve 1 aydan uzun süredir büyüyor (Growing) mu?',
          ],
          normalResult:
              'Simetrik, keskin düzgün sınırlı, tek tonlu ve yıllardır değişmeyen benler genellikle olağan nevüs görünümündedir.',
          warningResult:
              'Herhangi bir ABCDE, EFG, "Çirkin Ördek" bulgusu veya 4+ haftadır iyileşmeyen kanamalı yara varsa gecikmeden Dermatoloji (dermoskopi) muayenesi alın.',
          icon: Icons.biotech_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'skin_healthy_intact',
          title: 'Sağlıklı Bütün Cilt Yüzeyi',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFE2B89B),
          visualSignature:
              'Çevre deriyle uyumlu renk, kızarık plak, pullanma, kabarcık veya düzensiz pigment yok.',
          possibleAssociations: 'Olağan cilt bariyeri.',
        ),
        ReferenceFinding(
          id: 'skin_eczema_dermatitis_cue',
          title: 'Kızarık, Kuru / Kaşıntılı Döküntü (Dermatit / Egzama İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD87A6D),
          visualSignature:
              'Çevre cilde göre daha kırmızı/pembe, hafif pütürlü veya kuru, kaşıntı eşlik eden düzensiz yamalar.',
          possibleAssociations:
              'Atopik egzama, kontakt dermatit (deterjan/kozmetik/metal teması) veya tahriş.',
        ),
        ReferenceFinding(
          id: 'skin_scaly_plaque_psoriasis_cue',
          title: 'Gümüşi-Beyaz Pullu Sınırları Belirgin Plak',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFDAA49A),
          visualSignature:
              'Kızarık taban üzerinde parlak beyaz/gümüşi pullanma gösteren belirgin sınırlı plaklar (dirsek, diz, saçlı deri).',
          possibleAssociations:
              'Sedef (psöriyazis), seboreik dermatit veya kronik kuru egzama açısından dermatolog değerlendirmesi.',
        ),
        ReferenceFinding(
          id: 'skin_ring_fungal_cue',
          title: 'Halka Şeklinde Kenarı Kızarık Lezyon (Mantar İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFC96F5E),
          visualSignature:
              'Kenarları hafif kabarık, pullu ve kırmızı; orta kısmı daha soluk/açık halka şeklinde lezyon.',
          possibleAssociations:
              'Yüzeysel mantar enfeksiyonu (tinea) ön ipucu; kortizonlu krem sürmeden cildiye uzmanına gösterilmelidir.',
        ),
        ReferenceFinding(
          id: 'skin_urticaria_hives_cue',
          title: 'Kabarık, Gezici Pembe Plaklar (Ürtiker / Kurdeşen İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE88F8B),
          visualSignature:
              'Cilt yüzeyinden hafif kabarık, ortası soluklaşabilen pembe-kırmızı, şiddetli kaşıntılı kabartılar.',
          possibleAssociations:
              'Alerjik reaksiyon, gıda/ilaç duyarlılığı, ısı/stres kaynaklı ürtiker.',
          redFlagNote:
              'Dudak/dil şişmesi, ses kısıklığı veya nefes darlığı varsa acil servise başvurun.',
        ),
        ReferenceFinding(
          id: 'skin_pustule_yellow_crust_cue',
          title: 'Sarımsı Kabuklanma / İltihaplı Kabarcık',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD9A74A),
          visualSignature:
              'Kızarık zemin üzerinde bal rengi sarı kabuklanma, içi sıvı/irinli kabarcık veya folikül çevresi şişlik.',
          possibleAssociations:
              'Akne, folikülit, impetigo veya viral kabarcık (uçuk/zona) açısından hekim değerlendirmesi.',
        ),
        ReferenceFinding(
          id: 'skin_abcde_suspicious_mole',
          title: 'ABCDE Şüpheli Koyu / Çok Renkli veya Asimetrik Ben',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF47302A),
          visualSignature:
              'Asimetrik şekil, girintili/bulanık sınır, tek lezyon içinde birden fazla koyu/kahverengi/siyah/kırmızı ton, >6 mm çap veya hızlı değişim/kanama.',
          possibleAssociations:
              'Atipik nevüs veya melanom dışlanması için dermoskopik dermatoloji muayenesi şarttır.',
          redFlagNote:
              'Büyüyen, rengi değişen, kabuklanan veya kanayan benlerde gecikmeden dermatoloğa başvurun.',
        ),
        ReferenceFinding(
          id: 'skin_spreading_cellulitis_warning',
          title: 'Hızla Yayılan Sıcak, Ağrılı, Parlak Kızarıklık',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFC23934),
          visualSignature:
              'Sınırları hızla genişleyen parlak kırmızı, gergin, dokunmakla sıcak ve ağrılı cilt alanı.',
          possibleAssociations:
              'Selülit veya bakteriyel derin cilt enfeksiyonu açısından acil tıbbi değerlendirme gerekir.',
          redFlagNote:
              'Ateş, titreme veya kırmızı çizgilenme eşlik ediyorsa acil servise başvurun.',
        ),
        ReferenceFinding(
          id: 'skin_non_healing_cancer_cue',
          title: 'İyileşmeyen Kabuklu Yara / İnci Parlaklığında Nodül (BCC/SCC Uyarı)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFB75D57),
          visualSignature:
              '4 haftadan uzun süredir iyileşmeyen, tekrarlayan kanamalı/kabuklu yara veya kenarı inci parlaklığında kabarık nodül (özellikle güneşe açık yüz/kulak/elde).',
          possibleAssociations:
              'Melanom dışı cilt kanserleri (bazal hücreli veya skuamöz hücreli karsinom) dışlanması için dermoskopik dermatoloji muayenesi gerekir.',
          redFlagNote:
              '4 haftayı aşan iyileşmeyen veya kanayan her cilt yarası dermatolog tarafından incelenmelidir.',
        ),
        ReferenceFinding(
          id: 'skin_wart_rough_dots_cue',
          title: 'Pütürlü Kabartı & Küçük Siyah Noktacıklar (Siğil İpucu)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFCCB29A),
          visualSignature:
              'Cilt tonunda veya hafif grimsi-sarı sert, pütürlü/karnabahar benzeri kabartı; merkezinde toplu iğne başı kadar siyah noktalar (pıhtılaşmış kapiller).',
          possibleAssociations:
              'Yaygın/plantar siğil (HPV) veya nasır/keratoz ön ipucu; yüz, genital bölge ve diyabetik ayakta kendi kendine asit uygulanmamalıdır.',
        ),
        ReferenceFinding(
          id: 'skin_bruise_ecchymosis_cue',
          title: 'Morluk / Ekimoz Renk Evreleri (Mor → Lacivert → Yeşil-Sarı)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFF66538A),
          visualSignature:
              'Taze evrede kırmızı-mor, orta evrede lacivert-mor, iyileşme evresinde (7–14 gün) yeşilimsi-sarı renk değişimi gösteren cilt altı kanama alanı.',
          possibleAssociations:
              'Darbe sonrası olağan ekimoz; ancak darbe olmadan sık ve kendiliğinden çıkıyorsa trombosit/pıhtılaşma veya kan sulandırıcı açısından Dahiliye değerlendirmesi gerekir.',
          redFlagNote:
              'Darbesiz çoklu morluklar veya diş eti/burun kanaması eşlik ediyorsa hekime başvurun.',
        ),
        ReferenceFinding(
          id: 'skin_facial_hyperpigmentation_cue',
          title: 'Yüzde Güneş Lekesi / Melazma / Akne Sonrası Pigmentasyon',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFB8845B),
          visualSignature:
              'Yanak, alın veya üst dudakta çevre cilde göre daha koyu açık-koyu kahverengi yamalar veya sivilce sonrası pembe-kahverengi izler.',
          possibleAssociations:
              'Güneş lekesi (solar lentigo), melazma veya post-inflamatuar hiperpigmentasyon. Asimetrik/çok renkli veya değişen lekelerde önce dermoskopi yapılmalıdır.',
        ),
        ReferenceFinding(
          id: 'skin_non_blanching_petechiae',
          title: 'Baskıyla Solmayan Mor Noktacıklar (Peteşi / Purpura — Cam Testi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF8C1E35),
          visualSignature:
              'Cilt yüzeyinden kabarık olmayan, şeffaf cam bardakla bastırıldığında dahi beyazlamayan toplu iğne başı kırmızı-mor noktacıklar.',
          possibleAssociations:
              'Trombosit düşüklüğü, damar duvarı hassasiyeti veya ateşli durumlarda acil tıbbi değerlendirme gerektiren cilt altı mikro kanamaları.',
          redFlagNote:
              'Ateş, ense sertliği, şiddetli halsizlik veya hızla yayılan solmayan mor döküntüler varsa DERHAL acil servise başvurun.',
        ),
      ],
    ),
    CheckCategory.urine: ModuleReferenceSpec(
      category: CheckCategory.urine,
      clinicalMethodSummary:
          'Armstrong hidrasyon renk skalası, beyaz referans kutulu Von Kries renk kalibrasyonu ve gıda/ilaç/semptom bağlam filtrelemesi.',
      healthySummary:
          'Sağlıklı idrar berrak ve açık saman sarısı tondadır; bu görünüm yeterli sıvı alımını (iyi hidrasyon) gösterir.',
      captureQualityChecklist: [
        'Beyaz bir zemin/kap veya beyaz klozet kenarını "Beyaz Referans" kutusuna hizalayın.',
        'Sarı banyo ışığı idrarı olduğundan daha koyu gösterebilir; Beyaz Referans modunu açık tutun.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'urine_armstrong_hydration',
          title: 'Armstrong Hidrasyon & Gıda/İlaç Kontrolü',
          purpose:
              'İdrar rengindeki koyulaşmanın basit susuzluk mu yoksa tıbbi değerlendirme gerektiren bir bulgu mu olduğunu hızla ayırır.',
          steps: [
            'Son 24 saatte B vitamini, pancar, böğürtlen veya rifampisin/fenazopiridin gibi renk veren ilaç alıp almadığınızı kontrol edin.',
            'Koyu sarı idrar gördüyseniz 2 saat içinde 2–3 bardak su içip bir sonraki idrar rengini gözlemleyin.',
          ],
          normalResult:
              'Su içtikten sonra 1–2 idrarda rengin açık saman sarısına açılması olağan sıvı ihtiyacını gösterir.',
          warningResult:
              'Su içmenize rağmen çay/kola rengi sürüyorsa, pembe/kırmızı renk varsa veya yanma/ateş eşlik ediyorsa hekime başvurun.',
          icon: Icons.water_drop_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'urine_healthy_pale_straw',
          title: 'Açık Saman Sarısı (İdeal Hidrasyon)',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFF3EBAC),
          visualSignature:
              'Berrak, şeffaf açık saman/limonata sarısı ton; bulanıklık veya koyu tortu yok.',
          possibleAssociations: 'Yeterli ve dengeli sıvı tüketimi.',
        ),
        ReferenceFinding(
          id: 'urine_clear_overhydrated',
          title: 'Tamamen Renksiz / Su Gibi',
          isHealthyReference: false,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFF6F8F5),
          visualSignature: 'Neredeyse tamamen şeffaf, sarı pigmenti yok denecek kadar az.',
          possibleAssociations:
              'Kısa sürede yüksek miktarda su içildiğini gösterir; çok sık idrar ve aşırı susama eşlik ediyorsa takip edilmelidir.',
        ),
        ReferenceFinding(
          id: 'urine_dark_yellow_dehydration',
          title: 'Koyu Sarı / Bal Rengi',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE1B836),
          visualSignature:
              'Yoğun, doygun sarı veya parlak neon sarı renk.',
          possibleAssociations:
              'Hafif-orta sıvı eksikliği (dehidrasyon) veya B vitamini / multivitamin takviyesi.',
        ),
        ReferenceFinding(
          id: 'urine_cloudy_foamy',
          title: 'Bulanık veya Kalıcı Aşırı Köpüklü',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFDCD39E),
          visualSignature:
              'Berraklığını kaybetmiş bulanık görünüm veya hızla dağılmayan yoğun beyaz köpük tabakası.',
          possibleAssociations:
              'Sıvı eksikliği, idrar yolu enfeksiyonu (yanma/koku eşlik ediyorsa) veya kalıcı köpükte proteinüri/böbrek kontrolü.',
        ),
        ReferenceFinding(
          id: 'urine_pink_red_hematuria',
          title: 'Pembe / Kırmızımsı İdrar',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFD15B68),
          visualSignature:
              'Açık pembeden parlak kırmızıya uzanan kan/pancar benzeri renklenme.',
          possibleAssociations:
              'Son 24 saatte pancar, böğürtlen veya renk veren ilaç tüketilmediyse idrarda kan (hematüri), böbrek taşı veya enfeksiyon açısından mutlaka doktor muayenesi gerekir.',
          redFlagNote:
              'Yanma, yan/kasık ağrısı, ateş veya pıhtı varsa acil tıbbi değerlendirme alın.',
        ),
        ReferenceFinding(
          id: 'urine_dark_amber_tea',
          title: 'Koyu Kehribar / Çay-Kola Rengi',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF8B5723),
          visualSignature:
              'Koyu kahverengi, demli çay veya kola benzeri düşük parlaklıklı koyu ton.',
          possibleAssociations:
              'Ciddi dehidrasyon, karaciğer/safra yolu bilirubin artışı veya yoğun egzersiz sonrası kas yıkımı açısından değerlendirilmelidir.',
          redFlagNote:
              'Su içmenize rağmen rengi açılmıyorsa veya gözlerde sararma eşlik ediyorsa gecikmeden doktora başvurun.',
        ),
      ],
    ),
    CheckCategory.stool: ModuleReferenceSpec(
      category: CheckCategory.stool,
      clinicalMethodSummary:
          'Standart dışkı renk uyarı skalası (melena, akolik kil rengi, hematokezya) + Bristol Dışkı Kıvam Skalası (Tip 1–7) ve ilaç/diyet bağlamı.',
      healthySummary:
          'Sağlıklı dışkı açık, orta veya koyu kahverengi tonlardadır; siyah katran, beyaz/kil rengi veya belirgin kırmızı kan rengi içermez.',
      captureQualityChecklist: [
        'Gölge düşmeyecek doğrudan aydınlatma altında çekin; Beyaz Referans kutusunu beyaz klozet kenarına hizalayın.',
        'Son 48 saatteki gıda (pancar, ıspanak) ve ilaç (demir, bizmut) kullanımınızı dikkate alın.',
      ],
      selfTests: [
        ClinicalSelfTest(
          id: 'stool_bristol_scale',
          title: 'Bristol Dışkı Kıvam Skalası (Tip 1–7)',
          purpose:
              'Renk kontrolüne ek olarak bağırsak geçiş hızını (kabızlık vs. ideal vs. ishal) gastroenteroloji standardıyla takip etmenizi sağlar.',
          steps: [
            'Tip 1–2 (Sert topak / çatlaklı sert): Kabızlık eğilimi — lif ve su alımını artırın.',
            'Tip 3–4 (Pürüzsüz, yumuşak şekilli): İdeal bağırsak geçişi.',
            'Tip 5–7 (Yumuşak parçalar / lapa / tamamen sulu): Hızlı geçiş veya ishal — sıvı/elektrolit desteği önemlidir.',
          ],
          normalResult: 'Kahverengi ton ve Bristol Tip 3–4 aralığı olağandır.',
          warningResult:
              'Demir/bizmut olmadan siyah katran, kil/beyaz renk, parlak kırmızı kan veya 3 günden uzun sulu ishal varsa hekime başvurun.',
          icon: Icons.health_and_safety_outlined,
        ),
      ],
      findings: [
        ReferenceFinding(
          id: 'stool_healthy_brown',
          title: 'Sağlıklı Kahverengi Ton',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFF7D5333),
          visualSignature:
              'Açık-orta-koyu kahverengi aralığında doğal safra pigmentli görünüm.',
          possibleAssociations: 'Olağan sindirim ve safra akışı görünümü.',
        ),
        ReferenceFinding(
          id: 'stool_greenish',
          title: 'Yeşilimsi Dışkı',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFF5D7A47),
          visualSignature: 'Zeytin yeşili veya koyu yeşil ağırlıklı renk tonu.',
          possibleAssociations:
              'Ispanak/yeşil sebzeler, demir takviyesi, yeşil gıda boyaları veya ishal nedeniyle hızlı bağırsak geçişi.',
        ),
        ReferenceFinding(
          id: 'stool_yellow_greasy',
          title: 'Sarımsı / Yağlı Görünüm',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFC9A641),
          visualSignature:
              'Parlak sarı, soluk sarı veya yüzeyde yağlı/köpüklü görünüm.',
          possibleAssociations:
              'Beslenme değişimi, bağırsak enfeksiyonu veya kalıcıysa yağ emilimi/safra/pankreas hassasiyeti.',
        ),
        ReferenceFinding(
          id: 'stool_black_tarry_melena',
          title: 'Çok Koyu / Siyah Katran Rengi (Melena Uyarısı)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF211E1D),
          visualSignature:
              'Koyu kahverengiden belirgin şekilde ayrılan simsiyah, parlak/katran görünümlü ton.',
          possibleAssociations:
              'Demir hapı, bizmut veya aktif kömür kullanılmıyorsa üst sindirim sistemi kanaması açısından acil tıbbi değerlendirme gerekir.',
          redFlagNote:
              'Baş dönmesi, baygınlık, halsizlik veya karın ağrısı eşlik ediyorsa acil servise başvurun.',
        ),
        ReferenceFinding(
          id: 'stool_pale_clay_white',
          title: 'Çok Açık / Kil Rengi / Beyazımsı',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFD9D5C9),
          visualSignature:
              'Kahverengi pigmentini kaybetmiş gri, krem, tebeşir veya kil rengi görünüm.',
          possibleAssociations:
              'Safra akışında azalma veya tıkanıklık (karaciğer/safra kesesi/pankreas) açısından doktor değerlendirmesi gerekir.',
          redFlagNote:
              'Koyu idrar, gözlerde sararma veya karın ağrısı eşlik ediyorsa gecikmeden doktora başvurun.',
        ),
        ReferenceFinding(
          id: 'stool_bright_red_blood',
          title: 'Parlak Kırmızı / Kanlı Görünüm',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFFB8322E),
          visualSignature:
              'Dışkı yüzeyinde veya karışık halde parlak kırmızı kan rengi.',
          possibleAssociations:
              'Pancar, domates sosu veya kırmızı gıda boyası değilse hemoroid, anal fissür veya alt sindirim sistemi kanaması açısından değerlendirilmelidir.',
          redFlagNote:
              'Aktif kanama, şiddetli karın ağrısı veya baş dönmesi varsa acil yardım alın.',
        ),
      ],
    ),
  };
}
