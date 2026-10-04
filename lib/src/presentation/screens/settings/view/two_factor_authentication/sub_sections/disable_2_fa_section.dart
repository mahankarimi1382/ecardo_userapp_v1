import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class Disable2FaSection extends StatelessWidget {
  const Disable2FaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TwoFactorAuthenticationController controller = Get.find();
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.disable2FaSectionTitle,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            height: AppSpacing.lg,
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                localization.disable2FaSectionDescription,
                style: AppTextStyles.labelMedium.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Obx(
            () => CommonTextInputField(
              focusNode: controller.disable2FaFocusNode,
              isFocused: controller.isDisable2FaFocused.value,
              hintText: localization.changePasswordCurrentPassword,
              obscureText: true,
              controller: controller.disable2FaController,
              keyboardType: TextInputType.visiblePassword,
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              textStyle: AppTextStyles.bodyMedium.copyWith(color: primaryTextColor),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          CommonButton(
            borderRadius: AppSpacing.radiusMd,
            width: double.infinity,
            backgroundColor: AppColors.error,
            text: localization.disable2FaSectionDisableButton,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              if (controller.disable2FaController.text.isEmpty) {
                ToastHelper().showErrorToast(
                  localization.disable2FaSectionPasswordRequired,
                );
              } else {
                await controller.submitDisableTwoFa();
              }
            },
          ),
        ],
      ),
    );
  }
}
