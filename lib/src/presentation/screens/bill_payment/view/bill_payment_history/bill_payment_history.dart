import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/controller/bill_payment_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/model/bill_payment_history_model.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/bill_payment_history/sub_sections/bill_payment_history_details.dart';

class BillPaymentHistory extends StatefulWidget {
  const BillPaymentHistory({super.key});

  @override
  State<BillPaymentHistory> createState() => _BillPaymentHistoryState();
}

class _BillPaymentHistoryState extends State<BillPaymentHistory>
    with WidgetsBindingObserver {
  final BillPaymentHistoryController controller = Get.find();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMorePages.value &&
        !controller.isPageLoading.value) {
      controller.loadMoreBillPaymentHistory();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchBillPaymentHistory();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchBillPaymentHistory();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  String _formatAmount(String? rawAmount) {
    final settings = Get.find<SettingsService>();
    final String currency =
        settings.getSetting("site_currency")?.toString() ?? "";
    final int decimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: currency,
      siteCurrencyDecimals:
          settings.getSetting("site_currency_decimals")?.toString(),
      isCrypto: false,
    );
    final parsed = double.tryParse(rawAmount ?? "0") ?? 0.0;
    final formattedValue = parsed.toStringAsFixed(decimals);
    return currency.isNotEmpty ? "$formattedValue $currency" : formattedValue;
  }

  Color _getStatusColor(String? status) {
    switch (status?.trim().toLowerCase()) {
      case "success":
      case "approved":
      case "successful":
        return AppColors.success;
      case "pending":
        return AppColors.warning;
      case "failed":
      case "reject":
      case "rejected":
      case "canceled":
      case "cancelled":
      default:
        return AppColors.error;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final statusColor = _getStatusColor(status);
    final localizedText = StatusLabelHelper.localize(
      AppLocalizations.of(context)!,
      status ?? "",
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
        color: statusColor.withValues(alpha: 0.08),
      ),
      child: Text(
        localizedText,
        style: TextStyle(
          letterSpacing: 0,
          fontSize: 11,
          color: statusColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: CommonAppBar(
                    title: AppLocalizations.of(context)!.billPaymentHistoryTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const CommonLoading();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildBillPaymentHistoryList(context, isDark),
                      ],
                    );
                  }),
                ),
              ],
            ),
            Visibility(
              visible:
                  controller.isTransactionsLoading.value ||
                  controller.isPageLoading.value,
              child: const CommonLoading(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillPaymentHistoryList(BuildContext context, bool isDark) {
    final bills = controller.billPaymentHistoryModel.value.data?.bills ?? [];

    if (controller.isLoading.value) {
      return const Expanded(child: CommonLoading());
    }

    if (bills.isEmpty) {
      return Expanded(
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: EcardoEmptyState(
              title: AppLocalizations.of(context)!.billPaymentHistoryTitle,
              description: AppLocalizations.of(context)!.noDataFound,
              iconData: Icons.receipt_long_rounded,
              primaryActionLabel:
                  AppLocalizations.of(context)!.billPaymentScreenTitle,
              onPrimaryAction: () {
                HapticFeedback.lightImpact();
                Get.back();
              },
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
        onRefresh: () => refreshData(),
        child: controller.isLoading.value
            ? const CommonLoading()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final Bills bill = bills[index];

                    return Semantics(
                      button: true,
                      label:
                          "${bill.serviceName ?? ''}, ${_formatAmount(bill.amount)}, ${StatusLabelHelper.localize(AppLocalizations.of(context)!, bill.status ?? '')}",
                      child: Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.bottomSheet(
                              BillPaymentHistoryDetails(bill: bill),
                            );
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 56),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkPrimaryContainer
                                                : AppColors.brandVioletContainer,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(11),
                                            child: Image.asset(
                                              PngAssets.payBillTransaction,
                                              color: isDark
                                                  ? AppColors.mainSoftBlue
                                                  : AppColors.brandViolet,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bill.serviceName ?? "",
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  letterSpacing: 0,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  fontSize: 15.5,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextPrimary
                                                      : AppColors
                                                          .lightTextPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (bill.createdAt != null &&
                                                        bill.createdAt!
                                                            .contains(","))
                                                    ? bill.createdAt!
                                                        .split(",")
                                                        .first
                                                    : (bill.createdAt ?? ""),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  letterSpacing: 0,
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? AppColors
                                                          .darkTextSecondary
                                                      : AppColors
                                                          .lightTextTertiary,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatAmount(bill.amount),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      if (bill.status != null &&
                                          bill.status!
                                              .trim()
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        _buildStatusBadge(
                                          context,
                                          bill.status,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightBorder.withValues(alpha: 0.5),
                        height: 1,
                      ),
                    );
                  },
                  itemCount: bills.length,
                ),
              ),
      ),
    );
  }
}
