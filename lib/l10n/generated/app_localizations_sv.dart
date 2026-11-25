// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

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
  String get menuHome => 'Hem';

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
  String get menuVitalsTracker => 'Blodtryck & Blodsocker';

  @override
  String get menuLabReports => 'Labbrapporter';

  @override
  String get menuQuickColorCard => 'Camera-Free Color Card';

  @override
  String get menuHistory => 'Historik';

  @override
  String get menuReferenceGuide => 'Visual Reference Guide';

  @override
  String get menuSectionSettings => 'SETTINGS & PRIVACY';

  @override
  String get menuAiSettings => 'AI & Privacy';

  @override
  String get menuDisclaimer => 'Medical Disclaimer';

  @override
  String get menuTheme => 'Tema';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get menuLanguage => 'Språk';

  @override
  String get languageSystem => 'System Default';

  @override
  String get signInGoogleOrApple => 'Sign in with Google or Apple';

  @override
  String get signOut => 'Logga ut';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account and Local Data';

  @override
  String get deleteAccountBody =>
      'You will be signed out and your checkup history and personal color baselines on this device will be permanently deleted. Continue?';

  @override
  String get cancel => 'Avbryt';

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
  String get homeCategoriesTitle => 'Visuella hälsokontroller';

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
  String get menuSettings => 'Inställningar';

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
  String get labScreenTitle => 'Labbrapporter';

  @override
  String get labTabReports => 'My Reports';

  @override
  String get labTabTrends => 'Change Tracking';

  @override
  String get labAddBtn => 'Lägg till rapport';

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

  @override
  String atlasFilterAll(int count) {
    return 'Illustrated Atlas ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Urgent Signs ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Home Clinical Tests ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Signs Requiring Prompt Doctor Evaluation';

  @override
  String get atlasTapToCompareHint =>
      'Tap any card to enlarge side-by-side with the healthy reference.';

  @override
  String get atlasVisualCueLabel => 'Visual Cue';

  @override
  String get atlasClinicalContextLabel => 'Possible Clinical Context';

  @override
  String get atlasPossibleContextShort => 'Possible Context';

  @override
  String get atlasWarningPrefix => 'Warning';

  @override
  String get atlasCloseBtn => 'Close';

  @override
  String get atlasCaptureProtocolTitle => 'Best Capture Protocol';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Clinical Pre-Screening Tests You Can Do at Home';

  @override
  String get atlasSelfTestNormalPrefix => 'Normal';

  @override
  String get atlasSelfTestWarningPrefix => 'Attention';

  @override
  String get fitzpatrickScaleTitle =>
      'Fitzpatrick Skin Phototypes & ITA° Calibration Scale';

  @override
  String get fitzpatrickScaleSubtitle =>
      'The app measures the ITA° angle of surrounding healthy skin to balance analysis thresholds for your skin phototype.';

  @override
  String get resultVisualCompareTitle =>
      'Illustrated Clinical Reference Comparison';

  @override
  String get resultHealthyShort => 'Healthy';

  @override
  String get resultMatchedShort => 'Matched';

  @override
  String get resultViewFullAtlasBtn => 'View Full Illustrated Atlas';

  @override
  String get resultHomeSelfTestsBtn => 'Home Clinical Tests';

  @override
  String get resultClinicalBiomarkersTitle =>
      'Quantitative Clinical Measurements';

  @override
  String get cameraEyeModeSclera => 'Mode: Sclera (Jaundice)';

  @override
  String get cameraEyeModeConjunctiva => 'Lower Eyelid (Anemia)';

  @override
  String get cameraClinicalAtlasChip => 'Clinical Tests & Atlas';

  @override
  String get bristolScaleTitle =>
      'Bristol Stool Consistency Scale (Optional • Types 1–7)';

  @override
  String get bristolType1Title => 'Type 1 • Hard lumps';

  @override
  String get bristolType2Title => 'Type 2 • Lumpy sausage';

  @override
  String get bristolType3Title => 'Type 3 • Cracked sausage';

  @override
  String get bristolType4Title => 'Type 4 • Smooth (Ideal)';

  @override
  String get bristolType5Title => 'Type 5 • Soft blobs';

  @override
  String get bristolType6Title => 'Type 6 • Mushy / Loose';

  @override
  String get bristolType7Title => 'Type 7 • Entirely liquid';

  @override
  String get metricFitzpatrickPhototype => 'Fitzpatrick Phototype';

  @override
  String get metricAbcdeAsymmetry => 'A — Asymmetry';

  @override
  String get metricAbcdeBorder => 'B — Border Irregularity';

  @override
  String get metricAbcdeColors => 'C — Dermoscopic Colors';

  @override
  String get metricErythemaDelta => 'Erythema Index Δ';

  @override
  String get metricAnnularClearing => 'Annular Central Clearing';

  @override
  String get metricErythemaIndex => 'Erythema Index (EI)';

  @override
  String get metricScleraBilirubin => 'Scleral Bilirubin Index';

  @override
  String get metricHemorrhagePatch => 'Compact Hemorrhage Area';

  @override
  String get metricNailErythema => 'Nailbed Erythema Index';

  @override
  String get metricBeauGroove => 'Beau Transverse Groove';

  @override
  String get metricTerryLindsaySplit => 'Proximal/Distal Split';

  @override
  String get metricSplinterStreak => 'Splinter Streak Ratio';

  @override
  String get metricGeographicTongue => 'Geographic Tongue Score';

  @override
  String get metricYellowCoating => 'Yellow Coating Ratio';

  @override
  String get metricBristolScale => 'Bristol Scale';

  @override
  String get hubStartNewScan => 'Start New Scan';

  @override
  String get hubPickFromGallery => 'Gallery';

  @override
  String hubPastScansTitle(int count) {
    return 'Past Scans ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Total Scans';

  @override
  String get hubLastScanLabel => 'Last Scan';

  @override
  String get hubLatestStatusLabel => 'Latest Status';

  @override
  String get hubFilterAll => 'All';

  @override
  String get hubFilterAttention => 'Attention / Urgent';

  @override
  String get hubFilterWithPhoto => 'With Photo';

  @override
  String get hubColPhoto => 'Photo';

  @override
  String get hubColDate => 'Date';

  @override
  String get hubColFinding => 'Finding & Summary';

  @override
  String get hubColStatus => 'Status';

  @override
  String get hubCompareModeBtn => 'Compare 2 Scans';

  @override
  String hubCompareSelectHint(int count) {
    return 'Select 2 scans from the table to compare side-by-side ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Compare Side-by-Side';

  @override
  String get hubCompareCancelBtn => 'Cancel';

  @override
  String get hubCompareSheetTitle => 'Side-by-Side Scan Comparison';

  @override
  String get hubCompareOlderLabel => 'Earlier';

  @override
  String get hubCompareNewerLabel => 'Later';

  @override
  String get hubCompareMetricsTitle => 'Clinical Metrics Comparison';

  @override
  String hubEmptyTitle(String category) {
    return 'No $category scans yet';
  }

  @override
  String get hubEmptySubtitle =>
      'Start your first scan above. Every check is saved chronologically here with its thumbnail photo and full analysis report.';

  @override
  String get hubDoctorSummaryBtn => 'Doctor Summary';

  @override
  String get photoTapToZoomHint => 'Tap photo to zoom full-screen';

  @override
  String get photoZoomTitle => 'Captured Photo';

  @override
  String get resultDeleteRecordTooltip => 'Delete Record';

  @override
  String get resultDeleteConfirmTitle => 'Delete this scan?';

  @override
  String get resultDeleteConfirmBody =>
      'This checkup record will be permanently removed from your local history.';

  @override
  String get resultDeleteBtn => 'Delete';

  @override
  String get labLargeTextBtn => 'Large Text';

  @override
  String get labLargeTextOnBtn => 'Large Text: On';

  @override
  String get labSeniorOverviewTitle => 'Your Summary at a Glance';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count test(s) are within the normal range.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count test(s) are outside the reference range — explained simply below.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count test(s) are noticeably outside normal limits — please show your doctor soon.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count common routine test(s) are not included in this report.';
  }

  @override
  String get labAttentionSectionTitle => 'Values to Pay Attention To';

  @override
  String get labNormalSectionTitle => 'Normal Values (Good News)';

  @override
  String get labMissingSectionTitle => 'Tests Not Included in This Report';

  @override
  String get labMissingSectionExplain =>
      'Not every blood test order includes all panels. The common tests below were not listed in this report, so they were not evaluated.';

  @override
  String get labNotInReportBadge => 'Not in report';

  @override
  String get labWhatItMeansLabel => 'What it means';

  @override
  String get labWhatToDoLabel => 'What you can do';

  @override
  String get labAddAnotherPageBtn => 'Scan Another Page';

  @override
  String labPagesReadBadge(int count) {
    return '$count page(s) read';
  }

  @override
  String get labPhotoOfflineHint =>
      'Paper photo attached. Enable Cloud AI in Settings to read paper photos automatically, or enter values manually below.';

  @override
  String get labAllValuesNormalMsg =>
      'All recorded values in this report are within the reference range.';

  @override
  String get medTitle => 'Medication & Alarm Reminder';

  @override
  String get medSubtitle => 'Track pills, insulin & health alarms with photos';

  @override
  String get medMenuTitle => 'Medicinpåminnelser';

  @override
  String get medHomeCardEmpty => 'No alarms yet — add your first reminder';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return '$taken/$total taken today';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count active alarms';
  }

  @override
  String get medTabToday => 'Today';

  @override
  String get medTabAll => 'All Alarms';

  @override
  String get medAddAlarm => 'Add New Alarm';

  @override
  String get medEditAlarm => 'Edit Alarm';

  @override
  String get medCatPill => 'Medicine / Pill';

  @override
  String get medCatDiabetes => 'Diabetes Pill / Insulin';

  @override
  String get medCatBloodPressure => 'Blood Pressure Med';

  @override
  String get medCatVitamin => 'Vitamin / Supplement';

  @override
  String get medCatDropsCream => 'Eye Drops / Cream';

  @override
  String get medCatCheckup => 'Vitals / Checkup';

  @override
  String get medCatOther => 'Other';

  @override
  String get medMealAnytime => 'Anytime';

  @override
  String get medMealBefore => 'Before meal';

  @override
  String get medMealAfter => 'After meal';

  @override
  String get medMealWith => 'With meal';

  @override
  String get medMealBedtime => 'At bedtime';

  @override
  String get medDayMon => 'Mon';

  @override
  String get medDayTue => 'Tue';

  @override
  String get medDayWed => 'Wed';

  @override
  String get medDayThu => 'Thu';

  @override
  String get medDayFri => 'Fri';

  @override
  String get medDaySat => 'Sat';

  @override
  String get medDaySun => 'Sun';

  @override
  String get medEveryDay => 'Every Day';

  @override
  String get medWeekdays => 'Weekdays';

  @override
  String get medWeekends => 'Weekends';

  @override
  String get medFieldCategory => 'Category';

  @override
  String get medFieldName => 'Medicine / Reminder Name';

  @override
  String get medFieldNameHint => 'e.g. Metformin 1000 mg, Evening Insulin...';

  @override
  String get medFieldNameRequired =>
      'Please enter a medicine or reminder name.';

  @override
  String get medFieldDosage => 'Dosage / Amount (Optional)';

  @override
  String get medFieldDosageHint => 'e.g. 1 tablet, 12 units, 2 drops';

  @override
  String get medFieldDescription => 'Reminder Note (Shown on Alarm)';

  @override
  String get medFieldDescriptionHint =>
      'e.g. Take 30 min before breakfast with a full glass of water';

  @override
  String get medFieldMealTiming => 'Meal Timing';

  @override
  String get medFieldTime => 'Alarm Time';

  @override
  String get medFieldDays => 'Repeat Days';

  @override
  String get medFieldPhoto => 'Medicine Photo (Shown When Alarm Rings)';

  @override
  String get medTakePhoto => 'Take Photo';

  @override
  String get medPickGallery => 'From Gallery';

  @override
  String get medRemovePhoto => 'Remove Photo';

  @override
  String get medPhotoHint =>
      'Snap the medicine box or insulin pen so it displays clearly when the alarm rings.';

  @override
  String get medSoundToggle => 'Alarm Sound';

  @override
  String get medVibrateToggle => 'Vibration';

  @override
  String get medSaveAlarm => 'Save Alarm';

  @override
  String get medAlarmSaved => 'Alarm saved and scheduled.';

  @override
  String get medAlarmDeleted => 'Alarm deleted.';

  @override
  String get medDeleteConfirmTitle => 'Delete Alarm';

  @override
  String medDeleteConfirmBody(String title) {
    return 'Permanently delete the \"$title\" alarm?';
  }

  @override
  String get medStatusTaken => 'Taken';

  @override
  String get medStatusSnoozed => 'Snoozed';

  @override
  String get medStatusSkipped => 'Skipped';

  @override
  String get medStatusPending => 'Pending';

  @override
  String get medActionTaken => 'I Took It';

  @override
  String get medActionSnooze => 'Snooze 10 min';

  @override
  String get medActionSkip => 'Skip Today';

  @override
  String get medActionUndo => 'Undo';

  @override
  String get medActionPreviewAlarm => 'Test Alarm';

  @override
  String get medRingHeader => 'MEDICATION TIME';

  @override
  String get medRingNoteTitle => 'Reminder Note';

  @override
  String get medRingNoPhoto => 'No medicine photo added';

  @override
  String get medRingTapZoom => 'Tap photo to zoom';

  @override
  String get medRingSnoozedToast => 'Snoozed for 10 minutes.';

  @override
  String get medRingTakenToast => 'Great! Today\'s dose marked as taken.';

  @override
  String get medTodayProgressTitle => 'Today\'s Medication Plan';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Next alarm: $time • $title';
  }

  @override
  String get medNoTodayAlarms => 'No medication alarms scheduled for today.';

  @override
  String get medEmptyTitle => 'No Medication Alarms Yet';

  @override
  String get medEmptyBody =>
      'Add photo-supported alarms for diabetes pills, insulin, blood pressure meds, or daily checks. When it\'s time, the medicine photo and your note appear clearly on screen.';

  @override
  String get medQuickPresetDiabetes => 'Diabetes / Insulin';

  @override
  String get medQuickPresetBp => 'Blood Pressure';

  @override
  String get medQuickPresetVitamin => 'Vitamin';

  @override
  String get dietMenuTitle => 'Kost- & Dietplaner';

  @override
  String get dietHomeCardTitle => 'Diet & Meal Plans';

  @override
  String get dietHomeCardEmpty =>
      'Ready-made diets, compliance & weight tracking';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'Day $day/$total • $percent% compliance';
  }

  @override
  String get dietCalorieQuickTitle => 'AI Plate Calorie Counter';

  @override
  String get dietCalorieQuickSubtitle =>
      'Snap your plate photo to calculate calories & macros';

  @override
  String get dietTabActive => 'My Diet';

  @override
  String get dietTabTemplates => 'Diet Plans';

  @override
  String get dietTabWeight => 'Weight';

  @override
  String get dietTabCalories => 'AI Calories';

  @override
  String get dietStartDiet => 'Start Diet';

  @override
  String get dietRestartOrChange => 'Change Diet';

  @override
  String get dietEndDiet => 'End Diet';

  @override
  String get dietEndDietConfirm =>
      'End your active diet plan? Your compliance and weight records will be kept.';

  @override
  String get dietNoActiveTitle => 'No Active Diet Yet';

  @override
  String get dietNoActiveBody =>
      'Choose from ready-made clinical diet templates (Mediterranean, Diabetes-Friendly, DASH, Weight Loss, 16:8 Fasting, High Protein) and track daily compliance & weight.';

  @override
  String get dietBrowseTemplates => 'Browse Ready-Made Diets';

  @override
  String get dietStartDate => 'Start Date';

  @override
  String get dietEndDate => 'End Date';

  @override
  String get dietStartWeight => 'Start Weight (kg)';

  @override
  String get dietTargetWeight => 'Target Weight (kg)';

  @override
  String get dietDailyCalorieTarget => 'Daily Calorie Target (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days days';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String dietDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Compliance: $percent%';
  }

  @override
  String get dietFollowed => 'Followed';

  @override
  String get dietNotFollowed => 'Missed';

  @override
  String get dietPending => 'Pending';

  @override
  String get dietSlotBreakfast => 'Breakfast';

  @override
  String get dietSlotMorningSnack => 'Morning Snack';

  @override
  String get dietSlotLunch => 'Lunch';

  @override
  String get dietSlotAfternoonSnack => 'Afternoon Snack';

  @override
  String get dietSlotDinner => 'Dinner';

  @override
  String get dietAlternativesLabel => 'Alternative';

  @override
  String dietWaterTarget(String liters) {
    return 'Water target: $liters L';
  }

  @override
  String get dietRulesTitle => 'Plan Guidelines';

  @override
  String get dietSampleMenuTitle => 'Sample Daily Menu';

  @override
  String get dietStartedToast => 'Diet plan started! Stay consistent.';

  @override
  String get dietEndedToast => 'Active diet plan ended.';

  @override
  String get dietWeightLogTitle => 'Diet Weight Tracking';

  @override
  String get dietWeightAdd => 'Log Weight';

  @override
  String get dietWeightField => 'Current Weight (kg)';

  @override
  String get dietWeightNote => 'Note (Optional)';

  @override
  String get dietWeightNoteHint => 'e.g. Morning fasting weight';

  @override
  String get dietWeightEmpty =>
      'No weight entries yet. Log your first weight to track your trend.';

  @override
  String get dietWeightCurrent => 'Current';

  @override
  String get dietWeightTarget => 'Target';

  @override
  String get dietWeightChange => 'Change';

  @override
  String get dietWeightSaved => 'Weight entry saved.';

  @override
  String get dietCalorieTitle => 'AI Plate Calorie Calculator';

  @override
  String get dietCalorieSubtitle =>
      'Works with or without a diet — snap a plate photo or describe your meal.';

  @override
  String get dietSnapPlateCamera => 'Snap Plate Photo';

  @override
  String get dietPickPlateGallery => 'Pick from Gallery';

  @override
  String get dietFoodDescLabel => 'Meal Description / Portion (Optional)';

  @override
  String get dietFoodDescHint =>
      'e.g. Grilled chicken, bulgur pilaf, green salad, ayran';

  @override
  String get dietCalculateFromText => 'Calculate from Text';

  @override
  String get dietAnalyzingPlate => 'Analyzing plate calories & macros...';

  @override
  String get dietResultTitle => 'Calorie & Macro Analysis';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Vision';

  @override
  String get dietOnDeviceBadge => 'Smart On-Device Estimate';

  @override
  String get dietProtein => 'Protein';

  @override
  String get dietCarbs => 'Carbs';

  @override
  String get dietFat => 'Fat';

  @override
  String get dietFiber => 'Fiber';

  @override
  String get dietPortionScale => 'Portion Size';

  @override
  String get dietSaveMealLog => 'Save to Today\'s Log';

  @override
  String get dietMealLoggedToast => 'Meal calories saved to today\'s log.';

  @override
  String get dietTodayTotalCalories => 'Today\'s Total';

  @override
  String get dietRecentScans => 'Scanned Meals';

  @override
  String get dietNoScansYet =>
      'No meals scanned yet. Take a photo of your plate to estimate calories.';

  @override
  String dietHealthScore(int score) {
    return 'Balance Score: $score/10';
  }

  @override
  String get dietTodayLabel => 'Today';

  @override
  String get medCatHerbalTea => 'Herbal Tea';

  @override
  String get medCatCustom => 'Other (Custom)';

  @override
  String get medFieldCustomCategory => 'Custom Category Name';

  @override
  String get medFieldCustomCategoryHint =>
      'e.g. Probiotic, Herbal Blend, Water, Physio...';

  @override
  String get medQuickPresetHerbalTea => 'Herbal Tea';

  @override
  String get dietCreateCustom => 'Create My Own Diet';

  @override
  String get dietCreateCustomSubtitle =>
      'Enter your dietitian\'s list or your own meal plan manually';

  @override
  String get dietCustomNameLabel => 'Diet Plan Name';

  @override
  String get dietCustomNameHint =>
      'e.g. My Dietitian Plan, Custom Healthy Menu...';

  @override
  String get dietCustomNameRequired => 'Please enter a diet plan name.';

  @override
  String get dietCustomMealHint => 'What is planned for this meal?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (optional)';

  @override
  String get dietCustomAtLeastOneMeal => 'Please enter at least one meal.';

  @override
  String get dietCustomTemplatesTitle => 'My Custom Diet Plans';

  @override
  String get dietReadyTemplatesTitle => 'Ready-Made Diet Templates';

  @override
  String get donateTooltip => 'Support & Donate';

  @override
  String get donateMenuLabel => 'Support VisualCheckUp';

  @override
  String get donateMenuSubtitle =>
      'Coffee, meal or gift to support free health tools';

  @override
  String get donatePopupTitle => 'Support VisualCheckUp';

  @override
  String get donatePopupSubtitle =>
      'Your voluntary support helps us keep health screening, lab reading, medication alarms, and diet tools free and improving.';

  @override
  String get donateTierCoffeeTitle => 'Buy a Coffee';

  @override
  String get donateTierCoffeeDesc => 'A warm cup of coffee for development';

  @override
  String get donateTierMealTitle => 'Treat to a Meal';

  @override
  String get donateTierMealDesc => 'Great support for new health features';

  @override
  String get donateTierGiftTitle => 'Send a Gift';

  @override
  String get donateTierGiftDesc => 'Helps cover AI & server maintenance costs';

  @override
  String get donateTierGoldTitle => 'Big Support';

  @override
  String get donateTierGoldDesc =>
      'Powers upcoming medical modules & languages';

  @override
  String get donateTierHeroTitle => 'Health Hero';

  @override
  String get donateTierHeroDesc =>
      'Supports free health tracking for all families';

  @override
  String get donatePopularBadge => 'Popular';

  @override
  String donateConfirmButton(String price) {
    return 'Donate $price';
  }

  @override
  String get donateLaterButton => 'Maybe Later';

  @override
  String get donateThanksTitle => 'Thank You for Your Support!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'Your $tier ($price) support means a lot to us. Thank you for helping keep VisualCheckUp growing!';
  }

  @override
  String get donateSupporterBadge => 'Supporter • Thank you!';

  @override
  String get donateStoreNotice =>
      'Voluntary one-time support • No subscription';

  @override
  String get medFieldAlarmSound => 'Alarm Ringtone';

  @override
  String get medAlarmSoundClassic => 'Classic Alarm';

  @override
  String get medAlarmSoundClassicDesc => 'Crisp alarm clock ring';

  @override
  String get medAlarmSoundGentle => 'Gentle Chime';

  @override
  String get medAlarmSoundGentleDesc => 'Calm rising chime melody';

  @override
  String get medAlarmSoundRadar => 'Modern Radar';

  @override
  String get medAlarmSoundRadarDesc => 'Clear rhythmic alarm pulse';

  @override
  String get medAlarmSoundBell => 'Health Bell';

  @override
  String get medAlarmSoundBellDesc => 'Bright classic twin-bell ring';

  @override
  String get medAlarmSoundUrgent => 'Urgent High Alert';

  @override
  String get medAlarmSoundUrgentDesc =>
      'Strong insistent tone for critical doses';

  @override
  String get medAlarmSoundSystem => 'Device Alarm Tone';

  @override
  String get medAlarmSoundSystemDesc =>
      'Uses your phone\'s default alarm ringtone';

  @override
  String get medSoundPreviewPlay => 'Listen';

  @override
  String get medSoundPreviewStop => 'Stop';

  @override
  String get medSoundSilent => 'Silent';

  @override
  String get medPreviewModeBadge => 'PREVIEW';

  @override
  String get commMenuTitle => 'Global Hälsogemenskap';

  @override
  String get commHomeSubtitle =>
      'Worldwide health buddies, profile likes & safe messaging';

  @override
  String get commTabDiscover => 'Upptäck';

  @override
  String get commTabMessages => 'Meddelanden';

  @override
  String get commTabMyProfile => 'Min profil';

  @override
  String get commSafetyBanner =>
      'Peer wellness & motivation only — never medical advice or diagnosis. Your private lab reports and scans are never shared.';

  @override
  String get commSearchHint => 'Search by name, city, or wellness note...';

  @override
  String get commFilterAllGoals => 'All Goals';

  @override
  String get commFilterAllCountries => 'Worldwide';

  @override
  String get commEmptyDiscover => 'No health profiles match your filters yet.';

  @override
  String get commGoalDiabetes => 'Diabetes & Blood Sugar';

  @override
  String get commGoalBloodPressure => 'Blood Pressure & Heart';

  @override
  String get commGoalWeightDiet => 'Weight & Healthy Diet';

  @override
  String get commGoalHealthyLiving => 'Healthy Living';

  @override
  String get commGoalHerbalWellness => 'Herbal Tea & Natural Care';

  @override
  String get commGoalParentingGrowth => 'Parents & Child Growth';

  @override
  String get commGoalSkinCare => 'Skin & Daily Care';

  @override
  String get commGoalFitnessWalk => 'Walking & Movement';

  @override
  String get commGoalSleepStress => 'Sleep & Stress Balance';

  @override
  String commLikesCount(int count) {
    return '$count Likes';
  }

  @override
  String get commLikeAction => 'Like Profile';

  @override
  String get commUnlikeAction => 'Liked';

  @override
  String get commSendMessage => 'Send Message';

  @override
  String get commMessagesDisabled =>
      'This member has disabled direct messages.';

  @override
  String get commOptInTitle => 'Join the Global Health Community';

  @override
  String get commOptInBody =>
      'Connect with people worldwide who share your health goals. Joining is completely optional — your lab reports, camera scans, and medication photos stay 100% private on your device.';

  @override
  String get commOptInButton => 'Create My Health Profile';

  @override
  String get commFieldDisplayName => 'Display Name';

  @override
  String get commFieldNickname => 'Username (@handle)';

  @override
  String get commFieldCountry => 'Country';

  @override
  String get commFieldCity => 'City (optional)';

  @override
  String get commFieldLanguage => 'Preferred Language';

  @override
  String get commFieldGoals => 'Health & Wellness Goals';

  @override
  String get commFieldBio => 'About Me & Health Journey';

  @override
  String get commFieldDailyFocus => 'Daily Wellness Focus';

  @override
  String get commPrivacySection => 'Privacy & Messaging Controls';

  @override
  String get commToggleDiscoverable => 'Show my profile in Global Discover';

  @override
  String get commToggleHideRealName => 'Hide real name (show @username only)';

  @override
  String get commToggleHidePhoto => 'Hide profile photo';

  @override
  String get commToggleAllowMessages => 'Allow direct messages';

  @override
  String get commToggleRequireApproval =>
      'Require my approval for new message requests';

  @override
  String get commUploadPhoto => 'Upload Photo';

  @override
  String get commRemovePhoto => 'Remove Photo';

  @override
  String get commSaveProfile => 'Save Health Profile';

  @override
  String get commProfileSaved => 'Health community profile updated.';

  @override
  String get commLeaveCommunity => 'Leave Community & Delete Public Profile';

  @override
  String get commLeftCommunity =>
      'Your public community profile has been removed.';

  @override
  String get commInboxEmpty =>
      'No conversations yet. Discover health buddies and say hello!';

  @override
  String get commMessageRequestBadge => 'Message Request';

  @override
  String get commRequestBannerTitle => 'New message request';

  @override
  String get commRequestBannerBody =>
      'Accept to keep chatting, or decline/block this member.';

  @override
  String get commRequestAccept => 'Accept';

  @override
  String get commRequestDecline => 'Decline';

  @override
  String get commChatPlaceholder => 'Write a supportive message...';

  @override
  String get commAttachPhoto => 'Attach photo';

  @override
  String get commPhotoLabel => 'Photo';

  @override
  String get commRateLimited =>
      'Please wait a few seconds before sending another message.';

  @override
  String get commBlockedNotice =>
      'You cannot message this user due to block settings.';

  @override
  String get commMuteChat => 'Mute';

  @override
  String get commUnmuteChat => 'Unmute';

  @override
  String get commHideChat => 'Hide Chat';

  @override
  String get commBlockUser => 'Block User';

  @override
  String get commUnblockUser => 'Unblock User';

  @override
  String get commBlockedToast =>
      'User blocked. Their profile and messages are hidden.';

  @override
  String get commReportUser => 'Report';

  @override
  String get commReportTitle => 'Report Content or Member';

  @override
  String get commReportReasonInappropriate => 'Inappropriate content';

  @override
  String get commReportReasonSpam => 'Spam or advertising';

  @override
  String get commReportReasonHarassment => 'Harassment or hate speech';

  @override
  String get commReportReasonMisinfo =>
      'Unsafe medical advice / misinformation';

  @override
  String get commReportReasonOther => 'Other';

  @override
  String get commReportNoteHint => 'Optional details...';

  @override
  String get commReportSubmit => 'Submit Report';

  @override
  String get commReportSent =>
      'Thank you. Your safety report has been submitted.';

  @override
  String get commDeleteForMe => 'Delete for me';

  @override
  String get commDeleteForEveryone => 'Delete for everyone';

  @override
  String get commOnlineNow => 'Online';

  @override
  String get commFilterOnlineOnly => 'Online nu';

  @override
  String get commFilterSameCondition => 'Samma tillstånd';

  @override
  String get commFilterAllConditions => 'All Conditions';

  @override
  String get commSameConditionPrompt =>
      'Add a chronic condition in My Profile to match with peers sharing it.';

  @override
  String get commFieldChronicConditions => 'Chronic Conditions (Optional)';

  @override
  String get commFieldCustomCondition => 'Other Chronic Condition (optional)';

  @override
  String get commFieldCustomConditionHint =>
      'e.g. Fibromyalgia, PCOS, Vitamin D deficiency';

  @override
  String get commToggleShowConditions =>
      'Show my chronic conditions on profile';

  @override
  String get commToggleShowOnline => 'Show my online status';

  @override
  String get condType1Diabetes => 'Type 1 Diabetes';

  @override
  String get condType2Diabetes => 'Type 2 Diabetes';

  @override
  String get condHypertension => 'Hypertension';

  @override
  String get condAsthmaCopd => 'Asthma / COPD';

  @override
  String get condThyroidHashimoto => 'Thyroid / Hashimoto';

  @override
  String get condMigraine => 'Migraine';

  @override
  String get condHeartCondition => 'Heart & Vascular';

  @override
  String get condCeliacIbs => 'Celiac / IBS';

  @override
  String get condArthritis => 'Arthritis / Rheumatism';

  @override
  String get condAnemia => 'Anemia';

  @override
  String get condKidneyHealth => 'Kidney Health';

  @override
  String get condEczemaPsoriasis => 'Eczema / Psoriasis';

  @override
  String get adminPanelTitle => 'Admin-kontrollpanel';

  @override
  String get adminTabStats => 'Statistics';

  @override
  String get adminTabAnnouncements => 'Announcements';

  @override
  String get adminTabPromotions => 'Ads & Banners';

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminTabReports => 'Reports';

  @override
  String get adminStatOnline => 'Online Now';

  @override
  String get adminStatMembers => 'Members';

  @override
  String get adminStatLikes => 'Profile Likes';

  @override
  String get adminStatChats => 'Active Chats';

  @override
  String get adminStatPendingReports => 'Pending Reports';

  @override
  String get adminStatActiveBanners => 'Active Ads/Notices';

  @override
  String get adminConditionBreakdown => 'Chronic Condition Distribution';

  @override
  String get adminNewAnnouncement => 'New Announcement';

  @override
  String get adminNewPromotion => 'New Ad / Banner';

  @override
  String get adminFieldTitle => 'Title';

  @override
  String get adminFieldMessage => 'Message / Description';

  @override
  String get adminFieldLink => 'Link URL (optional)';

  @override
  String get adminFieldPlacement => 'Placement';

  @override
  String get adminPlacementHome => 'Home Top';

  @override
  String get adminPlacementCommunity => 'Community Top';

  @override
  String get adminPlacementProfile => 'Profile Top';

  @override
  String get adminTypeInfo => 'Announcement';

  @override
  String get adminTypeHealthTip => 'Health Tip';

  @override
  String get adminTypeWarning => 'Alert';

  @override
  String get adminTypeCampaign => 'Campaign';

  @override
  String get adminSearchUsersHint =>
      'Search users by name, country, or condition...';

  @override
  String get adminActionVerify => 'Verify';

  @override
  String get adminActionUnverify => 'Remove Verification';

  @override
  String get adminActionSuspend => 'Suspend';

  @override
  String get adminActionUnsuspend => 'Restore';

  @override
  String get adminStatusSuspended => 'Suspended';

  @override
  String get adminStatusVerified => 'Verified';

  @override
  String get adminReportResolve => 'Resolve';

  @override
  String get adminReportDismiss => 'Dismiss';

  @override
  String get adminNoReports => 'No safety reports yet.';

  @override
  String get adminNoAnnouncements => 'No announcements yet.';

  @override
  String get adminNoPromotions => 'No ads or banners yet.';

  @override
  String get commMusicSectionTitle => 'Koncentrationsmusik';

  @override
  String get commMusicTitleField => 'Track / Playlist Name (optional)';

  @override
  String get commMusicUrlField => 'Music Link (YouTube, Spotify, SoundCloud)';

  @override
  String get commMusicInvalidUrl =>
      'Please enter a valid YouTube, YouTube Music, Spotify, Apple Music, or SoundCloud link.';

  @override
  String get commMusicEmpty => 'No concentration music added yet.';

  @override
  String get commMusicListenAction => 'Listen';

  @override
  String get commMusicLikeAction => 'Like Music';

  @override
  String get commMusicListenersTitle => 'Who Listened?';

  @override
  String get commMusicListenersEmpty =>
      'No one has listened to this track yet.';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count Listeners';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '$count Plays';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '${count}x';
  }

  @override
  String get commProfileLikersTitle => 'Profile Likes';

  @override
  String get commProfileLikersEmpty => 'No profile likes yet.';

  @override
  String get commSocialsSectionTitle => 'Sociala medier';

  @override
  String get commToggleShowSocials => 'Visa mina sociala medier';

  @override
  String get commSocialsHiddenHint => 'Hidden from other members';

  @override
  String get commSocialsEmpty => 'No social accounts added yet.';

  @override
  String get commPreviewMyProfile => 'Preview My Profile';

  @override
  String get safetyContentBlocked =>
      'Texten innehåller olämpligt språk, förolämpningar eller förbjudet innehåll.';

  @override
  String get safetyImageBlocked =>
      'Bilden klarade inte säkerhetskontrollen och kunde inte laddas upp.';

  @override
  String get safetyAccountSuspended =>
      'Din community-åtkomst är tillfälligt avstängd på grund av regelbrott.';

  @override
  String get proMenuTitle => 'VisualCheckUp Pro';

  @override
  String get proMenuSubtitle =>
      'Obegränsade labbanalyser & reklamfri hälsospårning';

  @override
  String get proPaywallTitle => 'Uppgradera till VisualCheckUp Pro';

  @override
  String get proPaywallSubtitle =>
      'Lås upp obegränsade labbanalyser, hälsotrender och en reklamfri upplevelse.';

  @override
  String get proPlanMonthly => 'Månadsvis';

  @override
  String get proPlanYearly => 'Årsvis';

  @override
  String get proSaveBadge => 'Bäst värde • Spara 42%';

  @override
  String get proPerMonth => '/ månad';

  @override
  String get proPerYear => '/ år';

  @override
  String get proBenefitUnlimitedLabs =>
      'Obegränsade blod- och labbprovsanalyser';

  @override
  String get proBenefitAiInsights => 'Obegränsad AI-tolkning av PDF & foto';

  @override
  String get proBenefitAdFree => 'Helt reklamfri upplevelse';

  @override
  String get proBenefitDoctorPriority =>
      'Prioriterad läkarsökning & patientuppföljning';

  @override
  String get proSubscribeButton => 'Aktivera VisualCheckUp Pro';

  @override
  String get proRestoreButton => 'Återställ köp';

  @override
  String get proActiveBadge => 'VisualCheckUp Pro Aktiv';

  @override
  String get proActivatedToast =>
      'VisualCheckUp Pro aktiverat! Obegränsade labbanalyser upplåsta.';

  @override
  String labFreeQuotaBanner(int remaining, int limit) {
    return 'Gratis labbanalyser denna månad: $remaining / $limit';
  }

  @override
  String get labProUnlimitedBanner =>
      'VisualCheckUp Pro • Obegränsade labbanalyser';

  @override
  String get labLimitReachedTitle => 'Gratisgräns för månaden nådd';

  @override
  String get labLimitReachedBody =>
      'Gratiskonton kan analysera upp till 3 labbrapporter per månad. Uppgradera till Pro för obegränsat.';

  @override
  String get labUpgradeToProBtn => 'Skaffa Pro (Obegränsat)';

  @override
  String get doctorSearchTitle => 'Sök läkare per land';

  @override
  String get doctorSearchSubtitle =>
      'Hitta verifierade läkare efter land & specialitet för patientuppföljning';

  @override
  String get doctorSearchHomeCta => 'Sök läkare';

  @override
  String get doctorApplyCta => 'Läkaransökan';

  @override
  String get doctorSearchHint =>
      'Sök på namn, stad, klinik eller specialitet...';

  @override
  String get doctorFilterAllSpecialties => 'Alla specialiteter';

  @override
  String get doctorFilterFollowUpOnly => 'Patientuppföljning öppen';

  @override
  String get doctorEmptyResults =>
      'Inga verifierade läkare matchade ditt val ännu.';

  @override
  String get doctorVerifiedBadge => 'Verifierad läkare';

  @override
  String get doctorFollowUpBadge => 'Patientuppföljning';

  @override
  String doctorExperienceYears(int years) {
    return '$years års erf.';
  }

  @override
  String get doctorRequestFollowUpBtn => 'Begär uppföljning';

  @override
  String get doctorFollowUpDialogTitle => 'Begär patientuppföljning';

  @override
  String get doctorFollowUpNoteHint =>
      'Beskriv kort ditt kroniska tillstånd eller uppföljningsmål...';

  @override
  String get doctorFollowUpSent =>
      'Din uppföljningsförfrågan har skickats till läkaren!';

  @override
  String get doctorApplicationTitle => 'Ansökan för verifierad läkare';

  @override
  String get doctorApplicationSubtitle =>
      'Gå med i VisualCheckUps globala läkarkatalog för rådgivning och uppföljning.';

  @override
  String get doctorFieldTitle => 'Titel (Dr., Leg. läkare)';

  @override
  String get doctorFieldFullName => 'Fullständigt namn';

  @override
  String get doctorFieldSpecialty => 'Medicinsk specialitet';

  @override
  String get doctorFieldClinic => 'Sjukhus / Klinik';

  @override
  String get doctorFieldLicense => 'Legitimationsnummer';

  @override
  String get doctorFieldExperience => 'Års erfarenhet';

  @override
  String get doctorFieldBio => 'Klinisk profil & fokusområden';

  @override
  String get doctorToggleFollowUp =>
      'Ta emot förfrågningar om patientuppföljning';

  @override
  String get doctorUploadDocBtn => 'Ladda upp legitimationsbevis (Valfritt)';

  @override
  String get doctorPlanSectionTitle => 'Medlemskapsplan för läkare';

  @override
  String get doctorPlanMonthlyTitle => 'Läkare Standard (Månadsvis)';

  @override
  String get doctorPlanMonthlyDesc =>
      'Verifierat märke, land- & specialitetslistning, patientchatt';

  @override
  String get doctorPlanYearlyTitle => 'Läkare Pro + Uppföljning (Årsvis)';

  @override
  String get doctorPlanYearlyDesc =>
      'Prioriterad ranking, strukturerad patientuppföljning, obegränsade kontakter';

  @override
  String get doctorSubmitApplicationBtn => 'Skicka läkaransökan';

  @override
  String get doctorApplicationSubmitted =>
      'Din läkaransökan har skickats för granskning!';

  @override
  String get doctorApplicationPendingBadge => 'Ansökan väntar på granskning';

  @override
  String get adminTabDoctors => 'Läkare';

  @override
  String get adminApproveDoctor => 'Godkänn';

  @override
  String get adminRejectDoctor => 'Avslå';

  @override
  String get adminNoDoctorApps => 'Inga läkaransökningar ännu.';

  @override
  String get specInternalMedicine => 'Internmedicin';

  @override
  String get specCardiology => 'Kardiologi';

  @override
  String get specDermatology => 'Dermatologi';

  @override
  String get specEndocrinology => 'Endokrinologi';

  @override
  String get specNeurology => 'Neurologi';

  @override
  String get specOphthalmology => 'Oftalmologi';

  @override
  String get specPediatrics => 'Pediatrik';

  @override
  String get specFamilyMedicine => 'Allmänmedicin';

  @override
  String get specNutritionDietetics => 'Nutrition & Dietetik';

  @override
  String get specPsychiatry => 'Psykiatri';

  @override
  String get specPulmonology => 'Lungmedicin';

  @override
  String get specNephrology => 'Nefrologi';
}
