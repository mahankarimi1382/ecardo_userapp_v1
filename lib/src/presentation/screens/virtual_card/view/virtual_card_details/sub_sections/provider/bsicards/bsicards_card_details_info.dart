import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';

import '../../../../../../../../app/constants/app_colors.dart';

class BsicardsCardDetailsInfo extends StatelessWidget {
  const BsicardsCardDetailsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final card = controller.virtualCardDetailsBsiCardProviderModel.value.data;
    final cardType = card?.data?.type ?? '';
    final formattedCardType = cardType.isNotEmpty
        ? cardType[0].toUpperCase() + cardType.substring(1)
        : '';
    final localization = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization!.cardDetailsInfoTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  Colors.grey.shade400,
                  AppColors.white,
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.cardDetailsCardTypeValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: AppColors.lightTextPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    localization.cardDetailsCardTypeLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${card!.data?.balance} ${localization.bsicardsCardDetailsCurrencyValue}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: AppColors.success,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    formattedCardType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Text(
            localization.cardDetailsBillingAddressLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            card.data!.address1!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppColors.lightTextTertiary,
              letterSpacing: 0,
            ),
          ),
          Text(
            "${card.data?.city} , ${card.data?.state} - ${card.data?.country} ${card.data?.postalCode}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: AppColors.lightTextTertiary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.cardDetailsCardCurrencyLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: AppColors.lightTextTertiary,
                  letterSpacing: 0,
                ),
              ),
              Text(
                localization.bsicardsCardDetailsCurrencyValue,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          Obx(
            () => CommonButton(
              backgroundColor: card.data?.status == "active"
                  ? AppColors.error
                  : AppColors.lightPrimary,
              text: card.data?.status == "active"
                  ? localization.cardDetailsStatusButtonInactive
                  : localization.cardDetailsStatusButtonActive,
              height: 40,
              borderRadius: 10,
              fontSize: 14,
              onPressed: () => controller.cardUpdateStatus(
                cardId: card.externalId.toString(),
              ),
              isLoading: controller.isUpdateCardStatusLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}
