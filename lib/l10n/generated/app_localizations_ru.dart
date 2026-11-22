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
}
