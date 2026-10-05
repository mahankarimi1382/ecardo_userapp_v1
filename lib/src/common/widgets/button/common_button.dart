import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';

/// Visual style variants for [CommonButton].
enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

class CommonButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final String text;
  final VoidCallback? onPressed;
  final FontWeight fontWeight;
  final double fontSize;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? loadingColor;
  final bool? isLoading;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final ButtonVariant variant;

  const CommonButton({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w900,
    this.fontSize = 16,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.backgroundColor,
    this.isLoading,
    this.loadingColor,
    this.gradient,
    this.boxShadow,
    this.variant = ButtonVariant.primary,
  });

  const CommonButton.primary({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w900,
    this.fontSize = 16,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.backgroundColor,
    this.isLoading,
    this.loadingColor,
    this.gradient,
    this.boxShadow,
  }) : variant = ButtonVariant.primary;

  const CommonButton.secondary({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 16,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.backgroundColor,
    this.isLoading,
    this.loadingColor,
    this.gradient,
    this.boxShadow,
  }) : variant = ButtonVariant.secondary;

  const CommonButton.outline({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 16,
    this.textColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.backgroundColor = Colors.transparent,
    this.isLoading,
    this.loadingColor,
    this.gradient,
    this.boxShadow,
  }) : variant = ButtonVariant.outline;

  const CommonButton.text({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 16,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.backgroundColor = Colors.transparent,
    this.isLoading,
    this.loadingColor,
    this.gradient,
    this.boxShadow,
  }) : variant = ButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color effectiveBgColor;
    final Color effectiveTextColor;
    final Color? effectiveBorderColor;
    final double effectiveBorderWidth;

    switch (variant) {
      case ButtonVariant.primary:
        effectiveBgColor = backgroundColor ??
            (colorScheme.primary == AppColors.deepBlack
                ? (theme.brightness == Brightness.dark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary)
                : colorScheme.primary);
        effectiveTextColor = textColor ??
            (effectiveBgColor == AppColors.darkPrimary
                ? AppColors.deepBlack
                : AppColors.white);
        effectiveBorderColor = borderColor;
        effectiveBorderWidth = borderWidth;
        break;

      case ButtonVariant.secondary:
        effectiveBgColor = backgroundColor ?? colorScheme.secondaryContainer;
        effectiveTextColor = textColor ?? colorScheme.onSecondaryContainer;
        effectiveBorderColor = borderColor;
        effectiveBorderWidth = borderWidth;
        break;

      case ButtonVariant.outline:
        effectiveBgColor = backgroundColor ?? Colors.transparent;
        effectiveTextColor = textColor ?? colorScheme.primary;
        effectiveBorderColor = borderColor ?? colorScheme.primary;
        effectiveBorderWidth = borderWidth > 0 ? borderWidth : 1.5;
        break;

      case ButtonVariant.text:
        effectiveBgColor = backgroundColor ?? Colors.transparent;
        effectiveTextColor = textColor ?? colorScheme.primary;
        effectiveBorderColor = borderColor;
        effectiveBorderWidth = 0.0;
        break;
    }

    final effectiveLoadingColor = loadingColor ?? effectiveTextColor;

    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius.r),
      onTap: isLoading == true
          ? null
          : (onPressed == null
              ? null
              : () {
                  AppHaptics.light();
                  onPressed!();
                }),
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 8.w),
        width: width == double.infinity ? double.infinity : width?.w,
        height: height?.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius.r),
          color: gradient == null ? effectiveBgColor : null,
          gradient: gradient,
          boxShadow: boxShadow,
          border: effectiveBorderColor != null && effectiveBorderWidth > 0
              ? Border.all(color: effectiveBorderColor, width: effectiveBorderWidth.w)
              : null,
        ),
        child: isLoading == true
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: effectiveLoadingColor,
                  size: 32,
                ),
              )
            : Text(
                textAlign: TextAlign.center,
                text,
                style: TextStyle(
                  fontWeight: fontWeight,
                  fontSize: fontSize.sp,
                  color: effectiveTextColor,
                  letterSpacing: 0,
                ),
              ),
      ),
    );
  }
}
