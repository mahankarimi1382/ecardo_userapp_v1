import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Neo-fintech "Swipe to Confirm" action button.
///
/// Designed specifically for high-value financial actions (crypto transfers,
/// remittance approval, fiat withdrawals, escrow payments) to prevent accidental taps.
///
/// Features:
/// - Smooth inertia drag physics with spring snap-back.
/// - Fluid glowing gradient track that fills dynamically behind the thumb.
/// - Progressive tactile haptic ticks at intermediate and completion milestones.
/// - Text cross-fade with directional shimmer hint.
/// - Smooth transition to loading spinner and success checkmark states.
class EcardoSwipeButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  final String text;
  final String? loadingText;
  final String? successText;
  final Widget? icon;
  final bool isLoading;
  final bool isSuccess;
  final bool enabled;
  final double height;
  final double? width;
  final double threshold;
  final Gradient? activeGradient;
  final Color? trackColor;
  final Color? thumbColor;
  final Color? textColor;
  final bool animateShimmer;
  final EdgeInsetsGeometry? margin;

  const EcardoSwipeButton({
    super.key,
    required this.onSwipeComplete,
    this.text = 'Swipe to Confirm',
    this.loadingText = 'Processing...',
    this.successText = 'Confirmed',
    this.icon,
    this.isLoading = false,
    this.isSuccess = false,
    this.enabled = true,
    this.height = 58.0,
    this.width,
    this.threshold = 0.85,
    this.activeGradient,
    this.trackColor,
    this.thumbColor,
    this.textColor,
    this.animateShimmer = true,
    this.margin,
  });

  @override
  State<EcardoSwipeButton> createState() => EcardoSwipeButtonState();
}

