import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full-screen ambient glow & particle celebration effect service inspired by
/// Social Formul Bank (`AnnouncementService.showEffect`).
///
/// Triggers celebratory lights, atmospheric neon border pulsing, and falling
/// particles (hearts, stars, confetti, birthday cakes/balloons, or health motifs).
class VisualAnnouncementEffectService {
  VisualAnnouncementEffectService._();

  /// Displays the full-screen visual effect over [context]'s current Overlay.
  static void showEffect(
    BuildContext context, {
    String type = 'duyuru',
    String? shape,
    Duration duration = const Duration(milliseconds: 3600),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _AnnouncementEffectWidget(
        type: type,
        shape: shape,
        duration: duration,
        onComplete: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _AnnouncementEffectWidget extends StatefulWidget {
  const _AnnouncementEffectWidget({
    required this.type,
    this.shape,
    required this.duration,
    required this.onComplete,
  });

  final String type;
  final String? shape;
  final Duration duration;
  final VoidCallback onComplete;

  @override
  State<_AnnouncementEffectWidget> createState() =>
      _AnnouncementEffectWidgetState();
}

class _AnnouncementEffectWidgetState extends State<_AnnouncementEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  Timer? _glowStopTimer;
  final List<_EffectParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _buildParticles();

    _particleController.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });

    _glowStopTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _glowController.stop();
      }
    });
  }

  @override
  void dispose() {
    _glowStopTimer?.cancel();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color _resolveBaseColor() {
    final t = widget.type.toLowerCase();
    final s = (widget.shape ?? '').toLowerCase();

    if (s.contains('kalp') || s.contains('heart')) {
      return const Color(0xFFFF2A8D); // Neon Pink
    }
    if (s.contains('ünlem') || s.contains('warning') || t.contains('warning')) {
      return const Color(0xFFEF4444); // Neon Red
    }
    if (s.contains('yıldız') || s.contains('star')) {
      return const Color(0xFFFBBF24); // Gold
    }
    if (s.contains('roket') || s.contains('rocket')) {
      return const Color(0xFFFF6D00); // Neon Orange
    }
    if (s.contains('doğum') || s.contains('birthday') || t.contains('birthday')) {
      return const Color(0xFFF59E0B); // Festive Amber/Gold
    }
    if (t.contains('kampanya') || t.contains('campaign')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    if (s.contains('sağlık') || t.contains('healthtip') || t.contains('sağlık')) {
      return const Color(0xFF10B981); // Emerald
    }
    return const Color(0xFF00F2FE); // Electric Cyan
  }

  void _buildParticles() {
    final s = (widget.shape ?? widget.type).toLowerCase();
    if (s.contains('sadece neon') || s == 'neon') {
      // Glow-only: do not spawn emoji/icon particles
      return;
    }

    final color = _resolveBaseColor();

    for (int i = 0; i < 42; i++) {
      _ParticleSymbol symbol;
      Color pColor = color;

      if (s.contains('doğum') || s.contains('birthday')) {
        const birthdaySymbols = ['🎂', '🎈', '🎁', '🎉', '🍰', '✨', '💖'];
        symbol = _ParticleSymbol(
          birthdaySymbols[_random.nextInt(birthdaySymbols.length)],
        );
        pColor = [
          const Color(0xFFFF2A8D),
          const Color(0xFFF59E0B),
          const Color(0xFF00F2FE),
          const Color(0xFF10B981),
          const Color(0xFF8B5CF6),
        ][_random.nextInt(5)];
      } else if (s.contains('kalp') || s.contains('heart')) {
        const heartSymbols = ['❤️', '💖', '💕', '✨', '🌸', '💗'];
        symbol = _ParticleSymbol(
          heartSymbols[_random.nextInt(heartSymbols.length)],
        );
        pColor = const Color(0xFFFF2A8D);
      } else if (s.contains('ünlem') || s.contains('uyarı')) {
        const warningSymbols = ['❗', '⚠️', '🚨', '⚡', '🔔'];
        symbol = _ParticleSymbol(
          warningSymbols[_random.nextInt(warningSymbols.length)],
        );
        pColor = [
          const Color(0xFFEF4444),
          const Color(0xFFF59E0B),
          const Color(0xFFFF1744),
        ][_random.nextInt(3)];
      } else if (s.contains('yıldız') || s.contains('star')) {
        const starSymbols = ['⭐', '✨', '🌟', '💫', '⚡'];
        symbol = _ParticleSymbol(
          starSymbols[_random.nextInt(starSymbols.length)],
        );
        pColor = const Color(0xFFFBBF24);
      } else if (s.contains('megafon')) {
        const megafonSymbols = ['📢', '📣', '🔔', '✨'];
        symbol = _ParticleSymbol(
          megafonSymbols[_random.nextInt(megafonSymbols.length)],
        );
        pColor = [
          const Color(0xFF00F2FE),
          const Color(0xFFF59E0B),
          const Color(0xFFFF2A8D),
        ][_random.nextInt(3)];
      } else if (s.contains('soru')) {
        const questionSymbols = ['❓', '❔', '🤔', '💡', '✨'];
        symbol = _ParticleSymbol(
          questionSymbols[_random.nextInt(questionSymbols.length)],
        );
        pColor = [
          const Color(0xFF8B5CF6),
          const Color(0xFF00F2FE),
          const Color(0xFF38BDF8),
        ][_random.nextInt(3)];
      } else if (s.contains('roket')) {
        const rocketSymbols = ['🚀', '✨', '🔥', '💫', '🌟'];
        symbol = _ParticleSymbol(
          rocketSymbols[_random.nextInt(rocketSymbols.length)],
        );
        pColor = [
          const Color(0xFFFF6D00),
          const Color(0xFFEF4444),
          const Color(0xFFFBBF24),
        ][_random.nextInt(3)];
      } else if (s.contains('gülücük') || s.contains('smile')) {
        const smileSymbols = ['😊', '😂', '😎', '😍', '😁', '✨'];
        symbol = _ParticleSymbol(
          smileSymbols[_random.nextInt(smileSymbols.length)],
        );
        pColor = const Color(0xFFFBBF24);
      } else if (s.contains('karışık') || s.contains('mixed')) {
        const mixedSymbols = ['🎨', '⭐', '❤️', '🎵', '🎈', '🎉', '🍀', '✨'];
        symbol = _ParticleSymbol(
          mixedSymbols[_random.nextInt(mixedSymbols.length)],
        );
        pColor = [
          const Color(0xFFFF2A8D),
          const Color(0xFF00F2FE),
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
          const Color(0xFF8B5CF6),
        ][_random.nextInt(5)];
      } else if (s.contains('sağlık') || s.contains('health')) {
        const healthSymbols = ['🩺', '💊', '🌿', '🍎', '❤️', '✨', '💧'];
        symbol = _ParticleSymbol(
          healthSymbols[_random.nextInt(healthSymbols.length)],
        );
        pColor = [
          const Color(0xFF10B981),
          const Color(0xFF06B6D4),
          const Color(0xFFF43F5E),
        ][_random.nextInt(3)];
      } else {
        // Default festive celebration confetti / sparkles
        const confetti = ['🎉', '✨', '🎊', '⭐', '🎈', '🌟'];
        symbol = _ParticleSymbol(
          confetti[_random.nextInt(confetti.length)],
        );
        pColor = [
          const Color(0xFF00F2FE),
          const Color(0xFFFF2A8D),
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
        ][_random.nextInt(4)];
      }

      _particles.add(
        _EffectParticle(
          x: _random.nextDouble(),
          y: -0.15 - (_random.nextDouble() * 0.45),
          symbol: symbol,
          color: pColor,
          size: 18 + (_random.nextDouble() * 18),
          speed: 1.2 + (_random.nextDouble() * 2.8),
          drift: (_random.nextDouble() * 0.36) - 0.18,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() * 2.4) - 1.2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _resolveBaseColor();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowController, _particleController]),
        builder: (context, _) {
          final progress = _particleController.value;
          final glowFactor = _glowController.value;
          final screen = MediaQuery.of(context).size;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Atmospheric Edge Pulsing Neon Scrim
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: baseColor.withValues(
                        alpha: (0.20 + (glowFactor * 0.40)) * (1.0 - progress),
                      ),
                      width: 4.0 + (glowFactor * 6.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(
                          alpha: (0.25 + (glowFactor * 0.35)) *
                              (1.0 - (progress * 0.8)),
                        ),
                        blurRadius: 28.0 + (glowFactor * 32.0),
                        spreadRadius: 2.0 + (glowFactor * 4.0),
                      ),
                    ],
                  ),
                ),
              ),

              // Falling & drifting celebratory particles
              CustomPaint(
                size: screen,
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: progress,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParticleSymbol {
  const _ParticleSymbol(this.text);

  final String text;
}

class _EffectParticle {
  _EffectParticle({
    required this.x,
    required this.y,
    required this.symbol,
    required this.color,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
  });

  final double x;
  final double y;
  final _ParticleSymbol symbol;
  final Color color;
  final double size;
  final double speed;
  final double drift;
  final double rotation;
  final double rotationSpeed;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  final List<_EffectParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + (progress * p.speed)) * size.height;
      if (currentY < -40 || currentY > size.height + 40) continue;

      final currentX = (p.x + (math.sin(progress * 4.0 + p.drift) * 0.08)) *
          size.width;
      final currentRotation = p.rotation + (progress * p.rotationSpeed * math.pi);

      // Fade in at top, fade out near bottom
      double alpha = 1.0;
      if (progress < 0.1) {
        alpha = progress / 0.1;
      } else if (progress > 0.75) {
        alpha = (1.0 - progress) / 0.25;
      }
      alpha = alpha.clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      final textPainter = TextPainter(
        text: TextSpan(
          text: p.symbol.text,
          style: TextStyle(
            fontSize: p.size,
            color: p.color.withValues(alpha: alpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
