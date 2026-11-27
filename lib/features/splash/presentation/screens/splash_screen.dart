import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated launch splash screen with a sunlit green park background
/// (healthy middle-aged couple in their 40s) and the centered VisualCheckUp logo glowing
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
            // Clean full-screen display of the integrated cinematic splash artwork
            // (New red-heart neon emblem + Visual Check Up title + sunset coastal runners).
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  // Smooth entrance fade during first 22%
                  final entryProgress = Curves.easeOutCubic.transform(
                    (t / 0.22).clamp(0.0, 1.0),
                  );
                  // Gentle fade-out during the final 8%
                  final exitOpacity = t > 0.92
                      ? (1.0 - ((t - 0.92) / 0.08)).clamp(0.0, 1.0)
                      : 1.0;
                  final opacity = (entryProgress * exitOpacity).clamp(0.0, 1.0);
                  // Smooth breathing pulse (0..1)
                  final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 3.0);

                  return Opacity(
                    opacity: opacity,
                    child: Align(
                      alignment: const Alignment(0, 0.90),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sleek subtle neon loading line at the bottom
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 3.5,
                                width: 140,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.white.withValues(alpha: 0.18),
                                    ),
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (t / 0.92).clamp(0.0, 1.0),
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
                                              color: const Color(0xFF00F2FE)
                                                  .withValues(alpha: 0.6 + 0.4 * pulse),
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
