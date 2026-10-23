import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/digit_normalization_formatter.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class ChangePasscodeBottomSheet extends StatefulWidget {
  const ChangePasscodeBottomSheet({super.key});

  @override
  State<ChangePasscodeBottomSheet> createState() =>
      _ChangePasscodeBottomSheetState();
}

class _ChangePasscodeBottomSheetState extends State<ChangePasscodeBottomSheet> {
  final TwoFactorAuthenticationController controller = Get.find();

  List<TextInputFormatter> get _digitLimit => [
    DigitNormalizationFormatter(maxLength: PasscodeHelper.maxDigits),
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(PasscodeHelper.maxDigits),
  ];

  @override
  void initState() {
    super.initState();
    controller.oldPasscodeController.addListener(_onTextChanged);
    controller.newPasscodeController.addListener(_onTextChanged);
    controller.changedConfirmPasscodeController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.oldPasscodeController.removeListener(_onTextChanged);
    controller.newPasscodeController.removeListener(_onTextChanged);
    controller.changedConfirmPasscodeController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextTertiary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.white;

    final oldPass = controller.oldPasscodeController.text;
    final newPass = controller.newPasscodeController.text;
    final confirmPass = controller.changedConfirmPasscodeController.text;

    final isMismatch = newPass.length == 4 &&
        confirmPass.length == 4 &&
        newPass != confirmPass;
    final isMatch = newPass.length == 4 &&
        confirmPass.length == 4 &&
        newPass == confirmPass;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          topEnd: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              // Top drag indicator
              Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization?.changePasscodeTitle ??
                        l10nPick(
                          context,
                          en: 'Change Passcode',
                          fa: 'تغییر رمز عبور',
                          ar: 'تغيير رمز الأمان',
                        ),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 20.sp,
                      color: primaryTextColor,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: l10nPick(context, en: 'Close', fa: 'بستن'),
                    child: IconButton(
                      tooltip: l10nPick(context, en: 'Close', fa: 'بستن'),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22.sp,
                        color: secondaryTextColor,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              SizedBox(height: 20.h),

              // Old Passcode
              CommonRequiredLabelAndDynamicField(
                labelText: localization?.changePasscodeLabelOldPasscode ??
                    l10nPick(
                      context,
                      en: 'Current Passcode',
                      fa: 'رمز عبور فعلی',
                    ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "••••",
                    controller: controller.oldPasscodeController,
                    focusNode: controller.oldPasscodeFocusNode,
                    isFocused: controller.isOldPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _digitLimit,
                  ),
                ),
              ),

              // Visual 4-Dot Indicator for Old Passcode
              SizedBox(height: 8.h),
              VisualPinDotsIndicator(
                length: 4,
                filledCount: oldPass.length,
                isDark: isDark,
                dotSize: 11.r,
                spacing: 10.w,
              ),

              SizedBox(height: 16.h),

              // New Passcode
              CommonRequiredLabelAndDynamicField(
                labelText: localization?.changePasscodeLabelNewPasscode ??
                    l10nPick(
                      context,
                      en: 'New Passcode',
                      fa: 'رمز عبور جدید',
                    ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "••••",
                    controller: controller.newPasscodeController,
                    focusNode: controller.newPasscodeFocusNode,
                    isFocused: controller.isNewPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _digitLimit,
                  ),
                ),
              ),

              // Visual 4-Dot Indicator for New Passcode
              SizedBox(height: 8.h),
              VisualPinDotsIndicator(
                length: 4,
                filledCount: newPass.length,
                isDark: isDark,
                dotSize: 11.r,
                spacing: 10.w,
              ),

              SizedBox(height: 16.h),

              // Confirm New Passcode
              CommonRequiredLabelAndDynamicField(
                labelText: localization?.changePasscodeLabelConfirmPasscode ??
                    l10nPick(
                      context,
                      en: 'Confirm New Passcode',
                      fa: 'تکرار رمز عبور جدید',
                    ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "••••",
                    controller: controller.changedConfirmPasscodeController,
                    focusNode: controller.changedConfirmPasscodeFocusNode,
                    isFocused: controller.isChangeConfirmPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _digitLimit,
                  ),
                ),
              ),

              // Visual 4-Dot Indicator for Confirm Passcode
              SizedBox(height: 8.h),
              VisualPinDotsIndicator(
                length: 4,
                filledCount: confirmPass.length,
                isDark: isDark,
                isError: isMismatch,
                isSuccess: isMatch,
                dotSize: 11.r,
                spacing: 10.w,
              ),

              SizedBox(height: 28.h),
              CommonButton(
                text: localization?.changePasscodeButtonChange ??
                    l10nPick(context, en: 'Change Passcode', fa: 'تغییر رمز'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.submitChangePasscode();
                },
                borderRadius: 14.r,
                height: 50.h,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
