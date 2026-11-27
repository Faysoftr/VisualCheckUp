import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/ads/ad_ids.dart';

/// AppOpenAdManager — Uygulama açılış ve arka plandan dönüş tam sayfa reklamlarını yönetir.
/// Formül Bank'taki gibi Admin tarafından açılıp kapatılabilir, sıklık sınırı ayarlanabilir.
/// PRO üyeler ve Admin için reklamlar tamamen engellenir.
class AppOpenAdManager {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;

  AppOpenAdManager._internal();

  static const String prefKeyEnabled = 'app_open_ad_enabled';
  static const String prefKeyInterval = 'app_open_ad_interval_minutes';
  static const String prefKeyLastDismissed = 'app_open_ad_last_dismissed_ms';

  bool _isEnabled = false; // Firestore settings/daily_info -> isAppOpenAdEnabled
  int _intervalMinutes = 15; // Varsayılan 15 dakika sıklık sınırı
  bool _isShowingAd = false;
  DateTime? _lastDismissedTime;

  /// Adapter hook for real GoogleMobileAds AppOpenAd (in production environments)
  /// or mocked test callbacks.
  VoidCallback? onShowAdOverride;

  bool get isEnabled => _isEnabled;
  int get intervalMinutes => _intervalMinutes;
  bool get isShowingAd => _isShowingAd;

  /// Initializes persisted settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(prefKeyEnabled) ?? false;
      _intervalMinutes = prefs.getInt(prefKeyInterval) ?? 15;
      final lastMs = prefs.getInt(prefKeyLastDismissed);
      if (lastMs != null) {
        _lastDismissedTime = DateTime.fromMillisecondsSinceEpoch(lastMs);
      }
    } catch (_) {}
  }

  /// Sets the enabled state of app-open ads (synchronized from Admin Panel / Firestore)
  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyEnabled, value);
    } catch (_) {}
    debugPrint('[AppOpenAd] setEnabled: $_isEnabled');
  }

  /// Sets the frequency interval in minutes between app-open ads
  Future<void> setIntervalMinutes(int minutes) async {
    _intervalMinutes = minutes.clamp(1, 1440);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(prefKeyInterval, _intervalMinutes);
    } catch (_) {}
    debugPrint('[AppOpenAd] setIntervalMinutes: $_intervalMinutes');
  }

  /// Checks if enough time has passed since the last ad dismissal
  bool get isCooldownPassed {
    if (_lastDismissedTime == null) return true;
    final diffMinutes = DateTime.now().difference(_lastDismissedTime!).inMinutes;
    return diffMinutes >= _intervalMinutes;
  }

  /// Shows the App Open ad if available, enabled, and user is NOT Pro/Admin.
  /// [isPro] & [isAdmin]: Pro and Admin users never see ads.
  /// [ignoreCooldown]: Forced preview from Admin Panel test button.
  bool showAdIfAvailable({
    bool isPro = false,
    bool isAdmin = false,
    bool ignoreCooldown = false,
  }) {
    // 1. Pro ve Admin üyelere asla reklam gösterilmez
    if (isPro || isAdmin) {
      debugPrint('[AppOpenAd] Ad suppressed: User is Pro ($isPro) or Admin ($isAdmin).');
      return false;
    }

    // 2. Açılış reklamı kapalıysa çık
    if (!_isEnabled && !ignoreCooldown) {
      debugPrint('[AppOpenAd] Ad disabled by admin switch.');
      return false;
    }

    // 3. Halihazırda gösteriliyorsa çık
    if (_isShowingAd) {
      debugPrint('[AppOpenAd] Ad already showing.');
      return false;
    }

    // 4. Sıklık sınırı (cooldown) kontrolü
    if (!ignoreCooldown && !isCooldownPassed) {
      debugPrint('[AppOpenAd] Ad skipped: Cooldown active ($_intervalMinutes min limit).');
      return false;
    }

    _isShowingAd = true;
    _lastDismissedTime = DateTime.now();

    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(prefKeyLastDismissed, _lastDismissedTime!.millisecondsSinceEpoch);
      });
    } catch (_) {}

    debugPrint('[AppOpenAd] Showing AppOpen ad (AdUnit: ${AdIds.appOpenId})...');

    if (onShowAdOverride != null) {
      onShowAdOverride!();
    }

    _isShowingAd = false;
    return true;
  }
}
