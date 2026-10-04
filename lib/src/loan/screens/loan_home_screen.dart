import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import '../widgets/loan_status_stepper.dart';
import 'loan_intro_screen.dart';
import 'loan_application_screen.dart';
import 'loan_tracking_screen.dart';
import 'loan_detail_screen.dart';

/// Main hub for the Loan & Credit service — overview, application entry,
/// and live application tracking.
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

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'UNDER_ASSESSMENT': return 'در حال سنجش اعتبار';
      case 'COMPLEMENT_REQUIRED': return 'نیاز به تکمیل مدارک';
      case 'OFFERED': return 'پیشنهاد صادر شد';
      case 'AWAITING_COLLATERAL': return 'در انتظار وثیقه';
      case 'AWAITING_SIGNING': return 'در انتظار امضا';
      case 'DISBURSED': return 'پرداخت شد';
      case 'ACTIVE': return 'در حال بازپرداخت';
      case 'OVERDUE': return 'معوق';
      case 'DEFAULTED': return 'نکول';
      case 'COMPLETED': return 'تسویه‌شده';
      case 'REJECTED': return 'رد شد';
      case 'CANCELLED': return 'لغو';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return AppColors.success;
      case 'ACTIVE': return AppColors.lightPrimary;
      case 'OVERDUE': case 'DEFAULTED': return AppColors.error;
      case 'REJECTED': case 'CANCELLED': return AppColors.grey;
      case 'OFFERED': case 'AWAITING_COLLATERAL': case 'AWAITING_SIGNING':
        return AppColors.warning;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'تسهیلات و اعتبارات',
              en: 'Loans & Credit',
              ar: 'التسهيلات والقروض',
              zh: '贷款与信贷',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.page.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'پیگیری پرونده‌ها', en: 'Tracking', ar: 'المتابعة', zh: '追踪'),
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
          return const LoanSkeletonLoader(itemCount: 4);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchProducts();
            await controller.fetchMyCases();
          },
          child: ListView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.sm.h),
            children: [
              // Notice banner if backend endpoints are unavailable / returning empty
              if (controller.hasBackendError.value || controller.products.isEmpty)
                FinancialServiceUnavailableBanner(
                  serviceNameFa: 'تسهیلات بانکی و اعتباری',
                  serviceNameEn: 'Banking & Credit Facilities',
                  serviceNameAr: 'التسهيلات المصرفية والائتمانية',
                  serviceNameZh: '银行与信贷融通',
                  onRetry: () {
                    controller.fetchProducts();
                    controller.fetchMyCases();
                  },
                ),

              SizedBox(height: AppSpacing.sm.h),

              // Quick action cards
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.calculate_outlined,
                      titleFa: 'محاسبه‌گر و راهنما',
                      titleEn: 'Guide & Calculator',
                      color: AppColors.mainSoftBlue,
                      onTap: () => Get.to(() => const LoanIntroScreen()),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.post_add_rounded,
                      titleFa: 'ثبت درخواست وام',
                      titleEn: 'Apply for Loan',
                      color: primaryAccent,
                      onTap: () => Get.to(() => const LoanApplicationScreen()),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.timeline_rounded,
                      titleFa: 'پیگیری پرونده‌ها',
                      titleEn: 'Track Cases',
                      color: const Color(0xFF059669),
                      onTap: () => Get.to(() => const LoanTrackingScreen()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.xl.h),

              // Loan Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'طرح‌های تسهیلاتی فعال',
                      en: 'Active Loan Schemes',
                      ar: 'خطط التسهيلات النشطة',
                      zh: '可用贷款方案',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const LoanIntroScreen());
                    },
                    child: Text(
                      l10nPick(context, fa: 'مشاهده شرایط', en: 'View Terms', ar: 'الشروط', zh: '条件'),
                      style: AppTextStyles.labelSmall.copyWith(color: primaryAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),

              if (controller.products.isEmpty)
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 40.sp, color: Colors.grey.shade400),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'کاتالوگ تسهیلات در حال دریافت از سرور است',
                          en: 'Loan catalog awaiting server integration',
                          ar: 'بانتظار مزامنة كتالوج التسهيلات',
                          zh: '正在等待服务器同步贷款目录',
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'می‌توانید از طریق محاسبه‌گر، اقساط طرح پیش‌فرض را ارزیابی فرمایید.',
                          en: 'You can test installment estimates via the calculator.',
                          ar: 'يمكنك تجربة حساب الأقساط عبر الحاسبة.',
                          zh: '您可以通过测算器体验预估分期还款。',
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...controller.products.map((p) => _buildProductCard(context, p, isDark, primaryAccent)),

              SizedBox(height: AppSpacing.xl.h),

              // My Recent Cases Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'پرونده‌های من',
                      en: 'My Applications',
                      ar: 'ملفاتي',
                      zh: '我的申请',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (controller.myCases.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => const LoanTrackingScreen());
                      },
                      child: Text(
                        l10nPick(context, fa: 'مشاهده همه', en: 'View All', ar: 'الكل', zh: '全部'),
                        style: AppTextStyles.labelSmall.copyWith(color: primaryAccent),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),

              if (controller.myCases.isEmpty)
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.assignment_outlined, size: 28.sp, color: Colors.grey.shade400),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'در حال حاضر هیچ پرونده تسهیلاتی فعالی ندارید.',
                            en: 'No active loan application currently recorded.',
                            ar: 'لا توجد طلبات قروض مسجلة حالياً.',
                            zh: '当前未查询到正在进行的贷款申请。',
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...controller.myCases.take(3).map((c) => _buildCaseItem(context, c, isDark)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    LoanProductModel p,
    bool isDark,
    Color primaryAccent,
  ) {
    return Container(
      margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
      padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: AppColors.mainSoftBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(
                    context,
                    fa: 'سود: ${p.baseRateAnnual}٪ سالانه · سقف: ${p.maxAmount.toInt()}',
                    en: 'Rate: ${p.baseRateAnnual}% · Max: ${p.maxAmount.toInt()}',
                    ar: 'فائدة: ${p.baseRateAnnual}٪ · الحد: ${p.maxAmount.toInt()}',
                    zh: '利率：${p.baseRateAnnual}% · 上限：${p.maxAmount.toInt()}',
                  ),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 6.h),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.selectProduct(p);
              Get.to(() => const LoanApplicationScreen());
            },
            child: Text(
              l10nPick(context, fa: 'درخواست', en: 'Apply', ar: 'طلب', zh: '申请'),
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.deepBlack : AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, LoanCaseModel c, bool isDark) {
    final statusColor = _statusColor(c.status);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => LoanDetailScreen(caseId: c.id));
      },
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
        padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10nPick(context, fa: 'پرونده', en: 'Case', ar: 'ملف', zh: '案号')} ${c.caseNo}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${c.requestedAmount.toInt()} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
              ),
              child: Text(
                _statusFa(c.status),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
