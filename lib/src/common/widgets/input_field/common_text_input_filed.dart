import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonTextInputField extends StatelessWidget {
  final String hintText;
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
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final int? maxLine;
  final double? borderRadius;
  final bool? isBorderShow;
  final double? topLeftBorderRadius;
  final double? topRightBorderRadius;
  final double? bottomLeftBorderRadius;
  final double? bottomRightBorderRadius;
  final double? verticalPadding;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isInputFormatter;
  final bool? isSuffixIconOnTap;
  final Function()? suffixIconOnTap;
  final Widget? prefixIcon;
  final bool isSuffixIconCompact;
  final double? suffixIconWidth;
  final double? suffixIconHeight;

  const CommonTextInputField({
    super.key,
    required this.hintText,
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
    this.suffixIcon,
    this.suffixIconColor,
    this.onTap,
    this.backgroundColor,
    this.maxLine = 1,
    this.borderRadius,
    this.isBorderShow = true,
    this.topLeftBorderRadius,
    this.topRightBorderRadius,
    this.bottomLeftBorderRadius,
    this.bottomRightBorderRadius,
    this.verticalPadding,
    this.inputFormatters,
    this.isInputFormatter = false,
    this.suffixIconOnTap,
    this.isSuffixIconOnTap = false,
    this.prefixIcon,
    this.isSuffixIconCompact = true,
    this.suffixIconWidth,
    this.suffixIconHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isFocused
        ? AppColors.lightPrimary.withValues(alpha: 0.60)
        : AppColors.lightTextPrimary.withValues(alpha: 0.2);

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      focusNode: focusNode,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      style:
          textStyle ??
          TextStyle(
            fontSize: 15.sp,
            color: AppColors.lightTextPrimary,
            letterSpacing: 0,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
      maxLines: maxLine,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: verticalPadding?.h ?? 16.h,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: backgroundColor ?? AppColors.transparent,
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
          borderSide: isBorderShow == true
              ? BorderSide(color: borderColor, width: 1.w)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _getBorderRadius(context),
          borderSide: isBorderShow == true
              ? BorderSide(color: borderColor, width: 1.w)
              : BorderSide.none,
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
            ? (isSuffixIconOnTap == true
                  ? GestureDetector(
                      onTap: suffixIconOnTap,
                      child: isSuffixIconCompact
                          ? Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: 8.w,
                                end: 12.w,
                              ),
                              child: SizedBox(
                                width: suffixIconWidth?.w ?? 14.w,
                                height: suffixIconHeight?.h ?? 14.h,
                                child: suffixIcon,
                              ),
                            )
                          : SizedBox(
                              width: suffixIconWidth?.w ?? 14.w,
                              height: suffixIconHeight?.h ?? 14.h,
                              child: suffixIcon,
                            ),
                    )
                  : (isSuffixIconCompact
                        ? Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: 8.w,
                              end: 12,
                            ),
                            child: SizedBox(
                              width: suffixIconWidth?.w ?? 14.w,
                              height: suffixIconHeight?.h ?? 14.h,
                              child: suffixIcon,
                            ),
                          )
                        : SizedBox(
                            width: suffixIconWidth?.w ?? 14.w,
                            height: suffixIconHeight?.h ?? 14.h,
                            child: suffixIcon,
                          )))
            : null,

        suffixIconConstraints: isSuffixIconCompact
            ? BoxConstraints(minWidth: 20.w, minHeight: 20.h)
            : null,
      ),
    );
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    final baseRadius = borderRadius?.r ?? 16.r;

    final topLeft = topLeftBorderRadius?.r ?? baseRadius.r;
    final topRight = topRightBorderRadius?.r ?? baseRadius.r;
    final bottomLeft = bottomLeftBorderRadius?.r ?? baseRadius.r;
    final bottomRight = bottomRightBorderRadius?.r ?? baseRadius.r;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BorderRadius.only(
      topLeft: Radius.circular(isRtl ? topRight : topLeft),
      topRight: Radius.circular(isRtl ? topLeft : topRight),
      bottomLeft: Radius.circular(isRtl ? bottomRight : bottomLeft),
      bottomRight: Radius.circular(isRtl ? bottomLeft : bottomRight),
    );
  }
}
