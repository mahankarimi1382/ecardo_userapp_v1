import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/bill_payment_history_model.dart';

class BillPaymentHistoryDetails extends StatelessWidget {
  final Bills bill;

  const BillPaymentHistoryDetails({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final currency = Get.find<SettingsService>().getSetting("site_currency");

    return AnimatedContainer(
      width: double.infinity,
      height: 380.h,
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: Column(
          children: [
            _buildHeader(localization),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _detail(
                      localization.billPaymentDetailsTime,
                      bill.createdAt,
                    ),

                    _detail(
                      localization.billPaymentDetailsAmount,
                      '${bill.amount} $currency',
                    ),

                    _detail(
                      localization.billPaymentDetailsCharge,
                      '${bill.charge} $currency',
                      color: AppColors.error,
                    ),

                    _detail(
                      localization.billPaymentDetailsMethod,
                      bill.method,
                      color: AppColors.lightPrimary,
                    ),

                    _buildDetailRow(
                      label: localization.billPaymentDetailsStatus,
                      value: _buildStatusChip(bill.status),
                    ),

                    if (bill.metadata != null && bill.metadata!.isNotEmpty)
                      ...bill.metadata!.map(
                        (meta) => _detail(meta.key, meta.value),
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

  Widget _detail(String label, String? value, {Color? color}) {
    return _buildDetailRow(
      label: label,
      value: Text(
        value ?? '',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: color ?? AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget value}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextTertiary,
            ),
          ),
          Flexible(child: value),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localization) {
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
          localization.billPaymentDetailsTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Divider(color: AppColors.lightTextPrimary.withValues(alpha: 0.1)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        color: AppColors.success.withValues(alpha: 0.05),
      ),
      child: Text(
        status ?? '',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppColors.success,
        ),
      ),
    );
  }
}
