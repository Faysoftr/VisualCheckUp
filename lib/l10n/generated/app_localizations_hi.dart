// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'यह ऐप चिकित्सीय निदान नहीं करता; यह केवल जानकारी और प्रारंभिक जागरूकता के लिए है।';

  @override
  String get disclaimerTitle => 'महत्वपूर्ण चिकित्सीय सूचना';

  @override
  String get disclaimerFull =>
      'VisualCheckUp रंग और दृश्य संकेतों के आधार पर प्रारंभिक मूल्यांकन देता है। यह कोई मेडिकल उपकरण नहीं है और डॉक्टर की जांच या लैब टेस्ट का विकल्प नहीं है।\n\n• रोशनी और कैमरा सेंसर रंग की पहचान को प्रभावित करते हैं।\n• तेज दर्द, रक्तस्राव, तेज बुखार, पीलिया, काला/सफेद मल या सांस लेने में कठिनाई होने पर तुरंत डॉक्टर से मिलें।\n• गोपनीयता: फ़ोटो डिफ़ॉल्ट रूप से केवल आपके डिवाइस पर प्रोसेस होती हैं।';

  @override
  String get disclaimerAccept => 'मैं समझ गया/गई';

  @override
  String get loginTagline =>
      'त्वचा, तिल और दैनिक स्वास्थ्य संकेतों की निगरानी तथा डॉक्टर से मिलने की तैयारी के लिए सहायक।';

  @override
  String get featureColorCalibration => 'रंग कैलिब्रेशन';

  @override
  String get featurePrivacyFirst => 'गोपनीयता प्रथम';

  @override
  String get featureOptionalAi => 'वैकल्पिक AI';

  @override
  String get loginCardTitle => 'अपने खाते से जारी रखें';

  @override
  String get loginCardSubtitle =>
      'अपना रंग बेसलाइन और जांच इतिहास सुरक्षित रखें।';

  @override
  String get continueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get orDivider => 'या';

  @override
  String get continueAsGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get guestGreeting => 'त्वचा और स्वास्थ्य ट्रैकिंग';

  @override
  String userGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider खाता';
  }

  @override
  String get localOnlyLabel => 'केवल इस डिवाइस पर सहेजा गया';

  @override
  String get menuHome => 'होम';

  @override
  String get menuSectionVisualChecks => 'दृश्य जांच';

  @override
  String get menuSkinGroup => 'त्वचा (तिल, मस्सा, नील, दाग)';

  @override
  String get menuSkinGeneral => 'सामान्य त्वचा और दाने';

  @override
  String get menuSectionTracking => 'ट्रैकिंग, लैब और वाइटल्स';

  @override
  String get menuFollowUpPlan => 'व्यक्तिगत फॉलो-अप योजना';

  @override
  String get menuVitalsTracker => 'ब्लड प्रेशर और शुगर';

  @override
  String get menuLabReports => 'लैब और अस्पताल रिपोर्ट';

  @override
  String get menuQuickColorCard => 'बिना कैमरे का कलर कार्ड';

  @override
  String get menuHistory => 'जांच इतिहास';

  @override
  String get menuReferenceGuide => 'दृश्य संदर्भ मार्गदर्शिका';

  @override
  String get menuSectionSettings => 'सेटिंग्स और गोपनीयता';

  @override
  String get menuAiSettings => 'AI और गोपनीयता';

  @override
  String get menuDisclaimer => 'चिकित्सीय अस्वीकरण';

  @override
  String get menuTheme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get menuLanguage => 'ऐप की भाषा';

  @override
  String get languageSystem => 'सिस्टम भाषा';

  @override
  String get signInGoogleOrApple => 'Google या Apple से साइन इन करें';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountTitle => 'खाता और स्थानीय डेटा हटाएं';

  @override
  String get deleteAccountBody =>
      'आप साइन आउट हो जाएंगे और इस डिवाइस पर मौजूद जांच इतिहास स्थायी रूप से हट जाएगा। क्या आप जारी रखना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get followUpCardTitle => 'व्यक्तिगत फॉलो-अप योजना';

  @override
  String get followUpSelectEdit => 'चुनें / बदलें';

  @override
  String get followUpStart => 'शुरू करें';

  @override
  String get followUpEmptyHint =>
      'आंख, मूत्र, ब्लड प्रेशर, शुगर और अन्य रूटीन चुनने के लिए टैप करें।';

  @override
  String get followUpSheetSubtitle =>
      'आंख, जीभ, नाखून, त्वचा, मूत्र, मल, बीपी, शुगर और लैब रिपोर्ट को एक योजना में ट्रैक करें।';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active सक्रिय • $completed अद्यतन • $due बाकी';
  }

  @override
  String get homeCategoriesTitle => 'जांच श्रेणियां';

  @override
  String get homeCategoriesSubtitle =>
      'कैमरा या कलर कार्ड से दृश्य बदलावों को ट्रैक करें।';

  @override
  String get homeLabsVitalsTitle => 'लैब, बीपी और शुगर';

  @override
  String get homeLabsVitalsSubtitle =>
      'रक्त जांच रिपोर्ट पढ़ें और बीपी व शुगर के रुझान देखें।';

  @override
  String get homeLabsCardTitle => 'लैब और रिपोर्ट';

  @override
  String get homeLabsCardEmpty => 'ब्लड टेस्ट पढ़ें और समझें';

  @override
  String homeLabsCardCount(int count) {
    return '$count सहेजी गई रिपोर्ट';
  }

  @override
  String get homeVitalsCardTitle => 'बीपी और शुगर';

  @override
  String get homeVitalsCardEmpty => 'रीडिंग दर्ज करें और ट्रेंड देखें';

  @override
  String homeVitalsCardCount(int count) {
    return '$count सहेजी गई रीडिंग';
  }

  @override
  String get homeRecentChecks => 'हाल की जांचें';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get catEyeTitle => 'आंख (स्क्लेरा)';

  @override
  String get catEyeSubtitle => 'लाली, पीलापन और आंख की सफेदी';

  @override
  String get catNailTitle => 'नाखून';

  @override
  String get catNailSubtitle => 'पीलापन, नीलापन और आकार की जांच';

  @override
  String get catTongueTitle => 'जीभ';

  @override
  String get catTongueSubtitle => 'रंग, सफेद/पीली परत और बनावट';

  @override
  String get catFaceTitle => 'चेहरा और त्वचा';

  @override
  String get catFaceSubtitle => 'त्वचा का रंग, पीलापन और लाली';

  @override
  String get catSkinTitle => 'त्वचा रोग';

  @override
  String get catSkinSubtitle => 'तिल, मस्सा, नील, चेहरे के दाग और दाने';

  @override
  String get catUrineTitle => 'मूत्र का रंग';

  @override
  String get catUrineSubtitle => 'हाइड्रेशन और रंग स्केल जांच';

  @override
  String get catStoolTitle => 'मल का रंग';

  @override
  String get catStoolSubtitle => 'पाचन और रंग चेतावनी जांच';

  @override
  String get tooltipHistory => 'इतिहास';

  @override
  String get tooltipAccountMenu => 'खाता और मेनू';

  @override
  String get menuSettings => 'सेटिंग्स (अनुमतियाँ और भाषा)';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguageDesc =>
      'डिफ़ॉल्ट रूप से फ़ोन की भाषा उपयोग होती है। आप नीचे से कोई भी भाषा चुन सकते हैं।';

  @override
  String get settingsPermissionsTitle => 'ऐप अनुमतियाँ';

  @override
  String get settingsPermissionsDesc =>
      'यहाँ कैमरा और गैलरी अनुमतियाँ जांचें और प्रबंधित करें।';

  @override
  String get settingsCameraPermission => 'कैमरा अनुमति';

  @override
  String get settingsCameraPermissionDesc =>
      'आंख, जीभ, नाखून और त्वचा की फोटो के लिए';

  @override
  String get settingsPhotosPermission => 'गैलरी और फ़ोटो अनुमति';

  @override
  String get settingsPhotosPermissionDesc =>
      'फ़ोटो और लैब रिपोर्ट अपलोड करने के लिए';

  @override
  String get settingsOpenSystemPermissions => 'फ़ोन ऐप अनुमतियाँ खोलें';

  @override
  String get permChecking => 'जांच हो रही है...';

  @override
  String get permGranted => 'अनुमति दी गई';

  @override
  String get permDenied => 'अनुमति आवश्यक';

  @override
  String get permPermanent => 'सिस्टम सेटिंग्स से चालू करें';

  @override
  String get permUnavailable => 'डिवाइस द्वारा प्रबंधित';

  @override
  String get permGrantBtn => 'अनुमति दें';

  @override
  String get permOpenSettingsBtn => 'सेटिंग्स खोलें';

  @override
  String get skinCancerRisk => 'तिल और त्वचा कैंसर जोखिम';

  @override
  String get skinWart => 'मस्सा प्रारंभिक जांच';

  @override
  String get skinBruise => 'नील (चोट) ट्रैकिंग';

  @override
  String get skinFacialSpot => 'चेहरे के दाग';

  @override
  String get trackEyeTitle => 'साप्ताहिक आंख जांच';

  @override
  String get trackEyeSubtitle => 'लाली या पीलेपन में बदलाव ट्रैक करें';

  @override
  String get trackTongueTitle => 'साप्ताहिक जीभ जांच';

  @override
  String get trackTongueSubtitle => 'जीभ का रंग, परत और बनावट देखें';

  @override
  String get trackNailTitle => 'साप्ताहिक नाखून जांच';

  @override
  String get trackNailSubtitle => 'पीलापन, नीलापन या सफेदी की निगरानी करें';

  @override
  String get trackFaceTitle => 'पाक्षिक चेहरा व त्वचा टोन';

  @override
  String get trackFaceSubtitle => 'चेहरे के रंग और लाली की तुलना करें';

  @override
  String get trackSkinTitle => 'मासिक त्वचा, तिल और मस्सा जांच';

  @override
  String get trackSkinSubtitle =>
      '30 दिनों में तिल, मस्से व दागों में बदलाव देखें';

  @override
  String get trackHydrationTitle => 'दैनिक हाइड्रेशन (मूत्र) जांच';

  @override
  String get trackHydrationSubtitle =>
      'बिना कैमरे कलर कार्ड से 2 सेकंड में रिकॉर्ड करें';

  @override
  String get trackStoolTitle => 'साप्ताहिक मल रंग जांच';

  @override
  String get trackStoolSubtitle => 'पाचन और रंग चेतावनी नियमित ट्रैक करें';

  @override
  String get trackBpTitle => 'दैनिक ब्लड प्रेशर जांच';

  @override
  String get trackBpSubtitle => 'सिस्टोलिक/डायस्टोलिक और पल्स ट्रेंड सहेजें';

  @override
  String get trackSugarTitle => 'दैनिक ब्लड शुगर जांच';

  @override
  String get trackSugarSubtitle => 'फास्टिंग या भोजन के बाद शुगर रिकॉर्ड करें';

  @override
  String get trackLabTitle => 'त्रैमासिक ब्लड टेस्ट व रिपोर्ट';

  @override
  String get trackLabSubtitle => 'अस्पताल रिपोर्ट अपलोड करें और तुलना करें';

  @override
  String get statusFirstPending => 'पहले रिकॉर्ड की प्रतीक्षा';

  @override
  String get statusDueNow => 'जांच का समय हो गया है';

  @override
  String get statusDoneToday => 'आज पूरा हुआ';

  @override
  String statusNextDays(int days) {
    return 'अगली जांच: $days दिन बाद';
  }

  @override
  String get actionCheckNow => 'अभी जांचें';

  @override
  String get actionLogReading => 'रीडिंग दर्ज करें';

  @override
  String get actionAddReport => 'रिपोर्ट जोड़ें';

  @override
  String checkMethodTitle(String category) {
    return '$category • जांच का तरीका';
  }

  @override
  String get checkMethodSubtitle =>
      'बिना फोटो लिए 2 सेकंड में कलर कार्ड चुनें या कैमरा माप उपयोग करें।';

  @override
  String get colorCardRecommendedTitle => 'बिना कैमरे का कलर कार्ड (अनुशंसित)';

  @override
  String get colorCardRecommendedSubtitle =>
      'बिना फोटो के निजी और तेज़ रिकॉर्ड (2 सेकंड)';

  @override
  String get cameraMeasureTitle => 'कैमरा रंग माप';

  @override
  String get cameraMeasureSubtitle =>
      'व्हाइट-बैलेंस कैलिब्रेशन के साथ स्वचालित माप';

  @override
  String get referenceGuideSubtitle =>
      'स्वस्थ और असामान्य दृश्य संकेत देखने के लिए मॉड्यूल चुनें।';

  @override
  String get historyEmpty => 'अभी कोई सहेजी गई जांच नहीं है।';

  @override
  String get filterAll => 'सभी';

  @override
  String get aiSettingsTitle => 'AI और गोपनीयता';

  @override
  String get vitalsBpTab => 'ब्लड प्रेशर';

  @override
  String get vitalsSugarTab => 'ब्लड शुगर';

  @override
  String get skinScreenTitle => 'त्वचा स्थिति पूर्व-जांच';

  @override
  String get providerGuest => 'अतिथि';

  @override
  String signInFailed(String error) {
    return 'साइन-इन विफल: $error';
  }

  @override
  String get riskNormal => 'सामान्य रूप';

  @override
  String get riskAttention => 'फॉलो-अप की सलाह';

  @override
  String get riskUrgent => 'डॉक्टर की सलाह आवश्यक';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'नवीनतम: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'नवीनतम: $count मान ($abnormal सीमा से बाहर)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'नवीनतम: $count मान (सभी सामान्य)';
  }

  @override
  String get labStatusCriticalLow => 'अत्यधिक कम';

  @override
  String get labStatusLow => 'कम';

  @override
  String get labStatusNormal => 'सामान्य';

  @override
  String get labStatusHigh => 'अधिक';

  @override
  String get labStatusCriticalHigh => 'अत्यधिक अधिक';

  @override
  String get labSourceManual => 'मैनुअल प्रविष्टि';

  @override
  String get labSourcePasted => 'रिपोर्ट टेक्स्ट से पढ़ा गया';

  @override
  String get labSourcePhoto => 'JPG / फ़ोटो रिपोर्ट';

  @override
  String get labSourcePdf => 'PDF रिपोर्ट';

  @override
  String get bpLow => 'निम्न रक्तचाप';

  @override
  String get bpNormal => 'सामान्य सीमा';

  @override
  String get bpElevated => 'हल्का बढ़ा हुआ';

  @override
  String get bpStage1 => 'स्टेज 1 उच्च';

  @override
  String get bpStage2 => 'उच्च रक्तचाप (स्टेज 2)';

  @override
  String get bpCrisis => 'आपातकालीन उच्च रक्तचाप';

  @override
  String get sugarLow => 'निम्न रक्त शर्करा';

  @override
  String get sugarNormal => 'सामान्य सीमा';

  @override
  String get sugarBorderline => 'सीमा पर अधिक';

  @override
  String get sugarHigh => 'उच्च रक्त शर्करा';

  @override
  String get sugarVeryHigh => 'अत्यधिक उच्च शर्करा';

  @override
  String get sugarTypeFasting => 'उपवास (खाली पेट)';

  @override
  String get sugarTypePostMeal => 'भोजन के 2 घंटे बाद';

  @override
  String get sugarTypeRandom => 'यादृच्छिक';

  @override
  String get specialtyEye => 'नेत्र रोग या इंटरनल मेडिसिन';

  @override
  String get specialtyNail => 'त्वचा रोग या इंटरनल मेडिसिन';

  @override
  String get specialtyTongue => 'ईएनटी, मुख स्वास्थ्य या इंटरनल मेडिसिन';

  @override
  String get specialtySkin => 'त्वचा रोग विभाग';

  @override
  String get specialtyUrine => 'यूरोलॉजी या इंटरनल मेडिसिन';

  @override
  String get specialtyStool => 'गैस्ट्रोएंटरोलॉजी या इंटरनल मेडिसिन';

  @override
  String get cloudBackupTitle => 'क्लाउड बैकअप (वैकल्पिक • Firebase)';

  @override
  String get cloudBackupDesc =>
      'डिफ़ॉल्ट रूप से आपकी सभी रिपोर्ट और रीडिंग केवल इस डिवाइस पर रहती हैं। फ़ोन बदलते समय डेटा सुरक्षित रखने के लिए अपने Google/Apple खाते से बैकअप चालू करें।';

  @override
  String get cloudBackupToggleTitle => 'क्लाउड बैकअप सक्षम करें';

  @override
  String cloudBackupLastSync(String date) {
    return 'अंतिम बैकअप: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'सक्रिय • सिंक के लिए तैयार';

  @override
  String get cloudBackupDisabledLocal => 'बंद • केवल डिवाइस स्टोरेज';

  @override
  String get cloudBackupSignInRequired =>
      'क्लाउड बैकअप के लिए Google या Apple से साइन इन करें।';

  @override
  String get cloudBackupNowBtn => 'अभी बैकअप लें';

  @override
  String get cloudRestoreBtn => 'क्लाउड से पुनर्स्थापित करें';

  @override
  String get cloudConsentTitle => 'क्लाउड बैकअप सहमति';

  @override
  String get cloudConsentBody =>
      'आपकी सभी रिपोर्ट और रीडिंग डिफ़ॉल्ट रूप से केवल इस डिवाइस पर रहती हैं।\n\nक्लाउड बैकअप चालू करने पर यह डेटा आपके निजी Google/Apple खाते में सुरक्षित रहेगा और खाता हटाने पर स्थायी रूप से मिट जाएगा।\n\nक्या आप सहमत हैं?';

  @override
  String get cloudConsentConfirm => 'हाँ, सक्षम करें';

  @override
  String cloudBackupSuccess(int count) {
    return 'क्लाउड बैकअप पूर्ण: $count रिकॉर्ड सिंक हुए।';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'बैकअप विफल: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'क्लाउड से पुनर्स्थापित: $count रिकॉर्ड आयात हुए।';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'पुनर्स्थापना विफल: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'क्लाउड बैकअप बंद। नए रिकॉर्ड केवल इसी डिवाइस पर रहेंगे।';

  @override
  String get aiCloudToggleTitle => 'क्लाउड विज़न एआई (Gemini) विश्लेषण';

  @override
  String get aiCloudOnDesc =>
      'चालू: स्पष्ट फ़ोटो को छोटा करके सुरक्षित कनेक्शन से विश्लेषित किया जाता है। ऑफ़लाइन होने पर डिवाइस विश्लेषण चलता है।';

  @override
  String get aiCloudOffDesc =>
      'बंद (0 टोकन): सभी विश्लेषण केवल आपके डिवाइस पर होते हैं; कोई फ़ोटो बाहर नहीं भेजी जाती।';

  @override
  String get aiBackendOfflineNote =>
      'Gemini / Firebase AI कुंजी जुड़ने पर इस विकल्प के अनुसार क्लाउड विश्लेषण सक्रिय होगा; अभी ऑन-डिवाइस इंजन सक्रिय है।';

  @override
  String get aiOptimizationsTitle => 'सक्रिय टोकन और डेटा बचत नियंत्रण';

  @override
  String get aiOptQualityGate => '0-टोकन धुंधलापन, अंधेरा और चमक गुणवत्ता जांच';

  @override
  String get aiOptCompression => 'ऑटो-क्रॉप + 512px/768px JPEG (80%) संपीड़न';

  @override
  String get aiOptTieredModel => 'स्मार्ट मॉडल चयन (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'समान फ़ोटो के लिए लोकल हैश कैश (0 टोकन)';

  @override
  String get aiClearCacheBtn => 'AI कैश साफ़ करें';

  @override
  String get aiCacheCleared => 'AI कैश साफ़ हो गया।';

  @override
  String resultScreenTitle(String category) {
    return '$category परिणाम';
  }

  @override
  String get tooltipDoctorSummary => 'डॉक्टर के लिए सारांश';

  @override
  String get tooltipReferenceGuide => 'संदर्भ मार्गदर्शिका';

  @override
  String get calibratedColorTone => 'कैलिब्रेटेड रंग टोन';

  @override
  String get sampledColorTone => 'प्रमुख नमूना रंग टोन';

  @override
  String confidenceLabel(int percent) {
    return 'प्रारंभिक विश्वास: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote => 'सफ़ेद संदर्भ से रंग संतुलित किया गया।';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'सुझाया गया विभाग: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'समय के साथ परिवर्तन';

  @override
  String get todayLabel => 'आज';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'पिछला रिकॉर्ड: \"$title\" ($status)। कुल $count रिकॉर्ड ट्रैक किए जा रहे हैं।';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'व्यक्तिगत सामान्य मान से तुलना';

  @override
  String get yourBaselineLabel => 'आपका सामान्य';

  @override
  String get warningFlagsTitle => 'ध्यान देने योग्य चेतावनी संकेत';

  @override
  String get observationsTitle => 'अवलोकन';

  @override
  String get recommendationsTitle => 'सुझाव';

  @override
  String get personalBaselineCardTitle => 'व्यक्तिगत बेसलाइन कैलिब्रेशन';

  @override
  String get personalBaselineCardDesc =>
      'स्वस्थ दिन पर इसे अपने व्यक्तिगत सामान्य मान के रूप में सहेजें ताकि कैमरा अंतर कम हो।';

  @override
  String get saveBaselineBtn => 'मेरा सामान्य मान सहेजें';

  @override
  String get updateBaselineBtn => 'मेरा सामान्य मान अपडेट करें';

  @override
  String get clearBaselineBtn => 'हटाएँ';

  @override
  String baselineSavedMsg(String category) {
    return '$category के लिए व्यक्तिगत मान सहेजा गया।';
  }

  @override
  String baselineClearedMsg(String category) {
    return '$category का व्यक्तिगत मान हटा दिया गया।';
  }

  @override
  String get doctorSummaryBtn => 'डॉक्टर को दिखाएँ • सारांश तैयार करें';

  @override
  String get returnHomeBtn => 'होम पर लौटें';

  @override
  String get doctorSheetTitle => 'डॉक्टर विज़िट सारांश';

  @override
  String colorLabel(String hex, String status) {
    return 'रंग: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'पिछले रिकॉर्ड की समयरेखा';

  @override
  String get questionsForDoctorTitle => 'डॉक्टर से पूछने योग्य प्रश्न';

  @override
  String get copyShareSummaryBtn => 'सारांश कॉपी और साझा करें';

  @override
  String get doctorSummaryCopied => 'डॉक्टर सारांश क्लिपबोर्ड पर कॉपी हो गया।';

  @override
  String referenceSheetTitle(String category) {
    return '$category — दृश्य संदर्भ';
  }

  @override
  String get healthyReferenceLabel => 'स्वस्थ संदर्भ';

  @override
  String get captureChecklistTitle => 'सही फ़ोटो लेने के सुझाव';

  @override
  String get abnormalFindingsTitle => 'ध्यान देने योग्य / असामान्य लक्षण';

  @override
  String get cameraPermPermanentMsg =>
      'सिस्टम सेटिंग्स में कैमरा अनुमति बंद है। इसे चालू करें या गैलरी से फ़ोटो चुनें।';

  @override
  String get cameraPermRequiredMsg =>
      'विजुअल जांच के लिए कैमरा अनुमति आवश्यक है। चित्र आपके डिवाइस पर ही प्रोसेस होते हैं।';

  @override
  String get cameraGrantPermTitle => 'कैमरा अनुमति आवश्यक';

  @override
  String get cameraRequestPermBtn => 'कैमरा अनुमति दें';

  @override
  String get cameraPickGalleryBtn => 'गैलरी से चुनें';

  @override
  String get cameraWhiteRefOn => 'सफ़ेद संदर्भ: चालू';

  @override
  String get cameraWhiteRefOff => 'सफ़ेद संदर्भ: बंद';

  @override
  String get cameraBaselineActive => 'व्यक्तिगत मान सहेजा गया';

  @override
  String get cameraAnalyzing => 'विश्लेषण हो रहा है...';

  @override
  String get cameraCaptureBtn => 'फ़ोटो लें और जांचें';

  @override
  String cameraAnalysisFailed(String error) {
    return 'विश्लेषण त्रुटि: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • रंग कार्ड';
  }

  @override
  String get quickCardPrivacyBanner =>
      'कैमरा आवश्यक नहीं: 2 सेकंड में निजी रिकॉर्ड के लिए निकटतम रंग चुनें।';

  @override
  String get quickCardChooseShade => 'निकटतम रंग टोन चुनें';

  @override
  String get quickCardExtraContext => 'अतिरिक्त जानकारी (वैकल्पिक)';

  @override
  String get quickCardSaveViewBtn => 'सहेजें और मूल्यांकन देखें';

  @override
  String get quickCardUseCameraBtn => 'इसके बजाय कैमरा उपयोग करें';

  @override
  String get skinIntroTitle => 'विजुअल त्वचा प्रारंभिक जांच';

  @override
  String get skinIntroDesc =>
      'तिल, मस्से, नील और चेहरे के दागों की आसपास की त्वचा से तुलना करता है। यह निदान नहीं है; डॉक्टर से मिलने की तैयारी में सहायक है।';

  @override
  String get skinStep1Title => '1. त्वचा प्री-स्क्रीनिंग मॉड्यूल चुनें';

  @override
  String get skinOtherConcernsLabel => 'अन्य त्वचा लक्षण';

  @override
  String get skinStep2Title => '2. साथ के लक्षण (वैकल्पिक)';

  @override
  String get skinStep3Title => '3. शरीर का हिस्सा (वैकल्पिक)';

  @override
  String get skinStartCameraBtn => 'कैमरा से त्वचा जांच शुरू करें';

  @override
  String get skinConcernRash => 'लालिमा / दाने';

  @override
  String get skinConcernMole => 'तिल / गहरा दाग';

  @override
  String get skinConcernScaly => 'पपड़ीदार / सूखा धब्बा';

  @override
  String get skinConcernBlister => 'छाला / मुंहासा';

  @override
  String get skinConcernGeneral => 'सामान्य त्वचा जांच';

  @override
  String get bodyAreaFaceNeck => 'चेहरा / गर्दन';

  @override
  String get bodyAreaArmHand => 'बांह / हाथ';

  @override
  String get bodyAreaTorso => 'धड़';

  @override
  String get bodyAreaLegFoot => 'पैर / पांव';

  @override
  String get bodyAreaScalp => 'सिर की त्वचा';

  @override
  String get bodyAreaOther => 'अन्य';

  @override
  String get symptomItching => 'खुजली';

  @override
  String get symptomPainWarmth => 'दर्द / गर्मी';

  @override
  String get symptomRapidChange => 'तेजी से बढ़ना / आकार बदलना';

  @override
  String get symptomBleeding => 'खून बहना / रिसाव';

  @override
  String get symptomSpreading => 'तेजी से फैल रहा है';

  @override
  String get symptomFever => 'बुखार साथ है';

  @override
  String get symptomNonHealing => '4+ सप्ताह से न भरने वाला घाव';

  @override
  String get symptomOver6mm => '6 मिमी से बड़ा या अनियमित किनारा';

  @override
  String get symptomNoTrauma => 'बिना चोट के अपने आप उभरा';

  @override
  String get symptomRoughDots => 'खुरदरी सतह / छोटे काले बिंदु';

  @override
  String get symptomSunHormone => 'धूप, हार्मोन या मुंहासे का दाग';

  @override
  String get bruiseGuideTitle => 'नील के रंग चरण मार्गदर्शिका';

  @override
  String get wartGuideTitle => 'मस्सा सुरक्षा मार्गदर्शिका';

  @override
  String get abcdeGuideTitle => 'तिल के लिए ABCDE मार्गदर्शिका';

  @override
  String get abcdeGuideSubtitle =>
      'त्वचा विशेषज्ञों द्वारा उपयोग किए जाने वाले 5 मुख्य संकेत';

  @override
  String get labScreenTitle => 'लैब और अस्पताल रिपोर्ट';

  @override
  String get labTabReports => 'मेरी रिपोर्ट';

  @override
  String get labTabTrends => 'परिवर्तन ट्रैकिंग';

  @override
  String get labAddBtn => 'रिपोर्ट / रक्त जांच जोड़ें';

  @override
  String get labEmptyTitle => 'अभी तक कोई रक्त जांच सहेजी नहीं गई';

  @override
  String get labEmptyDesc =>
      'PDF या JPG रक्त जांच अपलोड करें; सरल व्याख्या के लिए वैकल्पिक रूप से निदान या अपनी शिकायत जोड़ें।';

  @override
  String get labAddFirstBtn => 'पहली रिपोर्ट जोड़ें';

  @override
  String get labTrendsEmptyDesc =>
      'विभिन्न तारीखों में रक्त जांच सहेजने पर हीमोग्लोबिन, फेरिटिन, ग्लूकोज, TSH आदि के ट्रेंड ग्राफ़ यहाँ दिखेंगे।';

  @override
  String labParamsCount(int count) {
    return '$count पैरामीटर';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count सीमा से बाहर';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'पैरामीटर मूल्यांकन ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'अस्पताल / डॉक्टर का निदान';

  @override
  String get labEnteredComplaintTitle => 'आपकी शिकायत / नोट';

  @override
  String get labInterpretationTitle => 'सरल व्याख्या और सारांश';

  @override
  String get labCopyDoctorSummaryBtn => 'डॉक्टर को दिखाएँ • कॉपी करें';

  @override
  String get labSummaryCopied => 'लैब सारांश कॉपी हो गया।';

  @override
  String get labExportPdfBtn => 'डॉक्टर PDF रिपोर्ट बनाएँ';

  @override
  String get labAddSheetTitle => 'अस्पताल / रक्त जांच रिपोर्ट जोड़ें';

  @override
  String get labReportTitleField => 'रिपोर्ट शीर्षक';

  @override
  String get labDefaultReportTitle => 'रक्त जांच परिणाम';

  @override
  String get labStep1Upload => '1. PDF या JPG रिपोर्ट अपलोड करें';

  @override
  String get labUploadPdfJpgBtn => 'PDF या JPG अपलोड करें';

  @override
  String get labCameraCaptureBtn => 'फ़ोटो लें';

  @override
  String get labStep2Context => '2. अस्पताल निदान व नोट (वैकल्पिक)';

  @override
  String get labStep2ContextHint =>
      'यदि कोई निदान समझना हो या शिकायत लिखनी हो तो दर्ज करें; दोनों खाली भी छोड़ सकते हैं।';

  @override
  String get labDiagnosisField => 'अस्पताल / डॉक्टर निदान (वैकल्पिक)';

  @override
  String get labComplaintField => 'आपकी शिकायत / प्रश्न (वैकल्पिक)';

  @override
  String get labStep3PasteManual =>
      '3. रिपोर्ट टेक्स्ट पेस्ट करें या मान जोड़ें';

  @override
  String get labParseTextBtn => 'टेक्स्ट पढ़ें और पार्स करें';

  @override
  String get labParamDropdown => 'जांच पैरामीटर';

  @override
  String labValueField(String unit) {
    return 'मान ($unit)';
  }

  @override
  String get labAddValueBtn => '+ जोड़ें';

  @override
  String labParsedValuesTitle(int count) {
    return 'पढ़े गए मान ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'मूल्यांकन करें और सहेजें';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count रिकॉर्ड • बदलाव: $delta • नवीनतम: $status';
  }

  @override
  String get vitalsScreenTitle => 'रक्तचाप और शुगर ट्रैकिंग';

  @override
  String get vitalsCopySummaryTooltip => 'डॉक्टर सारांश कॉपी करें';

  @override
  String get vitalsCopyEmptyMsg =>
      'सारांश बनाने के लिए पहले रक्तचाप या शुगर रीडिंग जोड़ें।';

  @override
  String get vitalsSummaryCopied => 'रक्तचाप व शुगर सारांश कॉपी हो गया।';

  @override
  String get vitalsAddBpBtn => 'रक्तचाप जोड़ें';

  @override
  String get vitalsAddSugarBtn => 'शुगर जोड़ें';

  @override
  String get vitalsBpEmptyTitle => 'अभी तक कोई रक्तचाप रीडिंग नहीं';

  @override
  String get vitalsBpEmptyDesc =>
      'ट्रेंड ग्राफ़ देखने के लिए तारीख के साथ सिस्टोलिक/डायस्टोलिक और पल्स सहेजें।';

  @override
  String get vitalsBpAddFirstBtn => 'पहला रक्तचाप जोड़ें';

  @override
  String get vitalsSugarEmptyTitle => 'अभी तक कोई शुगर रीडिंग नहीं';

  @override
  String get vitalsSugarEmptyDesc =>
      'ट्रेंड देखने के लिए उपवास, भोजन के बाद या यादृच्छिक शुगर रीडिंग सहेजें।';

  @override
  String get vitalsSugarAddFirstBtn => 'पहली शुगर रीडिंग जोड़ें';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'औसत ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • पल्स $pulse';
  }

  @override
  String get vitalsBpHistoryTitle => 'रक्तचाप का इतिहास';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'औसत ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'शुगर का इतिहास';

  @override
  String get vitalsNewBpTitle => 'नई रक्तचाप रीडिंग';

  @override
  String get vitalsSystolicField => 'सिस्टोलिक (ऊपरी)';

  @override
  String get vitalsDiastolicField => 'डायस्टोलिक (निचला)';

  @override
  String get vitalsPulseField => 'पल्स (वैकल्पिक)';

  @override
  String get vitalsNoteField => 'नोट (वैकल्पिक)';

  @override
  String get vitalsSaveBpBtn => 'रक्तचाप सहेजें';

  @override
  String get vitalsNewSugarTitle => 'नई शुगर रीडिंग';

  @override
  String get vitalsSugarValueField => 'रक्त शर्करा (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'शुगर सहेजें';

  @override
  String get chartAddReadingHint => 'चार्ट देखने के लिए रीडिंग जोड़ें';

  @override
  String get loginTermsTitle => 'उपयोग की शर्तें और चिकित्सा सूचना';

  @override
  String get loginTermsCheckbox =>
      'मैं समझता/समझती हूँ कि VisualCheckUp कोई पक्का चिकित्सीय निदान नहीं देता, यह केवल प्रारंभिक जागरूकता के लिए है, और मैं उपयोग की शर्तों से सहमत हूँ।';

  @override
  String get loginTermsRequiredMsg =>
      'साइन इन करने से पहले कृपया उपयोग की शर्तें और चिकित्सा सूचना स्वीकार करें।';

  @override
  String get loginTermsReadMore => 'शर्तें पढ़ें';

  @override
  String get loginTermsModalBody =>
      '• चिकित्सीय निदान नहीं: VisualCheckUp कोई मेडिकल डिवाइस नहीं है और न ही डॉक्टर की जांच या उपचार का विकल्प है।\n\n• केवल प्रारंभिक जानकारी: दृश्य जांच, लैब रिपोर्ट सारांश और BMI/विकास पैमाने केवल जागरूकता और डॉक्टर से परामर्श की तैयारी के लिए हैं।\n\n• आपातकालीन चेतावनी: सीने में दर्द, सांस लेने में तकलीफ या गंभीर लक्षण होने पर तुरंत आपातकालीन चिकित्सा सहायता लें।\n\n• गोपनीयता: आपका स्वास्थ्य डेटा डिफ़ॉल्ट रूप से केवल आपके डिवाइस में सुरक्षित रहता है।';

  @override
  String get loginTermsAcceptBtn => 'मैंने पढ़ा और स्वीकार किया';

  @override
  String atlasFilterAll(int count) {
    return 'सचित्र एटलस ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'तत्काल संकेत ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'घरेलू क्लिनिकल जांच ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'शीघ्र डॉक्टर मूल्यांकन की आवश्यकता वाले संकेत';

  @override
  String get atlasTapToCompareHint =>
      'स्वस्थ संदर्भ के साथ बड़ा करके तुलना करने के लिए किसी भी कार्ड पर टैप करें।';

  @override
  String get atlasVisualCueLabel => 'दृश्य संकेत';

  @override
  String get atlasClinicalContextLabel => 'संभावित क्लिनिकल संदर्भ';

  @override
  String get atlasPossibleContextShort => 'संभावित संदर्भ';

  @override
  String get atlasWarningPrefix => 'चेतावनी';

  @override
  String get atlasCloseBtn => 'बंद करें';

  @override
  String get atlasCaptureProtocolTitle => 'सर्वोत्तम फोटो प्रोटोकॉल';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'घर पर करने योग्य प्रारंभिक क्लिनिकल परीक्षण';

  @override
  String get atlasSelfTestNormalPrefix => 'सामान्य';

  @override
  String get atlasSelfTestWarningPrefix => 'ध्यान दें';

  @override
  String get fitzpatrickScaleTitle =>
      'फिट्ज़पैट्रिक त्वचा फोटोटाइप और ITA° कैलिब्रेशन स्केल';

  @override
  String get fitzpatrickScaleSubtitle =>
      'ऐप आसपास की स्वस्थ त्वचा के ITA° कोण को मापकर आपके त्वचा प्रकार के अनुसार विश्लेषण सीमा को संतुलित करता है।';

  @override
  String get resultVisualCompareTitle => 'सचित्र क्लिनिकल संदर्भ तुलना';

  @override
  String get resultHealthyShort => 'स्वस्थ';

  @override
  String get resultMatchedShort => 'मिलान';

  @override
  String get resultViewFullAtlasBtn => 'पूरा सचित्र एटलस देखें';

  @override
  String get resultHomeSelfTestsBtn => 'घरेलू क्लिनिकल जांच';

  @override
  String get resultClinicalBiomarkersTitle => 'मात्रात्मक क्लिनिकल माप';

  @override
  String get cameraEyeModeSclera => 'मोड: श्वेतपटल (पीलिया)';

  @override
  String get cameraEyeModeConjunctiva => 'निचली पलक (एनीमिया)';

  @override
  String get cameraClinicalAtlasChip => 'क्लिनिकल जांच और एटलस';

  @override
  String get bristolScaleTitle =>
      'ब्रिस्टल मल स्थिरता स्केल (वैकल्पिक • प्रकार 1–7)';

  @override
  String get bristolType1Title => 'प्रकार 1 • सख्त गांठें';

  @override
  String get bristolType2Title => 'प्रकार 2 • गांठदार लंबा';

  @override
  String get bristolType3Title => 'प्रकार 3 • दरारों वाला';

  @override
  String get bristolType4Title => 'प्रकार 4 • चिकना (आदर्श)';

  @override
  String get bristolType5Title => 'प्रकार 5 • नरम टुकड़े';

  @override
  String get bristolType6Title => 'प्रकार 6 • मुलायम / ढीला';

  @override
  String get bristolType7Title => 'प्रकार 7 • पूरी तरह तरल';

  @override
  String get metricFitzpatrickPhototype => 'फिट्ज़पैट्रिक फोटोटाइप';

  @override
  String get metricAbcdeAsymmetry => 'A — विषमता';

  @override
  String get metricAbcdeBorder => 'B — किनारे की अनियमितता';

  @override
  String get metricAbcdeColors => 'C — डर्मोस्कोपिक रंग';

  @override
  String get metricErythemaDelta => 'एरिथेमा सूचकांक Δ';

  @override
  String get metricAnnularClearing => 'वलयाकार केंद्रीय स्पष्टता';

  @override
  String get metricErythemaIndex => 'एरिथेमा सूचकांक (EI)';

  @override
  String get metricScleraBilirubin => 'श्वेतपटल बिलीरुबिन सूचकांक';

  @override
  String get metricHemorrhagePatch => 'सघन रक्तस्राव क्षेत्र';

  @override
  String get metricNailErythema => 'नाखून तल एरिथेमा सूचकांक';

  @override
  String get metricBeauGroove => 'बो अनुप्रस्थ खांचा';

  @override
  String get metricTerryLindsaySplit => 'प्रॉक्सिमल/डिस्टल विभाजन';

  @override
  String get metricSplinterStreak => 'स्प्लिंटर रेखा अनुपात';

  @override
  String get metricGeographicTongue => 'भौगोलिक जीभ स्कोर';

  @override
  String get metricYellowCoating => 'पीली परत का अनुपात';

  @override
  String get metricBristolScale => 'ब्रिस्टल स्केल';

  @override
  String get hubStartNewScan => 'नया स्कैन शुरू करें';

  @override
  String get hubPickFromGallery => 'गैलरी';

  @override
  String hubPastScansTitle(int count) {
    return 'पिछले स्कैन ($count)';
  }

  @override
  String get hubTotalScansLabel => 'कुल स्कैन';

  @override
  String get hubLastScanLabel => 'अंतिम स्कैन';

  @override
  String get hubLatestStatusLabel => 'ताज़ा स्थिति';

  @override
  String get hubFilterAll => 'सभी';

  @override
  String get hubFilterAttention => 'ध्यान / तत्काल';

  @override
  String get hubFilterWithPhoto => 'फोटो सहित';

  @override
  String get hubColPhoto => 'फोटो';

  @override
  String get hubColDate => 'तारीख';

  @override
  String get hubColFinding => 'निष्कर्ष और सारांश';

  @override
  String get hubColStatus => 'स्थिति';

  @override
  String get hubCompareModeBtn => '2 स्कैन की तुलना करें';

  @override
  String hubCompareSelectHint(int count) {
    return 'साथ-साथ तुलना के लिए तालिका से 2 स्कैन चुनें ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'साथ-साथ तुलना करें';

  @override
  String get hubCompareCancelBtn => 'रद्द करें';

  @override
  String get hubCompareSheetTitle => 'स्कैन की साथ-साथ तुलना';

  @override
  String get hubCompareOlderLabel => 'पहले का';

  @override
  String get hubCompareNewerLabel => 'बाद का';

  @override
  String get hubCompareMetricsTitle => 'क्लिनिकल माप तुलना';

  @override
  String hubEmptyTitle(String category) {
    return 'अभी तक कोई $category स्कैन नहीं';
  }

  @override
  String get hubEmptySubtitle =>
      'ऊपर से अपना पहला स्कैन शुरू करें। प्रत्येक जांच छोटे फोटो और विस्तृत रिपोर्ट के साथ यहाँ तिथि अनुसार सहेजी जाती है।';

  @override
  String get hubDoctorSummaryBtn => 'डॉक्टर सारांश';

  @override
  String get photoTapToZoomHint => 'पूर्ण स्क्रीन ज़ूम के लिए फोटो पर टैप करें';

  @override
  String get photoZoomTitle => 'ली गई फोटो';

  @override
  String get resultDeleteRecordTooltip => 'रिकॉर्ड हटाएं';

  @override
  String get resultDeleteConfirmTitle => 'क्या यह स्कैन हटाएं?';

  @override
  String get resultDeleteConfirmBody =>
      'यह जांच रिकॉर्ड आपके स्थानीय इतिहास से स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get resultDeleteBtn => 'हटाएं';

  @override
  String get labLargeTextBtn => 'बड़ा टेक्स्ट';

  @override
  String get labLargeTextOnBtn => 'बड़ा टेक्स्ट: चालू';

  @override
  String get labSeniorOverviewTitle => 'संक्षेप में आपकी रिपोर्ट';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count जांच के मान सामान्य सीमा के भीतर हैं।';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count मान सामान्य सीमा से बाहर हैं — नीचे सरल भाषा में समझाया गया है।';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count मान सीमा से काफी बाहर हैं — कृपया जल्द डॉक्टर को दिखाएं।';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count सामान्य बुनियादी जांच इस रिपोर्ट में शामिल नहीं हैं।';
  }

  @override
  String get labAttentionSectionTitle => 'ध्यान देने योग्य मान';

  @override
  String get labNormalSectionTitle => 'सामान्य मान (चिंता न करें)';

  @override
  String get labMissingSectionTitle =>
      'इस रिपोर्ट में शामिल न होने वाली जांचें';

  @override
  String get labMissingSectionExplain =>
      'हर ब्लड टेस्ट में सभी जांचें नहीं कराई जातीं। नीचे दी गई सामान्य जांचें इस रिपोर्ट में नहीं थीं।';

  @override
  String get labNotInReportBadge => 'रिपोर्ट में नहीं है';

  @override
  String get labWhatItMeansLabel => 'इसका क्या अर्थ है?';

  @override
  String get labWhatToDoLabel => 'आपको क्या करना चाहिए?';

  @override
  String get labAddAnotherPageBtn => 'अगला पेज स्कैन करें';

  @override
  String labPagesReadBadge(int count) {
    return '$count पेज पढ़े गए';
  }

  @override
  String get labPhotoOfflineHint =>
      'रिपोर्ट की फोटो जुड़ गई है। फोटो से मान अपने आप पढ़ने के लिए सेटिंग्स में क्लाउड AI चालू करें या नीचे मैन्युअल रूप से जोड़ें।';

  @override
  String get labAllValuesNormalMsg =>
      'इस रिपोर्ट के सभी दर्ज मान सामान्य सीमा के भीतर हैं।';
}
