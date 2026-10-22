import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Interactive & visual 4-dot / 6-dot indicator widget:
/// - Smooth scaling and glowing animations as dots are filled
/// - Horizontal shake animation and red color on error / mismatch
/// - Success pulse animation on successful PIN verification
/// - Compact badge mode for Settings screen preview rows
class VisualPinDotsIndicator extends StatefulWidget {
  final int length;
  final int filledCount;
  final bool isError;
  final bool isSuccess;
  final bool isDark;
  final double dotSize;
  final double spacing;

  const VisualPinDotsIndicator({
    super.key,
    this.length = 4,
    required this.filledCount,
    this.isError = false,
    this.isSuccess = false,
    required this.isDark,
    this.dotSize = 14.0,
    this.spacing = 12.0,
  });

  /// Compact static badge for settings rows showing configured 4-dot or 6-dot state.
  static Widget compact({
    required int length,
    required bool isConfigured,
    required bool isDark,
    double dotSize = 6.0,
    double spacing = 4.0,
  }) {
    final activeColor = isConfigured
        ? AppColors.success
        : (isDark ? AppColors.softGray : AppColors.lightTextTertiary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConfigured ? activeColor : Colors.transparent,
            border: isConfigured
                ? null
                : Border.all(
                    color: activeColor.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
          ),
        );
      }),
    );
  }

  @override
  State<VisualPinDotsIndicator> createState() => _VisualPinDotsIndicatorState();
}

class _VisualPinDotsIndicatorState extends State<VisualPinDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant VisualPinDotsIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = widget.isError
            ? math.sin(_shakeAnimation.value * math.pi * 4) * 8.0
            : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          final isFilled = index < widget.filledCount;
          final isActive = index == widget.filledCount;
          return _buildDot(isFilled: isFilled, isActive: isActive);
        }),
      ),
    );
  }

  Widget _buildDot({required bool isFilled, required bool isActive}) {
    Color fillColor;
    Color borderColor;

    if (widget.isError) {
      fillColor = AppColors.error;
      borderColor = AppColors.error;
    } else if (widget.isSuccess) {
      fillColor = AppColors.success;
      borderColor = AppColors.success;
    } else if (isFilled) {
      fillColor = widget.isDark
          ? AppColors.mainSoftBlue
          : AppColors.lightPrimary;
      borderColor = widget.isDark
          ? AppColors.mainSoftBlue
          : AppColors.lightPrimary;
    } else if (isActive) {
      fillColor = Colors.transparent;
      borderColor = widget.isDark
          ? AppColors.mainSoftBlue
          : AppColors.lightPrimary;
    } else {
      fillColor = Colors.transparent;
      borderColor = widget.isDark
          ? AppColors.darkBorder
          : AppColors.greyLight.withValues(alpha: 0.9);
    }

    final currentSize = isFilled ? widget.dotSize * 1.15 : widget.dotSize;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
      width: currentSize.w,
      height: currentSize.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(color: borderColor, width: isActive ? 2.0 : 1.5),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: fillColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}
