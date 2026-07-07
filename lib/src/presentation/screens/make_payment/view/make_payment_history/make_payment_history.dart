import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/view/make_payment_history/sub_sections/make_payment_transaction_filter_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class MakePaymentHistory extends StatefulWidget {
  const MakePaymentHistory({super.key});

  @override
  State<MakePaymentHistory> createState() => _MakePaymentHistoryState();
}

class _MakePaymentHistoryState extends State<MakePaymentHistory>
    with WidgetsBindingObserver {
  final MakePaymentHistoryController controller = Get.find();
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
                  title: localization.makePaymentHistoryScreenTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        MakePaymentTransactionFilterBottomSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsetsDirectional.only(end: 18),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),
                      child: Image.asset(PngAssets.commonFilterIcon),
                    ),
                  ),
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
    final transactions =
        controller.transactionsModel.value.data?.transactions ?? [];

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
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white,
                ),
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final Transactions transaction = transactions[index];

                    return GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          RecentTransactionDetails(transaction: transaction),
                        );
                      },
                      child: Container(
                        color: AppColors.transparent,
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color:
                                          TransactionDynamicColor.getTransactionColor(
                                            transaction.type,
                                          ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        TransactionDynamicIcon.getTransactionIcon(
                                          transaction.type,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction.type ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.5,
                                            color: AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          transaction.createdAt!
                                              .split(",")
                                              .first,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontSize: 14,
                                            color: AppColors.lightTextTertiary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, -2),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        transaction.isPlus == true ? "+" : "-",
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: transaction.isPlus == true
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
                                      "${transaction.isCrypto == true ? "" : transaction.trxCurrencySymbol}",
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: transaction.isPlus == true
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  transaction.isCrypto == true
                                      ? "${transaction.amount} ${transaction.trxCurrencyCode}"
                                      : "${transaction.amount}",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: transaction.isPlus == true
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
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
