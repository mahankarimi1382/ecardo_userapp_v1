import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../hotels/hotel_search_components.dart';
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
  bool reviewConfirmed = false;
  bool reservationExpired = false;
  final beneficiaryNameController = TextEditingController();
  final notificationPhoneController = TextEditingController();
  final notificationEmailController = TextEditingController();
  final reservatorFirstNameController = TextEditingController();
  final reservatorLastNameController = TextEditingController();
  final reservatorPhoneController = TextEditingController();
  final reservatorEmailController = TextEditingController();
  final specialRequestsController = TextEditingController();
  final List<_HotelRoomGuestFormState> hotelRoomGuestForms = [];
  late final List<_PassengerFormState> passengerForms;

  @override
  void initState() {
    super.initState();
    passengerForms = [
      for (var index = 0; index < widget.bookingDetails.adultCount; index++)
        _PassengerFormState(type: 'adult'),
      for (var index = 0; index < widget.bookingDetails.childCount; index++)
        _PassengerFormState(type: 'child'),
      for (var index = 0; index < widget.bookingDetails.infantCount; index++)
        _PassengerFormState(type: 'infant'),
    ];
    if (widget.type == TravelProductType.flight && passengerForms.isNotEmpty) {
      unawaited(_loadPrimaryTraveler());
    }
    if (widget.type == TravelProductType.hotel) {
      _initializeHotelGuests();
    }
  }

  @override
  void dispose() {
    reservationTimer?.cancel();
    beneficiaryNameController.dispose();
    notificationPhoneController.dispose();
    notificationEmailController.dispose();
    reservatorFirstNameController.dispose();
    reservatorLastNameController.dispose();
    reservatorPhoneController.dispose();
    reservatorEmailController.dispose();
    specialRequestsController.dispose();
    for (final form in hotelRoomGuestForms) {
      form.dispose();
    }
    for (final form in passengerForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _initializeHotelGuests() {
    final user = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().userModel.value.data
        : null;
    reservatorFirstNameController.text = user?.firstName ?? '';
    reservatorLastNameController.text = user?.lastName ?? '';
    reservatorPhoneController.text = user?.phone ?? '';
    reservatorEmailController.text = user?.email ?? '';
    specialRequestsController.text = widget.bookingDetails.specialRequests;
    final selectedRooms = widget.bookingDetails.selectedRooms.isNotEmpty
        ? widget.bookingDetails.selectedRooms
        : [
            TravelSelectedRoom(
              id: widget.bookingDetails.roomId,
              name: widget.bookingDetails.roomName,
              quantity: widget.bookingDetails.roomCount,
              unitPrice: widget.total.amount,
              currency: widget.total.currency,
            ),
          ];
    for (final room in selectedRooms) {
      for (var index = 1; index <= room.quantity; index++) {
        hotelRoomGuestForms.add(
          _HotelRoomGuestFormState(
            roomId: room.id,
            roomName: room.name,
            roomIndex: index,
            firstName: user?.firstName ?? '',
            lastName: user?.lastName ?? '',
            phone: user?.phone ?? '',
            email: user?.email ?? '',
          ),
        );
      }
    }
  }

  Future<void> _loadPrimaryTraveler() async {
    final profile = await ensureTravelController().loadTravelerProfile();
    final passenger = profile?.passenger;
    if (!mounted || passenger == null || passengerForms.isEmpty) return;
    setState(() {
      passengerForms.first.applyProfile(passenger);
      if (notificationPhoneController.text.trim().isEmpty) {
        notificationPhoneController.text = profile?.phone ?? '';
      }
    });
  }

  void _startReservationTimer(TravelReservation value) {
    reservationTimer?.cancel();
    setState(() {
      reservation = value;
      reservationRemaining = _remainingFor(value);
      reservationExpired = reservationRemaining == Duration.zero;
    });
    reservationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _remainingFor(value);
      if (remaining == Duration.zero) {
        reservationTimer?.cancel();
        setState(() {
          reservationRemaining = Duration.zero;
          reservationExpired = true;
        });
        return;
      }
      setState(() => reservationRemaining = remaining);
    });
  }

  Duration _remainingFor(TravelReservation value) {
    final remaining = value.expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatRemaining(Duration remaining) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _restartAfterExpiry(TravelController controller) {
    final expiredReservation = reservation;
    if (expiredReservation != null) {
      controller.clearExpiredReservationForRetry(expiredReservation);
    }
    reservationTimer?.cancel();
    setState(() {
      reservation = null;
      reservationRemaining = Duration.zero;
      reservationExpired = false;
      reviewConfirmed = false;
    });
  }

  TravelBookingDetails get _bookingDetails => widget.bookingDetails.copyWith(
    beneficiaryType: purchaseForOther ? 'other' : 'self',
    beneficiaryName: purchaseForOther
        ? beneficiaryNameController.text.trim()
        : '',
    passengers: widget.type == TravelProductType.flight
        ? passengerForms
              .map((form) => form.toPassenger())
              .whereType<TravelPassenger>()
              .toList()
        : const [],
    notificationContact: widget.type == TravelProductType.flight
        ? TravelNotificationContact(
            phone: notificationPhoneController.text,
            email: notificationEmailController.text,
          )
        : null,
    roomGuests: widget.type == TravelProductType.hotel
        ? hotelRoomGuestForms.map((form) => form.toGuest()).toList()
        : const [],
    specialRequests: widget.type == TravelProductType.hotel
        ? specialRequestsController.text.trim()
        : '',
  );

  bool get _hasValidFlightDetails {
    if (widget.type != TravelProductType.flight) return true;
    if (passengerForms.isEmpty ||
        passengerForms.any((form) => form.toPassenger() == null)) {
      return false;
    }
    return notificationPhoneController.text.trim().isNotEmpty ||
        notificationEmailController.text.trim().isNotEmpty;
  }

  bool get _hasValidHotelDetails {
    if (widget.type != TravelProductType.hotel) return true;
    return reservatorFirstNameController.text.trim().isNotEmpty &&
        reservatorLastNameController.text.trim().isNotEmpty &&
        reservatorPhoneController.text.trim().isNotEmpty &&
        reservatorEmailController.text.trim().isNotEmpty &&
        hotelRoomGuestForms.every((form) => form.toGuest().isComplete);
  }

  String _productTypeLabel(AppLocalizations localization) {
    return switch (widget.type) {
      TravelProductType.hotel => localization.travelHotels,
      TravelProductType.flight => localization.travelFlights,
      TravelProductType.esim => localization.travelEsimPackages,
    };
  }

  String _formattedDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    return TravelPage(
      title: localization.travelWalletCheckout,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(() {
            final wallet = controller.walletForCurrency(widget.total.currency);
            final hasBalance =
                controller.walletBalanceFor(widget.total.currency) >=
                widget.total.amount;
            final canPurchase = controller.canPurchase(widget.type);
            final needsWallet = reservation != null && !reservationExpired;
            return CommonButton(
              width: double.infinity,
              text: !canPurchase
                  ? localization.travelOfferUnavailable
                  : reservationExpired
                  ? widget.type == TravelProductType.hotel
                        ? localization.travelReserveHotel
                        : widget.type == TravelProductType.flight
                        ? localization.travelSelectFlight
                        : localization.travelChoosePackage
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
                  : reservationExpired
                  ? () => _restartAfterExpiry(controller)
                  : reservation == null
                  ? !reviewConfirmed
                        ? null
                        : () async {
                            if (purchaseForOther &&
                                beneficiaryNameController.text.trim().isEmpty) {
                              showTravelMessage(
                                context,
                                title: localization.travelPassengerReview,
                                message: localization.travelFieldRequired,
                              );
                              return;
                            }
                            if (!_hasValidFlightDetails) {
                              showTravelMessage(
                                context,
                                title: localization.travelPassengerReview,
                                message:
                                    localization.travelPassengerDetailsRequired,
                              );
                              return;
                            }
                            if (!_hasValidHotelDetails) {
                              showTravelMessage(
                                context,
                                title: hotelFlowText(
                                  context,
                                  'اطلاعات رزروکننده',
                                  'Reservator information',
                                ),
                                message: hotelFlowText(
                                  context,
                                  'اطلاعات رزروکننده و سرپرست هر اتاق را کامل کنید.',
                                  'Complete the reservator and room caretaker information.',
                                ),
                              );
                              return;
                            }
                            if (widget.type == TravelProductType.flight) {
                              final primaryPassenger = passengerForms.first
                                  .toPassenger();
                              if (primaryPassenger != null) {
                                await controller.updateTravelerProfile(
                                  primaryPassenger,
                                  phone: notificationPhoneController.text
                                      .trim(),
                                );
                                if (!context.mounted) return;
                              }
                            }
                            final value = await controller.reserve(
                              type: widget.type,
                              productId: widget.productId,
                              total: widget.total,
                              bookingDetails: _bookingDetails,
                            );
                            if (!context.mounted) return;
                            if (value != null) {
                              _startReservationTimer(value);
                            } else if (controller.checkoutFailed.value) {
                              showTravelMessage(
                                context,
                                title: localization.travelPaymentFailed,
                                message:
                                    localization.travelPaymentFailedDescription,
                              );
                            }
                          }
                  : !needsWallet
                  ? null
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
                      if (!context.mounted) return;
                      if (order != null) {
                        Get.off(() => TravelConfirmationScreen(order: order));
                      } else if (controller.checkoutFailed.value) {
                        showTravelMessage(
                          context,
                          title: localization.travelPaymentFailed,
                          message: localization.travelPaymentFailedDescription,
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
          }),
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
            _CheckoutProgress(
              currentStep: reservation == null ? 0 : 1,
              localization: localization,
              expired: reservationExpired,
              type: widget.type,
            ),
            SizedBox(height: 20.h),
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
                color: reservationExpired
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFFFF8E1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          reservationExpired
                              ? Icons.event_busy_rounded
                              : Icons.timer_outlined,
                          color: reservationExpired
                              ? TravelTheme.red
                              : TravelTheme.warning,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            reservationExpired
                                ? localization.travelReservationExpired
                                : localization.travelReservationHoldActive,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              reservation!.orderNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (!reservationExpired)
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              _formatRemaining(reservationRemaining),
                              style: const TextStyle(
                                color: TravelTheme.warning,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (reservationExpired) ...[
                      SizedBox(height: 10.h),
                      Text(
                        localization.travelNoPaymentAttemptedAfterExpiry,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
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
            if (widget.type == TravelProductType.flight) ...[
              for (var index = 0; index < passengerForms.length; index++) ...[
                _PassengerEditor(
                  form: passengerForms[index],
                  index: index,
                  enabled: reservation == null,
                  onChanged: () => setState(() => reviewConfirmed = false),
                ),
                if (index < passengerForms.length - 1) SizedBox(height: 10.h),
              ],
              SizedBox(height: 18.h),
              TravelSectionHeader(
                title: localization.travelNotificationContact,
              ),
              SizedBox(height: 10.h),
              TravelCard(
                child: Column(
                  children: [
                    TextField(
                      controller: notificationPhoneController,
                      enabled: reservation == null,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() => reviewConfirmed = false),
                      decoration: InputDecoration(
                        labelText: localization.travelPhone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: notificationEmailController,
                      enabled: reservation == null,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => reviewConfirmed = false),
                      decoration: InputDecoration(
                        labelText: localization.travelEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (widget.type == TravelProductType.hotel) ...[
              TravelCard(
                color: TravelTheme.purple.withValues(alpha: .07),
                child: Text(
                  hotelFlowText(
                    context,
                    'اطلاعات رزرو و تمام تغییرات این سفارش برای رزروکننده ارسال می‌شود.',
                    'Reservation details and every order update will be sent to the reservator.',
                  ),
                  style: TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 11.sp,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TravelCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: reservatorFirstNameController,
                            enabled: reservation == null,
                            decoration: InputDecoration(
                              labelText: localization.travelFirstName,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: reservatorLastNameController,
                            enabled: reservation == null,
                            decoration: InputDecoration(
                              labelText: localization.travelLastName,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: reservatorPhoneController,
                      enabled: reservation == null,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: localization.travelPhone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: reservatorEmailController,
                      enabled: reservation == null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: localization.travelEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              TravelSectionHeader(
                title: hotelFlowText(
                  context,
                  'سرپرست اتاق‌ها',
                  'Room caretakers',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                hotelFlowText(
                  context,
                  'برای هر اتاق فقط اطلاعات یک نفر مسئول لازم است؛ نیازی به ثبت اطلاعات همه مسافران نیست.',
                  'Only one responsible guest is needed for each room; you do not need to enter every passenger.',
                ),
                style: TextStyle(
                  color: TravelTheme.muted,
                  fontSize: 11.sp,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 10.h),
              for (final form in hotelRoomGuestForms) ...[
                _HotelRoomGuestEditor(form: form, enabled: reservation == null),
                SizedBox(height: 10.h),
              ],
              TextField(
                controller: specialRequestsController,
                enabled: reservation == null,
                minLines: 5,
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  labelText: hotelFlowText(
                    context,
                    'درخواست‌های ویژه (اختیاری)',
                    'Special requests (optional)',
                  ),
                  alignLabelWithHint: true,
                  hintText: hotelFlowText(
                    context,
                    'مانند اتاق غیرسیگاری، طبقه خاص یا زمان تقریبی ورود',
                    'For example, non-smoking room or estimated arrival time',
                  ),
                ),
              ),
            ] else
              TravelCard(
                child: RadioGroup<bool>(
                  groupValue: purchaseForOther,
                  onChanged: (value) {
                    if (reservation != null || value == null) return;
                    setState(() {
                      purchaseForOther = value;
                      reviewConfirmed = false;
                    });
                  },
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: false,
                        enabled: reservation == null,
                        title: Text(localization.travelPrimaryPassenger),
                        subtitle: Text(localization.travelPassengerFromProfile),
                      ),
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: true,
                        enabled: reservation == null,
                        title: Text(localization.commonDropdownOther),
                      ),
                      if (purchaseForOther)
                        TextField(
                          controller: beneficiaryNameController,
                          enabled: reservation == null,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            setState(() => reviewConfirmed = false);
                          },
                          decoration: InputDecoration(
                            labelText: localization.travelPrimaryPassenger,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelReviewStep),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: [
                  _SummaryRow(
                    label: _productTypeLabel(localization),
                    value: widget.title,
                  ),
                  if (widget.type == TravelProductType.hotel &&
                      widget.bookingDetails.roomName.isNotEmpty) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelRoom,
                      value: widget.bookingDetails.roomName,
                    ),
                  ],
                  if (widget.type == TravelProductType.hotel &&
                      widget.bookingDetails.checkInDate != null) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelCheckIn,
                      value: _formattedDate(
                        context,
                        widget.bookingDetails.checkInDate!,
                      ),
                    ),
                  ],
                  if (widget.type == TravelProductType.hotel &&
                      widget.bookingDetails.checkOutDate != null) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelCheckOut,
                      value: _formattedDate(
                        context,
                        widget.bookingDetails.checkOutDate!,
                      ),
                    ),
                  ],
                  if (widget.type == TravelProductType.hotel) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelRooms,
                      value: '${widget.bookingDetails.roomCount}',
                    ),
                  ],
                  if (widget.type != TravelProductType.esim) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelGuests,
                      value:
                          '${localization.travelAdults}: '
                          '${widget.bookingDetails.adultCount}  •  '
                          '${localization.travelChildren}: '
                          '${widget.bookingDetails.childCount}',
                    ),
                  ],
                  const Divider(height: 26),
                  _SummaryRow(
                    label: localization.travelBeneficiary,
                    value: purchaseForOther
                        ? beneficiaryNameController.text.trim()
                        : localization.travelPrimaryPassenger,
                  ),
                  const Divider(height: 26),
                  _SummaryRow(
                    label: localization.travelPaymentMethod,
                    value: localization.travelMainWallet,
                  ),
                  if (wallet != null) ...[
                    const Divider(height: 26),
                    _SummaryRow(
                      label: localization.travelAvailableBalance,
                      value: travelMoney(
                        context,
                        TravelMoney(
                          amount: controller.walletBalanceFor(
                            widget.total.currency,
                          ),
                          currency: widget.total.currency,
                        ),
                      ),
                    ),
                  ],
                  const Divider(height: 26),
                  _SummaryRow(
                    label: localization.travelTotal,
                    value: travelMoney(context, widget.total),
                    strong: true,
                  ),
                ],
              ),
            ),
            if (reservation == null) ...[
              SizedBox(height: 12.h),
              CheckboxListTile(
                value: reviewConfirmed,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  localization.travelReviewConfirmation,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  localization.travelReviewConfirmationDescription,
                ),
                onChanged: (value) =>
                    setState(() => reviewConfirmed = value ?? false),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    hotelFlowText(
                      context,
                      'با ادامه، ',
                      'By continuing, you accept the ',
                    ),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          hotelFlowText(
                            context,
                            'شرایط استفاده و حریم خصوصی',
                            'Terms and privacy policy',
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            ensureTravelController()
                                    .serviceFor(widget.type)
                                    ?.presentation['terms_text']
                                    ?.toString() ??
                                hotelFlowText(
                                  context,
                                  'متن شرایط این خدمت از پنل مدیریت سفر قابل تنظیم است. پیش از پرداخت، قوانین هتل، لغو، بازپرداخت و حریم خصوصی را بررسی کنید.',
                                  'The terms for this service are admin-controlled. Review hotel, cancellation, refund, and privacy rules before payment.',
                                ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Text(
                              hotelFlowText(context, 'بستن', 'Close'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: Text(
                      hotelFlowText(
                        context,
                        'شرایط استفاده و حریم خصوصی',
                        'terms and privacy policy',
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

class _CheckoutProgress extends StatelessWidget {
  final int currentStep;
  final AppLocalizations localization;
  final bool expired;
  final TravelProductType type;

  const _CheckoutProgress({
    required this.currentStep,
    required this.localization,
    required this.expired,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final labels = type == TravelProductType.hotel
        ? <String>[
            hotelFlowText(context, 'اطلاعات مسافر', 'Passenger information'),
            hotelFlowText(context, 'بررسی ظرفیت', 'Checking availability'),
            localization.travelPaymentMethod,
          ]
        : <String>[
            localization.travelReviewStep,
            localization.travelPaymentMethod,
            localization.travelConfirmationStep,
          ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 30.r,
                  height: 30.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index <= currentStep && !expired
                        ? TravelTheme.blue
                        : const Color(0xFFE8F1FD),
                    shape: BoxShape.circle,
                    border: expired && index == currentStep
                        ? Border.all(color: TravelTheme.red, width: 2)
                        : null,
                  ),
                  child: index < currentStep && !expired
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= currentStep && !expired
                                ? Colors.white
                                : TravelTheme.muted,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                SizedBox(height: 6.h),
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: index == currentStep
                        ? TravelTheme.ink
                        : TravelTheme.muted,
                    fontSize: 9.sp,
                    fontWeight: index == currentStep
                        ? FontWeight.w900
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (index < labels.length - 1)
            Expanded(
              child: Container(
                height: 2.h,
                margin: EdgeInsets.only(top: 14.h),
                color: index < currentStep && !expired
                    ? TravelTheme.blue
                    : const Color(0xFFE8F1FD),
              ),
            ),
        ],
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 16),
        Directionality(
          textDirection: TextDirection.ltr,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .52,
            ),
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: style,
            ),
          ),
        ),
      ],
    );
  }
}

class _HotelRoomGuestFormState {
  final String roomId;
  final String roomName;
  final int roomIndex;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  _HotelRoomGuestFormState({
    required this.roomId,
    required this.roomName,
    required this.roomIndex,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) : firstNameController = TextEditingController(text: firstName),
       lastNameController = TextEditingController(text: lastName),
       phoneController = TextEditingController(text: phone),
       emailController = TextEditingController(text: email);

  TravelRoomGuest toGuest() => TravelRoomGuest(
    roomId: roomId,
    roomIndex: roomIndex,
    firstName: firstNameController.text,
    lastName: lastNameController.text,
    phone: phoneController.text,
    email: emailController.text,
  );

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }
}

class _HotelRoomGuestEditor extends StatelessWidget {
  final _HotelRoomGuestFormState form;
  final bool enabled;

  const _HotelRoomGuestEditor({required this.form, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${form.roomName} • ${hotelFlowText(context, 'اتاق', 'Room')} ${form.roomIndex}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: form.firstNameController,
                  enabled: enabled,
                  decoration: InputDecoration(
                    labelText: localization.travelFirstName,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: form.lastNameController,
                  enabled: enabled,
                  decoration: InputDecoration(
                    labelText: localization.travelLastName,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: form.phoneController,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: localization.travelPhone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: form.emailController,
            enabled: enabled,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: localization.travelEmail,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerFormState {
  final String type;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nationalityController = TextEditingController(text: 'IR');
  final passportController = TextEditingController();
  late final TextEditingController birthDateController;
  late final TextEditingController passportExpiryController;
  String gender = 'male';

  _PassengerFormState({required this.type}) {
    final now = DateTime.now();
    final birthDate = switch (type) {
      'infant' => DateTime(now.year - 1, now.month, now.day),
      'child' => DateTime(now.year - 10, now.month, now.day),
      _ => DateTime(now.year - 30, now.month, now.day),
    };
    birthDateController = TextEditingController(text: _date(birthDate));
    passportExpiryController = TextEditingController(
      text: _date(DateTime(now.year + 2, now.month, now.day)),
    );
  }

  void applyProfile(TravelPassenger passenger) {
    firstNameController.text = passenger.firstName;
    lastNameController.text = passenger.lastName;
    nationalityController.text = passenger.nationalityCode;
    passportController.text = passenger.passportNumber;
    if (passenger.birthDate != null) {
      birthDateController.text = _date(passenger.birthDate!);
    }
    if (passenger.passportExpiry != null) {
      passportExpiryController.text = _date(passenger.passportExpiry!);
    }
    if (passenger.gender.isNotEmpty) gender = passenger.gender;
  }

  TravelPassenger? toPassenger() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final nationality = nationalityController.text.trim();
    final passport = passportController.text.trim();
    final birthDate = DateTime.tryParse(birthDateController.text.trim());
    final passportExpiry = DateTime.tryParse(
      passportExpiryController.text.trim(),
    );
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        nationality.length != 2 ||
        passport.isEmpty ||
        birthDate == null ||
        !birthDate.isBefore(DateTime.now()) ||
        passportExpiry == null ||
        !passportExpiry.isAfter(DateTime.now())) {
      return null;
    }
    return TravelPassenger(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      gender: gender,
      nationalityCode: nationality,
      passportNumber: passport,
      passportExpiry: passportExpiry,
      type: type,
    );
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nationalityController.dispose();
    passportController.dispose();
    birthDateController.dispose();
    passportExpiryController.dispose();
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _PassengerEditor extends StatefulWidget {
  final _PassengerFormState form;
  final int index;
  final bool enabled;
  final VoidCallback onChanged;

  const _PassengerEditor({
    required this.form,
    required this.index,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<_PassengerEditor> createState() => _PassengerEditorState();
}

class _PassengerEditorState extends State<_PassengerEditor> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final typeLabel = switch (widget.form.type) {
      'child' => localization.travelChildren,
      'infant' => localization.travelInfants,
      _ => localization.travelAdults,
    };
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$typeLabel ${widget.index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.form.firstNameController,
                  enabled: widget.enabled,
                  onChanged: (_) => widget.onChanged(),
                  decoration: InputDecoration(
                    labelText: localization.travelFirstName,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: widget.form.lastNameController,
                  enabled: widget.enabled,
                  onChanged: (_) => widget.onChanged(),
                  decoration: InputDecoration(
                    labelText: localization.travelLastName,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.form.birthDateController,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.datetime,
                  onChanged: (_) => widget.onChanged(),
                  decoration: InputDecoration(
                    labelText: localization.travelBirthDate,
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: widget.form.gender,
                  decoration: InputDecoration(
                    labelText: localization.travelGender,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(localization.travelMale),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(localization.travelFemale),
                    ),
                  ],
                  onChanged: widget.enabled
                      ? (value) {
                          setState(() => widget.form.gender = value ?? 'male');
                          widget.onChanged();
                        }
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: widget.form.passportController,
            enabled: widget.enabled,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => widget.onChanged(),
            decoration: InputDecoration(
              labelText: localization.travelPassportNumber,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.form.passportExpiryController,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.datetime,
                  onChanged: (_) => widget.onChanged(),
                  decoration: InputDecoration(
                    labelText: localization.travelPassportExpiry,
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: widget.form.nationalityController,
                  enabled: widget.enabled,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                  onChanged: (_) => widget.onChanged(),
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: localization.travelNationalityCode,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
