// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'یہ ایپ طبی تشخیص نہیں کرتی؛ یہ صرف معلومات اور ابتدائی بصری آگاہی کے لیے ہے۔';

  @override
  String get disclaimerTitle => 'اہم طبی اطلاع';

  @override
  String get disclaimerFull =>
      'VisualCheckUp رنگ اور ظاہری علامات کی بنیاد پر ابتدائی بصری جائزہ فراہم کرتا ہے۔ یہ طبی آلہ نہیں ہے اور ڈاکٹر کے معائنے یا لیب ٹیسٹ کا متبادل نہیں ہے۔\n\n• روشنی اور کیمرہ سینسر رنگ کی درستگی پر اثر انداز ہوتے ہیں۔\n• شدید درد، خون بہنے، تیز بخار، یرقان، سیاہ/سفید پاخانے یا سانس کی دشواری میں فوری ڈاکٹر سے رجوع کریں۔\n• پرائیویسی: تصاویر بطور ڈیفالٹ صرف آپ کے آلے پر پروسیس ہوتی ہیں۔';

  @override
  String get disclaimerAccept => 'میں سمجھ گیا/گئی';

  @override
  String get loginTagline =>
      'جلد، تل اور روزمرہ صحت کی علامات کی نگرانی اور ڈاکٹر سے ملاقات کی تیاری کا معاون۔';

  @override
  String get featureColorCalibration => 'رنگ کیلیبریشن';

  @override
  String get featurePrivacyFirst => 'پرائیویسی اول';

  @override
  String get featureOptionalAi => 'اختیاری AI';

  @override
  String get loginCardTitle => 'اپنے اکاؤنٹ سے جاری رکھیں';

  @override
  String get loginCardSubtitle =>
      'اپنے رنگ کے حوالے اور چیک اپ ہسٹری محفوظ رکھیں۔';

  @override
  String get continueWithApple => 'Apple کے ساتھ جاری رکھیں';

  @override
  String get continueWithGoogle => 'Google کے ساتھ جاری رکھیں';

  @override
  String get orDivider => 'یا';

  @override
  String get continueAsGuest => 'مہمان کے طور پر جاری رکھیں';

  @override
  String get guestGreeting => 'جلد اور بصری صحت کی نگرانی';

  @override
  String userGreeting(String name) {
    return 'خوش آمدید، $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider اکاؤنٹ';
  }

  @override
  String get localOnlyLabel => 'صرف اس آلے پر محفوظ';

  @override
  String get menuHome => 'ہوم';

  @override
  String get menuSectionVisualChecks => 'بصری چیک اپ';

  @override
  String get menuSkinGroup => 'جلد (تل، مسہ، نیل، داغ)';

  @override
  String get menuSkinGeneral => 'عام جلد اور خارش/دانے';

  @override
  String get menuSectionTracking => 'فالو اپ، لیب اور وائٹلز';

  @override
  String get menuFollowUpPlan => 'ذاتی فالو اپ پلان';

  @override
  String get menuVitalsTracker => 'بلڈ پریشر اور شوگر';

  @override
  String get menuLabReports => 'لیب اور ہسپتال رپورٹس';

  @override
  String get menuQuickColorCard => 'کیمرہ کے بغیر کلر کارڈ';

  @override
  String get menuHistory => 'چیک اپ ہسٹری';

  @override
  String get menuReferenceGuide => 'بصری حوالہ گائیڈ';

  @override
  String get menuSectionSettings => 'سیٹنگز اور پرائیویسی';

  @override
  String get menuAiSettings => 'AI اور پرائیویسی';

  @override
  String get menuDisclaimer => 'طبی اطلاع';

  @override
  String get menuTheme => 'تھیم';

  @override
  String get themeSystem => 'سسٹم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get menuLanguage => 'ایپ کی زبان';

  @override
  String get languageSystem => 'سسٹم کی زبان';

  @override
  String get signInGoogleOrApple => 'Google یا Apple سے سائن ان کریں';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get deleteAccount => 'اکاؤنٹ حذف کریں';

  @override
  String get deleteAccountTitle => 'اکاؤنٹ اور مقامی ڈیٹا حذف کریں';

  @override
  String get deleteAccountBody =>
      'آپ سائن آؤٹ ہو جائیں گے اور اس آلے پر موجود چیک اپ ہسٹری مستقل طور پر حذف ہو جائے گی۔ کیا آپ جاری رکھنا چاہتے ہیں؟';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get followUpCardTitle => 'ذاتی فالو اپ پلان';

  @override
  String get followUpSelectEdit => 'منتخب / ترمیم';

  @override
  String get followUpStart => 'شروع کریں';

  @override
  String get followUpEmptyHint =>
      'آنکھ، پیشاب، بلڈ پریشر، شوگر اور دیگر روٹین منتخب کرنے کے لیے ٹیپ کریں۔';

  @override
  String get followUpSheetSubtitle =>
      'آنکھ، زبان، ناخن، جلد، پیشاب، پاخانہ، بلڈ پریشر، شوگر اور لیب رپورٹس ایک ہی پلان میں ٹریک کریں۔';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active فعال • $completed اپ ڈیٹ • $due باقی';
  }

  @override
  String get homeCategoriesTitle => 'چیک اپ کی اقسام';

  @override
  String get homeCategoriesSubtitle =>
      'کیمرہ یا کلر کارڈ کے ذریعے بصری تبدیلیاں ٹریک کریں۔';

  @override
  String get homeLabsVitalsTitle => 'لیب، بلڈ پریشر اور شوگر';

  @override
  String get homeLabsVitalsSubtitle =>
      'خون کے ٹیسٹ کی رپورٹس پڑھیں اور بلڈ پریشر و شوگر کا رجحان دیکھیں۔';

  @override
  String get homeLabsCardTitle => 'لیب اور رپورٹس';

  @override
  String get homeLabsCardEmpty => 'بلڈ ٹیسٹ پڑھیں اور سمجھیں';

  @override
  String homeLabsCardCount(int count) {
    return '$count محفوظ رپورٹس';
  }

  @override
  String get homeVitalsCardTitle => 'بلڈ پریشر اور شوگر';

  @override
  String get homeVitalsCardEmpty => 'ریڈنگ درج کریں اور رجحان دیکھیں';

  @override
  String homeVitalsCardCount(int count) {
    return '$count محفوظ ریڈنگز';
  }

  @override
  String get homeRecentChecks => 'حالیہ چیک اپ';

  @override
  String get seeAll => 'سب دیکھیں';

  @override
  String get catEyeTitle => 'آنکھ (سفیدی)';

  @override
  String get catEyeSubtitle => 'سرخی، پیلا پن اور آنکھ کی سفیدی';

  @override
  String get catNailTitle => 'ناخن';

  @override
  String get catNailSubtitle => 'پیلا پن، نیلا پن اور ساخت کی جانچ';

  @override
  String get catTongueTitle => 'زبان';

  @override
  String get catTongueSubtitle => 'رنگ، سفید/پیلی تہہ اور ساخت';

  @override
  String get catFaceTitle => 'چہرہ اور جلد';

  @override
  String get catFaceSubtitle => 'جلد کا رنگ، پیلا پن اور سرخی';

  @override
  String get catSkinTitle => 'جلدی مسائل';

  @override
  String get catSkinSubtitle => 'تل، مسہ، نیل، چہرے کے داغ اور دانے';

  @override
  String get catUrineTitle => 'پیشاب کا رنگ';

  @override
  String get catUrineSubtitle => 'پانی کی مقدار اور رنگ کی جانچ';

  @override
  String get catStoolTitle => 'پاخانے کا رنگ';

  @override
  String get catStoolSubtitle => 'ہاضمہ اور رنگ کی تنبیہ کی جانچ';

  @override
  String get tooltipHistory => 'ہسٹری';

  @override
  String get tooltipAccountMenu => 'اکاؤنٹ اور مینو';

  @override
  String get menuSettings => 'سیٹنگز (اجازتیں اور زبان)';

  @override
  String get settingsTitle => 'سیٹنگز';

  @override
  String get settingsLanguageDesc =>
      'بطور ڈیفالٹ فون کی زبان استعمال ہوتی ہے۔ آپ نیچے سے کوئی بھی زبان منتخب کر سکتے ہیں۔';

  @override
  String get settingsPermissionsTitle => 'ایپ کی اجازتیں';

  @override
  String get settingsPermissionsDesc =>
      'یہاں کیمرہ اور گیلری کی اجازتیں چیک اور منظم کریں۔';

  @override
  String get settingsCameraPermission => 'کیمرہ کی اجازت';

  @override
  String get settingsCameraPermissionDesc =>
      'آنکھ، زبان، ناخن اور جلد کی تصاویر کے لیے';

  @override
  String get settingsPhotosPermission => 'گیلری اور تصاویر کی اجازت';

  @override
  String get settingsPhotosPermissionDesc =>
      'تصاویر اور لیب رپورٹس اپ لوڈ کرنے کے لیے';

  @override
  String get settingsOpenSystemPermissions => 'فون ایپ کی اجازتیں کھولیں';

  @override
  String get permChecking => 'جانچ ہو رہی ہے...';

  @override
  String get permGranted => 'اجازت دی گئی';

  @override
  String get permDenied => 'اجازت درکار ہے';

  @override
  String get permPermanent => 'سسٹم سیٹنگز سے آن کریں';

  @override
  String get permUnavailable => 'ڈیوائس کے زیر انتظام';

  @override
  String get permGrantBtn => 'اجازت دیں';

  @override
  String get permOpenSettingsBtn => 'سیٹنگز کھولیں';

  @override
  String get skinCancerRisk => 'تل اور جلدی کینسر کا خطرہ';

  @override
  String get skinWart => 'مسہ ابتدائی جانچ';

  @override
  String get skinBruise => 'نیل کی نگرانی';

  @override
  String get skinFacialSpot => 'چہرے کے داغ';

  @override
  String get trackEyeTitle => 'ہفتہ وار آنکھ کا چیک اپ';

  @override
  String get trackEyeSubtitle => 'آنکھ کی سرخی یا پیلا پن ٹریک کریں';

  @override
  String get trackTongueTitle => 'ہفتہ وار زبان کا معائنہ';

  @override
  String get trackTongueSubtitle => 'زبان کا رنگ، تہہ اور ساخت دیکھیں';

  @override
  String get trackNailTitle => 'ہفتہ وار ناخن کا معائنہ';

  @override
  String get trackNailSubtitle => 'پیلا پن، نیلا پن یا سفیدی چیک کریں';

  @override
  String get trackFaceTitle => 'دو ہفتہ وار چہرے کا رنگ';

  @override
  String get trackFaceSubtitle => 'چہرے کی رنگت اور سرخی کا موازنہ کریں';

  @override
  String get trackSkinTitle => 'ماہانہ جلد، تل اور مسہ چیک اپ';

  @override
  String get trackSkinSubtitle =>
      '30 دن میں تل، مسے اور داغوں میں تبدیلی دیکھیں';

  @override
  String get trackHydrationTitle => 'روزانہ ہائیڈریشن (پیشاب) چیک';

  @override
  String get trackHydrationSubtitle =>
      'کلر کارڈ سے 2 سیکنڈ میں پانی کا توازن درج کریں';

  @override
  String get trackStoolTitle => 'ہفتہ وار پاخانے کے رنگ کی جانچ';

  @override
  String get trackStoolSubtitle =>
      'ہاضمہ اور رنگ کی تنبیہ باقاعدگی سے ٹریک کریں';

  @override
  String get trackBpTitle => 'روزانہ بلڈ پریشر چیک';

  @override
  String get trackBpSubtitle => 'بلڈ پریشر اور نبض کا رجحان محفوظ کریں';

  @override
  String get trackSugarTitle => 'روزانہ بلڈ شوگر چیک';

  @override
  String get trackSugarSubtitle => 'نہار منہ یا کھانے کے بعد شوگر ریکارڈ کریں';

  @override
  String get trackLabTitle => 'سہ ماہی بلڈ ٹیسٹ اور رپورٹ';

  @override
  String get trackLabSubtitle => 'ہسپتال کی رپورٹس اپ لوڈ کریں اور موازنہ کریں';

  @override
  String get statusFirstPending => 'پہلے ریکارڈ کا انتظار';

  @override
  String get statusDueNow => 'چیک اپ کا وقت آ گیا ہے';

  @override
  String get statusDoneToday => 'آج مکمل ہو گیا';

  @override
  String statusNextDays(int days) {
    return 'اگلا چیک اپ: $days دن بعد';
  }

  @override
  String get actionCheckNow => 'ابھی چیک کریں';

  @override
  String get actionLogReading => 'ریڈنگ درج کریں';

  @override
  String get actionAddReport => 'رپورٹ شامل کریں';

  @override
  String checkMethodTitle(String category) {
    return '$category • چیک اپ کا طریقہ';
  }

  @override
  String get checkMethodSubtitle =>
      'تصویر لیے بغیر 2 سیکنڈ میں کلر کارڈ منتخب کریں یا کیمرہ استعمال کریں۔';

  @override
  String get colorCardRecommendedTitle => 'کیمرہ کے بغیر کلر کارڈ (تجویز کردہ)';

  @override
  String get colorCardRecommendedSubtitle =>
      'تصویر کے بغیر نجی اور تیز ریکارڈ (2 سیکنڈ)';

  @override
  String get cameraMeasureTitle => 'کیمرہ سے رنگ کی پیمائش';

  @override
  String get cameraMeasureSubtitle =>
      'وائٹ بیلنس کیلیبریشن کے ساتھ خودکار پیمائش';

  @override
  String get referenceGuideSubtitle =>
      'صحت مند اور غیر معمولی علامات دیکھنے کے لیے ماڈیول منتخب کریں۔';

  @override
  String get historyEmpty => 'ابھی تک کوئی چیک اپ محفوظ نہیں ہوا۔';

  @override
  String get filterAll => 'سب';

  @override
  String get aiSettingsTitle => 'AI اور پرائیویسی';

  @override
  String get vitalsBpTab => 'بلڈ پریشر';

  @override
  String get vitalsSugarTab => 'بلڈ شوگر';

  @override
  String get skinScreenTitle => 'جلدی مسائل کی ابتدائی جانچ';

  @override
  String get providerGuest => 'مہمان';

  @override
  String signInFailed(String error) {
    return 'سائن ان ناکام رہا: $error';
  }

  @override
  String get riskNormal => 'معمول کی ظاہری شکل';

  @override
  String get riskAttention => 'فالو اپ تجویز کیا جاتا ہے';

  @override
  String get riskUrgent => 'ڈاکٹر سے معائنہ تجویز کیا جاتا ہے';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'تازہ ترین: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'تازہ ترین: $count اقدار ($abnormal حد سے باہر)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'تازہ ترین: $count اقدار (سب معمول پر)';
  }

  @override
  String get labStatusCriticalLow => 'تشویشناک حد تک کم';

  @override
  String get labStatusLow => 'کم';

  @override
  String get labStatusNormal => 'نارمل';

  @override
  String get labStatusHigh => 'زیادہ';

  @override
  String get labStatusCriticalHigh => 'تشویشناک حد تک زیادہ';

  @override
  String get labSourceManual => 'دستی اندراج';

  @override
  String get labSourcePasted => 'رپورٹ کے متن سے پڑھا گیا';

  @override
  String get labSourcePhoto => 'JPG / تصویری رپورٹ';

  @override
  String get labSourcePdf => 'PDF رپورٹ';

  @override
  String get bpLow => 'کم بلڈ پریشر';

  @override
  String get bpNormal => 'نارمل حد';

  @override
  String get bpElevated => 'ہلکا زیادہ';

  @override
  String get bpStage1 => 'اسٹیج 1 ہائی';

  @override
  String get bpStage2 => 'واضح طور پر زیادہ';

  @override
  String get bpCrisis => 'ہنگامی ہائی بلڈ پریشر';

  @override
  String get sugarLow => 'کم بلڈ شوگر';

  @override
  String get sugarNormal => 'نارمل حد';

  @override
  String get sugarBorderline => 'سرحد پر زیادہ';

  @override
  String get sugarHigh => 'ہائی بلڈ شوگر';

  @override
  String get sugarVeryHigh => 'بہت زیادہ بلڈ شوگر';

  @override
  String get sugarTypeFasting => 'خالی پیٹ';

  @override
  String get sugarTypePostMeal => 'کھانے کے 2 گھنٹے بعد';

  @override
  String get sugarTypeRandom => 'بے ترتیب';

  @override
  String get specialtyEye => 'امراض چشم یا انٹرنل میڈیسن';

  @override
  String get specialtyNail => 'جلدی امراض یا انٹرنل میڈیسن';

  @override
  String get specialtyTongue => 'ای این ٹی، منہ کی صحت یا میڈیسن';

  @override
  String get specialtySkin => 'ڈرمٹولوجی (جلدی امراض)';

  @override
  String get specialtyUrine => 'یورولوجی یا انٹرنل میڈیسن';

  @override
  String get specialtyStool => 'معدہ و جگر یا انٹرنل میڈیسن';

  @override
  String get cloudBackupTitle => 'کلاؤڈ بیک اپ (اختیاری • Firebase)';

  @override
  String get cloudBackupDesc =>
      'ڈیفالٹ طور پر آپ کے تمام ٹیسٹ اور ریڈنگز صرف اس ڈیوائس پر محفوظ رہتی ہیں۔ فون بدلتے وقت ڈیٹا محفوظ رکھنے کے لیے اپنے Google/Apple اکاؤنٹ پر بیک اپ آن کر سکتے ہیں۔';

  @override
  String get cloudBackupToggleTitle => 'کلاؤڈ بیک اپ فعال کریں';

  @override
  String cloudBackupLastSync(String date) {
    return 'آخری بیک اپ: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'فعال • بیک اپ کے لیے تیار';

  @override
  String get cloudBackupDisabledLocal => 'بند • صرف ڈیوائس اسٹوریج';

  @override
  String get cloudBackupSignInRequired =>
      'کلاؤڈ بیک اپ کے لیے Google یا Apple سے سائن ان کریں۔';

  @override
  String get cloudBackupNowBtn => 'ابھی بیک اپ لیں';

  @override
  String get cloudRestoreBtn => 'کلاؤڈ سے بحال کریں';

  @override
  String get cloudConsentTitle => 'کلاؤڈ بیک اپ کی اجازت';

  @override
  String get cloudConsentBody =>
      'آپ کے ٹیسٹ، پیمائشیں اور ریکارڈ ڈیفالٹ طور پر صرف اس ڈیوائس پر محفوظ رہتے ہیں۔\n\nکلاؤڈ بیک اپ آن کرنے پر یہ ڈیٹا آپ کے ذاتی Google/Apple اکاؤنٹ میں محفوظ ہوگا اور اکاؤنٹ حذف کرنے پر مکمل طور پر مٹ جائے گا۔\n\nکیا آپ متفق ہیں؟';

  @override
  String get cloudConsentConfirm => 'جی ہاں، فعال کریں';

  @override
  String cloudBackupSuccess(int count) {
    return 'کلاؤڈ بیک اپ مکمل: $count ریکارڈ محفوظ ہوئے۔';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'بیک اپ ناکام: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'کلاؤڈ سے بحال ہو گیا: $count ریکارڈ منتقل ہوئے۔';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'بحالی ناکام: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'کلاؤڈ بیک اپ بند کر دیا گیا۔ نئے ریکارڈ صرف اس ڈیوائس پر رہیں گے۔';

  @override
  String get aiCloudToggleTitle => 'کلاؤڈ ویژن AI (Gemini) تجزیہ';

  @override
  String get aiCloudOnDesc =>
      'آن: واضح تصاویر کو چھوٹا کر کے محفوظ کنکشن سے تجزیہ کیا جاتا ہے۔ آف لائن پر ڈیوائس تجزیہ چلتا ہے۔';

  @override
  String get aiCloudOffDesc =>
      'بند (0 ٹوکن): تمام تجزیہ صرف آپ کی ڈیوائس پر ہوتا ہے؛ کوئی تصویر باہر نہیں بھیجی جاتی۔';

  @override
  String get aiBackendOfflineNote =>
      'جب Gemini / Firebase AI کنکشن فعال ہوگا تو اس انتخاب کے مطابق کلاؤڈ تجزیہ چلے گا؛ فی الحال ڈیوائس انجن فعال ہے۔';

  @override
  String get aiOptimizationsTitle => 'فعال ٹوکن اور ڈیٹا بچت کنٹرولز';

  @override
  String get aiOptQualityGate =>
      '0-ٹوکن دھندلاپن، اندھیرے اور چمک کی کوالٹی جانچ';

  @override
  String get aiOptCompression => 'خودکار کراپ + 512px/768px JPEG (%80) کمپریشن';

  @override
  String get aiOptTieredModel => 'اسمارٹ ماڈل انتخاب (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'ایک جیسی تصاویر کے لیے مقامی کیش (0 ٹوکن)';

  @override
  String get aiClearCacheBtn => 'AI کیش صاف کریں';

  @override
  String get aiCacheCleared => 'AI کیش صاف کر دی گئی۔';

  @override
  String resultScreenTitle(String category) {
    return '$category کا نتیجہ';
  }

  @override
  String get tooltipDoctorSummary => 'ڈاکٹر کے لیے خلاصہ';

  @override
  String get tooltipReferenceGuide => 'حوالہ گائیڈ';

  @override
  String get calibratedColorTone => 'کیلیبریٹڈ رنگ ٹون';

  @override
  String get sampledColorTone => 'نمایاں رنگ ٹون';

  @override
  String confidenceLabel(int percent) {
    return 'ابتدائی اعتماد: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote =>
      'سفید حوالہ کے ساتھ رنگ متوازن کیا گیا۔';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'تجویز کردہ شعبہ: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'وقت کے ساتھ تبدیلی کا موازنہ';

  @override
  String get todayLabel => 'آج';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'پچھلا ریکارڈ: \"$title\" ($status)۔ کل $count ریکارڈ زیر نگرانی ہیں۔';
  }

  @override
  String get personalBaselineComparisonTitle => 'ذاتی نارمل سے موازنہ';

  @override
  String get yourBaselineLabel => 'آپ کا نارمل';

  @override
  String get warningFlagsTitle => 'توجہ طلب علامات';

  @override
  String get observationsTitle => 'مشاہدات';

  @override
  String get recommendationsTitle => 'تجاویز';

  @override
  String get personalBaselineCardTitle => 'ذاتی نارمل کیلیبریشن';

  @override
  String get personalBaselineCardDesc =>
      'صحت مند دن کی یہ پیمائش اپنے ذاتی نارمل کے طور پر محفوظ کریں۔';

  @override
  String get saveBaselineBtn => 'ذاتی نارمل محفوظ کریں';

  @override
  String get updateBaselineBtn => 'ذاتی نارمل اپ ڈیٹ کریں';

  @override
  String get clearBaselineBtn => 'حذف کریں';

  @override
  String baselineSavedMsg(String category) {
    return '$category کے لیے ذاتی نارمل محفوظ ہو گیا۔';
  }

  @override
  String baselineClearedMsg(String category) {
    return '$category کا ذاتی نارمل ہٹا دیا گیا۔';
  }

  @override
  String get doctorSummaryBtn => 'ڈاکٹر کو دکھائیں • خلاصہ بنائیں';

  @override
  String get returnHomeBtn => 'ہوم پر واپس جائیں';

  @override
  String get doctorSheetTitle => 'ڈاکٹر ملاقات کا خلاصہ';

  @override
  String colorLabel(String hex, String status) {
    return 'رنگ: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'پچھلے ریکارڈ کی ٹائم لائن';

  @override
  String get questionsForDoctorTitle => 'ڈاکٹر سے پوچھنے کے سوالات';

  @override
  String get copyShareSummaryBtn => 'خلاصہ کاپی اور شیئر کریں';

  @override
  String get doctorSummaryCopied => 'ڈاکٹر کا خلاصہ کلپ بورڈ پر کاپی ہو گیا۔';

  @override
  String referenceSheetTitle(String category) {
    return '$category — بصری حوالہ جات';
  }

  @override
  String get healthyReferenceLabel => 'صحت مند حوالہ';

  @override
  String get captureChecklistTitle => 'درست تصویر لینے کے نکات';

  @override
  String get abnormalFindingsTitle => 'توجہ طلب / غیر معمولی علامات';

  @override
  String get cameraPermPermanentMsg =>
      'کیمرہ کی اجازت سیٹنگز میں بند ہے۔ اسے فعال کریں یا گیلری سے تصویر منتخب کریں۔';

  @override
  String get cameraPermRequiredMsg =>
      'بصری جانچ کے لیے کیمرہ کی اجازت درکار ہے۔ تصاویر صرف آپ کی ڈیوائس پر پروسیس ہوتی ہیں۔';

  @override
  String get cameraGrantPermTitle => 'کیمرہ تک رسائی درکار ہے';

  @override
  String get cameraRequestPermBtn => 'کیمرہ کی اجازت دیں';

  @override
  String get cameraPickGalleryBtn => 'گیلری سے منتخب کریں';

  @override
  String get cameraWhiteRefOn => 'سفید حوالہ: آن';

  @override
  String get cameraWhiteRefOff => 'سفید حوالہ: بند';

  @override
  String get cameraBaselineActive => 'ذاتی نارمل محفوظ';

  @override
  String get cameraAnalyzing => 'تجزیہ جاری ہے...';

  @override
  String get cameraCaptureBtn => 'تصویر لیں اور جانچیں';

  @override
  String cameraAnalysisFailed(String error) {
    return 'تجزیہ ناکام رہا: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • رنگ کارڈ';
  }

  @override
  String get quickCardPrivacyBanner =>
      'کیمرہ کی ضرورت نہیں: 2 سیکنڈ میں نجی ریکارڈ کے لیے قریب ترین رنگ منتخب کریں۔';

  @override
  String get quickCardChooseShade => 'قریب ترین رنگ منتخب کریں';

  @override
  String get quickCardExtraContext => 'اضافی معلومات (اختیاری)';

  @override
  String get quickCardSaveViewBtn => 'محفوظ کریں اور جائزہ دیکھیں';

  @override
  String get quickCardUseCameraBtn => 'اس کے بجائے کیمرہ استعمال کریں';

  @override
  String get skinIntroTitle => 'بصری جلدی ابتدائی جانچ';

  @override
  String get skinIntroDesc =>
      'تل، مسے، نیل اور چہرے کے داغوں کا اردگرد کی جلد سے موازنہ کرتا ہے۔ یہ تشخیص نہیں بلکہ ڈاکٹر سے ملاقات کی تیاری کے لیے ہے۔';

  @override
  String get skinStep1Title => '1. جلدی جانچ کا ماڈیول منتخب کریں';

  @override
  String get skinOtherConcernsLabel => 'دیگر جلدی علامات';

  @override
  String get skinStep2Title => '2. همراه علامات (اختیاری)';

  @override
  String get skinStep3Title => '3. جسم کا حصہ (اختیاری)';

  @override
  String get skinStartCameraBtn => 'کیمرہ سے جلد کی جانچ شروع کریں';

  @override
  String get skinConcernRash => 'سرخی / دانے';

  @override
  String get skinConcernMole => 'تل / گہرا دھبہ';

  @override
  String get skinConcernScaly => 'خشک / پپڑی دار دھبہ';

  @override
  String get skinConcernBlister => 'چھالا / مہاسے';

  @override
  String get skinConcernGeneral => 'عمومی جلد کی جانچ';

  @override
  String get bodyAreaFaceNeck => 'چہرہ / گردن';

  @override
  String get bodyAreaArmHand => 'بازو / ہاتھ';

  @override
  String get bodyAreaTorso => 'دھڑ';

  @override
  String get bodyAreaLegFoot => 'ٹانگ / پاؤں';

  @override
  String get bodyAreaScalp => 'سر کی جلد';

  @override
  String get bodyAreaOther => 'دیگر';

  @override
  String get symptomItching => 'خارش';

  @override
  String get symptomPainWarmth => 'درد / حرارت';

  @override
  String get symptomRapidChange => 'تیزی سے بڑھنا / شکل بدلنا';

  @override
  String get symptomBleeding => 'خون بہنا / رساؤ';

  @override
  String get symptomSpreading => 'تیزی سے پھیل رہا ہے';

  @override
  String get symptomFever => 'بخار ساتھ ہے';

  @override
  String get symptomNonHealing => '4+ ہفتوں سے نہ بھرنے والا زخم';

  @override
  String get symptomOver6mm => '6 ملی میٹر سے بڑا یا ناہموار کنارہ';

  @override
  String get symptomNoTrauma => 'چوٹ کے بغیر خود بخود نکلا';

  @override
  String get symptomRoughDots => 'کھردری سطح / چھوٹے کالے نقطے';

  @override
  String get symptomSunHormone => 'دھوپ، ہارمون یا مہاسوں کا داغ';

  @override
  String get bruiseGuideTitle => 'نیل کے رنگ کے مراحل';

  @override
  String get wartGuideTitle => 'مسے کی حفاظتی گائیڈ';

  @override
  String get abcdeGuideTitle => 'تلوں کے لیے ABCDE گائیڈ';

  @override
  String get abcdeGuideSubtitle => 'ماہرین جلد کے استعمال کردہ 5 اہم اشارے';

  @override
  String get labScreenTitle => 'لیب اور ہسپتال رپورٹس';

  @override
  String get labTabReports => 'میری رپورٹس';

  @override
  String get labTabTrends => 'تبدیلی کی نگرانی';

  @override
  String get labAddBtn => 'رپورٹ / بلڈ ٹیسٹ شامل کریں';

  @override
  String get labEmptyTitle => 'ابھی تک کوئی بلڈ ٹیسٹ محفوظ نہیں';

  @override
  String get labEmptyDesc =>
      'PDF یا JPG بلڈ رپورٹ اپ لوڈ کریں؛ آسان وضاحت کے لیے اختیاری طور پر تشخیص یا اپنی شکایت شامل کریں۔';

  @override
  String get labAddFirstBtn => 'پہلی رپورٹ شامل کریں';

  @override
  String get labTrendsEmptyDesc =>
      'مختلف تاریخوں پر بلڈ ٹیسٹ محفوظ کرنے سے ہیموگلوبن، فیریٹن، گلوکوز، TSH کے گراف یہاں بنیں گے۔';

  @override
  String labParamsCount(int count) {
    return '$count پیرامیٹرز';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count حد سے باہر';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'پیرامیٹرز کا جائزہ ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'ہسپتال / ڈاکٹر کی تشخیص';

  @override
  String get labEnteredComplaintTitle => 'آپ کی شکایت / نوٹ';

  @override
  String get labInterpretationTitle => 'آسان فہم وضاحت';

  @override
  String get labCopyDoctorSummaryBtn => 'ڈاکٹر کو دکھائیں • کاپی کریں';

  @override
  String get labSummaryCopied => 'ٹیسٹ کا خلاصہ کاپی ہو گیا۔';

  @override
  String get labExportPdfBtn => 'ڈاکٹر کے لیے PDF بنائیں';

  @override
  String get labAddSheetTitle => 'ہسپتال / بلڈ ٹیسٹ رپورٹ شامل کریں';

  @override
  String get labReportTitleField => 'رپورٹ کا عنوان';

  @override
  String get labDefaultReportTitle => 'بلڈ ٹیسٹ کا نتیجہ';

  @override
  String get labStep1Upload => '1. PDF یا JPG رپورٹ اپ لوڈ کریں';

  @override
  String get labUploadPdfJpgBtn => 'PDF یا JPG اپ لوڈ';

  @override
  String get labCameraCaptureBtn => 'تصویر کھینچیں';

  @override
  String get labStep2Context => '2. تشخیص اور نوٹ (اختیاری)';

  @override
  String get labStep2ContextHint =>
      'ڈاکٹر کی تشخیص یا اپنی شکایت لکھیں؛ آپ دونوں خانے خالی بھی چھوڑ سکتے ہیں۔';

  @override
  String get labDiagnosisField => 'ہسپتال / ڈاکٹر کی تشخیص (اختیاری)';

  @override
  String get labComplaintField => 'آپ کی شکایت / سوال (اختیاری)';

  @override
  String get labStep3PasteManual =>
      '3. رپورٹ متن پیسٹ کریں یا دستی اندراج کریں';

  @override
  String get labParseTextBtn => 'متن پڑھیں اور الگ کریں';

  @override
  String get labParamDropdown => 'ٹیسٹ پیرامیٹر';

  @override
  String labValueField(String unit) {
    return 'قدر ($unit)';
  }

  @override
  String get labAddValueBtn => '+ شامل';

  @override
  String labParsedValuesTitle(int count) {
    return 'پڑھی گئی اقدار ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'جائزہ لیں اور محفوظ کریں';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count ریکارڈ • تبدیلی: $delta • تازہ: $status';
  }

  @override
  String get vitalsScreenTitle => 'بلڈ پریشر اور شوگر ٹریکنگ';

  @override
  String get vitalsCopySummaryTooltip => 'ڈاکٹر کا خلاصہ کاپی کریں';

  @override
  String get vitalsCopyEmptyMsg =>
      'خلاصہ بنانے کے لیے پہلے بلڈ پریشر یا شوگر شامل کریں۔';

  @override
  String get vitalsSummaryCopied => 'بلڈ پریشر اور شوگر کا خلاصہ کاپی ہو گیا۔';

  @override
  String get vitalsAddBpBtn => 'بلڈ پریشر شامل کریں';

  @override
  String get vitalsAddSugarBtn => 'شوگر شامل کریں';

  @override
  String get vitalsBpEmptyTitle => 'ابھی تک کوئی بلڈ پریشر ریکارڈ نہیں';

  @override
  String get vitalsBpEmptyDesc =>
      'گراف دیکھنے کے لیے تاریخ کے ساتھ بلڈ پریشر اور نبض محفوظ کریں۔';

  @override
  String get vitalsBpAddFirstBtn => 'پہلا بلڈ پریشر شامل کریں';

  @override
  String get vitalsSugarEmptyTitle => 'ابھی تک کوئی بلڈ شوگر ریکارڈ نہیں';

  @override
  String get vitalsSugarEmptyDesc =>
      'رجحان دیکھنے کے لیے خالی پیٹ، کھانے کے بعد یا بے ترتیب شوگر محفوظ کریں۔';

  @override
  String get vitalsSugarAddFirstBtn => 'پہلی شوگر شامل کریں';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'اوسط ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • نبض $pulse';
  }

  @override
  String get vitalsBpHistoryTitle => 'بلڈ پریشر کا ریکارڈ';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'اوسط ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'شوگر کا ریکارڈ';

  @override
  String get vitalsNewBpTitle => 'نیا بلڈ پریشر اندراج';

  @override
  String get vitalsSystolicField => 'اوپر والا (سسٹولک)';

  @override
  String get vitalsDiastolicField => 'نیچے والا (ڈائیسٹولک)';

  @override
  String get vitalsPulseField => 'نبض (اختیاری)';

  @override
  String get vitalsNoteField => 'نوٹ (اختیاری)';

  @override
  String get vitalsSaveBpBtn => 'بلڈ پریشر محفوظ کریں';

  @override
  String get vitalsNewSugarTitle => 'نئی بلڈ شوگر';

  @override
  String get vitalsSugarValueField => 'بلڈ شوگر (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'شوگر محفوظ کریں';

  @override
  String get chartAddReadingHint => 'گراف دیکھنے کے لیے پیمائش شامل کریں';

  @override
  String get loginTermsTitle => 'استعمال کی شرائط اور طبی انتباہ';

  @override
  String get loginTermsCheckbox =>
      'میں سمجھتا/سمجھتی ہوں کہ VisualCheckUp حتمی طبی تشخیص فراہم نہیں کرتا، یہ صرف ابتدائی آگاہی کے لیے ہے، اور میں شرائطِ استعمال سے متفق ہوں۔';

  @override
  String get loginTermsRequiredMsg =>
      'سائن ان کرنے سے پہلے براہِ کرم استعمال کی شرائط اور طبی انتباہ کو منظور کریں۔';

  @override
  String get loginTermsReadMore => 'شرائط پڑھیں';

  @override
  String get loginTermsModalBody =>
      '• طبی تشخیص نہیں: VisualCheckUp کوئی طبی آلہ نہیں ہے اور ڈاکٹر کے معائنے یا علاج کا متبادل نہیں ہے۔\n\n• صرف ابتدائی آگاہی: بصری جانچ، لیب رپورٹس کا خلاصہ اور BMI/نمو کے پیمانے صرف ذاتی نگرانی اور ڈاکٹر سے مشورے کی تیاری کے لیے ہیں۔\n\n• ہنگامی انتباہ: سینے میں درد، سانس کی تکلیف یا شدید علامات کی صورت میں فوراً ہنگامی طبی مدد حاصل کریں۔\n\n• رازداری: آپ کا صحت کا ڈیٹا پہلے سے طے شدہ طور پر صرف آپ کے آلے میں محفوظ رہتا ہے۔';

  @override
  String get loginTermsAcceptBtn => 'میں نے پڑھ لیا اور متفق ہوں';

  @override
  String atlasFilterAll(int count) {
    return 'تصویری اٹلس ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'فوری علامات ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'گھریلو کلینیکل ٹیسٹ ($count)';
  }

  @override
  String get atlasUrgentSectionTitle => 'فوری طبی معائنے کی متقاضی علامات';

  @override
  String get atlasTapToCompareHint =>
      'صحت مند حوالہ کے ساتھ بڑا کر کے موازنہ کرنے کے لیے کسی بھی کارڈ پر ٹیپ کریں۔';

  @override
  String get atlasVisualCueLabel => 'بصری اشارہ';

  @override
  String get atlasClinicalContextLabel => 'ممکنہ کلینیکل پس منظر';

  @override
  String get atlasPossibleContextShort => 'ممکنہ پس منظر';

  @override
  String get atlasWarningPrefix => 'انتباہ';

  @override
  String get atlasCloseBtn => 'بند کریں';

  @override
  String get atlasCaptureProtocolTitle => 'تصویر لینے کا بہترین طریقہ';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'گھر پر کیے جانے والے ابتدائی کلینیکل ٹیسٹ';

  @override
  String get atlasSelfTestNormalPrefix => 'معمول کے مطابق';

  @override
  String get atlasSelfTestWarningPrefix => 'توجہ طلب';

  @override
  String get fitzpatrickScaleTitle => 'فٹز پیٹرک جلد کی اقسام اور ITA° پیمانہ';

  @override
  String get fitzpatrickScaleSubtitle =>
      'ایپ آس پاس کی صحت مند جلد کا ITA° زاویہ ناپ کر آپ کی جلد کی رنگت کے مطابق تجزیے کی حد متوازن کرتی ہے۔';

  @override
  String get resultVisualCompareTitle => 'تصویری کلینیکل حوالہ کا موازنہ';

  @override
  String get resultHealthyShort => 'صحت مند';

  @override
  String get resultMatchedShort => 'مماثل';

  @override
  String get resultViewFullAtlasBtn => 'مکمل تصویری اٹلس دیکھیں';

  @override
  String get resultHomeSelfTestsBtn => 'گھریلو کلینیکل ٹیسٹ';

  @override
  String get resultClinicalBiomarkersTitle => 'مقداری کلینیکل پیمائشیں';

  @override
  String get cameraEyeModeSclera => 'موڈ: آنکھ کی سفیدی (یرقان)';

  @override
  String get cameraEyeModeConjunctiva => 'نچلی پلک (خون کی کمی)';

  @override
  String get cameraClinicalAtlasChip => 'کلینیکل ٹیسٹ اور اٹلس';

  @override
  String get bristolScaleTitle => 'برسٹل پاخانہ پیمانہ (اختیاری • اقسام 1–7)';

  @override
  String get bristolType1Title => 'قسم 1 • سخت گانٹھیں';

  @override
  String get bristolType2Title => 'قسم 2 • گانٹھ دار لمبا';

  @override
  String get bristolType3Title => 'قسم 3 • دراڑوں والا';

  @override
  String get bristolType4Title => 'قسم 4 • ہموار (مثالی)';

  @override
  String get bristolType5Title => 'قسم 5 • نرم ٹکڑے';

  @override
  String get bristolType6Title => 'قسم 6 • نرم / ڈھیلا';

  @override
  String get bristolType7Title => 'قسم 7 • مکمل مائع';

  @override
  String get metricFitzpatrickPhototype => 'فٹز پیٹرک فوٹو ٹائپ';

  @override
  String get metricAbcdeAsymmetry => 'A — عدم توازن';

  @override
  String get metricAbcdeBorder => 'B — کناروں کی بے قاعدگی';

  @override
  String get metricAbcdeColors => 'C — ڈرموسکوپک رنگ';

  @override
  String get metricErythemaDelta => 'ایریتھیما انڈیکس Δ';

  @override
  String get metricAnnularClearing => 'حلقہ نما مرکزی صفائی';

  @override
  String get metricErythemaIndex => 'ایریتھیما انڈیکس (EI)';

  @override
  String get metricScleraBilirubin => 'اسکلیرا بلیروبن انڈیکس';

  @override
  String get metricHemorrhagePatch => 'مرتکز خون بہنے کا حصہ';

  @override
  String get metricNailErythema => 'ناخن بستر ایریتھیما انڈیکس';

  @override
  String get metricBeauGroove => 'بو افقی لکیر اسکور';

  @override
  String get metricTerryLindsaySplit => 'پراکسیمل/ڈسٹل فرق';

  @override
  String get metricSplinterStreak => 'اسپلنٹر لکیروں کا تناسب';

  @override
  String get metricGeographicTongue => 'جغرافیائی زبان اسکور';

  @override
  String get metricYellowCoating => 'زرد تہہ کا تناسب';

  @override
  String get metricBristolScale => 'برسٹل پیمانہ';

  @override
  String get hubStartNewScan => 'نیا اسکین شروع کریں';

  @override
  String get hubPickFromGallery => 'گیلری';

  @override
  String hubPastScansTitle(int count) {
    return 'گزشتہ اسکینز ($count)';
  }

  @override
  String get hubTotalScansLabel => 'کل اسکینز';

  @override
  String get hubLastScanLabel => 'آخری اسکین';

  @override
  String get hubLatestStatusLabel => 'تازہ ترین حالت';

  @override
  String get hubFilterAll => 'سب';

  @override
  String get hubFilterAttention => 'توجہ / فوری';

  @override
  String get hubFilterWithPhoto => 'تصویر کے ساتھ';

  @override
  String get hubColPhoto => 'تصویر';

  @override
  String get hubColDate => 'تاریخ';

  @override
  String get hubColFinding => 'نتیجہ اور خلاصہ';

  @override
  String get hubColStatus => 'حالت';

  @override
  String get hubCompareModeBtn => '2 اسکین کا موازنہ کریں';

  @override
  String hubCompareSelectHint(int count) {
    return 'آمنے سامنے موازنہ کے لیے جدول سے 2 اسکین منتخب کریں ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'آمنے سامنے موازنہ';

  @override
  String get hubCompareCancelBtn => 'منسوخ کریں';

  @override
  String get hubCompareSheetTitle => 'اسکینز کا آمنے سامنے موازنہ';

  @override
  String get hubCompareOlderLabel => 'پہلا';

  @override
  String get hubCompareNewerLabel => 'بعد کا';

  @override
  String get hubCompareMetricsTitle => 'کلینیکل پیمائشوں کا موازنہ';

  @override
  String hubEmptyTitle(String category) {
    return 'ابھی تک کوئی $category اسکین نہیں';
  }

  @override
  String get hubEmptySubtitle =>
      'اوپر سے اپنا پہلا اسکین شروع کریں۔ ہر معائنہ چھوٹی تصویر اور مکمل رپورٹ کے ساتھ یہاں تاریخ وار محفوظ ہوتا ہے۔';

  @override
  String get hubDoctorSummaryBtn => 'ڈاکٹر خلاصہ';

  @override
  String get photoTapToZoomHint => 'فل اسکرین زوم کے لیے تصویر پر ٹیپ کریں';

  @override
  String get photoZoomTitle => 'لی گئی تصویر';

  @override
  String get resultDeleteRecordTooltip => 'ریکارڈ حذف کریں';

  @override
  String get resultDeleteConfirmTitle => 'یہ اسکین حذف کریں؟';

  @override
  String get resultDeleteConfirmBody =>
      'یہ معائنہ ریکارڈ آپ کی مقامی تاریخ سے مستقل طور پر حذف ہو جائے گا۔';

  @override
  String get resultDeleteBtn => 'حذف کریں';

  @override
  String get labLargeTextBtn => 'بڑا متن';

  @override
  String get labLargeTextOnBtn => 'بڑا متن: آن';

  @override
  String get labSeniorOverviewTitle => 'آپ کی رپورٹ کا سادہ خلاصہ';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count ٹیسٹ معمول کی حد کے اندر ہیں۔';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count ٹیسٹ معمول کی حد سے باہر ہیں — نیچے سادہ وضاحت موجود ہے۔';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count ٹیسٹ واضح طور پر حد سے باہر ہیں — جلد ڈاکٹر کو دکھائیں۔';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count بنیادی ٹیسٹ اس رپورٹ میں شامل نہیں ہیں۔';
  }

  @override
  String get labAttentionSectionTitle => 'توجہ طلب نتائج';

  @override
  String get labNormalSectionTitle => 'معمول کے نتائج (اطمینان بخش)';

  @override
  String get labMissingSectionTitle =>
      'اس رپورٹ میں شامل نہ ہونے والے بنیادی ٹیسٹ';

  @override
  String get labMissingSectionExplain =>
      'ہر خون کے ٹیسٹ میں تمام پیرامیٹرز شامل نہیں ہوتے۔ نیچے دیے گئے بنیادی ٹیسٹ اس رپورٹ میں موجود نہیں تھے۔';

  @override
  String get labNotInReportBadge => 'رپورٹ میں شامل نہیں';

  @override
  String get labWhatItMeansLabel => 'اس کا کیا مطلب ہے؟';

  @override
  String get labWhatToDoLabel => 'آپ کو کیا کرنا چاہیے؟';

  @override
  String get labAddAnotherPageBtn => 'اگلے صفحے کی تصویر لیں';

  @override
  String labPagesReadBadge(int count) {
    return '$count صفحے پڑھے گئے';
  }

  @override
  String get labPhotoOfflineHint =>
      'رپورٹ کی تصویر منسلک ہو گئی۔ خودکار مطالعے کے لیے سیٹنگز میں کلاؤڈ AI آن کریں یا نیچے خود قدریں درج کریں۔';

  @override
  String get labAllValuesNormalMsg =>
      'اس رپورٹ میں درج تمام نتائج معمول کی حد میں ہیں۔';
}
