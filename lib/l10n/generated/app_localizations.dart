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
