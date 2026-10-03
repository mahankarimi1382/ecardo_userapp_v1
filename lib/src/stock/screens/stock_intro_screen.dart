import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'stock_order_screen.dart';

/// Screen introducing international stock trading markets, risk profile requirements,
/// and execution mechanisms.
class StockIntroScreen extends StatelessWidget {
  const StockIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'Ø±Ø§Ù‡Ù†Ù…Ø§ÛŒ Ø¨ÙˆØ±Ø³â€ŒÙ‡Ø§ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ',
              en: 'Global Stock Markets Guide',
              ar: 'Ø¯Ù„ÙŠÙ„ Ø§Ù„Ø£Ø³Ù‡Ù… ÙˆØ§Ù„Ø£Ø³ÙˆØ§Ù‚ Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠØ©',
              zh: 'å…¨çƒè¯åˆ¸å¸‚åœºäº¤æ˜“æŒ‡å—',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'ÙˆØ±ÙˆØ¯ Ø¨Ù‡ Ø³Ø§Ù…Ø§Ù†Ù‡ Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù…',
              en: 'Open Stock Order Desk',
              ar: 'Ø§Ù„Ø¯Ø®ÙˆÙ„ Ø¥Ù„Ù‰ Ù…Ù†ØµØ© Ø§Ù„ØªØ¯Ø§ÙˆÙ„',
              zh: 'è¿›å…¥å›½é™…è‚¡ç¥¨ä¸‹å•ç»ˆç«¯',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () => Get.to(() => const StockOrderScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlack, AppColors.darkGray],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.mainSoftBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.show_chart_rounded, color: AppColors.mainSoftBlue, size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'Ø¯Ø³ØªØ±Ø³ÛŒ Ù…Ø³ØªÙ‚ÛŒÙ… Ø¨Ù‡ Ø¨Ø§Ø²Ø§Ø±Ù‡Ø§ÛŒ Ø³Ù‡Ø§Ù… Ø¬Ù‡Ø§Ù†ÛŒ',
                            en: 'Direct Access to Global Equities',
                            ar: 'ÙˆØµÙˆÙ„ Ù…Ø¨Ø§Ø´Ø± Ø¥Ù„Ù‰ Ø£Ø³ÙˆØ§Ù‚ Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ø¯ÙˆÙ„ÙŠØ©',
                            zh: 'ç›´è¿žå…¨çƒæ ¸å¿ƒè‚¡ç¥¨äº¤æ˜“æ‰€',
                          ),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'Ø§Ù…Ú©Ø§Ù† Ù…Ø¹Ø§Ù…Ù„Ù‡ Ø³Ù‡Ø§Ù… Ø´Ø±Ú©Øªâ€ŒÙ‡Ø§ÛŒ Ø¨Ø²Ø±Ú¯ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ Ø¯Ø± Ø¨ÙˆØ±Ø³ Ù†ÛŒÙˆÛŒÙˆØ±Ú© (NYSE)ØŒ Ù†Ø²Ø¯Ú© (NASDAQ) Ùˆ Ø¨ÙˆØ±Ø³ Ù„Ù†Ø¯Ù† Ø¨Ø§ ØªØ³ÙˆÛŒÙ‡ Ø±ÛŒØ§Ù„ÛŒ Ùˆ Ø§Ø±Ø²ÛŒ Ù„Ø­Ø¸Ù‡â€ŒØ§ÛŒ.',
                      en: 'Trade top international equities across NYSE, NASDAQ, and London Stock Exchange with real-time multi-currency settlement.',
                      ar: 'ØªØ¯Ø§ÙˆÙ„ Ø£Ø³Ù‡Ù… ÙƒØ¨Ø±Ù‰ Ø§Ù„Ø´Ø±ÙƒØ§Øª Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠØ© ÙÙŠ Ø¨ÙˆØ±ØµØ§Øª Ù†ÙŠÙˆÙŠÙˆØ±Ùƒ ÙˆÙ†Ø§Ø³Ø¯Ø§Ùƒ ÙˆÙ„Ù†Ø¯Ù† Ù…Ø¹ ØªØ³ÙˆÙŠØ© ÙÙˆØ±ÙŠØ©.',
                      zh: 'å®žæ—¶äº¤æ˜“çº½äº¤æ‰€ï¼ˆNYSEï¼‰ã€çº³æ–¯è¾¾å…‹ï¼ˆNASDAQï¼‰åŠä¼¦æ•¦è¯äº¤æ‰€å…¨çƒæ ‡çš„ï¼Œæ”¯æŒå¤šå¸ç§å³æ—¶ç»“ç®—ã€‚',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Key features
            Text(
              l10nPick(
                context,
                fa: 'ÙˆÛŒÚ˜Ú¯ÛŒâ€ŒÙ‡Ø§ÛŒ Ú©Ù„ÛŒØ¯ÛŒ Ø³Ø±ÙˆÛŒØ³ Ù…Ø¹Ø§Ù…Ù„Ø§Øª Ø³Ù‡Ø§Ù…',
                en: 'Trading Features',
                ar: 'Ù…Ø²Ø§ÙŠØ§ Ø®Ø¯Ù…Ø© Ø§Ù„ØªØ¯Ø§ÙˆÙ„',
                zh: 'è‚¡ç¥¨äº¤æ˜“æ ¸å¿ƒç‰¹è‰²',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildFeatureTile(
              context,
              icon: Icons.currency_exchange_rounded,
              titleFa: 'ØªØ³ÙˆÛŒÙ‡ Ú†Ù†Ø¯Ø§Ø±Ø²ÛŒ Ø¢Ù†ÛŒ',
              titleEn: 'Instant Multi-Currency FX',
              descFa: 'Ù¾Ø±Ø¯Ø§Ø®Øª Ø¨Ù‡ Ø±ÛŒØ§Ù„ØŒ ØªØªØ± (USDT) ÛŒØ§ Ø¯Ù„Ø§Ø± Ø¨Ø§ Ù†Ø±Ø® Ø¨Ø±Ø§Ø¨Ø±ÛŒ Ù„Ø­Ø¸Ù‡â€ŒØ§ÛŒ Ùˆ Ø¨Ø¯ÙˆÙ† Ú©Ø§Ø±Ù…Ø²Ø¯ ØªØ¨Ø¯ÛŒÙ„ Ù¾Ù†Ù‡Ø§Ù†.',
              descEn: 'Pay in IRR, USDT, or USD with real-time FX rate snapshot and zero hidden spreads.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.bolt_rounded,
              titleFa: 'Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Market Ùˆ Limit',
              titleEn: 'Market & Limit Orders',
              descFa: 'Ø§Ø¬Ø±Ø§ÛŒ Ø³ÙØ§Ø±Ø´ Ø¨Ø± Ø§Ø³Ø§Ø³ Ø¨Ù‡ØªØ±ÛŒÙ† Ù‚ÛŒÙ…Øª Ù„Ø­Ø¸Ù‡â€ŒØ§ÛŒ Ø¨Ø§Ø²Ø§Ø± ÛŒØ§ ØªØ¹ÛŒÛŒÙ† Ù‚ÛŒÙ…Øª Ø­Ø¯ Ø¨Ø±Ø§ÛŒ Ø´Ú©Ø§Ø± ÙØ±ØµØªâ€ŒÙ‡Ø§.',
              descEn: 'Execute immediately at market best bid/ask or place disciplined limit orders.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.pie_chart_outline_rounded,
              titleFa: 'Ø³Ø¨Ø¯ Ø¯Ø§Ø±Ø§ÛŒÛŒ Ùˆ Ú¯Ø²Ø§Ø±Ø´â€ŒÚ¯ÛŒØ±ÛŒ Ø´ÙØ§Ù',
              titleEn: 'Real-Time Portfolio Tracking',
              descFa: 'Ù†Ù…Ø§ÛŒØ´ ØªÙÚ©ÛŒÚ©ÛŒ Ø¯Ø§Ø±Ø§ÛŒÛŒâ€ŒÙ‡Ø§ØŒ Ø³ÙˆØ¯ Ùˆ Ø²ÛŒØ§Ù† Ù…Ø­Ù‚Ù‚â€ŒØ´Ø¯Ù‡ Ùˆ ØºÛŒØ±Ù…Ø­Ù‚Ù‚ Ùˆ Ø³Ø§Ø¨Ù‚Ù‡ Ù…Ø¹Ø§Ù…Ù„Ø§Øª.',
              descEn: 'Granular asset breakdown, realized/unrealized P&L, and complete trade audits.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.psychology_alt_rounded,
              titleFa: 'Ø§Ù…ØªØ«Ø§Ù„ Ùˆ Ù…Ø¯ÛŒØ±ÛŒØª Ø±ÛŒØ³Ú© Ù‡ÙˆØ´Ù…Ù†Ø¯',
              titleEn: 'Compliance & Risk Governance',
              descFa: 'Ø³Ù†Ø¬Ø´ Ø´Ø§Ø®Øµ Ø±ÛŒØ³Ú© Ú©Ø§Ø±Ø¨Ø± Ù‚Ø¨Ù„ Ø§Ø² ÙˆØ±ÙˆØ¯ Ø¨Ù‡ Ù…Ø¹Ø§Ù…Ù„Ø§Øª Ù¾Ø±Ù†ÙˆØ³Ø§Ù† Ø¨Ù‡ Ù…Ù†Ø¸ÙˆØ± ØµÛŒØ§Ù†Øª Ø§Ø² Ø³Ø±Ù…Ø§ÛŒÙ‡.',
              descEn: 'Mandatory suitability and risk profiling to ensure investor capital protection.',
            ),

            SizedBox(height: 20.h),

            // Trading hours notice
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: AppColors.mainSoftBlue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'Ø³Ø§Ø¹Ø§Øª Ú©Ø§Ø±ÛŒ Ø¨Ø§Ø²Ø§Ø±Ù‡Ø§ÛŒ Ø¬Ù‡Ø§Ù†ÛŒ',
                          en: 'Market Trading Hours',
                          ar: 'Ø³Ø§Ø¹Ø§Øª Ø¹Ù…Ù„ Ø§Ù„Ø£Ø³ÙˆØ§Ù‚',
                          zh: 'å…¨çƒäº¤æ˜“æ‰€äº¤æ˜“æ—¶é—´',
                        ),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'Ø¨ÙˆØ±Ø³â€ŒÙ‡Ø§ÛŒ Ø¢Ù…Ø±ÛŒÚ©Ø§ (NYSE/NASDAQ) Ø¯Ø± Ø±ÙˆØ²Ù‡Ø§ÛŒ Ø¯ÙˆØ´Ù†Ø¨Ù‡ ØªØ§ Ø¬Ù…Ø¹Ù‡ Ø§Ø² Ø³Ø§Ø¹Øª Û¹:Û³Û° Ø§Ù„ÛŒ Û±Û¶:Û°Û° Ø¨Ù‡ ÙˆÙ‚Øª Ù†ÛŒÙˆÛŒÙˆØ±Ú© ÙØ¹Ø§Ù„ Ù…ÛŒâ€ŒØ¨Ø§Ø´Ù†Ø¯. Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ø«Ø¨Øªâ€ŒØ´Ø¯Ù‡ Ø¯Ø± Ø²Ù…Ø§Ù† ØªØ¹Ø·ÛŒÙ„ÛŒØŒ Ø¯Ø± Ø§Ø¨ØªØ¯Ø§ÛŒ Ø¬Ù„Ø³Ù‡ Ø¨Ø¹Ø¯ Ø§Ø±Ø³Ø§Ù„ Ø®ÙˆØ§Ù‡Ù†Ø¯ Ø´Ø¯.',
                      en: 'US markets operate Mondayâ€“Friday 09:30â€“16:00 EST. Orders placed after hours are queued for market open.',
                      ar: 'ØªØ¹Ù…Ù„ Ø§Ù„Ø¨ÙˆØ±ØµØ§Øª Ø§Ù„Ø£Ù…Ø±ÙŠÙƒÙŠØ© Ù…Ù† Ø§Ù„Ø¥Ø«Ù†ÙŠÙ† Ø¥Ù„Ù‰ Ø§Ù„Ø¬Ù…Ø¹Ø©. Ø§Ù„Ø£ÙˆØ§Ù…Ø± Ø§Ù„Ù…Ø³Ø¬Ù„Ø© Ø®Ø§Ø±Ø¬ Ø§Ù„Ø³Ø§Ø¹Ø§Øª ØªÙØ¹Ù„Ù‚ Ù„Ø§ÙØªØªØ§Ø­ Ø§Ù„Ø¬Ù„Ø³Ø©.',
                      zh: 'ç¾Žè‚¡å¸¸è§„äº¤æ˜“æ—¶æ®µä¸ºç¾Žä¸œæ—¶é—´å‘¨ä¸€è‡³å‘¨äº” 09:30â€“16:00ã€‚ä¼‘å¸‚æ—¶æ®µæ‰€ä¸‹è®¢å•å°†åœ¨ä¸‹ä¸ªäº¤æ˜“æ—¥å¼€ç›˜æŽ’é˜Ÿæäº¤ã€‚',
                    ),
                    style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.lightPrimary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
