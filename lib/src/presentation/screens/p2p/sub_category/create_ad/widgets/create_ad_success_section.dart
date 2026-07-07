import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/model/create_ad_response_model.dart';

import '../../../../../../app/constants/assets_path/png/png_assets.dart';

class CreateAdSuccessSection extends StatelessWidget {
  final Data? adData;

  const CreateAdSuccessSection({super.key, required this.adData});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final typeText = (adData?.adType ?? '').toLowerCase() == 'sell'
        ? localization.p2pSell
        : localization.p2pBuy;
    final assetCode = adData?.assetCurrency?.code ?? '-';
    final fiatCode = adData?.fiatCurrency?.code ?? '-';
    final statusText = adData?.status ?? 'N/A';
    final methodName = adData?.paymentMethods?.isNotEmpty == true
        ? adData!.paymentMethods!.first.paymentMethod?.name ?? '-'
        : '-';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,

      children: [
        Image.asset(
          PngAssets.successBg,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Column(
          children: [
            SizedBox(height: 54.h),
            Container(
              width: 70.w,
              height: 70.h,
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 35.w,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              statusText == 'active'
                  ? localization.p2pAdSuccessfullyPosted
                  : localization.p2pAdsSubmittedUnderReview,
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              statusText == 'active'
                  ? localization.p2pAdPublishedDescription
                  : localization.p2pAdUnderReviewDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              ),
            ),
            SizedBox(height: 40.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                children: [
                  _buildTopRow(
                    left: '$typeText $assetCode With $fiatCode',
                    right: statusText.capitalizeFirst ?? '-',
                    rightColor: statusText == 'active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  _divider(),
                  _buildInfoRow(
                    title: localization.p2pTotalAmount,
                    value: '${adData?.totalAmount ?? '-'} ',
                  ),
                  _divider(),
                  _buildInfoRow(
                    title: localization.p2pLimit,
                    value: adData?.orderLimit ?? '-',
                  ),
                  _divider(),
                  _buildInfoRow(
                    title: localization.p2pAdNumber,
                    value: adData?.adNumber ?? '-',
                  ),
                  _divider(),
                  _buildInfoRow(title: localization.p2pMethod, value: methodName),
                ],
              ),
            ),
            const Spacer(),
            CommonButton(
              text: localization.p2pGoToMyAds,
              onPressed: () => Get.offAllNamed(
                BaseRoute.p2pTrading,
                arguments: {
                  'initial_tab': 3,
                  'from_create_ad_success': true,
                },
              ),
              width: double.infinity,
            ),
            SizedBox(height: 18.h),
          ],
        ),
      ],
    );
  }

  Widget _buildTopRow({
    required String left,
    required String right,
    required Color rightColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
          Text(
            right,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: rightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String title, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
    );
  }
}
