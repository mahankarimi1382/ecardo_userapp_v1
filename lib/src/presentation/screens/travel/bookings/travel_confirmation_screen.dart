import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
          if (order.type != TravelProductType.esim &&
              order.status != TravelOrderStatus.failed &&
              order.status != TravelOrderStatus.refunded) ...[
            SizedBox(height: 16.h),
            CommonButton(
              width: double.infinity,
              text: localization.qrCodeScreenDownloadButton,
              backgroundColor: travelProductColor(order.type),
              onPressed: () => downloadTravelVoucher(context, order),
            ),
          ],
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

Future<void> downloadTravelVoucher(
  BuildContext context,
  TravelOrder order,
) async {
  final locale = Localizations.localeOf(context);
  final isRtl = const {'fa', 'ar'}.contains(locale.languageCode);
  final fontAsset = switch (locale.languageCode) {
    'fa' || 'ar' => 'assets/fonts/Vazirmatn-Regular.ttf',
    'zh' => 'assets/fonts/LemiZhiXiaQianFeng-Regular.ttf',
    'ru' => 'assets/fonts/NotoSans-Regular.ttf',
    _ => 'assets/fonts/PlusJakartaSans-Medium.ttf',
  };
  final fontData = await rootBundle.load(fontAsset);
  final font = pw.Font.ttf(fontData);
  final document = pw.Document();
  final voucherData = [
    'ecardo-travel',
    order.id,
    order.reference,
    order.type.name,
    order.total.amount.toString(),
    order.total.currency,
  ].join('|');
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(base: font, bold: font),
      build: (_) => pw.Directionality(
        textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              'eCardo Travel',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              order.type == TravelProductType.hotel
                  ? 'Hotel reservation voucher'
                  : 'Flight ticket voucher',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 24),
            _voucherRow('Product', order.titleKey),
            _voucherRow('Reference', order.reference),
            _voucherRow('Status', order.status.name),
            _voucherRow(
              'Paid amount',
              '${order.total.amount.toStringAsFixed(0)} ${order.total.currency}',
            ),
            ...order.details.entries.map(
              (entry) => _voucherRow(
                entry.key.replaceAll('_', ' '),
                entry.value,
              ),
            ),
            pw.Spacer(),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: voucherData,
                width: 150,
                height: 150,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              order.reference,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Present this voucher with the traveler identity document. Supplier confirmation and cancellation rules remain authoritative.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    ),
  );
  final bytes = await document.save();
  await Printing.sharePdf(
    bytes: Uint8List.fromList(bytes),
    filename: 'ecardo-${order.type.name}-${order.reference}.pdf',
  );
}

pw.Widget _voucherRow(String label, String value) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 9),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey300),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );
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
