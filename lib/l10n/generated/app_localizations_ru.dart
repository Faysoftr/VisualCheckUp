// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'VisualCheckUp';

  @override
  String get disclaimerShort =>
      'Приложение не ставит медицинский диагноз; оно предназначено только для информации и визуального самоконтроля.';

  @override
  String get disclaimerTitle => 'Важное медицинское уведомление';

  @override
  String get disclaimerFull =>
      'VisualCheckUp выполняет предварительную визуальную оценку по цвету и внешним признакам. Это не медицинское изделие и оно не заменяет врача или лабораторные анализы.\n\n• Освещение и камера напрямую влияют на цветопередачу.\n• Немедленно обратитесь к врачу при сильной боли, кровотечении, высокой температуре, желтухе, черном/белом стуле или одышке.\n• Конфиденциальность: снимки по умолчанию обрабатываются локально на устройстве.';

  @override
  String get disclaimerAccept => 'Понятно';

  @override
  String get loginTagline =>
      'Персональный помощник для визуального наблюдения за кожей, родинками и подготовки к визиту к врачу.';

  @override
  String get featureColorCalibration => 'Калибровка цвета';

  @override
  String get featurePrivacyFirst => 'Приватность';

  @override
  String get featureOptionalAi => 'Опциональный ИИ';

  @override
  String get loginCardTitle => 'Войти в аккаунт';

  @override
  String get loginCardSubtitle =>
      'Сохраняйте личные цветовые ориентиры и историю проверок.';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get orDivider => 'или';

  @override
  String get continueAsGuest => 'Продолжить как гость';

  @override
  String get guestGreeting => 'Визуальный контроль здоровья';

  @override
  String userGreeting(String name) {
    return 'Здравствуйте, $name';
  }

  @override
  String accountTypeLabel(String provider) {
    return 'Аккаунт $provider';
  }

  @override
  String get localOnlyLabel => 'Хранится только на этом устройстве';

  @override
  String get menuHome => 'Главная';

  @override
  String get menuSectionVisualChecks => 'ВИЗУАЛЬНЫЕ ПРОВЕРКИ';

  @override
  String get menuSkinGroup => 'Кожа (Родинки, Бородавки, Синяки)';

  @override
  String get menuSkinGeneral => 'Общая кожа и сыпь';

  @override
  String get menuSectionTracking => 'ПЛАН, АНАЛИЗЫ И ПОКАЗАТЕЛИ';

  @override
  String get menuFollowUpPlan => 'Личный план наблюдения';

  @override
  String get menuVitalsTracker => 'Давление и сахар крови';

  @override
  String get menuLabReports => 'Анализы и выписки';

  @override
  String get menuQuickColorCard => 'Цветовая карта без камеры';

  @override
  String get menuHistory => 'История проверок';

  @override
  String get menuReferenceGuide => 'Визуальный справочник';

  @override
  String get menuSectionSettings => 'НАСТРОЙКИ И ПРИВАТНОСТЬ';

  @override
  String get menuAiSettings => 'ИИ и приватность';

  @override
  String get menuDisclaimer => 'Медицинское уведомление';

  @override
  String get menuTheme => 'Тема оформления';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get menuLanguage => 'Язык приложения';

  @override
  String get languageSystem => 'Язык системы';

  @override
  String get signInGoogleOrApple => 'Войти через Google или Apple';

  @override
  String get signOut => 'Выйти';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт и локальные данные';

  @override
  String get deleteAccountBody =>
      'Вы выйдете из аккаунта, а история проверок и локальные ориентиры на этом устройстве будут удалены навсегда. Продолжить?';

  @override
  String get cancel => 'Отмена';

  @override
  String get followUpCardTitle => 'Личный план наблюдения';

  @override
  String get followUpSelectEdit => 'Выбрать / Изменить';

  @override
  String get followUpStart => 'Начать';

  @override
  String get followUpEmptyHint =>
      'Нажмите, чтобы выбрать проверки глаз, мочи, давления, сахара и другие.';

  @override
  String get followUpSheetSubtitle =>
      'Отслеживайте глаза, язык, ногти, кожу, мочу, стул, давление, сахар и анализы в одном плане.';

  @override
  String followUpSummaryCounts(int active, int completed, int due) {
    return 'Активно: $active • Актуально: $completed • Ожидают: $due';
  }

  @override
  String get homeCategoriesTitle => 'Категории проверок';

  @override
  String get homeCategoriesSubtitle =>
      'Отслеживайте визуальные изменения с помощью камеры или цветовой карты.';

  @override
  String get homeLabsVitalsTitle => 'Анализы, давление и сахар';

  @override
  String get homeLabsVitalsSubtitle =>
      'Загружайте анализы крови и отслеживайте динамику давления и глюкозы.';

  @override
  String get homeLabsCardTitle => 'Анализы и отчеты';

  @override
  String get homeLabsCardEmpty => 'Чтение и оценка анализов';

  @override
  String homeLabsCardCount(int count) {
    return 'Сохранено отчетов: $count';
  }

  @override
  String get homeVitalsCardTitle => 'Давление и сахар';

  @override
  String get homeVitalsCardEmpty => 'Запись и графики трендов';

  @override
  String homeVitalsCardCount(int count) {
    return 'Сохранено замеров: $count';
  }

  @override
  String get homeRecentChecks => 'Последние проверки';

  @override
  String get seeAll => 'Показать все';

  @override
  String get catEyeTitle => 'Глаза (Склера)';

  @override
  String get catEyeSubtitle => 'Покраснение, желтушность и оттенок склеры';

  @override
  String get catNailTitle => 'Ногти';

  @override
  String get catNailSubtitle => 'Бледность, синюшность, желтизна и форма';

  @override
  String get catTongueTitle => 'Язык';

  @override
  String get catTongueSubtitle => 'Цвет, белый/желтый налет и текстура';

  @override
  String get catFaceTitle => 'Лицо и кожа';

  @override
  String get catFaceSubtitle => 'Тон кожи, бледность и покраснение';

  @override
  String get catSkinTitle => 'Состояние кожи';

  @override
  String get catSkinSubtitle => 'Родинки, бородавки, синяки, пятна и сыпь';

  @override
  String get catUrineTitle => 'Цвет мочи';

  @override
  String get catUrineSubtitle => 'Гидратация и цветовая шкала';

  @override
  String get catStoolTitle => 'Цвет стула';

  @override
  String get catStoolSubtitle => 'Пищеварение и цветовые предупреждения';

  @override
  String get tooltipHistory => 'История';

  @override
  String get tooltipAccountMenu => 'Аккаунт и меню';

  @override
  String get menuSettings => 'Настройки (Разрешения и Язык)';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguageDesc =>
      'По умолчанию используется язык телефона. Вы можете выбрать любой язык ниже.';

  @override
  String get settingsPermissionsTitle => 'Разрешения приложения';

  @override
  String get settingsPermissionsDesc =>
      'Проверьте и настройте доступ к камере и галерее.';

  @override
  String get settingsCameraPermission => 'Доступ к камере';

  @override
  String get settingsCameraPermissionDesc =>
      'Для съемки глаз, языка, ногтей и кожи';

  @override
  String get settingsPhotosPermission => 'Доступ к галерее и фото';

  @override
  String get settingsPhotosPermissionDesc =>
      'Для загрузки фотографий и анализов';

  @override
  String get settingsOpenSystemPermissions => 'Открыть разрешения на телефоне';

  @override
  String get permChecking => 'Проверка...';

  @override
  String get permGranted => 'Разрешено';

  @override
  String get permDenied => 'Требуется доступ';

  @override
  String get permPermanent => 'Включите в настройках системы';

  @override
  String get permUnavailable => 'Управляется устройством';

  @override
  String get permGrantBtn => 'Разрешить';

  @override
  String get permOpenSettingsBtn => 'Открыть настройки';

  @override
  String get skinCancerRisk => 'Родинки и риск меланомы';

  @override
  String get skinWart => 'Проверка бородавок';

  @override
  String get skinBruise => 'Отслеживание синяков';

  @override
  String get skinFacialSpot => 'Пятна на лице';

  @override
  String get trackEyeTitle => 'Еженедельная проверка глаз';

  @override
  String get trackEyeSubtitle => 'Отслеживайте покраснение или желтушность';

  @override
  String get trackTongueTitle => 'Еженедельная проверка языка';

  @override
  String get trackTongueSubtitle => 'Отслеживайте цвет, налет и текстуру';

  @override
  String get trackNailTitle => 'Еженедельная проверка ногтей';

  @override
  String get trackNailSubtitle =>
      'Следите за бледностью, синюшностью и желтизной';

  @override
  String get trackFaceTitle => 'Тон лица раз в 2 недели';

  @override
  String get trackFaceSubtitle => 'Сравнивайте бледность и покраснение лица';

  @override
  String get trackSkinTitle => 'Ежемесячный осмотр кожи и родинок';

  @override
  String get trackSkinSubtitle =>
      'Сравнивайте изменения родинок, бородавок и пятен за 30 дней';

  @override
  String get trackHydrationTitle => 'Ежедневная гидратация (моча)';

  @override
  String get trackHydrationSubtitle =>
      'Запишите за 2 секунды по цветовой карте без камеры';

  @override
  String get trackStoolTitle => 'Еженедельный контроль стула';

  @override
  String get trackStoolSubtitle =>
      'Отслеживайте пищеварение и цветовые сигналы';

  @override
  String get trackBpTitle => 'Ежедневное измерение давления';

  @override
  String get trackBpSubtitle => 'Записывайте давление и пульс';

  @override
  String get trackSugarTitle => 'Ежедневный контроль сахара';

  @override
  String get trackSugarSubtitle => 'Отслеживайте глюкозу натощак и после еды';

  @override
  String get trackLabTitle => 'Анализы крови раз в 3 месяца';

  @override
  String get trackLabSubtitle =>
      'Загружайте бланки анализов и сравнивайте динамику';

  @override
  String get statusFirstPending => 'Ожидается первая запись';

  @override
  String get statusDueNow => 'Пора выполнить проверку';

  @override
  String get statusDoneToday => 'Выполнено сегодня';

  @override
  String statusNextDays(int days) {
    return 'Следующая проверка через $days дн.';
  }

  @override
  String get actionCheckNow => 'Проверить';

  @override
  String get actionLogReading => 'Записать';

  @override
  String get actionAddReport => 'Добавить отчет';

  @override
  String checkMethodTitle(String category) {
    return '$category • Способ проверки';
  }

  @override
  String get checkMethodSubtitle =>
      'Выберите цвет за 2 секунды без фото или используйте камеру.';

  @override
  String get colorCardRecommendedTitle =>
      'Цветовая карта без камеры (Рекомендуется)';

  @override
  String get colorCardRecommendedSubtitle => 'Быстро и приватно без фото (2 с)';

  @override
  String get cameraMeasureTitle => 'Измерение камерой';

  @override
  String get cameraMeasureSubtitle => 'Автоматический замер с балансом белого';

  @override
  String get referenceGuideSubtitle =>
      'Выберите модуль для просмотра визуальных ориентиров.';

  @override
  String get historyEmpty => 'Сохраненных проверок пока нет.';

  @override
  String get filterAll => 'Все';

  @override
  String get aiSettingsTitle => 'ИИ и приватность';

  @override
  String get vitalsBpTab => 'Давление';

  @override
  String get vitalsSugarTab => 'Сахар крови';

  @override
  String get skinScreenTitle => 'Предварительный осмотр кожи';

  @override
  String get providerGuest => 'Гость';

  @override
  String signInFailed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String get riskNormal => 'Обычный вид';

  @override
  String get riskAttention => 'Рекомендуется наблюдение';

  @override
  String get riskUrgent => 'Рекомендуется осмотр врача';

  @override
  String recentSummaryFallback(String category, String status) {
    return '$category • $status';
  }

  @override
  String latestSummaryPrefix(String value) {
    return 'Последнее: $value';
  }

  @override
  String latestLabValuesSummary(int count, int abnormal) {
    return 'Последнее: $count показ. ($abnormal вне нормы)';
  }

  @override
  String latestLabAllNormal(int count) {
    return 'Последнее: $count показ. (все в норме)';
  }

  @override
  String get labStatusCriticalLow => 'Критически низкий';

  @override
  String get labStatusLow => 'Низкий';

  @override
  String get labStatusNormal => 'Норма';

  @override
  String get labStatusHigh => 'Высокий';

  @override
  String get labStatusCriticalHigh => 'Критически высокий';

  @override
  String get labSourceManual => 'Ручной ввод';

  @override
  String get labSourcePasted => 'Прочитано из текста';

  @override
  String get labSourcePhoto => 'Фото / JPG отчёт';

  @override
  String get labSourcePdf => 'PDF отчёт';

  @override
  String get bpLow => 'Низкое давление';

  @override
  String get bpNormal => 'В норме';

  @override
  String get bpElevated => 'Повышенное';

  @override
  String get bpStage1 => 'Повышенное (ст. 1)';

  @override
  String get bpStage2 => 'Высокое (ст. 2)';

  @override
  String get bpCrisis => 'Гипертонический криз';

  @override
  String get sugarLow => 'Низкий сахар';

  @override
  String get sugarNormal => 'В норме';

  @override
  String get sugarBorderline => 'Погранично высокий';

  @override
  String get sugarHigh => 'Высокий сахар';

  @override
  String get sugarVeryHigh => 'Очень высокий сахар';

  @override
  String get sugarTypeFasting => 'Натощак';

  @override
  String get sugarTypePostMeal => 'После еды (2 ч)';

  @override
  String get sugarTypeRandom => 'Случайный';

  @override
  String get specialtyEye => 'Офтальмология или терапия';

  @override
  String get specialtyNail => 'Дерматология или терапия';

  @override
  String get specialtyTongue => 'ЛОР, стоматология или терапия';

  @override
  String get specialtySkin => 'Дерматология';

  @override
  String get specialtyUrine => 'Урология или терапия';

  @override
  String get specialtyStool => 'Гастроэнтерология или терапия';

  @override
  String get cloudBackupTitle => 'Облачное копирование (по желанию • Firebase)';

  @override
  String get cloudBackupDesc =>
      'По умолчанию все анализы и измерения хранятся только на этом устройстве. Включите личное резервное копирование в аккаунт Google/Apple, чтобы сохранить данные при смене телефона.';

  @override
  String get cloudBackupToggleTitle => 'Включить облачное копирование';

  @override
  String cloudBackupLastSync(String date) {
    return 'Последнее копирование: $date';
  }

  @override
  String get cloudBackupEnabledReady => 'Включено • Готово к синхронизации';

  @override
  String get cloudBackupDisabledLocal => 'Выключено • Только на устройстве';

  @override
  String get cloudBackupSignInRequired =>
      'Войдите через Google или Apple для облачного копирования.';

  @override
  String get cloudBackupNowBtn => 'Сохранить сейчас';

  @override
  String get cloudRestoreBtn => 'Восстановить из облака';

  @override
  String get cloudConsentTitle => 'Согласие на облачное копирование';

  @override
  String get cloudConsentBody =>
      'Ваши анализы и измерения по умолчанию хранятся только на этом устройстве.\n\nПри включении облачного копирования данные сохраняются приватно в вашем аккаунте Google/Apple и полностью удаляются при удалении аккаунта.\n\nВы согласны?';

  @override
  String get cloudConsentConfirm => 'Да, включить';

  @override
  String cloudBackupSuccess(int count) {
    return 'Копирование завершено: синхронизировано $count зап.';
  }

  @override
  String cloudBackupFailed(String error) {
    return 'Ошибка копирования: $error';
  }

  @override
  String cloudRestoreSuccess(int count) {
    return 'Восстановлено из облака: $count зап.';
  }

  @override
  String cloudRestoreFailed(String error) {
    return 'Ошибка восстановления: $error';
  }

  @override
  String get cloudBackupDisabledNotice =>
      'Облачное копирование выключено. Новые записи хранятся только локально.';

  @override
  String get aiCloudToggleTitle => 'Облачный ИИ-анализ (Gemini)';

  @override
  String get aiCloudOnDesc =>
      'Вкл.: Чёткие фото сжимаются и анализируются по защищённому каналу. Без сети работает локальный анализ.';

  @override
  String get aiCloudOffDesc =>
      'Выкл. (0 токенов): Весь анализ выполняется только на устройстве; фото никуда не отправляются.';

  @override
  String get aiBackendOfflineNote =>
      'После подключения ключа Gemini / Firebase AI облачный анализ заработает автоматически; сейчас активен локальный движок.';

  @override
  String get aiOptimizationsTitle => 'Активная экономия токенов и трафика';

  @override
  String get aiOptQualityGate =>
      'Проверка резкости, света и бликов без токенов';

  @override
  String get aiOptCompression => 'Автообрезка + сжатие JPEG 512/768px (80%)';

  @override
  String get aiOptTieredModel => 'Умный выбор модели (Flash-Lite / Flash)';

  @override
  String get aiOptHashCache => 'Локальный кэш повторных фото (0 токенов)';

  @override
  String get aiClearCacheBtn => 'Очистить кэш ИИ';

  @override
  String get aiCacheCleared => 'Кэш ИИ очищен.';

  @override
  String resultScreenTitle(String category) {
    return 'Результат: $category';
  }

  @override
  String get tooltipDoctorSummary => 'Сводка для врача';

  @override
  String get tooltipReferenceGuide => 'Справочник';

  @override
  String get calibratedColorTone => 'Калиброванный тон';

  @override
  String get sampledColorTone => 'Измеренный основной тон';

  @override
  String confidenceLabel(int percent) {
    return 'Уверенность оценки: $percent%';
  }

  @override
  String get whiteBalanceDefaultNote => 'Цвет откалиброван по белому эталону.';

  @override
  String recommendedSpecialtyLabel(String specialty) {
    return 'Рекомендуемый специалист: $specialty';
  }

  @override
  String get timelineComparisonTitle => 'Изменения со временем';

  @override
  String get todayLabel => 'Сегодня';

  @override
  String previousRecordSummary(String title, String status, int count) {
    return 'Предыдущая запись: «$title» ($status). Всего записей: $count.';
  }

  @override
  String get personalBaselineComparisonTitle => 'Сравнение с вашей нормой';

  @override
  String get yourBaselineLabel => 'Ваша норма';

  @override
  String get warningFlagsTitle => 'Тревожные признаки';

  @override
  String get observationsTitle => 'Наблюдения';

  @override
  String get recommendationsTitle => 'Рекомендации';

  @override
  String get personalBaselineCardTitle => 'Личная калибровка нормы';

  @override
  String get personalBaselineCardDesc =>
      'Сохраните это измерение в здоровый день как личный эталон для уменьшения погрешности камеры.';

  @override
  String get saveBaselineBtn => 'Сохранить как мою норму';

  @override
  String get updateBaselineBtn => 'Обновить мою норму';

  @override
  String get clearBaselineBtn => 'Удалить';

  @override
  String baselineSavedMsg(String category) {
    return 'Личная норма для «$category» сохранена.';
  }

  @override
  String baselineClearedMsg(String category) {
    return 'Личная норма для «$category» удалена.';
  }

  @override
  String get doctorSummaryBtn => 'Показать врачу • Сводка';

  @override
  String get returnHomeBtn => 'На главную';

  @override
  String get doctorSheetTitle => 'Сводка для визита к врачу';

  @override
  String colorLabel(String hex, String status) {
    return 'Цвет: $hex • $status';
  }

  @override
  String get timelineHistoryTitle => 'Хронология предыдущих записей';

  @override
  String get questionsForDoctorTitle => 'Вопросы для врача';

  @override
  String get copyShareSummaryBtn => 'Скопировать и поделиться';

  @override
  String get doctorSummaryCopied => 'Сводка для врача скопирована.';

  @override
  String referenceSheetTitle(String category) {
    return '$category — Визуальный справочник';
  }

  @override
  String get healthyReferenceLabel => 'Здоровый ориентир';

  @override
  String get captureChecklistTitle => 'Советы по съёмке';

  @override
  String get abnormalFindingsTitle => 'Признаки, требующие внимания';

  @override
  String get cameraPermPermanentMsg =>
      'Доступ к камере отключён в настройках. Включите его или выберите фото из галереи.';

  @override
  String get cameraPermRequiredMsg =>
      'Для визуальной проверки нужен доступ к камере. Изображения обрабатываются локально.';

  @override
  String get cameraGrantPermTitle => 'Нужен доступ к камере';

  @override
  String get cameraRequestPermBtn => 'Разрешить камеру';

  @override
  String get cameraPickGalleryBtn => 'Выбрать из галереи';

  @override
  String get cameraWhiteRefOn => 'Белый эталон: Вкл.';

  @override
  String get cameraWhiteRefOff => 'Белый эталон: Выкл.';

  @override
  String get cameraBaselineActive => 'Эталон сохранён';

  @override
  String get cameraAnalyzing => 'Анализ...';

  @override
  String get cameraCaptureBtn => 'Снять и оценить';

  @override
  String cameraAnalysisFailed(String error) {
    return 'Ошибка анализа: $error';
  }

  @override
  String quickCardTitle(String category) {
    return '$category • Цветовая карта';
  }

  @override
  String get quickCardPrivacyBanner =>
      'Без камеры: выберите ближайший оттенок для быстрой и приватной записи за 2 секунды.';

  @override
  String get quickCardChooseShade => 'Выберите ближайший оттенок';

  @override
  String get quickCardExtraContext => 'Доп. сведения (по желанию)';

  @override
  String get quickCardSaveViewBtn => 'Сохранить и посмотреть';

  @override
  String get quickCardUseCameraBtn => 'Использовать камеру';

  @override
  String get skinIntroTitle => 'Визуальный дерматологический скрининг';

  @override
  String get skinIntroDesc =>
      'Сравнивает родинки, бородавки, синяки и пятна с окружающей кожей. Не является диагнозом; помогает подготовиться к врачу.';

  @override
  String get skinStep1Title => '1. Выберите модуль проверки кожи';

  @override
  String get skinOtherConcernsLabel => 'Другие проявления';

  @override
  String get skinStep2Title => '2. Сопутствующие симптомы (необязательно)';

  @override
  String get skinStep3Title => '3. Область тела (необязательно)';

  @override
  String get skinStartCameraBtn => 'Начать проверку кожи камерой';

  @override
  String get skinConcernRash => 'Покраснение / Сыпь';

  @override
  String get skinConcernMole => 'Родинка / Тёмное пятно';

  @override
  String get skinConcernScaly => 'Шелушение / Сухая бляшка';

  @override
  String get skinConcernBlister => 'Пузырьки / Акне';

  @override
  String get skinConcernGeneral => 'Общая проверка кожи';

  @override
  String get bodyAreaFaceNeck => 'Лицо / Шея';

  @override
  String get bodyAreaArmHand => 'Рука / Кисть';

  @override
  String get bodyAreaTorso => 'Туловище';

  @override
  String get bodyAreaLegFoot => 'Нога / Стопа';

  @override
  String get bodyAreaScalp => 'Кожа головы';

  @override
  String get bodyAreaOther => 'Другое';

  @override
  String get symptomItching => 'Зуд';

  @override
  String get symptomPainWarmth => 'Боль / Жар';

  @override
  String get symptomRapidChange => 'Быстрый рост / изменение';

  @override
  String get symptomBleeding => 'Кровоточивость / Мокнутие';

  @override
  String get symptomSpreading => 'Быстро распространяется';

  @override
  String get symptomFever => 'Есть температура';

  @override
  String get symptomNonHealing => 'Незаживающая рана (4+ нед.)';

  @override
  String get symptomOver6mm => 'Более 6 мм или неровный край';

  @override
  String get symptomNoTrauma => 'Появился без удара';

  @override
  String get symptomRoughDots => 'Шероховатость / чёрные точки';

  @override
  String get symptomSunHormone => 'Солнечное/гормональное пятно';

  @override
  String get bruiseGuideTitle => 'Стадии цвета синяка';

  @override
  String get wartGuideTitle => 'Памятка по бородавкам';

  @override
  String get abcdeGuideTitle => 'Правило ABCDE для родинок';

  @override
  String get abcdeGuideSubtitle => '5 ключевых признаков для оценки родинок';

  @override
  String get labScreenTitle => 'Анализы и отчёты';

  @override
  String get labTabReports => 'Мои отчёты';

  @override
  String get labTabTrends => 'Динамика';

  @override
  String get labAddBtn => 'Добавить анализ';

  @override
  String get labEmptyTitle => 'Сохранённых анализов пока нет';

  @override
  String get labEmptyDesc =>
      'Загрузите PDF или JPG анализа; при желании добавьте диагноз или жалобу для понятного обзора.';

  @override
  String get labAddFirstBtn => 'Добавить первый отчёт';

  @override
  String get labTrendsEmptyDesc =>
      'Сохраняйте анализы за разные даты, чтобы видеть графики динамики гемоглобина, ферритина, глюкозы, ТТГ и др.';

  @override
  String labParamsCount(int count) {
    return '$count показ.';
  }

  @override
  String labOutOfRangeCount(int count) {
    return '$count вне нормы';
  }

  @override
  String labDetailParamsTitle(int count) {
    return 'Оценка показателей ($count)';
  }

  @override
  String get labEnteredDiagnosisTitle => 'Диагноз врача / больницы';

  @override
  String get labEnteredComplaintTitle => 'Ваша жалоба / заметка';

  @override
  String get labInterpretationTitle => 'Понятное пояснение';

  @override
  String get labCopyDoctorSummaryBtn => 'Показать врачу • Копировать';

  @override
  String get labSummaryCopied => 'Сводка анализов скопирована.';

  @override
  String get labExportPdfBtn => 'Экспорт PDF для врача';

  @override
  String get labAddSheetTitle => 'Добавить анализ / отчёт';

  @override
  String get labReportTitleField => 'Название отчёта';

  @override
  String get labDefaultReportTitle => 'Результат анализа крови';

  @override
  String get labStep1Upload => '1. Загрузить PDF или JPG';

  @override
  String get labUploadPdfJpgBtn => 'Загрузить PDF / JPG';

  @override
  String get labCameraCaptureBtn => 'Сфотографировать';

  @override
  String get labStep2Context => '2. Диагноз и заметка (необязательно)';

  @override
  String get labStep2ContextHint =>
      'Укажите диагноз или жалобы, если нужно пояснение; оба поля можно оставить пустыми.';

  @override
  String get labDiagnosisField => 'Диагноз врача (необязательно)';

  @override
  String get labComplaintField => 'Жалобы / вопрос (необязательно)';

  @override
  String get labStep3PasteManual => '3. Вставить текст или добавить значения';

  @override
  String get labParseTextBtn => 'Распознать текст';

  @override
  String get labParamDropdown => 'Показатель';

  @override
  String labValueField(String unit) {
    return 'Значение ($unit)';
  }

  @override
  String get labAddValueBtn => '+ Добавить';

  @override
  String labParsedValuesTitle(int count) {
    return 'Распознано ($count)';
  }

  @override
  String get labSaveEvaluateBtn => 'Оценить и сохранить';

  @override
  String labTrendSummary(int count, String delta, String status) {
    return 'Записей: $count • Изм.: $delta • Посл.: $status';
  }

  @override
  String get vitalsScreenTitle => 'Давление и сахар';

  @override
  String get vitalsCopySummaryTooltip => 'Скопировать сводку для врача';

  @override
  String get vitalsCopyEmptyMsg =>
      'Сначала добавьте измерение давления или сахара.';

  @override
  String get vitalsSummaryCopied => 'Сводка давления и сахара скопирована.';

  @override
  String get vitalsAddBpBtn => 'Добавить давление';

  @override
  String get vitalsAddSugarBtn => 'Добавить сахар';

  @override
  String get vitalsBpEmptyTitle => 'Измерений давления пока нет';

  @override
  String get vitalsBpEmptyDesc =>
      'Записывайте давление и пульс с датой, чтобы отслеживать график динамики.';

  @override
  String get vitalsBpAddFirstBtn => 'Добавить первое измерение';

  @override
  String get vitalsSugarEmptyTitle => 'Измерений сахара пока нет';

  @override
  String get vitalsSugarEmptyDesc =>
      'Записывайте сахар натощак, после еды или случайный для отслеживания динамики.';

  @override
  String get vitalsSugarAddFirstBtn => 'Добавить первое измерение';

  @override
  String vitalsBpAverage(int count, int sys, int dia) {
    return 'Среднее ($count): $sys/$dia mmHg';
  }

  @override
  String vitalsLastPulse(int pulse) {
    return ' • Пульс $pulse';
  }

  @override
  String get vitalsBpHistoryTitle => 'История измерений давления';

  @override
  String vitalsSugarAverage(int count, int avg) {
    return 'Среднее ($count): $avg mg/dL';
  }

  @override
  String get vitalsSugarHistoryTitle => 'История измерений сахара';

  @override
  String get vitalsNewBpTitle => 'Новое измерение давления';

  @override
  String get vitalsSystolicField => 'Верхнее (систол.)';

  @override
  String get vitalsDiastolicField => 'Нижнее (диастол.)';

  @override
  String get vitalsPulseField => 'Пульс (необязательно)';

  @override
  String get vitalsNoteField => 'Заметка (необязательно)';

  @override
  String get vitalsSaveBpBtn => 'Сохранить давление';

  @override
  String get vitalsNewSugarTitle => 'Новое измерение сахара';

  @override
  String get vitalsSugarValueField => 'Сахар крови (мг/дл)';

  @override
  String get vitalsSaveSugarBtn => 'Сохранить сахар';

  @override
  String get chartAddReadingHint => 'Добавьте измерения для графика';

  @override
  String get loginTermsTitle =>
      'Условия использования и медицинское предупреждение';

  @override
  String get loginTermsCheckbox =>
      'Я понимаю, что VisualCheckUp не ставит точный медицинский диагноз, предназначен только для предварительного ознакомления, и принимаю Условия использования.';

  @override
  String get loginTermsRequiredMsg =>
      'Пожалуйста, примите Условия использования и медицинское предупреждение перед входом.';

  @override
  String get loginTermsReadMore => 'Читать условия';

  @override
  String get loginTermsModalBody =>
      '• Не является диагнозом: VisualCheckUp не является медицинским прибором и не заменяет осмотр и лечение у врача.\n\n• Только для информации: Визуальные проверки, сводки анализов и шкалы ИМТ/роста предназначены для личного наблюдения и подготовки к визиту к врачу.\n\n• Экстренные случаи: При сильной боли в груди, одышке или острых симптомах немедленно обратитесь за скорой помощью.\n\n• Конфиденциальность: По умолчанию все данные хранятся только на вашем устройстве.';

  @override
  String get loginTermsAcceptBtn => 'Прочитал(а) и принимаю';

  @override
  String atlasFilterAll(int count) {
    return 'Иллюстрированный атлас ($count)';
  }

  @override
  String atlasFilterUrgent(int count) {
    return 'Срочные признаки ($count)';
  }

  @override
  String atlasFilterSelfTests(int count) {
    return 'Домашние тесты ($count)';
  }

  @override
  String get atlasUrgentSectionTitle =>
      'Признаки, требующие скорой оценки врача';

  @override
  String get atlasTapToCompareHint =>
      'Нажмите на любую карточку, чтобы увеличить и сравнить со здоровым эталоном.';

  @override
  String get atlasVisualCueLabel => 'Визуальный признак';

  @override
  String get atlasClinicalContextLabel => 'Возможный клинический контекст';

  @override
  String get atlasPossibleContextShort => 'Возможный контекст';

  @override
  String get atlasWarningPrefix => 'Внимание';

  @override
  String get atlasCloseBtn => 'Закрыть';

  @override
  String get atlasCaptureProtocolTitle => 'Оптимальный протокол съёмки';

  @override
  String get atlasHomeSelfTestsSectionTitle =>
      'Предварительные клинические тесты дома';

  @override
  String get atlasSelfTestNormalPrefix => 'Норма';

  @override
  String get atlasSelfTestWarningPrefix => 'Внимание';

  @override
  String get fitzpatrickScaleTitle => 'Фототипы кожи Фитцпатрика и шкала ITA°';

  @override
  String get fitzpatrickScaleSubtitle =>
      'Приложение измеряет угол ITA° окружающей здоровой кожи и адаптирует пороги анализа под ваш фототип.';

  @override
  String get resultVisualCompareTitle =>
      'Сравнение с иллюстрированным клиническим эталоном';

  @override
  String get resultHealthyShort => 'Здоровый';

  @override
  String get resultMatchedShort => 'Совпадение';

  @override
  String get resultViewFullAtlasBtn => 'Открыть весь атлас';

  @override
  String get resultHomeSelfTestsBtn => 'Домашние тесты';

  @override
  String get resultClinicalBiomarkersTitle =>
      'Количественные клинические измерения';

  @override
  String get cameraEyeModeSclera => 'Режим: Склера (Желтуха)';

  @override
  String get cameraEyeModeConjunctiva => 'Нижнее веко (Анемия)';

  @override
  String get cameraClinicalAtlasChip => 'Тесты и Атлас';

  @override
  String get bristolScaleTitle =>
      'Бристольская шкала стула (необязательно • Типы 1–7)';

  @override
  String get bristolType1Title => 'Тип 1 • Твёрдые комки';

  @override
  String get bristolType2Title => 'Тип 2 • Комковатая форма';

  @override
  String get bristolType3Title => 'Тип 3 • С трещинами';

  @override
  String get bristolType4Title => 'Тип 4 • Гладкий (Идеал)';

  @override
  String get bristolType5Title => 'Тип 5 • Мягкие кусочки';

  @override
  String get bristolType6Title => 'Тип 6 • Кашицеобразный';

  @override
  String get bristolType7Title => 'Тип 7 • Полностью жидкий';

  @override
  String get metricFitzpatrickPhototype => 'Фототип Фитцпатрика';

  @override
  String get metricAbcdeAsymmetry => 'A — Асимметрия';

  @override
  String get metricAbcdeBorder => 'B — Неровность границ';

  @override
  String get metricAbcdeColors => 'C — Дерматоскопические цвета';

  @override
  String get metricErythemaDelta => 'Индекс эритемы Δ';

  @override
  String get metricAnnularClearing => 'Кольцевидное просветление центра';

  @override
  String get metricErythemaIndex => 'Индекс эритемы (EI)';

  @override
  String get metricScleraBilirubin => 'Индекс билирубина склеры';

  @override
  String get metricHemorrhagePatch => 'Зона плотного кровоизлияния';

  @override
  String get metricNailErythema => 'Индекс эритемы ногтевого ложа';

  @override
  String get metricBeauGroove => 'Поперечная борозда Бо';

  @override
  String get metricTerryLindsaySplit => 'Проксимально-дистальный контраст';

  @override
  String get metricSplinterStreak => 'Доля подногтевых полосок';

  @override
  String get metricGeographicTongue => 'Индекс географического языка';

  @override
  String get metricYellowCoating => 'Доля жёлтого налёта';

  @override
  String get metricBristolScale => 'Шкала Бристоля';

  @override
  String get hubStartNewScan => 'Начать новое сканирование';

  @override
  String get hubPickFromGallery => 'Галерея';

  @override
  String hubPastScansTitle(int count) {
    return 'Прошлые проверки ($count)';
  }

  @override
  String get hubTotalScansLabel => 'Всего проверок';

  @override
  String get hubLastScanLabel => 'Последняя';

  @override
  String get hubLatestStatusLabel => 'Последний статус';

  @override
  String get hubFilterAll => 'Все';

  @override
  String get hubFilterAttention => 'Внимание / Срочно';

  @override
  String get hubFilterWithPhoto => 'С фото';

  @override
  String get hubColPhoto => 'Фото';

  @override
  String get hubColDate => 'Дата';

  @override
  String get hubColFinding => 'Результат и сводка';

  @override
  String get hubColStatus => 'Статус';

  @override
  String get hubCompareModeBtn => 'Сравнить 2 проверки';

  @override
  String hubCompareSelectHint(int count) {
    return 'Выберите 2 проверки в таблице для сравнения рядом ($count/2)';
  }

  @override
  String get hubCompareActionBtn => 'Сравнить рядом';

  @override
  String get hubCompareCancelBtn => 'Отмена';

  @override
  String get hubCompareSheetTitle => 'Сравнение проверок рядом';

  @override
  String get hubCompareOlderLabel => 'Ранее';

  @override
  String get hubCompareNewerLabel => 'Позже';

  @override
  String get hubCompareMetricsTitle => 'Сравнение клинических показателей';

  @override
  String hubEmptyTitle(String category) {
    return 'Проверок «$category» пока нет';
  }

  @override
  String get hubEmptySubtitle =>
      'Начните первую проверку выше. Каждая запись сохраняется здесь по дате с миниатюрой фото и полным отчётом.';

  @override
  String get hubDoctorSummaryBtn => 'Сводка врачу';

  @override
  String get photoTapToZoomHint =>
      'Нажмите на фото для увеличения на весь экран';

  @override
  String get photoZoomTitle => 'Сделанное фото';

  @override
  String get resultDeleteRecordTooltip => 'Удалить запись';

  @override
  String get resultDeleteConfirmTitle => 'Удалить эту проверку?';

  @override
  String get resultDeleteConfirmBody =>
      'Запись проверки будет безвозвратно удалена из локальной истории.';

  @override
  String get resultDeleteBtn => 'Удалить';

  @override
  String get labLargeTextBtn => 'Крупный шрифт';

  @override
  String get labLargeTextOnBtn => 'Крупный шрифт: Вкл';

  @override
  String get labSeniorOverviewTitle => 'Краткий итог простыми словами';

  @override
  String labSeniorNormalBullet(int count) {
    return '$count показател(ей) находятся в пределах нормы.';
  }

  @override
  String labSeniorAbnormalBullet(int count) {
    return '$count показател(ей) выходят за пределы нормы — простое объяснение ниже.';
  }

  @override
  String labSeniorCriticalBullet(int count) {
    return '$count показател(ей) заметно отклоняются от нормы — покажите отчёт врачу в ближайшее время.';
  }

  @override
  String labSeniorMissingBullet(int count) {
    return '$count базовых анализов отсутствуют в этом бланке.';
  }

  @override
  String get labAttentionSectionTitle =>
      'Показатели, на которые стоит обратить внимание';

  @override
  String get labNormalSectionTitle => 'Показатели в норме';

  @override
  String get labMissingSectionTitle =>
      'Базовые анализы, которых нет в этом отчёте';

  @override
  String get labMissingSectionExplain =>
      'Не в каждом анализе крови назначают все показатели. Перечисленные ниже базовые тесты отсутствуют в загруженном бланке.';

  @override
  String get labNotInReportBadge => 'Нет в отчёте';

  @override
  String get labWhatItMeansLabel => 'Что это означает?';

  @override
  String get labWhatToDoLabel => 'Что рекомендуется сделать?';

  @override
  String get labAddAnotherPageBtn => 'Снять ещё страницу';

  @override
  String labPagesReadBadge(int count) {
    return 'Прочитано страниц: $count';
  }

  @override
  String get labPhotoOfflineHint =>
      'Фото бланка прикреплено. Включите облачный ИИ в Настройках для автоматического чтения фото или введите значения вручную ниже.';

  @override
  String get labAllValuesNormalMsg =>
      'Все записанные показатели в этом отчёте находятся в пределах нормы.';

  @override
  String get medTitle => 'Напоминания и будильник лекарств';

  @override
  String get medSubtitle =>
      'Таблетки, инсулин и замеры с фото на экране будильника';

  @override
  String get medMenuTitle => 'Будильник лекарств';

  @override
  String get medHomeCardEmpty =>
      'Пока нет будильников — добавьте первое напоминание';

  @override
  String medHomeCardTodaySummary(int taken, int total) {
    return 'Сегодня принято: $taken/$total';
  }

  @override
  String medHomeCardActiveCount(int count) {
    return 'Активных будильников: $count';
  }

  @override
  String get medTabToday => 'Сегодня';

  @override
  String get medTabAll => 'Все будильники';

  @override
  String get medAddAlarm => 'Новый будильник';

  @override
  String get medEditAlarm => 'Изменить будильник';

  @override
  String get medCatPill => 'Лекарство / Таблетки';

  @override
  String get medCatDiabetes => 'Диабет / Инсулин';

  @override
  String get medCatBloodPressure => 'От давления';

  @override
  String get medCatVitamin => 'Витамины / БАД';

  @override
  String get medCatDropsCream => 'Капли / Крем';

  @override
  String get medCatCheckup => 'Замер / Контроль';

  @override
  String get medCatOther => 'Другое';

  @override
  String get medMealAnytime => 'В любое время';

  @override
  String get medMealBefore => 'До еды';

  @override
  String get medMealAfter => 'После еды';

  @override
  String get medMealWith => 'Во время еды';

  @override
  String get medMealBedtime => 'Перед сном';

  @override
  String get medDayMon => 'Пн';

  @override
  String get medDayTue => 'Вт';

  @override
  String get medDayWed => 'Ср';

  @override
  String get medDayThu => 'Чт';

  @override
  String get medDayFri => 'Пт';

  @override
  String get medDaySat => 'Сб';

  @override
  String get medDaySun => 'Вс';

  @override
  String get medEveryDay => 'Каждый день';

  @override
  String get medWeekdays => 'Будни';

  @override
  String get medWeekends => 'Выходные';

  @override
  String get medFieldCategory => 'Категория';

  @override
  String get medFieldName => 'Название лекарства / напоминания';

  @override
  String get medFieldNameHint =>
      'Напр.: Метформин 1000 мг, Вечерний инсулин...';

  @override
  String get medFieldNameRequired =>
      'Введите название лекарства или напоминания.';

  @override
  String get medFieldDosage => 'Дозировка (необязательно)';

  @override
  String get medFieldDosageHint => 'Напр.: 1 таблетка, 12 ЕД, 2 капли';

  @override
  String get medFieldDescription => 'Пояснение (покажется на будильнике)';

  @override
  String get medFieldDescriptionHint =>
      'Напр.: Принять за 30 мин до завтрака, запивая водой';

  @override
  String get medFieldMealTiming => 'Приём относительно еды';

  @override
  String get medFieldTime => 'Время будильника';

  @override
  String get medFieldDays => 'Дни повторения';

  @override
  String get medFieldPhoto => 'Фото лекарства (покажется при звонке)';

  @override
  String get medTakePhoto => 'Сделать фото';

  @override
  String get medPickGallery => 'Из галереи';

  @override
  String get medRemovePhoto => 'Удалить фото';

  @override
  String get medPhotoHint =>
      'Сфотографируйте упаковку или шприц-ручку, чтобы увидеть её крупно при срабатывании.';

  @override
  String get medSoundToggle => 'Звук будильника';

  @override
  String get medVibrateToggle => 'Вибрация';

  @override
  String get medSaveAlarm => 'Сохранить будильник';

  @override
  String get medAlarmSaved => 'Будильник сохранён и запланирован.';

  @override
  String get medAlarmDeleted => 'Будильник удалён.';

  @override
  String get medDeleteConfirmTitle => 'Удалить будильник';

  @override
  String medDeleteConfirmBody(String title) {
    return 'Удалить будильник «$title» навсегда?';
  }

  @override
  String get medStatusTaken => 'Принято';

  @override
  String get medStatusSnoozed => 'Отложено';

  @override
  String get medStatusSkipped => 'Пропущено';

  @override
  String get medStatusPending => 'Ожидается';

  @override
  String get medActionTaken => 'Принял(а)';

  @override
  String get medActionSnooze => 'Отложить 10 мин';

  @override
  String get medActionSkip => 'Пропустить сегодня';

  @override
  String get medActionUndo => 'Отменить';

  @override
  String get medActionPreviewAlarm => 'Проверить будильник';

  @override
  String get medRingHeader => 'ВРЕМЯ ПРИЁМА ЛЕКАРСТВА';

  @override
  String get medRingNoteTitle => 'Заметка к напоминанию';

  @override
  String get medRingNoPhoto => 'Фото лекарства не добавлено';

  @override
  String get medRingTapZoom => 'Нажмите на фото, чтобы увеличить';

  @override
  String get medRingSnoozedToast => 'Отложено на 10 минут.';

  @override
  String get medRingTakenToast => 'Отлично! Сегодняшний приём отмечен.';

  @override
  String get medTodayProgressTitle => 'Приём лекарств сегодня';

  @override
  String medNextAlarmLabel(String time, String title) {
    return 'Следующий будильник: $time • $title';
  }

  @override
  String get medNoTodayAlarms =>
      'На сегодня будильники лекарств не запланированы.';

  @override
  String get medEmptyTitle => 'Будильников пока нет';

  @override
  String get medEmptyBody =>
      'Добавьте будильники с фото для таблеток от сахара, инсулина или давления. В нужное время фото и заметка появятся крупно на экране.';

  @override
  String get medQuickPresetDiabetes => 'Сахар / Инсулин';

  @override
  String get medQuickPresetBp => 'От давления';

  @override
  String get medQuickPresetVitamin => 'Витамины';

  @override
  String get dietMenuTitle => 'Диета и ИИ-калории';

  @override
  String get dietHomeCardTitle => 'Диета и Питание';

  @override
  String get dietHomeCardEmpty => 'Готовые диеты, соблюдение и вес';

  @override
  String dietHomeCardActive(int day, int total, int percent) {
    return 'День $day/$total • $percent% соблюдения';
  }

  @override
  String get dietCalorieQuickTitle => 'ИИ-подсчёт калорий по фото';

  @override
  String get dietCalorieQuickSubtitle =>
      'Сфотографируйте тарелку — узнайте калории и БЖУ';

  @override
  String get dietTabActive => 'Моя диета';

  @override
  String get dietTabTemplates => 'Шаблоны';

  @override
  String get dietTabWeight => 'Вес';

  @override
  String get dietTabCalories => 'ИИ Калории';

  @override
  String get dietStartDiet => 'Начать диету';

  @override
  String get dietRestartOrChange => 'Сменить диету';

  @override
  String get dietEndDiet => 'Завершить диету';

  @override
  String get dietEndDietConfirm =>
      'Завершить активную диету? История соблюдения и веса сохранится.';

  @override
  String get dietNoActiveTitle => 'Нет активной диеты';

  @override
  String get dietNoActiveBody =>
      'Выберите готовый шаблон диеты (Средиземноморская, Диабет, DASH, Похудение, 16:8, Белковая) и отслеживайте рацион и вес.';

  @override
  String get dietBrowseTemplates => 'Выбрать диету';

  @override
  String get dietStartDate => 'Дата начала';

  @override
  String get dietEndDate => 'Дата окончания';

  @override
  String get dietStartWeight => 'Начальный вес (кг)';

  @override
  String get dietTargetWeight => 'Целевой вес (кг)';

  @override
  String get dietDailyCalorieTarget => 'Дневная норма калорий (ккал)';

  @override
  String dietDurationDays(int days) {
    return '$days дн.';
  }

  @override
  String dietDayProgress(int day, int total) {
    return 'День $day из $total';
  }

  @override
  String dietDaysLeft(int days) {
    return 'Осталось $days дн.';
  }

  @override
  String dietComplianceRate(int percent) {
    return 'Соблюдение: $percent%';
  }

  @override
  String get dietFollowed => 'Соблюдал(а)';

  @override
  String get dietNotFollowed => 'Нарушил(а)';

  @override
  String get dietPending => 'Ожидается';

  @override
  String get dietSlotBreakfast => 'Завтрак';

  @override
  String get dietSlotMorningSnack => 'Перекус утром';

  @override
  String get dietSlotLunch => 'Обед';

  @override
  String get dietSlotAfternoonSnack => 'Полдник';

  @override
  String get dietSlotDinner => 'Ужин';

  @override
  String get dietAlternativesLabel => 'Замена';

  @override
  String dietWaterTarget(String liters) {
    return 'Норма воды: $liters л';
  }

  @override
  String get dietRulesTitle => 'Правила диеты';

  @override
  String get dietSampleMenuTitle => 'Пример дневного меню';

  @override
  String get dietStartedToast => 'Диета успешно запущена!';

  @override
  String get dietEndedToast => 'Активная диета завершена.';

  @override
  String get dietWeightLogTitle => 'Контроль веса на диете';

  @override
  String get dietWeightAdd => 'Добавить вес';

  @override
  String get dietWeightField => 'Текущий вес (кг)';

  @override
  String get dietWeightNote => 'Заметка (необязательно)';

  @override
  String get dietWeightNoteHint => 'Напр.: Утром натощак';

  @override
  String get dietWeightEmpty =>
      'Записей веса пока нет. Добавьте первое взвешивание.';

  @override
  String get dietWeightCurrent => 'Текущий';

  @override
  String get dietWeightTarget => 'Цель';

  @override
  String get dietWeightChange => 'Изменение';

  @override
  String get dietWeightSaved => 'Вес сохранён.';

  @override
  String get dietCalorieTitle => 'ИИ-калькулятор калорий по фото';

  @override
  String get dietCalorieSubtitle =>
      'Работает и без диеты — сфотографируйте тарелку или опишите блюдо.';

  @override
  String get dietSnapPlateCamera => 'Сфотографировать тарелку';

  @override
  String get dietPickPlateGallery => 'Из галереи';

  @override
  String get dietFoodDescLabel => 'Описание блюда / порция (необязательно)';

  @override
  String get dietFoodDescHint => 'Напр.: Курица гриль, булгур, салат, айран';

  @override
  String get dietCalculateFromText => 'Рассчитать по тексту';

  @override
  String get dietAnalyzingPlate => 'Анализируем калории и БЖУ...';

  @override
  String get dietResultTitle => 'Анализ калорий и БЖУ';

  @override
  String get dietAiPoweredBadge => 'Gemini AI Зрение';

  @override
  String get dietOnDeviceBadge => 'Умная локальная оценка';

  @override
  String get dietProtein => 'Белки';

  @override
  String get dietCarbs => 'Углеводы';

  @override
  String get dietFat => 'Жиры';

  @override
  String get dietFiber => 'Клетчатка';

  @override
  String get dietPortionScale => 'Размер порции';

  @override
  String get dietSaveMealLog => 'Сохранить в дневник';

  @override
  String get dietMealLoggedToast => 'Калории блюда добавлены за сегодня.';

  @override
  String get dietTodayTotalCalories => 'Всего сегодня';

  @override
  String get dietRecentScans => 'Проанализированные блюда';

  @override
  String get dietNoScansYet =>
      'Сканирований пока нет. Сфотографируйте тарелку.';

  @override
  String dietHealthScore(int score) {
    return 'Баланс: $score/10';
  }

  @override
  String get dietTodayLabel => 'Сегодня';

  @override
  String get medCatHerbalTea => 'Травяной чай';

  @override
  String get medCatCustom => 'Другое (Ввести вручную)';

  @override
  String get medFieldCustomCategory => 'Своя категория';

  @override
  String get medFieldCustomCategoryHint => 'Напр.: Пробиотик, Вода, Зарядка...';

  @override
  String get medQuickPresetHerbalTea => 'Травяной чай';

  @override
  String get dietCreateCustom => 'Создать свою диету';

  @override
  String get dietCreateCustomSubtitle =>
      'Введите рацион диетолога или свой собственный план питания';

  @override
  String get dietCustomNameLabel => 'Название диеты';

  @override
  String get dietCustomNameHint => 'Напр.: План диетолога, Моё меню...';

  @override
  String get dietCustomNameRequired => 'Введите название диеты.';

  @override
  String get dietCustomMealHint => 'Что запланировано на этот приём пищи?';

  @override
  String get dietCustomMealCaloriesHint => 'ккал (необязательно)';

  @override
  String get dietCustomAtLeastOneMeal => 'Укажите хотя бы один приём пищи.';

  @override
  String get dietCustomTemplatesTitle => 'Мои собственные планы';

  @override
  String get dietReadyTemplatesTitle => 'Готовые шаблоны диет';

  @override
  String get donateTooltip => 'Поддержать / Донат';

  @override
  String get donateMenuLabel => 'Поддержать VisualCheckUp';

  @override
  String get donateMenuSubtitle =>
      'Кофе, обед или подарок в поддержку приложения';

  @override
  String get donatePopupTitle => 'Поддержать VisualCheckUp';

  @override
  String get donatePopupSubtitle =>
      'Ваша добровольная поддержка помогает бесплатно развивать проверки, чтение анализов, напоминания о лекарствах и диету.';

  @override
  String get donateTierCoffeeTitle => 'Угостить кофе';

  @override
  String get donateTierCoffeeDesc => 'Чашка горячего кофе для разработки';

  @override
  String get donateTierMealTitle => 'Угостить обедом';

  @override
  String get donateTierMealDesc => 'Отличная поддержка новых функций здоровья';

  @override
  String get donateTierGiftTitle => 'Отправить подарок';

  @override
  String get donateTierGiftDesc => 'Помогает покрыть расходы на ИИ и серверы';

  @override
  String get donateTierGoldTitle => 'Большая поддержка';

  @override
  String get donateTierGoldDesc =>
      'Ускоряет создание новых медицинских модулей';

  @override
  String get donateTierHeroTitle => 'Герой здоровья';

  @override
  String get donateTierHeroDesc =>
      'Вклад в бесплатный контроль здоровья для семей';

  @override
  String get donatePopularBadge => 'Популярное';

  @override
  String donateConfirmButton(String price) {
    return 'Поддержать $price';
  }

  @override
  String get donateLaterButton => 'Позже';

  @override
  String get donateThanksTitle => 'Спасибо за поддержку!';

  @override
  String donateThanksBody(String tier, String price) {
    return 'Ваша поддержка «$tier» ($price) очень важна для нас. Спасибо, что помогаете развивать VisualCheckUp!';
  }

  @override
  String get donateSupporterBadge => 'Поддержал(а) • Спасибо!';

  @override
  String get donateStoreNotice =>
      'Разовая добровольная поддержка • Без подписки';

  @override
  String get medFieldAlarmSound => 'Мелодия будильника';

  @override
  String get medAlarmSoundClassic => 'Классический будильник';

  @override
  String get medAlarmSoundClassicDesc => 'Чёткий сигнал будильника';

  @override
  String get medAlarmSoundGentle => 'Мягкая мелодия';

  @override
  String get medAlarmSoundGentleDesc => 'Спокойный перезвон';

  @override
  String get medAlarmSoundRadar => 'Современный сигнал';

  @override
  String get medAlarmSoundRadarDesc => 'Ритмичный чёткий будильник';

  @override
  String get medAlarmSoundBell => 'Звонок здоровья';

  @override
  String get medAlarmSoundBellDesc => 'Яркий двойной звонок';

  @override
  String get medAlarmSoundUrgent => 'Громкий срочный сигнал';

  @override
  String get medAlarmSoundUrgentDesc => 'Усиленный тон для важных доз';

  @override
  String get medAlarmSoundSystem => 'Сигнал телефона';

  @override
  String get medAlarmSoundSystemDesc =>
      'Стандартная мелодия будильника устройства';

  @override
  String get medSoundPreviewPlay => 'Слушать';

  @override
  String get medSoundPreviewStop => 'Стоп';

  @override
  String get medSoundSilent => 'Без звука';

  @override
  String get medPreviewModeBadge => 'ПРЕДПРОСМОТР';

  @override
  String get commMenuTitle => 'Сообщество здоровья';

  @override
  String get commHomeSubtitle =>
      'Единомышленники по всему миру, лайки профилей и безопасный чат';

  @override
  String get commTabDiscover => 'Обзор';

  @override
  String get commTabMessages => 'Сообщения';

  @override
  String get commTabMyProfile => 'Мой профиль';

  @override
  String get commSafetyBanner =>
      'Только взаимная поддержка и мотивация — не медицинская консультация. Ваши анализы и фото никогда не публикуются.';

  @override
  String get commSearchHint => 'Поиск по имени, городу или цели...';

  @override
  String get commFilterAllGoals => 'Все цели';

  @override
  String get commFilterAllCountries => 'Весь мир';

  @override
  String get commEmptyDiscover => 'По вашим фильтрам профилей не найдено.';

  @override
  String get commGoalDiabetes => 'Диабет и сахар';

  @override
  String get commGoalBloodPressure => 'Давление и сердце';

  @override
  String get commGoalWeightDiet => 'Вес и здоровое питание';

  @override
  String get commGoalHealthyLiving => 'Здоровый образ жизни';

  @override
  String get commGoalHerbalWellness => 'Травяной чай и уход';

  @override
  String get commGoalParentingGrowth => 'Родители и рост детей';

  @override
  String get commGoalSkinCare => 'Кожа и уход';

  @override
  String get commGoalFitnessWalk => 'Ходьба и активность';

  @override
  String get commGoalSleepStress => 'Сон и антистресс';

  @override
  String commLikesCount(int count) {
    return '$count лайков';
  }

  @override
  String get commLikeAction => 'Нравится';

  @override
  String get commUnlikeAction => 'Понравилось';

  @override
  String get commSendMessage => 'Написать';

  @override
  String get commMessagesDisabled => 'Пользователь отключил личные сообщения.';

  @override
  String get commOptInTitle => 'Присоединяйтесь к сообществу здоровья';

  @override
  String get commOptInBody =>
      'Находите людей со схожими целями здоровья по всему миру. Участие добровольное — ваши анализы и снимки остаются приватными.';

  @override
  String get commOptInButton => 'Создать профиль здоровья';

  @override
  String get commFieldDisplayName => 'Имя';

  @override
  String get commFieldNickname => 'Никнейм (@handle)';

  @override
  String get commFieldCountry => 'Страна';

  @override
  String get commFieldCity => 'Город (необязательно)';

  @override
  String get commFieldLanguage => 'Язык общения';

  @override
  String get commFieldGoals => 'Цели здоровья';

  @override
  String get commFieldBio => 'О себе и пути к здоровью';

  @override
  String get commFieldDailyFocus => 'Ежедневный фокус';

  @override
  String get commPrivacySection => 'Приватность и сообщения';

  @override
  String get commToggleDiscoverable =>
      'Показывать мой профиль в глобальном поиске';

  @override
  String get commToggleHideRealName => 'Скрыть настоящее имя (только @ник)';

  @override
  String get commToggleHidePhoto => 'Скрыть фото профиля';

  @override
  String get commToggleAllowMessages => 'Разрешить личные сообщения';

  @override
  String get commToggleRequireApproval =>
      'Требовать подтверждение новых запросов';

  @override
  String get commUploadPhoto => 'Загрузить фото';

  @override
  String get commRemovePhoto => 'Удалить фото';

  @override
  String get commSaveProfile => 'Сохранить профиль';

  @override
  String get commProfileSaved => 'Профиль сообщества обновлён.';

  @override
  String get commLeaveCommunity => 'Покинуть сообщество и удалить профиль';

  @override
  String get commLeftCommunity => 'Ваш публичный профиль удалён.';

  @override
  String get commInboxEmpty =>
      'Пока нет диалогов. Найдите единомышленников в Обзоре!';

  @override
  String get commMessageRequestBadge => 'Запрос';

  @override
  String get commRequestBannerTitle => 'Новый запрос на переписку';

  @override
  String get commRequestBannerBody =>
      'Примите, чтобы общаться, или отклоните/заблокируйте.';

  @override
  String get commRequestAccept => 'Принять';

  @override
  String get commRequestDecline => 'Отклонить';

  @override
  String get commChatPlaceholder => 'Напишите доброе сообщение...';

  @override
  String get commAttachPhoto => 'Прикрепить фото';

  @override
  String get commPhotoLabel => 'Фото';

  @override
  String get commRateLimited =>
      'Подождите пару секунд перед следующим сообщением.';

  @override
  String get commBlockedNotice => 'Отправка невозможна из-за блокировки.';

  @override
  String get commMuteChat => 'Без звука';

  @override
  String get commUnmuteChat => 'Включить звук';

  @override
  String get commHideChat => 'Скрыть чат';

  @override
  String get commBlockUser => 'Заблокировать';

  @override
  String get commUnblockUser => 'Разблокировать';

  @override
  String get commBlockedToast => 'Пользователь заблокирован.';

  @override
  String get commReportUser => 'Пожаловаться';

  @override
  String get commReportTitle => 'Пожаловаться на профиль или сообщение';

  @override
  String get commReportReasonInappropriate => 'Неприемлемый контент';

  @override
  String get commReportReasonSpam => 'Спам или реклама';

  @override
  String get commReportReasonHarassment => 'Оскорбления или травля';

  @override
  String get commReportReasonMisinfo => 'Опасные мед. советы / дезинформация';

  @override
  String get commReportReasonOther => 'Другое';

  @override
  String get commReportNoteHint => 'Дополнительные детали...';

  @override
  String get commReportSubmit => 'Отправить жалобу';

  @override
  String get commReportSent => 'Спасибо. Жалоба отправлена.';

  @override
  String get commDeleteForMe => 'Удалить у меня';

  @override
  String get commDeleteForEveryone => 'Удалить для всех';

  @override
  String get commOnlineNow => 'В сети';

  @override
  String get commFilterOnlineOnly => 'Сейчас в сети';

  @override
  String get commFilterSameCondition => 'Та же болезнь';

  @override
  String get commFilterAllConditions => 'Все состояния';

  @override
  String get commSameConditionPrompt =>
      'Добавьте хроническое состояние в «Мой профиль», чтобы найти единомышленников.';

  @override
  String get commFieldChronicConditions => 'Хронические состояния (по желанию)';

  @override
  String get commFieldCustomCondition => 'Другое хроническое состояние';

  @override
  String get commFieldCustomConditionHint => 'Напр.: фибромиалгия, СПКЯ...';

  @override
  String get commToggleShowConditions =>
      'Показывать хронические состояния в профиле';

  @override
  String get commToggleShowOnline => 'Показывать статус «В сети»';

  @override
  String get condType1Diabetes => 'Диабет 1 типа';

  @override
  String get condType2Diabetes => 'Диабет 2 типа';

  @override
  String get condHypertension => 'Гипертония';

  @override
  String get condAsthmaCopd => 'Астма / ХОБЛ';

  @override
  String get condThyroidHashimoto => 'Щитовидная железа / Хашимото';

  @override
  String get condMigraine => 'Мигрень';

  @override
  String get condHeartCondition => 'Сердце и сосуды';

  @override
  String get condCeliacIbs => 'Целиакия / СРК';

  @override
  String get condArthritis => 'Артрит / Ревматизм';

  @override
  String get condAnemia => 'Анемия';

  @override
  String get condKidneyHealth => 'Почки';

  @override
  String get condEczemaPsoriasis => 'Экзема / Псориаз';

  @override
  String get adminPanelTitle => 'Панель администратора';

  @override
  String get adminTabStats => 'Статистика';

  @override
  String get adminTabAnnouncements => 'Объявления';

  @override
  String get adminTabPromotions => 'Реклама';

  @override
  String get adminTabUsers => 'Пользователи';

  @override
  String get adminTabReports => 'Жалобы';

  @override
  String get adminStatOnline => 'В сети';

  @override
  String get adminStatMembers => 'Участники';

  @override
  String get adminStatLikes => 'Лайки';

  @override
  String get adminStatChats => 'Чаты';

  @override
  String get adminStatPendingReports => 'Ожидающие жалобы';

  @override
  String get adminStatActiveBanners => 'Активные баннеры';

  @override
  String get adminConditionBreakdown => 'Распределение хронических состояний';

  @override
  String get adminNewAnnouncement => 'Новое объявление';

  @override
  String get adminNewPromotion => 'Новый баннер / реклама';

  @override
  String get adminFieldTitle => 'Заголовок';

  @override
  String get adminFieldMessage => 'Текст / описание';

  @override
  String get adminFieldLink => 'Ссылка URL (необязательно)';

  @override
  String get adminFieldPlacement => 'Размещение';

  @override
  String get adminPlacementHome => 'Главная (верх)';

  @override
  String get adminPlacementCommunity => 'Сообщество (верх)';

  @override
  String get adminPlacementProfile => 'Профиль (верх)';

  @override
  String get adminTypeInfo => 'Объявление';

  @override
  String get adminTypeHealthTip => 'Совет здоровья';

  @override
  String get adminTypeWarning => 'Предупреждение';

  @override
  String get adminTypeCampaign => 'Акция';

  @override
  String get adminSearchUsersHint => 'Поиск по имени, стране или диагнозу...';

  @override
  String get adminActionVerify => 'Подтвердить';

  @override
  String get adminActionUnverify => 'Снять отметку';

  @override
  String get adminActionSuspend => 'Заблокировать';

  @override
  String get adminActionUnsuspend => 'Восстановить';

  @override
  String get adminStatusSuspended => 'Заблокирован';

  @override
  String get adminStatusVerified => 'Подтверждён';

  @override
  String get adminReportResolve => 'Решено';

  @override
  String get adminReportDismiss => 'Отклонить';

  @override
  String get adminNoReports => 'Жалоб пока нет.';

  @override
  String get adminNoAnnouncements => 'Объявлений пока нет.';

  @override
  String get adminNoPromotions => 'Рекламных баннеров пока нет.';

  @override
  String get commMusicSectionTitle => 'Музыка для концентрации';

  @override
  String get commMusicTitleField =>
      'Название трека / плейлиста (необязательно)';

  @override
  String get commMusicUrlField =>
      'Ссылка на музыку (YouTube, Spotify, SoundCloud)';

  @override
  String get commMusicInvalidUrl =>
      'Введите корректную ссылку YouTube, Spotify, Apple Music или SoundCloud.';

  @override
  String get commMusicEmpty => 'Музыка для концентрации еще не добавлена.';

  @override
  String get commMusicListenAction => 'Слушать';

  @override
  String get commMusicLikeAction => 'Нравится музыка';

  @override
  String get commMusicListenersTitle => 'Кто слушал';

  @override
  String get commMusicListenersEmpty => 'Этот трек еще никто не слушал.';

  @override
  String commMusicUniqueListeners(int count) {
    return '$count слушателей';
  }

  @override
  String commMusicTotalPlays(int count) {
    return '$count прослушиваний';
  }

  @override
  String commMusicPlayCountBadge(int count) {
    return '${count}x';
  }

  @override
  String get commProfileLikersTitle => 'Лайки профиля';

  @override
  String get commProfileLikersEmpty => 'Пока нет лайков профиля.';

  @override
  String get commSocialsSectionTitle => 'Социальные сети';

  @override
  String get commToggleShowSocials => 'Показывать мои соцсети';

  @override
  String get commSocialsHiddenHint => 'Скрыто от других участников';

  @override
  String get commSocialsEmpty => 'Социальные сети еще не добавлены.';

  @override
  String get commPreviewMyProfile => 'Предпросмотр профиля';

  @override
  String get safetyContentBlocked =>
      'This text contains inappropriate language, insults, or restricted content and cannot be posted.';

  @override
  String get safetyImageBlocked =>
      'This image did not pass safety verification and could not be uploaded.';

  @override
  String get safetyAccountSuspended =>
      'Your community access is temporarily suspended due to safety policy violations.';

  @override
  String get proMenuTitle => 'VisualCheckUp Pro';

  @override
  String get proMenuSubtitle =>
      'Unlimited lab analyses & ad-free health tracking';

  @override
  String get proPaywallTitle => 'Upgrade to VisualCheckUp Pro';

  @override
  String get proPaywallSubtitle =>
      'Unlock unlimited lab report analyses, full health trends, and an ad-free experience.';

  @override
  String get proPlanMonthly => 'Monthly';

  @override
  String get proPlanYearly => 'Yearly';

  @override
  String get proSaveBadge => 'Best Value • Save 42%';

  @override
  String get proPerMonth => '/ month';

  @override
  String get proPerYear => '/ year';

  @override
  String get proBenefitUnlimitedLabs => 'Unlimited blood & lab report analyses';

  @override
  String get proBenefitAiInsights => 'Unlimited AI PDF & photo lab extraction';

  @override
  String get proBenefitAdFree => 'Completely ad-free experience';

  @override
  String get proBenefitDoctorPriority =>
      'Priority verified doctor search & follow-up requests';

  @override
  String get proSubscribeButton => 'Activate VisualCheckUp Pro';

  @override
  String get proRestoreButton => 'Restore Purchases';

  @override
  String get proActiveBadge => 'VisualCheckUp Pro Active';

  @override
  String get proActivatedToast =>
      'VisualCheckUp Pro activated! Unlimited lab analyses unlocked.';

  @override
  String labFreeQuotaBanner(int remaining, int limit) {
    return 'Free Lab Analyses This Month: $remaining / $limit';
  }

  @override
  String get labProUnlimitedBanner =>
      'VisualCheckUp Pro • Unlimited Lab Analyses';

  @override
  String get labLimitReachedTitle => 'Monthly Free Lab Limit Reached';

  @override
  String get labLimitReachedBody =>
      'Free accounts can analyze up to 3 lab reports per month. Upgrade to VisualCheckUp Pro for unlimited analyses.';

  @override
  String get labUpgradeToProBtn => 'Go Pro (Unlimited)';

  @override
  String get doctorSearchTitle => 'Поиск врача по стране';

  @override
  String get doctorSearchSubtitle =>
      'Search licensed doctors by country & specialty for guidance and patient follow-up';

  @override
  String get doctorSearchHomeCta => 'Search Doctors';

  @override
  String get doctorApplyCta => 'Заявка врача';

  @override
  String get doctorSearchHint =>
      'Search by doctor name, city, clinic, or specialty...';

  @override
  String get doctorFilterAllSpecialties => 'All Specialties';

  @override
  String get doctorFilterFollowUpOnly => 'Patient Follow-Up Open';

  @override
  String get doctorEmptyResults =>
      'No verified doctors match your selected country or specialty yet.';

  @override
  String get doctorVerifiedBadge => 'Verified Doctor';

  @override
  String get doctorFollowUpBadge => 'Patient Follow-Up';

  @override
  String doctorExperienceYears(int years) {
    return '$years yrs exp.';
  }

  @override
  String get doctorRequestFollowUpBtn => 'Request Follow-Up';

  @override
  String get doctorFollowUpDialogTitle => 'Request Patient Follow-Up';

  @override
  String get doctorFollowUpNoteHint =>
      'Briefly describe your chronic condition or follow-up goal...';

  @override
  String get doctorFollowUpSent =>
      'Your patient follow-up request has been sent to the doctor!';

  @override
  String get doctorApplicationTitle => 'Verified Doctor Application';

  @override
  String get doctorApplicationSubtitle =>
      'Join VisualCheckUp\'s global doctor directory to guide patients and offer structured follow-ups.';

  @override
  String get doctorFieldTitle => 'Medical Title';

  @override
  String get doctorFieldFullName => 'Full Name';

  @override
  String get doctorFieldSpecialty => 'Medical Specialty';

  @override
  String get doctorFieldClinic => 'Hospital / Clinic Name';

  @override
  String get doctorFieldLicense => 'Medical License / Diploma No';

  @override
  String get doctorFieldExperience => 'Years of Experience';

  @override
  String get doctorFieldBio => 'Professional Bio & Clinical Focus';

  @override
  String get doctorToggleFollowUp => 'Accept Patient Follow-Up Requests';

  @override
  String get doctorUploadDocBtn => 'Upload Diploma / License Photo (Optional)';

  @override
  String get doctorPlanSectionTitle => 'Doctor Directory Membership Plan';

  @override
  String get doctorPlanMonthlyTitle => 'Doctor Standard (Monthly)';

  @override
  String get doctorPlanMonthlyDesc =>
      'Verified badge, country & specialty listing, direct patient chat';

  @override
  String get doctorPlanYearlyTitle => 'Doctor Pro + Follow-Up (Yearly)';

  @override
  String get doctorPlanYearlyDesc =>
      'Priority country ranking, structured patient follow-ups, unlimited connections';

  @override
  String get doctorSubmitApplicationBtn => 'Submit Doctor Application';

  @override
  String get doctorApplicationSubmitted =>
      'Your doctor application has been submitted for admin verification!';

  @override
  String get doctorApplicationPendingBadge =>
      'Application Pending Verification';

  @override
  String get adminTabDoctors => 'Врачи';

  @override
  String get adminApproveDoctor => 'Approve';

  @override
  String get adminRejectDoctor => 'Reject';

  @override
  String get adminNoDoctorApps => 'No doctor applications yet.';

  @override
  String get specInternalMedicine => 'Internal Medicine';

  @override
  String get specCardiology => 'Cardiology';

  @override
  String get specDermatology => 'Dermatology';

  @override
  String get specEndocrinology => 'Endocrinology';

  @override
  String get specNeurology => 'Neurology';

  @override
  String get specOphthalmology => 'Ophthalmology';

  @override
  String get specPediatrics => 'Pediatrics';

  @override
  String get specFamilyMedicine => 'Family Medicine';

  @override
  String get specNutritionDietetics => 'Nutrition & Dietetics';

  @override
  String get specPsychiatry => 'Psychiatry';

  @override
  String get specPulmonology => 'Pulmonology';

  @override
  String get specNephrology => 'Nephrology';
}
