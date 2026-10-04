import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';

class GiftRedeemSection extends StatefulWidget {
  const GiftRedeemSection({super.key});

  @override
  State<GiftRedeemSection> createState() => _GiftRedeemSectionState();
}

class _GiftRedeemSectionState extends State<GiftRedeemSection> {
  final GiftRedeemController controller = Get.find<GiftRedeemController>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.xl,
          end: AppSpacing.xl,
          bottom: AppSpacing.xxl,
          top: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : AppColors.mutedBlue.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.giftRedeemGiftCode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    isFocused: controller.isGiftCodeFocused.value,
                    focusNode: controller.giftCodeFocusNode,
                    backgroundColor: AppColors.transparent,
                    hintText: 'Enter 12 or 16-character code',
                    keyboardType: TextInputType.text,
                    controller: controller.giftCodeController,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              CommonButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  if (controller.giftCodeController.text.isNotEmpty) {
                    await controller.giftCodeRedeem();
                  } else {
                    ToastHelper().showErrorToast(
                      localizations.giftRedeemValidation,
                    );
                  }
                },
                width: double.infinity,
                text: localizations.giftRedeemButton,
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      ),
    );
  }
}
