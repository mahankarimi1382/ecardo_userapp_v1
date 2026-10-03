import 'dart:async' show Timer;
import 'dart:io' show File;
import 'dart:ui' as ui show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class RecentTransactionDetails extends StatefulWidget {
  final Transactions transaction;

  const RecentTransactionDetails({super.key, required this.transaction});

  @override
  State<RecentTransactionDetails> createState() =>
      _RecentTransactionDetailsState();
}

class _RecentTransactionDetailsState extends State<RecentTransactionDetails> {
  /// v1.0.35 (RECEIPT-SHARE): rasterizes the receipt card below into a
  /// branded PNG and opens the system share sheet.
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
    // M-4 pattern: backend status casing is not guaranteed — compare on a
    // normalized form. "approved" and "completed" are accepted alongside "success".
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
    if (isCrypto == true) {
      return "$amount $currencyCode";
    }
    return "$currencySymbol$amount";
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final transaction = widget.transaction;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Container(
                    color: AppColors.white,
                    child: Column(
                      children: [
                        _buildBrandedShareHeader(),
                        const SizedBox(height: 16),
                        _buildTransactionInfo(),
                        const SizedBox(height: 30),
                        _buildDescription(),
                        const SizedBox(height: 30),
                        _buildDetailRow(
                          label: localization.transactionDetailsWallet,
                          value: Text(
                            "${transaction.walletType} (${transaction.trxCurrencyCode})",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 16,
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _buildAmountRow(
                          localization.transactionDetailsCharge,
                          transaction.charge ?? "",
                          transaction.charge,
                          transaction.isPlus,
                          transaction.isCrypto,
                          transaction.trxCurrencyCode,
                          transaction.trxCurrencySymbol,
                        ),
                        _buildTransactionIdRow(transaction.tnx),
                        _buildDetailRow(
                          label: localization.transactionDetailsMethod,
                          value: Text(
                            transaction.method ?? "",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 16,
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _buildAmountRow(
                          localization.transactionDetailsTotalAmount,
                          transaction.finalAmount ?? "",
                          transaction.finalAmount,
                          transaction.isPlus,
                          transaction.isCrypto,
                          transaction.trxCurrencyCode,
                          transaction.trxCurrencySymbol,
                        ),
                        _buildDetailRow(
                          label: localization.transactionDetailsStatus,
                          value: _buildStatusChip(transaction.status),
                        ),
                        const SizedBox(height: 18),
                        _buildReceiptFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // v1.0.35 (RECEIPT-SHARE): fixed share action below the receipt.
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _sharing ? null : () => _shareReceipt(),
                    icon: _sharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(
                      localization.shareReceipt,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    String? currencySymbol,
  ) {
    final isCharge = label.toLowerCase().contains("charge");
    final color = isCharge ? AppColors.error : _getAmountColor(isPlus);
    final prefix = isCharge ? "-" : _getAmountPrefix(isPlus);

    return _buildDetailRow(
      label: label,
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prefix,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              _formatAmount(amount, isCrypto, currencyCode, currencySymbol),
              textAlign: TextAlign.end,
              overflow: TextOverflow.visible,
              softWrap: true,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 15,
                color: AppColors.lightTextTertiary,
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

  Widget _buildTransactionIdRow(String? tnx) {
    final localization = AppLocalizations.of(context)!;
    final tnxText = (tnx ?? '').trim();

    return _buildDetailRow(
      label: localization.transactionDetailsTransactionId,
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
                fontSize: 15,
                fontFamily: 'monospace',
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w900,
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
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.lightTextPrimary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _copiedTnx
                            ? AppColors.success.withValues(alpha: 0.35)
                            : AppColors.lightTextPrimary.withValues(alpha: 0.12),
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      _copiedTnx ? Icons.check_rounded : Icons.copy_rounded,
                      size: 14,
                      color: _copiedTnx
                          ? AppColors.success
                          : AppColors.lightTextSecondary,
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

  Widget _buildStatusChip(String? status) {
    final statusColor = _getStatusColor(status);
    final localization = AppLocalizations.of(context)!;
    final localizedLabel =
        StatusLabelHelper.localize(localization, status ?? "");

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
        color: statusColor.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 13),
          const SizedBox(width: 4),
          Text(
            localizedLabel,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontSize: 12.5,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.lightTextPrimary.withValues(alpha: 0.1),
            AppColors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localization.transactionDetailsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Branded band rendered at the top of the captured receipt image — makes
  /// the shared PNG read as an official eCardo document, not a screenshot.
  Widget _buildBrandedShareHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.lightPrimary,
            AppColors.lightPrimary.withValues(alpha: 0.78),
          ],
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

  /// Rasterizes the receipt boundary to a PNG and opens the system share
  /// sheet. Failures never crash the sheet — a localized toast is shown.
  Future<void> _shareReceipt() async {
    if (_sharing) return;
    // Capture before any await — BuildContext must not cross async gaps.
    final localization = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ecardo_receipt_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: localization?.shareReceiptBody ?? 'My eCardo transaction receipt',
          subject: 'eCardo',
        ),
      );
    } catch (e) {
      debugPrint('Receipt share failed: $e');
      if (mounted) {
        final localization = AppLocalizations.of(context);
        ToastHelper().showErrorToast(
          localization?.shareReceiptFailed ?? 'Could not share the receipt.',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _buildCategoryBadge(String? type) {
    final categoryName = (type ?? '').trim();
    if (categoryName.isEmpty) return const SizedBox.shrink();

    final iconPath = TransactionDynamicIcon.getTransactionIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: 0.18),
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
              color: AppColors.lightPrimary,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            categoryName,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.lightPrimary,
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

  Widget _buildTransactionInfo() {
    final transaction = widget.transaction;
    final formattedDate = _formatTimestamp(context, transaction.createdAt);

    // v1.0.36 (RECEIPT-SHARE): centered hero layout — the amount is the
    // protagonist of the receipt image, exactly like premium wallet apps.
    return Column(
      children: [
        _buildCategoryBadge(transaction.type),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _getAmountPrefix(transaction.isPlus),
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 22,
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
                  fontSize: 28,
                  color: _getAmountColor(transaction.isPlus),
                ),
              ),
            ),
          ],
        ),
        if (formattedDate.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.lightTextTertiary,
                ),
                const SizedBox(width: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 12,
                    color: AppColors.lightTextTertiary,
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

  /// Footer rendered inside the shared image — makes the PNG read as an
  /// official document and gives it a designed bottom edge.
  Widget _buildReceiptFooter() {
    return Column(
      children: [
        Divider(
          height: 0,
          color: AppColors.black.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded,
                size: 12, color: AppColors.lightTextTertiary),
            const SizedBox(width: 5),
            Text(
              'eCardo  ·  ecardo.ir',
              style: TextStyle(
                letterSpacing: 0.4,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final localization = AppLocalizations.of(context)!;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.transactionDetailsDescription,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.transaction.description ?? "",
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
