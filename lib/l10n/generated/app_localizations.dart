import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'VisualCheckUp'**
  String get appTitle;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'This app does not provide a medical diagnosis; it is for informational and visual self-awareness purposes only.'**
  String get disclaimerShort;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Medical Notice'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerFull.
  ///
  /// In en, this message translates to:
  /// **'VisualCheckUp provides a visual self-awareness pre-assessment based on color and appearance cues. It is not a medical device and never replaces a doctor\'s examination, lab testing, or medical diagnosis.\n\n• Ambient lighting, camera sensors, and screen calibration directly affect color perception.\n• Seek medical attention promptly for severe pain, bleeding, high fever, jaundice, black/clay stools, sudden vision changes, or breathing difficulty.\n• Privacy: Captured images are processed on your device by default.'**
  String get disclaimerFull;

  /// No description provided for @disclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get disclaimerAccept;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Personal visual wellness tracker and doctor visit preparation assistant for skin, moles, and daily signs.'**
  String get loginTagline;

  /// No description provided for @featureColorCalibration.
  ///
  /// In en, this message translates to:
  /// **'Color Calibration'**
  String get featureColorCalibration;

  /// No description provided for @featurePrivacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get featurePrivacyFirst;

  /// No description provided for @featureOptionalAi.
  ///
  /// In en, this message translates to:
  /// **'Optional AI'**
  String get featureOptionalAi;

  /// No description provided for @loginCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with your account'**
  String get loginCardTitle;

  /// No description provided for @loginCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your personal color baselines and checkup history organized.'**
  String get loginCardSubtitle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @guestGreeting.
  ///
  /// In en, this message translates to:
  /// **'Skin & Visual Wellness Tracking'**
  String get guestGreeting;

  /// No description provided for @userGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String userGreeting(String name);

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'{provider} Account'**
  String accountTypeLabel(String provider);

  /// No description provided for @localOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device only'**
  String get localOnlyLabel;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuSectionVisualChecks.
  ///
  /// In en, this message translates to:
  /// **'VISUAL CHECKS'**
  String get menuSectionVisualChecks;

  /// No description provided for @menuSkinGroup.
  ///
  /// In en, this message translates to:
  /// **'Skin (Mole, Wart, Bruise, Spot)'**
  String get menuSkinGroup;

  /// No description provided for @menuSkinGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Skin & Rash'**
  String get menuSkinGeneral;

  /// No description provided for @menuSectionTracking.
  ///
  /// In en, this message translates to:
  /// **'TRACKING, LABS & VITALS'**
  String get menuSectionTracking;

  /// No description provided for @menuFollowUpPlan.
  ///
  /// In en, this message translates to:
  /// **'Personal Follow-Up Plan'**
  String get menuFollowUpPlan;

  /// No description provided for @menuVitalsTracker.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure & Sugar'**
  String get menuVitalsTracker;

  /// No description provided for @menuLabReports.
  ///
  /// In en, this message translates to:
  /// **'Lab & Hospital Reports'**
  String get menuLabReports;

  /// No description provided for @menuQuickColorCard.
  ///
  /// In en, this message translates to:
  /// **'Camera-Free Color Card'**
  String get menuQuickColorCard;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'Checkup History'**
  String get menuHistory;

  /// No description provided for @menuReferenceGuide.
  ///
  /// In en, this message translates to:
  /// **'Visual Reference Guide'**
  String get menuReferenceGuide;

  /// No description provided for @menuSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS & PRIVACY'**
  String get menuSectionSettings;

  /// No description provided for @menuAiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI & Privacy'**
  String get menuAiSettings;

  /// No description provided for @menuDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get menuDisclaimer;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance Theme'**
  String get menuTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get menuLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @signInGoogleOrApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google or Apple'**
  String get signInGoogleOrApple;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account and Local Data'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out and your checkup history and personal color baselines on this device will be permanently deleted. Continue?'**
  String get deleteAccountBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @followUpCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Follow-Up Plan'**
  String get followUpCardTitle;

  /// No description provided for @followUpSelectEdit.
  ///
  /// In en, this message translates to:
  /// **'Select / Edit'**
  String get followUpSelectEdit;

  /// No description provided for @followUpStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get followUpStart;

  /// No description provided for @followUpEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select eye, urine, blood pressure, blood sugar, and other routines.'**
  String get followUpEmptyHint;

  /// No description provided for @followUpSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track eye, tongue, nail, skin, urine, stool, blood pressure, blood sugar, and lab reports in one plan.'**
  String get followUpSheetSubtitle;

  /// No description provided for @followUpSummaryCounts.
  ///
  /// In en, this message translates to:
  /// **'{active} active • {completed} up to date • {due} due'**
  String followUpSummaryCounts(int active, int completed, int due);

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkup Categories'**
  String get homeCategoriesTitle;

  /// No description provided for @homeCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track visual changes with camera calibration or camera-free color cards.'**
  String get homeCategoriesSubtitle;

  /// No description provided for @homeLabsVitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Labs, Blood Pressure & Sugar'**
  String get homeLabsVitalsTitle;

  /// No description provided for @homeLabsVitalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read hospital/blood test reports and track blood pressure & glucose trends.'**
  String get homeLabsVitalsSubtitle;

  /// No description provided for @homeLabsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Labs & Reports'**
  String get homeLabsCardTitle;

  /// No description provided for @homeLabsCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Read & review blood tests'**
  String get homeLabsCardEmpty;

  /// No description provided for @homeLabsCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved reports'**
  String homeLabsCardCount(int count);

  /// No description provided for @homeVitalsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure & Sugar'**
  String get homeVitalsCardTitle;

  /// No description provided for @homeVitalsCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log readings & view trends'**
  String get homeVitalsCardEmpty;

  /// No description provided for @homeVitalsCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved readings'**
  String homeVitalsCardCount(int count);

  /// No description provided for @homeRecentChecks.
  ///
  /// In en, this message translates to:
  /// **'Recent Checks'**
  String get homeRecentChecks;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @catEyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eye (Sclera)'**
  String get catEyeTitle;

  /// No description provided for @catEyeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Redness, yellowing, and sclera tone'**
  String get catEyeSubtitle;

  /// No description provided for @catNailTitle.
  ///
  /// In en, this message translates to:
  /// **'Nail'**
  String get catNailTitle;

  /// No description provided for @catNailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pallor, cyanosis, yellowing & shape'**
  String get catNailSubtitle;

  /// No description provided for @catTongueTitle.
  ///
  /// In en, this message translates to:
  /// **'Tongue'**
  String get catTongueTitle;

  /// No description provided for @catTongueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Color, white/yellow coating & texture'**
  String get catTongueSubtitle;

  /// No description provided for @catFaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Face & Skin'**
  String get catFaceTitle;

  /// No description provided for @catFaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skin tone, pallor, and redness'**
  String get catFaceSubtitle;

  /// No description provided for @catSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Skin Conditions'**
  String get catSkinTitle;

  /// No description provided for @catSkinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mole, wart, bruise, facial spot & rash'**
  String get catSkinSubtitle;

  /// No description provided for @catUrineTitle.
  ///
  /// In en, this message translates to:
  /// **'Urine Color'**
  String get catUrineTitle;

  /// No description provided for @catUrineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration and color scale check'**
  String get catUrineSubtitle;

  /// No description provided for @catStoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Stool Color'**
  String get catStoolTitle;

  /// No description provided for @catStoolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Digestion and color warning check'**
  String get catStoolSubtitle;

  /// No description provided for @tooltipHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tooltipHistory;

  /// No description provided for @tooltipAccountMenu.
  ///
  /// In en, this message translates to:
  /// **'Account & Menu'**
  String get tooltipAccountMenu;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings (Permissions & Language)'**
  String get menuSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Your phone language is used automatically by default. You can choose any language below.'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get settingsPermissionsTitle;

  /// No description provided for @settingsPermissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Check and manage camera and gallery/photo permissions here.'**
  String get settingsPermissionsDesc;

  /// No description provided for @settingsCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get settingsCameraPermission;

  /// No description provided for @settingsCameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Used for eye, tongue, nail, and skin captures'**
  String get settingsCameraPermissionDesc;

  /// No description provided for @settingsPhotosPermission.
  ///
  /// In en, this message translates to:
  /// **'Gallery & Photos Permission'**
  String get settingsPhotosPermission;

  /// No description provided for @settingsPhotosPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Used to upload photos and lab report images'**
  String get settingsPhotosPermissionDesc;

  /// No description provided for @settingsOpenSystemPermissions.
  ///
  /// In en, this message translates to:
  /// **'Open Phone App Permissions'**
  String get settingsOpenSystemPermissions;

  /// No description provided for @permChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get permChecking;

  /// No description provided for @permGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permGranted;

  /// No description provided for @permDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Needed'**
  String get permDenied;

  /// No description provided for @permPermanent.
  ///
  /// In en, this message translates to:
  /// **'Enable in System Settings'**
  String get permPermanent;

  /// No description provided for @permUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Managed by Device'**
  String get permUnavailable;

  /// No description provided for @permGrantBtn.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permGrantBtn;

  /// No description provided for @permOpenSettingsBtn.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permOpenSettingsBtn;

  /// No description provided for @skinCancerRisk.
  ///
  /// In en, this message translates to:
  /// **'Mole & Skin Cancer Risk'**
  String get skinCancerRisk;

  /// No description provided for @skinWart.
  ///
  /// In en, this message translates to:
  /// **'Wart Pre-Check'**
  String get skinWart;

  /// No description provided for @skinBruise.
  ///
  /// In en, this message translates to:
  /// **'Bruise Tracking'**
  String get skinBruise;

  /// No description provided for @skinFacialSpot.
  ///
  /// In en, this message translates to:
  /// **'Facial Spot'**
  String get skinFacialSpot;

  /// No description provided for @trackEyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Eye (Sclera) Check'**
  String get trackEyeTitle;

  /// No description provided for @trackEyeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track redness or yellowing changes in the sclera'**
  String get trackEyeSubtitle;

  /// No description provided for @trackTongueTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Tongue Check'**
  String get trackTongueTitle;

  /// No description provided for @trackTongueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track tongue color, coating, and surface changes'**
  String get trackTongueSubtitle;

  /// No description provided for @trackNailTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Nail Check'**
  String get trackNailTitle;

  /// No description provided for @trackNailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor nail bed pallor, cyanosis, or yellowing'**
  String get trackNailSubtitle;

  /// No description provided for @trackFaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Biweekly Face & Skin Tone'**
  String get trackFaceTitle;

  /// No description provided for @trackFaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare pallor, redness, and facial tone changes'**
  String get trackFaceSubtitle;

  /// No description provided for @trackSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Skin, Mole & Wart Check'**
  String get trackSkinTitle;

  /// No description provided for @trackSkinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare 30-day changes in moles, warts, bruises & spots'**
  String get trackSkinSubtitle;

  /// No description provided for @trackHydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Hydration (Urine) Check'**
  String get trackHydrationTitle;

  /// No description provided for @trackHydrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log hydration in 2 seconds with camera-free color card'**
  String get trackHydrationSubtitle;

  /// No description provided for @trackStoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stool Color Check'**
  String get trackStoolTitle;

  /// No description provided for @trackStoolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track digestion and color warning signs regularly'**
  String get trackStoolSubtitle;

  /// No description provided for @trackBpTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Blood Pressure Check'**
  String get trackBpTitle;

  /// No description provided for @trackBpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log systolic/diastolic pressure and pulse trends'**
  String get trackBpSubtitle;

  /// No description provided for @trackSugarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Blood Sugar Check'**
  String get trackSugarTitle;

  /// No description provided for @trackSugarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track fasting or post-meal blood glucose readings'**
  String get trackSugarSubtitle;

  /// No description provided for @trackLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Blood Test & Lab Report'**
  String get trackLabTitle;

  /// No description provided for @trackLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload hospital/blood test reports and compare over time'**
  String get trackLabSubtitle;

  /// No description provided for @statusFirstPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for first log'**
  String get statusFirstPending;

  /// No description provided for @statusDueNow.
  ///
  /// In en, this message translates to:
  /// **'Time for checkup'**
  String get statusDueNow;

  /// No description provided for @statusDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get statusDoneToday;

  /// No description provided for @statusNextDays.
  ///
  /// In en, this message translates to:
  /// **'Next check in {days} days'**
  String statusNextDays(int days);

  /// No description provided for @actionCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get actionCheckNow;

  /// No description provided for @actionLogReading.
  ///
  /// In en, this message translates to:
  /// **'Log Reading'**
  String get actionLogReading;

  /// No description provided for @actionAddReport.
  ///
  /// In en, this message translates to:
  /// **'Add Report'**
  String get actionAddReport;

  /// No description provided for @checkMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} • Check Method'**
  String checkMethodTitle(String category);

  /// No description provided for @checkMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick from the color card in 2 seconds without taking a photo, or use camera measurement.'**
  String get checkMethodSubtitle;

  /// No description provided for @colorCardRecommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera-Free Color Card (Recommended)'**
  String get colorCardRecommendedTitle;

  /// No description provided for @colorCardRecommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private, fast 2-second log without a photo'**
  String get colorCardRecommendedSubtitle;

  /// No description provided for @cameraMeasureTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Color Measurement'**
  String get cameraMeasureTitle;

  /// No description provided for @cameraMeasureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic measurement with white-reference calibration'**
  String get cameraMeasureSubtitle;

  /// No description provided for @referenceGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a module to view healthy vs. abnormal visual findings.'**
  String get referenceGuideSubtitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved checkups yet.'**
  String get historyEmpty;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @aiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI & Privacy Settings'**
  String get aiSettingsTitle;

  /// No description provided for @vitalsBpTab.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get vitalsBpTab;

  /// No description provided for @vitalsSugarTab.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get vitalsSugarTab;

  /// No description provided for @skinScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Skin Conditions Pre-Check'**
  String get skinScreenTitle;

  /// No description provided for @providerGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get providerGuest;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String signInFailed(String error);

  /// No description provided for @riskNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Appearance'**
  String get riskNormal;

  /// No description provided for @riskAttention.
  ///
  /// In en, this message translates to:
  /// **'Follow-Up Suggested'**
  String get riskAttention;

  /// No description provided for @riskUrgent.
  ///
  /// In en, this message translates to:
  /// **'Doctor Review Recommended'**
  String get riskUrgent;

  /// No description provided for @recentSummaryFallback.
  ///
  /// In en, this message translates to:
  /// **'{category} • {status}'**
  String recentSummaryFallback(String category, String status);

  /// No description provided for @latestSummaryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Latest: {value}'**
  String latestSummaryPrefix(String value);

  /// No description provided for @latestLabValuesSummary.
  ///
  /// In en, this message translates to:
  /// **'Latest: {count} values ({abnormal} out of range)'**
  String latestLabValuesSummary(int count, int abnormal);

  /// No description provided for @latestLabAllNormal.
  ///
  /// In en, this message translates to:
  /// **'Latest: {count} values (all normal)'**
  String latestLabAllNormal(int count);

  /// No description provided for @labStatusCriticalLow.
  ///
  /// In en, this message translates to:
  /// **'Critical Low'**
  String get labStatusCriticalLow;

  /// No description provided for @labStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get labStatusLow;

  /// No description provided for @labStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get labStatusNormal;

  /// No description provided for @labStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get labStatusHigh;

  /// No description provided for @labStatusCriticalHigh.
  ///
  /// In en, this message translates to:
  /// **'Critical High'**
  String get labStatusCriticalHigh;

  /// No description provided for @labSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get labSourceManual;

  /// No description provided for @labSourcePasted.
  ///
  /// In en, this message translates to:
  /// **'Parsed from Report Text'**
  String get labSourcePasted;

  /// No description provided for @labSourcePhoto.
  ///
  /// In en, this message translates to:
  /// **'JPG / Photo Report'**
  String get labSourcePhoto;

  /// No description provided for @labSourcePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF Report'**
  String get labSourcePdf;

  /// No description provided for @bpLow.
  ///
  /// In en, this message translates to:
  /// **'Low Blood Pressure'**
  String get bpLow;

  /// No description provided for @bpNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Range'**
  String get bpNormal;

  /// No description provided for @bpElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get bpElevated;

  /// No description provided for @bpStage1.
  ///
  /// In en, this message translates to:
  /// **'Stage 1 High'**
  String get bpStage1;

  /// No description provided for @bpStage2.
  ///
  /// In en, this message translates to:
  /// **'Stage 2 High'**
  String get bpStage2;

  /// No description provided for @bpCrisis.
  ///
  /// In en, this message translates to:
  /// **'Hypertensive Crisis'**
  String get bpCrisis;

  /// No description provided for @sugarLow.
  ///
  /// In en, this message translates to:
  /// **'Low Blood Sugar'**
  String get sugarLow;

  /// No description provided for @sugarNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Range'**
  String get sugarNormal;

  /// No description provided for @sugarBorderline.
  ///
  /// In en, this message translates to:
  /// **'Borderline High'**
  String get sugarBorderline;

  /// No description provided for @sugarHigh.
  ///
  /// In en, this message translates to:
  /// **'High Blood Sugar'**
  String get sugarHigh;

  /// No description provided for @sugarVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High Blood Sugar'**
  String get sugarVeryHigh;

  /// No description provided for @sugarTypeFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get sugarTypeFasting;

  /// No description provided for @sugarTypePostMeal.
  ///
  /// In en, this message translates to:
  /// **'Post-Meal (2h)'**
  String get sugarTypePostMeal;

  /// No description provided for @sugarTypeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get sugarTypeRandom;

  /// No description provided for @specialtyEye.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology or Internal Medicine'**
  String get specialtyEye;

  /// No description provided for @specialtyNail.
  ///
  /// In en, this message translates to:
  /// **'Dermatology or Internal Medicine'**
  String get specialtyNail;

  /// No description provided for @specialtyTongue.
  ///
  /// In en, this message translates to:
  /// **'ENT, Oral Health, or Internal Medicine'**
  String get specialtyTongue;

  /// No description provided for @specialtySkin.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get specialtySkin;

  /// No description provided for @specialtyUrine.
  ///
  /// In en, this message translates to:
  /// **'Urology or Internal Medicine'**
  String get specialtyUrine;

  /// No description provided for @specialtyStool.
  ///
  /// In en, this message translates to:
  /// **'Gastroenterology or Internal Medicine'**
  String get specialtyStool;

  /// No description provided for @cloudBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup (Optional • Firebase)'**
  String get cloudBackupTitle;

  /// No description provided for @cloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'By default, all your lab reports and readings stay on this device only. Enable private backup under your Google/Apple account if you want to keep data when changing phones.'**
  String get cloudBackupDesc;

  /// No description provided for @cloudBackupToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Cloud Backup'**
  String get cloudBackupToggleTitle;

  /// No description provided for @cloudBackupLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String cloudBackupLastSync(String date);

  /// No description provided for @cloudBackupEnabledReady.
  ///
  /// In en, this message translates to:
  /// **'Enabled • Ready to sync'**
  String get cloudBackupEnabledReady;

  /// No description provided for @cloudBackupDisabledLocal.
  ///
  /// In en, this message translates to:
  /// **'Off • On-device storage only'**
  String get cloudBackupDisabledLocal;

  /// No description provided for @cloudBackupSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google or Apple to use cloud backup.'**
  String get cloudBackupSignInRequired;

  /// No description provided for @cloudBackupNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Back Up Now'**
  String get cloudBackupNowBtn;

  /// No description provided for @cloudRestoreBtn.
  ///
  /// In en, this message translates to:
  /// **'Restore from Cloud'**
  String get cloudRestoreBtn;

  /// No description provided for @cloudConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup Consent'**
  String get cloudConsentTitle;

  /// No description provided for @cloudConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Your blood tests, vitals, and checkups are stored only on this device by default.\n\nIf you enable cloud backup, this data is stored privately under your Google/Apple Firebase account and permanently deleted when you delete your account.\n\nDo you consent?'**
  String get cloudConsentBody;

  /// No description provided for @cloudConsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, Enable'**
  String get cloudConsentConfirm;

  /// No description provided for @cloudBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup complete: {count} records synced.'**
  String cloudBackupSuccess(int count);

  /// No description provided for @cloudBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String cloudBackupFailed(String error);

  /// No description provided for @cloudRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored from cloud: {count} records imported.'**
  String cloudRestoreSuccess(int count);

  /// No description provided for @cloudRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String cloudRestoreFailed(String error);

  /// No description provided for @cloudBackupDisabledNotice.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup turned off. New records stay on this device only.'**
  String get cloudBackupDisabledNotice;

  /// No description provided for @aiCloudToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Vision AI (Gemini) Analysis'**
  String get aiCloudToggleTitle;

  /// No description provided for @aiCloudOnDesc.
  ///
  /// In en, this message translates to:
  /// **'On: Sharp photos are resized and analyzed over a secure connection. Falls back on-device when offline.'**
  String get aiCloudOnDesc;

  /// No description provided for @aiCloudOffDesc.
  ///
  /// In en, this message translates to:
  /// **'Off (0 Tokens): All analysis runs strictly on your device; no photos are ever uploaded.'**
  String get aiCloudOffDesc;

  /// No description provided for @aiBackendOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'When a Gemini / Firebase AI key is configured, cloud analysis activates automatically according to this toggle; the on-device engine is currently active.'**
  String get aiBackendOfflineNote;

  /// No description provided for @aiOptimizationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Token & Data Saving Controls'**
  String get aiOptimizationsTitle;

  /// No description provided for @aiOptQualityGate.
  ///
  /// In en, this message translates to:
  /// **'0-token blur, darkness, and glare quality gate'**
  String get aiOptQualityGate;

  /// No description provided for @aiOptCompression.
  ///
  /// In en, this message translates to:
  /// **'Auto-crop + 512px / 768px JPEG (80%) compression'**
  String get aiOptCompression;

  /// No description provided for @aiOptTieredModel.
  ///
  /// In en, this message translates to:
  /// **'Smart model routing (Flash-Lite / Flash) & low thinking'**
  String get aiOptTieredModel;

  /// No description provided for @aiOptHashCache.
  ///
  /// In en, this message translates to:
  /// **'On-device duplicate hash cache (0 tokens)'**
  String get aiOptHashCache;

  /// No description provided for @aiClearCacheBtn.
  ///
  /// In en, this message translates to:
  /// **'Clear AI Cache'**
  String get aiClearCacheBtn;

  /// No description provided for @aiCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'AI cache cleared.'**
  String get aiCacheCleared;

  /// No description provided for @resultScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} Result'**
  String resultScreenTitle(String category);

  /// No description provided for @tooltipDoctorSummary.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visit Summary'**
  String get tooltipDoctorSummary;

  /// No description provided for @tooltipReferenceGuide.
  ///
  /// In en, this message translates to:
  /// **'Reference Guide'**
  String get tooltipReferenceGuide;

  /// No description provided for @calibratedColorTone.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Color Tone'**
  String get calibratedColorTone;

  /// No description provided for @sampledColorTone.
  ///
  /// In en, this message translates to:
  /// **'Sampled Dominant Tone'**
  String get sampledColorTone;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Pre-check confidence: {percent}%'**
  String confidenceLabel(int percent);

  /// No description provided for @whiteBalanceDefaultNote.
  ///
  /// In en, this message translates to:
  /// **'Color balanced with white reference.'**
  String get whiteBalanceDefaultNote;

  /// No description provided for @recommendedSpecialtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested specialty: {specialty}'**
  String recommendedSpecialtyLabel(String specialty);

  /// No description provided for @timelineComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Over Time'**
  String get timelineComparisonTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @previousRecordSummary.
  ///
  /// In en, this message translates to:
  /// **'Previous log: \"{title}\" ({status}). Tracking {count} records.'**
  String previousRecordSummary(String title, String status, int count);

  /// No description provided for @personalBaselineComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Baseline Comparison'**
  String get personalBaselineComparisonTitle;

  /// No description provided for @yourBaselineLabel.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get yourBaselineLabel;

  /// No description provided for @warningFlagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning Signs to Watch'**
  String get warningFlagsTitle;

  /// No description provided for @observationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get observationsTitle;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendationsTitle;

  /// No description provided for @personalBaselineCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Baseline Calibration'**
  String get personalBaselineCardTitle;

  /// No description provided for @personalBaselineCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a reading on a healthy day as your personal baseline to reduce camera sensor drift.'**
  String get personalBaselineCardDesc;

  /// No description provided for @saveBaselineBtn.
  ///
  /// In en, this message translates to:
  /// **'Save as My Baseline'**
  String get saveBaselineBtn;

  /// No description provided for @updateBaselineBtn.
  ///
  /// In en, this message translates to:
  /// **'Update My Baseline'**
  String get updateBaselineBtn;

  /// No description provided for @clearBaselineBtn.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get clearBaselineBtn;

  /// No description provided for @baselineSavedMsg.
  ///
  /// In en, this message translates to:
  /// **'Personal baseline saved for {category}.'**
  String baselineSavedMsg(String category);

  /// No description provided for @baselineClearedMsg.
  ///
  /// In en, this message translates to:
  /// **'Personal baseline removed for {category}.'**
  String baselineClearedMsg(String category);

  /// No description provided for @doctorSummaryBtn.
  ///
  /// In en, this message translates to:
  /// **'Show to Doctor • Prepare Summary'**
  String get doctorSummaryBtn;

  /// No description provided for @returnHomeBtn.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get returnHomeBtn;

  /// No description provided for @doctorSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Show to Doctor • Visit Summary'**
  String get doctorSheetTitle;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color: {hex} • {status}'**
  String colorLabel(String hex, String status);

  /// No description provided for @timelineHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline with Previous Logs'**
  String get timelineHistoryTitle;

  /// No description provided for @questionsForDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions to Ask Your Doctor'**
  String get questionsForDoctorTitle;

  /// No description provided for @copyShareSummaryBtn.
  ///
  /// In en, this message translates to:
  /// **'Copy & Share Summary'**
  String get copyShareSummaryBtn;

  /// No description provided for @doctorSummaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit summary copied to clipboard.'**
  String get doctorSummaryCopied;

  /// No description provided for @referenceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} — Visual References'**
  String referenceSheetTitle(String category);

  /// No description provided for @healthyReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Healthy Reference'**
  String get healthyReferenceLabel;

  /// No description provided for @captureChecklistTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture Tips'**
  String get captureChecklistTitle;

  /// No description provided for @abnormalFindingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Abnormal / Warning Visual Findings'**
  String get abnormalFindingsTitle;

  /// No description provided for @cameraPermPermanentMsg.
  ///
  /// In en, this message translates to:
  /// **'Camera access is disabled in system settings. Enable camera permission for VisualCheckUp or pick a photo from gallery.'**
  String get cameraPermPermanentMsg;

  /// No description provided for @cameraPermRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed for visual pre-checks. Images are processed on your device by default.'**
  String get cameraPermRequiredMsg;

  /// No description provided for @cameraGrantPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Needed'**
  String get cameraGrantPermTitle;

  /// No description provided for @cameraRequestPermBtn.
  ///
  /// In en, this message translates to:
  /// **'Grant Camera Permission'**
  String get cameraRequestPermBtn;

  /// No description provided for @cameraPickGalleryBtn.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get cameraPickGalleryBtn;

  /// No description provided for @cameraWhiteRefOn.
  ///
  /// In en, this message translates to:
  /// **'White Reference: On'**
  String get cameraWhiteRefOn;

  /// No description provided for @cameraWhiteRefOff.
  ///
  /// In en, this message translates to:
  /// **'White Reference: Off'**
  String get cameraWhiteRefOff;

  /// No description provided for @cameraBaselineActive.
  ///
  /// In en, this message translates to:
  /// **'Baseline Saved'**
  String get cameraBaselineActive;

  /// No description provided for @cameraAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get cameraAnalyzing;

  /// No description provided for @cameraCaptureBtn.
  ///
  /// In en, this message translates to:
  /// **'Capture & Analyze'**
  String get cameraCaptureBtn;

  /// No description provided for @cameraAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {error}'**
  String cameraAnalysisFailed(String error);

  /// No description provided for @quickCardTitle.
  ///
  /// In en, this message translates to:
  /// **'{category} • Color Card'**
  String quickCardTitle(String category);

  /// No description provided for @quickCardPrivacyBanner.
  ///
  /// In en, this message translates to:
  /// **'No camera needed: pick the closest shade for a private 2-second record.'**
  String get quickCardPrivacyBanner;

  /// No description provided for @quickCardChooseShade.
  ///
  /// In en, this message translates to:
  /// **'Select the Closest Color Shade'**
  String get quickCardChooseShade;

  /// No description provided for @quickCardExtraContext.
  ///
  /// In en, this message translates to:
  /// **'Extra Context (Optional)'**
  String get quickCardExtraContext;

  /// No description provided for @quickCardSaveViewBtn.
  ///
  /// In en, this message translates to:
  /// **'Save & View Assessment'**
  String get quickCardSaveViewBtn;

  /// No description provided for @quickCardUseCameraBtn.
  ///
  /// In en, this message translates to:
  /// **'Use Camera Instead'**
  String get quickCardUseCameraBtn;

  /// No description provided for @skinIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Visual Dermatology Pre-Screening'**
  String get skinIntroTitle;

  /// No description provided for @skinIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Compares moles, warts, bruises, and facial spots against surrounding skin. Not a diagnosis; helps prepare for a dermatologist visit.'**
  String get skinIntroDesc;

  /// No description provided for @skinStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Select Skin Pre-Screening Module'**
  String get skinStep1Title;

  /// No description provided for @skinOtherConcernsLabel.
  ///
  /// In en, this message translates to:
  /// **'Other Skin Presentations'**
  String get skinOtherConcernsLabel;

  /// No description provided for @skinStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Accompanying Symptoms (Optional)'**
  String get skinStep2Title;

  /// No description provided for @skinStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Body Area (Optional)'**
  String get skinStep3Title;

  /// No description provided for @skinStartCameraBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Camera Skin Check'**
  String get skinStartCameraBtn;

  /// No description provided for @skinConcernRash.
  ///
  /// In en, this message translates to:
  /// **'Redness / Rash'**
  String get skinConcernRash;

  /// No description provided for @skinConcernMole.
  ///
  /// In en, this message translates to:
  /// **'Mole / Dark Spot'**
  String get skinConcernMole;

  /// No description provided for @skinConcernScaly.
  ///
  /// In en, this message translates to:
  /// **'Scaly / Dry Plaque'**
  String get skinConcernScaly;

  /// No description provided for @skinConcernBlister.
  ///
  /// In en, this message translates to:
  /// **'Blister / Acne'**
  String get skinConcernBlister;

  /// No description provided for @skinConcernGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Skin Check'**
  String get skinConcernGeneral;

  /// No description provided for @bodyAreaFaceNeck.
  ///
  /// In en, this message translates to:
  /// **'Face / Neck'**
  String get bodyAreaFaceNeck;

  /// No description provided for @bodyAreaArmHand.
  ///
  /// In en, this message translates to:
  /// **'Arm / Hand'**
  String get bodyAreaArmHand;

  /// No description provided for @bodyAreaTorso.
  ///
  /// In en, this message translates to:
  /// **'Torso'**
  String get bodyAreaTorso;

  /// No description provided for @bodyAreaLegFoot.
  ///
  /// In en, this message translates to:
  /// **'Leg / Foot'**
  String get bodyAreaLegFoot;

  /// No description provided for @bodyAreaScalp.
  ///
  /// In en, this message translates to:
  /// **'Scalp'**
  String get bodyAreaScalp;

  /// No description provided for @bodyAreaOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get bodyAreaOther;

  /// No description provided for @symptomItching.
  ///
  /// In en, this message translates to:
  /// **'Itching'**
  String get symptomItching;

  /// No description provided for @symptomPainWarmth.
  ///
  /// In en, this message translates to:
  /// **'Pain / Warmth'**
  String get symptomPainWarmth;

  /// No description provided for @symptomRapidChange.
  ///
  /// In en, this message translates to:
  /// **'Rapid growth / shape change'**
  String get symptomRapidChange;

  /// No description provided for @symptomBleeding.
  ///
  /// In en, this message translates to:
  /// **'Bleeding / Oozing'**
  String get symptomBleeding;

  /// No description provided for @symptomSpreading.
  ///
  /// In en, this message translates to:
  /// **'Spreading rapidly'**
  String get symptomSpreading;

  /// No description provided for @symptomFever.
  ///
  /// In en, this message translates to:
  /// **'Fever present'**
  String get symptomFever;

  /// No description provided for @symptomNonHealing.
  ///
  /// In en, this message translates to:
  /// **'Non-healing sore (4+ weeks)'**
  String get symptomNonHealing;

  /// No description provided for @symptomOver6mm.
  ///
  /// In en, this message translates to:
  /// **'Over 6 mm or irregular border'**
  String get symptomOver6mm;

  /// No description provided for @symptomNoTrauma.
  ///
  /// In en, this message translates to:
  /// **'Appeared without trauma'**
  String get symptomNoTrauma;

  /// No description provided for @symptomRoughDots.
  ///
  /// In en, this message translates to:
  /// **'Rough surface / tiny black dots'**
  String get symptomRoughDots;

  /// No description provided for @symptomSunHormone.
  ///
  /// In en, this message translates to:
  /// **'Sun, hormone, or post-acne spot'**
  String get symptomSunHormone;

  /// No description provided for @bruiseGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Bruise Color Stages Guide'**
  String get bruiseGuideTitle;

  /// No description provided for @wartGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Wart Pre-Check & Safety Guide'**
  String get wartGuideTitle;

  /// No description provided for @abcdeGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'ABCDE Mole Self-Check Guide'**
  String get abcdeGuideTitle;

  /// No description provided for @abcdeGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 key signs dermatologists use for mole & skin cancer screening'**
  String get abcdeGuideSubtitle;

  /// No description provided for @labScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab & Hospital Reports'**
  String get labScreenTitle;

  /// No description provided for @labTabReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get labTabReports;

  /// No description provided for @labTabTrends.
  ///
  /// In en, this message translates to:
  /// **'Change Tracking'**
  String get labTabTrends;

  /// No description provided for @labAddBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Report / Blood Test'**
  String get labAddBtn;

  /// No description provided for @labEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved blood tests yet'**
  String get labEmptyTitle;

  /// No description provided for @labEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a PDF or JPG blood test report; optionally add your hospital diagnosis or complaint for a plain-language summary.'**
  String get labEmptyDesc;

  /// No description provided for @labAddFirstBtn.
  ///
  /// In en, this message translates to:
  /// **'Add First Lab / PDF Report'**
  String get labAddFirstBtn;

  /// No description provided for @labTrendsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Save blood tests on different dates to see longitudinal trend charts for Hemoglobin, Ferritin, Glucose, TSH, Vitamin D, and more.'**
  String get labTrendsEmptyDesc;

  /// No description provided for @labParamsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} parameters'**
  String labParamsCount(int count);

  /// No description provided for @labOutOfRangeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} out of range'**
  String labOutOfRangeCount(int count);

  /// No description provided for @labDetailParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Review ({count})'**
  String labDetailParamsTitle(int count);

  /// No description provided for @labEnteredDiagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Doctor Diagnosis'**
  String get labEnteredDiagnosisTitle;

  /// No description provided for @labEnteredComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Complaint / Note'**
  String get labEnteredComplaintTitle;

  /// No description provided for @labInterpretationTitle.
  ///
  /// In en, this message translates to:
  /// **'Plain-Language Interpretation'**
  String get labInterpretationTitle;

  /// No description provided for @labCopyDoctorSummaryBtn.
  ///
  /// In en, this message translates to:
  /// **'Show to Doctor • Copy Summary'**
  String get labCopyDoctorSummaryBtn;

  /// No description provided for @labSummaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Lab summary copied to clipboard.'**
  String get labSummaryCopied;

  /// No description provided for @labExportPdfBtn.
  ///
  /// In en, this message translates to:
  /// **'Export Doctor PDF'**
  String get labExportPdfBtn;

  /// No description provided for @labAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Hospital / Blood Test Report'**
  String get labAddSheetTitle;

  /// No description provided for @labReportTitleField.
  ///
  /// In en, this message translates to:
  /// **'Report Title'**
  String get labReportTitleField;

  /// No description provided for @labDefaultReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Test Result'**
  String get labDefaultReportTitle;

  /// No description provided for @labStep1Upload.
  ///
  /// In en, this message translates to:
  /// **'1. Upload PDF or JPG Blood Report'**
  String get labStep1Upload;

  /// No description provided for @labUploadPdfJpgBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF or JPG'**
  String get labUploadPdfJpgBtn;

  /// No description provided for @labCameraCaptureBtn.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get labCameraCaptureBtn;

  /// No description provided for @labStep2Context.
  ///
  /// In en, this message translates to:
  /// **'2. Hospital Diagnosis & Note (Optional)'**
  String get labStep2Context;

  /// No description provided for @labStep2ContextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a doctor\'s diagnosis you want explained or your symptoms; you may leave both blank.'**
  String get labStep2ContextHint;

  /// No description provided for @labDiagnosisField.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Doctor Diagnosis (Optional)'**
  String get labDiagnosisField;

  /// No description provided for @labComplaintField.
  ///
  /// In en, this message translates to:
  /// **'Your Symptoms / Question (Optional)'**
  String get labComplaintField;

  /// No description provided for @labStep3PasteManual.
  ///
  /// In en, this message translates to:
  /// **'3. Paste Report Text or Add Values Manually'**
  String get labStep3PasteManual;

  /// No description provided for @labParseTextBtn.
  ///
  /// In en, this message translates to:
  /// **'Read & Parse Text'**
  String get labParseTextBtn;

  /// No description provided for @labParamDropdown.
  ///
  /// In en, this message translates to:
  /// **'Lab Parameter'**
  String get labParamDropdown;

  /// No description provided for @labValueField.
  ///
  /// In en, this message translates to:
  /// **'Value ({unit})'**
  String labValueField(String unit);

  /// No description provided for @labAddValueBtn.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get labAddValueBtn;

  /// No description provided for @labParsedValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Parsed Values ({count})'**
  String labParsedValuesTitle(int count);

  /// No description provided for @labSaveEvaluateBtn.
  ///
  /// In en, this message translates to:
  /// **'Evaluate & Save Dated Report'**
  String get labSaveEvaluateBtn;

  /// No description provided for @labTrendSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} records • Change: {delta} • Latest: {status}'**
  String labTrendSummary(int count, String delta, String status);

  /// No description provided for @vitalsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure & Sugar'**
  String get vitalsScreenTitle;

  /// No description provided for @vitalsCopySummaryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy Doctor Summary'**
  String get vitalsCopySummaryTooltip;

  /// No description provided for @vitalsCopyEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Add a blood pressure or glucose reading first to create a summary.'**
  String get vitalsCopyEmptyMsg;

  /// No description provided for @vitalsSummaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Blood pressure & sugar summary copied.'**
  String get vitalsSummaryCopied;

  /// No description provided for @vitalsAddBpBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Blood Pressure'**
  String get vitalsAddBpBtn;

  /// No description provided for @vitalsAddSugarBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Blood Sugar'**
  String get vitalsAddSugarBtn;

  /// No description provided for @vitalsBpEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No blood pressure readings yet'**
  String get vitalsBpEmptyTitle;

  /// No description provided for @vitalsBpEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Log systolic/diastolic pressure and pulse with dates to follow your trend chart.'**
  String get vitalsBpEmptyDesc;

  /// No description provided for @vitalsBpAddFirstBtn.
  ///
  /// In en, this message translates to:
  /// **'Add First BP Reading'**
  String get vitalsBpAddFirstBtn;

  /// No description provided for @vitalsSugarEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No blood sugar readings yet'**
  String get vitalsSugarEmptyTitle;

  /// No description provided for @vitalsSugarEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Log fasting, post-meal (2h), or random glucose readings to track your trend.'**
  String get vitalsSugarEmptyDesc;

  /// No description provided for @vitalsSugarAddFirstBtn.
  ///
  /// In en, this message translates to:
  /// **'Add First Sugar Reading'**
  String get vitalsSugarAddFirstBtn;

  /// No description provided for @vitalsBpAverage.
  ///
  /// In en, this message translates to:
  /// **'Average ({count}): {sys}/{dia} mmHg'**
  String vitalsBpAverage(int count, int sys, int dia);

  /// No description provided for @vitalsLastPulse.
  ///
  /// In en, this message translates to:
  /// **' • Pulse {pulse} bpm'**
  String vitalsLastPulse(int pulse);

  /// No description provided for @vitalsBpHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dated Blood Pressure Logs'**
  String get vitalsBpHistoryTitle;

  /// No description provided for @vitalsSugarAverage.
  ///
  /// In en, this message translates to:
  /// **'Average ({count}): {avg} mg/dL'**
  String vitalsSugarAverage(int count, int avg);

  /// No description provided for @vitalsSugarHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dated Blood Sugar Logs'**
  String get vitalsSugarHistoryTitle;

  /// No description provided for @vitalsNewBpTitle.
  ///
  /// In en, this message translates to:
  /// **'New Blood Pressure Reading'**
  String get vitalsNewBpTitle;

  /// No description provided for @vitalsSystolicField.
  ///
  /// In en, this message translates to:
  /// **'Systolic (Top)'**
  String get vitalsSystolicField;

  /// No description provided for @vitalsDiastolicField.
  ///
  /// In en, this message translates to:
  /// **'Diastolic (Bottom)'**
  String get vitalsDiastolicField;

  /// No description provided for @vitalsPulseField.
  ///
  /// In en, this message translates to:
  /// **'Pulse (bpm — Optional)'**
  String get vitalsPulseField;

  /// No description provided for @vitalsNoteField.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get vitalsNoteField;

  /// No description provided for @vitalsSaveBpBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Blood Pressure'**
  String get vitalsSaveBpBtn;

  /// No description provided for @vitalsNewSugarTitle.
  ///
  /// In en, this message translates to:
  /// **'New Blood Sugar Reading'**
  String get vitalsNewSugarTitle;

  /// No description provided for @vitalsSugarValueField.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar (mg/dL)'**
  String get vitalsSugarValueField;

  /// No description provided for @vitalsSaveSugarBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Blood Sugar'**
  String get vitalsSaveSugarBtn;

  /// No description provided for @chartAddReadingHint.
  ///
  /// In en, this message translates to:
  /// **'Add readings to view chart'**
  String get chartAddReadingHint;

  /// No description provided for @loginTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use & Medical Notice'**
  String get loginTermsTitle;

  /// No description provided for @loginTermsCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand that VisualCheckUp does not provide a medical diagnosis and is for preliminary awareness only, and I accept the Terms of Use.'**
  String get loginTermsCheckbox;

  /// No description provided for @loginTermsRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Use & Medical Notice before signing in.'**
  String get loginTermsRequiredMsg;

  /// No description provided for @loginTermsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read Terms'**
  String get loginTermsReadMore;

  /// No description provided for @loginTermsModalBody.
  ///
  /// In en, this message translates to:
  /// **'• Not a Medical Diagnosis: VisualCheckUp is not a medical device and does not diagnose, treat, or replace a licensed physician.\n\n• Awareness & Preparation Only: Visual checks, lab summaries, and growth/BMI scales are informational tools to help you prepare for doctor visits.\n\n• Emergency Warning: If you experience severe pain, chest pain, shortness of breath, sudden vision loss, or urgent symptoms, seek emergency medical care immediately.\n\n• Privacy: Your health records stay on your device by default and are never sold or shared with third parties.'**
  String get loginTermsModalBody;

  /// No description provided for @loginTermsAcceptBtn.
  ///
  /// In en, this message translates to:
  /// **'I Have Read & Accept'**
  String get loginTermsAcceptBtn;

  /// No description provided for @atlasFilterAll.
  ///
  /// In en, this message translates to:
  /// **'Illustrated Atlas ({count})'**
  String atlasFilterAll(int count);

  /// No description provided for @atlasFilterUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent Signs ({count})'**
  String atlasFilterUrgent(int count);

  /// No description provided for @atlasFilterSelfTests.
  ///
  /// In en, this message translates to:
  /// **'Home Clinical Tests ({count})'**
  String atlasFilterSelfTests(int count);

  /// No description provided for @atlasUrgentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Signs Requiring Prompt Doctor Evaluation'**
  String get atlasUrgentSectionTitle;

  /// No description provided for @atlasTapToCompareHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any card to enlarge side-by-side with the healthy reference.'**
  String get atlasTapToCompareHint;

  /// No description provided for @atlasVisualCueLabel.
  ///
  /// In en, this message translates to:
  /// **'Visual Cue'**
  String get atlasVisualCueLabel;

  /// No description provided for @atlasClinicalContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Possible Clinical Context'**
  String get atlasClinicalContextLabel;

  /// No description provided for @atlasPossibleContextShort.
  ///
  /// In en, this message translates to:
  /// **'Possible Context'**
  String get atlasPossibleContextShort;

  /// No description provided for @atlasWarningPrefix.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get atlasWarningPrefix;

  /// No description provided for @atlasCloseBtn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get atlasCloseBtn;

  /// No description provided for @atlasCaptureProtocolTitle.
  ///
  /// In en, this message translates to:
  /// **'Best Capture Protocol'**
  String get atlasCaptureProtocolTitle;

  /// No description provided for @atlasHomeSelfTestsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Pre-Screening Tests You Can Do at Home'**
  String get atlasHomeSelfTestsSectionTitle;

  /// No description provided for @atlasSelfTestNormalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get atlasSelfTestNormalPrefix;

  /// No description provided for @atlasSelfTestWarningPrefix.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get atlasSelfTestWarningPrefix;

  /// No description provided for @fitzpatrickScaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitzpatrick Skin Phototypes & ITA° Calibration Scale'**
  String get fitzpatrickScaleTitle;

  /// No description provided for @fitzpatrickScaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The app measures the ITA° angle of surrounding healthy skin to balance analysis thresholds for your skin phototype.'**
  String get fitzpatrickScaleSubtitle;

  /// No description provided for @resultVisualCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Illustrated Clinical Reference Comparison'**
  String get resultVisualCompareTitle;

  /// No description provided for @resultHealthyShort.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get resultHealthyShort;

  /// No description provided for @resultMatchedShort.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get resultMatchedShort;

  /// No description provided for @resultViewFullAtlasBtn.
  ///
  /// In en, this message translates to:
  /// **'View Full Illustrated Atlas'**
  String get resultViewFullAtlasBtn;

  /// No description provided for @resultHomeSelfTestsBtn.
  ///
  /// In en, this message translates to:
  /// **'Home Clinical Tests'**
  String get resultHomeSelfTestsBtn;

  /// No description provided for @resultClinicalBiomarkersTitle.
  ///
  /// In en, this message translates to:
  /// **'Quantitative Clinical Measurements'**
  String get resultClinicalBiomarkersTitle;

  /// No description provided for @cameraEyeModeSclera.
  ///
  /// In en, this message translates to:
  /// **'Mode: Sclera (Jaundice)'**
  String get cameraEyeModeSclera;

  /// No description provided for @cameraEyeModeConjunctiva.
  ///
  /// In en, this message translates to:
  /// **'Lower Eyelid (Anemia)'**
  String get cameraEyeModeConjunctiva;

  /// No description provided for @cameraClinicalAtlasChip.
  ///
  /// In en, this message translates to:
  /// **'Clinical Tests & Atlas'**
  String get cameraClinicalAtlasChip;

  /// No description provided for @bristolScaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Bristol Stool Consistency Scale (Optional • Types 1–7)'**
  String get bristolScaleTitle;

  /// No description provided for @bristolType1Title.
  ///
  /// In en, this message translates to:
  /// **'Type 1 • Hard lumps'**
  String get bristolType1Title;

  /// No description provided for @bristolType2Title.
  ///
  /// In en, this message translates to:
  /// **'Type 2 • Lumpy sausage'**
  String get bristolType2Title;

  /// No description provided for @bristolType3Title.
  ///
  /// In en, this message translates to:
  /// **'Type 3 • Cracked sausage'**
  String get bristolType3Title;

  /// No description provided for @bristolType4Title.
  ///
  /// In en, this message translates to:
  /// **'Type 4 • Smooth (Ideal)'**
  String get bristolType4Title;

  /// No description provided for @bristolType5Title.
  ///
  /// In en, this message translates to:
  /// **'Type 5 • Soft blobs'**
  String get bristolType5Title;

  /// No description provided for @bristolType6Title.
  ///
  /// In en, this message translates to:
  /// **'Type 6 • Mushy / Loose'**
  String get bristolType6Title;

  /// No description provided for @bristolType7Title.
  ///
  /// In en, this message translates to:
  /// **'Type 7 • Entirely liquid'**
  String get bristolType7Title;

  /// No description provided for @metricFitzpatrickPhototype.
  ///
  /// In en, this message translates to:
  /// **'Fitzpatrick Phototype'**
  String get metricFitzpatrickPhototype;

  /// No description provided for @metricAbcdeAsymmetry.
  ///
  /// In en, this message translates to:
  /// **'A — Asymmetry'**
  String get metricAbcdeAsymmetry;

  /// No description provided for @metricAbcdeBorder.
  ///
  /// In en, this message translates to:
  /// **'B — Border Irregularity'**
  String get metricAbcdeBorder;

  /// No description provided for @metricAbcdeColors.
  ///
  /// In en, this message translates to:
  /// **'C — Dermoscopic Colors'**
  String get metricAbcdeColors;

  /// No description provided for @metricErythemaDelta.
  ///
  /// In en, this message translates to:
  /// **'Erythema Index Δ'**
  String get metricErythemaDelta;

  /// No description provided for @metricAnnularClearing.
  ///
  /// In en, this message translates to:
  /// **'Annular Central Clearing'**
  String get metricAnnularClearing;

  /// No description provided for @metricErythemaIndex.
  ///
  /// In en, this message translates to:
  /// **'Erythema Index (EI)'**
  String get metricErythemaIndex;

  /// No description provided for @metricScleraBilirubin.
  ///
  /// In en, this message translates to:
  /// **'Scleral Bilirubin Index'**
  String get metricScleraBilirubin;

  /// No description provided for @metricHemorrhagePatch.
  ///
  /// In en, this message translates to:
  /// **'Compact Hemorrhage Area'**
  String get metricHemorrhagePatch;

  /// No description provided for @metricNailErythema.
  ///
  /// In en, this message translates to:
  /// **'Nailbed Erythema Index'**
  String get metricNailErythema;

  /// No description provided for @metricBeauGroove.
  ///
  /// In en, this message translates to:
  /// **'Beau Transverse Groove'**
  String get metricBeauGroove;

  /// No description provided for @metricTerryLindsaySplit.
  ///
  /// In en, this message translates to:
  /// **'Proximal/Distal Split'**
  String get metricTerryLindsaySplit;

  /// No description provided for @metricSplinterStreak.
  ///
  /// In en, this message translates to:
  /// **'Splinter Streak Ratio'**
  String get metricSplinterStreak;

  /// No description provided for @metricGeographicTongue.
  ///
  /// In en, this message translates to:
  /// **'Geographic Tongue Score'**
  String get metricGeographicTongue;

  /// No description provided for @metricYellowCoating.
  ///
  /// In en, this message translates to:
  /// **'Yellow Coating Ratio'**
  String get metricYellowCoating;

  /// No description provided for @metricBristolScale.
  ///
  /// In en, this message translates to:
  /// **'Bristol Scale'**
  String get metricBristolScale;

  /// No description provided for @hubStartNewScan.
  ///
  /// In en, this message translates to:
  /// **'Start New Scan'**
  String get hubStartNewScan;

  /// No description provided for @hubPickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get hubPickFromGallery;

  /// No description provided for @hubPastScansTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Scans ({count})'**
  String hubPastScansTitle(int count);

  /// No description provided for @hubTotalScansLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get hubTotalScansLabel;

  /// No description provided for @hubLastScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Scan'**
  String get hubLastScanLabel;

  /// No description provided for @hubLatestStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest Status'**
  String get hubLatestStatusLabel;

  /// No description provided for @hubFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hubFilterAll;

  /// No description provided for @hubFilterAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention / Urgent'**
  String get hubFilterAttention;

  /// No description provided for @hubFilterWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'With Photo'**
  String get hubFilterWithPhoto;

  /// No description provided for @hubColPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get hubColPhoto;

  /// No description provided for @hubColDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hubColDate;

  /// No description provided for @hubColFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding & Summary'**
  String get hubColFinding;

  /// No description provided for @hubColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get hubColStatus;

  /// No description provided for @hubCompareModeBtn.
  ///
  /// In en, this message translates to:
  /// **'Compare 2 Scans'**
  String get hubCompareModeBtn;

  /// No description provided for @hubCompareSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select 2 scans from the table to compare side-by-side ({count}/2)'**
  String hubCompareSelectHint(int count);

  /// No description provided for @hubCompareActionBtn.
  ///
  /// In en, this message translates to:
  /// **'Compare Side-by-Side'**
  String get hubCompareActionBtn;

  /// No description provided for @hubCompareCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get hubCompareCancelBtn;

  /// No description provided for @hubCompareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Side-by-Side Scan Comparison'**
  String get hubCompareSheetTitle;

  /// No description provided for @hubCompareOlderLabel.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get hubCompareOlderLabel;

  /// No description provided for @hubCompareNewerLabel.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get hubCompareNewerLabel;

  /// No description provided for @hubCompareMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Metrics Comparison'**
  String get hubCompareMetricsTitle;

  /// No description provided for @hubEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No {category} scans yet'**
  String hubEmptyTitle(String category);

  /// No description provided for @hubEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first scan above. Every check is saved chronologically here with its thumbnail photo and full analysis report.'**
  String get hubEmptySubtitle;

  /// No description provided for @hubDoctorSummaryBtn.
  ///
  /// In en, this message translates to:
  /// **'Doctor Summary'**
  String get hubDoctorSummaryBtn;

  /// No description provided for @photoTapToZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Tap photo to zoom full-screen'**
  String get photoTapToZoomHint;

  /// No description provided for @photoZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Captured Photo'**
  String get photoZoomTitle;

  /// No description provided for @resultDeleteRecordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get resultDeleteRecordTooltip;

  /// No description provided for @resultDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this scan?'**
  String get resultDeleteConfirmTitle;

  /// No description provided for @resultDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This checkup record will be permanently removed from your local history.'**
  String get resultDeleteConfirmBody;

  /// No description provided for @resultDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get resultDeleteBtn;

  /// No description provided for @labLargeTextBtn.
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get labLargeTextBtn;

  /// No description provided for @labLargeTextOnBtn.
  ///
  /// In en, this message translates to:
  /// **'Large Text: On'**
  String get labLargeTextOnBtn;

  /// No description provided for @labSeniorOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Summary at a Glance'**
  String get labSeniorOverviewTitle;

  /// No description provided for @labSeniorNormalBullet.
  ///
  /// In en, this message translates to:
  /// **'{count} test(s) are within the normal range.'**
  String labSeniorNormalBullet(int count);

  /// No description provided for @labSeniorAbnormalBullet.
  ///
  /// In en, this message translates to:
  /// **'{count} test(s) are outside the reference range — explained simply below.'**
  String labSeniorAbnormalBullet(int count);

  /// No description provided for @labSeniorCriticalBullet.
  ///
  /// In en, this message translates to:
  /// **'{count} test(s) are noticeably outside normal limits — please show your doctor soon.'**
  String labSeniorCriticalBullet(int count);

  /// No description provided for @labSeniorMissingBullet.
  ///
  /// In en, this message translates to:
  /// **'{count} common routine test(s) are not included in this report.'**
  String labSeniorMissingBullet(int count);

  /// No description provided for @labAttentionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Values to Pay Attention To'**
  String get labAttentionSectionTitle;

  /// No description provided for @labNormalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Normal Values (Good News)'**
  String get labNormalSectionTitle;

  /// No description provided for @labMissingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests Not Included in This Report'**
  String get labMissingSectionTitle;

  /// No description provided for @labMissingSectionExplain.
  ///
  /// In en, this message translates to:
  /// **'Not every blood test order includes all panels. The common tests below were not listed in this report, so they were not evaluated.'**
  String get labMissingSectionExplain;

  /// No description provided for @labNotInReportBadge.
  ///
  /// In en, this message translates to:
  /// **'Not in report'**
  String get labNotInReportBadge;

  /// No description provided for @labWhatItMeansLabel.
  ///
  /// In en, this message translates to:
  /// **'What it means'**
  String get labWhatItMeansLabel;

  /// No description provided for @labWhatToDoLabel.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get labWhatToDoLabel;

  /// No description provided for @labAddAnotherPageBtn.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Page'**
  String get labAddAnotherPageBtn;

  /// No description provided for @labPagesReadBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} page(s) read'**
  String labPagesReadBadge(int count);

  /// No description provided for @labPhotoOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Paper photo attached. Enable Cloud AI in Settings to read paper photos automatically, or enter values manually below.'**
  String get labPhotoOfflineHint;

  /// No description provided for @labAllValuesNormalMsg.
  ///
  /// In en, this message translates to:
  /// **'All recorded values in this report are within the reference range.'**
  String get labAllValuesNormalMsg;

  /// No description provided for @medTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication & Alarm Reminder'**
  String get medTitle;

  /// No description provided for @medSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track pills, insulin & health alarms with photos'**
  String get medSubtitle;

  /// No description provided for @medMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Alarms'**
  String get medMenuTitle;

  /// No description provided for @medHomeCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alarms yet — add your first reminder'**
  String get medHomeCardEmpty;

  /// No description provided for @medHomeCardTodaySummary.
  ///
  /// In en, this message translates to:
  /// **'{taken}/{total} taken today'**
  String medHomeCardTodaySummary(int taken, int total);

  /// No description provided for @medHomeCardActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active alarms'**
  String medHomeCardActiveCount(int count);

  /// No description provided for @medTabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get medTabToday;

  /// No description provided for @medTabAll.
  ///
  /// In en, this message translates to:
  /// **'All Alarms'**
  String get medTabAll;

  /// No description provided for @medAddAlarm.
  ///
  /// In en, this message translates to:
  /// **'Add New Alarm'**
  String get medAddAlarm;

  /// No description provided for @medEditAlarm.
  ///
  /// In en, this message translates to:
  /// **'Edit Alarm'**
  String get medEditAlarm;

  /// No description provided for @medCatPill.
  ///
  /// In en, this message translates to:
  /// **'Medicine / Pill'**
  String get medCatPill;

  /// No description provided for @medCatDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Pill / Insulin'**
  String get medCatDiabetes;

  /// No description provided for @medCatBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure Med'**
  String get medCatBloodPressure;

  /// No description provided for @medCatVitamin.
  ///
  /// In en, this message translates to:
  /// **'Vitamin / Supplement'**
  String get medCatVitamin;

  /// No description provided for @medCatDropsCream.
  ///
  /// In en, this message translates to:
  /// **'Eye Drops / Cream'**
  String get medCatDropsCream;

  /// No description provided for @medCatCheckup.
  ///
  /// In en, this message translates to:
  /// **'Vitals / Checkup'**
  String get medCatCheckup;

  /// No description provided for @medCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get medCatOther;

  /// No description provided for @medMealAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get medMealAnytime;

  /// No description provided for @medMealBefore.
  ///
  /// In en, this message translates to:
  /// **'Before meal'**
  String get medMealBefore;

  /// No description provided for @medMealAfter.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get medMealAfter;

  /// No description provided for @medMealWith.
  ///
  /// In en, this message translates to:
  /// **'With meal'**
  String get medMealWith;

  /// No description provided for @medMealBedtime.
  ///
  /// In en, this message translates to:
  /// **'At bedtime'**
  String get medMealBedtime;

  /// No description provided for @medDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get medDayMon;

  /// No description provided for @medDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get medDayTue;

  /// No description provided for @medDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get medDayWed;

  /// No description provided for @medDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get medDayThu;

  /// No description provided for @medDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get medDayFri;

  /// No description provided for @medDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get medDaySat;

  /// No description provided for @medDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get medDaySun;

  /// No description provided for @medEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every Day'**
  String get medEveryDay;

  /// No description provided for @medWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get medWeekdays;

  /// No description provided for @medWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get medWeekends;

  /// No description provided for @medFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get medFieldCategory;

  /// No description provided for @medFieldName.
  ///
  /// In en, this message translates to:
  /// **'Medicine / Reminder Name'**
  String get medFieldName;

  /// No description provided for @medFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Metformin 1000 mg, Evening Insulin...'**
  String get medFieldNameHint;

  /// No description provided for @medFieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a medicine or reminder name.'**
  String get medFieldNameRequired;

  /// No description provided for @medFieldDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage / Amount (Optional)'**
  String get medFieldDosage;

  /// No description provided for @medFieldDosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tablet, 12 units, 2 drops'**
  String get medFieldDosageHint;

  /// No description provided for @medFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder Note (Shown on Alarm)'**
  String get medFieldDescription;

  /// No description provided for @medFieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Take 30 min before breakfast with a full glass of water'**
  String get medFieldDescriptionHint;

  /// No description provided for @medFieldMealTiming.
  ///
  /// In en, this message translates to:
  /// **'Meal Timing'**
  String get medFieldMealTiming;

  /// No description provided for @medFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Alarm Time'**
  String get medFieldTime;

  /// No description provided for @medFieldDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat Days'**
  String get medFieldDays;

  /// No description provided for @medFieldPhoto.
  ///
  /// In en, this message translates to:
  /// **'Medicine Photo (Shown When Alarm Rings)'**
  String get medFieldPhoto;

  /// No description provided for @medTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get medTakePhoto;

  /// No description provided for @medPickGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get medPickGallery;

  /// No description provided for @medRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get medRemovePhoto;

  /// No description provided for @medPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Snap the medicine box or insulin pen so it displays clearly when the alarm rings.'**
  String get medPhotoHint;

  /// No description provided for @medSoundToggle.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get medSoundToggle;

  /// No description provided for @medVibrateToggle.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get medVibrateToggle;

  /// No description provided for @medSaveAlarm.
  ///
  /// In en, this message translates to:
  /// **'Save Alarm'**
  String get medSaveAlarm;

  /// No description provided for @medAlarmSaved.
  ///
  /// In en, this message translates to:
  /// **'Alarm saved and scheduled.'**
  String get medAlarmSaved;

  /// No description provided for @medAlarmDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alarm deleted.'**
  String get medAlarmDeleted;

  /// No description provided for @medDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Alarm'**
  String get medDeleteConfirmTitle;

  /// No description provided for @medDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete the \"{title}\" alarm?'**
  String medDeleteConfirmBody(String title);

  /// No description provided for @medStatusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get medStatusTaken;

  /// No description provided for @medStatusSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get medStatusSnoozed;

  /// No description provided for @medStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get medStatusSkipped;

  /// No description provided for @medStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get medStatusPending;

  /// No description provided for @medActionTaken.
  ///
  /// In en, this message translates to:
  /// **'I Took It'**
  String get medActionTaken;

  /// No description provided for @medActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get medActionSnooze;

  /// No description provided for @medActionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip Today'**
  String get medActionSkip;

  /// No description provided for @medActionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get medActionUndo;

  /// No description provided for @medActionPreviewAlarm.
  ///
  /// In en, this message translates to:
  /// **'Test Alarm'**
  String get medActionPreviewAlarm;

  /// No description provided for @medRingHeader.
  ///
  /// In en, this message translates to:
  /// **'MEDICATION TIME'**
  String get medRingHeader;

  /// No description provided for @medRingNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Note'**
  String get medRingNoteTitle;

  /// No description provided for @medRingNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No medicine photo added'**
  String get medRingNoPhoto;

  /// No description provided for @medRingTapZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap photo to zoom'**
  String get medRingTapZoom;

  /// No description provided for @medRingSnoozedToast.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for 10 minutes.'**
  String get medRingSnoozedToast;

  /// No description provided for @medRingTakenToast.
  ///
  /// In en, this message translates to:
  /// **'Great! Today\'s dose marked as taken.'**
  String get medRingTakenToast;

  /// No description provided for @medTodayProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medication Plan'**
  String get medTodayProgressTitle;

  /// No description provided for @medNextAlarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Next alarm: {time} • {title}'**
  String medNextAlarmLabel(String time, String title);

  /// No description provided for @medNoTodayAlarms.
  ///
  /// In en, this message translates to:
  /// **'No medication alarms scheduled for today.'**
  String get medNoTodayAlarms;

  /// No description provided for @medEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Medication Alarms Yet'**
  String get medEmptyTitle;

  /// No description provided for @medEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add photo-supported alarms for diabetes pills, insulin, blood pressure meds, or daily checks. When it\'s time, the medicine photo and your note appear clearly on screen.'**
  String get medEmptyBody;

  /// No description provided for @medQuickPresetDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes / Insulin'**
  String get medQuickPresetDiabetes;

  /// No description provided for @medQuickPresetBp.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get medQuickPresetBp;

  /// No description provided for @medQuickPresetVitamin.
  ///
  /// In en, this message translates to:
  /// **'Vitamin'**
  String get medQuickPresetVitamin;

  /// No description provided for @dietMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet & AI Calorie Tracker'**
  String get dietMenuTitle;

  /// No description provided for @dietHomeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet & Meal Plans'**
  String get dietHomeCardTitle;

  /// No description provided for @dietHomeCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Ready-made diets, compliance & weight tracking'**
  String get dietHomeCardEmpty;

  /// No description provided for @dietHomeCardActive.
  ///
  /// In en, this message translates to:
  /// **'Day {day}/{total} • {percent}% compliance'**
  String dietHomeCardActive(int day, int total, int percent);

  /// No description provided for @dietCalorieQuickTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Plate Calorie Counter'**
  String get dietCalorieQuickTitle;

  /// No description provided for @dietCalorieQuickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snap your plate photo to calculate calories & macros'**
  String get dietCalorieQuickSubtitle;

  /// No description provided for @dietTabActive.
  ///
  /// In en, this message translates to:
  /// **'My Diet'**
  String get dietTabActive;

  /// No description provided for @dietTabTemplates.
  ///
  /// In en, this message translates to:
  /// **'Diet Plans'**
  String get dietTabTemplates;

  /// No description provided for @dietTabWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get dietTabWeight;

  /// No description provided for @dietTabCalories.
  ///
  /// In en, this message translates to:
  /// **'AI Calories'**
  String get dietTabCalories;

  /// No description provided for @dietStartDiet.
  ///
  /// In en, this message translates to:
  /// **'Start Diet'**
  String get dietStartDiet;

  /// No description provided for @dietRestartOrChange.
  ///
  /// In en, this message translates to:
  /// **'Change Diet'**
  String get dietRestartOrChange;

  /// No description provided for @dietEndDiet.
  ///
  /// In en, this message translates to:
  /// **'End Diet'**
  String get dietEndDiet;

  /// No description provided for @dietEndDietConfirm.
  ///
  /// In en, this message translates to:
  /// **'End your active diet plan? Your compliance and weight records will be kept.'**
  String get dietEndDietConfirm;

  /// No description provided for @dietNoActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active Diet Yet'**
  String get dietNoActiveTitle;

  /// No description provided for @dietNoActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Choose from ready-made clinical diet templates (Mediterranean, Diabetes-Friendly, DASH, Weight Loss, 16:8 Fasting, High Protein) and track daily compliance & weight.'**
  String get dietNoActiveBody;

  /// No description provided for @dietBrowseTemplates.
  ///
  /// In en, this message translates to:
  /// **'Browse Ready-Made Diets'**
  String get dietBrowseTemplates;

  /// No description provided for @dietStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get dietStartDate;

  /// No description provided for @dietEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get dietEndDate;

  /// No description provided for @dietStartWeight.
  ///
  /// In en, this message translates to:
  /// **'Start Weight (kg)'**
  String get dietStartWeight;

  /// No description provided for @dietTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight (kg)'**
  String get dietTargetWeight;

  /// No description provided for @dietDailyCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Target (kcal)'**
  String get dietDailyCalorieTarget;

  /// No description provided for @dietDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String dietDurationDays(int days);

  /// No description provided for @dietDayProgress.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String dietDayProgress(int day, int total);

  /// No description provided for @dietDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String dietDaysLeft(int days);

  /// No description provided for @dietComplianceRate.
  ///
  /// In en, this message translates to:
  /// **'Compliance: {percent}%'**
  String dietComplianceRate(int percent);

  /// No description provided for @dietFollowed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get dietFollowed;

  /// No description provided for @dietNotFollowed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get dietNotFollowed;

  /// No description provided for @dietPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dietPending;

  /// No description provided for @dietSlotBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get dietSlotBreakfast;

  /// No description provided for @dietSlotMorningSnack.
  ///
  /// In en, this message translates to:
  /// **'Morning Snack'**
  String get dietSlotMorningSnack;

  /// No description provided for @dietSlotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get dietSlotLunch;

  /// No description provided for @dietSlotAfternoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Snack'**
  String get dietSlotAfternoonSnack;

  /// No description provided for @dietSlotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dietSlotDinner;

  /// No description provided for @dietAlternativesLabel.
  ///
  /// In en, this message translates to:
  /// **'Alternative'**
  String get dietAlternativesLabel;

  /// No description provided for @dietWaterTarget.
  ///
  /// In en, this message translates to:
  /// **'Water target: {liters} L'**
  String dietWaterTarget(String liters);

  /// No description provided for @dietRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Guidelines'**
  String get dietRulesTitle;

  /// No description provided for @dietSampleMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Daily Menu'**
  String get dietSampleMenuTitle;

  /// No description provided for @dietStartedToast.
  ///
  /// In en, this message translates to:
  /// **'Diet plan started! Stay consistent.'**
  String get dietStartedToast;

  /// No description provided for @dietEndedToast.
  ///
  /// In en, this message translates to:
  /// **'Active diet plan ended.'**
  String get dietEndedToast;

  /// No description provided for @dietWeightLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Weight Tracking'**
  String get dietWeightLogTitle;

  /// No description provided for @dietWeightAdd.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get dietWeightAdd;

  /// No description provided for @dietWeightField.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get dietWeightField;

  /// No description provided for @dietWeightNote.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get dietWeightNote;

  /// No description provided for @dietWeightNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning fasting weight'**
  String get dietWeightNoteHint;

  /// No description provided for @dietWeightEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weight entries yet. Log your first weight to track your trend.'**
  String get dietWeightEmpty;

  /// No description provided for @dietWeightCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get dietWeightCurrent;

  /// No description provided for @dietWeightTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get dietWeightTarget;

  /// No description provided for @dietWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get dietWeightChange;

  /// No description provided for @dietWeightSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight entry saved.'**
  String get dietWeightSaved;

  /// No description provided for @dietCalorieTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Plate Calorie Calculator'**
  String get dietCalorieTitle;

  /// No description provided for @dietCalorieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Works with or without a diet — snap a plate photo or describe your meal.'**
  String get dietCalorieSubtitle;

  /// No description provided for @dietSnapPlateCamera.
  ///
  /// In en, this message translates to:
  /// **'Snap Plate Photo'**
  String get dietSnapPlateCamera;

  /// No description provided for @dietPickPlateGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get dietPickPlateGallery;

  /// No description provided for @dietFoodDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Description / Portion (Optional)'**
  String get dietFoodDescLabel;

  /// No description provided for @dietFoodDescHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grilled chicken, bulgur pilaf, green salad, ayran'**
  String get dietFoodDescHint;

  /// No description provided for @dietCalculateFromText.
  ///
  /// In en, this message translates to:
  /// **'Calculate from Text'**
  String get dietCalculateFromText;

  /// No description provided for @dietAnalyzingPlate.
  ///
  /// In en, this message translates to:
  /// **'Analyzing plate calories & macros...'**
  String get dietAnalyzingPlate;

  /// No description provided for @dietResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie & Macro Analysis'**
  String get dietResultTitle;

  /// No description provided for @dietAiPoweredBadge.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI Vision'**
  String get dietAiPoweredBadge;

  /// No description provided for @dietOnDeviceBadge.
  ///
  /// In en, this message translates to:
  /// **'Smart On-Device Estimate'**
  String get dietOnDeviceBadge;

  /// No description provided for @dietProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dietProtein;

  /// No description provided for @dietCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get dietCarbs;

  /// No description provided for @dietFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get dietFat;

  /// No description provided for @dietFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get dietFiber;

  /// No description provided for @dietPortionScale.
  ///
  /// In en, this message translates to:
  /// **'Portion Size'**
  String get dietPortionScale;

  /// No description provided for @dietSaveMealLog.
  ///
  /// In en, this message translates to:
  /// **'Save to Today\'s Log'**
  String get dietSaveMealLog;

  /// No description provided for @dietMealLoggedToast.
  ///
  /// In en, this message translates to:
  /// **'Meal calories saved to today\'s log.'**
  String get dietMealLoggedToast;

  /// No description provided for @dietTodayTotalCalories.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Total'**
  String get dietTodayTotalCalories;

  /// No description provided for @dietRecentScans.
  ///
  /// In en, this message translates to:
  /// **'Scanned Meals'**
  String get dietRecentScans;

  /// No description provided for @dietNoScansYet.
  ///
  /// In en, this message translates to:
  /// **'No meals scanned yet. Take a photo of your plate to estimate calories.'**
  String get dietNoScansYet;

  /// No description provided for @dietHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Balance Score: {score}/10'**
  String dietHealthScore(int score);

  /// No description provided for @dietTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dietTodayLabel;

  /// No description provided for @medCatHerbalTea.
  ///
  /// In en, this message translates to:
  /// **'Herbal Tea'**
  String get medCatHerbalTea;

  /// No description provided for @medCatCustom.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get medCatCustom;

  /// No description provided for @medFieldCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom Category Name'**
  String get medFieldCustomCategory;

  /// No description provided for @medFieldCustomCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Probiotic, Herbal Blend, Water, Physio...'**
  String get medFieldCustomCategoryHint;

  /// No description provided for @medQuickPresetHerbalTea.
  ///
  /// In en, this message translates to:
  /// **'Herbal Tea'**
  String get medQuickPresetHerbalTea;

  /// No description provided for @dietCreateCustom.
  ///
  /// In en, this message translates to:
  /// **'Create My Own Diet'**
  String get dietCreateCustom;

  /// No description provided for @dietCreateCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your dietitian\'s list or your own meal plan manually'**
  String get dietCreateCustomSubtitle;

  /// No description provided for @dietCustomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan Name'**
  String get dietCustomNameLabel;

  /// No description provided for @dietCustomNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Dietitian Plan, Custom Healthy Menu...'**
  String get dietCustomNameHint;

  /// No description provided for @dietCustomNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a diet plan name.'**
  String get dietCustomNameRequired;

  /// No description provided for @dietCustomMealHint.
  ///
  /// In en, this message translates to:
  /// **'What is planned for this meal?'**
  String get dietCustomMealHint;

  /// No description provided for @dietCustomMealCaloriesHint.
  ///
  /// In en, this message translates to:
  /// **'kcal (optional)'**
  String get dietCustomMealCaloriesHint;

  /// No description provided for @dietCustomAtLeastOneMeal.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one meal.'**
  String get dietCustomAtLeastOneMeal;

  /// No description provided for @dietCustomTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Custom Diet Plans'**
  String get dietCustomTemplatesTitle;

  /// No description provided for @dietReadyTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-Made Diet Templates'**
  String get dietReadyTemplatesTitle;

  /// No description provided for @donateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Support & Donate'**
  String get donateTooltip;

  /// No description provided for @donateMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Support VisualCheckUp'**
  String get donateMenuLabel;

  /// No description provided for @donateMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee, meal or gift to support free health tools'**
  String get donateMenuSubtitle;

  /// No description provided for @donatePopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Support VisualCheckUp'**
  String get donatePopupTitle;

  /// No description provided for @donatePopupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your voluntary support helps us keep health screening, lab reading, medication alarms, and diet tools free and improving.'**
  String get donatePopupSubtitle;

  /// No description provided for @donateTierCoffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a Coffee'**
  String get donateTierCoffeeTitle;

  /// No description provided for @donateTierCoffeeDesc.
  ///
  /// In en, this message translates to:
  /// **'A warm cup of coffee for development'**
  String get donateTierCoffeeDesc;

  /// No description provided for @donateTierMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Treat to a Meal'**
  String get donateTierMealTitle;

  /// No description provided for @donateTierMealDesc.
  ///
  /// In en, this message translates to:
  /// **'Great support for new health features'**
  String get donateTierMealDesc;

  /// No description provided for @donateTierGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Gift'**
  String get donateTierGiftTitle;

  /// No description provided for @donateTierGiftDesc.
  ///
  /// In en, this message translates to:
  /// **'Helps cover AI & server maintenance costs'**
  String get donateTierGiftDesc;

  /// No description provided for @donateTierGoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Big Support'**
  String get donateTierGoldTitle;

  /// No description provided for @donateTierGoldDesc.
  ///
  /// In en, this message translates to:
  /// **'Powers upcoming medical modules & languages'**
  String get donateTierGoldDesc;

  /// No description provided for @donateTierHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Hero'**
  String get donateTierHeroTitle;

  /// No description provided for @donateTierHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Supports free health tracking for all families'**
  String get donateTierHeroDesc;

  /// No description provided for @donatePopularBadge.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get donatePopularBadge;

  /// No description provided for @donateConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Donate {price}'**
  String donateConfirmButton(String price);

  /// No description provided for @donateLaterButton.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get donateLaterButton;

  /// No description provided for @donateThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank You for Your Support!'**
  String get donateThanksTitle;

  /// No description provided for @donateThanksBody.
  ///
  /// In en, this message translates to:
  /// **'Your {tier} ({price}) support means a lot to us. Thank you for helping keep VisualCheckUp growing!'**
  String donateThanksBody(String tier, String price);

  /// No description provided for @donateSupporterBadge.
  ///
  /// In en, this message translates to:
  /// **'Supporter • Thank you!'**
  String get donateSupporterBadge;

  /// No description provided for @donateStoreNotice.
  ///
  /// In en, this message translates to:
  /// **'Voluntary one-time support • No subscription'**
  String get donateStoreNotice;

  /// No description provided for @medFieldAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm Ringtone'**
  String get medFieldAlarmSound;

  /// No description provided for @medAlarmSoundClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Alarm'**
  String get medAlarmSoundClassic;

  /// No description provided for @medAlarmSoundClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Crisp alarm clock ring'**
  String get medAlarmSoundClassicDesc;

  /// No description provided for @medAlarmSoundGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle Chime'**
  String get medAlarmSoundGentle;

  /// No description provided for @medAlarmSoundGentleDesc.
  ///
  /// In en, this message translates to:
  /// **'Calm rising chime melody'**
  String get medAlarmSoundGentleDesc;

  /// No description provided for @medAlarmSoundRadar.
  ///
  /// In en, this message translates to:
  /// **'Modern Radar'**
  String get medAlarmSoundRadar;

  /// No description provided for @medAlarmSoundRadarDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear rhythmic alarm pulse'**
  String get medAlarmSoundRadarDesc;

  /// No description provided for @medAlarmSoundBell.
  ///
  /// In en, this message translates to:
  /// **'Health Bell'**
  String get medAlarmSoundBell;

  /// No description provided for @medAlarmSoundBellDesc.
  ///
  /// In en, this message translates to:
  /// **'Bright classic twin-bell ring'**
  String get medAlarmSoundBellDesc;

  /// No description provided for @medAlarmSoundUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent High Alert'**
  String get medAlarmSoundUrgent;

  /// No description provided for @medAlarmSoundUrgentDesc.
  ///
  /// In en, this message translates to:
  /// **'Strong insistent tone for critical doses'**
  String get medAlarmSoundUrgentDesc;

  /// No description provided for @medAlarmSoundSystem.
  ///
  /// In en, this message translates to:
  /// **'Device Alarm Tone'**
  String get medAlarmSoundSystem;

  /// No description provided for @medAlarmSoundSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses your phone\'s default alarm ringtone'**
  String get medAlarmSoundSystemDesc;

  /// No description provided for @medSoundPreviewPlay.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get medSoundPreviewPlay;

  /// No description provided for @medSoundPreviewStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get medSoundPreviewStop;

  /// No description provided for @medSoundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get medSoundSilent;

  /// No description provided for @medPreviewModeBadge.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get medPreviewModeBadge;

  /// No description provided for @commMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Community'**
  String get commMenuTitle;

  /// No description provided for @commHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Worldwide health buddies, profile likes & safe messaging'**
  String get commHomeSubtitle;

  /// No description provided for @commTabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get commTabDiscover;

  /// No description provided for @commTabMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get commTabMessages;

  /// No description provided for @commTabMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get commTabMyProfile;

  /// No description provided for @commSafetyBanner.
  ///
  /// In en, this message translates to:
  /// **'Peer wellness & motivation only — never medical advice or diagnosis. Your private lab reports and scans are never shared.'**
  String get commSafetyBanner;

  /// No description provided for @commSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, city, or wellness note...'**
  String get commSearchHint;

  /// No description provided for @commFilterAllGoals.
  ///
  /// In en, this message translates to:
  /// **'All Goals'**
  String get commFilterAllGoals;

  /// No description provided for @commFilterAllCountries.
  ///
  /// In en, this message translates to:
  /// **'Worldwide'**
  String get commFilterAllCountries;

  /// No description provided for @commEmptyDiscover.
  ///
  /// In en, this message translates to:
  /// **'No health profiles match your filters yet.'**
  String get commEmptyDiscover;

  /// No description provided for @commGoalDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes & Blood Sugar'**
  String get commGoalDiabetes;

  /// No description provided for @commGoalBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure & Heart'**
  String get commGoalBloodPressure;

  /// No description provided for @commGoalWeightDiet.
  ///
  /// In en, this message translates to:
  /// **'Weight & Healthy Diet'**
  String get commGoalWeightDiet;

  /// No description provided for @commGoalHealthyLiving.
  ///
  /// In en, this message translates to:
  /// **'Healthy Living'**
  String get commGoalHealthyLiving;

  /// No description provided for @commGoalHerbalWellness.
  ///
  /// In en, this message translates to:
  /// **'Herbal Tea & Natural Care'**
  String get commGoalHerbalWellness;

  /// No description provided for @commGoalParentingGrowth.
  ///
  /// In en, this message translates to:
  /// **'Parents & Child Growth'**
  String get commGoalParentingGrowth;

  /// No description provided for @commGoalSkinCare.
  ///
  /// In en, this message translates to:
  /// **'Skin & Daily Care'**
  String get commGoalSkinCare;

  /// No description provided for @commGoalFitnessWalk.
  ///
  /// In en, this message translates to:
  /// **'Walking & Movement'**
  String get commGoalFitnessWalk;

  /// No description provided for @commGoalSleepStress.
  ///
  /// In en, this message translates to:
  /// **'Sleep & Stress Balance'**
  String get commGoalSleepStress;

  /// No description provided for @commLikesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Likes'**
  String commLikesCount(int count);

  /// No description provided for @commLikeAction.
  ///
  /// In en, this message translates to:
  /// **'Like Profile'**
  String get commLikeAction;

  /// No description provided for @commUnlikeAction.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get commUnlikeAction;

  /// No description provided for @commSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get commSendMessage;

  /// No description provided for @commMessagesDisabled.
  ///
  /// In en, this message translates to:
  /// **'This member has disabled direct messages.'**
  String get commMessagesDisabled;

  /// No description provided for @commOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Global Health Community'**
  String get commOptInTitle;

  /// No description provided for @commOptInBody.
  ///
  /// In en, this message translates to:
  /// **'Connect with people worldwide who share your health goals. Joining is completely optional — your lab reports, camera scans, and medication photos stay 100% private on your device.'**
  String get commOptInBody;

  /// No description provided for @commOptInButton.
  ///
  /// In en, this message translates to:
  /// **'Create My Health Profile'**
  String get commOptInButton;

  /// No description provided for @commFieldDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get commFieldDisplayName;

  /// No description provided for @commFieldNickname.
  ///
  /// In en, this message translates to:
  /// **'Username (@handle)'**
  String get commFieldNickname;

  /// No description provided for @commFieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get commFieldCountry;

  /// No description provided for @commFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City (optional)'**
  String get commFieldCity;

  /// No description provided for @commFieldLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get commFieldLanguage;

  /// No description provided for @commFieldGoals.
  ///
  /// In en, this message translates to:
  /// **'Health & Wellness Goals'**
  String get commFieldGoals;

  /// No description provided for @commFieldBio.
  ///
  /// In en, this message translates to:
  /// **'About Me & Health Journey'**
  String get commFieldBio;

  /// No description provided for @commFieldDailyFocus.
  ///
  /// In en, this message translates to:
  /// **'Daily Wellness Focus'**
  String get commFieldDailyFocus;

  /// No description provided for @commPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Messaging Controls'**
  String get commPrivacySection;

  /// No description provided for @commToggleDiscoverable.
  ///
  /// In en, this message translates to:
  /// **'Show my profile in Global Discover'**
  String get commToggleDiscoverable;

  /// No description provided for @commToggleHideRealName.
  ///
  /// In en, this message translates to:
  /// **'Hide real name (show @username only)'**
  String get commToggleHideRealName;

  /// No description provided for @commToggleHidePhoto.
  ///
  /// In en, this message translates to:
  /// **'Hide profile photo'**
  String get commToggleHidePhoto;

  /// No description provided for @commToggleAllowMessages.
  ///
  /// In en, this message translates to:
  /// **'Allow direct messages'**
  String get commToggleAllowMessages;

  /// No description provided for @commToggleRequireApproval.
  ///
  /// In en, this message translates to:
  /// **'Require my approval for new message requests'**
  String get commToggleRequireApproval;

  /// No description provided for @commUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo'**
  String get commUploadPhoto;

  /// No description provided for @commRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get commRemovePhoto;

  /// No description provided for @commSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Health Profile'**
  String get commSaveProfile;

  /// No description provided for @commProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Health community profile updated.'**
  String get commProfileSaved;

  /// No description provided for @commLeaveCommunity.
  ///
  /// In en, this message translates to:
  /// **'Leave Community & Delete Public Profile'**
  String get commLeaveCommunity;

  /// No description provided for @commLeftCommunity.
  ///
  /// In en, this message translates to:
  /// **'Your public community profile has been removed.'**
  String get commLeftCommunity;

  /// No description provided for @commInboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Discover health buddies and say hello!'**
  String get commInboxEmpty;

  /// No description provided for @commMessageRequestBadge.
  ///
  /// In en, this message translates to:
  /// **'Message Request'**
  String get commMessageRequestBadge;

  /// No description provided for @commRequestBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'New message request'**
  String get commRequestBannerTitle;

  /// No description provided for @commRequestBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Accept to keep chatting, or decline/block this member.'**
  String get commRequestBannerBody;

  /// No description provided for @commRequestAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commRequestAccept;

  /// No description provided for @commRequestDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get commRequestDecline;

  /// No description provided for @commChatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a supportive message...'**
  String get commChatPlaceholder;

  /// No description provided for @commAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get commAttachPhoto;

  /// No description provided for @commPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get commPhotoLabel;

  /// No description provided for @commRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few seconds before sending another message.'**
  String get commRateLimited;

  /// No description provided for @commBlockedNotice.
  ///
  /// In en, this message translates to:
  /// **'You cannot message this user due to block settings.'**
  String get commBlockedNotice;

  /// No description provided for @commMuteChat.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get commMuteChat;

  /// No description provided for @commUnmuteChat.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get commUnmuteChat;

  /// No description provided for @commHideChat.
  ///
  /// In en, this message translates to:
  /// **'Hide Chat'**
  String get commHideChat;

  /// No description provided for @commBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get commBlockUser;

  /// No description provided for @commUnblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get commUnblockUser;

  /// No description provided for @commBlockedToast.
  ///
  /// In en, this message translates to:
  /// **'User blocked. Their profile and messages are hidden.'**
  String get commBlockedToast;

  /// No description provided for @commReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get commReportUser;

  /// No description provided for @commReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Content or Member'**
  String get commReportTitle;

  /// No description provided for @commReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get commReportReasonInappropriate;

  /// No description provided for @commReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or advertising'**
  String get commReportReasonSpam;

  /// No description provided for @commReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or hate speech'**
  String get commReportReasonHarassment;

  /// No description provided for @commReportReasonMisinfo.
  ///
  /// In en, this message translates to:
  /// **'Unsafe medical advice / misinformation'**
  String get commReportReasonMisinfo;

  /// No description provided for @commReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commReportReasonOther;

  /// No description provided for @commReportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details...'**
  String get commReportNoteHint;

  /// No description provided for @commReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get commReportSubmit;

  /// No description provided for @commReportSent.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your safety report has been submitted.'**
  String get commReportSent;

  /// No description provided for @commDeleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get commDeleteForMe;

  /// No description provided for @commDeleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get commDeleteForEveryone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'es',
    'fr',
    'hi',
    'pt',
    'ru',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
