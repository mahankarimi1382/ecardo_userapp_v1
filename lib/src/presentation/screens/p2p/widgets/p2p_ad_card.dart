import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart'
    as marketplace;
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_buy_sell_ad_screen.dart';

/// P2P Advertisement Card with enhanced Trader Reputation Badge,
/// completion rate %, order volume, payment methods, and dark mode support.
class P2pAdCard extends StatelessWidget {
  final marketplace.Ad item;

  const P2pAdCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final traderName = (item.advertiser?.fullName?.trim().isNotEmpty ?? false)
        ? item.advertiser!.fullName!
        : (item.advertiser?.username ?? '--');
    final avatarText = (item.advertiser?.avatarText?.trim().isNotEmpty ?? false)
        ? item.advertiser!.avatarText!
        : (traderName.isNotEmpty ? traderName[0].toUpperCase() : 'T');
    final paymentMethod = item.paymentMethods?.isNotEmpty == true
        ? (item.paymentMethods!.first.paymentMethod?.name ?? '--')
        : '--';
    final completionRate = (item.completionRate ?? 0).toDouble();
    final completedOrders = item.completedOrders ?? 0;
    final isOwnAd = item.isOwnAd == true;
    final isAdTypeBuy = (item.adType ?? '').toLowerCase() == 'buy';
    final actionLabel = isAdTypeBuy ? localization.p2pSell : localization.p2pBuy;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trader Header & Reputation Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Online Indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, AppColors.mutedBlue]
                            : [AppColors.deepBlack, AppColors.darkGray],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        avatarText,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBg, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSpacing.sm.w),

              // Trader Name & Verified Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.advertiser?.username ?? traderName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                              color: textPrimary,
                            ),
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
                    SizedBox(height: 3.h),

                    // Trader Reputation Badges Row (Success Rate % & Volume)
                    Row(
                      children: [
                        // Completion % Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 11.r, color: AppColors.success),
                              SizedBox(width: 3.w),
                              Text(
                                '${completionRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),

                        // Orders Volume Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                          ),
                          child: Text(
                            '$completedOrders ${localization.p2pOrders.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Response Time Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12.r,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      item.responseTime ?? '15m',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: AppSpacing.sm.h),

          // Price & Order Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price, Limits & Available
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.price ?? '--',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 17.sp,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    _buildCardInfoText(localization.p2pLimit, item.orderLimit ?? '--', textPrimary, textSecondary),
                    SizedBox(height: 3.h),
                    _buildCardInfoText(localization.p2pAvailable, item.totalAmount ?? '--', textPrimary, textSecondary),
                  ],
                ),
              ),

              SizedBox(width: AppSpacing.sm.w),

              // Payment Method Pill & Action Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                    child: Text(
                      paymentMethod,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  SizedBox(
                    height: 38.h,
                    child: ElevatedButton(
                      onPressed: isOwnAd
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              final adId = item.id;
                              if (adId == null) return;
                              Get.to(
                                () => P2pBuySellAdScreen(
                                  adId: adId,
                                  isSellMode: isAdTypeBuy,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdTypeBuy
                            ? (isOwnAd ? textSecondary.withValues(alpha: 0.2) : AppColors.error)
                            : (isOwnAd ? textSecondary.withValues(alpha: 0.2) : AppColors.success),
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoText(String title, String value, Color textPrimary, Color textSecondary) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
