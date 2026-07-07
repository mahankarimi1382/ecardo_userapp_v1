import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class MyWalletSection extends StatelessWidget {
  const MyWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final homeController = Get.find<HomeController>();
    final showSingleWalletOnly = homeController.walletsList.length == 1;

    return Column(
      children: [
        SectionHeader(
          sectionName: localization.myWalletSectionTitle,
          onTap: () {
            Get.toNamed(BaseRoute.wallets);
          },
        ),
        const SizedBox(height: 10),
        showSingleWalletOnly
            ? _buildSingleCardView(context, homeController.walletsList)
            : _buildHorizontalScrollView(context, homeController.walletsList),
      ],
    );
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
    final currencyCode = wallet.code;
    final currencyIcon = wallet.icon.toString();
    final currencySymbol = wallet.symbol.toString();

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
              title: wallet.name!,
              currencyCode: currencyCode!,
              currencyIcon: currencyIcon,
            ),
            _buildBalance(
              context,
              formatedBalance: wallet.formattedBalance!,
              code: currencyCode,
              isDefaultWallet: isDefaultWallet,
              symbol: currencySymbol,
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
}
