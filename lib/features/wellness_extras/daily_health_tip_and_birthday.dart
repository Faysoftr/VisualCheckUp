import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';

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
    final tips = allTipsForLocale(languageCode, now: now);
    return tips.first;
  }

  static List<String> allTipsForLocale(String languageCode, {DateTime? now}) {
    final dt = now ?? DateTime.now();
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays;
    final code = languageCode.toLowerCase();

    final tips = _tipsByLang[code] ?? _tipsByLang['en']!;
    final start = dayOfYear % tips.length;
    return [
      for (int i = 0; i < tips.length; i++) tips[(start + i) % tips.length],
    ];
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
/// saved birthday.
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
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBirthday) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      key: const Key('home_birthday_celebration_card'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🎂', style: TextStyle(fontSize: 30)),
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
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12.5,
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
