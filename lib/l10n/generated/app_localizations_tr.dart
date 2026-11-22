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

  @override
  String get menuSettings => 'Ayarlar (İzinler & Dil)';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguageDesc =>
      'Varsayılan olarak telefonun sistem dili kullanılır. İstersen aşağıdan istediğin dili seçebilirsin.';

  @override
  String get settingsPermissionsTitle => 'Uygulama İzinleri';

  @override
  String get settingsPermissionsDesc =>
      'Kamera ve fotoğraf/galeri izinlerini buradan kontrol edip yönetebilirsin.';

  @override
  String get settingsCameraPermission => 'Kamera İzni';

  @override
  String get settingsCameraPermissionDesc =>
      'Göz, dil, tırnak ve cilt çekimleri için';

  @override
  String get settingsPhotosPermission => 'Galeri & Fotoğraf İzni';

  @override
  String get settingsPhotosPermissionDesc =>
      'Galeriden fotoğraf ve tahlil görseli yüklemek için';

  @override
  String get settingsOpenSystemPermissions => 'Telefon Uygulama İzinlerini Aç';

  @override
  String get permChecking => 'Kontrol ediliyor...';

  @override
  String get permGranted => 'İzin Verildi';

  @override
  String get permDenied => 'İzin Gerekli';

  @override
  String get permPermanent => 'Sistem Ayarından Açılmalı';

  @override
  String get permUnavailable => 'Cihaz Tarafından Yönetiliyor';

  @override
  String get permGrantBtn => 'İzin Ver';

  @override
  String get permOpenSettingsBtn => 'Ayarları Aç';

  @override
  String get skinCancerRisk => 'Ben & Cilt Kanseri Risk';

  @override
  String get skinWart => 'Siğil Ön Kontrol';

  @override
  String get skinBruise => 'Morluk Takibi';

  @override
  String get skinFacialSpot => 'Yüz Lekesi';

  @override
  String get trackEyeTitle => 'Haftalık Göz (Sklera) Kontrolü';

  @override
  String get trackEyeSubtitle =>
      'Göz akında kızarıklık veya sarılık değişimini izle';

  @override
  String get trackTongueTitle => 'Haftalık Dil Gözlemi';

  @override
  String get trackTongueSubtitle =>
      'Dil rengi, beyaz/sarı kaplama ve doku değişimlerini takip et';

  @override
  String get trackNailTitle => 'Haftalık Tırnak Gözlemi';

  @override
  String get trackNailSubtitle =>
      'Tırnak yatağı solukluğu, morarma veya sararma kontrolü';

  @override
  String get trackFaceTitle => '2 Haftalık Yüz & Cilt Tonu';

  @override
  String get trackFaceSubtitle =>
      'Yüzde solgunluk, kızarıklık ve ton değişimini kıyasla';

  @override
  String get trackSkinTitle => 'Aylık Cilt, Ben & Siğil Kontrolü';

  @override
  String get trackSkinSubtitle =>
      'Ben, siğil, morluk ve yüz lekelerinde 30 günlük değişimi izle';

  @override
  String get trackHydrationTitle => 'Günlük Hidrasyon (İdrar) Takibi';

  @override
  String get trackHydrationSubtitle =>
      'Kamerasız renk kartıyla 2 saniyede su dengeni kaydet';

  @override
  String get trackStoolTitle => 'Haftalık Dışkı Rengi Takibi';

  @override
  String get trackStoolSubtitle =>
      'Sindirim ve renk uyarılarını düzenli takip et';

  @override
  String get trackBpTitle => 'Günlük Tansiyon Ölçümü';

  @override
  String get trackBpSubtitle =>
      'Büyük/küçük tansiyon ve nabız trendini günlük kaydet';

  @override
  String get trackSugarTitle => 'Günlük Kan Şekeri Takibi';

  @override
  String get trackSugarSubtitle =>
      'Açlık veya tokluk kan şekeri değerlerini izle';

  @override
  String get trackLabTitle => '3 Aylık Kan Tahlili & Rapor';

  @override
  String get trackLabSubtitle =>
      'Hastane/kan testi raporlarını yükleyip dönemsel karşılaştır';

  @override
  String get statusFirstPending => 'İlk kayıt bekleniyor';

  @override
  String get statusDueNow => 'Kontrol zamanı geldi';

  @override
  String get statusDoneToday => 'Bugün tamamlandı';

  @override
  String statusNextDays(int days) {
    return 'Sonraki kontrol: $days gün sonra';
  }

  @override
  String get actionCheckNow => 'Şimdi Kontrol Et';

  @override
  String get actionLogReading => 'Ölçüm Gir';

  @override
  String get actionAddReport => 'Rapor Ekle';

  @override
  String checkMethodTitle(String category) {
    return '$category • Kontrol Yöntemi';
  }

  @override
  String get checkMethodSubtitle =>
      'Fotoğraf çekmeden 2 saniyede renk kartından seçebilir veya kamera ölçümünü kullanabilirsiniz.';

  @override
  String get colorCardRecommendedTitle => 'Kamerasız Renk Kartı (Önerilen)';

  @override
  String get colorCardRecommendedSubtitle =>
      'Fotoğraf çekmeden gizli ve hızlı kayıt (2 sn)';

  @override
  String get cameraMeasureTitle => 'Kamera ile Renk Ölçümü';

  @override
  String get cameraMeasureSubtitle =>
      'Beyaz referans kalibrasyonu ile otomatik ölçüm';

  @override
  String get referenceGuideSubtitle =>
      'Sağlıklı ve dikkat gerektiren görsel bulguları incelemek için modül seçin.';

  @override
  String get historyEmpty => 'Henüz kayıtlı bir kontrol yok.';

  @override
  String get filterAll => 'Tümü';

  @override
  String get aiSettingsTitle => 'Yapay Zeka & Gizlilik';

  @override
  String get vitalsBpTab => 'Tansiyon';

  @override
  String get vitalsSugarTab => 'Kan Şekeri';

  @override
  String get skinScreenTitle => 'Cilt Hastalıkları Ön Kontrol';
}
