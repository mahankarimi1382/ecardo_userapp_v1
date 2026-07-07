import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/model/payment_links_history_model.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

import '../../../../../../l10n/app_localizations.dart';

class PaymentLinksListSection extends StatefulWidget {
  const PaymentLinksListSection({super.key});

  @override
  State<PaymentLinksListSection> createState() =>
      _PaymentLinksListSectionState();
}

class _PaymentLinksListSectionState extends State<PaymentLinksListSection> {
  final PaymentLinksController controller = Get.find();
  final SettingsService settingsService = Get.find();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    if (!controller.isInitialized.value) {
      loadData();
      controller.isInitialized.value = true;
    }
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
      controller.loadMoreGiftHistory();
    }
  }

  Future<void> loadData() async {
    controller.isListLoading.value = true;
    await controller.fetchPaymentLinksHistory(isRefresh: true);
    controller.isListLoading.value = false;
  }

  Future<void> _onRefresh() async {
    await controller.fetchPaymentLinksHistory(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final paymentLinks = controller.allPaymentLinks;

            if (controller.isListLoading.value && paymentLinks.isEmpty) {
              return CommonLoading();
            }

            if (paymentLinks.isEmpty) {
              return NoDataFound();
            }

            return RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: _onRefresh,
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsetsDirectional.only(
                  top: 30,
                  bottom: 30,
                  start: 18,
                  end: 18,
                ),
                itemBuilder: (context, index) {
                  final PaymentLinks paymentLink = paymentLinks[index];

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
                                  paymentLink.number ?? "",
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
                                  ClipboardData(
                                    text: paymentLink.paymentLink ?? "",
                                  ),
                                );
                                ToastHelper().showSuccessToast(
                                  localizations.paymentLinksCopySuccessToast,
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
                          "${localizations.paymentLinksListItemCreatedAt}${paymentLink.createdAt}",
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
                          children: [
                            Text(
                              localizations.paymentLinksListItemStatus,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.lightTextTertiary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                paymentLink.isPaid == true
                                    ? localizations.paymentLinksStatusPaid
                                    : localizations.paymentLinksStatusUnpaid,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: paymentLink.isPaid == true
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
                itemCount: paymentLinks.length,
              ),
            );
          }),
          Obx(
            () => Visibility(
              visible: controller.isListLoadingMore.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
