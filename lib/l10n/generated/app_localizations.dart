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
