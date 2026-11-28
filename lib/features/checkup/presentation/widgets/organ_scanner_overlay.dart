import 'package:flutter/material.dart';
import 'package:visualcheckup/core/color/organ_isolator.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';

/// Full-bleed medical macro scanner overlay displayed after capturing or
/// selecting a photo:
/// 1. Displays ONLY the isolated target organ (tongue without face/neck, nail
///    without hand, eye without face, etc.) magnified to center stage.
/// 2. Animates a smooth macro zoom-in followed by a continuous up-and-down
///    laser scan beam + HUD corner brackets while analysis runs.
class OrganScannerOverlay extends StatefulWidget {
  const OrganScannerOverlay({
    super.key,
    required this.category,
    required this.isolatedOrgan,
    this.isTurkish = true,
  });

  final CheckCategory category;
  final IsolatedOrganResult isolatedOrgan;
  final bool isTurkish;

  @override
  State<OrganScannerOverlay> createState() => _OrganScannerOverlayState();
}

class _OrganScannerOverlayState extends State<OrganScannerOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnim;
  late final AnimationController _laserController;
  late final AnimationController _stepController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..forward();
    _zoomAnim = CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeOutBack,
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat(reverse: true);

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _laserController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  String _stepText(double t) {
    if (widget.isTurkish) {
      if (t < 0.34) {
        return '1/3 Hedef doku vücuttan ayrıştırıldı ve büyütüldü...';
      }
      if (t < 0.72) {
        return '2/3 Yüzey dokusu ve renk spektrumu taranıyor...';
      }
      return '3/3 Analiz tamamlanıyor, rapor hazırlanıyor...';
    }
    if (t < 0.34) {
      return '1/3 Target tissue isolated & magnified...';
    }
    if (t < 0.72) {
      return '2/3 Scanning surface texture & color spectrum...';
    }
    return '3/3 Finalizing analysis report...';
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.category.accentColor;
    const laserCyan = Color(0xFF22D3EE);
    final badgeTitle = widget.isTurkish
        ? widget.isolatedOrgan.organLabelTr
        : widget.isolatedOrgan.organLabelEn;
    final zoomText = '${widget.isolatedOrgan.zoomFactor.toStringAsFixed(1)}x Makro';

    return ColoredBox(
      key: const Key('organ_scanner_overlay'),
      color: const Color(0xFF060B0F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              // Top Macro Isolation Badge
              Container(
                key: const Key('organ_scanner_badge'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B24),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: laserCyan.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: laserCyan.withValues(alpha: 0.16),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.center_focus_strong_rounded,
                      color: laserCyan,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$badgeTitle • $zoomText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Magnified Isolated Organ + Up/Down Laser Beam Viewport
              ScaleTransition(
                scale: Tween<double>(begin: 0.72, end: 1.0).animate(_zoomAnim),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 330,
                    maxHeight: 350,
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.94,
                    child: Container(
                      key: const Key('organ_scanner_viewport'),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080E12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.22),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Isolated zoomed-in organ (no surrounding body!)
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.memory(
                              widget.isolatedOrgan.isolatedImageBytes,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),

                          // Up-and-down sweeping laser beam + scan curtain
                          AnimatedBuilder(
                            animation: _laserController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _LaserScanPainter(
                                  progress: _laserController.value,
                                  movingDown: _laserController.status ==
                                      AnimationStatus.forward,
                                  beamColor: laserCyan,
                                  accentColor: accent,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bottom Live Scanning Telemetry Card
              AnimatedBuilder(
                animation: _stepController,
                builder: (context, _) {
                  final progress = _stepController.value.clamp(0.08, 1.0);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D161E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: laserCyan,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.isTurkish
                                    ? 'Analiz Ediliyor...'
                                    : 'Analyzing...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _stepText(_stepController.value),
                          key: const Key('organ_scanner_status_text'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(laserCyan),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaserScanPainter extends CustomPainter {
  const _LaserScanPainter({
    required this.progress,
    required this.movingDown,
    required this.beamColor,
    required this.accentColor,
  });

  final double progress;
  final bool movingDown;
  final Color beamColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle medical HUD micro-grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    const step = 28.0;
    for (double x = step; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = step; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Trailing laser scan curtain (above beam when moving down, below when moving up)
    final beamY = (h * 0.08) + (h * 0.84) * progress;
    const trailHeight = 54.0;
    final trailRect = movingDown
        ? Rect.fromLTWH(0, (beamY - trailHeight).clamp(0.0, h), w, trailHeight)
        : Rect.fromLTWH(0, beamY, w, trailHeight.clamp(0.0, h - beamY));

    final trailGradient = LinearGradient(
      begin: movingDown ? Alignment.topCenter : Alignment.bottomCenter,
      end: movingDown ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [
        beamColor.withValues(alpha: 0.0),
        beamColor.withValues(alpha: 0.24),
      ],
    );
    canvas.drawRect(
      trailRect,
      Paint()..shader = trailGradient.createShader(trailRect),
    );

    // 3. Bright horizontal laser line + outer glow
    canvas.drawLine(
      Offset(8, beamY),
      Offset(w - 8, beamY),
      Paint()
        ..color = beamColor.withValues(alpha: 0.55)
        ..strokeWidth = 7.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(
      Offset(6, beamY),
      Offset(w - 6, beamY),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // 4. Precision HUD corner brackets
    final bracketPaint = Paint()
      ..color = beamColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    const pad = 12.0;
    const len = 22.0;
    // Top-left
    canvas.drawLine(const Offset(pad, pad + len), const Offset(pad, pad), bracketPaint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(w - pad - len, pad), Offset(w - pad, pad), bracketPaint);
    canvas.drawLine(Offset(w - pad, pad), Offset(w - pad, pad + len), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(pad, h - pad - len), Offset(pad, h - pad), bracketPaint);
    canvas.drawLine(Offset(pad, h - pad), Offset(pad + len, h - pad), bracketPaint);
    // Bottom-right
    canvas.drawLine(
      Offset(w - pad - len, h - pad),
      Offset(w - pad, h - pad),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(w - pad, h - pad - len),
      Offset(w - pad, h - pad),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaserScanPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.movingDown != movingDown;
  }
}
