import 'package:flutter/material.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';

class RecentTransactionDetails extends StatefulWidget {
  final Transactions transaction;

  const RecentTransactionDetails({super.key, required this.transaction});

  @override
  State<RecentTransactionDetails> createState() =>
      _RecentTransactionDetailsState();
}

class _RecentTransactionDetailsState extends State<RecentTransactionDetails> {
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Success":
        return AppColors.success;
      case "Pending":
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
                child: Column(
                  children: [
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
                    const SizedBox(height: 50),
                  ],
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

  Widget _buildTransactionInfo() {
    final transaction = widget.transaction;
    final dateParts = transaction.createdAt?.split(",") ?? [];
    final date = dateParts.isNotEmpty ? dateParts.first : "";
    final time = dateParts.length > 1 ? dateParts.last : "";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                transaction.type ?? "",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getAmountPrefix(transaction.isPlus),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: _getAmountColor(transaction.isPlus),
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    _formatAmount(
                      transaction.amount ?? "",
                      transaction.isCrypto,
                      transaction.trxCurrencyCode,
                      transaction.trxCurrencySymbol,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: _getAmountColor(transaction.isPlus),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 14,
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              time,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 14,
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w700,
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
