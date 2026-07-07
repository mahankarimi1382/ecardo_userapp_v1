import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class GiftCardSuccessSection extends StatefulWidget {
  const GiftCardSuccessSection({super.key});

  @override
  State<GiftCardSuccessSection> createState() => _GiftCardSuccessSectionState();
}

class _GiftCardSuccessSectionState extends State<GiftCardSuccessSection> {
  final GiftCardController controller = Get.find();
  final SettingsService settingsService = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 192,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(PngAssets.pendingAndSuccessFrame),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(PngAssets.commonSuccessIcon, width: 80),
                    const SizedBox(height: 16),
                    Text(
                      textAlign: TextAlign.center,
                      localization.giftCardSuccessTitle,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSuccessDynamicContent(
                      title: localization.giftCardTransactionIdLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['transaction_id']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardProductNameLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['product_name']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardSenderNameLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['sender_name']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardRecipientEmailLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['recipient_email']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardRecipientPhoneLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['recipient_phone_number']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardUnitPriceLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['unit_price']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardQuantityLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['quantity']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      height: 0,
                      color: AppColors.black.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 20),
                    _buildSuccessDynamicContent(
                      title: localization.giftCardTotalAmountLabel,
                      content: controller
                          .successGiftCardOrderData
                          .value!['total_price']
                          .toString(),
                      contentColor: AppColors.lightTextPrimary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              CommonButton(
                onPressed: () async {
                  Get.until((route) {
                    return route.settings.name == BaseRoute.giftCard;
                  });
                  controller.isGiftCardLoading.value = true;
                  await controller.getGiftCardProducts(isRefresh: true);
                  controller.isGiftCardLoading.value = false;
                },
                width: double.infinity,
                text: localization.giftCardSuccessGiftCardsButton,
              ),

              const SizedBox(height: 20),
              CommonButton(
                onPressed: () async {
                  Get.delete<GiftCardController>();
                  Get.delete<GiftCardHistoryController>();
                  Get.toNamed(BaseRoute.navigation);
                  await Get.find<HomeController>().loadData();
                },
                width: double.infinity,
                text: localization.giftCardSuccessBackHomeButton,
                backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                borderColor: AppColors.lightPrimary.withValues(alpha: 0.60),
                borderWidth: 2,
                textColor: AppColors.lightTextPrimary,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSuccessDynamicContent({
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: contentColor,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
