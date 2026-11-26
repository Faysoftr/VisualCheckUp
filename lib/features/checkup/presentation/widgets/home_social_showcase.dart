import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/community/domain/wellness_wall_models.dart';
import 'package:visualcheckup/features/community/presentation/widgets/community_avatar_and_report.dart';
import 'package:visualcheckup/features/doctors/domain/doctor_models.dart';
import 'package:visualcheckup/features/wellness_extras/daily_health_tip_and_birthday.dart';

/// Reusable Social Formula Bank-inspired glowing gradient-border card container.
class SfbGradientBorderCard extends StatelessWidget {
  const SfbGradientBorderCard({
    super.key,
    required this.child,
    this.gradientColors = const [
      Color(0xFF06B6D4),
      Color(0xFF14B8A6),
      Color(0xFFEC4899),
    ],
    this.borderRadius = 22,
    this.borderWidth = 1.8,
    this.padding = const EdgeInsets.all(14),
    this.glowColor,
  });

  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF132223) : Colors.white;
    final effectiveGlow = glowColor ?? gradientColors.first;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withValues(alpha: isDark ? 0.18 : 0.14),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Circular avatar wrapped in a colorful gradient ring (Social Formula Bank style).
class SfbGradientRingAvatar extends StatelessWidget {
  const SfbGradientRingAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.radius = 26,
    this.ringWidth = 2.6,
    this.ringColors = const [
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ],
    this.accentColor,
    this.isOnline = false,
  });

  final String initials;
  final String? photoUrl;
  final double radius;
  final double ringWidth;
  final List<Color> ringColors;
  final Color? accentColor;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final innerBg = isDark ? const Color(0xFF132223) : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(ringWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ringColors,
            ),
            boxShadow: [
              BoxShadow(
                color: ringColors.last.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: innerBg,
              shape: BoxShape.circle,
            ),
            child: CommunityAvatar(
              initials: initials,
              photoUrl: photoUrl,
              radius: radius,
              accentColor: accentColor ?? AppTheme.primaryTeal,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: innerBg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Glowing cyan Daily Health Tip card (modeled after SFB "Tarihte Bugün" card).
class SfbDailyHealthTipCard extends StatelessWidget {
  const SfbDailyHealthTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final tip = DailyWellnessExtras.dailyTipForLocale(langCode);

    return SfbGradientBorderCard(
      key: const Key('home_sfb_daily_tip_card'),
      gradientColors: const [
        Color(0xFF06B6D4),
        Color(0xFF2DD4BF),
        Color(0xFF38BDF8),
      ],
      glowColor: const Color(0xFF06B6D4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF0891B2),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyHealthTipTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF0891B2),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.38,
                    fontWeight: FontWeight.w600,
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

/// Verified Doctors horizontal showcase card (modeled after SFB "Özel Ders Verenler").
class SfbVerifiedDoctorsSection extends StatelessWidget {
  const SfbVerifiedDoctorsSection({
    super.key,
    required this.doctors,
    required this.onSeeAll,
    required this.onApplyDoctor,
    required this.onTapCountry,
  });

  final List<DoctorProfile> doctors;
  final VoidCallback onSeeAll;
  final VoidCallback onApplyDoctor;
  final ValueChanged<String> onTapCountry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: const Key('home_sfb_doctors_card'),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132223) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 18,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.doctorSearchTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    l10n.doctorSearchHomeCta,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tappable Search Bar (just like SFB "İl, ilçe veya branş arayın...")
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: isDark ? 0.35 : 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.doctorSearchHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 138,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: doctors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final doc = doctors[idx];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onTapCountry(doc.countryCode),
                  child: Container(
                    width: 116,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: isDark ? 0.25 : 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              const Color(0xFF0284C7).withValues(alpha: 0.14),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            size: 19,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          doc.displayTitleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doc.specialty.localizedLabel(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doc.country.flag} ${doc.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onApplyDoctor,
              icon: const Icon(Icons.verified_user_outlined, size: 15),
              label: Text(
                l10n.doctorApplyCta,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal circular gradient-ring members row (modeled after SFB "Yeni Üyelerimiz").
class SfbNewMembersSection extends StatelessWidget {
  const SfbNewMembersSection({
    super.key,
    required this.members,
    required this.onTapMember,
    required this.onSeeAll,
  });

  final List<HealthCommunityProfile> members;
  final ValueChanged<HealthCommunityProfile> onTapMember;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (members.isEmpty) return const SizedBox.shrink();

    return SfbGradientBorderCard(
      key: const Key('home_sfb_new_members_card'),
      gradientColors: const [
        Color(0xFFEC4899),
        Color(0xFFA855F7),
        Color(0xFF14B8A6),
      ],
      glowColor: const Color(0xFFEC4899),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 17,
                  color: Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.sfbNewMembersTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onSeeAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l10n.commTabDiscover,
                    style: const TextStyle(
                      color: Color(0xFFDB2777),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 102,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final m = members[idx];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTapMember(m),
                  child: SizedBox(
                    width: 82,
                    child: Column(
                      children: [
                        SfbGradientRingAvatar(
                          initials: m.initials,
                          photoUrl: m.visiblePhotoUrl,
                          radius: 25,
                          ringWidth: 2.3,
                          accentColor: m.healthGoals.first.accentColor,
                          isOnline: m.isVisibleOnline,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          m.visibleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (m.nickname.isNotEmpty)
                          Text(
                            '@${m.nickname}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0891B2),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ranked Active Members leaderboard card (modeled after SFB "En Aktif Üyeler").
class SfbActiveMembersSection extends StatelessWidget {
  const SfbActiveMembersSection({
    super.key,
    required this.members,
    required this.onTapMember,
  });

  final List<HealthCommunityProfile> members;
  final ValueChanged<HealthCommunityProfile> onTapMember;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    if (members.isEmpty) return const SizedBox.shrink();

    final top = members.take(5).toList();

    return SfbGradientBorderCard(
      key: const Key('home_sfb_active_members_card'),
      gradientColors: const [
        Color(0xFF06B6D4),
        Color(0xFFEC4899),
      ],
      glowColor: const Color(0xFF06B6D4),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFF59E0B),
                size: 21,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.sfbActiveMembersTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < top.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTapMember(top[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: isDark ? 0.28 : 0.42),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${i + 1}.',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    CommunityAvatar(
                      initials: top[i].initials,
                      photoUrl: top[i].visiblePhotoUrl,
                      radius: 16,
                      accentColor: top[i].healthGoals.first.accentColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        top[i].nickname.isNotEmpty
                            ? top[i].nickname
                            : top[i].visibleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${top[i].likesCount * 10 + 25}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: top[i].isVerified
                          ? const Color(0xFF0284C7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (i < top.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// Latest Wellness Wall posts preview (modeled after SFB "Son Sorular").
class SfbLatestPostsSection extends StatelessWidget {
  const SfbLatestPostsSection({
    super.key,
    required this.posts,
    required this.onOpenWall,
  });

  final List<WellnessWallPost> posts;
  final VoidCallback onOpenWall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    if (posts.isEmpty) return const SizedBox.shrink();

    final latest = posts.take(2).toList();

    return Column(
      key: const Key('home_sfb_latest_posts_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.sfbLatestPostsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF0891B2),
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onOpenWall,
              child: Text(l10n.commTabWall),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final post in latest) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132223) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommunityAvatar(
                      initials: post.authorName.trim().isNotEmpty
                          ? post.authorName.trim().substring(0, 1).toUpperCase()
                          : 'U',
                      radius: 20,
                      accentColor:
                          post.condition?.accentColor ?? AppTheme.primaryTeal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (post.condition != null)
                            Text(
                              post.condition!.localizedLabel(l10n),
                              style: const TextStyle(
                                color: Color(0xFF0891B2),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (post.hasDoctorReply)
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: Color(0xFF0F766E),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onOpenWall,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.sfbViewDetails,
                            style: const TextStyle(
                              color: Color(0xFF0891B2),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFF0891B2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
