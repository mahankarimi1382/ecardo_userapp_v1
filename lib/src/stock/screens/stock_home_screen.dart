import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text(l10nPick(context, fa: 'پرسشنامه ارزیابی ریسک', en: 'Risk Assessment Quiz'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(
                context,
                fa: 'بر اساس الزامات امتثال و کارگزاری، ارزیابی سطح ریسک برای تعیین ابزارها و هشدارهای معاملاتی ضروری است.',
                en: 'Mandatory compliance assessment to classify your risk profile.',
              ),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12.h),
            Text('• هدف سرمایه‌گذاری: رشد تدریجی ثروت', style: TextStyle(fontSize: 11.sp)),
            Text('• افق زمانی: بیش از ۳ سال (بلندمدت)', style: TextStyle(fontSize: 11.sp)),
            Text('• تحمل نوسان: متوسط (حفظ دارایی در افت ۲۰٪)', style: TextStyle(fontSize: 11.sp)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              await controller.submitRiskQuiz(answers);
              Get.snackbar(
                l10nPick(context, fa: 'ثبت شد', en: 'Updated'),
                l10nPick(context, fa: 'پروفایل ریسک شما با موفقیت به‌روزرسانی شد.', en: 'Risk profile updated.'),
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text(l10nPick(context, fa: 'تأیید و ثبت پروفایل', en: 'Confirm'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context, StockController controller, StockSymbolModel symbol) {
    controller.selectedSymbol.value = symbol;
    controller.updateFxCalculation();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Obx(() {
          final mkt = controller.selectedMarket.value;
          final isBuy = controller.orderSide.value == 'BUY';

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${symbol.nameFa} (${symbol.ticker})', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
                      Text('${symbol.lastPrice} ${mkt?.baseCurrency ?? "USD"}', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                    ],
                  ),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              SizedBox(height: 16.h),

              // Buy / Sell Selector
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBuy ? Colors.green : Colors.grey.shade100,
                        elevation: isBuy ? 2 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      onPressed: () {
                        controller.orderSide.value = 'BUY';
                        controller.updateFxCalculation();
                      },
                      child: Text(
                        l10nPick(context, fa: 'خرید (Buy)', en: 'Buy'),
                        style: TextStyle(color: isBuy ? Colors.white : Colors.grey.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isBuy ? Colors.redAccent : Colors.grey.shade100,
                        elevation: !isBuy ? 2 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      onPressed: () {
                        controller.orderSide.value = 'SELL';
                        controller.updateFxCalculation();
                      },
                      child: Text(
                        l10nPick(context, fa: 'فروش (Sell)', en: 'Sell'),
                        style: TextStyle(color: !isBuy ? Colors.white : Colors.grey.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Quantity counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10nPick(context, fa: 'تعداد سهام:', en: 'Quantity:'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (controller.quantity.value > 1) {
                            controller.quantity.value -= 1;
                            controller.updateFxCalculation();
                          }
                        },
                      ),
                      Text('${controller.quantity.value.toInt()}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          controller.quantity.value += 1;
                          controller.updateFxCalculation();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Payment Currency Selector
              Text(l10nPick(context, fa: 'ارز پرداخت:', en: 'Payment Currency:'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                children: ['IRR', 'USD', 'USDT', 'EUR'].map((curr) {
                  final isSel = controller.payCurrency.value == curr;
                  return ChoiceChip(
                    label: Text(curr),
                    selected: isSel,
                    selectedColor: AppColors.lightPrimary.withOpacity(0.2),
                    onSelected: (v) {
                      controller.payCurrency.value = curr;
                      controller.updateFxCalculation();
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // Two-line cost calculation
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10nPick(context, fa: 'مبلغ به ارز بازار:', en: 'Market Value:'), style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                        Text('${(symbol.lastPrice * controller.quantity.value).toStringAsFixed(2)} ${mkt?.baseCurrency}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10nPick(context, fa: 'مبلغ نهایی به ارز انتخابی:', en: 'Final Pay Amount:'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        Text(
                          '${controller.calculatedPayAmount.value.toStringAsFixed(0)} ${controller.payCurrency.value}',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppColors.lightPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBuy ? Colors.green : Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: controller.isOrderLoading.value
                      ? null
                      : () async {
                          final ok = await controller.submitOrder(acknowledgedRisk: true);
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              l10nPick(context, fa: 'ثبت شد', en: 'Executed'),
                              l10nPick(context, fa: 'سفارش با موفقیت ثبت و اجرا گردید.', en: 'Order executed successfully.'),
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        },
                  child: controller.isOrderLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isBuy ? l10nPick(context, fa: 'ثبت سفارش خرید', en: 'Place Buy Order') : l10nPick(context, fa: 'ثبت سفارش فروش', en: 'Place Sell Order'),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final StockController controller = Get.put(StockController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10nPick(context, fa: 'معاملات بین‌المللی سهام', en: 'Stock Exchange'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadDashboard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightPrimary));
        }

        final acc = controller.account.value;
        final selectedMkt = controller.selectedMarket.value;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Account & Risk Profile Card
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(context, fa: 'حساب معاملاتی:', en: 'Trading Account:'),
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                            ),
                            Text(
                              acc?.accountNo ?? 'TRD-DEFAULT',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Text(
                            'سطح ریسک: ${acc?.riskProfileLabel ?? "متعادل"}',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.amber.shade300),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(context, fa: 'ارزش پورتفوی:', en: 'Portfolio:'),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade300),
                        ),
                        Text(
                          '${((controller.portfolioData['total_portfolio_value_irr'] ?? 0) as num).toInt()} ریال',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                        ),
                        InkWell(
                          onTap: () => _showRiskQuiz(context, controller),
                          child: Text(
                            l10nPick(context, fa: 'تکمیل مجدد پرسشنامه', en: 'Retake Quiz'),
                            style: TextStyle(fontSize: 11.sp, color: AppColors.lightPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Delayed quote disclaimer (Compliance Requirement)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16.w, color: Colors.amber.shade800),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10nPick(context, fa: 'قیمت‌های نمادها با تأخیر ۱۵ دقیقه طبق قوانین کارگزاری نمایش داده می‌شوند.', en: 'Quotes are delayed by 15 minutes per exchange rules.'),
                        style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 2. Market Tabs
              Text(l10nPick(context, fa: 'بورس‌های بین‌المللی فعال:', en: 'Active Exchanges:'), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              SizedBox(
                height: 40.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.markets.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (ctx, i) {
                    final m = controller.markets[i];
                    final isSel = selectedMkt?.code == m.code;

                    return ChoiceChip(
                      label: Text('${m.nameFa} (${m.code})'),
                      selected: isSel,
                      selectedColor: AppColors.lightPrimary.withOpacity(0.2),
                      onSelected: (v) => controller.selectMarket(m),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // 3. Symbols in selected market
              Text(
                'نمادهای قابل معامله در ${selectedMkt?.nameFa ?? ""}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10.h),

              if (selectedMkt != null)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedMkt.symbols.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (ctx, idx) {
                    final sym = selectedMkt.symbols[idx];

                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(sym.ticker, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900)),
                                    if (sym.highVolatility) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6.r)),
                                        child: Text('پرنوسان', style: TextStyle(fontSize: 9.sp, color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(sym.nameFa, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${sym.lastPrice} ${selectedMkt.baseCurrency}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900)),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightPrimary,
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                onPressed: () => _showOrderSheet(context, controller, sym),
                                child: Text(l10nPick(context, fa: 'معامله', en: 'Trade'), style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}