import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

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
                    fillColor: TravelTheme.cardSurfaceFor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: TravelTheme.borderFor(context),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: TravelTheme.borderFor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: TravelTheme.isDark(context)
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                        width: 1.5,
                      ),
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
                        color: TravelTheme.textSecondaryFor(context),
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
                      style: TextButton.styleFrom(
                        foregroundColor: TravelTheme.primaryFor(context),
                      ),
                    ),
                  ),
                ] else
                  SizedBox(height: 16.h),
              ],
              if (visibleOrders.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: typedOrders.isEmpty ? 40.h : 20.h,
                  ),
                  child: Builder(
                    builder: (context) {
                      final isError = controller.ordersError.value != null;
                      final String emptyTitle;
                      final String emptyDesc;
                      final IconData emptyIcon;
                      final String? primaryLabel;
                      final VoidCallback? primaryAction;
                      final String? secondaryLabel;
                      final VoidCallback? secondaryAction;

                      if (isError) {
                        emptyTitle = localization.allControllerLoadError;
                        emptyDesc = localization.noInternetConnectionMessage;
                        emptyIcon = Icons.cloud_off_rounded;
                        primaryLabel =
                            localization.noInternetConnectionRetryButton;
                        primaryAction = controller.isActivityLoading.value
                            ? null
                            : () => controller.refreshOrders();
                        secondaryLabel = null;
                        secondaryAction = null;
                      } else if (hasDiscoveryFilters) {
                        emptyTitle = switch (widget.initialType) {
                          TravelProductType.hotel =>
                            localization.travelNoHotelResults,
                          TravelProductType.flight =>
                            localization.travelNoFlightResults,
                          TravelProductType.esim =>
                            localization.travelNoEsimPackages,
                          null => localization.travelNoBookings,
                        };
                        emptyDesc = l10nPick(
                          context,
                          en: 'No bookings match your active search or filters. Clear your filters to see all bookings.',
                          fa: 'هیچ سفارشی با جستجو یا فیلترهای انتخابی شما مطابقت ندارد. فیلترها را پاک کنید.',
                          ar: 'لا توجد حجوزات تطابق البحث أو الفلاتر المحددة. قم بإلغاء الفلاتر لعرض جميع الحجوزات.',
                        );
                        emptyIcon = Icons.filter_alt_off_rounded;
                        primaryLabel = localization.reset;
                        primaryAction = _resetDiscovery;
                        secondaryLabel = localization.refresh;
                        secondaryAction = controller.isActivityLoading.value
                            ? null
                            : () => controller.refreshOrders();
                      } else {
                        emptyTitle = switch (widget.initialType) {
                          TravelProductType.hotel =>
                            localization.travelNoHotels,
                          TravelProductType.flight =>
                            localization.travelNoFlights,
                          TravelProductType.esim => localization.travelNoEsims,
                          null => localization.travelNoBookings,
                        };
                        emptyDesc = l10nPick(
                          context,
                          en: 'Your travel reservations, flight tickets, and hotel bookings will appear here once booked.',
                          fa: 'رزروهای سفر، بلیط‌های پرواز و هتل‌های شما پس از ثبت در اینجا نمایش داده خواهند شد.',
                          ar: 'ستظهر هنا حجوزات السفر وتذاكر الطيران والفنادق بعد إتمام الحجز.',
                        );
                        emptyIcon = switch (widget.initialType) {
                          TravelProductType.hotel => Icons.hotel_outlined,
                          TravelProductType.flight =>
                            Icons.flight_takeoff_rounded,
                          TravelProductType.esim => Icons.sim_card_outlined,
                          null => Icons.luggage_outlined,
                        };
                        primaryLabel = localization.refresh;
                        primaryAction = controller.isActivityLoading.value
                            ? null
                            : () => controller.refreshOrders();
                        secondaryLabel = null;
                        secondaryAction = null;
                      }

                      return EcardoEmptyState(
                        title: emptyTitle,
                        description: emptyDesc,
                        iconData: emptyIcon,
                        glowColor: isError
                            ? AppColors.error
                            : (TravelTheme.isDark(context)
                                  ? AppColors.mainSoftBlue
                                  : AppColors.brandViolet),
                        iconColor: isError ? AppColors.error : null,
                        primaryActionLabel: primaryLabel,
                        onPrimaryAction: primaryAction,
                        secondaryActionLabel: secondaryLabel,
                        onSecondaryAction: secondaryAction,
                      );
                    },
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
    final isDark = TravelTheme.isDark(context);
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;
    final activeBg = isDark
        ? AppColors.darkPrimaryContainer
        : AppColors.brandVioletContainer;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: TravelTheme.cardSurfaceFor(context),
      selectedColor: activeBg,
      side: BorderSide(
        color: selected ? activeColor : TravelTheme.borderFor(context),
      ),
      labelStyle: TextStyle(
        color: selected ? activeColor : TravelTheme.textSecondaryFor(context),
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
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: TravelTheme.textPrimaryFor(context),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: TravelTheme.cardSurfaceFor(context),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: TravelTheme.borderFor(context)),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: TravelTheme.textSecondaryFor(context),
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
    final isDark = TravelTheme.isDark(context);
    final statusColor = travelOrderStatusColor(order.status);
    final statusBgColor = travelOrderStatusContainerColor(order.status, isDark);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final prodColor = travelProductColor(order.type);

    return TravelCard(
      child: Column(
        children: [
          Semantics(
            button: true,
            label:
                '${travelLocalizedKey(localization, order.titleKey)}, ${travelOrderStatusText(localization, order.status)}, ${order.reference}',
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => Get.to(() => TravelConfirmationScreen(order: order)),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Row(
                  children: [
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: prodColor.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: prodColor.withValues(
                            alpha: isDark ? 0.35 : 0.2,
                          ),
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        travelProductIcon(order.type),
                        color: prodColor,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            travelLocalizedKey(localization, order.titleKey),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              order.reference,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: statusColor.withValues(
                                alpha: isDark ? 0.4 : 0.25,
                              ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                travelOrderStatusIcon(order.status),
                                color: statusColor,
                                size: 12.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                travelOrderStatusText(
                                  localization,
                                  order.status,
                                ),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: textSecondary,
                          size: 18.r,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (order.hasIssuedVoucher) ...[
            SizedBox(height: 12.h),
            Divider(color: TravelTheme.borderFor(context), height: 1),
            SizedBox(height: 10.h),
            TravelVoucherQr(order: order, size: 116.r),
            SizedBox(height: 8.h),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                order.reference,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => downloadTravelVoucher(context, order),
              icon: const Icon(Icons.download_rounded),
              label: Text(localization.qrCodeScreenDownloadButton),
              style: TextButton.styleFrom(
                foregroundColor: TravelTheme.primaryFor(context),
              ),
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
  TravelOrderStatus.refundPending => AppColors.warning,
  TravelOrderStatus.confirmed ||
  TravelOrderStatus.issued ||
  TravelOrderStatus.active ||
  TravelOrderStatus.completed => AppColors.success,
  TravelOrderStatus.cancelled ||
  TravelOrderStatus.refunded ||
  TravelOrderStatus.expired ||
  TravelOrderStatus.unknown => AppColors.softGray,
  TravelOrderStatus.failed => AppColors.error,
};

Color travelOrderStatusContainerColor(TravelOrderStatus status, bool isDark) =>
    switch (status) {
      TravelOrderStatus.paymentPending ||
      TravelOrderStatus.paymentProcessing ||
      TravelOrderStatus.paymentReceived ||
      TravelOrderStatus.supplierPending ||
      TravelOrderStatus.cancellationPending ||
      TravelOrderStatus.refundPending =>
        isDark ? AppColors.darkSurfaceVariant : AppColors.warningContainer,
      TravelOrderStatus.confirmed ||
      TravelOrderStatus.issued ||
      TravelOrderStatus.active ||
      TravelOrderStatus.completed =>
        isDark ? AppColors.darkSecondaryContainer : AppColors.successContainer,
      TravelOrderStatus.cancelled ||
      TravelOrderStatus.refunded ||
      TravelOrderStatus.expired ||
      TravelOrderStatus.unknown =>
        isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      TravelOrderStatus.failed =>
        isDark ? AppColors.darkSurfaceVariant : AppColors.errorContainer,
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
