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
}
