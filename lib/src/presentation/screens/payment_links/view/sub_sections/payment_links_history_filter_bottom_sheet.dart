import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';

class PaymentLinksHistoryFilterBottomSheet extends StatefulWidget {
  const PaymentLinksHistoryFilterBottomSheet({super.key});

  @override
  State<PaymentLinksHistoryFilterBottomSheet> createState() =>
      _PaymentLinksHistoryFilterBottomSheetState();
}

class _PaymentLinksHistoryFilterBottomSheetState
    extends State<PaymentLinksHistoryFilterBottomSheet> {
  final PaymentLinksController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      height: 280,
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
      ),
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
                labelText: localizations.paymentLinksFilterNumberLabel,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.paymentLinkNumberController,
                    focusNode: controller.paymentLinkNumberFocusNode,
                    isFocused: controller.isPaymentLinkNumberFocused.value,
                    keyboardType: TextInputType.text,
                    borderRadius: AppSpacing.radiusLg,
                    backgroundColor: AppColors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              CommonButton(
                borderRadius: AppSpacing.radiusLg,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.applyFilter();
                  Get.back();
                },
                width: double.infinity,
                text: localizations.paymentLinksFilterButton,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
