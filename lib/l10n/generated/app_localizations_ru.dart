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
}
