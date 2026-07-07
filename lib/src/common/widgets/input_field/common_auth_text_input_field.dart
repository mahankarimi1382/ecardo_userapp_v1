import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonAuthTextInputField extends StatelessWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool isFocused;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool enabled;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? backgroundColor;
  final List<String>? autofillHints;
  final VoidCallback? onTap;
  final double? borderRadius;
  final double? topLeftBorderRadius;
  final double? topRightBorderRadius;
  final double? bottomLeftBorderRadius;
  final double? bottomRightBorderRadius;

  const CommonAuthTextInputField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.isFocused = false,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.textStyle,
    this.hintStyle,
    this.backgroundColor,
    this.autofillHints,
    this.onTap,
    this.borderRadius,
    this.topLeftBorderRadius,
    this.topRightBorderRadius,
    this.bottomLeftBorderRadius,
    this.bottomRightBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isFocused
        ? AppColors.lightPrimary.withValues(alpha: 0.60)
        : AppColors.lightTextPrimary.withValues(alpha: 0.2);

    return SizedBox(
      height: 48.h,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        focusNode: focusNode,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        enabled: enabled,
        autofillHints: autofillHints,
        onTap: onTap,
        style:
            textStyle ??
            TextStyle(
              fontSize: 15.sp,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: AppColors.transparent,
          hintText: hintText,
          hintStyle:
              hintStyle ??
              TextStyle(
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                letterSpacing: 0,
                height: 1.1,
              ),
          enabledBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(context),
            borderSide: BorderSide(color: borderColor, width: 1.5.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: _getBorderRadius(context),
            borderSide: BorderSide(color: borderColor, width: 1.5.w),
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 12.w,
                    end: 8.w,
                  ),
                  child: prefixIcon,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 8.w,
                    end: 12.w,
                  ),
                  child: suffixIcon,
                )
              : null,
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    final baseRadius = borderRadius?.r ?? 16.r;

    final topLeft = topLeftBorderRadius?.r ?? baseRadius;
    final topRight = topRightBorderRadius?.r ?? baseRadius;
    final bottomLeft = bottomLeftBorderRadius?.r ?? baseRadius;
    final bottomRight = bottomRightBorderRadius?.r ?? baseRadius;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BorderRadius.only(
      topLeft: Radius.circular(isRtl ? topRight : topLeft),
      topRight: Radius.circular(isRtl ? topLeft : topRight),
      bottomLeft: Radius.circular(isRtl ? bottomRight : bottomLeft),
      bottomRight: Radius.circular(isRtl ? bottomLeft : bottomRight),
    );
  }
}
