import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

class ActionButtonSection extends StatelessWidget {
  const ActionButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = Get.find<SettingsService>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
                icon: Icons.swap_horiz_rounded,
                name: localizations.actionButtonTransfer,
                onPressed: () {
                  if (settings.getSetting("user_transfer") == "1") {
                    Get.toNamed(BaseRoute.transfer);
                  } else {
                    ToastHelper().showErrorToast(
                      localizations.actionButtonUserTransferNotEnabled,
                    );
                  }
                },
                backgroundColor: AppColors.mainSoftBlue.withValues(alpha: 0.35),
              ),
              _buildButtons(
                context,
                icon: Icons.currency_exchange_rounded,
                name: localizations.actionButtonExchange,
                onPressed: () {
                  if (settings.getSetting("user_exchange") == "1") {
                    Get.toNamed(BaseRoute.exchange);
                  } else {
                    ToastHelper().showErrorToast(
                      localizations.actionButtonUserExchangeNotEnabled,
                    );
                  }
                },
                backgroundColor: AppColors.mutedBlue.withValues(alpha: 0.30),
              ),
              _buildButtons(
                context,
                icon: Icons.add_circle_outline_rounded,
                name: l10nPick(
                  context,
                  en: 'Deposit',
                  fa: 'واریز',
                  ar: 'إيداع',
                  zh: '充值',
                  tr: 'Yatır',
                  ru: 'Пополнить',
                ),
                onPressed: () {
                  if (settings.getSetting("user_deposit") == "1") {
                    Get.toNamed(BaseRoute.addMoney);
                  } else {
                    ToastHelper().showErrorToast(
                      l10nPick(
                        context,
                        en: 'Deposit is not enabled',
                        fa: 'واریز وجه فعال نیست',
                        ar: 'خدمة الإيداع غير مفعلة',
                        zh: '充值功能未启用',
                        tr: 'Yatırma etkin değil',
                        ru: 'Пополнение не включено',
                      ),
                    );
                  }
                },
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.18),
              ),
              _buildButtons(
                context,
                icon: Icons.account_balance_wallet_outlined,
                name: localizations.actionButtonWithdraw,
                onPressed: () {
                  if (settings.getSetting("user_withdraw") == "1") {
                    Get.toNamed(BaseRoute.withdraw);
                  } else {
                    ToastHelper().showErrorToast(
                      localizations.actionButtonUserWithdrawNotEnabled,
                    );
                  }
                },
                backgroundColor: AppColors.taupeBronze.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
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
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          splashColor: AppColors.lightPrimary.withValues(alpha: 0.12),
          highlightColor: AppColors.lightPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 74, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FittedBox(
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
                          color: AppColors.lightTextPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
