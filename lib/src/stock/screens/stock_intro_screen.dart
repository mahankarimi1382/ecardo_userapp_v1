import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'stock_order_screen.dart';

/// Screen introducing international stock trading markets (NYSE, NASDAQ, HKEX, LSE, TSE),
/// risk profile requirements, execution mechanisms, compliance assessment, and settlement rules.
class StockIntroScreen extends StatelessWidget {
  const StockIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'راهنمای بورس‌های بین‌المللی',
              en: 'Global Stock Markets Guide',
              ar: 'دليل الأسواق العالمية',
              zh: '全球证券交易所指南',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ECardoTokens.space4.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'ورود به سامانه ثبت سفارش سهام',
              en: 'Open Stock Order Desk',
              ar: 'الدخول إلى منصة التداول',
              zh: '进入国际股票下单终端',
            ),
            backgroundColor: ECardoTokens.brand700(context),
            textColor: ECardoTokens.inkOnBrand,
            onPressed: () => Get.to(() => const StockOrderScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ECardoTokens.space4.w,
          vertical: ECardoTokens.space3.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Card
            _buildHeroCard(context),

            SizedBox(height: ECardoTokens.space5.h),

            // 2. Supported Markets Section
            _buildSectionHeader(
              context,
              icon: Icons.language_rounded,
              titleFa: 'بازارهای پشتیبانی‌شده',
              titleEn: 'Supported Markets',
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildMarketCards(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 3. Trading Features Cards
            _buildSectionHeader(
              context,
              icon: Icons.star_outline_rounded,
              titleFa: 'ویژگی‌های کلیدی',
              titleEn: 'Trading Features',
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildFeatureTiles(context),

            SizedBox(height: ECardoTokens.space5.h),

            // 4. Compliance & Risk Assessment Requirement
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ECardoTokens.warningBg(context),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                border: Border.all(color: ECardoTokens.warning(context).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ECardoTokens.space2.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.warning(context).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.psychology_alt_rounded, color: ECardoTokens.warning(context), size: 20.sp),
                      ),
                      SizedBox(width: ECardoTokens.space3.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'امتیثال و ارزیابی ریسک (Compliance)',
                            en: 'Risk Profile & Compliance',
                            ar: 'الامتثال وتقييم المخاطر',
                            zh: '合规性与风险画像评估',
                          ),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'طبق استانداردهای بین‌المللی MIFID II و الزامات کارگزاری‌های همکار، تکمیل پرسشنامه ۶ مرحله‌ای سنجش صلاحیت و پذیرش ریسک سرمایه‌گذاری برای معاملات بازارهای جهانی اجباری است.',
                      en: 'Under MIFID II investor protection standards, completing the 6-question suitability check and risk acceptance is mandatory for global market access.',
                      ar: 'وفقا لمعايير حماية المستثمر الدولية، يجب إكمال استبيان المخاطر المكون من 6 أسئلة قبل التداول.',
                      zh: '根据 MIFID II 国际投资者保护标准，参与全球市场交易前必须完成 6 项合规与风险接受问卷。',
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkMuted(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // 5. Settlement Rules Card
            _buildSettlementRulesCard(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 6. Market Hours Notice
            _buildMarketHoursCard(context),

            SizedBox(height: ECardoTokens.space6.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ECardoTokens.space5.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ECardoTokens.brand900(context),
            ECardoTokens.brand700(context),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ECardoTokens.space2.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.sand100(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.show_chart_rounded, color: ECardoTokens.sand600(context), size: 22.sp),
              ),
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'دسترسی مستقیم به بازارهای سهام جهانی',
                    en: 'Direct Access to Global Equities',
                    ar: 'وصول مباشر للأسهم العالمية',
                    zh: '直连全球核心股票交易所',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.inkOnBrand,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space3.h),
          Text(
            l10nPick(
              context,
              fa: 'معامله سهام شرکت‌های بزرگ بین‌المللی در بورس نیویورک (NYSE)، نزدک (NASDAQ)، هنگ‌کنگ (HKEX)، لندن (LSE) و توکیو (TSE) با تسویه ریالی، تتری یا دلاری براساس نرخ لحظه‌ای ارز.',
              en: 'Trade top international equities across NYSE, NASDAQ, HKEX, LSE, and TSE with real-time multi-currency settlement in IRR, USDT, or USD.',
              ar: 'تداول أسهم كبرى الشركات العالمية في البورصات الرئيسية مع تسوية فورية.',
              zh: '实时交易纽交所（NYSE）、纳斯达克（NASDAQ）、港交所（HKEX）、伦敦证交所（LSE）及东京证交所（TSE），支持里亚尔、USDT 或美元按实时汇率结算。',
            ),
            style: TextStyle(
              fontSize: 11.5.sp,
              color: ECardoTokens.inkOnBrandMuted(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String titleFa, required String titleEn, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: ECardoTokens.brand500(context), size: 18.sp),
        SizedBox(width: ECardoTokens.space2.w),
        Text(
          l10nPick(context, fa: titleFa, en: titleEn),
          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
        ),
      ],
    );
  }

  Widget _buildMarketCards(BuildContext context) {
    final markets = [
      {'code': 'NASDAQ', 'label': 'Nasdaq'},
      {'code': 'NYSE', 'label': 'NYSE'},
      {'code': 'HKEX', 'label': 'HKEX'},
      {'code': 'LSE', 'label': 'LSE'},
      {'code': 'TSE', 'label': 'TSE'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: markets.length,
      itemBuilder: (context, i) {
        final m = markets[i];
        return Container(
          padding: EdgeInsets.all(ECardoTokens.space3.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            border: Border.all(color: ECardoTokens.border(context)),
            boxShadow: ECardoTokens.shadowCard(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Text(
                  m['code']!,
                  style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: ECardoTokens.brand700(context)),
                ),
              ),
              Text(
                l10nPick(
                  context,
                  fa: m['label']!,
                  en: m['label']!,
                  ar: m['label']!,
                  zh: m['label']!,
                ),
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureTiles(BuildContext context) {
    return Column(
      children: [
        _buildFeatureTile(
          context: context,
          icon: Icons.currency_exchange_rounded,
          titleFa: 'تسویه چندارزی آنی',
          titleEn: 'Instant Multi-Currency FX',
          descFa: 'پرداخت به ریال (IRR)، تتر (USDT) یا دلار (USD) با نرخ برابری لحظه‌ای و بدون کارمزد تبدیل پنهان.',
          descEn: 'Pay in IRR, USDT, or USD with transparent real-time FX rate snapshot and zero hidden spreads.',
        ),
        SizedBox(height: ECardoTokens.space2.h),
        _buildFeatureTile(
          context: context,
          icon: Icons.tune_rounded,
          titleFa: 'انواع سفارش معاملاتی',
          titleEn: 'Market · Limit · Stop-Loss',
          descFa: 'اجرای فوری به قیمت فعلی بازار، سفارش معین با قیمت هدف، یا حد ضرر خودکار برای مدیریت ریسک.',
          descEn: 'Execute immediately at best market price, set disciplined limit orders, or place stop-loss for risk management.',
        ),
        SizedBox(height: ECardoTokens.space2.h),
        _buildFeatureTile(
          context: context,
          icon: Icons.pie_chart_rounded,
          titleFa: 'پایش لحظه‌ای دارایی',
          titleEn: 'Real-Time Portfolio Tracking',
          descFa: 'نمایش تفکیکی سود و زیان محقق‌شده و غیرمحقق، ارزش روز holdings، و گزارش کامل معاملات.',
          descEn: 'Granular asset breakdown showing realized/unrealized P&L, current valuations, and complete trade history.',
        ),
        SizedBox(height: ECardoTokens.space2.h),
        _buildFeatureTile(
          context: context,
          icon: Icons.shield_rounded,
          titleFa: 'سنجش ریسک و مدیریت سرمایه',
          titleEn: 'Investor Protection & Risk Governance',
          descFa: 'آزمونی جامع ۶ سوالی متناسب با سطح تحمل نوسان شما؛ اهرم‌های مجاز (1:1 تا 1:2) براساس امتثال.',
          descEn: 'Comprehensive 6-question assessment tailored to your volatility tolerance; leverage tiers from conservative (1:1) to aggressive (1:2).',
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      padding: EdgeInsets.all(ECardoTokens.space3.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(ECardoTokens.space2.r),
            decoration: BoxDecoration(
              color: ECardoTokens.brand100(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            ),
            child: Icon(icon, color: ECardoTokens.brand500(context), size: 18.sp),
          ),
          SizedBox(width: ECardoTokens.space3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementRulesCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ECardoTokens.space4.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ECardoTokens.space2.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.infoBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                ),
                child: Icon(Icons.schedule_rounded, color: ECardoTokens.info(context), size: 18.sp),
              ),
              SizedBox(width: ECardoTokens.space2.w),
              Expanded(
                child: Text(
                  l10nPick(context, fa: 'قانون تسویه حساب T+2', en: 'T+2 Settlement Rule'),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
                ),
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space3.h),
          Text(
            l10nPick(
              context,
              fa: 'بر اساس قانون بین‌المللی CSO/SEC، کلیه سفارش‌های اجرایی شده در بورس‌های خارجی در طول زمان‌های اداری معمولاً پس از طی دو روز کاری (T+2) در حساب معاملاتی شما تسویه نهایی خواهند شد.',
              en: 'Per SEC and CSO regulations, all executed trades typically settle within 2 business days (T+2) and will reflect in your brokerage account.',
              ar: 'حسب نظام هيئة الأوراق المالية، تتم تسوية الصفقات خلال يومين عمليين.',
              zh: '依据美国证券交易委员会（SEC）监管规定，所有已成交的海外证券委托通常在两个工作日内（T+2）结清并反映至您的交易账户。',
            ),
            style: TextStyle(
              fontSize: 11.sp,
              color: ECardoTokens.inkMuted(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketHoursCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ECardoTokens.space4.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ECardoTokens.surfaceSunken(context),
            ECardoTokens.surfaceCard(context),
          ],
        ),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: ECardoTokens.brand500(context), size: 18.sp),
              SizedBox(width: ECardoTokens.space2.w),
              Text(
                l10nPick(context, fa: 'ساعات فعالیت بازارها', en: 'Market Operating Hours'),
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space3.h),
          _buildHourRow(context, 'NYSE / NASDAQ (USA)', 'Monday–Friday, 09:30–16:00 EST', 'دوشنبه الی جمعه, ۰۹:۳۰-۱۶:۰۰ به وقت نیویورک', '周一至周五 09:30–16:00 美东时间'),
          Divider(height: 18.h, color: ECardoTokens.border(context)),
          _buildHourRow(context, 'LSE (UK)', 'Monday–Friday, 08:00–16:30 GMT', 'دوشنبه الی جمعه, ۰۸:۰۰-۱۶:۳۰ به وقت گرینویچ', '周一至周五 08:00–16:30 伦敦时间'),
          Divider(height: 18.h, color: ECardoTokens.border(context)),
          _buildHourRow(context, 'HKEX (Hong Kong)', 'Monday–Friday, 09:30–16:00 HKT', 'دوشنبه الی جمعه, ۰۹:۳۰-۱۶:۰۰ به وقت هنگ‌کنگ', '周一至周五 09:30–16:00 香港时间'),
          Divider(height: 18.h, color: ECardoTokens.border(context)),
          _buildHourRow(context, 'TSE (Japan)', 'Monday–Friday, 09:00–11:30, 12:30–15:30 JST', 'دوشنبه الی جمعه, ۰۹:۰۰-۱۲:۰۰ و ۱۳:۰۰-۱۶:۰۰ به وقت توکیو', '周一至周五 09:00–11:30 和 12:30–15:30 东京时间'),
        ],
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, String label, String hoursEn, String hoursFa, String hoursZh) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: ECardoTokens.ink(context),
          ),
        ),
        SizedBox(width: ECardoTokens.space3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hoursEn,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: ECardoTokens.space1.h),
              Text(
                '$hoursFa | $hoursZh',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
