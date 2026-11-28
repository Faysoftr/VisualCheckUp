import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:visualcheckup/l10n/generated/app_localizations.dart';

/// Animated launch splash screen displaying the coastal sunset runners artwork
/// with the integrated transparent VisualCheckUp emblem at the top and a
/// frosted-glass bottom banner whose tagline adapts automatically to the
/// selected app language or phone system language across all 15 locales.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 2200),
  });

  final VoidCallback onComplete;
  final Duration duration;

  static String fallbackTaglineForCode(String code) {
    switch (code.toLowerCase()) {
      case 'tr':
        return 'Yapay Zeka Destekli\nSağlık Takibi';
      case 'de':
        return 'KI-gestützte\nGesundheitsverfolgung';
      case 'es':
        return 'Seguimiento de Salud\nImpulsado por IA';
      case 'fr':
        return "Suivi de Santé\nPropulsé par l'IA";
      case 'it':
        return "Monitoraggio della Salute\nBasato sull'IA";
      case 'nl':
        return 'AI-Aangedreven\nGezondheidsmonitoring';
      case 'sv':
        return 'AI-Driven\nHälsoövervakning';
      case 'pt':
        return 'Monitoramento de Saúde\ncom Inteligência Artificial';
      case 'ru':
        return 'Мониторинг здоровья\nна базе ИИ';
      case 'ar':
        return 'متابعة صحية مدعومة\nبالذكاء الاصطناعي';
      case 'zh':
        return 'AI 智能驱动\n全方位健康追踪';
      case 'hi':
        return 'AI-संचालित\nस्वास्थ्य ट्रैकिंग';
      case 'bn':
        return 'AI-চালিত\nস্বাস্থ্য ট্র্যাকিং';
      case 'ur':
        return 'مصنوعی ذہانت سے چلنے والی\nصحت کی نگرانی';
      case 'en':
      default:
        return 'AI-Powered\nHealth Tracking';
    }
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _finish();
        }
      })
      ..forward();
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _resolveTagline(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (l10n != null) {
      return l10n.splashTagline;
    }
    final activeLocale = Localizations.maybeLocaleOf(context) ??
        PlatformDispatcher.instance.locale;
    return SplashScreen.fallbackTaglineForCode(activeLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final tagline = _resolveTagline(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1F1C),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/splash_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            SafeArea(
              bottom: false,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  final entryProgress = Curves.easeOutCubic.transform(
                    (t / 0.22).clamp(0.0, 1.0),
                  );
                  final exitOpacity = t > 0.92
                      ? (1.0 - ((t - 0.92) / 0.08)).clamp(0.0, 1.0)
                      : 1.0;
                  final opacity = (entryProgress * exitOpacity).clamp(0.0, 1.0);
                  final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 3.0);

                  return Opacity(
                    opacity: opacity,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              key: const Key('splash_tagline_card'),
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                20,
                                18,
                                20,
                                math.max(
                                  20.0,
                                  MediaQuery.paddingOf(context).bottom + 14.0,
                                ),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF2B2E33)
                                        .withValues(alpha: 0.52),
                                    const Color(0xFF141B20)
                                        .withValues(alpha: 0.72),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tagline,
                                    key: const Key('splash_tagline_text'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.24,
                                      letterSpacing: -0.3,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF67E8F9)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 12,
                                        ),
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.45),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: SizedBox(
                                      height: 3.5,
                                      width: 140,
                                      child: Stack(
                                        children: [
                                          Container(
                                            color: Colors.white
                                                .withValues(alpha: 0.20),
                                          ),
                                          FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor:
                                                (t / 0.92).clamp(0.0, 1.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF00F2FE),
                                                    Color(0xFFFF1E56),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                            0xFF00F2FE)
                                                        .withValues(
                                                            alpha: 0.6 +
                                                                0.4 * pulse),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
