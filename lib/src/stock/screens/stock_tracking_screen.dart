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
      case 'PENDING_BROKER': return l10nPick(context, fa: 'در صف کارگزاری', en: 'Pending Broker', ar: 'قيد الإرسال', zh: '券商排队中');
      case 'EXECUTED': return l10nPick(context, fa: 'اجرا شد', en: 'Executed', ar: 'تم التنفيذ', zh: '已成交');
      case 'PARTIALLY_FILLED': return l10nPick(context, fa: 'اجرای جزئی', en: 'Partial Fill', ar: 'تنفيذ جزئي', zh: '部分成交');
      case 'CANCELLED': return l10nPick(context, fa: 'لغوشده', en: 'Cancelled', ar: 'ملغي', zh: '已撤单');
      case 'REJECTED': return l10nPick(context, fa: 'رد شد', en: 'Rejected', ar: 'مرفوض', zh: '已废单');
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'EXECUTED': return const Color(0xFF059669);
      case 'PARTIALLY_FILLED': return const Color(0xFF0D9488);
      case 'PENDING_BROKER': return const Color(0xFFD97706);
      case 'REJECTED': return const Color(0xFFDC2626);
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
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.lightPrimary,
              labelColor: AppColors.lightPrimary,
              unselectedLabelColor: AppColors.lightTextSecondary,
              labelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
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
                            colors: [Color(0xFF161614), Color(0xFF263238)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(context, fa: 'ارزش کل دارایی سهام (USD)', en: 'Total Stock Valuation (USD)'),
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
                                  '${l10nPick(context, fa: 'حساب کارگزاری', en: 'Broker Acc')}: ${acc?.accountNumber ?? 'STK-PENDING'}',
                                  style: TextStyle(fontSize: 11.sp, color: Colors.white60),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488),
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
                        l10nPick(context, fa: 'سهام تحت تملک', en: 'Holdings', ar: 'الأسهم المملوكة', zh: '持仓列表'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8.h),
                      _buildEmptyState(
                        context,
                        icon: Icons.pie_chart_outline_rounded,
                        titleFa: 'سبد دارایی در حال حاضر خالی است',
                        titleEn: 'Your stock portfolio is currently empty',
                        descFa: 'پس از اجرای اولین سفارش خرید، سهام به حساب معاملاتی شما اضافه خواهد شد.',
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
                          ? const Color(0xFF059669).withValues(alpha: 0.12)
                          : const Color(0xFFDC2626).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      ord.side,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: isBuy ? const Color(0xFF059669) : const Color(0xFFDC2626),
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
            '${l10nPick(context, fa: 'شماره سفارش', en: 'Order No.', ar: 'رقم الأمر', zh: '订单号')}: ${ord.orderNo}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ord.qty} ${l10nPick(context, fa: 'سهم با قیمت', en: 'Shares at', ar: 'سهم بسعر', zh: '股 @')} \$${ord.price}',
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
            text: l10nPick(context, fa: 'ثبت سفارش سهام جدید', en: 'Place New Stock Order'),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () => Get.to(() => const StockOrderScreen()),
          ),
        ],
      ),
    );
  }
}
