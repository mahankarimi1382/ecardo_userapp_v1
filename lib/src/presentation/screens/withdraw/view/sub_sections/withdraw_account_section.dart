import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/sub_sections/delete_account_dropdown_section.dart';

class WithdrawAccountSection extends StatefulWidget {
  const WithdrawAccountSection({super.key});

  @override
  State<WithdrawAccountSection> createState() => _WithdrawAccountSectionState();
}

class _WithdrawAccountSectionState extends State<WithdrawAccountSection>
    with WidgetsBindingObserver {
  final WithdrawAccountController controller = Get.find();
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
      controller.loadMoreWithdrawAccounts();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    _hasLoadError.value = false;
    try {
      await controller.fetchWithdrawAccounts();
    } catch (_) {
      _hasLoadError.value = true;
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    _hasLoadError.value = false;
    try {
      await controller.fetchWithdrawAccounts();
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.withdrawAccountSectionTitle,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 18,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Obx(
              () => Stack(
                children: [
                  RefreshIndicator(
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    onRefresh: refreshData,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(AppSpacing.radiusLg),
                          topEnd: Radius.circular(AppSpacing.radiusLg),
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CommonLoading()
                          : _hasLoadError.value
                          ? EcardoErrorView(
                              message: localization.allControllerLoadError,
                              onRetry: loadData,
                              retryLabel:
                                  localization.noInternetConnectionRetryButton,
                            )
                          : (controller
                                      .withdrawAccountModel
                                      .value
                                      .data
                                      ?.accounts
                                      ?.isEmpty ??
                                  true)
                          ? LayoutBuilder(
                              builder: (context, constraints) =>
                                  SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: EcardoEmptyState(
                                      title: localization
                                          .withdrawAccountSectionTitle,
                                      description: localization.noDataFound,
                                      iconData:
                                          Icons.account_balance_wallet_rounded,
                                      primaryActionLabel: localization
                                          .withdrawScreenAddAccountButton,
                                      onPrimaryAction: () {
                                        HapticFeedback.lightImpact();
                                        Get.find<WithdrawController>()
                                            .selectedScreen
                                            .value = 2;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                top: AppSpacing.lg,
                                bottom: AppSpacing.xxl,
                              ),
                              itemBuilder: (context, index) {
                                final Accounts account = controller
                                    .withdrawAccountModel
                                    .value
                                    .data!
                                    .accounts![index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              account.methodName ?? "",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.lightTextPrimary,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${account.walletName ?? ''} (${account.currency ?? ''})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.lightTextTertiary,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSm,
                                            ),
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              final withdrawController =
                                                  Get.find<
                                                    WithdrawController
                                                  >();
                                              withdrawController
                                                      .selectedAccount
                                                      .value =
                                                  account;
                                              withdrawController
                                                      .selectedScreen
                                                      .value =
                                                  3;
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(7),
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppSpacing.radiusSm,
                                                ),
                                                color: (isDark
                                                        ? AppColors.darkPrimary
                                                        : AppColors.lightPrimary)
                                                    .withValues(alpha: 0.12),
                                              ),
                                              child: Image.asset(
                                                PngAssets.editCommonIcon,
                                                color: isDark
                                                    ? AppColors.darkPrimary
                                                    : AppColors.lightPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSm,
                                            ),
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              Get.bottomSheet(
                                                DeleteAccountDropdownSection(
                                                  accountId: account.id
                                                      .toString(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(7),
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  AppSpacing.radiusSm,
                                                ),
                                                color: AppColors.error
                                                    .withValues(alpha: 0.12),
                                              ),
                                              child: Image.asset(
                                                PngAssets.invoiceDeleteIcon,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                height: AppSpacing.xxl,
                                color: isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                                indent: AppSpacing.lg,
                                endIndent: AppSpacing.lg,
                              ),
                              itemCount: controller
                                  .withdrawAccountModel
                                  .value
                                  .data!
                                  .accounts!
                                  .length,
                            ),
                    ),
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
          ),
        ],
      ),
    );
  }
}
