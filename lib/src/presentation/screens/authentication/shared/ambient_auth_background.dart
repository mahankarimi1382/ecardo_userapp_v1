import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Ambient radiant aura / mesh background for flagship fintech authentication screens.
/// Renders luminous radial glows and ambient gradients that smoothly adapt
/// between dark mode (deep midnight navy aura) and light mode (pristine luminous canvas).
class AmbientAuthBackground extends StatelessWidget {
  final Widget child;

  const AmbientAuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base gradient layer
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        ...AppColors.heroNightGradient,
                      ]
                    : const [
                        AppColors.lightBackground,
                        AppColors.lightSurfaceVariant,
                        AppColors.lightSurface,
                      ],
              ),
            ),
          ),
        ),

        // Top-trailing radial glowing aura
        PositionedDirectional(
          top: -100,
          end: -80,
          child: IgnorePointer(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          AppColors.mainSoftBlue.withValues(alpha: 0.16),
                          AppColors.brandViolet.withValues(alpha: 0.08),
                          AppColors.transparent,
                        ]
                      : [
                          AppColors.mainSoftBlue.withValues(alpha: 0.25),
                          AppColors.brandVioletContainer.withValues(alpha: 0.12),
                          AppColors.transparent,
                        ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Bottom-leading radial glowing aura
        PositionedDirectional(
          bottom: -120,
          start: -80,
          child: IgnorePointer(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          AppColors.brandViolet.withValues(alpha: 0.14),
                          AppColors.brandVioletDeep.withValues(alpha: 0.06),
                          AppColors.transparent,
                        ]
                      : [
                          AppColors.lightOutlineVariant.withValues(alpha: 0.40),
                          AppColors.brandVioletContainer.withValues(alpha: 0.15),
                          AppColors.transparent,
                        ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Center subtle mesh aura
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SubtleGridPainter(isDark: isDark),
            ),
          ),
        ),

        // Main content on top
        child,
      ],
    );
  }
}

/// Subtle precision grid lines for flagship fintech aesthetic.
class _SubtleGridPainter extends CustomPainter {
  final bool isDark;

  const _SubtleGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.white : AppColors.deepBlack)
          .withValues(alpha: isDark ? 0.022 : 0.015)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SubtleGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
