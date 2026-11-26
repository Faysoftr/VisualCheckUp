import 'dart:io';

/// Official Google AdMob identifiers for VisualCheckUp (synchronized with Social Formul Bank).
class AdIds {
  AdIds._();

  // Android AdMob IDs
  static const String _androidAppId = 'ca-app-pub-7020995238802429~2988869493';
  static const String _androidBannerId = 'ca-app-pub-7020995238802429/8084433449';
  static const String _androidNativeId = 'ca-app-pub-7020995238802429/8235524990';
  static const String _androidInterstitialId = 'ca-app-pub-7020995238802429/1619947507';
  static const String _androidAppOpenId = 'ca-app-pub-7020995238802429/5110785742';

  // iOS AdMob IDs
  static const String _iosAppId = 'ca-app-pub-7020995238802429~2988869493';
  static const String _iosBannerId = 'ca-app-pub-7020995238802429/8084433449';
  static const String _iosNativeId = 'ca-app-pub-7020995238802429/8235524990';
  static const String _iosInterstitialId = 'ca-app-pub-7020995238802429/1619947507';
  static const String _iosAppOpenId = 'ca-app-pub-7020995238802429/5110785742';

  static String get appId => Platform.isIOS ? _iosAppId : _androidAppId;

  /// Banner (320x50 and 300x250)
  static String get bannerId => Platform.isIOS ? _iosBannerId : _androidBannerId;

  /// Native Advanced Ad
  static String get nativeId => Platform.isIOS ? _iosNativeId : _androidNativeId;

  /// Interstitial Ad
  static String get interstitialId => Platform.isIOS ? _iosInterstitialId : _androidInterstitialId;

  /// App Open Ad
  static String get appOpenId => Platform.isIOS ? _iosAppOpenId : _androidAppOpenId;
}
