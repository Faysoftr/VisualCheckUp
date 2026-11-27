// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'এই অ্যাপটি চিকিৎসা নির্ণয় করে না; এটি শুধুমাত্র তথ্য এবং প্রাথমিক সচেতনতার জন্য।';

  @override
  String get disclaimerTitle => 'গুরুত্বপূর্ণ চিকিৎসা বিজ্ঞপ্তি';

  @override
  String get disclaimerFull =>
      'VisualCheckUp রঙ ও দৃশ্যমান লক্ষণের ভিত্তিতে প্রাথমিক ধারণা দেয়। এটি কোনো মেডিকেল ডিভাইস নয় এবং ডাক্তারের পরীক্ষা বা ল্যাব টেস্টের বিকল্প নয়।\n\n• আলো এবং ক্যামেরা সেন্সর রঙের মান প্রভাবিত করতে পারে।\n• তীব্র ব্যথা, রক্তপাত, উচ্চ জ্বর, জন্ডিস, কালো/সাদা মল বা শ্বাসকষ্ট হলে দ্রুত চিকিৎসকের পরামর্শ নিন।\n• গোপনীয়তা: ছবি ডিফল্টভাবে আপনার ডিভাইসেই প্রসেস হয়।';

  @override
  String get disclaimerAccept => 'বুঝেছি';

  @override
  String get loginTagline =>
      'ত্বক, তিল এবং দৈনন্দিন স্বাস্থ্য পরিবর্তন পর্যবেক্ষণ ও ডাক্তারের অ্যাপয়েন্টমেন্টের প্রস্তুতি সহায়ক।';

  @override
  String get featureColorCalibration => 'রঙ ক্যালিব্রেশন';

  @override
  String get featurePrivacyFirst => 'গোপনীয়তা অগ্রাধিকার';

  @override
  String get featureOptionalAi => 'ঐচ্ছিক AI';

  @override
  String get loginCardTitle => 'আপনার অ্যাকাউন্ট দিয়ে চালিয়ে যান';

  @override
  String get loginCardSubtitle =>
      'আপনার রঙের রেফারেন্স এবং চেকআপ ইতিহাস গুছিয়ে রাখুন।';

  @override
  String get continueWithApple => 'Apple দিয়ে চালিয়ে যান';

  @override
  String get continueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get orDivider => 'অথবা';

  @override
  String get continueAsGuest => 'অতিথি হিসেবে চালিয়ে যান';

  @override
  String get guestGreeting => 'ত্বক ও দৃশ্যমান স্বাস্থ্য ট্র্যাকিং';

  @override
  String userGreeting(String name) {
    return 'স্বাগতম, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider অ্যাকাউন্ট';
  }

  @override
  String get localOnlyLabel => 'শুধুমাত্র এই ডিভাইসে সংরক্ষিত';

  @override
  String get menuHome => 'হোম';

  @override
  String get menuSectionVisualChecks => 'দৃশ্যমান পরীক্ষা';

  @override
  String get menuSkinGroup => 'ত্বক (তিল, আঁচিল, কালশিটে, দাগ)';

  @override
  String get menuSkinGeneral => 'সাধারণ ত্বক ও র‍্যাশ';

  @override
  String get menuSectionTracking => 'ট্র্যাকিং, ল্যাব ও ভাইটালস';

  @override
  String get menuFollowUpPlan => 'ব্যক্তিগত ফলো-আপ প্ল্যান';

  @override
  String get menuVitalsTracker => 'রক্তচাপ ও সুগার ট্র্যাকার';

  @override
  String get menuLabReports => 'ল্যাব ও হাসপাতাল রিপোর্ট';

  @override
  String get menuQuickColorCard => 'ক্যামেরাবিহীন কালার কার্ড';

  @override
  String get menuHistory => 'পরীক্ষার ইতিহাস';

  @override
  String get menuReferenceGuide => 'দৃশ্যমান রেফারেন্স গাইড';

  @override
  String get menuSectionSettings => 'সেটিংস ও গোপনীয়তা';

  @override
  String get menuAiSettings => 'AI ও গোপনীয়তা';

  @override
  String get menuDisclaimer => 'চিকিৎসা বিজ্ঞপ্তি';

  @override
  String get menuTheme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get menuLanguage => 'অ্যাপের ভাষা';

  @override
  String get languageSystem => 'সিস্টেম ভাষা';

  @override
  String get signInGoogleOrApple => 'Google বা Apple দিয়ে সাইন ইন করুন';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get deleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get deleteAccountTitle => 'অ্যাকাউন্ট এবং লোকাল ডেটা মুছুন';

  @override
  String get deleteAccountBody =>
      'আপনি সাইন আউট হবেন এবং এই ডিভাইসের চেকআপ ইতিহাস স্থায়ীভাবে মুছে যাবে। চালিয়ে যাবেন?';

  @override
  String get cancel => 'বাতিল';

  @override
  String get followUpCardTitle => 'ব্যক্তিগত ফলো-আপ প্ল্যান';

  @override
  String get followUpSelectEdit => 'নির্বাচন / সম্পাদনা';

  @override
  String get followUpStart => 'শুরু করুন';

  @override
  String get followUpEmptyHint =>
      'চোখ, প্রস্রাব, রক্তচাপ, সুগার ও অন্যান্য রুটিন নির্বাচন করতে ট্যাপ করুন।';

  @override
  String get followUpSheetSubtitle =>
      'একটি প্ল্যানে চোখ, জিহ্বা, নখ, ত্বক, প্রস্রাব, মল, রক্তচাপ, সুগার ও ল্যাব রিপোর্ট ট্র্যাক করুন।';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active সক্রিয় • $completed হালনাগাদ • $due বাকি';
  }

  @override
  String get homeCategoriesTitle => 'পরীক্ষার বিভাগ';

  @override
  String get homeCategoriesSubtitle =>
      'ক্যামেরা বা কালার কার্ড দিয়ে দৃশ্যমান পরিবর্তন পর্যবেক্ষণ করুন।';

  @override
  String get homeLabsVitalsTitle => 'ল্যাব, রক্তচাপ ও সুগার';

  @override
  String get homeLabsVitalsSubtitle =>
      'রক্ত পরীক্ষার রিপোর্ট পড়ুন এবং রক্তচাপ ও সুগারের ধারা দেখুন।';

  @override
  String get homeLabsCardTitle => 'ল্যাব ও রিপোর্ট';

  @override
  String get homeLabsCardEmpty => 'রক্ত পরীক্ষা পড়ুন ও বুঝুন';

  @override
  String homeLabsCardCount(int count) {
    return '$countটি সংরক্ষিত রিপোর্ট';
  }

  @override
  String get homeVitalsCardTitle => 'রক্তচাপ ও সুগার';

  @override
  String get homeVitalsCardEmpty => 'রিডিং দিন ও ট্রেন্ড দেখুন';

  @override
  String homeVitalsCardCount(int count) {
    return '$countটি সংরক্ষিত রিডিং';
  }

  @override
  String get homeRecentChecks => 'সাম্প্রতিক পরীক্ষা';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String get catEyeTitle => 'চোখ (স্ক্লেরা)';

  @override
  String get catEyeSubtitle => 'লালচে ভাব, হলুদ ভাব ও চোখের সাদা অংশ';

  @override
  String get catNailTitle => 'নখ';

  @override
  String get catNailSubtitle => 'ফ্যাকাশে, নীলচে, হলুদ ও গঠনের পরীক্ষা';

  @override
  String get catTongueTitle => 'জিহ্বা';

  @override
  String get catTongueSubtitle => 'রঙ, সাদা/হলুদ আস্তরণ ও গঠন';

  @override
  String get catFaceTitle => 'মুখ ও ত্বক';

  @override
  String get catFaceSubtitle => 'ত্বকের রঙ, ফ্যাকাশে ভাব ও লালচে ভাব';

  @override
  String get catSkinTitle => 'ত্বকের সমস্যা';

  @override
  String get catSkinSubtitle => 'তিল, আঁচিল, কালশিটে, মুখের দাগ ও র‍্যাশ';

  @override
  String get catUrineTitle => 'প্রস্রাবের রঙ';

  @override
  String get catUrineSubtitle => 'হাইড্রেশন ও রঙ স্কেল পরীক্ষা';

  @override
  String get catStoolTitle => 'মলের রঙ';

  @override
  String get catStoolSubtitle => 'হজম ও রঙের সতর্কতা পরীক্ষা';

  @override
  String get tooltipHistory => 'ইতিহাস';

  @override
  String get tooltipAccountMenu => 'অ্যাকাউন্ট ও মেনু';

  @override
  String get menuSettings => 'সেটিংস (অনুমতি ও ভাষা)';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsLanguageDesc =>
      'ডিফল্টভাবে ফোনের ভাষা ব্যবহার হয়। নিচ থেকে যেকোনো ভাষা বেছে নিতে পারেন।';

  @override
  String get settingsPermissionsTitle => 'অ্যাপ অনুমতি';

  @override
  String get settingsPermissionsDesc =>
      'এখান থেকে ক্যামেরা ও গ্যালারি অনুমতি পরিচালনা করুন।';

  @override
  String get settingsCameraPermission => 'ক্যামেরা অনুমতি';

  @override
  String get settingsCameraPermissionDesc =>
      'চোখ, জিহ্বা, নখ ও ত্বকের ছবির জন্য';

  @override
  String get settingsPhotosPermission => 'গ্যালারি ও ফটো অনুমতি';

  @override
  String get settingsPhotosPermissionDesc =>
      'ছবি ও ল্যাব রিপোর্ট আপলোড করার জন্য';

  @override
  String get settingsOpenSystemPermissions => 'ফোনের অ্যাপ অনুমতি খুলুন';

  @override
  String get permChecking => 'যাচাই হচ্ছে...';

  @override
  String get permGranted => 'অনুমোদিত';

  @override
  String get permDenied => 'অনুমতি প্রয়োজন';

  @override
  String get permPermanent => 'সিস্টেম সেটিংস থেকে চালু করুন';

  @override
  String get permUnavailable => 'ডিভাইস দ্বারা পরিচালিত';

  @override
  String get permGrantBtn => 'অনুমতি দিন';

  @override
  String get permOpenSettingsBtn => 'সেটিংস খুলুন';

  @override
  String get skinCancerRisk => 'তিল ও ত্বকের ক্যান্সার ঝুঁকি';

  @override
  String get skinWart => 'আঁচিল প্রাথমিক পরীক্ষা';

  @override
  String get skinBruise => 'কালশিটে পর্যবেক্ষণ';

  @override
  String get skinFacialSpot => 'মুখের দাগ';

  @override
  String get trackEyeTitle => 'সাপ্তাহিক চোখ পরীক্ষা';

  @override
  String get trackEyeSubtitle => 'চোখের লালচে বা হলুদ ভাব পর্যবেক্ষণ করুন';

  @override
  String get trackTongueTitle => 'সাপ্তাহিক জিহ্বা পরীক্ষা';

  @override
  String get trackTongueSubtitle => 'জিহ্বার রঙ ও আস্তরণের পরিবর্তন দেখুন';

  @override
  String get trackNailTitle => 'সাপ্তাহিক নখ পরীক্ষা';

  @override
  String get trackNailSubtitle => 'ফ্যাকাশে, নীলচে বা হলুদ ভাব নজরে রাখুন';

  @override
  String get trackFaceTitle => 'পাক্ষিক মুখ ও ত্বকের রঙ';

  @override
  String get trackFaceSubtitle => 'ফ্যাকাশে ভাব ও লালচে ভাব তুলনা করুন';

  @override
  String get trackSkinTitle => 'মাসিক ত্বক, তিল ও আঁচিল পরীক্ষা';

  @override
  String get trackSkinSubtitle => '৩০ দিনে তিল, আঁচিল ও দাগের পরিবর্তন দেখুন';

  @override
  String get trackHydrationTitle => 'দৈনিক হাইড্রেশন (প্রস্রাব) ট্র্যাকিং';

  @override
  String get trackHydrationSubtitle =>
      'কালার কার্ডে ২ সেকেন্ডে পানির ভারসাম্য লিখুন';

  @override
  String get trackStoolTitle => 'সাপ্তাহিক মলের রঙ পরীক্ষা';

  @override
  String get trackStoolSubtitle => 'হজম ও রঙের সতর্কতা নিয়মিত ট্র্যাক করুন';

  @override
  String get trackBpTitle => 'দৈনিক রক্তচাপ পরিমাপ';

  @override
  String get trackBpSubtitle =>
      'সিস্টোলিক/ডায়াস্টোলিক ও পালস ট্রেন্ড সংরক্ষণ করুন';

  @override
  String get trackSugarTitle => 'দৈনিক ব্লাড সুগার ট্র্যাকিং';

  @override
  String get trackSugarSubtitle => 'খালি পেটে বা খাওয়ার পর সুগার রেকর্ড করুন';

  @override
  String get trackLabTitle => 'ত্রৈমাসিক রক্ত পরীক্ষা ও রিপোর্ট';

  @override
  String get trackLabSubtitle => 'হাসপাতালের রিপোর্ট আপলোড করে তুলনা করুন';

  @override
  String get statusFirstPending => 'প্রথম রেকর্ডের অপেক্ষায়';

  @override
  String get statusDueNow => 'পরীক্ষার সময় হয়েছে';

  @override
  String get statusDoneToday => 'আজ সম্পন্ন হয়েছে';

  @override
  String statusNextDays(int days) {
    return 'পরবর্তী পরীক্ষা: $days দিন পর';
  }

  @override
  String get actionCheckNow => 'এখনই পরীক্ষা করুন';

  @override
  String get actionLogReading => 'রিডিং দিন';

  @override
  String get actionAddReport => 'রিপোর্ট যোগ করুন';

  @override
  String checkMethodTitle(String category) {
    return '$category • পরীক্ষার পদ্ধতি';
  }

  @override
  String get checkMethodSubtitle =>
      'ছবি না তুলে ২ সেকেন্ডে কালার কার্ড বেছে নিন অথবা ক্যামেরা ব্যবহার করুন।';

  @override
  String get colorCardRecommendedTitle =>
      'ক্যামেরাবিহীন কালার কার্ড (প্রস্তাবিত)';

  @override
  String get colorCardRecommendedSubtitle =>
      'ছবি ছাড়াই ব্যক্তিগত ও দ্রুত রেকর্ড (২ সেকেন্ড)';

  @override
  String get cameraMeasureTitle => 'ক্যামেরা রঙ পরিমাপ';

  @override
  String get cameraMeasureSubtitle =>
      'হোয়াইট-ব্যালেন্স ক্যালিব্রেশনসহ স্বয়ংক্রিয় পরিমাপ';

  @override
  String get referenceGuideSubtitle =>
      'স্বাভাবিক ও অস্বাভাবিক লক্ষণ দেখতে মডিউল নির্বাচন করুন।';

  @override
  String get historyEmpty => 'এখনো কোনো পরীক্ষা সংরক্ষিত হয়নি।';

  @override
  String get filterAll => 'সব';

  @override
  String get aiSettingsTitle => 'AI ও গোপনীয়তা';

  @override
  String get vitalsBpTab => 'রক্তচাপ';

  @override
  String get vitalsSugarTab => 'ব্লাড সুগার';

  @override
  String get skinScreenTitle => 'ত্বকের সমস্যার প্রাথমিক পরীক্ষা';

  @override
  String get providerGuest => 'অতিথি';

  @override
  String signInFailed(String error) {
    return 'সাইন-ইন ব্যর্থ হয়েছে: $error';
  }

  @override
  String get riskNormal => 'স্বাভাবিক চেহারা';

  @override
  String get riskAttention => 'ফলো-আপ প্রস্তাবিত';

  @override
  String get riskUrgent => 'ডাক্তারের পরামর্শ জরুরি';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'সর্বশেষ: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'সর্বশেষ: $countটি মান ($abnormalটি সীমার বাইরে)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'সর্বশেষ: $countটি মান (সব স্বাভাবিক)';
  }

  @override
  String get labStatusCriticalLow => 'অত্যন্ত কম';

  @override
  String get labStatusLow => 'কম';

  @override
  String get labStatusNormal => 'স্বাভাবিক';

  @override
  String get labStatusHigh => 'বেশি';

  @override
  String get labStatusCriticalHigh => 'অত্যন্ত বেশি';

  @override
  String get labSourceManual => 'ম্যানুয়াল এন্ট্রি';

  @override
  String get labSourcePasted => 'রিপোর্ট টেক্সট থেকে পঠিত';

  @override
  String get labSourcePhoto => 'JPG / ছবি রিপোর্ট';

  @override
  String get labSourcePdf => 'PDF রিপোর্ট';

  @override
  String get bpLow => 'নিম্ন রক্তচাপ';

  @override
  String get bpNormal => 'স্বাভাবিক সীমা';

  @override
  String get bpElevated => 'সামান্য বেশি';

  @override
  String get bpStage1 => 'ধাপ ১ উচ্চ';

  @override
  String get bpStage2 => 'উল্লেখযোগ্য উচ্চ';

  @override
  String get bpCrisis => 'জরুরি উচ্চ রক্তচাপ';

  @override
  String get sugarLow => 'নিম্ন রক্তের শর্করা';

  @override
  String get sugarNormal => 'স্বাভাবিক সীমা';

  @override
  String get sugarBorderline => 'সীমান্তরেখায় বেশি';

  @override
  String get sugarHigh => 'উচ্চ রক্তের শর্করা';

  @override
  String get sugarVeryHigh => 'অত্যন্ত উচ্চ শর্করা';

  @override
  String get sugarTypeFasting => 'খালি পেটে';

  @override
  String get sugarTypePostMeal => 'খাওয়ার ২ ঘণ্টা পর';

  @override
  String get sugarTypeRandom => 'যেকোনো সময়';

  @override
  String get specialtyEye => 'চক্ষু বা মেডিসিন বিভাগ';

  @override
  String get specialtyNail => 'চর্মরোগ বা মেডিসিন';

  @override
  String get specialtyTongue => 'ইএনটি, মুখের স্বাস্থ্য বা মেডিসিন';

  @override
  String get specialtySkin => 'চর্মরোগ বিভাগ';

  @override
  String get specialtyUrine => 'ইউরোলজি বা মেডিসিন';

  @override
  String get specialtyStool => 'গ্যাস্ট্রোএন্টারোলজি বা মেডিসিন';

  @override
  String get cloudBackupTitle => 'ক্লাউড ব্যাকআপ (ঐচ্ছিক • Firebase)';

  @override
  String get cloudBackupDesc =>
      'ডিফল্টভাবে আপনার সব রিপোর্ট ও পরিমাপ শুধুমাত্র এই ডিভাইসে থাকে। ফোন বদলানোর সময় ডেটা সুরক্ষিত রাখতে আপনার Google/Apple অ্যাকাউন্টে ব্যাকআপ চালু করতে পারেন।';

  @override
  String get cloudBackupToggleTitle => 'ক্লাউড ব্যাকআপ চালু করুন';

  @override
  String cloudBackupLastSync(String date) {
    return 'শেষ ব্যাকআপ: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'চালু • ব্যাকআপের জন্য প্রস্তুত';

  @override
  String get cloudBackupDisabledLocal => 'বন্ধ • শুধুমাত্র ডিভাইসে সংরক্ষিত';

  @override
  String get cloudBackupSignInRequired =>
      'ক্লাউড ব্যাকআপের জন্য Google বা Apple দিয়ে সাইন ইন করুন।';

  @override
  String get cloudBackupNowBtn => 'এখনই ব্যাকআপ নিন';

  @override
  String get cloudRestoreBtn => 'ক্লাউড থেকে পুনরুদ্ধার';

  @override
  String get cloudConsentTitle => 'ক্লাউড ব্যাকআপ সম্মতি';

  @override
  String get cloudConsentBody =>
      'আপনার রক্তের পরীক্ষা, পরিমাপ ও চেকআপ ডিফল্টভাবে কেবল এই ডিভাইসে থাকে।\n\nক্লাউড ব্যাকআপ চালু করলে ডেটা আপনার ব্যক্তিগত Google/Apple ফায়ারবেস অ্যাকাউন্টে সংরক্ষিত হবে এবং অ্যাকাউন্ট মুছলে স্থায়ীভাবে মুছে যাবে।\n\nআপনি কি সম্মত?';

  @override
  String get cloudConsentConfirm => 'হ্যাঁ, চালু করুন';

  @override
  String cloudBackupSuccess(int count) {
    return 'ক্লাউড ব্যাকআপ সম্পন্ন: $countটি রেকর্ড সিঙ্ক হয়েছে।';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'ব্যাকআপ ব্যর্থ: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'ক্লাউড থেকে পুনরুদ্ধার হয়েছে: $countটি রেকর্ড আমদানি হয়েছে।';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'পুনরুদ্ধার ব্যর্থ: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'ক্লাউড ব্যাকআপ বন্ধ হয়েছে। নতুন রেকর্ড কেবল এই ডিভাইসে থাকবে।';

  @override
  String get aiCloudToggleTitle => 'ক্লাউড ভিশন এআই (Gemini) বিশ্লেষণ';

  @override
  String get aiCloudOnDesc =>
      'চালু: স্পষ্ট ছবিগুলো ছোট করে নিরাপদ সংযোগে বিশ্লেষণ করা হয়। অফলাইনে ডিভাইস বিশ্লেষণ চলে।';

  @override
  String get aiCloudOffDesc =>
      'বন্ধ (০ টোকেন): সমস্ত বিশ্লেষণ কেবল আপনার ডিভাইসে হয়; কোনো ছবি পাঠানো হয় না।';

  @override
  String get aiBackendOfflineNote =>
      'Gemini / Firebase AI সংযুক্ত হলে এই অপশন অনুযায়ী ক্লাউড বিশ্লেষণ চালু হবে; বর্তমানে ডিভাইস ইঞ্জিন সক্রিয়।';

  @override
  String get aiOptimizationsTitle => 'সক্রিয় টোকেন ও ডেটা সাশ্রয় নিয়ন্ত্রণ';

  @override
  String get aiOptQualityGate => '০-টোকেন ঝাপসা, অন্ধকার ও ঝলক মান যাচাই';

  @override
  String get aiOptCompression => 'অটো-ক্রপ + 512px/768px JPEG (80%) কম্প্রেশন';

  @override
  String get aiOptTieredModel => 'স্মার্ট মডেল নির্বাচন (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'একই ছবির জন্য ডিভাইস ক্যাশে (০ টোকেন)';

  @override
  String get aiClearCacheBtn => 'এআই ক্যাশে মুছুন';

  @override
  String get aiCacheCleared => 'এআই ক্যাশে পরিষ্কার করা হয়েছে।';

  @override
  String resultScreenTitle(String category) {
    return '$category ফলাফল';
  }

  @override
  String get tooltipDoctorSummary => 'ডাক্তারের জন্য সারসংক্ষেপ';

  @override
  String get tooltipReferenceGuide => 'রেফারেন্স গাইড';

  @override
  String get calibratedColorTone => 'ক্যালিব্রেটেড রঙের টোন';

  @override
  String get sampledColorTone => 'প্রধান নমুনা রঙের টোন';

  @override
  String confidenceLabel(int percent) {
    return 'প্রাথমিক আস্থা: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote =>
      'সাদা রেফারেন্স দিয়ে রঙ ভারসাম্য করা হয়েছে।';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'পরামর্শযোগ্য বিভাগ: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'সময়ের সাথে পরিবর্তন';

  @override
  String get todayLabel => 'আজ';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'পূর্ববর্তী রেকর্ড: \"$title\" ($status)। মোট $countটি রেকর্ড সংরক্ষিত।';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'ব্যক্তিগত স্বাভাবিক মানের তুলনা';

  @override
  String get yourBaselineLabel => 'স্বাভাবিক';

  @override
  String get warningFlagsTitle => 'সতর্কতা লক্ষণ';

  @override
  String get observationsTitle => 'পর্যবেক্ষণ';

  @override
  String get recommendationsTitle => 'পরামর্শ';

  @override
  String get personalBaselineCardTitle => 'ব্যক্তিগত বেসলাইন ক্যালিব্রেশন';

  @override
  String get personalBaselineCardDesc =>
      'সুস্থ দিনে এই পরিমাপটিকে আপনার ব্যক্তিগত স্বাভাবিক মান হিসেবে সংরক্ষণ করুন।';

  @override
  String get saveBaselineBtn => 'ব্যক্তিগত মান হিসেবে সংরক্ষণ';

  @override
  String get updateBaselineBtn => 'ব্যক্তিগত মান আপডেট করুন';

  @override
  String get clearBaselineBtn => 'মুছুন';

  @override
  String baselineSavedMsg(String category) {
    return '$category-এর জন্য ব্যক্তিগত মান সংরক্ষিত।';
  }

  @override
  String baselineClearedMsg(String category) {
    return '$category-এর ব্যক্তিগত মান মুছে ফেলা হয়েছে।';
  }

  @override
  String get doctorSummaryBtn => 'ডাক্তারকে দেখান • সারসংক্ষেপ';

  @override
  String get returnHomeBtn => 'হোমে ফিরুন';

  @override
  String get doctorSheetTitle => 'ডাক্তারের সাক্ষাৎ সারসংক্ষেপ';

  @override
  String colorLabel(String hex, String status) {
    return 'রঙ: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'পূর্ববর্তী রেকর্ডের সময়রেখা';

  @override
  String get questionsForDoctorTitle => 'ডাক্তারকে জিজ্ঞেস করার প্রশ্ন';

  @override
  String get copyShareSummaryBtn => 'সারসংক্ষেপ কপি ও শেয়ার করুন';

  @override
  String get doctorSummaryCopied =>
      'ডাক্তারের সারসংক্ষেপ ক্লিপবোর্ডে কপি হয়েছে।';

  @override
  String referenceSheetTitle(String category) {
    return '$category — ভিজ্যুয়াল রেফারেন্স';
  }

  @override
  String get healthyReferenceLabel => 'স্বাস্থ্যকর রেফারেন্স';

  @override
  String get captureChecklistTitle => 'সঠিক ছবির টিপস';

  @override
  String get abnormalFindingsTitle => 'সতর্কতামূলক ও অস্বাভাবিক লক্ষণ';

  @override
  String get cameraPermPermanentMsg =>
      'ডিভাইস সেটিংস থেকে ক্যামেরা অনুমতি বন্ধ। সেটিংস থেকে চালু করুন বা গ্যালারি থেকে ছবি বাছুন।';

  @override
  String get cameraPermRequiredMsg =>
      'ভিজ্যুয়াল চেকের জন্য ক্যামেরা অনুমতি প্রয়োজন। ছবিগুলো ডিভাইসেই প্রক্রিয়াকরণ হয়।';

  @override
  String get cameraGrantPermTitle => 'ক্যামেরা অনুমতি প্রয়োজন';

  @override
  String get cameraRequestPermBtn => 'ক্যামেরা অনুমতি দিন';

  @override
  String get cameraPickGalleryBtn => 'গ্যালারি থেকে বাছুন';

  @override
  String get cameraWhiteRefOn => 'সাদা রেফারেন্স: চালু';

  @override
  String get cameraWhiteRefOff => 'সাদা রেফারেন্স: বন্ধ';

  @override
  String get cameraBaselineActive => 'ব্যক্তিগত মান সংরক্ষিত';

  @override
  String get cameraAnalyzing => 'বিশ্লেষণ চলছে...';

  @override
  String get cameraCaptureBtn => 'ছবি তুলুন ও বিশ্লেষণ করুন';

  @override
  String cameraAnalysisFailed(String error) {
    return 'বিশ্লেষণে ত্রুটি: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • রঙের কার্ড';
  }

  @override
  String get quickCardPrivacyBanner =>
      'ক্যামেরার প্রয়োজন নেই: ২ সেকেন্ডে গোপন ও দ্রুত রেকর্ডের জন্য কাছাকাছি রঙটি বাছুন।';

  @override
  String get quickCardChooseShade => 'নিকটতম রঙের টোন নির্বাচন করুন';

  @override
  String get quickCardExtraContext => 'অতিরিক্ত তথ্য (ঐচ্ছিক)';

  @override
  String get quickCardSaveViewBtn => 'সংরক্ষণ ও মূল্যায়ন দেখুন';

  @override
  String get quickCardUseCameraBtn => 'এর পরিবর্তে ক্যামেরা ব্যবহার করুন';

  @override
  String get skinIntroTitle => 'ভিজ্যুয়াল ডার্মাটোলজি প্রাথমিক পরীক্ষা';

  @override
  String get skinIntroDesc =>
      'তিল, আঁচিল, কালশিটে ও মুখের দাগ আশেপাশের ত্বকের সাথে তুলনা করে। এটি কোনো রোগ নির্ণয় নয়; চর্মরোগ বিশেষজ্ঞের প্রস্তুতিতে সহায়ক।';

  @override
  String get skinStep1Title => '১. ত্বকের প্রি-স্ক্রিনিং মডিউল নির্বাচন করুন';

  @override
  String get skinOtherConcernsLabel => 'অন্যান্য ত্বকের লক্ষণ';

  @override
  String get skinStep2Title => '২. সহগামী লক্ষণ (ঐচ্ছিক)';

  @override
  String get skinStep3Title => '৩. শরীরের অংশ (ঐচ্ছিক)';

  @override
  String get skinStartCameraBtn => 'ক্যামেরা দিয়ে ত্বক পরীক্ষা শুরু করুন';

  @override
  String get skinConcernRash => 'লালচে ভাব / ফুসকুড়ি';

  @override
  String get skinConcernMole => 'তিল / কালো দাগ';

  @override
  String get skinConcernScaly => 'খসখসে / শুষ্ক অংশ';

  @override
  String get skinConcernBlister => 'ফোস্কা / ব্রণ';

  @override
  String get skinConcernGeneral => 'সাধারণ ত্বক পরীক্ষা';

  @override
  String get bodyAreaFaceNeck => 'মুখ / ঘাড়';

  @override
  String get bodyAreaArmHand => 'হাত / বাহু';

  @override
  String get bodyAreaTorso => 'শরীরের মধ্যভাগ';

  @override
  String get bodyAreaLegFoot => 'পা';

  @override
  String get bodyAreaScalp => 'মাথার ত্বক';

  @override
  String get bodyAreaOther => 'অন্যান্য';

  @override
  String get symptomItching => 'চুলকানি';

  @override
  String get symptomPainWarmth => 'ব্যথা / গরম ভাব';

  @override
  String get symptomRapidChange => 'দ্রুত বৃদ্ধি / আকার পরিবর্তন';

  @override
  String get symptomBleeding => 'রক্তপাত / পুঁজ';

  @override
  String get symptomSpreading => 'দ্রুত ছড়াচ্ছে';

  @override
  String get symptomFever => 'জ্বর আছে';

  @override
  String get symptomNonHealing => '৪+ সপ্তাহে না শুকানো ঘা';

  @override
  String get symptomOver6mm => '৬ মিমি-এর বড় বা অসম কিনারা';

  @override
  String get symptomNoTrauma => 'আঘাত ছাড়াই নিজে থেকে হয়েছে';

  @override
  String get symptomRoughDots => 'খসখসে তল / ছোট কালো বিন্দু';

  @override
  String get symptomSunHormone => 'রোদ, হরমোন বা ব্রণের দাগ';

  @override
  String get bruiseGuideTitle => 'কালশিটে রঙের ধাপ নির্দেশিকা';

  @override
  String get wartGuideTitle => 'আঁচিল পূর্ব-পরীক্ষা ও নিরাপত্তা গাইড';

  @override
  String get abcdeGuideTitle => 'তিলের জন্য ABCDE গাইড';

  @override
  String get abcdeGuideSubtitle =>
      'চর্মরোগ বিশেষজ্ঞদের ব্যবহৃত ৫টি প্রধান লক্ষণ';

  @override
  String get labScreenTitle => 'ল্যাব ও হাসপাতাল রিপোর্ট';

  @override
  String get labTabReports => 'আমার রিপোর্ট';

  @override
  String get labTabTrends => 'পরিবর্তন ট্র্যাকিং';

  @override
  String get labAddBtn => 'রিপোর্ট / রক্তের পরীক্ষা যোগ করুন';

  @override
  String get labEmptyTitle => 'এখনো কোনো রক্তের পরীক্ষা সংরক্ষিত নেই';

  @override
  String get labEmptyDesc =>
      'PDF বা JPG রক্তের রিপোর্ট আপলোড করুন; সহজ ব্যাখ্যার জন্য ঐচ্ছিকভাবে ডাক্তারের নির্ণয় বা আপনার লক্ষণ যোগ করুন।';

  @override
  String get labAddFirstBtn => 'প্রথম রিপোর্ট যোগ করুন';

  @override
  String get labTrendsEmptyDesc =>
      'ভিন্ন তারিখে রক্তের পরীক্ষা সংরক্ষণ করলে হিমোগ্লোবিন, ফেরিটিন, গ্লুকোজ, টিএসএইচ ইত্যাদির গ্রাফ এখানে দেখা যাবে।';

  @override
  String labParamsCount(int count) {
    return '$countটি প্যারামিটার';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$countটি সীমার বাইরে';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'প্যারামিটার মূল্যায়ন ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'হাসপাতাল / ডাক্তারের নির্ণয়';

  @override
  String get labEnteredComplaintTitle => 'আপনার অভিযোগ / নোট';

  @override
  String get labInterpretationTitle => 'সহজ ভাষায় ব্যাখ্যা';

  @override
  String get labCopyDoctorSummaryBtn => 'ডাক্তারকে দেখান • সারসংক্ষেপ কপি';

  @override
  String get labSummaryCopied => 'রিপোর্ট সারসংক্ষেপ কপি হয়েছে।';

  @override
  String get labExportPdfBtn => 'ডাক্তার PDF রিপোর্ট তৈরি করুন';

  @override
  String get labAddSheetTitle => 'হাসপাতাল / রক্তের রিপোর্ট যোগ করুন';

  @override
  String get labReportTitleField => 'রিপোর্টের শিরোনাম';

  @override
  String get labDefaultReportTitle => 'রক্তের পরীক্ষার ফলাফল';

  @override
  String get labStep1Upload => '১. PDF বা JPG রিপোর্ট আপলোড করুন';

  @override
  String get labUploadPdfJpgBtn => 'PDF বা JPG আপলোড';

  @override
  String get labCameraCaptureBtn => 'ছবি তুলুন';

  @override
  String get labStep2Context => '২. হাসপাতালের নির্ণয় ও নোট (ঐচ্ছিক)';

  @override
  String get labStep2ContextHint =>
      'ডাক্তারের নির্ণয় বা আপনার লক্ষণ লিখুন; চাইলে দুটিই ফাঁকা রাখতে পারেন।';

  @override
  String get labDiagnosisField => 'হাসপাতাল / ডাক্তারের নির্ণয় (ঐচ্ছিক)';

  @override
  String get labComplaintField => 'আপনার লক্ষণ / প্রশ্ন (ঐচ্ছিক)';

  @override
  String get labStep3PasteManual =>
      '৩. রিপোর্ট টেক্সট পেস্ট করুন বা মান যোগ করুন';

  @override
  String get labParseTextBtn => 'টেক্সট পড়ুন ও বিশ্লেষণ করুন';

  @override
  String get labParamDropdown => 'পরীক্ষার প্যারামিটার';

  @override
  String labValueField(String unit) {
    return 'মান ($unit)';
  }

  @override
  String get labAddValueBtn => '+ যোগ';

  @override
  String labParsedValuesTitle(int count) {
    return 'পঠিত মান ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'মূল্যায়ন ও সংরক্ষণ করুন';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$countটি রেকর্ড • পরিবর্তন: $delta • সর্বশেষ: $status';
  }

  @override
  String get vitalsScreenTitle => 'রক্তচাপ ও শর্করা ট্র্যাকিং';

  @override
  String get vitalsCopySummaryTooltip => 'ডাক্তারের সারসংক্ষেপ কপি';

  @override
  String get vitalsCopyEmptyMsg =>
      'সারসংক্ষেপ তৈরি করতে আগে রক্তচাপ বা শর্করা যোগ করুন।';

  @override
  String get vitalsSummaryCopied => 'রক্তচাপ ও শর্করার সারসংক্ষেপ কপি হয়েছে।';

  @override
  String get vitalsAddBpBtn => 'রক্তচাপ যোগ করুন';

  @override
  String get vitalsAddSugarBtn => 'শর্করা যোগ করুন';

  @override
  String get vitalsBpEmptyTitle => 'এখনো কোনো রক্তচাপ পরিমাপ নেই';

  @override
  String get vitalsBpEmptyDesc =>
      'ট্রেন্ড গ্রাফ দেখতে তারিখসহ রক্তচাপ ও পালস সংরক্ষণ করুন।';

  @override
  String get vitalsBpAddFirstBtn => 'প্রথম রক্তচাপ যোগ করুন';

  @override
  String get vitalsSugarEmptyTitle => 'এখনো কোনো রক্তের শর্করা পরিমাপ নেই';

  @override
  String get vitalsSugarEmptyDesc =>
      'ট্রেন্ড দেখতে খালি পেটে, খাওয়ার পর বা যেকোনো সময়ের শর্করা সংরক্ষণ করুন।';

  @override
  String get vitalsSugarAddFirstBtn => 'প্রথম শর্করা যোগ করুন';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'গড় ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • পালস $pulse';
  }

  @override
  String get vitalsBpHistoryTitle => 'তারিখসহ রক্তচাপের রেকর্ড';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'গড় ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'তারিখসহ শর্করার রেকর্ড';

  @override
  String get vitalsNewBpTitle => 'নতুন রক্তচাপ পরিমাপ';

  @override
  String get vitalsSystolicField => 'সিস্টোলিক (উপরের)';

  @override
  String get vitalsDiastolicField => 'ডায়াস্টোলিক (নিচের)';

  @override
  String get vitalsPulseField => 'পালস (ঐচ্ছিক)';

  @override
  String get vitalsNoteField => 'নোট (ঐচ্ছিক)';

  @override
  String get vitalsSaveBpBtn => 'রক্তচাপ সংরক্ষণ';

  @override
  String get vitalsNewSugarTitle => 'নতুন শর্করা পরিমাপ';

  @override
  String get vitalsSugarValueField => 'রক্তের শর্করা (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'শর্করা সংরক্ষণ';

  @override
  String get chartAddReadingHint => 'চার্ট দেখতে পরিমাপ যোগ করুন';

  @override
  String get loginTermsTitle => 'ব্যবহারের শর্তাবলী ও চিকিৎসা সতর্কতা';

  @override
  String get loginTermsCheckbox =>
      'আমি বুঝি যে VisualCheckUp কোনো চূড়ান্ত চিকিৎসা নির্ণয় দেয় না, এটি কেবল প্রাথমিক সচেতনতার জন্য, এবং আমি শর্তাবলীতে সম্মত।';

  @override
  String get loginTermsRequiredMsg =>
      'সাইন ইন করার আগে অনুগ্রহ করে ব্যবহারের শর্তাবলী ও চিকিৎসা সতর্কতা অনুমোদন করুন।';

  @override
  String get loginTermsReadMore => 'শর্তাবলী পড়ুন';

  @override
  String get loginTermsModalBody =>
      '• চিকিৎসা নির্ণয় নয়: VisualCheckUp কোনো মেডিকেল ডিভাইস নয় এবং চিকিৎসকের পরামর্শ বা চিকিৎসার বিকল্প নয়।\n\n• কেবল প্রাথমিক তথ্য: ভিজ্যুয়াল চেক, ল্যাব রিপোর্ট সারাংশ ও বিএমআই/বৃদ্ধি স্কেল কেবল ব্যক্তিগত পর্যবেক্ষণ ও ডাক্তার দেখানোর প্রস্তুতির জন্য।\n\n• জরুরি সতর্কতা: তীব্র বুকে ব্যথা, শ্বাসকষ্ট বা জরুরি উপসর্গ থাকলে অবিলম্বে জরুরি চিকিৎসা নিন।\n\n• গোপনীয়তা: আপনার স্বাস্থ্য তথ্য ডিফল্টভাবে কেবল আপনার ডিভাইসেই সংরক্ষিত থাকে।';

  @override
  String get loginTermsAcceptBtn => 'পড়েছি এবং সম্মত';

  @override
  String atlasFilterAll(int count) {
    return 'চিত্রিত অ্যাটলাস ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'জরুরি লক্ষণ ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'ঘরোয়া ক্লিনিক্যাল পরীক্ষা ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'দ্রুত চিকিৎসকের মূল্যায়ন প্রয়োজন এমন লক্ষণ';

  @override
  String get atlasTapToCompareHint =>
      'সুস্থ রেফারেন্সের সাথে পাশাপাশি বড় করে দেখতে যেকোনো কার্ডে ট্যাপ করুন।';

  @override
  String get atlasVisualCueLabel => 'দৃশ্যমান সংকেত';

  @override
  String get atlasClinicalContextLabel => 'সম্ভাব্য ক্লিনিক্যাল প্রেক্ষাপট';

  @override
  String get atlasPossibleContextShort => 'সম্ভাব্য প্রেক্ষাপট';

  @override
  String get atlasWarningPrefix => 'সতর্কতা';

  @override
  String get atlasCloseBtn => 'বন্ধ করুন';

  @override
  String get atlasCaptureProtocolTitle => 'সঠিক ছবি তোলার নিয়ম';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'বাড়িতে করা যায় এমন প্রাথমিক ক্লিনিক্যাল পরীক্ষা';

  @override
  String get atlasSelfTestNormalPrefix => 'স্বাভাবিক';

  @override
  String get atlasSelfTestWarningPrefix => 'মনোযোগ দিন';

  @override
  String get fitzpatrickScaleTitle =>
      'ফিটজপ্যাট্রিক ত্বকের ধরন ও ITA° ক্যালিব্রেশন স্কেল';

  @override
  String get fitzpatrickScaleSubtitle =>
      'অ্যাপটি আশেপাশের সুস্থ ত্বকের ITA° কোণ পরিমাপ করে আপনার ত্বকের ধরন অনুযায়ী বিশ্লেষণের সীমা সামঞ্জস্য করে।';

  @override
  String get resultVisualCompareTitle => 'চিত্রিত ক্লিনিক্যাল রেফারেন্স তুলনা';

  @override
  String get resultHealthyShort => 'সুস্থ';

  @override
  String get resultMatchedShort => 'মিলেছে';

  @override
  String get resultViewFullAtlasBtn => 'সম্পূর্ণ চিত্রিত অ্যাটলাস দেখুন';

  @override
  String get resultHomeSelfTestsBtn => 'ঘরোয়া ক্লিনিক্যাল পরীক্ষা';

  @override
  String get resultClinicalBiomarkersTitle => 'পরিমাণগত ক্লিনিক্যাল পরিমাপ';

  @override
  String get cameraEyeModeSclera => 'মোড: স্ক্লেরা (জন্ডিস)';

  @override
  String get cameraEyeModeConjunctiva => 'নিচের চোখের পাতা (রক্তস্বল্পতা)';

  @override
  String get cameraClinicalAtlasChip => 'ক্লিনিক্যাল পরীক্ষা ও অ্যাটলাস';

  @override
  String get bristolScaleTitle =>
      'ব্রিস্টল মলের ঘনত্ব স্কেল (ঐচ্ছিক • ধরন ১–৭)';

  @override
  String get bristolType1Title => 'ধরন ১ • শক্ত দলা';

  @override
  String get bristolType2Title => 'ধরন ২ • দলাযুক্ত লম্বাটে';

  @override
  String get bristolType3Title => 'ধরন ৩ • ফাটলযুক্ত লম্বাটে';

  @override
  String get bristolType4Title => 'ধরন ৪ • মসৃণ (আদর্শ)';

  @override
  String get bristolType5Title => 'ধরন ৫ • নরম টুকরো';

  @override
  String get bristolType6Title => 'ধরন ৬ • নরম / আলগা';

  @override
  String get bristolType7Title => 'ধরন ৭ • সম্পূর্ণ তরল';

  @override
  String get metricFitzpatrickPhototype => 'ফিটজপ্যাট্রিক ফটোটাইপ';

  @override
  String get metricAbcdeAsymmetry => 'A — অসামঞ্জস্যতা';

  @override
  String get metricAbcdeBorder => 'B — প্রান্তের অনিয়ম';

  @override
  String get metricAbcdeColors => 'C — ডার্মোস্কোপিক রঙ';

  @override
  String get metricErythemaDelta => 'এরিথেমা সূচক Δ';

  @override
  String get metricAnnularClearing => 'বলয়াকার কেন্দ্র পরিষ্কারতা';

  @override
  String get metricErythemaIndex => 'এরিথেমা সূচক (EI)';

  @override
  String get metricScleraBilirubin => 'স্ক্লেরাল বিলিরুবিন সূচক';

  @override
  String get metricHemorrhagePatch => 'ঘন রক্তক্ষরণ এলাকা';

  @override
  String get metricNailErythema => 'নখের তলার এরিথেমা সূচক';

  @override
  String get metricBeauGroove => 'বো আড়াআড়ি খাঁজ';

  @override
  String get metricTerryLindsaySplit => 'প্রক্সিমাল/ডিস্টাল বিভাজন';

  @override
  String get metricSplinterStreak => 'স্প্লিন্টার রেখার অনুপাত';

  @override
  String get metricGeographicTongue => 'জিওগ্রাফিক জিহ্বা স্কোর';

  @override
  String get metricYellowCoating => 'হলুদ প্রলেপের অনুপাত';

  @override
  String get metricBristolScale => 'ব্রিস্টল স্কেল';

  @override
  String get hubStartNewScan => 'নতুন স্ক্যান শুরু করুন';

  @override
  String get hubPickFromGallery => 'গ্যালারি';

  @override
  String hubPastScansTitle(int count) {
    return 'পূর্ববর্তী স্ক্যানসমূহ ($count)';
  }

  @override
  String get hubTotalScansLabel => 'মোট স্ক্যান';

  @override
  String get hubLastScanLabel => 'শেষ স্ক্যান';

  @override
  String get hubLatestStatusLabel => 'সর্বশেষ অবস্থা';

  @override
  String get hubFilterAll => 'সব';

  @override
  String get hubFilterAttention => 'সতর্কতা / জরুরি';

  @override
  String get hubFilterWithPhoto => 'ছবিসহ';

  @override
  String get hubColPhoto => 'ছবি';

  @override
  String get hubColDate => 'তারিখ';

  @override
  String get hubColFinding => 'ফলাফল ও সারসংক্ষেপ';

  @override
  String get hubColStatus => 'অবস্থা';

  @override
  String get hubCompareModeBtn => '২টি স্ক্যান তুলনা করুন';

  @override
  String hubCompareSelectHint(int count) {
    return 'পাশাপাশি তুলনা করতে তালিকা থেকে ২টি স্ক্যান নির্বাচন করুন ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'পাশাপাশি তুলনা করুন';

  @override
  String get hubCompareCancelBtn => 'বাতিল';

  @override
  String get hubCompareSheetTitle => 'পাশাপাশি স্ক্যান তুলনা';

  @override
  String get hubCompareOlderLabel => 'পূর্বের';

  @override
  String get hubCompareNewerLabel => 'পরবর্তী';

  @override
  String get hubCompareMetricsTitle => 'ক্লিনিক্যাল পরিমাপ তুলনা';

  @override
  String hubEmptyTitle(String category) {
    return 'এখনো কোনো $category স্ক্যান নেই';
  }

  @override
  String get hubEmptySubtitle =>
      'উপর থেকে প্রথম স্ক্যান শুরু করুন। প্রতিটি পরীক্ষা ছোট ছবি ও বিস্তারিত রিপোর্টসহ এখানে তারিখ অনুযায়ী সংরক্ষিত থাকবে।';

  @override
  String get hubDoctorSummaryBtn => 'ডাক্তারের সারসংক্ষেপ';

  @override
  String get photoTapToZoomHint => 'পূর্ণ স্ক্রিনে বড় করতে ছবিতে ট্যাপ করুন';

  @override
  String get photoZoomTitle => 'তোলা ছবি';

  @override
  String get resultDeleteRecordTooltip => 'রেকর্ড মুছুন';

  @override
  String get resultDeleteConfirmTitle => 'এই স্ক্যানটি মুছবেন?';

  @override
  String get resultDeleteConfirmBody =>
      'এই পরীক্ষার রেকর্ডটি আপনার স্থানীয় ইতিহাস থেকে স্থায়ীভাবে মুছে ফেলা হবে।';

  @override
  String get resultDeleteBtn => 'মুছুন';

  @override
  String get labLargeTextBtn => 'বড় লেখা';

  @override
  String get labLargeTextOnBtn => 'বড় লেখা: চালু';

  @override
  String get labSeniorOverviewTitle => 'এক নজরে আপনার সারসংক্ষেপ';

  @override
  String labSeniorNormalBullet(int count) {
    return '$countটি পরীক্ষার মান স্বাভাবিক সীমার মধ্যে আছে।';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$countটি মান স্বাভাবিক সীমার বাইরে — নিচে সহজ ভাষায় ব্যাখ্যা করা হয়েছে।';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$countটি মান উল্লেখযোগ্যভাবে সীমার বাইরে — অনুগ্রহ করে দ্রুত ডাক্তারকে দেখান।';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$countটি সাধারণ মৌলিক পরীক্ষা এই রিপোর্টে অন্তর্ভুক্ত নেই।';
  }

  @override
  String get labAttentionSectionTitle => 'যে মানগুলোতে মনোযোগ দেওয়া প্রয়োজন';

  @override
  String get labNormalSectionTitle => 'স্বাভাবিক মানসমূহ (নিশ্চিন্ত থাকুন)';

  @override
  String get labMissingSectionTitle => 'এই রিপোর্টে না থাকা মৌলিক পরীক্ষা';

  @override
  String get labMissingSectionExplain =>
      'সব রক্ত পরীক্ষায় সব টেস্ট করা হয় না। নিচের সাধারণ পরীক্ষাগুলো এই রিপোর্টে না থাকায় মূল্যায়ন করা হয়নি।';

  @override
  String get labNotInReportBadge => 'রিপোর্টে নেই';

  @override
  String get labWhatItMeansLabel => 'এর অর্থ কী?';

  @override
  String get labWhatToDoLabel => 'আপনার করণীয় কী?';

  @override
  String get labAddAnotherPageBtn => 'আরেকটি পাতার ছবি তুলুন';

  @override
  String labPagesReadBadge(int count) {
    return '$count পাতা পড়া হয়েছে';
  }

  @override
  String get labPhotoOfflineHint =>
      'রিপোর্টের ছবি যুক্ত হয়েছে। কাগজের ছবি স্বয়ংক্রিয়ভাবে পড়তে সেটিংস থেকে ক্লাউড এআই চালু করুন অথবা নিচে হাতে মান লিখুন।';

  @override
  String get labAllValuesNormalMsg =>
      'এই রিপোর্টের সব মান স্বাভাবিক সীমার মধ্যে রয়েছে।';

  @override
  String get medTitle => 'ওষুধ ও অ্যালার্ম রিমাইন্ডার';

  @override
  String get medSubtitle =>
      'ছবিসহ ওষুধ, ইনসুলিন ও চেকআপ অ্যালার্ম ট্র্যাক করুন';

  @override
  String get medMenuTitle => 'ওষুধের অ্যালার্ম';

  @override
  String get medHomeCardEmpty =>
      'কোনো অ্যালার্ম নেই — প্রথম রিমাইন্ডার যোগ করুন';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return 'আজ $taken/$total নেওয়া হয়েছে';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$countটি সক্রিয় অ্যালার্ম';
  }

  @override
  String get medTabToday => 'আজ';

  @override
  String get medTabAll => 'সব অ্যালার্ম';

  @override
  String get medAddAlarm => 'নতুন অ্যালার্ম যোগ করুন';

  @override
  String get medEditAlarm => 'অ্যালার্ম সম্পাদনা';

  @override
  String get medCatPill => 'ওষুধ / ট্যাবলেট';

  @override
  String get medCatDiabetes => 'ডায়াবেটিস / ইনসুলিন';

  @override
  String get medCatBloodPressure => 'রক্তচাপের ওষুধ';

  @override
  String get medCatVitamin => 'ভিটামিন / সাপ্লিমেন্ট';

  @override
  String get medCatDropsCream => 'চোখের ড্রপ / ক্রিম';

  @override
  String get medCatCheckup => 'পরিমাপ / চেকআপ';

  @override
  String get medCatOther => 'অন্যান্য';

  @override
  String get medMealAnytime => 'যেকোনো সময়';

  @override
  String get medMealBefore => 'খাবার আগে';

  @override
  String get medMealAfter => 'খাবার পরে';

  @override
  String get medMealWith => 'খাবারের সাথে';

  @override
  String get medMealBedtime => 'ঘুমানোর আগে';

  @override
  String get medDayMon => 'সোম';

  @override
  String get medDayTue => 'মঙ্গল';

  @override
  String get medDayWed => 'বুধ';

  @override
  String get medDayThu => 'বৃহ';

  @override
  String get medDayFri => 'শুক্র';

  @override
  String get medDaySat => 'শনি';

  @override
  String get medDaySun => 'রবি';

  @override
  String get medEveryDay => 'প্রতিদিন';

  @override
  String get medWeekdays => 'কর্মদিবস';

  @override
  String get medWeekends => 'সপ্তাহান্ত';

  @override
  String get medFieldCategory => 'বিভাগ';

  @override
  String get medFieldName => 'ওষুধ / রিমাইন্ডারের নাম';

  @override
  String get medFieldNameHint => 'যেমন: মেটফরমিন ১০০০, রাতের ইনসুলিন...';

  @override
  String get medFieldNameRequired =>
      'অনুগ্রহ করে ওষুধ বা রিমাইন্ডারের নাম লিখুন।';

  @override
  String get medFieldDosage => 'মাত্রা / পরিমাণ (ঐচ্ছিক)';

  @override
  String get medFieldDosageHint => 'যেমন: ১টি ট্যাবলেট, ১২ ইউনিট, ২ ফোঁটা';

  @override
  String get medFieldDescription => 'রিমাইন্ডার নোট (অ্যালার্মে দেখাবে)';

  @override
  String get medFieldDescriptionHint =>
      'যেমন: নাস্তার ৩০ মিনিট আগে ১ গ্লাস পানিসহ খান';

  @override
  String get medFieldMealTiming => 'খাওয়ার সময়';

  @override
  String get medFieldTime => 'অ্যালার্মের সময়';

  @override
  String get medFieldDays => 'পুনরাবৃত্তির দিন';

  @override
  String get medFieldPhoto => 'ওষুধের ছবি (অ্যালার্ম বাজলে দেখাবে)';

  @override
  String get medTakePhoto => 'ছবি তুলুন';

  @override
  String get medPickGallery => 'গ্যালারি থেকে';

  @override
  String get medRemovePhoto => 'ছবি সরান';

  @override
  String get medPhotoHint =>
      'ওষুধের বাক্স বা ইনসুলিন পেনের ছবি তুললে অ্যালার্মের সময় স্ক্রিনে বড় করে দেখাবে।';

  @override
  String get medSoundToggle => 'অ্যালার্ম শব্দ';

  @override
  String get medVibrateToggle => 'কম্পন';

  @override
  String get medSaveAlarm => 'অ্যালার্ম সংরক্ষণ করুন';

  @override
  String get medAlarmSaved => 'অ্যালার্ম সংরক্ষিত ও নির্ধারিত হয়েছে।';

  @override
  String get medAlarmDeleted => 'অ্যালার্ম মুছে ফেলা হয়েছে।';

  @override
  String get medDeleteConfirmTitle => 'অ্যালার্ম মুছুন';

  @override
  String medDeleteConfirmBody(String title) {
    return '\"$title\" অ্যালার্মটি কি স্থায়ীভাবে মুছে ফেলবেন?';
  }

  @override
  String get medStatusTaken => 'নেওয়া হয়েছে';

  @override
  String get medStatusSnoozed => 'স্থগিত';

  @override
  String get medStatusSkipped => 'বাদ দেওয়া হয়েছে';

  @override
  String get medStatusPending => 'অপেক্ষমাণ';

  @override
  String get medActionTaken => 'খেয়েছি / নিয়েছি';

  @override
  String get medActionSnooze => '১০ মি. পর';

  @override
  String get medActionSkip => 'আজ বাদ দিন';

  @override
  String get medActionUndo => 'পূর্বাবস্থায়';

  @override
  String get medActionPreviewAlarm => 'অ্যালার্ম পরীক্ষা';

  @override
  String get medRingHeader => 'ওষুধের সময়';

  @override
  String get medRingNoteTitle => 'রিমাইন্ডার নোট';

  @override
  String get medRingNoPhoto => 'ওষুধের ছবি যোগ করা হয়নি';

  @override
  String get medRingTapZoom => 'বড় করতে ছবিতে ট্যাপ করুন';

  @override
  String get medRingSnoozedToast => '১০ মিনিটের জন্য স্থগিত করা হয়েছে।';

  @override
  String get medRingTakenToast => 'দারুণ! আজকের ডোজ নেওয়া হিসেবে সংরক্ষিত।';

  @override
  String get medTodayProgressTitle => 'আজকের ওষুধের তালিকা';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'পরবর্তী অ্যালার্ম: $time • $title';
  }

  @override
  String get medNoTodayAlarms =>
      'আজকের জন্য কোনো ওষুধের অ্যালার্ম নির্ধারিত নেই।';

  @override
  String get medEmptyTitle => 'এখনও কোনো ওষুধের অ্যালার্ম নেই';

  @override
  String get medEmptyBody =>
      'ডায়াবেটিস, ইনসুলিন বা রক্তচাপের ওষুধের জন্য ছবিসহ অ্যালার্ম যোগ করুন। সময় হলে ওষুধের ছবি ও আপনার নোট স্ক্রিনে স্পষ্ট দেখাবে।';

  @override
  String get medQuickPresetDiabetes => 'ডায়াবেটিস / ইনসুলিন';

  @override
  String get medQuickPresetBp => 'রক্তচাপের ওষুধ';

  @override
  String get medQuickPresetVitamin => 'ভিটামিন';

  @override
  String get dietMenuTitle => 'ডায়েট ও AI ক্যালোরি ট্র্যাকার';

  @override
  String get dietHomeCardTitle => 'ডায়েট ও খাবার তালিকা';

  @override
  String get dietHomeCardEmpty => 'রেডি ডায়েট, অনুসরণ ও ওজন ট্র্যাকিং';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'দিন $day/$total • $percent% অনুসরণ';
  }

  @override
  String get dietCalorieQuickTitle => 'AI প্লেট ক্যালোরি হিসাব';

  @override
  String get dietCalorieQuickSubtitle =>
      'প্লেটের ছবি তুলে ক্যালোরি ও পুষ্টিগুণ জানুন';

  @override
  String get dietTabActive => 'আমার ডায়েট';

  @override
  String get dietTabTemplates => 'রেডি ডায়েট';

  @override
  String get dietTabWeight => 'ওজন';

  @override
  String get dietTabCalories => 'AI ক্যালোরি';

  @override
  String get dietStartDiet => 'ডায়েট শুরু করুন';

  @override
  String get dietRestartOrChange => 'ডায়েট পরিবর্তন';

  @override
  String get dietEndDiet => 'ডায়েট শেষ করুন';

  @override
  String get dietEndDietConfirm =>
      'চলমান ডায়েট প্ল্যান শেষ করবেন? আপনার অনুসরণ ও ওজনের রেকর্ড সংরক্ষিত থাকবে।';

  @override
  String get dietNoActiveTitle => 'এখনও কোনো সক্রিয় ডায়েট নেই';

  @override
  String get dietNoActiveBody =>
      'প্রস্তুতকৃত ডায়েট টেমপ্লেট থেকে বেছে নিন এবং প্রতিদিন মেনে চলা ও ওজন পরিবর্তন ট্র্যাক করুন।';

  @override
  String get dietBrowseTemplates => 'রেডি ডায়েট দেখুন';

  @override
  String get dietStartDate => 'শুরুর তারিখ';

  @override
  String get dietEndDate => 'শেষের তারিখ';

  @override
  String get dietStartWeight => 'শুরুর ওজন (কেজি)';

  @override
  String get dietTargetWeight => 'লক্ষ্য ওজন (কেজি)';

  @override
  String get dietDailyCalorieTarget => 'দৈনিক ক্যালোরি লক্ষ্য (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days দিন';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'দিন $day / $total';
  }

  @override
  String dietDaysLeft(int days) {
    return '$days দিন বাকি';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'অনুসরণ: $percent%';
  }

  @override
  String get dietFollowed => 'মেনেছি';

  @override
  String get dietNotFollowed => 'মানিনি';

  @override
  String get dietPending => 'অপেক্ষমাণ';

  @override
  String get dietSlotBreakfast => 'সকালের নাশতা';

  @override
  String get dietSlotMorningSnack => 'সকালের হালকা খাবার';

  @override
  String get dietSlotLunch => 'দুপুরের খাবার';

  @override
  String get dietSlotAfternoonSnack => 'বিকালের নাশতা';

  @override
  String get dietSlotDinner => 'রাতের খাবার';

  @override
  String get dietAlternativesLabel => 'বিকল্প';

  @override
  String dietWaterTarget(String liters) {
    return 'পানির লক্ষ্য: $liters লি.';
  }

  @override
  String get dietRulesTitle => 'ডায়েটের নিয়মাবলি';

  @override
  String get dietSampleMenuTitle => 'নমুনা দৈনিক মেনু';

  @override
  String get dietStartedToast => 'ডায়েট প্ল্যান শুরু হয়েছে!';

  @override
  String get dietEndedToast => 'চলমান ডায়েট শেষ হয়েছে।';

  @override
  String get dietWeightLogTitle => 'ডায়েট ওজন ট্র্যাকিং';

  @override
  String get dietWeightAdd => 'ওজন যোগ করুন';

  @override
  String get dietWeightField => 'বর্তমান ওজন (কেজি)';

  @override
  String get dietWeightNote => 'নোট (ঐচ্ছিক)';

  @override
  String get dietWeightNoteHint => 'যেমন: সকালে খালি পেটে ওজন';

  @override
  String get dietWeightEmpty => 'এখনও ওজনের রেকর্ড নেই। প্রথম ওজন যোগ করুন।';

  @override
  String get dietWeightCurrent => 'বর্তমান';

  @override
  String get dietWeightTarget => 'লক্ষ্য';

  @override
  String get dietWeightChange => 'পরিবর্তন';

  @override
  String get dietWeightSaved => 'ওজন সংরক্ষিত হয়েছে।';

  @override
  String get dietCalorieTitle => 'AI প্লেট ক্যালোরি ক্যালকুলেটর';

  @override
  String get dietCalorieSubtitle =>
      'ডায়েট ছাড়াও ব্যবহার করুন — খাবারের প্লেটের ছবি তুলুন বা নাম লিখুন।';

  @override
  String get dietSnapPlateCamera => 'প্লেটের ছবি তুলুন';

  @override
  String get dietPickPlateGallery => 'গ্যালারি থেকে';

  @override
  String get dietFoodDescLabel => 'খাবারের বিবরণ / পরিমাণ (ঐচ্ছিক)';

  @override
  String get dietFoodDescHint => 'যেমন: গ্রিল্ড চিকেন, ভাত, সালাদ, দই';

  @override
  String get dietCalculateFromText => 'লেখা থেকে হিসাব';

  @override
  String get dietAnalyzingPlate => 'ক্যালোরি ও পুষ্টিগুণ বিশ্লেষণ হচ্ছে...';

  @override
  String get dietResultTitle => 'ক্যালোরি ও পুষ্টি বিশ্লেষণ';

  @override
  String get dietAiPoweredBadge => 'Gemini AI ভিশন';

  @override
  String get dietOnDeviceBadge => 'স্মার্ট ডিভাইস অনুমান';

  @override
  String get dietProtein => 'প্রোটিন';

  @override
  String get dietCarbs => 'কার্বস';

  @override
  String get dietFat => 'চর্বি';

  @override
  String get dietFiber => 'ফাইবার';

  @override
  String get dietPortionScale => 'পরিমাণ';

  @override
  String get dietSaveMealLog => 'আজকের লগে সংরক্ষণ';

  @override
  String get dietMealLoggedToast => 'খাবারের ক্যালোরি আজকের লগে যোগ হয়েছে।';

  @override
  String get dietTodayTotalCalories => 'আজকের মোট';

  @override
  String get dietRecentScans => 'হিসাব করা খাবার';

  @override
  String get dietNoScansYet => 'এখনও কোনো খাবার স্ক্যান করা হয়নি।';

  @override
  String dietHealthScore(int score) {
    return 'ব্যালেন্স স্কোর: $score/10';
  }

  @override
  String get dietTodayLabel => 'আজ';

  @override
  String get medCatHerbalTea => 'হার্বাল চা';

  @override
  String get medCatCustom => 'অন্যান্য (নিজে লিখুন)';

  @override
  String get medFieldCustomCategory => 'নিজস্ব বিভাগের নাম';

  @override
  String get medFieldCustomCategoryHint =>
      'যেমন: প্রোবায়োটিক, পানি পান, ব্যায়াম...';

  @override
  String get medQuickPresetHerbalTea => 'হার্বাল চা';

  @override
  String get dietCreateCustom => 'নিজের ডায়েট তৈরি করুন';

  @override
  String get dietCreateCustomSubtitle =>
      'ডায়েটিশিয়ানের তালিকা বা নিজের খাবার পরিকল্পনা লিখুন';

  @override
  String get dietCustomNameLabel => 'ডায়েটের নাম';

  @override
  String get dietCustomNameHint => 'যেমন: আমার ডায়েট তালিকা, নিজস্ব মেনু...';

  @override
  String get dietCustomNameRequired => 'অনুগ্রহ করে ডায়েটের নাম লিখুন।';

  @override
  String get dietCustomMealHint => 'এই বেলায় কী খাবেন?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (ঐচ্ছিক)';

  @override
  String get dietCustomAtLeastOneMeal => 'অনুগ্রহ করে অন্তত একটি খাবার লিখুন।';

  @override
  String get dietCustomTemplatesTitle => 'আমার নিজস্ব ডায়েট প্ল্যান';

  @override
  String get dietReadyTemplatesTitle => 'রেডি ডায়েট টেমপ্লেট';

  @override
  String get donateTooltip => 'সহায়তা ও ডোনেশন';

  @override
  String get donateMenuLabel => 'VisualCheckUp-কে সহায়তা করুন';

  @override
  String get donateMenuSubtitle =>
      'কফি, খাবার বা উপহার দিয়ে বিনামূল্যের স্বাস্থ্যসেবায় সহায়তা করুন';

  @override
  String get donatePopupTitle => 'VisualCheckUp-কে সহায়তা করুন';

  @override
  String get donatePopupSubtitle =>
      'আপনার স্বেচ্ছামূলক সহায়তা আমাদের স্বাস্থ্য পরীক্ষা, ল্যাব রিপোর্ট, ওষুধ অ্যালার্ম ও ডায়েট ফিচার উন্নত রাখতে সাহায্য করে।';

  @override
  String get donateTierCoffeeTitle => 'এক কাপ কফি';

  @override
  String get donateTierCoffeeDesc => 'ডেভেলপমেন্টের জন্য উষ্ণ কফি';

  @override
  String get donateTierMealTitle => 'এক বেলা খাবার';

  @override
  String get donateTierMealDesc => 'নতুন স্বাস্থ্য ফিচারের জন্য চমৎকার সহায়তা';

  @override
  String get donateTierGiftTitle => 'উপহার পাঠান';

  @override
  String get donateTierGiftDesc => 'AI ও সার্ভার খরচে সহায়তা করে';

  @override
  String get donateTierGoldTitle => 'বড় সহায়তা';

  @override
  String get donateTierGoldDesc => 'আগামী মেডিকেল মডিউল তৈরিতে শক্তি জোগায়';

  @override
  String get donateTierHeroTitle => 'হেলথ হিরো';

  @override
  String get donateTierHeroDesc =>
      'সব পরিবারের বিনামূল্যের স্বাস্থ্য ট্র্যাকিংয়ে অবদান';

  @override
  String get donatePopularBadge => 'জনপ্রিয়';

  @override
  String donateConfirmButton(String price) {
    return '$price সহায়তা করুন';
  }

  @override
  String get donateLaterButton => 'পরে';

  @override
  String get donateThanksTitle => 'আপনার সহায়তার জন্য ধন্যবাদ!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'আপনার $tier ($price) সহায়তা আমাদের জন্য অনেক মূল্যবান!';
  }

  @override
  String get donateSupporterBadge => 'সহায়তাকারী • ধন্যবাদ!';

  @override
  String get donateStoreNotice =>
      'এককালীন স্বেচ্ছামূলক সহায়তা • কোনো সাবস্ক্রিপশন নয়';

  @override
  String get medFieldAlarmSound => 'অ্যালার্মের সুর';

  @override
  String get medAlarmSoundClassic => 'ক্লাসিক অ্যালার্ম';

  @override
  String get medAlarmSoundClassicDesc => 'স্পষ্ট অ্যালার্ম ঘড়ির শব্দ';

  @override
  String get medAlarmSoundGentle => 'মৃদু সুর';

  @override
  String get medAlarmSoundGentleDesc => 'শান্ত ও কোমল বেল সুর';

  @override
  String get medAlarmSoundRadar => 'আধুনিক অ্যালার্ম';

  @override
  String get medAlarmSoundRadarDesc => 'স্পষ্ট ছন্দময় অ্যালার্ম টোন';

  @override
  String get medAlarmSoundBell => 'স্বাস্থ্য ঘণ্টা';

  @override
  String get medAlarmSoundBellDesc => 'উজ্জ্বল ক্লাসিক ডাবল বেল রিং';

  @override
  String get medAlarmSoundUrgent => 'জরুরি উচ্চ সতর্কতা';

  @override
  String get medAlarmSoundUrgentDesc => 'গুরুত্বপূর্ণ ডোজের জন্য জোরালো শব্দ';

  @override
  String get medAlarmSoundSystem => 'ফোনের অ্যালার্ম সুর';

  @override
  String get medAlarmSoundSystemDesc =>
      'ফোনের ডিফল্ট অ্যালার্ম রিংটোন ব্যবহার করে';

  @override
  String get medSoundPreviewPlay => 'শুনুন';

  @override
  String get medSoundPreviewStop => 'থামান';

  @override
  String get medSoundSilent => 'নীরব';

  @override
  String get medPreviewModeBadge => 'প্রিভিউ';

  @override
  String get commMenuTitle => 'স্বাস্থ্য কমিউনিটি';

  @override
  String get commHomeSubtitle =>
      'বিশ্বব্যাপী স্বাস্থ্য সঙ্গী, প্রোফাইল লাইক ও নিরাপদ মেসেজিং';

  @override
  String get commTabDiscover => 'খুঁজুন';

  @override
  String get commTabMessages => 'মেসেজ';

  @override
  String get commTabMyProfile => 'আমার প্রোফাইল';

  @override
  String get commSafetyBanner =>
      'শুধুমাত্র অভিজ্ঞতা ও অনুপ্রেরণার জন্য — চিকিৎসা পরামর্শ নয়। আপনার ল্যাব রিপোর্ট ও ছবি কখনোই শেয়ার হয় না।';

  @override
  String get commSearchHint => 'নাম, শহর বা স্বাস্থ্য লক্ষ্য খুঁজুন...';

  @override
  String get commFilterAllGoals => 'সব লক্ষ্য';

  @override
  String get commFilterAllCountries => 'বিশ্বব্যাপী';

  @override
  String get commEmptyDiscover =>
      'আপনার ফিল্টারের সাথে কোনো স্বাস্থ্য প্রোফাইল মেলেনি।';

  @override
  String get commGoalDiabetes => 'ডায়াবেটিস ও রক্তে শর্করা';

  @override
  String get commGoalBloodPressure => 'রক্তচাপ ও হৃদরোগ';

  @override
  String get commGoalWeightDiet => 'ওজন ও স্বাস্থ্যকর ডায়েট';

  @override
  String get commGoalHealthyLiving => 'সুস্থ জীবনযাপন';

  @override
  String get commGoalHerbalWellness => 'হার্বাল চা ও প্রাকৃতিক যত্ন';

  @override
  String get commGoalParentingGrowth => 'অভিভাবক ও শিশুর বৃদ্ধি';

  @override
  String get commGoalSkinCare => 'ত্বক ও দৈনন্দিন যত্ন';

  @override
  String get commGoalFitnessWalk => 'হাঁটা ও শরীরচর্চা';

  @override
  String get commGoalSleepStress => 'ঘুম ও মানসিক চাপ নিয়ন্ত্রণ';

  @override
  String commLikesCount(int count) {
    return '$count লাইক';
  }

  @override
  String get commLikeAction => 'লাইক দিন';

  @override
  String get commUnlikeAction => 'লাইক করা হয়েছে';

  @override
  String get commSendMessage => 'মেসেজ পাঠান';

  @override
  String get commMessagesDisabled => 'এই সদস্য সরাসরি মেসেজ বন্ধ রেখেছেন।';

  @override
  String get commOptInTitle => 'গ্লোবাল হেলথ কমিউনিটিতে যোগ দিন';

  @override
  String get commOptInBody =>
      'বিশ্বজুড়ে একই স্বাস্থ্য লক্ষ্যের মানুষের সাথে যুক্ত হন। যোগ দেওয়া সম্পূর্ণ ঐচ্ছিক — আপনার রিপোর্ট ও ছবি ১০০% গোপন থাকবে।';

  @override
  String get commOptInButton => 'আমার স্বাস্থ্য প্রোফাইল তৈরি করুন';

  @override
  String get commFieldDisplayName => 'প্রদর্শিত নাম';

  @override
  String get commFieldNickname => 'ইউজারনেম (@handle)';

  @override
  String get commFieldCountry => 'দেশ';

  @override
  String get commFieldCity => 'শহর (ঐচ্ছিক)';

  @override
  String get commFieldLanguage => 'পছন্দের ভাষা';

  @override
  String get commFieldGoals => 'স্বাস্থ্য লক্ষ্যসমূহ';

  @override
  String get commFieldBio => 'আমার সম্পর্কে ও স্বাস্থ্য যাত্রা';

  @override
  String get commFieldDailyFocus => 'দৈনন্দিন স্বাস্থ্য লক্ষ্য';

  @override
  String get commPrivacySection => 'গোপনীয়তা ও মেসেজ নিয়ন্ত্রণ';

  @override
  String get commToggleDiscoverable => 'বিশ্বব্যাপী খোঁজে আমার প্রোফাইল দেখান';

  @override
  String get commToggleHideRealName => 'আসল নাম লুকান (শুধু @handle দেখান)';

  @override
  String get commToggleHidePhoto => 'প্রোফাইল ছবি লুকান';

  @override
  String get commToggleAllowMessages => 'সরাসরি মেসেজ অনুমতি দিন';

  @override
  String get commToggleRequireApproval =>
      'নতুন মেসেজ অনুরোধে আমার অনুমোদন লাগবে';

  @override
  String get commUploadPhoto => 'ছবি আপলোড';

  @override
  String get commRemovePhoto => 'ছবি সরান';

  @override
  String get commSaveProfile => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get commProfileSaved => 'স্বাস্থ্য কমিউনিটি প্রোফাইল আপডেট হয়েছে।';

  @override
  String get commLeaveCommunity => 'কমিউনিটি ছাড়ুন ও পাবলিক প্রোফাইল মুছুন';

  @override
  String get commLeftCommunity => 'আপনার পাবলিক প্রোফাইল মুছে ফেলা হয়েছে।';

  @override
  String get commInboxEmpty =>
      'এখনো কোনো চ্যাট নেই। নতুন স্বাস্থ্য সঙ্গী খুঁজে হ্যালো বলুন!';

  @override
  String get commMessageRequestBadge => 'মেসেজ অনুরোধ';

  @override
  String get commRequestBannerTitle => 'নতুন মেসেজ অনুরোধ';

  @override
  String get commRequestBannerBody =>
      'চ্যাট চালিয়ে যেতে গ্রহণ করুন, অথবা প্রত্যাখ্যান/ব্লক করুন।';

  @override
  String get commRequestAccept => 'গ্রহণ করুন';

  @override
  String get commRequestDecline => 'প্রত্যাখ্যান';

  @override
  String get commChatPlaceholder => 'সহায়ক বার্তা লিখুন...';

  @override
  String get commAttachPhoto => 'ছবি যোগ করুন';

  @override
  String get commPhotoLabel => 'ছবি';

  @override
  String get commRateLimited =>
      'আরেকটি মেসেজ পাঠানোর আগে কয়েক সেকেন্ড অপেক্ষা করুন।';

  @override
  String get commBlockedNotice =>
      'ব্লক সেটিংসের কারণে এই ব্যবহারকারীকে মেসেজ পাঠানো যাবে না।';

  @override
  String get commMuteChat => 'মিউট';

  @override
  String get commUnmuteChat => 'আনমিউট';

  @override
  String get commHideChat => 'চ্যাট লুকান';

  @override
  String get commBlockUser => 'ব্লক করুন';

  @override
  String get commUnblockUser => 'আনব্লক করুন';

  @override
  String get commBlockedToast => 'ব্যবহারকারীকে ব্লক করা হয়েছে।';

  @override
  String get commReportUser => 'রিপোর্ট';

  @override
  String get commReportTitle => 'সদস্য বা বার্তা রিপোর্ট করুন';

  @override
  String get commReportReasonInappropriate => 'অনুপযুক্ত বিষয়বস্তু';

  @override
  String get commReportReasonSpam => 'স্প্যাম বা বিজ্ঞাপন';

  @override
  String get commReportReasonHarassment => 'হয়রানি বা ঘৃণামূলক বক্তব্য';

  @override
  String get commReportReasonMisinfo => 'অনিরাপদ চিকিৎসা পরামর্শ / ভুল তথ্য';

  @override
  String get commReportReasonOther => 'অন্যান্য';

  @override
  String get commReportNoteHint => 'অতিরিক্ত বিবরণ (ঐচ্ছিক)...';

  @override
  String get commReportSubmit => 'রিপোর্ট পাঠান';

  @override
  String get commReportSent => 'ধন্যবাদ। আপনার নিরাপত্তা রিপোর্ট জমা হয়েছে।';

  @override
  String get commDeleteForMe => 'আমার থেকে মুছুন';

  @override
  String get commDeleteForEveryone => 'সবার জন্য মুছুন';

  @override
  String get commOnlineNow => 'অনলাইন';

  @override
  String get commFilterOnlineOnly => 'অনলাইন সদস্য';

  @override
  String get commFilterSameCondition => 'একই রোগ';

  @override
  String get commFilterAllConditions => 'সব রোগ';

  @override
  String get commSameConditionPrompt =>
      'একই রোগের মানুষ খুঁজতে আমার প্রোফাইলে আপনার দীর্ঘমেয়াদী রোগ যোগ করুন।';

  @override
  String get commFieldChronicConditions => 'দীর্ঘমেয়াদী রোগ (ঐচ্ছিক)';

  @override
  String get commFieldCustomCondition => 'অন্য দীর্ঘমেয়াদী রোগ (ঐচ্ছিক)';

  @override
  String get commFieldCustomConditionHint =>
      'যেমন: ফাইব্রোমায়ালজিয়া, PCOS...';

  @override
  String get commToggleShowConditions => 'প্রোফাইলে দীর্ঘমেয়াদী রোগ দেখান';

  @override
  String get commToggleShowOnline => 'অনলাইন অবস্থা দেখান';

  @override
  String get condType1Diabetes => 'টাইপ ১ ডায়াবেটিস';

  @override
  String get condType2Diabetes => 'টাইপ ২ ডায়াবেটিস';

  @override
  String get condHypertension => 'উচ্চ রক্তচাপ';

  @override
  String get condAsthmaCopd => 'হাঁপানি / COPD';

  @override
  String get condThyroidHashimoto => 'থাইরয়েড / হাশিমোটো';

  @override
  String get condMigraine => 'মাইগ্রেন';

  @override
  String get condHeartCondition => 'হৃদরোগ';

  @override
  String get condCeliacIbs => 'সেলিয়াক / IBS';

  @override
  String get condArthritis => 'বাত / আর্থ্রাইটিস';

  @override
  String get condAnemia => 'রক্তস্বল্পতা';

  @override
  String get condKidneyHealth => 'কিডনি স্বাস্থ্য';

  @override
  String get condEczemaPsoriasis => 'একজিমা / সোরিয়াসিস';

  @override
  String get adminPanelTitle => 'অ্যাডমিন কন্ট্রোল প্যানেল';

  @override
  String get adminTabStats => 'পরিসংখ্যান';

  @override
  String get adminTabAnnouncements => 'ঘোষণা';

  @override
  String get adminTabPromotions => 'বিজ্ঞাপন';

  @override
  String get adminTabUsers => 'ব্যবহারকারী';

  @override
  String get adminTabReports => 'রিপোর্ট';

  @override
  String get adminStatOnline => 'অনলাইন';

  @override
  String get adminStatMembers => 'সদস্য';

  @override
  String get adminStatLikes => 'লাইক';

  @override
  String get adminStatChats => 'চ্যাট';

  @override
  String get adminStatPendingReports => 'অপেক্ষমান রিপোর্ট';

  @override
  String get adminStatActiveBanners => 'সক্রিয় ব্যানার';

  @override
  String get adminConditionBreakdown => 'দীর্ঘমেয়াদী রোগের পরিসংখ্যান';

  @override
  String get adminNewAnnouncement => 'নতুন ঘোষণা';

  @override
  String get adminNewPromotion => 'নতুন বিজ্ঞাপন / ব্যানার';

  @override
  String get adminFieldTitle => 'শিরোনাম';

  @override
  String get adminFieldMessage => 'বার্তা / বিবরণ';

  @override
  String get adminFieldLink => 'লিংক URL (ঐচ্ছিক)';

  @override
  String get adminFieldPlacement => 'অবস্থান';

  @override
  String get adminPlacementHome => 'হোম শীর্ষ';

  @override
  String get adminPlacementCommunity => 'কমিউনিটি শীর্ষ';

  @override
  String get adminPlacementProfile => 'প্রোফাইল শীর্ষ';

  @override
  String get adminTypeInfo => 'ঘোষণা';

  @override
  String get adminTypeHealthTip => 'স্বাস্থ্য টিপস';

  @override
  String get adminTypeWarning => 'সতর্কতা';

  @override
  String get adminTypeCampaign => 'ক্যাম্পেইন';

  @override
  String get adminSearchUsersHint => 'নাম, দেশ বা রোগ দিয়ে খুঁজুন...';

  @override
  String get adminActionVerify => 'যাচাই করুন';

  @override
  String get adminActionUnverify => 'যাচাই সরান';

  @override
  String get adminActionSuspend => 'স্থগিত করুন';

  @override
  String get adminActionUnsuspend => 'পুনরায় চালু';

  @override
  String get adminStatusSuspended => 'স্থগিত';

  @override
  String get adminStatusVerified => 'যাচাইকৃত';

  @override
  String get adminReportResolve => 'সমাধান';

  @override
  String get adminReportDismiss => 'বাতিল';

  @override
  String get adminNoReports => 'কোনো রিপোর্ট নেই।';

  @override
  String get adminNoAnnouncements => 'কোনো ঘোষণা নেই।';

  @override
  String get adminNoPromotions => 'কোনো বিজ্ঞাপন নেই।';

  @override
  String get commMusicSectionTitle => 'মনোযোগ ও শান্তির সঙ্গীত';

  @override
  String get commMusicTitleField => 'গান / প্লেলিস্টের নাম (ঐচ্ছিক)';

  @override
  String get commMusicUrlField => 'সঙ্গীত লিঙ্ক (YouTube, Spotify, SoundCloud)';

  @override
  String get commMusicInvalidUrl =>
      'অনুগ্রহ করে একটি বৈধ YouTube, Spotify, Apple Music বা SoundCloud লিঙ্ক দিন।';

  @override
  String get commMusicEmpty => 'এখনও কোনো মনোযোগের সঙ্গীত যোগ করা হয়নি।';

  @override
  String get commMusicListenAction => 'শুনুন';

  @override
  String get commMusicLikeAction => 'সঙ্গীত পছন্দ করুন';

  @override
  String get commMusicListenersTitle => 'যারা শুনেছেন';

  @override
  String get commMusicListenersEmpty => 'এখনও কেউ এই সঙ্গীতটি শোনেনি।';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count জন শুনেছেন';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '$count বার শোনা হয়েছে';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '$count বার';
  }

  @override
  String get commProfileLikersTitle => 'প্রোফাইল লাইক';

  @override
  String get commProfileLikersEmpty => 'এখনও কোনো প্রোফাইল লাইক নেই।';

  @override
  String get commSocialsSectionTitle => 'সোশ্যাল মিডিয়া অ্যাকাউন্ট';

  @override
  String get commToggleShowSocials => 'আমার সোশ্যাল মিডিয়া অ্যাকাউন্ট দেখান';

  @override
  String get commSocialsHiddenHint => 'অন্য সদস্যদের থেকে লুকানো';

  @override
  String get commSocialsEmpty => 'এখনও কোনো সোশ্যাল অ্যাকাউন্ট যোগ করা হয়নি।';

  @override
  String get commPreviewMyProfile => 'আমার প্রোফাইল দেখুন';

  @override
  String get safetyContentBlocked =>
      'This text contains inappropriate language, insults, or restricted content and cannot be posted.';

  @override
  String get safetyImageBlocked =>
      'This image did not pass safety verification and could not be uploaded.';

  @override
  String get safetyAccountSuspended =>
      'Your community access is temporarily suspended due to safety policy violations.';

  @override
  String get proMenuTitle => 'VisualCheckUp Pro';

  @override
  String get proMenuSubtitle =>
      'Unlimited lab analyses & ad-free health tracking';

  @override
  String get proPaywallTitle => 'Upgrade to VisualCheckUp Pro';

  @override
  String get proPaywallSubtitle =>
      'Unlock unlimited lab report analyses, full health trends, and an ad-free experience.';

  @override
  String get proPlanMonthly => 'Monthly';

  @override
  String get proPlanYearly => 'Yearly';

  @override
  String get proSaveBadge => 'Best Value • Save 42%';

  @override
  String get proPerMonth => '/ month';

  @override
  String get proPerYear => '/ year';

  @override
  String get proBenefitUnlimitedLabs => 'Unlimited blood & lab report analyses';

  @override
  String get proBenefitAiInsights => 'Unlimited AI PDF & photo lab extraction';

  @override
  String get proBenefitAdFree => 'Completely ad-free experience';

  @override
  String get proBenefitDoctorPriority =>
      'Priority verified doctor search & follow-up requests';

  @override
  String get proSubscribeButton => 'Activate VisualCheckUp Pro';

  @override
  String get proRestoreButton => 'Restore Purchases';

  @override
  String get proActiveBadge => 'VisualCheckUp Pro Active';

  @override
  String get proActivatedToast =>
      'VisualCheckUp Pro activated! Unlimited lab analyses unlocked.';

  @override
  String labFreeQuotaBanner(int remaining, int limit) {
    return 'Free Lab Analyses This Month: $remaining / $limit';
  }

  @override
  String get labProUnlimitedBanner =>
      'VisualCheckUp Pro • Unlimited Lab Analyses';

  @override
  String get labLimitReachedTitle => 'Monthly Free Lab Limit Reached';

  @override
  String get labLimitReachedBody =>
      'Free accounts can analyze up to 3 lab reports per month. Upgrade to VisualCheckUp Pro for unlimited analyses.';

  @override
  String get labUpgradeToProBtn => 'Go Pro (Unlimited)';

  @override
  String get doctorSearchTitle => 'দেশ অনুযায়ী ডাক্তার খুঁজুন';

  @override
  String get doctorSearchSubtitle =>
      'Search licensed doctors by country & specialty for guidance and patient follow-up';

  @override
  String get doctorSearchHomeCta => 'Search Doctors';

  @override
  String get doctorApplyCta => 'ডাক্তার আবেদন';

  @override
  String get doctorSearchHint =>
      'Search by doctor name, city, clinic, or specialty...';

  @override
  String get doctorFilterAllSpecialties => 'All Specialties';

  @override
  String get doctorFilterFollowUpOnly => 'Patient Follow-Up Open';

  @override
  String get doctorEmptyResults =>
      'No verified doctors match your selected country or specialty yet.';

  @override
  String get doctorVerifiedBadge => 'Verified Doctor';

  @override
  String get doctorFollowUpBadge => 'Patient Follow-Up';

  @override
  String doctorExperienceYears(int years) {
    return '$years yrs exp.';
  }

  @override
  String get doctorRequestFollowUpBtn => 'Request Follow-Up';

  @override
  String get doctorFollowUpDialogTitle => 'Request Patient Follow-Up';

  @override
  String get doctorFollowUpNoteHint =>
      'Briefly describe your chronic condition or follow-up goal...';

  @override
  String get doctorFollowUpSent =>
      'Your patient follow-up request has been sent to the doctor!';

  @override
  String get doctorApplicationTitle => 'Verified Doctor Application';

  @override
  String get doctorApplicationSubtitle =>
      'Join VisualCheckUp\'s global doctor directory to guide patients and offer structured follow-ups.';

  @override
  String get doctorFieldTitle => 'Medical Title';

  @override
  String get doctorFieldFullName => 'Full Name';

  @override
  String get doctorFieldSpecialty => 'Medical Specialty';

  @override
  String get doctorFieldClinic => 'Hospital / Clinic Name';

  @override
  String get doctorFieldLicense => 'Medical License / Diploma No';

  @override
  String get doctorFieldExperience => 'Years of Experience';

  @override
  String get doctorFieldBio => 'Professional Bio & Clinical Focus';

  @override
  String get doctorToggleFollowUp => 'Accept Patient Follow-Up Requests';

  @override
  String get doctorUploadDocBtn => 'Upload Diploma / License Photo (Optional)';

  @override
  String get doctorPlanSectionTitle => 'Doctor Directory Membership Plan';

  @override
  String get doctorPlanMonthlyTitle => 'Doctor Standard (Monthly)';

  @override
  String get doctorPlanMonthlyDesc =>
      'Verified badge, country & specialty listing, direct patient chat';

  @override
  String get doctorPlanYearlyTitle => 'Doctor Pro + Follow-Up (Yearly)';

  @override
  String get doctorPlanYearlyDesc =>
      'Priority country ranking, structured patient follow-ups, unlimited connections';

  @override
  String get doctorSubmitApplicationBtn => 'Submit Doctor Application';

  @override
  String get doctorApplicationSubmitted =>
      'Your doctor application has been submitted for admin verification!';

  @override
  String get doctorApplicationPendingBadge =>
      'Application Pending Verification';

  @override
  String get adminTabDoctors => 'ডাক্তার';

  @override
  String get adminApproveDoctor => 'Approve';

  @override
  String get adminRejectDoctor => 'Reject';

  @override
  String get adminNoDoctorApps => 'No doctor applications yet.';

  @override
  String get specInternalMedicine => 'Internal Medicine';

  @override
  String get specCardiology => 'Cardiology';

  @override
  String get specDermatology => 'Dermatology';

  @override
  String get specEndocrinology => 'Endocrinology';

  @override
  String get specNeurology => 'Neurology';

  @override
  String get specOphthalmology => 'Ophthalmology';

  @override
  String get specPediatrics => 'Pediatrics';

  @override
  String get specFamilyMedicine => 'Family Medicine';

  @override
  String get specNutritionDietetics => 'Nutrition & Dietetics';

  @override
  String get specPsychiatry => 'Psychiatry';

  @override
  String get specPulmonology => 'Pulmonology';

  @override
  String get specNephrology => 'Nephrology';

  @override
  String get dailyHealthTipTitle => 'আজকের স্বাস্থ্য টিপ';

  @override
  String birthdayCardTitle(String name) {
    return 'শুভ জন্মদিন, $name! 🎉';
  }

  @override
  String get birthdayCardSubtitle => 'সুস্থ ও সুখী একটি বছর কামনা করি।';

  @override
  String get commDrawerProfileSubtitle =>
      'আপনার সোশ্যাল কার্ড, মুড ও পরিসংখ্যান';

  @override
  String get commDrawerCommunitySubtitle => 'খুঁজুন • ওয়াল • গ্রুপ • চ্যাট';

  @override
  String get commTabWall => 'ওয়াল';

  @override
  String get commTabGroups => 'গ্রুপ';

  @override
  String get commEditProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get commDoneEditing => 'বাতিল';

  @override
  String get commFriendsStat => 'বন্ধু';

  @override
  String get commAddFriend => 'বন্ধু যোগ করুন';

  @override
  String get commFriendPending => 'অনুরোধ পাঠানো হয়েছে';

  @override
  String get commFriendsConnected => 'বন্ধু';

  @override
  String get commFriendsSheetTitle => 'স্বাস্থ্য বন্ধু';

  @override
  String get commFriendsEmpty =>
      'এখনো কোনো স্বাস্থ্য বন্ধু নেই। খুঁজুন থেকে যুক্ত হোন!';

  @override
  String get commMoodSectionTitle => 'আজকের মুড';

  @override
  String get commMoodEnergetic => 'উদ্যমী';

  @override
  String get commMoodCalm => 'শান্ত';

  @override
  String get commMoodGrateful => 'কৃতজ্ঞ';

  @override
  String get commMoodFocused => 'মনোযোগী';

  @override
  String get commMoodTired => 'ক্লান্ত';

  @override
  String get commMoodRecovering => 'সুস্থ হচ্ছি';

  @override
  String get commWallTitle => 'অভিজ্ঞতা ও প্রশ্ন ওয়াল';

  @override
  String get commWallNewPost => 'পোস্ট করুন';

  @override
  String get commWallPostTitleHint =>
      'শিরোনাম (যেমন: সকালের হাঁটা ও সুগার নিয়ন্ত্রণ)';

  @override
  String get commWallPostBodyHint => 'আপনার অভিজ্ঞতা বা প্রশ্ন শেয়ার করুন...';

  @override
  String get commWallPublishBtn => 'প্রকাশ করুন';

  @override
  String get commWallDoctorReplyBadge => 'ডাক্তারের উত্তর';

  @override
  String get commWallCommentsTitle => 'মন্তব্য';

  @override
  String get commWallCommentHint => 'সহায়ক মন্তব্য লিখুন...';

  @override
  String get commWallEmpty => 'এখনো কোনো পোস্ট নেই। প্রথম শেয়ার করুন!';

  @override
  String get commGroupsTitle => 'সহায়তা গ্রুপ';

  @override
  String get commGroupsCreate => 'গ্রুপ তৈরি করুন';

  @override
  String get commGroupsJoin => 'যোগ দিন';

  @override
  String get commGroupsJoined => 'যুক্ত আছেন';

  @override
  String get commGroupsOpenChat => 'গ্রুপ চ্যাট';

  @override
  String commGroupsMembersCount(int count) {
    return '$count সদস্য';
  }

  @override
  String get commGroupsNameHint => 'গ্রুপের নাম';

  @override
  String get commGroupsDescHint => 'গ্রুপের বিবরণ ও বিষয়';

  @override
  String get commGroupsEmpty => 'এই ফিল্টারে কোনো গ্রুপ পাওয়া যায়নি।';

  @override
  String get commToggleOnlyFriendsMsg =>
      'শুধুমাত্র বন্ধুরা আমাকে বার্তা পাঠাতে পারবে';

  @override
  String get commOpenCommunityCta => 'কমিউনিটি';

  @override
  String get sfbGoToProfile => 'প্রোফাইলে যান';

  @override
  String get sfbMyMessages => 'আমার বার্তা';

  @override
  String get sfbMyFriends => 'আমার বন্ধু';

  @override
  String get sfbSeeAll => 'সব দেখুন';

  @override
  String get sfbNewMembersTitle => 'নতুন সদস্য';

  @override
  String get sfbActiveMembersTitle => 'সবচেয়ে সক্রিয় সদস্য';

  @override
  String get sfbLatestPostsTitle => 'সর্বশেষ পোস্ট';

  @override
  String get sfbViewDetails => 'বিস্তারিত দেখুন';

  @override
  String get sfbAdminBadge => 'অ্যাডমিন';

  @override
  String get sfbAdminConsoleTitle => 'দ্রুত অ্যাডমিন কনসোল';

  @override
  String get sfbAdminFounderBanner =>
      'প্ল্যাটফর্ম প্রতিষ্ঠাতা ও সিস্টেম অ্যাডমিন';

  @override
  String get adminFieldIcon => 'স্বাস্থ্য ও উদযাপন আইকন';

  @override
  String get adminToggleSendPush => 'ব্যবহারকারীদের বিজ্ঞপ্তি পাঠান';

  @override
  String get adminToggleSendPushSubtitle =>
      'বিজ্ঞপ্তি পাঠান এবং উপকারী স্বাস্থ্য তথ্য কার্ডে দেখান';

  @override
  String get adminAnnouncementPublishedToast =>
      'ঘোষণা প্রকাশিত হয়েছে এবং বিজ্ঞপ্তি পাঠানো হয়েছে।';

  @override
  String get cameraLiveLight => 'আলো';

  @override
  String get cameraLiveFocus => 'ফোকাস';

  @override
  String get cameraLiveGlare => 'ঝলক';
}
