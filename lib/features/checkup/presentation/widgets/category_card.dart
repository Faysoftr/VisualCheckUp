import 'package:flutter/material.dart';
import 'package:visualcheckup/core/l10n/l10n_extensions.dart';
import 'package:visualcheckup/features/checkup/domain/check_category.dart';
import 'package:visualcheckup/features/checkup/presentation/widgets/category_icon.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CheckCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = category.accentColor;

    final hsl = HSLColor.fromColor(accent);
    final lighterAccent = hsl
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 0.85))
        .toColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF162323).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? accent.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.14 : 0.09),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: accent.withValues(alpha: 0.12),
            highlightColor: accent.withValues(alpha: 0.06),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real photorealistic module backdrop biased gently toward right
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(
                      category.cardBackgroundAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Soft directional frosted scrim: keeps photo crisp & visible
                // in the upper-right while ensuring AAA readability for text
                // at the bottom-left in both Light and Dark themes.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          stops: const [0.0, 0.48, 0.80, 1.0],
                          colors: isDark
                              ? [
                                  const Color(0xFF101D1D)
                                      .withValues(alpha: 0.94),
                                  const Color(0xFF142424)
                                      .withValues(alpha: 0.78),
                                  const Color(0xFF162626)
                                      .withValues(alpha: 0.42),
                                  accent.withValues(alpha: 0.16),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.94),
                                  Colors.white.withValues(alpha: 0.76),
                                  Colors.white.withValues(alpha: 0.34),
                                  accent.withValues(alpha: 0.08),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Subtle bottom readability veil behind title & subtitle
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 92,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isDark
                              ? [
                                  const Color(0xFF0E1A1A)
                                      .withValues(alpha: 0.88),
                                  const Color(0xFF0E1A1A)
                                      .withValues(alpha: 0.0),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.90),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [accent, lighterAccent],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(
                                    alpha: isDark ? 0.35 : 0.30,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: CategoryIcon(
                              category: category,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.42)
                                  : Colors.white.withValues(alpha: 0.82),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: isDark ? Colors.white : accent,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        category.localizedTitle(context.l10n),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.localizedSubtitle(context.l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.84)
                              : colorScheme.onSurface.withValues(alpha: 0.78),
                          height: 1.28,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
