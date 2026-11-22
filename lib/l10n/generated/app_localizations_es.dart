// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'Esta aplicación no ofrece un diagnóstico médico; es solo para información y autoconciencia visual.';

  @override
  String get disclaimerTitle => 'Aviso Médico Importante';

  @override
  String get disclaimerFull =>
      'VisualCheckUp ofrece una evaluación visual previa basada en señales de color y aspecto. No es un dispositivo médico ni sustituye una consulta médica o análisis de laboratorio.\n\n• La luz ambiental y el sensor de la cámara afectan la percepción del color.\n• Acuda a un médico de inmediato ante dolor intenso, sangrado, fiebre alta, ictericia, heces negras/blancas o dificultad para respirar.\n• Privacidad: las imágenes se procesan en su dispositivo por defecto.';

  @override
  String get disclaimerAccept => 'Entendido';

  @override
  String get loginTagline =>
      'Asistente personal para el seguimiento visual de la piel, lunares y preparación para consultas médicas.';

  @override
  String get featureColorCalibration => 'Calibración de Color';

  @override
  String get featurePrivacyFirst => 'Privacidad Primero';

  @override
  String get featureOptionalAi => 'IA Opcional';

  @override
  String get loginCardTitle => 'Continúa con tu cuenta';

  @override
  String get loginCardSubtitle =>
      'Mantén organizados tus valores de referencia y tu historial de controles.';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get orDivider => 'o';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get guestGreeting => 'Seguimiento Visual de Salud';

  @override
  String userGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return 'Cuenta de $provider';
  }

  @override
  String get localOnlyLabel => 'Guardado solo en este dispositivo';

  @override
  String get menuHome => 'Inicio';

  @override
  String get menuSectionVisualChecks => 'CONTROLES VISUALES';

  @override
  String get menuSkinGroup => 'Piel (Lunar, Verruga, Moretón)';

  @override
  String get menuSkinGeneral => 'Piel General y Erupciones';

  @override
  String get menuSectionTracking => 'SEGUIMIENTO, ANÁLISIS Y SIGNOS';

  @override
  String get menuFollowUpPlan => 'Plan de Seguimiento Personal';

  @override
  String get menuVitalsTracker => 'Presión Arterial y Glucosa';

  @override
  String get menuLabReports => 'Análisis e Informes Médicos';

  @override
  String get menuQuickColorCard => 'Carta de Color sin Cámara';

  @override
  String get menuHistory => 'Historial de Controles';

  @override
  String get menuReferenceGuide => 'Guía Visual de Referencia';

  @override
  String get menuSectionSettings => 'AJUSTES Y PRIVACIDAD';

  @override
  String get menuAiSettings => 'IA y Privacidad';

  @override
  String get menuDisclaimer => 'Aviso Médico';

  @override
  String get menuTheme => 'Tema de Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get menuLanguage => 'Idioma de la App';

  @override
  String get languageSystem => 'Idioma del Sistema';

  @override
  String get signInGoogleOrApple => 'Iniciar sesión con Google o Apple';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta y datos locales';

  @override
  String get deleteAccountBody =>
      'Se cerrará tu sesión y se eliminarán permanentemente tu historial y referencias de color en este dispositivo. ¿Continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get followUpCardTitle => 'Plan de Seguimiento Personal';

  @override
  String get followUpSelectEdit => 'Elegir / Editar';

  @override
  String get followUpStart => 'Iniciar';

  @override
  String get followUpEmptyHint =>
      'Toca para elegir controles de ojos, orina, presión arterial, glucosa y más.';

  @override
  String get followUpSheetSubtitle =>
      'Sigue ojos, lengua, uñas, piel, orina, heces, presión arterial, glucosa y análisis en un solo plan.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active activos • $completed al día • $due pendientes';
  }

  @override
  String get homeCategoriesTitle => 'Categorías de Control';

  @override
  String get homeCategoriesSubtitle =>
      'Registra cambios visuales con cámara o carta de color sin cámara.';

  @override
  String get homeLabsVitalsTitle => 'Análisis, Presión y Glucosa';

  @override
  String get homeLabsVitalsSubtitle =>
      'Lee informes de laboratorio y sigue tendencias de presión y glucosa.';

  @override
  String get homeLabsCardTitle => 'Análisis e Informes';

  @override
  String get homeLabsCardEmpty => 'Leer y revisar análisis';

  @override
  String homeLabsCardCount(int count) {
    return '$count informes guardados';
  }

  @override
  String get homeVitalsCardTitle => 'Presión y Glucosa';

  @override
  String get homeVitalsCardEmpty => 'Registrar y ver tendencias';

  @override
  String homeVitalsCardCount(int count) {
    return '$count registros guardados';
  }

  @override
  String get homeRecentChecks => 'Controles Recientes';

  @override
  String get seeAll => 'Ver Todo';

  @override
  String get catEyeTitle => 'Ojos (Esclera)';

  @override
  String get catEyeSubtitle => 'Enrojecimiento, tono amarillento y esclera';

  @override
  String get catNailTitle => 'Uñas';

  @override
  String get catNailSubtitle => 'Palidez, coloración azulada, amarilla y forma';

  @override
  String get catTongueTitle => 'Lengua';

  @override
  String get catTongueSubtitle => 'Color, capa blanca/amarilla y textura';

  @override
  String get catFaceTitle => 'Rostro y Piel';

  @override
  String get catFaceSubtitle => 'Tono de piel, palidez y enrojecimiento';

  @override
  String get catSkinTitle => 'Afecciones de la Piel';

  @override
  String get catSkinSubtitle =>
      'Lunares, verrugas, moretones, manchas y erupciones';

  @override
  String get catUrineTitle => 'Color de la Orina';

  @override
  String get catUrineSubtitle => 'Hidratación y escala de color';

  @override
  String get catStoolTitle => 'Color de las Heces';

  @override
  String get catStoolSubtitle => 'Digestión y señales de alerta';

  @override
  String get tooltipHistory => 'Historial';

  @override
  String get tooltipAccountMenu => 'Cuenta y Menú';

  @override
  String get menuSettings => 'Ajustes (Permisos e Idioma)';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguageDesc =>
      'Por defecto se usa el idioma del teléfono. Puedes elegir otro idioma abajo.';

  @override
  String get settingsPermissionsTitle => 'Permisos de la App';

  @override
  String get settingsPermissionsDesc =>
      'Consulta y gestiona los permisos de cámara y galería aquí.';

  @override
  String get settingsCameraPermission => 'Permiso de Cámara';

  @override
  String get settingsCameraPermissionDesc =>
      'Para capturas de ojos, lengua, uñas y piel';

  @override
  String get settingsPhotosPermission => 'Permiso de Galería y Fotos';

  @override
  String get settingsPhotosPermissionDesc =>
      'Para subir fotos e informes de laboratorio';

  @override
  String get settingsOpenSystemPermissions => 'Abrir Permisos del Teléfono';

  @override
  String get permChecking => 'Comprobando...';

  @override
  String get permGranted => 'Concedido';

  @override
  String get permDenied => 'Permiso Necesario';

  @override
  String get permPermanent => 'Activar en Ajustes del Sistema';

  @override
  String get permUnavailable => 'Gestionado por el Dispositivo';

  @override
  String get permGrantBtn => 'Permitir';

  @override
  String get permOpenSettingsBtn => 'Abrir Ajustes';

  @override
  String get skinCancerRisk => 'Riesgo de Lunar y Piel';

  @override
  String get skinWart => 'Pre-control de Verruga';

  @override
  String get skinBruise => 'Seguimiento de Moretón';

  @override
  String get skinFacialSpot => 'Mancha Facial';

  @override
  String get trackEyeTitle => 'Control Semanal de Ojos';

  @override
  String get trackEyeSubtitle => 'Observa enrojecimiento o tono amarillento';

  @override
  String get trackTongueTitle => 'Control Semanal de Lengua';

  @override
  String get trackTongueSubtitle =>
      'Sigue el color, saburra y textura de la lengua';

  @override
  String get trackNailTitle => 'Control Semanal de Uñas';

  @override
  String get trackNailSubtitle => 'Vigila palidez, tono azulado o amarillo';

  @override
  String get trackFaceTitle => 'Tono Facial Quincenal';

  @override
  String get trackFaceSubtitle =>
      'Compara palidez, enrojecimiento y tono facial';

  @override
  String get trackSkinTitle => 'Control Mensual de Piel y Lunares';

  @override
  String get trackSkinSubtitle =>
      'Compara cambios en lunares, verrugas y manchas cada 30 días';

  @override
  String get trackHydrationTitle => 'Hidratación Diaria (Orina)';

  @override
  String get trackHydrationSubtitle =>
      'Registra tu hidratación en 2 s con carta de color';

  @override
  String get trackStoolTitle => 'Control Semanal de Heces';

  @override
  String get trackStoolSubtitle => 'Sigue la digestión y señales de alerta';

  @override
  String get trackBpTitle => 'Presión Arterial Diaria';

  @override
  String get trackBpSubtitle => 'Registra presión sistólica/diastólica y pulso';

  @override
  String get trackSugarTitle => 'Glucosa en Sangre Diaria';

  @override
  String get trackSugarSubtitle => 'Registra glucosa en ayunas o posprandial';

  @override
  String get trackLabTitle => 'Análisis de Sangre Trimestral';

  @override
  String get trackLabSubtitle => 'Sube informes médicos y compara tendencias';

  @override
  String get statusFirstPending => 'Esperando primer registro';

  @override
  String get statusDueNow => 'Hora de revisar';

  @override
  String get statusDoneToday => 'Completado hoy';

  @override
  String statusNextDays(int days) {
    return 'Próximo control en $days días';
  }

  @override
  String get actionCheckNow => 'Revisar Ahora';

  @override
  String get actionLogReading => 'Registrar';

  @override
  String get actionAddReport => 'Añadir Informe';

  @override
  String checkMethodTitle(String category) {
    return '$category • Método de Control';
  }

  @override
  String get checkMethodSubtitle =>
      'Elige en 2 segundos desde la carta de color sin foto o usa la cámara.';

  @override
  String get colorCardRecommendedTitle =>
      'Carta de Color sin Cámara (Recomendado)';

  @override
  String get colorCardRecommendedSubtitle =>
      'Registro privado y rápido sin foto (2 s)';

  @override
  String get cameraMeasureTitle => 'Medición con Cámara';

  @override
  String get cameraMeasureSubtitle =>
      'Medición automática con balance de blancos';

  @override
  String get referenceGuideSubtitle =>
      'Elige un módulo para ver referencias saludables y de alerta.';

  @override
  String get historyEmpty => 'Aún no hay controles guardados.';

  @override
  String get filterAll => 'Todos';

  @override
  String get aiSettingsTitle => 'IA y Privacidad';

  @override
  String get vitalsBpTab => 'Presión Arterial';

  @override
  String get vitalsSugarTab => 'Glucosa';

  @override
  String get skinScreenTitle => 'Pre-control de Afecciones Cutáneas';
}
