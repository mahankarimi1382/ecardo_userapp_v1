import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Preset aesthetic variants for [EcardoGlassCard].
enum EcardoGlassVariant {
  /// Standard neo-fintech frosted glass with subtle ambient glow.
  standard,

  /// Heavily frosted milky glass with heightened backdrop blur.
  frosted,

  /// Soft blue accent tint inspired by eCardo primary brand.
  accent,

  /// Cyber/neon edge glow with elevated ambient highlights.
  neon,

  /// Ultra-minimal translucent glass for secondary cards.
  subtle,
}

/// An ultra-premium neo-fintech glassmorphism card component.
///
/// Features:
/// - True hardware-accelerated [BackdropFilter] blur (sigma 10–16).
/// - Multi-stop linear gradient border with physics-inspired light refraction.
/// - Ambient radial glow positioned at configurable light source coordinates.
/// - Automatic adaptive luminance for light and dark themes.
/// - Tactile scale-down bounce with micro-haptic feedback on tap.
class EcardoGlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final Color? glowColor;
  final Alignment glowAlignment;
  final double glowRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool interactive;
  final double pressedScale;
  final EcardoGlassVariant variant;
  final List<BoxShadow>? shadows;
  final Clip clipBehavior;

  const EcardoGlassCard({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.borderRadius = AppSpacing.radiusLg,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderGradient,
    this.borderWidth = 1.2,
    this.glowColor,
    this.glowAlignment = const Alignment(-0.8, -0.8),
    this.glowRadius = 0.9,
    this.onTap,
    this.onLongPress,
    this.interactive = true,
    this.pressedScale = 0.978,
    this.variant = EcardoGlassVariant.standard,
    this.shadows,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<EcardoGlassCard> createState() => _EcardoGlassCardState();
}

class _EcardoGlassCardState extends State<EcardoGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (_isInteractive) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isInteractive) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isInteractive) {
      _controller.reverse();
    }
  }

  bool get _isInteractive =>
      widget.interactive && (widget.onTap != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve color styling dynamically based on theme and variant
    final resolvedBg = widget.backgroundColor ?? _resolveBackgroundColor(isDark);
    final resolvedBorderGradient =
        widget.borderGradient ?? _resolveBorderGradient(isDark);
    final resolvedGlow = widget.glowColor ?? _resolveGlowColor(isDark);
    final resolvedBlur = _resolveBlur();

    Widget cardBody = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      clipBehavior: widget.clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: resolvedBlur,
          sigmaY: resolvedBlur,
        ),
        child: CustomPaint(
          foregroundPainter: _GradientBorderPainter(
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            gradient: resolvedBorderGradient,
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: RadialGradient(
                center: widget.glowAlignment,
                radius: widget.glowRadius,
                colors: [
                  resolvedGlow,
                  resolvedGlow.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    // Apply soft drop shadows if enabled or provided
    final shadows = widget.shadows ?? _resolveShadows(isDark);
    if (shadows.isNotEmpty) {
      cardBody = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: shadows,
        ),
        child: cardBody,
      );
    }

    if (widget.margin != null) {
      cardBody = Padding(
        padding: widget.margin!,
        child: cardBody,
      );
    }

    if (!_isInteractive) {
      return cardBody;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: cardBody,
      ),
    );
  }

  double _resolveBlur() {
    return switch (widget.variant) {
      EcardoGlassVariant.frosted => widget.blur * 1.5,
      EcardoGlassVariant.subtle => widget.blur * 0.75,
      _ => widget.blur,
    };
  }

  Color _resolveBackgroundColor(bool isDark) {
    if (isDark) {
      return switch (widget.variant) {
        EcardoGlassVariant.standard => const Color(0x381E1E1C),
        EcardoGlassVariant.frosted => const Color(0x52262625),
        EcardoGlassVariant.accent => const Color(0x301E2E42),
        EcardoGlassVariant.neon => const Color(0x3D1A2535),
        EcardoGlassVariant.subtle => const Color(0x20161614),
      };
    } else {
      return switch (widget.variant) {
        EcardoGlassVariant.standard => const Color(0xCCFFFFFF),
        EcardoGlassVariant.frosted => const Color(0xEEF8F9FA),
        EcardoGlassVariant.accent => const Color(0xE8F2F6FC),
        EcardoGlassVariant.neon => const Color(0xE6FFFFFF),
        EcardoGlassVariant.subtle => const Color(0x99FFFFFF),
      };
    }
  }

  Gradient _resolveBorderGradient(bool isDark) {
    if (isDark) {
      return switch (widget.variant) {
        EcardoGlassVariant.neon => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x80ABC3EA),
              Color(0x33849ACD),
              Color(0x0DFFFFFF),
              Color(0x59ABC3EA),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        EcardoGlassVariant.accent => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x66ABC3EA),
              Color(0x26849ACD),
              Color(0x0AFFFFFF),
              Color(0x33ABC3EA),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        _ => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x47FFFFFF),
              Color(0x1AFFFFFF),
              Color(0x08FFFFFF),
              Color(0x26ABC3EA),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
      };
    } else {
      return switch (widget.variant) {
        EcardoGlassVariant.neon => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0x80ABC3EA),
              Color(0x40D5CBC8),
              Color(0x99ABC3EA),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        EcardoGlassVariant.accent => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFAFFFFFF),
              Color(0x66ABC3EA),
              Color(0x2BD5CBC8),
              Color(0x66849ACD),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ),
        _ => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF5FFFFFF),
              Color(0x4DFFFFFF),
              Color(0x33D5CBC8),
              Color(0x66ABC3EA),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
      };
    }
  }

  Color _resolveGlowColor(bool isDark) {
    if (isDark) {
      return switch (widget.variant) {
        EcardoGlassVariant.neon => const Color(0x33ABC3EA),
        EcardoGlassVariant.accent => const Color(0x24ABC3EA),
        EcardoGlassVariant.frosted => const Color(0x1FFFFFFF),
        EcardoGlassVariant.subtle => const Color(0x0FFFFFFF),
        EcardoGlassVariant.standard => const Color(0x1FABC3EA),
      };
    } else {
      return switch (widget.variant) {
        EcardoGlassVariant.neon => const Color(0x33ABC3EA),
        EcardoGlassVariant.accent => const Color(0x29ABC3EA),
        EcardoGlassVariant.frosted => const Color(0x33FFFFFF),
        EcardoGlassVariant.subtle => const Color(0x1AFFFFFF),
        EcardoGlassVariant.standard => const Color(0x24ABC3EA),
      };
    }
  }

  List<BoxShadow> _resolveShadows(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -4,
        ),
        if (widget.variant == EcardoGlassVariant.neon)
          BoxShadow(
            color: AppColors.mainSoftBlue.withValues(alpha: 0.15),
            offset: const Offset(0, 0),
            blurRadius: 18,
            spreadRadius: 1,
          ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color(0x14000000),
          offset: const Offset(0, 6),
          blurRadius: 20,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.mainSoftBlue.withValues(alpha: 0.08),
          offset: const Offset(0, 1),
          blurRadius: 6,
        ),
      ];
    }
  }
}

/// Custom painter that draws an exact gradient stroke along a rounded rectangle.
class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  const _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (borderWidth <= 0) return;

    final halfWidth = borderWidth / 2;
    final rect = Offset(halfWidth, halfWidth) &
        Size(size.width - borderWidth, size.height - borderWidth);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular((borderRadius - halfWidth).clamp(0.0, double.infinity)),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true
      ..shader = gradient.createShader(Offset.zero & size);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradient != gradient;
  }
}
