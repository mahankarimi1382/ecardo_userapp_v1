import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/model/my_ads_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/widgets/delete_payment_account_dropdown_section.dart';

import 'edit_my_ad_bottom_sheet.dart';
import 'my_ads_details_bottom_sheet.dart';

class MyAdsCard extends StatelessWidget {
  final Ad ad;
  final MyAdsController controller;

  const MyAdsCard({super.key, required this.ad, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final adType = _formatLabel(ad.adType);
    final normalizedStatus = ad.status?.trim().toLowerCase() ?? '';
    final isBuy = adType.toLowerCase() == 'buy';
    final canToggleStatus =
        normalizedStatus == 'active' || normalizedStatus == 'inactive';
    final isActiveStatus = normalizedStatus == 'active';
    final pairText = ad.assetFiatPair?.trim().isNotEmpty == true
        ? ad.assetFiatPair!
        : '${ad.assetCurrency?.code ?? '-'} / ${ad.fiatCurrency?.code ?? '-'}';
    final totalAmountText = (ad.totalAmount ?? '0').trim();
    final completedTradeText = '${ad.completedOrders ?? 0} ${localization.p2pOrders}';
    final statusText = _formatLabel(ad.status);
    final statusColor = _statusColor(ad.status);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.adNumber ?? '--',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      pairText,
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (isBuy ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  adType,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: isBuy ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoBlock(
                  title: localization.p2pTotalAmount,
                  value: totalAmountText,
                ),
              ),
              Expanded(
                child: _buildInfoBlock(
                  title: localization.p2pCompletedTradeQty,
                  value: completedTradeText,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(
            height: 1,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${localization.p2pStatus}: ',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: statusText,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildActionIcon(
                icon: Icons.edit_outlined,
                color: AppColors.lightTextPrimary,
                onTap: _openEditBottomSheet,
              ),
              if (canToggleStatus) ...[
                SizedBox(width: 12.w),
                _buildActionIcon(
                  icon: isActiveStatus
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  color: isActiveStatus
                      ? AppColors.lightPrimary
                      : AppColors.success,
                  onTap: _onToggleAdStatus,
                ),
              ],
              SizedBox(width: 12.w),
              _buildActionIcon(
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: _openDeleteBottomSheet,
              ),
              SizedBox(width: 10.w),
              CommonButton(
                text: localization.p2pView,
                onPressed: _openAdDetailsBottomSheet,
                borderRadius: 10.r,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 26.h,
                width: 50.w,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({
    required String title,
    required String value,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Icon(icon, size: 20.w, color: color),
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

  void _openAdDetailsBottomSheet() {
    Get.bottomSheet(MyAdsDetailsBottomSheet(ad: ad), isScrollControlled: true);
  }

  void _openDeleteBottomSheet() {
    final adId = ad.id?.toString();
    if (adId == null || adId.isEmpty) return;

    Get.bottomSheet(
      DeletePaymentAccountDropdownSection(
        onPressed: () async {
          Get.back();
          await controller.deleteAds(adId);
        },
        subTitle: AppLocalizations.of(Get.context!)!.p2pDeleteAdConfirmation,
      ),
    );
  }

  Future<void> _onToggleAdStatus() async {
    final adId = ad.id?.toString();
    if (adId == null || adId.isEmpty) return;

    final currentStatus = ad.status?.trim().toLowerCase();
    if (currentStatus != 'active' && currentStatus != 'inactive') return;

    final nextStatus = currentStatus == 'active' ? 'inactive' : 'active';
    await controller.updateAdStatus(adId: adId, status: nextStatus);
  }

  void _openEditBottomSheet() {
    Get.bottomSheet(
      EditMyAdBottomSheet(ad: ad, controller: controller),
      isScrollControlled: true,
    );
  }
}
