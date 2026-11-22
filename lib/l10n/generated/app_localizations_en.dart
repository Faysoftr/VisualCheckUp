// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'This app does not provide a medical diagnosis; it is for informational and visual self-awareness purposes only.';

  @override
  String get disclaimerTitle => 'Important Medical Notice';

  @override
  String get disclaimerFull =>
      'VisualCheckUp provides a visual self-awareness pre-assessment based on color and appearance cues. It is not a medical device and never replaces a doctor\'s examination, lab testing, or medical diagnosis.\n\n• Ambient lighting, camera sensors, and screen calibration directly affect color perception.\n• Seek medical attention promptly for severe pain, bleeding, high fever, jaundice, black/clay stools, sudden vision changes, or breathing difficulty.\n• Privacy: Captured images are processed on your device by default.';

  @override
  String get disclaimerAccept => 'I Understand';

  @override
  String get loginTagline =>
      'Personal visual wellness tracker and doctor visit preparation assistant for skin, moles, and daily signs.';

  @override
  String get featureColorCalibration => 'Color Calibration';

  @override
  String get featurePrivacyFirst => 'Privacy First';

  @override
  String get featureOptionalAi => 'Optional AI';

  @override
  String get loginCardTitle => 'Continue with your account';

  @override
  String get loginCardSubtitle =>
      'Keep your personal color baselines and checkup history organized.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get guestGreeting => 'Skin & Visual Wellness Tracking';

  @override
  String userGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return '$provider Account';
  }

  @override
  String get localOnlyLabel => 'Stored on this device only';

  @override
  String get menuHome => 'Home';

  @override
  String get menuSectionVisualChecks => 'VISUAL CHECKS';

  @override
  String get menuSkinGroup => 'Skin (Mole, Wart, Bruise, Spot)';

  @override
  String get menuSkinGeneral => 'General Skin & Rash';

  @override
  String get menuSectionTracking => 'TRACKING, LABS & VITALS';

  @override
  String get menuFollowUpPlan => 'Personal Follow-Up Plan';

  @override
  String get menuVitalsTracker => 'Blood Pressure & Sugar';

  @override
  String get menuLabReports => 'Lab & Hospital Reports';

  @override
  String get menuQuickColorCard => 'Camera-Free Color Card';

  @override
  String get menuHistory => 'Checkup History';

  @override
  String get menuReferenceGuide => 'Visual Reference Guide';

  @override
  String get menuSectionSettings => 'SETTINGS & PRIVACY';

  @override
  String get menuAiSettings => 'AI & Privacy';

  @override
  String get menuDisclaimer => 'Medical Disclaimer';

  @override
  String get menuTheme => 'Appearance Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get menuLanguage => 'App Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get signInGoogleOrApple => 'Sign in with Google or Apple';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account and Local Data';

  @override
  String get deleteAccountBody =>
      'You will be signed out and your checkup history and personal color baselines on this device will be permanently deleted. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get followUpCardTitle => 'Personal Follow-Up Plan';

  @override
  String get followUpSelectEdit => 'Select / Edit';

  @override
  String get followUpStart => 'Start';

  @override
  String get followUpEmptyHint =>
      'Tap to select eye, urine, blood pressure, blood sugar, and other routines.';

  @override
  String get followUpSheetSubtitle =>
      'Track eye, tongue, nail, skin, urine, stool, blood pressure, blood sugar, and lab reports in one plan.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active active • $completed up to date • $due due';
  }

  @override
  String get homeCategoriesTitle => 'Checkup Categories';

  @override
  String get homeCategoriesSubtitle =>
      'Track visual changes with camera calibration or camera-free color cards.';

  @override
  String get homeLabsVitalsTitle => 'Labs, Blood Pressure & Sugar';

  @override
  String get homeLabsVitalsSubtitle =>
      'Read hospital/blood test reports and track blood pressure & glucose trends.';

  @override
  String get homeLabsCardTitle => 'Labs & Reports';

  @override
  String get homeLabsCardEmpty => 'Read & review blood tests';

  @override
  String homeLabsCardCount(int count) {
    return '$count saved reports';
  }

  @override
  String get homeVitalsCardTitle => 'Blood Pressure & Sugar';

  @override
  String get homeVitalsCardEmpty => 'Log readings & view trends';

  @override
  String homeVitalsCardCount(int count) {
    return '$count saved readings';
  }

  @override
  String get homeRecentChecks => 'Recent Checks';

  @override
  String get seeAll => 'See All';

  @override
  String get catEyeTitle => 'Eye (Sclera)';

  @override
  String get catEyeSubtitle => 'Redness, yellowing, and sclera tone';

  @override
  String get catNailTitle => 'Nail';

  @override
  String get catNailSubtitle => 'Pallor, cyanosis, yellowing & shape';

  @override
  String get catTongueTitle => 'Tongue';

  @override
  String get catTongueSubtitle => 'Color, white/yellow coating & texture';

  @override
  String get catFaceTitle => 'Face & Skin';

  @override
  String get catFaceSubtitle => 'Skin tone, pallor, and redness';

  @override
  String get catSkinTitle => 'Skin Conditions';

  @override
  String get catSkinSubtitle => 'Mole, wart, bruise, facial spot & rash';

  @override
  String get catUrineTitle => 'Urine Color';

  @override
  String get catUrineSubtitle => 'Hydration and color scale check';

  @override
  String get catStoolTitle => 'Stool Color';

  @override
  String get catStoolSubtitle => 'Digestion and color warning check';

  @override
  String get tooltipHistory => 'History';

  @override
  String get tooltipAccountMenu => 'Account & Menu';

  @override
  String get menuSettings => 'Settings (Permissions & Language)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageDesc =>
      'Your phone language is used automatically by default. You can choose any language below.';

  @override
  String get settingsPermissionsTitle => 'App Permissions';

  @override
  String get settingsPermissionsDesc =>
      'Check and manage camera and gallery/photo permissions here.';

  @override
  String get settingsCameraPermission => 'Camera Permission';

  @override
  String get settingsCameraPermissionDesc =>
      'Used for eye, tongue, nail, and skin captures';

  @override
  String get settingsPhotosPermission => 'Gallery & Photos Permission';

  @override
  String get settingsPhotosPermissionDesc =>
      'Used to upload photos and lab report images';

  @override
  String get settingsOpenSystemPermissions => 'Open Phone App Permissions';

  @override
  String get permChecking => 'Checking...';

  @override
  String get permGranted => 'Granted';

  @override
  String get permDenied => 'Permission Needed';

  @override
  String get permPermanent => 'Enable in System Settings';

  @override
  String get permUnavailable => 'Managed by Device';

  @override
  String get permGrantBtn => 'Allow';

  @override
  String get permOpenSettingsBtn => 'Open Settings';

  @override
  String get skinCancerRisk => 'Mole & Skin Cancer Risk';

  @override
  String get skinWart => 'Wart Pre-Check';

  @override
  String get skinBruise => 'Bruise Tracking';

  @override
  String get skinFacialSpot => 'Facial Spot';

  @override
  String get trackEyeTitle => 'Weekly Eye (Sclera) Check';

  @override
  String get trackEyeSubtitle =>
      'Track redness or yellowing changes in the sclera';

  @override
  String get trackTongueTitle => 'Weekly Tongue Check';

  @override
  String get trackTongueSubtitle =>
      'Track tongue color, coating, and surface changes';

  @override
  String get trackNailTitle => 'Weekly Nail Check';

  @override
  String get trackNailSubtitle =>
      'Monitor nail bed pallor, cyanosis, or yellowing';

  @override
  String get trackFaceTitle => 'Biweekly Face & Skin Tone';

  @override
  String get trackFaceSubtitle =>
      'Compare pallor, redness, and facial tone changes';

  @override
  String get trackSkinTitle => 'Monthly Skin, Mole & Wart Check';

  @override
  String get trackSkinSubtitle =>
      'Compare 30-day changes in moles, warts, bruises & spots';

  @override
  String get trackHydrationTitle => 'Daily Hydration (Urine) Check';

  @override
  String get trackHydrationSubtitle =>
      'Log hydration in 2 seconds with camera-free color card';

  @override
  String get trackStoolTitle => 'Weekly Stool Color Check';

  @override
  String get trackStoolSubtitle =>
      'Track digestion and color warning signs regularly';

  @override
  String get trackBpTitle => 'Daily Blood Pressure Check';

  @override
  String get trackBpSubtitle =>
      'Log systolic/diastolic pressure and pulse trends';

  @override
  String get trackSugarTitle => 'Daily Blood Sugar Check';

  @override
  String get trackSugarSubtitle =>
      'Track fasting or post-meal blood glucose readings';

  @override
  String get trackLabTitle => 'Quarterly Blood Test & Lab Report';

  @override
  String get trackLabSubtitle =>
      'Upload hospital/blood test reports and compare over time';

  @override
  String get statusFirstPending => 'Waiting for first log';

  @override
  String get statusDueNow => 'Time for checkup';

  @override
  String get statusDoneToday => 'Completed today';

  @override
  String statusNextDays(int days) {
    return 'Next check in $days days';
  }

  @override
  String get actionCheckNow => 'Check Now';

  @override
  String get actionLogReading => 'Log Reading';

  @override
  String get actionAddReport => 'Add Report';

  @override
  String checkMethodTitle(String category) {
    return '$category • Check Method';
  }

  @override
  String get checkMethodSubtitle =>
      'Pick from the color card in 2 seconds without taking a photo, or use camera measurement.';

  @override
  String get colorCardRecommendedTitle =>
      'Camera-Free Color Card (Recommended)';

  @override
  String get colorCardRecommendedSubtitle =>
      'Private, fast 2-second log without a photo';

  @override
  String get cameraMeasureTitle => 'Camera Color Measurement';

  @override
  String get cameraMeasureSubtitle =>
      'Automatic measurement with white-reference calibration';

  @override
  String get referenceGuideSubtitle =>
      'Select a module to view healthy vs. abnormal visual findings.';

  @override
  String get historyEmpty => 'No saved checkups yet.';

  @override
  String get filterAll => 'All';

  @override
  String get aiSettingsTitle => 'AI & Privacy Settings';

  @override
  String get vitalsBpTab => 'Blood Pressure';

  @override
  String get vitalsSugarTab => 'Blood Sugar';

  @override
  String get skinScreenTitle => 'Skin Conditions Pre-Check';
}
