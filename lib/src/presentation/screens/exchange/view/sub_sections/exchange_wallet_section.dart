import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';

class ExchangeWalletSection extends StatelessWidget {
  const ExchangeWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final ExchangeController controller = Get.find();

    return Obx(
      () => InkWell(
        onTap: () {
          Get.bottomSheet(
            CommonDropdownWalletBottomSheet(
              notFoundText: localizations.exchangeWalletsNotFound,
              dropdownItems: controller.fromExchangeWalletsList,
              bottomSheetHeight: 450,
              currentlySelectedValue: controller.fromWallet.value!.name,
              onItemSelected: (value) async {
                final selectedWallet = controller.fromExchangeWalletsList
                    .firstWhere((w) => w.name == value);
                controller.fromWallet.value = selectedWallet;
              },
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(PngAssets.addMoneyFrame),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  controller.fromWallet.value!.isDefault == true
                      ? Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            controller.fromWallet.value!.symbol!,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.network(
                            controller.fromWallet.value!.icon!,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                PngAssets.commonErrorIcon,
                                color: AppColors.error.withValues(alpha: 0.7),
                              );
                            },
                          ),
                        ),
                  SizedBox(width: 10),
                  Text(
                    controller.fromWallet.value!.name!,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Image.asset(PngAssets.commonArrowDownIcon, width: 16),
                ],
              ),
              SizedBox(height: 20),
              Text(
                localizations.exchangeWalletBalance,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "${controller.fromWallet.value!.formattedBalance} ${controller.fromWallet.value!.code}",
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
