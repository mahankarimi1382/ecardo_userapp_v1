import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';

class Generate2FaSection extends StatelessWidget {
  const Generate2FaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final TwoFactorAuthenticationController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;
    final iconStyle = SettingsIconTokens.twoFactor(isDark: isDark);

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: iconStyle.iconColor,
                  size: 22,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  localization.generate2FaSectionTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            localization.generate2FaSectionDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: secondaryTextColor,
              height: 1.45,
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
          CommonButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              controller.loadGenerate2Fa();
            },
            width: double.infinity,
            borderRadius: AppSpacing.radiusMd,
            text: localization.generate2FaSectionGenerateButton,
          ),
        ],
      ),
    );
  }
}
