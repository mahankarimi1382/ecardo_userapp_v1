import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';

/// International-Grade Hotel Voucher Screen with QR Code,
/// booking reference, check-in time, contact details, and downloadable PDF voucher.
class HotelVoucherScreen extends StatefulWidget {
  final String orderId;
  final String bookingReference;
  final String hotelTitle;
  final String hotelAddress;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final List<TravelSelectedRoom> selectedRooms;
  final double totalAmount;
  final String currency;
  final int nights;
  final String? specialRequests;

  const HotelVoucherScreen({
    super.key,
    required this.orderId,
    this.bookingReference = 'EC-HTL-849201',
    required this.hotelTitle,
    required this.hotelAddress,
    this.guestName = 'Primary Guest',
    this.guestEmail = 'guest@ecardo.com',
    this.guestPhone = '+1 555-0199',
    required this.checkInDate,
    required this.checkOutDate,
    required this.selectedRooms,
    required this.totalAmount,
    required this.currency,
    required this.nights,
    this.specialRequests,
  });

  @override
  State<HotelVoucherScreen> createState() => _HotelVoucherScreenState();
}

class _HotelVoucherScreenState extends State<HotelVoucherScreen> {
  bool _isGeneratingPdf = false;

  String get _refCode =>
      widget.bookingReference.isNotEmpty ? widget.bookingReference : 'EC-HTL-${widget.orderId.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)}';

