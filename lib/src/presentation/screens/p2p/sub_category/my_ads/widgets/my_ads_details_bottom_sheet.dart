import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/model/my_ads_response_model.dart';

import '../../../../../../app/constants/assets_path/png/png_assets.dart';

class MyAdsDetailsBottomSheet extends StatelessWidget {
  final Ad ad;

  const MyAdsDetailsBottomSheet({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final adType = _formatLabel(ad.adType);
    final pairText = ad.assetFiatPair?.trim().isNotEmpty == true
        ? ad.assetFiatPair!
        : '${ad.assetCurrency?.code ?? '-'} / ${ad.fiatCurrency?.code ?? '-'}';
    final totalAmountText = '${ad.totalAmount ?? '0'} '.trim();
    final completedTradeText = '${ad.completedOrders ?? 0} ${localization.p2pOrders}';
    final paymentMethods = ad.paymentMethods
        ?.map((method) => method.paymentMethod?.name ?? '')
        .where((name) => name.trim().isNotEmpty)
        .join(', ');
    final statusText = _formatLabel(ad.status);
    final statusColor = _statusColor(ad.status);
    final createTime = ad.createdAt;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 45.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.p2pAdsView,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 20.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightTextPrimary.withValues(alpha: 0.10),
                  AppColors.white,
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 28.h),
              child: Column(
                children: [
                  _buildDetailsRow(localization.p2pAdNumberTitle, ad.adNumber ?? '--'),
                  _buildDetailsRow(
                    localization.p2pType,
                    adType,
                    valueColor: adType.toLowerCase() == 'buy'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  _buildDetailsRow(localization.p2pAssetFiat, pairText),
                  _buildDetailsRow(localization.p2pTotalAmount, totalAmountText),
                  _buildDetailsRow(localization.p2pCompletedTradeQty, completedTradeText),
                  _buildDetailsRow(
                    localization.p2pOrderLimit,
                    ad.orderLimit?.trim().isNotEmpty == true
                        ? ad.orderLimit!
                        : '--',
                  ),
                  _buildDetailsRow(
                    localization.p2pPriceExchangeRate,
                    ad.exchangeText?.trim().isNotEmpty == true
                        ? ad.exchangeText!
                        : (ad.price?.trim().isNotEmpty == true
                              ? ad.price!
                              : '--'),
                  ),
                  _buildDetailsRow(
                    localization.p2pPaymentMethod,
                    paymentMethods?.trim().isNotEmpty == true
                        ? paymentMethods!
                        : '--',
                  ),
                  _buildDetailsRow(
                    localization.p2pLastUpdated,
                    ad.lastUpdated?.trim().isNotEmpty == true
                        ? ad.lastUpdated!
                        : '--',
                  ),
                  _buildDetailsRow(localization.p2pCreateTime, createTime.toString()),
                  _buildDetailsRow(
                    localization.p2pStatus,
                    statusText,
                    valueColor: statusColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: valueColor ?? AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final source = value.trim().toLowerCase();
    return source[0].toUpperCase() + source.substring(1);
  }

  Color _statusColor(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'inactive':
        return AppColors.error;
      case 'completed':
        return AppColors.lightPrimary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.lightTextPrimary.withValues(alpha: 0.6);
    }
  }
}
