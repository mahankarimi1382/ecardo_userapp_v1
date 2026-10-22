import 'dart:async' show Timer;
import 'dart:io' show File;
import 'dart:ui' as ui show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

/// Luxury Digital Receipt modal bottom sheet for eCardo.
///
/// Features:
/// - High-end card modal with smooth rounded corners (24r) and dark mode styling.
/// - Prominent hero amount with live status badge and category identifier.
/// - Detailed breakdown rows: Transaction ID with quick copy button,
///   Date & Exact Time (Jalali + Gregorian), Source Wallet, Target/Beneficiary,
///   Fee/Charge, Exchange Rate (if applicable), and Total Amount.
/// - 3 Action Buttons at bottom:
///   1. Repeat Transfer/Payment (navigates to relevant flow with prefilled data).
///   2. Share Receipt (rasterizes digital PNG with text fallback via share_plus).
///   3. Support Inquiry (opens support ticket with reference prefilled).
class RecentTransactionDetails extends StatefulWidget {
  final Transactions transaction;

  const RecentTransactionDetails({super.key, required this.transaction});

  @override
  State<RecentTransactionDetails> createState() =>
      _RecentTransactionDetailsState();
}

class _RecentTransactionDetailsState extends State<RecentTransactionDetails> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _sharing = false;
  bool _copiedTnx = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'success':
      case 'approved':
      case 'completed':
      case 'complete':
      case '1':
        return AppColors.success;
      case 'pending':
      case 'processing':
      case '2':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  Color _getAmountColor(bool? isPlus) {
    return isPlus == true ? AppColors.success : AppColors.error;
  }

  String _getAmountPrefix(bool? isPlus) {
    return isPlus == true ? "+" : "-";
  }

  String _formatAmount(
    String amount,
    bool? isCrypto,
    String? currencyCode,
    String? currencySymbol,
  ) {
    String clean = amount;
    final parsed = double.tryParse(amount.replaceAll(',', ''));
    if (parsed != null && currencyCode != null && currencyCode.isNotEmpty) {
      final decimals = DynamicDecimalsHelper().getDynamicDecimals(
        currencyCode: currencyCode,
        siteCurrencyCode: 'USD',
        siteCurrencyDecimals: '2',
        isCrypto: isCrypto == true,
      );
      if (decimals == 0) {
        clean = parsed.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
      } else {
        clean = parsed
            .toStringAsFixed(decimals)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
      }
    }
    if (isCrypto == true) {
      return "$clean $currencyCode";
    }
    final sym = currencySymbol ?? '';
    return sym.isNotEmpty
        ? "$sym$clean"
        : "$clean ${currencyCode ?? ''}".trim();
  }

  void _onRepeat() {
    HapticFeedback.lightImpact();
    Get.back();
    final type = widget.transaction.type?.toLowerCase() ?? '';
    String targetRoute = BaseRoute.transfer;
    if (type.contains('exchange')) {
      targetRoute = BaseRoute.exchange;
    } else if (type.contains('deposit') || type.contains('add_money')) {
      targetRoute = BaseRoute.addMoney;
    } else if (type.contains('withdraw') || type.contains('cash_out')) {
      targetRoute = BaseRoute.withdraw;
    } else if (type.contains('payment') || type.contains('card')) {
      targetRoute = BaseRoute.makePayment;
    }
    Get.toNamed(
      targetRoute,
      arguments: {
        'amount': widget.transaction.amount,
        'currency': widget.transaction.trxCurrencyCode,
        'method': widget.transaction.method,
      },
    );
  }

  void _onSupportInquiry() {
    HapticFeedback.lightImpact();
    Get.back();
    final tnx = widget.transaction.tnx ?? '';
    try {
      Get.toNamed(
        BaseRoute.addNewTicket,
        arguments: {
          'transaction_ref': tnx,
          'amount': widget.transaction.amount,
          'currency': widget.transaction.trxCurrencyCode,
          'title': widget.transaction.type ?? 'تراکنش',
          'status': widget.transaction.status,
        },
      );
    } catch (_) {
      Get.toNamed(BaseRoute.supportTickets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final transaction = widget.transaction;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : AppColors.black.withValues(alpha: 0.08),
            blurRadius: 36,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Container(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    child: Column(
                      children: [
                        _buildBrandedShareHeader(),
                        const SizedBox(height: 16),
                        _buildTransactionInfo(isDark),
                        const SizedBox(height: 24),
                        if (transaction.description != null &&
                            transaction.description!.trim().isNotEmpty) ...[
                          _buildDescription(isDark),
                          const SizedBox(height: 20),
                        ],
                        _buildDivider(isDark),
                        const SizedBox(height: 16),
                        // Detailed Breakdown Rows
                        _buildTransactionIdRow(transaction.tnx, isDark),
                        _buildDateTimeBreakdownRow(
                          context,
                          transaction.createdAt,
                          isDark,
                        ),
                        _buildDetailRow(
                          label: localization.transactionDetailsWallet,
                          value: Text(
                            "${transaction.walletType ?? 'Main'} (${transaction.trxCurrencyCode ?? 'USD'})",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          isDark: isDark,
                        ),
                        _buildDetailRow(
                          label: localization.transactionDetailsMethod,
                          value: Text(
                            transaction.method ?? "—",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          isDark: isDark,
                        ),
                        _buildAmountRow(
                          localization.transactionDetailsCharge,
                          transaction.charge ?? "0.00",
                          transaction.charge,
                          transaction.isPlus,
                          transaction.isCrypto,
                          transaction.trxCurrencyCode,
                          transaction.trxCurrencySymbol,
                          isDark: isDark,
                        ),
                        _buildExchangeRateRow(context, isDark),
                        _buildAmountRow(
                          localization.transactionDetailsTotalAmount,
                          transaction.finalAmount ??
                              transaction.amount ??
                              "0.00",
                          transaction.finalAmount,
                          transaction.isPlus,
                          transaction.isCrypto,
                          transaction.trxCurrencyCode,
                          transaction.trxCurrencySymbol,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),
                        _buildReceiptFooter(isDark),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 3 Bottom Action Buttons
            _buildBottomActionButtons(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String amount,
    String? charge,
    bool? isPlus,
    bool? isCrypto,
    String? currencyCode,
    String? currencySymbol, {
    required bool isDark,
  }) {
    final isCharge =
        label.toLowerCase().contains("charge") ||
        label.contains("کارمزد") ||
        label.contains("رسوم");
    final color = isCharge ? AppColors.error : _getAmountColor(isPlus);
    final prefix = isCharge ? "-" : _getAmountPrefix(isPlus);

    return _buildDetailRow(
      label: label,
      isDark: isDark,
      value: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          '$prefix${_formatAmount(amount, isCrypto, currencyCode, currencySymbol)}',
          textAlign: TextAlign.end,
          overflow: TextOverflow.visible,
          softWrap: true,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateRow(BuildContext context, bool isDark) {
    final tx = widget.transaction;
    final isExchange = tx.type?.toLowerCase() == 'exchange';
    final hasPay =
        tx.payAmount != null &&
        tx.payAmount!.trim().isNotEmpty &&
        tx.payCurrency != null &&
        tx.payCurrency!.trim().isNotEmpty;

    if (!isExchange && !hasPay) return const SizedBox.shrink();

    final exchangeValue = hasPay
        ? '${tx.payAmount} ${tx.payCurrency}'
        : (tx.method ?? '—');

    return _buildDetailRow(
      label: l10nPick(
        context,
        en: 'Exchange / Paid',
        fa: 'مبلغ پرداختی / تبدیل',
        ar: 'المبلغ المدفوع / الصرف',
        zh: '支付/兑换金额',
        ru: 'Сумма обмена',
        tr: 'Ödenen / Dönüşüm',
      ),
      isDark: isDark,
      value: Text(
        exchangeValue,
        style: TextStyle(
          letterSpacing: 0,
          fontSize: 15,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDateTimeBreakdownRow(
    BuildContext context,
    String? rawCreatedAt,
    bool isDark,
  ) {
    if (rawCreatedAt == null || rawCreatedAt.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final parsed = JalaliDateHelper.tryParse(rawCreatedAt);
    final jalaliText = JalaliDateHelper.format(rawCreatedAt);
    final gregorianText = parsed != null
        ? DateFormat(
            'd MMM yyyy, HH:mm',
          ).format(parsed.isUtc ? parsed.toLocal() : parsed)
        : '';

    final isFa =
        Localizations.localeOf(context).languageCode == 'fa' ||
        Localizations.localeOf(context).languageCode == 'ar';

    return _buildDetailRow(
      label: l10nPick(
        context,
        en: 'Date & Exact Time',
        fa: 'تاریخ و زمان دقیق',
        ar: 'التاريخ والوقت بالتفصيل',
        zh: '确切日期与时间',
        ru: 'Дата и точное время',
        tr: 'Tarih ve Tam Saat',
      ),
      isDark: isDark,
      value: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isFa
                ? jalaliText
                : (gregorianText.isNotEmpty ? gregorianText : jalaliText),
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 14.5,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (gregorianText.isNotEmpty && isFa) ...[
            const SizedBox(height: 2),
            Text(
              '$gregorianText (میلادی)',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (!isFa && jalaliText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '$jalaliText (Jalali)',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required Widget value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 14.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIdRow(String? tnx, bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final tnxText = (tnx ?? '').trim();

    return _buildDetailRow(
      label: localization.transactionDetailsTransactionId,
      isDark: isDark,
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              tnxText.isNotEmpty ? tnxText : '—',
              textDirection: TextDirection.ltr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                letterSpacing: 0.5,
                fontSize: 14.5,
                fontFamily: 'monospace',
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (tnxText.isNotEmpty) ...[
            const SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: Tooltip(
                message: l10nPick(
                  context,
                  en: 'Copy Transaction ID',
                  fa: 'کپی شناسه تراکنش',
                  ar: 'نسخ معرف المعاملة',
                  tr: 'İşlem numarasını kopyala',
                  ru: 'Скопировать ID транзакции',
                  zh: '复制交易号',
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: tnxText));
                    setState(() => _copiedTnx = true);
                    ToastHelper().showSuccessToast(
                      l10nPick(
                        context,
                        en: 'Transaction ID copied',
                        fa: 'شناسه تراکنش کپی شد',
                        ar: 'تم نسخ معرف المعاملة',
                        tr: 'İşlem numarası kopyalandı',
                        ru: 'ID транзакции скопирован',
                        zh: '已复制交易号',
                      ),
                    );
                    _copyTimer?.cancel();
                    _copyTimer = Timer(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copiedTnx = false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _copiedTnx
                          ? AppColors.success.withValues(alpha: 0.14)
                          : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightTextPrimary.withValues(
                                    alpha: 0.07,
                                  )),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _copiedTnx
                            ? AppColors.success.withValues(alpha: 0.35)
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightTextPrimary.withValues(
                                      alpha: 0.12,
                                    )),
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      _copiedTnx ? Icons.check_rounded : Icons.copy_rounded,
                      size: 14,
                      color: _copiedTnx
                          ? AppColors.success
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, bool isDark) {
    final statusColor = _getStatusColor(status);
    final localization = AppLocalizations.of(context)!;
    final localizedLabel = StatusLabelHelper.localize(
      localization,
      status ?? "",
    );

    IconData statusIcon;
    switch ((status ?? '').trim().toLowerCase()) {
      case 'success':
      case 'approved':
      case 'completed':
      case 'complete':
      case '1':
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'pending':
      case 'processing':
      case '2':
        statusIcon = Icons.access_time_filled_rounded;
        break;
      default:
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.40 : 0.25),
          width: 0.8,
        ),
        color: statusColor.withValues(alpha: isDark ? 0.18 : 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 14),
          const SizedBox(width: 5),
          Text(
            localizedLabel,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontSize: 13,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: isDark
          ? AppColors.darkDivider
          : AppColors.lightDivider.withValues(alpha: 0.5),
    );
  }

  Widget _buildHeader(bool isDark) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),
        // Drag pill handle
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.22)
                : AppColors.lightTextPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          localization.transactionDetailsTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 14),
        _buildDivider(isDark),
        const SizedBox(height: 14),
      ],
    );
  }

  /// Branded band rendered at top of shared receipt image.
  Widget _buildBrandedShareHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.brandViolet, AppColors.brandVioletDeep],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'eCardo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.transactionsPopupReceiptTitle,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rasterizes the receipt to a PNG or shares a formatted text summary.
  Future<void> _shareReceipt() async {
    if (_sharing) return;
    final localization = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        try {
          final image = await boundary.toImage(pixelRatio: 3);
          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          image.dispose();
          if (byteData != null) {
            final dir = await getTemporaryDirectory();
            final file = File(
              '${dir.path}/ecardo_receipt_${DateTime.now().millisecondsSinceEpoch}.png',
            );
            await file.writeAsBytes(byteData.buffer.asUint8List());

            await SharePlus.instance.share(
              ShareParams(
                files: [XFile(file.path)],
                text:
                    localization?.shareReceiptBody ??
                    'My eCardo transaction receipt',
                subject: 'eCardo Receipt',
              ),
            );
            return;
          }
        } catch (imgError) {
          debugPrint(
            'Image rasterization failed, falling back to text ticket: $imgError',
          );
        }
      }

      // Text ticket fallback
      final tx = widget.transaction;
      final textSummary =
          '''
eCardo Digital Receipt
------------------------------
Reference: ${tx.tnx ?? '—'}
Type: ${tx.type ?? 'Transaction'}
Amount: ${tx.isPlus == true ? '+' : '-'}${tx.trxCurrencySymbol ?? ''}${tx.amount ?? '0.00'} ${tx.trxCurrencyCode ?? ''}
Date: ${JalaliDateHelper.format(tx.createdAt)}
Status: ${tx.status ?? 'Success'}
Method: ${tx.method ?? '—'}
------------------------------
Verified by eCardo · ecardo.ir
''';

      await SharePlus.instance.share(
        ShareParams(
          text: textSummary,
          subject: 'eCardo Transaction Receipt ${tx.tnx ?? ""}',
        ),
      );
    } catch (e) {
      debugPrint('Receipt share failed: $e');
      if (mounted) {
        ToastHelper().showErrorToast(
          localization?.shareReceiptFailed ?? 'Could not share the receipt.',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _buildCategoryBadge(String? type, bool isDark) {
    final categoryName = (type ?? '').trim();
    if (categoryName.isEmpty) return const SizedBox.shrink();

    final iconPath = TransactionDynamicIcon.getTransactionIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.brandViolet.withValues(alpha: 0.18)
            : AppColors.brandVioletContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.brandViolet.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 17,
            height: 17,
            errorBuilder: (_, _, _) => const Icon(
              Icons.receipt_long_rounded,
              size: 17,
              color: AppColors.brandViolet,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            categoryName,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.brandViolet,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(BuildContext context, String? rawCreatedAt) {
    if (rawCreatedAt == null || rawCreatedAt.trim().isEmpty) return '';

    final locale = Localizations.localeOf(context).languageCode;
    final parsed = JalaliDateHelper.tryParse(rawCreatedAt);
    if (parsed == null) return rawCreatedAt;

    if (locale == 'fa' || locale == 'ar') {
      return JalaliDateHelper.format(rawCreatedAt);
    }

    try {
      final localDt = parsed.isUtc ? parsed.toLocal() : parsed;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final itemDay = DateTime(localDt.year, localDt.month, localDt.day);
      final diff = today.difference(itemDay).inDays;
      final timeStr = DateFormat('HH:mm').format(localDt);

      if (diff == 0) {
        final todayWord = l10nPick(
          context,
          en: 'Today',
          fa: 'امروز',
          ar: 'اليوم',
          tr: 'Bugün',
          ru: 'Сегодня',
          zh: '今天',
        );
        return '$todayWord, $timeStr';
      } else if (diff == 1) {
        final yestWord = l10nPick(
          context,
          en: 'Yesterday',
          fa: 'دیروز',
          ar: 'أمس',
          tr: 'Dün',
          ru: 'Вчера',
          zh: '昨天',
        );
        return '$yestWord, $timeStr';
      }

      return DateFormat('d MMM yyyy, HH:mm').format(localDt);
    } catch (_) {
      return JalaliDateHelper.format(rawCreatedAt);
    }
  }

  Widget _buildTransactionInfo(bool isDark) {
    final transaction = widget.transaction;
    final formattedDate = _formatTimestamp(context, transaction.createdAt);

    return Column(
      children: [
        _buildCategoryBadge(transaction.type, isDark),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _getAmountPrefix(transaction.isPlus),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: _getAmountColor(transaction.isPlus),
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  _formatAmount(
                    transaction.amount ?? "",
                    transaction.isCrypto,
                    transaction.trxCurrencyCode,
                    transaction.trxCurrencySymbol,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: _getAmountColor(transaction.isPlus),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildStatusChip(transaction.status, isDark),
        if (formattedDate.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightTextPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiptFooter(bool isDark) {
    return Column(
      children: [
        Divider(
          height: 0,
          color: isDark
              ? AppColors.darkDivider
              : AppColors.black.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 12,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(width: 5),
            Text(
              'eCardo  ·  ecardo.ir',
              style: TextStyle(
                letterSpacing: 0.4,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(bool isDark) {
    final localization = AppLocalizations.of(context)!;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.transactionDetailsDescription,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.transaction.description ?? "",
            style: TextStyle(
              fontSize: 13.5,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(bool isDark) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          children: [
            // 1. Repeat Transfer / Payment
            Expanded(
              flex: 3,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 4,
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                onPressed: _onRepeat,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.replay_rounded, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Repeat',
                          fa: 'تکرار',
                          ar: 'تكرار',
                          tr: 'Tekrarla',
                          ru: 'Повторить',
                          zh: '再次',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Share Receipt (Hero CTA)
            Expanded(
              flex: 4,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandViolet,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.brandViolet.withValues(alpha: 0.35),
                ),
                onPressed: _sharing ? null : () => _shareReceipt(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_sharing)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    else
                      const Icon(Icons.ios_share_rounded, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Share',
                          fa: 'اشتراک',
                          ar: 'مشاركة',
                          tr: 'Paylaş',
                          ru: 'Поделиться',
                          zh: '分享',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 3. Support Inquiry
            Expanded(
              flex: 3,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 4,
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                onPressed: _onSupportInquiry,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.headset_mic_rounded, size: 15),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Support',
                          fa: 'پشتیبانی',
                          ar: 'الدعم',
                          tr: 'Destek',
                          ru: 'Поддержка',
                          zh: '客服',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
