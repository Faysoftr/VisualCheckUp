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
}
