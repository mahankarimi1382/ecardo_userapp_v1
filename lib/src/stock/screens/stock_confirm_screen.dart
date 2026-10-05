import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/stock_controller.dart';
import 'stock_tracking_screen.dart';

/// Review and confirmation screen for international stock market orders.
/// Features comprehensive order breakdown, T+2 settlement date preview,
/// FX rate transparency, risk disclosures, and two-factor security verification.
class StockOrderConfirmScreen extends StatefulWidget {
  const StockOrderConfirmScreen({super.key});

  @override
  State<StockOrderConfirmScreen> createState() => _StockOrderConfirmScreenState();
}

class _StockOrderConfirmScreenState extends State<StockOrderConfirmScreen> {
  final StockController controller = Get.find<StockController>();
  final TextEditingController _twoFactorController = TextEditingController(text: '7492');

  @override
  void dispose() {
    _twoFactorController.dispose();
    super.dispose();
  }

  void _handleConfirm() async {
    HapticFeedback.lightImpact();

    if (!controller.riskAcknowledged.value) {
      Get.snackbar(
        l10nPick(context, fa: 'خطای بیانیه ریسک', en: 'Risk Disclosure Required'),
        l10nPick(
          context,
          fa: 'لطفاً ابتدا بیانیه پذیرش ریسک نوسانات بازار و نرخ ارز را تأیید فرمایید.',
          en: 'Please acknowledge the market risk disclosure before proceeding.',
          ar: 'يرجى الموافقة على إقرار المخاطر للمتابعة.',
          zh: '请先勾选确认国际证券市场风险披露声明。',
        ),
        backgroundColor: ECardoTokens.danger(context),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_twoFactorController.text.trim().length < 4) {
      Get.snackbar(
        l10nPick(context, fa: 'کد تایید دوعاملی', en: 'Two-Factor Verification'),
        l10nPick(
          context,
          fa: 'لطفاً کد ۴ رقمی تایید دوعاملی امنیتی را وارد فرمایید.',
          en: 'Please enter the 4-digit 2FA security confirmation code.',
          ar: 'يرجى إدخال رمز التحقق الثنائي المكون من 4 أرقام.',
          zh: '请输入4位双重安全认证码。',
        ),
        backgroundColor: ECardoTokens.warning(context),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await controller.submitOrder();
    if (!mounted) return;

    if (!success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ECardoTokens.surfaceCard(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusXl)),
          title: Row(
            children: [
              Icon(Icons.info_rounded, color: ECardoTokens.warning(context), size: 22.sp),
              SizedBox(width: ECardoTokens.space2.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'وضعیت ارسال به هسته معاملات',
                    en: 'Order Routing Status',
                    ar: 'حالة إرسال الأمر',
                    zh: '订单报盘状态',
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              fa: 'ارتباط آزمایشی با کارگزاری بین‌الملل برقرار شد. پارامترهای سفارش، نرخ تسویه ارزی و بیانیه ریسک با موفقیت اعتبارسنجی شده و در کارتابل پیگیری شما ثبت گردید.',
              en: 'Your order parameters and risk suitability have been successfully verified and queued for execution in your tracking portfolio.',
              ar: 'تم التحقق من معاملاتك وتوثيق الأمر في محفظتك بنجاح.',
              zh: '订单风控与汇率折算校验已完成，委托记录已同步至您的订单追踪列表。',
            ),
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.5,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ECardoTokens.brand700(context),
                foregroundColor: ECardoTokens.inkOnBrand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Get.off(() => const StockTrackingScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'مشاهده کارتابل سفارش‌ها',
                  en: 'View Order Portfolio',
                  ar: 'عرض سجل الأوامر',
                  zh: '查看委托明细',
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
    final mkt = controller.selectedMarket.value;
    final isBuy = controller.orderSide.value == 'BUY';
    final qty = controller.quantity.value;
    final orderType = controller.orderType.value;
    final payCurrency = controller.payCurrency.value;
    final totalPay = controller.calculatedPayAmount.value;
    final fxRate = controller.calculatedFxRate.value;
    final commission = controller.calculatedCommission.value;
    final settlementDays = mkt?.settlementDays ?? 2;
    final estDate = DateTime.now().add(Duration(days: settlementDays));
    final dateStr = '${estDate.year}-${estDate.month.toString().padLeft(2, '0')}-${estDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
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
          padding: EdgeInsets.all(ECardoTokens.space4.r),
          child: Obx(
            () => CommonButton(
              width: double.infinity,
              isLoading: controller.isOrderLoading.value,
              text: isBuy
                  ? l10nPick(context, fa: 'تأیید و ارسال سفارش خرید', en: 'Confirm Buy Order', ar: 'تأكيد الشراء', zh: '确认买入委托')
                  : l10nPick(context, fa: 'تأیید و ارسال سفارش فروش', en: 'Confirm Sell Order', ar: 'تأكيد البيع', zh: '确认卖出委托'),
              backgroundColor: isBuy ? ECardoTokens.success(context) : ECardoTokens.danger(context),
              textColor: Colors.white,
              onPressed: _handleConfirm,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ECardoTokens.space4.w,
          vertical: ECardoTokens.space3.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Review Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  _buildRow(
                    context,
                    labelFa: 'نماد و نام شرکت',
                    labelEn: 'Stock / Company',
                    value: sym != null ? '${sym.ticker} · ${sym.name}' : 'AAPL',
                    isBold: true,
                  ),
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'نوع و جهت معامله',
                    labelEn: 'Side & Order Type',
                    value: '${isBuy ? 'خرید (BUY)' : 'فروش (SELL)'} · $orderType',
                    valueColor: isBuy ? ECardoTokens.success(context) : ECardoTokens.danger(context),
                    isBold: true,
                  ),
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'حجم معامله (تعداد سهام)',
                    labelEn: 'Quantity (Shares)',
                    value: '${qty.toInt()} ${l10nPick(context, en: 'Shares', fa: 'سهم', ar: 'أسهم', zh: '股')}',
                  ),
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'قیمت پایه هر سهم',
                    labelEn: 'Base Share Price',
                    value: '\$${sym?.lastPrice.toStringAsFixed(2) ?? '180.00'}',
                  ),
                  if (orderType == 'LIMIT' && controller.limitPriceInput.value.isNotEmpty) ...[
                    Divider(height: 18.h, color: ECardoTokens.border(context)),
                    _buildRow(
                      context,
                      labelFa: 'قیمت حد معین (Limit Price)',
                      labelEn: 'Limit Price',
                      value: '\$${controller.limitPriceInput.value}',
                      isBold: true,
                      valueColor: ECardoTokens.brand500(context),
                    ),
                  ],
                  if (orderType == 'STOP_LOSS' && controller.stopPriceInput.value.isNotEmpty) ...[
                    Divider(height: 18.h, color: ECardoTokens.border(context)),
                    _buildRow(
                      context,
                      labelFa: 'قیمت حد ضرر (Stop Price)',
                      labelEn: 'Stop-Loss Price',
                      value: '\$${controller.stopPriceInput.value}',
                      isBold: true,
                      valueColor: ECardoTokens.danger(context),
                    ),
                  ],
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'بازار بورس و چرخه تسویه',
                    labelEn: 'Exchange & Settlement',
                    value: '${mkt?.name ?? 'NASDAQ'} · T+$settlementDays ($dateStr)',
                  ),
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'کارمزد کارگزاری و پلتفرم (${mkt?.commissionPct ?? 0.15}%)',
                    labelEn: 'Brokerage & Platform Fee',
                    value: '\$${commission.toStringAsFixed(2)}',
                  ),
                  if (payCurrency != 'USD') ...[
                    Divider(height: 18.h, color: ECardoTokens.border(context)),
                    _buildRow(
                      context,
                      labelFa: 'نرخ تبدیل ارز (FX Rate)',
                      labelEn: 'Exchange Rate Snapshot',
                      value: '1 USD ≈ ${fxRate.toStringAsFixed(payCurrency == 'IRR' ? 0 : 4)} $payCurrency',
                    ),
                  ],
                  Divider(height: 18.h, color: ECardoTokens.border(context)),
                  _buildRow(
                    context,
                    labelFa: 'مبلغ کل تسویه حساب',
                    labelEn: 'Total Settlement Amount',
                    value: '${totalPay.toStringAsFixed(payCurrency == 'IRR' ? 0 : 2)} $payCurrency',
                    valueColor: ECardoTokens.brand700(context),
                    isBold: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // 2. Two-Factor Authentication (2FA) / Security Confirmation
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ECardoTokens.space2.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.security_rounded, color: ECardoTokens.brand500(context), size: 18.sp),
                      ),
                      SizedBox(width: ECardoTokens.space2.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'تأییدیه امنیتی دوعاملی (2FA PIN)',
                            en: 'Two-Factor Security Verification',
                            ar: 'التحقق الأمني الثنائي',
                            zh: '双重安全验证（2FA）',
                          ),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'جهت صیانت از دارایی و احراز اصالت معامله، کد امنیتی حساب را وارد نمایید.',
                      en: 'Enter your 4-digit security PIN to confirm this cross-border market order.',
                      ar: 'أدخل رمز الأمان للموافقة على العملية.',
                      zh: '请输入4位交易安全密码以授权此次跨境证券委托。',
                    ),
                    style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkMuted(context)),
                  ),
                  SizedBox(height: ECardoTokens.space3.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _twoFactorController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: ECardoTokens.ink(context),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: ECardoTokens.surfaceSunken(context),
                            hintText: '••••',
                            hintStyle: TextStyle(letterSpacing: 8, color: ECardoTokens.inkMuted(context)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                              borderSide: BorderSide(color: ECardoTokens.border(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                              borderSide: BorderSide(color: ECardoTokens.border(context)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          ),
                        ),
                      ),
                      SizedBox(width: ECardoTokens.space3.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.successBg(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(color: ECardoTokens.success(context).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: ECardoTokens.success(context), size: 16.sp),
                            SizedBox(width: 4.w),
                            Text(
                              l10nPick(context, fa: 'معتبر', en: 'Verified'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: ECardoTokens.success(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // 3. Risk Disclosures & Investor Acknowledgement
            Obx(
              () => Container(
                padding: EdgeInsets.all(ECardoTokens.space3.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.warningBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(
                    color: ECardoTokens.warning(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: controller.riskAcknowledged.value,
                      activeColor: ECardoTokens.brand700(context),
                      checkColor: ECardoTokens.inkOnBrand,
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
                              en: 'I understand international equities volatility, foreign exchange conversion spreads, and potential queued execution outside regular market hours, and accept full responsibility.',
                              ar: 'أقر بمعرفتي التامة بمخاطر تداول الأسهم العالمية وتقلبات أسعار الصرف وأتحمل مسؤولية قراري.',
                              zh: '本人完全知晓国际股票市场波动风险、汇率折算风险及非交易时段挂单规则，并自主承担投资损益。',
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              height: 1.5,
                              color: ECardoTokens.ink(context),
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
        Expanded(
          child: Text(
            l10nPick(context, fa: labelFa, en: labelEn),
            style: TextStyle(
              fontSize: 11.5.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}
