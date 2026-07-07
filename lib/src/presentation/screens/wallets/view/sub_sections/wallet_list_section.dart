import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/view/sub_sections/delete_wallet_bottom_sheet.dart';

class WalletListSection extends StatelessWidget {
  const WalletListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final WalletsController walletsController = Get.find<WalletsController>();

    return ListView.separated(
      padding: EdgeInsetsDirectional.fromSTEB(18, 30, 18, 30),
      itemBuilder: (context, index) {
        final Wallets item = walletsController.walletsList[index];
        final isDefault = index == 0;

        return GestureDetector(
          onTap: () {
            Get.toNamed(
              BaseRoute.walletsDetails,
              arguments: {"wallet_id": item.id},
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: AssetImage(
                      isDefault
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
                    Row(
                      children: [
                        isDefault == true
                            ? Image.asset(
                                PngAssets.cryptocurrencyIcon,
                                width: 40,
                                height: 40,
                              )
                            : Container(
                                padding: EdgeInsets.all(8),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.lightTextPrimary.withValues(
                                    alpha: 0.20,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Image.network(
                                  item.icon!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      PngAssets.commonErrorIcon,
                                      color: AppColors.error.withValues(
                                        alpha: 0.7,
                                      ),
                                    );
                                  },
                                ),
                              ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name ?? "",
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
                                  child: Image.asset(
                                    PngAssets.commonInfoIcon,
                                    width: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item.code ?? "",
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
                    ),
                    Text(
                      item.isDefault == true
                          ? "${item.symbol}${item.formattedBalance}"
                          : "${item.formattedBalance} ${item.code}",
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (Get.find<SettingsService>().getSetting(
                                  "user_deposit",
                                ) ==
                                "1") {
                              Get.toNamed(
                                BaseRoute.addMoney,
                                arguments: {"wallet_id": item.id.toString()},
                              );
                            } else {
                              ToastHelper().showErrorToast(
                                localization
                                    .walletListSectionUserDepositNotEnabled,
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.19),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              localization.walletListSectionTopUpButton,
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
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (Get.find<SettingsService>().getSetting(
                                  "user_withdraw",
                                ) ==
                                "1") {
                              Get.toNamed(BaseRoute.withdraw);
                            } else {
                              ToastHelper().showErrorToast(
                                localization
                                    .walletListSectionUserWithdrawNotEnabled,
                              );
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.19),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              localization.walletListSectionWithdrawButton,
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
                    ),
                  ],
                ),
              ),
              if (isDefault == false)
                PositionedDirectional(
                  top: 16,
                  end: 16,
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Get.bottomSheet(
                          DeleteWalletBottomSheet(walletId: item.id.toString()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.white,
                        ),
                        child: Image.asset(
                          PngAssets.walletDeleteCommonIcon,
                          width: 20,
                          height: 20,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 10);
      },
      itemCount: walletsController.walletsList.length,
    );
  }
}
