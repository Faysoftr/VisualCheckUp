import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';
import 'package:visualcheckup/core/theme/visual_announcement_effect_service.dart';
import 'package:visualcheckup/features/community/data/health_community_repository.dart';
import 'package:visualcheckup/features/community/domain/health_community_models.dart';

/// Evidence-based daily health tips (rotates deterministically by day of year)
/// plus birthday celebration helper for VisualCheckUp HomeScreen.
class DailyWellnessExtras {
  DailyWellnessExtras._();

  static const String _birthdayMonthKey = 'visualcheckup_birthday_month_v1';
  static const String _birthdayDayKey = 'visualcheckup_birthday_day_v1';

  static Future<void> saveBirthday({
    required int month,
    required int day,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_birthdayMonthKey, month.clamp(1, 12));
    await prefs.setInt(_birthdayDayKey, day.clamp(1, 31));
  }

  static Future<(int, int)?> loadBirthday() async {
    final prefs = await SharedPreferences.getInstance();
    final m = prefs.getInt(_birthdayMonthKey);
    final d = prefs.getInt(_birthdayDayKey);
    if (m == null || d == null) return null;
    return (m, d);
  }

  static Future<bool> isTodayBirthday({DateTime? now}) async {
    final saved = await loadBirthday();
    if (saved == null) return false;
    final dt = now ?? DateTime.now();
    return saved.$1 == dt.month && saved.$2 == dt.day;
  }

  static String dailyTipForLocale(String languageCode, {DateTime? now}) {
    final dt = now ?? DateTime.now();
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays;
    final code = languageCode.toLowerCase();

    final tips = _tipsByLang[code] ?? _tipsByLang['en']!;
    return tips[dayOfYear % tips.length];
  }

  static const Map<String, List<String>> _tipsByLang = {
    'tr': [
      'Göz yorgunluğunu azaltmak için 20-20-20 kuralını uygulayın: Her 20 dakikada 20 saniye boyunca 6 metre uzağa bakın.',
      'Evde tansiyon ölçerken 5 dakika dinlenin, ayaklarınızı yere düz basın ve kolunuzu kalp hizasında destekleyin.',
      'Yemeklerden 20-30 dakika sonra yapılan 15 dakikalık hafif yürüyüş, tokluk kan şekerini dengelemeye yardımcı olur.',
      'Güne 1 bardak oda sıcaklığında suyla başlamak sabah hidrasyonunu ve dolaşımı destekler.',
      'Günlük tuz alımını 5 gramın altında tutmak uzun vadede damar ve böbrek sağlığını korur.',
      'Düzenli uyku saatleri bağışıklık sistemini ve stres hormonlarının dengesini güçlendirir.',
    ],
    'en': [
      'Follow the 20-20-20 rule to reduce eye strain: every 20 minutes, look 20 feet away for 20 seconds.',
      'Rest quietly for 5 minutes before measuring home blood pressure, with feet flat and arm at heart level.',
      'A gentle 15-minute walk 20–30 minutes after meals helps steady post-meal blood glucose levels.',
      'Starting your morning with a glass of water supports hydration and circulation.',
      'Keeping daily sodium intake low protects long-term cardiovascular and kidney health.',
      'Consistent sleep and wake times strengthen immunity and metabolic balance.',
    ],
    'de': [
      'Nutzen Sie die 20-20-20-Regel für entspannte Augen: Alle 20 Minuten 20 Sekunden lang in die Ferne blicken.',
      'Ruhen Sie vor der Blutdruckmessung 5 Minuten ruhig und halten Sie den Arm auf Herzhöhe.',
      'Ein 15-minütiger Spaziergang nach dem Essen unterstützt einen stabilen Blutzuckerspiegel.',
      'Starten Sie den Tag mit einem Glas Wasser für optimale Hydratation.',
    ],
    'sv': [
      'Följ 20-20-20-regeln för ögonen: var 20:e minut, titta långt bort i 20 sekunder.',
      'Vila 5 minuter före blodtrycksmätning hemma med armen i hjärthöjd.',
      'En lugn 15-minuterspromenad efter måltid hjälper till att stabilisera blodsockret.',
      'Börja morgonen med ett glas vatten för god vätskebalans.',
    ],
    'es': [
      'Aplica la regla 20-20-20 para descansar la vista: cada 20 minutos mira a lo lejos durante 20 segundos.',
      'Descansa 5 minutos antes de medir tu presión arterial en casa con el brazo a la altura del corazón.',
      'Caminar suavemente 15 minutos después de comer ayuda a estabilizar la glucosa.',
      'Comenzar el día con un vaso de agua favorece la hidratación y la energía.',
    ],
  };
}

/// Compact daily scientific health tip card shown on HomeScreen.
class DailyHealthTipCard extends StatelessWidget {
  const DailyHealthTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final tip = DailyWellnessExtras.dailyTipForLocale(langCode);

