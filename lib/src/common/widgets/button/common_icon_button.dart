import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final String text;
  final VoidCallback? onPressed;
  final FontWeight fontWeight;
  final double fontSize;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final Color? iconColor;
  final double iconAndTextSpace;
  final bool? isIconColor;
  final bool isIconRight;
  final bool? isLoading;
  final Color? loadingColor;

  const CommonIconButton({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = 16.0,
    required this.text,
    this.onPressed,
    this.fontWeight = FontWeight.w900,
    this.fontSize = 16,
    this.textColor = AppColors.white,
    this.borderColor,
    this.borderWidth = 0.0,
    this.backgroundColor = AppColors.lightPrimary,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    this.iconColor = AppColors.white,
    required this.iconAndTextSpace,
    this.isIconColor = true,
    this.isIconRight = false,
    this.isLoading,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Image.asset(
      icon,
      width: iconWidth.w,
      height: iconHeight.h,
      color: isIconColor == true ? iconColor : null,
    );

    final textWidget = Text(
      text,
      style: TextStyle(
        letterSpacing: 0,
        fontWeight: fontWeight,
        fontSize: fontSize.sp,
        color: textColor,
      ),
    );

    return GestureDetector(
      onTap: isLoading == true ? null : onPressed,
      child: Container(
        width: width?.w,
        height: height?.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius.r),
          color: backgroundColor,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: isLoading == true
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: loadingColor ?? AppColors.white,
                  size: 32,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: isIconRight
                    ? [
                        textWidget,
                        SizedBox(width: iconAndTextSpace.w),
                        iconWidget,
                      ]
                    : [
                        iconWidget,
                        SizedBox(width: iconAndTextSpace.w),
                        textWidget,
                      ],
              ),
      ),
    );
  }
}
