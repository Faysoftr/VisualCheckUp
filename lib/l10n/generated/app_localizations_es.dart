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
}
