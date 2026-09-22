import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/wallet_live_rate_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';
import 'package:ecardo_user/src/helper/responsive.dart';

class MyWalletSection extends StatelessWidget {
  const MyWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final homeController = Get.find<HomeController>();

    // Obx so live-rate refresh redraws the ≈ chips without a full reload.
    return Obx(() {
      final wallets = homeController.walletsList.toList();
      if (Get.isRegistered<WalletLiveRateService>()) {
        // Touch ratesIrr so GetX tracks it.
        Get.find<WalletLiveRateService>().ratesIrr.length;
      }
      final showSingleWalletOnly = wallets.length == 1;
      return Column(
        children: [
          SectionHeader(
            sectionName: localization.myWalletSectionTitle,
            onTap: () {
              Get.toNamed(BaseRoute.wallets);
            },
          ),
          SizedBox(height: Responsive.sectionGap(context) / 2),
          if (wallets.isEmpty)
            EmptyView.wallets(onCta: () => Get.toNamed(BaseRoute.wallets))
          else if (showSingleWalletOnly)
            _buildSingleCardView(context, wallets)
          else
            _buildHorizontalScrollView(context, wallets),
        ],
      );
    });
  }

  Widget _buildHorizontalScrollView(
    BuildContext context,
    List<Wallets> wallets,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: Row(
        children: wallets.map((wallet) {
          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: wallet == wallets.last ? 0 : 10,
            ),
            child: _buildWalletCard(context, wallet, useFullWidth: false),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleCardView(BuildContext context, List<Wallets> wallets) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      child: _buildWalletCard(context, wallets.first, useFullWidth: true),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    Wallets wallet, {
    required bool useFullWidth,
  }) {
    final isDefaultWallet = wallet.isDefault == true;
    // v1.0.43 (crash fix): name/code/formattedBalance were force-unwrapped —
    // a wallet served with any of them null threw mid-build and grey-screened
    // the whole home page. Degrade gracefully instead.
    final currencyCode = wallet.code ?? '';
    final currencyIcon = wallet.icon.toString();
    final currencySymbol = wallet.symbol.toString();
    final title = wallet.name ?? currencyCode;
    final formatedBalance = wallet.formattedBalance ?? '0';

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          BaseRoute.walletsDetails,
          arguments: {"wallet_id": wallet.id},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        width: useFullWidth ? double.infinity : 300,
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(
              isDefaultWallet
                  ? PngAssets.walletFrameOne
                  : PngAssets.walletFrameTwo,
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWalletHeader(
              context,
              isDefaultWallet: isDefaultWallet,
              title: title,
              currencyCode: currencyCode,
              currencyIcon: currencyIcon,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalance(
                  context,
                  formatedBalance: formatedBalance,
                  code: currencyCode,
                  isDefaultWallet: isDefaultWallet,
                  symbol: currencySymbol,
                ),
                if (_liveConversionLabel(wallet) != null) ...[
                  const SizedBox(height: 6),
                  _buildLiveRateChip(
                    label: _liveConversionLabel(wallet)!,
                    isDefaultWallet: isDefaultWallet,
                  ),
                ],
              ],
            ),
            _buildActionButtons(
              context,
              isDefaultWallet: isDefaultWallet,
              walletId: wallet.id.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletHeader(
    BuildContext context, {
    required bool isDefaultWallet,
    required String title,
    required String currencyCode,
    required String currencyIcon,
  }) {
    return Row(
      children: [
        isDefaultWallet
            ? Image.asset(PngAssets.cryptocurrencyIcon, width: 40, height: 40)
            : Container(
                padding: EdgeInsets.all(8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Image.network(
                  currencyIcon,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      PngAssets.commonErrorIcon,
                      color: AppColors.error.withValues(alpha: 0.7),
                    );
                  },
                ),
              ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 2),
                Transform.translate(
                  offset: Offset(0, -5),
                  child: Image.asset(PngAssets.commonInfoIcon, width: 12),
                ),
              ],
            ),
            Text(
              currencyCode,
              style: const TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalance(
    BuildContext context, {
    required String formatedBalance,
    required String code,
    required String symbol,
    required bool isDefaultWallet,
  }) {
    return Text(
      isDefaultWallet ? "$symbol$formatedBalance" : "$formatedBalance $code",
      style: const TextStyle(
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.white,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
    required bool isDefaultWallet,
    required String walletId,
  }) {
    final localization = AppLocalizations.of(context)!;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Get.find<SettingsService>().getSetting("user_deposit") == "1") {
              Get.toNamed(
                BaseRoute.addMoney,
                arguments: {"wallet_id": walletId},
              );
            } else {
              ToastHelper().showErrorToast(
                localization.myWalletUserDepositNotEnabled,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.19),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              localization.myWalletTopUp,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            if (Get.find<SettingsService>().getSetting("user_withdraw") ==
                "1") {
              Get.toNamed(BaseRoute.withdraw);
            } else {
              ToastHelper().showErrorToast(
                localization.myWalletUserWithdrawNotEnabled,
              );
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.19),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              localization.myWalletWithdraw,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _liveConversionLabel(Wallets wallet) {
    // Prefer live fee.ecardo.ir rates (fixes wrong/stale conversion_rate).
    if (Get.isRegistered<WalletLiveRateService>()) {
      final live = Get.find<WalletLiveRateService>().equivalentLabel(wallet);
      if (live != null) return live;
    }
    // Fallback: backend conversion_rate with inverse heuristic.
    final rateRaw = wallet.conversionRate;
    final balRaw = wallet.balance;
    if (rateRaw == null || rateRaw.isEmpty || balRaw == null || balRaw.isEmpty) {
      return null;
    }
    final rate = double.tryParse(rateRaw.replaceAll(',', ''));
    final bal = double.tryParse(balRaw.replaceAll(',', ''));
    if (rate == null || bal == null || rate <= 0) return null;

    final site = Get.find<SettingsService>().getSetting('site_currency') ?? '';
    final code = (wallet.code ?? '').toUpperCase();
    if (site.isEmpty || site.toUpperCase() == code) return null;

    final looksInverse = rate < 0.001 &&
        (code == 'USD' || code == 'EUR' || code == 'GBP' || code == 'USDT');
    final eq = looksInverse ? (bal / rate) : (bal * rate);
    final decimals = int.tryParse(
          Get.find<SettingsService>().getSetting('site_currency_decimals') ??
              '0',
        ) ??
        0;
    final formatted = eq.toStringAsFixed(decimals.clamp(0, 8));
    return '≈ $formatted $site';
  }

  Widget _buildLiveRateChip({
    required String label,
    required bool isDefaultWallet,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF5CFFB0),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5CFFB0).withValues(alpha: 0.55),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0.2,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }

}
