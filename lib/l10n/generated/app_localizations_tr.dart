// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'Bu uygulama tıbbi teşhis koymaz; yalnızca bilgilendirme ve ön farkındalık amaçlıdır.';

  @override
  String get disclaimerTitle => 'Önemli Tıbbi Bilgilendirme';

  @override
  String get disclaimerFull =>
      'VisualCheckUp, kamera görüntüleri üzerinden genel renk ve görsel ipuçlarına dayalı bir ön değerlendirme sunar. Tıbbi bir cihaz değildir ve kesinlikle doktor muayenesi, laboratuvar testi veya tıbbi teşhis yerine geçmez.\n\n• Ortam ışığı, kamera sensörü ve telefon ekranı renk algısını doğrudan etkiler.\n• Şiddetli ağrı, kanama, yüksek ateş, sarılık, siyah/beyaz dışkı veya ani görme değişimi gibi belirtilerde vakit kaybetmeden bir sağlık kuruluşuna başvurun.\n• Gizlilik: Çekilen görüntüler varsayılan olarak yalnızca cihazınızda işlenir.';

  @override
  String get disclaimerAccept => 'Okudum, Anladım';

  @override
  String get loginTagline =>
      'Cilt, ben ve görsel sağlık değişimleri için kişisel takip ve doktor randevusuna hazırlık asistanı.';

  @override
  String get featureColorCalibration => 'Renk Kalibrasyonu';

  @override
  String get featurePrivacyFirst => 'Gizlilik Öncelikli';

  @override
  String get featureOptionalAi => 'Opsiyonel AI';

  @override
  String get loginCardTitle => 'Hesabınızla devam edin';

  @override
  String get loginCardSubtitle =>
      'Kişisel renk referanslarınızı ve kontrol geçmişinizi senkronize tutun.';

  @override
  String get continueWithApple => 'Apple ile Devam Et';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get orDivider => 'veya';

  @override
  String get continueAsGuest => 'Misafir Olarak Devam Et';

  @override
  String get guestGreeting => 'Cilt & Görsel Sağlık Takibi';

  @override
  String userGreeting(String name) {
    return 'Merhaba, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider Hesabı';
  }

  @override
  String get localOnlyLabel => 'Yalnızca bu cihazda kayıtlı';

  @override
  String get menuHome => 'Ana Ekran';

  @override
  String get menuSectionVisualChecks => 'GÖRSEL KONTROLLER';

  @override
  String get menuSkinGroup => 'Cilt (Ben, Siğil, Morluk, Leke)';

  @override
  String get menuSkinGeneral => 'Genel Cilt & Döküntü';

  @override
  String get menuSectionTracking => 'TAKİP, TAHLİL & VİTAL';

  @override
  String get menuFollowUpPlan => 'Kişisel Takip Planı';

  @override
  String get menuVitalsTracker => 'Tansiyon & Şeker Takibi';

  @override
  String get menuLabReports => 'Tahlil & Hastane Raporları';

  @override
  String get menuQuickColorCard => 'Kamerasız Renk Kartı';

  @override
  String get menuHistory => 'Kontrol Geçmişi';

  @override
  String get menuReferenceGuide => 'Görsel Referans Rehberi';

  @override
  String get menuSectionSettings => 'AYARLAR & GİZLİLİK';

  @override
  String get menuAiSettings => 'Yapay Zeka & Gizlilik';

  @override
  String get menuDisclaimer => 'Tıbbi Bilgilendirme';

  @override
  String get menuTheme => 'Görünüm Teması';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get menuLanguage => 'Uygulama Dili';

  @override
  String get languageSystem => 'Sistem Dili';

  @override
  String get signInGoogleOrApple => 'Google veya Apple ile Giriş Yap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountTitle => 'Hesabı ve Yerel Verileri Sil';

  @override
  String get deleteAccountBody =>
      'Oturumunuz kapatılacak ve bu cihazdaki kontrol geçmişiniz ile kişisel renk referanslarınız kalıcı olarak silinecek. Devam etmek istiyor musunuz?';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get followUpCardTitle => 'Kişisel Takip Planı';

  @override
  String get followUpSelectEdit => 'Seç / Düzenle';

  @override
  String get followUpStart => 'Başla';

  @override
  String get followUpEmptyHint =>
      'Göz, idrar, tansiyon, şeker ve diğer takiplerini seçmek için dokun.';

  @override
  String get followUpSheetSubtitle =>
      'Göz, dil, tırnak, cilt, idrar, dışkı, tansiyon, kan şekeri ve tahlil verilerinin tümünü tek planda seçip izle.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active aktif takip • $completed güncel • $due bekleniyor';
  }

  @override
  String get homeCategoriesTitle => 'Kontrol Kategorileri';

  @override
  String get homeCategoriesSubtitle =>
      'Kamera veya kamerasız renk kartı ile görsel değişim takibi yapın.';

  @override
  String get homeLabsVitalsTitle => 'Tahlil, Tansiyon & Şeker';

  @override
  String get homeLabsVitalsSubtitle =>
      'Hastane/kan testi raporlarını oku, tansiyon ve şeker değişimini tarihli izle.';

  @override
  String get homeLabsCardTitle => 'Tahlil & Raporlar';

  @override
  String get homeLabsCardEmpty => 'Kan testi oku & değerlendir';

  @override
  String homeLabsCardCount(int count) {
    return '$count kayıtlı rapor';
  }

  @override
  String get homeVitalsCardTitle => 'Tansiyon & Şeker';

  @override
  String get homeVitalsCardEmpty => 'Ölçüm gir & trend izle';

  @override
  String homeVitalsCardCount(int count) {
    return '$count kayıtlı ölçüm';
  }

  @override
  String get homeRecentChecks => 'Son Kontroller';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get catEyeTitle => 'Göz (Sklera)';

  @override
  String get catEyeSubtitle => 'Kızarıklık, sarılık ve göz akı tonu';

  @override
  String get catNailTitle => 'Tırnak';

  @override
  String get catNailSubtitle => 'Solukluk, morarma ve sararma kontrolü';

  @override
  String get catTongueTitle => 'Dil';

  @override
  String get catTongueSubtitle => 'Renk, beyaz/sarı tabaka ve kuruluk';

  @override
  String get catFaceTitle => 'Yüz & Cilt';

  @override
  String get catFaceSubtitle => 'Cilt tonu, solgunluk ve kızarıklık';

  @override
  String get catSkinTitle => 'Cilt Hastalıkları';

  @override
  String get catSkinSubtitle => 'Ben, siğil, morluk, yüz lekesi ve döküntü';

  @override
  String get catUrineTitle => 'İdrar Rengi';

  @override
  String get catUrineSubtitle => 'Hidrasyon ve renk skalası kontrolü';

  @override
  String get catStoolTitle => 'Dışkı Rengi';

  @override
  String get catStoolSubtitle => 'Sindirim ve renk uyarı kontrolü';

  @override
  String get tooltipHistory => 'Geçmiş';

  @override
  String get tooltipAccountMenu => 'Hesap ve Menü';
}
