import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'travel_confirmation_screen.dart';

class TravelOrdersScreen extends StatefulWidget {
  final TravelProductType? initialType;

  const TravelOrdersScreen({super.key, this.initialType});

  @override
  State<TravelOrdersScreen> createState() => _TravelOrdersScreenState();
}

class _TravelOrdersScreenState extends State<TravelOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  TravelOrderGroup? _selectedGroup;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetDiscovery() {
    _searchController.clear();
    setState(() => _selectedGroup = null);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final title = switch (widget.initialType) {
      TravelProductType.hotel => localization.travelMyHotels,
      TravelProductType.flight => localization.travelMyFlights,
      TravelProductType.esim => localization.travelMyEsims,
      null => localization.travelMyBookings,
    };
    return TravelPage(
      title: title,
      child: Obx(() {
        final typedOrders = widget.initialType == null
            ? controller.orders.toList()
            : controller.orders
                  .where((order) => order.type == widget.initialType)
                  .toList();
        final normalizedQuery = _searchController.text.trim().toLowerCase();
        final visibleOrders = typedOrders.where((order) {
          if (_selectedGroup != null && order.group != _selectedGroup) {
            return false;
          }
          return normalizedQuery.isEmpty ||
              _matchesOrderSearch(order, localization, normalizedQuery);
        }).toList();
        final hasDiscoveryFilters =
            normalizedQuery.isNotEmpty || _selectedGroup != null;
        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            children: [
              if (typedOrders.isNotEmpty) ...[
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: localization.search,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            tooltip: localization.reset,
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: TravelTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: TravelTheme.border),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _OrderGroupChip(
                        label: localization.travelAllBookings,
                        selected: _selectedGroup == null,
                        onSelected: () => setState(() => _selectedGroup = null),
                      ),
                      for (final group in TravelOrderGroup.values) ...[
                        SizedBox(width: 8.w),
                        _OrderGroupChip(
                          label: travelOrderGroupTitle(localization, group),
                          selected: _selectedGroup == group,
                          onSelected: () =>
                              setState(() => _selectedGroup = group),
                        ),
                      ],
                    ],
                  ),
                ),
                if (controller.ordersLastUpdatedAt.value != null) ...[
                  SizedBox(height: 8.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      '${localization.travelLastUpdated}: ${MaterialLocalizations.of(context).formatShortDate(controller.ordersLastUpdatedAt.value!)}',
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                if (hasDiscoveryFilters) ...[
                  SizedBox(height: 4.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _resetDiscovery,
                      icon: const Icon(Icons.filter_alt_off_rounded),
                      label: Text(localization.reset),
                    ),
                  ),
                ] else
                  SizedBox(height: 16.h),
              ],
              if (visibleOrders.isEmpty) ...[
                SizedBox(height: typedOrders.isEmpty ? 120.h : 48.h),
                TravelEmptyState(
                  message: controller.ordersError.value != null
                      ? localization.allControllerLoadError
                      : switch (widget.initialType) {
                          TravelProductType.hotel =>
                            localization.travelNoHotels,
                          TravelProductType.flight =>
                            localization.travelNoFlights,
                          TravelProductType.esim => localization.travelNoEsims,
                          null => localization.travelNoBookings,
                        },
                ),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton.icon(
                    onPressed: hasDiscoveryFilters
                        ? _resetDiscovery
                        : controller.isActivityLoading.value
                        ? null
                        : controller.refreshOrders,
                    icon: Icon(
                      hasDiscoveryFilters
                          ? Icons.filter_alt_off_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(
                      hasDiscoveryFilters
                          ? localization.reset
                          : localization.noInternetConnectionRetryButton,
                    ),
                  ),
                ),
              ] else
                for (final group in TravelOrderGroup.values)
                  if (visibleOrders.any((order) => order.group == group)) ...[
                    _OrderSectionTitle(
                      title: travelOrderGroupTitle(localization, group),
                      count: visibleOrders
                          .where((order) => order.group == group)
                          .length,
                    ),
                    SizedBox(height: 10.h),
                    for (final order in visibleOrders.where(
                      (order) => order.group == group,
                    )) ...[
                      _TravelOrderCard(order: order),
                      SizedBox(height: 12.h),
                    ],
                    SizedBox(height: 6.h),
                  ],
            ],
          ),
        );
      }),
    );
  }
}

bool _matchesOrderSearch(
  TravelOrder order,
  AppLocalizations localization,
  String normalizedQuery,
) {
  final searchableFields = <String>[
    order.reference,
    order.id,
    order.titleKey,
    travelLocalizedKey(localization, order.titleKey),
    order.rawStatus,
    ...order.details.keys,
    ...order.details.values,
  ];
  return searchableFields.any(
    (field) => field.toLowerCase().contains(normalizedQuery),
  );
}

