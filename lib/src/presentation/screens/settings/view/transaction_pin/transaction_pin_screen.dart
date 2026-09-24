import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
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
    final range =
        '${PasscodeHelper.minDigits}–${PasscodeHelper.maxDigits}';

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  loc.generatePasscodeSectionTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Text(
                  loc.generatePasscodeSectionDescription,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
                child: Text(
                  '($range digits)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.lightTextTertiary.withValues(alpha: 0.8),
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
                        ? _managed(loc)
                        : _set(loc),
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

  Widget _set(AppLocalizations loc) {
    return Column(
      children: [
        _card(
          child: Column(
            children: [
              CommonRequiredLabelAndDynamicField(
                labelText: loc.generatePasscodeLabelPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '****',
                    controller: c.passcodeController,
                    focusNode: c.passcodeFocus,
                    isFocused: c.isPasscodeFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CommonRequiredLabelAndDynamicField(
                labelText: loc.generatePasscodeLabelConfirmPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '****',
                    controller: c.confirmController,
                    focusNode: c.confirmFocus,
                    isFocused: c.isConfirmFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CommonButton(
                width: double.infinity,
                text: loc.generatePasscodeSectionButtonGenerate,
                onPressed: c.submitSet,
                borderRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _managed(AppLocalizations loc) {
    return Column(
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.disableChangePasscodeButtonChange,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              CommonRequiredLabelAndDynamicField(
                labelText: loc.changePasscodeLabelOldPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '****',
                    controller: c.oldController,
                    focusNode: c.oldFocus,
                    isFocused: c.isOldFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CommonRequiredLabelAndDynamicField(
                labelText: loc.changePasscodeLabelNewPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '****',
                    controller: c.newController,
                    focusNode: c.newFocus,
                    isFocused: c.isNewFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CommonRequiredLabelAndDynamicField(
                labelText: loc.changePasscodeLabelConfirmPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '****',
                    controller: c.changeConfirmController,
                    focusNode: c.changeConfirmFocus,
                    isFocused: c.isChangeConfirmFocused.value,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: _fmt,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CommonButton(
                width: double.infinity,
                text: loc.changePasscodeButtonChange,
                onPressed: c.submitChange,
                borderRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.disableChangePasscodeButtonDisable,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'برای غیرفعال‌سازی، رمز ورود حساب لازم است (نه رمز انتقال).',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 14),
              CommonRequiredLabelAndDynamicField(
                labelText: loc.disablePasscodeLabelPassword,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: '',
                    controller: c.passwordController,
                    focusNode: c.passwordFocus,
                    isFocused: c.isPasswordFocused.value,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CommonButton(
                width: double.infinity,
                backgroundColor: AppColors.error,
                text: loc.disableChangePasscodeButtonDisable,
                onPressed: c.submitDisable,
                borderRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightTextTertiary.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );
  }
}