    return Container(
      key: const Key('home_daily_health_tip_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF122826)
            : AppTheme.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryTeal.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              size: 19,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyHealthTipTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Festive health-focused birthday card shown when today matches the user's
/// saved birthday, featuring celebratory confetti, balloons, and cake bursts.
class BirthdayCelebrationCard extends StatefulWidget {
  const BirthdayCelebrationCard({
    super.key,
    required this.displayName,
    this.nowOverride,
  });

  final String displayName;
  final DateTime? nowOverride;

  @override
  State<BirthdayCelebrationCard> createState() =>
      _BirthdayCelebrationCardState();
}

class _BirthdayCelebrationCardState extends State<BirthdayCelebrationCard> {
  bool _isBirthday = false;
  bool _hasTriggeredInitialBurst = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final hit = await DailyWellnessExtras.isTodayBirthday(
      now: widget.nowOverride,
    );
    if (!mounted) return;
    setState(() => _isBirthday = hit);

    if (hit && !_hasTriggeredInitialBurst) {
      _hasTriggeredInitialBurst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _triggerCelebration();
      });
    }
  }

  void _triggerCelebration() {
    HapticFeedback.heavyImpact();
    VisualAnnouncementEffectService.showEffect(
      context,
      type: 'birthday',
      shape: 'doğum günü',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBirthday) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      key: const Key('home_birthday_celebration_card'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _triggerCelebration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎂', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.birthdayCardTitle(widget.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.birthdayCardSubtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _triggerCelebration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.celebration_rounded, size: 16),
                  label: const Text(
                    'Kutla 🎉',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Social Formul Bank-inspired showcase card listing community members
/// whose birthday is today, with cake badges and interactive "Kutla 🎉" wishes.
class CommunityBirthdayShowcaseCard extends StatefulWidget {
  const CommunityBirthdayShowcaseCard({
    super.key,
    this.profiles,
    this.onOpenProfile,
  });

  final List<HealthCommunityProfile>? profiles;
  final ValueChanged<HealthCommunityProfile>? onOpenProfile;

  @override
  State<CommunityBirthdayShowcaseCard> createState() =>
      _CommunityBirthdayShowcaseCardState();
}

class _CommunityBirthdayShowcaseCardState
    extends State<CommunityBirthdayShowcaseCard> {
  final Set<String> _celebratedUids = {};

  void _celebrateMember(HealthCommunityProfile member) {
    HapticFeedback.heavyImpact();
    setState(() => _celebratedUids.add(member.uid));
    VisualAnnouncementEffectService.showEffect(
      context,
      type: 'birthday',
      shape: 'doğum günü',
    );

    _showWishSheet(member);
  }

  void _showWishSheet(HealthCommunityProfile member) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController(
      text: '🎂 Sağlıklı, mutlu ve neşeyle dolu nice güzel yaşlara! 🎉',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132223) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2A8D).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎂', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.visibleName} için Doğum Günü Notu',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Tebrik dileğin topluluk panosuna iletilecek',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _wishChip(
                    '🎂 Nice Sağlıklı Yaşlara!',
                    controller,
                    '🎂 Sağlıklı, mutlu ve neşeyle dolu nice güzel yaşlara! 🎉',
                  ),
                  _wishChip(
                    '✨ Şifa & Huzur',
                    controller,
                    '✨ Yeni yaşın sana bol şifa, enerji ve huzur getirsin! 🌟',
                  ),
                  _wishChip(
                    '💪 Sağlık Yolculuğunda Başarılar',
                    controller,
                    '💪 Sağlıklı yaşam yolculuğunda nice başarılı yıllara! 🌿',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tebrik mesajını yaz...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Text('💌', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${member.visibleName} için kutlama notun iletildi! 🎉',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2A8D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'Kutlamayı İlet 💌',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wishChip(
    String label,
    TextEditingController controller,
    String fullText,
  ) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => controller.text = fullText,
      backgroundColor: const Color(0xFFFF2A8D).withValues(alpha: 0.08),
      side: BorderSide(
        color: const Color(0xFFFF2A8D).withValues(alpha: 0.22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = HealthCommunityRepository.getTodayBirthdayProfiles(
      source: widget.profiles,
    );

    if (members.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: const Key('home_community_birthdays_section'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF142426)
            : const Color(0xFFFFF1F2).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF2A8D).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2A8D).withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A8D).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cake_rounded,
                    color: Color(0xFFFF2A8D),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Bugün Doğum Günü Olan Üyelerimiz',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A8D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${members.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF2A8D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.pink.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 116,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isCelebrated = _celebratedUids.contains(member.uid);

                return Container(
                  width: 96,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: widget.onOpenProfile != null
                            ? () => widget.onOpenProfile!(member)
                            : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFFF2A8D)
                                  .withValues(alpha: 0.18),
                              child: Text(
                                member.initials,
                                style: const TextStyle(
                                  color: Color(0xFFFF2A8D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '🎂',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        member.visibleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 24,
                        child: ElevatedButton(
                          onPressed: isCelebrated
                              ? null
                              : () => _celebrateMember(member),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCelebrated
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFF2A8D),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF10B981)
                                .withValues(alpha: 0.8),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isCelebrated ? '✓ Kutlandı' : 'Kutla 🎉',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

