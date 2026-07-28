import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

import '../core/controller/travel_controller.dart';
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
            isSuccessful ? localization.travelPurchaseSuccessful : statusText,
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
            TravelVoucherCard(order: order),
            SizedBox(height: 16.h),
            CommonButton(
              width: double.infinity,
              text: localization.qrCodeScreenDownloadButton,
              backgroundColor: travelProductColor(order.type),
              onPressed: () => downloadTravelVoucher(context, order),
            ),
          ],
          if (_canRequestTravelRefund(order)) ...[
            SizedBox(height: 12.h),
            Obx(() {
              final controller = Get.find<TravelController>();
              return CommonButton(
                width: double.infinity,
                text: order.details['raw_status'] == 'voucher_generated'
                    ? 'Request refund'
                    : 'Cancel booking',
                backgroundColor: Colors.white,
                textColor: TravelTheme.red,
                borderColor: TravelTheme.red,
                borderWidth: 1,
                isLoading: controller.isCheckoutLoading.value,
                loadingColor: TravelTheme.red,
                onPressed: () => _showRefundRequestDialog(context, order),
              );
            }),
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

class TravelVoucherCard extends StatelessWidget {
  final TravelOrder order;
  final double qrSize;
  final bool compact;

  const TravelVoucherCard({
    super.key,
    required this.order,
    this.qrSize = 190,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final entries = travelVoucherEntries(context, order);
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            localization.qrCodeScreenTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 13.sp : 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14.h),
          Center(
            child: TravelVoucherQr(order: order, size: qrSize),
          ),
          SizedBox(height: 10.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              order.reference,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
          ),
          if (!compact) ...[
            SizedBox(height: 18.h),
            const Divider(),
            ...entries.map(
              (entry) => _VoucherDetailRow(
                label: entry.label,
                value: entry.value,
                forceLtr: entry.forceLtr,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TravelVoucherQr extends StatelessWidget {
  final TravelOrder order;
  final double size;

  const TravelVoucherQr({super.key, required this.order, required this.size});

  @override
  Widget build(BuildContext context) {
    final svg = Barcode.qrCode().toSvg(
      travelVoucherData(order),
      width: size,
      height: size,
      drawText: false,
    );
    return Container(
      width: size + 20.r,
      height: size + 20.r,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: SvgPicture.string(svg),
    );
  }
}

class TravelVoucherEntry {
  final String label;
  final String value;
  final bool forceLtr;

  const TravelVoucherEntry({
    required this.label,
    required this.value,
    this.forceLtr = false,
  });
}

List<TravelVoucherEntry> travelVoucherEntries(
  BuildContext context,
  TravelOrder order,
) {
  final localization = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final entries = <TravelVoucherEntry>[
    TravelVoucherEntry(
      label: localization.travelReference,
      value: order.reference,
      forceLtr: true,
    ),
    TravelVoucherEntry(
      label: localization.travelStatus,
      value: _travelOrderStatusText(localization, order.status),
    ),
    TravelVoucherEntry(
      label: 'Purchase date',
      value: DateFormat.yMMMd(
        locale,
      ).add_Hm().format(order.createdAt.toLocal()),
      forceLtr: true,
    ),
    TravelVoucherEntry(
      label: localization.travelPaidAmount,
      value: travelMoney(context, order.total),
      forceLtr: true,
    ),
  ];
  const hiddenDetails = {'raw_status', 'approval_status', 'gateway_status'};
  for (final detail in order.details.entries) {
    final value = detail.value.trim();
    if (value.isEmpty || hiddenDetails.contains(detail.key)) continue;
    entries.add(
      TravelVoucherEntry(
        label: _voucherLabel(detail.key),
        value: value,
        forceLtr: _voucherValueIsLtr(detail.key),
      ),
    );
  }
  return entries;
}

String travelVoucherData(TravelOrder order) => [
  'ecardo-travel',
  order.id,
  order.reference,
  order.type.name,
  order.total.amount.toString(),
  order.total.currency,
  order.details['voucher_number'] ?? '',
  order.details['supplier_reference'] ?? '',
].join('|');

String _travelOrderStatusText(
  AppLocalizations localization,
  TravelOrderStatus status,
) => switch (status) {
  TravelOrderStatus.pending => localization.travelPendingConfirmation,
  TravelOrderStatus.active => localization.travelActive,
  TravelOrderStatus.confirmed => localization.travelConfirmed,
  TravelOrderStatus.completed => localization.travelCompleted,
  TravelOrderStatus.refunded => localization.travelRefunded,
  TravelOrderStatus.failed => localization.travelFailed,
};

String _voucherLabel(String key) {
  const labels = {
    'supplier_reference': 'Supplier reference',
    'booking_number': 'Booking number',
    'voucher_number': 'Voucher number',
    'voucher_issued_at': 'Voucher issued',
    'check_in': 'Check-in',
    'check_out': 'Check-out',
    'room': 'Room',
    'room_count': 'Rooms',
    'adult_count': 'Adults',
    'child_count': 'Children',
    'board_type': 'Board',
    'cancellation_policy': 'Cancellation policy',
    'beneficiary': 'Passenger / beneficiary',
    'origin': 'Origin',
    'destination': 'Destination',
    'departure': 'Departure',
    'arrival': 'Arrival',
    'flight_number': 'Flight number',
    'airline': 'Airline',
    'cabin': 'Cabin',
    'baggage': 'Baggage',
  };
  return labels[key] ??
      key
          .split('_')
          .where((part) => part.isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' ');
}

bool _voucherValueIsLtr(String key) => {
  'supplier_reference',
  'booking_number',
  'voucher_number',
  'voucher_issued_at',
  'check_in',
  'check_out',
  'departure',
  'arrival',
  'flight_number',
}.contains(key);

bool _canRequestTravelRefund(TravelOrder order) =>
    order.type != TravelProductType.esim &&
    {'booked', 'voucher_generated'}.contains(order.details['raw_status']);

Future<void> _showRefundRequestDialog(
  BuildContext context,
  TravelOrder order,
) async {
  final controller = Get.find<TravelController>();
  final noteController = TextEditingController();
  var reasonCode = 'TRIP_CHANGED';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          order.details['raw_status'] == 'voucher_generated'
              ? 'Request refund'
              : 'Cancel booking',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This sends a request for review. Cancellation and refund are not immediate, and supplier penalties may apply.',
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                initialValue: reasonCode,
                decoration: const InputDecoration(labelText: 'Reason'),
                items: const [
                  DropdownMenuItem(
                    value: 'TRIP_CHANGED',
                    child: Text('Travel plans changed'),
                  ),
                  DropdownMenuItem(
                    value: 'BOOKING_MISTAKE',
                    child: Text('Booking mistake'),
                  ),
                  DropdownMenuItem(
                    value: 'PERSONAL_REASON',
                    child: Text('Personal reason'),
                  ),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (value) =>
                    setState(() => reasonCode = value ?? reasonCode),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteController,
                maxLength: 1000,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Additional note (optional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Submit request'),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) {
    noteController.dispose();
    return;
  }
  final updatedOrder = await controller.requestRefund(
    order: order,
    reasonCode: reasonCode,
    customerNote: noteController.text,
  );
  noteController.dispose();
  if (!context.mounted) return;
  if (updatedOrder == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'The booking cannot be cancelled from its current state.',
        ),
      ),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Your cancellation and refund request is awaiting review.'),
    ),
  );
  await Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => TravelConfirmationScreen(order: updatedOrder),
    ),
  );
}

Future<void> downloadTravelVoucher(
  BuildContext context,
  TravelOrder order,
) async {
  final locale = Localizations.localeOf(context);
  final isRtl = const {'fa', 'ar'}.contains(locale.languageCode);
  final voucherEntries = travelVoucherEntries(context, order);
  final voucherData = travelVoucherData(order);
  final fontAsset = switch (locale.languageCode) {
    'fa' || 'ar' => 'assets/fonts/Vazirmatn-Regular.ttf',
    'zh' => 'assets/fonts/LemiZhiXiaQianFeng-Regular.ttf',
    'ru' => 'assets/fonts/NotoSans-Regular.ttf',
    _ => 'assets/fonts/PlusJakartaSans-Medium.ttf',
  };
  final fontData = await rootBundle.load(fontAsset);
  final font = pw.Font.ttf(fontData);
  final document = pw.Document();
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
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            _voucherRow('Product', order.titleKey),
            ...voucherEntries.map(
              (entry) => _voucherRow(entry.label, entry.value),
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

class _VoucherDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool forceLtr;

  const _VoucherDetailRow({
    required this.label,
    required this.value,
    required this.forceLtr,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      textAlign: TextAlign.end,
      style: TextStyle(
        color: TravelTheme.ink,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: forceLtr
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: valueWidget,
                  )
                : valueWidget,
          ),
        ],
      ),
    );
  }
}

pw.Widget _voucherRow(String label, String value) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 9),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
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
