import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'travel_confirmation_screen.dart';

class TravelCheckoutScreen extends StatefulWidget {
  final TravelProductType type;
  final String productId;
  final String title;
  final TravelMoney total;
  final TravelBookingDetails bookingDetails;

  const TravelCheckoutScreen({
    super.key,
    required this.type,
    required this.productId,
    required this.title,
    required this.total,
    this.bookingDetails = const TravelBookingDetails(),
  });

  @override
  State<TravelCheckoutScreen> createState() => _TravelCheckoutScreenState();
}

class _TravelCheckoutScreenState extends State<TravelCheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    return TravelPage(
      title: localization.travelWalletCheckout,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
            () {
              final hasBalance =
                  controller.mainWalletBalance >= widget.total.amount;
              final canPurchase = controller.canPurchase(widget.type);
              return CommonButton(
                width: double.infinity,
                text: !canPurchase
                    ? localization.travelOfferUnavailable
                    : hasBalance
                    ? localization.travelPayFromWallet
                    : localization.travelAddMoney,
                backgroundColor: !canPurchase
                    ? TravelTheme.muted
                    : hasBalance
                    ? travelProductColor(widget.type)
                    : TravelTheme.green,
                textColor:
                    widget.type == TravelProductType.esim &&
                        hasBalance &&
                        canPurchase
                    ? TravelTheme.ink
                    : Colors.white,
                isLoading: controller.isCheckoutLoading.value,
                onPressed: !canPurchase
                    ? null
                    : hasBalance
                    ? () async {
                        final order = await controller.checkout(
                          type: widget.type,
                          productId: widget.productId,
                          total: widget.total,
                          bookingDetails: widget.bookingDetails,
                        );
                        if (order != null) {
                          Get.off(
                            () => TravelConfirmationScreen(order: order),
                          );
                        } else if (controller.checkoutFailed.value) {
                          Get.snackbar(
                            localization.travelPaymentFailed,
                            localization.travelPaymentFailedDescription,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    : () async {
                        await Get.toNamed(BaseRoute.addMoney);
                        await controller.refreshMainWallet();
                        if (mounted) setState(() {});
                      },
              );
            },
          ),
        ),
      ),
      child: Obx(() {
        final hasBalance =
            controller.mainWalletBalance >= widget.total.amount;
        final canPurchase = controller.canPurchase(widget.type);
        return ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            if (!canPurchase) ...[
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: TravelTheme.red,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        localization.travelOfferUnavailable,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            TravelCard(
              color: travelProductColor(widget.type).withValues(alpha: .10),
              child: Row(
                children: [
                  Container(
                    width: 54.r,
                    height: 54.r,
                    decoration: BoxDecoration(
                      color: travelProductColor(widget.type),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(
                      travelProductIcon(widget.type),
                      color: widget.type == TravelProductType.esim
                          ? TravelTheme.ink
                          : Colors.white,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          localization.travelBackendConfirmedPrice,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelPaymentMethod),
            SizedBox(height: 10.h),
            TravelCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFEAF7EF),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: TravelTheme.green,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.travelMainWallet,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          localization.travelAvailableBalance,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      travelMoney(
                        context,
                        TravelMoney(
                          amount: controller.mainWalletBalance,
                          currency: controller.mainWalletCurrency,
                        ),
                      ),
                      style: TextStyle(
                        color: hasBalance ? TravelTheme.green : TravelTheme.red,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (canPurchase && !hasBalance) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: TravelTheme.red,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        localization.travelInsufficientBalance,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelPriceSummary),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: [
                  _SummaryRow(
                    label: localization.travelSubtotal,
                    value: travelMoney(context, widget.total),
                  ),
                  const Divider(height: 26),
                  _SummaryRow(
                    label: localization.travelWalletPayment,
                    value: travelMoney(context, widget.total),
                  ),
                  const Divider(height: 26),
                  _SummaryRow(
                    label: localization.travelTotal,
                    value: travelMoney(context, widget.total),
                    strong: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              localization.travelCheckoutSafetyNote,
              textAlign: TextAlign.center,
              style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(value, style: style),
        ),
      ],
    );
  }
}
