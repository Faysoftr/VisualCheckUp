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

  @override
  String get providerGuest => 'Invitado';

  @override
  String signInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get riskNormal => 'Aspecto normal';

  @override
  String get riskAttention => 'Seguimiento sugerido';

  @override
  String get riskUrgent => 'Se recomienda evaluación médica';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'Último: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'Último: $count valores ($abnormal fuera de rango)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Último: $count valores (todos normales)';
  }

  @override
  String get labStatusCriticalLow => 'Crítico bajo';

  @override
  String get labStatusLow => 'Bajo';

  @override
  String get labStatusNormal => 'Normal';

  @override
  String get labStatusHigh => 'Alto';

  @override
  String get labStatusCriticalHigh => 'Crítico alto';

  @override
  String get labSourceManual => 'Entrada manual';

  @override
  String get labSourcePasted => 'Leído del texto';

  @override
  String get labSourcePhoto => 'Informe JPG / Foto';

  @override
  String get labSourcePdf => 'Informe PDF';

  @override
  String get bpLow => 'Presión baja';

  @override
  String get bpNormal => 'Rango normal';

  @override
  String get bpElevated => 'Elevada';

  @override
  String get bpStage1 => 'Hipertensión grado 1';

  @override
  String get bpStage2 => 'Hipertensión grado 2';

  @override
  String get bpCrisis => 'Crisis hipertensiva';

  @override
  String get sugarLow => 'Glucosa baja';

  @override
  String get sugarNormal => 'Rango normal';

  @override
  String get sugarBorderline => 'En el límite';

  @override
  String get sugarHigh => 'Glucosa alta';

  @override
  String get sugarVeryHigh => 'Glucosa muy alta';

  @override
  String get sugarTypeFasting => 'En ayunas';

  @override
  String get sugarTypePostMeal => 'Posprandial (2h)';

  @override
  String get sugarTypeRandom => 'Aleatorio';

  @override
  String get specialtyEye => 'Oftalmología o Medicina Interna';

  @override
  String get specialtyNail => 'Dermatología o Medicina Interna';

  @override
  String get specialtyTongue => 'ORL, Salud Bucal o Medicina Interna';

  @override
  String get specialtySkin => 'Dermatología';

  @override
  String get specialtyUrine => 'Urología o Medicina Interna';

  @override
  String get specialtyStool => 'Gastroenterología o Medicina Interna';

  @override
  String get cloudBackupTitle => 'Copia en la nube (Opcional • Firebase)';

  @override
  String get cloudBackupDesc =>
      'Por defecto, todos tus análisis y mediciones se guardan solo en este dispositivo. Activa la copia privada en tu cuenta Google/Apple si deseas conservarlos al cambiar de teléfono.';

  @override
  String get cloudBackupToggleTitle => 'Activar copia en la nube';

  @override
  String cloudBackupLastSync(String date) {
    return 'Última copia: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Activo • Listo para sincronizar';

  @override
  String get cloudBackupDisabledLocal =>
      'Desactivado • Solo almacenamiento local';

  @override
  String get cloudBackupSignInRequired =>
      'Inicia sesión con Google o Apple para usar la copia en la nube.';

  @override
  String get cloudBackupNowBtn => 'Respaldar ahora';

  @override
  String get cloudRestoreBtn => 'Restaurar de la nube';

  @override
  String get cloudConsentTitle => 'Consentimiento de copia en la nube';

  @override
  String get cloudConsentBody =>
      'Tus análisis, mediciones y chequeos se guardan solo en este dispositivo por defecto.\n\nSi activas la copia en la nube, se guardarán de forma privada en tu cuenta Google/Apple y se eliminarán por completo al borrar tu cuenta.\n\n¿Aceptas?';

  @override
  String get cloudConsentConfirm => 'Sí, activar';

  @override
  String cloudBackupSuccess(int count) {
    return 'Copia completada: $count registros sincronizados.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Error en la copia: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Restaurado de la nube: $count registros importados.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Copia en la nube desactivada. Los nuevos registros quedan solo en este dispositivo.';

  @override
  String get aiCloudToggleTitle => 'Análisis con IA en la nube (Gemini)';

  @override
  String get aiCloudOnDesc =>
      'Activado: Las fotos nítidas se redimensionan y analizan de forma segura. Sin conexión usa análisis local.';

  @override
  String get aiCloudOffDesc =>
      'Desactivado (0 tokens): Todo el análisis se hace en tu dispositivo; no se envía ninguna foto.';

  @override
  String get aiBackendOfflineNote =>
      'Cuando se configure la clave de Gemini / Firebase AI, el análisis en la nube se activará según esta opción; el motor local está activo.';

  @override
  String get aiOptimizationsTitle =>
      'Controles activos de ahorro de tokens y datos';

  @override
  String get aiOptQualityGate =>
      'Filtro de calidad sin tokens (desenfoque, luz y brillo)';

  @override
  String get aiOptCompression =>
      'Recorte automático + compresión JPEG 512px/768px (80%)';

  @override
  String get aiOptTieredModel =>
      'Selección inteligente de modelo (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'Caché local para fotos repetidas (0 tokens)';

  @override
  String get aiClearCacheBtn => 'Limpiar caché de IA';

  @override
  String get aiCacheCleared => 'Caché de IA borrada.';

  @override
  String resultScreenTitle(String category) {
    return 'Resultado de $category';
  }

  @override
  String get tooltipDoctorSummary => 'Resumen para el médico';

  @override
  String get tooltipReferenceGuide => 'Guía de referencia';

  @override
  String get calibratedColorTone => 'Tono de color calibrado';

  @override
  String get sampledColorTone => 'Tono dominante medido';

  @override
  String confidenceLabel(int percent) {
    return 'Confianza preliminar: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote =>
      'Color equilibrado con referencia blanca.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Especialidad sugerida: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Comparación en el tiempo';

  @override
  String get todayLabel => 'Hoy';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Registro previo: \"$title\" ($status). $count registros en seguimiento.';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'Comparación con tu base personal';

  @override
  String get yourBaselineLabel => 'Tu base';

  @override
  String get warningFlagsTitle => 'Signos de alerta';

  @override
  String get observationsTitle => 'Observaciones';

  @override
  String get recommendationsTitle => 'Recomendaciones';

  @override
  String get personalBaselineCardTitle => 'Calibración de base personal';

  @override
  String get personalBaselineCardDesc =>
      'Guarda esta medición en un día saludable como tu referencia personal para reducir variaciones de cámara.';

  @override
  String get saveBaselineBtn => 'Guardar como mi base';

  @override
  String get updateBaselineBtn => 'Actualizar mi base';

  @override
  String get clearBaselineBtn => 'Eliminar';

  @override
  String baselineSavedMsg(String category) {
    return 'Base personal guardada para $category.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'Base personal eliminada para $category.';
  }

  @override
  String get doctorSummaryBtn => 'Mostrar al médico • Preparar resumen';

  @override
  String get returnHomeBtn => 'Volver al inicio';

  @override
  String get doctorSheetTitle => 'Resumen para la consulta médica';

  @override
  String colorLabel(String hex, String status) {
    return 'Color: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Historial cronológico';

  @override
  String get questionsForDoctorTitle => 'Preguntas para tu médico';

  @override
  String get copyShareSummaryBtn => 'Copiar y compartir resumen';

  @override
  String get doctorSummaryCopied => 'Resumen médico copiado al portapapeles.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Referencias visuales';
  }

  @override
  String get healthyReferenceLabel => 'Referencia saludable';

  @override
  String get captureChecklistTitle => 'Consejos de captura';

  @override
  String get abnormalFindingsTitle => 'Hallazgos visuales de atención';

  @override
  String get cameraPermPermanentMsg =>
      'El permiso de cámara está desactivado en ajustes. Actívalo o elige una foto de la galería.';

  @override
  String get cameraPermRequiredMsg =>
      'Se necesita permiso de cámara para el chequeo visual. Las imágenes se procesan localmente.';

  @override
  String get cameraGrantPermTitle => 'Acceso a la cámara';

  @override
  String get cameraRequestPermBtn => 'Permitir cámara';

  @override
  String get cameraPickGalleryBtn => 'Elegir de galería';

  @override
  String get cameraWhiteRefOn => 'Referencia blanca: Activa';

  @override
  String get cameraWhiteRefOff => 'Referencia blanca: Inactiva';

  @override
  String get cameraBaselineActive => 'Base guardada';

  @override
  String get cameraAnalyzing => 'Analizando...';

  @override
  String get cameraCaptureBtn => 'Capturar y analizar';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Error en el análisis: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Carta de color';
  }

  @override
  String get quickCardPrivacyBanner =>
      'Sin cámara: elige el tono más parecido para un registro privado en 2 segundos.';

  @override
  String get quickCardChooseShade => 'Elige el tono más parecido';

  @override
  String get quickCardExtraContext => 'Contexto adicional (Opcional)';

  @override
  String get quickCardSaveViewBtn => 'Guardar y ver evaluación';

  @override
  String get quickCardUseCameraBtn => 'Usar cámara en su lugar';

  @override
  String get skinIntroTitle => 'Pre-evaluación dermatológica visual';

  @override
  String get skinIntroDesc =>
      'Compara lunares, verrugas, moretones y manchas faciales con la piel circundante. No es un diagnóstico; ayuda a preparar la consulta.';

  @override
  String get skinStep1Title => '1. Selecciona un módulo dermatológico';

  @override
  String get skinOtherConcernsLabel => 'Otras presentaciones';

  @override
  String get skinStep2Title => '2. Síntomas acompañantes (Opcional)';

  @override
  String get skinStep3Title => '3. Zona del cuerpo (Opcional)';

  @override
  String get skinStartCameraBtn => 'Iniciar chequeo de piel con cámara';

  @override
  String get skinConcernRash => 'Enrojecimiento / Sarpullido';

  @override
  String get skinConcernMole => 'Lunar / Mancha oscura';

  @override
  String get skinConcernScaly => 'Placa seca / escamosa';

  @override
  String get skinConcernBlister => 'Ampolla / Acné';

  @override
  String get skinConcernGeneral => 'Chequeo general de piel';

  @override
  String get bodyAreaFaceNeck => 'Cara / Cuello';

  @override
  String get bodyAreaArmHand => 'Brazo / Mano';

  @override
  String get bodyAreaTorso => 'Torso';

  @override
  String get bodyAreaLegFoot => 'Pierna / Pie';

  @override
  String get bodyAreaScalp => 'Cuero cabelludo';

  @override
  String get bodyAreaOther => 'Otro';

  @override
  String get symptomItching => 'Picazón';

  @override
  String get symptomPainWarmth => 'Dolor / Calor';

  @override
  String get symptomRapidChange => 'Crecimiento rápido / cambio';

  @override
  String get symptomBleeding => 'Sangrado / Secreción';

  @override
  String get symptomSpreading => 'Se extiende rápido';

  @override
  String get symptomFever => 'Con fiebre';

  @override
  String get symptomNonHealing => 'Herida que no sana (4+ sem.)';

  @override
  String get symptomOver6mm => 'Más de 6 mm o borde irregular';

  @override
  String get symptomNoTrauma => 'Apareció sin golpe';

  @override
  String get symptomRoughDots => 'Superficie áspera / puntos negros';

  @override
  String get symptomSunHormone => 'Mancha solar, hormonal o post-acné';

  @override
  String get bruiseGuideTitle => 'Guía de etapas del moretón';

  @override
  String get wartGuideTitle => 'Guía de seguridad para verrugas';

  @override
  String get abcdeGuideTitle => 'Guía ABCDE para lunares';

  @override
  String get abcdeGuideSubtitle => '5 signos clave que usan los dermatólogos';

  @override
  String get labScreenTitle => 'Análisis e informes';

  @override
  String get labTabReports => 'Mis informes';

  @override
  String get labTabTrends => 'Tendencias';

  @override
  String get labAddBtn => 'Añadir informe / análisis';

  @override
  String get labEmptyTitle => 'Aún no hay análisis guardados';

  @override
  String get labEmptyDesc =>
      'Sube tu análisis en PDF o JPG; opcionalmente añade el diagnóstico o tus síntomas para un resumen claro.';

  @override
  String get labAddFirstBtn => 'Añadir primer informe';

  @override
  String get labTrendsEmptyDesc =>
      'Guarda análisis en distintas fechas para ver gráficos de evolución de Hemoglobina, Ferritina, Glucosa, TSH y más.';

  @override
  String labParamsCount(int count) {
    return '$count parámetros';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count fuera de rango';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Evaluación de parámetros ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Diagnóstico médico';

  @override
  String get labEnteredComplaintTitle => 'Tu síntoma / nota';

  @override
  String get labInterpretationTitle => 'Interpretación clara';

  @override
  String get labCopyDoctorSummaryBtn => 'Mostrar al médico • Copiar';

  @override
  String get labSummaryCopied => 'Resumen de análisis copiado.';

  @override
  String get labExportPdfBtn => 'Exportar PDF para el médico';

  @override
  String get labAddSheetTitle => 'Añadir informe / análisis';

  @override
  String get labReportTitleField => 'Título del informe';

  @override
  String get labDefaultReportTitle => 'Resultado de análisis';

  @override
  String get labStep1Upload => '1. Subir informe PDF o JPG';

  @override
  String get labUploadPdfJpgBtn => 'Subir PDF o JPG';

  @override
  String get labCameraCaptureBtn => 'Tomar foto';

  @override
  String get labStep2Context => '2. Diagnóstico y nota (Opcional)';

  @override
  String get labStep2ContextHint =>
      'Escribe el diagnóstico que deseas entender o tus síntomas; puedes dejar ambos vacíos.';

  @override
  String get labDiagnosisField => 'Diagnóstico médico (Opcional)';

  @override
  String get labComplaintField => 'Tus síntomas / pregunta (Opcional)';

  @override
  String get labStep3PasteManual =>
      '3. Pegar texto del informe o añadir valores';

  @override
  String get labParseTextBtn => 'Leer y analizar texto';

  @override
  String get labParamDropdown => 'Parámetro';

  @override
  String labValueField(String unit) {
    return 'Valor ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Añadir';

  @override
  String labParsedValuesTitle(int count) {
    return 'Valores leídos ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Evaluar y guardar';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count registros • Cambio: $delta • Último: $status';
  }

  @override
  String get vitalsScreenTitle => 'Presión y Glucosa';

  @override
  String get vitalsCopySummaryTooltip => 'Copiar resumen médico';

  @override
  String get vitalsCopyEmptyMsg =>
      'Añade primero una lectura de presión o glucosa.';

  @override
  String get vitalsSummaryCopied => 'Resumen de presión y glucosa copiado.';

  @override
  String get vitalsAddBpBtn => 'Añadir presión';

  @override
  String get vitalsAddSugarBtn => 'Añadir glucosa';

  @override
  String get vitalsBpEmptyTitle => 'Sin lecturas de presión aún';

  @override
  String get vitalsBpEmptyDesc =>
      'Registra tu presión sistólica, diastólica y pulso para seguir el gráfico.';

  @override
  String get vitalsBpAddFirstBtn => 'Añadir primera presión';

  @override
  String get vitalsSugarEmptyTitle => 'Sin lecturas de glucosa aún';

  @override
  String get vitalsSugarEmptyDesc =>
      'Registra glucosa en ayunas, posprandial (2h) o aleatoria para ver la tendencia.';

  @override
  String get vitalsSugarAddFirstBtn => 'Añadir primera glucosa';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Promedio ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Pulso $pulse lpm';
  }

  @override
  String get vitalsBpHistoryTitle => 'Historial de presión';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Promedio ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'Historial de glucosa';

  @override
  String get vitalsNewBpTitle => 'Nueva lectura de presión';

  @override
  String get vitalsSystolicField => 'Sistólica (Alta)';

  @override
  String get vitalsDiastolicField => 'Diastólica (Baja)';

  @override
  String get vitalsPulseField => 'Pulso (lpm — Opcional)';

  @override
  String get vitalsNoteField => 'Nota (Opcional)';

  @override
  String get vitalsSaveBpBtn => 'Guardar presión';

  @override
  String get vitalsNewSugarTitle => 'Nueva lectura de glucosa';

  @override
  String get vitalsSugarValueField => 'Glucosa (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'Guardar glucosa';

  @override
  String get chartAddReadingHint => 'Añade lecturas para ver el gráfico';

  @override
  String get loginTermsTitle => 'Términos de uso y aviso médico';

  @override
  String get loginTermsCheckbox =>
      'Entiendo que VisualCheckUp no ofrece un diagnóstico médico definitivo, es solo orientativo y acepto los Términos de uso.';

  @override
  String get loginTermsRequiredMsg =>
      'Debes aceptar los Términos de uso y el aviso médico antes de iniciar sesión.';

  @override
  String get loginTermsReadMore => 'Leer términos';

  @override
  String get loginTermsModalBody =>
      '• Sin diagnóstico médico: VisualCheckUp no es un dispositivo médico ni sustituye la evaluación o tratamiento de un profesional de la salud.\n\n• Solo orientación: Los controles visuales, resúmenes de análisis y escalas de IMC/crecimiento sirven únicamente para seguimiento personal y consulta médica.\n\n• Emergencias: Ante dolor intenso, dolor de pecho, falta de aire o síntomas urgentes, acude de inmediato a urgencias.\n\n• Privacidad: Tus datos se guardan de forma predeterminada solo en tu dispositivo.';

  @override
  String get loginTermsAcceptBtn => 'He leído y acepto';

  @override
  String atlasFilterAll(int count) {
    return 'Atlas Ilustrado ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Signos Urgentes ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Pruebas Clínicas en Casa ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Signos que Requieren Evaluación Médica Pronta';

  @override
  String get atlasTapToCompareHint =>
      'Toca cualquier tarjeta para ampliarla junto a la referencia saludable.';

  @override
  String get atlasVisualCueLabel => 'Signo Visual';

  @override
  String get atlasClinicalContextLabel => 'Posible Contexto Clínico';

  @override
  String get atlasPossibleContextShort => 'Contexto Posible';

  @override
  String get atlasWarningPrefix => 'Advertencia';

  @override
  String get atlasCloseBtn => 'Cerrar';

  @override
  String get atlasCaptureProtocolTitle => 'Protocolo Óptimo de Captura';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Pruebas Clínicas de Pre-Evaluación en Casa';

  @override
  String get atlasSelfTestNormalPrefix => 'Normal';

  @override
  String get atlasSelfTestWarningPrefix => 'Atención';

  @override
  String get fitzpatrickScaleTitle =>
      'Fototipos de Piel Fitzpatrick y Escala ITA°';

  @override
  String get fitzpatrickScaleSubtitle =>
      'La app mide el ángulo ITA° de la piel sana circundante para equilibrar los umbrales según tu fototipo.';

  @override
  String get resultVisualCompareTitle =>
      'Comparación con Referencia Clínica Ilustrada';

  @override
  String get resultHealthyShort => 'Saludable';

  @override
  String get resultMatchedShort => 'Coincide';

  @override
  String get resultViewFullAtlasBtn => 'Ver Atlas Ilustrado Completo';

  @override
  String get resultHomeSelfTestsBtn => 'Pruebas Clínicas en Casa';

  @override
  String get resultClinicalBiomarkersTitle =>
      'Mediciones Clínicas Cuantitativas';

  @override
  String get cameraEyeModeSclera => 'Modo: Esclera (Ictericia)';

  @override
  String get cameraEyeModeConjunctiva => 'Párpado Inferior (Anemia)';

  @override
  String get cameraClinicalAtlasChip => 'Pruebas y Atlas';

  @override
  String get bristolScaleTitle =>
      'Escala de Heces de Bristol (Opcional • Tipos 1–7)';

  @override
  String get bristolType1Title => 'Tipo 1 • Bolitas duras';

  @override
  String get bristolType2Title => 'Tipo 2 • Salchicha grumosa';

  @override
  String get bristolType3Title => 'Tipo 3 • Con grietas';

  @override
  String get bristolType4Title => 'Tipo 4 • Suave (Ideal)';

  @override
  String get bristolType5Title => 'Tipo 5 • Trozos blandos';

  @override
  String get bristolType6Title => 'Tipo 6 • Pastosa / Blanda';

  @override
  String get bristolType7Title => 'Tipo 7 • Totalmente líquida';

  @override
  String get metricFitzpatrickPhototype => 'Fototipo Fitzpatrick';

  @override
  String get metricAbcdeAsymmetry => 'A — Asimetría';

  @override
  String get metricAbcdeBorder => 'B — Irregularidad del Borde';

  @override
  String get metricAbcdeColors => 'C — Colores Dermatoscópicos';

  @override
  String get metricErythemaDelta => 'Índice de Eritema Δ';

  @override
  String get metricAnnularClearing => 'Aclaramiento Central Anular';

  @override
  String get metricErythemaIndex => 'Índice de Eritema (EI)';

  @override
  String get metricScleraBilirubin => 'Índice de Bilirrubina Escleral';

  @override
  String get metricHemorrhagePatch => 'Área de Hemorragia Compacta';

  @override
  String get metricNailErythema => 'Índice de Eritema Ungueal';

  @override
  String get metricBeauGroove => 'Surco Transversal de Beau';

  @override
  String get metricTerryLindsaySplit => 'División Proximal/Distal';

  @override
  String get metricSplinterStreak => 'Proporción de Hemorragia en Astilla';

  @override
  String get metricGeographicTongue => 'Puntuación Lengua Geográfica';

  @override
  String get metricYellowCoating => 'Proporción de Capa Amarilla';

  @override
  String get metricBristolScale => 'Escala de Bristol';

  @override
  String get hubStartNewScan => 'Iniciar Nuevo Escaneo';

  @override
  String get hubPickFromGallery => 'Galería';

  @override
  String hubPastScansTitle(int count) {
    return 'Escaneos Anteriores ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Total Escaneos';

  @override
  String get hubLastScanLabel => 'Último Escaneo';

  @override
  String get hubLatestStatusLabel => 'Último Estado';

  @override
  String get hubFilterAll => 'Todos';

  @override
  String get hubFilterAttention => 'Atención / Urgente';

  @override
  String get hubFilterWithPhoto => 'Con Foto';

  @override
  String get hubColPhoto => 'Foto';

  @override
  String get hubColDate => 'Fecha';

  @override
  String get hubColFinding => 'Hallazgo y Resumen';

  @override
  String get hubColStatus => 'Estado';

  @override
  String get hubCompareModeBtn => 'Comparar 2 Escaneos';

  @override
  String hubCompareSelectHint(int count) {
    return 'Selecciona 2 escaneos de la tabla para compararlos lado a lado ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Comparar Lado a Lado';

  @override
  String get hubCompareCancelBtn => 'Cancelar';

  @override
  String get hubCompareSheetTitle => 'Comparación de Escaneos Lado a Lado';

  @override
  String get hubCompareOlderLabel => 'Anterior';

  @override
  String get hubCompareNewerLabel => 'Posterior';

  @override
  String get hubCompareMetricsTitle => 'Comparación de Métricas Clínicas';

  @override
  String hubEmptyTitle(String category) {
    return 'Aún no hay escaneos de $category';
  }

  @override
  String get hubEmptySubtitle =>
      'Inicia tu primer escaneo arriba. Cada revisión se guarda aquí cronológicamente con su miniatura y reporte detallado.';

  @override
  String get hubDoctorSummaryBtn => 'Resumen Médico';

  @override
  String get photoTapToZoomHint =>
      'Toca la foto para ampliar a pantalla completa';

  @override
  String get photoZoomTitle => 'Foto Capturada';

  @override
  String get resultDeleteRecordTooltip => 'Eliminar Registro';

  @override
  String get resultDeleteConfirmTitle => '¿Eliminar este escaneo?';

  @override
  String get resultDeleteConfirmBody =>
      'Este registro se eliminará permanentemente de tu historial local.';

  @override
  String get resultDeleteBtn => 'Eliminar';

  @override
  String get labLargeTextBtn => 'Texto Grande';

  @override
  String get labLargeTextOnBtn => 'Texto Grande: Sí';

  @override
  String get labSeniorOverviewTitle => 'Tu Resumen en Pocas Palabras';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count resultado(s) están dentro del rango normal.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count resultado(s) están fuera de rango — explicados de forma sencilla abajo.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count resultado(s) están notablemente fuera de límite — muéstralos pronto a tu médico.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count pruebas básicas comunes no aparecen en este informe.';
  }

  @override
  String get labAttentionSectionTitle => 'Valores a los que Prestar Atención';

  @override
  String get labNormalSectionTitle => 'Valores Normales (Buenas Noticias)';

  @override
  String get labMissingSectionTitle => 'Pruebas No Incluidas en Este Informe';

  @override
  String get labMissingSectionExplain =>
      'No todos los análisis piden todas las pruebas. Las pruebas básicas siguientes no figuran en este informe, por lo que no se evaluaron.';

  @override
  String get labNotInReportBadge => 'No figura en el informe';

  @override
  String get labWhatItMeansLabel => '¿Qué significa?';

  @override
  String get labWhatToDoLabel => '¿Qué puedes hacer?';

  @override
  String get labAddAnotherPageBtn => 'Escanear Otra Página';

  @override
  String labPagesReadBadge(int count) {
    return '$count página(s) leída(s)';
  }

  @override
  String get labPhotoOfflineHint =>
      'Foto del informe adjunta. Activa la IA en la Nube en Ajustes para leer fotos automáticamente o ingresa los valores manualmente abajo.';

  @override
  String get labAllValuesNormalMsg =>
      'Todos los valores registrados en este informe están dentro del rango normal.';

  @override
  String get medTitle => 'Recordatorio y Alarmas de Medicación';

  @override
  String get medSubtitle => 'Controla pastillas, insulina y alarmas con foto';

  @override
  String get medMenuTitle => 'Alarmas de Medicación';

  @override
  String get medHomeCardEmpty =>
      'Sin alarmas aún — añade tu primer recordatorio';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return '$taken/$total tomadas hoy';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count alarmas activas';
  }

  @override
  String get medTabToday => 'Hoy';

  @override
  String get medTabAll => 'Todas las Alarmas';

  @override
  String get medAddAlarm => 'Nueva Alarma';

  @override
  String get medEditAlarm => 'Editar Alarma';

  @override
  String get medCatPill => 'Medicamento / Pastilla';

  @override
  String get medCatDiabetes => 'Diabetes / Insulina';

  @override
  String get medCatBloodPressure => 'Presión Arterial';

  @override
  String get medCatVitamin => 'Vitamina / Suplemento';

  @override
  String get medCatDropsCream => 'Gotas / Crema';

  @override
  String get medCatCheckup => 'Medición / Control';

  @override
  String get medCatOther => 'Otro';

  @override
  String get medMealAnytime => 'Cualquier momento';

  @override
  String get medMealBefore => 'Antes de comer';

  @override
  String get medMealAfter => 'Después de comer';

  @override
  String get medMealWith => 'Con la comida';

  @override
  String get medMealBedtime => 'Antes de dormir';

  @override
  String get medDayMon => 'Lun';

  @override
  String get medDayTue => 'Mar';

  @override
  String get medDayWed => 'Mié';

  @override
  String get medDayThu => 'Jue';

  @override
  String get medDayFri => 'Vie';

  @override
  String get medDaySat => 'Sáb';

  @override
  String get medDaySun => 'Dom';

  @override
  String get medEveryDay => 'Todos los días';

  @override
  String get medWeekdays => 'Entre semana';

  @override
  String get medWeekends => 'Fines de semana';

  @override
  String get medFieldCategory => 'Categoría';

  @override
  String get medFieldName => 'Nombre del medicamento / recordatorio';

  @override
  String get medFieldNameHint =>
      'Ej.: Metformina 1000 mg, Insulina nocturna...';

  @override
  String get medFieldNameRequired =>
      'Por favor escribe el nombre del medicamento.';

  @override
  String get medFieldDosage => 'Dosis / Cantidad (Opcional)';

  @override
  String get medFieldDosageHint => 'Ej.: 1 comprimido, 12 unidades, 2 gotas';

  @override
  String get medFieldDescription =>
      'Nota del recordatorio (Se ve en la alarma)';

  @override
  String get medFieldDescriptionHint =>
      'Ej.: Tomar 30 min antes del desayuno con agua';

  @override
  String get medFieldMealTiming => 'Horario con comidas';

  @override
  String get medFieldTime => 'Hora de la alarma';

  @override
  String get medFieldDays => 'Días de repetición';

  @override
  String get medFieldPhoto => 'Foto del medicamento (Visible al sonar)';

  @override
  String get medTakePhoto => 'Tomar Foto';

  @override
  String get medPickGallery => 'Galería';

  @override
  String get medRemovePhoto => 'Quitar Foto';

  @override
  String get medPhotoHint =>
      'Fotografía la caja o pluma de insulina para verla claramente cuando suene la alarma.';

  @override
  String get medSoundToggle => 'Sonido de alarma';

  @override
  String get medVibrateToggle => 'Vibración';

  @override
  String get medSaveAlarm => 'Guardar Alarma';

  @override
  String get medAlarmSaved => 'Alarma guardada y programada.';

  @override
  String get medAlarmDeleted => 'Alarma eliminada.';

  @override
  String get medDeleteConfirmTitle => 'Eliminar Alarma';

  @override
  String medDeleteConfirmBody(String title) {
    return '¿Eliminar permanentemente la alarma \"$title\"?';
  }

  @override
  String get medStatusTaken => 'Tomada';

  @override
  String get medStatusSnoozed => 'Pospuesta';

  @override
  String get medStatusSkipped => 'Omitida';

  @override
  String get medStatusPending => 'Pendiente';

  @override
  String get medActionTaken => 'Ya la tomé';

  @override
  String get medActionSnooze => 'Posponer 10 min';

  @override
  String get medActionSkip => 'Omitir hoy';

  @override
  String get medActionUndo => 'Deshacer';

  @override
  String get medActionPreviewAlarm => 'Probar Alarma';

  @override
  String get medRingHeader => 'HORA DE TU MEDICINA';

  @override
  String get medRingNoteTitle => 'Nota del recordatorio';

  @override
  String get medRingNoPhoto => 'Sin foto de medicamento';

  @override
  String get medRingTapZoom => 'Toca la foto para ampliar';

  @override
  String get medRingSnoozedToast => 'Pospuesta por 10 minutos.';

  @override
  String get medRingTakenToast => '¡Excelente! Dosis de hoy registrada.';

  @override
  String get medTodayProgressTitle => 'Plan de medicación de hoy';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Próxima alarma: $time • $title';
  }

  @override
  String get medNoTodayAlarms =>
      'No hay alarmas de medicación programadas para hoy.';

  @override
  String get medEmptyTitle => 'Aún no hay alarmas';

  @override
  String get medEmptyBody =>
      'Añade alarmas con foto para pastillas de diabetes, insulina o presión. Al llegar la hora verás la foto del medicamento y tu nota en grande.';

  @override
  String get medQuickPresetDiabetes => 'Diabetes / Insulina';

  @override
  String get medQuickPresetBp => 'Presión arterial';

  @override
  String get medQuickPresetVitamin => 'Vitamina';

  @override
  String get dietMenuTitle => 'Dieta y Calorías IA';

  @override
  String get dietHomeCardTitle => 'Dieta y Menús';

  @override
  String get dietHomeCardEmpty => 'Dietas listas, seguimiento y peso';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'Día $day/$total • $percent% cumplimiento';
  }

  @override
  String get dietCalorieQuickTitle => 'Calcular Calorías del Plato IA';

  @override
  String get dietCalorieQuickSubtitle =>
      'Fotografía tu plato para ver calorías y macros';

  @override
  String get dietTabActive => 'Mi Dieta';

  @override
  String get dietTabTemplates => 'Plantillas';

  @override
  String get dietTabWeight => 'Peso';

  @override
  String get dietTabCalories => 'Calorías IA';

  @override
  String get dietStartDiet => 'Empezar Dieta';

  @override
  String get dietRestartOrChange => 'Cambiar Dieta';

  @override
  String get dietEndDiet => 'Finalizar Dieta';

  @override
  String get dietEndDietConfirm =>
      '¿Finalizar tu plan activo? Se conservará el historial de cumplimiento y peso.';

  @override
  String get dietNoActiveTitle => 'Aún sin dieta activa';

  @override
  String get dietNoActiveBody =>
      'Elige entre plantillas listas (Mediterránea, Diabetes, DASH, Pérdida de Peso, Ayuno 16:8, Alta Proteína) y controla fechas, cumplimiento y peso.';

  @override
  String get dietBrowseTemplates => 'Ver Dietas Listas';

  @override
  String get dietStartDate => 'Fecha de inicio';

  @override
  String get dietEndDate => 'Fecha de fin';

  @override
  String get dietStartWeight => 'Peso inicial (kg)';

  @override
  String get dietTargetWeight => 'Peso objetivo (kg)';

  @override
  String get dietDailyCalorieTarget => 'Meta calórica diaria (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days días';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'Día $day de $total';
  }

  @override
  String dietDaysLeft(int days) {
    return 'Faltan $days días';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Cumplimiento: $percent%';
  }

  @override
  String get dietFollowed => 'Cumplí';

  @override
  String get dietNotFollowed => 'No cumplí';

  @override
  String get dietPending => 'Pendiente';

  @override
  String get dietSlotBreakfast => 'Desayuno';

  @override
  String get dietSlotMorningSnack => 'Merienda mañana';

  @override
  String get dietSlotLunch => 'Almuerzo';

  @override
  String get dietSlotAfternoonSnack => 'Merienda tarde';

  @override
  String get dietSlotDinner => 'Cena';

  @override
  String get dietAlternativesLabel => 'Alternativa';

  @override
  String dietWaterTarget(String liters) {
    return 'Meta de agua: $liters L';
  }

  @override
  String get dietRulesTitle => 'Guía del plan';

  @override
  String get dietSampleMenuTitle => 'Menú diario de ejemplo';

  @override
  String get dietStartedToast => '¡Plan de dieta iniciado!';

  @override
  String get dietEndedToast => 'Plan de dieta finalizado.';

  @override
  String get dietWeightLogTitle => 'Control de Peso en Dieta';

  @override
  String get dietWeightAdd => 'Registrar Peso';

  @override
  String get dietWeightField => 'Peso actual (kg)';

  @override
  String get dietWeightNote => 'Nota (Opcional)';

  @override
  String get dietWeightNoteHint => 'Ej.: Peso en ayunas por la mañana';

  @override
  String get dietWeightEmpty =>
      'Aún no hay registros de peso. Añade tu primer pesaje.';

  @override
  String get dietWeightCurrent => 'Actual';

  @override
  String get dietWeightTarget => 'Objetivo';

  @override
  String get dietWeightChange => 'Cambio';

  @override
  String get dietWeightSaved => 'Registro de peso guardado.';

  @override
  String get dietCalorieTitle => 'Calculadora de Calorías por Foto IA';

  @override
  String get dietCalorieSubtitle =>
      'Funciona con o sin dieta — fotografía tu plato o escribe tu comida.';

  @override
  String get dietSnapPlateCamera => 'Fotografiar Plato';

  @override
  String get dietPickPlateGallery => 'Elegir de Galería';

  @override
  String get dietFoodDescLabel => 'Descripción / Porción (Opcional)';

  @override
  String get dietFoodDescHint =>
      'Ej.: Pollo a la plancha, arroz integral, ensalada';

  @override
  String get dietCalculateFromText => 'Calcular desde Texto';

  @override
  String get dietAnalyzingPlate => 'Analizando calorías y nutrientes...';

  @override
  String get dietResultTitle => 'Análisis de Calorías y Macros';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Visión';

  @override
  String get dietOnDeviceBadge => 'Estimación Inteligente Local';

  @override
  String get dietProtein => 'Proteína';

  @override
  String get dietCarbs => 'Carbohidratos';

  @override
  String get dietFat => 'Grasa';

  @override
  String get dietFiber => 'Fibra';

  @override
  String get dietPortionScale => 'Tamaño de porción';

  @override
  String get dietSaveMealLog => 'Guardar en Registro de Hoy';

  @override
  String get dietMealLoggedToast => 'Calorías de la comida guardadas.';

  @override
  String get dietTodayTotalCalories => 'Total de hoy';

  @override
  String get dietRecentScans => 'Comidas Analizadas';

  @override
  String get dietNoScansYet =>
      'Aún no has analizado platos. Toma una foto de tu comida.';

  @override
  String dietHealthScore(int score) {
    return 'Equilibrio: $score/10';
  }

  @override
  String get dietTodayLabel => 'Hoy';

  @override
  String get medCatHerbalTea => 'Infusión / Té Herbal';

  @override
  String get medCatCustom => 'Otro (Manual)';

  @override
  String get medFieldCustomCategory => 'Nombre de categoría personalizada';

  @override
  String get medFieldCustomCategoryHint =>
      'Ej.: Probiótico, Agua, Fisioterapia...';

  @override
  String get medQuickPresetHerbalTea => 'Infusión / Té';

  @override
  String get dietCreateCustom => 'Crear Mi Propia Dieta';

  @override
  String get dietCreateCustomSubtitle =>
      'Introduce manualmente la dieta de tu nutricionista o tu menú';

  @override
  String get dietCustomNameLabel => 'Nombre de la dieta';

  @override
  String get dietCustomNameHint => 'Ej.: Plan del nutricionista, Mi menú...';

  @override
  String get dietCustomNameRequired =>
      'Por favor escribe el nombre de la dieta.';

  @override
  String get dietCustomMealHint => '¿Qué comerás en esta comida?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (opcional)';

  @override
  String get dietCustomAtLeastOneMeal => 'Introduce al menos una comida.';

  @override
  String get dietCustomTemplatesTitle => 'Mis Planes Personalizados';

  @override
  String get dietReadyTemplatesTitle => 'Plantillas de Dieta Listas';

  @override
  String get donateTooltip => 'Apoyar / Donar';

  @override
  String get donateMenuLabel => 'Apoyar a VisualCheckUp';

  @override
  String get donateMenuSubtitle =>
      'Un café, comida o regalo para apoyar herramientas de salud';

  @override
  String get donatePopupTitle => 'Apoya a VisualCheckUp';

  @override
  String get donatePopupSubtitle =>
      'Tu apoyo voluntario nos ayuda a mantener gratuitas y mejorar las herramientas de salud, análisis, alarmas y dieta.';

  @override
  String get donateTierCoffeeTitle => 'Invitar un Café';

  @override
  String get donateTierCoffeeDesc => 'Un café calentito para el desarrollo';

  @override
  String get donateTierMealTitle => 'Invitar una Comida';

  @override
  String get donateTierMealDesc => 'Gran apoyo para nuevas funciones de salud';

  @override
  String get donateTierGiftTitle => 'Enviar un Regalo';

  @override
  String get donateTierGiftDesc => 'Ayuda a cubrir costos de IA y servidores';

  @override
  String get donateTierGoldTitle => 'Gran Apoyo';

  @override
  String get donateTierGoldDesc => 'Impulsa nuevos módulos médicos e idiomas';

  @override
  String get donateTierHeroTitle => 'Héroe de la Salud';

  @override
  String get donateTierHeroDesc =>
      'Apoya el seguimiento gratuito para todas las familias';

  @override
  String get donatePopularBadge => 'Popular';

  @override
  String donateConfirmButton(String price) {
    return 'Donar $price';
  }

  @override
  String get donateLaterButton => 'Más Tarde';

  @override
  String get donateThanksTitle => '¡Gracias por tu Apoyo!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'Tu aporte de $tier ($price) significa muchísimo para nosotros. ¡Gracias por hacer crecer VisualCheckUp!';
  }

  @override
  String get donateSupporterBadge => 'Colaborador • ¡Gracias!';

  @override
  String get donateStoreNotice => 'Apoyo voluntario único • Sin suscripción';
}
