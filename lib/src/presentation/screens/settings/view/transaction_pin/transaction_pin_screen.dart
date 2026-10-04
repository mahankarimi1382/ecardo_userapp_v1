import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/transaction_pin_controller.dart';

/// System B — رمز انتقال وجه (Transaction PIN). Not 2FA, not App Lock.
class TransactionPinScreen extends StatefulWidget {
  const TransactionPinScreen({super.key});

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen> {
  late final TransactionPinController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(TransactionPinController());
  }

  List<TextInputFormatter> get _fmt => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(PasscodeHelper.maxDigits),
      ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final range = '${PasscodeHelper.minDigits}–${PasscodeHelper.maxDigits}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  l10nPick(
                    context,
                    en: 'Transaction PIN',
                    fa: 'رمز انتقال وجه',
                    ar: 'رمز التحويل',
                    zh: '转账密码',
                  ),
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Text(
                  l10nPick(
                    context,
                    en: 'Set a 4–6 digit PIN to authorize transfers and payments',
                    fa: 'یک رمز ۴ تا ۶ رقمی برای تأیید انتقال وجه و پرداخت‌ها تعیین کنید',
                    ar: 'قم بتعيين رمز من 4-6 أرقام لتأكيد التحويلات والمدفوعات',
                    zh: '设置4–6位密码以验证转账与支付',
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
                child: Text(
                  l10nPick(
                    context,
                    en: '($range digits)',
                    fa: '($range رقم)',
                    ar: '($range أرقام)',
                    zh: '($range 位数字)',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryTextColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const CommonLoading();
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: c.hasPasscode.value
                        ? _managed(loc, isDark, primaryTextColor, secondaryTextColor)
                        : _set(loc, isDark, primaryTextColor, secondaryTextColor),
                  );
                }),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: c.isBusy.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _set(
    AppLocalizations loc,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        _card(
          isDark: isDark,
          child: Column(
            children: [
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'Transaction PIN',
                  fa: 'رمز انتقال وجه',
                  ar: 'رمز التحويل',
                  zh: '转账密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '••••',
                    controller: c.passcodeController,
                    focusNode: c.passcodeFocus,
                    isFocused: c.isPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'Repeat Transaction PIN',
                  fa: 'تکرار رمز انتقال وجه',
                  ar: 'تأكيد رمز التحويل',
                  zh: '确认转账密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '••••',
                    controller: c.confirmController,
                    focusNode: c.confirmFocus,
                    isFocused: c.isConfirmFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              CommonButton(
                width: double.infinity,
                text: l10nPick(
                  context,
                  en: 'Set Transaction PIN',
                  fa: 'ثبت رمز انتقال',
                  ar: 'تعيين رمز التحويل',
                  zh: '设置转账密码',
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  c.submitSet();
                },
                borderRadius: AppSpacing.radiusMd,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.bottomSafe(context, 20)),
      ],
    );
  }

  Widget _managed(
    AppLocalizations loc,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Change Transaction PIN',
                  fa: 'تغییر رمز انتقال وجه',
                  ar: 'تغيير رمز التحويل',
                  zh: '修改转账密码',
                ),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'Current PIN',
                  fa: 'رمز انتقال فعلی',
                  ar: 'رمز التحويل الحالي',
                  zh: '当前转账密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '••••',
                    controller: c.oldController,
                    focusNode: c.oldFocus,
                    isFocused: c.isOldFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'New PIN',
                  fa: 'رمز انتقال جدید',
                  ar: 'رمز التحويل الجديد',
                  zh: '新转账密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '••••',
                    controller: c.newController,
                    focusNode: c.newFocus,
                    isFocused: c.isNewFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'Repeat New PIN',
                  fa: 'تکرار رمز انتقال جدید',
                  ar: 'تأكيد رمز التحويل الجديد',
                  zh: '确认新密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '••••',
                    controller: c.changeConfirmController,
                    focusNode: c.changeConfirmFocus,
                    isFocused: c.isChangeConfirmFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.titleMedium.copyWith(
                      color: primaryTextColor,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              CommonButton(
                width: double.infinity,
                text: l10nPick(
                  context,
                  en: 'Change PIN',
                  fa: 'تغییر رمز',
                  ar: 'تغيير الرمز',
                  zh: '修改密码',
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  c.submitChange();
                },
                borderRadius: AppSpacing.radiusMd,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Disable Transaction PIN',
                  fa: 'غیرفعال‌سازی رمز انتقال وجه',
                  ar: 'تعطيل رمز التحويل',
                  zh: '停用转账密码',
                ),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10nPick(
                  context,
                  en: 'Account password is required to disable (not transaction PIN).',
                  fa: 'برای غیرفعال‌سازی، رمز ورود حساب لازم است (نه رمز انتقال).',
                  ar: 'يلزم إدخال كلمة مرور الحساب للتعطيل (وليس رمز التحويل).',
                  zh: '停用需要账户密码（而非转账密码）。',
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              CommonRequiredLabelAndDynamicField(
                labelText: l10nPick(
                  context,
                  en: 'Account Password',
                  fa: 'رمز ورود حساب',
                  ar: 'كلمة مرور الحساب',
                  zh: '账户密码',
                ),
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '',
                    controller: c.passwordController,
                    focusNode: c.passwordFocus,
                    isFocused: c.isPasswordFocused.value,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    textStyle: AppTextStyles.bodyMedium.copyWith(color: primaryTextColor),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              CommonButton(
                width: double.infinity,
                backgroundColor: AppColors.error,
                text: l10nPick(
                  context,
                  en: 'Disable PIN',
                  fa: 'غیرفعال‌سازی',
                  ar: 'تعطيل',
                  zh: '停用',
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  c.submitDisable();
                },
                borderRadius: AppSpacing.radiusMd,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.bottomSafe(context, 30)),
      ],
    );
  }

  Widget _card({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}
