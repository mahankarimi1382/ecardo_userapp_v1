import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/model/payment_links_history_model.dart';

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
  final RxBool _hasLoadError = false.obs;

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
    _hasLoadError.value = false;
    try {
      await controller.fetchPaymentLinksHistory(isRefresh: true);
    } catch (_) {
      _hasLoadError.value = true;
    } finally {
      controller.isListLoading.value = false;
    }
  }

  Future<void> _onRefresh() async {
    _hasLoadError.value = false;
    try {
      await controller.fetchPaymentLinksHistory(isRefresh: true);
    } catch (_) {
      _hasLoadError.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final paymentLinks = controller.allPaymentLinks;

            if (controller.isListLoading.value && paymentLinks.isEmpty) {
              return const CommonLoading();
            }

            if (_hasLoadError.value && paymentLinks.isEmpty) {
              return EcardoErrorView(
                message: localizations.allControllerLoadError,
                onRetry: loadData,
                retryLabel: localizations.noInternetConnectionRetryButton,
              );
            }

            if (paymentLinks.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: EcardoEmptyState(
                        title: localizations.paymentLinksTabList,
                        description: localizations.noDataFound,
                        iconData: Icons.link_rounded,
                        primaryActionLabel: localizations.paymentLinksTabCreate,
                        onPrimaryAction: () {
                          HapticFeedback.lightImpact();
                          controller.selectedScreen.value = 1;
                        },
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              onRefresh: _onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsetsDirectional.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xxxl,
                  start: AppSpacing.page,
                  end: AppSpacing.page,
                ),
                itemBuilder: (context, index) {
                  final PaymentLinks paymentLink = paymentLinks[index];
                  final isPaid = paymentLink.isPaid == true;
                  final statusColor =
                      isPaid ? AppColors.success : AppColors.warning;

                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
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
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
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
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  color: (isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary)
                                      .withValues(alpha: 0.10),
                                  border: Border.all(
                                    color: (isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lightPrimary)
                                        .withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                                child: Image.asset(
                                  PngAssets.commonGiftCopyIcon,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "${localizations.paymentLinksListItemCreatedAt} ${paymentLink.createdAt ?? ''}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Divider(
                            height: 1,
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.paymentLinksListItemStatus,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextTertiary,
                              ),
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
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                                color: statusColor.withValues(alpha: 0.08),
                              ),
                              child: Text(
                                isPaid
                                    ? localizations.paymentLinksStatusPaid
                                    : localizations.paymentLinksStatusUnpaid,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemCount: paymentLinks.length,
              ),
            );
          }),
        ],
      ),
    );
  }
}
