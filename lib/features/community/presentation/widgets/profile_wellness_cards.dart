import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';
import 'package:visualcheckup/features/pedometer/domain/pedometer_models.dart';
import 'package:visualcheckup/features/sobriety/domain/sobriety_models.dart';

/// Displays the user's Healthy Living Motto on their profile, with instant
/// show/hide & preset/custom motto selection for the owner.
class ProfileMottoCard extends StatelessWidget {
  const ProfileMottoCard({
    super.key,
    required this.profile,
    required this.isOwner,
    this.onToggleVisibility,
    this.onPickOrEditMotto,
  });

  final HealthCommunityProfile profile;
  final bool isOwner;
  final ValueChanged<bool>? onToggleVisibility;
  final ValueChanged<String>? onPickOrEditMotto;

  Future<void> _openQuickMottoSheet(BuildContext context) async {
    if (onPickOrEditMotto == null) return;
    final ctrl = TextEditingController(text: profile.motto);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 4,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sağlıklı Yaşam Mottonuzu Seçin',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hazır sağlıklı yaşam mottolarından birini seçin veya kendi mottonuzu yazın.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('motto_preset_dropdown'),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Hazır Sağlıklı Yaşam Mottoları',
                    prefixIcon: Icon(Icons.auto_awesome_rounded),
                  ),
                  items: [
                    for (final m in HealthyLivingMottos.presets)
                      DropdownMenuItem<String>(
                        value: m,
                        child: Text(
                          m,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                  ],
                  onChanged: (selected) {
                    if (selected != null) {
                      ctrl.text = selected;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('motto_custom_text_field'),
                  controller: ctrl,
                  maxLines: 2,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Mottonuz',
                    hintText: 'Örn: Bugün attığın her adım yarının nefesidir...',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('motto_save_sheet_btn'),
                    onPressed: () {
                      final val = ctrl.text.trim();
                      Navigator.of(ctx).pop();
                      onPickOrEditMotto!(val);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Mottoyu Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isOwner && (!profile.showMotto || profile.motto.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasMotto = profile.motto.trim().isNotEmpty;
    final displayMotto = hasMotto
        ? profile.motto.trim()
        : HealthyLivingMottos.presets.first;

    return Card(
      key: const Key('profile_motto_card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF0D9488).withValues(alpha: 0.35),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D9488).withValues(alpha: 0.10),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 19,
                  color: Color(0xFF0D9488),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Sağlıklı Yaşam Mottom',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isOwner) ...[
                  if (!profile.showMotto)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Gizli',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  IconButton(
                    key: const Key('profile_motto_visibility_btn'),
                    visualDensity: VisualDensity.compact,
                    tooltip: profile.showMotto
                        ? 'Profilde Gizle'
                        : 'Profilde Göster',
                    onPressed: onToggleVisibility == null
                        ? null
                        : () => onToggleVisibility!(!profile.showMotto),
                    icon: Icon(
                      profile.showMotto
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    key: const Key('profile_motto_edit_btn'),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Mottoyu Değiştir',
                    onPressed: () => _openQuickMottoSheet(context),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '“$displayMotto”',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: !profile.showMotto && isOwner
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.65)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the user's Smoking & Alcohol Cessation progress on their profile.
class ProfileSobrietyShowcaseCard extends StatelessWidget {
  const ProfileSobrietyShowcaseCard({
    super.key,
    required this.profile,
    required this.isOwner,
    this.localOverrideState,
    this.onToggleVisibility,
    this.onOpenTracker,
  });

  final HealthCommunityProfile profile;
  final bool isOwner;
  final SobrietyState? localOverrideState;
  final ValueChanged<bool>? onToggleVisibility;
  final VoidCallback? onOpenTracker;

  @override
  Widget build(BuildContext context) {
    final effState = localOverrideState ??
        SobrietyState(
          smokeQuitAt: profile.smokeQuitAt,
          alcoholQuitAt: profile.alcoholQuitAt,
          dailyCigarettes: profile.dailyCigarettesCount,
          packPriceTry: (profile.dailySmokeCostTry * 20.0) /
              (profile.dailyCigarettesCount.clamp(1, 100)),
          dailyAlcoholCostTry: profile.dailyAlcoholCostTry,
          showOnProfile: profile.showSobrietyOnProfile,
        );

    final visibleFlag = localOverrideState != null
        ? localOverrideState!.showOnProfile
        : profile.showSobrietyOnProfile;

    if (!isOwner && (!visibleFlag || !effState.isAnyActive)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final active = effState.isAnyActive;
    final maxDay = effState.maxActiveDayNumber(now);
    final todaySaved = SobrietyState.formatTry(effState.todayMoneySavedAt(now));
    final totalSaved = SobrietyState.formatTry(effState.totalMoneySavedAt(now));
    final lifeRegained =
        SobrietyState.formatLifeRegained(effState.lifeRegainedAt(now));

    BodyRecoveryMilestone? activeMilestone;
    if (active) {
      final maxElapsed = effState.smokeElapsedAt(now) >
              effState.alcoholElapsedAt(now)
          ? effState.smokeElapsedAt(now)
          : effState.alcoholElapsedAt(now);
      for (final m in SobrietyKnowledgeBase.dayByDayMilestones) {
        activeMilestone = m;
        if (!m.isCompletedFor(maxElapsed)) break;
      }
    }

    return Card(
      key: const Key('profile_sobriety_card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF16A34A).withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0x2216A34A),
                  child: Icon(
                    Icons.smoke_free_rounded,
                    size: 18,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sigara & Alkolsüz Yaşam',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isOwner) ...[
                  if (!visibleFlag)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Gizli',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (onToggleVisibility != null)
                    IconButton(
                      key: const Key('profile_sobriety_visibility_btn'),
                      visualDensity: VisualDensity.compact,
                      tooltip: visibleFlag
                          ? 'Profilde Gizle'
                          : 'Profilde Göster',
                      onPressed: () => onToggleVisibility!(!visibleFlag),
                      icon: Icon(
                        visibleFlag
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (!active)
              Text(
                'Sigara ve alkolü bırakma sayacını başlatarak gün gün vücudunuzdaki iyileşmeleri, kazanılan parayı ve kazanılan ömrü takip edin.',
                style: theme.textTheme.bodySmall,
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _BadgeChip(
                    icon: Icons.emoji_events_rounded,
                    label: 'Gün $maxDay Özgürlük',
                    color: const Color(0xFF16A34A),
                  ),
                  _BadgeChip(
                    icon: Icons.payments_outlined,
                    label: 'Bugün: $todaySaved • Toplam: $totalSaved',
                    color: const Color(0xFF0D9488),
                  ),
                  _BadgeChip(
                    icon: Icons.favorite_rounded,
                    label: 'Kazanılan Ömür: +$lifeRegained',
                    color: const Color(0xFFE11D48),
                  ),
                ],
              ),
              if (activeMilestone != null) ...[
                const SizedBox(height: 8),
                Text(
                  '✨ ${activeMilestone.dayLabel}: ${activeMilestone.title}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
            if (isOwner && onOpenTracker != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  key: const Key('profile_open_sobriety_btn'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: onOpenTracker,
                  icon: Icon(
                    active ? Icons.timeline_rounded : Icons.play_arrow_rounded,
                    size: 17,
                  ),
                  label: Text(active ? 'Detayları Gör' : 'Takibi Başlat'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Displays the user's Step Counter (Today / This Week / This Month) on their profile.
class ProfileStepCounterShowcaseCard extends StatelessWidget {
  const ProfileStepCounterShowcaseCard({
    super.key,
    required this.profile,
    required this.isOwner,
    this.localPedometerState,
    this.onToggleVisibility,
    this.onOpenStepCounter,
  });

  final HealthCommunityProfile profile;
  final bool isOwner;
  final PedometerState? localPedometerState;
  final ValueChanged<bool>? onToggleVisibility;
  final VoidCallback? onOpenStepCounter;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final visibleFlag = localPedometerState != null
        ? localPedometerState!.showOnProfile
        : profile.showStepsOnProfile;

    final today = localPedometerState != null
        ? localPedometerState!.todayStepsAt(now)
        : profile.todayStepsCount;
    final week = localPedometerState != null
        ? localPedometerState!.thisWeekStepsAt(now)
        : profile.weekStepsCount;
    final month = localPedometerState != null
        ? localPedometerState!.thisMonthStepsAt(now)
        : profile.monthStepsCount;
    final goal = (localPedometerState != null
            ? localPedometerState!.dailyStepGoal
            : profile.dailyStepGoal)
        .clamp(1, 100000);

    if (!isOwner && !visibleFlag) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fmt = NumberFormat.decimalPattern('tr');
    final ratio = (today / goal).clamp(0.0, 1.0);

    return Card(
      key: const Key('profile_steps_card'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0x220284C7),
                  child: Icon(
                    Icons.directions_walk_rounded,
                    size: 18,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Adım Sayar & Yürüyüş Özeti',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isOwner) ...[
                  if (!visibleFlag)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Gizli',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (onToggleVisibility != null)
                    IconButton(
                      key: const Key('profile_steps_visibility_btn'),
                      visualDensity: VisualDensity.compact,
                      tooltip: visibleFlag
                          ? 'Profilde Gizle'
                          : 'Profilde Göster',
                      onPressed: () => onToggleVisibility!(!visibleFlag),
                      icon: Icon(
                        visibleFlag
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniStepStat(
                    label: 'Bugün',
                    value: fmt.format(today),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStepStat(
                    label: 'Bu Hafta',
                    value: fmt.format(week),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniStepStat(
                    label: 'Bu Ay',
                    value: fmt.format(month),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Günlük Hedef: ${fmt.format(today)} / ${fmt.format(goal)} (%${(ratio * 100).round()})',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                if (isOwner && onOpenStepCounter != null)
                  TextButton.icon(
                    key: const Key('profile_open_steps_btn'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: onOpenStepCounter,
                    icon: const Icon(Icons.open_in_new_rounded, size: 15),
                    label: const Text('Adım Sayarı Aç'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepStat extends StatelessWidget {
  const _MiniStepStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
