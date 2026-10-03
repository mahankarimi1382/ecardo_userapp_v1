import 'dart:convert';
import 'package:barcode/barcode.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/guarantee_models.dart';

/// Official Digital Bank Guarantee (Letter of Guarantee - LG) Certificate Widget.
///
/// Designed with high-security aesthetics:
/// - Header: Issuing Financial Entity ("eCardo International Digital Banking & Guarantee Partner"), Official Seal watermark.
/// - Guarantee Reference Number (e.g. LG-2026-8849-IRR), issuing date, and maturity date.
/// - Beneficiary Name, Applicant Name, Purpose (Tender / Bid Bond, Performance Bond, Advance Payment).
/// - Maximum Guaranteed Amount in bold financial typography with currency symbol.
/// - Vector QR code using package:barcode/barcode.dart (Barcode.qrCode()) encoding verification URL & payload.
/// - Real-time validity badge (Valid / Active: green, Discharged / Closed: blue, Claimed: red).
/// - Print / Download PDF action button using package:printing and package:pdf.
class GuaranteeCertificateWidget extends StatelessWidget {
  final String referenceNumber;
  final String beneficiaryName;
  final String applicantName;
  final String purpose;
  final double amount;
  final String currency;
  final DateTime issueDate;
  final DateTime maturityDate;
  final String status;
  final String issuingEntity;
  final String? verificationUrl;
  final VoidCallback? onDownloadPdf;

  const GuaranteeCertificateWidget({
    super.key,
    required this.referenceNumber,
    required this.beneficiaryName,
    required this.applicantName,
    required this.purpose,
    required this.amount,
    this.currency = 'IRR',
    required this.issueDate,
    required this.maturityDate,
    required this.status,
    this.issuingEntity = 'eCardo International Digital Banking & Guarantee Partner',
    this.verificationUrl,
    this.onDownloadPdf,
  });

  /// Factory constructor to build a GuaranteeCertificateWidget directly from a GuaranteeCaseModel.
  factory GuaranteeCertificateWidget.fromCase(
    GuaranteeCaseModel caseModel, {
    Key? key,
    String? applicantName,
    VoidCallback? onDownloadPdf,
  }) {
    final issued = caseModel.issued;
    final ref = (issued != null && issued.bankRef.trim().isNotEmpty)
        ? issued.bankRef.trim()
        : 'LG-2026-${caseModel.caseNo}';
    final now = DateTime.now();
    final issue = issued?.issueDate ?? now;
    final expiry = issued?.expiryDate ?? now.add(Duration(days: (caseModel.validityMonths * 30).clamp(30, 720)));
    final purposeTitle = caseModel.instrument?.name ?? 'ضمانت‌نامه حسن انجام تعهدات (Performance Bond)';

    return GuaranteeCertificateWidget(
      key: key,
      referenceNumber: ref,
      beneficiaryName: caseModel.beneficiaryName,
      applicantName: applicantName ?? 'متقاضی حقیقی/حقوقی ایکاردو (eCardo Verified)',
      purpose: purposeTitle,
      amount: caseModel.amount,
      currency: caseModel.currency,
      issueDate: issue,
      maturityDate: expiry,
      status: caseModel.status,
      onDownloadPdf: onDownloadPdf,
    );
  }

  String get _effectiveVerificationUrl {
    if (verificationUrl != null && verificationUrl!.isNotEmpty) {
      return verificationUrl!;
    }
    final encodedRef = Uri.encodeComponent(referenceNumber);
    final encodedBen = Uri.encodeComponent(beneficiaryName);
    return 'https://verify.ecardo.ir/guarantee?ref=$encodedRef&ben=$encodedBen&amt=$amount&cur=$currency&st=$status';
  }

  /// A checksum over the fields shown, so a reader can detect an edit or a
  /// transcription slip.
  ///
  /// It is NOT a signature. It is an unkeyed SHA-256 over data the holder
  /// already has, so anyone can recompute it after changing the amount — it
  /// proves nothing about who issued the document. Presenting it as an
  /// authenticity signal overstates it; it is labelled as a checksum
  /// wherever it appears.
  String get _cryptographicFingerprint {
    final raw = '$referenceNumber|$beneficiaryName|$amount|$currency|${issueDate.toIso8601String()}|$issuingEntity';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    final hex = digest.toString().toUpperCase();
    return 'SHA256: ${hex.substring(0, 8)}...${hex.substring(hex.length - 8)}';
  }

