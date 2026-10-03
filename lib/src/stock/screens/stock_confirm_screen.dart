import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
    if (!controller.riskAcknowledged.value) {
      Get.snackbar(
        l10nPick(context, fa: 'Ø®Ø·Ø§', en: 'Error'),
        l10nPick(
          context,
          fa: 'Ù„Ø·ÙØ§Ù‹ Ø§Ø¨ØªØ¯Ø§ Ø¨ÛŒØ§Ù†ÛŒÙ‡ Ù¾Ø°ÛŒØ±Ø´ Ø±ÛŒØ³Ú© Ù…Ø¹Ø§Ù…Ù„Ø§Øª Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ Ø±Ø§ ØªØ£ÛŒÛŒØ¯ ÙØ±Ù…Ø§ÛŒÛŒØ¯.',
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
      // Backend returned failure or error
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.candlestick_chart_rounded, color: AppColors.warning, size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'ÙˆØ¶Ø¹ÛŒØª Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„',
                    en: 'Brokerage Gateway Status',
                    ar: 'Ø­Ø§Ù„Ø© Ø¨ÙˆØ§Ø¨Ø© Ø§Ù„ÙˆØ³Ø§Ø·Ø© Ø§Ù„Ø¯ÙˆÙ„ÙŠØ©',
                    zh: 'å›½é™…åˆ¸å•†ç½‘å…³çŠ¶æ€',
                  ),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              fa: 'Ø§Ø±ØªØ¨Ø§Ø· Ø¨Ø±Ø®Ø· Ø¨Ø§ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ÛŒ Ø¯Ø± Ø­Ø§Ù„ ØªÙˆØ³Ø¹Ù‡ Ùˆ Ø§ØªØµØ§Ù„ Ù†Ù‡Ø§ÛŒÛŒ Ø§Ø³Øª (Ú©Ø¯ Ø§Ù†Ø¯Ù¾ÙˆÛŒÙ†Øª: /stock/orders). Ø³ÙØ§Ø±Ø´ Ø´Ù…Ø§ Ø¯Ø± ØµÙ Ø¢Ø²Ù…Ø§ÛŒØ´ÛŒ Ø¨Ø§ Ù…ÙˆÙÙ‚ÛŒØª Ø§Ø¹ØªØ¨Ø§Ø±Ø³Ù†Ø¬ÛŒ Ø´Ø¯ Ùˆ Ø¨Ø§ Ø±Ø§Ù‡â€ŒØ§Ù†Ø¯Ø§Ø²ÛŒ Ø³Ø±ÙˆØ± Ø¨Ù‡ Ù‡Ø³ØªÙ‡ Ù…Ø¹Ø§Ù…Ù„Ø§Øª Ø§Ø±Ø³Ø§Ù„ Ù…ÛŒâ€ŒØ´ÙˆØ¯.',
              en: 'The direct broker integration is undergoing scheduled upgrade (/stock/orders). Your order parameters have been validated locally.',
              ar: 'Ø§Ù„Ø±Ø¨Ø· Ø§Ù„Ù…Ø¨Ø§Ø´Ø± Ù…Ø¹ Ø´Ø±ÙƒØ© Ø§Ù„ÙˆØ³Ø§Ø·Ø© Ù‚ÙŠØ¯ Ø§Ù„ØªØ±Ù‚ÙŠØ© ÙˆØ§Ù„ØªØ¬Ù‡ÙŠØ².',
              zh: 'å›½é™…åˆ¸å•†æ’®åˆç½‘å…³æ­£åœ¨ç³»ç»Ÿå‡çº§ä¸­ï¼ˆæŽ¥å£ /stock/ordersï¼‰ã€‚æ‚¨çš„å§”æ‰˜æŒ‡ä»¤å·²åœ¨æœ¬åœ°æˆåŠŸå®Œæˆé£ŽæŽ§æ ¡éªŒã€‚',
            ),
            style: TextStyle(fontSize: 12.sp, height: 1.6),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                Get.back();
                Get.off(() => const StockTrackingScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'Ù…Ø´Ø§Ù‡Ø¯Ù‡ Ú©Ø§Ø±ØªØ§Ø¨Ù„ Ø³ÙØ§Ø±Ø´â€ŒÙ‡Ø§',
                  en: 'View Order Portfolio',
                  ar: 'Ø¹Ø±Ø¶ Ø³Ø¬Ù„ Ø§Ù„Ø£ÙˆØ§Ù…Ø±',
                  zh: 'æŸ¥çœ‹å§”æ‰˜ä¸ŽæŒä»“',
                ),
                style: const TextStyle(color: Colors.white),
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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'ØªØ£ÛŒÛŒØ¯ Ù†Ù‡Ø§ÛŒÛŒ Ø³ÙØ§Ø±Ø´ Ø³Ù‡Ø§Ù…',
              en: 'Confirm Stock Order',
              ar: 'ØªØ£ÙƒÙŠØ¯ Ø£Ù…Ø± Ø§Ù„Ø³Ù‡Ù…',
              zh: 'ç¡®è®¤å§”æ‰˜ä¸‹å•',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
            () => CommonButton(
              width: double.infinity,
              isLoading: controller.isOrderLoading.value,
              text: isBuy
                  ? l10nPick(context, fa: 'ØªØ£ÛŒÛŒØ¯ Ùˆ Ø§Ø±Ø³Ø§Ù„ Ø³ÙØ§Ø±Ø´ Ø®Ø±ÛŒØ¯', en: 'Confirm Buy Order', ar: 'ØªØ£ÙƒÙŠØ¯ Ø§Ù„Ø´Ø±Ø§Ø¡', zh: 'ç¡®è®¤ä¹°å…¥å§”æ‰˜')
                  : l10nPick(context, fa: 'ØªØ£ÛŒÛŒØ¯ Ùˆ Ø§Ø±Ø³Ø§Ù„ Ø³ÙØ§Ø±Ø´ ÙØ±ÙˆØ´', en: 'Confirm Sell Order', ar: 'ØªØ£ÙƒÙŠØ¯ Ø§Ù„Ø¨ÙŠØ¹', zh: 'ç¡®è®¤å–å‡ºå§”æ‰˜'),
              backgroundColor: isBuy ? AppColors.success : AppColors.error,
              onPressed: _handleConfirm,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Review Card
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _buildRow(
                    context,
                    labelFa: 'Ù†Ù…Ø§Ø¯ Ùˆ Ø´Ø±Ú©Øª',
                    labelEn: 'Stock / Ticker',
                    value: sym != null ? '${sym.ticker} (${sym.name})' : 'AAPL',
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'Ù†ÙˆØ¹ Ùˆ Ø¬Ù‡Øª Ù…Ø¹Ø§Ù…Ù„Ù‡',
                    labelEn: 'Side & Type',
                    value: '${isBuy ? 'Ø®Ø±ÛŒØ¯ (BUY)' : 'ÙØ±ÙˆØ´ (SELL)'} Â· $orderType',
                    valueColor: isBuy ? AppColors.success : AppColors.error,
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'Ø­Ø¬Ù… Ù…Ø¹Ø§Ù…Ù„Ù‡ (ØªØ¹Ø¯Ø§Ø¯ Ø³Ù‡Ù…)',
                    labelEn: 'Quantity',
                    value: '$qty Ø³Ù‡Ù…',
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'Ù‚ÛŒÙ…Øª Ù¾Ø§ÛŒÙ‡ Ø³Ù‡Ù…',
                    labelEn: 'Base Share Price',
                    value: '\$${sym?.lastPrice ?? 180.0}',
                  ),
                  if (orderType == 'LIMIT' && controller.limitPriceInput.value.isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildRow(
                      context,
                      labelFa: 'Ù‚ÛŒÙ…Øª Ø³Ù‚Ù/Ú©Ù Ù…Ø¹ÛŒÙ† (Limit)',
                      labelEn: 'Limit Price',
                      value: '\$${controller.limitPriceInput.value}',
                      isBold: true,
                    ),
                  ],
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'Ø§Ø±Ø² Ùˆ Ù…Ø¨Ù„Øº ØªØ³ÙˆÛŒÙ‡ Ù†Ù‡Ø§ÛŒÛŒ',
                    labelEn: 'Total Settlement',
                    value: '${totalPay.toStringAsFixed(payCurrency == 'IRR' ? 0 : 2)} $payCurrency',
                    valueColor: AppColors.lightPrimary,
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'Ú©Ø§Ø±Ù…Ø²Ø¯ Ú©Ø§Ø±Ú¯Ø²Ø§Ø±ÛŒ Ùˆ Ø¨ÙˆØ±Ø³',
                    labelEn: 'Brokerage & Clearing Fee',
                    value: '0.15% (Ù…Ø¹Ø§Ù Ø¯Ø± Ù…Ø§Ù‡ Ø§ÙˆÙ„)',
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Risk Disclosure Agreement
            Obx(
              () => Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: controller.riskAcknowledged.value,
                      activeColor: AppColors.lightPrimary,
                      onChanged: (val) {
                        controller.riskAcknowledged.value = val ?? false;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.riskAcknowledged.value = !controller.riskAcknowledged.value;
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            l10nPick(
                              context,
                              fa: 'Ø§ÛŒÙ†Ø¬Ø§Ù†Ø¨ Ø§Ø² Ø±ÛŒØ³Ú© Ù†ÙˆØ³Ø§Ù†Ø§Øª Ø¨Ø§Ø²Ø§Ø± Ø³Ù‡Ø§Ù… Ø¨ÛŒÙ†â€ŒØ§Ù„Ù…Ù„Ù„ØŒ ØªØºÛŒÛŒØ±Ø§Øª Ù†Ø±Ø® Ø¨Ø±Ø§Ø¨Ø±ÛŒ Ø§Ø±Ø² Ùˆ Ø±ÛŒØ³Ú© ØªØ§Ø®ÛŒØ± Ø§Ø­ØªÙ…Ø§Ù„ÛŒ Ø¯Ø± Ø³Ø§Ø¹Ø§Øª Ø¨Ø³ØªÙ‡ Ø¨ÙˆØ¯Ù† Ø¨Ø§Ø²Ø§Ø± Ø¢Ú¯Ø§Ù‡ÛŒ Ú©Ø§Ù…Ù„ Ø¯Ø§Ø´ØªÙ‡ Ùˆ Ù…Ø³Ø¦ÙˆÙ„ÛŒØª ØªØµÙ…ÛŒÙ…â€ŒÚ¯ÛŒØ±ÛŒ Ø³Ø±Ù…Ø§ÛŒÙ‡â€ŒÚ¯Ø°Ø§Ø±ÛŒ Ø±Ø§ Ù…ÛŒâ€ŒÙ¾Ø°ÛŒØ±Ù….',
                              en: 'I understand the volatility of international stock markets, FX conversion risks, and potential after-hours settlement queues, and accept full investment responsibility.',
                              ar: 'Ø£Ù‚Ø± Ø¨Ù…Ø¹Ø±ÙØªÙŠ Ø§Ù„ØªØ§Ù…Ø© Ø¨Ù…Ø®Ø§Ø·Ø± ØªØ¯Ø§ÙˆÙ„ Ø§Ù„Ø£Ø³Ù‡Ù… Ø§Ù„Ø¹Ø§Ù„Ù…ÙŠØ© ÙˆØªÙ‚Ù„Ø¨Ø§Øª Ø£Ø³Ø¹Ø§Ø± Ø§Ù„ØµØ±Ù ÙˆØ£ØªØ­Ù…Ù„ Ù…Ø³Ø¤ÙˆÙ„ÙŠØ© Ù‚Ø±Ø§Ø±ÙŠ.',
                              zh: 'æœ¬äººå®Œå…¨çŸ¥æ™“å›½é™…è‚¡ç¥¨å¸‚åœºæ³¢åŠ¨é£Žé™©ã€æ±‡çŽ‡æŠ˜ç®—é£Žé™©åŠéžäº¤æ˜“æ—¶æ®µæŒ‚å•è§„åˆ™ï¼Œå¹¶è‡ªä¸»æ‰¿æ‹…æŠ•èµ„æŸç›Šã€‚',
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              height: 1.5,
                              color: AppColors.lightTextPrimary,
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
          style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
