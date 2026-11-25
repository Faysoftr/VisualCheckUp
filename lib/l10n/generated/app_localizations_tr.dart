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

  @override
  String get providerGuest => 'Misafir';

  @override
  String signInFailed(String error) {
    return 'Giriş yapılamadı: $error';
  }

  @override
  String get riskNormal => 'Olağan Görünüm';

  @override
  String get riskAttention => 'Takip Önerilir';

  @override
  String get riskUrgent => 'Doktor Değerlendirmesi Önerilir';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'Son: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'Son: $count değer ($abnormal referans dışı)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Son: $count değer (tümü normal)';
  }

  @override
  String get labStatusCriticalLow => 'Kritik Düşük';

  @override
  String get labStatusLow => 'Düşük';

  @override
  String get labStatusNormal => 'Normal';

  @override
  String get labStatusHigh => 'Yüksek';

  @override
  String get labStatusCriticalHigh => 'Kritik Yüksek';

  @override
  String get labSourceManual => 'Manuel Giriş';

  @override
  String get labSourcePasted => 'Rapor Metninden Okundu';

  @override
  String get labSourcePhoto => 'JPG / Fotoğraf Raporu';

  @override
  String get labSourcePdf => 'PDF Raporu';

  @override
  String get bpLow => 'Düşük Tansiyon';

  @override
  String get bpNormal => 'Normal Aralık';

  @override
  String get bpElevated => 'Yüksek-Normal';

  @override
  String get bpStage1 => 'Evre 1 Yüksek';

  @override
  String get bpStage2 => 'Belirgin Yüksek';

  @override
  String get bpCrisis => 'Acil Yüksek Tansiyon';

  @override
  String get sugarLow => 'Düşük Şeker (Hipoglisemi)';

  @override
  String get sugarNormal => 'Normal Aralık';

  @override
  String get sugarBorderline => 'Sınırda Yüksek';

  @override
  String get sugarHigh => 'Yüksek Kan Şekeri';

  @override
  String get sugarVeryHigh => 'Çok Yüksek Şeker';

  @override
  String get sugarTypeFasting => 'Açlık';

  @override
  String get sugarTypePostMeal => 'Tokluk (2. saat)';

  @override
  String get sugarTypeRandom => 'Rastgele';

  @override
  String get specialtyEye => 'Göz Hastalıkları veya Dahiliye';

  @override
  String get specialtyNail => 'Dermatoloji veya Dahiliye';

  @override
  String get specialtyTongue => 'KBB, Ağız & Diş Sağlığı veya Dahiliye';

  @override
  String get specialtySkin => 'Dermatoloji';

  @override
  String get specialtyUrine => 'Üroloji veya Dahiliye';

  @override
  String get specialtyStool => 'Gastroenteroloji veya Dahiliye';

  @override
  String get cloudBackupTitle => 'Bulut Yedekleme (İsteğe Bağlı • Firebase)';

  @override
  String get cloudBackupDesc =>
      'Varsayılan olarak tüm kan tahlili ve ölçüm verileriniz yalnızca bu cihazda saklanır. Telefon değiştirirken verilerinizi korumak isterseniz kendi Google/Apple hesabınıza özel yedeklemeyi açabilirsiniz.';

  @override
  String get cloudBackupToggleTitle => 'Buluta Yedeklemeyi Etkinleştir';

  @override
  String cloudBackupLastSync(String date) {
    return 'Son yedekleme: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Etkin • Yedeklemeye hazır';

  @override
  String get cloudBackupDisabledLocal => 'Kapalı • Yalnızca cihaz içi depolama';

  @override
  String get cloudBackupSignInRequired =>
      'Bulut yedekleme için Google veya Apple hesabıyla oturum açmanız gerekir.';

  @override
  String get cloudBackupNowBtn => 'Şimdi Yedekle';

  @override
  String get cloudRestoreBtn => 'Buluttan Geri Yükle';

  @override
  String get cloudConsentTitle => 'Bulut Yedekleme Onayı (KVKK)';

  @override
  String get cloudConsentBody =>
      'Kan tahlilleriniz, tansiyon/şeker ölçümleriniz ve kontrol kayıtlarınız varsayılan olarak yalnızca cihazınızda saklanır.\n\nBulut yedeklemeyi açarsanız bu sağlık verileri yalnızca kendi Google/Apple hesabınıza özel Firebase Firestore alanında saklanır; başka hiç kimse erişemez ve hesabınızı sildiğinizde buluttan tamamen silinir.\n\nOnaylıyor musunuz?';

  @override
  String get cloudConsentConfirm => 'Evet, Etkinleştir';

  @override
  String cloudBackupSuccess(int count) {
    return 'Bulut yedekleme tamamlandı: $count kayıt eşitlendi.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Yedekleme yapılamadı: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Buluttan geri yüklendi: $count kayıt cihazınıza aktarıldı.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Geri yükleme yapılamadı: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Bulut yedekleme kapatıldı. Yeni kayıtlar yalnızca cihazda tutulur.';

  @override
  String get aiCloudToggleTitle => 'Bulut Yapay Zeka (Gemini) Analizi';

  @override
  String get aiCloudOnDesc =>
      'Açık: Net ve kaliteli fotoğraflar küçültülerek anlık görsel analiz için güvenli bağlantıdan işlenir. İnternet yoksa cihaz içi analiz çalışır.';

  @override
  String get aiCloudOffDesc =>
      'Kapalı (0 Token): Tüm analizler yalnızca cihazınızda yapılır; hiçbir fotoğraf dışarı gönderilmez.';

  @override
  String get aiBackendOfflineNote =>
      'Firebase AI Logic / Gemini bağlantısı eklendiğinde bulut analizi bu tercihe göre otomatik devreye girer; şu an cihaz içi motor aktiftir.';

  @override
  String get aiOptimizationsTitle => 'Aktif Token & Veri Tasarrufu Kontrolleri';

  @override
  String get aiOptQualityGate =>
      '0-token bulanıklık, karanlık ve parlama kalite kapısı';

  @override
  String get aiOptCompression =>
      'Otomatik kırpma + 512px / 768px JPEG (%80) sıkıştırma';

  @override
  String get aiOptTieredModel =>
      'Akıllı model seçimi (Flash-Lite / Flash) & düşük thinking';

  @override
  String get aiOptHashCache =>
      'Aynı fotoğraf için cihaz içi hash önbelleği (0 token)';

  @override
  String get aiClearCacheBtn => 'AI Önbelleğini Temizle';

  @override
  String get aiCacheCleared => 'Yapay zeka önbelleği temizlendi.';

  @override
  String resultScreenTitle(String category) {
    return '$category Sonucu';
  }

  @override
  String get tooltipDoctorSummary => 'Doktora Göster Özeti';

  @override
  String get tooltipReferenceGuide => 'Referans Rehberi';

  @override
  String get calibratedColorTone => 'Kalibre Edilmiş Renk Tonu';

  @override
  String get sampledColorTone => 'Örneklenen Baskın Renk Tonu';

  @override
  String confidenceLabel(int percent) {
    return 'Ön değerlendirme güveni: %$percent';
  }

  @override
  String get whiteBalanceDefaultNote => 'Beyaz referans ile renk dengelendi.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Danışılabilecek bölüm: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Zaman İçi Değişim Karşılaştırması';

  @override
  String get todayLabel => 'Bugün';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Önceki kayıt: \"$title\" ($status). Toplam $count kayıt takip ediliyor.';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'Kişisel Normal Karşılaştırması';

  @override
  String get yourBaselineLabel => 'Normaliniz';

  @override
  String get warningFlagsTitle => 'Dikkat Edilmesi Gereken Belirtiler';

  @override
  String get observationsTitle => 'Gözlemler';

  @override
  String get recommendationsTitle => 'Öneriler';

  @override
  String get personalBaselineCardTitle => 'Kişisel Normal (Bazal) Kalibrasyon';

  @override
  String get personalBaselineCardDesc =>
      'Kendinizi sağlıklı hissettiğiniz bir günde bu ölçümü kişisel normaliniz olarak kaydedin; telefonunuzun kamera sensörüne özel sapmaları azaltır.';

  @override
  String get saveBaselineBtn => 'Kişisel Normalim Olarak Kaydet';

  @override
  String get updateBaselineBtn => 'Kişisel Normalimi Güncelle';

  @override
  String get clearBaselineBtn => 'Kaydı Sil';

  @override
  String baselineSavedMsg(String category) {
    return '$category için kişisel normal tonunuz kaydedildi.';
  }

  @override
  String baselineClearedMsg(String category) {
    return '$category kişisel normal kaydı kaldırıldı.';
  }

  @override
  String get doctorSummaryBtn => 'Doktora Göster • Özet Hazırla';

  @override
  String get returnHomeBtn => 'Ana Ekrana Dön';

  @override
  String get doctorSheetTitle => 'Doktora Göster • Randevu Özeti';

  @override
  String colorLabel(String hex, String status) {
    return 'Renk: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Önceki Kayıtlarla Zaman Çizelgesi';

  @override
  String get questionsForDoctorTitle => 'Doktorunuza Sorabileceğiniz Sorular';

  @override
  String get copyShareSummaryBtn => 'Özeti Kopyala ve Paylaş';

  @override
  String get doctorSummaryCopied =>
      'Doktor randevu özeti panoya kopyalandı. Notlara veya mesajlara yapıştırabilirsiniz.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Görsel Referanslar';
  }

  @override
  String get healthyReferenceLabel => 'Sağlıklı Referans';

  @override
  String get captureChecklistTitle => 'Doğru Çekim Kontrol Listesi';

  @override
  String get abnormalFindingsTitle =>
      'Dikkat Edilmesi Gereken / Sağlıksız Bulgular';

  @override
  String get cameraPermPermanentMsg =>
      'Kamera izni cihaz ayarlarından kapatılmış. Ayarlardan VisualCheckUp için kamera iznini açabilir veya galeriden fotoğraf seçebilirsiniz.';

  @override
  String get cameraPermRequiredMsg =>
      'Görsel ön kontrol yapabilmek için kamera izni gerekiyor. Görüntüler yalnızca cihazınızda işlenir ve sunucuya gönderilmez.';

  @override
  String get cameraGrantPermTitle => 'Kamera İzni Gerekli';

  @override
  String get cameraRequestPermBtn => 'Kamera İzni Ver';

  @override
  String get cameraPickGalleryBtn => 'Galeriden Fotoğraf Seç';

  @override
  String get cameraWhiteRefOn => 'Beyaz Referans: Açık';

  @override
  String get cameraWhiteRefOff => 'Beyaz Referans: Kapalı';

  @override
  String get cameraBaselineActive => 'Kişisel Normal Kayıtlı';

  @override
  String get cameraAnalyzing => 'Analiz ediliyor...';

  @override
  String get cameraCaptureBtn => 'Çek ve Değerlendir';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Analiz sırasında hata: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Renk Kartı';
  }

  @override
  String get quickCardPrivacyBanner =>
      'Kamera gerekmez: Gördüğünüz renge en yakın kartı seçerek 2 saniyede gizli ve hızlı kayıt oluşturun.';

  @override
  String get quickCardChooseShade => 'En Yakın Renk Tonunu Seçin';

  @override
  String get quickCardExtraContext => 'Ek Bilgi (İsteğe Bağlı)';

  @override
  String get quickCardSaveViewBtn => 'Kaydet ve Değerlendirmeyi Gör';

  @override
  String get quickCardUseCameraBtn => 'Bunun Yerine Kamera ile Çek';

  @override
  String get skinIntroTitle => 'Görsel Dermatoloji Ön Tarama';

  @override
  String get skinIntroDesc =>
      'Ben/cilt kanseri risk işaretleri, siğil, morluk ve yüz lekeleri için çevre cilt kıyaslı ön değerlendirme sunar. Kesin teşhis koymaz; dermatoloğa hazırlık amaçlıdır.';

  @override
  String get skinStep1Title => '1. Özel Cilt Ön Tarama Modülü Seçin';

  @override
  String get skinOtherConcernsLabel => 'Diğer Cilt Görünümleri';

  @override
  String get skinStep2Title => '2. Eşlik Eden Belirtiler (Opsiyonel)';

  @override
  String get skinStep3Title => '3. Vücut Bölgesi (Opsiyonel)';

  @override
  String get skinStartCameraBtn => 'Kamera ile Cilt Kontrolünü Başlat';

  @override
  String get skinConcernRash => 'Kızarıklık / Döküntü';

  @override
  String get skinConcernMole => 'Ben / Koyu Leke';

  @override
  String get skinConcernScaly => 'Pullu / Kuru Plak';

  @override
  String get skinConcernBlister => 'Kabarcık / Sivilce';

  @override
  String get skinConcernGeneral => 'Genel Cilt Kontrolü';

  @override
  String get bodyAreaFaceNeck => 'Yüz / Boyun';

  @override
  String get bodyAreaArmHand => 'Kol / El';

  @override
  String get bodyAreaTorso => 'Gövde';

  @override
  String get bodyAreaLegFoot => 'Bacak / Ayak';

  @override
  String get bodyAreaScalp => 'Saçlı Deri';

  @override
  String get bodyAreaOther => 'Diğer';

  @override
  String get symptomItching => 'Kaşıntı';

  @override
  String get symptomPainWarmth => 'Ağrı / Isı artışı';

  @override
  String get symptomRapidChange => 'Hızlı büyüme / şekil değişimi';

  @override
  String get symptomBleeding => 'Kanama / Sızıntı / İltihap';

  @override
  String get symptomSpreading => 'Hızla yayılıyor';

  @override
  String get symptomFever => 'Ateş eşlik ediyor';

  @override
  String get symptomNonHealing => '4+ haftadır iyileşmeyen yara/kabuk';

  @override
  String get symptomOver6mm => '6 mm üstü veya düzensiz kenar';

  @override
  String get symptomNoTrauma => 'Darbe olmadan kendiliğinden çıktı';

  @override
  String get symptomRoughDots => 'Pütürlü yüzey / küçük siyah noktalar';

  @override
  String get symptomSunHormone => 'Güneş, hormon veya akne sonrası leke';

  @override
  String get bruiseGuideTitle => 'Morluk Renk Evreleri Rehberi';

  @override
  String get wartGuideTitle => 'Siğil Ön Kontrol & Güvenlik Rehberi';

  @override
  String get abcdeGuideTitle => 'Benler İçin ABCDE Kontrol Rehberi';

  @override
  String get abcdeGuideSubtitle =>
      'Dermatologların ben ve cilt kanseri ön taramasında kullandığı 5 işaret';

  @override
  String get labScreenTitle => 'Tahlil & Hastane Raporları';

  @override
  String get labTabReports => 'Raporlarım';

  @override
  String get labTabTrends => 'Değişim Takibi';

  @override
  String get labAddBtn => 'Rapor / Kan Testi Ekle';

  @override
  String get labEmptyTitle => 'Henüz kayıtlı kan tahlili yok';

  @override
  String get labEmptyDesc =>
      'PDF veya JPG kan sonucunuzu yükleyin; isterseniz doktorun yazdığı teşhisi veya kendi şikayetinizi ekleyip sade Türkçe ile yorumlatın.';

  @override
  String get labAddFirstBtn => 'İlk Tahlil / PDF Raporunu Ekle';

  @override
  String get labTrendsEmptyDesc =>
      'Farklı tarihlerde kan testi kaydettiğinizde Hemoglobin, Ferritin, Glukoz, TSH, Vitamin D gibi değerlerin zaman içi değişim grafikleri burada oluşur.';

  @override
  String labParamsCount(int count) {
    return '$count parametre';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count referans dışı';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Parametre Değerlendirmesi ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Girilen Hastane / Doktor Teşhisi';

  @override
  String get labEnteredComplaintTitle => 'Şikayetiniz / Kendi Notunuz';

  @override
  String get labInterpretationTitle => 'Anlaşılır Değerlendirme & Yorum';

  @override
  String get labCopyDoctorSummaryBtn => 'Doktora Göster • Özeti Kopyala';

  @override
  String get labSummaryCopied => 'Tahlil özeti panoya kopyalandı.';

  @override
  String get labExportPdfBtn => 'Doktor PDF Raporu İndir / Paylaş';

  @override
  String get labAddSheetTitle => 'Hastane Raporu / Kan Testi Ekle';

  @override
  String get labReportTitleField => 'Rapor Başlığı';

  @override
  String get labDefaultReportTitle => 'Kan Tahlili Sonucu';

  @override
  String get labStep1Upload => '1. PDF veya JPG Kan Sonucu Yükle';

  @override
  String get labUploadPdfJpgBtn => 'PDF veya JPG Yükle';

  @override
  String get labCameraCaptureBtn => 'Kamerayla Çek';

  @override
  String get labStep2Context =>
      '2. Hastane Teşhisi & Kendi Notunuz (İsteğe Bağlı)';

  @override
  String get labStep2ContextHint =>
      'Doktorun verdiği teşhisi anlamakta zorlandıysanız ya da şikayetinizi eklemek isterseniz yazın; ikisini de boş bırakabilirsiniz.';

  @override
  String get labDiagnosisField =>
      'Hastane / Doktor Teşhisi (Boş Bırakılabilir)';

  @override
  String get labComplaintField =>
      'Şikayetiniz / Kendi Metniniz (Boş Bırakılabilir)';

  @override
  String get labStep3PasteManual =>
      '3. e-Nabız Metni Yapıştır veya Manuel Değer Ekle';

  @override
  String get labParseTextBtn => 'Metni Oku ve Ayrıştır';

  @override
  String get labParamDropdown => 'Tahlil Parametresi';

  @override
  String labValueField(String unit) {
    return 'Değer ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Ekle';

  @override
  String labParsedValuesTitle(int count) {
    return 'Okunan Değerler ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Değerlendir ve Tarihli Kaydet';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count kayıt • Değişim: $delta • Son durum: $status';
  }

  @override
  String get vitalsScreenTitle => 'Tansiyon & Şeker Takibi';

  @override
  String get vitalsCopySummaryTooltip => 'Doktora Göster Özeti Kopyala';

  @override
  String get vitalsCopyEmptyMsg =>
      'Özet oluşturmak için önce tansiyon veya şeker ekleyin.';

  @override
  String get vitalsSummaryCopied =>
      'Tansiyon & şeker takip özeti panoya kopyalandı.';

  @override
  String get vitalsAddBpBtn => 'Tansiyon Ekle';

  @override
  String get vitalsAddSugarBtn => 'Şeker Ekle';

  @override
  String get vitalsBpEmptyTitle => 'Henüz tansiyon ölçümü yok';

  @override
  String get vitalsBpEmptyDesc =>
      'Büyük/küçük tansiyon ve nabız değerlerinizi tarihli kaydederek değişim grafiğini izleyin.';

  @override
  String get vitalsBpAddFirstBtn => 'İlk Tansiyon Ölçümünü Ekle';

  @override
  String get vitalsSugarEmptyTitle => 'Henüz kan şekeri ölçümü yok';

  @override
  String get vitalsSugarEmptyDesc =>
      'Açlık, tokluk (2. saat) veya rastgele şeker ölçümlerinizi tarihli kaydederek eğilimi takip edin.';

  @override
  String get vitalsSugarAddFirstBtn => 'İlk Şeker Ölçümünü Ekle';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Ortalama ($count ölçüm): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Son nabız: $pulse bpm';
  }

  @override
  String get vitalsBpHistoryTitle => 'Tarihli Tansiyon Kayıtları';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Ortalama ($count ölçüm): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'Tarihli Şeker Kayıtları';

  @override
  String get vitalsNewBpTitle => 'Yeni Tansiyon Ölçümü';

  @override
  String get vitalsSystolicField => 'Büyük (Sistolik)';

  @override
  String get vitalsDiastolicField => 'Küçük (Diyastolik)';

  @override
  String get vitalsPulseField => 'Nabız (bpm — Opsiyonel)';

  @override
  String get vitalsNoteField => 'Not (Opsiyonel — ör. sabah dinlenmiş)';

  @override
  String get vitalsSaveBpBtn => 'Tansiyonu Kaydet';

  @override
  String get vitalsNewSugarTitle => 'Yeni Kan Şekeri Ölçümü';

  @override
  String get vitalsSugarValueField => 'Kan Şekeri (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'Kan Şekerini Kaydet';

  @override
  String get chartAddReadingHint => 'Grafik için ölçüm ekleyin';

  @override
  String get loginTermsTitle => 'Kullanım Koşulları & Tıbbi Uyarı';

  @override
  String get loginTermsCheckbox =>
      'VisualCheckUp’ın kesin tıbbi teşhis koymadığını, yalnızca ön farkındalık amaçlı olduğunu anladım ve Kullanım Koşullarını onaylıyorum.';

  @override
  String get loginTermsRequiredMsg =>
      'Giriş yapabilmek için önce Kullanım Koşulları ve Tıbbi Uyarıyı onaylamanız gerekir.';

  @override
  String get loginTermsReadMore => 'Koşulları Oku';

  @override
  String get loginTermsModalBody =>
      '• Kesin Teşhis Koymaz: VisualCheckUp tıbbi bir cihaz değildir; hastalık tanısı koymaz, tedavi önermez ve doktor muayenesinin yerini almaz.\n\n• Yalnızca Ön Farkındalık: Görsel kontroller, kan tahlili özetleri ve boy/kilo/VKİ skalaları yalnızca kişisel takip ve doktor görüşmesine hazırlık amaçlıdır.\n\n• Acil Durum Uyarısı: Şiddetli ağrı, göğüs ağrısı, nefes darlığı, ani görme kaybı veya acil belirtilerde vakit kaybetmeden 112’ye ya da en yakın sağlık kuruluşuna başvurun.\n\n• Gizlilik: Sağlık verileriniz varsayılan olarak yalnızca cihazınızda saklanır ve üçüncü taraflarla paylaşılmaz.';

  @override
  String get loginTermsAcceptBtn => 'Okudum, Onaylıyorum';

  @override
  String atlasFilterAll(int count) {
    return 'Resimli Atlas ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Acil İşaretler ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Evde Klinik Testler ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Acil Hekim Değerlendirmesi Gerektiren İşaretler';

  @override
  String get atlasTapToCompareHint =>
      'Sağlıklı referansla yan yana büyütmek için herhangi bir karta dokunun.';

  @override
  String get atlasVisualCueLabel => 'Görsel İşaret';

  @override
  String get atlasClinicalContextLabel => 'Olası Klinik Bağlam';

  @override
  String get atlasPossibleContextShort => 'Olası Bağlam';

  @override
  String get atlasWarningPrefix => 'Uyarı';

  @override
  String get atlasCloseBtn => 'Kapat';

  @override
  String get atlasCaptureProtocolTitle => 'En Doğru Çekim Protokolü';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Evde Uygulayabileceğiniz Klinik Ön Testler';

  @override
  String get atlasSelfTestNormalPrefix => 'Olağan';

  @override
  String get atlasSelfTestWarningPrefix => 'Dikkat';

  @override
  String get fitzpatrickScaleTitle =>
      'Fitzpatrick Cilt Fototipleri & ITA° Kalibrasyon Skalası';

  @override
  String get fitzpatrickScaleSubtitle =>
      'Uygulama çevre sağlıklı derinin ITA° açısını ölçerek analiz eşiklerini cilt fototipinize göre dengeler.';

  @override
  String get resultVisualCompareTitle => 'Resimli Klinik Referans Kıyaslaması';

  @override
  String get resultHealthyShort => 'Sağlıklı';

  @override
  String get resultMatchedShort => 'Eşleşen';

  @override
  String get resultViewFullAtlasBtn => 'Tüm Resimli Atlası Gör';

  @override
  String get resultHomeSelfTestsBtn => 'Evde Klinik Testler';

  @override
  String get resultClinicalBiomarkersTitle => 'Kantitatif Klinik Ölçümler';

  @override
  String get cameraEyeModeSclera => 'Mod: Sklera (Sarılık)';

  @override
  String get cameraEyeModeConjunctiva => 'Alt Göz Kapağı (Anemi)';

  @override
  String get cameraClinicalAtlasChip => 'Klinik Test & Atlas';

  @override
  String get bristolScaleTitle =>
      'Bristol Dışkı Kıvam Skalası (Opsiyonel • Tip 1–7)';

  @override
  String get bristolType1Title => 'Tip 1 • Sert topaklar';

  @override
  String get bristolType2Title => 'Tip 2 • Topaklı sucuk';

  @override
  String get bristolType3Title => 'Tip 3 • Çatlaklı sucuk';

  @override
  String get bristolType4Title => 'Tip 4 • Pürüzsüz (İdeal)';

  @override
  String get bristolType5Title => 'Tip 5 • Yumuşak parçalar';

  @override
  String get bristolType6Title => 'Tip 6 • Püremsi / Gevşek';

  @override
  String get bristolType7Title => 'Tip 7 • Tamamen sıvı';

  @override
  String get metricFitzpatrickPhototype => 'Fitzpatrick Fototip';

  @override
  String get metricAbcdeAsymmetry => 'A — Asimetri';

  @override
  String get metricAbcdeBorder => 'B — Sınır Düzensizliği';

  @override
  String get metricAbcdeColors => 'C — Dermoskopik Renk';

  @override
  String get metricErythemaDelta => 'Eritem İndeksi Δ';

  @override
  String get metricAnnularClearing => 'Halka Merkez Açılması';

  @override
  String get metricErythemaIndex => 'Eritem İndeksi (EI)';

  @override
  String get metricScleraBilirubin => 'Sklera Bilirubin İndeksi';

  @override
  String get metricHemorrhagePatch => 'Kompakt Kanama Alanı';

  @override
  String get metricNailErythema => 'Tırnak Yatağı Eritem İndeksi';

  @override
  String get metricBeauGroove => 'Beau Yatay Oluk Skoru';

  @override
  String get metricTerryLindsaySplit => 'Proksimal/Distal Ayrım';

  @override
  String get metricSplinterStreak => 'Kıymık Çizgisi Oranı';

  @override
  String get metricGeographicTongue => 'Harita Dil Skoru';

  @override
  String get metricYellowCoating => 'Sarı Pas Oranı';

  @override
  String get metricBristolScale => 'Bristol Skalası';

  @override
  String get hubStartNewScan => 'Yeni Tarama Başlat';

  @override
  String get hubPickFromGallery => 'Galeriden';

  @override
  String hubPastScansTitle(int count) {
    return 'Geçmiş Taramalar ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Toplam Tarama';

  @override
  String get hubLastScanLabel => 'Son Tarama';

  @override
  String get hubLatestStatusLabel => 'Son Durum';

  @override
  String get hubFilterAll => 'Tümü';

  @override
  String get hubFilterAttention => 'Uyarı / Takip';

  @override
  String get hubFilterWithPhoto => 'Fotoğraflı';

  @override
  String get hubColPhoto => 'Fotoğraf';

  @override
  String get hubColDate => 'Tarih';

  @override
  String get hubColFinding => 'Bulgu & Özet';

  @override
  String get hubColStatus => 'Durum';

  @override
  String get hubCompareModeBtn => '2 Taramayı Karşılaştır';

  @override
  String hubCompareSelectHint(int count) {
    return 'Yan yana karşılaştırmak için tablodan 2 tarama seçin ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Yan Yana Karşılaştır';

  @override
  String get hubCompareCancelBtn => 'Vazgeç';

  @override
  String get hubCompareSheetTitle => 'Yan Yana Tarama Karşılaştırması';

  @override
  String get hubCompareOlderLabel => 'Önceki';

  @override
  String get hubCompareNewerLabel => 'Sonraki';

  @override
  String get hubCompareMetricsTitle => 'Klinik Ölçüm Karşılaştırması';

  @override
  String hubEmptyTitle(String category) {
    return 'Henüz $category taraması yok';
  }

  @override
  String get hubEmptySubtitle =>
      'Yukarıdan ilk taramanızı başlatın. Her kontrol, küçük fotoğrafı ve detaylı analiz raporuyla burada tarih sırasıyla saklanır.';

  @override
  String get hubDoctorSummaryBtn => 'Doktor Özeti';

  @override
  String get photoTapToZoomHint => 'Tam ekran büyütmek için fotoğrafa dokunun';

  @override
  String get photoZoomTitle => 'Çekilen Fotoğraf';

  @override
  String get resultDeleteRecordTooltip => 'Kaydı Sil';

  @override
  String get resultDeleteConfirmTitle => 'Bu tarama silinsin mi?';

  @override
  String get resultDeleteConfirmBody =>
      'Bu kontrol kaydı yerel geçmişinizden kalıcı olarak silinecektir.';

  @override
  String get resultDeleteBtn => 'Sil';

  @override
  String get labLargeTextBtn => 'Büyük Yazı';

  @override
  String get labLargeTextOnBtn => 'Büyük Yazı: Açık';

  @override
  String get labSeniorOverviewTitle => 'Özetle Durumunuz';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count değeriniz normal aralıkta görünüyor.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count değeriniz referans aralığının dışında — aşağıda sade açıklaması var.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count değeriniz belirgin şekilde sınır dışı — gecikmeden doktorunuza gösterin.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return 'Temel kan panelindeki $count test bu raporda yer almıyor.';
  }

  @override
  String get labAttentionSectionTitle => 'Dikkat Etmeniz Gereken Değerler';

  @override
  String get labNormalSectionTitle =>
      'Normal Çıkan Değerler (İçiniz Rahat Olsun)';

  @override
  String get labMissingSectionTitle => 'Bu Raporda Yer Almayan Temel Testler';

  @override
  String get labMissingSectionExplain =>
      'Her tahlilde bütün testler istenmez. Aşağıdaki temel testler yüklediğiniz raporda yer almadığı için boş bırakılmıştır.';

  @override
  String get labNotInReportBadge => 'Raporda yer almıyor';

  @override
  String get labWhatItMeansLabel => 'Ne anlama gelir?';

  @override
  String get labWhatToDoLabel => 'Ne yapmalısınız?';

  @override
  String get labAddAnotherPageBtn => 'Başka Sayfa Çek';

  @override
  String labPagesReadBadge(int count) {
    return '$count sayfa okundu';
  }

  @override
  String get labPhotoOfflineHint =>
      'Rapor fotoğrafı eklendi. Kağıt fotoğraflarının otomatik okunması için Ayarlar > Bulut AI seçeneğini açabilir veya değerleri aşağıdan elle ekleyebilirsiniz.';

  @override
  String get labAllValuesNormalMsg =>
      'Bu rapordaki tüm değerleriniz referans aralığında görünüyor.';

  @override
  String get medTitle => 'İlaç & Alarm Hatırlatıcı';

  @override
  String get medSubtitle =>
      'İlaç, insülin ve kontrol alarmlarınızı fotoğrafla takip edin';

  @override
  String get medMenuTitle => 'İlaç & Alarm Hatırlatıcı';

  @override
  String get medHomeCardEmpty => 'Henüz alarm yok — ilk ilacınızı ekleyin';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return 'Bugün $taken/$total alındı';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count aktif alarm';
  }

  @override
  String get medTabToday => 'Bugün';

  @override
  String get medTabAll => 'Tüm Alarmlar';

  @override
  String get medAddAlarm => 'Yeni Alarm Ekle';

  @override
  String get medEditAlarm => 'Alarmı Düzenle';

  @override
  String get medCatPill => 'İlaç / Hap';

  @override
  String get medCatDiabetes => 'Şeker Hapı / İğnesi';

  @override
  String get medCatBloodPressure => 'Tansiyon İlacı';

  @override
  String get medCatVitamin => 'Vitamin / Takviye';

  @override
  String get medCatDropsCream => 'Göz Damlası / Krem';

  @override
  String get medCatCheckup => 'Ölçüm / Kontrol';

  @override
  String get medCatOther => 'Diğer';

  @override
  String get medMealAnytime => 'Fark etmez';

  @override
  String get medMealBefore => 'Aç karnına';

  @override
  String get medMealAfter => 'Tok karnına';

  @override
  String get medMealWith => 'Yemekle birlikte';

  @override
  String get medMealBedtime => 'Yatmadan önce';

  @override
  String get medDayMon => 'Pzt';

  @override
  String get medDayTue => 'Sal';

  @override
  String get medDayWed => 'Çar';

  @override
  String get medDayThu => 'Per';

  @override
  String get medDayFri => 'Cum';

  @override
  String get medDaySat => 'Cmt';

  @override
  String get medDaySun => 'Paz';

  @override
  String get medEveryDay => 'Her Gün';

  @override
  String get medWeekdays => 'Hafta İçi';

  @override
  String get medWeekends => 'Hafta Sonu';

  @override
  String get medFieldCategory => 'Kategori';

  @override
  String get medFieldName => 'İlaç / Hatırlatıcı Adı';

  @override
  String get medFieldNameHint => 'Örn: Glifor 1000 mg, Akşam İnsülini...';

  @override
  String get medFieldNameRequired =>
      'Lütfen ilaç veya hatırlatıcı adını yazın.';

  @override
  String get medFieldDosage => 'Doz / Miktar (İsteğe bağlı)';

  @override
  String get medFieldDosageHint => 'Örn: 1 tablet, 12 ünite, 2 damla';

  @override
  String get medFieldDescription => 'Hatırlatıcı Açıklaması (Alarmda Görünür)';

  @override
  String get medFieldDescriptionHint =>
      'Örn: Kahvaltıdan 30 dk önce bol su ile için';

  @override
  String get medFieldMealTiming => 'Kullanım Zamanı';

  @override
  String get medFieldTime => 'Alarm Saati';

  @override
  String get medFieldDays => 'Tekrar Günleri';

  @override
  String get medFieldPhoto => 'İlacın Fotoğrafı (Alarm Çalınca Gösterilir)';

  @override
  String get medTakePhoto => 'Fotoğraf Çek';

  @override
  String get medPickGallery => 'Galeriden Seç';

  @override
  String get medRemovePhoto => 'Fotoğrafı Kaldır';

  @override
  String get medPhotoHint =>
      'İlaç kutusunun veya insülin kaleminin fotoğrafını çekerseniz vakti gelince ekranda büyükçe görünür.';

  @override
  String get medSoundToggle => 'Alarm Sesi';

  @override
  String get medVibrateToggle => 'Titreşim';

  @override
  String get medSaveAlarm => 'Alarmı Kaydet';

  @override
  String get medAlarmSaved => 'Alarm kaydedildi ve zamanlandı.';

  @override
  String get medAlarmDeleted => 'Alarm silindi.';

  @override
  String get medDeleteConfirmTitle => 'Alarmı Sil';

  @override
  String medDeleteConfirmBody(String title) {
    return '\"$title\" alarmı kalıcı olarak silinsin mi?';
  }

  @override
  String get medStatusTaken => 'Alındı';

  @override
  String get medStatusSnoozed => 'Ertelendi';

  @override
  String get medStatusSkipped => 'Atlandı';

  @override
  String get medStatusPending => 'Bekliyor';

  @override
  String get medActionTaken => 'İçtim / Aldım';

  @override
  String get medActionSnooze => '10 dk Ertele';

  @override
  String get medActionSkip => 'Bugün Atla';

  @override
  String get medActionUndo => 'Geri Al';

  @override
  String get medActionPreviewAlarm => 'Alarmı Önizle';

  @override
  String get medRingHeader => 'İLAÇ ZAMANI';

  @override
  String get medRingNoteTitle => 'Hatırlatma Notu';

  @override
  String get medRingNoPhoto => 'İlaç fotoğrafı eklenmemiş';

  @override
  String get medRingTapZoom => 'Büyütmek için fotoğrafa dokunun';

  @override
  String get medRingSnoozedToast => '10 dakika ertelendi.';

  @override
  String get medRingTakenToast =>
      'Harika! Bugünkü doz alındı olarak kaydedildi.';

  @override
  String get medTodayProgressTitle => 'Bugünkü İlaç Takibi';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Sıradaki alarm: $time • $title';
  }

  @override
  String get medNoTodayAlarms => 'Bugün için planlanmış ilaç alarmı yok.';

  @override
  String get medEmptyTitle => 'Henüz İlaç Alarmı Yok';

  @override
  String get medEmptyBody =>
      'Şeker hapı, insülin, tansiyon ilacı veya günlük kontrolleriniz için fotoğraf destekli alarmlar ekleyin. Vakti gelince ilacın resmi ve açıklamanız ekranda büyükçe görünür.';

  @override
  String get medQuickPresetDiabetes => 'Şeker / İnsülin';

  @override
  String get medQuickPresetBp => 'Tansiyon İlacı';

  @override
  String get medQuickPresetVitamin => 'Vitamin';

  @override
  String get dietMenuTitle => 'Diyet & AI Kalori Takibi';

  @override
  String get dietHomeCardTitle => 'Diyet & Beslenme';

  @override
  String get dietHomeCardEmpty => 'Hazır diyetler, uyum ve kilo takibi';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return '$day/$total. gün • %$percent uyum';
  }

  @override
  String get dietCalorieQuickTitle => 'AI Tabak Kalori Hesapla';

  @override
  String get dietCalorieQuickSubtitle =>
      'Tabağın fotoğrafını çek, kalori ve makroları öğren';

  @override
  String get dietTabActive => 'Diyetim';

  @override
  String get dietTabTemplates => 'Hazır Diyetler';

  @override
  String get dietTabWeight => 'Kilo Takibi';

  @override
  String get dietTabCalories => 'AI Kalori';

  @override
  String get dietStartDiet => 'Diyete Başla';

  @override
  String get dietRestartOrChange => 'Diyeti Değiştir';

  @override
  String get dietEndDiet => 'Diyeti Bitir';

  @override
  String get dietEndDietConfirm =>
      'Aktif diyet planı sonlandırılsın mı? Uyum ve kilo geçmişiniz korunur.';

  @override
  String get dietNoActiveTitle => 'Henüz Aktif Diyet Yok';

  @override
  String get dietNoActiveBody =>
      'Hazır diyet şablonlarından (Akdeniz, Şeker Dostu, Tansiyon DASH, Dengeli Kilo Verme, 16:8 Aralıklı Oruç, Yüksek Protein) birini seçerek tarih, uyum ve kilo takibine başlayın.';

  @override
  String get dietBrowseTemplates => 'Hazır Diyetleri İncele';

  @override
  String get dietStartDate => 'Başlangıç Tarihi';

  @override
  String get dietEndDate => 'Bitiş Tarihi';

  @override
  String get dietStartWeight => 'Başlangıç Kilosu (kg)';

  @override
  String get dietTargetWeight => 'Hedef Kilo (kg)';

  @override
  String get dietDailyCalorieTarget => 'Günlük Kalori Hedefi (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days gün';
  }

  @override
  String dietDayProgress(int day, int total) {
    return '$day. Gün / $total';
  }

  @override
  String dietDaysLeft(int days) {
    return '$days gün kaldı';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Uyum: %$percent';
  }

  @override
  String get dietFollowed => 'Uydum';

  @override
  String get dietNotFollowed => 'Uymadım';

  @override
  String get dietPending => 'Bekliyor';

  @override
  String get dietSlotBreakfast => 'Kahvaltı';

  @override
  String get dietSlotMorningSnack => 'Kuşluk Ara Öğün';

  @override
  String get dietSlotLunch => 'Öğle Yemeği';

  @override
  String get dietSlotAfternoonSnack => 'İkindi Ara Öğün';

  @override
  String get dietSlotDinner => 'Akşam Yemeği';

  @override
  String get dietAlternativesLabel => 'Alternatif';

  @override
  String dietWaterTarget(String liters) {
    return 'Su hedefi: $liters L';
  }

  @override
  String get dietRulesTitle => 'Diyet Kuralları';

  @override
  String get dietSampleMenuTitle => 'Örnek Günlük Menü';

  @override
  String get dietStartedToast =>
      'Diyet planınız başlatıldı! Başarılar dileriz.';

  @override
  String get dietEndedToast => 'Aktif diyet planı sonlandırıldı.';

  @override
  String get dietWeightLogTitle => 'Diyet Kilo Takibi';

  @override
  String get dietWeightAdd => 'Kilo Ekle';

  @override
  String get dietWeightField => 'Güncel Kilo (kg)';

  @override
  String get dietWeightNote => 'Not (İsteğe bağlı)';

  @override
  String get dietWeightNoteHint => 'Örn: Sabah aç karnına tartım';

  @override
  String get dietWeightEmpty =>
      'Henüz kilo kaydı yok. Değişimi görmek için ilk tartımınızı ekleyin.';

  @override
  String get dietWeightCurrent => 'Güncel';

  @override
  String get dietWeightTarget => 'Hedef';

  @override
  String get dietWeightChange => 'Değişim';

  @override
  String get dietWeightSaved => 'Kilo kaydı eklendi.';

  @override
  String get dietCalorieTitle => 'Yapay Zeka Tabak Kalori Hesapla';

  @override
  String get dietCalorieSubtitle =>
      'Diyetten bağımsız da kullanılabilir — tabağın fotoğrafını çekin veya yemeği yazın.';

  @override
  String get dietSnapPlateCamera => 'Tabağın Fotoğrafını Çek';

  @override
  String get dietPickPlateGallery => 'Galeriden Seç';

  @override
  String get dietFoodDescLabel => 'Yemek Açıklaması / Porsiyon (İsteğe bağlı)';

  @override
  String get dietFoodDescHint =>
      'Örn: Izgara tavuk, bulgur pilavı, mevsim salata, ayran';

  @override
  String get dietCalculateFromText => 'Metinden Hesapla';

  @override
  String get dietAnalyzingPlate =>
      'Tabak kalorisi ve besin değerleri hesaplanıyor...';

  @override
  String get dietResultTitle => 'Kalori & Besin Analizi';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Görsel Analiz';

  @override
  String get dietOnDeviceBadge => 'Akıllı Cihaz İçi Tahmin';

  @override
  String get dietProtein => 'Protein';

  @override
  String get dietCarbs => 'Karbonhidrat';

  @override
  String get dietFat => 'Yağ';

  @override
  String get dietFiber => 'Lif';

  @override
  String get dietPortionScale => 'Porsiyon Boyutu';

  @override
  String get dietSaveMealLog => 'Bugünkü Kayda Ekle';

  @override
  String get dietMealLoggedToast => 'Öğün kalorisi bugünkü günlüğe eklendi.';

  @override
  String get dietTodayTotalCalories => 'Bugün Alınan';

  @override
  String get dietRecentScans => 'Hesaplanan Öğünler';

  @override
  String get dietNoScansYet =>
      'Henüz tabak taraması yok. Kalorisini öğrenmek için tabağın fotoğrafını çekin.';

  @override
  String dietHealthScore(int score) {
    return 'Denge Puanı: $score/10';
  }

  @override
  String get dietTodayLabel => 'Bugün';

  @override
  String get medCatHerbalTea => 'Bitki Çayı';

  @override
  String get medCatCustom => 'Diğer (Elle Gir)';

  @override
  String get medFieldCustomCategory => 'Özel Kategori Adı (Elle Girin)';

  @override
  String get medFieldCustomCategoryHint =>
      'Örn: Probiyotik, Su İçme, Fizik Tedavi, Kür...';

  @override
  String get medQuickPresetHerbalTea => 'Bitki Çayı';

  @override
  String get dietCreateCustom => 'Kendi Diyetimi Oluştur';

  @override
  String get dietCreateCustomSubtitle =>
      'Diyetisyeninizin listesini veya kendi öğün planınızı elle girin';

  @override
  String get dietCustomNameLabel => 'Diyet Adı';

  @override
  String get dietCustomNameHint => 'Örn: Diyetisyen Listem, Kendi Menüm...';

  @override
  String get dietCustomNameRequired => 'Lütfen diyet adını yazın.';

  @override
  String get dietCustomMealHint => 'Bu öğünde ne yiyeceksiniz?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (isteğe bağlı)';

  @override
  String get dietCustomAtLeastOneMeal => 'Lütfen en az bir öğün yazın.';

  @override
  String get dietCustomTemplatesTitle => 'Kendi Diyet Şablonlarım';

  @override
  String get dietReadyTemplatesTitle => 'Hazır Diyet Şablonları';

  @override
  String get donateTooltip => 'Destek Ol / Bağış';

  @override
  String get donateMenuLabel => 'Bağış Yap & Destek Ol';

  @override
  String get donateMenuSubtitle =>
      'Kahve, yemek veya hediye ile uygulamamıza destek olun';

  @override
  String get donatePopupTitle => 'VisualCheckUp\'a Destek Ol';

  @override
  String get donatePopupSubtitle =>
      'Gönüllü desteğiniz; göz, dil, tahlil okuma, ilaç alarmı ve diyet özelliklerini ücretsiz geliştirmeye devam etmemizi sağlar.';

  @override
  String get donateTierCoffeeTitle => 'Kahve Ismarla';

  @override
  String get donateTierCoffeeDesc => 'Geliştirme ekibine sıcak bir kahve';

  @override
  String get donateTierMealTitle => 'Yemek Ismarla';

  @override
  String get donateTierMealDesc =>
      'Yeni sağlık özellikleri için güzel bir destek';

  @override
  String get donateTierGiftTitle => 'Hediye Gönder';

  @override
  String get donateTierGiftDesc => 'Yapay zeka ve sunucu giderlerine katkı';

  @override
  String get donateTierGoldTitle => 'Büyük Destek';

  @override
  String get donateTierGoldDesc =>
      'Yeni sağlık modüllerinin geliştirilmesine destek';

  @override
  String get donateTierHeroTitle => 'Sağlık Kahramanı';

  @override
  String get donateTierHeroDesc =>
      'Tüm aileler için ücretsiz sağlık takibine büyük katkı';

  @override
  String get donatePopularBadge => 'Popüler';

  @override
  String donateConfirmButton(String price) {
    return '$price Destek Ol';
  }

  @override
  String get donateLaterButton => 'Şimdi Değil';

  @override
  String get donateThanksTitle => 'Desteğiniz İçin Teşekkürler!';

  @override
  String donateThanksBody(String tier, String price) {
    return '$tier ($price) desteğiniz bizim için çok değerli. VisualCheckUp\'ı birlikte büyüttüğünüz için teşekkür ederiz!';
  }

  @override
  String get donateSupporterBadge => 'Destekçimiz • Teşekkürler!';

  @override
  String get donateStoreNotice =>
      'Tek seferlik gönüllü destek • Abonelik değildir';

  @override
  String get medFieldAlarmSound => 'Alarm Sesi Seçimi';

  @override
  String get medAlarmSoundClassic => 'Klasik Alarm';

  @override
  String get medAlarmSoundClassicDesc => 'Net çalar saat sesi';

  @override
  String get medAlarmSoundGentle => 'Yumuşak Melodi';

  @override
  String get medAlarmSoundGentleDesc => 'Sakin ve yumuşak zil melodisi';

  @override
  String get medAlarmSoundRadar => 'Modern Alarm';

  @override
  String get medAlarmSoundRadarDesc => 'Ritimli modern alarm tonu';

  @override
  String get medAlarmSoundBell => 'Sağlık Zili';

  @override
  String get medAlarmSoundBellDesc => 'Parlak klasik çift zil sesi';

  @override
  String get medAlarmSoundUrgent => 'Güçlü Acil Alarm';

  @override
  String get medAlarmSoundUrgentDesc => 'Kritik dozlar için güçlü uyarı tonu';

  @override
  String get medAlarmSoundSystem => 'Telefon Alarm Sesi';

  @override
  String get medAlarmSoundSystemDesc =>
      'Telefonun kendi alarm melodisini kullanır';

  @override
  String get medSoundPreviewPlay => 'Dinle';

  @override
  String get medSoundPreviewStop => 'Durdur';

  @override
  String get medSoundSilent => 'Sessiz';

  @override
  String get medPreviewModeBadge => 'ÖNİZLEME';

  @override
  String get commMenuTitle => 'Sağlık Topluluğu';

  @override
  String get commHomeSubtitle =>
      'Dünya çapında sağlık arkadaşları, profil beğeni ve güvenli mesaj';

  @override
  String get commTabDiscover => 'Keşfet';

  @override
  String get commTabMessages => 'Mesajlar';

  @override
  String get commTabMyProfile => 'Profilim';

  @override
  String get commSafetyBanner =>
      'Yalnızca deneyim ve motivasyon paylaşımı içindir; tıbbi tanı/reçete değildir. Tahlilleriniz ve kamera kayıtlarınız asla paylaşılmaz.';

  @override
  String get commSearchHint => 'İsim, şehir veya sağlık notu ara...';

  @override
  String get commFilterAllGoals => 'Tüm Hedefler';

  @override
  String get commFilterAllCountries => 'Dünya Geneli';

  @override
  String get commEmptyDiscover => 'Filtrenize uyan sağlık profili bulunamadı.';

  @override
  String get commGoalDiabetes => 'Diyabet & Kan Şekeri';

  @override
  String get commGoalBloodPressure => 'Tansiyon & Kalp';

  @override
  String get commGoalWeightDiet => 'Kilo & Sağlıklı Diyet';

  @override
  String get commGoalHealthyLiving => 'Sağlıklı Yaşam';

  @override
  String get commGoalHerbalWellness => 'Bitki Çayı & Doğal Bakım';

  @override
  String get commGoalParentingGrowth => 'Ebeveyn & Çocuk Büyümesi';

  @override
  String get commGoalSkinCare => 'Cilt & Günlük Bakım';

  @override
  String get commGoalFitnessWalk => 'Yürüyüş & Hareket';

  @override
  String get commGoalSleepStress => 'Uyku & Stres Dengesi';

  @override
  String commLikesCount(int count) {
    return '$count Beğeni';
  }

  @override
  String get commLikeAction => 'Profili Beğen';

  @override
  String get commUnlikeAction => 'Beğenildi';

  @override
  String get commSendMessage => 'Mesaj Gönder';

  @override
  String get commMessagesDisabled => 'Bu üye özel mesaj almayı kapatmış.';

  @override
  String get commOptInTitle => 'Küresel Sağlık Topluluğuna Katıl';

  @override
  String get commOptInBody =>
      'Dünya çapında benzer sağlık hedeflerine sahip kişilerle tanışın. Katılım tamamen isteğe bağlıdır — tahlil raporlarınız, kamera taramalarınız ve ilaç fotoğraflarınız %100 gizli kalır.';

  @override
  String get commOptInButton => 'Sağlık Profilimi Oluştur';

  @override
  String get commFieldDisplayName => 'Görünen Ad';

  @override
  String get commFieldNickname => 'Kullanıcı Adı (@rumuz)';

  @override
  String get commFieldCountry => 'Ülke';

  @override
  String get commFieldCity => 'Şehir (isteğe bağlı)';

  @override
  String get commFieldLanguage => 'Tercih Edilen Dil';

  @override
  String get commFieldGoals => 'Sağlık & Yaşam Hedefleri';

  @override
  String get commFieldBio => 'Hakkımda & Sağlık Yolculuğum';

  @override
  String get commFieldDailyFocus => 'Günlük Sağlık Odağım';

  @override
  String get commPrivacySection => 'Gizlilik & Mesajlaşma Ayarları';

  @override
  String get commToggleDiscoverable => 'Profilim Küresel Keşfet\'te görünsün';

  @override
  String get commToggleHideRealName =>
      'Gerçek adımı gizle (sadece @rumuz görünsün)';

  @override
  String get commToggleHidePhoto => 'Profil fotoğrafımı gizle';

  @override
  String get commToggleAllowMessages => 'Özel mesaj almaya izin ver';

  @override
  String get commToggleRequireApproval =>
      'Yeni mesaj isteklerinde onayım istensin';

  @override
  String get commUploadPhoto => 'Fotoğraf Yükle';

  @override
  String get commRemovePhoto => 'Fotoğrafı Kaldır';

  @override
  String get commSaveProfile => 'Sağlık Profilini Kaydet';

  @override
  String get commProfileSaved => 'Sağlık topluluğu profiliniz güncellendi.';

  @override
  String get commLeaveCommunity => 'Topluluktan Ayrıl & Profili Kaldır';

  @override
  String get commLeftCommunity =>
      'Herkese açık topluluk profiliniz kaldırıldı.';

  @override
  String get commInboxEmpty =>
      'Henüz mesajlaşmanız yok. Keşfet\'ten sağlık arkadaşları bulup merhaba deyin!';

  @override
  String get commMessageRequestBadge => 'Mesaj İsteği';

  @override
  String get commRequestBannerTitle => 'Yeni mesaj isteği';

  @override
  String get commRequestBannerBody =>
      'Sohbete devam etmek için kabul edin veya reddedip engelleyin.';

  @override
  String get commRequestAccept => 'Kabul Et';

  @override
  String get commRequestDecline => 'Reddet';

  @override
  String get commChatPlaceholder => 'Destekleyici bir mesaj yazın...';

  @override
  String get commAttachPhoto => 'Fotoğraf ekle';

  @override
  String get commPhotoLabel => 'Fotoğraf';

  @override
  String get commRateLimited =>
      'Yeni mesaj göndermeden önce birkaç saniye bekleyin.';

  @override
  String get commBlockedNotice =>
      'Engelleme ayarları nedeniyle bu kişiye mesaj gönderilemez.';

  @override
  String get commMuteChat => 'Sessize Al';

  @override
  String get commUnmuteChat => 'Sesi Aç';

  @override
  String get commHideChat => 'Sohbeti Gizle';

  @override
  String get commBlockUser => 'Kullanıcıyı Engelle';

  @override
  String get commUnblockUser => 'Engeli Kaldır';

  @override
  String get commBlockedToast =>
      'Kullanıcı engellendi. Profili ve mesajları gizlendi.';

  @override
  String get commReportUser => 'Şikayet Et';

  @override
  String get commReportTitle => 'Üyeyi veya Mesajı Şikayet Et';

  @override
  String get commReportReasonInappropriate => 'Uygunsuz içerik';

  @override
  String get commReportReasonSpam => 'Spam veya reklam';

  @override
  String get commReportReasonHarassment => 'Taciz veya nefret söylemi';

  @override
  String get commReportReasonMisinfo => 'Güvensiz tıbbi tavsiye / yanlış bilgi';

  @override
  String get commReportReasonOther => 'Diğer';

  @override
  String get commReportNoteHint => 'Ek açıklama (isteğe bağlı)...';

  @override
  String get commReportSubmit => 'Şikayeti Gönder';

  @override
  String get commReportSent => 'Teşekkürler. Güvenlik bildiriminiz iletildi.';

  @override
  String get commDeleteForMe => 'Benden sil';

  @override
  String get commDeleteForEveryone => 'Herkesten sil';
}
