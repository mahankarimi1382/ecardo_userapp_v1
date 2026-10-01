import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
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
              fa: 'راهنمای بورس‌های بین‌المللی',
              en: 'Global Stock Markets Guide',
              ar: 'دليل الأسهم والأسواق العالمية',
              zh: '全球证券市场交易指南',
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
              fa: 'ورود به سامانه ثبت سفارش سهام',
              en: 'Open Stock Order Desk',
              ar: 'الدخول إلى منصة التداول',
              zh: '进入国际股票下单终端',
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
                  colors: [Color(0xFF161614), Color(0xFF1E293B)],
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
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.show_chart_rounded, color: const Color(0xFF38BDF8), size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'دسترسی مستقیم به بازارهای سهام جهانی',
                            en: 'Direct Access to Global Equities',
                            ar: 'وصول مباشر إلى أسواق الأسهم الدولية',
                            zh: '直连全球核心股票交易所',
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
                      fa: 'امکان معامله سهام شرکت‌های بزرگ بین‌المللی در بورس نیویورک (NYSE)، نزدک (NASDAQ) و بورس لندن با تسویه ریالی و ارزی لحظه‌ای.',
                      en: 'Trade top international equities across NYSE, NASDAQ, and London Stock Exchange with real-time multi-currency settlement.',
                      ar: 'تداول أسهم كبرى الشركات العالمية في بورصات نيويورك وناسداك ولندن مع تسوية فورية.',
                      zh: '实时交易纽交所（NYSE）、纳斯达克（NASDAQ）及伦敦证交所全球标的，支持多币种即时结算。',
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
                fa: 'ویژگی‌های کلیدی سرویس معاملات سهام',
                en: 'Trading Features',
                ar: 'مزايا خدمة التداول',
                zh: '股票交易核心特色',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildFeatureTile(
              context,
              icon: Icons.currency_exchange_rounded,
              titleFa: 'تسویه چندارزی آنی',
              titleEn: 'Instant Multi-Currency FX',
              descFa: 'پرداخت به ریال، تتر (USDT) یا دلار با نرخ برابری لحظه‌ای و بدون کارمزد تبدیل پنهان.',
              descEn: 'Pay in IRR, USDT, or USD with real-time FX rate snapshot and zero hidden spreads.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.bolt_rounded,
              titleFa: 'سفارش‌های Market و Limit',
              titleEn: 'Market & Limit Orders',
              descFa: 'اجرای سفارش بر اساس بهترین قیمت لحظه‌ای بازار یا تعیین قیمت حد برای شکار فرصت‌ها.',
              descEn: 'Execute immediately at market best bid/ask or place disciplined limit orders.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.pie_chart_outline_rounded,
              titleFa: 'سبد دارایی و گزارش‌گیری شفاف',
              titleEn: 'Real-Time Portfolio Tracking',
              descFa: 'نمایش تفکیکی دارایی‌ها، سود و زیان محقق‌شده و غیرمحقق و سابقه معاملات.',
              descEn: 'Granular asset breakdown, realized/unrealized P&L, and complete trade audits.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.psychology_alt_rounded,
              titleFa: 'امتثال و مدیریت ریسک هوشمند',
              titleEn: 'Compliance & Risk Governance',
              descFa: 'سنجش شاخص ریسک کاربر قبل از ورود به معاملات پرنوسان به منظور صیانت از سرمایه.',
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
                          fa: 'ساعات کاری بازارهای جهانی',
                          en: 'Market Trading Hours',
                          ar: 'ساعات عمل الأسواق',
                          zh: '全球交易所交易时间',
                        ),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'بورس‌های آمریکا (NYSE/NASDAQ) در روزهای دوشنبه تا جمعه از ساعت ۹:۳۰ الی ۱۶:۰۰ به وقت نیویورک فعال می‌باشند. سفارش‌های ثبت‌شده در زمان تعطیلی، در ابتدای جلسه بعد ارسال خواهند شد.',
                      en: 'US markets operate Monday–Friday 09:30–16:00 EST. Orders placed after hours are queued for market open.',
                      ar: 'تعمل البورصات الأمريكية من الإثنين إلى الجمعة. الأوامر المسجلة خارج الساعات تُعلق لافتتاح الجلسة.',
                      zh: '美股常规交易时段为美东时间周一至周五 09:30–16:00。休市时段所下订单将在下个交易日开盘排队提交。',
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
