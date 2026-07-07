import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/request_money_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/request_money_history_model.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/request_money_history/sub_sections/request_money_history_details.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class RequestMoneyHistory extends StatefulWidget {
  const RequestMoneyHistory({super.key});

  @override
  State<RequestMoneyHistory> createState() => _RequestMoneyHistoryState();
}

class _RequestMoneyHistoryState extends State<RequestMoneyHistory>
    with WidgetsBindingObserver {
  final RequestMoneyHistoryController controller = Get.find();
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
      controller.loadMoreTransactions();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchTransactions();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchTransactions();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  String _getRequesterName(Requests request) {
    return request.recipient?.name ?? "";
  }

  String _getAmount(Requests request) {
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: request.currency ?? '',
      siteCurrencyCode:
          Get.find<SettingsService>().getSetting("site_currency") ?? '',
      siteCurrencyDecimals:
          Get.find<SettingsService>().getSetting("site_currency_decimals") ??
          '2',
      isCrypto: request.isCrypto ?? false,
    );

    final amount = double.tryParse(request.amount ?? '0') ?? 0;
    return "${request.currencySymbol ?? ''}${amount.toStringAsFixed(calculateDecimals)}";
  }

  String _getStatus(Requests request) {
    final status = request.status ?? '';
    return status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : "";
  }

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                CommonAppBar(
                  title: localization.requestMoneyHistoryScreenTitle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return CommonLoading();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildTransactionsList(),
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

  Widget _buildTransactionsList() {
    final localization = AppLocalizations.of(context)!;
    final transactions =
        controller.receivedRequestModel.value.data?.requests ?? [];

    if (controller.isLoading.value) {
      return Expanded(child: CommonLoading());
    }

    if (transactions.isEmpty) {
      return Expanded(child: NoDataFound());
    }

    return Expanded(
      child: RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: () => refreshData(),
        child: controller.isLoading.value
            ? CommonLoading()
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white,
                ),
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final Requests transaction = transactions[index];

                    return InkWell(
                      onTap: () {
                        Get.bottomSheet(
                          RequestMoneyHistoryDetails(request: transaction),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getRequesterName(transaction),
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppColors.lightTextPrimary,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Text(
                                  _getAmount(transaction),
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localization
                                          .requestMoneyHistoryRequestedAt,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.lightTextTertiary,
                                      ),
                                    ),
                                    Text(
                                      DateFormat("dd MMM yyyy hh:mm a").format(
                                        DateTime.parse(
                                          transaction.createdAt ??
                                              DateTime.now().toString(),
                                        ),
                                      ),
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.lightTextTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      localization.requestMoneyHistoryStatus,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.lightTextTertiary,
                                      ),
                                    ),
                                    Text(
                                      _getStatus(transaction),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                        fontSize: 13,
                                        color: getStatusColor(
                                          transaction.status,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.10,
                        ),
                        height: 0,
                      ),
                    );
                  },
                  itemCount: transactions.length,
                ),
              ),
      ),
    );
  }
}
