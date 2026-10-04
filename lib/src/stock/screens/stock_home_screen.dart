import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_intro_screen.dart';
import 'stock_order_screen.dart';
import 'stock_tracking_screen.dart';

/// Main screen for International Stock Trading.
class StockHomeScreen extends StatelessWidget {
  const StockHomeScreen({super.key});

  void _showRiskQuiz(BuildContext context, StockController controller) {
    final Map<String, String> answers = {
      'R1': 'EXP_MID',
      'R2': 'HOR_LONG',
      'R3': 'TOL_MID',
      'R4': 'ALLOC_MID',
      'R5': 'GOAL_GROWTH',
      'R6': 'FX_MKT_YES',
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(
          l10nPick(context, fa: 'پرسشنامه ارزیابی ریسک', en: 'Risk Assessment Quiz', ar: 'استبيان تقييم المخاطر', zh: '风险评估问卷'),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(
                context,
                fa: 'بر اساس الزامات امتثال و کارگزاری، ارزیابی سطح ریسک برای تعیین ابزارها و هشدارهای معاملاتی ضروری است.',
                en: 'Mandatory compliance assessment to classify your investor risk profile.',
                ar: 'تقييم الامتثال الإلزامي لتصنيف مستوى المخاطر الاستثمارية.',
                zh: '合规性投资者风险承受能力评估，用以匹配交易标的与风险警示。',
              ),
              style: TextStyle(
                fontSize: 11.5.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              l10nPick(context, en: '• Investment Goal: Capital Growth', fa: '• هدف سرمایه‌گذاری: رشد تدریجی ثروت (Capital Growth)'),
              style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            SizedBox(height: 2.h),
            Text(
              l10nPick(context, en: '• Time Horizon: >3 Years (Long Term)', fa: '• افق زمانی: بیش از ۳ سال (بلندمدت Long Term)'),
              style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            SizedBox(height: 2.h),
            Text(
              l10nPick(context, en: '• Volatility Tolerance: Moderate (Hold through 20% drawdowns)', fa: '• تحمل نوسان: متوسط (حفظ دارایی در افت ۲۰٪)'),
              style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء', zh: '取消'),
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
            ),
            onPressed: () async {
              Get.back();
              await controller.submitRiskQuiz(answers);
              if (!context.mounted) return;
              Get.snackbar(
                l10nPick(context, fa: 'ثبت شد', en: 'Updated', ar: 'تم التحديث', zh: '已更新'),
                l10nPick(context, fa: 'پروفایل ریسک شما با موفقیت ثبت شد.', en: 'Risk profile updated.', ar: 'تم حفظ الملف.', zh: '风险画像已更新。'),
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            child: Text(
              l10nPick(context, fa: 'تأیید و ثبت پروفایل', en: 'Confirm Profile', ar: 'تأكيد', zh: '确认提交'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StockController controller = Get.isRegistered<StockController>()
        ? Get.find<StockController>()
        : Get.put(StockController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'بورس و سهام بین‌الملل',
              en: 'Global Stock Trading',
              ar: 'تداول الأسهم الدولية',
              zh: '全球证券交易',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.lg.w),
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconMd.sp,
                ),
                tooltip: l10nPick(context, fa: 'پیگیری سفارش‌ها', en: 'Tracking', ar: 'المتابعة', zh: '订单追踪'),
                onPressed: () => Get.to(() => const StockTrackingScreen()),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.markets.isEmpty) {
          return _buildLoadingSkeleton(isDark);
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
            children: [
              // Notice banner if backend is unavailable / markets empty
              if (controller.hasBackendError.value || controller.markets.isEmpty)
                FinancialServiceUnavailableBanner(
                  serviceNameFa: 'بورس‌های بین‌الملل و کارگزاری',
                  serviceNameEn: 'International Brokerage & Stocks',
                  serviceNameAr: 'الأسهم والوساطة الدولية',
                  serviceNameZh: '国际证券撮合',
                  onRetry: controller.loadDashboard,
                ),

              SizedBox(height: AppSpacing.xs.h),

              // Action Tiles
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.info_outline_rounded,
                      titleFa: 'راهنما و بازارها',
                      titleEn: 'Markets Guide',
                      color: AppColors.mainSoftBlue,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => const StockIntroScreen());
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.candlestick_chart_rounded,
                      titleFa: 'ثبت سفارش سهام',
                      titleEn: 'Place Order',
                      color: AppColors.success,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => const StockOrderScreen());
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      isDark: isDark,
                      icon: Icons.pie_chart_rounded,
                      titleFa: 'سبد دارایی و سفارشات',
                      titleEn: 'My Portfolio',
                      color: AppColors.lightSecondary,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => const StockTrackingScreen());
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.lg.h),

              // Risk Assessment Banner / Status
              Container(
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm.r),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_rounded, color: AppColors.warning, size: 20.sp),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, fa: 'سطح ریسک معاملاتی: متوسط (تأییدشده)', en: 'Risk Profile: Moderate', ar: 'مستوى المخاطر: متوسط', zh: '风险画像：稳健型（已认证）'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(context, fa: 'مطابق استانداردهای امتثال مالی بین‌المللی', en: 'Compliant with investor protection rules', ar: 'متوافق مع معايير حماية المستثمر', zh: '符合国际合规与投资者保护准则'),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _showRiskQuiz(context, controller);
                      },
                      child: Text(
                        l10nPick(context, fa: 'پرسشنامه', en: 'Quiz', ar: 'الاستبيان', zh: '测评'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.xl.h),

              // Markets & Popular Stocks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'نمادهای محبوب بورس آمریکا و اروپا',
                      en: 'Trending Global Stocks',
                      ar: 'الأسهم العالمية الشائعة',
                      zh: '全球热门证券标的',
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const StockOrderScreen());
                    },
                    child: Text(
                      l10nPick(context, fa: 'میز معاملات', en: 'Order Desk', ar: 'التداول', zh: '交易台'),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),

              if (controller.markets.isEmpty)
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.query_stats_rounded,
                        size: 40.sp,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'نرخ‌های زنده بازار در حال اتصال به کارگزاری است',
                          en: 'Live quotes awaiting broker feed connection',
                          ar: 'في انتظار أسعار السوق المباشرة',
                          zh: '正在等待经纪商行情源连接',
                        ),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'سفارش‌های آزمایشی را می‌توانید از طریق بخش ثبت سفارش بررسی نمایید.',
                          en: 'You can test simulated orders via the order desk.',
                          ar: 'يمكنك تجربة أوامر التداول عبر الشاشة المخصصة.',
                          zh: '您可以在下单终端体验模拟交易流程。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...controller.markets.expand((m) => m.symbols).take(8).map((s) => _buildSymbolCard(context, controller, s, isDark)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (_, _) => Container(
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
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
      ),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm.r),
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
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolCard(BuildContext context, StockController controller, StockSymbolModel s, bool isDark) {
    final isPos = s.dailyChangePct >= 0;
    final changeColor = isPos ? AppColors.success : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ticker Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            ),
            child: Text(
              s.ticker,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md.w),

          // Name & Industry
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  s.industry ?? '\$${s.lastPrice}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Price & Change pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${s.lastPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPos ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      size: 14.sp,
                      color: changeColor,
                    ),
                    Text(
                      '${isPos ? '+' : ''}${s.dailyChangePct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(width: AppSpacing.md.w),

          // Trade CTA
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              elevation: 0,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.selectSymbol(s);
              Get.to(() => const StockOrderScreen());
            },
            child: Text(
              l10nPick(context, fa: 'معامله', en: 'Trade', ar: 'تداول', zh: '交易'),
              style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}