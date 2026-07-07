import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/controller/bill_payment_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/bill_payment_history_model.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/view/bill_payment_history/sub_sections/bill_payment_history_details.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class BillPaymentHistory extends StatefulWidget {
  const BillPaymentHistory({super.key});

  @override
  State<BillPaymentHistory> createState() => _BillPaymentHistoryState();
}

class _BillPaymentHistoryState extends State<BillPaymentHistory>
    with WidgetsBindingObserver {
  final BillPaymentHistoryController controller = Get.find();
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
      controller.loadMoreBillPaymentHistory();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchBillPaymentHistory();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchBillPaymentHistory();
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
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                CommonAppBar(
                  title: AppLocalizations.of(context)!.billPaymentHistoryTitle,
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
                        _buildBillPaymentHistoryList(),
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

  Widget _buildBillPaymentHistoryList() {
    final bills = controller.billPaymentHistoryModel.value.data?.bills ?? [];

    if (controller.isLoading.value) {
      return Expanded(child: CommonLoading());
    }

    if (bills.isEmpty) {
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
                    final Bills bill = bills[index];

                    return GestureDetector(
                      onTap: () {
                        Get.bottomSheet(BillPaymentHistoryDetails(bill: bill));
                      },
                      child: Container(
                        color: AppColors.transparent,
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
                                      color: Color(0xFF4D8D7E),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        PngAssets.payBillTransaction,
                                        color: AppColors.white,
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
                                          bill.serviceName ?? "",
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
                                          bill.createdAt!.split(",").first,
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
                                Text(
                                  "${bill.amount} ${Get.find<SettingsService>().getSetting("site_currency")}",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: AppColors.success,
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
                  itemCount: bills.length,
                ),
              ),
      ),
    );
  }
}
