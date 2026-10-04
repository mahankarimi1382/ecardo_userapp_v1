import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Modern floating label input field with sleek frosted styling, glowing focus,
/// and clear animated error presentation.
class CreativeFloatingTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isFocused;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? errorText;
  final List<String>? autofillHints;
  final bool isRequired;
  final bool readOnly;
  final VoidCallback? onTap;

  const CreativeFloatingTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.isFocused = false,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.errorText,
    this.autofillHints,
    this.isRequired = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    final primaryAccent =
        isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack;

    // Field surface background
    final fieldBg = isDark
        ? Colors.white.withValues(alpha: isFocused ? 0.08 : 0.04)
        : (isFocused ? const Color(0xFFF8FAFC) : const Color(0xFFFFFFFF));

    // Border color
    Color borderColor;
    if (hasError) {
      borderColor = const Color(0xFFEF4444);
    } else if (isFocused) {
      borderColor = primaryAccent;
    } else {
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : AppColors.lightBorder.withValues(alpha: 0.7);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: borderColor,
              width: isFocused || hasError ? 1.6 : 1.2,
            ),
            boxShadow: [
              if (isFocused && !hasError)
                BoxShadow(
                  color: primaryAccent.withValues(alpha: isDark ? 0.25 : 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              if (hasError)
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            autofillHints: autofillHints,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsetsDirectional.only(
                start: prefixIcon != null ? 10.w : 16.w,
                end: 14.w,
                top: 14.h,
                bottom: 14.h,
              ),
              labelText: isRequired ? '$label *' : label,
              labelStyle: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: hasError
                    ? const Color(0xFFEF4444)
                    : (isFocused
                        ? primaryAccent
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary)),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              floatingLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: hasError
                    ? const Color(0xFFEF4444)
                    : (isFocused
                        ? primaryAccent
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                    : AppColors.lightTextTertiary.withValues(alpha: 0.6),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 8.w),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 13.sp,
                  color: const Color(0xFFEF4444),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
