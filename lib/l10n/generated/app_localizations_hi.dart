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

  @override
  String get medTitle => 'दवा और अलार्म रिमाइंडर';

  @override
  String get medSubtitle =>
      'फ़ोटो के साथ दवा, इंसुलिन और चेकअप अलार्म ट्रैक करें';

  @override
  String get medMenuTitle => 'दवा अलार्म';

  @override
  String get medHomeCardEmpty => 'अभी कोई अलार्म नहीं — पहला रिमाइंडर जोड़ें';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return 'आज $taken/$total ली गई';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count सक्रिय अलार्म';
  }

  @override
  String get medTabToday => 'आज';

  @override
  String get medTabAll => 'सभी अलार्म';

  @override
  String get medAddAlarm => 'नया अलार्म जोड़ें';

  @override
  String get medEditAlarm => 'अलार्म संपादित करें';

  @override
  String get medCatPill => 'दवा / गोली';

  @override
  String get medCatDiabetes => 'शुगर की दवा / इंसुलिन';

  @override
  String get medCatBloodPressure => 'बीपी की दवा';

  @override
  String get medCatVitamin => 'विटामिन / सप्लीमेंट';

  @override
  String get medCatDropsCream => 'आई ड्रॉप / क्रीम';

  @override
  String get medCatCheckup => 'जाँच / माप';

  @override
  String get medCatOther => 'अन्य';

  @override
  String get medMealAnytime => 'कभी भी';

  @override
  String get medMealBefore => 'खाने से पहले';

  @override
  String get medMealAfter => 'खाने के बाद';

  @override
  String get medMealWith => 'खाने के साथ';

  @override
  String get medMealBedtime => 'सोने से पहले';

  @override
  String get medDayMon => 'सोम';

  @override
  String get medDayTue => 'मंगल';

  @override
  String get medDayWed => 'बुध';

  @override
  String get medDayThu => 'गुरु';

  @override
  String get medDayFri => 'शुक्र';

  @override
  String get medDaySat => 'शनि';

  @override
  String get medDaySun => 'रवि';

  @override
  String get medEveryDay => 'हर दिन';

  @override
  String get medWeekdays => 'सप्ताह के दिन';

  @override
  String get medWeekends => 'सप्ताहांत';

  @override
  String get medFieldCategory => 'श्रेणी';

  @override
  String get medFieldName => 'दवा / रिमाइंडर का नाम';

  @override
  String get medFieldNameHint => 'जैसे: मेटफॉर्मिन 1000 mg, शाम का इंसुलिन...';

  @override
  String get medFieldNameRequired => 'कृपया दवा या रिमाइंडर का नाम लिखें।';

  @override
  String get medFieldDosage => 'खुराक / मात्रा (वैकल्पिक)';

  @override
  String get medFieldDosageHint => 'जैसे: 1 गोली, 12 यूनिट, 2 बूँद';

  @override
  String get medFieldDescription => 'रिमाइंडर नोट (अलार्म पर दिखेगा)';

  @override
  String get medFieldDescriptionHint =>
      'जैसे: नाश्ते से 30 मिनट पहले पानी के साथ लें';

  @override
  String get medFieldMealTiming => 'लेने का समय';

  @override
  String get medFieldTime => 'अलार्म का समय';

  @override
  String get medFieldDays => 'दोहराने के दिन';

  @override
  String get medFieldPhoto => 'दवा की फ़ोटो (अलार्म बजने पर दिखेगी)';

  @override
  String get medTakePhoto => 'फ़ोटो लें';

  @override
  String get medPickGallery => 'गैलरी से';

  @override
  String get medRemovePhoto => 'फ़ोटो हटाएँ';

  @override
  String get medPhotoHint =>
      'दवा के डिब्बे या इंसुलिन पेन की फ़ोटो लें ताकि अलार्म बजने पर स्क्रीन पर साफ दिखे।';

  @override
  String get medSoundToggle => 'अलार्म ध्वनि';

  @override
  String get medVibrateToggle => 'कंपन';

  @override
  String get medSaveAlarm => 'अलार्म सहेजें';

  @override
  String get medAlarmSaved => 'अलार्म सहेजा और सेट किया गया।';

  @override
  String get medAlarmDeleted => 'अलार्म हटाया गया।';

  @override
  String get medDeleteConfirmTitle => 'अलार्म हटाएँ';

  @override
  String medDeleteConfirmBody(String title) {
    return 'क्या आप \"$title\" अलार्म को स्थायी रूप से हटाना चाहते हैं?';
  }

  @override
  String get medStatusTaken => 'ली गई';

  @override
  String get medStatusSnoozed => 'टाली गई';

  @override
  String get medStatusSkipped => 'छोड़ी गई';

  @override
  String get medStatusPending => 'बाकी है';

  @override
  String get medActionTaken => 'दवा ले ली';

  @override
  String get medActionSnooze => '10 मिनट बाद';

  @override
  String get medActionSkip => 'आज छोड़ें';

  @override
  String get medActionUndo => 'वापस लें';

  @override
  String get medActionPreviewAlarm => 'अलार्म जांचें';

  @override
  String get medRingHeader => 'दवा का समय';

  @override
  String get medRingNoteTitle => 'रिमाइंडर नोट';

  @override
  String get medRingNoPhoto => 'दवा की फ़ोटो नहीं जोड़ी गई';

  @override
  String get medRingTapZoom => 'बड़ा देखने के लिए फ़ोटो पर टैप करें';

  @override
  String get medRingSnoozedToast => '10 मिनट के लिए टाला गया।';

  @override
  String get medRingTakenToast => 'बहुत बढ़िया! आज की खुराक दर्ज हो गई।';

  @override
  String get medTodayProgressTitle => 'आज की दवा योजना';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'अगला अलार्म: $time • $title';
  }

  @override
  String get medNoTodayAlarms => 'आज के लिए कोई दवा अलार्म सेट नहीं है।';

  @override
  String get medEmptyTitle => 'अभी कोई दवा अलार्म नहीं है';

  @override
  String get medEmptyBody =>
      'शुगर की दवा, इंसुलिन या बीपी की दवा के लिए फ़ोटो वाले अलार्म जोड़ें। समय होने पर दवा की फ़ोटो और आपका नोट स्क्रीन पर स्पष्ट दिखेगा।';

  @override
  String get medQuickPresetDiabetes => 'शुगर / इंसुलिन';

  @override
  String get medQuickPresetBp => 'बीपी दवा';

  @override
  String get medQuickPresetVitamin => 'विटामिन';

  @override
  String get dietMenuTitle => 'डाइट और AI कैलोरी ट्रैकर';

  @override
  String get dietHomeCardTitle => 'डाइट और भोजन योजना';

  @override
  String get dietHomeCardEmpty => 'रेडी डाइट, पालन और वजन ट्रैकिंग';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'दिन $day/$total • $percent% पालन';
  }

  @override
  String get dietCalorieQuickTitle => 'AI प्लेट कैलोरी कैलकुलेटर';

  @override
  String get dietCalorieQuickSubtitle =>
      'थाली की फ़ोटो खींचें, कैलोरी और पोषण जानें';

  @override
  String get dietTabActive => 'मेरी डाइट';

  @override
  String get dietTabTemplates => 'तैयार डाइट';

  @override
  String get dietTabWeight => 'वजन';

  @override
  String get dietTabCalories => 'AI कैलोरी';

  @override
  String get dietStartDiet => 'डाइट शुरू करें';

  @override
  String get dietRestartOrChange => 'डाइट बदलें';

  @override
  String get dietEndDiet => 'डाइट समाप्त करें';

  @override
  String get dietEndDietConfirm =>
      'सक्रिय डाइट प्लान समाप्त करें? आपका पालन और वजन रिकॉर्ड सुरक्षित रहेगा।';

  @override
  String get dietNoActiveTitle => 'अभी कोई सक्रिय डाइट नहीं';

  @override
  String get dietNoActiveBody =>
      'तैयार डाइट प्लान चुनें और दैनिक पालन व वजन में बदलाव को ट्रैक करें।';

  @override
  String get dietBrowseTemplates => 'तैयार डाइट देखें';

  @override
  String get dietStartDate => 'शुरुआत की तारीख';

  @override
  String get dietEndDate => 'समाप्ति की तारीख';

  @override
  String get dietStartWeight => 'शुरुआती वजन (किग्रा)';

  @override
  String get dietTargetWeight => 'लक्ष्य वजन (किग्रा)';

  @override
  String get dietDailyCalorieTarget => 'दैनिक कैलोरी लक्ष्य (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days दिन';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'दिन $day / $total';
  }

  @override
  String dietDaysLeft(int days) {
    return '$days दिन शेष';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'पालन: $percent%';
  }

  @override
  String get dietFollowed => 'पालन किया';

  @override
  String get dietNotFollowed => 'नहीं किया';

  @override
  String get dietPending => 'बाकी है';

  @override
  String get dietSlotBreakfast => 'नाश्ता';

  @override
  String get dietSlotMorningSnack => 'सुबह का स्नैक';

  @override
  String get dietSlotLunch => 'दोपहर का भोजन';

  @override
  String get dietSlotAfternoonSnack => 'शाम का स्नैक';

  @override
  String get dietSlotDinner => 'रात का भोजन';

  @override
  String get dietAlternativesLabel => 'विकल्प';

  @override
  String dietWaterTarget(String liters) {
    return 'पानी का लक्ष्य: $liters ली.';
  }

  @override
  String get dietRulesTitle => 'डाइट दिशानिर्देश';

  @override
  String get dietSampleMenuTitle => 'नमूना दैनिक मेनू';

  @override
  String get dietStartedToast => 'डाइट प्लान शुरू हो गया!';

  @override
  String get dietEndedToast => 'सक्रिय डाइट प्लान समाप्त हुआ।';

  @override
  String get dietWeightLogTitle => 'डाइट वजन ट्रैकिंग';

  @override
  String get dietWeightAdd => 'वजन दर्ज करें';

  @override
  String get dietWeightField => 'वर्तमान वजन (किग्रा)';

  @override
  String get dietWeightNote => 'नोट (वैकल्पिक)';

  @override
  String get dietWeightNoteHint => 'जैसे: सुबह खाली पेट वजन';

  @override
  String get dietWeightEmpty => 'अभी कोई वजन रिकॉर्ड नहीं है। पहला वजन जोड़ें।';

  @override
  String get dietWeightCurrent => 'वर्तमान';

  @override
  String get dietWeightTarget => 'लक्ष्य';

  @override
  String get dietWeightChange => 'बदलाव';

  @override
  String get dietWeightSaved => 'वजन सहेजा गया।';

  @override
  String get dietCalorieTitle => 'AI प्लेट कैलोरी कैलकुलेटर';

  @override
  String get dietCalorieSubtitle =>
      'डाइट के बिना भी उपयोग करें — थाली की फ़ोटो लें या भोजन लिखें।';

  @override
  String get dietSnapPlateCamera => 'थाली की फ़ोटो लें';

  @override
  String get dietPickPlateGallery => 'गैलरी से चुनें';

  @override
  String get dietFoodDescLabel => 'भोजन विवरण / मात्रा (वैकल्पिक)';

  @override
  String get dietFoodDescHint => 'जैसे: ग्रिल्ड चिकन, सलाद, दही, दाल';

  @override
  String get dietCalculateFromText => 'टेक्स्ट से गणना करें';

  @override
  String get dietAnalyzingPlate => 'कैलोरी और पोषक तत्वों का विश्लेषण...';

  @override
  String get dietResultTitle => 'कैलोरी और पोषण विश्लेषण';

  @override
  String get dietAiPoweredBadge => 'Gemini AI विज़न';

  @override
  String get dietOnDeviceBadge => 'स्मार्ट लोकल अनुमान';

  @override
  String get dietProtein => 'प्रोटीन';

  @override
  String get dietCarbs => 'कार्ब्स';

  @override
  String get dietFat => 'वसा';

  @override
  String get dietFiber => 'फाइबर';

  @override
  String get dietPortionScale => 'मात्रा';

  @override
  String get dietSaveMealLog => 'आज के लॉग में सहेजें';

  @override
  String get dietMealLoggedToast => 'भोजन की कैलोरी आज के लॉग में जुड़ गई।';

  @override
  String get dietTodayTotalCalories => 'आज का कुल';

  @override
  String get dietRecentScans => 'विश्लेषित भोजन';

  @override
  String get dietNoScansYet =>
      'अभी कोई भोजन स्कैन नहीं हुआ। थाली की फ़ोटो लें।';

  @override
  String dietHealthScore(int score) {
    return 'संतुलन स्कोर: $score/10';
  }

  @override
  String get dietTodayLabel => 'आज';

  @override
  String get medCatHerbalTea => 'हर्बल चाय / काढ़ा';

  @override
  String get medCatCustom => 'अन्य (स्वयं लिखें)';

  @override
  String get medFieldCustomCategory => 'कस्टम श्रेणी का नाम';

  @override
  String get medFieldCustomCategoryHint =>
      'जैसे: प्रोबायोटिक, पानी, व्यायाम...';

  @override
  String get medQuickPresetHerbalTea => 'हर्बल चाय';

  @override
  String get dietCreateCustom => 'अपनी खुद की डाइट बनाएं';

  @override
  String get dietCreateCustomSubtitle =>
      'अपने डायटीशियन की सूची या खुद की भोजन योजना लिखें';

  @override
  String get dietCustomNameLabel => 'डाइट का नाम';

  @override
  String get dietCustomNameHint => 'जैसे: मेरी डायटीशियन योजना, कस्टम मेनू...';

  @override
  String get dietCustomNameRequired => 'कृपया डाइट का नाम लिखें।';

  @override
  String get dietCustomMealHint => 'इस भोजन में आप क्या खाएंगे?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (वैकल्पिक)';

  @override
  String get dietCustomAtLeastOneMeal => 'कृपया कम से कम एक भोजन लिखें।';

  @override
  String get dietCustomTemplatesTitle => 'मेरी कस्टम डाइट योजनाएं';

  @override
  String get dietReadyTemplatesTitle => 'तैयार डाइट टेम्प्लेट';

  @override
  String get donateTooltip => 'सहयोग / दान करें';

  @override
  String get donateMenuLabel => 'VisualCheckUp का समर्थन करें';

  @override
  String get donateMenuSubtitle =>
      'कॉफ़ी, भोजन या उपहार देकर मुफ़्त स्वास्थ्य ऐप का समर्थन करें';

  @override
  String get donatePopupTitle => 'VisualCheckUp का समर्थन करें';

  @override
  String get donatePopupSubtitle =>
      'आपका स्वैच्छिक सहयोग हमें स्वास्थ्य जाँच, लैब रिपोर्ट, दवा अलार्म और डाइट फ़ीचर बेहतर बनाने में मदद करता है।';

  @override
  String get donateTierCoffeeTitle => 'कॉफ़ी पिलाएँ';

  @override
  String get donateTierCoffeeDesc => 'डेवलपमेंट के लिए एक गर्म कप कॉफ़ी';

  @override
  String get donateTierMealTitle => 'भोजन उपहार';

  @override
  String get donateTierMealDesc => 'नए स्वास्थ्य फ़ीचर्स के लिए बेहतरीन सहयोग';

  @override
  String get donateTierGiftTitle => 'उपहार भेजें';

  @override
  String get donateTierGiftDesc => 'AI और सर्वर खर्च में योगदान';

  @override
  String get donateTierGoldTitle => 'बड़ा सहयोग';

  @override
  String get donateTierGoldDesc =>
      'आगामी हेल्थ मॉड्यूल और भाषाओं के लिए समर्थन';

  @override
  String get donateTierHeroTitle => 'हेल्थ हीरो';

  @override
  String get donateTierHeroDesc =>
      'सभी परिवारों के मुफ़्त स्वास्थ्य ट्रैकिंग में योगदान';

  @override
  String get donatePopularBadge => 'लोकप्रिय';

  @override
  String donateConfirmButton(String price) {
    return '$price सहयोग करें';
  }

  @override
  String get donateLaterButton => 'बाद में';

  @override
  String get donateThanksTitle => 'आपके सहयोग के लिए धन्यवाद!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'आपका $tier ($price) सहयोग हमारे लिए बहुत मायने रखता है। धन्यवाद!';
  }

  @override
  String get donateSupporterBadge => 'समर्थक • धन्यवाद!';

  @override
  String get donateStoreNotice =>
      'एकमुश्त स्वैच्छिक सहयोग • कोई सब्सक्रिप्शन नहीं';

  @override
  String get medFieldAlarmSound => 'अलार्म की ध्वनि';

  @override
  String get medAlarmSoundClassic => 'क्लासिक अलार्म';

  @override
  String get medAlarmSoundClassicDesc => 'स्पष्ट अलार्म घड़ी की रिंग';

  @override
  String get medAlarmSoundGentle => 'सौम्य धुन';

  @override
  String get medAlarmSoundGentleDesc => 'शांत और मधुर घंटी की धुन';

  @override
  String get medAlarmSoundRadar => 'आधुनिक अलार्म';

  @override
  String get medAlarmSoundRadarDesc => 'स्पष्ट लयबद्ध अलार्म टोन';

  @override
  String get medAlarmSoundBell => 'स्वास्थ्य घंटी';

  @override
  String get medAlarmSoundBellDesc => 'चमकीली क्लासिक डबल बेल रिंग';

  @override
  String get medAlarmSoundUrgent => 'तेज़ आपात अलार्म';

  @override
  String get medAlarmSoundUrgentDesc => 'ज़रूरी दवाओं के लिए तेज़ ध्वनि';

  @override
  String get medAlarmSoundSystem => 'फ़ोन अलार्म टोन';

  @override
  String get medAlarmSoundSystemDesc =>
      'फ़ोन की डिफ़ॉल्ट अलार्म रिंगटोन का उपयोग करता है';

  @override
  String get medSoundPreviewPlay => 'सुनें';

  @override
  String get medSoundPreviewStop => 'रोकें';

  @override
  String get medSoundSilent => 'मौन';

  @override
  String get medPreviewModeBadge => 'प्रीव्यू';

  @override
  String get commMenuTitle => 'हेल्थ कम्युनिटी';

  @override
  String get commHomeSubtitle =>
      'दुनिया भर के स्वास्थ्य साथी, प्रोफ़ाइल लाइक और सुरक्षित चैट';

  @override
  String get commTabDiscover => 'खोजें';

  @override
  String get commTabMessages => 'संदेश';

  @override
  String get commTabMyProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get commSafetyBanner =>
      'केवल स्वास्थ्य अनुभव और प्रेरणा के लिए — चिकित्सीय सलाह नहीं। आपकी निजी रिपोर्ट और फ़ोटो कभी साझा नहीं होतीं।';

  @override
  String get commSearchHint => 'नाम, शहर या स्वास्थ्य लक्ष्य खोजें...';

  @override
  String get commFilterAllGoals => 'सभी लक्ष्य';

  @override
  String get commFilterAllCountries => 'दुनिया भर में';

  @override
  String get commEmptyDiscover =>
      'आपके फ़िल्टर से कोई स्वास्थ्य प्रोफ़ाइल नहीं मिली।';

  @override
  String get commGoalDiabetes => 'डायबिटीज़ और ब्लड शुगर';

  @override
  String get commGoalBloodPressure => 'ब्लड प्रेशर और हृदय';

  @override
  String get commGoalWeightDiet => 'वज़न और स्वस्थ आहार';

  @override
  String get commGoalHealthyLiving => 'स्वस्थ जीवनशैली';

  @override
  String get commGoalHerbalWellness => 'हर्बल चाय और प्राकृतिक देखभाल';

  @override
  String get commGoalParentingGrowth => 'माता-पिता और बच्चों की वृद्धि';

  @override
  String get commGoalSkinCare => 'त्वचा और दैनिक देखभाल';

  @override
  String get commGoalFitnessWalk => 'वॉकिंग और व्यायाम';

  @override
  String get commGoalSleepStress => 'नींद और तनाव संतुलन';

  @override
  String commLikesCount(int count) {
    return '$count लाइक';
  }

  @override
  String get commLikeAction => 'प्रोफ़ाइल लाइक करें';

  @override
  String get commUnlikeAction => 'लाइक किया गया';

  @override
  String get commSendMessage => 'संदेश भेजें';

  @override
  String get commMessagesDisabled => 'इस सदस्य ने सीधे संदेश बंद रखे हैं।';

  @override
  String get commOptInTitle => 'ग्लोबल हेल्थ कम्युनिटी से जुड़ें';

  @override
  String get commOptInBody =>
      'दुनिया भर में समान स्वास्थ्य लक्ष्य वाले लोगों से जुड़ें। शामिल होना पूरी तरह वैकल्पिक है — आपकी मेडिकल रिपोर्ट 100% निजी रहती हैं।';

  @override
  String get commOptInButton => 'मेरी स्वास्थ्य प्रोफ़ाइल बनाएँ';

  @override
  String get commFieldDisplayName => 'प्रदर्शित नाम';

  @override
  String get commFieldNickname => 'यूज़रनेम (@handle)';

  @override
  String get commFieldCountry => 'देश';

  @override
  String get commFieldCity => 'शहर (वैकल्पिक)';

  @override
  String get commFieldLanguage => 'पसंदीदा भाषा';

  @override
  String get commFieldGoals => 'स्वास्थ्य और वेलनेस लक्ष्य';

  @override
  String get commFieldBio => 'मेरे बारे में और स्वास्थ्य यात्रा';

  @override
  String get commFieldDailyFocus => 'दैनिक स्वास्थ्य फ़ोकस';

  @override
  String get commPrivacySection => 'गोपनीयता और संदेश सेटिंग्स';

  @override
  String get commToggleDiscoverable => 'ग्लोबल खोज में मेरी प्रोफ़ाइल दिखाएँ';

  @override
  String get commToggleHideRealName => 'असली नाम छिपाएँ (केवल @handle)';

  @override
  String get commToggleHidePhoto => 'प्रोफ़ाइल फ़ोटो छिपाएँ';

  @override
  String get commToggleAllowMessages => 'सीधे संदेश की अनुमति दें';

  @override
  String get commToggleRequireApproval =>
      'नए संदेश अनुरोध के लिए मेरी मंज़ूरी लें';

  @override
  String get commUploadPhoto => 'फ़ोटो अपलोड करें';

  @override
  String get commRemovePhoto => 'फ़ोटो हटाएँ';

  @override
  String get commSaveProfile => 'प्रोफ़ाइल सहेजें';

  @override
  String get commProfileSaved => 'कम्युनिटी प्रोफ़ाइल अपडेट हो गई।';

  @override
  String get commLeaveCommunity => 'कम्युनिटी छोड़ें और पब्लिक प्रोफ़ाइल हटाएँ';

  @override
  String get commLeftCommunity => 'आपकी पब्लिक प्रोफ़ाइल हटा दी गई है।';

  @override
  String get commInboxEmpty =>
      'अभी कोई बातचीत नहीं। स्वास्थ्य साथी खोजें और नमस्ते कहें!';

  @override
  String get commMessageRequestBadge => 'संदेश अनुरोध';

  @override
  String get commRequestBannerTitle => 'नया संदेश अनुरोध';

  @override
  String get commRequestBannerBody =>
      'चैट जारी रखने के लिए स्वीकार करें, या अस्वीकार/ब्लॉक करें।';

  @override
  String get commRequestAccept => 'स्वीकार करें';

  @override
  String get commRequestDecline => 'अस्वीकार करें';

  @override
  String get commChatPlaceholder => 'सहयोगी संदेश लिखें...';

  @override
  String get commAttachPhoto => 'फ़ोटो जोड़ें';

  @override
  String get commPhotoLabel => 'फ़ोटो';

  @override
  String get commRateLimited =>
      'अगला संदेश भेजने से पहले कुछ सेकंड प्रतीक्षा करें।';

  @override
  String get commBlockedNotice =>
      'ब्लॉक सेटिंग के कारण संदेश नहीं भेजा जा सकता।';

  @override
  String get commMuteChat => 'म्यूट';

  @override
  String get commUnmuteChat => 'अनम्यूट';

  @override
  String get commHideChat => 'चैट छिपाएँ';

  @override
  String get commBlockUser => 'ब्लॉक करें';

  @override
  String get commUnblockUser => 'अनब्लॉक करें';

  @override
  String get commBlockedToast => 'उपयोगकर्ता को ब्लॉक कर दिया गया।';

  @override
  String get commReportUser => 'रिपोर्ट करें';

  @override
  String get commReportTitle => 'सदस्य या संदेश की रिपोर्ट करें';

  @override
  String get commReportReasonInappropriate => 'अनुचित सामग्री';

  @override
  String get commReportReasonSpam => 'स्पैम या विज्ञापन';

  @override
  String get commReportReasonHarassment => 'उत्पीड़न या घृणास्पद भाषा';

  @override
  String get commReportReasonMisinfo =>
      'असुरक्षित चिकित्सीय सलाह / गलत जानकारी';

  @override
  String get commReportReasonOther => 'अन्य';

  @override
  String get commReportNoteHint => 'वैकल्पिक विवरण...';

  @override
  String get commReportSubmit => 'रिपोर्ट भेजें';

  @override
  String get commReportSent => 'धन्यवाद। आपकी सुरक्षा रिपोर्ट भेज दी गई है।';

  @override
  String get commDeleteForMe => 'मेरे लिए हटाएँ';

  @override
  String get commDeleteForEveryone => 'सभी के लिए हटाएँ';

  @override
  String get commOnlineNow => 'ऑनलाइन';

  @override
  String get commFilterOnlineOnly => 'अभी ऑनलाइन';

  @override
  String get commFilterSameCondition => 'समान बीमारी';

  @override
  String get commFilterAllConditions => 'सभी बीमारियाँ';

  @override
  String get commSameConditionPrompt =>
      'समान स्वास्थ्य स्थिति वाले लोगों को खोजने के लिए मेरी प्रोफ़ाइल में दीर्घकालिक बीमारी जोड़ें।';

  @override
  String get commFieldChronicConditions => 'दीर्घकालिक बीमारियाँ (वैकल्पिक)';

  @override
  String get commFieldCustomCondition => 'अन्य दीर्घकालिक स्थिति (वैकल्पिक)';

  @override
  String get commFieldCustomConditionHint => 'जैसे: फ़ाइब्रोमायल्जिया, PCOS...';

  @override
  String get commToggleShowConditions =>
      'मेरी प्रोफ़ाइल पर दीर्घकालिक बीमारियाँ दिखाएँ';

  @override
  String get commToggleShowOnline => 'मेरा ऑनलाइन स्टेटस दिखाएँ';

  @override
  String get condType1Diabetes => 'टाइप 1 डायबिटीज़';

  @override
  String get condType2Diabetes => 'टाइप 2 डायबिटीज़';

  @override
  String get condHypertension => 'हाई ब्लड प्रेशर';

  @override
  String get condAsthmaCopd => 'अस्थमा / COPD';

  @override
  String get condThyroidHashimoto => 'थायरॉइड / हाशिमोटो';

  @override
  String get condMigraine => 'माइग्रेन';

  @override
  String get condHeartCondition => 'हृदय रोग';

  @override
  String get condCeliacIbs => 'सीलिएक / IBS';

  @override
  String get condArthritis => 'गठिया / अर्थराइटिस';

  @override
  String get condAnemia => 'एनीमिया';

  @override
  String get condKidneyHealth => 'किडनी स्वास्थ्य';

  @override
  String get condEczemaPsoriasis => 'एक्ज़िमा / सोरायसिस';

  @override
  String get adminPanelTitle => 'एडमिन कंट्रोल पैनल';

  @override
  String get adminTabStats => 'आँकड़े';

  @override
  String get adminTabAnnouncements => 'घोषणाएँ';

  @override
  String get adminTabPromotions => 'विज्ञापन';

  @override
  String get adminTabUsers => 'उपयोगकर्ता';

  @override
  String get adminTabReports => 'रिपोर्ट्स';

  @override
  String get adminStatOnline => 'ऑनलाइन';

  @override
  String get adminStatMembers => 'सदस्य';

  @override
  String get adminStatLikes => 'लाइक';

  @override
  String get adminStatChats => 'चैट्स';

  @override
  String get adminStatPendingReports => 'लंबित रिपोर्ट';

  @override
  String get adminStatActiveBanners => 'सक्रिय बैनर';

  @override
  String get adminConditionBreakdown => 'दीर्घकालिक बीमारियों का विवरण';

  @override
  String get adminNewAnnouncement => 'नई घोषणा';

  @override
  String get adminNewPromotion => 'नया विज्ञापन / बैनर';

  @override
  String get adminFieldTitle => 'शीर्षक';

  @override
  String get adminFieldMessage => 'संदेश / विवरण';

  @override
  String get adminFieldLink => 'लिंक URL (वैकल्पिक)';

  @override
  String get adminFieldPlacement => 'स्थान';

  @override
  String get adminPlacementHome => 'होम शीर्ष';

  @override
  String get adminPlacementCommunity => 'कम्युनिटी शीर्ष';

  @override
  String get adminPlacementProfile => 'प्रोफ़ाइल शीर्ष';

  @override
  String get adminTypeInfo => 'घोषणा';

  @override
  String get adminTypeHealthTip => 'स्वास्थ्य टिप';

  @override
  String get adminTypeWarning => 'चेतावनी';

  @override
  String get adminTypeCampaign => 'अभियान';

  @override
  String get adminSearchUsersHint => 'नाम, देश या बीमारी से खोजें...';

  @override
  String get adminActionVerify => 'सत्यापित करें';

  @override
  String get adminActionUnverify => 'सत्यापन हटाएँ';

  @override
  String get adminActionSuspend => 'निलंबित करें';

  @override
  String get adminActionUnsuspend => 'बहाल करें';

  @override
  String get adminStatusSuspended => 'निलंबित';

  @override
  String get adminStatusVerified => 'सत्यापित';

  @override
  String get adminReportResolve => 'हल करें';

  @override
  String get adminReportDismiss => 'खारिज करें';

  @override
  String get adminNoReports => 'कोई सुरक्षा रिपोर्ट नहीं।';

  @override
  String get adminNoAnnouncements => 'अभी कोई घोषणा नहीं।';

  @override
  String get adminNoPromotions => 'अभी कोई विज्ञापन नहीं।';

  @override
  String get commMusicSectionTitle => 'एकाग्रता और शांति संगीत';

  @override
  String get commMusicTitleField => 'ट्रैक / प्लेलिस्ट का नाम (वैकल्पिक)';

  @override
  String get commMusicUrlField => 'संगीत लिंक (YouTube, Spotify, SoundCloud)';

  @override
  String get commMusicInvalidUrl =>
      'कृपया एक मान्य YouTube, Spotify, Apple Music या SoundCloud लिंक दर्ज करें।';

  @override
  String get commMusicEmpty => 'अभी तक कोई एकाग्रता संगीत नहीं जोड़ा गया है।';

  @override
  String get commMusicListenAction => 'सुनें';

  @override
  String get commMusicLikeAction => 'संगीत पसंद करें';

  @override
  String get commMusicListenersTitle => 'संगीत सुनने वाले';

  @override
  String get commMusicListenersEmpty => 'अभी तक किसी ने यह संगीत नहीं सुना है।';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count श्रोता';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '$count बार सुना गया';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '${count}x';
  }

  @override
  String get commProfileLikersTitle => 'प्रोफ़ाइल लाइक';

  @override
  String get commProfileLikersEmpty => 'अभी तक कोई प्रोफ़ाइल लाइक नहीं है।';

  @override
  String get commSocialsSectionTitle => 'सोशल मीडिया खाते';

  @override
  String get commToggleShowSocials => 'मेरे सोशल मीडिया खाते दिखाएं';

  @override
  String get commSocialsHiddenHint => 'अन्य सदस्यों से छिपा हुआ';

  @override
  String get commSocialsEmpty => 'अभी तक कोई सोशल खाता नहीं जोड़ा गया है।';

  @override
  String get commPreviewMyProfile => 'मेरा प्रोफ़ाइल पूर्वावलोकन';

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
  String get doctorSearchTitle => 'देश के अनुसार डॉक्टर खोजें';

  @override
  String get doctorSearchSubtitle =>
      'Search licensed doctors by country & specialty for guidance and patient follow-up';

  @override
  String get doctorSearchHomeCta => 'Search Doctors';

  @override
  String get doctorApplyCta => 'डॉक्टर आवेदन';

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
  String get adminTabDoctors => 'डॉक्टर';

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
  String get dailyHealthTipTitle => 'आज की स्वास्थ्य सलाह';

  @override
  String birthdayCardTitle(String name) {
    return 'जन्मदिन मुबारक, $name! 🎉';
  }

  @override
  String get birthdayCardSubtitle =>
      'आपको स्वस्थ और खुशहाल वर्ष की शुभकामनाएँ।';

  @override
  String get commDrawerProfileSubtitle => 'आपका सोशल कार्ड, मूड और आँकड़े';

  @override
  String get commDrawerCommunitySubtitle => 'खोजें • वॉल • समूह • चैट';

  @override
  String get commTabWall => 'वॉल';

  @override
  String get commTabGroups => 'समूह';

  @override
  String get commEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get commDoneEditing => 'रद्द करें';

  @override
  String get commFriendsStat => 'दोस्त';

  @override
  String get commAddFriend => 'दोस्त जोड़ें';

  @override
  String get commFriendPending => 'अनुरोध भेजा';

  @override
  String get commFriendsConnected => 'दोस्त';

  @override
  String get commFriendsSheetTitle => 'स्वास्थ्य मित्र';

  @override
  String get commFriendsEmpty =>
      'अभी कोई स्वास्थ्य मित्र नहीं है। खोजें टैब से जुड़ें!';

  @override
  String get commMoodSectionTitle => 'आज का मूड';

  @override
  String get commMoodEnergetic => 'ऊर्जावान';

  @override
  String get commMoodCalm => 'शांत';

  @override
  String get commMoodGrateful => 'आभारी';

  @override
  String get commMoodFocused => 'केंद्रित';

  @override
  String get commMoodTired => 'थका हुआ';

  @override
  String get commMoodRecovering => 'स्वस्थ हो रहा';

  @override
  String get commWallTitle => 'अनुभव और प्रश्न वॉल';

  @override
  String get commWallNewPost => 'पोस्ट करें';

  @override
  String get commWallPostTitleHint =>
      'शीर्षक (जैसे: सुबह की सैर और शुगर संतुलन)';

  @override
  String get commWallPostBodyHint => 'अपना अनुभव या प्रश्न साझा करें...';

  @override
  String get commWallPublishBtn => 'प्रकाशित करें';

  @override
  String get commWallDoctorReplyBadge => 'डॉक्टर का उत्तर';

  @override
  String get commWallCommentsTitle => 'टिप्पणियाँ';

  @override
  String get commWallCommentHint => 'सहायक टिप्पणी लिखें...';

  @override
  String get commWallEmpty => 'अभी कोई पोस्ट नहीं। सबसे पहले साझा करें!';

  @override
  String get commGroupsTitle => 'सहायता समूह';

  @override
  String get commGroupsCreate => 'समूह बनाएँ';

  @override
  String get commGroupsJoin => 'जुड़ें';

  @override
  String get commGroupsJoined => 'जुड़े हुए';

  @override
  String get commGroupsOpenChat => 'समूह चैट';

  @override
  String commGroupsMembersCount(int count) {
    return '$count सदस्य';
  }

  @override
  String get commGroupsNameHint => 'समूह का नाम';

  @override
  String get commGroupsDescHint => 'समूह विवरण और विषय';

  @override
  String get commGroupsEmpty => 'इस फ़िल्टर के लिए कोई समूह नहीं मिला।';

  @override
  String get commToggleOnlyFriendsMsg => 'केवल दोस्त मुझे संदेश भेज सकें';

  @override
  String get commOpenCommunityCta => 'समुदाय';

  @override
  String get sfbGoToProfile => 'प्रोफ़ाइल देखें';

  @override
  String get sfbMyMessages => 'मेरे संदेश';

  @override
  String get sfbMyFriends => 'मेरे दोस्त';

  @override
  String get sfbSeeAll => 'सभी देखें';

  @override
  String get sfbNewMembersTitle => 'नए सदस्य';

  @override
  String get sfbActiveMembersTitle => 'सबसे सक्रिय सदस्य';

  @override
  String get sfbLatestPostsTitle => 'नवीनतम पोस्ट';

  @override
  String get sfbViewDetails => 'विवरण देखें';

  @override
  String get sfbAdminBadge => 'एडमिन';

  @override
  String get sfbAdminConsoleTitle => 'त्वरित एडमिन कंसोल';

  @override
  String get sfbAdminFounderBanner => 'प्लेटफ़ॉर्म संस्थापक एवं सिस्टम एडमिन';

  @override
  String get splashTagline => 'AI-संचालित\nस्वास्थ्य ट्रैकिंग';
}
