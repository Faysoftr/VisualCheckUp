import 'package:flutter/material.dart';
import 'package:visualcheckup/core/theme/app_theme.dart';

/// Theme-adaptive health & wellness background designed for navigation drawers.
///
/// Automatically switches between dedicated light (`drawer_bg_light.jpg`) and
/// dark (`drawer_bg_dark.jpg`) health illustrations with ECG heartbeat waves,
/// botanical leaves, and medical icons, paired with a directional readability
/// scrim so menu labels remain crisp in both light and dark themes (including
/// RTL layouts).
class HealthDrawerBackground extends StatelessWidget {
  const HealthDrawerBackground({
    super.key,
    required this.child,
  });

  static const String lightAssetPath = 'assets/images/drawer_bg_light.jpg';
  static const String darkAssetPath = 'assets/images/drawer_bg_dark.jpg';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final assetPath = isDark ? darkAssetPath : lightAssetPath;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base solid fallback while the image decodes
        ColoredBox(
          color: isDark ? const Color(0xFF0B1516) : AppTheme.lightCanvas,
        ),
        // Smooth cross-fade between Light and Dark health backgrounds
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox.expand(
            key: ValueKey<String>(isDark ? 'drawer_bg_dark' : 'drawer_bg_light'),
            child: Transform.flip(
              flipX: isRtl,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                gaplessPlayback: true,
                cacheWidth: 720,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        // Subtle directional readability scrim: protects text on the start edge
        // while keeping the health motifs vivid along the outer/top/bottom edges
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
              colors: isDark
                  ? [
                      const Color(0xFF0A1415).withValues(alpha: 0.42),
                      const Color(0xFF0A1415).withValues(alpha: 0.22),
                      const Color(0xFF0A1415).withValues(alpha: 0.08),
                    ]
                  : [
                      const Color(0xFFF7FBFA).withValues(alpha: 0.48),
                      const Color(0xFFF7FBFA).withValues(alpha: 0.22),
                      const Color(0xFFF7FBFA).withValues(alpha: 0.05),
                    ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: child,
        ),
      ],
    );
  }
}
