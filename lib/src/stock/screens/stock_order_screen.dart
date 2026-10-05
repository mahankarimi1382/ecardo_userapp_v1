import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import '../models/stock_models.dart';
import 'stock_confirm_screen.dart';

/// Form screen for entering Buy/Sell international stock orders.
/// Supports Market, Limit, and Stop-Loss orders with T+2 settlement,
/// FX rate conversion preview, and commission breakdown.
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

  late final TextEditingController _qtyController;
  late final TextEditingController _limitPriceController;
  late final TextEditingController _stopPriceController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: controller.quantity.value.toStringAsFixed(0));
    _limitPriceController = TextEditingController(text: controller.limitPriceInput.value);
    _stopPriceController = TextEditingController(text: controller.stopPriceInput.value);

    if (controller.selectedSymbol.value == null &&
        controller.selectedMarket.value?.symbols.isNotEmpty == true) {
      controller.selectSymbol(controller.selectedMarket.value!.symbols.first);
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _limitPriceController.dispose();
    _stopPriceController.dispose();
    super.dispose();
  }

  void _onProceed() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() != true) return;

    final q = double.tryParse(_qtyController.text) ?? 1.0;
    controller.quantity.value = q;
    controller.limitPriceInput.value = _limitPriceController.text.trim();
    controller.stopPriceInput.value = _stopPriceController.text.trim();
    controller.updateFxCalculation();

    Get.to(() => const StockOrderConfirmScreen());
  }

  void _adjustQty(double delta) {
    HapticFeedback.selectionClick();
    final current = double.tryParse(_qtyController.text) ?? 1.0;
    final next = (current + delta).clamp(1.0, 10000.0);
    _qtyController.text = next.toStringAsFixed(0);
    controller.quantity.value = next;
    controller.updateFxCalculation();
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
              fa: 'فرم ثبت سفارش سهام بین‌الملل',
              en: 'International Stock Order',
              ar: 'أمر تداول الأسهم العالمية',
              zh: '国际股票下单终端',
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
              fa: 'پیش‌نمایش و ثبت نهایی سفارش',
              en: 'Place Order & Review',
              ar: 'معاينة ومراجعة الأمر',
              zh: '订单预览与校验',
            ),
            backgroundColor: ECardoTokens.brand700(context),
            textColor: ECardoTokens.inkOnBrand,
            onPressed: _onProceed,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: ECardoTokens.space4.w,
            vertical: ECardoTokens.space3.h,
          ),
          children: [
            // 1. Buy / Sell Switcher
            _buildSideSelector(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 2. Exchange Market Selector
            _buildSectionLabel(
              context,
              labelFa: 'بازار بورس بین‌المللی',
              labelEn: 'Exchange Market',
              icon: Icons.language_rounded,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildMarketDropdown(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 3. Stock Symbol Selector
            _buildSectionLabel(
              context,
              labelFa: 'نماد سهام شرکت',
              labelEn: 'Equity Symbol',
              icon: Icons.storefront_rounded,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildSymbolDropdown(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 4. Order Type (Market, Limit, Stop-Loss)
            _buildSectionLabel(
              context,
              labelFa: 'نوع سفارش معاملاتی',
              labelEn: 'Order Execution Type',
              icon: Icons.tune_rounded,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildOrderTypeSelector(context),

            // Conditional price fields
            _buildConditionalPriceFields(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 5. Quantity (Shares) with Quick Steppers
            _buildSectionLabel(
              context,
              labelFa: 'تعداد سهام (حجم سفارش)',
              labelEn: 'Order Quantity (Shares)',
              icon: Icons.tag_rounded,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildQuantityInput(context),

            SizedBox(height: ECardoTokens.space4.h),

            // 6. Settlement & Pay Currency
            _buildSectionLabel(
              context,
              labelFa: 'ارز پرداخت و تسویه کیف پول',
              labelEn: 'Settlement Currency',
              icon: Icons.currency_exchange_rounded,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            _buildCurrencyDropdown(context),

            SizedBox(height: ECardoTokens.space5.h),

            // 7. Live FX & Settlement Estimate Card
            _buildSettlementPreviewCard(context),

            SizedBox(height: ECardoTokens.space5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
    BuildContext context, {
    required String labelFa,
    required String labelEn,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: ECardoTokens.brand500(context)),
        SizedBox(width: ECardoTokens.space2.w),
        Expanded(
          child: Text(
            l10nPick(context, fa: labelFa, en: labelEn),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideSelector(BuildContext context) {
    return Obx(() {
      final isBuy = controller.orderSide.value == 'BUY';
      return Container(
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceSunken(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        padding: EdgeInsets.all(ECardoTokens.space1.r),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.orderSide.value = 'BUY';
                  controller.updateFxCalculation();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isBuy ? ECardoTokens.success(context) : Colors.transparent,
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 16.sp,
                        color: isBuy ? Colors.white : ECardoTokens.inkMuted(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10nPick(context, fa: 'خرید (BUY)', en: 'BUY', ar: 'شراء', zh: '买入'),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isBuy ? Colors.white : ECardoTokens.ink(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.orderSide.value = 'SELL';
                  controller.updateFxCalculation();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: !isBuy ? ECardoTokens.danger(context) : Colors.transparent,
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 16.sp,
                        color: !isBuy ? Colors.white : ECardoTokens.inkMuted(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10nPick(context, fa: 'فروش (SELL)', en: 'SELL', ar: 'بيع', zh: '卖出'),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: !isBuy ? Colors.white : ECardoTokens.ink(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMarketDropdown(BuildContext context) {
    return Obx(() {
      final mkts = controller.markets.toList();
      final selected = controller.selectedMarket.value;
      if (selected != null && !mkts.contains(selected)) {
        mkts.insert(0, selected);
      }
      final safeValue = mkts.contains(selected)
          ? selected
          : (mkts.isNotEmpty ? mkts.first : null);

      return Container(
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space3.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<StockMarketModel>(
            value: safeValue,
            isExpanded: true,
            dropdownColor: ECardoTokens.surfaceCard(context),
            icon: Icon(Icons.arrow_drop_down_rounded, color: ECardoTokens.inkMuted(context)),
            items: mkts.map((m) {
              return DropdownMenuItem<StockMarketModel>(
                value: m,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      child: Text(
                        m.code,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.brand700(context),
                        ),
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space2.w),
                    Expanded(
                      child: Text(
                        '${m.name} (${m.baseCurrency}) · T+${m.settlementDays}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.selectMarket(val);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildSymbolDropdown(BuildContext context) {
    return Obx(() {
      final syms = (controller.selectedMarket.value?.symbols ?? []).toList();
      final currentSelected = controller.selectedSymbol.value;
      if (currentSelected != null && !syms.any((s) => s.ticker == currentSelected.ticker)) {
        syms.insert(0, currentSelected);
      }
      final selectedTicker = currentSelected?.ticker ?? (syms.isNotEmpty ? syms.first.ticker : null);

      return Container(
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space3.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedTicker,
            isExpanded: true,
            dropdownColor: ECardoTokens.surfaceCard(context),
            icon: Icon(Icons.arrow_drop_down_rounded, color: ECardoTokens.inkMuted(context)),
            items: syms.map((s) {
              final isPos = s.dailyChangePct >= 0;
              final changeCol = isPos ? ECardoTokens.success(context) : ECardoTokens.danger(context);
              return DropdownMenuItem<String>(
                value: s.ticker,
                child: Row(
                  children: [
                    Text(
                      s.ticker,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.brand700(context),
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space2.w),
                    Expanded(
                      child: Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                    ),
                    Text(
                      '\$${s.lastPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${isPos ? '+' : ''}${s.dailyChangePct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: changeCol,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (ticker) {
              if (ticker != null) {
                final match = syms.firstWhereOrNull((s) => s.ticker == ticker);
                if (match != null) {
                  controller.selectSymbol(match);
                }
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildOrderTypeSelector(BuildContext context) {
    return Obx(() {
      final currentType = controller.orderType.value;
      final types = [
        {'id': 'MARKET', 'label': l10nPick(context, fa: 'قیمت بازار (Market)', en: 'Market')},
        {'id': 'LIMIT', 'label': l10nPick(context, fa: 'سفارش معین (Limit)', en: 'Limit')},
        {'id': 'STOP_LOSS', 'label': l10nPick(context, fa: 'حد ضرر (Stop-Loss)', en: 'Stop-Loss')},
      ];

      return Row(
        children: types.map((t) {
          final isSelected = currentType == t['id'];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: ChoiceChip(
                label: Text(
                  t['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5.sp,
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
                padding: EdgeInsets.symmetric(vertical: 4.h),
                onSelected: (val) {
                  if (val) {
                    HapticFeedback.selectionClick();
                    controller.orderType.value = t['id']!;
                    controller.updateFxCalculation();
                  }
                },
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildConditionalPriceFields(BuildContext context) {
    return Obx(() {
      final type = controller.orderType.value;
      if (type == 'MARKET') return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ECardoTokens.space3.h),
          if (type == 'LIMIT') ...[
            _buildSectionLabel(
              context,
              labelFa: 'قیمت حد معین (Limit Price)',
              labelEn: 'Limit Price',
              icon: Icons.price_change_outlined,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            TextFormField(
              controller: _limitPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ECardoTokens.surfaceCard(context),
                hintText: controller.selectedSymbol.value?.lastPrice.toStringAsFixed(2) ?? '180.00',
                hintStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
                suffixText: controller.selectedMarket.value?.baseCurrency ?? 'USD',
                suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: ECardoTokens.brand500(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.brand500(context), width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              onChanged: (val) {
                controller.limitPriceInput.value = val;
                controller.updateFxCalculation();
              },
              validator: (val) {
                if (controller.orderType.value == 'LIMIT') {
                  if (val == null || val.trim().isEmpty) {
                    return l10nPick(context, fa: 'قیمت حد معین الزامی است', en: 'Limit price is required');
                  }
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) {
                    return l10nPick(context, fa: 'قیمت حد باید بزرگتر از صفر باشد', en: 'Must be > 0');
                  }
                }
                return null;
              },
            ),
          ],
          if (type == 'STOP_LOSS') ...[
            _buildSectionLabel(
              context,
              labelFa: 'قیمت حد ضرر (Stop Price)',
              labelEn: 'Stop-Loss Price',
              icon: Icons.shield_outlined,
            ),
            SizedBox(height: ECardoTokens.space2.h),
            TextFormField(
              controller: _stopPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: ECardoTokens.surfaceCard(context),
                hintText: controller.selectedSymbol.value != null
                    ? (controller.selectedSymbol.value!.lastPrice * 0.95).toStringAsFixed(2)
                    : '170.00',
                hintStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
                suffixText: controller.selectedMarket.value?.baseCurrency ?? 'USD',
                suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: ECardoTokens.danger(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.brand500(context), width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              onChanged: (val) {
                controller.stopPriceInput.value = val;
                controller.updateFxCalculation();
              },
              validator: (val) {
                if (controller.orderType.value == 'STOP_LOSS') {
                  if (val == null || val.trim().isEmpty) {
                    return l10nPick(context, fa: 'قیمت حد ضرر الزامی است', en: 'Stop price is required');
                  }
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) {
                    return l10nPick(context, fa: 'قیمت حد ضرر باید بزرگتر از صفر باشد', en: 'Must be > 0');
                  }
                }
                return null;
              },
            ),
          ],
        ],
      );
    });
  }

  Widget _buildQuantityInput(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => _adjustQty(-1.0),
              style: IconButton.styleFrom(
                backgroundColor: ECardoTokens.surfaceSunken(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd)),
              ),
              icon: Icon(Icons.remove, color: ECardoTokens.ink(context), size: 18.sp),
            ),
            SizedBox(width: ECardoTokens.space2.w),
            Expanded(
              child: TextFormField(
                controller: _qtyController,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.ink(context),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ECardoTokens.surfaceCard(context),
                  hintText: '1',
                  suffixText: l10nPick(context, fa: 'سهم', en: 'shares'),
                  suffixStyle: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide: BorderSide(color: ECardoTokens.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide: BorderSide(color: ECardoTokens.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide: BorderSide(color: ECardoTokens.brand500(context), width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                ),
                onChanged: (val) {
                  final d = double.tryParse(val) ?? 1.0;
                  controller.quantity.value = d;
                  controller.updateFxCalculation();
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10nPick(context, fa: 'تعداد سهم الزامی است', en: 'Quantity is required');
                  }
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) {
                    return l10nPick(context, fa: 'تعداد باید بزرگتر از صفر باشد', en: 'Must be > 0');
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: ECardoTokens.space2.w),
            IconButton(
              onPressed: () => _adjustQty(1.0),
              style: IconButton.styleFrom(
                backgroundColor: ECardoTokens.surfaceSunken(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd)),
              ),
              icon: Icon(Icons.add, color: ECardoTokens.ink(context), size: 18.sp),
            ),
          ],
        ),
        SizedBox(height: ECardoTokens.space2.h),
        // Quick share presets (10, 50, 100 shares)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [5.0, 10.0, 25.0, 50.0, 100.0].map((preset) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: ActionChip(
                label: Text(
                  '${preset.toInt()}',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.brand700(context),
                  ),
                ),
                backgroundColor: ECardoTokens.brand100(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _qtyController.text = preset.toInt().toString();
                  controller.quantity.value = preset;
                  controller.updateFxCalculation();
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(color: ECardoTokens.border(context)),
        ),
        padding: EdgeInsets.symmetric(horizontal: ECardoTokens.space3.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.payCurrency.value,
            isExpanded: true,
            dropdownColor: ECardoTokens.surfaceCard(context),
            icon: Icon(Icons.arrow_drop_down_rounded, color: ECardoTokens.inkMuted(context)),
            items: [
              DropdownMenuItem(
                value: 'IRR',
                child: Text(
                  l10nPick(context, fa: 'ریال ایران (IRR) - تسویه شتابی', en: 'Iranian Rial (IRR)'),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: ECardoTokens.ink(context)),
                ),
              ),
              DropdownMenuItem(
                value: 'USDT',
                child: Text(
                  l10nPick(context, fa: 'تتر ولت (USDT) - تسویه آنی', en: 'Tether Wallet (USDT)'),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: ECardoTokens.ink(context)),
                ),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Text(
                  l10nPick(context, fa: 'دلار بانکی (USD) - حساب ارزی', en: 'US Dollar (USD)'),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: ECardoTokens.ink(context)),
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                controller.payCurrency.value = val;
                controller.updateFxCalculation();
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildSettlementPreviewCard(BuildContext context) {
    return Obx(() {
      final payAmt = controller.calculatedPayAmount.value;
      final rate = controller.calculatedFxRate.value;
      final curr = controller.payCurrency.value;
      final commission = controller.calculatedCommission.value;
      final mkt = controller.selectedMarket.value;
      final settlementDays = mkt?.settlementDays ?? 2;
      final estDate = DateTime.now().add(Duration(days: settlementDays));
      final dateStr = '${estDate.year}-${estDate.month.toString().padLeft(2, '0')}-${estDate.day.toString().padLeft(2, '0')}';

      return Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
          border: Border.all(color: ECardoTokens.brand500(context).withValues(alpha: 0.3)),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: ECardoTokens.brand500(context), size: 18.sp),
                      SizedBox(width: ECardoTokens.space2.w),
                      Expanded(
                        child: Text(
                          l10nPick(context, fa: 'پیش‌نمایش تسویه و کارمزد:', en: 'Settlement & Execution:'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ECardoTokens.space2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.sand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  ),
                  child: Text(
                    'T+$settlementDays ($dateStr)',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.sand600(context),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 18.h, color: ECardoTokens.border(context)),
            _buildSummaryRow(
              context,
              labelFa: 'کارمزد کارگزاری (${mkt?.commissionPct ?? 0.15}%):',
              labelEn: 'Brokerage Fee (${mkt?.commissionPct ?? 0.15}%):',
              value: '\$${commission.toStringAsFixed(2)}',
            ),
            if (curr != 'USD') ...[
              SizedBox(height: 4.h),
              _buildSummaryRow(
                context,
                labelFa: 'نرخ تبدیل ارز برخط:',
                labelEn: 'Live FX Rate:',
                value: '1 USD ≈ ${rate.toStringAsFixed(curr == 'IRR' ? 0 : 4)} $curr',
              ),
            ],
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(ECardoTokens.space3.r),
              decoration: BoxDecoration(
                color: ECardoTokens.brand100(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10nPick(context, fa: 'مبلغ کل قابل پرداخت:', en: 'Total Settlement Amount:'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.brand700(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${payAmt.toStringAsFixed(curr == 'IRR' ? 0 : 2)} $curr',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.brand700(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String labelFa,
    required String labelEn,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            l10nPick(context, fa: labelFa, en: labelEn),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context)),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: ECardoTokens.ink(context)),
        ),
      ],
    );
  }
}
