import 'dart:io' show File;
import 'dart:ui' as ui show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';

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

  Color _getStatusColor(String? status) {
    // M-4 pattern: backend status casing is not guaranteed — compare on a
    // normalized form. "approved" is accepted alongside "success" because
    // KYC-style responses use it.
    switch ((status ?? '').trim().toLowerCase()) {
      case 'success':
      case 'approved':
        return AppColors.success;
      case 'pending':
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
                        _buildDetailRow(
                          label: localization.transactionDetailsTransactionId,
                          value: Text(
                            transaction.tnx ?? "",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 16,
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
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
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 16,
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Flexible(child: value),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        color: statusColor.withValues(alpha: 0.05),
      ),
      child: Text(
        status ?? "",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          fontSize: 13,
          color: statusColor,
        ),
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
          const Spacer(),
          Text(
            AppLocalizations.of(context)!.transactionsPopupReceiptTitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
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

      final localization = AppLocalizations.of(context);
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

  Widget _buildTransactionInfo() {
    final transaction = widget.transaction;
    final dateParts = transaction.createdAt?.split(",") ?? [];
    final date = dateParts.isNotEmpty ? dateParts.first : "";
    final time = dateParts.length > 1 ? dateParts.last : "";

    // v1.0.36 (RECEIPT-SHARE): centered hero layout — the amount is the
    // protagonist of the receipt image, exactly like premium wallet apps.
    return Column(
      children: [
        Text(
          transaction.type ?? "",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 8),
        Text(
          (date.isEmpty && time.isEmpty) ? "" : "$date · $time",
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 12,
            color: AppColors.lightTextTertiary,
            fontWeight: FontWeight.w700,
          ),
        ),
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
