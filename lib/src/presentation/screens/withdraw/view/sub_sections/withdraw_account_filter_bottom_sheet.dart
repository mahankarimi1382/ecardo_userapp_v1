import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';

class WithdrawAccountFilterBottomSheet extends StatefulWidget {
  const WithdrawAccountFilterBottomSheet({super.key});

  @override
  State<WithdrawAccountFilterBottomSheet> createState() =>
      _WithdrawAccountFilterBottomSheetState();
}

class _WithdrawAccountFilterBottomSheetState
    extends State<WithdrawAccountFilterBottomSheet> {
  final WithdrawAccountController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: AppSpacing.xxl,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                      : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.withdrawAccountFilterMethodName,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.methodNameController,
                    focusNode: controller.methodNameFocusNode,
                    isFocused: controller.isMethodNameFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              CommonButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.fetchDynamicWithdrawAccounts();
                  controller.methodNameController.clear();
                  Get.back();
                },
                width: double.infinity,
                text: localization.withdrawAccountFilterApplyButton,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
