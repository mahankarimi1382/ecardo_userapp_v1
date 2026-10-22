import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// PREMIER SERVICES HUB & QUICK ACTION MATRIX (Super-App Style).
///
/// Designed in accordance with top fintech super-apps (Asan Pardakht, Top, Revolut):
/// - High-visibility access to core services right on the dashboard.
/// - 8 essential quick service tiles (Licenses, Bills, Gift Cards, Travel, Transfers, Exchange, Cards, More).
/// - Tactile micro-bounce animations with haptic feedback on tap.
/// - Direct deep routing without forcing user through nested menus.
class ServicesEntrySection extends StatelessWidget {
  const ServicesEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Section Header: Title & "View All" Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.widgets_rounded,
                        color: AppColors.white,
                        size: 16.r,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Essential Services',
                          fa: 'خدمات و امکانات',
                          ar: 'الخدمات الأساسية',
                          tr: 'Temel Hizmetler',
                          ru: 'Сервисы و услуги',
                          zh: '核心服务',
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: l10nPick(
                  context,
                  en: 'All Services',
                  fa: 'مشاهده همه',
                  ar: 'جميع الخدمات',
                  tr: 'Tümü',
                  ru: 'Все',
                  zh: '全部',
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed(BaseRoute.services);
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'All Services',
                              fa: 'مشاهده همه',
                              ar: 'جميع الخدمات',
                              tr: 'Tümü',
                              ru: 'Все',
                              zh: '全部',
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                            size: 18.r,
                            color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 2. Services Grid Container (Glassmorphic Container)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.black.withValues(alpha: 0.25)
                      : AppColors.brandViolet.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1 (Top 4 Core Services)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ServiceTileItem(
                      icon: Icons.verified_outlined,
                      label: l10nPick(
                        context,
                        en: 'Licenses',
                        fa: 'فروشگاه لایسنس',
                        ar: 'التراخيص',
                        tr: 'Lisanslar',
                        ru: 'Лицензии',
                      ),
                      gradient: const [AppColors.brandViolet, AppColors.brandVioletDeep],
                      isDark: isDark,
                      badge: l10nPick(context, en: 'VIP', fa: 'ویژه', ar: 'مميز'),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.services);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.receipt_long_rounded,
                      label: l10nPick(
                        context,
                        en: 'Bills',
                        fa: 'پرداخت قبوض',
                        ar: 'دفع الفواتير',
                        tr: 'Faturalar',
                        ru: 'Счета',
                      ),
                      gradient: const [AppColors.warning, AppColors.warmBrown],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.billPayment);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.card_giftcard_rounded,
                      label: l10nPick(
                        context,
                        en: 'Gift Cards',
                        fa: 'کارت هدیه',
                        ar: 'بطاقات الهدايا',
                        tr: 'Hediye Kartı',
                        ru: 'Подарки',
                      ),
                      gradient: const [AppColors.error, AppColors.brandVioletDeep],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.giftCard);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.flight_takeoff_rounded,
                      label: l10nPick(
                        context,
                        en: 'Travel',
                        fa: 'سفر و پرواز',
                        ar: 'السياحة والطيران',
                        tr: 'Seyahat',
                        ru: 'Путешествия',
                      ),
                      gradient: const [AppColors.info, AppColors.mutedBlue],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.services);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Row 2 (Bottom 4 Core Services)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ServiceTileItem(
                      icon: Icons.swap_horiz_rounded,
                      label: l10nPick(
                        context,
                        en: 'Transfer',
                        fa: 'انتقال وجه',
                        ar: 'تحويل أموال',
                        tr: 'Transfer',
                        ru: 'Перевод',
                      ),
                      gradient: const [AppColors.success, AppColors.mutedBlue],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.transfer);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.currency_exchange_rounded,
                      label: l10nPick(
                        context,
                        en: 'Exchange',
                        fa: 'تبدیل ارز',
                        ar: 'تبادل العملات',
                        tr: 'Döviz',
                        ru: 'Обмен',
                      ),
                      gradient: const [AppColors.info, AppColors.brandViolet],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.exchange);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.credit_card_rounded,
                      label: l10nPick(
                        context,
                        en: 'Cards',
                        fa: 'کارت مجازی',
                        ar: 'البطاقات',
                        tr: 'Kartlar',
                        ru: 'Карты',
                      ),
                      gradient: const [AppColors.mainSoftBlue, AppColors.brandVioletDeep],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.virtualCard);
                      },
                    ),
                    _ServiceTileItem(
                      icon: Icons.apps_rounded,
                      label: l10nPick(
                        context,
                        en: 'More Hub',
                        fa: 'کل خدمات',
                        ar: 'المزيد',
                        tr: 'Daha Fazla',
                        ru: 'Еще',
                      ),
                      gradient: const [AppColors.darkGray, AppColors.softGray],
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.services);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final bool isDark;
  final VoidCallback onTap;
  final String? badge;

  const _ServiceTileItem({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isDark,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = badge != null ? '$label, $badge' : label;

    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          child: SizedBox(
            width: 72.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: isDark ? 0.35 : 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.white,
                        size: 24.r,
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        top: -4.h,
                        right: -4.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isDark ? AppColors.darkCard : AppColors.white,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 7.h),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
