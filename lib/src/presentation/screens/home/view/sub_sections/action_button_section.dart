import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

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
            icon: Icons.swap_horiz,
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
            backgroundColor: const Color(0xFFABC3EA).withValues(alpha: 0.25),
          ),
          _buildButtons(
            context,
            icon: Icons.account_balance,
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
            backgroundColor: const Color(0xFFB3A9A5).withValues(alpha: 0.28),
          ),
          if (Get.find<SettingsService>().getSetting("agent_system") == "1")
            _buildButtons(
              context,
              icon: Icons.payments,
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
              backgroundColor: const Color(0xFF849ACD).withValues(alpha: 0.25),
            ),
          _buildButtons(
            context,
            icon: Icons.currency_exchange,
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
            backgroundColor: const Color(0xFFABC3EA).withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context, {
    required IconData icon,
    required String name,
    required GestureTapCallback onPressed,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          splashColor: AppColors.lightPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
