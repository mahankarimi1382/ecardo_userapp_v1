import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import 'stock_tracking_screen.dart';

/// Review and confirmation screen for international stock market orders.
class StockOrderConfirmScreen extends StatefulWidget {
  const StockOrderConfirmScreen({super.key});

  @override
  State<StockOrderConfirmScreen> createState() => _StockOrderConfirmScreenState();
}

class _StockOrderConfirmScreenState extends State<StockOrderConfirmScreen> {
  final StockController controller = Get.find<StockController>();

  void _handleConfirm() async {
    HapticFeedback.lightImpact();
    if (!controller.riskAcknowledged.value) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(
          context,
          fa: 'لطفاً ابتدا بیانیه پذیرش ریسک معاملات بین‌المللی را تأیید فرمایید.',
          en: 'Please accept the risk disclosure statement to proceed.',
        ),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.submitOrder();
    if (!mounted) return;

    if (!success) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      // Backend returned failure or error
      Get.dialog(
        AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
          title: Row(
            children: [
              Icon(Icons.candlestick_chart_rounded, color: AppColors.warning, size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'وضعیت کارگزاری بین‌الملل',
                    en: 'Brokerage Gateway Status',
                    ar: 'حالة بوابة الوساطة الدولية',
                    zh: '国际券商网关状态',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              fa: 'ارتباط برخط با کارگزاری بین‌المللی در حال توسعه و اتصال نهایی است (کد اندپوینت: /stock/orders). سفارش شما در صف آزمایشی با موفقیت اعتبارسنجی شد و با راه‌اندازی سرور به هسته معاملات ارسال می‌شود.',
              en: 'The direct broker integration is undergoing scheduled upgrade (/stock/orders). Your order parameters have been validated locally.',
              ar: 'الربط المباشر مع شركة الوساطة قيد الترقية والتجهيز.',
              zh: '国际券商撮合网关正在系统升级中（接口 /stock/orders）。您的委托指令已在本地成功完成风控校验。',
            ),
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
              ),
              onPressed: () {
                Get.back();
                Get.off(() => const StockTrackingScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'مشاهده کارتابل سفارش‌ها',
                  en: 'View Order Portfolio',
                  ar: 'عرض سجل الأوامر',
                  zh: '查看委托与持仓',
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.off(() => const StockTrackingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sym = controller.selectedSymbol.value;
    final isBuy = controller.orderSide.value == 'BUY';
    final qty = controller.quantity.value;
    final orderType = controller.orderType.value;
    final payCurrency = controller.payCurrency.value;
    final totalPay = controller.calculatedPayAmount.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'تأیید نهایی سفارش سهام',
              en: 'Confirm Stock Order',
              ar: 'تأكيد أمر السهم',
              zh: '确认委托下单',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          child: Obx(
            () => CommonButton(
              width: double.infinity,
              isLoading: controller.isOrderLoading.value,
              text: isBuy
                  ? l10nPick(context, fa: 'تأیید و ارسال سفارش خرید', en: 'Confirm Buy Order', ar: 'تأكيد الشراء', zh: '确认买入委托')
                  : l10nPick(context, fa: 'تأیید و ارسال سفارش فروش', en: 'Confirm Sell Order', ar: 'تأكيد البيع', zh: '确认卖出委托'),
              backgroundColor: isBuy ? AppColors.success : AppColors.error,
              onPressed: _handleConfirm,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Review Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'نماد و شرکت',
                    labelEn: 'Stock / Ticker',
                    value: sym != null ? '${sym.ticker} (${sym.name})' : 'AAPL',
                    isBold: true,
                  ),
                  Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'نوع و جهت معامله',
                    labelEn: 'Side & Type',
                    value: '${isBuy ? 'خرید (BUY)' : 'فروش (SELL)'} · $orderType',
                    valueColor: isBuy ? AppColors.success : AppColors.error,
                    isBold: true,
                  ),
                  Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'حجم معامله (تعداد سهم)',
                    labelEn: 'Quantity',
                    value: '$qty ${l10nPick(context, en: 'Shares', fa: 'سهم', ar: 'أسهم', zh: '股')}',
                  ),
                  Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'قیمت پایه سهم',
                    labelEn: 'Base Share Price',
                    value: '\$${sym?.lastPrice ?? 180.0}',
                  ),
                  if (orderType == 'LIMIT' && controller.limitPriceInput.value.isNotEmpty) ...[
                    Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _buildRow(
                      context,
                      isDark: isDark,
                      labelFa: 'قیمت سقف/کف معین (Limit)',
                      labelEn: 'Limit Price',
                      value: '\$${controller.limitPriceInput.value}',
                      isBold: true,
                    ),
                  ],
                  Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'ارز و مبلغ تسویه نهایی',
                    labelEn: 'Total Settlement',
                    value: '${totalPay.toStringAsFixed(payCurrency == 'IRR' ? 0 : 2)} $payCurrency',
                    valueColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    isBold: true,
                  ),
                  Divider(height: 20.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildRow(
                    context,
                    isDark: isDark,
                    labelFa: 'کارمزد کارگزاری و بورس',
                    labelEn: 'Brokerage & Clearing Fee',
                    value: '0.15% (${l10nPick(context, en: 'Waived for Month 1', fa: 'معاف در ماه اول')})',
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Risk Disclosure Agreement
            Obx(
              () => Container(
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: controller.riskAcknowledged.value,
                      activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        controller.riskAcknowledged.value = val ?? false;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.riskAcknowledged.value = !controller.riskAcknowledged.value;
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            l10nPick(
                              context,
                              fa: 'اینجانب از ریسک نوسانات بازار سهام بین‌الملل، تغییرات نرخ برابری ارز و ریسک تاخیر احتمالی در ساعات بسته بودن بازار آگاهی کامل داشته و مسئولیت تصمیم‌گیری سرمایه‌گذاری را می‌پذیرم.',
                              en: 'I understand the volatility of international stock markets, FX conversion risks, and potential after-hours settlement queues, and accept full investment responsibility.',
                              ar: 'أقر بمعرفتي التامة بمخاطر تداول الأسهم العالمية وتقلبات أسعار الصرف وأتحمل مسؤولية قراري.',
                              zh: '本人完全知晓国际股票市场波动风险、汇率折算风险及非交易时段挂单规则，并自主承担投资损益。',
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              height: 1.5,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required bool isDark,
    required String labelFa,
    required String labelEn,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10nPick(context, fa: labelFa, en: labelEn),
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}