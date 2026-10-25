import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_received_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/transfer_received_history/sub_sections/transfer_received_transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/tx_history_shimmer_skeleton.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class TransferReceivedHistory extends StatefulWidget {
  const TransferReceivedHistory({super.key});

  @override
  State<TransferReceivedHistory> createState() =>
      _TransferReceivedHistoryState();
}

class _TransferReceivedHistoryState extends State<TransferReceivedHistory>
    with WidgetsBindingObserver {
  final TransferReceivedHistoryController controller = Get.find();
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
    await controller.fetchTransactions();
  }

  Future<void> refreshData() async {
    await controller.fetchTransactions();
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
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      backgroundColor: colorScheme.surface,
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                CommonAppBar(
                  title: localization.transferReceivedHistoryScreenTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.bottomSheet(
                        TransferReceivedTransactionFilterBottomSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsetsDirectional.only(
                        end: AppSpacing.page,
                      ),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHigh
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: isDark ? 0.3 : 0.6,
                          ),
                        ),
                      ),
                      child: Image.asset(
                        PngAssets.commonFilterIcon,
                        color: isDark ? colorScheme.onSurface : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const TxHistoryShimmerSkeleton();
                    }

                    if (controller.hasError.value) {
                      return Center(
                        child: EcardoErrorView(
                          message: controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : localization.allControllerLoadError,
                          onRetry: loadData,
                          retryLabel:
                              localization.noInternetConnectionRetryButton,
                        ),
                      );
                    }

                    return _buildTransactionsList(localization, isDark, colorScheme);
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

  Widget _buildTransactionsList(
    AppLocalizations localization,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final transactions =
        controller.transactionsModel.value.data?.transactions ?? [];

    if (transactions.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: EcardoEmptyState(
                title: localization.transferReceivedHistoryScreenTitle,
                description: localization.noDataFound,
                iconData: Icons.call_received_rounded,
                primaryActionLabel: localization.transferScreenTitle,
                onPrimaryAction: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: refreshData,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.25 : 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.lightShadow).withValues(
                alpha: isDark ? 0.3 : 0.05,
              ),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          itemCount: transactions.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.2 : 0.4,
            ),
          ),
          itemBuilder: (context, index) {
            final Transactions transaction = transactions[index];

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Get.bottomSheet(
                  RecentTransactionDetails(transaction: transaction),
                );
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: TransactionDynamicColor.getTransactionColor(
                                transaction.type,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
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
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.type ?? "",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  transaction.createdAt?.split(",").first ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w600,
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
                      textDirection: TextDirection.ltr,
                      children: [
                        Text(
                          transaction.isPlus == true ? "+ " : "- ",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: transaction.isPlus == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        if (transaction.isCrypto != true &&
                            transaction.trxCurrencySymbol != null)
                          Text(
                            transaction.trxCurrencySymbol!,
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
                              ? "${transaction.amount} ${transaction.trxCurrencyCode ?? ''}"
                              : "${transaction.amount}",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: transaction.isPlus == true
                                ? AppColors.success
                                : colorScheme.onSurface,
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
    );
  }
}
