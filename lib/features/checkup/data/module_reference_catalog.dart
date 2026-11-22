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

  static List<ModuleReferenceSpec> get all =>
      CheckCategory.values.map(forCategory).toList();

  static const Map<CheckCategory, ModuleReferenceSpec> _specs = {
    CheckCategory.eye: ModuleReferenceSpec(
      category: CheckCategory.eye,
      healthySummary:
          'Sağlıklı göz akı (sklera) pürüzsüz, parlak, nötr porselen beyazı tondadır; yaygın sarılık, belirgin kanlanma veya odaklanmış kanama lekesi bulunmaz.',
      captureQualityChecklist: [
        'Doğal gün ışığında çekim yapın; sarı ampul altında sklera olduğundan sarı görünebilir.',
        'Flaş kullanmayın; göz kapağını nazikçe aralayarak skleranın net görünmesini sağlayın.',
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
      ],
    ),
    CheckCategory.nail: ModuleReferenceSpec(
      category: CheckCategory.nail,
      healthySummary:
          'Sağlıklı tırnak plağı pürüzsüz, yarı saydam ve esnektir; altındaki tırnak yatağı canlı doğal pembe tondadır, belirgin sararma, morarma, çökme, kalınlaşma veya koyu dikey bant içermez.',
      captureQualityChecklist: [
        'Tırnakta oje, cila veya jel bulunmamalıdır.',
        'Eller oda sıcaklığındayken (üşümemişken) beyaz bir kâğıt/zemin üzerinde, gün ışığında çekin.',
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
          title: 'Soluk / Beyazımsı Tırnak Yatağı',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFEEE4E2),
          visualSignature:
              'Normal pembe tona kıyasla belirgin derecede soluk, kansız/beyazımsı tırnak yatağı (Terry veya soluk tırnak görünümü).',
          possibleAssociations:
              'Demir eksikliği/anemi, periferik dolaşım yavaşlığı veya beslenme eksiklikleri açısından kan sayımıyla değerlendirilebilir.',
        ),
        ReferenceFinding(
          id: 'nail_yellow_thickened',
          title: 'Sararma ve Kalınlaşma',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD8BE67),
          visualSignature:
              'Tırnak plağında sarımsı-mat renklenme, kalınlaşma, ufalanma veya tırnak yatağından ayrılma (onikoliz).',
          possibleAssociations:
              'Oje/sigara boyanması, tırnak mantarı (onikomikoz), sedef veya nadiren kronik solunum/lenf hassasiyetleri.',
        ),
        ReferenceFinding(
          id: 'nail_white_spots_leukonychia',
          title: 'Beyaz Noktalar / Çizgiler (Lökonişi)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFF4F1EC),
          visualSignature:
              'Tırnak plağı içinde noktasal veya yatay beyaz bulutlanmalar.',
          possibleAssociations:
              'Çoğunlukla mikro travmalar veya manikür darbesi; tüm tırnaklarda yaygınsa çinko/protein dengesi değerlendirilebilir.',
        ),
        ReferenceFinding(
          id: 'nail_pitting_or_ridges',
          title: 'Çukurlaşma (Pitting) veya Enine Oluklar (Beau Çizgileri)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD6B4AE),
          visualSignature:
              'Tırnak yüzeyinde toplu iğne başı gibi küçük çukurlar veya tırnağı enine kesen belirgin çökük oluklar.',
          possibleAssociations:
              'Sedef (psöriyazis), egzama, alopecia areata veya birkaç ay önce geçirilmiş ağır enfeksiyon/yüksek ateş sonrası büyüme duraksaması.',
        ),
        ReferenceFinding(
          id: 'nail_spoon_koilonychia',
          title: 'Kaşık Tırnak (Koilonişi) / Aşırı Kırılganlık',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFE3C9C4),
          visualSignature:
              'Tırnak orta kısmının içe doğru çökük, kenarlarının yukarı kalkık ve ince olması.',
          possibleAssociations:
              'Uzun süreli demir eksikliği anemisi veya tiroid/mineral dengesizliği ön ipucu.',
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
              'Düşük kan oksijenlenmesi, Raynaud fenomeni, solunum veya dolaşım sistemi değerlendirmesi gerekir.',
          redFlagNote:
              'Nefes darlığı, göğüs ağrısı, dudak morarması veya baş dönmesi varsa acil tıbbi yardım alın.',
        ),
        ReferenceFinding(
          id: 'nail_dark_vertical_band',
          title: 'Koyu Kahverengi / Siyah Dikey Şerit (Melanoniki)',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF42312C),
          visualSignature:
              'Tırnak kökünden ucuna uzanan tekil koyu kahverengi/siyah dikey bant (özellikle genişleyen veya tırnak etine taşan — Hutchinson işareti).',
          possibleAssociations:
              'Darbe sonrası kanama (hematom) olabileceği gibi subungual melanom açısından mutlaka dermoskopik dermatoloji muayenesi gerekir.',
          redFlagNote:
              'Bilinen darbe yoksa, bant genişliyorsa veya tırnak etinde koyulaşma varsa gecikmeden dermatoloğa başvurun.',
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
              'Tek tırnakta darbe kaynaklı olabilir; birden fazla tırnakta travmasız görülüyorsa damar/kalp/sistemik değerlendirme önerilir.',
          redFlagNote:
              'Ateş, halsizlik veya birden fazla tırnakta kendiliğinden oluşuyorsa hekime başvurun.',
        ),
      ],
    ),
    CheckCategory.tongue: ModuleReferenceSpec(
      category: CheckCategory.tongue,
      healthySummary:
          'Sağlıklı dil nemli, esnek, doğal canlı pembe tonda ve üzerinde çok ince şeffaf/hafif beyazımsı bir tabaka bulunur; kalın pas, yoğun kızarıklık veya iyileşmeyen yara yoktur.',
      captureQualityChecklist: [
        'Kahve, çay, renkli yiyecek veya ağız gargarası sonrası en az 30 dakika bekleyin.',
        'Doğal gün ışığında dilinizi germeden hafifçe dışarı çıkarıp çerçeveleyin.',
      ],
      findings: [
        ReferenceFinding(
          id: 'tongue_healthy_pink',
          title: 'Sağlıklı Pembe Dil',
          isHealthyReference: true,
          riskLevel: RiskLevel.normal,
          swatchColor: Color(0xFFDC8D96),
          visualSignature:
              'Nemli, eşit pembe yüzey, ince doğal papilla dokusu, belirgin kalın tabaka veya yara yok.',
          possibleAssociations: 'Olağan ağız ve dil görünümü.',
        ),
        ReferenceFinding(
          id: 'tongue_thick_white_coating',
          title: 'Kalın Beyaz Tabaka / Pamukçuk İpucu',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFECE6E2),
          visualSignature:
              'Dil sırtını kaplayan kalın beyazımsı-kremsi tabaka veya peynirimsi beyaz plaklar.',
          possibleAssociations:
              'Ağız kuruluğu, yetersiz su tüketimi, ağızdan nefes alma, ağız hijyeni veya silinmeyen/ağrılı plaklarda oral mantar (kandida).',
        ),
        ReferenceFinding(
          id: 'tongue_yellow_brown_coating',
          title: 'Sarımsı / Kahverengimsi Pas Tabakası',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD6B96E),
          visualSignature:
              'Özellikle dil arka-orta kısmında sarımsı veya kahverengimsi renkli birikim.',
          possibleAssociations:
              'Çay/kahve/tütün, ağız kuruluğu, antibiyotik sonrası flora değişimi veya reflü/sindirim hassasiyeti.',
        ),
        ReferenceFinding(
          id: 'tongue_geographic_patches',
          title: 'Harita Görünümlü Kızarık Yamalar',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFD26D7B),
          visualSignature:
              'Beyazımsı kenarlı, ortası pürüzsüz pembe-kırmızı harita benzeri düzensiz adacıklar.',
          possibleAssociations:
              'Coğrafi dil (genellikle iyi huylu, stres veya baharatlı/asitli gıdalara hassasiyet gösterebilir).',
        ),
        ReferenceFinding(
          id: 'tongue_beefy_red_smooth',
          title: 'Yoğun Kırmızı / Pürüzsüz Dil (Atrofik / Çilek Dil)',
          isHealthyReference: false,
          riskLevel: RiskLevel.attention,
          swatchColor: Color(0xFFC93D4C),
          visualSignature:
              'Normal pembeden belirgin derecede parlak-koyu kırmızı, papillaların silindiği pürüzsüz veya şiş görünümlü dil.',
          possibleAssociations:
              'B12, folik asit veya demir eksikliği, sıcak yiyecek tahrişi veya ateşli enfeksiyonlar.',
        ),
        ReferenceFinding(
          id: 'tongue_purple_or_nonhealing_ulcer',
          title: 'Morarma, Belirgin Şişlik veya İyileşmeyen Yara',
          isHealthyReference: false,
          riskLevel: RiskLevel.urgent,
          swatchColor: Color(0xFF834C73),
          visualSignature:
              'Dil yüzeyinde koyu mor/mavimsi renk, belirgin ödem/şişlik veya 2 haftadan uzun süren sert kenarlı yara/beyaz-kırmızı leke.',
          possibleAssociations:
              'Oksijenlenme/dolaşım hassasiyeti, alerjik ödem (anjiyoödem) veya KBB/diş hekimi değerlendirmesi gereken oral lezyonlar.',
          redFlagNote:
              'Dil şişmesi, nefes alma veya yutma güçlüğü varsa acil servise başvurun.',
        ),
      ],
    ),
    CheckCategory.face: ModuleReferenceSpec(
      category: CheckCategory.face,
      healthySummary:
          'Sağlıklı yüz cildi kişinin doğal ten alt tonuyla uyumlu, dengeli renktedir; ani sararma, belirgin solgunluk, yaygın kızarıklık veya dudak çevresi morarması yoktur.',
      captureQualityChecklist: [
        'Makyajsız, filtresiz ve doğrudan gün ışığı alan bir ortamda çekim yapın.',
        'Kişisel normal (bazal) kaydınız varsa aynı ışıkta kıyaslama çok daha doğru olur.',
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
      healthySummary:
          'Sağlıklı cilt yüzeyi homojen renkli, pürüzsüz ve bütünlüğü korunmuş durumdadır; çevre ciltten keskin biçimde ayrılan kızarık plak, pullanma, akıntı veya asimetrik çok renkli lezyon bulunmaz.',
      captureQualityChecklist: [
        'Lezyonu 10–15 cm mesafeden net odaklayın ve çevresinde sağlıklı deriden küçük bir alan bırakın.',
        'Doğal gün ışığında çekin; krem/merhem sürülü değilken görüntü alın.',
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
      ],
    ),
    CheckCategory.urine: ModuleReferenceSpec(
      category: CheckCategory.urine,
      healthySummary:
          'Sağlıklı idrar berrak ve açık saman sarısı tondadır; bu görünüm yeterli sıvı alımını (iyi hidrasyon) gösterir.',
      captureQualityChecklist: [
        'Beyaz bir zemin/kap veya beyaz klozet kenarını "Beyaz Referans" kutusuna hizalayın.',
        'Sarı banyo ışığı idrarı olduğundan daha koyu gösterebilir; Beyaz Referans modunu açık tutun.',
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
      healthySummary:
          'Sağlıklı dışkı açık, orta veya koyu kahverengi tonlardadır; siyah katran, beyaz/kil rengi veya belirgin kırmızı kan rengi içermez.',
      captureQualityChecklist: [
        'Gölge düşmeyecek doğrudan aydınlatma altında çekin; Beyaz Referans kutusunu beyaz klozet kenarına hizalayın.',
        'Son 48 saatteki gıda (pancar, ıspanak) ve ilaç (demir, bizmut) kullanımınızı dikkate alın.',
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
