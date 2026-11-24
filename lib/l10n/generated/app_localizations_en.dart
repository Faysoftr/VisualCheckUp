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

  @override
  String get providerGuest => 'Guest';

  @override
  String signInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get riskNormal => 'Normal Appearance';

  @override
  String get riskAttention => 'Follow-Up Suggested';

  @override
  String get riskUrgent => 'Doctor Review Recommended';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'Latest: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'Latest: $count values ($abnormal out of range)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Latest: $count values (all normal)';
  }

  @override
  String get labStatusCriticalLow => 'Critical Low';

  @override
  String get labStatusLow => 'Low';

  @override
  String get labStatusNormal => 'Normal';

  @override
  String get labStatusHigh => 'High';

  @override
  String get labStatusCriticalHigh => 'Critical High';

  @override
  String get labSourceManual => 'Manual Entry';

  @override
  String get labSourcePasted => 'Parsed from Report Text';

  @override
  String get labSourcePhoto => 'JPG / Photo Report';

  @override
  String get labSourcePdf => 'PDF Report';

  @override
  String get bpLow => 'Low Blood Pressure';

  @override
  String get bpNormal => 'Normal Range';

  @override
  String get bpElevated => 'Elevated';

  @override
  String get bpStage1 => 'Stage 1 High';

  @override
  String get bpStage2 => 'Stage 2 High';

  @override
  String get bpCrisis => 'Hypertensive Crisis';

  @override
  String get sugarLow => 'Low Blood Sugar';

  @override
  String get sugarNormal => 'Normal Range';

  @override
  String get sugarBorderline => 'Borderline High';

  @override
  String get sugarHigh => 'High Blood Sugar';

  @override
  String get sugarVeryHigh => 'Very High Blood Sugar';

  @override
  String get sugarTypeFasting => 'Fasting';

  @override
  String get sugarTypePostMeal => 'Post-Meal (2h)';

  @override
  String get sugarTypeRandom => 'Random';

  @override
  String get specialtyEye => 'Ophthalmology or Internal Medicine';

  @override
  String get specialtyNail => 'Dermatology or Internal Medicine';

  @override
  String get specialtyTongue => 'ENT, Oral Health, or Internal Medicine';

  @override
  String get specialtySkin => 'Dermatology';

  @override
  String get specialtyUrine => 'Urology or Internal Medicine';

  @override
  String get specialtyStool => 'Gastroenterology or Internal Medicine';

  @override
  String get cloudBackupTitle => 'Cloud Backup (Optional • Firebase)';

  @override
  String get cloudBackupDesc =>
      'By default, all your lab reports and readings stay on this device only. Enable private backup under your Google/Apple account if you want to keep data when changing phones.';

  @override
  String get cloudBackupToggleTitle => 'Enable Cloud Backup';

  @override
  String cloudBackupLastSync(String date) {
    return 'Last backup: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Enabled • Ready to sync';

  @override
  String get cloudBackupDisabledLocal => 'Off • On-device storage only';

  @override
  String get cloudBackupSignInRequired =>
      'Sign in with Google or Apple to use cloud backup.';

  @override
  String get cloudBackupNowBtn => 'Back Up Now';

  @override
  String get cloudRestoreBtn => 'Restore from Cloud';

  @override
  String get cloudConsentTitle => 'Cloud Backup Consent';

  @override
  String get cloudConsentBody =>
      'Your blood tests, vitals, and checkups are stored only on this device by default.\n\nIf you enable cloud backup, this data is stored privately under your Google/Apple Firebase account and permanently deleted when you delete your account.\n\nDo you consent?';

  @override
  String get cloudConsentConfirm => 'Yes, Enable';

  @override
  String cloudBackupSuccess(int count) {
    return 'Cloud backup complete: $count records synced.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Restored from cloud: $count records imported.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Cloud backup turned off. New records stay on this device only.';

  @override
  String get aiCloudToggleTitle => 'Cloud Vision AI (Gemini) Analysis';

  @override
  String get aiCloudOnDesc =>
      'On: Sharp photos are resized and analyzed over a secure connection. Falls back on-device when offline.';

  @override
  String get aiCloudOffDesc =>
      'Off (0 Tokens): All analysis runs strictly on your device; no photos are ever uploaded.';

  @override
  String get aiBackendOfflineNote =>
      'When a Gemini / Firebase AI key is configured, cloud analysis activates automatically according to this toggle; the on-device engine is currently active.';

  @override
  String get aiOptimizationsTitle => 'Active Token & Data Saving Controls';

  @override
  String get aiOptQualityGate =>
      '0-token blur, darkness, and glare quality gate';

  @override
  String get aiOptCompression =>
      'Auto-crop + 512px / 768px JPEG (80%) compression';

  @override
  String get aiOptTieredModel =>
      'Smart model routing (Flash-Lite / Flash) & low thinking';

  @override
  String get aiOptHashCache => 'On-device duplicate hash cache (0 tokens)';

  @override
  String get aiClearCacheBtn => 'Clear AI Cache';

  @override
  String get aiCacheCleared => 'AI cache cleared.';

  @override
  String resultScreenTitle(String category) {
    return '$category Result';
  }

  @override
  String get tooltipDoctorSummary => 'Doctor Visit Summary';

  @override
  String get tooltipReferenceGuide => 'Reference Guide';

  @override
  String get calibratedColorTone => 'Calibrated Color Tone';

  @override
  String get sampledColorTone => 'Sampled Dominant Tone';

  @override
  String confidenceLabel(int percent) {
    return 'Pre-check confidence: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote => 'Color balanced with white reference.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Suggested specialty: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Change Over Time';

  @override
  String get todayLabel => 'Today';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Previous log: \"$title\" ($status). Tracking $count records.';
  }

  @override
  String get personalBaselineComparisonTitle => 'Personal Baseline Comparison';

  @override
  String get yourBaselineLabel => 'Baseline';

  @override
  String get warningFlagsTitle => 'Warning Signs to Watch';

  @override
  String get observationsTitle => 'Observations';

  @override
  String get recommendationsTitle => 'Recommendations';

  @override
  String get personalBaselineCardTitle => 'Personal Baseline Calibration';

  @override
  String get personalBaselineCardDesc =>
      'Save a reading on a healthy day as your personal baseline to reduce camera sensor drift.';

  @override
  String get saveBaselineBtn => 'Save as My Baseline';

  @override
  String get updateBaselineBtn => 'Update My Baseline';

  @override
  String get clearBaselineBtn => 'Remove';

  @override
  String baselineSavedMsg(String category) {
    return 'Personal baseline saved for $category.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'Personal baseline removed for $category.';
  }

  @override
  String get doctorSummaryBtn => 'Show to Doctor • Prepare Summary';

  @override
  String get returnHomeBtn => 'Back to Home';

  @override
  String get doctorSheetTitle => 'Show to Doctor • Visit Summary';

  @override
  String colorLabel(String hex, String status) {
    return 'Color: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Timeline with Previous Logs';

  @override
  String get questionsForDoctorTitle => 'Questions to Ask Your Doctor';

  @override
  String get copyShareSummaryBtn => 'Copy & Share Summary';

  @override
  String get doctorSummaryCopied => 'Doctor visit summary copied to clipboard.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Visual References';
  }

  @override
  String get healthyReferenceLabel => 'Healthy Reference';

  @override
  String get captureChecklistTitle => 'Capture Tips';

  @override
  String get abnormalFindingsTitle => 'Abnormal / Warning Visual Findings';

  @override
  String get cameraPermPermanentMsg =>
      'Camera access is disabled in system settings. Enable camera permission for VisualCheckUp or pick a photo from gallery.';

  @override
  String get cameraPermRequiredMsg =>
      'Camera permission is needed for visual pre-checks. Images are processed on your device by default.';

  @override
  String get cameraGrantPermTitle => 'Camera Access Needed';

  @override
  String get cameraRequestPermBtn => 'Grant Camera Permission';

  @override
  String get cameraPickGalleryBtn => 'Choose from Gallery';

  @override
  String get cameraWhiteRefOn => 'White Reference: On';

  @override
  String get cameraWhiteRefOff => 'White Reference: Off';

  @override
  String get cameraBaselineActive => 'Baseline Saved';

  @override
  String get cameraAnalyzing => 'Analyzing...';

  @override
  String get cameraCaptureBtn => 'Capture & Analyze';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Analysis failed: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Color Card';
  }

  @override
  String get quickCardPrivacyBanner =>
      'No camera needed: pick the closest shade for a private 2-second record.';

  @override
  String get quickCardChooseShade => 'Select the Closest Color Shade';

  @override
  String get quickCardExtraContext => 'Extra Context (Optional)';

  @override
  String get quickCardSaveViewBtn => 'Save & View Assessment';

  @override
  String get quickCardUseCameraBtn => 'Use Camera Instead';

  @override
  String get skinIntroTitle => 'Visual Dermatology Pre-Screening';

  @override
  String get skinIntroDesc =>
      'Compares moles, warts, bruises, and facial spots against surrounding skin. Not a diagnosis; helps prepare for a dermatologist visit.';

  @override
  String get skinStep1Title => '1. Select Skin Pre-Screening Module';

  @override
  String get skinOtherConcernsLabel => 'Other Skin Presentations';

  @override
  String get skinStep2Title => '2. Accompanying Symptoms (Optional)';

  @override
  String get skinStep3Title => '3. Body Area (Optional)';

  @override
  String get skinStartCameraBtn => 'Start Camera Skin Check';

  @override
  String get skinConcernRash => 'Redness / Rash';

  @override
  String get skinConcernMole => 'Mole / Dark Spot';

  @override
  String get skinConcernScaly => 'Scaly / Dry Plaque';

  @override
  String get skinConcernBlister => 'Blister / Acne';

  @override
  String get skinConcernGeneral => 'General Skin Check';

  @override
  String get bodyAreaFaceNeck => 'Face / Neck';

  @override
  String get bodyAreaArmHand => 'Arm / Hand';

  @override
  String get bodyAreaTorso => 'Torso';

  @override
  String get bodyAreaLegFoot => 'Leg / Foot';

  @override
  String get bodyAreaScalp => 'Scalp';

  @override
  String get bodyAreaOther => 'Other';

  @override
  String get symptomItching => 'Itching';

  @override
  String get symptomPainWarmth => 'Pain / Warmth';

  @override
  String get symptomRapidChange => 'Rapid growth / shape change';

  @override
  String get symptomBleeding => 'Bleeding / Oozing';

  @override
  String get symptomSpreading => 'Spreading rapidly';

  @override
  String get symptomFever => 'Fever present';

  @override
  String get symptomNonHealing => 'Non-healing sore (4+ weeks)';

  @override
  String get symptomOver6mm => 'Over 6 mm or irregular border';

  @override
  String get symptomNoTrauma => 'Appeared without trauma';

  @override
  String get symptomRoughDots => 'Rough surface / tiny black dots';

  @override
  String get symptomSunHormone => 'Sun, hormone, or post-acne spot';

  @override
  String get bruiseGuideTitle => 'Bruise Color Stages Guide';

  @override
  String get wartGuideTitle => 'Wart Pre-Check & Safety Guide';

  @override
  String get abcdeGuideTitle => 'ABCDE Mole Self-Check Guide';

  @override
  String get abcdeGuideSubtitle =>
      '5 key signs dermatologists use for mole & skin cancer screening';

  @override
  String get labScreenTitle => 'Lab & Hospital Reports';

  @override
  String get labTabReports => 'My Reports';

  @override
  String get labTabTrends => 'Change Tracking';

  @override
  String get labAddBtn => 'Add Report / Blood Test';

  @override
  String get labEmptyTitle => 'No saved blood tests yet';

  @override
  String get labEmptyDesc =>
      'Upload a PDF or JPG blood test report; optionally add your hospital diagnosis or complaint for a plain-language summary.';

  @override
  String get labAddFirstBtn => 'Add First Lab / PDF Report';

  @override
  String get labTrendsEmptyDesc =>
      'Save blood tests on different dates to see longitudinal trend charts for Hemoglobin, Ferritin, Glucose, TSH, Vitamin D, and more.';

  @override
  String labParamsCount(int count) {
    return '$count parameters';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count out of range';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Parameter Review ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Hospital / Doctor Diagnosis';

  @override
  String get labEnteredComplaintTitle => 'Your Complaint / Note';

  @override
  String get labInterpretationTitle => 'Plain-Language Interpretation';

  @override
  String get labCopyDoctorSummaryBtn => 'Show to Doctor • Copy Summary';

  @override
  String get labSummaryCopied => 'Lab summary copied to clipboard.';

  @override
  String get labExportPdfBtn => 'Export Doctor PDF';

  @override
  String get labAddSheetTitle => 'Add Hospital / Blood Test Report';

  @override
  String get labReportTitleField => 'Report Title';

  @override
  String get labDefaultReportTitle => 'Blood Test Result';

  @override
  String get labStep1Upload => '1. Upload PDF or JPG Blood Report';

  @override
  String get labUploadPdfJpgBtn => 'Upload PDF or JPG';

  @override
  String get labCameraCaptureBtn => 'Take Photo';

  @override
  String get labStep2Context => '2. Hospital Diagnosis & Note (Optional)';

  @override
  String get labStep2ContextHint =>
      'Enter a doctor\'s diagnosis you want explained or your symptoms; you may leave both blank.';

  @override
  String get labDiagnosisField => 'Hospital / Doctor Diagnosis (Optional)';

  @override
  String get labComplaintField => 'Your Symptoms / Question (Optional)';

  @override
  String get labStep3PasteManual =>
      '3. Paste Report Text or Add Values Manually';

  @override
  String get labParseTextBtn => 'Read & Parse Text';

  @override
  String get labParamDropdown => 'Lab Parameter';

  @override
  String labValueField(String unit) {
    return 'Value ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Add';

  @override
  String labParsedValuesTitle(int count) {
    return 'Parsed Values ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Evaluate & Save Dated Report';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count records • Change: $delta • Latest: $status';
  }

  @override
  String get vitalsScreenTitle => 'Blood Pressure & Sugar';

  @override
  String get vitalsCopySummaryTooltip => 'Copy Doctor Summary';

  @override
  String get vitalsCopyEmptyMsg =>
      'Add a blood pressure or glucose reading first to create a summary.';

  @override
  String get vitalsSummaryCopied => 'Blood pressure & sugar summary copied.';

  @override
  String get vitalsAddBpBtn => 'Add Blood Pressure';

  @override
  String get vitalsAddSugarBtn => 'Add Blood Sugar';

  @override
  String get vitalsBpEmptyTitle => 'No blood pressure readings yet';

  @override
  String get vitalsBpEmptyDesc =>
      'Log systolic/diastolic pressure and pulse with dates to follow your trend chart.';

  @override
  String get vitalsBpAddFirstBtn => 'Add First BP Reading';

  @override
  String get vitalsSugarEmptyTitle => 'No blood sugar readings yet';

  @override
  String get vitalsSugarEmptyDesc =>
      'Log fasting, post-meal (2h), or random glucose readings to track your trend.';

  @override
  String get vitalsSugarAddFirstBtn => 'Add First Sugar Reading';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Average ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Pulse $pulse bpm';
  }

  @override
  String get vitalsBpHistoryTitle => 'Dated Blood Pressure Logs';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Average ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'Dated Blood Sugar Logs';

  @override
  String get vitalsNewBpTitle => 'New Blood Pressure Reading';

  @override
  String get vitalsSystolicField => 'Systolic (Top)';

  @override
  String get vitalsDiastolicField => 'Diastolic (Bottom)';

  @override
  String get vitalsPulseField => 'Pulse (bpm — Optional)';

  @override
  String get vitalsNoteField => 'Note (Optional)';

  @override
  String get vitalsSaveBpBtn => 'Save Blood Pressure';

  @override
  String get vitalsNewSugarTitle => 'New Blood Sugar Reading';

  @override
  String get vitalsSugarValueField => 'Blood Sugar (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'Save Blood Sugar';

  @override
  String get chartAddReadingHint => 'Add readings to view chart';

  @override
  String get loginTermsTitle => 'Terms of Use & Medical Notice';

  @override
  String get loginTermsCheckbox =>
      'I understand that VisualCheckUp does not provide a medical diagnosis and is for preliminary awareness only, and I accept the Terms of Use.';

  @override
  String get loginTermsRequiredMsg =>
      'Please accept the Terms of Use & Medical Notice before signing in.';

  @override
  String get loginTermsReadMore => 'Read Terms';

  @override
  String get loginTermsModalBody =>
      '• Not a Medical Diagnosis: VisualCheckUp is not a medical device and does not diagnose, treat, or replace a licensed physician.\n\n• Awareness & Preparation Only: Visual checks, lab summaries, and growth/BMI scales are informational tools to help you prepare for doctor visits.\n\n• Emergency Warning: If you experience severe pain, chest pain, shortness of breath, sudden vision loss, or urgent symptoms, seek emergency medical care immediately.\n\n• Privacy: Your health records stay on your device by default and are never sold or shared with third parties.';

  @override
  String get loginTermsAcceptBtn => 'I Have Read & Accept';
}
