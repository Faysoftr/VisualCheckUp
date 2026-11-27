import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/admin/data/admin_repository.dart';
import 'package:visualcheckup/features/admin/domain/admin_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/subscription/data/subscription_repository.dart';

/// Displays the newest active [GlobalAnnouncement] published from Admin Panel.
///
/// Features Social Formul Bank-inspired atmospheric ambient neon glow and
/// interactive particle celebration effects (hearts, stars, confetti).
class GlobalAnnouncementBanner extends StatefulWidget {
  const GlobalAnnouncementBanner({
    super.key,
    this.repository,
    this.margin = const EdgeInsets.fromLTRB(16, 10, 16, 4),
  });

  final AdminRepository? repository;
  final EdgeInsetsGeometry margin;

  @override
  State<GlobalAnnouncementBanner> createState() =>
      _GlobalAnnouncementBannerState();
}

class _GlobalAnnouncementBannerState extends State<GlobalAnnouncementBanner> {
  GlobalAnnouncement? _announcement;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = widget.repository ?? AdminRepository();
    final active = await repo.loadAnnouncements(activeOnly: true);
    if (!mounted) return;
    final latest = active.isEmpty ? null : active.first;
    setState(() => _announcement = latest);

    if (latest != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastSeen = prefs.getString('last_seen_global_announcement_id');
        if (lastSeen != latest.id) {
          await prefs.setString('last_seen_global_announcement_id', latest.id);
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _triggerCelebrationEffect(latest);
            });
          }
        }
      } catch (_) {}
    }
  }

  void _triggerCelebrationEffect(GlobalAnnouncement ann) {
    HapticFeedback.mediumImpact();
    final shape = ann.effectShape.isNotEmpty
        ? ann.effectShape
        : (ann.type == AnnouncementType.healthTip
            ? 'kalp'
            : (ann.type == AnnouncementType.campaign ? 'konfeti' : 'yıldız'));
    VisualAnnouncementEffectService.showEffect(
      context,
      type: ann.type.name,
      shape: shape,
      customColor: ann.customColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ann = _announcement;
    if (ann == null || _dismissed) return const SizedBox.shrink();

    final accent = ann.customColor ?? ann.type.accentColor;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: Key('global_announcement_banner_${ann.id}'),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _triggerCelebrationEffect(ann),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ann.type.icon, color: accent, size: 20),
                ),
                const SizedBox(width: 11),
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
                            ann.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${GlobalAnnouncement.shapeEmoji(ann.effectShape)} DUYURU',
                              style: TextStyle(
                                color: accent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ann.message,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Işıkları & Parçacıkları Oynat',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _triggerCelebrationEffect(ann),
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    size: 19,
                    color: accent,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => setState(() => _dismissed = true),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays active promotional banner/card configured for [placement].
class HealthPromotionBanner extends StatefulWidget {
  const HealthPromotionBanner({
    super.key,
    required this.placement,
    this.repository,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 4),
  });

  final PromotionPlacement placement;
  final AdminRepository? repository;
  final EdgeInsetsGeometry margin;

  @override
  State<HealthPromotionBanner> createState() => _HealthPromotionBannerState();
}

class _HealthPromotionBannerState extends State<HealthPromotionBanner> {
  HealthPromotion? _promo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sub = await SubscriptionRepository().loadSubscription();
    if (sub.isPro) {
      if (!mounted) return;
      setState(() => _promo = null);
      return;
    }
    final repo = widget.repository ?? AdminRepository();
    final list = await repo.loadPromotions(
      activeOnly: true,
      placement: widget.placement,
    );
    if (!mounted) return;
    setState(() => _promo = list.isEmpty ? null : list.first);
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promo;
    if (promo == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: Key('health_promo_banner_${promo.id}'),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promo.imageUrl != null && promo.imageUrl!.trim().isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 120,
              child: CommunityImagePreview(
                imageUrl: promo.imageUrl!,
                width: double.infinity,
                height: 120,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (promo.subtitle.trim().isNotEmpty)
                        Text(
                          promo.subtitle.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