  Future<void> _exportPdfVoucher() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final doc = pw.Document();
      final qrSvg = Barcode.qrCode().toSvg(
        'ECARDO:HOTEL:${_refCode}:${widget.orderId}',
        width: 100,
        height: 100,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // PDF Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('0B3B33'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'eCardo Travel Official Voucher',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Booking Reference: $_refCode',
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('D9A94A'),
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('15713F'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'CONFIRMED & PAID',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Hotel Details & QR Code
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            widget.hotelTitle,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            widget.hotelAddress,
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                          ),
                          pw.SizedBox(height: 12),
                          pw.Text(
                            'Lead Guest: ${widget.guestName}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Contact: ${widget.guestEmail} | ${widget.guestPhone}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 90,
                      height: 90,
                      child: pw.SvgImage(svg: qrSvg),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 12),

                // Stay Dates Table
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Check-in Date & Time', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '${widget.checkInDate.year}/${widget.checkInDate.month.toString().padLeft(2, '0')}/${widget.checkInDate.day.toString().padLeft(2, '0')} (From 14:00)',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Check-out Date & Time', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '${widget.checkOutDate.year}/${widget.checkOutDate.month.toString().padLeft(2, '0')}/${widget.checkOutDate.day.toString().padLeft(2, '0')} (Until 12:00)',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Duration', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                          pw.SizedBox(height: 2),
                          pw.Text('${widget.nights} Nights', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 12),

                // Reserved Rooms
                pw.Text(
                  'Reserved Accommodation',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...widget.selectedRooms.map((room) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${room.quantity}x ${room.name}', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          '${room.currency} ${(room.unitPrice * room.quantity * widget.nights).toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 8),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Paid (Taxes & Fees Included)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      '${widget.currency} ${widget.totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('11564A'),
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer Notice
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('E7ECE8'),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    'Important: Present this digital voucher or printed copy alongside a valid government-issued photo ID upon check-in. In case of late arrival after 20:00, kindly contact the hotel front desk.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'hotel-voucher-${_refCode}.pdf',
      );
    } catch (_) {
      Get.snackbar(
        'Voucher PDF',
        'Could not export PDF voucher. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final qrSvg = Barcode.qrCode().toSvg(
      'ECARDO:HOTEL:${_refCode}:${widget.orderId}',
      width: 140,
      height: 140,
    );

    return TravelPage(
      title: isRtl ? 'واچر رزرو هتل' : 'Hotel Booking Voucher',
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          children: [
            // Status Header Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space5.r),
              decoration: BoxDecoration(
                color: ECardoTokens.brand900(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radius2xl),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.successBg(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14.sp,
                              color: ECardoTokens.success(context),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isRtl ? 'رزرو تایید شده' : 'Confirmed & Paid',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: ECardoTokens.success(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'eCardo Travel',
                        style: TextStyle(
                          color: ECardoTokens.sand400(context),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isRtl ? 'کد پیگیری رزرو' : 'Booking Reference',
                    style: TextStyle(
                      color: ECardoTokens.inkOnBrandMuted(context),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _refCode,
                      style: TextStyle(
                        color: ECardoTokens.inkOnBrand,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Express QR Code Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space5.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  Text(
                    isRtl ? 'کیوآرکد پذیرش سریع در هتل' : 'Express Desk Check-in QR Code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isRtl
                        ? 'این کد را در بدو ورود به مسئول پذیرش هتل نشان دهید'
                        : 'Present this QR code at front desk upon arrival',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(color: ECardoTokens.border(context)),
                    ),
                    child: SvgPicture.string(
                      qrSvg,
                      width: 140.r,
                      height: 140.r,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Hotel & Stay Information
            Container(
              padding: EdgeInsets.all(ECardoTokens.space5.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hotel_rounded,
                          color: ECardoTokens.brand700(context),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hotelTitle,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.hotelAddress,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ECardoTokens.inkMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: ECardoTokens.border(context), height: 24.h),

                  // Dates Grid
                  Row(
                    children: [
                      Expanded(
                        child: _VoucherDateBlock(
                          label: AppLocalizations.of(context)!.hotel_check_in,
                          date: widget.checkInDate,
                          timeNotice: isRtl ? 'ساعت ۱۴:۰۰ به بعد' : 'From 14:00',
                          icon: Icons.login_rounded,
                        ),
                      ),
                      Container(
                        height: 44.h,
                        width: 1.w,
                        color: ECardoTokens.border(context),
                      ),
                      Expanded(
                        child: _VoucherDateBlock(
                          label: AppLocalizations.of(context)!.hotel_check_out,
                          date: widget.checkOutDate,
                          timeNotice: isRtl ? 'تا قبل از ۱۲:۰۰' : 'Until 12:00',
                          icon: Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),

                  Divider(color: ECardoTokens.border(context), height: 24.h),

                  // Lead Guest & Contact Details
                  Text(
                    isRtl ? 'اطلاعات مهمان اصلی' : 'Primary Guest Details',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _DetailLine(
                    icon: Icons.person_rounded,
                    label: isRtl ? 'نام مهمان:' : 'Guest Name:',
                    value: widget.guestName,
                  ),
                  _DetailLine(
                    icon: Icons.email_outlined,
                    label: isRtl ? 'ایمیل:' : 'Email:',
                    value: widget.guestEmail,
                  ),
                  _DetailLine(
                    icon: Icons.phone_outlined,
                    label: isRtl ? 'شماره تماس:' : 'Phone:',
                    value: widget.guestPhone,
                  ),

                  Divider(color: ECardoTokens.border(context), height: 24.h),

                  // Reserved Room Category
                  Text(
                    isRtl ? 'اتاق‌های رزرو شده' : 'Reserved Rooms',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...widget.selectedRooms.map((room) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${room.quantity}x ${room.name}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              travelMoney(
                                context,
                                TravelMoney(
                                  amount: room.unitPrice * room.quantity * widget.nights,
                                  currency: room.currency,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: ECardoTokens.brand700(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  Divider(color: ECardoTokens.border(context), height: 24.h),

                  // Total Paid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRtl ? 'مجموع پرداخت شده' : 'Total Paid',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          travelMoney(
                            context,
                            TravelMoney(
                              amount: widget.totalAmount,
                              currency: widget.currency,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: ECardoTokens.brand700(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Action Buttons: Download PDF Voucher & Share
            CommonButton(
              width: double.infinity,
              height: 52,
              text: isRtl ? 'دریافت فایل واچر رسمی (PDF)' : 'Download PDF Voucher',
              backgroundColor: ECardoTokens.brand900(context),
              isLoading: _isGeneratingPdf,
              onPressed: _exportPdfVoucher,
            ),
            SizedBox(height: 12.h),

            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 48.h),
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ECardoTokens.brand700(context),
                  side: BorderSide(color: ECardoTokens.border(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                  ),
                ),
                icon: const Icon(Icons.home_rounded),
                label: Text(
                  isRtl ? 'بازگشت به صفحه اصلی سفر' : 'Back to Travel Home',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _VoucherDateBlock extends StatelessWidget {
  final String label;
  final DateTime date;
  final String timeNotice;
  final IconData icon;

  const _VoucherDateBlock({
    required this.label,
    required this.date,
    required this.timeNotice,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: ECardoTokens.brand700(context)),
            SizedBox(width: 4.w),
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
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: ECardoTokens.ink(context),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          timeNotice,
          style: TextStyle(
            fontSize: 10.sp,
            color: ECardoTokens.brand700(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: ECardoTokens.inkMuted(context)),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
