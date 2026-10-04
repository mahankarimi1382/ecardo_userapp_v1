import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';
import 'license_store_screen.dart';

class LicenseMyLicensesScreen extends StatefulWidget {
  const LicenseMyLicensesScreen({super.key});

  @override
  State<LicenseMyLicensesScreen> createState() => _LicenseMyLicensesScreenState();
}

class _LicenseMyLicensesScreenState extends State<LicenseMyLicensesScreen> with SingleTickerProviderStateMixin {
  late final LicenseController controller;
  late TabController _tabController;
  final Set<int> _revealedKeys = <int>{};

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LicenseController>()
        ? Get.find<LicenseController>()
        : Get.put(LicenseController());
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchMyLicenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              en: 'Digital License Vault',
              fa: 'صندوق لایسنس‌های دیجیتال',
              ar: 'خزينة التراخيص الرقمية',
              zh: '数字许可证保险库',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.lg.w),
              child: IconButton(
                tooltip: l10nPick(context, en: 'License Store', fa: 'فروشگاه لایسنس', ar: 'متجر التراخيص', zh: '授权商城'),
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconMd.sp,
                ),
                onPressed: () => Get.to(() => const LicenseStoreScreen()),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              indicatorWeight: 3.h,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vpn_key_rounded, size: AppSpacing.iconXs.sp),
                      SizedBox(width: AppSpacing.sm.w),
                      Text(l10nPick(context, en: 'Active Keys', fa: 'کلیدهای فعال', ar: 'مفاتيح نشطة', zh: '有效密钥')),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: AppSpacing.iconXs.sp),
                      SizedBox(width: AppSpacing.sm.w),
                      Text(l10nPick(context, en: 'Expired Archive', fa: 'آرشیو منقضی‌شده', ar: 'أرشيف منتهي', zh: '已过期归档')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMyLicenses.value && controller.myLicenses.isEmpty) {
                return _buildLoadingSkeleton(isDark);
              }

              final activeList = controller.myLicenses.where((k) => !k.isExpired).toList();
              final expiredList = controller.myLicenses.where((k) => k.isExpired).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, activeList, isActive: true, isDark: isDark),
                  _buildList(context, expiredList, isActive: false, isDark: isDark),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: 3,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md.h),
      itemBuilder: (_, _) => Container(
        height: 180.h,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Container(
                    height: 16.h,
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<LicenseKeyItem> list, {required bool isActive, required bool isDark}) {
    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.xxl.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryContainer : AppColors.lightSecondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.lock_outline_rounded : Icons.history_toggle_off_rounded,
                  size: 40.sp,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                isActive
                    ? l10nPick(context, en: 'No Active Licenses in Vault', fa: 'هیچ لایسنس فعالی در صندوق نیست', ar: 'لا توجد تراخيص نشطة', zh: '保险库中暂无有效许可证')
                    : l10nPick(context, en: 'No Expired Licenses', fa: 'لایسنس منقضی‌شده‌ای وجود ندارد', ar: 'لا توجد تراخيص منتهية', zh: '暂无已过期许可证'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                isActive
                    ? l10nPick(context,
                        en: 'Browse our genuine software license catalog for developer tools, OS, and AI subscriptions.',
                        fa: 'از کاتالوگ لایسنس‌های معتبر برای ابزارهای توسعه، سیستم‌عامل و هوش مصنوعی بازدید نمایید.')
                    : l10nPick(context,
                        en: 'Past expired licenses and archived activation keys will appear here.',
                        fa: 'کلیدهای منقضی‌شده قبلی در این قسمت آرشیو خواهند شد.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
              if (isActive) ...[
                SizedBox(height: AppSpacing.xl.h),
                CommonButton(
                  width: 200,
                  height: 44,
                  text: l10nPick(context, en: 'Explore License Store', fa: 'ورود به فروشگاه لایسنس', ar: 'تصفح المتجر', zh: '浏览授权商店'),
                  onPressed: () => Get.to(() => const LicenseStoreScreen()),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchMyLicenses(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.lg.r),
        itemCount: list.length,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (context, i) => _buildVaultLicenseCard(context, list[i], isDark: isDark),
      ),
    );
  }

  Widget _buildVaultLicenseCard(BuildContext context, LicenseKeyItem item, {required bool isDark}) {
    final isRevealed = _revealedKeys.contains(item.id);
    final displayedKey = isRevealed
        ? (item.licenseKey.isNotEmpty ? item.licenseKey : item.keyMasked)
        : item.keyMasked;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product Title + Security Status + Expiry Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimaryContainer : AppColors.lightSecondaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconSm.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Text(
                          '${item.edition} • ${item.durationMonths} ${l10nPick(context, en: 'Months', fa: 'ماهه', ar: 'شهر', zh: '个月')}',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, size: 10.sp, color: AppColors.success),
                              SizedBox(width: 3.w),
                              Text(
                                l10nPick(context, en: 'Genuine Retail', fa: 'اورجینال قانونی', ar: 'ترخيص أصلي', zh: '官方正版'),
                                style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: item.isExpired
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Text(
                  item.isExpired
                      ? l10nPick(context, en: 'Expired', fa: 'منقضی‌شده', ar: 'منتهي', zh: '已过期')
                      : '${item.daysRemaining ?? 30} ${l10nPick(context, en: 'Days Left', fa: 'روز باقی‌مانده', ar: 'يوم متبقي', zh: '天剩余')}',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: item.isExpired ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),

          // Digital Key Vault Container (One-Tap Copy + Reveal Toggle)
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
              border: Border.all(
                color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isRevealed ? Icons.lock_open_rounded : Icons.lock_rounded,
                  size: AppSpacing.iconXs.sp,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Text(
                    displayedKey,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: isRevealed
                      ? l10nPick(context, en: 'Hide key', fa: 'مخفی‌سازی کلید')
                      : l10nPick(context, en: 'Reveal key', fa: 'نمایش کلید'),
                  icon: Icon(
                    isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isRevealed) {
                        _revealedKeys.remove(item.id);
                      } else {
                        _revealedKeys.add(item.id);
                      }
                    });
                  },
                ),
                IconButton(
                  tooltip: l10nPick(context, en: 'Copy key', fa: 'کپی کلید'),
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18.sp,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final textToCopy = item.licenseKey.isNotEmpty ? item.licenseKey : item.keyMasked;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ToastHelper().showSuccessToast(
                      l10nPick(context, en: 'Digital license key copied!', fa: 'کلید لایسنس دیجیتال کپی شد!'),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md.h),

          // Expiry info & Renewal Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 13.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    item.expiresAt != null
                        ? '${l10nPick(context, en: 'Expires:', fa: 'انقضا:', ar: 'الانتهاء:', zh: '到期:')} ${item.expiresAt!.split("T")[0]}'
                        : '',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
              CommonButton(
                width: 140,
                height: 38,
                fontSize: 12,
                text: l10nPick(
                  context,
                  en: 'Renew License',
                  fa: 'تمدید لایسنس',
                  ar: 'تجديد الترخيص',
                  zh: '续订许可证',
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final newOrd = await controller.renewLicense(item.id);
                  if (!context.mounted) return;
                  if (newOrd != null) {
                    ToastHelper().showSuccessToast(l10nPick(
                      context,
                      en: 'Renewal order created!',
                      fa: 'سفارش تمدید لایسنس ثبت شد!',
                    ));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
