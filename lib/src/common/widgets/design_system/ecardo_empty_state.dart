import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Creative Neo-Fintech Empty State View for eCardo.
///
/// Features:
/// - Multi-layered glowing icon container with breathing radial gradient aura.
/// - Concentric decorative orbital rings mimicking financial planetary vaults.
/// - Clear, inspiring microcopy with headline and informative guidance.
/// - Primary and optional secondary CTA buttons with tactile bounce press.
/// - Adaptive light and dark theme styling.
class EcardoEmptyState extends StatefulWidget {
  final String title;
  final String description;
  final IconData? iconData;
  final Widget? icon;
  final Color? iconColor;
  final Color? glowColor;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? customIllustration;
  final bool animateGlow;
  final EdgeInsetsGeometry padding;

  const EcardoEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.iconData = Icons.account_balance_wallet_outlined,
    this.icon,
    this.iconColor,
    this.glowColor,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.customIllustration,
    this.animateGlow = true,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  @override
  State<EcardoEmptyState> createState() => _EcardoEmptyStateState();
}

class _EcardoEmptyStateState extends State<EcardoEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.animateGlow) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultGlow = isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue;
    final glow = widget.glowColor ?? defaultGlow;

    return Center(
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Glowing Orbital Icon Container
            widget.customIllustration ?? _buildGlowingIcon(isDark, glow),
            const SizedBox(height: AppSpacing.xxl),

            // 2. Headline Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Inspiring Microcopy
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.45,
                ),
              ),
            ),

            // 4. CTA Action Buttons
            if (widget.primaryActionLabel != null && widget.onPrimaryAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildPrimaryButton(context, isDark),
            ],

            if (widget.secondaryActionLabel != null && widget.onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildSecondaryButton(context, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingIcon(bool isDark, Color glow) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.animateGlow ? _pulseAnimation.value : 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer breathing ambient glow aura
            Transform.scale(
              scale: scale,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.withValues(alpha: isDark ? 0.28 : 0.18),
                      glow.withValues(alpha: isDark ? 0.08 : 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Middle orbital dashed/gradient boundary ring
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.45)
                    : AppColors.lightSecondaryContainer.withValues(alpha: 0.50),
                border: Border.all(
                  color: isDark
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.35)
                      : AppColors.mutedBlue.withValues(alpha: 0.30),
                  width: 1.2,
                ),
              ),
            ),

            // Inner solid icon pedestal
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCard : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: widget.icon ??
                    Icon(
                      widget.iconData,
                      size: 32,
                      color: widget.iconColor ??
                          (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDark) {
    return _TactileButton(
      label: widget.primaryActionLabel!,
      onPressed: widget.onPrimaryAction!,
      backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
      textColor: isDark ? AppColors.deepBlack : Colors.white,
      isPrimary: true,
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDark) {
    return _TactileButton(
      label: widget.secondaryActionLabel!,
      onPressed: widget.onSecondaryAction!,
      backgroundColor: Colors.transparent,
      textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      isPrimary: false,
    );
  }
}

class _TactileButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isPrimary;

  const _TactileButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.isPrimary,
  });

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isPrimary ? 28 : 16,
            vertical: widget.isPrimary ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelLarge.copyWith(
              color: widget.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
