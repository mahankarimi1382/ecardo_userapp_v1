import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_order_screen.dart';

/// Screen displaying international stock orders, execution states, and portfolio holdings.
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
      case 'PENDING_BROKER': return l10nPick(context, fa: 'Ø¯Ø± ØµÙ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ', en: 'Pending Broker', ar: 'Ù‚ÙŠØ¯ Ø§Ù„Ø¥Ø±Ø³Ø§Ù„', zh: 'åˆ¸å•†æŽ’é˜Ÿä¸­');
      case 'EXECUTED': return l10nPick(context, fa: 'Ø§Ø¬Ø±Ø§ Ø´Ø¯', en: 'Executed', ar: 'ØªÙ… Ø§Ù„ØªÙ†ÙÙŠØ°', zh: 'å·²æˆäº¤');
      case 'PARTIALLY_FILLED': return l10nPick(context, fa: 'Ø§Ø¬Ø±Ø§ÛŒ Ø¬Ø²Ø¦ÛŒ', en: 'Partial Fill', ar: 'ØªÙ†ÙÙŠØ° Ø¬Ø²Ø¦ÙŠ', zh: 'éƒ¨åˆ†æˆäº¤');
      case 'CANCELLED': return l10nPick(context, fa: 'Ù„ØºÙˆØ´Ø¯Ù‡', en: 'Cancelled', ar: 'Ù…Ù„ØºÙŠ', zh: 'å·²æ’¤å•');
      case 'REJECTED': return l10nPick(context, fa: 'Ø±Ø¯ Ø´Ø¯', en: 'Rejected', ar: 'Ù…Ø±ÙÙˆØ¶', zh: 'å·²åºŸå•');
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'EXECUTED': return AppColors.success;
      case 'PARTIALLY_FILLED': return AppColors.success;
      case 'PENDING_BROKER': return AppColors.warning;
      case 'REJECTED': return AppColors.error;
      default: return Colors.grey;
    }
  }

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
              fa: 'Ù¾ÛŒÚ¯ÛŒØ±ÛŒ Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ Ùˆ Ø¯Ø§Ø±Ø§ÛŒÛŒâ€ŒÙ‡Ø§ÛŒ Ø³Ù‡Ø§Ù…',
              en: 'Stock Orders & Portfolio',
              ar: 'Ù…ØªØ§Ø¨Ø¹Ø© Ø£ÙˆØ§Ù…Ø± ÙˆÙ…Ø­ÙØ¸Ø© Ø§Ù„Ø£Ø³Ù‡Ù…',
              zh: 'è‚¡ç¥¨å§”æ‰˜ä¸ŽæŒä»“ç®¡ç†',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner
          FinancialServiceUnavailableBanner(
            serviceNameFa: 'Ø¨ÙˆØ±Ø³ Ùˆ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„',
            serviceNameEn: 'Stock Brokerage',
            serviceNameAr: 'Ø§Ù„Ø£Ø³Ù‡Ù… ÙˆØ§Ù„ÙˆØ³Ø§Ø·Ø© Ø§Ù„Ø¯ÙˆÙ„ÙŠØ©',
            serviceNameZh: 'å›½é™…è¯åˆ¸ç»çºª',
            isCompact: true,
            onRetry: controller.loadDashboard,
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.lightPrimary,
              labelColor: AppColors.lightPrimary,
              unselectedLabelColor: AppColors.lightTextSecondary,
              labelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
              tabs: [
                Tab(text: l10nPick(context, fa: 'Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ù…Ù†', en: 'My Orders', ar: 'Ø£ÙˆØ§Ù…Ø±ÙŠ', zh: 'å§”æ‰˜æ˜Žç»†')),
                Tab(text: l10nPick(context, fa: 'Ø³Ø¨Ø¯ Ø¯Ø§Ø±Ø§ÛŒÛŒ (Ù¾ÙˆØ±ØªÙÙˆÛŒ)', en: 'Portfolio', ar: 'Ø§Ù„Ù…Ø­ÙØ¸Ø©', zh: 'æŒä»“æ¦‚è§ˆ')),
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
                      titleFa: 'Ù‡ÛŒÚ† Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù…ÛŒ Ø«Ø¨Øª Ù†Ø´Ø¯Ù‡ Ø§Ø³Øª',
                      titleEn: 'No stock orders recorded',
                      descFa: 'Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§ÛŒ Ø®Ø±ÛŒØ¯ Ùˆ ÙØ±ÙˆØ´ Ø³Ù‡Ø§Ù… Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ Ø´Ù…Ø§ Ù¾Ø³ Ø§Ø² Ø«Ø¨Øª Ø¯Ø± Ø§ÛŒÙ† Ø¨Ø®Ø´ Ù¾ÛŒÚ¯ÛŒØ±ÛŒ Ù…ÛŒâ€ŒØ´ÙˆÙ†Ø¯.',
                      descEn: 'Your buy and sell stock orders will appear here once placed.',
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: ordersList.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, i) {
                      final ord = ordersList[i];
                      return _buildOrderCard(context, ord);
                    },
                  );
                }),

                // Portfolio tab
                Obx(() {
                  final acc = controller.account.value;
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    children: [
                      // Balance summary
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.deepBlack, AppColors.darkGray],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(context, fa: 'Ø§Ø±Ø²Ø´ Ú©Ù„ Ø¯Ø§Ø±Ø§ÛŒÛŒ Ø³Ù‡Ø§Ù… (USD)', en: 'Total Stock Valuation (USD)'),
                              style: TextStyle(fontSize: 11.5.sp, color: Colors.white70),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '\$${acc?.totalPortfolioValueUsd.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10nPick(context, fa: 'Ø­Ø³Ø§Ø¨ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ', en: 'Broker Acc')}: ${acc?.accountNumber ?? 'STK-PENDING'}',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.white60),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightSecondary,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    acc?.riskTier ?? 'RISK-MID',
                                    style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        l10nPick(context, fa: 'Ø³Ù‡Ø§Ù… ØªØ­Øª ØªÙ…Ù„Ú©', en: 'Holdings', ar: 'Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ù…Ù…Ù„ÙˆÙƒØ©', zh: 'æŒä»“åˆ—è¡¨'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8.h),
                      _buildEmptyState(
                        context,
                        icon: Icons.pie_chart_outline_rounded,
                        titleFa: 'Ø³Ø¨Ø¯ Ø¯Ø§Ø±Ø§ÛŒÛŒ Ø¯Ø± Ø­Ø§Ù„ Ø­Ø§Ø¶Ø± Ø®Ø§Ù„ÛŒ Ø§Ø³Øª',
                        titleEn: 'Your stock portfolio is currently empty',
                        descFa: 'Ù¾Ø³ Ø§Ø² Ø§Ø¬Ø±Ø§ÛŒ Ø§ÙˆÙ„ÛŒÙ† Ø³ÙØ§Ø±Ø´ Ø®Ø±ÛŒØ¯ØŒ Ø³Ù‡Ø§Ù… Ø¨Ù‡ Ø­Ø³Ø§Ø¨ Ù…Ø¹Ø§Ù…Ù„Ø§ØªÛŒ Ø´Ù…Ø§ Ø§Ø¶Ø§ÙÙ‡ Ø®ÙˆØ§Ù‡Ø¯ Ø´Ø¯.',
                        descEn: 'Shares will reflect in your account once purchase orders execute.',
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, StockOrderModel ord) {
    final isBuy = ord.side == 'BUY';
    final statusColor = _statusColor(ord.status);
    final statusText = _statusLabel(context, ord.status);

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isBuy
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      ord.side,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: isBuy ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    ord.ticker,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${l10nPick(context, fa: 'Ø´Ù…Ø§Ø±Ù‡ Ø³ÙØ§Ø±Ø´', en: 'Order No.', ar: 'Ø±Ù‚Ù… Ø§Ù„Ø£Ù…Ø±', zh: 'è®¢å•å·')}: ${ord.orderNo}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ord.qty} ${l10nPick(context, fa: 'Ø³Ù‡Ù… Ø¨Ø§ Ù‚ÛŒÙ…Øª', en: 'Shares at', ar: 'Ø³Ù‡Ù… Ø¨Ø³Ø¹Ø±', zh: 'è‚¡ @')} \$${ord.price}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                '${ord.totalAmount.toStringAsFixed(ord.currency == 'IRR' ? 0 : 2)} ${ord.currency}',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 50.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            l10nPick(context, fa: descFa, en: descEn),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
          ),
          SizedBox(height: 18.h),
          CommonButton(
            height: 40,
            text: l10nPick(context, fa: 'Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù… Ø¬Ø¯ÛŒØ¯', en: 'Place New Stock Order'),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () => Get.to(() => const StockOrderScreen()),
          ),
        ],
      ),
    );
  }
}