class _OrderGroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _OrderGroupChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: TravelTheme.blue.withValues(alpha: .14),
      side: BorderSide(color: selected ? TravelTheme.blue : TravelTheme.border),
      labelStyle: TextStyle(
        color: selected ? TravelTheme.blue : TravelTheme.muted,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _OrderSectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _OrderSectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: TravelTheme.border),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: TravelTheme.muted,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TravelOrderCard extends StatelessWidget {
  final TravelOrder order;

  const _TravelOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final statusColor = travelOrderStatusColor(order.status);
    return TravelCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => Get.to(() => TravelConfirmationScreen(order: order)),
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
                        travelLocalizedKey(localization, order.titleKey),
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
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      travelOrderStatusIcon(order.status),
                      color: statusColor,
                      size: 18.r,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      travelOrderStatusText(localization, order.status),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ],
            ),
          ),
          if (order.hasIssuedVoucher) ...[
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
              onPressed: () => downloadTravelVoucher(context, order),
              icon: const Icon(Icons.download_rounded),
              label: Text(localization.qrCodeScreenDownloadButton),
            ),
          ],
        ],
      ),
    );
  }
}

String travelOrderGroupTitle(
  AppLocalizations localization,
  TravelOrderGroup group,
) => switch (group) {
  TravelOrderGroup.attention => localization.travelNeedsAttention,
  TravelOrderGroup.upcoming => localization.travelUpcomingAndActive,
  TravelOrderGroup.completed => localization.travelCompleted,
  TravelOrderGroup.cancellation => localization.travelCancellationsAndRefunds,
};

String travelOrderStatusText(
  AppLocalizations localization,
  TravelOrderStatus status,
) => switch (status) {
  TravelOrderStatus.paymentPending => localization.travelPaymentPending,
  TravelOrderStatus.paymentProcessing => localization.travelPaymentProcessing,
  TravelOrderStatus.paymentReceived => localization.travelPaymentReceived,
  TravelOrderStatus.supplierPending => localization.travelPendingConfirmation,
  TravelOrderStatus.confirmed => localization.travelConfirmed,
  TravelOrderStatus.issued => localization.travelVoucherIssued,
  TravelOrderStatus.active => localization.travelActive,
  TravelOrderStatus.completed => localization.travelCompleted,
  TravelOrderStatus.cancellationPending =>
    localization.travelCancellationRequested,
  TravelOrderStatus.refundPending => localization.travelRefundInReview,
  TravelOrderStatus.cancelled => localization.travelCancelled,
  TravelOrderStatus.refunded => localization.travelRefunded,
  TravelOrderStatus.failed => localization.travelFailed,
  TravelOrderStatus.expired => localization.travelExpired,
  TravelOrderStatus.unknown => localization.travelStatusUnavailable,
};

Color travelOrderStatusColor(TravelOrderStatus status) => switch (status) {
  TravelOrderStatus.paymentPending ||
  TravelOrderStatus.paymentProcessing ||
  TravelOrderStatus.paymentReceived ||
  TravelOrderStatus.supplierPending ||
  TravelOrderStatus.cancellationPending ||
  TravelOrderStatus.refundPending => TravelTheme.warning,
  TravelOrderStatus.confirmed ||
  TravelOrderStatus.issued ||
  TravelOrderStatus.active ||
  TravelOrderStatus.completed => TravelTheme.green,
  TravelOrderStatus.cancelled ||
  TravelOrderStatus.refunded ||
  TravelOrderStatus.expired ||
  TravelOrderStatus.unknown => TravelTheme.muted,
  TravelOrderStatus.failed => TravelTheme.red,
};

IconData travelOrderStatusIcon(TravelOrderStatus status) => switch (status) {
  TravelOrderStatus.paymentPending => Icons.payment_rounded,
  TravelOrderStatus.paymentProcessing ||
  TravelOrderStatus.paymentReceived ||
  TravelOrderStatus.supplierPending => Icons.hourglass_top_rounded,
  TravelOrderStatus.confirmed => Icons.event_available_rounded,
  TravelOrderStatus.issued => Icons.qr_code_2_rounded,
  TravelOrderStatus.active => Icons.travel_explore_rounded,
  TravelOrderStatus.completed => Icons.check_circle_rounded,
  TravelOrderStatus.cancellationPending ||
  TravelOrderStatus.refundPending => Icons.pending_actions_rounded,
  TravelOrderStatus.cancelled => Icons.event_busy_rounded,
  TravelOrderStatus.refunded => Icons.currency_exchange_rounded,
  TravelOrderStatus.failed => Icons.error_rounded,
  TravelOrderStatus.expired => Icons.timer_off_rounded,
  TravelOrderStatus.unknown => Icons.help_outline_rounded,
};
