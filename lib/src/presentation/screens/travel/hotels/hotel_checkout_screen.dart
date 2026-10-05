import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'dart:math' as math;

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'widgets/cancellation_policy_timeline.dart';

/// International-Grade Hotel Checkout Screen with comprehensive guest information form,
/// special requests field, payment method selection, final booking review with
/// cancellation policy summary, and voucher download capability.
class HotelCheckoutScreen extends StatefulWidget {
  final String productId;
  final String hotelTitle;
  final String hotelAddress;
  final TravelMoney total;
  final TravelBookingDetails bookingDetails;
  final int nights;

  const HotelCheckoutScreen({
    super.key,
    required this.productId,
    required this.hotelTitle,
    required this.hotelAddress,
    required this.total,
    required this.bookingDetails,
    required this.nights,
  });

  @override
  State<HotelCheckoutScreen> createState() => _HotelCheckoutScreenState();
}

class _HotelCheckoutScreenState extends State<HotelCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.wallet;
  List<String> _specialRequestsLines = [''];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = ensureTravelController();
    final travelers = controller.travellerProfile.value;
    _firstNameController.text = travelers.firstName;
    _lastNameController.text = travelers.lastName;
    _emailController.text = travelers.email;
    _phoneController.text = travelers.phone ?? '';
    _companyController.text = travelers.companyName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void addSpecialRequestLine() {
    setState(() {
      _specialRequestsLines.add('');
    });
  }

  void removeSpecialRequestLine(int index) {
    if (_specialRequestsLines.length > 1) {
      setState(() {
        _specialRequestsLines.removeAt(index);
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final localization = AppLocalizations.of(context)!;
      final controller = ensureTravelController();
      final travelerProfile = TravelTravelerProfile(
        passenger: TravelPassenger(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          companyName: _companyController.text.trim(),
        ),
        phone: _phoneController.text.trim(),
        complete: true,
      );

      await controller.saveTraveler(travelerProfile);

      final ids = uuid.v4();

      final succeeded = await controller.payReservation(
        reservation: TravelReservation(
          type: TravelProductType.hotel,
          productId: widget.productId,
          expectedTotal: widget.total,
          idempotencyKey: ids,
          bookingDetails: widget.bookingDetails.copyWith(
            checkInDate: DateTime.now(),
            checkOutDate: DateTime.now().add(Duration(days: widget.nights)),
            travelerId: 'guest',
            specialRequests: _specialRequestsLines.where((e) => e.trim().isNotEmpty).join('\n'),
          ),
        ),
        idempotencyKey: ids,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (succeeded) {
        Get.offAll(
          () => HotelVoucherScreen(
            orderId: ids,
            productId: widget.productId,
            hotelTitle: widget.hotelTitle,
            hotelAddress: widget.hotelAddress,
            checkInDate: widget.bookingDetails.checkInDate ?? DateTime.now(),
            checkOutDate: widget.bookingDetails.checkOutDate ?? DateTime.now().add(Duration(days: widget.nights)),
            selectedRooms: widget.bookingDetails.selectedRooms,
            totalAmount: widget.total.amount,
            currency: widget.total.currency,
            nights: widget.nights,
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          controller.checkoutError.value ?? 'Booking failed',
          backgroundColor: ECardoTokens.danger(context),
          colorText: ECardoTokens.inkOnBrand,
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        showTravelMessage(
          context,
          title: 'Error',
          message: 'Failed to process your booking. Please try again.',
        );
      }
    }
  }

  void _generateAndDownloadVoucher() async {
    final pdf = PdfDocument();

    // Page settings
    final page = PdfPage(
      size: PdfPageSize.a4,
      margins: const PdfMargins.all(20),
    );

    // Header Section
    pdf.pageHeader(page, (context) {
      return Container(
        padding: const PdfEdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ECardoTokens.brand900(context), ECardoTokens.brand700(context)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.hotel_rounded, color: ECardoTokens.inkOnBrand, size: 32),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotelTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ECardoTokens.inkOnBrand,
                    ),
                  ),
                  Text(
                    widget.hotelAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkOnBrand.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });

    // Main Content
    pdf.pageBody(page, (context) {
      return Column(
        children: [
          // Booking Reference & QR Code Section
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: ECardoTokens.border(context)),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hotel_booking_reference,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.inkMuted(context),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          widget.orderId.value.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: ECardoTokens.brand700(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: ECardoTokens.border(context)),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    ),
                    child: Image.memory(
                      Barcode.qrCode().encodeAsBytes(widget.orderId.value),
                      width: 80.w,
                      height: 80.h,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 20.h),

          // Check-in/Check-out Dates
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    label: AppLocalizations.of(context)!.hotel_check_in,
                    value: '${widget.checkInDate.year}/${widget.checkInDate.month.toString().padLeft(2, '0')}/${widget.checkInDate.day.toString().padLeft(2, '0')}',
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _InfoRow(
                    label: AppLocalizations.of(context)!.hotel_check_out,
                    value: '${widget.checkOutDate.year}/${widget.checkOutDate.month.toString().padLeft(2, '0')}/${widget.checkOutDate.day.toString().padLeft(2, '0')}',
                    icon: Icons.arrow_back_rounded,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Divider(height: 1.h),
          SizedBox(height: 16.h),

          // Selected Rooms Summary
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.hotel_selected_rooms,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...widget.selectedRooms.map((room) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Icon(
                    Icons.bed_rounded,
                    size: 18.sp,
                    color: ECardoTokens.brand700(context),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      room.name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${room.quantity}x',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      travelMoney(
                        Get.context!,
                        TravelMoney(amount: room.unitPrice * room.quantity * widget.nights, currency: room.currency),
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.brand700(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 16.h),
          Divider(height: 20.h),
          SizedBox(height: 16.h),

          // Total Amount
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: ECardoTokens.brand100(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.hotel_total_amount,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.brand700(context),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    travelMoney(Get.context!, widget.total),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.brand700(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Important Information Notes
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: ECardoTokens.infoBg(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                border: Border.all(color: ECardoTokens.info(context).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: ECardoTokens.info(context),
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hotel_important_notes,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.info(context),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isRtl ? 'آدرس هتل را همراه داشته باشید' : 'Please have the hotel address ready for check-in',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Text(
                          isRtl ? 'کارت شناسایی معتبر برای ورود به هتل لازم است' : 'Valid photo ID required for hotel check-in',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });

    // Download the PDF
    await Printing.sharePdf(bytes: await pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TravelPage(
      title: localization.travelCheckout,
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cancellation Policy Summary Card
                Semantics(
                  label: 'Cancellation policy summary before final confirmation',
                  child: CancellationPolicyTimelineCard(
                    checkInDate: widget.bookingDetails.checkInDate,
                    customPolicySummary: '',
                    onTap: null,
                  ),
                ),

                SizedBox(height: 20.h),

                // Guest Information Section
                Text(
                  localization.travelGuestInformation,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 10.h),

                // First Name Field
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.travel_first_name,
                    hintText: localization.travel_first_name_hint,
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.travel_valid_first_name_required;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10.h),

                // Last Name Field
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.travel_last_name,
                    hintText: localization.travel_last_name_hint,
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.travel_valid_last_name_required;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10.h),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.travel_email,
                    hintText: localization.travel_email_hint,
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return AppLocalizations.of(context)!.travel_valid_email_required;
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10.h),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.travel_phone_number,
                    hintText: localization.travel_phone_number_hint,
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                ),

                SizedBox(height: 10.h),

                // Company Name Field (Optional)
                TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    labelText: localization.travel_company_name,
                    hintText: localization.travel_company_name_optional,
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.border(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                ),

                SizedBox(height: 16.h),

                // Special Requests Section
                Text(
                  localization.travel_special_requests,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 8.h),
                ...List.generate(_specialRequestsLines.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _specialRequestsLines[index]),
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: isRtl ? 'توضیحات خاص یا نیاز ویژه...' : 'Special request or dietary needs...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                borderSide: BorderSide(color: ECardoTokens.border(context)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                borderSide: BorderSide(color: ECardoTokens.border(context)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                borderSide: BorderSide(color: ECardoTokens.brand700(context)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _specialRequestsLines[index] = value;
                              });
                            },
                          ),
                        ),
                        if (_specialRequestsLines.length > 1)
                          IconButton(
                            onPressed: () => removeSpecialRequestLine(index),
                            icon: Icon(Icons.close_circle_outline_rounded),
                            color: ECardoTokens.danger(context),
                          ),
                      ],
                    ),
                  );
                }),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 44.h),
                  child: TextButton.icon(
                    onPressed: addSpecialRequestLine,
                    icon: Icon(Icons.add_circle_outline_rounded),
                    label: Text(
                      isRtl ? 'اضافه کردن درخواست بیشتر' : 'Add More Special Request',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                    ),
                    style: TextButton.styleFrom(foregroundColor: ECardoTokens.brand500(context)),
                  ),
                ),

                SizedBox(height: 20.h),

                // Payment Method Selection
                Text(
                  localization.travel_payment_method,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 10.h),
                _PaymentMethodTile(
                  title: 'Wallet Balance',
                  description: 'Pay instantly from your eCardo Wallet',
                  icon: Icons.account_balance_wallet_rounded,
                  isSelected: _selectedPaymentMethod == PaymentMethod.wallet,
                  onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.wallet),
                ),
                SizedBox(height: 8.h),
                _PaymentMethodTile(
                  title: 'Bank Transfer / Credit Card',
                  description: 'Secure bank transfer (Available in select countries)',
                  icon: Icons.credit_card_rounded,
                  isSelected: _selectedPaymentMethod == PaymentMethod.card,
                  onSelect: () => setState(() => _selectedPaymentMethod = PaymentMethod.card),
                ),

                SizedBox(height: 24.h),

                // Final Review Section
                Text(
                  localization.travel_final_review,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 10.h),
                _ReviewSection(
                  hotelTitle: widget.hotelTitle,
                  hotelAddress: widget.hotelAddress,
                  checkInDate: widget.bookingDetails.checkInDate ?? DateTime.now(),
                  checkOutDate: widget.bookingDetails.checkOutDate ?? DateTime.now().add(Duration(days: widget.nights)),
                  rooms: widget.bookingDetails.selectedRooms,
                  totalAmount: widget.total.amount,
                  currency: widget.total.currency,
                  nights: widget.nights,
                  paymentMethod: _selectedPaymentMethod,
                ),

                SizedBox(height: 24.h),

                // Confirm Button
                CommonButton(
                  width: double.infinity,
                  height: 52,
                  text: localization.travelConfirmBooking,
                  backgroundColor: ECardoTokens.brand900(context),
                  isLoading: _isLoading,
                  onPressed: _submitReservation,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaymentMethod { wallet, card }

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PaymentMethodTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ECardoTokens.brand100(context) : Colors.transparent,
      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        onTap: onSelect,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: isSelected ? ECardoTokens.brand100(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            border: Border.all(
              color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: ECardoTokens.brand700(context),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
                    width: 2.w,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand700(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String hotelTitle;
  final String hotelAddress;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final List<TravelSelectedRoom> rooms;
  final double totalAmount;
  final String currency;
  final int nights;
  final PaymentMethod paymentMethod;

  const _ReviewSection({
    required this.hotelTitle,
    required this.hotelAddress,
    required this.checkInDate,
    required this.checkOutDate,
    required this.rooms,
    required this.totalAmount,
    required this.currency,
    required this.nights,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization?.hotel_hotel_details ?? (isRtl ? 'جزئیات هتل و رزرو' : 'Hotel & Booking Details'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 12.h),
          TravelBidiText(
            hotelTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 4.h),
          TravelBidiText(
            hotelAddress,
            style: TextStyle(
              fontSize: 12.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 16.sp,
                color: ECardoTokens.brand700(context),
              ),
              SizedBox(width: 8.w),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$checkInDate - $checkOutDate ($nights ${AppLocalizations.of(context)!.hotel_nights})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            localization?.hotel_rooms_list ?? (isRtl ? 'اتاق‌های انتخاب شده:' : 'Selected Rooms:'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 6.h),
          ...rooms.map((room) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ),
                  Text(
                    '${room.quantity} x ${travelMoney(context, TravelMoney(amount: room.unitPrice * room.quantity * nights, currency: room.currency))}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.brand700(context),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          Divider(color: ECardoTokens.border(context)),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization?.hotel_total_for_nights(nights) ?? (isRtd ? 'مجموع کل' : 'Total Amount'),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  travelMoney(context, TravelMoney(amount: totalAmount, currency: currency)),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.brand700(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.payment_rounded,
                size: 14.sp,
                color: ECardoTokens.brand500(context),
              ),
              SizedBox(width: 6.w),
              Text(
                paymentMethod == PaymentMethod.wallet
                    ? 'Wallet Balance'
                    : 'Credit Card / Bank Transfer',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: ECardoTokens.brand700(context),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}

String get localization => AppLocalizations.of(Get.context)!;
