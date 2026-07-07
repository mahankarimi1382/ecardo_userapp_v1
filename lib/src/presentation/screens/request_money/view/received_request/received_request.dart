import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/received_request_controller.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/model/received_request_model.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/received_request/sub_sections/accept_request_dropdown.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/received_request/sub_sections/received_request_details.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/sub_sections/request_money_header_section.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

class ReceivedRequest extends StatefulWidget {
  const ReceivedRequest({super.key});

  @override
  State<ReceivedRequest> createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest> {
  final ReceivedRequestController controller = Get.find();
  final SettingsService settingsService = Get.find();
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
    await controller.fetchReceivedRequest(isRefresh: true);
    controller.isLoading.value = false;
  }

  Future<void> _onRefresh() async {
    await controller.fetchReceivedRequest(isRefresh: true);
  }

  String _getRequesterName(Requests request) {
    return request.requester?.name ?? "";
  }

  String _getAmount(Requests request) {
    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: request.currency ?? '',
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? '',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: request.isCrypto ?? false,
    );

    final amount = double.tryParse(request.amount ?? '0') ?? 0;
    return "${request.currencySymbol ?? ''}${amount.toStringAsFixed(calculateDecimals)}";
  }

  String _getStatus(Requests request) {
    final status = request.status ?? '';
    return status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : "";
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "success":
        return AppColors.success;
      case "pending":
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Obx(() {
          final requests = controller.allReceivedRequest;

          return RefreshIndicator(
            color: AppColors.lightPrimary,
            onRefresh: _onRefresh,
            child: Column(
              children: [
                const RequestMoneyHeaderSection(),
                Expanded(
                  child: controller.isLoading.value
                      ? CommonLoading()
                      : requests.isEmpty
                      ? NoDataFound()
                      : ListView.separated(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          padding: const EdgeInsetsDirectional.only(
                            top: 30,
                            bottom: 30,
                            start: 18,
                            end: 18,
                          ),
                          itemBuilder: (context, index) {
                            final Requests request = requests[index];

                            return InkWell(
                              onTap: () {
                                Get.bottomSheet(
                                  ReceivedRequestDetails(request: request),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBackground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getRequesterName(request),
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: AppColors.lightTextPrimary,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _getAmount(request),
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              localization
                                                  .receivedRequestRequestedAt,
                                              style: TextStyle(
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextTertiary,
                                              ),
                                            ),
                                            Text(
                                              DateFormat(
                                                "dd MMM yyyy hh:mm a",
                                              ).format(
                                                DateTime.parse(
                                                  request.createdAt ??
                                                      DateTime.now().toString(),
                                                ),
                                              ),
                                              style: TextStyle(
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              localization
                                                  .receivedRequestStatus,
                                              style: TextStyle(
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color:
                                                    AppColors.lightTextTertiary,
                                              ),
                                            ),
                                            Text(
                                              _getStatus(request),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0,
                                                fontSize: 13,
                                                color: getStatusColor(
                                                  request.status,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (request.status == "pending") ...[
                                      SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.white,
                                              AppColors.lightTextPrimary
                                                  .withValues(alpha: 0.1),
                                              AppColors.white,
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CommonButton(
                                              backgroundColor: AppColors.error
                                                  .withValues(alpha: 0.10),
                                              width: double.infinity,
                                              height: 45,
                                              text: localization
                                                  .receivedRequestRejectButton,
                                              textColor: AppColors.error,
                                              fontSize: 14,
                                              onPressed: () => controller
                                                  .submitRequestAction(
                                                    requestId:
                                                        request.id
                                                            ?.toString() ??
                                                        '',
                                                    action: "reject",
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: CommonButton(
                                              onPressed: () {
                                                Get.bottomSheet(
                                                  SizedBox(
                                                    height: Get.height * 0.65,
                                                    child:
                                                        AcceptRequestDropdown(
                                                          request: request,
                                                        ),
                                                  ),
                                                  isScrollControlled: true,
                                                );
                                              },
                                              width: double.infinity,
                                              height: 45,
                                              text: localization
                                                  .receivedRequestAcceptButton,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 16);
                          },
                          itemCount: requests.length,
                        ),
                ),
              ],
            ),
          );
        }),
        Obx(
          () => Visibility(
            visible:
                controller.isLoadingMore.value ||
                controller.isSubmittingAction.value,
            child: CommonLoading(),
          ),
        ),
      ],
    );
  }
}
