// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'هذا التطبيق لا يقدم تشخيصًا طبيًا؛ وهو مخصص للمعلومات والوعي البصري المبدئي فقط.';

  @override
  String get disclaimerTitle => 'تنبيه طبي مهم';

  @override
  String get disclaimerFull =>
      'يقدم VisualCheckUp تقييمًا بصريًا مبدئيًا يعتمد على إشارات اللون والمظهر. إنه ليس جهازًا طبيًا ولا يغني أبدًا عن فحص الطبيب أو التحاليل المخبرية.\n\n• الإضاءة المحيطة وحساس الكاميرا يؤثران على دقة الألوان.\n• راجع الطبيب فورًا عند وجود ألم شديد أو نزيف أو حمى مرتفعة أو اصفرار أو براز أسود/شاحب أو ضيق تنفس.\n• الخصوصية: تتم معالجة الصور على جهازك افتراضيًا.';

  @override
  String get disclaimerAccept => 'فهمت ذلك';

  @override
  String get loginTagline =>
      'مساعدك الشخصي لمتابعة تغيرات الجلد والشامات والعلامات البصرية والاستعداد لزيارة الطبيب.';

  @override
  String get featureColorCalibration => 'معايرة الألوان';

  @override
  String get featurePrivacyFirst => 'الخصوصية أولاً';

  @override
  String get featureOptionalAi => 'ذكاء اصطناعي اختياري';

  @override
  String get loginCardTitle => 'تابع باستخدام حسابك';

  @override
  String get loginCardSubtitle =>
      'احفظ مراجع الألوان الشخصية وسجل الفحوصات بشكل منظم.';

  @override
  String get continueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get orDivider => 'أو';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get guestGreeting => 'متابعة الجلد والصحة البصرية';

  @override
  String userGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return 'حساب $provider';
  }

  @override
  String get localOnlyLabel => 'محفوظ على هذا الجهاز فقط';

  @override
  String get menuHome => 'الرئيسية';

  @override
  String get menuSectionVisualChecks => 'الفحوصات البصرية';

  @override
  String get menuSkinGroup => 'الجلد (شامة، ثؤلول، كدمة، بقعة)';

  @override
  String get menuSkinGeneral => 'الجلد العام والطفح';

  @override
  String get menuSectionTracking => 'المتابعة والتحاليل والمؤشرات';

  @override
  String get menuFollowUpPlan => 'خطة المتابعة الشخصية';

  @override
  String get menuVitalsTracker => 'ضغط الدم والسكر';

  @override
  String get menuLabReports => 'التحاليل وتقارير المستشفى';

  @override
  String get menuQuickColorCard => 'بطاقة الألوان بدون كاميرا';

  @override
  String get menuHistory => 'سجل الفحوصات';

  @override
  String get menuReferenceGuide => 'دليل المراجع البصرية';

  @override
  String get menuSectionSettings => 'الإعدادات والخصوصية';

  @override
  String get menuAiSettings => 'الذكاء الاصطناعي والخصوصية';

  @override
  String get menuDisclaimer => 'التنبيه الطبي';

  @override
  String get menuTheme => 'مظهر التطبيق';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get menuLanguage => 'لغة التطبيق';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get signInGoogleOrApple => 'تسجيل الدخول عبر Google أو Apple';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف الحساب والبيانات المحلية';

  @override
  String get deleteAccountBody =>
      'سيتم تسجيل خروجك وحذف سجل الفحوصات ومراجع الألوان على هذا الجهاز نهائيًا. هل تريد المتابعة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get followUpCardTitle => 'خطة المتابعة الشخصية';

  @override
  String get followUpSelectEdit => 'اختيار / تعديل';

  @override
  String get followUpStart => 'ابدأ';

  @override
  String get followUpEmptyHint =>
      'اضغط لاختيار متابعة العين والبول والضغط والسكر وغيرها.';

  @override
  String get followUpSheetSubtitle =>
      'تابع العين واللسان والأظافر والجلد والبول والبراز وضغط الدم والسكر والتحاليل في خطة واحدة.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active نشط • $completed محدث • $due مستحق';
  }

  @override
  String get homeCategoriesTitle => 'فئات الفحص';

  @override
  String get homeCategoriesSubtitle =>
      'تابع التغيرات البصرية بالكاميرا أو ببطاقة الألوان بدون كاميرا.';

  @override
  String get homeLabsVitalsTitle => 'التحاليل والضغط والسكر';

  @override
  String get homeLabsVitalsSubtitle =>
      'اقرأ تقارير تحاليل الدم وتابع مؤشرات الضغط والسكر بالتاريخ.';

  @override
  String get homeLabsCardTitle => 'التحاليل والتقارير';

  @override
  String get homeLabsCardEmpty => 'قراءة ومراجعة تحاليل الدم';

  @override
  String homeLabsCardCount(int count) {
    return '$count تقارير محفوظة';
  }

  @override
  String get homeVitalsCardTitle => 'الضغط والسكر';

  @override
  String get homeVitalsCardEmpty => 'إدخال القراءات ومتابعة الاتجاه';

  @override
  String homeVitalsCardCount(int count) {
    return '$count قراءات محفوظة';
  }

  @override
  String get homeRecentChecks => 'أحدث الفحوصات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get catEyeTitle => 'العين (الصلبة)';

  @override
  String get catEyeSubtitle => 'الاحمرار والاصفرار ولون بياض العين';

  @override
  String get catNailTitle => 'الأظافر';

  @override
  String get catNailSubtitle => 'الشحوب والازرقاق والاصفرار والشكل';

  @override
  String get catTongueTitle => 'اللسان';

  @override
  String get catTongueSubtitle => 'اللون والطبقة البيضاء/الصفراء والملمس';

  @override
  String get catFaceTitle => 'الوجه والبشرة';

  @override
  String get catFaceSubtitle => 'لون البشرة والشحوب والاحمرار';

  @override
  String get catSkinTitle => 'حالات الجلد';

  @override
  String get catSkinSubtitle => 'الشامات والثآليل والكدمات وبقع الوجه والطفح';

  @override
  String get catUrineTitle => 'لون البول';

  @override
  String get catUrineSubtitle => 'فحص الترطيب ومقياس الألوان';

  @override
  String get catStoolTitle => 'لون البراز';

  @override
  String get catStoolSubtitle => 'فحص الهضم وعلامات التحذير اللونية';

  @override
  String get tooltipHistory => 'السجل';

  @override
  String get tooltipAccountMenu => 'الحساب والقائمة';
}
