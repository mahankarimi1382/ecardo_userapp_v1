import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/bottom_sheet/transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/transaction_type_list.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with WidgetsBindingObserver {
  final TransactionsController controller = Get.find();
  late ScrollController _scrollController;
  int _dirFilter = 0; // 0 all, 1 in, 2 out

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
    _openDeepLinkedTransactionIfAny();
  }

  void _openDeepLinkedTransactionIfAny() {
    final args = Get.arguments;
    if (args is! Map) return;
    if (args['open_details'] != true) return;
    final id = args['transaction_id']?.toString();
    if (id == null || id.isEmpty) return;
    final list =
        controller.transactionsModel.value.data?.transactions ?? const [];
    Transactions? match;
    for (final t in list) {
      if (t.tnx?.toString() == id) {
        match = t;
        break;
      }
    }
    if (match == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.bottomSheet(
        RecentTransactionDetails(transaction: match!),
        isScrollControlled: true,
      );
    });
  }

  Future<void> refreshData() async {
    if (controller.hasActiveFilters()) {
      controller.isLoading.value = true;
      await controller.fetchDynamicTransactions();
      controller.isLoading.value = false;
    } else {
      controller.isLoading.value = true;
      await controller.fetchTransactions();
      controller.isLoading.value = false;
    }
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
                  title: localization.transactionsScreenTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(TransactionFilterBottomSheet());
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
                        SizedBox(height: 33, child: TransactionTypeList()),
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
    final all =
        controller.transactionsModel.value.data?.transactions ?? [];
    final transactions = all.where((tx) {
      if (_dirFilter == 1) return tx.isPlus == true;
      if (_dirFilter == 2) return tx.isPlus != true;
      return true;
    }).toList();

    if (controller.isLoading.value) {
      return const Expanded(child: CommonLoading());
    }

    if (transactions.isEmpty) {
      return const Expanded(child: NoDataFound());
    }

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _dirChip('همه', 0),
                _dirChip('ورودی', 1),
                _dirChip('خروجی', 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => refreshData(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.white,
                ),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
                        height: 0,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    final Transactions transaction = transactions[index];
                    return InkWell(
                      onTap: () {
                        Get.bottomSheet(
                          RecentTransactionDetails(transaction: transaction),
                          isScrollControlled: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
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
                                      color: TransactionDynamicColor
                                          .getTransactionColor(transaction.type),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        TransactionDynamicIcon
                                            .getTransactionIcon(transaction.type),
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
                                          transaction.type ?? '',
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
                                          JalaliDateHelper.format(
                                            transaction.createdAt,
                                          ),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  transaction.isCrypto == true
                                      ? '${transaction.amount} ${transaction.trxCurrencyCode}'
                                      : '${transaction.trxCurrencySymbol ?? ''}${transaction.amount}',
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dirChip(String label, int value) {
    final selected = _dirFilter == value;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _dirFilter = value),
        selectedColor: AppColors.lightPrimary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: selected ? AppColors.lightPrimary : null,
        ),
      ),
    );
  }
}
