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
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/withdraw_history/sub_sections/withdraw_transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:ecardo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class WithdrawHistory extends StatefulWidget {
  const WithdrawHistory({super.key});

  @override
  State<WithdrawHistory> createState() => _WithdrawHistoryState();
}

class _WithdrawHistoryState extends State<WithdrawHistory>
    with WidgetsBindingObserver {
  final WithdrawHistoryController controller = Get.find();
  late ScrollController _scrollController;
  final RxBool _hasLoadError = false.obs;

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
    _hasLoadError.value = false;
    try {
      await controller.fetchTransactions();
    } catch (_) {
      _hasLoadError.value = true;
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    _hasLoadError.value = false;
    try {
      await controller.fetchTransactions();
    } catch (_) {
      _hasLoadError.value = true;
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                CommonAppBar(
                  title: localization.withdrawHistoryScreenTitle,
                  rightSideWidget: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.bottomSheet(
                        const WithdrawTransactionFilterBottomSheet(),
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
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Image.asset(
                        PngAssets.commonFilterIcon,
                        color: isDark ? AppColors.warmWhite : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const CommonLoading();
                    }

                    if (_hasLoadError.value) {
                      return EcardoErrorView(
                        message: localization.allControllerLoadError,
                        onRetry: loadData,
                        retryLabel: localization.noInternetConnectionRetryButton,
                      );
                    }

                    return _buildTransactionsList(localization, isDark);
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
                title: localization.withdrawHistoryScreenTitle,
                description: localization.noDataFound,
                iconData: Icons.history_rounded,
                primaryActionLabel: localization.withdrawScreenTitle,
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
      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      onRefresh: refreshData,
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.page,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: AppSpacing.md,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          itemBuilder: (context, index) {
            final Transactions transaction = transactions[index];

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.bottomSheet(
                  RecentTransactionDetails(transaction: transaction),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: TransactionDynamicColor.getTransactionColor(
                          transaction.type,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
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
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.createdAt ?? "",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${transaction.amount ?? ''} ${transaction.trxCurrencyCode ?? transaction.payCurrency ?? ''}",
                          style: TextStyle(
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: (transaction.isSuccess
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXs,
                            ),
                          ),
                          child: Text(
                            transaction.isSuccess ? "Success" : "Pending",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: transaction.isSuccess
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
          itemCount: transactions.length,
        ),
      ),
    );
  }
}
