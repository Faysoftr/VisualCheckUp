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

  @override
  String get providerGuest => 'Convidado';

  @override
  String signInFailed(String error) {
    return 'Falha ao entrar: $error';
  }

  @override
  String get riskNormal => 'Aparência normal';

  @override
  String get riskAttention => 'Acompanhamento sugerido';

  @override
  String get riskUrgent => 'Avaliação médica recomendada';

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
    return 'Último: $count valores ($abnormal fora da faixa)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Último: $count valores (todos normais)';
  }

  @override
  String get labStatusCriticalLow => 'Crítico baixo';

  @override
  String get labStatusLow => 'Baixo';

  @override
  String get labStatusNormal => 'Normal';

  @override
  String get labStatusHigh => 'Alto';

  @override
  String get labStatusCriticalHigh => 'Crítico alto';

  @override
  String get labSourceManual => 'Entrada manual';

  @override
  String get labSourcePasted => 'Lido do texto';

  @override
  String get labSourcePhoto => 'Relatório JPG / Foto';

  @override
  String get labSourcePdf => 'Relatório PDF';

  @override
  String get bpLow => 'Pressão baixa';

  @override
  String get bpNormal => 'Faixa normal';

  @override
  String get bpElevated => 'Elevada';

  @override
  String get bpStage1 => 'Hipertensão estágio 1';

  @override
  String get bpStage2 => 'Hipertensão estágio 2';

  @override
  String get bpCrisis => 'Crise hipertensiva';

  @override
  String get sugarLow => 'Hipoglicemia';

  @override
  String get sugarNormal => 'Faixa normal';

  @override
  String get sugarBorderline => 'Limítrofe';

  @override
  String get sugarHigh => 'Glicemia alta';

  @override
  String get sugarVeryHigh => 'Glicemia muito alta';

  @override
  String get sugarTypeFasting => 'Jejum';

  @override
  String get sugarTypePostMeal => 'Pós-prandial (2h)';

  @override
  String get sugarTypeRandom => 'Aleatório';

  @override
  String get specialtyEye => 'Oftalmologia ou Clínica Médica';

  @override
  String get specialtyNail => 'Dermatologia ou Clínica Médica';

  @override
  String get specialtyTongue => 'Otorrino, Saúde Bucal ou Clínica Médica';

  @override
  String get specialtySkin => 'Dermatologia';

  @override
  String get specialtyUrine => 'Urologia ou Clínica Médica';

  @override
  String get specialtyStool => 'Gastroenterologia ou Clínica Médica';

  @override
  String get cloudBackupTitle => 'Backup na nuvem (Opcional • Firebase)';

  @override
  String get cloudBackupDesc =>
      'Por padrão, seus exames e medições ficam apenas neste dispositivo. Ative o backup privado na sua conta Google/Apple se quiser manter os dados ao trocar de celular.';

  @override
  String get cloudBackupToggleTitle => 'Ativar backup na nuvem';

  @override
  String cloudBackupLastSync(String date) {
    return 'Último backup: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Ativo • Pronto para sincronizar';

  @override
  String get cloudBackupDisabledLocal =>
      'Desativado • Apenas armazenamento local';

  @override
  String get cloudBackupSignInRequired =>
      'Entre com Google ou Apple para usar o backup na nuvem.';

  @override
  String get cloudBackupNowBtn => 'Fazer backup agora';

  @override
  String get cloudRestoreBtn => 'Restaurar da nuvem';

  @override
  String get cloudConsentTitle => 'Consentimento de backup na nuvem';

  @override
  String get cloudConsentBody =>
      'Seus exames, medições e registros ficam apenas neste dispositivo por padrão.\n\nAo ativar o backup na nuvem, esses dados serão armazenados de forma privada na sua conta Google/Apple e apagados permanentemente ao excluir a conta.\n\nVocê concorda?';

  @override
  String get cloudConsentConfirm => 'Sim, ativar';

  @override
  String cloudBackupSuccess(int count) {
    return 'Backup concluído: $count registros sincronizados.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Falha no backup: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Restaurado da nuvem: $count registros importados.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Falha ao restaurar: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Backup na nuvem desativado. Novos registros ficam apenas no dispositivo.';

  @override
  String get aiCloudToggleTitle => 'Análise de IA na nuvem (Gemini)';

  @override
  String get aiCloudOnDesc =>
      'Ativado: Fotos nítidas são redimensionadas e analisadas com segurança. Offline usa análise local.';

  @override
  String get aiCloudOffDesc =>
      'Desativado (0 tokens): Toda análise ocorre no dispositivo; nenhuma foto é enviada.';

  @override
  String get aiBackendOfflineNote =>
      'Quando a chave Gemini / Firebase AI for configurada, a análise em nuvem ativará automaticamente; o motor local está ativo.';

  @override
  String get aiOptimizationsTitle =>
      'Controles ativos de economia de tokens e dados';

  @override
  String get aiOptQualityGate =>
      'Filtro de qualidade 0-token (desfoque, luz e brilho)';

  @override
  String get aiOptCompression =>
      'Corte automático + compressão JPEG 512/768px (80%)';

  @override
  String get aiOptTieredModel =>
      'Seleção inteligente de modelo (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'Cache local de duplicatas (0 tokens)';

  @override
  String get aiClearCacheBtn => 'Limpar cache de IA';

  @override
  String get aiCacheCleared => 'Cache de IA limpo.';

  @override
  String resultScreenTitle(String category) {
    return 'Resultado: $category';
  }

  @override
  String get tooltipDoctorSummary => 'Resumo para o médico';

  @override
  String get tooltipReferenceGuide => 'Guia de referência';

  @override
  String get calibratedColorTone => 'Tom de cor calibrado';

  @override
  String get sampledColorTone => 'Tom dominante amostrado';

  @override
  String confidenceLabel(int percent) {
    return 'Confiança preliminar: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote =>
      'Cor equilibrada com referência branca.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Especialidade sugerida: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Comparação ao longo do tempo';

  @override
  String get todayLabel => 'Hoje';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Registro anterior: \"$title\" ($status). $count registros acompanhados.';
  }

  @override
  String get personalBaselineComparisonTitle =>
      'Comparação com sua base pessoal';

  @override
  String get yourBaselineLabel => 'Sua base';

  @override
  String get warningFlagsTitle => 'Sinais de alerta';

  @override
  String get observationsTitle => 'Observações';

  @override
  String get recommendationsTitle => 'Recomendações';

  @override
  String get personalBaselineCardTitle => 'Calibração de base pessoal';

  @override
  String get personalBaselineCardDesc =>
      'Salve esta medição em um dia saudável como sua base pessoal para reduzir variações da câmera.';

  @override
  String get saveBaselineBtn => 'Salvar como minha base';

  @override
  String get updateBaselineBtn => 'Atualizar minha base';

  @override
  String get clearBaselineBtn => 'Remover';

  @override
  String baselineSavedMsg(String category) {
    return 'Base pessoal salva para $category.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'Base pessoal removida para $category.';
  }

  @override
  String get doctorSummaryBtn => 'Mostrar ao médico • Resumo';

  @override
  String get returnHomeBtn => 'Voltar ao início';

  @override
  String get doctorSheetTitle => 'Resumo para consulta médica';

  @override
  String colorLabel(String hex, String status) {
    return 'Cor: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Linha do tempo anterior';

  @override
  String get questionsForDoctorTitle => 'Perguntas para o médico';

  @override
  String get copyShareSummaryBtn => 'Copiar e compartilhar resumo';

  @override
  String get doctorSummaryCopied => 'Resumo médico copiado.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Referências visuais';
  }

  @override
  String get healthyReferenceLabel => 'Referência saudável';

  @override
  String get captureChecklistTitle => 'Dicas de captura';

  @override
  String get abnormalFindingsTitle => 'Achados visuais de atenção';

  @override
  String get cameraPermPermanentMsg =>
      'A permissão de câmera está desativada nos ajustes. Ative-a ou escolha uma foto da galeria.';

  @override
  String get cameraPermRequiredMsg =>
      'É necessária permissão de câmera para o exame visual. Imagens processadas localmente.';

  @override
  String get cameraGrantPermTitle => 'Acesso à câmera necessário';

  @override
  String get cameraRequestPermBtn => 'Permitir câmera';

  @override
  String get cameraPickGalleryBtn => 'Escolher da galeria';

  @override
  String get cameraWhiteRefOn => 'Referência branca: Ativa';

  @override
  String get cameraWhiteRefOff => 'Referência branca: Inativa';

  @override
  String get cameraBaselineActive => 'Base pessoal salva';

  @override
  String get cameraAnalyzing => 'Analisando...';

  @override
  String get cameraCaptureBtn => 'Capturar e analisar';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Erro na análise: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Cartela de cores';
  }

  @override
  String get quickCardPrivacyBanner =>
      'Sem câmera: escolha o tom mais próximo para um registro privado em 2 segundos.';

  @override
  String get quickCardChooseShade => 'Selecione o tom mais próximo';

  @override
  String get quickCardExtraContext => 'Contexto extra (Opcional)';

  @override
  String get quickCardSaveViewBtn => 'Salvar e ver avaliação';

  @override
  String get quickCardUseCameraBtn => 'Usar câmera em vez disso';

  @override
  String get skinIntroTitle => 'Pré-triagem dermatológica visual';

  @override
  String get skinIntroDesc =>
      'Compara pintas, verrugas, hematomas e manchas faciais com a pele ao redor. Não é diagnóstico; auxilia na consulta.';

  @override
  String get skinStep1Title => '1. Selecione o módulo dermatológico';

  @override
  String get skinOtherConcernsLabel => 'Outras apresentações';

  @override
  String get skinStep2Title => '2. Sintomas associados (Opcional)';

  @override
  String get skinStep3Title => '3. Região do corpo (Opcional)';

  @override
  String get skinStartCameraBtn => 'Iniciar exame de pele pela câmera';

  @override
  String get skinConcernRash => 'Vermelhidão / Erupção';

  @override
  String get skinConcernMole => 'Pinta / Mancha escura';

  @override
  String get skinConcernScaly => 'Placa seca / descamativa';

  @override
  String get skinConcernBlister => 'Bolha / Acne';

  @override
  String get skinConcernGeneral => 'Exame geral da pele';

  @override
  String get bodyAreaFaceNeck => 'Rosto / Pescoço';

  @override
  String get bodyAreaArmHand => 'Braço / Mão';

  @override
  String get bodyAreaTorso => 'Tronco';

  @override
  String get bodyAreaLegFoot => 'Perna / Pé';

  @override
  String get bodyAreaScalp => 'Couro cabeludo';

  @override
  String get bodyAreaOther => 'Outro';

  @override
  String get symptomItching => 'Coceira';

  @override
  String get symptomPainWarmth => 'Dor / Calor';

  @override
  String get symptomRapidChange => 'Crescimento rápido / mudança';

  @override
  String get symptomBleeding => 'Sangramento / Secreção';

  @override
  String get symptomSpreading => 'Espalhando rápido';

  @override
  String get symptomFever => 'Com febre';

  @override
  String get symptomNonHealing => 'Ferida sem cicatrização (4+ sem.)';

  @override
  String get symptomOver6mm => 'Maior que 6 mm ou borda irregular';

  @override
  String get symptomNoTrauma => 'Surgiu sem pancada';

  @override
  String get symptomRoughDots => 'Superfície áspera / pontos pretos';

  @override
  String get symptomSunHormone => 'Mancha solar, hormonal ou pós-acne';

  @override
  String get bruiseGuideTitle => 'Guia de fases do hematoma';

  @override
  String get wartGuideTitle => 'Guia de segurança para verrugas';

  @override
  String get abcdeGuideTitle => 'Guia ABCDE para pintas';

  @override
  String get abcdeGuideSubtitle =>
      '5 sinais principais usados por dermatologistas';

  @override
  String get labScreenTitle => 'Exames e laudos';

  @override
  String get labTabReports => 'Meus exames';

  @override
  String get labTabTrends => 'Evolução';

  @override
  String get labAddBtn => 'Adicionar exame';

  @override
  String get labEmptyTitle => 'Nenhum exame salvo ainda';

  @override
  String get labEmptyDesc =>
      'Envie seu exame em PDF ou JPG; se quiser, adicione o diagnóstico ou sintomas para uma explicação simples.';

  @override
  String get labAddFirstBtn => 'Adicionar primeiro exame';

  @override
  String get labTrendsEmptyDesc =>
      'Salve exames em datas diferentes para ver gráficos de evolução de Hemoglobina, Ferritina, Glicose, TSH e mais.';

  @override
  String labParamsCount(int count) {
    return '$count parâmetros';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count fora da faixa';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Avaliação de parâmetros ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Diagnóstico médico';

  @override
  String get labEnteredComplaintTitle => 'Sua queixa / nota';

  @override
  String get labInterpretationTitle => 'Interpretação clara';

  @override
  String get labCopyDoctorSummaryBtn => 'Mostrar ao médico • Copiar';

  @override
  String get labSummaryCopied => 'Resumo do exame copiado.';

  @override
  String get labExportPdfBtn => 'Exportar PDF para o médico';

  @override
  String get labAddSheetTitle => 'Adicionar exame / laudo';

  @override
  String get labReportTitleField => 'Título do exame';

  @override
  String get labDefaultReportTitle => 'Resultado de exame';

  @override
  String get labStep1Upload => '1. Enviar exame PDF ou JPG';

  @override
  String get labUploadPdfJpgBtn => 'Enviar PDF ou JPG';

  @override
  String get labCameraCaptureBtn => 'Tirar foto';

  @override
  String get labStep2Context => '2. Diagnóstico e nota (Opcional)';

  @override
  String get labStep2ContextHint =>
      'Digite o diagnóstico que deseja entender ou seus sintomas; pode deixar em branco.';

  @override
  String get labDiagnosisField => 'Diagnóstico médico (Opcional)';

  @override
  String get labComplaintField => 'Seus sintomas / dúvida (Opcional)';

  @override
  String get labStep3PasteManual => '3. Colar texto ou adicionar valores';

  @override
  String get labParseTextBtn => 'Ler e extrair texto';

  @override
  String get labParamDropdown => 'Parâmetro';

  @override
  String labValueField(String unit) {
    return 'Valor ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Adicionar';

  @override
  String labParsedValuesTitle(int count) {
    return 'Valores lidos ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Avaliar e salvar';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return '$count registros • Mudança: $delta • Último: $status';
  }

  @override
  String get vitalsScreenTitle => 'Pressão e Glicemia';

  @override
  String get vitalsCopySummaryTooltip => 'Copiar resumo médico';

  @override
  String get vitalsCopyEmptyMsg =>
      'Adicione primeiro uma medição de pressão ou glicemia.';

  @override
  String get vitalsSummaryCopied => 'Resumo de pressão e glicemia copiado.';

  @override
  String get vitalsAddBpBtn => 'Adicionar pressão';

  @override
  String get vitalsAddSugarBtn => 'Adicionar glicemia';

  @override
  String get vitalsBpEmptyTitle => 'Nenhuma medição de pressão ainda';

  @override
  String get vitalsBpEmptyDesc =>
      'Registre pressão sistólica, diastólica e pulso para acompanhar o gráfico.';

  @override
  String get vitalsBpAddFirstBtn => 'Adicionar primeira pressão';

  @override
  String get vitalsSugarEmptyTitle => 'Nenhuma medição de glicemia ainda';

  @override
  String get vitalsSugarEmptyDesc =>
      'Registre glicemia em jejum, pós-prandial ou aleatória para acompanhar a tendência.';

  @override
  String get vitalsSugarAddFirstBtn => 'Adicionar primeira glicemia';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Média ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Pulso $pulse bpm';
  }

  @override
  String get vitalsBpHistoryTitle => 'Histórico de pressão';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Média ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'Histórico de glicemia';

  @override
  String get vitalsNewBpTitle => 'Nova medição de pressão';

  @override
  String get vitalsSystolicField => 'Sistólica (Máxima)';

  @override
  String get vitalsDiastolicField => 'Diastólica (Mínima)';

  @override
  String get vitalsPulseField => 'Pulso (bpm — Opcional)';

  @override
  String get vitalsNoteField => 'Nota (Opcional)';

  @override
  String get vitalsSaveBpBtn => 'Salvar pressão';

  @override
  String get vitalsNewSugarTitle => 'Nova medição de glicemia';

  @override
  String get vitalsSugarValueField => 'Glicemia (mg/dL)';

  @override
  String get vitalsSaveSugarBtn => 'Salvar glicemia';

  @override
  String get chartAddReadingHint => 'Adicione medições para ver o gráfico';

  @override
  String get loginTermsTitle => 'Termos de uso e aviso médico';

  @override
  String get loginTermsCheckbox =>
      'Entendo que o VisualCheckUp não fornece diagnóstico médico definitivo, serve apenas para orientação inicial, e aceito os Termos de uso.';

  @override
  String get loginTermsRequiredMsg =>
      'Aceite os Termos de uso e o aviso médico antes de entrar.';

  @override
  String get loginTermsReadMore => 'Ler termos';

  @override
  String get loginTermsModalBody =>
      '• Sem diagnóstico médico: O VisualCheckUp não é um dispositivo médico e não substitui consulta ou tratamento médico.\n\n• Apenas orientação: Verificações visuais, resumos de exames e escalas de IMC/crescimento auxiliam no acompanhamento pessoal e na consulta médica.\n\n• Emergência: Em caso de dor no peito, falta de ar ou sintomas graves, procure atendimento de emergência imediatamente.\n\n• Privacidade: Seus dados permanecem armazenados apenas no seu dispositivo por padrão.';

  @override
  String get loginTermsAcceptBtn => 'Li e aceito';

  @override
  String atlasFilterAll(int count) {
    return 'Atlas Ilustrado ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Sinais Urgentes ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Testes Clínicos em Casa ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Sinais que Exigem Avaliação Médica Rápida';

  @override
  String get atlasTapToCompareHint =>
      'Toque em qualquer cartão para ampliar lado a lado com a referência saudável.';

  @override
  String get atlasVisualCueLabel => 'Sinal Visual';

  @override
  String get atlasClinicalContextLabel => 'Possível Contexto Clínico';

  @override
  String get atlasPossibleContextShort => 'Contexto Possível';

  @override
  String get atlasWarningPrefix => 'Alerta';

  @override
  String get atlasCloseBtn => 'Fechar';

  @override
  String get atlasCaptureProtocolTitle => 'Melhor Protocolo de Captura';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Testes Clínicos Preliminares para Fazer em Casa';

  @override
  String get atlasSelfTestNormalPrefix => 'Normal';

  @override
  String get atlasSelfTestWarningPrefix => 'Atenção';

  @override
  String get fitzpatrickScaleTitle =>
      'Fototipos de Pele Fitzpatrick e Escala ITA°';

  @override
  String get fitzpatrickScaleSubtitle =>
      'O app mede o ângulo ITA° da pele saudável ao redor para equilibrar os limites de análise conforme seu fototipo.';

  @override
  String get resultVisualCompareTitle =>
      'Comparação com Referência Clínica Ilustrada';

  @override
  String get resultHealthyShort => 'Saudável';

  @override
  String get resultMatchedShort => 'Correspondente';

  @override
  String get resultViewFullAtlasBtn => 'Ver Atlas Ilustrado Completo';

  @override
  String get resultHomeSelfTestsBtn => 'Testes Clínicos em Casa';

  @override
  String get resultClinicalBiomarkersTitle => 'Medições Clínicas Quantitativas';

  @override
  String get cameraEyeModeSclera => 'Modo: Esclera (Icterícia)';

  @override
  String get cameraEyeModeConjunctiva => 'Pálpebra Inferior (Anemia)';

  @override
  String get cameraClinicalAtlasChip => 'Testes e Atlas';

  @override
  String get bristolScaleTitle =>
      'Escala de Fezes de Bristol (Opcional • Tipos 1–7)';

  @override
  String get bristolType1Title => 'Tipo 1 • Caroços duros';

  @override
  String get bristolType2Title => 'Tipo 2 • Salsicha grumosa';

  @override
  String get bristolType3Title => 'Tipo 3 • Com fissuras';

  @override
  String get bristolType4Title => 'Tipo 4 • Lisa (Ideal)';

  @override
  String get bristolType5Title => 'Tipo 5 • Pedaços macios';

  @override
  String get bristolType6Title => 'Tipo 6 • Pastosa / Solta';

  @override
  String get bristolType7Title => 'Tipo 7 • Totalmente líquida';

  @override
  String get metricFitzpatrickPhototype => 'Fototipo Fitzpatrick';

  @override
  String get metricAbcdeAsymmetry => 'A — Assimetria';

  @override
  String get metricAbcdeBorder => 'B — Irregularidade da Borda';

  @override
  String get metricAbcdeColors => 'C — Cores Dermatoscópicas';

  @override
  String get metricErythemaDelta => 'Índice de Eritema Δ';

  @override
  String get metricAnnularClearing => 'Clareamento Central Anular';

  @override
  String get metricErythemaIndex => 'Índice de Eritema (EI)';

  @override
  String get metricScleraBilirubin => 'Índice de Bilirrubina Escleral';

  @override
  String get metricHemorrhagePatch => 'Área de Hemorragia Compacta';

  @override
  String get metricNailErythema => 'Índice de Eritema Ungueal';

  @override
  String get metricBeauGroove => 'Sulco Transversal de Beau';

  @override
  String get metricTerryLindsaySplit => 'Divisão Proximal/Distal';

  @override
  String get metricSplinterStreak => 'Razão de Hemorragia em Estilhaço';

  @override
  String get metricGeographicTongue => 'Pontuação Língua Geográfica';

  @override
  String get metricYellowCoating => 'Proporção de Saburra Amarela';

  @override
  String get metricBristolScale => 'Escala de Bristol';

  @override
  String get hubStartNewScan => 'Iniciar Novo Exame';

  @override
  String get hubPickFromGallery => 'Galeria';

  @override
  String hubPastScansTitle(int count) {
    return 'Exames Anteriores ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Total de Exames';

  @override
  String get hubLastScanLabel => 'Último Exame';

  @override
  String get hubLatestStatusLabel => 'Último Status';

  @override
  String get hubFilterAll => 'Todos';

  @override
  String get hubFilterAttention => 'Atenção / Urgente';

  @override
  String get hubFilterWithPhoto => 'Com Foto';

  @override
  String get hubColPhoto => 'Foto';

  @override
  String get hubColDate => 'Data';

  @override
  String get hubColFinding => 'Achado e Resumo';

  @override
  String get hubColStatus => 'Status';

  @override
  String get hubCompareModeBtn => 'Comparar 2 Exames';

  @override
  String hubCompareSelectHint(int count) {
    return 'Selecione 2 exames na tabela para comparar lado a lado ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Comparar Lado a Lado';

  @override
  String get hubCompareCancelBtn => 'Cancelar';

  @override
  String get hubCompareSheetTitle => 'Comparação Lado a Lado';

  @override
  String get hubCompareOlderLabel => 'Anterior';

  @override
  String get hubCompareNewerLabel => 'Mais recente';

  @override
  String get hubCompareMetricsTitle => 'Comparação de Métricas Clínicas';

  @override
  String hubEmptyTitle(String category) {
    return 'Nenhum exame de $category ainda';
  }

  @override
  String get hubEmptySubtitle =>
      'Inicie seu primeiro exame acima. Cada registro fica salvo aqui por data com miniatura e relatório completo.';

  @override
  String get hubDoctorSummaryBtn => 'Resumo Médico';

  @override
  String get photoTapToZoomHint => 'Toque na foto para ampliar em tela cheia';

  @override
  String get photoZoomTitle => 'Foto Capturada';

  @override
  String get resultDeleteRecordTooltip => 'Excluir Registro';

  @override
  String get resultDeleteConfirmTitle => 'Excluir este exame?';

  @override
  String get resultDeleteConfirmBody =>
      'Este registro será removido permanentemente do seu histórico local.';

  @override
  String get resultDeleteBtn => 'Excluir';

  @override
  String get labLargeTextBtn => 'Texto Grande';

  @override
  String get labLargeTextOnBtn => 'Texto Grande: Sim';

  @override
  String get labSeniorOverviewTitle => 'Seu Resumo Simplificado';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count resultado(s) estão dentro da faixa normal.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count resultado(s) estão fora da referência — explicados de forma simples abaixo.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count resultado(s) estão bem fora dos limites — mostre ao seu médico em breve.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count exames básicos comuns não constam neste laudo.';
  }

  @override
  String get labAttentionSectionTitle => 'Valores que Merecem Atenção';

  @override
  String get labNormalSectionTitle => 'Valores Normais (Fique Tranquilo)';

  @override
  String get labMissingSectionTitle => 'Exames Não Incluídos Neste Laudo';

  @override
  String get labMissingSectionExplain =>
      'Nem todo pedido inclui todos os exames. Os exames comuns abaixo não aparecem neste relatório e não foram avaliados.';

  @override
  String get labNotInReportBadge => 'Não consta no laudo';

  @override
  String get labWhatItMeansLabel => 'O que significa?';

  @override
  String get labWhatToDoLabel => 'O que fazer?';

  @override
  String get labAddAnotherPageBtn => 'Fotografar Outra Página';

  @override
  String labPagesReadBadge(int count) {
    return '$count página(s) lida(s)';
  }

  @override
  String get labPhotoOfflineHint =>
      'Foto do laudo anexada. Ative a IA na Nuvem em Configurações para leitura automática ou adicione os valores manualmente abaixo.';

  @override
  String get labAllValuesNormalMsg =>
      'Todos os valores registrados neste laudo estão dentro da faixa normal.';

  @override
  String get medTitle => 'Lembretes e Alarmes de Medicação';

  @override
  String get medSubtitle => 'Acompanhe remédios, insulina e alarmes com foto';

  @override
  String get medMenuTitle => 'Alarmes de Medicação';

  @override
  String get medHomeCardEmpty =>
      'Sem alarmes ainda — adicione seu primeiro lembrete';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return '$taken/$total tomados hoje';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return '$count alarmes ativos';
  }

  @override
  String get medTabToday => 'Hoje';

  @override
  String get medTabAll => 'Todos os Alarmes';

  @override
  String get medAddAlarm => 'Novo Alarme';

  @override
  String get medEditAlarm => 'Editar Alarme';

  @override
  String get medCatPill => 'Remédio / Comprimido';

  @override
  String get medCatDiabetes => 'Diabetes / Insulina';

  @override
  String get medCatBloodPressure => 'Pressão Arterial';

  @override
  String get medCatVitamin => 'Vitamina / Suplemento';

  @override
  String get medCatDropsCream => 'Colírio / Creme';

  @override
  String get medCatCheckup => 'Medição / Controle';

  @override
  String get medCatOther => 'Outro';

  @override
  String get medMealAnytime => 'Qualquer horário';

  @override
  String get medMealBefore => 'Antes da refeição';

  @override
  String get medMealAfter => 'Após a refeição';

  @override
  String get medMealWith => 'Com a refeição';

  @override
  String get medMealBedtime => 'Antes de dormir';

  @override
  String get medDayMon => 'Seg';

  @override
  String get medDayTue => 'Ter';

  @override
  String get medDayWed => 'Qua';

  @override
  String get medDayThu => 'Qui';

  @override
  String get medDayFri => 'Sex';

  @override
  String get medDaySat => 'Sáb';

  @override
  String get medDaySun => 'Dom';

  @override
  String get medEveryDay => 'Todos os dias';

  @override
  String get medWeekdays => 'Dias úteis';

  @override
  String get medWeekends => 'Fins de semana';

  @override
  String get medFieldCategory => 'Categoria';

  @override
  String get medFieldName => 'Nome do remédio / lembrete';

  @override
  String get medFieldNameHint =>
      'Ex.: Metformina 1000 mg, Insulina da noite...';

  @override
  String get medFieldNameRequired => 'Informe o nome do remédio ou lembrete.';

  @override
  String get medFieldDosage => 'Dose / Quantidade (Opcional)';

  @override
  String get medFieldDosageHint => 'Ex.: 1 comprimido, 12 unidades, 2 gotas';

  @override
  String get medFieldDescription => 'Nota do lembrete (Aparece no alarme)';

  @override
  String get medFieldDescriptionHint =>
      'Ex.: Tomar 30 min antes do café com água';

  @override
  String get medFieldMealTiming => 'Horário com refeições';

  @override
  String get medFieldTime => 'Hora do alarme';

  @override
  String get medFieldDays => 'Dias de repetição';

  @override
  String get medFieldPhoto => 'Foto do remédio (Exibida ao tocar)';

  @override
  String get medTakePhoto => 'Tirar Foto';

  @override
  String get medPickGallery => 'Galeria';

  @override
  String get medRemovePhoto => 'Remover Foto';

  @override
  String get medPhotoHint =>
      'Fotografe a caixa ou caneta de insulina para vê-la em destaque quando o alarme tocar.';

  @override
  String get medSoundToggle => 'Som do alarme';

  @override
  String get medVibrateToggle => 'Vibração';

  @override
  String get medSaveAlarm => 'Salvar Alarme';

  @override
  String get medAlarmSaved => 'Alarme salvo e agendado.';

  @override
  String get medAlarmDeleted => 'Alarme excluído.';

  @override
  String get medDeleteConfirmTitle => 'Excluir Alarme';

  @override
  String medDeleteConfirmBody(String title) {
    return 'Excluir permanentemente o alarme \"$title\"?';
  }

  @override
  String get medStatusTaken => 'Tomado';

  @override
  String get medStatusSnoozed => 'Adiado';

  @override
  String get medStatusSkipped => 'Pulado';

  @override
  String get medStatusPending => 'Pendente';

  @override
  String get medActionTaken => 'Já tomei';

  @override
  String get medActionSnooze => 'Adiar 10 min';

  @override
  String get medActionSkip => 'Pular hoje';

  @override
  String get medActionUndo => 'Desfazer';

  @override
  String get medActionPreviewAlarm => 'Testar Alarme';

  @override
  String get medRingHeader => 'HORA DO REMÉDIO';

  @override
  String get medRingNoteTitle => 'Nota do lembrete';

  @override
  String get medRingNoPhoto => 'Sem foto do remédio';

  @override
  String get medRingTapZoom => 'Toque na foto para ampliar';

  @override
  String get medRingSnoozedToast => 'Adiado por 10 minutos.';

  @override
  String get medRingTakenToast => 'Ótimo! Dose de hoje marcada como tomada.';

  @override
  String get medTodayProgressTitle => 'Plano de medicação de hoje';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Próximo alarme: $time • $title';
  }

  @override
  String get medNoTodayAlarms =>
      'Nenhum alarme de medicação programado para hoje.';

  @override
  String get medEmptyTitle => 'Nenhum alarme ainda';

  @override
  String get medEmptyBody =>
      'Adicione alarmes com foto para diabetes, insulina ou pressão. Na hora certa, a foto do remédio e sua nota aparecem bem visíveis na tela.';

  @override
  String get medQuickPresetDiabetes => 'Diabetes / Insulina';

  @override
  String get medQuickPresetBp => 'Pressão';

  @override
  String get medQuickPresetVitamin => 'Vitamina';

  @override
  String get dietMenuTitle => 'Dieta e Calorias IA';

  @override
  String get dietHomeCardTitle => 'Dieta e Cardápios';

  @override
  String get dietHomeCardEmpty => 'Dietas prontas, adesão e peso';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'Dia $day/$total • $percent% adesão';
  }

  @override
  String get dietCalorieQuickTitle => 'Calcular Calorias do Prato IA';

  @override
  String get dietCalorieQuickSubtitle =>
      'Fotografe seu prato para ver calorias e macros';

  @override
  String get dietTabActive => 'Minha Dieta';

  @override
  String get dietTabTemplates => 'Modelos';

  @override
  String get dietTabWeight => 'Peso';

  @override
  String get dietTabCalories => 'Calorias IA';

  @override
  String get dietStartDiet => 'Iniciar Dieta';

  @override
  String get dietRestartOrChange => 'Trocar Dieta';

  @override
  String get dietEndDiet => 'Encerrar Dieta';

  @override
  String get dietEndDietConfirm =>
      'Encerrar seu plano ativo? O histórico de adesão e peso será mantido.';

  @override
  String get dietNoActiveTitle => 'Nenhuma dieta ativa ainda';

  @override
  String get dietNoActiveBody =>
      'Escolha um modelo pronto (Mediterrânea, Diabetes, DASH, Emagrecimento, Jejum 16:8, Proteica) e acompanhe adesão e peso.';

  @override
  String get dietBrowseTemplates => 'Ver Dietas Prontas';

  @override
  String get dietStartDate => 'Data de início';

  @override
  String get dietEndDate => 'Data de término';

  @override
  String get dietStartWeight => 'Peso inicial (kg)';

  @override
  String get dietTargetWeight => 'Peso meta (kg)';

  @override
  String get dietDailyCalorieTarget => 'Meta diária de calorias (kcal)';

  @override
  String dietDurationDays(int days) {
    return '$days dias';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'Dia $day de $total';
  }

  @override
  String dietDaysLeft(int days) {
    return 'Faltam $days dias';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Adesão: $percent%';
  }

  @override
  String get dietFollowed => 'Segui';

  @override
  String get dietNotFollowed => 'Não segui';

  @override
  String get dietPending => 'Pendente';

  @override
  String get dietSlotBreakfast => 'Café da manhã';

  @override
  String get dietSlotMorningSnack => 'Lanche da manhã';

  @override
  String get dietSlotLunch => 'Almoço';

  @override
  String get dietSlotAfternoonSnack => 'Lanche da tarde';

  @override
  String get dietSlotDinner => 'Jantar';

  @override
  String get dietAlternativesLabel => 'Alternativa';

  @override
  String dietWaterTarget(String liters) {
    return 'Meta de água: $liters L';
  }

  @override
  String get dietRulesTitle => 'Diretrizes do plano';

  @override
  String get dietSampleMenuTitle => 'Cardápio diário exemplo';

  @override
  String get dietStartedToast => 'Plano de dieta iniciado!';

  @override
  String get dietEndedToast => 'Plano de dieta encerrado.';

  @override
  String get dietWeightLogTitle => 'Acompanhamento de Peso';

  @override
  String get dietWeightAdd => 'Registrar Peso';

  @override
  String get dietWeightField => 'Peso atual (kg)';

  @override
  String get dietWeightNote => 'Nota (Opcional)';

  @override
  String get dietWeightNoteHint => 'Ex.: Pesagem em jejum pela manhã';

  @override
  String get dietWeightEmpty =>
      'Sem registros de peso ainda. Adicione o primeiro.';

  @override
  String get dietWeightCurrent => 'Atual';

  @override
  String get dietWeightTarget => 'Meta';

  @override
  String get dietWeightChange => 'Variação';

  @override
  String get dietWeightSaved => 'Peso salvo.';

  @override
  String get dietCalorieTitle => 'Calculadora de Calorias por Foto IA';

  @override
  String get dietCalorieSubtitle =>
      'Funciona com ou sem dieta — tire foto do prato ou descreva a refeição.';

  @override
  String get dietSnapPlateCamera => 'Foto do Prato';

  @override
  String get dietPickPlateGallery => 'Escolher da Galeria';

  @override
  String get dietFoodDescLabel => 'Descrição / Porção (Opcional)';

  @override
  String get dietFoodDescHint =>
      'Ex.: Frango grelhado, arroz integral, salada verde';

  @override
  String get dietCalculateFromText => 'Calcular pelo Texto';

  @override
  String get dietAnalyzingPlate => 'Analisando calorias e nutrientes...';

  @override
  String get dietResultTitle => 'Análise de Calorias e Macros';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Visão';

  @override
  String get dietOnDeviceBadge => 'Estimativa Local Inteligente';

  @override
  String get dietProtein => 'Proteína';

  @override
  String get dietCarbs => 'Carboidratos';

  @override
  String get dietFat => 'Gordura';

  @override
  String get dietFiber => 'Fibras';

  @override
  String get dietPortionScale => 'Tamanho da porção';

  @override
  String get dietSaveMealLog => 'Salvar no Registro de Hoje';

  @override
  String get dietMealLoggedToast => 'Calorias da refeição salvas.';

  @override
  String get dietTodayTotalCalories => 'Total de hoje';

  @override
  String get dietRecentScans => 'Refeições Analisadas';

  @override
  String get dietNoScansYet =>
      'Nenhuma refeição escaneada ainda. Tire foto do seu prato.';

  @override
  String dietHealthScore(int score) {
    return 'Equilíbrio: $score/10';
  }

  @override
  String get dietTodayLabel => 'Hoje';

  @override
  String get medCatHerbalTea => 'Chá de Ervas';

  @override
  String get medCatCustom => 'Outro (Manual)';

  @override
  String get medFieldCustomCategory => 'Nome da categoria personalizada';

  @override
  String get medFieldCustomCategoryHint =>
      'Ex.: Probiótico, Água, Fisioterapia...';

  @override
  String get medQuickPresetHerbalTea => 'Chá de Ervas';

  @override
  String get dietCreateCustom => 'Criar Minha Própria Dieta';

  @override
  String get dietCreateCustomSubtitle =>
      'Insira manualmente o cardápio do nutricionista ou o seu plano';

  @override
  String get dietCustomNameLabel => 'Nome da dieta';

  @override
  String get dietCustomNameHint =>
      'Ex.: Plano da nutricionista, Meu cardápio...';

  @override
  String get dietCustomNameRequired => 'Informe o nome da dieta.';

  @override
  String get dietCustomMealHint => 'O que você vai comer nesta refeição?';

  @override
  String get dietCustomMealCaloriesHint => 'kcal (opcional)';

  @override
  String get dietCustomAtLeastOneMeal => 'Informe pelo menos uma refeição.';

  @override
  String get dietCustomTemplatesTitle => 'Meus Planos Personalizados';

  @override
  String get dietReadyTemplatesTitle => 'Modelos de Dieta Prontos';

  @override
  String get donateTooltip => 'Apoiar / Doar';

  @override
  String get donateMenuLabel => 'Apoiar o VisualCheckUp';

  @override
  String get donateMenuSubtitle =>
      'Café, refeição ou presente para apoiar recursos de saúde';

  @override
  String get donatePopupTitle => 'Apoie o VisualCheckUp';

  @override
  String get donatePopupSubtitle =>
      'Seu apoio voluntário nos ajuda a manter gratuitos e evoluir os exames visuais, laudos, alarmes e dietas.';

  @override
  String get donateTierCoffeeTitle => 'Pagar um Café';

  @override
  String get donateTierCoffeeDesc => 'Um café quentinho para o desenvolvimento';

  @override
  String get donateTierMealTitle => 'Oferecer uma Refeição';

  @override
  String get donateTierMealDesc => 'Ótimo apoio para novos recursos de saúde';

  @override
  String get donateTierGiftTitle => 'Enviar um Presente';

  @override
  String get donateTierGiftDesc => 'Ajuda a cobrir custos de IA e servidores';

  @override
  String get donateTierGoldTitle => 'Grande Apoio';

  @override
  String get donateTierGoldDesc => 'Impulsiona novos módulos médicos e idiomas';

  @override
  String get donateTierHeroTitle => 'Herói da Saúde';

  @override
  String get donateTierHeroDesc =>
      'Apoia o acompanhamento gratuito para todas as famílias';

  @override
  String get donatePopularBadge => 'Popular';

  @override
  String donateConfirmButton(String price) {
    return 'Doar $price';
  }

  @override
  String get donateLaterButton => 'Mais Tarde';

  @override
  String get donateThanksTitle => 'Obrigado pelo seu Apoio!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'Sua contribuição $tier ($price) significa muito para nós. Obrigado por fazer o VisualCheckUp crescer!';
  }

  @override
  String get donateSupporterBadge => 'Apoiador • Obrigado!';

  @override
  String get donateStoreNotice => 'Apoio único voluntário • Sem assinatura';

  @override
  String get medFieldAlarmSound => 'Toque do alarme';

  @override
  String get medAlarmSoundClassic => 'Alarme clássico';

  @override
  String get medAlarmSoundClassicDesc => 'Toque nítido de despertador';

  @override
  String get medAlarmSoundGentle => 'Melodia suave';

  @override
  String get medAlarmSoundGentleDesc => 'Toque calmo e harmonioso';

  @override
  String get medAlarmSoundRadar => 'Alarme moderno';

  @override
  String get medAlarmSoundRadarDesc => 'Pulso rítmico bem audível';

  @override
  String get medAlarmSoundBell => 'Sino da saúde';

  @override
  String get medAlarmSoundBellDesc => 'Toque clássico de sino duplo';

  @override
  String get medAlarmSoundUrgent => 'Alerta urgente forte';

  @override
  String get medAlarmSoundUrgentDesc => 'Som intenso para doses importantes';

  @override
  String get medAlarmSoundSystem => 'Alarme do aparelho';

  @override
  String get medAlarmSoundSystemDesc =>
      'Usa o toque de alarme padrão do telefone';

  @override
  String get medSoundPreviewPlay => 'Ouvir';

  @override
  String get medSoundPreviewStop => 'Parar';

  @override
  String get medSoundSilent => 'Silencioso';

  @override
  String get medPreviewModeBadge => 'PRÉVIA';
}
