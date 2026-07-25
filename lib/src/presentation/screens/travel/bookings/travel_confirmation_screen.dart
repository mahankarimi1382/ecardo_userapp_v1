import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'travel_orders_screen.dart';

class TravelConfirmationScreen extends StatelessWidget {
  final TravelOrder order;

  const TravelConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isSuccessful =
        order.status != TravelOrderStatus.failed &&
        order.status != TravelOrderStatus.refunded;
    final title = switch (order.status) {
      TravelOrderStatus.failed => localization.travelBookingFailed,
      TravelOrderStatus.refunded => localization.travelBookingRefunded,
      _ => switch (order.type) {
        TravelProductType.hotel =>
          order.status == TravelOrderStatus.pending
              ? localization.travelHotelBookingSubmitted
              : localization.travelHotelVoucher,
        TravelProductType.flight => localization.travelFlightTicket,
        TravelProductType.esim => localization.travelEsimActivation,
      },
    };
    final description = switch (order.status) {
      TravelOrderStatus.failed => localization.travelBookingFailedDescription,
      TravelOrderStatus.refunded =>
        localization.travelBookingRefundedDescription,
      _ => switch (order.type) {
        TravelProductType.hotel =>
          order.status == TravelOrderStatus.pending
              ? localization.travelHotelPendingConfirmationDescription
              : localization.travelVoucherReady,
        TravelProductType.flight => localization.travelTicketReady,
        TravelProductType.esim => localization.travelEsimReady,
      },
    };
    final statusText = switch (order.status) {
      TravelOrderStatus.pending => localization.travelPendingConfirmation,
      TravelOrderStatus.confirmed => localization.travelConfirmed,
      TravelOrderStatus.active => localization.travelActive,
      TravelOrderStatus.completed => localization.travelCompleted,
      TravelOrderStatus.refunded => localization.travelRefunded,
      TravelOrderStatus.failed => localization.travelFailed,
    };
    return TravelPage(
      title: title,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelViewMyBookings,
            backgroundColor: travelProductColor(order.type),
            textColor: order.type == TravelProductType.esim
                ? TravelTheme.ink
                : Colors.white,
            onPressed: () => Get.off(() => const TravelOrdersScreen()),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          SizedBox(height: 16.h),
          Center(
            child: Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: isSuccessful
                    ? const Color(0xFFEAF7EF)
                    : const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccessful ? Icons.check_rounded : Icons.close_rounded,
                size: 52,
                color: isSuccessful ? TravelTheme.green : TravelTheme.red,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            isSuccessful
                ? localization.travelPurchaseSuccessful
                : statusText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp),
          ),
          SizedBox(height: 26.h),
          TravelCard(
            child: Column(
              children: [
                Icon(
                  travelProductIcon(order.type),
                  size: 56.r,
                  color: travelProductColor(order.type),
                ),
                SizedBox(height: 14.h),
                Text(
                  travelLocalizedKey(localization, order.titleKey),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 18.h),
                const Divider(),
                _ConfirmationRow(
                  label: localization.travelReference,
                  value: order.reference,
                  forceLtr: true,
                ),
                const Divider(),
                _ConfirmationRow(
                  label: localization.travelStatus,
                  value: statusText,
                ),
                const Divider(),
                _ConfirmationRow(
                  label: localization.travelPaidAmount,
                  value: travelMoney(context, order.total),
                  forceLtr: true,
                ),
              ],
            ),
          ),
          if (order.type == TravelProductType.esim) ...[
            SizedBox(height: 16.h),
            TravelCard(
              color: TravelTheme.yellow.withValues(alpha: .13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.travelActivationDetails,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    localization.travelActivationInstructions,
                    style: TextStyle(
                      color: TravelTheme.muted,
                      fontSize: 11.sp,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool forceLtr;

  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w800),
    );
    return Row(
      children: [
        Expanded(child: Text(label)),
        forceLtr
            ? Directionality(
                textDirection: TextDirection.ltr,
                child: valueWidget,
              )
            : valueWidget,
      ],
    );
  }
}
