import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

class DeletePaymentAccountDropdownSection extends StatelessWidget {
  final void Function() onPressed;
  final String? subTitle;

  const DeletePaymentAccountDropdownSection({
    super.key,
    required this.onPressed,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(PngAssets.walletDeleteCommonIconTwo, width: 70),
            const SizedBox(height: 16),
            Text(
              localization.deleteAccountDropdownTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: AppColors.lightTextPrimary,
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subTitle ?? localization.deleteAccountDropdownMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 40),
            CommonButton(
              backgroundColor: AppColors.error,
              width: 120,
              text: localization.deleteAccountDropdownDeleteButton,
              onPressed: onPressed,
            ),
            const SizedBox(height: 20),
            CommonButton(
              width: 120,
              text: localization.deleteAccountDropdownCancelButton,
              backgroundColor: AppColors.transparent,
              textColor: AppColors.lightTextTertiary,
              onPressed: Get.back,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