  String _formatCurrency(double amt) {
    if (amt <= 0) return '0';
    final isInt = amt.truncateToDouble() == amt;
    final fixed = isInt ? amt.toStringAsFixed(0) : amt.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Real-time Validity Badge Configuration
  ({String labelFa, String labelEn, Color bgColor, Color textColor, Color borderColor, IconData icon})
      _getValidityBadge(BuildContext context) {
    final st = status.toUpperCase();
    if (st == 'ISSUED' || st == 'ACTIVE' || st == 'IN_FORCE') {
      return (
        labelFa: 'معتبر و نافذ (ACTIVE)',
        labelEn: 'VALID & ACTIVE',
        bgColor: const Color(0xFFE8F8F0),
        textColor: const Color(0xFF14AE6F),
        borderColor: const Color(0xFF86EFAC),
        icon: Icons.verified_rounded,
      );
    }
    if (st == 'RELEASED' || st == 'CLOSED' || st == 'DISCHARGED') {
      return (
        labelFa: 'ابطال و تسویه‌شده (DISCHARGED)',
        labelEn: 'DISCHARGED & CLOSED',
        bgColor: const Color(0xFFEFF6FF),
        textColor: const Color(0xFF2563EB),
        borderColor: const Color(0xFFBFDBFE),
        icon: Icons.task_alt_rounded,
      );
    }
    if (st == 'CLAIMED') {
      return (
        labelFa: 'مطالبه‌شده (فریز/CLAIMED)',
        labelEn: 'CLAIMED & FROZEN',
        bgColor: const Color(0xFFFEF2F2),
        textColor: const Color(0xFFDC2626),
        borderColor: const Color(0xFFFECACA),
        icon: Icons.warning_rounded,
      );
    }
    if (st == 'EXPIRED') {
      return (
        labelFa: 'منقضی‌شده (مهلت ۳۰ روزه)',
        labelEn: 'EXPIRED (WAITING PERIOD)',
        bgColor: const Color(0xFFFFFBEB),
        textColor: const Color(0xFFD97706),
        borderColor: const Color(0xFFFDE68A),
        icon: Icons.timer_outlined,
      );
    }
    // Draft or review stages
    return (
      labelFa: 'پیش‌نویس سند (DRAFT)',
      labelEn: 'PRE-ISSUANCE DRAFT',
      bgColor: const Color(0xFFF1F5F9),
      textColor: const Color(0xFF475569),
      borderColor: const Color(0xFFCBD5E1),
      icon: Icons.article_outlined,
    );
  }

  /// Generate Vector QR Code SVG string using package:barcode/barcode.dart
  String _generateVectorQrSvg(String payload) {
    try {
      final barcode = Barcode.qrCode();
      return barcode.toSvg(
        payload,
        width: 110,
        height: 110,
        drawText: false,
      );
    } catch (_) {
      return '<svg width="110" height="110"></svg>';
    }
  }

  /// Export & Print official PDF document using package:printing and package:pdf
  Future<void> _handlePrintAndDownloadPdf(BuildContext context) async {
    HapticFeedback.mediumImpact();
    if (onDownloadPdf != null) {
      onDownloadPdf!();
      return;
    }

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
      } catch (_) {
        font = pw.Font.helvetica();
      }

      final doc = pw.Document();
      final badge = _getValidityBadge(context);
      final formattedAmt = '${_formatCurrency(amount)} $currency';
      final verifyUrl = _effectiveVerificationUrl;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: font, bold: font),
          build: (pw.Context pdfContext) {
            return pw.Directionality(
              textDirection: isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.teal800, width: 2.5),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // PDF Header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              issuingEntity,
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.teal900,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'DIGITAL LETTER OF GUARANTEE',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                            pw.SizedBox(height: 2),
                            // The previous text here read "Governing Rules:
                            // URDG 758 / Central Bank Directives", asserting a
                            // regulatory framework this app has no standing
                            // under. A user submitting this to a bank relies on
                            // that claim, so it states the actual scope instead.
                            pw.Text(
                              'Issued by eCardo for record purposes. Not a '
                              'negotiable instrument under URDG 758 unless '
                              'countersigned by the issuing bank.',
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                        // Status Badge in PDF
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.teal50,
                            border: pw.Border.all(color: PdfColors.teal700),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            isRtl ? badge.labelFa : badge.labelEn,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 16),
                    pw.Divider(color: PdfColors.teal800, thickness: 1),
                    pw.SizedBox(height: 12),

                    // Certificate Title & Reference
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            isRtl ? 'گواهی‌نامه رسمی ضمانت‌نامه بانکی' : 'OFFICIAL BANK GUARANTEE CERTIFICATE',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Ref: $referenceNumber',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 18),

                    // Key Details Grid
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          _buildPdfRow(isRtl ? 'نام ذینفع:' : 'Beneficiary:', beneficiaryName),
                          pw.SizedBox(height: 6),
                          _buildPdfRow(isRtl ? 'نام متقاضی (مضمون‌عنه):' : 'Applicant:', applicantName),
                          pw.SizedBox(height: 6),
                          _buildPdfRow(isRtl ? 'موضوع و نوع ضمانت‌نامه:' : 'Purpose / Type:', purpose),
                          pw.SizedBox(height: 6),
                          _buildPdfRow(isRtl ? 'تاریخ صدور:' : 'Issue Date:', _formatDate(issueDate)),
                          pw.SizedBox(height: 6),
                          _buildPdfRow(isRtl ? 'تاریخ سررسید نهایی:' : 'Maturity Date:', _formatDate(maturityDate)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 16),

                    // Guaranteed Amount Banner
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal900,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            isRtl ? 'حداکثر سقف تعهد مالی ضمانت‌نامه' : 'MAXIMUM GUARANTEED AMOUNT',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.teal100),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            formattedAmt,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    // QR Code & Verification Block
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                isRtl
                                    ? 'استعلام آنی اصالت سند در سامانه اعتبارسنجی ایکاردو:'
                                    : 'Real-time Verification via eCardo Portal:',
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                verifyUrl,
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.blue800),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                _cryptographicFingerprint,
                                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                isRtl
                                    ? 'این ضمانت‌نامه الکترونیکی دارای ثبت قطعی و تعهد پرداخت غیرقابل برگشت عندالمطالبه است.'
                                    : 'This electronic guarantee carries unconditional and irrevocable on-demand payment obligation.',
                                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: verifyUrl,
                          width: 90,
                          height: 90,
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 12),
                    pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                    pw.SizedBox(height: 6),

                    // Signature & Stamp Note
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          // Was: "Digitally Signed & Sealed by eCardo
                          // Banking Partner (HSM RSA-4096)". No private key
                          // exists anywhere in this codebase, so that line
                          // asserted a cryptographic signature on a document
                          // users hand to banks and customs authorities. It is
                          // now labelled as what it actually is: a checksum
                          // the reader can recompute, plus a reference to
                          // check against the issuing bank's system.
                          'Unsigned summary — verify against the issuing '
                          'bank record. Bank issuance requires the bank '
                          'seal and countersignature.',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.Text(
                          'Page 1 of 1',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      final pdfBytes = await doc.save();
      await Printing.layoutPdf(
        name: 'eCardo-Guarantee-$referenceNumber.pdf',
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10nPick(
                context,
                fa: 'خطا در ایجاد یا چاپ سند PDF: ${e.toString()}',
                en: 'Error generating or printing PDF: ${e.toString()}',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getValidityBadge(context);
    final qrSvg = _generateVectorQrSvg(_effectiveVerificationUrl);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFD),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFF0F766E), width: 2.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Official Seal Watermark (Background)
            Positioned(
              right: -30.r,
              top: 50.h,
              child: Opacity(
                opacity: 0.04,
                child: Container(
                  width: 220.r,
                  height: 220.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_outlined,
                      size: 150.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // Inner Decorative Guilloche Security Border
            Container(
              margin: EdgeInsets.all(6.r),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row: Issuing Entity & Validity Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: const Color(0xFF0D9488),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issuingEntity,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F766E),
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              l10nPick(
                                context,
                                fa: 'همکار رسمی صدور ضمانت‌نامه بانکی و خدمات مالی بین‌المللی',
                                en: 'Official Digital Bank Guarantee & Escrow Partner',
                                ar: 'الشريك المصرفي الرسمي لإصدار خطابات الضمان المعتمدة',
                                zh: '官方数字保函及跨境金融授信合作机构',
                              ),
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Real-time Validity Badge
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: badge.bgColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: badge.borderColor, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badge.icon, size: 14.sp, color: badge.textColor),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(
                              context,
                              fa: badge.labelFa,
                              en: badge.labelEn,
                              ar: badge.labelFa,
                              zh: badge.labelEn,
                            ),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: badge.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Reference Number Box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            fa: 'شناسه مرجع ضمانت‌نامه (LG Ref):',
                            en: 'Guarantee Ref:',
                            ar: 'الرقم المرجعي للضمان:',
                            zh: '保函登记编号：',
                          ),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            SelectableText(
                              referenceNumber,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: const Color(0xFF0F766E),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            InkWell(
                              onTap: () async {
                                await Clipboard.setData(ClipboardData(text: referenceNumber));
                                HapticFeedback.selectionClick();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10nPick(
                                          context,
                                          fa: 'شناسه ضمانت‌نامه در حافظه کپی شد',
                                          en: 'Guarantee reference copied to clipboard',
                                        ),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16.sp,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Parties & Purpose Grid
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.business_rounded,
                          label: l10nPick(
                            context,
                            fa: 'نام ذینفع (کارفرما):',
                            en: 'Beneficiary:',
                            ar: 'اسم المستفيد:',
                            zh: '受益人：',
                          ),
                          value: beneficiaryName,
                        ),
                        SizedBox(height: 8.h),
                        _buildInfoRow(
                          icon: Icons.person_pin_rounded,
                          label: l10nPick(
                            context,
                            fa: 'متقاضی (مضمون‌عنه):',
                            en: 'Applicant / Principal:',
                            ar: 'المتقدم / المدين الأصلي:',
                            zh: '被担保人（申请人）：',
                          ),
                          value: applicantName,
                        ),
                        SizedBox(height: 8.h),
                        _buildInfoRow(
                          icon: Icons.assignment_rounded,
                          label: l10nPick(
                            context,
                            fa: 'موضوع ضمانت‌نامه:',
                            en: 'Purpose / Instrument:',
                            ar: 'الغرض من الضمان:',
                            zh: '担保业务目的：',
                          ),
                          value: purpose,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateItem(
                                label: l10nPick(
                                  context,
                                  fa: 'تاریخ صدور',
                                  en: 'Issue Date',
                                  ar: 'تاريخ الإصدار',
                                  zh: '开立日期',
                                ),
                                date: _formatDate(issueDate),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildDateItem(
                                label: l10nPick(
                                  context,
                                  fa: 'سررسید انقضا',
                                  en: 'Expiry Date',
                                  ar: 'تاريخ الانتهاء',
                                  zh: '有效截止期',
                                ),
                                date: _formatDate(maturityDate),
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Maximum Guaranteed Amount Banner
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10nPick(
                            context,
                            fa: 'حداکثر سقف تعهد مالی ضمانت‌نامه',
                            en: 'MAXIMUM GUARANTEED AMOUNT',
                            ar: 'الحد الأقصى لمبلغ التزام الضمان',
                            zh: '保函不可撤销最高担保限额',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFCCFBF1),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatCurrency(amount),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'monospace',
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              currency,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF99F6E4),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10nPick(
                            context,
                            fa: 'تعهد پرداخت قطعی و عندالمطالبه به اولین درخواست کتبی ذینفع',
                            en: 'Irrevocable, unconditional & on-demand payment guarantee',
                            ar: 'التزام دفع غير مشروط عند أول طلب كتابي من المستفيد',
                            zh: '见索即付，见书面索赔通知无条件立即对外承付',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xFFE6FFFA),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Vector QR Code & Verification Block
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Vector QR Code from package:barcode/barcode.dart
                        Container(
                          width: 100.r,
                          height: 100.r,
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: SvgPicture.string(
                            qrSvg,
                            width: 88.r,
                            height: 88.r,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Verification Explanations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(
                                  context,
                                  fa: 'استعلام آنلاین اصالت گواهی',
                                  en: 'Instant Online Verification',
                                  ar: 'التحقق الفوري من صحة المستند',
                                  zh: '扫码查验保函真伪与有效状态',
                                ),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                l10nPick(
                                  context,
                                  fa: 'این گواهی خلاصهٔ اطلاعات است و به‌تنهایی اعتبار قانونی ندارد. برای استناد رسمی، اصلِ دارای مهر و امضای بانک صادرکننده لازم است.',
                                  en: 'This is an informational summary and is not '
                                      'independently valid on its own. For official '
                                      'use, the bank-sealed and countersigned '
                                      'original is required.',
                                ),
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: AppColors.lightTextSecondary,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Checksum: ${_cryptographicFingerprint}',
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Print / Download PDF Action Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                    label: Text(
                      l10nPick(
                        context,
                        fa: 'چاپ و دانلود نسخه رسمی سند (PDF)',
                        en: 'Print / Download Official Certificate (PDF)',
                        ar: 'طباعة وتحميل النسخة الرسمية (PDF)',
                        zh: '打印/导出正式保函电子凭单 (PDF)',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () => _handlePrintAndDownloadPdf(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF0D9488)),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem({
    required String label,
    required String date,
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFEF3C7) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: highlight ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: highlight ? const Color(0xFF92400E) : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            date,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: highlight ? const Color(0xFF92400E) : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
