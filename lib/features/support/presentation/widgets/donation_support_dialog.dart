import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

/// Voluntary support/donation tiers with store-ready product IDs.
enum DonationTier {
  coffee,
  meal,
  gift,
  gold,
  hero,
}

extension DonationTierX on DonationTier {
  String get productId {
    switch (this) {
      case DonationTier.coffee:
        return 'visualcheckup_donate_coffee_399';
      case DonationTier.meal:
        return 'visualcheckup_donate_meal_999';
      case DonationTier.gift:
        return 'visualcheckup_donate_gift_1999';
      case DonationTier.gold:
        return 'visualcheckup_donate_gold_2999';
      case DonationTier.hero:
        return 'visualcheckup_donate_hero_4999';
    }
  }

  String get priceLabel {
    switch (this) {
      case DonationTier.coffee:
        return '\$3.99';
      case DonationTier.meal:
        return '\$9.99';
      case DonationTier.gift:
        return '\$19.99';
      case DonationTier.gold:
        return '\$29.99';
      case DonationTier.hero:
        return '\$49.99';
    }
  }

  bool get isPopular => this == DonationTier.gift;

  IconData get icon {
    switch (this) {
      case DonationTier.coffee:
        return Icons.local_cafe_rounded;
      case DonationTier.meal:
        return Icons.restaurant_rounded;
      case DonationTier.gift:
        return Icons.card_giftcard_rounded;
      case DonationTier.gold:
        return Icons.favorite_rounded;
      case DonationTier.hero:
        return Icons.workspace_premium_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case DonationTier.coffee:
        return const Color(0xFFB45309);
      case DonationTier.meal:
        return const Color(0xFF0F766E);
      case DonationTier.gift:
        return const Color(0xFFE11D48);
      case DonationTier.gold:
        return const Color(0xFF7C3AED);
      case DonationTier.hero:
        return const Color(0xFFD97706);
    }
  }

  String localizedTitle(AppLocalizations l10n) {
    switch (this) {
      case DonationTier.coffee:
        return l10n.donateTierCoffeeTitle;
      case DonationTier.meal:
        return l10n.donateTierMealTitle;
      case DonationTier.gift:
        return l10n.donateTierGiftTitle;
      case DonationTier.gold:
        return l10n.donateTierGoldTitle;
      case DonationTier.hero:
        return l10n.donateTierHeroTitle;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case DonationTier.coffee:
        return l10n.donateTierCoffeeDesc;
      case DonationTier.meal:
        return l10n.donateTierMealDesc;
      case DonationTier.gift:
        return l10n.donateTierGiftDesc;
      case DonationTier.gold:
        return l10n.donateTierGoldDesc;
      case DonationTier.hero:
        return l10n.donateTierHeroDesc;
    }
  }
}

/// Voluntary donation / support popup dialog with Coffee, Meal, Gift, Big
/// Support, and Health Hero tiers.
class DonationSupportDialog extends StatefulWidget {
  const DonationSupportDialog({
    super.key,
    this.onConfirmTier,
  });

  /// Optional custom purchase callback (e.g. Google Play / App Store billing).
  final Future<bool> Function(DonationTier tier)? onConfirmTier;

  static const String _supporterPrefsKey = 'visualcheckup_is_supporter_v1';

  static Future<DonationTier?> show(
    BuildContext context, {
    Future<bool> Function(DonationTier tier)? onConfirmTier,
  }) {
    return showDialog<DonationTier>(
      context: context,
      builder: (_) => DonationSupportDialog(onConfirmTier: onConfirmTier),
    );
  }

  static Future<bool> isSupporter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_supporterPrefsKey) ?? false;
  }

  @override
  State<DonationSupportDialog> createState() => _DonationSupportDialogState();
}

class _DonationSupportDialogState extends State<DonationSupportDialog> {
  DonationTier _selected = DonationTier.gift;
  bool _processing = false;
  bool _isSupporter = false;
  DonationTier? _completedTier;

  @override
  void initState() {
    super.initState();
    _loadSupporterStatus();
  }

  Future<void> _loadSupporterStatus() async {
    final flag = await DonationSupportDialog.isSupporter();
    if (!mounted) return;
    setState(() => _isSupporter = flag);
  }

  Future<void> _handleConfirm() async {
    if (_processing) return;
    setState(() => _processing = true);

    bool ok = true;
    if (widget.onConfirmTier != null) {
      ok = await widget.onConfirmTier!(_selected);
    }
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(DonationSupportDialog._supporterPrefsKey, true);
    }
    if (!mounted) return;
    setState(() {
      _processing = false;
      if (ok) {
        _isSupporter = true;
        _completedTier = _selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      key: const Key('donation_support_dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
        child: _completedTier != null
            ? _buildThankYouView(context, _completedTier!)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warm coral-rose header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.donatePopupTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.donatePopupSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                        if (_isSupporter) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.donateSupporterBadge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Scrollable donation tiers
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Column(
                        children: [
                          for (final tier in DonationTier.values) ...[
                            _DonationTierTile(
                              tier: tier,
                              selected: _selected == tier,
                              onTap: () => setState(() => _selected = tier),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Footer action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            key: const Key('donate_confirm_button'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _selected.accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _processing ? null : _handleConfirm,
                            icon: _processing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.favorite_rounded, size: 20),
                            label: Text(
                              l10n.donateConfirmButton(_selected.priceLabel),
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.donateStoreNotice,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.donateLaterButton),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildThankYouView(BuildContext context, DonationTier tier) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tier.accentColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: tier.accentColor,
              size: 46,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.donateThanksTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.donateThanksBody(
              tier.localizedTitle(l10n),
              tier.priceLabel,
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(tier),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationTierTile extends StatelessWidget {
  const _DonationTierTile({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final DonationTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = tier.accentColor;

    return InkWell(
      key: Key('donate_tier_${tier.name}'),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accent
                : colorScheme.outlineVariant.withValues(alpha: 0.55),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: accent.withValues(alpha: 0.16),
              child: Icon(tier.icon, color: accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        tier.localizedTitle(l10n),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (tier.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.donatePopularBadge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.localizedDescription(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? accent
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tier.priceLabel,
                style: TextStyle(
                  color: selected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
