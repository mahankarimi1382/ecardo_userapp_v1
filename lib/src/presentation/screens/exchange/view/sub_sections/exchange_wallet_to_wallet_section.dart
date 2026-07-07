import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';

class ExchangeWalletToWalletSection extends StatelessWidget {
  const ExchangeWalletToWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final ExchangeController controller = Get.find();

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(30),
          bottomEnd: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CommonRequiredLabelAndDynamicField(
            labelHeight: 8,
            isLabelRequired: true,
            labelText: localizations.exchangeWalletToWallet,
            dynamicField: Row(
              children: [
                Obx(() {
                  final fromWallet = controller.fromWallet.value;
                  return _buildWalletToWallet(
                    walletName:
                        fromWallet?.name ?? localizations.exchangeFromWallet,
                    isFocused: controller.fromWalletBorderFocused,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownWalletBottomSheet(
                          notFoundText: localizations
                              .exchangeWalletToWalletWalletsNotFound,
                          dropdownItems: controller.fromExchangeWalletsList,
                          bottomSheetHeight: 450,
                          currentlySelectedValue: fromWallet?.name,
                          onItemSelected: (value) async {
                            final selectedWallet = controller
                                .fromExchangeWalletsList
                                .firstWhere((w) => w.name == value);
                            controller.fromWallet.value = selectedWallet;
                            controller.calculateExchange();
                          },
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(width: 18),
                Obx(() {
                  final toWallet = controller.toWallet.value;
                  return _buildWalletToWallet(
                    walletName:
                        toWallet?.name ?? localizations.exchangeToWallet,
                    isFocused: controller.toWalletBorderFocused,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownWalletBottomSheet(
                          notFoundText: localizations
                              .exchangeWalletToWalletWalletsNotFound,
                          dropdownItems: controller.toExchangeWalletsList,
                          bottomSheetHeight: 450,
                          currentlySelectedValue: toWallet?.name,
                          onItemSelected: (value) async {
                            final selectedWallet = controller
                                .toExchangeWalletsList
                                .firstWhere((w) => w.name == value);
                            controller.toWallet.value = selectedWallet;
                            controller.calculateExchange();
                          },
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.exchangeRate,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightPrimary,
                  letterSpacing: 0,
                  fontSize: 14,
                ),
              ),
              Obx(() {
                final fromCode = controller.fromWallet.value?.code ?? "";
                final toCode = controller.toWallet.value?.code ?? "";
                final rate = controller.exchangeRate.value;

                return Text(
                  "1 $fromCode = ${rate.toStringAsFixed(DynamicDecimalsHelper().getDynamicDecimals(currencyCode: controller.toWallet.value!.name!, siteCurrencyCode: Get.find<SettingsService>().getSetting("site_currency")!, siteCurrencyDecimals: Get.find<SettingsService>().getSetting("site_currency_decimals")!, isCrypto: controller.toWallet.value!.isCrypto!))} $toCode",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: 0,
                    fontSize: 14,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildWalletToWallet({
    required String walletName,
    required GestureTapCallback? onTap,
    required RxBool isFocused,
  }) {
    return Expanded(
      child: Obx(
        () => InkWell(
          onTap: () {
            Get.find<ExchangeController>().fromWalletBorderFocused.value =
                false;
            Get.find<ExchangeController>().toWalletBorderFocused.value = false;
            isFocused.value = true;

            if (onTap != null) onTap();
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocused.value
                    ? AppColors.lightPrimary.withValues(alpha: 0.60)
                    : AppColors.lightTextPrimary.withValues(alpha: 0.10),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9280FD),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Image.asset(PngAssets.commonWalletIcon),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    walletName,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.lightTextPrimary,
                      letterSpacing: 0,
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
