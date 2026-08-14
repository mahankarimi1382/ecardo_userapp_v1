import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/exchange_history/sub_sections/exchange_transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class ExchangeHistory extends StatefulWidget {
  const ExchangeHistory({super.key});

  @override
  State<ExchangeHistory> createState() => _ExchangeHistoryState();
}

class _ExchangeHistoryState extends State<ExchangeHistory>
    with WidgetsBindingObserver {
  final ExchangeHistoryController controller = Get.find();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                CommonAppBar(
                  title: localizations.exchangeHistoryTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        const ExchangeTransactionFilterBottomSheet(),
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
                      return const _HistorySkeleton();
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
              visible: controller.isTransactionsLoading.value ||
                  controller.isPageLoading.value,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.lightPrimary,
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

  Widget _buildTransactionsList() {
    final transactions =
        controller.transactionsModel.value.data?.transactions ?? [];

    if (transactions.isEmpty) {
      return const Expanded(child: NoDataFound());
    }

    return Expanded(
      child: RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: () => refreshData(),
        child: Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
          ),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          transaction.type ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15.5,
                                            color:
                                                AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                      if (transaction.isCrypto == true) ...[
                                        const SizedBox(width: 8),
                                        const _CryptoMiniBadge(),
                                      ],
                                    ],
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
                          Text(
                            transaction.isCrypto == true
                                ? "${transaction.amount} ${transaction.trxCurrencyCode}"
                                : "${transaction.amount}",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
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
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
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

class _CryptoMiniBadge extends StatelessWidget {
  const _CryptoMiniBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'CRYPTO',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.lightSecondary,
        ),
      ),
    );
  }
}

/// Skeleton loader shaped to match the actual list rows — gives the user
/// a sense of what's coming instead of an opaque spinner.
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightTextPrimary.withValues(alpha: 0.06),
      highlightColor: AppColors.lightTextPrimary.withValues(alpha: 0.12),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
              Container(
                height: 14,
                width: 60,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
