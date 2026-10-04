import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class Enable2FaSection extends StatelessWidget {
  const Enable2FaSection({super.key});

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
            localization.enable2FaSectionTitle,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          Divider(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            height: AppSpacing.lg,
          ),
          Column(
            children: [
              SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.center,
                child: Text(
                  localization.enable2FaSectionDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // QR Code container with clean high contrast background for scanner compatibility
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SvgPicture.string(controller.qrCode.toString()),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                localization.enable2FaSectionPinLabel,
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
              focusNode: controller.enable2FaFocusNode,
              isFocused: controller.isEnable2FaFocused.value,
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              hintText: "••••••",
              controller: controller.enable2FaController,
              keyboardType: TextInputType.number,
              textStyle: AppTextStyles.titleMedium.copyWith(
                color: primaryTextColor,
                letterSpacing: 4,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          CommonButton(
            width: double.infinity,
            borderRadius: AppSpacing.radiusMd,
            text: localization.enable2FaSectionEnableButton,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              if (controller.enable2FaController.text.isEmpty) {
                ToastHelper().showErrorToast(
                  localization.enable2FaSectionPinRequired,
                );
              } else {
                await controller.submitEnableTwoFa();
              }
            },
          ),
        ],
      ),
    );
  }
}