class EcardoSwipeButtonState extends State<EcardoSwipeButton>
    with TickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _completed = false;
  bool _passedHalfwayHaptic = false;

  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.animateShimmer) {
      _shimmerController.repeat();
    }

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    // Seed with a listener-free animation so _animateTo can always removeListener
    // without hitting a LateInitializationError on the first snap.
    _resetAnimation = const AlwaysStoppedAnimation<double>(0.0);
  }

  @override
  void didUpdateWidget(EcardoSwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if loading or success finished or if explicitly enabled again
    if (oldWidget.isLoading && !widget.isLoading && !widget.isSuccess) {
      reset();
    }
  }

  @override
  void dispose() {
    _resetController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// Manually reset the swipe button thumb back to 0.0.
  void reset() {
    if (!mounted) return;
    _resetController.stop();
    setState(() {
      _dragPosition = 0.0;
      _completed = false;
      _passedHalfwayHaptic = false;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!widget.enabled || widget.isLoading || widget.isSuccess || _completed) {
      return;
    }

    final newPos = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    final progress = maxDrag > 0 ? (newPos / maxDrag) : 0.0;

    // Haptic tick at 50% milestone
    if (progress >= 0.5 && !_passedHalfwayHaptic) {
      _passedHalfwayHaptic = true;
      HapticFeedback.selectionClick();
    } else if (progress < 0.5 && _passedHalfwayHaptic) {
      _passedHalfwayHaptic = false;
    }

    setState(() {
      _dragPosition = newPos;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) {
    if (!widget.enabled || widget.isLoading || widget.isSuccess || _completed) {
      return;
    }

    final progress = maxDrag > 0 ? (_dragPosition / maxDrag) : 0.0;

    if (progress >= widget.threshold) {
      // Trigger completion
      _snapToComplete(maxDrag);
    } else {
      // Snap back to zero with spring
      _snapBack();
    }
  }

  void _animateTo(double target, Curve curve) {
    _resetController.stop();
    // Drop the previous listener before wiring a new one: each snap rebuilds the
    // Animation, and leaving the old listener attached would keep calling setState
    // from a stale animation — accumulating one per swipe attempt.
    _resetAnimation.removeListener(_onAnimationTick);
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: target,
    ).animate(
      CurvedAnimation(parent: _resetController, curve: curve),
    )..addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    if (!mounted) return;
    setState(() => _dragPosition = _resetAnimation.value);
  }

  void _snapToComplete(double maxDrag) {
    _completed = true;
    _animateTo(maxDrag, Curves.easeOutCubic);

    _resetController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      widget.onSwipeComplete();
    });
  }

  void _snapBack() {
    _animateTo(0.0, Curves.easeOutBack);

    _resetController.forward(from: 0.0).then((_) {
      _passedHalfwayHaptic = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double thumbSize = widget.height - 8.0;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final maxDrag = math.max(0.0, totalWidth - thumbSize - 8.0);
          final progress = maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

          return _buildTrack(
            context,
            isDark,
            totalWidth,
            maxDrag,
            progress,
            thumbSize,
          );
        },
      ),
    );
  }

  Widget _buildTrack(
    BuildContext context,
    bool isDark,
    double totalWidth,
    double maxDrag,
    double progress,
    double thumbSize,
  ) {
    final defaultTrackColor = isDark
        ? AppColors.darkCard
        : AppColors.lightSecondaryContainer.withValues(alpha: 0.6);

    final resolvedTrackColor = widget.trackColor ?? defaultTrackColor;

    final defaultGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF263345),
              AppColors.mainSoftBlue,
            ],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          )
        : const LinearGradient(
            colors: [
              AppColors.darkGray,
              AppColors.deepBlack,
            ],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          );

    final resolvedGradient = widget.activeGradient ?? defaultGradient;

    final fillWidth = (thumbSize + 8.0 + _dragPosition).clamp(0.0, totalWidth);

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        // 1. Outer Track Container
        Container(
          width: totalWidth,
          height: widget.height,
          decoration: BoxDecoration(
            color: resolvedTrackColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
        ),

        // 2. Glowing Gradient Fill that follows thumb
        if (fillWidth > 0 && !widget.isLoading && !widget.isSuccess)
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Container(
              width: fillWidth,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: resolvedGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainSoftBlue.withValues(
                      alpha: isDark ? 0.35 * progress : 0.20 * progress,
                    ),
                    blurRadius: 16 * progress,
                    spreadRadius: 2 * progress,
                  ),
                ],
              ),
            ),
          ),

        // 3. Status Display (Loading / Success / Centered Text Label)
        if (widget.isLoading)
          _buildLoadingState(isDark)
        else if (widget.isSuccess)
          _buildSuccessState(isDark)
        else
          _buildTextLabel(isDark, progress, totalWidth, thumbSize),

        // 4. Draggable Thumb
        if (!widget.isLoading && !widget.isSuccess)
          Positioned(
            left: 4.0 + _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) =>
                  _onHorizontalDragUpdate(details, maxDrag),
              onHorizontalDragEnd: (details) =>
                  _onHorizontalDragEnd(details, maxDrag),
              child: _buildThumb(isDark, thumbSize, progress),
            ),
          ),
      ],
    );
  }

  Widget _buildTextLabel(
    bool isDark,
    double progress,
    double totalWidth,
    double thumbSize,
  ) {
    final textColor = widget.textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    // Fade out as thumb travels across
    final textOpacity = (1.0 - (progress * 2.2)).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Opacity(
        opacity: textOpacity,
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: thumbSize / 2),
                Text(
                  widget.text,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                _buildShimmerArrows(textColor),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerArrows(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: textColor.withValues(alpha: 0.35),
        ),
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: textColor.withValues(alpha: 0.70),
          ),
        ),
        Transform.translate(
          offset: const Offset(-16, 0),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildThumb(bool isDark, double size, double progress) {
    final defaultThumbColor = isDark ? AppColors.darkSurface : AppColors.white;
    final thumbColor = widget.thumbColor ?? defaultThumbColor;

    final iconColor = isDark ? AppColors.mainSoftBlue : AppColors.deepBlack;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: thumbColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
            blurRadius: 8 + (progress * 6),
            offset: const Offset(0, 2),
          ),
          if (progress > 0.8)
            BoxShadow(
              color: AppColors.mainSoftBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: widget.icon ??
            Icon(
              Icons.arrow_forward_rounded,
              color: iconColor,
              size: 20,
            ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            widget.loadingText ?? 'Processing...',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          // successContainer is a near-white tint meant for the light theme; on a dark
          // track it reads as a bright slab. Alpha over the track keeps the same hue
          // without the glare.
          color: isDark
              ? AppColors.success.withValues(alpha: 0.18)
              : AppColors.successContainer,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.successText ?? 'Confirmed',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
