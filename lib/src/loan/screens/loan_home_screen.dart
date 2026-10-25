import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import '../widgets/loan_status_stepper.dart';
import 'loan_application_screen.dart';
import 'loan_detail_screen.dart';
import 'loan_collateral_warning_screen.dart';
import 'loan_tracking_screen.dart';

/// Main hub for the Loans & Credit service — elevated to modern fintech standards.
/// Features:
/// 1. Header with tracking navigation
/// 2. Real-time active loan status tracking card with embedded milestone stepper
/// 3. Available loan products catalog (Crypto-backed, Business, Personal micro)
/// 4. Sticky Bottom CTA: "Apply for a loan"
class LoanHomeScreen extends StatefulWidget {
  const LoanHomeScreen({super.key});

  @override
  State<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends State<LoanHomeScreen> {
  late final LoanController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());
    controller.fetchProducts();
    controller.fetchMyCases();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'تسهیلات و وام‌ها',
              en: 'Loans & Credit',
              ar: 'القروض والتسهيلات',
              zh: '信贷融通',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.sm.w),
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: primaryAccent,
                  size: 22.sp,
                ),
                tooltip: l10nPick(
                  context,
                  fa: 'پیگیری پرونده‌ها',
                  en: 'Track Applications',
                  ar: 'متابعة الطلبات',
                  zh: '进度追踪',
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const LoanTrackingScreen());
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeCase = controller.myCases.isNotEmpty
            ? controller.myCases.first
            : LoanController.sampleActiveLoan;

        final availableProducts = controller.products.isNotEmpty
            ? controller.products
            : LoanController.defaultProducts;

        return RefreshIndicator(
          color: primaryAccent,
          onRefresh: () async {
            await controller.fetchProducts();
            await controller.fetchMyCases();
          },
          child: ListView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.page.w,
              vertical: AppSpacing.md.h,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // ------------------ Active Loan Section Header ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'پرونده تسهیلات جاری شما',
                          en: 'Your Active Loan',
                          ar: 'ملف التسهيل النشط',
                          zh: '当前活跃贷款',
                        ),
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: primaryAccent,
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const LoanTrackingScreen());
                    },
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'همه پرونده‌ها',
                        en: 'View All',
                        ar: 'الكل',
                        zh: '全部',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),

              // ------------------ Real-time Loan Status Tracking Card ------------------
              LoanStatusTrackingCard(
                loanCase: activeCase,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => LoanDetailScreen(caseId: activeCase.id));
                },
                onPayNextInstallment: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => LoanDetailScreen(caseId: activeCase.id));
                },
                onTopUpCollateral: () {
                  HapticFeedback.lightImpact();
                  Get.to(
                    () => LoanCollateralWarningScreen(loanCase: activeCase),
                  );
                },
              ),

              SizedBox(height: AppSpacing.xl.h),

              // ------------------ Available Loan Products Header ------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'طرح‌های تسهیلاتی دردسترس',
                      en: 'Available Loan Products',
                      ar: 'طروحات التمويل المتاحة',
                      zh: '可用贷款产品方案',
                    ),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '${availableProducts.length} ${l10nPick(context, fa: 'طرح', en: 'plans', ar: 'خطط', zh: '个方案')}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),

              // ------------------ Product List Cards ------------------
              ...availableProducts.map(
                (product) => Padding(
                  padding: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
                  child: _buildProductCard(
                    context,
                    product,
                    isDark,
                    primaryAccent,
                    surfaceColor,
                    borderColor,
                    textPrimary,
                    textSecondary,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.huge.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: isDark ? AppColors.deepBlack : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                ),
              ),
              icon: Icon(FluentIcons.add_circle_24_regular, size: 18.sp),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.to(() => const LoanApplicationScreen());
              },
              label: Text(
                l10nPick(
                  context,
                  fa: 'درخواست تسهیلات جدید',
                  en: 'Apply for a Loan',
                  ar: 'طلب قرض جديد',
                  zh: '立即申请贷款',
                ),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual available product card with modern fintech visual tokens
  Widget _buildProductCard(
    BuildContext context,
    LoanProductModel p,
    bool isDark,
    Color primaryAccent,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isCrypto =
        p.requiredCollateralType != null &&
        p.requiredCollateralType!.isNotEmpty;
    final isBusiness = p.audience.toUpperCase() == 'BUSINESS';

    final badgeBg = isCrypto
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : (isBusiness
              ? const Color(0xFF3B82F6).withValues(alpha: 0.12)
              : primaryAccent.withValues(alpha: 0.12));
    final badgeColor = isCrypto
        ? const Color(0xFF059669)
        : (isBusiness ? const Color(0xFF2563EB) : primaryAccent);

    final iconData = isCrypto
        ? FluentIcons.money_hand_24_regular
        : (isBusiness
              ? FluentIcons.building_bank_24_regular
              : FluentIcons.person_24_regular);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        controller.selectProduct(p);
        Get.to(() => const LoanApplicationScreen());
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title + SLA Tag
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  ),
                  child: Center(
                    child: Icon(iconData, size: 18.sp, color: badgeColor),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.localizedName(context),
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      if (p.tagline.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          p.localizedTagline(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  ),
                  child: Text(
                    p.localizedSla(context),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.sm.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Bottom Metric Row: Rate + Max Limit + Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.percent_rounded,
                      size: 14.sp,
                      color: primaryAccent,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${p.interestRatePct.toStringAsFixed(1)}٪ ${l10nPick(context, fa: 'سالانه', en: 'APR', ar: 'سنوياً', zh: '年化')}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(width: 1, height: 12.h, color: borderColor),
                    SizedBox(width: 10.w),
                    Text(
                      '${l10nPick(context, fa: 'تا سقف', en: 'Up to', ar: 'حتى', zh: '最高')} ${p.maxAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} USD',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.sp,
                  color: primaryAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
