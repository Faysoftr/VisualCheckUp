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
}
