import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/request_money_history_model.dart';

class RequestMoneyHistoryDetails extends StatelessWidget {
  final Requests request;

  const RequestMoneyHistoryDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: request.currency!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: request.isCrypto!,
    );

    Color getStatusColor(String? status) {
      switch (status) {
        case "success":
          return AppColors.success;
        case "pending":
          return AppColors.warning;
        default:
          return AppColors.error;
      }
    }

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      height: 430,
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
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailRow(
                      label:
                          localization.requestMoneyHistoryDetailsRequestEmail,
                      content: request.recipient!.email!,
                      contentColor: AppColors.lightPrimary,
                    ),
                    _buildDetailRow(
                      label: localization.requestMoneyHistoryDetailsCurrency,
                      content: request.currency!,
                      contentColor: AppColors.lightTextPrimary,
                    ),

                    _buildDetailRow(
                      label: localization.requestMoneyHistoryDetailsCharge,
                      content:
                          "${double.tryParse(request.charge!)!.toStringAsFixed(calculateDecimals)} ${request.currency}",
                      contentColor: AppColors.error,
                    ),

                    _buildDetailRow(
                      label: localization.requestMoneyHistoryDetailsFinalAmount,
                      content:
                          "${double.tryParse(request.finalAmount!)!.toStringAsFixed(calculateDecimals)} ${request.currency}",
                      contentColor: AppColors.success,
                    ),

                    _buildDetailRow(
                      label: localization.requestMoneyHistoryDetailsRequestAt,
                      content: DateFormat(
                        "dd MMM yyyy",
                      ).format(DateTime.parse(request.createdAt!)),
                      contentColor: AppColors.lightTextPrimary,
                    ),

                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            localization.requestMoneyHistoryDetailsStatus,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 16,
                              color: AppColors.lightTextTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: getStatusColor(
                                request.status!.toLowerCase(),
                              ),
                            ),
                            child: Text(
                              () {
                                final status = (request.status);
                                return status!.isNotEmpty
                                    ? status[0].toUpperCase() +
                                          status.substring(1)
                                    : "";
                              }(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                fontSize: 13,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              request.recipient!.name ?? "",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: AppColors.lightTextPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Image.asset(
                PngAssets.closeCommonIcon,
                width: 28,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
      ],
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

  Widget _buildDetailRow({
    required String label,
    required String content,
    Color? contentColor,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 15),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 15,
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              content,
              textAlign: TextAlign.end,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 15,
                color: contentColor ?? AppColors.lightTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
