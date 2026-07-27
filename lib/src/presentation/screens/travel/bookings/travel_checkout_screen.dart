import 'dart:async';

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
  TravelReservation? reservation;
  Timer? reservationTimer;
  Duration reservationRemaining = Duration.zero;
  bool purchaseForOther = false;
  final beneficiaryNameController = TextEditingController();

  @override
  void dispose() {
    reservationTimer?.cancel();
    beneficiaryNameController.dispose();
    super.dispose();
  }

  void _startReservationTimer(TravelReservation value) {
    reservationTimer?.cancel();
    setState(() {
      reservation = value;
      reservationRemaining = value.expiresAt.difference(DateTime.now());
    });
    reservationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = value.expiresAt.difference(DateTime.now());
      if (remaining.isNegative) {
        reservationTimer?.cancel();
        setState(() {
          reservation = null;
          reservationRemaining = Duration.zero;
        });
        return;
      }
      setState(() => reservationRemaining = remaining);
    });
  }

  TravelBookingDetails get _bookingDetails => widget.bookingDetails.copyWith(
    beneficiaryType: purchaseForOther ? 'other' : 'self',
    beneficiaryName: purchaseForOther
        ? beneficiaryNameController.text.trim()
        : '',
  );

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
              final wallet = controller.walletForCurrency(
                widget.total.currency,
              );
              final hasBalance =
                  controller.walletBalanceFor(widget.total.currency) >=
                  widget.total.amount;
              final canPurchase = controller.canPurchase(widget.type);
              return CommonButton(
                width: double.infinity,
                text: !canPurchase
                    ? localization.travelOfferUnavailable
                    : reservation == null
                    ? widget.type == TravelProductType.hotel
                          ? localization.travelReserveHotel
                          : localization.travelSelectFlight
                    : wallet == null
                    ? localization.travelMainWallet
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
                    : reservation == null
                    ? () async {
                        if (purchaseForOther &&
                            beneficiaryNameController.text.trim().isEmpty) {
                          Get.snackbar(
                            localization.travelPassengerReview,
                            localization.travelOfferUnavailable,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        final value = await controller.reserve(
                          type: widget.type,
                          productId: widget.productId,
                          total: widget.total,
                          bookingDetails: _bookingDetails,
                        );
                        if (value != null) {
                          _startReservationTimer(value);
                        } else if (controller.checkoutFailed.value) {
                          Get.snackbar(
                            localization.travelPaymentFailed,
                            localization.travelPaymentFailedDescription,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    : wallet == null
                    ? () => Get.toNamed(
                        BaseRoute.createNewWallet,
                        arguments: {'returnRoute': BaseRoute.travel},
                      )
                    : hasBalance
                    ? () async {
                        final order = await controller.payReservation(
                          reservation!,
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
                        await Get.toNamed(
                          BaseRoute.addMoney,
                          arguments: {
                            'returnRoute': BaseRoute.travel,
                            'wallet_id': wallet.id.toString(),
                          },
                        );
                        await controller.refreshMainWallet();
                        if (mounted) setState(() {});
                      },
              );
            },
          ),
        ),
      ),
      child: Obx(() {
        final wallet = controller.walletForCurrency(widget.total.currency);
        final hasBalance =
            controller.walletBalanceFor(widget.total.currency) >=
            widget.total.amount;
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
            if (reservation != null) ...[
              TravelCard(
                color: const Color(0xFFFFF8E1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: TravelTheme.warning,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              reservation!.orderNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '${reservationRemaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${reservationRemaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: TravelTheme.warning,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
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
            TravelSectionHeader(title: localization.travelPassengerReview),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    groupValue: purchaseForOther,
                    title: Text(localization.travelPrimaryPassenger),
                    subtitle: Text(localization.travelPassengerFromProfile),
                    onChanged: reservation == null
                        ? (value) => setState(
                            () => purchaseForOther = value ?? false,
                          )
                        : null,
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    groupValue: purchaseForOther,
                    title: Text(localization.commonDropdownOther),
                    onChanged: reservation == null
                        ? (value) => setState(
                            () => purchaseForOther = value ?? true,
                          )
                        : null,
                  ),
                  if (purchaseForOther)
                    TextField(
                      controller: beneficiaryNameController,
                      enabled: reservation == null,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: localization.travelPrimaryPassenger,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
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
                          amount: controller.walletBalanceFor(
                            widget.total.currency,
                          ),
                          currency: widget.total.currency,
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
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      width: double.infinity,
                      text: localization.travelAddMoney,
                      backgroundColor: TravelTheme.green,
                      onPressed: wallet == null
                          ? () => Get.toNamed(
                              BaseRoute.createNewWallet,
                              arguments: {'returnRoute': BaseRoute.travel},
                            )
                          : () async {
                              await Get.toNamed(
                                BaseRoute.addMoney,
                                arguments: {
                                  'returnRoute': BaseRoute.travel,
                                  'wallet_id': wallet.id.toString(),
                          },
                              );
                              await controller.refreshMainWallet();
                              if (mounted) setState(() {});
                            },
                    ),
                  ),
                  if (wallet != null) ...[
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CommonButton(
                        width: double.infinity,
                        text: localization.exchangeTitle,
                        backgroundColor: TravelTheme.blue,
                        onPressed: () async {
                          final candidates = controller.fundedExchangeWallets(
                            widget.total.currency,
                          );
                          final suggested = candidates.isEmpty
                              ? null
                              : candidates.first;
                          await Get.toNamed(
                            BaseRoute.exchange,
                            arguments: {
                              'returnRoute': BaseRoute.travel,
                              'to_currency': widget.total.currency,
                              if (suggested?.code != null)
                                'from_currency': suggested!.code,
                            },
                          );
                          await controller.refreshMainWallet();
                          if (mounted) setState(() {});
                        },
                      ),
                    ),
                  ],
                ],
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
