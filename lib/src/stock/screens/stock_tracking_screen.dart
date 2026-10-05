import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_order_screen.dart';

/// Screen displaying international stock orders, execution states, and portfolio holdings.
/// Features real-time tracking across NYSE, NASDAQ, HKEX, LSE, TSE with T+2 settlement awareness.
class StockTrackingScreen extends StatefulWidget {
  const StockTrackingScreen({super.key});

  @override
  State<StockTrackingScreen> createState() => _StockTrackingScreenState();
}

class _StockTrackingScreenState extends State<StockTrackingScreen> with SingleTickerProviderStateMixin {
  late final StockController controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<StockController>()
        ? Get.find<StockController>()
        : Get.put(StockController());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'SUBMITTED': return l10nPick(context, fa: 'ثبت شده', en: 'Submitted');
      case 'PENDING_BROKER': return l10nPick(context, fa: 'در صف کارگزاری', en: 'Pending Broker');
      case 'EXECUTED': return l10nPick(context, fa: 'اجرا شد', en: 'Executed');
      case 'PARTIALLY_FILLED': return l10nPick(context, fa: 'اجرای جزئی', en: 'Partial Fill');
      case 'CANCELLED': return l10nPick(context, fa: 'لغو شده', en: 'Cancelled');
      case 'REJECTED': return l10nPick(context, fa: 'رد شد', en: 'Rejected');
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'EXECUTED':
      case 'PARTIALLY_FILLED':
        return ECardoTokens.success(context);
      case 'PENDING_BROKER':
        return ECardoTokens.warning(context);
      case 'REJECTED':
      case 'CANCELLED':
        return ECardoTokens.danger(context);
      case 'SUBMITTED':
        return ECardoTokens.info(context);
      default:
        return ECardoTokens.inkMuted(context);
    }
  }

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
              fa: 'پیگیری سفارش‌ها و دارایی‌های سهام',
              en: 'Stock Orders & Portfolio',
              ar: 'متابعة أوامر ومحفظة الأسهم',
              zh: '股票委托与持仓管理',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner
          FinancialServiceUnavailableBanner(
            serviceNameFa: 'بورس و کارگزاری بین‌الملل',
            serviceNameEn: 'Stock Brokerage',
            serviceNameAr: 'الأسهم والوساطة الدولية',
            serviceNameZh: '国际证券经纪',
            isCompact: true,
            onRetry: controller.loadDashboard,
          ),

          // Tabs
          Container(
            color: ECardoTokens.surfaceSunken(context),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ECardoTokens.brand700(context),
              labelColor: ECardoTokens.brand700(context),
              unselectedLabelColor: ECardoTokens.inkMuted(context),
              labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
              indicatorWeight: 3.h,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10nPick(context, fa: 'سفارش‌های من', en: 'My Orders', ar: 'أوامري', zh: '委托明细')),
                Tab(text: l10nPick(context, fa: 'سبد دارایی (پورتفوی)', en: 'Portfolio', ar: 'المحفظة', zh: '持仓概览')),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Orders tab
                Obx(() {
                  final ordersList = controller.orders;
                  if (ordersList.isEmpty) {
                    return _buildEmptyState(
                      context,
                      icon: Icons.history_rounded,
                      titleFa: 'هیچ سفارش سهامی ثبت نشده است',
                      titleEn: 'No stock orders recorded',
                      descFa: 'سفارش‌های خرید و فروش سهام بین‌المللی شما پس از ثبت در این بخش پیگیری می‌شوند.',
                      descEn: 'Your buy and sell stock orders will appear here once placed.',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadDashboard,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ECardoTokens.space4.w,
                        vertical: ECardoTokens.space3.h,
                      ),
                      itemCount: ordersList.length,
                      separatorBuilder: (_, _) => SizedBox(height: ECardoTokens.space3.h),
                      itemBuilder: (context, i) {
                        final ord = ordersList[i];
                        return _buildOrderCard(context, ord);
                      },
                    ),
                  );
                }),

                // Portfolio tab
                Obx(() {
                  final summary = controller.portfolioSummary.value;
                  final acc = controller.account.value;

                  return RefreshIndicator(
                    onRefresh: controller.loadDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ECardoTokens.space4.w,
                        vertical: ECardoTokens.space3.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Balance Summary Card
                          Container(
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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10nPick(context, fa: 'ارزش کل دارایی سهام (USD)', en: 'Total Stock Valuation (USD)'),
                                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkOnBrandMuted(context)),
                                    ),
                                    Icon(Icons.pie_chart_rounded, color: ECardoTokens.sand400(context), size: 18.sp),
                                  ],
                                ),
                                SizedBox(height: ECardoTokens.space2.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '\$${summary?.totalValueUsd.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: ECardoTokens.inkOnBrand),
                                    ),
                                    SizedBox(width: ECardoTokens.space2.w),
                                    Text(
                                      summary != null && summary.totalUnrealizedPnlUsd >= 0
                                          ? '+\$${summary.totalUnrealizedPnlUsd.toStringAsFixed(1)}'
                                          : '-',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: ECardoTokens.inkOnBrandMuted(context),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: ECardoTokens.sand400(context).withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                      ),
                                      child: Text(
                                        'T+2 Settlement',
                                        style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w800, color: ECardoTokens.sand100(context)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: ECardoTokens.space3.h),
                                Divider(height: 18.h, color: ECardoTokens.inkOnBrand.withValues(alpha: 0.1)),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      acc?.accountNumber ?? 'STK-PENDING',
                                      style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkOnBrandMuted(context)),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: ECardoTokens.successBg(context),
                                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                      ),
                                      child: Text(
                                        acc?.riskTier ?? 'BALANCED',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          color: ECardoTokens.success(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: ECardoTokens.space4.h),

                          // Holdings List Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10nPick(context, fa: 'سهام تحت تملک', en: 'Holdings'),
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: ECardoTokens.ink(context),
                                ),
                              ),
                              Text(
                                '${controller.holdings.length} symbols',
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ECardoTokens.inkMuted(context)),
                              ),
                            ],
                          ),

                          SizedBox(height: ECardoTokens.space3.h),

                          // Holdings Cards
                          if (controller.holdings.isEmpty) ...[
                            _buildEmptyState(
                              context,
                              icon: Icons.pie_chart_outline_rounded,
                              titleFa: 'سبد دارایی خالی است',
                              titleEn: 'Portfolio is currently empty',
                              descFa: 'پس از اجرای اولین سفارش خرید، سهام به حساب معاملاتی شما اضافه خواهد شد.',
                              descEn: 'Shares will reflect in your account once purchase orders execute.',
                            ),
                          ] else ...[
                            ...controller.holdings.map((h) => _buildHoldingCard(context, h)),
                          ],

                          SizedBox(height: ECardoTokens.space6.h),

                          // Currency Exposure Chart Preview
                          Container(
                            padding: EdgeInsets.all(ECardoTokens.space4.r),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceCard(context),
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                              border: Border.all(color: ECardoTokens.border(context)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10nPick(context, fa: 'توزیع ارز (FX Exposure)', en: 'Currency Distribution'),
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: ECardoTokens.ink(context),
                                  ),
                                ),
                                SizedBox(height: ECardoTokens.space3.h),
                                if (controller.holdings.isNotEmpty) ...[
                                  _buildCurrencyChip('USD 75%', color: ECardoTokens.brand500(context)),
                                  SizedBox(height: ECardoTokens.space2.h),
                                  _buildCurrencyChip('HKD 20%', color: ECardoTokens.sand600(context)),
                                  SizedBox(height: ECardoTokens.space2.h),
                                  _buildCurrencyChip('GBP 5%', color: ECardoTokens.info(context)),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: ECardoTokens.space4.h),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyChip(String label, {required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space2.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, StockOrderModel ord) {
    final isBuy = ord.side == 'BUY';
    final statusColor = _statusColor(ord.status);
    final statusText = _statusLabel(context, ord.status);
    final settlementDays = ord.settlementDays;
    final estDate = (ord.createdAt ?? DateTime.now()).add(Duration(days: settlementDays));
    final dateStr = '${estDate.year}-${estDate.month.toString().padLeft(2, '0')}-${estDate.day.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.all(ECardoTokens.space3.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: (isBuy ? ECardoTokens.success(context) : ECardoTokens.danger(context)).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                    ),
                    child: Text(
                      ord.side,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: isBuy ? ECardoTokens.success(context) : ECardoTokens.danger(context),
                      ),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space2.w),
                  Text(
                    ord.ticker,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space2.h),
          Text(
            '${l10nPick(context, fa: 'شماره سفارش:', en: 'Order No.:')} ${ord.orderNo}',
            style: TextStyle(
              fontSize: 10.5.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
          SizedBox(height: ECardoTokens.space2.h),
          Divider(height: 16.h, color: ECardoTokens.border(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ord.qty.toInt()} ${l10nPick(context, fa: 'سهم', en: 'shares')} · \$${ord.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.ink(context)),
                    ),
                    if (ord.commissionAmount > 0) ...[
                      Text(
                        'Commission: \$${ord.commissionAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ord.payAmount.toStringAsFixed(ord.currency == 'IRR' ? 0 : 2)} ${ord.currency}',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: ECardoTokens.brand700(context)),
                  ),
                  Text(
                    'T+$settlementDays ($dateStr)',
                    style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w700, color: ECardoTokens.sand600(context)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(BuildContext context, StockHoldingModel h) {
    final isPos = h.unrealizedPnl >= 0;
    final pnlColor = isPos ? ECardoTokens.success(context) : ECardoTokens.danger(context);
    final currentValue = h.currentValue;

    return Container(
      margin: EdgeInsets.only(bottom: ECardoTokens.space2.h),
      padding: EdgeInsets.all(ECardoTokens.space3.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        h.ticker.substring(0, min(3, h.ticker.length)).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.brand700(context),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                        Text(
                          '${h.shares.toInt()} shares · $h.currency @ ${h.exchangeCode}',
                          style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkMuted(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${currentValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${isPos ? '+' : ''}\$${h.unrealizedPnl.toStringAsFixed(2)} (${h.unrealizedPnlPercent.toStringAsFixed(2)}%)',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: pnlColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ECardoTokens.space2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg Cost: \$${h.averageCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context)),
              ),
              Text(
                'Current: \$${h.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Realized P&L: \$${h.realizedPnl.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkMuted(context)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isPos ? ECardoTokens.successBg(context) : ECardoTokens.dangerBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Text(
                  isPos ? 'Profit' : 'Loss',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isPos ? ECardoTokens.success(context) : ECardoTokens.danger(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ECardoTokens.space5.h),
      padding: EdgeInsets.all(ECardoTokens.space6.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48.sp,
            color: ECardoTokens.inkMuted(context),
          ),
          SizedBox(height: ECardoTokens.space3.h),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: ECardoTokens.space2.h),
          Text(
            l10nPick(context, fa: descFa, en: descEn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
          SizedBox(height: ECardoTokens.space4.h),
          CommonButton(
            height: 42.h,
            text: l10nPick(context, fa: 'ثبت سفارش سهام جدید', en: 'Place New Stock Order'),
            backgroundColor: ECardoTokens.brand700(context),
            textColor: ECardoTokens.inkOnBrand,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => const StockOrderScreen());
            },
          ),
        ],
      ),
    );
  }
}
