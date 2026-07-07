import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_redeem_history_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/gift_redeem_history/sub_sections/gift_redeem_transaction_filter_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class GiftRedeemHistory extends StatefulWidget {
  const GiftRedeemHistory({super.key});

  @override
  State<GiftRedeemHistory> createState() => _GiftRedeemHistoryState();
}

class _GiftRedeemHistoryState extends State<GiftRedeemHistory>
    with WidgetsBindingObserver {
  final GiftRedeemHistoryController controller = Get.find();
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
                  title: localizations.giftRedeemHistoryTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(GiftRedeemTransactionFilterBottomSheet());
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
    final localization = AppLocalizations.of(context)!;
    final transactions =
        controller.giftRedeemHistoryModel.value.data?.gifts ?? [];

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
                    final Gifts gift = transactions[index];

                    final calculateDecimals = DynamicDecimalsHelper()
                        .getDynamicDecimals(
                          currencyCode: gift.currency!,
                          siteCurrencyCode: Get.find<SettingsService>()
                              .getSetting("site_currency")!,
                          siteCurrencyDecimals: Get.find<SettingsService>()
                              .getSetting("site_currency_decimals")!,
                          isCrypto: gift.isCrypto!,
                        );

                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF9F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 8),
                                child: Text(
                                    gift.code ?? "",
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: gift.code ?? ""),
                                  );
                                  ToastHelper().showSuccessToast(
                                    localization.giftRedeemHistoryCodeCopied,
                                  );
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.lightPrimary.withValues(
                                        alpha: 0.16,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Image.asset(
                                    PngAssets.commonGiftCopyIcon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "${localization.giftRedeemHistoryCreatedAt} ${DateFormat("dd MMM yyyy hh:mm a").format(DateTime.parse(gift.createdAt ?? ""))}",
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white,
                                  AppColors.lightTextPrimary.withValues(
                                    alpha: 0.2,
                                  ),
                                  AppColors.white,
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      localization.giftRedeemHistoryStatus,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.lightTextTertiary,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        gift.isRedeemed == true
                                            ? localization
                                                  .giftRedeemHistoryClaimed
                                            : localization
                                                  .giftRedeemHistoryClaimable,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: gift.isRedeemed == true
                                              ? AppColors.warning
                                              : AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${double.tryParse(gift.amount!)!.toStringAsFixed(calculateDecimals)} ${gift.currency}",
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
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
