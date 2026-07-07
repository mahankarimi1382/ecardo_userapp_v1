import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/delete_account_dropdown_section.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class WithdrawAccountSection extends StatefulWidget {
  const WithdrawAccountSection({super.key});

  @override
  State<WithdrawAccountSection> createState() => _WithdrawAccountSectionState();
}

class _WithdrawAccountSectionState extends State<WithdrawAccountSection>
    with WidgetsBindingObserver {
  final WithdrawAccountController controller = Get.find();
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
      controller.loadMoreWithdrawAccounts();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchWithdrawAccounts();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchWithdrawAccounts();
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.withdrawAccountSectionTitle,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 18,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () => Stack(
                children: [
                  RefreshIndicator(
                    color: AppColors.lightPrimary,
                    onRefresh: () => refreshData(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(16),
                          topEnd: Radius.circular(16),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? CommonLoading()
                          : controller
                                .withdrawAccountModel
                                .value
                                .data!
                                .accounts!
                                .isEmpty
                          ? NoDataFound()
                          : ListView.separated(
                              physics: AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 30,
                              ),
                              itemBuilder: (context, index) {
                                final Accounts account = controller
                                    .withdrawAccountModel
                                    .value
                                    .data!
                                    .accounts![index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.methodName ?? "",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: AppColors.lightTextPrimary,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "${account.walletName} (${account.currency})",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color:
                                                  AppColors.lightTextTertiary,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
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
                                              padding: EdgeInsets.all(7),
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: AppColors.lightPrimary
                                                    .withValues(alpha: 0.10),
                                              ),
                                              child: Image.asset(
                                                PngAssets.editCommonIcon,
                                                color: AppColors.lightPrimary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () => Get.bottomSheet(
                                              DeleteAccountDropdownSection(
                                                accountId: account.id
                                                    .toString(),
                                              ),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: AppColors.error
                                                    .withValues(alpha: 0.10),
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
                              separatorBuilder: (context, index) => Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Divider(
                                    height: 0,
                                    color: AppColors.lightTextPrimary
                                        .withValues(alpha: 0.10),
                                  ),
                                  const SizedBox(height: 20),
                                ],
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
