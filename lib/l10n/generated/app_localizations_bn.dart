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
}
