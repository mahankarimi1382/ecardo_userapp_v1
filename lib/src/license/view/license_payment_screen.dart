import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';
import 'license_delivery_screen.dart';

class LicensePaymentScreen extends StatefulWidget {
  final LicenseProductItem product;
  final String edition;
  final int durationMonths;
  final double priceUsd;

  const LicensePaymentScreen({
    super.key,
    required this.product,
    required this.edition,
    required this.durationMonths,
    required this.priceUsd,
  });

  @override
  State<LicensePaymentScreen> createState() => _LicensePaymentScreenState();
}

class _LicensePaymentScreenState extends State<LicensePaymentScreen> {
  final LicenseController controller = Get.find<LicenseController>();

  String selectedRoute = 'WALLET'; // WALLET, ONCHAIN, FIAT
  bool isCreating = true;
  LicenseOrderItem? order;

  @override
  void initState() {
    super.initState();
    _initOrder();
  }

  Future<void> _initOrder() async {
    setState(() => isCreating = true);
    final ord = await controller.createOrder(
      productId: widget.product.id,
      edition: widget.edition,
      durationMonths: widget.durationMonths,
      payRoute: 'CRYPTO_WALLET',
      payCurrency: 'USD',
    );
    if (mounted) {
      setState(() {
        order = ord;
        isCreating = false;
      });
    }
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
              en: 'Checkout & Payment',
              fa: 'پرداخت و تسویه لایسنس',
              ar: 'الدفع والتسوية',
              zh: '结账付款',
            ),
          ),
        ),
      ),
      body: isCreating
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Failed to create order. Please try again.',
                      fa: 'خطا در ثبت سفارش. لطفاً دوباره تلاش کنید.',
                      ar: 'فشل في إنشاء الطلب.',
                      zh: '创建订单失败，请重试。',
                    ),
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.lg.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price lock countdown banner
                      Obx(() {
                        final rem = controller.remainingSeconds.value;
                        final isUrgent = rem <= 60;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? AppColors.error.withValues(alpha: 0.12)
                                : AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                            border: Border.all(
                              color: isUrgent ? AppColors.error : AppColors.warning,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: isUrgent ? AppColors.error : AppColors.warning,
                                size: AppSpacing.iconSm.sp,
                              ),
                              SizedBox(width: AppSpacing.sm.w),
                              Expanded(
                                child: Text(
                                  l10nPick(
                                    context,
                                    en: '15-minute price lock active:',
                                    fa: 'قفل ۱۵ دقیقه‌ای قیمت فعال است:',
                                    ar: 'تأكيد السعر لمدة ١٥ دقيقة:',
                                    zh: '15分钟锁价保护生效中：',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isUrgent ? AppColors.error : AppColors.warning,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTimer(rem),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: isUrgent ? AppColors.error : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: AppSpacing.lg.h),

                      // Order Summary Card
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(context, en: 'Order Summary', fa: 'خلاصه سفارش', ar: 'ملخص الطلب', zh: '订单摘要'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Divider(
                              height: 20.h,
                              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            ),
                            _buildSummaryRow(l10nPick(context, en: 'Order Number', fa: 'شماره سفارش', ar: 'رقم الطلب', zh: '订单号'), order!.orderNo, isDark),
                            SizedBox(height: AppSpacing.sm.h),
                            _buildSummaryRow(l10nPick(context, en: 'Product', fa: 'محصول', ar: 'المنتج', zh: '商品'), widget.product.name, isDark),
                            SizedBox(height: AppSpacing.sm.h),
                            _buildSummaryRow(l10nPick(context, en: 'Edition', fa: 'ویرایش', ar: 'الإصدار', zh: '版本'), widget.edition, isDark),
                            SizedBox(height: AppSpacing.sm.h),
                            _buildSummaryRow(l10nPick(context, en: 'Duration', fa: 'مدت', ar: 'المدة', zh: '周期'), '${widget.durationMonths} ${l10nPick(context, en: 'Months', fa: 'ماهه', ar: 'شهر', zh: '个月')}', isDark),
                            Divider(
                              height: 20.h,
                              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10nPick(context, en: 'Total Due (USD)', fa: 'مجموع قابل پرداخت', ar: 'الإجمالي المستحق', zh: '应付总额'),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '\$${widget.priceUsd.toStringAsFixed(2)} USD',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),

                      // Payment Route Options
                      Text(
                        l10nPick(context, en: 'Select Payment Method', fa: 'انتخاب روش پرداخت', ar: 'اختر طريقة الدفع', zh: '选择支付方式'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      RadioGroup<String>(
                        groupValue: selectedRoute,
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRoute = val);
                        },
                        child: Column(
                          children: [
                            _buildRouteOption(
                              id: 'WALLET',
                              isDark: isDark,
                              icon: Icons.account_balance_wallet_outlined,
                              title: l10nPick(context, en: 'Pay from Wallet (Instant)', fa: 'پرداخت از کیف پول داخلی (تحویل آنی)', ar: 'الدفع من المحفظة', zh: '钱包余额秒付'),
                              subtitle: l10nPick(context, en: 'Deduct from internal USD/Crypto wallet with zero network fees.', fa: 'کسر مستقیم از موجودی کیف‌پول بدون کارمزد شبکه.', ar: 'خصم مباشر دون رسوم شبكة.', zh: '从eCardo钱包直接结算，零链上转账费。'),
                            ),
                            SizedBox(height: AppSpacing.sm.h),

                            _buildRouteOption(
                              id: 'ONCHAIN',
                              isDark: isDark,
                              icon: Icons.currency_bitcoin_rounded,
                              title: l10nPick(context, en: 'Pay with Crypto (On-Chain)', fa: 'پرداخت با رمزارز (انتقال آن‌چین)', ar: 'دفع بالعملات الرقمية', zh: '链上加密货币转账'),
                              subtitle: l10nPick(context, en: 'Transfer USDT TRC20/ERC20 from an external exchange or wallet.', fa: 'انتقال رمزارز تتر از صرافی یا کیف‌پول خارجی.', ar: 'تحويل USDT من محفظة خارجية.', zh: '支持从外部交易所或钱包充值USDT TRC20。'),
                            ),
                            SizedBox(height: AppSpacing.sm.h),

                            _buildRouteOption(
                              id: 'FIAT',
                              isDark: isDark,
                              icon: Icons.credit_card_rounded,
                              title: l10nPick(context, en: 'Pay with Card (USD)', fa: 'پرداخت دلاری با کارت', ar: 'الدفع بالبطاقة', zh: '国际信用卡支付'),
                              subtitle: l10nPick(context, en: 'International Visa/Mastercard payment gateway with 3DS.', fa: 'درگاه بین‌المللی ویزا و مسترکارت دلاری.', ar: 'بوابة فيزا وماستركارد الدولية.', zh: '支持Visa/万事达3DS安全认证支付。'),
                            ),
                          ],
                        ),
                      ),

                      // On-Chain Crypto Deposit Box
                      if (selectedRoute == 'ONCHAIN' && order?.cryptoWalletAddress != null) ...[
                        SizedBox(height: AppSpacing.lg.h),
                        Container(
                          padding: EdgeInsets.all(AppSpacing.lg.r),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkPrimaryContainer : AppColors.lightSecondaryContainer),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(context, en: 'USDT TRC-20 Deposit Address:', fa: 'آدرس واریز تتر TRC-20:', ar: 'عنوان إيداع USDT:', zh: 'USDT TRC-20充值地址：'),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order!.cryptoWalletAddress!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: 'monospace',
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.copy,
                                      size: AppSpacing.iconSm.sp,
                                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(ClipboardData(text: order!.cryptoWalletAddress!));
                                      ToastHelper().showSuccessToast(l10nPick(context, en: 'Address copied!', fa: 'آدرس کپی شد!'));
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                l10nPick(context, en: 'Awaiting 2 network confirmations (60 min deadline)', fa: 'نیازمند ۲ تأیید شبکه بلاکچین (مهلت ۶۰ دقیقه)', ar: 'في انتظار تأكيدين من الشبكة', zh: '等待2个网络区块确认（有效期60分钟）'),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: AppSpacing.xxl.h),

                      // Submit Payment Button
                      Obx(() => CommonButton(
                            width: double.infinity,
                            isLoading: controller.isPaying.value,
                            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            textColor: isDark ? AppColors.deepBlack : AppColors.white,
                            text: selectedRoute == 'WALLET'
                                ? l10nPick(context, en: 'Pay from Wallet', fa: 'پرداخت از کیف پول', ar: 'الدفع من المحفظة', zh: '从钱包付款')
                                : selectedRoute == 'ONCHAIN'
                                    ? l10nPick(context, en: 'Generate On-Chain Address', fa: 'تولید آدرس آن‌چین', ar: 'توليد العنوان', zh: '生成链上地址')
                                    : l10nPick(context, en: 'Pay with Card (USD)', fa: 'پرداخت دلاری با کارت', ar: 'الدفع بالبطاقة', zh: '用卡支付'),
                            onPressed: _handlePaymentAction,
                          )),
                      SizedBox(height: AppSpacing.md.h),

                      // Cancel Order Button
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            if (order != null) {
                              await controller.cancelOrder(order!.id);
                              Get.back();
                            }
                          },
                          child: Text(
                            l10nPick(
                              context,
                              en: 'Cancel Order',
                              fa: 'لغو سفارش',
                              ar: 'إلغاء الطلب',
                              zh: '取消订单',
                            ),
                            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOption({
    required String id,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedRoute == id;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selectedRoute = id);
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.deepBlack : AppColors.white)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: AppSpacing.iconMd.sp,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaymentAction() async {
    if (order == null) return;
    HapticFeedback.lightImpact();

    if (selectedRoute == 'WALLET') {
      final success = await controller.payWallet(order!.id);
      if (success && controller.currentOrder.value != null) {
        Get.off(() => LicenseDeliveryScreen(order: controller.currentOrder.value!));
      }
    } else if (selectedRoute == 'ONCHAIN') {
      final success = await controller.payCrypto(order!.id, network: 'TRC20');
      if (mounted && success) {
        setState(() {
          order = controller.currentOrder.value;
        });
      }
    } else {
      if (!mounted) return;
      ToastHelper().showSuccessToast(l10nPick(
        context,
        en: 'Redirecting to secure card payment gateway...',
        fa: 'در حال اتصال به درگاه کارت دلاری...',
      ));
    }
  }
}