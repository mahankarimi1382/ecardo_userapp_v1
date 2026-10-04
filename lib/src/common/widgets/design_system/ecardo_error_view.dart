import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Creative Neo-Fintech Error View for eCardo.
///
/// Features:
/// - Continuous pulsing radar/sonar warning glyph with expanding ripple rings.
/// - Clear diagnostic headline and solution-oriented microcopy.
/// - Prominent monospace error code pill badge with one-tap copy.
/// - Animated "Try Again" button with tactile bounce and loading state.
/// - Optional expandable technical diagnostic accordion for debug/support.
/// - Adaptive light and dark theme styling.
class EcardoErrorView extends StatefulWidget {
  final String title;
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool isRetrying;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final String? technicalDetails;
  final IconData iconData;
  final Color? iconColor;
  final bool animatePulse;
  final EdgeInsetsGeometry padding;

  const EcardoErrorView({
    super.key,
    this.title = 'Unable to Complete Request',
    required this.message,
    this.errorCode,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.isRetrying = false,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.technicalDetails,
    this.iconData = Icons.wifi_off_rounded,
    this.iconColor,
    this.animatePulse = true,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  @override
  State<EcardoErrorView> createState() => _EcardoErrorViewState();
}

class _EcardoErrorViewState extends State<EcardoErrorView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _rippleAnimation;
  bool _detailsExpanded = false;
  bool _codeCopied = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOutQuad,
      ),
    );

    if (widget.animatePulse) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _copyErrorCode(String code) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: code));
    _copyTimer?.cancel();
    setState(() => _codeCopied = true);
    _copyTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.iconColor ?? AppColors.error;

    return Center(
      child: SingleChildScrollView(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Pulsing Warning Radar Glyph
            _buildPulsingRadar(isDark, accentColor),
            const SizedBox(height: AppSpacing.xxl),

            // 2. Error Code Badge (if provided)
            if (widget.errorCode != null) ...[
              _buildErrorCodeBadge(isDark, accentColor),
              const SizedBox(height: AppSpacing.md),
            ],

            // 3. Headline Title
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

            // 4. Diagnostic Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.45,
                ),
              ),
            ),

            // 5. Expandable Technical Details
            if (widget.technicalDetails != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildTechnicalAccordion(isDark),
            ],

            // 6. Action Buttons
            if (widget.onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildRetryButton(isDark, accentColor),
            ],

            if (widget.onSecondaryAction != null && widget.secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildSecondaryButton(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingRadar(bool isDark, Color accent) {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        final rippleProgress = _rippleAnimation.value;
        final rippleScale = 1.0 + (rippleProgress * 0.45);
        final rippleOpacity = (1.0 - rippleProgress).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer radar ripple ring
            Transform.scale(
              scale: rippleScale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(
                      alpha: (isDark ? 0.35 : 0.25) * rippleOpacity,
                    ),
                    width: 1.8,
                  ),
                  color: accent.withValues(
                    alpha: (isDark ? 0.08 : 0.04) * rippleOpacity,
                  ),
                ),
              ),
            ),

            // Middle glowing ambient aura
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.25 : 0.15),
                    accent.withValues(alpha: isDark ? 0.05 : 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),

            // Inner pedestal container
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkCard : AppColors.white,
                border: Border.all(
                  color: accent.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.25 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.iconData,
                  size: 30,
                  color: accent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorCodeBadge(bool isDark, Color accent) {
    return GestureDetector(
      onTap: () => _copyErrorCode(widget.errorCode!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
              : AppColors.lightSecondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _codeCopied ? Icons.check_circle_rounded : Icons.terminal_rounded,
              size: 13,
              color: _codeCopied ? AppColors.success : accent,
            ),
            const SizedBox(width: 5),
            Text(
              _codeCopied ? 'Code Copied' : widget.errorCode!,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: _codeCopied
                    ? AppColors.success
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalAccordion(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _detailsExpanded = !_detailsExpanded);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _detailsExpanded ? 'Hide Technical Details' : 'View Diagnostics',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.mutedBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _detailsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                ),
              ],
            ),
          ),
          if (_detailsExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.deepBlack : const Color(0xFFF1F1F3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                widget.technicalDetails!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.4,
                  // softGray is a dark-theme-unreadable mid gray; swap it for the
                  // theme's secondary text color so diagnostics stay legible on dark.
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.softGray,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRetryButton(bool isDark, Color accent) {
    return _AnimatedPressButton(
      label: widget.retryLabel,
      isLoading: widget.isRetrying,
      onPressed: widget.onRetry!,
      backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
      textColor: isDark ? AppColors.deepBlack : Colors.white,
      icon: Icons.refresh_rounded,
    );
  }

  Widget _buildSecondaryButton(bool isDark) {
    return TextButton(
      onPressed: widget.onSecondaryAction,
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
      child: Text(
        widget.secondaryActionLabel!,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnimatedPressButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const _AnimatedPressButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  @override
  State<_AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<_AnimatedPressButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
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
        if (!widget.isLoading) {
          HapticFeedback.lightImpact();
          _controller.forward();
        }
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: widget.textColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
