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
          l10nPick(context, fa: 'Ù¾Ø±Ø³Ø´Ù†Ø§Ù…Ù‡ Ø§Ø±Ø²ÛŒØ§Ø¨ÛŒ Ø±ÛŒØ³Ú©', en: 'Risk Assessment Quiz', ar: 'Ø§Ø³ØªØ¨ÙŠØ§Ù† ØªÙ‚ÙŠÙŠÙ… Ø§Ù„Ù…Ø®Ø§Ø·Ø±', zh: 'é£Žé™©è¯„ä¼°é—®å·'),
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(
                context,
                fa: 'Ø¨Ø± Ø§Ø³Ø§Ø³ Ø§Ù„Ø²Ø§Ù…Ø§Øª Ø§Ù…ØªØ«Ø§Ù„ Ùˆ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒØŒ Ø§Ø±Ø²ÛŒØ§Ø¨ÛŒ Ø³Ø·Ø­ Ø±ÛŒØ³Ú© Ø¨Ø±Ø§ÛŒ ØªØ¹ÛŒÛŒÙ† Ø§Ø¨Ø²Ø§Ø±Ù‡Ø§ Ùˆ Ù‡Ø´Ø¯Ø§Ø±Ù‡Ø§ÛŒ Ù…Ø¹Ø§Ù…Ù„Ø§ØªÛŒ Ø¶Ø±ÙˆØ±ÛŒ Ø§Ø³Øª.',
                en: 'Mandatory compliance assessment to classify your investor risk profile.',
                ar: 'ØªÙ‚ÙŠÙŠÙ… Ø§Ù„Ø§Ù…ØªØ«Ø§Ù„ Ø§Ù„Ø¥Ù„Ø²Ø§Ù…ÙŠ Ù„ØªØµÙ†ÙŠÙ Ù…Ø³ØªÙˆÙ‰ Ø§Ù„Ù…Ø®Ø§Ø·Ø± Ø§Ù„Ø§Ø³ØªØ«Ù…Ø§Ø±ÙŠØ©.',
                zh: 'åˆè§„æ€§æŠ•èµ„è€…é£Žé™©æ‰¿å—èƒ½åŠ›è¯„ä¼°ï¼Œç”¨ä»¥åŒ¹é…äº¤æ˜“æ ‡çš„ä¸Žé£Žé™©è­¦ç¤ºã€‚',
              ),
              style: TextStyle(fontSize: 11.5.sp, color: Colors.grey.shade600, height: 1.5),
            ),
            SizedBox(height: 12.h),
            Text('â€¢ Ù‡Ø¯Ù Ø³Ø±Ù…Ø§ÛŒÙ‡â€ŒÚ¯Ø°Ø§Ø±ÛŒ: Ø±Ø´Ø¯ ØªØ¯Ø±ÛŒØ¬ÛŒ Ø«Ø±ÙˆØª (Capital Growth)', style: TextStyle(fontSize: 11.sp)),
            Text('â€¢ Ø§ÙÙ‚ Ø²Ù…Ø§Ù†ÛŒ: Ø¨ÛŒØ´ Ø§Ø² Û³ Ø³Ø§Ù„ (Ø¨Ù„Ù†Ø¯Ù…Ø¯Øª Long Term)', style: TextStyle(fontSize: 11.sp)),
            Text('â€¢ ØªØ­Ù…Ù„ Ù†ÙˆØ³Ø§Ù†: Ù…ØªÙˆØ³Ø· (Ø­ÙØ¸ Ø¯Ø§Ø±Ø§ÛŒÛŒ Ø¯Ø± Ø§ÙØª Û²Û°Ùª)', style: TextStyle(fontSize: 11.sp)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, fa: 'Ø§Ù†ØµØ±Ø§Ù', en: 'Cancel', ar: 'Ø¥Ù„ØºØ§Ø¡', zh: 'å–æ¶ˆ')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              await controller.submitRiskQuiz(answers);
              Get.snackbar(
                l10nPick(context, fa: 'Ø«Ø¨Øª Ø´Ø¯', en: 'Updated', ar: 'ØªÙ… Ø§Ù„ØªØ­Ø¯ÙŠØ«', zh: 'å·²æ›´æ–°'),
                l10nPick(context, fa: 'Ù¾Ø±ÙˆÙØ§ÛŒÙ„ Ø±ÛŒØ³Ú© Ø´Ù…Ø§ Ø¨Ø§ Ù…ÙˆÙÙ‚ÛŒØª Ø«Ø¨Øª Ø´Ø¯.', en: 'Risk profile updated.', ar: 'ØªÙ… Ø­ÙØ¸ Ø§Ù„Ù…Ù„Ù.', zh: 'é£Žé™©ç”»åƒå·²æ›´æ–°ã€‚'),
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            },
            child: Text(
              l10nPick(context, fa: 'ØªØ£ÛŒÛŒØ¯ Ùˆ Ø«Ø¨Øª Ù¾Ø±ÙˆÙØ§ÛŒÙ„', en: 'Confirm', ar: 'ØªØ£ÙƒÙŠØ¯', zh: 'ç¡®è®¤æäº¤'),
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
              fa: 'Ø¨ÙˆØ±Ø³ Ùˆ Ø³Ù‡Ø§Ù… Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„',
              en: 'Global Stock Trading',
              ar: 'ØªØ¯Ø§ÙˆÙ„ Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ø¯ÙˆÙ„ÙŠØ©',
              zh: 'å…¨çƒè¯åˆ¸äº¤æ˜“',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'Ù¾ÛŒÚ¯ÛŒØ±ÛŒ Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§', en: 'Tracking', ar: 'Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©', zh: 'è®¢å•è¿½è¸ª'),
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
                  serviceNameFa: 'Ø¨ÙˆØ±Ø³â€ŒÙ‡Ø§ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ Ùˆ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ',
                  serviceNameEn: 'International Brokerage & Stocks',
                  serviceNameAr: 'Ø§Ù„Ø£Ø³Ù‡Ù… ÙˆØ§Ù„ÙˆØ³Ø§Ø·Ø© Ø§Ù„Ø¯ÙˆÙ„ÙŠØ©',
                  serviceNameZh: 'å›½é™…è¯åˆ¸æ’®åˆ',
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
                      titleFa: 'Ø±Ø§Ù‡Ù†Ù…Ø§ Ùˆ Ø¨Ø§Ø²Ø§Ø±Ù‡Ø§',
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
                      titleFa: 'Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù…',
                      titleEn: 'Place Order',
                      color: AppColors.success,
                      onTap: () => Get.to(() => const StockOrderScreen()),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.pie_chart_rounded,
                      titleFa: 'Ø³Ø¨Ø¯ Ø¯Ø§Ø±Ø§ÛŒÛŒ Ùˆ Ø³ÙØ§Ø±Ø´Ø§Øª',
                      titleEn: 'My Portfolio',
                      color: AppColors.lightSecondary,
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
                        color: AppColors.warning.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_rounded, color: AppColors.warning, size: 20.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, fa: 'Ø³Ø·Ø­ Ø±ÛŒØ³Ú© Ù…Ø¹Ø§Ù…Ù„Ø§ØªÛŒ: Ù…ØªÙˆØ³Ø· (ØªØ£ÛŒÛŒØ¯Ø´Ø¯Ù‡)', en: 'Risk Profile: Moderate'),
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10nPick(context, fa: 'Ù…Ø·Ø§Ø¨Ù‚ Ø§Ø³ØªØ§Ù†Ø¯Ø§Ø±Ø¯Ù‡Ø§ÛŒ Ø§Ù…ØªØ«Ø§Ù„ Ù…Ø§Ù„ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ', en: 'Compliant with investor protection rules'),
                            style: TextStyle(fontSize: 10.5.sp, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRiskQuiz(context, controller),
                      child: Text(
                        l10nPick(context, fa: 'Ù¾Ø±Ø³Ø´Ù†Ø§Ù…Ù‡', en: 'Quiz', ar: 'Ø§Ù„Ø§Ø³ØªØ¨ÙŠØ§Ù†', zh: 'æµ‹éªŒ'),
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
                      fa: 'Ù†Ù…Ø§Ø¯Ù‡Ø§ÛŒ Ù…Ø­Ø¨ÙˆØ¨ Ø¨ÙˆØ±Ø³ Ø¢Ù…Ø±ÛŒÚ©Ø§ Ùˆ Ø§Ø±ÙˆÙ¾Ø§',
                      en: 'Trending Global Stocks',
                      ar: 'Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠØ© Ø§Ù„Ø´Ø§Ø¦Ø¹Ø©',
                      zh: 'å…¨çƒçƒ­é—¨è‚¡ç¥¨æ ‡çš„',
                    ),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const StockOrderScreen()),
                    child: Text(
                      l10nPick(context, fa: 'Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´', en: 'Order Desk', ar: 'Ø§Ù„ØªØ¯Ø§ÙˆÙ„', zh: 'äº¤æ˜“å°'),
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
                          fa: 'Ù†Ø±Ø®â€ŒÙ‡Ø§ÛŒ Ø²Ù†Ø¯Ù‡ Ø¨Ø§Ø²Ø§Ø± Ø¯Ø± Ø­Ø§Ù„ Ø§ØªØµØ§Ù„ Ø¨Ù‡ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ Ø§Ø³Øª',
                          en: 'Live quotes awaiting broker feed connection',
                          ar: 'Ø¨Ø§Ù†ØªØ¸Ø§Ø± Ù…Ø²Ø§Ù…Ù†Ø© Ø§Ù„Ø£Ø³Ø¹Ø§Ø± Ø§Ù„Ù…Ø¨Ø§Ø´Ø±Ø©',
                          zh: 'æ­£åœ¨ç­‰å¾…åˆ¸å•†è¡Œæƒ…æºå»ºç«‹è¿žæŽ¥',
                        ),
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ø¢Ø²Ù…Ø§ÛŒØ´ÛŒ Ø±Ø§ Ù…ÛŒâ€ŒØªÙˆØ§Ù†ÛŒØ¯ Ø§Ø² Ø·Ø±ÛŒÙ‚ Ø¨Ø®Ø´ Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´ Ø¨Ø±Ø±Ø³ÛŒ Ù†Ù…Ø§ÛŒÛŒØ¯.',
                          en: 'You can test simulated orders via the order desk.',
                          ar: 'ÙŠÙ…ÙƒÙ†Ùƒ ØªØ¬Ø±Ø¨Ø© Ø§Ù„Ø£ÙˆØ§Ù…Ø± Ø¹Ø¨Ø± Ù†Ø§ÙØ°Ø© Ø§Ù„ØªØ¯Ø§ÙˆÙ„.',
                          zh: 'æ‚¨å¯ä»¥åœ¨ä¸‹å•ç»ˆç«¯ä½“éªŒæ¨¡æ‹Ÿä¹°å–æµç¨‹ã€‚',
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
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${isPos ? '+' : ''}${s.dailyChangePct.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: isPos ? AppColors.success : AppColors.error,
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
              l10nPick(context, fa: 'Ù…Ø¹Ø§Ù…Ù„Ù‡', en: 'Trade', ar: 'ØªØ¯Ø§ÙˆÙ„', zh: 'äº¤æ˜“'),
              style: TextStyle(fontSize: 11.5.sp, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
