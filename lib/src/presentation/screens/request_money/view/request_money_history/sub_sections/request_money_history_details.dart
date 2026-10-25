import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/model/request_money_history_model.dart';

class RequestMoneyHistoryDetails extends StatelessWidget {
  final Requests request;

  const RequestMoneyHistoryDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double chargeValue = double.tryParse(request.charge ?? '') ?? 0.0;
    final double finalAmountValue =
        double.tryParse(request.finalAmount ?? '') ?? 0.0;
    final currencyCode = request.currency ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currencyCode,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: request.isCrypto ?? false,
    );

    // en_US grouping, no symbol — aligned with the design-system money widgets.
    final amountFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: calculateDecimals,
    );

    Color getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
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
      duration: AppDurations.normal,
      height: 440,
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow).withValues(
              alpha: isDark ? 0.4 : 0.08,
            ),
            blurRadius: 40,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.page,
        ),
        child: Column(
          children: [
            _buildHeader(colorScheme),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: localization.requestMoneyHistoryDetailsRequestEmail,
                      content: request.recipient?.email ?? '',
                      contentColor: colorScheme.primary,
                    ),
                    _buildDetailRow(
                      context,
                      label: localization.requestMoneyHistoryDetailsCurrency,
                      content: currencyCode,
                      contentColor: colorScheme.onSurface,
                    ),
                    _buildDetailRow(
                      context,
                      label: localization.requestMoneyHistoryDetailsCharge,
                      content:
                          "${amountFormatter.format(chargeValue).trim()} $currencyCode",
                      contentColor: AppColors.error,
                    ),
                    _buildDetailRow(
                      context,
                      label: localization.requestMoneyHistoryDetailsFinalAmount,
                      content:
                          "${amountFormatter.format(finalAmountValue).trim()} $currencyCode",
                      contentColor: AppColors.success,
                    ),
                    _buildDetailRow(
                      context,
                      label: localization.requestMoneyHistoryDetailsRequestAt,
                      content: request.createdAt != null &&
                              request.createdAt!.isNotEmpty
                          ? () {
                              try {
                                return DateFormat("dd MMM yyyy").format(
                                  DateTime.parse(request.createdAt!),
                                );
                              } catch (_) {
                                return request.createdAt!.split(",").first;
                              }
                            }()
                          : '',
                      contentColor: colorScheme.onSurface,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            localization.requestMoneyHistoryDetailsStatus,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 15,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                              color: getStatusColor(request.status),
                            ),
                            child: Text(
                              () {
                                final status = request.status ?? '';
                                return status.isNotEmpty
                                    ? status[0].toUpperCase() +
                                        status.substring(1)
                                    : "";
                              }(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                                fontSize: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              request.recipient?.name ?? "",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                color: colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String content,
    required Color contentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              content,
              textAlign: TextAlign.end,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 15,
                color: contentColor,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
