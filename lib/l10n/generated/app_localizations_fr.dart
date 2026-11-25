// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'Cette application ne pose pas de diagnostic médical ; elle sert uniquement à l\'information et à la vigilance visuelle.';

  @override
  String get disclaimerTitle => 'Avis Médical Important';

  @override
  String get disclaimerFull =>
      'VisualCheckUp propose une pré-évaluation visuelle basée sur la couleur et l\'aspect. Ce n\'est pas un dispositif médical et cela ne remplace jamais un médecin ou un examen de laboratoire.\n\n• L\'éclairage ambiant et le capteur photo influencent la perception des couleurs.\n• Consultez rapidement en cas de douleur intense, saignement, forte fièvre, jaunisse, selles noires/pâles ou gêne respiratoire.\n• Confidentialité : les images sont traitées localement par défaut.';

  @override
  String get disclaimerAccept => 'J\'ai compris';

  @override
  String get loginTagline =>
      'Assistant personnel pour le suivi visuel de la peau, des grains de beauté et la préparation des rendez-vous médicaux.';

  @override
  String get featureColorCalibration => 'Calibration Couleur';

  @override
  String get featurePrivacyFirst => 'Confidentialité';

  @override
  String get featureOptionalAi => 'IA Optionnelle';

  @override
  String get loginCardTitle => 'Continuer avec votre compte';

  @override
  String get loginCardSubtitle =>
      'Conservez vos références de couleur et votre historique de contrôles.';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get orDivider => 'ou';

  @override
  String get continueAsGuest => 'Continuer en tant qu\'invité';

  @override
  String get guestGreeting => 'Suivi Visuel Santé & Peau';

  @override
  String userGreeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return 'Compte $provider';
  }

  @override
  String get localOnlyLabel => 'Enregistré uniquement sur cet appareil';

  @override
  String get menuHome => 'Accueil';

  @override
  String get menuSectionVisualChecks => 'CONTRÔLES VISUELS';

  @override
  String get menuSkinGroup => 'Peau (Grain de beauté, Verrue)';

  @override
  String get menuSkinGeneral => 'Peau Générale & Éruptions';

  @override
  String get menuSectionTracking => 'SUIVI, ANALYSES & CONSTANTES';

  @override
  String get menuFollowUpPlan => 'Plan de Suivi Personnel';

  @override
  String get menuVitalsTracker => 'Tension & Glycémie';

  @override
  String get menuLabReports => 'Analyses & Comptes Rendus';

  @override
  String get menuQuickColorCard => 'Nuancier sans Caméra';

  @override
  String get menuHistory => 'Historique des Contrôles';

  @override
  String get menuReferenceGuide => 'Guide Visuel de Référence';

  @override
  String get menuSectionSettings => 'PARAMÈTRES & CONFIDENTIALITÉ';

  @override
  String get menuAiSettings => 'IA & Confidentialité';

  @override
  String get menuDisclaimer => 'Avis Médical';

  @override
  String get menuTheme => 'Thème d\'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get menuLanguage => 'Langue de l\'Application';

  @override
  String get languageSystem => 'Langue du Système';

  @override
  String get signInGoogleOrApple => 'Se connecter avec Google ou Apple';

  @override
  String get signOut => 'Se Déconnecter';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte et les données locales';

  @override
  String get deleteAccountBody =>
      'Vous serez déconnecté et votre historique ainsi que vos références locales seront définitivement supprimés. Continuer ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get followUpCardTitle => 'Plan de Suivi Personnel';

  @override
  String get followUpSelectEdit => 'Choisir / Modifier';

  @override
  String get followUpStart => 'Démarrer';

  @override
  String get followUpEmptyHint =>
      'Appuyez pour choisir les suivis yeux, urine, tension, glycémie et autres.';

  @override
  String get followUpSheetSubtitle =>
      'Suivez yeux, langue, ongles, peau, urine, selles, tension, glycémie et analyses dans un seul plan.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active actifs • $completed à jour • $due à faire';
  }

  @override
  String get homeCategoriesTitle => 'Catégories de Contrôle';

  @override
  String get homeCategoriesSubtitle =>
      'Suivez les changements visuels par caméra ou nuancier sans caméra.';

  @override
  String get homeLabsVitalsTitle => 'Analyses, Tension & Glycémie';

  @override
  String get homeLabsVitalsSubtitle =>
      'Lisez vos bilans sanguins et suivez vos courbes de tension et glycémie.';

  @override
  String get homeLabsCardTitle => 'Analyses & Bilans';

  @override
  String get homeLabsCardEmpty => 'Lire et analyser vos bilans';

  @override
  String homeLabsCardCount(int count) {
    return '$count bilans enregistrés';
  }

  @override
  String get homeVitalsCardTitle => 'Tension & Glycémie';

  @override
  String get homeVitalsCardEmpty => 'Saisir et suivre les tendances';

  @override
  String homeVitalsCardCount(int count) {
    return '$count mesures enregistrées';
  }

  @override
  String get homeRecentChecks => 'Contrôles Récents';

  @override
  String get seeAll => 'Tout Voir';

  @override
  String get catEyeTitle => 'Yeux (Sclérotique)';

  @override
  String get catEyeSubtitle => 'Rougeur, jaunissement et teinte oculaire';

  @override
  String get catNailTitle => 'Ongles';

  @override
  String get catNailSubtitle => 'Pâleur, cyanose, jaunissement et forme';

  @override
  String get catTongueTitle => 'Langue';

  @override
  String get catTongueSubtitle => 'Couleur, enduit blanc/jaune et texture';

  @override
  String get catFaceTitle => 'Visage & Teint';

  @override
  String get catFaceSubtitle => 'Teint, pâleur et rougeurs';

  @override
  String get catSkinTitle => 'Affections Cutanées';

  @override
  String get catSkinSubtitle => 'Grain de beauté, verrue, ecchymose, tache';

  @override
  String get catUrineTitle => 'Couleur de l\'Urine';

  @override
  String get catUrineSubtitle => 'Hydratation et échelle de couleur';

  @override
  String get catStoolTitle => 'Couleur des Selles';

  @override
  String get catStoolSubtitle => 'Digestion et signes d\'alerte';

  @override
  String get tooltipHistory => 'Historique';

  @override
  String get tooltipAccountMenu => 'Compte et Menu';

  @override
  String get menuSettings => 'Paramètres (Autorisations & Langue)';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguageDesc =>
      'La langue du téléphone est utilisée par défaut. Vous pouvez choisir une autre langue ci-dessous.';

  @override
  String get settingsPermissionsTitle => 'Autorisations';

  @override
  String get settingsPermissionsDesc =>
      'Consultez et gérez ici les autorisations caméra et photos.';

  @override
  String get settingsCameraPermission => 'Autorisation Caméra';

  @override
  String get settingsCameraPermissionDesc =>
      'Pour les photos des yeux, de la langue, des ongles et de la peau';

  @override
  String get settingsPhotosPermission => 'Autorisation Galerie & Photos';

  @override
  String get settingsPhotosPermissionDesc =>
      'Pour importer des photos et bilans médicaux';

  @override
  String get settingsOpenSystemPermissions =>
      'Ouvrir les Autorisations du Téléphone';

  @override
  String get permChecking => 'Vérification...';

  @override
  String get permGranted => 'Accordée';

  @override
  String get permDenied => 'Autorisation Requise';

  @override
  String get permPermanent => 'Activer dans les Réglages Système';

  @override
  String get permUnavailable => 'Géré par l\'appareil';

  @override
  String get permGrantBtn => 'Autoriser';

  @override
  String get permOpenSettingsBtn => 'Ouvrir Réglages';

  @override
  String get skinCancerRisk => 'Grain de Beauté & Risque';

  @override
  String get skinWart => 'Pré-contrôle Verrue';

  @override
  String get skinBruise => 'Suivi Ecchymose';

  @override
  String get skinFacialSpot => 'Tache Faciale';

  @override
  String get trackEyeTitle => 'Contrôle Hebdomadaire des Yeux';

  @override
  String get trackEyeSubtitle =>
      'Suivez rougeurs ou jaunissement de la sclérotique';

  @override
  String get trackTongueTitle => 'Contrôle Hebdomadaire de la Langue';

  @override
  String get trackTongueSubtitle => 'Suivez couleur, enduit et texture';

  @override
  String get trackNailTitle => 'Contrôle Hebdomadaire des Ongles';

  @override
  String get trackNailSubtitle => 'Surveillez pâleur, cyanose ou jaunissement';

  @override
  String get trackFaceTitle => 'Teint Facial Bimensuel';

  @override
  String get trackFaceSubtitle => 'Comparez pâleur, rougeurs et teint';

  @override
  String get trackSkinTitle => 'Contrôle Mensuel Peau & Grains de Beauté';

  @override
  String get trackSkinSubtitle => 'Comparez l\'évolution sur 30 jours';

  @override
  String get trackHydrationTitle => 'Hydratation Quotidienne (Urine)';

  @override
  String get trackHydrationSubtitle =>
      'Enregistrez en 2 s avec le nuancier sans caméra';

  @override
  String get trackStoolTitle => 'Contrôle Hebdomadaire des Selles';

  @override
  String get trackStoolSubtitle => 'Suivez la digestion et les alertes couleur';

  @override
  String get trackBpTitle => 'Tension Artérielle Quotidienne';

  @override
  String get trackBpSubtitle =>
      'Enregistrez tension systolique/diastolique et pouls';

  @override
  String get trackSugarTitle => 'Glycémie Quotidienne';

  @override
  String get trackSugarSubtitle =>
      'Suivez votre glycémie à jeun ou après repas';

  @override
  String get trackLabTitle => 'Bilan Sanguin Trimestriel';

  @override
  String get trackLabSubtitle =>
      'Importez vos bilans et comparez dans le temps';

  @override
  String get statusFirstPending => 'En attente du premier relevé';

  @override
  String get statusDueNow => 'Contrôle à effectuer';

  @override
  String get statusDoneToday => 'Terminé aujourd\'hui';

  @override
  String statusNextDays(int days) {
    return 'Prochain contrôle dans $days jours';
  }

  @override
  String get actionCheckNow => 'Contrôler';

  @override
  String get actionLogReading => 'Saisir';

  @override
  String get actionAddReport => 'Ajouter Bilan';

  @override
  String checkMethodTitle(String category) {
    return '$category • Méthode de Contrôle';
  }

  @override
  String get checkMethodSubtitle =>
      'Choisissez en 2 secondes sur le nuancier sans photo ou utilisez la caméra.';

  @override
  String get colorCardRecommendedTitle => 'Nuancier sans Caméra (Recommandé)';

  @override
  String get colorCardRecommendedSubtitle =>
      'Rapide et confidentiel sans photo (2 s)';

  @override
  String get cameraMeasureTitle => 'Mesure par Caméra';

  @override
  String get cameraMeasureSubtitle =>
      'Mesure automatique avec balance des blancs';

  @override
  String get referenceGuideSubtitle =>
      'Sélectionnez un module pour consulter les références visuelles.';

  @override
  String get historyEmpty => 'Aucun contrôle enregistré pour le moment.';

  @override
  String get filterAll => 'Tous';

  @override
  String get aiSettingsTitle => 'IA & Confidentialité';

  @override
  String get vitalsBpTab => 'Tension';

  @override
  String get vitalsSugarTab => 'Glycémie';

  @override
  String get skinScreenTitle => 'Pré-contrôle Cutané';

  @override
  String get providerGuest => 'Invité';

  @override
  String signInFailed(String error) {
    return 'Échec de connexion : $error';
  }

  @override
  String get riskNormal => 'Aspect normal';

  @override
  String get riskAttention => 'Suivi conseillé';

  @override
  String get riskUrgent => 'Avis médical recommandé';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'Dernier : $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'Dernier : $count valeurs ($abnormal hors norme)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Dernier : $count valeurs (toutes normales)';
  }

  @override
  String get labStatusCriticalLow => 'Critique bas';

  @override
  String get labStatusLow => 'Bas';

  @override
  String get labStatusNormal => 'Normal';

  @override
  String get labStatusHigh => 'Élevé';

  @override
  String get labStatusCriticalHigh => 'Critique élevé';

  @override
  String get labSourceManual => 'Saisie manuelle';

  @override
  String get labSourcePasted => 'Lu depuis le texte';

  @override
  String get labSourcePhoto => 'Rapport JPG / Photo';

  @override
  String get labSourcePdf => 'Rapport PDF';

  @override
  String get bpLow => 'Tension basse';

  @override
  String get bpNormal => 'Plage normale';

  @override
  String get bpElevated => 'Élevée';

  @override
  String get bpStage1 => 'Hypertension stade 1';

  @override
  String get bpStage2 => 'Hypertension stade 2';

  @override
  String get bpCrisis => 'Crise hypertensive';

  @override
  String get sugarLow => 'Hypoglycémie';

  @override
  String get sugarNormal => 'Plage normale';

  @override
  String get sugarBorderline => 'Limite élevée';

  @override
  String get sugarHigh => 'Glycémie élevée';

  @override
  String get sugarVeryHigh => 'Glycémie très élevée';

  @override
  String get sugarTypeFasting => 'À jeun';

  @override
  String get sugarTypePostMeal => 'Post-repas (2h)';

  @override
  String get sugarTypeRandom => 'Aléatoire';

  @override
  String get specialtyEye => 'Ophtalmologie ou Médecine interne';

  @override
  String get specialtyNail => 'Dermatologie ou Médecine interne';

  @override
  String get specialtyTongue => 'ORL, Santé bucco-dentaire ou Médecine interne';

  @override
  String get specialtySkin => 'Dermatologie';

  @override
  String get specialtyUrine => 'Urologie ou Médecine interne';

  @override
  String get specialtyStool => 'Gastro-entérologie ou Médecine interne';

  @override
  String get cloudBackupTitle => 'Sauvegarde cloud (Optionnel • Firebase)';

  @override
  String get cloudBackupDesc =>
      'Par défaut, vos analyses et mesures restent uniquement sur cet appareil. Activez la sauvegarde privée sur votre compte Google/Apple pour les conserver lors d\'un changement de téléphone.';

  @override
  String get cloudBackupToggleTitle => 'Activer la sauvegarde cloud';

  @override
  String cloudBackupLastSync(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Activé • Prêt à synchroniser';

  @override
  String get cloudBackupDisabledLocal =>
      'Désactivé • Stockage local uniquement';

  @override
  String get cloudBackupSignInRequired =>
      'Connectez-vous avec Google ou Apple pour la sauvegarde cloud.';

  @override
  String get cloudBackupNowBtn => 'Sauvegarder';

  @override
  String get cloudRestoreBtn => 'Restaurer du cloud';

  @override
  String get cloudConsentTitle => 'Consentement sauvegarde cloud';

  @override
  String get cloudConsentBody =>
      'Vos analyses, mesures et suivis restent par défaut sur cet appareil.\n\nSi vous activez la sauvegarde cloud, ils seront stockés en privé sur votre compte Google/Apple et supprimés définitivement lors de la suppression du compte.\n\nAcceptez-vous ?';

  @override
  String get cloudConsentConfirm => 'Oui, activer';

  @override
  String cloudBackupSuccess(int count) {
    return 'Sauvegarde terminée : $count enregistrements synchronisés.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Échec de sauvegarde : $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Restauré du cloud : $count enregistrements importés.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Échec de restauration : $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Sauvegarde cloud désactivée. Les nouveaux enregistrements restent locaux.';

  @override
  String get aiCloudToggleTitle => 'Analyse IA cloud (Gemini)';

  @override
  String get aiCloudOnDesc =>
      'Activé : Les photos nettes sont redimensionnées et analysées de manière sécurisée. Mode local hors ligne.';

  @override
  String get aiCloudOffDesc =>
      'Désactivé (0 token) : Toute analyse reste sur votre appareil ; aucune photo n\'est envoyée.';

  @override
  String get aiBackendOfflineNote =>
      'Une fois la clé Gemini / Firebase AI configurée, l\'analyse cloud s\'active selon ce choix ; le moteur local est actif.';

  @override
  String get aiOptimizationsTitle =>
      'Contrôles d\'économie de tokens et données';

  @override
  String get aiOptQualityGate =>
      'Filtre qualité 0-token (flou, obscurité, reflets)';

  @override
  String get aiOptCompression =>
      'Recadrage auto + compression JPEG 512/768px (80%)';

  @override
  String get aiOptTieredModel => 'Routage intelligent (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'Cache local pour doublons (0 token)';

  @override
  String get aiClearCacheBtn => 'Vider le cache IA';

  @override
  String get aiCacheCleared => 'Cache IA vidé.';

  @override
  String resultScreenTitle(String category) {
    return 'Résultat : $category';
  }

  @override
  String get tooltipDoctorSummary => 'Résumé pour le médecin';

  @override
  String get tooltipReferenceGuide => 'Guide de référence';

  @override
  String get calibratedColorTone => 'Teinte calibrée';

  @override
  String get sampledColorTone => 'Teinte dominante mesurée';

  @override
  String confidenceLabel(int percent) {
    return 'Confiance préliminaire : $percent%';
  }

  @override
  String get whiteBalanceDefaultNote =>
      'Couleur équilibrée avec référence blanche.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Spécialité conseillée : $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Évolution dans le temps';

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Précédent : \"$title\" ($status). $count enregistrements suivis.';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'Comparaison avec votre référence';

  @override
  String get yourBaselineLabel => 'Référence';

  @override
  String get warningFlagsTitle => 'Signes d\'alerte';

  @override
  String get observationsTitle => 'Observations';

  @override
  String get recommendationsTitle => 'Recommandations';

  @override
  String get personalBaselineCardTitle =>
      'Calibration de référence personnelle';

  @override
  String get personalBaselineCardDesc =>
      'Enregistrez cette mesure un jour sain comme référence personnelle pour limiter les écarts de caméra.';

  @override
  String get saveBaselineBtn => 'Enregistrer ma référence';

  @override
  String get updateBaselineBtn => 'Mettre à jour ma référence';

  @override
  String get clearBaselineBtn => 'Supprimer';

  @override
  String baselineSavedMsg(String category) {
    return 'Référence enregistrée pour $category.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'Référence supprimée pour $category.';
  }

  @override
  String get doctorSummaryBtn => 'Montrer au médecin • Résumé';

  @override
  String get returnHomeBtn => 'Retour à l\'accueil';

  @override
  String get doctorSheetTitle => 'Résumé de consultation';

  @override
  String colorLabel(String hex, String status) {
    return 'Couleur : $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Chronologie des mesures';

  @override
  String get questionsForDoctorTitle => 'Questions à poser au médecin';

  @override
  String get copyShareSummaryBtn => 'Copier et partager';

  @override
  String get doctorSummaryCopied => 'Résumé copié dans le presse-papiers.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Références visuelles';
  }

  @override
  String get healthyReferenceLabel => 'Référence saine';

  @override
  String get captureChecklistTitle => 'Conseils de prise de vue';

  @override
  String get abnormalFindingsTitle => 'Signes visuels à surveiller';

  @override
  String get cameraPermPermanentMsg =>
      'L\'accès caméra est désactivé dans les réglages. Activez-le ou choisissez une photo.';

  @override
  String get cameraPermRequiredMsg =>
      'L\'autorisation caméra est requise pour le contrôle visuel. Traitement local par défaut.';

  @override
  String get cameraGrantPermTitle => 'Accès caméra requis';

  @override
  String get cameraRequestPermBtn => 'Autoriser la caméra';

  @override
  String get cameraPickGalleryBtn => 'Choisir dans la galerie';

  @override
  String get cameraWhiteRefOn => 'Référence blanche : Active';

  @override
  String get cameraWhiteRefOff => 'Référence blanche : Désactivée';

  @override
  String get cameraBaselineActive => 'Référence enregistrée';

  @override
  String get cameraAnalyzing => 'Analyse en cours...';

  @override
  String get cameraCaptureBtn => 'Capturer et analyser';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Erreur d\'analyse : $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Nuancier';
  }

  @override
  String get quickCardPrivacyBanner =>
      'Sans caméra : choisissez la teinte la plus proche pour un suivi rapide en 2 secondes.';

  @override
  String get quickCardChooseShade => 'Choisissez la teinte la plus proche';

  @override
  String get quickCardExtraContext => 'Contexte supplémentaire (Optionnel)';

  @override
  String get quickCardSaveViewBtn => 'Enregistrer et voir l\'évaluation';

  @override
  String get quickCardUseCameraBtn => 'Utiliser la caméra à la place';

  @override
  String get skinIntroTitle => 'Pré-évaluation dermatologique visuelle';

  @override
  String get skinIntroDesc =>
      'Compare grains de beauté, verrues, ecchymoses et taches avec la peau environnante. Non diagnostique ; prépare la consultation.';

  @override
  String get skinStep1Title => '1. Choisissez un module dermatologique';

  @override
  String get skinOtherConcernsLabel => 'Autres aspects cutanés';

  @override
  String get skinStep2Title => '2. Symptômes associés (Optionnel)';

  @override
  String get skinStep3Title => '3. Zone du corps (Optionnel)';

  @override
  String get skinStartCameraBtn => 'Démarrer le contrôle cutané';

  @override
  String get skinConcernRash => 'Rougeur / Éruption';

  @override
  String get skinConcernMole => 'Grain de beauté / Tache';

  @override
  String get skinConcernScaly => 'Plaque sèche / squameuse';

  @override
  String get skinConcernBlister => 'Vésicule / Acné';

  @override
  String get skinConcernGeneral => 'Contrôle cutané général';

  @override
  String get bodyAreaFaceNeck => 'Visage / Cou';

  @override
  String get bodyAreaArmHand => 'Bras / Main';

  @override
  String get bodyAreaTorso => 'Torse';

  @override
  String get bodyAreaLegFoot => 'Jambe / Pied';

  @override
  String get bodyAreaScalp => 'Cuir chevelu';

  @override
  String get bodyAreaOther => 'Autre';

  @override
  String get symptomItching => 'Démangeaisons';

  @override
  String get symptomPainWarmth => 'Douleur / Chaleur';

  @override
  String get symptomRapidChange => 'Évolution rapide';

  @override
  String get symptomBleeding => 'Saignement / Suintement';

  @override
  String get symptomSpreading => 'S\'étend rapidement';

  @override
  String get symptomFever => 'Fièvre associée';

  @override
  String get symptomNonHealing => 'Plaie non cicatrisée (4+ sem.)';

  @override
  String get symptomOver6mm => '> 6 mm ou bords irréguliers';

  @override
  String get symptomNoTrauma => 'Apparu sans choc';

  @override
  String get symptomRoughDots => 'Surface rugueuse / points noirs';

  @override
  String get symptomSunHormone => 'Tache solaire, hormonale ou post-acné';

  @override
  String get bruiseGuideTitle => 'Guide des stades d\'ecchymose';

  @override
  String get wartGuideTitle => 'Guide sécurité verrues';

  @override
  String get abcdeGuideTitle => 'Guide ABCDE des grains de beauté';

  @override
  String get abcdeGuideSubtitle =>
      '5 signes clés utilisés par les dermatologues';

  @override
  String get labScreenTitle => 'Bilans et rapports';

  @override
  String get labTabReports => 'Mes rapports';

  @override
  String get labTabTrends => 'Évolution';

  @override
  String get labAddBtn => 'Ajouter un bilan';

  @override
  String get labEmptyTitle => 'Aucun bilan enregistré';

  @override
  String get labEmptyDesc =>
      'Importez votre bilan PDF ou JPG ; ajoutez si besoin un diagnostic ou vos symptômes pour une explication claire.';

  @override
  String get labAddFirstBtn => 'Ajouter un premier rapport';

  @override
  String get labTrendsEmptyDesc =>
      'Enregistrez des bilans à différentes dates pour suivre l\'évolution de l\'hémoglobine, ferritine, glucose, TSH, etc.';

  @override
  String labParamsCount(int count) {
    return '$count paramètres';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count hors norme';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Analyse des paramètres ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Diagnostic médical';

  @override
  String get labEnteredComplaintTitle => 'Votre symptôme / note';

  @override
  String get labInterpretationTitle => 'Explication claire';

  @override
  String get labCopyDoctorSummaryBtn => 'Montrer au médecin • Copier';

  @override
  String get labSummaryCopied => 'Résumé du bilan copié.';

  @override
  String get labExportPdfBtn => 'Exporter en PDF médical';

  @override
  String get labAddSheetTitle => 'Ajouter un rapport médical';

  @override
  String get labReportTitleField => 'Titre du rapport';

  @override
  String get labDefaultReportTitle => 'Résultat de bilan sanguin';

  @override
  String get labStep1Upload => '1. Importer PDF ou JPG';

  @override
  String get labUploadPdfJpgBtn => 'Importer PDF ou JPG';

  @override
  String get labCameraCaptureBtn => 'Prendre en photo';

  @override
  String get labStep2Context => '2. Diagnostic et note (Optionnel)';

  @override
  String get labStep2ContextHint =>
      'Indiquez un diagnostic à clarifier ou vos symptômes ; vous pouvez laisser vide.';

  @override
  String get labDiagnosisField => 'Diagnostic médical (Optionnel)';

  @override
  String get labComplaintField => 'Vos symptômes / question (Optionnel)';

  @override
  String get labStep3PasteManual => '3. Coller le texte ou saisir manuellement';

  @override
  String get labParseTextBtn => 'Lire et analyser le texte';

  @override
  String get labParamDropdown => 'Paramètre';

  @override
  String labValueField(String unit) {
    return 'Valeur ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Ajouter';

  @override
  String labParsedValuesTitle(int count) {
    return 'Valeurs lues ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Évaluer et enregistrer';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count relevés • Écart : $delta • Dernier : $status';
  }

  @override
  String get vitalsScreenTitle => 'Tension et Glycémie';

  @override
  String get vitalsCopySummaryTooltip => 'Copier le résumé médical';

  @override
  String get vitalsCopyEmptyMsg =>
      'Ajoutez d\'abord une mesure de tension ou de glycémie.';

  @override
  String get vitalsSummaryCopied => 'Résumé tension & glycémie copié.';

  @override
  String get vitalsAddBpBtn => 'Ajouter tension';

  @override
  String get vitalsAddSugarBtn => 'Ajouter glycémie';

  @override
  String get vitalsBpEmptyTitle => 'Aucune mesure de tension';

  @override
  String get vitalsBpEmptyDesc =>
      'Enregistrez vos mesures de tension et pouls datées pour suivre la courbe.';

  @override
  String get vitalsBpAddFirstBtn => 'Ajouter première tension';

  @override
  String get vitalsSugarEmptyTitle => 'Aucune mesure de glycémie';

  @override
  String get vitalsSugarEmptyDesc =>
      'Enregistrez votre glycémie à jeun, post-repas ou aléatoire pour suivre la tendance.';

  @override
  String get vitalsSugarAddFirstBtn => 'Ajouter première glycémie';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Moyenne ($count) : $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Pouls $pulse bpm';
  }

  @override
  String get vitalsBpHistoryTitle => 'Historique de tension';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Moyenne ($count) : $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'Historique de glycémie';

  @override
  String get vitalsNewBpTitle => 'Nouvelle mesure de tension';

  @override
  String get vitalsSystolicField => 'Systolique (Haute)';

  @override
  String get vitalsDiastolicField => 'Diastolique (Basse)';

  @override
  String get vitalsPulseField => 'Pouls (bpm — Optionnel)';

  @override
  String get vitalsNoteField => 'Note (Optionnel)';

  @override
  String get vitalsSaveBpBtn => 'Enregistrer la tension';

  @override
  String get vitalsNewSugarTitle => 'Nouvelle mesure de glycémie';

  @override
  String get vitalsSugarValueField => 'Glycémie (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'Enregistrer la glycémie';

  @override
  String get chartAddReadingHint =>
      'Ajoutez des mesures pour voir le graphique';

  @override
  String get loginTermsTitle => 'Conditions d’utilisation et avis médical';

  @override
  String get loginTermsCheckbox =>
      'Je comprends que VisualCheckUp ne pose pas de diagnostic médical définitif, qu’il est uniquement informatif, et j’accepte les conditions d’utilisation.';

  @override
  String get loginTermsRequiredMsg =>
      'Veuillez accepter les conditions d’utilisation et l’avis médical avant de vous connecter.';

  @override
  String get loginTermsReadMore => 'Lire les conditions';

  @override
  String get loginTermsModalBody =>
      '• Aucun diagnostic médical : VisualCheckUp n’est pas un dispositif médical et ne remplace pas la consultation d’un médecin.\n\n• Sensibilisation uniquement : Les contrôles visuels, bilans sanguins et courbes IMC/croissance servent uniquement au suivi personnel et à la préparation médicale.\n\n• Urgence : En cas de douleur thoracique, essoufflement ou symptôme grave, contactez immédiatement les urgences.\n\n• Confidentialité : Vos données restent par défaut uniquement sur votre appareil.';

  @override
  String get loginTermsAcceptBtn => 'J’ai lu et j’accepte';

  @override
  String atlasFilterAll(int count) {
    return 'Atlas Illustré ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Signes Urgents ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Tests Cliniques Maison ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Signes Nécessitant un Avis Médical Rapide';

  @override
  String get atlasTapToCompareHint =>
      'Appuyez sur une carte pour l’agrandir côte à côte avec la référence saine.';

  @override
  String get atlasVisualCueLabel => 'Indice Visuel';

  @override
  String get atlasClinicalContextLabel => 'Contexte Clinique Possible';

  @override
  String get atlasPossibleContextShort => 'Contexte Possible';

  @override
  String get atlasWarningPrefix => 'Alerte';

  @override
  String get atlasCloseBtn => 'Fermer';

  @override
  String get atlasCaptureProtocolTitle => 'Protocole Optimal de Prise de Vue';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Tests Cliniques Préliminaires à Domicile';

  @override
  String get atlasSelfTestNormalPrefix => 'Normal';

  @override
  String get atlasSelfTestWarningPrefix => 'Attention';

  @override
  String get fitzpatrickScaleTitle =>
      'Phototypes de Fitzpatrick & Échelle ITA°';

  @override
  String get fitzpatrickScaleSubtitle =>
      'L’application mesure l’angle ITA° de la peau saine environnante pour ajuster les seuils à votre phototype.';

  @override
  String get resultVisualCompareTitle =>
      'Comparaison de Référence Clinique Illustrée';

  @override
  String get resultHealthyShort => 'Sain';

  @override
  String get resultMatchedShort => 'Correspondant';

  @override
  String get resultViewFullAtlasBtn => 'Voir l’Atlas Illustré Complet';

  @override
  String get resultHomeSelfTestsBtn => 'Tests Cliniques Maison';

  @override
  String get resultClinicalBiomarkersTitle => 'Mesures Cliniques Quantitatives';

  @override
  String get cameraEyeModeSclera => 'Mode : Sclère (Ictère)';

  @override
  String get cameraEyeModeConjunctiva => 'Paupière Inférieure (Anémie)';

  @override
  String get cameraClinicalAtlasChip => 'Tests & Atlas';

  @override
  String get bristolScaleTitle =>
      'Échelle de Bristol des Selles (Optionnel • Types 1–7)';

  @override
  String get bristolType1Title => 'Type 1 • Billes dures';

  @override
  String get bristolType2Title => 'Type 2 • Saucisse grumeleuse';

  @override
  String get bristolType3Title => 'Type 3 • Craquelée';

  @override
  String get bristolType4Title => 'Type 4 • Lisse (Idéal)';

  @override
  String get bristolType5Title => 'Type 5 • Morceaux mous';

  @override
  String get bristolType6Title => 'Type 6 • Pâteuse / Molle';

  @override
  String get bristolType7Title => 'Type 7 • Entièrement liquide';

  @override
  String get metricFitzpatrickPhototype => 'Phototype Fitzpatrick';

  @override
  String get metricAbcdeAsymmetry => 'A — Asymétrie';

  @override
  String get metricAbcdeBorder => 'B — Irrégularité des Bords';

  @override
  String get metricAbcdeColors => 'C — Couleurs Dermoscopiques';

  @override
  String get metricErythemaDelta => 'Indice d’Érythème Δ';

  @override
  String get metricAnnularClearing => 'Éclaircissement Central Annulaire';

  @override
  String get metricErythemaIndex => 'Indice d’Érythème (EI)';

  @override
  String get metricScleraBilirubin => 'Indice Bilirubine Sclérale';

  @override
  String get metricHemorrhagePatch => 'Zone d’Hémorragie Compacte';

  @override
  String get metricNailErythema => 'Indice d’Érythème Unguéal';

  @override
  String get metricBeauGroove => 'Sillon Transversal de Beau';

  @override
  String get metricTerryLindsaySplit => 'Division Proximale/Distale';

  @override
  String get metricSplinterStreak => 'Ratio d’Hémorragie en Écharde';

  @override
  String get metricGeographicTongue => 'Score Langue Géographique';

  @override
  String get metricYellowCoating => 'Ratio d’Enduit Jaune';

  @override
  String get metricBristolScale => 'Échelle de Bristol';

  @override
  String get hubStartNewScan => 'Démarrer un Nouveau Scan';

  @override
  String get hubPickFromGallery => 'Galerie';

  @override
  String hubPastScansTitle(int count) {
    return 'Scans Précédents ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Total des Scans';

  @override
  String get hubLastScanLabel => 'Dernier Scan';

  @override
  String get hubLatestStatusLabel => 'Dernier Statut';

  @override
  String get hubFilterAll => 'Tous';

  @override
  String get hubFilterAttention => 'Attention / Urgent';

  @override
  String get hubFilterWithPhoto => 'Avec Photo';

  @override
  String get hubColPhoto => 'Photo';

  @override
  String get hubColDate => 'Date';

  @override
  String get hubColFinding => 'Résultat & Résumé';

  @override
  String get hubColStatus => 'Statut';

  @override
  String get hubCompareModeBtn => 'Comparer 2 Scans';

  @override
  String hubCompareSelectHint(int count) {
    return 'Sélectionnez 2 scans dans le tableau pour comparer côte à côte ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Comparer Côte à Côte';

  @override
  String get hubCompareCancelBtn => 'Annuler';

  @override
  String get hubCompareSheetTitle => 'Comparaison de Scans Côte à Côte';

  @override
  String get hubCompareOlderLabel => 'Antérieur';

  @override
  String get hubCompareNewerLabel => 'Plus récent';

  @override
  String get hubCompareMetricsTitle => 'Comparaison des Mesures Cliniques';

  @override
  String hubEmptyTitle(String category) {
    return 'Aucun scan $category pour le moment';
  }

  @override
  String get hubEmptySubtitle =>
      'Lancez votre premier scan ci-dessus. Chaque contrôle est archivé ici par date avec sa miniature et son rapport complet.';

  @override
  String get hubDoctorSummaryBtn => 'Résumé Médecin';

  @override
  String get photoTapToZoomHint =>
      'Appuyez sur la photo pour zoomer en plein écran';

  @override
  String get photoZoomTitle => 'Photo Capturée';

  @override
  String get resultDeleteRecordTooltip => 'Supprimer';

  @override
  String get resultDeleteConfirmTitle => 'Supprimer ce scan ?';

  @override
  String get resultDeleteConfirmBody =>
      'Cet enregistrement sera définitivement supprimé de votre historique local.';

  @override
  String get resultDeleteBtn => 'Supprimer';

  @override
  String get labLargeTextBtn => 'Grand Texte';

  @override
  String get labLargeTextOnBtn => 'Grand Texte : Oui';

  @override
  String get labSeniorOverviewTitle => 'Votre Résumé en un Coup d’Œil';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count résultat(s) sont dans la norme.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count résultat(s) sont hors norme — expliqués simplement ci-dessous.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count résultat(s) s’écartent nettement des limites — montrez-les vite à votre médecin.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count analyses de routine courantes ne figurent pas dans ce rapport.';
  }

  @override
  String get labAttentionSectionTitle => 'Valeurs à Surveiller';

  @override
  String get labNormalSectionTitle => 'Valeurs Normales (Rassurant)';

  @override
  String get labMissingSectionTitle => 'Analyses Non Incluses dans ce Rapport';

  @override
  String get labMissingSectionExplain =>
      'Chaque bilan sanguin ne demande pas tous les tests. Les analyses courantes ci-dessous ne figurent pas sur ce document.';

  @override
  String get labNotInReportBadge => 'Absent du rapport';

  @override
  String get labWhatItMeansLabel => 'Ce que cela signifie';

  @override
  String get labWhatToDoLabel => 'Que faire ?';

  @override
  String get labAddAnotherPageBtn => 'Scanner une Autre Page';

  @override
  String labPagesReadBadge(int count) {
    return '$count page(s) lue(s)';
  }

  @override
  String get labPhotoOfflineHint =>
      'Photo du rapport ajoutée. Activez l’IA Cloud dans les Paramètres pour lire les photos automatiquement ou saisissez les valeurs ci-dessous.';

  @override
  String get labAllValuesNormalMsg =>
      'Toutes les valeurs enregistrées dans ce rapport sont dans la plage normale.';

  @override
  String get medTitle => 'Rappels & Alarmes Médicaments';

  @override
  String get medSubtitle => 'Suivez pilules, insuline et alarmes avec photo';

  @override
  String get medMenuTitle => 'Alarmes Médicaments';

  @override
  String get medHomeCardEmpty => 'Aucune alarme — ajoutez votre premier rappel';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return '$taken/$total pris aujourd\'hui';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count alarmes actives';
  }

  @override
  String get medTabToday => 'Aujourd\'hui';

  @override
  String get medTabAll => 'Toutes les alarmes';

  @override
  String get medAddAlarm => 'Nouvelle alarme';

  @override
  String get medEditAlarm => 'Modifier l\'alarme';

  @override
  String get medCatPill => 'Médicament / Comprimé';

  @override
  String get medCatDiabetes => 'Diabète / Insuline';

  @override
  String get medCatBloodPressure => 'Tension artérielle';

  @override
  String get medCatVitamin => 'Vitamine / Complément';

  @override
  String get medCatDropsCream => 'Collyre / Crème';

  @override
  String get medCatCheckup => 'Mesure / Contrôle';

  @override
  String get medCatOther => 'Autre';

  @override
  String get medMealAnytime => 'À tout moment';

  @override
  String get medMealBefore => 'Avant le repas';

  @override
  String get medMealAfter => 'Après le repas';

  @override
  String get medMealWith => 'Pendant le repas';

  @override
  String get medMealBedtime => 'Au coucher';

  @override
  String get medDayMon => 'Lun';

  @override
  String get medDayTue => 'Mar';

  @override
  String get medDayWed => 'Mer';

  @override
  String get medDayThu => 'Jeu';

  @override
  String get medDayFri => 'Ven';

  @override
  String get medDaySat => 'Sam';

  @override
  String get medDaySun => 'Dim';

  @override
  String get medEveryDay => 'Tous les jours';

  @override
  String get medWeekdays => 'Jours ouvrés';

  @override
  String get medWeekends => 'Week-end';

  @override
  String get medFieldCategory => 'Catégorie';

  @override
  String get medFieldName => 'Nom du médicament / rappel';

  @override
  String get medFieldNameHint =>
      'Ex. : Metformine 1000 mg, Insuline du soir...';

  @override
  String get medFieldNameRequired => 'Veuillez saisir le nom du médicament.';

  @override
  String get medFieldDosage => 'Dose / Quantité (Optionnel)';

  @override
  String get medFieldDosageHint => 'Ex. : 1 comprimé, 12 unités, 2 gouttes';

  @override
  String get medFieldDescription => 'Note de rappel (Affichée sur l\'alarme)';

  @override
  String get medFieldDescriptionHint =>
      'Ex. : Prendre 30 min avant le petit-déjeuner avec de l\'eau';

  @override
  String get medFieldMealTiming => 'Moment de prise';

  @override
  String get medFieldTime => 'Heure de l\'alarme';

  @override
  String get medFieldDays => 'Jours de répétition';

  @override
  String get medFieldPhoto => 'Photo du médicament (Affichée à la sonnerie)';

  @override
  String get medTakePhoto => 'Prendre photo';

  @override
  String get medPickGallery => 'Galerie';

  @override
  String get medRemovePhoto => 'Supprimer photo';

  @override
  String get medPhotoHint =>
      'Prenez la boîte ou le stylo d\'insuline en photo pour l\'afficher en grand lors de l\'alarme.';

  @override
  String get medSoundToggle => 'Son de l\'alarme';

  @override
  String get medVibrateToggle => 'Vibration';

  @override
  String get medSaveAlarm => 'Enregistrer l\'alarme';

  @override
  String get medAlarmSaved => 'Alarme enregistrée et programmée.';

  @override
  String get medAlarmDeleted => 'Alarme supprimée.';

  @override
  String get medDeleteConfirmTitle => 'Supprimer l\'alarme';

  @override
  String medDeleteConfirmBody(String title) {
    return 'Supprimer définitivement l\'alarme \"$title\" ?';
  }

  @override
  String get medStatusTaken => 'Pris';

  @override
  String get medStatusSnoozed => 'Reporté';

  @override
  String get medStatusSkipped => 'Ignoré';

  @override
  String get medStatusPending => 'En attente';

  @override
  String get medActionTaken => 'C\'est pris';

  @override
  String get medActionSnooze => 'Reporter 10 min';

  @override
  String get medActionSkip => 'Passer aujourd\'hui';

  @override
  String get medActionUndo => 'Annuler';

  @override
  String get medActionPreviewAlarm => 'Tester l\'alarme';

  @override
  String get medRingHeader => 'HEURE DU MÉDICAMENT';

  @override
  String get medRingNoteTitle => 'Note de rappel';

  @override
  String get medRingNoPhoto => 'Aucune photo de médicament';

  @override
  String get medRingTapZoom => 'Touchez la photo pour zoomer';

  @override
  String get medRingSnoozedToast => 'Reportée de 10 minutes.';

  @override
  String get medRingTakenToast => 'Parfait ! Dose du jour enregistrée.';

  @override
  String get medTodayProgressTitle => 'Programme d\'aujourd\'hui';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Prochaine alarme : $time • $title';
  }

  @override
  String get medNoTodayAlarms =>
      'Aucune alarme médicament prévue aujourd\'hui.';

  @override
  String get medEmptyTitle => 'Aucune alarme médicament';

  @override
  String get medEmptyBody =>
      'Ajoutez des alarmes avec photo pour le diabète, l\'insuline ou la tension. À l\'heure dite, la photo et votre note s\'affichent clairement.';

  @override
  String get medQuickPresetDiabetes => 'Diabète / Insuline';

  @override
  String get medQuickPresetBp => 'Tension';

  @override
  String get medQuickPresetVitamin => 'Vitamine';

  @override
  String get dietMenuTitle => 'Régime & Calories IA';

  @override
  String get dietHomeCardTitle => 'Régime & Menus';

  @override
  String get dietHomeCardEmpty => 'Régimes prêts, suivi et poids';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'Jour $day/$total • $percent% suivi';
  }

  @override
  String get dietCalorieQuickTitle => 'Calories de l\'Assiette IA';

  @override
  String get dietCalorieQuickSubtitle =>
      'Photographiez votre assiette pour calculer calories et macros';

  @override
  String get dietTabActive => 'Mon Régime';

  @override
  String get dietTabTemplates => 'Modèles';

  @override
  String get dietTabWeight => 'Poids';

  @override
  String get dietTabCalories => 'Calories IA';

  @override
  String get dietStartDiet => 'Démarrer le Régime';

  @override
  String get dietRestartOrChange => 'Changer de Régime';

  @override
  String get dietEndDiet => 'Terminer le Régime';

  @override
  String get dietEndDietConfirm =>
      'Terminer le régime actif ? Votre historique de suivi et de poids sera conservé.';

  @override
  String get dietNoActiveTitle => 'Aucun régime actif';

  @override
  String get dietNoActiveBody =>
      'Choisissez un modèle prêt (Méditerranéen, Diabète, DASH, Perte de poids, Jeûne 16:8, Hyperprotéiné) et suivez vos repas et votre poids.';

  @override
  String get dietBrowseTemplates => 'Voir les régimes prêts';

  @override
  String get dietStartDate => 'Date de début';

  @override
  String get dietEndDate => 'Date de fin';

  @override
  String get dietStartWeight => 'Poids initial (kg)';

  @override
  String get dietTargetWeight => 'Poids cible (kg)';

  @override
  String get dietDailyCalorieTarget => 'Objectif calorique quotidien (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days jours';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'Jour $day sur $total';
  }

  @override
  String dietDaysLeft(int days) {
    return '$days jours restants';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Suivi : $percent%';
  }

  @override
  String get dietFollowed => 'Suivi';

  @override
  String get dietNotFollowed => 'Écart';

  @override
  String get dietPending => 'En attente';

  @override
  String get dietSlotBreakfast => 'Petit-déjeuner';

  @override
  String get dietSlotMorningSnack => 'Collation matin';

  @override
  String get dietSlotLunch => 'Déjeuner';

  @override
  String get dietSlotAfternoonSnack => 'Collation après-midi';

  @override
  String get dietSlotDinner => 'Dîner';

  @override
  String get dietAlternativesLabel => 'Alternative';

  @override
  String dietWaterTarget(String liters) {
    return 'Objectif eau : $liters L';
  }

  @override
  String get dietRulesTitle => 'Règles du programme';

  @override
  String get dietSampleMenuTitle => 'Exemple de menu journalier';

  @override
  String get dietStartedToast => 'Programme régime démarré !';

  @override
  String get dietEndedToast => 'Programme régime terminé.';

  @override
  String get dietWeightLogTitle => 'Suivi du Poids';

  @override
  String get dietWeightAdd => 'Ajouter Poids';

  @override
  String get dietWeightField => 'Poids actuel (kg)';

  @override
  String get dietWeightNote => 'Note (Optionnel)';

  @override
  String get dietWeightNoteHint => 'Ex. : Pesée à jeun le matin';

  @override
  String get dietWeightEmpty =>
      'Aucune pesée enregistrée. Ajoutez votre premier poids.';

  @override
  String get dietWeightCurrent => 'Actuel';

  @override
  String get dietWeightTarget => 'Cible';

  @override
  String get dietWeightChange => 'Évolution';

  @override
  String get dietWeightSaved => 'Poids enregistré.';

  @override
  String get dietCalorieTitle => 'Calculateur Calories IA par Photo';

  @override
  String get dietCalorieSubtitle =>
      'Utilisable avec ou sans régime — photographiez votre assiette ou décrivez le plat.';

  @override
  String get dietSnapPlateCamera => 'Photo de l\'Assiette';

  @override
  String get dietPickPlateGallery => 'Depuis la Galerie';

  @override
  String get dietFoodDescLabel => 'Description / Portion (Optionnel)';

  @override
  String get dietFoodDescHint => 'Ex. : Poulet grillé, boulgour, salade verte';

  @override
  String get dietCalculateFromText => 'Calculer via Texte';

  @override
  String get dietAnalyzingPlate => 'Analyse des calories et macros...';

  @override
  String get dietResultTitle => 'Analyse Calories & Macros';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Vision';

  @override
  String get dietOnDeviceBadge => 'Estimation Locale Intelligente';

  @override
  String get dietProtein => 'Protéines';

  @override
  String get dietCarbs => 'Glucides';

  @override
  String get dietFat => 'Lipides';

  @override
  String get dietFiber => 'Fibres';

  @override
  String get dietPortionScale => 'Taille de portion';

  @override
  String get dietSaveMealLog => 'Enregistrer pour Aujourd\'hui';

  @override
  String get dietMealLoggedToast => 'Calories du repas ajoutées au journal.';

  @override
  String get dietTodayTotalCalories => 'Total du jour';

  @override
  String get dietRecentScans => 'Repas Analysés';

  @override
  String get dietNoScansYet =>
      'Aucun repas analysé. Photographiez votre assiette.';

  @override
  String dietHealthScore(int score) {
    return 'Équilibre : $score/10';
  }

  @override
  String get dietTodayLabel => 'Aujourd\'hui';

  @override
  String get medCatHerbalTea => 'Tisane / Thé aux herbes';

  @override
  String get medCatCustom => 'Autre (Personnalisé)';

  @override
  String get medFieldCustomCategory => 'Nom de catégorie personnalisé';

  @override
  String get medFieldCustomCategoryHint =>
      'Ex. : Probiotique, Eau, Kinésithérapie...';

  @override
  String get medQuickPresetHerbalTea => 'Tisane';

  @override
  String get dietCreateCustom => 'Créer Mon Propre Régime';

  @override
  String get dietCreateCustomSubtitle =>
      'Saisissez le plan de votre diététicien ou vos repas manuellement';

  @override
  String get dietCustomNameLabel => 'Nom du régime';

  @override
  String get dietCustomNameHint => 'Ex. : Plan diététicien, Mon menu...';

  @override
  String get dietCustomNameRequired => 'Veuillez saisir le nom du régime.';

  @override
  String get dietCustomMealHint => 'Que prévoyez-vous pour ce repas ?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (optionnel)';

  @override
  String get dietCustomAtLeastOneMeal => 'Veuillez saisir au moins un repas.';

  @override
  String get dietCustomTemplatesTitle => 'Mes Plans Personnalisés';

  @override
  String get dietReadyTemplatesTitle => 'Modèles de Régime Prêts';

  @override
  String get donateTooltip => 'Soutenir / Faire un don';

  @override
  String get donateMenuLabel => 'Soutenir VisualCheckUp';

  @override
  String get donateMenuSubtitle =>
      'Un café, un repas ou un cadeau pour soutenir l\'application';

  @override
  String get donatePopupTitle => 'Soutenir VisualCheckUp';

  @override
  String get donatePopupSubtitle =>
      'Votre soutien volontaire nous aide à garder les outils santé, analyses, alarmes médicaments et régimes gratuits.';

  @override
  String get donateTierCoffeeTitle => 'Offrir un Café';

  @override
  String get donateTierCoffeeDesc => 'Un café chaud pour le développement';

  @override
  String get donateTierMealTitle => 'Offrir un Repas';

  @override
  String get donateTierMealDesc =>
      'Un beau soutien pour de nouvelles fonctions';

  @override
  String get donateTierGiftTitle => 'Envoyer un Cadeau';

  @override
  String get donateTierGiftDesc =>
      'Aide à couvrir les frais d\'IA et de serveur';

  @override
  String get donateTierGoldTitle => 'Grand Soutien';

  @override
  String get donateTierGoldDesc => 'Finance les prochains modules de santé';

  @override
  String get donateTierHeroTitle => 'Héros de la Santé';

  @override
  String get donateTierHeroDesc =>
      'Soutient le suivi santé gratuit pour toutes les familles';

  @override
  String get donatePopularBadge => 'Populaire';

  @override
  String donateConfirmButton(String price) {
    return 'Donner $price';
  }

  @override
  String get donateLaterButton => 'Plus Tard';

  @override
  String get donateThanksTitle => 'Merci pour votre soutien !';

  @override
  String donateThanksBody(String tier, String price) {
    return 'Votre soutien $tier ($price) compte énormément pour nous. Merci d\'aider VisualCheckUp à grandir !';
  }

  @override
  String get donateSupporterBadge => 'Donateur • Merci !';

  @override
  String get donateStoreNotice =>
      'Soutien ponctuel volontaire • Sans abonnement';

  @override
  String get medFieldAlarmSound => 'Sonnerie d\'alarme';

  @override
  String get medAlarmSoundClassic => 'Alarme classique';

  @override
  String get medAlarmSoundClassicDesc => 'Sonnerie nette de réveil';

  @override
  String get medAlarmSoundGentle => 'Mélodie douce';

  @override
  String get medAlarmSoundGentleDesc => 'Carillon calme et progressif';

  @override
  String get medAlarmSoundRadar => 'Alarme moderne';

  @override
  String get medAlarmSoundRadarDesc => 'Impulsion rythmée bien audible';

  @override
  String get medAlarmSoundBell => 'Cloche santé';

  @override
  String get medAlarmSoundBellDesc => 'Double sonnette classique lumineuse';

  @override
  String get medAlarmSoundUrgent => 'Alerte urgente forte';

  @override
  String get medAlarmSoundUrgentDesc =>
      'Tonalité puissante pour doses essentielles';

  @override
  String get medAlarmSoundSystem => 'Alarme du téléphone';

  @override
  String get medAlarmSoundSystemDesc =>
      'Utilise la sonnerie d\'alarme par défaut';

  @override
  String get medSoundPreviewPlay => 'Écouter';

  @override
  String get medSoundPreviewStop => 'Arrêter';

  @override
  String get medSoundSilent => 'Silencieux';

  @override
  String get medPreviewModeBadge => 'APERÇU';

  @override
  String get commMenuTitle => 'Communauté Santé';

  @override
  String get commHomeSubtitle =>
      'Partenaires bien-être mondiaux, mentions j\'aime et messagerie sûre';

  @override
  String get commTabDiscover => 'Découvrir';

  @override
  String get commTabMessages => 'Messages';

  @override
  String get commTabMyProfile => 'Mon Profil';

  @override
  String get commSafetyBanner =>
      'Entraide et motivation uniquement — jamais d\'avis médical. Vos analyses et photos privées ne sont jamais partagées.';

  @override
  String get commSearchHint => 'Rechercher par nom, ville ou objectif...';

  @override
  String get commFilterAllGoals => 'Tous les objectifs';

  @override
  String get commFilterAllCountries => 'Monde entier';

  @override
  String get commEmptyDiscover =>
      'Aucun profil santé ne correspond à vos filtres.';

  @override
  String get commGoalDiabetes => 'Diabète & Glycémie';

  @override
  String get commGoalBloodPressure => 'Tension & Cœur';

  @override
  String get commGoalWeightDiet => 'Poids & Alimentation';

  @override
  String get commGoalHealthyLiving => 'Vie Saine';

  @override
  String get commGoalHerbalWellness => 'Tisanes & Soin Naturel';

  @override
  String get commGoalParentingGrowth => 'Parents & Croissance';

  @override
  String get commGoalSkinCare => 'Peau & Soin Quotidien';

  @override
  String get commGoalFitnessWalk => 'Marche & Activité';

  @override
  String get commGoalSleepStress => 'Sommeil & Stress';

  @override
  String commLikesCount(int count) {
    return '$count J\'aime';
  }

  @override
  String get commLikeAction => 'Aimer le profil';

  @override
  String get commUnlikeAction => 'Aimé';

  @override
  String get commSendMessage => 'Envoyer un message';

  @override
  String get commMessagesDisabled =>
      'Ce membre a désactivé les messages directs.';

  @override
  String get commOptInTitle => 'Rejoindre la Communauté Santé';

  @override
  String get commOptInBody =>
      'Rencontrez des personnes partageant vos objectifs bien-être dans le monde. Inscription 100 % optionnelle — vos données médicales restent privées.';

  @override
  String get commOptInButton => 'Créer mon profil santé';

  @override
  String get commFieldDisplayName => 'Nom affiché';

  @override
  String get commFieldNickname => 'Pseudo (@handle)';

  @override
  String get commFieldCountry => 'Pays';

  @override
  String get commFieldCity => 'Ville (optionnel)';

  @override
  String get commFieldLanguage => 'Langue préférée';

  @override
  String get commFieldGoals => 'Objectifs santé & bien-être';

  @override
  String get commFieldBio => 'À propos & parcours santé';

  @override
  String get commFieldDailyFocus => 'Objectif bien-être du jour';

  @override
  String get commPrivacySection => 'Confidentialité & Messagerie';

  @override
  String get commToggleDiscoverable => 'Afficher mon profil dans Découvrir';

  @override
  String get commToggleHideRealName => 'Masquer le vrai nom (afficher @pseudo)';

  @override
  String get commToggleHidePhoto => 'Masquer ma photo';

  @override
  String get commToggleAllowMessages => 'Autoriser les messages directs';

  @override
  String get commToggleRequireApproval =>
      'Demander mon accord pour les nouvelles demandes';

  @override
  String get commUploadPhoto => 'Importer une photo';

  @override
  String get commRemovePhoto => 'Supprimer la photo';

  @override
  String get commSaveProfile => 'Enregistrer le profil';

  @override
  String get commProfileSaved => 'Profil communautaire mis à jour.';

  @override
  String get commLeaveCommunity => 'Quitter et supprimer le profil public';

  @override
  String get commLeftCommunity => 'Votre profil public a été supprimé.';

  @override
  String get commInboxEmpty =>
      'Aucune conversation. Découvrez des membres et dites bonjour !';

  @override
  String get commMessageRequestBadge => 'Demande';

  @override
  String get commRequestBannerTitle => 'Nouvelle demande de message';

  @override
  String get commRequestBannerBody =>
      'Acceptez pour discuter, ou refusez/bloquez ce membre.';

  @override
  String get commRequestAccept => 'Accepter';

  @override
  String get commRequestDecline => 'Refuser';

  @override
  String get commChatPlaceholder => 'Écrire un message bienveillant...';

  @override
  String get commAttachPhoto => 'Joindre une photo';

  @override
  String get commPhotoLabel => 'Photo';

  @override
  String get commRateLimited =>
      'Veuillez patienter quelques secondes avant d\'envoyer un autre message.';

  @override
  String get commBlockedNotice =>
      'Impossible d\'envoyer un message suite à un blocage.';

  @override
  String get commMuteChat => 'Mettre en sourdine';

  @override
  String get commUnmuteChat => 'Réactiver';

  @override
  String get commHideChat => 'Masquer';

  @override
  String get commBlockUser => 'Bloquer';

  @override
  String get commUnblockUser => 'Débloquer';

  @override
  String get commBlockedToast => 'Membre bloqué.';

  @override
  String get commReportUser => 'Signaler';

  @override
  String get commReportTitle => 'Signaler un membre ou message';

  @override
  String get commReportReasonInappropriate => 'Contenu inapproprié';

  @override
  String get commReportReasonSpam => 'Spam ou publicité';

  @override
  String get commReportReasonHarassment => 'Harcèlement ou discours haineux';

  @override
  String get commReportReasonMisinfo =>
      'Conseil médical dangereux / désinformation';

  @override
  String get commReportReasonOther => 'Autre';

  @override
  String get commReportNoteHint => 'Détails optionnels...';

  @override
  String get commReportSubmit => 'Envoyer le signalement';

  @override
  String get commReportSent => 'Merci. Votre signalement a été envoyé.';

  @override
  String get commDeleteForMe => 'Supprimer pour moi';

  @override
  String get commDeleteForEveryone => 'Supprimer pour tous';

  @override
  String get commOnlineNow => 'En ligne';

  @override
  String get commFilterOnlineOnly => 'En ligne';

  @override
  String get commFilterSameCondition => 'Même maladie';

  @override
  String get commFilterAllConditions => 'Toutes les maladies';

  @override
  String get commSameConditionPrompt =>
      'Ajoutez une maladie chronique dans Mon Profil pour trouver des membres similaires.';

  @override
  String get commFieldChronicConditions => 'Maladies chroniques (Optionnel)';

  @override
  String get commFieldCustomCondition => 'Autre maladie chronique (optionnel)';

  @override
  String get commFieldCustomConditionHint => 'Ex. : Fibromyalgie, SOPK...';

  @override
  String get commToggleShowConditions => 'Afficher mes maladies chroniques';

  @override
  String get commToggleShowOnline => 'Afficher mon statut en ligne';

  @override
  String get condType1Diabetes => 'Diabète Type 1';

  @override
  String get condType2Diabetes => 'Diabète Type 2';

  @override
  String get condHypertension => 'Hypertension';

  @override
  String get condAsthmaCopd => 'Asthme / BPCO';

  @override
  String get condThyroidHashimoto => 'Thyroïde / Hashimoto';

  @override
  String get condMigraine => 'Migraine';

  @override
  String get condHeartCondition => 'Cœur & Vaisseaux';

  @override
  String get condCeliacIbs => 'Cœliaque / SII';

  @override
  String get condArthritis => 'Arthrite / Rhumatisme';

  @override
  String get condAnemia => 'Anémie';

  @override
  String get condKidneyHealth => 'Santé Rénale';

  @override
  String get condEczemaPsoriasis => 'Eczéma / Psoriasis';

  @override
  String get adminPanelTitle => 'Panneau d\'Administration';

  @override
  String get adminTabStats => 'Statistiques';

  @override
  String get adminTabAnnouncements => 'Annonces';

  @override
  String get adminTabPromotions => 'Publicités';

  @override
  String get adminTabUsers => 'Utilisateurs';

  @override
  String get adminTabReports => 'Signalements';

  @override
  String get adminStatOnline => 'En ligne';

  @override
  String get adminStatMembers => 'Membres';

  @override
  String get adminStatLikes => 'J\'aime';

  @override
  String get adminStatChats => 'Discussions';

  @override
  String get adminStatPendingReports => 'Signalements en attente';

  @override
  String get adminStatActiveBanners => 'Bannières actives';

  @override
  String get adminConditionBreakdown => 'Répartition des maladies chroniques';

  @override
  String get adminNewAnnouncement => 'Nouvelle annonce';

  @override
  String get adminNewPromotion => 'Nouvelle bannière';

  @override
  String get adminFieldTitle => 'Titre';

  @override
  String get adminFieldMessage => 'Message / Description';

  @override
  String get adminFieldLink => 'Lien URL (optionnel)';

  @override
  String get adminFieldPlacement => 'Emplacement';

  @override
  String get adminPlacementHome => 'Haut Accueil';

  @override
  String get adminPlacementCommunity => 'Haut Communauté';

  @override
  String get adminPlacementProfile => 'Haut Profil';

  @override
  String get adminTypeInfo => 'Annonce';

  @override
  String get adminTypeHealthTip => 'Conseil Santé';

  @override
  String get adminTypeWarning => 'Alerte';

  @override
  String get adminTypeCampaign => 'Campagne';

  @override
  String get adminSearchUsersHint => 'Rechercher par nom, pays ou maladie...';

  @override
  String get adminActionVerify => 'Vérifier';

  @override
  String get adminActionUnverify => 'Retirer badge';

  @override
  String get adminActionSuspend => 'Suspendre';

  @override
  String get adminActionUnsuspend => 'Réactiver';

  @override
  String get adminStatusSuspended => 'Suspendu';

  @override
  String get adminStatusVerified => 'Vérifié';

  @override
  String get adminReportResolve => 'Résoudre';

  @override
  String get adminReportDismiss => 'Ignorer';

  @override
  String get adminNoReports => 'Aucun signalement.';

  @override
  String get adminNoAnnouncements => 'Aucune annonce.';

  @override
  String get adminNoPromotions => 'Aucune publicité.';

  @override
  String get commMusicSectionTitle => 'Musique de Concentration';

  @override
  String get commMusicTitleField => 'Nom du titre / playlist (facultatif)';

  @override
  String get commMusicUrlField => 'Lien musical (YouTube, Spotify, SoundCloud)';

  @override
  String get commMusicInvalidUrl =>
      'Veuillez saisir un lien YouTube, Spotify, Apple Music ou SoundCloud valide.';

  @override
  String get commMusicEmpty => 'Aucune musique de concentration ajoutée.';

  @override
  String get commMusicListenAction => 'Écouter';

  @override
  String get commMusicLikeAction => 'Aimer la musique';

  @override
  String get commMusicListenersTitle => 'Auditeurs';

  @override
  String get commMusicListenersEmpty => 'Personne n\'a encore écouté ce titre.';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count auditeurs';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '$count écoutes';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '${count}x';
  }

  @override
  String get commProfileLikersTitle => 'Mentions J\'aime du profil';

  @override
  String get commProfileLikersEmpty =>
      'Aucun J\'aime sur le profil pour le moment.';

  @override
  String get commSocialsSectionTitle => 'Réseaux Sociaux';

  @override
  String get commToggleShowSocials => 'Afficher mes réseaux sociaux';

  @override
  String get commSocialsHiddenHint => 'Masqué aux autres membres';

  @override
  String get commSocialsEmpty => 'Aucun réseau social ajouté.';

  @override
  String get commPreviewMyProfile => 'Aperçu de mon profil';
}
