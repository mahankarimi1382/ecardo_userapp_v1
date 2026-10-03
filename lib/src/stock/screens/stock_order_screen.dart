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
              fa: 'ÙØ±Ù… Ø«Ø¨Øª Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù… Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„',
              en: 'International Stock Order',
              ar: 'Ø£Ù…Ø± ØªØ¯Ø§ÙˆÙ„ Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠØ©',
              zh: 'å›½é™…è‚¡ç¥¨ä¸‹å•è¡¨å•',
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
              fa: 'Ù¾ÛŒØ´â€ŒÙ†Ù…Ø§ÛŒØ´ Ùˆ Ø¨Ø±Ø±Ø³ÛŒ Ù†Ù‡Ø§ÛŒÛŒ Ù…Ø¹Ø§Ù…Ù„Ù‡',
              en: 'Review & Verify Order',
              ar: 'Ù…Ø¹Ø§ÙŠÙ†Ø© ÙˆÙ…Ø±Ø§Ø¬Ø¹Ø© Ø§Ù„Ø£Ù…Ø±',
              zh: 'è®¢å•é¢„å®¡ä¸Žæ ¸éªŒ',
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
              l10nPick(context, fa: 'Ø¨Ø§Ø²Ø§Ø± Ø¨ÙˆØ±Ø³ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„', en: 'Exchange Market', ar: 'Ø§Ù„Ø³ÙˆÙ‚ Ø§Ù„Ù…Ø§Ù„ÙŠ', zh: 'äº¤æ˜“æ‰€å¸‚åœº'),
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
                        l10nPick(context, fa: 'Ø¨ÙˆØ±Ø³ Ù†Ø²Ø¯Ú© Ùˆ Ù†ÛŒÙˆÛŒÙˆØ±Ú© (NASDAQ / NYSE)', en: 'US Equities (NASDAQ / NYSE)'),
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
              l10nPick(context, fa: 'Ø§Ù†ØªØ®Ø§Ø¨ Ù†Ù…Ø§Ø¯ Ø³Ù‡Ø§Ù…', en: 'Stock Symbol', ar: 'Ø±Ù…Ø² Ø§Ù„Ø³Ù‡Ù…', zh: 'è‚¡ç¥¨æ ‡çš„'),
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
                          Text('Ø¢Ø®Ø±ÛŒÙ† Ù‚ÛŒÙ…Øª: \$182.50', style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text('+1.45%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11.sp)),
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
              l10nPick(context, fa: 'Ø¬Ù‡Øª Ù…Ø¹Ø§Ù…Ù„Ù‡', en: 'Order Side', ar: 'Ù†ÙˆØ¹ Ø§Ù„Ø¹Ù…Ù„ÙŠØ©', zh: 'äº¤æ˜“æ–¹å‘'),
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
                        backgroundColor: isBuy ? AppColors.success : AppColors.lightSurface,
                        foregroundColor: isBuy ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: isBuy ? AppColors.success : AppColors.lightBorder,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'Ø®Ø±ÛŒØ¯ (BUY)', en: 'BUY', ar: 'Ø´Ø±Ø§Ø¡', zh: 'ä¹°å…¥'),
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
                        backgroundColor: !isBuy ? AppColors.error : AppColors.lightSurface,
                        foregroundColor: !isBuy ? Colors.white : Colors.black87,
                        side: BorderSide(
                          color: !isBuy ? AppColors.error : AppColors.lightBorder,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'ÙØ±ÙˆØ´ (SELL)', en: 'SELL', ar: 'Ø¨ÙŠØ¹', zh: 'å–å‡º'),
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
              l10nPick(context, fa: 'ØªØ¹Ø¯Ø§Ø¯ Ø³Ù‡Ù… (Ø­Ø¬Ù…)', en: 'Quantity (Shares)', ar: 'Ø¹Ø¯Ø¯ Ø§Ù„Ø£Ø³Ù‡Ù…', zh: 'å§”æ‰˜è‚¡æ•°'),
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
                  return l10nPick(context, fa: 'ÙˆØ§Ø±Ø¯ Ú©Ø±Ø¯Ù† ØªØ¹Ø¯Ø§Ø¯ Ø³Ù‡Ù… Ø§Ù„Ø²Ø§Ù…ÛŒ Ø§Ø³Øª', en: 'Quantity is required');
                }
                final numVal = double.tryParse(val.trim());
                if (numVal == null || numVal <= 0) {
                  return l10nPick(context, fa: 'ØªØ¹Ø¯Ø§Ø¯ Ø³Ù‡Ù… Ø¨Ø§ÛŒØ¯ Ø¨Ø²Ø±Ú¯ØªØ± Ø§Ø² ØµÙØ± Ø¨Ø§Ø´Ø¯', en: 'Must be greater than 0');
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Order Type: MARKET vs LIMIT
            Text(
              l10nPick(context, fa: 'Ù†ÙˆØ¹ Ø³ÙØ§Ø±Ø´ Ù…Ø¹Ø§Ù…Ù„Ù‡', en: 'Order Type', ar: 'Ù†ÙˆØ¹ Ø§Ù„Ø£Ù…Ø±', zh: 'è®¢å•ç±»åž‹'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final isMarket = controller.orderType.value == 'MARKET';
              return Row(
                children: [
                  ChoiceChip(
                    label: Text(l10nPick(context, fa: 'Ù‚ÛŒÙ…Øª Ù„Ø­Ø¸Ù‡â€ŒØ§ÛŒ Ø¨Ø§Ø²Ø§Ø± (Market)', en: 'Market Order')),
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
                    label: Text(l10nPick(context, fa: 'Ù‚ÛŒÙ…Øª Ù…Ø¹ÛŒÙ† (Limit)', en: 'Limit Order')),
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
                    l10nPick(context, fa: 'Ù‚ÛŒÙ…Øª Ø­Ø¯ Ù…Ø¹Ø§Ù…Ù„Ù‡ (USD / Ø§Ø±Ø² Ù¾Ø§ÛŒÙ‡ Ø¨Ø§Ø²Ø§Ø±)', en: 'Limit Price (Base Currency)'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _limitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ù…Ø«Ø§Ù„: 180.00',
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
                          return l10nPick(context, fa: 'Ù‚ÛŒÙ…Øª Ø­Ø¯ Ø§Ù„Ø²Ø§Ù…ÛŒ Ø§Ø³Øª', en: 'Limit price is required');
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) {
                          return l10nPick(context, fa: 'Ù‚ÛŒÙ…Øª Ø­Ø¯ Ù†Ø§Ù…Ø¹ØªØ¨Ø± Ø§Ø³Øª', en: 'Invalid limit price');
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
              l10nPick(context, fa: 'Ø§Ø±Ø² Ù¾Ø±Ø¯Ø§Ø®Øª Ùˆ ØªØ³ÙˆÛŒÙ‡ Ú©ÛŒÙ Ù¾ÙˆÙ„', en: 'Settlement Currency', ar: 'Ø¹Ù…Ù„Ø© Ø§Ù„ØªØ³ÙˆÙŠØ©', zh: 'ç»“ç®—å¸ç§'),
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
                  DropdownMenuItem(value: 'IRR', child: Text('Ø±ÛŒØ§Ù„ Ø§ÛŒØ±Ø§Ù† (IRR)')),
                  DropdownMenuItem(value: 'USDT', child: Text('ØªØªØ± ÙˆØ§Ù„Øª (USDT)')),
                  DropdownMenuItem(value: 'USD', child: Text('Ø¯Ù„Ø§Ø± (USD)')),
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
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(context, fa: 'Ù…Ø¨Ù„Øº Ú©Ù„ Ø¨Ø±Ø¢ÙˆØ±Ø¯ÛŒ ØªØ³ÙˆÛŒÙ‡:', en: 'Estimated Settlement:'),
                          style: TextStyle(fontSize: 12.sp, color: AppColors.success),
                        ),
                        Text(
                          '${payAmt.toStringAsFixed(curr == 'IRR' ? 0 : 2)} $curr',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.success),
                        ),
                      ],
                    ),
                    if (curr != 'USD') ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, fa: 'Ù†Ø±Ø® ØªØ³ÙˆÛŒÙ‡ Ø§Ø±Ø²ÛŒ:', en: 'FX Conversion Rate:'),
                            style: TextStyle(fontSize: 11.sp, color: AppColors.success),
                          ),
                          Text(
                            '1 USD = $rate $curr',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.success),
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
