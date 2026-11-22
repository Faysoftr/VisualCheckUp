import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';

/// Animated launch splash screen with a sunlit green park background
/// (healthy elderly couple) and the centered VisualCheckUp logo glowing
/// with a pulsing neon emerald/mint aura.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 2200),
  });

  final VoidCallback onComplete;
  final Duration duration;

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
              alignment: Alignment.bottomCenter,
            ),
            // Soft cinematic gradient scrim: darker around the neon logo for
            // crisp contrast, gentler at the bottom so the happy elderly couple
            // in the sunlit green park remains clearly visible.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB8081B18),
                    Color(0x990A2420),
                    Color(0x3D0A2420),
                    Color(0x66061513),
                  ],
                  stops: [0.0, 0.42, 0.72, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  // Smooth entrance fade + scale during first 28%
                  final entryProgress = Curves.easeOutCubic.transform(
                    (t / 0.28).clamp(0.0, 1.0),
                  );
                  // Gentle fade-out during the final 10%
                  final exitOpacity = t > 0.90
                      ? (1.0 - ((t - 0.90) / 0.10)).clamp(0.0, 1.0)
                      : 1.0;
                  final opacity = (entryProgress * exitOpacity).clamp(0.0, 1.0);
                  final scale = 0.88 + (0.12 * entryProgress);
                  // Smooth neon breathing pulse (0..1)
                  final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 3.0);

                  return Opacity(
                    opacity: opacity,
                    child: Align(
                      alignment: const Alignment(0, -0.34),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 118,
                                height: 118,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Color.lerp(
                                      const Color(0xFF4CFFD8),
                                      const Color(0xFFA6FFEE),
                                      pulse,
                                    )!,
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2EFFD6).withValues(
                                        alpha: 0.48 + (0.34 * pulse),
                                      ),
                                      blurRadius: 26 + (22 * pulse),
                                      spreadRadius: 3 + (6 * pulse),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF00C9A7).withValues(
                                        alpha: 0.40 + (0.25 * pulse),
                                      ),
                                      blurRadius: 52 + (24 * pulse),
                                      spreadRadius: 6 + (6 * pulse),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/images/app_logo.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF2EFFD6).withValues(
                                      alpha: 0.55 + (0.3 * pulse),
                                    ),
                                    blurRadius: 18,
                                  ),
                                  const Shadow(
                                    color: Color(0xAA000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.loginTagline,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xCC000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
