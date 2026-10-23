import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/controller/verify_passcode_controller.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/visual_pin_dots_indicator.dart';

/// Ultra-Modernized Neo-Fintech Transaction PIN Bottom Sheet (BluBank/Revolut Style).
///
/// Features:
/// - Visual 4-dot indicator via [VisualPinDotsIndicator] with glowing scale & error shake.
/// - Tactile numeric keypad with haptic feedback on every tap.
/// - Instant auto-submit upon entering the 4th digit (no extra confirm tap required).
/// - Comprehensive Dark/Light mode theme adaptation.
/// - Native RTL & Multilingual copy (fa, en, ar, tr, ru).
class VerifyPasscodeBottomSheet extends StatefulWidget {
  final int pinLength;

  const VerifyPasscodeBottomSheet({super.key, this.pinLength = 4});

  @override
  State<VerifyPasscodeBottomSheet> createState() =>
      _VerifyPasscodeBottomSheetState();
}

class _VerifyPasscodeBottomSheetState extends State<VerifyPasscodeBottomSheet> {
  final VerifyPasscodeController controller = Get.put(
    VerifyPasscodeController(),
  );

  String _pin = '';
  bool _isError = false;
  bool _isSuccess = false;

  void _onDigitTap(String digit) {
    if (controller.isPasscodeVerifyLoading.value ||
        _pin.length >= widget.pinLength) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isError = false;
      _pin += digit;
      controller.passcodeController.text = _pin;
    });

    if (_pin.length == widget.pinLength) {
      _handleSubmit();
    }
  }

  void _onBackspaceTap() {
    if (controller.isPasscodeVerifyLoading.value || _pin.isEmpty) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
      controller.passcodeController.text = _pin;
    });
  }

  Future<void> _handleSubmit() async {
    final code = _pin.trim();
    if (!PasscodeHelper.isValidFormat(code)) {
      setState(() => _isError = true);
      HapticFeedback.heavyImpact();
      ToastHelper().showErrorToast(
        l10nPick(
          context,
          en: 'Please enter a valid 4-digit PIN',
          fa: 'لطفاً رمز ۴ رقمی معتبر را وارد نمایید',
          ar: 'يرجى إدخال رمز أمان صحيح من 4 أرقام',
          tr: 'Lütfen geçerli 4 haneli PIN girin',
          ru: 'Пожалуйста, введите 4-значный PIN-код',
        ),
      );
      return;
    }

    final success = await controller.submitPasscodeVerify();
    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      Get.back(result: code);
    } else {
      setState(() {
        _isError = true;
        _pin = '';
        controller.passcodeController.clear();
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isError = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);

    final bgColor = isDark ? AppColors.darkCard : AppColors.white;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subtextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Header Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 16.r,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      localization?.verifyPasscodeTitle ??
                          l10nPick(
                            context,
                            en: 'Transaction PIN',
                            fa: 'رمز انتقال وجه',
                            ar: 'رمز أمان التحويل',
                          ),
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Semantics(
                  button: true,
                  label: l10nPick(context, en: 'Close', fa: 'بستن'),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.back();
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 48.w,
                        minHeight: 48.h,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 30.r,
                        height: 30.r,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.r,
                          color: subtextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Instruction Subtitle
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10nPick(
                  context,
                  en: 'Enter your 4-digit transaction PIN to confirm',
                  fa: 'رمز ۴ رقمی انتقال وجه خود را وارد فرمایید',
                  ar: 'أدخل رمز PIN المكون من 4 أرقام لتأكيد العملية',
                  tr: 'Onaylamak için 4 haneli işlem PIN kodunuzu girin',
                  ru: 'Введите 4-значный PIN-код для подтверждения',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: subtextColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Visual PIN Dots Indicator
            Obx(
              () => controller.isPasscodeVerifyLoading.value
                  ? SizedBox(
                      height: 32.h,
                      child: Center(
                        child: SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet,
                          ),
                        ),
                      ),
                    )
                  : VisualPinDotsIndicator(
                      length: widget.pinLength,
                      filledCount: _pin.length,
                      isError: _isError,
                      isSuccess: _isSuccess,
                      isDark: isDark,
                      dotSize: 16.r,
                      spacing: 16.w,
                    ),
            ),
            SizedBox(height: 28.h),

            // Tactile Numeric Keypad Grid
            _buildNumericKeypad(isDark, textColor),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(bool isDark, Color textColor) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], isDark, textColor),
        SizedBox(height: 10.h),
        _buildKeypadRow(['4', '5', '6'], isDark, textColor),
        SizedBox(height: 10.h),
        _buildKeypadRow(['7', '8', '9'], isDark, textColor),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Empty placeholder / clear
            _buildKeypadButton(
              child: Text(
                'C',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              onTap: () {
                if (_pin.isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _pin = '';
                    controller.passcodeController.clear();
                  });
                }
              },
              isDark: isDark,
            ),
            _buildKeypadButton(
              child: Text(
                '0',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              onTap: () => _onDigitTap('0'),
              isDark: isDark,
            ),
            _buildKeypadButton(
              child: Icon(
                Icons.backspace_outlined,
                size: 20.r,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              onTap: _onBackspaceTap,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> digits, bool isDark, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _buildKeypadButton(
          child: Text(
            digit,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          onTap: () => _onDigitTap(digit),
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    required Widget child,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        width: 68.w,
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.6)
              : AppColors.lightSecondaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightOutlineVariant,
            width: 0.8,
          ),
        ),
        child: child,
      ),
    );
  }
}
