import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';

class ActionButtonSection extends StatelessWidget {
  const ActionButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildButtons(
            context,
            icon: PngAssets.commonTransferIcon,
            name: localizations.actionButtonTransfer,
            onPressed: () {
              if (Get.find<SettingsService>().getSetting("user_transfer") ==
                  "1") {
                Get.toNamed(BaseRoute.transfer);
              } else {
                ToastHelper().showErrorToast(
                  localizations.actionButtonUserTransferNotEnabled,
                );
              }
            },
            backgroundColor: const Color(0xFFA869FF).withValues(alpha: 0.3),
          ),
          _buildButtons(
            context,
            icon: PngAssets.commonWithdrawIcon,
            name: localizations.actionButtonWithdraw,
            onPressed: () {
              if (Get.find<SettingsService>().getSetting("user_withdraw") ==
                  "1") {
                Get.toNamed(BaseRoute.withdraw);
              } else {
                ToastHelper().showErrorToast(
                  localizations.actionButtonUserWithdrawNotEnabled,
                );
              }
            },
            backgroundColor: const Color(0xFFFF77BA).withValues(alpha: 0.3),
          ),
          if (Get.find<SettingsService>().getSetting("agent_system") == "1")
            _buildButtons(
              context,
              icon: PngAssets.commonPaymentIcon,
              name: localizations.actionButtonPayment,
              onPressed: () {
                if (Get.find<SettingsService>().getSetting("user_payment") ==
                    "1") {
                  Get.toNamed(BaseRoute.makePayment);
                } else {
                  ToastHelper().showErrorToast(
                    localizations.actionButtonUserPaymentNotEnabled,
                  );
                }
              },
              backgroundColor: const Color(0xFFFFBB8C).withValues(alpha: 0.3),
            ),
          _buildButtons(
            context,
            icon: PngAssets.commonExchangeIcon,
            name: localizations.actionButtonExchange,
            onPressed: () {
              if (Get.find<SettingsService>().getSetting("user_exchange") ==
                  "1") {
                Get.toNamed(BaseRoute.exchange);
              } else {
                ToastHelper().showErrorToast(
                  localizations.actionButtonUserExchangeNotEnabled,
                );
              }
            },
            backgroundColor: const Color(0xFFA869FF).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context, {
    required String icon,
    required String name,
    required GestureTapCallback onPressed,
    required Color backgroundColor,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.lightPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Image(image: AssetImage(icon), width: 25),
              SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
