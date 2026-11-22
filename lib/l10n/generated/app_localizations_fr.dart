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
}
