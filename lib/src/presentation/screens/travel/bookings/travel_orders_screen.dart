import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'travel_confirmation_screen.dart';

class TravelOrdersScreen extends StatelessWidget {
  final TravelProductType? initialType;

  const TravelOrdersScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final title = switch (initialType) {
      TravelProductType.hotel => localization.travelMyHotels,
      TravelProductType.flight => localization.travelMyFlights,
      TravelProductType.esim => localization.travelMyEsims,
      null => localization.travelMyBookings,
    };
    return TravelPage(
      title: title,
      child: Obx(() {
        final visibleOrders = initialType == null
            ? controller.orders.toList()
            : controller.orders
                  .where((order) => order.type == initialType)
                  .toList();
        return visibleOrders.isEmpty
            ? TravelEmptyState(
                message: switch (initialType) {
                  TravelProductType.hotel => localization.travelNoHotels,
                  TravelProductType.flight => localization.travelNoFlights,
                  TravelProductType.esim => localization.travelNoEsims,
                  null => localization.travelNoBookings,
                },
              )
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: visibleOrders.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final order = visibleOrders[index];
                  final canDownloadVoucher =
                      order.type != TravelProductType.esim &&
                      order.status != TravelOrderStatus.failed &&
                      order.status != TravelOrderStatus.refunded;
                  return TravelCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Get.to(
                            () => TravelConfirmationScreen(order: order),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54.r,
                                height: 54.r,
                                decoration: BoxDecoration(
                                  color: travelProductColor(
                                    order.type,
                                  ).withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(18.r),
                                ),
                                child: Icon(
                                  travelProductIcon(order.type),
                                  color: travelProductColor(order.type),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      travelLocalizedKey(
                                        localization,
                                        order.titleKey,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        order.reference,
                                        style: TextStyle(
                                          color: TravelTheme.muted,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    switch (order.status) {
                                      TravelOrderStatus.pending =>
                                        localization.travelPendingConfirmation,
                                      TravelOrderStatus.active =>
                                        localization.travelActive,
                                      TravelOrderStatus.confirmed =>
                                        localization.travelConfirmed,
                                      TravelOrderStatus.completed =>
                                        localization.travelCompleted,
                                      TravelOrderStatus.refunded =>
                                        localization.travelRefunded,
                                      TravelOrderStatus.failed =>
                                        localization.travelFailed,
                                    },
                                    style: TextStyle(
                                      color: switch (order.status) {
                                        TravelOrderStatus.pending =>
                                          TravelTheme.warning,
                                        TravelOrderStatus.failed =>
                                          TravelTheme.red,
                                        TravelOrderStatus.refunded =>
                                          TravelTheme.muted,
                                        TravelOrderStatus.confirmed ||
                                        TravelOrderStatus.active ||
                                        TravelOrderStatus.completed =>
                                          TravelTheme.green,
                                      },
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (canDownloadVoucher) ...[
                          SizedBox(height: 14.h),
                          const Divider(),
                          SizedBox(height: 10.h),
                          TravelVoucherQr(order: order, size: 116.r),
                          SizedBox(height: 8.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              order.reference,
                              style: TextStyle(
                                color: TravelTheme.muted,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                downloadTravelVoucher(context, order),
                            icon: const Icon(Icons.download_rounded),
                            label: Text(
                              localization.qrCodeScreenDownloadButton,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
      }),
    );
  }
}
