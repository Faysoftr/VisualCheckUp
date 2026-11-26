import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageOption {
  const AppLanguageOption({
    required this.locale,
    required this.nativeName,
    required this.englishName,
    this.isRtl = false,
  });

  final Locale locale;
  final String nativeName;
  final String englishName;
  final bool isRtl;

  String get code => locale.languageCode;
}

/// Manages active application [Locale] across the 10 most spoken global
/// languages plus Turkish (11 languages total), persisted in SharedPreferences.
///
/// Defaults to `null` so the app automatically follows the phone's system
/// language unless the user explicitly selects a language in Settings.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController([super.initialLocale]);

  static const String _prefsKey = 'visualcheckup_locale_v1';
  static const String _systemSentinel = 'system';

  static const List<AppLanguageOption> supportedLanguages = [
    AppLanguageOption(
      locale: Locale('tr'),
      nativeName: 'Türkçe',
      englishName: 'Turkish',
    ),
    AppLanguageOption(
      locale: Locale('en'),
      nativeName: 'English',
      englishName: 'English',
    ),
    AppLanguageOption(
      locale: Locale('zh'),
      nativeName: '中文 (简体)',
      englishName: 'Chinese (Simplified)',
    ),
    AppLanguageOption(
      locale: Locale('hi'),
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
    ),
    AppLanguageOption(
      locale: Locale('es'),
      nativeName: 'Español',
      englishName: 'Spanish',
    ),
    AppLanguageOption(
      locale: Locale('de'),
      nativeName: 'Deutsch',
      englishName: 'German',
    ),
    AppLanguageOption(
      locale: Locale('sv'),
      nativeName: 'Svenska',
      englishName: 'Swedish',
    ),
    AppLanguageOption(
      locale: Locale('fr'),
      nativeName: 'Français',
      englishName: 'French',
    ),
    AppLanguageOption(
      locale: Locale('it'),
      nativeName: 'Italiano',
      englishName: 'Italian',
    ),
    AppLanguageOption(
      locale: Locale('nl'),
      nativeName: 'Nederlands',
      englishName: 'Dutch',
    ),
    AppLanguageOption(
      locale: Locale('ar'),
      nativeName: 'العربية',
      englishName: 'Arabic',
      isRtl: true,
    ),
    AppLanguageOption(
      locale: Locale('bn'),
      nativeName: 'বাংলা',
      englishName: 'Bengali',
    ),
    AppLanguageOption(
      locale: Locale('pt'),
      nativeName: 'Português',
      englishName: 'Portuguese',
    ),
    AppLanguageOption(
      locale: Locale('ru'),
      nativeName: 'Русский',
      englishName: 'Russian',
    ),
    AppLanguageOption(
      locale: Locale('ur'),
      nativeName: 'اردو',
      englishName: 'Urdu',
      isRtl: true,
    ),
  ];

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => l.locale).toList(growable: false);

  static AppLanguageOption optionForCode(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null) return;
    if (saved == _systemSentinel) {
      value = null;
      return;
    }
    final match = supportedLanguages.where((l) => l.code == saved);
    if (match.isNotEmpty) {
      value = match.first.locale;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_prefsKey, _systemSentinel);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
