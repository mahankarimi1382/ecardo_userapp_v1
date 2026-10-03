import 'dart:convert';
import 'dart:io' show File;
import 'dart:math' as math;
import 'dart:ui' as ui show ImageByteFormat;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Transaction status for the digital receipt header badge.
enum ReceiptStatus {
  success,
  pending,
  failed,
}

/// Structured key-value row for the receipt body.
class ReceiptRowData {
  final String label;
  final String? value;
  final double? amount;
  final int? decimals;
  final String? currencyCode;
  final Color? valueColor;
  final bool isHighlighted;
  final bool isCopyable;
  final String? copyValue;
  final Widget? customValueWidget;

  const ReceiptRowData({
    required this.label,
    this.value,
    this.amount,
    this.decimals,
    this.currencyCode,
    this.valueColor,
    this.isHighlighted = false,
    this.isCopyable = false,
    this.copyValue,
    this.customValueWidget,
  });
}

/// Custom clipper that creates a modern FinTech ticket silhouette:
/// - 16px rounded outer corners
/// - Concave semicircular side notches on left and right edges at [notchY]
class TicketClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchRadius;
  final double? notchY;
  final double notchFraction;

  const TicketClipper({
    this.borderRadius = 16.0,
    this.notchRadius = 12.0,
    this.notchY,
    this.notchFraction = 0.65,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double r = borderRadius.clamp(0.0, math.min(w / 2, h / 2));
    final double nr = notchRadius.clamp(0.0, math.min(w / 4, h / 4));
    final double rawNotchY = notchY ?? (h * notchFraction);
    final double ny = rawNotchY.clamp(r + nr, h - r - nr);

    // 1. Move to start of top edge (after top-left corner)
    path.moveTo(r, 0);

    // 2. Top edge
    path.lineTo(w - r, 0);

    // 3. Top-right corner
    if (r > 0) {
      path.arcToPoint(Offset(w, r), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(w, 0);
    }

    // 4. Right edge down to notch
    path.lineTo(w, ny - nr);

    // 5. Right concave notch: curves inward to the left (into the card)
    if (nr > 0) {
      path.arcToPoint(
        Offset(w, ny + nr),
        radius: Radius.circular(nr),
        clockwise: false,
      );
    }

    // 6. Right edge down to bottom-right corner
    path.lineTo(w, h - r);

    // 7. Bottom-right corner
    if (r > 0) {
      path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(w, h);
    }

    // 8. Bottom edge to bottom-left corner
    path.lineTo(r, h);

    // 9. Bottom-left corner
    if (r > 0) {
      path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(0, h);
    }

    // 10. Left edge up to notch
    path.lineTo(0, ny + nr);

    // 11. Left concave notch: curves inward to the right (into the card)
    if (nr > 0) {
      path.arcToPoint(
        Offset(0, ny - nr),
        radius: Radius.circular(nr),
        clockwise: false,
      );
    }

    // 12. Left edge up to top-left corner
    path.lineTo(0, r);

    // 13. Top-left corner
    if (r > 0) {
      path.arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true);
    } else {
      path.lineTo(0, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      oldClipper.borderRadius != borderRadius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchY != notchY ||
      oldClipper.notchFraction != notchFraction;
}

/// Paints a solid background, subtle drop shadow, and outline border
/// tracing the exact silhouette of [TicketClipper].
class TicketBorderPainter extends CustomPainter {
  final double borderRadius;
  final double notchRadius;
  final double? notchY;
  final double notchFraction;
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;
  final bool drawShadow;

  const TicketBorderPainter({
    this.borderRadius = 16.0,
    this.notchRadius = 12.0,
    this.notchY,
    this.notchFraction = 0.65,
    this.borderColor = const Color(0x1F161614),
    this.borderWidth = 1.0,
    this.fillColor = Colors.white,
    this.drawShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = TicketClipper(
      borderRadius: borderRadius,
      notchRadius: notchRadius,
      notchY: notchY,
      notchFraction: notchFraction,
    );
    final path = clipper.getClip(size);

    if (drawShadow) {
      canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: 0.08),
        8.0,
        true,
      );
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(TicketBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.notchRadius != notchRadius ||
      oldDelegate.notchY != notchY ||
      oldDelegate.notchFraction != notchFraction ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.drawShadow != drawShadow;
}

/// Custom painter that draws a clean, dashed perforated line between
/// the two concave ticket notches.
class PerforatedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final double padding;

  const PerforatedLinePainter({
    this.color = const Color(0xFFD5CBC8),
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.2,
    this.padding = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startX = padding;
    final endX = size.width - padding;
    final y = size.height / 2;

    while (startX < endX) {
      final currentDashWidth = math.min(dashWidth, endX - startX);
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + currentDashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(PerforatedLinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.padding != padding;
}

/// Modern FinTech ticket-style receipt widget with:
/// - Rounded notched ticket clipper & perforated dashed tear line
/// - Header with eCardo branding, status pill badge, and date
/// - Prominent hero amount and detailed key-value rows
/// - Barcode (Code128) & verifiable QR Code
/// - Integrated high-res PNG sharing and PDF download/print action bar
class DigitalReceiptTicket extends StatefulWidget {
  final String title;
  final ReceiptStatus status;
  final String? transactionId;
  final DateTime? dateTime;
  final String? formattedDateTime;
  final double? primaryAmount;
  final String? primaryCurrency;
  final int primaryDecimals;
  final double? fee;
  final String? feeCurrency;
  final int feeDecimals;
  final String? fromAccount;
  final String? toAccount;
  final String? exchangeRate;
  final List<ReceiptRowData>? extraRows;
  final Map<String, dynamic>? qrPayload;
  final bool showBarcode;
  final bool showQrCode;
  final bool showActions;
  final VoidCallback? onShareCustom;
  final VoidCallback? onDownloadPdfCustom;

  const DigitalReceiptTicket({
    super.key,
    required this.title,
    this.status = ReceiptStatus.success,
    this.transactionId,
    this.dateTime,
    this.formattedDateTime,
    this.primaryAmount,
    this.primaryCurrency,
    this.primaryDecimals = 2,
    this.fee,
    this.feeCurrency,
    this.feeDecimals = 2,
    this.fromAccount,
    this.toAccount,
    this.exchangeRate,
    this.extraRows,
    this.qrPayload,
    this.showBarcode = true,
    this.showQrCode = true,
    this.showActions = true,
    this.onShareCustom,
    this.onDownloadPdfCustom,
  });

  @override
  State<DigitalReceiptTicket> createState() => _DigitalReceiptTicketState();
}

class _DigitalReceiptTicketState extends State<DigitalReceiptTicket> {
  final GlobalKey _ticketRepaintKey = GlobalKey();
  final GlobalKey _ticketContainerKey = GlobalKey();
  final GlobalKey _separatorKey = GlobalKey();

  double? _measuredNotchY;
  bool _isSharing = false;
  bool _isGeneratingPdf = false;

  static const double _notchRadius = 12.0;
  static const double _borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNotchPosition());
  }

  @override
  void didUpdateWidget(DigitalReceiptTicket oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNotchPosition());
  }

  void _measureNotchPosition() {
    if (!mounted) return;
    final separatorBox = _separatorKey.currentContext?.findRenderObject() as RenderBox?;
    final ticketBox = _ticketContainerKey.currentContext?.findRenderObject() as RenderBox?;

    if (separatorBox != null && ticketBox != null && separatorBox.hasSize && ticketBox.hasSize) {
      final offset = separatorBox.localToGlobal(Offset.zero, ancestor: ticketBox);
      final calculatedY = offset.dy + (separatorBox.size.height / 2);
      if (_measuredNotchY == null || (_measuredNotchY! - calculatedY).abs() > 0.5) {
        setState(() {
          _measuredNotchY = calculatedY;
        });
      }
    }
  }

  String _resolveDateTimeString(BuildContext context) {
    if (widget.formattedDateTime != null && widget.formattedDateTime!.isNotEmpty) {
      return widget.formattedDateTime!;
    }
    final dt = widget.dateTime ?? DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fa') {
      return JalaliDateHelper.formatDateTime(dt);
    }
    try {
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (_) {
      return dt.toIso8601String();
    }
  }

  String _formatAmount(double amount, int decimals) {
    final formatter = NumberFormat.currency(
      decimalDigits: decimals,
      symbol: '',
    );
    return formatter.format(amount).trim();
  }

  Map<String, dynamic> _buildDefaultQrPayload() {
    return {
      'iss': 'eCardo',
      'tnx': widget.transactionId ?? '',
      if (widget.primaryAmount != null) 'amount': widget.primaryAmount,
      if (widget.primaryCurrency != null) 'currency': widget.primaryCurrency,
      if (widget.dateTime != null) 'timestamp': widget.dateTime!.toIso8601String(),
      'status': widget.status.name,
    };
  }

  String _generateBarcodeSvg(String rawReference) {
    final ref = rawReference.trim().isEmpty ? 'ECAR-00000000' : rawReference.trim();
    try {
      final barcode = Barcode.code128();
      return barcode.toSvg(
        ref,
        width: 240,
        height: 48,
        drawText: false,
      );
    } catch (e) {
      debugPrint('Barcode generation fallback: $e');
      try {
        return Barcode.code39().toSvg(ref, width: 240, height: 48, drawText: false);
      } catch (_) {
        return '<svg width="240" height="48"></svg>';
      }
    }
  }

  String _generateQrSvg(Map<String, dynamic> payload) {
    try {
      final data = jsonEncode(payload);
      final qr = Barcode.qrCode();
      return qr.toSvg(
        data,
        width: 120,
        height: 120,
      );
    } catch (e) {
      debugPrint('QR generation error: $e');
      try {
        return Barcode.qrCode().toSvg('eCardo-Receipt', width: 120, height: 120);
      } catch (_) {
        return '<svg width="120" height="120"></svg>';
      }
    }
  }

  List<ReceiptRowData> _collectAllRows(BuildContext context) {
    final list = <ReceiptRowData>[];

    // Transaction ID
    if (widget.transactionId != null && widget.transactionId!.isNotEmpty) {
      list.add(
        ReceiptRowData(
          label: l10nPick(
            context,
            en: 'Transaction ID',
            fa: 'شناسه تراکنش',
            ar: 'معرف المعاملة',
            zh: '交易编号',
          ),
          value: widget.transactionId,
          isCopyable: true,
          copyValue: widget.transactionId,
        ),
      );
    }

    // From Account / Wallet
    if (widget.fromAccount != null && widget.fromAccount!.isNotEmpty) {
      list.add(
        ReceiptRowData(
          label: l10nPick(
            context,
            en: 'From Wallet',
            fa: 'از کیف پول',
            ar: 'من محفظة',
            zh: '付款钱包',
          ),
          value: widget.fromAccount,
        ),
      );
    }

    // To Account / Recipient
    if (widget.toAccount != null && widget.toAccount!.isNotEmpty) {
      list.add(
        ReceiptRowData(
          label: l10nPick(
            context,
            en: 'To Wallet',
            fa: 'به کیف پول',
            ar: 'إلى محفظة',
            zh: '收款钱包',
          ),
          value: widget.toAccount,
        ),
      );
    }

    // Exchange Rate
    if (widget.exchangeRate != null && widget.exchangeRate!.isNotEmpty) {
      list.add(
        ReceiptRowData(
          label: l10nPick(
            context,
            en: 'Exchange Rate',
            fa: 'نرخ تبادل',
            ar: 'سعر الصرف',
            zh: '兑换汇率',
          ),
          value: widget.exchangeRate,
        ),
      );
    }

    // Fee / Charge
    if (widget.fee != null) {
      list.add(
        ReceiptRowData(
          label: l10nPick(
            context,
            en: 'Fee / Charge',
            fa: 'کارمزد تراکنش',
            ar: 'الرسوم',
            zh: '手续费',
          ),
          amount: widget.fee,
          decimals: widget.feeDecimals,
          currencyCode: widget.feeCurrency ?? widget.primaryCurrency,
          valueColor: AppColors.warning,
        ),
      );
    }

    // Extra Rows
    if (widget.extraRows != null && widget.extraRows!.isNotEmpty) {
      list.addAll(widget.extraRows!);
    }

    return list;
  }

  Future<void> _shareReceiptAsImage() async {
    if (widget.onShareCustom != null) {
      widget.onShareCustom!();
      return;
    }

    if (_isSharing) return;
    HapticFeedback.selectionClick();
    setState(() => _isSharing = true);

    try {
      final boundary = _ticketRepaintKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        if (mounted) {
          ToastHelper().showErrorToast(
            l10nPick(
              context,
              en: 'Could not capture receipt image',
              fa: 'خطا در ثبت تصویر رسید',
              ar: 'تعذر التقاط صورة الإيصال',
              zh: '无法截取收据图像',
            ),
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final tnx = widget.transactionId ?? 'tx';
      final file = File(
        '${tempDir.path}/ecardo_receipt_${tnx}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());

      final shareText = l10nPick(
        context,
        en: 'eCardo Digital Receipt - ${widget.title} ($tnx)',
        fa: 'رسید دیجیتال eCardo - ${widget.title} ($tnx)',
        ar: 'إيصال eCardo الرقمي - ${widget.title} ($tnx)',
        zh: 'eCardo 电子凭证 - ${widget.title} ($tnx)',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: shareText,
          subject: 'eCardo Receipt',
        ),
      );
    } catch (e) {
      debugPrint('Share image failed: $e');
      if (mounted) {
        ToastHelper().showErrorToast(
          l10nPick(
            context,
            en: 'Could not share the receipt',
            fa: 'اشتراک‌گذاری رسید ناموفق بود',
            ar: 'تعذرت مشاركة الإيصال',
            zh: '分享凭证失败',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _exportPdf() async {
    if (widget.onDownloadPdfCustom != null) {
      widget.onDownloadPdfCustom!();
      return;
    }

    if (_isGeneratingPdf) return;
    HapticFeedback.selectionClick();
    setState(() => _isGeneratingPdf = true);

    try {
      final locale = Localizations.localeOf(context);
      final isRtl = const {'fa', 'ar'}.contains(locale.languageCode);

      final fontAsset = switch (locale.languageCode) {
        'fa' || 'ar' => 'assets/fonts/Vazirmatn-Regular.ttf',
        'ru' || 'zh' => 'assets/fonts/NotoSans-Regular.ttf',
        _ => 'assets/fonts/PlusJakartaSans-VariableFont_wght.ttf',
      };

      pw.Font font;
      try {
        final fontData = await rootBundle.load(fontAsset);
        font = pw.Font.ttf(fontData);
      } catch (e) {
        debugPrint('PDF font loading fallback: $e');
        font = pw.Font.helvetica();
      }

      final doc = pw.Document();

      final PdfColor statusColor = switch (widget.status) {
        ReceiptStatus.success => PdfColor.fromInt(0xFF14AE6F),
        ReceiptStatus.pending => PdfColor.fromInt(0xFFFFAA00),
        ReceiptStatus.failed => PdfColor.fromInt(0xFFDC3C22),
      };
      final PdfColor statusBgColor = switch (widget.status) {
        ReceiptStatus.success => PdfColor.fromInt(0xFFE8F8F0),
        ReceiptStatus.pending => PdfColor.fromInt(0xFFFFF8E1),
        ReceiptStatus.failed => PdfColor.fromInt(0xFFFDECEA),
      };
      final String statusText = switch (widget.status) {
        ReceiptStatus.success => l10nPick(context, en: 'SUCCESS', fa: 'موفق', ar: 'ناجح', zh: '成功'),
        ReceiptStatus.pending => l10nPick(context, en: 'PENDING', fa: 'در انتظار', ar: 'قيد الانتظار', zh: '处理中'),
        ReceiptStatus.failed => l10nPick(context, en: 'FAILED', fa: 'ناموفق', ar: 'فشل', zh: '失败'),
      };

      final allRows = _collectAllRows(context);
      final qrData = jsonEncode(widget.qrPayload ?? _buildDefaultQrPayload());
      final tnx = widget.transactionId ?? '';
      final formattedDate = _resolveDateTimeString(context);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
          theme: pw.ThemeData.withFont(base: font, bold: font),
          build: (pwContext) {
            return pw.Directionality(
              textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Top Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Column(
                        crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'eCardo',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF161614),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            l10nPick(
                              context,
                              en: 'International Financial Super App',
                              fa: 'سوپراپلیکیشن مالی بین‌المللی',
                              ar: 'التطبيق المالي الرقمي الشامل',
                              zh: '国际金融超级应用',
                            ),
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: statusBgColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                          border: pw.Border.all(color: statusColor, width: 0.8),
                        ),
                        child: pw.Text(
                          statusText,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 14),
                  pw.Divider(color: PdfColors.grey300, thickness: 0.8),
                  pw.SizedBox(height: 14),

                  // Hero Section
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          widget.title,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        if (widget.primaryAmount != null) ...[
                          pw.SizedBox(height: 6),
                          pw.Text(
                            '${_formatAmount(widget.primaryAmount!, widget.primaryDecimals)} ${widget.primaryCurrency ?? ''}',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF161614),
                            ),
                          ),
                        ],
                        if (formattedDate.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            formattedDate,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Key-value rows table
                  ...allRows.map(
                    (row) {
                      String rowValue = row.value ?? '';
                      if (row.amount != null && row.decimals != null) {
                        rowValue = '${_formatAmount(row.amount!, row.decimals!)} ${row.currencyCode ?? ''}';
                      }
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.6),
                          ),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              row.label,
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                            ),
                            pw.Text(
                              rowValue,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: row.isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
                                color: PdfColor.fromInt(0xFF161614),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  pw.Spacer(),

                  // QR Code & Barcode
                  pw.Center(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (qrData.isNotEmpty) ...[
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                            ),
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: qrData,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          pw.SizedBox(width: 24),
                        ],
                        if (tnx.isNotEmpty) ...[
                          pw.Column(
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.code128(),
                                data: tnx,
                                width: 170,
                                height: 40,
                                drawText: false,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                tnx,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 14),

                  pw.Text(
                    l10nPick(
                      context,
                      en: 'Official eCardo Digital Transaction Receipt - Cryptographically Verifiable',
                      fa: 'رسید رسمی تراکنش دیجیتال eCardo - دارای اعتبار و اصالت‌سنجی رمزنگاری‌شده',
                      ar: 'إيصال رسمي لمعاملة رقمية عبر eCardo - معتمد برمجياً',
                      zh: 'eCardo官方电子交易凭证 - 具备加密验证',
                    ),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await doc.save();
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'ecardo-receipt-${tnx.isNotEmpty ? tnx : "tx"}.pdf',
      );
    } catch (e) {
      debugPrint('PDF export failed: $e');
      if (mounted) {
        ToastHelper().showErrorToast(
          l10nPick(
            context,
            en: 'Failed to generate PDF receipt',
            fa: 'خطا در ایجاد فایل PDF رسید',
            ar: 'فشل في إنشاء ملف PDF للإيصال',
            zh: '生成PDF凭单失败',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _collectAllRows(context);
    final formattedDate = _resolveDateTimeString(context);
    final tnx = widget.transactionId ?? '';
    final qrData = widget.qrPayload ?? _buildDefaultQrPayload();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // RepaintBoundary isolates the ticket card for high-resolution PNG export
        RepaintBoundary(
          key: _ticketRepaintKey,
          child: CustomPaint(
            key: _ticketContainerKey,
            painter: TicketBorderPainter(
              borderRadius: _borderRadius,
              notchRadius: _notchRadius,
              notchY: _measuredNotchY,
              borderColor: AppColors.lightBorder.withValues(alpha: 0.8),
              borderWidth: 1.0,
              fillColor: AppColors.white,
              drawShadow: true,
            ),
            child: ClipPath(
              clipper: TicketClipper(
                borderRadius: _borderRadius,
                notchRadius: _notchRadius,
                notchY: _measuredNotchY,
              ),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Section
                    _buildHeader(context, formattedDate),
                    const SizedBox(height: 18),

                    // 2. Hero Amount Section
                    if (widget.primaryAmount != null) ...[
                      _buildHeroAmount(),
                      const SizedBox(height: 16),
                    ],

                    // 3. Body Key-Value Rows
                    if (rows.isNotEmpty) ...[
                      ...rows.map((row) => _buildRowWidget(context, row)),
                    ],

                    // 4. Perforated Notch Separator
                    const SizedBox(height: 8),
                    Container(
                      key: _separatorKey,
                      height: _notchRadius * 2,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: const Size(double.infinity, 2),
                        painter: PerforatedLinePainter(
                          color: AppColors.lightDivider,
                          dashWidth: 6.0,
                          dashSpace: 4.0,
                          strokeWidth: 1.2,
                          padding: _notchRadius + 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 5. Barcode & QR Code Section
                    if (widget.showBarcode || widget.showQrCode) ...[
                      _buildBarcodeAndQrSection(context, tnx, qrData),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Action Bar (outside RepaintBoundary so exported PNG remains pure ticket)
        if (widget.showActions) ...[
          const SizedBox(height: 20),
          _buildActionBar(context),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // eCardo Brand Logo & Name
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/logos/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'eCardo',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            // Status Badge Pill
            _buildStatusBadge(context),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextSecondary,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (formattedDate.isNotEmpty)
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightTextTertiary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (bgColor, borderColor, textColor, icon, label) = switch (widget.status) {
      ReceiptStatus.success => (
          AppColors.successContainer,
          AppColors.success.withValues(alpha: 0.35),
          AppColors.success,
          Icons.check_circle_rounded,
          l10nPick(context, en: 'Success', fa: 'موفق', ar: 'ناجح', zh: '成功'),
        ),
      ReceiptStatus.pending => (
          AppColors.warningContainer,
          AppColors.warning.withValues(alpha: 0.35),
          AppColors.warning,
          Icons.schedule_rounded,
          l10nPick(context, en: 'Pending', fa: 'در انتظار', ar: 'قيد الانتظار', zh: '处理中'),
        ),
      ReceiptStatus.failed => (
          AppColors.errorContainer,
          AppColors.error.withValues(alpha: 0.35),
          AppColors.error,
          Icons.cancel_rounded,
          l10nPick(context, en: 'Failed', fa: 'ناموفق', ar: 'فشل', zh: '失败'),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAmount() {
    final formatted = _formatAmount(widget.primaryAmount!, widget.primaryDecimals);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            integerPart,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.lightTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (decimalPart.isNotEmpty)
            Text(
              '.$decimalPart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.55),
              ),
            ),
          if (widget.primaryCurrency != null && widget.primaryCurrency!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.primaryCurrency!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRowWidget(BuildContext context, ReceiptRowData row) {
    String valueText = row.value ?? '';
    if (row.amount != null && row.decimals != null) {
      valueText = '${_formatAmount(row.amount!, row.decimals!)} ${row.currencyCode ?? ''}'.trim();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 4,
            child: Text(
              row.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.lightTextTertiary,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: row.customValueWidget ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        valueText,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: row.isHighlighted ? FontWeight.w900 : FontWeight.w700,
                          fontSize: row.isHighlighted ? 15 : 13,
                          color: row.valueColor ?? AppColors.lightTextPrimary,
                          letterSpacing: row.isCopyable ? 0.5 : 0,
                          fontFamily: row.isCopyable ? 'monospace' : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (row.isCopyable) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          final textToCopy = row.copyValue ?? valueText;
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          ToastHelper().showSuccessToast(
                            l10nPick(
                              context,
                              en: 'Copied to clipboard',
                              fa: 'در حافظه کپی شد',
                              ar: 'تم النسخ إلى الحافظة',
                              zh: '已复制到剪贴板',
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeAndQrSection(
    BuildContext context,
    String tnx,
    Map<String, dynamic> qrData,
  ) {
    return Column(
      children: [
        if (widget.showQrCode) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: SvgPicture.string(
              _generateQrSvg(qrData),
              width: 110,
              height: 110,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.showBarcode && tnx.isNotEmpty) ...[
          SvgPicture.string(
            _generateBarcodeSvg(tnx),
            height: 42,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tnx,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  letterSpacing: 2.0,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Clipboard.setData(ClipboardData(text: tnx));
                  ToastHelper().showSuccessToast(
                    l10nPick(
                      context,
                      en: 'Transaction reference copied',
                      fa: 'شناسه پیگیری کپی شد',
                      ar: 'تم نسخ الرقم المرجعي',
                      zh: '交易参考编号已复制',
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 13,
              color: AppColors.lightTextTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              l10nPick(
                context,
                en: 'Scan QR to verify on eCardo network',
                fa: 'جهت اعتبارسنجی رسید، بارکد را اسکن کنید',
                ar: 'امسح الرمز للتحقق من شبكة eCardo',
                zh: '扫描二维码验证凭证真伪',
              ),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      children: [
        // Share PNG image button
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(
                color: AppColors.lightPrimary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              backgroundColor: AppColors.white,
            ),
            onPressed: _isSharing ? null : _shareReceiptAsImage,
            icon: _isSharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.lightPrimary,
                  ),
            label: Text(
              l10nPick(
                context,
                en: 'Share Image',
                fa: 'اشتراک تصویر',
                ar: 'مشاركة الصورة',
                zh: '分享图片',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.lightPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Download / Print PDF button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: AppColors.deepBlack,
              elevation: 0,
            ),
            onPressed: _isGeneratingPdf ? null : _exportPdf,
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
            label: Text(
              l10nPick(
                context,
                en: 'PDF Receipt',
                fa: 'رسید PDF',
                ar: 'إيصال PDF',
                zh: 'PDF凭单',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
