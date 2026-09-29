import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              en: 'Checkout & Payment',
              fa: 'پرداخت و تسویه لایسنس',
              ar: 'الدفع',
              zh: '结账付款',
            ),
          ),
        ),
      ),
      body: isCreating
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(
                  child: Text(l10nPick(
                    context,
                    en: 'Failed to create order. Please try again.',
                    fa: 'خطا در ثبت سفارش. لطفاً دوباره تلاش کنید.',
                  )),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price lock countdown banner
                      Obx(() {
                        final rem = controller.remainingSeconds.value;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: rem > 60 ? Colors.amber.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: rem > 60 ? Colors.amber.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: rem > 60 ? Colors.amber.shade800 : Colors.red.shade800,
                                size: 22.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  l10nPick(
                                    context,
                                    en: '15-minute price lock active:',
                                    fa: 'قفل ۱۵ دقیقه‌ای قیمت فعال است:',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: rem > 60 ? Colors.amber.shade900 : Colors.red.shade900,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTimer(rem),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: rem > 60 ? Colors.amber.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),

                      // Order Summary Card
                      Container(
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(context, en: 'Order Summary', fa: 'خلاصه سفارش'),
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
                            ),
                            Divider(height: 20.h, color: Colors.grey.shade200),
                            _buildSummaryRow(l10nPick(context, en: 'Order Number', fa: 'شماره سفارش'), order!.orderNo),
                            SizedBox(height: 8.h),
                            _buildSummaryRow(l10nPick(context, en: 'Product', fa: 'محصول'), widget.product.name),
                            SizedBox(height: 8.h),
                            _buildSummaryRow(l10nPick(context, en: 'Edition', fa: 'ویرایش'), widget.edition),
                            SizedBox(height: 8.h),
                            _buildSummaryRow(l10nPick(context, en: 'Duration', fa: 'مدت'), '${widget.durationMonths} Months'),
                            Divider(height: 20.h, color: Colors.grey.shade200),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10nPick(context, en: 'Total Due (USD)', fa: 'مجموع قابل پرداخت'),
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
                                ),
                                Text(
                                  '\$${widget.priceUsd.toStringAsFixed(2)} USD',
                                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppColors.lightPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Payment Route Options
                      Text(
                        l10nPick(context, en: 'Select Payment Method', fa: 'انتخاب روش پرداخت'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
                      ),
                      SizedBox(height: 12.h),

                      _buildRouteOption(
                        id: 'WALLET',
                        icon: Icons.account_balance_wallet_outlined,
                        title: l10nPick(context, en: 'Pay from Wallet (Instant)', fa: 'پرداخت از کیف پول داخلی (تحویل آنی)'),
                        subtitle: l10nPick(context, en: 'Deduct from internal USD/Crypto wallet with zero network fees.', fa: 'کسر مستقیم از موجودی کیف‌پول بدون کارمزد شبکه.'),
                      ),
                      SizedBox(height: 10.h),

                      _buildRouteOption(
                        id: 'ONCHAIN',
                        icon: Icons.currency_bitcoin_rounded,
                        title: l10nPick(context, en: 'Pay with Crypto (On-Chain)', fa: 'پرداخت با رمزارز (انتقال آن‌چین)'),
                        subtitle: l10nPick(context, en: 'Transfer USDT TRC20/ERC20 from an external exchange or wallet.', fa: 'انتقال رمزارز تتر از صرافی یا کیف‌پول خارجی.'),
                      ),
                      SizedBox(height: 10.h),

                      _buildRouteOption(
                        id: 'FIAT',
                        icon: Icons.credit_card_rounded,
                        title: l10nPick(context, en: 'Pay with Card (USD)', fa: 'پرداخت دلاری با کارت'),
                        subtitle: l10nPick(context, en: 'International Visa/Mastercard payment gateway with 3DS.', fa: 'درگاه بین‌المللی ویزا و مسترکارت دلاری.'),
                      ),

                      // On-Chain Crypto Deposit Box
                      if (selectedRoute == 'ONCHAIN' && order?.cryptoWalletAddress != null) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(context, en: 'USDT TRC-20 Deposit Address:', fa: 'آدرس واریز تتر TRC-20:'),
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order!.cryptoWalletAddress!,
                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace', color: Colors.blue.shade900),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: order!.cryptoWalletAddress!));
                                      ToastHelper().showSuccessToast(l10nPick(context, en: 'Address copied!', fa: 'آدرس کپی شد!'));
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                l10nPick(context, en: 'Awaiting 2 network confirmations (60 min deadline)', fa: 'نیازمند ۲ تأیید شبکه بلاکچین (مهلت ۶۰ دقیقه)'),
                                style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 30.h),

                      // Submit Payment Button
                      Obx(() => CommonButton(
                            width: double.infinity,
                            isLoading: controller.isPaying.value,
                            text: selectedRoute == 'WALLET'
                                ? l10nPick(context, en: 'Pay from Wallet', fa: 'پرداخت از کیف پول', ar: 'الدفع من المحفظة', zh: '从钱包付款')
                                : selectedRoute == 'ONCHAIN'
                                    ? l10nPick(context, en: 'Generate On-Chain Address', fa: 'تولید آدرس آن‌چین', ar: 'توليد العنوان', zh: '生成链上地址')
                                    : l10nPick(context, en: 'Pay with Card (USD)', fa: 'پرداخت دلاری با کارت', ar: 'الدفع بالبطاقة', zh: '用卡支付'),
                            onPressed: _handlePaymentAction,
                          )),
                      SizedBox(height: 12.h),

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
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
      ],
    );
  }

  Widget _buildRouteOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedRoute == id;
    return InkWell(
      onTap: () => setState(() => selectedRoute = id),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightPrimary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.lightPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, height: 1.3),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: selectedRoute,
              activeColor: AppColors.lightPrimary,
              onChanged: (val) {
                if (val != null) setState(() => selectedRoute = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaymentAction() async {
    if (order == null) return;

    if (selectedRoute == 'WALLET') {
      final success = await controller.payWallet(order!.id);
      if (success && controller.currentOrder.value != null) {
        Get.off(() => LicenseDeliveryScreen(order: controller.currentOrder.value!));
      }
    } else if (selectedRoute == 'ONCHAIN') {
      final success = await controller.payCrypto(order!.id, network: 'TRC20');
      if (success) {
        setState(() {
          order = controller.currentOrder.value;
        });
      }
    } else {
      ToastHelper().showSuccessToast(l10nPick(
        context,
        en: 'Redirecting to secure card payment gateway...',
        fa: 'در حال اتصال به درگاه کارت دلاری...',
      ));
    }
  }
}
