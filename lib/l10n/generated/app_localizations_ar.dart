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

  @override
  String get providerGuest => 'ضيف';

  @override
  String signInFailed(String error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get riskNormal => 'مظهر طبيعي';

  @override
  String get riskAttention => 'يُنصح بالمتابعة';

  @override
  String get riskUrgent => 'يُنصح بمراجعة الطبيب';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'الأحدث: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'الأحدث: $count قيمة ($abnormal خارج النطاق)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'الأحدث: $count قيمة (الكل طبيعي)';
  }

  @override
  String get labStatusCriticalLow => 'منخفض بشكل حرج';

  @override
  String get labStatusLow => 'منخفض';

  @override
  String get labStatusNormal => 'طبيعي';

  @override
  String get labStatusHigh => 'مرتفع';

  @override
  String get labStatusCriticalHigh => 'مرتفع بشكل حرج';

  @override
  String get labSourceManual => 'إدخال يدوي';

  @override
  String get labSourcePasted => 'مقروء من نص التقرير';

  @override
  String get labSourcePhoto => 'تقرير صورة / JPG';

  @override
  String get labSourcePdf => 'تقرير PDF';

  @override
  String get bpLow => 'انخفاض ضغط الدم';

  @override
  String get bpNormal => 'نطاق طبيعي';

  @override
  String get bpElevated => 'مرتفع قليلاً';

  @override
  String get bpStage1 => 'ارتفاع المرحلة 1';

  @override
  String get bpStage2 => 'ارتفاع ملحوظ';

  @override
  String get bpCrisis => 'أزمة ارتفاع ضغط حاد';

  @override
  String get sugarLow => 'انخفاض سكر الدم';

  @override
  String get sugarNormal => 'نطاق طبيعي';

  @override
  String get sugarBorderline => 'مرتفع على الحدود';

  @override
  String get sugarHigh => 'ارتفاع سكر الدم';

  @override
  String get sugarVeryHigh => 'ارتفاع حاد في السكر';

  @override
  String get sugarTypeFasting => 'صائم';

  @override
  String get sugarTypePostMeal => 'بعد الأكل (ساعتين)';

  @override
  String get sugarTypeRandom => 'عشوائي';

  @override
  String get specialtyEye => 'طب العيون أو الباطنية';

  @override
  String get specialtyNail => 'الجلدية أو الباطنية';

  @override
  String get specialtyTongue => 'الأنف والأذن أو صحة الفم أو الباطنية';

  @override
  String get specialtySkin => 'الأمراض الجلدية';

  @override
  String get specialtyUrine => 'المسالك البولية أو الباطنية';

  @override
  String get specialtyStool => 'الجهاز الهضمي أو الباطنية';

  @override
  String get cloudBackupTitle => 'النسخ الاحتياطي السحابي (اختياري • Firebase)';

  @override
  String get cloudBackupDesc =>
      'افتراضياً، تبقى جميع تقاريرك وقياساتك على هذا الجهاز فقط. يمكنك تفعيل النسخ الاحتياطي الخاص بحساب Google/Apple لحماية بياناتك عند تغيير الهاتف.';

  @override
  String get cloudBackupToggleTitle => 'تفعيل النسخ الاحتياطي السحابي';

  @override
  String cloudBackupLastSync(String date) {
    return 'آخر نسخة احتياطية: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'مفعّل • جاهز للمزامنة';

  @override
  String get cloudBackupDisabledLocal => 'متوقف • التخزين على الجهاز فقط';

  @override
  String get cloudBackupSignInRequired =>
      'يلزم تسجيل الدخول بحساب Google أو Apple لاستخدام النسخ السحابي.';

  @override
  String get cloudBackupNowBtn => 'نسخ احتياطي الآن';

  @override
  String get cloudRestoreBtn => 'استعادة من السحابة';

  @override
  String get cloudConsentTitle => 'موافقة النسخ الاحتياطي السحابي';

  @override
  String get cloudConsentBody =>
      'تُحفظ تحاليلك وقياساتك وفحوصاتك افتراضياً على جهازك فقط.\n\nعند تفعيل النسخ السحابي، تُخزن بياناتك بشكل خاص ضمن حساب Google/Apple الخاص بك وتُحذف نهائياً عند حذف حسابك.\n\nهل توافق؟';

  @override
  String get cloudConsentConfirm => 'نعم، تفعيل';

  @override
  String cloudBackupSuccess(int count) {
    return 'اكتمل النسخ السحابي: تمت مزامنة $count سجل.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'تمت الاستعادة من السحابة: تم استيراد $count سجل.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'تم إيقاف النسخ السحابي. ستُحفظ السجلات الجديدة على الجهاز فقط.';

  @override
  String get aiCloudToggleTitle => 'تحليل الذكاء الاصطناعي السحابي (Gemini)';

  @override
  String get aiCloudOnDesc =>
      'مفعّل: تُصغّر الصور الواضحة وتُحلّل عبر اتصال آمن، مع التحليل المحلي عند عدم توفر الإنترنت.';

  @override
  String get aiCloudOffDesc =>
      'متوقف (0 توكن): يتم كل التحليل محلياً على جهازك فقط؛ لا تُرسل أي صور للخارج.';

  @override
  String get aiBackendOfflineNote =>
      'عند ربط مفتاح Gemini / Firebase AI يتفعّل التحليل السحابي تلقائياً وفق هذا الخيار؛ المحرك المحلي نشط حالياً.';

  @override
  String get aiOptimizationsTitle => 'ضوابط توفير البيانات والتوكن النشطة';

  @override
  String get aiOptQualityGate =>
      'فحص تلقائي للضبابية والظلام والوهج بدون تكلفة';

  @override
  String get aiOptCompression => 'قص تلقائي وضغط JPEG بدقة 512/768 بكسل';

  @override
  String get aiOptTieredModel =>
      'اختيار ذكي للنموذج (Flash-Lite / Flash) لتقليل الاستهلاك';

  @override
  String get aiOptHashCache => 'ذاكرة تخزين محلية للصور المكررة (0 توكن)';

  @override
  String get aiClearCacheBtn => 'مسح ذاكرة الذكاء الاصطناعي';

  @override
  String get aiCacheCleared => 'تم مسح ذاكرة الذكاء الاصطناعي.';

  @override
  String resultScreenTitle(String category) {
    return 'نتيجة $category';
  }

  @override
  String get tooltipDoctorSummary => 'ملخص لزيارة الطبيب';

  @override
  String get tooltipReferenceGuide => 'دليل المراجع';

  @override
  String get calibratedColorTone => 'درجة اللون المعايرة';

  @override
  String get sampledColorTone => 'درجة اللون السائدة';

  @override
  String confidenceLabel(int percent) {
    return 'ثقة الفحص المبدئي: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote => 'تمت موازنة اللون بالمرجع الأبيض.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'التخصص المقترح: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'المقارنة عبر الزمن';

  @override
  String get todayLabel => 'اليوم';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'السجل السابق: \"$title\" ($status). تتم متابعة $count سجل.';
  }

  @override
  String get personalBaselineComparisonTitle => 'مقارنة مع المعدل الشخصي';

  @override
  String get yourBaselineLabel => 'المعدل';

  @override
  String get warningFlagsTitle => 'علامات تحذيرية تستدعي الانتباه';

  @override
  String get observationsTitle => 'الملاحظات';

  @override
  String get recommendationsTitle => 'التوصيات';

  @override
  String get personalBaselineCardTitle => 'معايرة المعدل الشخصي';

  @override
  String get personalBaselineCardDesc =>
      'احفظ قياساً في يوم تشعر فيه بصحة جيدة كمرجعك الشخصي لتقليل اختلافات كاميرا الهاتف.';

  @override
  String get saveBaselineBtn => 'حفظ كمرجعي الشخصي';

  @override
  String get updateBaselineBtn => 'تحديث مرجعي الشخصي';

  @override
  String get clearBaselineBtn => 'حذف';

  @override
  String baselineSavedMsg(String category) {
    return 'تم حفظ المرجع الشخصي لـ $category.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'تم حذف المرجع الشخصي لـ $category.';
  }

  @override
  String get doctorSummaryBtn => 'عرض على الطبيب • تحضير الملخص';

  @override
  String get returnHomeBtn => 'العودة للرئيسية';

  @override
  String get doctorSheetTitle => 'عرض على الطبيب • ملخص الزيارة';

  @override
  String colorLabel(String hex, String status) {
    return 'اللون: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'التسلسل الزمني مع السجلات السابقة';

  @override
  String get questionsForDoctorTitle => 'أسئلة يمكنك طرحها على طبيبك';

  @override
  String get copyShareSummaryBtn => 'نسخ ومشاركة الملخص';

  @override
  String get doctorSummaryCopied => 'تم نسخ ملخص الزيارة إلى الحافظة.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — المراجع البصرية';
  }

  @override
  String get healthyReferenceLabel => 'المرجع السليم';

  @override
  String get captureChecklistTitle => 'نصائح التصوير الدقيق';

  @override
  String get abnormalFindingsTitle => 'العلامات غير الطبيعية / التحذيرية';

  @override
  String get cameraPermPermanentMsg =>
      'تم تعطيل إذن الكاميرا في الإعدادات. يمكنك تفعيله أو اختيار صورة من المعرض.';

  @override
  String get cameraPermRequiredMsg =>
      'يلزم إذن الكاميرا لإجراء الفحص البصري. تُعالج الصور محلياً على جهازك.';

  @override
  String get cameraGrantPermTitle => 'يلزم الوصول إلى الكاميرا';

  @override
  String get cameraRequestPermBtn => 'منح إذن الكاميرا';

  @override
  String get cameraPickGalleryBtn => 'اختيار من المعرض';

  @override
  String get cameraWhiteRefOn => 'المرجع الأبيض: مفعّل';

  @override
  String get cameraWhiteRefOff => 'المرجع الأبيض: متوقف';

  @override
  String get cameraBaselineActive => 'المرجع الشخصي محفوظ';

  @override
  String get cameraAnalyzing => 'جارٍ التحليل...';

  @override
  String get cameraCaptureBtn => 'التقاط وتحليل';

  @override
  String cameraAnalysisFailed(String error) {
    return 'فشل التحليل: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • بطاقة الألوان';
  }

  @override
  String get quickCardPrivacyBanner =>
      'لا حاجة للكاميرا: اختر أقرب درجة لون لتسجيل سريع وخاص خلال ثانيتين.';

  @override
  String get quickCardChooseShade => 'اختر أقرب درجة لون';

  @override
  String get quickCardExtraContext => 'معلومات إضافية (اختياري)';

  @override
  String get quickCardSaveViewBtn => 'حفظ وعرض التقييم';

  @override
  String get quickCardUseCameraBtn => 'استخدام الكاميرا بدلاً من ذلك';

  @override
  String get skinIntroTitle => 'فحص جلدي بصري مبدئي';

  @override
  String get skinIntroDesc =>
      'يقارن الشامات والثآليل والكدمات وبقع الوجه بالجلد المحيط. ليس تشخيصاً طبياً؛ يهدف للتحضير لزيارة طبيب الجلدية.';

  @override
  String get skinStep1Title => '1. اختر وحدة الفحص الجلدي';

  @override
  String get skinOtherConcernsLabel => 'حالات جلدية أخرى';

  @override
  String get skinStep2Title => '2. الأعراض المصاحبة (اختياري)';

  @override
  String get skinStep3Title => '3. منطقة الجسم (اختياري)';

  @override
  String get skinStartCameraBtn => 'بدء فحص الجلد بالكاميرا';

  @override
  String get skinConcernRash => 'احمرار / طفح جلدي';

  @override
  String get skinConcernMole => 'شامة / بقعة داكنة';

  @override
  String get skinConcernScaly => 'قشور / جفاف';

  @override
  String get skinConcernBlister => 'بثور / حب الشباب';

  @override
  String get skinConcernGeneral => 'فحص جلدي عام';

  @override
  String get bodyAreaFaceNeck => 'الوجه / الرقبة';

  @override
  String get bodyAreaArmHand => 'الذراع / اليد';

  @override
  String get bodyAreaTorso => 'الجذع';

  @override
  String get bodyAreaLegFoot => 'الساق / القدم';

  @override
  String get bodyAreaScalp => 'فروة الرأس';

  @override
  String get bodyAreaOther => 'أخرى';

  @override
  String get symptomItching => 'حكة';

  @override
  String get symptomPainWarmth => 'ألم / سخونة';

  @override
  String get symptomRapidChange => 'نمو سريع / تغير الشكل';

  @override
  String get symptomBleeding => 'نزيف / إفرازات';

  @override
  String get symptomSpreading => 'ينتشر بسرعة';

  @override
  String get symptomFever => 'ترافقه حمى';

  @override
  String get symptomNonHealing => 'جرح لا يلتئم (+4 أسابيع)';

  @override
  String get symptomOver6mm => 'أكبر من 6 مم أو حواف غير منتظمة';

  @override
  String get symptomNoTrauma => 'ظهر تلقائياً دون إصابة';

  @override
  String get symptomRoughDots => 'سطح خشن / نقاط سوداء صغيرة';

  @override
  String get symptomSunHormone => 'بقعة شمس أو هرمونات أو بعد حب الشباب';

  @override
  String get bruiseGuideTitle => 'دليل مراحل ألوان الكدمات';

  @override
  String get wartGuideTitle => 'دليل فحص وسلامة الثآليل';

  @override
  String get abcdeGuideTitle => 'دليل ABCDE لفحص الشامات';

  @override
  String get abcdeGuideSubtitle =>
      '5 علامات أساسية يستخدمها أطباء الجلدية في فحص الشامات';

  @override
  String get labScreenTitle => 'التحاليل وتقارير المستشفى';

  @override
  String get labTabReports => 'تقاريري';

  @override
  String get labTabTrends => 'تتبع التغيرات';

  @override
  String get labAddBtn => 'إضافة تقرير / تحليل دم';

  @override
  String get labEmptyTitle => 'لا توجد تحاليل دم محفوظة بعد';

  @override
  String get labEmptyDesc =>
      'ارفع تقرير PDF أو JPG؛ يمكنك اختيارياً إضافة تشخيص المستشفى أو شكواك للحصول على شرح مبسط.';

  @override
  String get labAddFirstBtn => 'إضافة أول تقرير PDF';

  @override
  String get labTrendsEmptyDesc =>
      'احفظ تحاليل بتواريخ مختلفة لعرض رسوم التغير الزمني للهيموغلوبين والفيريتين والغلوكوز وTSH وفيتامين د.';

  @override
  String labParamsCount(int count) {
    return '$count مؤشر';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count خارج النطاق';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'تقييم المؤشرات ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'تشخيص المستشفى / الطبيب';

  @override
  String get labEnteredComplaintTitle => 'شكواك / ملاحظتك';

  @override
  String get labInterpretationTitle => 'تفسير مبسط وواضح';

  @override
  String get labCopyDoctorSummaryBtn => 'عرض على الطبيب • نسخ الملخص';

  @override
  String get labSummaryCopied => 'تم نسخ ملخص التحليل.';

  @override
  String get labExportPdfBtn => 'تصدير تقرير PDF للطبيب';

  @override
  String get labAddSheetTitle => 'إضافة تقرير مستشفى / تحليل دم';

  @override
  String get labReportTitleField => 'عنوان التقرير';

  @override
  String get labDefaultReportTitle => 'نتيجة تحليل الدم';

  @override
  String get labStep1Upload => '1. رفع تقرير PDF أو JPG';

  @override
  String get labUploadPdfJpgBtn => 'رفع PDF أو JPG';

  @override
  String get labCameraCaptureBtn => 'التقاط صورة';

  @override
  String get labStep2Context => '2. تشخيص المستشفى وملاحظتك (اختياري)';

  @override
  String get labStep2ContextHint =>
      'أضف التشخيص الذي ترغب في فهمه أو شكواك؛ يمكنك ترك الحقلين فارغين.';

  @override
  String get labDiagnosisField => 'تشخيص المستشفى / الطبيب (اختياري)';

  @override
  String get labComplaintField => 'شكواك / سؤالك (اختياري)';

  @override
  String get labStep3PasteManual => '3. لصق نص التقرير أو إضافة القيم يدوياً';

  @override
  String get labParseTextBtn => 'قراءة وتحليل النص';

  @override
  String get labParamDropdown => 'مؤشر التحليل';

  @override
  String labValueField(String unit) {
    return 'القيمة ($unit)';
  }

  @override
  String get labAddValueBtn => '+ إضافة';

  @override
  String labParsedValuesTitle(int count) {
    return 'القيم المقروءة ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'تقييم وحفظ التقرير';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count سجل • التغير: $delta • الأحدث: $status';
  }

  @override
  String get vitalsScreenTitle => 'متابعة الضغط والسكر';

  @override
  String get vitalsCopySummaryTooltip => 'نسخ ملخص الطبيب';

  @override
  String get vitalsCopyEmptyMsg => 'أضف قياس ضغط أو سكر أولاً لإنشاء ملخص.';

  @override
  String get vitalsSummaryCopied => 'تم نسخ ملخص الضغط والسكر.';

  @override
  String get vitalsAddBpBtn => 'إضافة ضغط الدم';

  @override
  String get vitalsAddSugarBtn => 'إضافة سكر الدم';

  @override
  String get vitalsBpEmptyTitle => 'لا توجد قياسات ضغط دم بعد';

  @override
  String get vitalsBpEmptyDesc =>
      'سجّل الضغط الانقباضي والانبساطي والنبض بالتاريخ لمتابعة الرسم البياني.';

  @override
  String get vitalsBpAddFirstBtn => 'إضافة أول قياس ضغط';

  @override
  String get vitalsSugarEmptyTitle => 'لا توجد قياسات سكر دم بعد';

  @override
  String get vitalsSugarEmptyDesc =>
      'سجّل قياسات السكر صائماً أو بعد الأكل أو عشوائياً لمتابعة الاتجاه.';

  @override
  String get vitalsSugarAddFirstBtn => 'إضافة أول قياس سكر';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'المتوسط ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • النبض $pulse';
  }

  @override
  String get vitalsBpHistoryTitle => 'سجل قياسات ضغط الدم';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'المتوسط ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'سجل قياسات سكر الدم';

  @override
  String get vitalsNewBpTitle => 'قياس ضغط دم جديد';

  @override
  String get vitalsSystolicField => 'الانقباضي (الأعلى)';

  @override
  String get vitalsDiastolicField => 'الانبساطي (الأدنى)';

  @override
  String get vitalsPulseField => 'النبض (اختياري)';

  @override
  String get vitalsNoteField => 'ملاحظة (اختياري)';

  @override
  String get vitalsSaveBpBtn => 'حفظ ضغط الدم';

  @override
  String get vitalsNewSugarTitle => 'قياس سكر دم جديد';

  @override
  String get vitalsSugarValueField => 'سكر الدم (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'حفظ سكر الدم';

  @override
  String get chartAddReadingHint => 'أضف قياسات لعرض الرسم البياني';

  @override
  String get loginTermsTitle => 'شروط الاستخدام والتنبيه الطبي';

  @override
  String get loginTermsCheckbox =>
      'أفهم أن VisualCheckUp لا يقدم تشخيصًا طبيًا نهائيًا وهو للتوعية الأولية فقط، وأوافق على شروط الاستخدام.';

  @override
  String get loginTermsRequiredMsg =>
      'يرجى الموافقة على شروط الاستخدام والتنبيه الطبي قبل تسجيل الدخول.';

  @override
  String get loginTermsReadMore => 'قراءة الشروط';

  @override
  String get loginTermsModalBody =>
      '• ليس تشخيصًا طبيًا: تطبيق VisualCheckUp ليس جهازًا طبيًا ولا يغني عن فحص الطبيب أو علاجه.\n\n• للتوعية فقط: الفحوصات البصرية وملخصات التحاليل ومؤشر كتلة الجسم والنمو مخصصة للمتابعة الشخصية والتحضير لزيارة الطبيب.\n\n• تنبيه طارئ: عند وجود ألم شديد في الصدر أو ضيق تنفس أو أعراض طارئة، توجه فورًا إلى الطوارئ.\n\n• الخصوصية: تُحفظ بياناتك الصحية افتراضيًا على جهازك فقط.';

  @override
  String get loginTermsAcceptBtn => 'قرأت وأوافق';
}
