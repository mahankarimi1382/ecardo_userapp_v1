import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart'
    as marketplace;
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/p2p_buy_sell_ad_screen.dart';

class P2pAdCard extends StatelessWidget {
  final marketplace.Ad item;

  const P2pAdCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final traderName = (item.advertiser?.fullName?.trim().isNotEmpty ?? false)
        ? item.advertiser!.fullName!
        : (item.advertiser?.username ?? '--');
    final avatarText = (item.advertiser?.avatarText?.trim().isNotEmpty ?? false)
        ? item.advertiser!.avatarText!
        : traderName[0].toUpperCase();
    final paymentMethod = item.paymentMethods?.isNotEmpty == true
        ? (item.paymentMethods!.first.paymentMethod?.name ?? '--')
        : '--';
    final completionRate = (item.completionRate ?? 0).toDouble();
    final isOwnAd = item.isOwnAd == true;
    final isAdTypeBuy = (item.adType ?? '').toLowerCase() == 'buy';
    final actionLabel = isAdTypeBuy ? localization.p2pSell : localization.p2pBuy;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.70),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatarText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.advertiser?.username ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        if (item.advertiser?.isVerifiedTrader == true) ...[
                          SizedBox(width: 4.w),
                          SvgPicture.asset(
                            SvgAssets.commonIdVerifiedBadgeIcon,
                            width: 15.w,
                            height: 15.h,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${item.completedOrders ?? 0} ${localization.p2pOrders.toLowerCase()}  |  ${completionRate.toStringAsFixed(2)}% ${localization.p2pCompletion.toLowerCase()}',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.price ?? '--',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildCardInfoText(localization.p2pLimit, item.orderLimit ?? '--'),
                    SizedBox(height: 10.h),
                    _buildCardInfoText(localization.p2pAvailable, item.totalAmount ?? '--'),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    paymentMethod,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 12.w,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.56,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '| ${item.responseTime ?? '--'}',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  CommonButton(
                    text: actionLabel,
                    onPressed: isOwnAd
                        ? null
                        : () {
                            final adId = item.id;
                            if (adId == null) return;
                            Get.to(
                              () => P2pBuySellAdScreen(
                                adId: adId,
                                isSellMode: actionLabel == 'Sell',
                              ),
                            );
                          },
                    width: 80.w,
                    height: 30.h,
                    borderRadius: 8.r,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    textColor: isOwnAd
                        ? AppColors.lightTextPrimary.withValues(alpha: 0.4)
                        : AppColors.white,
                    backgroundColor: isAdTypeBuy
                        ? (isOwnAd
                              ? AppColors.lightTextPrimary.withValues(
                                  alpha: 0.15,
                                )
                              : AppColors.error)
                        : (isOwnAd
                              ? AppColors.lightTextPrimary.withValues(
                                  alpha: 0.15,
                                )
                              : AppColors.success),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoText(String title, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title  |  ',
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
