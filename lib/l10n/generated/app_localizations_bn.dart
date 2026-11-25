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
}
