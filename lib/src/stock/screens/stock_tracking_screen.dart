import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
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
      case 'EXECUTED': return AppColors.success;
      case 'PARTIALLY_FILLED': return AppColors.success;
      case 'PENDING_BROKER': return AppColors.warning;
      case 'REJECTED': return AppColors.error;
      default: return AppColors.softGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              labelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
              indicatorWeight: 3.h,
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
                      isDark: isDark,
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
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
                      itemCount: ordersList.length,
                      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                      itemBuilder: (context, i) {
                        final ord = ordersList[i];
                        return _buildOrderCard(context, ord, isDark);
                      },
                    ),
                  );
                }),

                // Portfolio tab
                Obx(() {
                  final acc = controller.account.value;
                  return RefreshIndicator(
                    onRefresh: controller.loadDashboard,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
                      children: [
                        // Balance summary
                        Container(
                          padding: EdgeInsets.all(AppSpacing.lg.r),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.deepBlack, AppColors.darkGray],
                            ),
                            borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(context, fa: 'ارزش کل دارایی سهام (USD)', en: 'Total Stock Valuation (USD)', ar: 'إجمالي تقييم المحفظة', zh: '股票总资产折合（USD）'),
                                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '\$${acc?.totalPortfolioValueUsd.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              SizedBox(height: AppSpacing.sm.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${l10nPick(context, fa: 'حساب کارگزاری', en: 'Broker Acc')}: ${acc?.accountNumber ?? 'STK-PENDING'}',
                                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightSecondary,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
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

                        SizedBox(height: AppSpacing.lg.h),

                        Text(
                          l10nPick(context, fa: 'سهام تحت تملک', en: 'Holdings', ar: 'الأسهم المملوكة', zh: '持仓列表'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        _buildEmptyState(
                          context,
                          isDark: isDark,
                          icon: Icons.pie_chart_outline_rounded,
                          titleFa: 'سبد دارایی در حال حاضر خالی است',
                          titleEn: 'Your stock portfolio is currently empty',
                          descFa: 'پس از اجرای اولین سفارش خرید، سهام به حساب معاملاتی شما اضافه خواهد شد.',
                          descEn: 'Shares will reflect in your account once purchase orders execute.',
                        ),
                      ],
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

  Widget _buildOrderCard(BuildContext context, StockOrderModel ord, bool isDark) {
    final isBuy = ord.side == 'BUY';
    final statusColor = _statusColor(ord.status);
    final statusText = _statusLabel(context, ord.status);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
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
                  SizedBox(width: AppSpacing.sm.w),
                  Text(
                    ord.ticker,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
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
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Divider(height: 16.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ord.qty} ${l10nPick(context, fa: 'سهم با قیمت', en: 'Shares at', ar: 'سهم بسعر', zh: '股 @')} \$${ord.price}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${ord.totalAmount.toStringAsFixed(ord.currency == 'IRR' ? 0 : 2)} ${ord.currency}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.lg.r),
      padding: EdgeInsets.all(AppSpacing.xxl.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 50.sp,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10nPick(context, fa: descFa, en: descEn),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          CommonButton(
            height: 40,
            text: l10nPick(context, fa: 'ثبت سفارش سهام جدید', en: 'Place New Stock Order', ar: 'تسجيل أمر جديد', zh: '新建股票买卖'),
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            textColor: isDark ? AppColors.deepBlack : AppColors.white,
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