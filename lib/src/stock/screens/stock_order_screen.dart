import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_confirm_screen.dart';

/// Form screen for placing buy/sell stock orders in international markets.
class StockOrderScreen extends StatefulWidget {
  const StockOrderScreen({super.key});

  @override
  State<StockOrderScreen> createState() => _StockOrderScreenState();
}

class _StockOrderScreenState extends State<StockOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final StockController controller = Get.isRegistered<StockController>()
      ? Get.find<StockController>()
      : Get.put(StockController());

  final _qtyController = TextEditingController(text: '1.0');
  final _limitPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (controller.selectedSymbol.value == null &&
        controller.selectedMarket.value?.symbols.isNotEmpty == true) {
      controller.selectSymbol(controller.selectedMarket.value!.symbols.first);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  void _onProceed() {
    if (_formKey.currentState?.validate() != true) return;

    final q = double.tryParse(_qtyController.text) ?? 1.0;
    controller.quantity.value = q;
    controller.limitPriceInput.value = _limitPriceController.text.trim();
    controller.updateFxCalculation();

    Get.to(() => const StockOrderConfirmScreen());
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
              fa: 'فرم ثبت سفارش سهام بین‌الملل',
              en: 'International Stock Order',
              ar: 'أمر تداول الأسهم العالمية',
              zh: '国际股票下单表单',
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
              fa: 'پیش‌نمایش و بررسی نهایی معامله',
              en: 'Review & Verify Order',
              ar: 'معاينة ومراجعة الأمر',
              zh: '订单预审与核验',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: _onProceed,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // Market Selector
            Text(
              l10nPick(context, fa: 'بازار بورس بین‌الملل', en: 'Exchange Market', ar: 'السوق المالي', zh: '交易所市场'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final mkts = controller.markets;
              if (mkts.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded, color: AppColors.mainSoftBlue, size: 22.sp),
                      SizedBox(width: 10.w),
                      Text(
                        l10nPick(context, fa: 'بورس نزدک و نیویورک (NASDAQ / NYSE)', en: 'US Equities (NASDAQ / NYSE)'),
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<StockMarketModel>(
                initialValue: controller.selectedMarket.value ?? mkts.first,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: mkts.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text('${m.name} (${m.baseCurrency})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectMarket(val);
                },
              );
            }),

            SizedBox(height: 16.h),

            // Symbol Picker
            Text(
              l10nPick(context, fa: 'انتخاب نماد سهام', en: 'Stock Symbol', ar: 'رمز السهم', zh: '股票标的'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final syms = controller.selectedMarket.value?.symbols ?? [];
              if (syms.isEmpty) {
                // Default fallback representation
                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AAPL (Apple Inc.)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                          Text('آخرین قیمت: \$182.50', style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text('+1.45%', style: TextStyle(color: const Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 11.sp)),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<StockSymbolModel>(
                initialValue: controller.selectedSymbol.value ?? syms.first,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: syms.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text('${s.ticker} - ${s.name} (\$${s.lastPrice})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectSymbol(val);
                },
              );
            }),

            SizedBox(height: 16.h),

            // Side Selector: BUY / SELL
            Text(
              l10nPick(context, fa: 'جهت معامله', en: 'Order Side', ar: 'نوع العملية', zh: '交易方向'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final isBuy = controller.orderSide.value == 'BUY';
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBuy ? const Color(0xFF059669) : Colors.white,
                        foregroundColor: isBuy ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isBuy ? const Color(0xFF059669) : AppColors.lightBorder,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'خرید (BUY)', en: 'BUY', ar: 'شراء', zh: '买入'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                      onPressed: () {
                        controller.orderSide.value = 'BUY';
                        controller.updateFxCalculation();
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isBuy ? const Color(0xFFDC2626) : Colors.white,
                        foregroundColor: !isBuy ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: !isBuy ? const Color(0xFFDC2626) : AppColors.lightBorder,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'فروش (SELL)', en: 'SELL', ar: 'بيع', zh: '卖出'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                      onPressed: () {
                        controller.orderSide.value = 'SELL';
                        controller.updateFxCalculation();
                      },
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 16.h),

            // Quantity
            Text(
              l10nPick(context, fa: 'تعداد سهم (حجم)', en: 'Quantity (Shares)', ar: 'عدد الأسهم', zh: '委托股数'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '1.0',
                prefixIcon: const Icon(Icons.tag_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
              onChanged: (val) {
                final d = double.tryParse(val) ?? 1.0;
                controller.quantity.value = d;
                controller.updateFxCalculation();
              },
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10nPick(context, fa: 'وارد کردن تعداد سهم الزامی است', en: 'Quantity is required');
                }
                final numVal = double.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return l10nPick(context, fa: 'تعداد سهم باید بزرگتر از صفر باشد', en: 'Must be greater than 0');
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Order Type: MARKET vs LIMIT
            Text(
              l10nPick(context, fa: 'نوع سفارش معامله', en: 'Order Type', ar: 'نوع الأمر', zh: '订单类型'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final isMarket = controller.orderType.value == 'MARKET';
              return Row(
                children: [
                  ChoiceChip(
                    label: Text(l10nPick(context, fa: 'قیمت لحظه‌ای بازار (Market)', en: 'Market Order')),
                    selected: isMarket,
                    selectedColor: AppColors.lightPrimary,
                    labelStyle: TextStyle(
                      color: isMarket ? Colors.white : AppColors.lightTextPrimary,
                      fontWeight: isMarket ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) {
                        controller.orderType.value = 'MARKET';
                        controller.updateFxCalculation();
                      }
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text(l10nPick(context, fa: 'قیمت معین (Limit)', en: 'Limit Order')),
                    selected: !isMarket,
                    selectedColor: AppColors.lightPrimary,
                    labelStyle: TextStyle(
                      color: !isMarket ? Colors.white : AppColors.lightTextPrimary,
                      fontWeight: !isMarket ? FontWeight.w800 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) {
                        controller.orderType.value = 'LIMIT';
                        controller.updateFxCalculation();
                      }
                    },
                  ),
                ],
              );
            }),

            // If LIMIT, show limit price input
            Obx(() {
              if (controller.orderType.value != 'LIMIT') return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    l10nPick(context, fa: 'قیمت حد معامله (USD / ارز پایه بازار)', en: 'Limit Price (Base Currency)'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _limitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'مثال: 180.00',
                      prefixIcon: const Icon(Icons.price_change_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                    ),
                    onChanged: (val) {
                      controller.limitPriceInput.value = val;
                      controller.updateFxCalculation();
                    },
                    validator: (val) {
                      if (controller.orderType.value == 'LIMIT') {
                        if (val == null || val.trim().isEmpty) {
                          return l10nPick(context, fa: 'قیمت حد الزامی است', en: 'Limit price is required');
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) {
                          return l10nPick(context, fa: 'قیمت حد نامعتبر است', en: 'Invalid limit price');
                        }
                      }
                      return null;
                    },
                  ),
                ],
              );
            }),

            SizedBox(height: 16.h),

            // Pay Currency
            Text(
              l10nPick(context, fa: 'ارز پرداخت و تسویه کیف پول', en: 'Settlement Currency', ar: 'عملة التسوية', zh: '结算币种'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: controller.payCurrency.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: const [
                  DropdownMenuItem(value: 'IRR', child: Text('ریال ایران (IRR)')),
                  DropdownMenuItem(value: 'USDT', child: Text('تتر والت (USDT)')),
                  DropdownMenuItem(value: 'USD', child: Text('دلار (USD)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller.payCurrency.value = val;
                    controller.updateFxCalculation();
                  }
                },
              );
            }),

            SizedBox(height: 16.h),

            // Live calculation preview
            Obx(() {
              final payAmt = controller.calculatedPayAmount.value;
              final rate = controller.calculatedFxRate.value;
              final curr = controller.payCurrency.value;

              return Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Soft green
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(context, fa: 'مبلغ کل برآوردی تسویه:', en: 'Estimated Settlement:'),
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF166534)),
                        ),
                        Text(
                          '${payAmt.toStringAsFixed(curr == 'IRR' ? 0 : 2)} $curr',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF15803D)),
                        ),
                      ],
                    ),
                    if (curr != 'USD') ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, fa: 'نرخ تسویه ارزی:', en: 'FX Conversion Rate:'),
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF166534)),
                          ),
                          Text(
                            '1 USD = $rate $curr',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
