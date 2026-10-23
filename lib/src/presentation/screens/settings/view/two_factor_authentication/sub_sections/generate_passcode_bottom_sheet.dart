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

class GeneratePasscodeBottomSheet extends StatefulWidget {
  const GeneratePasscodeBottomSheet({super.key});

  @override
  State<GeneratePasscodeBottomSheet> createState() =>
      _GeneratePasscodeBottomSheetState();
}

class _GeneratePasscodeBottomSheetState
    extends State<GeneratePasscodeBottomSheet> {
  final TwoFactorAuthenticationController controller = Get.find();

  List<TextInputFormatter> get _digitLimit => [
    DigitNormalizationFormatter(maxLength: PasscodeHelper.maxDigits),
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(PasscodeHelper.maxDigits),
  ];

  @override
  void initState() {
    super.initState();
    controller.passcodeController.addListener(_onTextChanged);
    controller.confirmPasscodeController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.passcodeController.removeListener(_onTextChanged);
    controller.confirmPasscodeController.removeListener(_onTextChanged);
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

    final pass = controller.passcodeController.text;
    final confirm = controller.confirmPasscodeController.text;
    final isMismatch = pass.length == 4 && confirm.length == 4 && pass != confirm;
    final isMatch = pass.length == 4 && confirm.length == 4 && pass == confirm;

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
                    localization?.generatePasscodeTitle ??
                        l10nPick(
                          context,
                          en: 'Set Passcode',
                          fa: 'تعیین رمز عبور',
                          ar: 'تعيين رمز الأمان',
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

              // Passcode field
              CommonRequiredLabelAndDynamicField(
                labelText: localization?.generatePasscodeLabelPasscode ??
                    l10nPick(
                      context,
                      en: 'Passcode (4 digits)',
                      fa: 'رمز ۴ رقمی',
                    ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "••••",
                    controller: controller.passcodeController,
                    focusNode: controller.passcodeFocusNode,
                    isFocused: controller.isPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _digitLimit,
                  ),
                ),
              ),

              // Visual 4-Dot Indicator for Passcode
              SizedBox(height: 10.h),
              VisualPinDotsIndicator(
                length: 4,
                filledCount: pass.length,
                isDark: isDark,
                dotSize: 12.r,
                spacing: 12.w,
              ),

              SizedBox(height: 18.h),

              // Confirm passcode field
              CommonRequiredLabelAndDynamicField(
                labelText: localization?.generatePasscodeLabelConfirmPasscode ??
                    l10nPick(
                      context,
                      en: 'Confirm Passcode',
                      fa: 'تکرار رمز ۴ رقمی',
                    ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "••••",
                    controller: controller.confirmPasscodeController,
                    focusNode: controller.confirmPasscodeFocusNode,
                    isFocused: controller.isConfirmPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _digitLimit,
                  ),
                ),
              ),

              // Visual 4-Dot Indicator for Confirm
              SizedBox(height: 10.h),
              VisualPinDotsIndicator(
                length: 4,
                filledCount: confirm.length,
                isDark: isDark,
                isError: isMismatch,
                isSuccess: isMatch,
                dotSize: 12.r,
                spacing: 12.w,
              ),

              SizedBox(height: 28.h),
              CommonButton(
                text: localization?.generatePasscodeButtonConfirm ??
                    l10nPick(context, en: 'Confirm', fa: 'تأیید'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  controller.submitGeneratePasscode();
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
