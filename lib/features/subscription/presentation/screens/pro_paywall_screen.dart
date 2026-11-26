import 'package:flutter/material.dart';
import 'package:visualcheckup/core/iap/in_app_purchase_service.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';
import 'package:visualcheckup/features/subscription/domain/subscription_models.dart';

/// VisualCheckUp Pro paywall screen with global Monthly & Yearly pricing.
/// Unlocks unlimited lab report analyses, AI extraction, and ad-free usage.
class ProPaywallScreen extends StatefulWidget {
  const ProPaywallScreen({
    super.key,
    required this.repository,
    this.userId,
    this.triggeredByLabLimit = false,
  });

  final SubscriptionRepository repository;
  final String? userId;
  final bool triggeredByLabLimit;

  @override
  State<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends State<ProPaywallScreen> {
  SubscriptionTier _selectedTier = SubscriptionTier.proYearly;
  UserSubscriptionState _current = const UserSubscriptionState();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await widget.repository.loadSubscription(uid: widget.userId);
    if (!mounted) return;
    setState(() {
      _current = state;
      if (state.tier.isPro) {
        _selectedTier = state.tier;
      }
      _loading = false;
    });
  }

  Future<void> _activate() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final productId = _selectedTier == SubscriptionTier.proYearly
        ? HealthInAppPurchaseService.proYearly
        : HealthInAppPurchaseService.proMonthly;

    final success = await HealthInAppPurchaseService.instance.buySubscription(
      productId,
      userId: widget.userId,
    );

    if (!mounted) return;

    if (success) {
      final updated = await widget.repository.activatePlan(
        uid: widget.userId,
        tier: _selectedTier,
      );
      setState(() {
        _current = updated;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.proActivatedToast)),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _submitting = true);
    await HealthInAppPurchaseService.instance.restorePurchases(userId: widget.userId);
    final restored =
        await widget.repository.loadSubscription(uid: widget.userId);
    if (!mounted) return;
    setState(() {
      _current = restored;
      _submitting = false;
    });
    if (restored.isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.proActiveBadge)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktif bir abonelik bulunamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proMenuTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Hero Gradient Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B6E6E), Color(0xFF0F3D3E)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFBBF24)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _current.isPro
                                  ? l10n.proActiveBadge
                                  : l10n.proMenuTitle,
                              style: const TextStyle(
                                color: Color(0xFFFDE68A),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.triggeredByLabLimit
                            ? l10n.labLimitReachedTitle
                            : l10n.proPaywallTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.triggeredByLabLimit
                            ? l10n.labLimitReachedBody
                            : l10n.proPaywallSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Benefits Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _BenefitRow(
                          icon: Icons.biotech_rounded,
                          text: l10n.proBenefitUnlimitedLabs,
                        ),
                        const SizedBox(height: 10),
                        _BenefitRow(
                          icon: Icons.auto_awesome_rounded,
                          text: l10n.proBenefitAiInsights,
                        ),
                        const SizedBox(height: 10),
                        _BenefitRow(
                          icon: Icons.block_rounded,
                          text: l10n.proBenefitAdFree,
                        ),
                        const SizedBox(height: 10),
                        _BenefitRow(
                          icon: Icons.medical_services_rounded,
                          text: l10n.proBenefitDoctorPriority,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Picker: Yearly (Best Value) & Monthly
                _PlanOptionTile(
                  key: const Key('pro_plan_yearly_tile'),
                  title: l10n.proPlanYearly,
                  priceText:
                      '${SubscriptionTier.proYearly.localizedPrice(langCode)} ${l10n.proPerYear}',
                  subtitle:
                      '${SubscriptionTier.proYearly.localizedMonthlyEquivalent(langCode)} ${l10n.proPerMonth} • \$34.99 USD',
                  badge: l10n.proSaveBadge,
                  selected: _selectedTier == SubscriptionTier.proYearly,
                  onTap: () =>
                      setState(() => _selectedTier = SubscriptionTier.proYearly),
                ),
                const SizedBox(height: 10),
                _PlanOptionTile(
                  key: const Key('pro_plan_monthly_tile'),
                  title: l10n.proPlanMonthly,
                  priceText:
                      '${SubscriptionTier.proMonthly.localizedPrice(langCode)} ${l10n.proPerMonth}',
                  subtitle: '\$4.99 USD ${l10n.proPerMonth}',
                  selected: _selectedTier == SubscriptionTier.proMonthly,
                  onTap: () => setState(
                    () => _selectedTier = SubscriptionTier.proMonthly,
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    key: const Key('pro_subscribe_button'),
                    onPressed: _submitting ? null : _activate,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.workspace_premium_rounded),
                    label: Text(
                      _current.isPro
                          ? l10n.proActiveBadge
                          : l10n.proSubscribeButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('pro_restore_button'),
                  onPressed: _submitting ? null : _restore,
                  child: Text(
                    l10n.proRestoreButton,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      key: const Key('pro_privacy_policy_link'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Gizlilik Politikası',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(' • ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    TextButton(
                      key: const Key('pro_terms_eula_link'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Kullanım Koşulları (EULA)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ödeme, satın alma onayının ardından Apple Kimliği (App Store) veya Google Play hesabınızdan tahsil edilir. Abonelik, geçerli dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik yenilenir. Aboneliğinizi dilediğiniz zaman App Store / Google Play hesap ayarlarınızdan yönetebilir veya iptal edebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.14),
          child: Icon(icon, size: 18, color: AppTheme.primaryTeal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _PlanOptionTile extends StatelessWidget {
  const _PlanOptionTile({
    super.key,
    required this.title,
    required this.priceText,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String priceText;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryTeal.withValues(alpha: 0.10)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            width: selected ? 2 : 1,
            color: selected ? AppTheme.primaryTeal : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppTheme.primaryTeal
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              priceText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
