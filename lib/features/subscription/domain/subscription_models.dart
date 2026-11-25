/// Subscription plans and pricing for VisualCheckUp Pro.
///
/// Distinct from any other app — positioned at globally accepted personal
/// health-assistant pricing with localized display currencies.
enum SubscriptionTier {
  free,
  proMonthly,
  proYearly,
}

extension SubscriptionTierX on SubscriptionTier {
  static SubscriptionTier fromId(String? value) {
    for (final t in SubscriptionTier.values) {
      if (t.name == value) return t;
    }
    return SubscriptionTier.free;
  }

  bool get isPro =>
      this == SubscriptionTier.proMonthly || this == SubscriptionTier.proYearly;

  String get productId {
    switch (this) {
      case SubscriptionTier.free:
        return '';
      case SubscriptionTier.proMonthly:
        return 'visualcheckup_pro_monthly';
      case SubscriptionTier.proYearly:
        return 'visualcheckup_pro_yearly';
    }
  }

  /// Globally accepted USD reference price.
  double get usdPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.proMonthly:
        return 4.99;
      case SubscriptionTier.proYearly:
        return 34.99;
    }
  }

  /// Localized display price tailored to the active app language/region.
  String localizedPrice(String languageCode) {
    final code = languageCode.toLowerCase();
    switch (this) {
      case SubscriptionTier.free:
        return '0';
      case SubscriptionTier.proMonthly:
        if (code == 'tr') return '₺149,99';
        if (code == 'de' || code == 'es' || code == 'fr' || code == 'it' || code == 'nl' || code == 'pt') {
          return '€4,99';
        }
        if (code == 'sv') return '55 kr';
        return '\$4.99';
      case SubscriptionTier.proYearly:
        if (code == 'tr') return '₺999,99';
        if (code == 'de' || code == 'es' || code == 'fr' || code == 'it' || code == 'nl' || code == 'pt') {
          return '€34,99';
        }
        if (code == 'sv') return '389 kr';
        return '\$34.99';
    }
  }

  /// Monthly equivalent display price for the yearly plan.
  String localizedMonthlyEquivalent(String languageCode) {
    final code = languageCode.toLowerCase();
    if (this != SubscriptionTier.proYearly) return localizedPrice(code);
    if (code == 'tr') return '₺83,33';
    if (code == 'de' || code == 'es' || code == 'fr' || code == 'it' || code == 'nl' || code == 'pt') {
      return '€2,92';
    }
    if (code == 'sv') return '32 kr';
    return '\$2.92';
  }
}

/// Active subscription status for a VisualCheckUp user.
class UserSubscriptionState {
  const UserSubscriptionState({
    this.tier = SubscriptionTier.free,
    this.activatedAt,
    this.expiresAt,
    this.storeSource = 'local',
  });

  /// Free-tier limit for lab report uploads/analyses per calendar month.
  static const int freeMonthlyLabReportLimit = 3;

  final SubscriptionTier tier;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String storeSource;

  bool isProAt(DateTime now) {
    if (!tier.isPro) return false;
    if (expiresAt != null && expiresAt!.isBefore(now)) return false;
    return true;
  }

  bool get isPro => isProAt(DateTime.now());

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        if (activatedAt != null) 'activatedAt': activatedAt!.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        'storeSource': storeSource,
      };

  factory UserSubscriptionState.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionState(
      tier: SubscriptionTierX.fromId(json['tier'] as String?),
      activatedAt: DateTime.tryParse((json['activatedAt'] as String?) ?? ''),
      expiresAt: DateTime.tryParse((json['expiresAt'] as String?) ?? ''),
      storeSource: (json['storeSource'] as String?) ?? 'local',
    );
  }
}
