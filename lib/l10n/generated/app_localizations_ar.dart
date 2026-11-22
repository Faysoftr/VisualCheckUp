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

  @override
  String get menuSettings => 'الإعدادات (الأذونات واللغة)';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguageDesc =>
      'تُستخدم لغة الهاتف تلقائيًا افتراضيًا، ويمكنك اختيار أي لغة أدناه.';

  @override
  String get settingsPermissionsTitle => 'أذونات التطبيق';

  @override
  String get settingsPermissionsDesc =>
      'تحقق من أذونات الكاميرا والمعرض وأدرها من هنا.';

  @override
  String get settingsCameraPermission => 'إذن الكاميرا';

  @override
  String get settingsCameraPermissionDesc =>
      'للالتقاط البصري للعين واللسان والأظافر والجلد';

  @override
  String get settingsPhotosPermission => 'إذن المعرض والصور';

  @override
  String get settingsPhotosPermissionDesc =>
      'لرفع الصور وتقارير التحاليل المخبرية';

  @override
  String get settingsOpenSystemPermissions => 'فتح أذونات التطبيق في الهاتف';

  @override
  String get permChecking => 'جارٍ التحقق...';

  @override
  String get permGranted => 'تم السماح';

  @override
  String get permDenied => 'الإذن مطلوب';

  @override
  String get permPermanent => 'التفعيل من إعدادات النظام';

  @override
  String get permUnavailable => 'يُدار عبر الجهاز';

  @override
  String get permGrantBtn => 'سماح';

  @override
  String get permOpenSettingsBtn => 'فتح الإعدادات';

  @override
  String get skinCancerRisk => 'الشامة ومخاطر سرطان الجلد';

  @override
  String get skinWart => 'فحص مبدئي للثؤلول';

  @override
  String get skinBruise => 'متابعة الكدمات';

  @override
  String get skinFacialSpot => 'بقع الوجه';

  @override
  String get trackEyeTitle => 'فحص العين الأسبوعي';

  @override
  String get trackEyeSubtitle => 'تابع احمرار أو اصفرار بياض العين';

  @override
  String get trackTongueTitle => 'فحص اللسان الأسبوعي';

  @override
  String get trackTongueSubtitle => 'تابع لون اللسان والطبقة السطحية';

  @override
  String get trackNailTitle => 'فحص الأظافر الأسبوعي';

  @override
  String get trackNailSubtitle => 'راقب الشحوب أو الازرقاق أو الاصفرار';

  @override
  String get trackFaceTitle => 'فحص الوجه كل أسبوعين';

  @override
  String get trackFaceSubtitle => 'قارن الشحوب والاحمرار ولون البشرة';

  @override
  String get trackSkinTitle => 'فحص الجلد والشامات الشهري';

  @override
  String get trackSkinSubtitle =>
      'قارن تغيرات الشامات والثآليل والبقع كل 30 يومًا';

  @override
  String get trackHydrationTitle => 'متابعة الترطيب اليومية (البول)';

  @override
  String get trackHydrationSubtitle => 'سجّل الترطيب في ثانيتين ببطاقة الألوان';

  @override
  String get trackStoolTitle => 'فحص لون البراز الأسبوعي';

  @override
  String get trackStoolSubtitle => 'تابع الهضم وعلامات التحذير اللونية';

  @override
  String get trackBpTitle => 'قياس ضغط الدم اليومي';

  @override
  String get trackBpSubtitle => 'سجّل الضغط الانقباضي/الانبساطي والنبض';

  @override
  String get trackSugarTitle => 'قياس سكر الدم اليومي';

  @override
  String get trackSugarSubtitle => 'تابع قراءات السكر صائمًا أو بعد الأكل';

  @override
  String get trackLabTitle => 'تحليل الدم والتقارير كل 3 أشهر';

  @override
  String get trackLabSubtitle => 'ارفع تقارير المستشفى وقارنها دوريًا';

  @override
  String get statusFirstPending => 'بانتظار أول سجل';

  @override
  String get statusDueNow => 'حان وقت الفحص';

  @override
  String get statusDoneToday => 'اكتمل اليوم';

  @override
  String statusNextDays(int days) {
    return 'الفحص القادم بعد $days يوم';
  }

  @override
  String get actionCheckNow => 'افحص الآن';

  @override
  String get actionLogReading => 'إدخال قراءة';

  @override
  String get actionAddReport => 'إضافة تقرير';

  @override
  String checkMethodTitle(String category) {
    return '$category • طريقة الفحص';
  }

  @override
  String get checkMethodSubtitle =>
      'اختر من بطاقة الألوان خلال ثانيتين دون تصوير أو استخدم الكاميرا.';

  @override
  String get colorCardRecommendedTitle => 'بطاقة الألوان بدون كاميرا (موصى به)';

  @override
  String get colorCardRecommendedSubtitle =>
      'تسجيل سريع وخاص دون صورة (ثانيتان)';

  @override
  String get cameraMeasureTitle => 'القياس بالكاميرا';

  @override
  String get cameraMeasureSubtitle => 'قياس تلقائي مع معايرة توازن الأبيض';

  @override
  String get referenceGuideSubtitle =>
      'اختر وحدة لعرض المراجع البصرية السليمة وغير الطبيعية.';

  @override
  String get historyEmpty => 'لا توجد فحوصات محفوظة بعد.';

  @override
  String get filterAll => 'الكل';

  @override
  String get aiSettingsTitle => 'الذكاء الاصطناعي والخصوصية';

  @override
  String get vitalsBpTab => 'ضغط الدم';

  @override
  String get vitalsSugarTab => 'سكر الدم';

  @override
  String get skinScreenTitle => 'فحص مبدئي لحالات الجلد';
}
