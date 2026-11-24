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
}
