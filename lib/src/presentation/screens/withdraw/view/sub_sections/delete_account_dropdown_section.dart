import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';

class DeleteAccountDropdownSection extends StatelessWidget {
  final String accountId;

  const DeleteAccountDropdownSection({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      width: double.infinity,
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
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
            const SizedBox(height: AppSpacing.xxxl),
            Image.asset(PngAssets.walletDeleteCommonIconTwo, width: 70),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization.deleteAccountDropdownTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                localization.deleteAccountDropdownMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            CommonButton(
              backgroundColor: AppColors.error,
              width: 140,
              text: localization.deleteAccountDropdownDeleteButton,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                Get.back();
                await Get.find<WithdrawAccountController>()
                    .deleteWithdrawAccount(accountId);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            CommonButton(
              width: 140,
              text: localization.deleteAccountDropdownCancelButton,
              backgroundColor: AppColors.transparent,
              textColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextTertiary,
              onPressed: () => Get.back(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
