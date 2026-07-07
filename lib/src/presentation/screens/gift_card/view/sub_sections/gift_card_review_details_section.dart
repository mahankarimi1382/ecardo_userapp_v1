import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_product_details_model.dart';

class GiftCardReviewDetailsSection extends StatelessWidget {
  final GiftCardProductDetailsData cardDetails;

  const GiftCardReviewDetailsSection({super.key, required this.cardDetails});

  @override
  Widget build(BuildContext context) {
    final GiftCardController controller = Get.find();
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          CommonAppBar(title: localization.giftCardDetailsTitle),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                top: 60.h,
                start: 18.w,
                end: 18.w,
                bottom: 30.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.giftCardReviewDetailsTitle,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardProductNameLabel,
                              content: cardDetails.productName ?? "",
                              contentColor: AppColors.success,
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardEmailLabel,
                              content: controller.emailController.text,
                              contentColor: AppColors.lightTextPrimary,
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardYourNameLabel,
                              content: controller.nameController.text,
                              contentColor: AppColors.lightTextPrimary,
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => _buildReviewDynamicContent(
                                context,
                                title: localization.giftCardUnitPriceLabel,
                                content:
                                    "${controller.unitPrice.toStringAsFixed(2)} ${cardDetails.senderCurrencyCode} ( ${cardDetails.denominationType == 'FIXED'
                                        ? controller.selectedAmount.value
                                        : cardDetails.denominationType == 'RANGE'
                                        ? controller.amountController.text
                                        : ""} ${cardDetails.recipientCurrencyCode} )",
                                contentColor: AppColors.lightTextPrimary,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardQuantityLabel,
                              content: controller.count.value.toString(),
                              contentColor: AppColors.lightTextPrimary,
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => _buildReviewDynamicContent(
                                context,
                                title: localization.giftCardSubTotalLabel,
                                content:
                                    "${controller.subTotal.toStringAsFixed(2)} ${cardDetails.senderCurrencyCode}",
                                contentColor: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardTotalFeeLabel,
                              content:
                                  "${controller.totalFee.toStringAsFixed(2)} ${cardDetails.senderCurrencyCode}",
                              contentColor: AppColors.lightTextPrimary,
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              height: 0,
                              color: AppColors.black.withValues(alpha: 0.10),
                            ),
                            const SizedBox(height: 20),
                            _buildReviewDynamicContent(
                              context,
                              title: localization.giftCardTotalLabel,
                              content:
                                  "${controller.total.toStringAsFixed(2)} ${cardDetails.senderCurrencyCode}",
                              contentColor: AppColors.lightTextPrimary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: CommonIconButton(
                              backgroundColor: AppColors.lightPrimary
                                  .withValues(alpha: 0.04),
                              borderWidth: 2,
                              borderColor: AppColors.lightPrimary.withValues(
                                alpha: 0.50,
                              ),
                              width: double.infinity,
                              height: 52,
                              text: localization.giftCardReviewBackButton,
                              icon: PngAssets.reviewArrowBackCommonIcon,
                              iconWidth: 18,
                              iconHeight: 18,
                              iconAndTextSpace: 8,
                              iconColor: AppColors.lightTextPrimary,
                              textColor: AppColors.lightTextPrimary,
                              onPressed: () => Get.back(),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Obx(
                              () => CommonIconButton(
                                isLoading:
                                    controller.isBuyNowGiftCardLoading.value,
                                onPressed: () => controller.postBuyNowGiftCard(
                                  productId: cardDetails.productId.toString(),
                                  denominationType: cardDetails.denominationType
                                      .toString(),
                                  minRecipientDenomination: cardDetails
                                      .minRecipientDenomination
                                      .toString(),
                                  maxRecipientDenomination: cardDetails
                                      .maxRecipientDenomination
                                      .toString(),
                                  cardDetails: cardDetails,
                                ),
                                width: double.infinity,
                                height: 52,
                                text: localization.giftCardReviewPayNowButton,
                                icon: PngAssets.reviewArrowRightCommonIcon,
                                iconWidth: 18,
                                iconHeight: 18,
                                iconAndTextSpace: 8,
                                isIconRight: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
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
