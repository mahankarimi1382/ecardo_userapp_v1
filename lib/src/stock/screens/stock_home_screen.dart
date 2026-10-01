import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          l10nPick(context, fa: 'پرسشنامه ارزیابی ریسک', en: 'Risk Assessment Quiz', ar: 'استبيان تقييم المخاطر', zh: '风险评估问卷'),
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
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
              style: TextStyle(fontSize: 11.5.sp, color: Colors.grey.shade600, height: 1.5),
            ),
            SizedBox(height: 12.h),
            Text('• هدف سرمایه‌گذاری: رشد تدریجی ثروت (Capital Growth)', style: TextStyle(fontSize: 11.sp)),
            Text('• افق زمانی: بیش از ۳ سال (بلندمدت Long Term)', style: TextStyle(fontSize: 11.sp)),
            Text('• تحمل نوسان: متوسط (حفظ دارایی در افت ۲۰٪)', style: TextStyle(fontSize: 11.sp)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء', zh: '取消')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              await controller.submitRiskQuiz(answers);
              Get.snackbar(
                l10nPick(context, fa: 'ثبت شد', en: 'Updated', ar: 'تم التحديث', zh: '已更新'),
                l10nPick(context, fa: 'پروفایل ریسک شما با موفقیت ثبت شد.', en: 'Risk profile updated.', ar: 'تم حفظ الملف.', zh: '风险画像已更新。'),
                backgroundColor: const Color(0xFF059669),
                colorText: Colors.white,
              );
            },
            child: Text(
              l10nPick(context, fa: 'تأیید و ثبت پروفایل', en: 'Confirm', ar: 'تأكيد', zh: '确认提交'),
              style: const TextStyle(color: Colors.white),
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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'پیگیری سفارش‌ها', en: 'Tracking', ar: 'المتابعة', zh: '订单追踪'),
                onPressed: () => Get.to(() => const StockTrackingScreen()),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.markets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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

              SizedBox(height: 6.h),

              // Action Tiles
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      titleFa: 'راهنما و بازارها',
                      titleEn: 'Markets Guide',
                      color: AppColors.mainSoftBlue,
                      onTap: () => Get.to(() => const StockIntroScreen()),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.candlestick_chart_rounded,
                      titleFa: 'ثبت سفارش سهام',
                      titleEn: 'Place Order',
                      color: const Color(0xFF059669),
                      onTap: () => Get.to(() => const StockOrderScreen()),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.pie_chart_rounded,
                      titleFa: 'سبد دارایی و سفارشات',
                      titleEn: 'My Portfolio',
                      color: const Color(0xFF2563EB),
                      onTap: () => Get.to(() => const StockTrackingScreen()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Risk Assessment Banner / Status
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_rounded, color: const Color(0xFFD97706), size: 20.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, fa: 'سطح ریسک معاملاتی: متوسط (تأییدشده)', en: 'Risk Profile: Moderate'),
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10nPick(context, fa: 'مطابق استانداردهای امتثال مالی بین‌المللی', en: 'Compliant with investor protection rules'),
                            style: TextStyle(fontSize: 10.5.sp, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRiskQuiz(context, controller),
                      child: Text(
                        l10nPick(context, fa: 'پرسشنامه', en: 'Quiz', ar: 'الاستبيان', zh: '测验'),
                        style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

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
                      zh: '全球热门股票标的',
                    ),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const StockOrderScreen()),
                    child: Text(
                      l10nPick(context, fa: 'ثبت سفارش', en: 'Order Desk', ar: 'التداول', zh: '交易台'),
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightPrimary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              if (controller.markets.isEmpty)
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.query_stats_rounded, size: 40.sp, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'نرخ‌های زنده بازار در حال اتصال به کارگزاری است',
                          en: 'Live quotes awaiting broker feed connection',
                          ar: 'بانتظار مزامنة الأسعار المباشرة',
                          zh: '正在等待券商行情源建立连接',
                        ),
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'سفارش‌های آزمایشی را می‌توانید از طریق بخش ثبت سفارش بررسی نمایید.',
                          en: 'You can test simulated orders via the order desk.',
                          ar: 'يمكنك تجربة الأوامر عبر نافذة التداول.',
                          zh: '您可以在下单终端体验模拟买卖流程。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...controller.markets.expand((m) => m.symbols).take(5).map((s) => _buildSymbolCard(context, controller, s)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolCard(BuildContext context, StockController controller, StockSymbolModel s) {
    final isPos = s.dailyChangePct >= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              s.ticker,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.lightPrimary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 2.h),
                Text(
                  '\$${s.lastPrice}',
                  style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isPos
                  ? const Color(0xFF059669).withValues(alpha: 0.12)
                  : const Color(0xFFDC2626).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${isPos ? '+' : ''}${s.dailyChangePct.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: isPos ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            ),
            onPressed: () {
              controller.selectSymbol(s);
              Get.to(() => const StockOrderScreen());
            },
            child: Text(
              l10nPick(context, fa: 'معامله', en: 'Trade', ar: 'تداول', zh: '交易'),
              style: TextStyle(fontSize: 11.5.sp, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
