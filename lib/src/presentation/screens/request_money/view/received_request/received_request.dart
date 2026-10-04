import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/received_request_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/model/received_request_model.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/received_request/sub_sections/received_request_details.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_header_section.dart';

class ReceivedRequest extends StatefulWidget {
  const ReceivedRequest({super.key});

  @override
  State<ReceivedRequest> createState() => _ReceivedRequestState();
}

class _ReceivedRequestState extends State<ReceivedRequest> {
  final ReceivedRequestController controller = Get.find();
  final SettingsService settingsService = Get.find();
  late ScrollController _scrollController;
  final RxBool _hasLoadError = false.obs;

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
    _hasLoadError.value = false;
    try {
      await controller.fetchReceivedRequest(isRefresh: true);
    } catch (_) {
      _hasLoadError.value = true;
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> _onRefresh() async {
    _hasLoadError.value = false;
    try {
      await controller.fetchReceivedRequest(isRefresh: true);
    } catch (_) {
      _hasLoadError.value = true;
    }
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
    if (status.isEmpty) return '';
    final loc = AppLocalizations.of(Get.context!);
    if (loc == null) return status;
    return StatusLabelHelper.localize(loc, status);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "success":
      case "approved":
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Obx(() {
          final requests = controller.allReceivedRequest;

          return RefreshIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            onRefresh: _onRefresh,
            child: Column(
              children: [
                const RequestMoneyHeaderSection(),
                Expanded(
                  child: controller.isLoading.value
                      ? const CommonLoading()
                      : _hasLoadError.value
                      ? EcardoErrorView(
                          message: localization.allControllerLoadError,
                          onRetry: loadData,
                          retryLabel:
                              localization.noInternetConnectionRetryButton,
                        )
                      : requests.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: EcardoEmptyState(
                                  title: localization
                                      .requestMoneyHeaderSectionReceivedRequestButton,
                                  description: localization.noDataFound,
                                  iconData: Icons.move_to_inbox_rounded,
                                  primaryActionLabel: localization
                                      .requestMoneyHeaderSectionRequestMoneyButton,
                                  onPrimaryAction: () {
                                    HapticFeedback.lightImpact();
                                    Get.find<RequestMoneyController>()
                                        .selectedScreen
                                        .value = 0;
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          padding: const EdgeInsetsDirectional.only(
                            top: AppSpacing.lg,
                            bottom: AppSpacing.xxxl,
                            start: AppSpacing.page,
                            end: AppSpacing.page,
                          ),
                          itemBuilder: (context, index) {
                            final Requests request = requests[index];
                            final requesterName = _getRequesterName(request);
                            final statusColor =
                                _getStatusColor(request.status);

                            return InkWell(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Get.bottomSheet(
                                  ReceivedRequestDetails(request: request),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkCard
                                      : AppColors.lightCard,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? AppColors.darkShadow
                                          : AppColors.lightShadow,
                                      blurRadius: AppSpacing.sm,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        MonogramAvatar(
                                          name: requesterName,
                                          imageUrl: request.requester?.avatar,
                                          size: 42,
                                          isVerified: true,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Text(
                                            requesterName,
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _getAmount(request),
                                          style: TextStyle(
                                            letterSpacing: -0.2,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
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
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isDark
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.lightTextTertiary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
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
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.lightTextPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusFull,
                                            ),
                                            border: Border.all(
                                              color: statusColor.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                            color: statusColor.withValues(
                                              alpha: 0.08,
                                            ),
                                          ),
                                          child: Text(
                                            _getStatus(request),
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontSize: 11,
                                              color: statusColor,
                                              fontWeight: FontWeight.w800,
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
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemCount: requests.length,
                        ),
                ),
              ],
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
    );
  }
}
