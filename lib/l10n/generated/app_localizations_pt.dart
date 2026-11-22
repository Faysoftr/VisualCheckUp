// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'Este aplicativo não faz diagnóstico médico; serve apenas para informação e autoconsciência visual.';

  @override
  String get disclaimerTitle => 'Aviso Médico Importante';

  @override
  String get disclaimerFull =>
      'O VisualCheckUp oferece uma pré-avaliação visual baseada em sinais de cor e aparência. Não é um dispositivo médico e nunca substitui uma consulta médica ou exames laboratoriais.\n\n• A iluminação ambiente e o sensor da câmera afetam a percepção de cor.\n• Procure atendimento médico imediatamente em caso de dor intensa, sangramento, febre alta, icterícia, fezes pretas/claras ou falta de ar.\n• Privacidade: as imagens são processadas no seu dispositivo por padrão.';

  @override
  String get disclaimerAccept => 'Entendi';

  @override
  String get loginTagline =>
      'Assistente pessoal para acompanhar mudanças visuais da pele, pintas e preparar consultas médicas.';

  @override
  String get featureColorCalibration => 'Calibração de Cor';

  @override
  String get featurePrivacyFirst => 'Privacidade';

  @override
  String get featureOptionalAi => 'IA Opcional';

  @override
  String get loginCardTitle => 'Continue com sua conta';

  @override
  String get loginCardSubtitle =>
      'Mantenha suas referências de cor e histórico de verificações organizados.';

  @override
  String get continueWithApple => 'Continuar com a Apple';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get orDivider => 'ou';

  @override
  String get continueAsGuest => 'Continuar como convidado';

  @override
  String get guestGreeting => 'Acompanhamento Visual de Saúde';

  @override
  String userGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return 'Conta $provider';
  }

  @override
  String get localOnlyLabel => 'Salvo apenas neste dispositivo';

  @override
  String get menuHome => 'Início';

  @override
  String get menuSectionVisualChecks => 'VERIFICAÇÕES VISUAIS';

  @override
  String get menuSkinGroup => 'Pele (Pinta, Verruga, Hematoma)';

  @override
  String get menuSkinGeneral => 'Pele Geral e Erupções';

  @override
  String get menuSectionTracking => 'ACOMPANHAMENTO, EXAMES E SINAIS';

  @override
  String get menuFollowUpPlan => 'Plano de Acompanhamento Pessoal';

  @override
  String get menuVitalsTracker => 'Pressão Arterial e Glicemia';

  @override
  String get menuLabReports => 'Exames e Laudos Hospitalares';

  @override
  String get menuQuickColorCard => 'Cartão de Cores sem Câmera';

  @override
  String get menuHistory => 'Histórico de Verificações';

  @override
  String get menuReferenceGuide => 'Guia Visual de Referência';

  @override
  String get menuSectionSettings => 'CONFIGURAÇÕES E PRIVACIDADE';

  @override
  String get menuAiSettings => 'IA e Privacidade';

  @override
  String get menuDisclaimer => 'Aviso Médico';

  @override
  String get menuTheme => 'Tema de Aparência';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get menuLanguage => 'Idioma do Aplicativo';

  @override
  String get languageSystem => 'Idioma do Sistema';

  @override
  String get signInGoogleOrApple => 'Entrar com Google ou Apple';

  @override
  String get signOut => 'Sair';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String get deleteAccountTitle => 'Excluir conta e dados locais';

  @override
  String get deleteAccountBody =>
      'Você será desconectado e seu histórico e referências locais serão excluídos permanentemente. Continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get followUpCardTitle => 'Plano de Acompanhamento Pessoal';

  @override
  String get followUpSelectEdit => 'Selecionar / Editar';

  @override
  String get followUpStart => 'Iniciar';

  @override
  String get followUpEmptyHint =>
      'Toque para escolher rotinas de olhos, urina, pressão, glicemia e outros.';

  @override
  String get followUpSheetSubtitle =>
      'Acompanhe olhos, língua, unhas, pele, urina, fezes, pressão arterial, glicemia e exames em um só plano.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return '$active ativos • $completed em dia • $due pendentes';
  }

  @override
  String get homeCategoriesTitle => 'Categorias de Verificação';

  @override
  String get homeCategoriesSubtitle =>
      'Acompanhe mudanças visuais por câmera ou cartão de cores sem câmera.';

  @override
  String get homeLabsVitalsTitle => 'Exames, Pressão e Glicemia';

  @override
  String get homeLabsVitalsSubtitle =>
      'Leia laudos de sangue e acompanhe tendências de pressão e glicemia.';

  @override
  String get homeLabsCardTitle => 'Exames e Laudos';

  @override
  String get homeLabsCardEmpty => 'Ler e revisar exames de sangue';

  @override
  String homeLabsCardCount(int count) {
    return '$count laudos salvos';
  }

  @override
  String get homeVitalsCardTitle => 'Pressão e Glicemia';

  @override
  String get homeVitalsCardEmpty => 'Registrar e ver tendências';

  @override
  String homeVitalsCardCount(int count) {
    return '$count medições salvas';
  }

  @override
  String get homeRecentChecks => 'Verificações Recentes';

  @override
  String get seeAll => 'Ver Tudo';

  @override
  String get catEyeTitle => 'Olhos (Esclera)';

  @override
  String get catEyeSubtitle => 'Vermelhidão, amarelamento e tom ocular';

  @override
  String get catNailTitle => 'Unhas';

  @override
  String get catNailSubtitle => 'Palidez, coloração azulada, amarela e forma';

  @override
  String get catTongueTitle => 'Língua';

  @override
  String get catTongueSubtitle => 'Cor, saburra branca/amarela e textura';

  @override
  String get catFaceTitle => 'Rosto e Pele';

  @override
  String get catFaceSubtitle => 'Tom da pele, palidez e vermelhidão';

  @override
  String get catSkinTitle => 'Condições da Pele';

  @override
  String get catSkinSubtitle =>
      'Pintas, verrugas, hematomas, manchas e erupções';

  @override
  String get catUrineTitle => 'Cor da Urina';

  @override
  String get catUrineSubtitle => 'Hidratação e escala de cores';

  @override
  String get catStoolTitle => 'Cor das Fezes';

  @override
  String get catStoolSubtitle => 'Digestão e alertas de coloração';

  @override
  String get tooltipHistory => 'Histórico';

  @override
  String get tooltipAccountMenu => 'Conta e Menu';

  @override
  String get menuSettings => 'Configurações (Permissões e Idioma)';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageDesc =>
      'O idioma do telefone é usado por padrão. Você pode escolher outro idioma abaixo.';

  @override
  String get settingsPermissionsTitle => 'Permissões do App';

  @override
  String get settingsPermissionsDesc =>
      'Verifique e gerencie as permissões de câmera e galeria aqui.';

  @override
  String get settingsCameraPermission => 'Permissão de Câmera';

  @override
  String get settingsCameraPermissionDesc =>
      'Para capturas de olhos, língua, unhas e pele';

  @override
  String get settingsPhotosPermission => 'Permissão de Galeria e Fotos';

  @override
  String get settingsPhotosPermissionDesc =>
      'Para enviar fotos e laudos de exames';

  @override
  String get settingsOpenSystemPermissions => 'Abrir Permissões do Telefone';

  @override
  String get permChecking => 'Verificando...';

  @override
  String get permGranted => 'Concedida';

  @override
  String get permDenied => 'Permissão Necessária';

  @override
  String get permPermanent => 'Ativar nas Configurações do Sistema';

  @override
  String get permUnavailable => 'Gerenciado pelo Dispositivo';

  @override
  String get permGrantBtn => 'Permitir';

  @override
  String get permOpenSettingsBtn => 'Abrir Configurações';

  @override
  String get skinCancerRisk => 'Pinta e Risco Cutâneo';

  @override
  String get skinWart => 'Pré-avaliação de Verruga';

  @override
  String get skinBruise => 'Acompanhamento de Hematoma';

  @override
  String get skinFacialSpot => 'Mancha Facial';

  @override
  String get trackEyeTitle => 'Verificação Semanal dos Olhos';

  @override
  String get trackEyeSubtitle => 'Acompanhe vermelhidão ou amarelamento';

  @override
  String get trackTongueTitle => 'Verificação Semanal da Língua';

  @override
  String get trackTongueSubtitle => 'Acompanhe cor, saburra e textura';

  @override
  String get trackNailTitle => 'Verificação Semanal das Unhas';

  @override
  String get trackNailSubtitle => 'Monitore palidez, tom azulado ou amarelo';

  @override
  String get trackFaceTitle => 'Tom Facial Quinzenal';

  @override
  String get trackFaceSubtitle => 'Compare palidez, vermelhidão e tom da pele';

  @override
  String get trackSkinTitle => 'Verificação Mensal de Pele e Pintas';

  @override
  String get trackSkinSubtitle =>
      'Compare mudanças em 30 dias em pintas, verrugas e manchas';

  @override
  String get trackHydrationTitle => 'Hidratação Diária (Urina)';

  @override
  String get trackHydrationSubtitle =>
      'Registre em 2 s com o cartão de cores sem câmera';

  @override
  String get trackStoolTitle => 'Verificação Semanal das Fezes';

  @override
  String get trackStoolSubtitle => 'Acompanhe digestão e alertas de coloração';

  @override
  String get trackBpTitle => 'Pressão Arterial Diária';

  @override
  String get trackBpSubtitle => 'Registre pressão sistólica/diastólica e pulso';

  @override
  String get trackSugarTitle => 'Glicemia Diária';

  @override
  String get trackSugarSubtitle => 'Registre glicemia em jejum ou pós-refeição';

  @override
  String get trackLabTitle => 'Exame de Sangue Trimestral';

  @override
  String get trackLabSubtitle =>
      'Envie laudos hospitalares e compare ao longo do tempo';

  @override
  String get statusFirstPending => 'Aguardando primeiro registro';

  @override
  String get statusDueNow => 'Hora de verificar';

  @override
  String get statusDoneToday => 'Concluído hoje';

  @override
  String statusNextDays(int days) {
    return 'Próxima verificação em $days dias';
  }

  @override
  String get actionCheckNow => 'Verificar Agora';

  @override
  String get actionLogReading => 'Registrar';

  @override
  String get actionAddReport => 'Adicionar Laudo';

  @override
  String checkMethodTitle(String category) {
    return '$category • Método de Verificação';
  }

  @override
  String get checkMethodSubtitle =>
      'Escolha em 2 segundos no cartão de cores sem foto ou use a câmera.';

  @override
  String get colorCardRecommendedTitle =>
      'Cartão de Cores sem Câmera (Recomendado)';

  @override
  String get colorCardRecommendedSubtitle =>
      'Registro privado e rápido sem foto (2 s)';

  @override
  String get cameraMeasureTitle => 'Medição com Câmera';

  @override
  String get cameraMeasureSubtitle =>
      'Medição automática com balanço de branco';

  @override
  String get referenceGuideSubtitle =>
      'Escolha um módulo para ver referências saudáveis e de alerta.';

  @override
  String get historyEmpty => 'Nenhuma verificação salva ainda.';

  @override
  String get filterAll => 'Todos';

  @override
  String get aiSettingsTitle => 'IA e Privacidade';

  @override
  String get vitalsBpTab => 'Pressão Arterial';

  @override
  String get vitalsSugarTab => 'Glicemia';

  @override
  String get skinScreenTitle => 'Pré-avaliação Cutânea';
}
