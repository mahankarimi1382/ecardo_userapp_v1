import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/model/gift_history_model.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class GiftHistory extends StatefulWidget {
  const GiftHistory({super.key});

  @override
  State<GiftHistory> createState() => _GiftHistoryState();
}

class _GiftHistoryState extends State<GiftHistory> {
  final GiftHistoryController controller = Get.find();
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
    controller.isLoading.value = true;
    await controller.fetchGiftHistory(isRefresh: true);
    controller.isLoading.value = false;
  }

  Future<void> _onRefresh() async {
    await controller.fetchGiftHistory(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final gifts = controller.allGifts;

            if (controller.isLoading.value && gifts.isEmpty) {
              return CommonLoading();
            }

            if (gifts.isEmpty) {
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
                  final Gifts gift = gifts[index];

                  final calculateDecimals = DynamicDecimalsHelper()
                      .getDynamicDecimals(
                        currencyCode: gift.currency!,
                        siteCurrencyCode: settingsService.getSetting(
                          "site_currency",
                        )!,
                        siteCurrencyDecimals: settingsService.getSetting(
                          "site_currency_decimals",
                        )!,
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
                                  localizations.giftHistoryCodeCopied,
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
                          "${localizations.giftHistoryCreatedAt} ${DateFormat("dd MMM yyyy hh:mm a").format(DateTime.parse(gift.createdAt ?? ""))}",
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
                                    localizations.giftHistoryStatus,
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
                                          ? localizations.giftHistoryClaimed
                                          : localizations.giftHistoryClaimable,
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
                  return const SizedBox(height: 15);
                },
                itemCount: gifts.length,
              ),
            );
          }),
          Obx(
            () => Visibility(
              visible: controller.isLoadingMore.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
