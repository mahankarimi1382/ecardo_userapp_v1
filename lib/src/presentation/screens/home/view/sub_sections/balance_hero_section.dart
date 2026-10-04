import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Modern balance hero with multi-currency support, privacy toggle, and quick
/// actions — replacing the old `ActionButtonSection` + separate wallet display.
///
/// Integrates `EcardoBalanceHero` from the design system library.
class BalanceHeroSection extends StatelessWidget {
  const BalanceHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final settings = Get.find<SettingsService>();
    final loc = AppLocalizations.of(context)!;

    return Obx(() {
      final wallets = homeController.walletsList;

      // Sum the balance of the primary (default) wallet, or the first wallet.
      double totalBalance = 0.0;
      String currencyCode = 'USD';
      String? currencySymbol;

      final defaultWallet = wallets.firstWhereOrNull(
        (w) => w.isDefault == true,
      );

      if (defaultWallet != null) {
        totalBalance = double.tryParse(defaultWallet.balance ?? '0') ?? 0.0;
        currencyCode = defaultWallet.code ?? 'USD';
        currencySymbol = defaultWallet.symbol;
      } else if (wallets.isNotEmpty) {
        // Sum all wallets when there is no primary
        for (final wallet in wallets) {
          totalBalance += double.tryParse(wallet.balance ?? '0') ?? 0.0;
        }
        currencyCode = wallets.first.code ?? 'USD';
        currencySymbol = wallets.first.symbol;
      }

      // Collect unique currency codes from wallets
      final availableCurrencies = wallets
          .map((w) => w.code ?? '')
          .where((code) => code.isNotEmpty)
          .toSet()
          .toList();

      if (availableCurrencies.isEmpty) {
        availableCurrencies.add('USD');
      }

      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: EcardoBalanceHero(
          amount: totalBalance,
          currencyCode: currencyCode,
          currencySymbol: currencySymbol,
          availableCurrencies: availableCurrencies,
          onCurrencyChanged: (_) {
            // Currency switching handled in wallets screen
          },
          accountLabel: l10nPick(
            context,
            en: 'Total Balance',
            fa: 'موجودی کل',
            ar: 'الرصيد الإجمالي',
            zh: '总余额',
            tr: 'Toplam Bakiye',
            ru: 'Общий баланс',
          ),
          showQuickActions: true,
          actions: [
            EcardoHeroAction(
              label: loc.actionButtonTransfer,
              icon: Icons.swap_horiz_rounded,
              onTap: () {
                if (settings.getSetting("user_transfer") == "1") {
                  Get.toNamed(BaseRoute.transfer);
                } else {
                  ToastHelper().showErrorToast(
                    loc.actionButtonUserTransferNotEnabled,
                  );
                }
              },
            ),
            EcardoHeroAction(
              label: loc.actionButtonExchange,
              icon: Icons.currency_exchange_rounded,
              onTap: () {
                if (settings.getSetting("user_exchange") == "1") {
                  Get.toNamed(BaseRoute.exchange);
                } else {
                  ToastHelper().showErrorToast(
                    loc.actionButtonUserExchangeNotEnabled,
                  );
                }
              },
            ),
            EcardoHeroAction(
              label: l10nPick(
                context,
                en: 'Deposit',
                fa: 'واریز',
                ar: 'إيداع',
                zh: '充值',
                tr: 'Yatır',
                ru: 'Пополнить',
              ),
              icon: Icons.add_circle_outline_rounded,
              onTap: () {
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
            ),
            EcardoHeroAction(
              label: loc.actionButtonWithdraw,
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {
                if (settings.getSetting("user_withdraw") == "1") {
                  Get.toNamed(BaseRoute.withdraw);
                } else {
                  ToastHelper().showErrorToast(
                    loc.actionButtonUserWithdrawNotEnabled,
                  );
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
