import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/wallet_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_color.dart';
import 'package:qunzo_user/src/presentation/widgets/transaction_dynamic_icon.dart';

class WalletDetails extends StatefulWidget {
  const WalletDetails({super.key});

  @override
  State<WalletDetails> createState() => _WalletDetailsState();
}

class _WalletDetailsState extends State<WalletDetails> {
  final WalletDetailsController controller = Get.find();
  final walletId = Get.arguments['wallet_id'];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreTransactions();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchWallets(id: walletId);
    await controller.fetchTransactions(isRefresh: true);
    controller.fetchWallets(id: walletId);
    controller.isLoading.value = false;
  }

  Future<void> _onRefresh() async {
    await controller.fetchTransactions(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? CommonLoading()
            : RefreshIndicator(
                color: AppColors.lightPrimary,
                onRefresh: _onRefresh,
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 30),
                    SectionHeader(
                      sectionName: localization.walletDetailsHistory,
                      onTap: () {
                        Get.toNamed(BaseRoute.transactions);
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTransactionsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String icon,
    required Color iconBgColor,
    required GestureTapCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightPrimary.withValues(alpha: 0.30),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Image.asset(icon),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final localization = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(30),
          bottomEnd: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(PngAssets.walletShape, fit: BoxFit.contain),
              Column(
                children: [
                  SizedBox(height: 60),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                        ),
                        child: Image.asset(
                          isRtl
                              ? PngAssets.arrowLeftCommonIcon
                              : PngAssets.arrowLeftCommonIcon,
                          width: 28,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownWalletBottomSheet(
                          notFoundText:
                              localization.walletDetailsWalletsNotFound,
                          dropdownItems: controller.walletsList,
                          bottomSheetHeight: 450,
                          currentlySelectedValue: controller.wallet.value!.name,
                          onItemSelected: (value) async {
                            final selectedWallet = controller.walletsList
                                .firstWhere((w) => w.name == value);

                            controller.wallet.value = selectedWallet;
                            controller.walletName.value =
                                selectedWallet.name ?? "";
                            controller.walletIcon.value =
                                (selectedWallet.isDefault == true
                                    ? selectedWallet.symbol
                                    : selectedWallet.icon) ??
                                "";
                            controller.walletId.value = selectedWallet.id
                                .toString();
                            await controller.fetchTransactions(isRefresh: true);
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.70),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              controller.wallet.value!.isDefault == true
                                  ? Container(
                                      alignment: Alignment.center,
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        controller.walletIcon.value,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontSize: 14,
                                          color: AppColors.lightPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.network(
                                        controller.walletIcon.value,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                PngAssets.commonErrorIcon,
                                                width: 36,
                                                height: 36,
                                                color: AppColors.error
                                                    .withValues(alpha: 0.7),
                                              );
                                            },
                                      ),
                                    ),
                              SizedBox(width: 6),
                              Text(
                                controller.walletName.value,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Image.asset(
                            PngAssets.commonArrowDownIcon,
                            color: AppColors.white,
                            width: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    localization.walletDetailsAvailableBalance,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "${controller.wallet.value!.symbol!}${controller.wallet.value!.formattedBalance!}",
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    title: localization.walletDetailsTopUp,
                    icon: PngAssets.topUpCommonIcon,
                    iconBgColor: Color(0xFF81BAFF),
                    onTap: () {
                      if (Get.find<SettingsService>().getSetting(
                            "user_deposit",
                          ) ==
                          "1") {
                        Get.toNamed(
                          BaseRoute.addMoney,
                          arguments: {
                            "wallet_id": controller.walletId.toString(),
                          },
                        );
                      } else {
                        ToastHelper().showErrorToast(
                          localization.walletDetailsUserDepositNotEnabled,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: _buildActionButton(
                    title: localization.walletDetailsWithdraw,
                    icon: PngAssets.withdrawCommonIcon,
                    iconBgColor: Color(0xFF9280FD),
                    onTap: () {
                      if (Get.find<SettingsService>().getSetting(
                            "user_withdraw",
                          ) ==
                          "1") {
                        Get.toNamed(BaseRoute.withdraw);
                      } else {
                        ToastHelper().showErrorToast(
                          localization.walletDetailsUserWithdrawNotEnabled,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = controller.allTransactions;

    if (controller.isLoading.value && transactions.isEmpty) {
      return CommonLoading();
    }

    if (transactions.isEmpty) {
      return NoDataFound();
    }

    return Expanded(
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: ListView.separated(
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
                                      transaction.createdAt!.split(",").first,
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
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
                    height: 0,
                  ),
                );
              },
              itemCount: transactions.length,
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.isLoadingMore.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
