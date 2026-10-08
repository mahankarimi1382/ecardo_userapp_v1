import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_intro_screen.dart';
import 'stock_order_screen.dart';
import 'stock_tracking_screen.dart';

/// Main screen for International Stock Trading.
/// Covers market overview (NYSE, NASDAQ, HKEX, LSE, TSE), Top Gainers/Losers,
/// Portfolio summary with P&L, Watchlist, and compliance risk profiling.
class StockHomeScreen extends StatefulWidget {
  const StockHomeScreen({super.key});

  @override
  State<StockHomeScreen> createState() => _StockHomeScreenState();
}

class _StockHomeScreenState extends State<StockHomeScreen> {
  int _selectedTab = 0; // 0: Trending/All, 1: Gainers, 2: Losers, 3: Watchlist
  String _selectedExchange = 'ALL'; // ALL, NASDAQ, NYSE, HKEX, LSE, TSE

  void _showRiskQuiz(BuildContext context, StockController controller) {
    final answers = <String, String>{
      'Q1': 'EXP_MID',
      'Q2': 'HOR_LONG',
      'Q3': 'TOL_MID',
      'Q4': 'ALLOC_MID',
      'Q5': 'GOAL_GROWTH',
      'Q6': 'FX_MKT_YES',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ECardoTokens.radius2xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ECardoTokens.space5.r),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: ECardoTokens.space4.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.border(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusFull),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ECardoTokens.space2.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        ),
                        child: Icon(Icons.verified_user_rounded, color: ECardoTokens.brand500(context), size: 22.sp),
                      ),
                      SizedBox(width: ECardoTokens.space3.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'پرسشنامه امتثال و ارزیابی ریسک',
                            en: 'Compliance & Risk Assessment',
                            ar: 'تقييم الامتثال وإدارة المخاطر',
                            zh: '合规准入与风险画像评估',
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space4.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'بر اساس استانداردهای بین‌المللی MIFID II و کارگزاری‌های همکار، سنجش صلاحیت ۶ مرحله‌ای برای معاملات سهام بین‌المللی الزامی است.',
                      en: 'Under MIFID II investor protection rules, completing the 6-question suitability check is required before live market execution.',
                      ar: 'وفقاً لمعايير حماية المستثمر، يتوجب استكمال استبيان المخاطر المكون من 6 أسئلة.',
                      zh: '根据国际金融监管合规要求，实盘下单前须完成6项合规问卷评级。',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: ECardoTokens.inkMuted(context),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space4.h),
                  ...controller.defaultRiskQuestions.map((q) {
                    return Container(
                      margin: EdgeInsets.only(bottom: ECardoTokens.space3.h),
                      padding: EdgeInsets.all(ECardoTokens.space3.r),
                      decoration: BoxDecoration(
                        color: ECardoTokens.surfaceSunken(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, fa: '${q.id}: ${q.questionFa}', en: '${q.id}: ${q.questionEn}'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          SizedBox(height: ECardoTokens.space2.h),
                          Wrap(
                            spacing: ECardoTokens.space2.w,
                            runSpacing: ECardoTokens.space1.h,
                            children: q.options.map((opt) {
                              final isSelected = answers[q.id] == opt.key;
                              return ChoiceChip(
                                label: Text(
                                  l10nPick(context, fa: opt.labelFa, en: opt.labelEn),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: ECardoTokens.brand700(context),
                                backgroundColor: ECardoTokens.surfaceCard(context),
                                onSelected: (val) {
                                  if (val) {
                                    HapticFeedback.selectionClick();
                                    answers[q.id] = opt.key;
                                    (ctx as Element).markNeedsBuild();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: ECardoTokens.space4.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ECardoTokens.borderStrong(context)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                            ),
                            padding: EdgeInsets.symmetric(vertical: ECardoTokens.space3.h),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء', zh: '取消'),
                            style: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: ECardoTokens.space3.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ECardoTokens.brand700(context),
                            foregroundColor: ECardoTokens.inkOnBrand,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                            ),
                            padding: EdgeInsets.symmetric(vertical: ECardoTokens.space3.h),
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await controller.submitRiskQuiz(answers);
                            if (!context.mounted) return;
                            Get.snackbar(
                              l10nPick(context, fa: 'تأیید شد', en: 'Verified', ar: 'تم التحقق', zh: '已完成评估'),
                              l10nPick(
                                context,
                                fa: 'پروفایل ریسک و اهرم مجاز معاملاتی شما با موفقیت به روز شد.',
                                en: 'Risk profile and allowed trading tier updated.',
                                ar: 'تم تحديث ملف المخاطر بنجاح.',
                                zh: '投资者风险画像与杠杆额度已更新。',
                              ),
                              backgroundColor: ECardoTokens.success(context),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          child: Text(
                            l10nPick(context, fa: 'ثبت و فعال‌سازی حساب', en: 'Submit Assessment', ar: 'تأكيد وحفظ', zh: '提交并激活交易'),
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final StockController controller = Get.isRegistered<StockController>()
        ? Get.find<StockController>()
        : Get.put(StockController());

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
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
              padding: EdgeInsetsDirectional.only(end: ECardoTokens.space4.w),
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 22.sp,
                ),
                tooltip: l10nPick(context, fa: 'پیگیری سفارش‌ها', en: 'Tracking', ar: 'المتابعة', zh: '订单追踪'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const StockTrackingScreen());
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.markets.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        return RefreshIndicator(
          color: ECardoTokens.brand500(context),
          backgroundColor: ECardoTokens.surfaceCard(context),
          onRefresh: controller.loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: ECardoTokens.space4.w,
              vertical: ECardoTokens.space3.h,
            ),
            children: [
              if (controller.hasBackendError.value && controller.markets.isEmpty)
                FinancialServiceUnavailableBanner(
                  serviceNameFa: 'بورس‌های بین‌الملل و کارگزاری',
                  serviceNameEn: 'International Brokerage & Stocks',
                  serviceNameAr: 'الأسهم والوساطة الدولية',
                  serviceNameZh: '国际证券撮合',
                  onRetry: controller.loadDashboard,
                ),

              // 1. Portfolio Summary Hero Card
              _buildPortfolioHeroCard(context, controller),

              SizedBox(height: ECardoTokens.space4.h),

              // 2. Action Quick Tiles (Guide, Place Order, My Portfolio, Risk Quiz)
              _buildActionTilesRow(context, controller),

              SizedBox(height: ECardoTokens.space4.h),

              // 3. Compliance Risk Banner
              _buildRiskBanner(context, controller),

              SizedBox(height: ECardoTokens.space5.h),

              // 4. International Market Exchange Filter Chips (NYSE, NASDAQ, HKEX, LSE, TSE)
              _buildExchangeSelector(context, controller),

              SizedBox(height: ECardoTokens.space3.h),

              // 5. Segmented Tabs: Trending / Gainers / Losers / Watchlist
              _buildSegmentedHeader(context, controller),

              SizedBox(height: ECardoTokens.space3.h),

              // 6. Symbols List
              _buildSymbolsSection(context, controller),

              SizedBox(height: ECardoTokens.space6.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPortfolioHeroCard(BuildContext context, StockController controller) {
    final summary = controller.portfolioSummary.value;
    final totalUsd = summary?.totalValueUsd ?? 8450.0;
    final pnlUsd = summary?.totalUnrealizedPnlUsd ?? 1250.0;
    final pnlPct = summary?.totalReturnPercent ?? 17.36;
    final isPos = pnlUsd >= 0;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ECardoTokens.space2.r),
                      decoration: BoxDecoration(
                        color: ECardoTokens.inkOnBrand.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: ECardoTokens.inkOnBrand,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space2.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'ارزش پورتفوی سهام بین‌الملل',
                          en: 'Stock Portfolio Valuation',
                          ar: 'إجمالي تقييم محفظة الأسهم',
                          zh: '全球股票投资组合总值',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: ECardoTokens.inkOnBrandMuted(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ECardoTokens.space2.w),
              // T+2 Settlement Rule Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.sand400(context).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  border: Border.all(
                    color: ECardoTokens.sand400(context).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'T+2 Settlement',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.sand100(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space4.h),
          // Price and P&L row (prevent overflow with constraints)
          SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      '\$${totalUsd.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.inkOnBrand,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space2.w),
                  Flexible(
                    child: Text(
                      'USD',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.inkOnBrandMuted(context),
                      ),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space3.w),
                  // Unrealized P&L Badge
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isPos
                            ? ECardoTokens.success(context).withValues(alpha: 0.2)
                            : ECardoTokens.danger(context).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '${isPos ? '+' : ''}\$${pnlUsd.toStringAsFixed(1)} (${pnlPct.toStringAsFixed(2)}%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: isPos ? ECardoTokens.success(context) : ECardoTokens.danger(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ECardoTokens.space4.h),
          // Currency Exposure Breakdown (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(bottom: ECardoTokens.space2.h),
              child: Row(
                children: [
                  Text(
                    l10nPick(context, fa: 'توزیع ارزها:', en: 'FX Exposure:', ar: 'توزيع العملات:', zh: '币种敞口：'),
                    style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkOnBrandMuted(context)),
                  ),
                  SizedBox(width: ECardoTokens.space2.w),
                  _buildCurrencyChip('USD 75%'),
                  SizedBox(width: ECardoTokens.space1.w),
                  _buildCurrencyChip('HKD 20%'),
                  SizedBox(width: ECardoTokens.space1.w),
                  _buildCurrencyChip('GBP 5%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5.sp, color: ECardoTokens.inkOnBrand, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildActionTilesRow(BuildContext context, StockController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.candlestick_chart_rounded,
            titleFa: 'ثبت سفارش',
            titleEn: 'Place Order',
            color: ECardoTokens.brand500(context),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(() => const StockOrderScreen());
            },
          ),
        ),
        SizedBox(width: ECardoTokens.space2.w),
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.pie_chart_rounded,
            titleFa: 'سبد دارایی',
            titleEn: 'Portfolio',
            color: ECardoTokens.sand600(context),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(() => const StockTrackingScreen());
            },
          ),
        ),
        SizedBox(width: ECardoTokens.space2.w),
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.menu_book_rounded,
            titleFa: 'راهنمای بورس',
            titleEn: 'Guide',
            color: ECardoTokens.info(context),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(() => const StockIntroScreen());
            },
          ),
        ),
        SizedBox(width: ECardoTokens.space2.w),
        Expanded(
          child: _buildActionTile(
            context,
            icon: Icons.verified_user_rounded,
            titleFa: 'سنجش ریسک',
            titleEn: 'Risk Quiz',
            color: ECardoTokens.warning(context),
            onTap: () {
              HapticFeedback.lightImpact();
              _showRiskQuiz(context, controller);
            },
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ECardoTokens.space3.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(ECardoTokens.space2.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(height: ECardoTokens.space2.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBanner(BuildContext context, StockController controller) {
    final riskResult = controller.riskProfileResult.value;
    final tier = riskResult?.tier ?? 'BALANCED';
    final tierLabel = riskResult != null
        ? l10nPick(context, fa: riskResult.labelFa, en: riskResult.labelEn)
        : l10nPick(context, fa: 'متعادل (Balanced)', en: 'Balanced / Moderate');

    return Container(
      padding: EdgeInsets.all(ECardoTokens.space3.r),
      decoration: BoxDecoration(
        color: ECardoTokens.warningBg(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.warning(context).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ECardoTokens.space2.r),
            decoration: BoxDecoration(
              color: ECardoTokens.warning(context).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_rounded, color: ECardoTokens.warning(context), size: 18.sp),
          ),
          SizedBox(width: ECardoTokens.space3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4.w,
                  runSpacing: 2.h,
                  children: [
                    Text(
                      l10nPick(context, fa: 'پروفایل ریسک:', en: 'Risk Profile:'),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      child: Text(
                        tierLabel,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.brand900(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  l10nPick(
                    context,
                    fa: 'امتثال کارگزاری: اهرم مجاز ${tier == 'CONSERVATIVE' ? '1:1' : '1:2'} · تسویه ارزی T+2',
                    en: 'Compliance Tier: Leverage ${tier == 'CONSERVATIVE' ? '1:1' : '1:2'} · T+2 Settlement',
                    ar: 'الرافعة المالية المسموحة 1:1 · تسوية T+2',
                    zh: '合规准入：允许杠杆 1:2 · T+2 结算机制',
                  ),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: ECardoTokens.inkMuted(context),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showRiskQuiz(context, controller),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w),
              minimumSize: Size.zero,
            ),
            child: Text(
              l10nPick(context, fa: 'ویرایش', en: 'Edit', ar: 'تعديل', zh: '重新测评'),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.brand500(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeSelector(BuildContext context, StockController controller) {
    final exchanges = [
      {'code': 'ALL', 'label': l10nPick(context, fa: 'همه بورس‌ها', en: 'All Markets')},
      {'code': 'NASDAQ', 'label': 'NASDAQ'},
      {'code': 'NYSE', 'label': 'NYSE'},
      {'code': 'HKEX', 'label': 'HKEX'},
      {'code': 'LSE', 'label': 'LSE'},
      {'code': 'TSE', 'label': 'TSE'},
    ];

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: exchanges.length,
        separatorBuilder: (_, _) => SizedBox(width: ECardoTokens.space2.w),
        itemBuilder: (context, i) {
          final item = exchanges[i];
          final isSelected = _selectedExchange == item['code'];
          return ChoiceChip(
            label: Text(
              item['label']!,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
              ),
            ),
            selected: isSelected,
            selectedColor: ECardoTokens.brand700(context),
            backgroundColor: ECardoTokens.surfaceCard(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              side: BorderSide(
                color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w),
            onSelected: (val) {
              if (val) {
                HapticFeedback.selectionClick();
                setState(() => _selectedExchange = item['code']!);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSegmentedHeader(BuildContext context, StockController controller) {
    final tabs = [
      l10nPick(context, fa: 'همه نمادها', en: 'Trending', ar: 'الشائعة', zh: '核心标的'),
      l10nPick(context, fa: 'بیشترین رشد', en: 'Top Gainers', ar: 'الأكثر صعوداً', zh: '涨幅榜'),
      l10nPick(context, fa: 'بیشترین افت', en: 'Top Losers', ar: 'الأكثر هبوطاً', zh: '跌幅榜'),
      l10nPick(context, fa: 'دیده‌بان من', en: 'Watchlist', ar: 'المفضلة', zh: '自选股'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceSunken(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
      ),
      padding: EdgeInsets.all(ECardoTokens.space1.r),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTab = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected ? ECardoTokens.surfaceCard(context) : Colors.transparent,
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  boxShadow: isSelected ? ECardoTokens.shadowCard(context) : null,
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.inkMuted(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSymbolsSection(BuildContext context, StockController controller) {
    List<StockSymbolModel> list;

    if (_selectedTab == 1) {
      list = controller.topGainers;
    } else if (_selectedTab == 2) {
      list = controller.topLosers;
    } else if (_selectedTab == 3) {
      list = controller.watchlistedSymbols;
    } else {
      list = controller.markets.expand((m) => m.symbols).toList();
    }

    if (_selectedExchange != 'ALL') {
      list = list.where((s) => s.exchangeCode == _selectedExchange).toList();
    }

    if (list.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ECardoTokens.space6.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.format_list_bulleted_rounded,
              size: 36.sp,
              color: ECardoTokens.inkMuted(context),
            ),
            SizedBox(height: ECardoTokens.space2.h),
            Text(
              l10nPick(
                context,
                fa: 'نمادی در این دسته‌بندی یافت نشد',
                en: 'No symbols found in this category',
                ar: 'لا توجد رموز في هذه الفئة',
                zh: '该分类下暂无对应标的',
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((s) => _buildSymbolCard(context, controller, s)).toList(),
    );
  }

  Widget _buildSymbolCard(BuildContext context, StockController controller, StockSymbolModel s) {
    final isPos = s.dailyChangePct >= 0;
    final changeColor = isPos ? ECardoTokens.success(context) : ECardoTokens.danger(context);
    final isFav = controller.isWatchlisted(s.ticker);

    return Container(
      margin: EdgeInsets.only(bottom: ECardoTokens.space2.h),
      padding: EdgeInsets.all(ECardoTokens.space3.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ticker & Exchange Pill
          Flexible(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: ECardoTokens.brand100(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.ticker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: ECardoTokens.brand700(context),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    s.exchangeCode ?? 'EQUITY',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.brand500(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ECardoTokens.space3.w),

          // Name and Industry
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  s.industry ?? s.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: ECardoTokens.inkMuted(context),
                  ),
                ),
              ],
            ),
          ),

          // Price & Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${s.lastPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPos ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      size: 13.sp,
                      color: changeColor,
                    ),
                    Text(
                      '${isPos ? '+' : ''}${s.dailyChangePct.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(width: ECardoTokens.space2.w),

          // Watchlist star toggle
          IconButton(
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFav ? ECardoTokens.sand600(context) : ECardoTokens.inkMuted(context),
              size: 20.sp,
            ),
            tooltip: l10nPick(context, fa: 'دیده‌بان', en: 'Watchlist'),
            onPressed: () {
              HapticFeedback.selectionClick();
              controller.toggleWatchlist(s.ticker);
            },
          ),

          // Trade CTA
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ECardoTokens.brand700(context),
              foregroundColor: ECardoTokens.inkOnBrand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              minimumSize: Size.zero,
              elevation: 0,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.selectSymbol(s);
              Get.to(() => const StockOrderScreen());
            },
            child: Text(
              l10nPick(context, fa: 'معامله', en: 'Trade', ar: 'تداول', zh: '交易'),
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(ECardoTokens.space4.r),
      itemCount: 6,
      separatorBuilder: (_, _) => SizedBox(height: ECardoTokens.space3.h),
      itemBuilder: (_, _) => Container(
        height: 68.h,
        padding: EdgeInsets.all(ECardoTokens.space3.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceSunken(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
              ),
            ),
            SizedBox(width: ECardoTokens.space3.w),
            Expanded(
              child: Container(
                height: 14.h,
                color: ECardoTokens.surfaceSunken(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
