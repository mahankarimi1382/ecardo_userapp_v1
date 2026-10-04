import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_redeem_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/model/gift_redeem_history_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/gift_redeem_history/sub_sections/gift_redeem_transaction_filter_bottom_sheet.dart';

class GiftRedeemHistory extends StatefulWidget {
  const GiftRedeemHistory({super.key});

  @override
  State<GiftRedeemHistory> createState() => _GiftRedeemHistoryState();
}

class _GiftRedeemHistoryState extends State<GiftRedeemHistory>
    with WidgetsBindingObserver {
  final GiftRedeemHistoryController controller = Get.find<GiftRedeemHistoryController>();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                CommonAppBar(
                  title: localizations.giftRedeemHistoryTitle,
                  rightSideWidget: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.bottomSheet(const GiftRedeemTransactionFilterBottomSheet());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      margin: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Image.asset(
                        PngAssets.commonFilterIcon,
                        color: isDark ? AppColors.mainSoftBlue : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _buildTransactionsList(localizations, isDark),
                ),
              ],
            ),
            Visibility(
              visible: controller.isTransactionsLoading.value ||
                  controller.isPageLoading.value,
              child: const Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(AppLocalizations localization, bool isDark) {
    final transactions =
        controller.giftRedeemHistoryModel.value.data?.gifts ?? [];

    // 1. Loading
    if (controller.isLoading.value && transactions.isEmpty) {
      return const Center(child: CommonLoading());
    }

    // 2. Empty
    if (transactions.isEmpty) {
      return Center(
        child: EcardoEmptyState(
          iconData: Icons.receipt_long_rounded,
          title: 'No Redemption History',
          description: 'You have not redeemed any gift vouchers yet.',
          primaryActionLabel: localization.noInternetConnectionRetryButton,
          onPrimaryAction: refreshData,
        ),
      );
    }

    // 3. Content
    return RefreshIndicator(
      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
      onRefresh: refreshData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          final Gifts gift = transactions[index];
          final currency = gift.currency ?? 'USD';
          final isCrypto = gift.isCrypto ?? false;

          final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
            currencyCode: currency,
            siteCurrencyCode: Get.find<SettingsService>().getSetting('site_currency') ?? 'USD',
            siteCurrencyDecimals:
                Get.find<SettingsService>().getSetting('site_currency_decimals') ?? '2',
            isCrypto: isCrypto,
          );

          DateTime? parsedDate = DateTime.tryParse(gift.createdAt ?? '');
          final formattedDate = parsedDate != null
              ? DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate)
              : (gift.createdAt ?? '');

          final isRedeemed = gift.isRedeemed == true;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : AppColors.mutedBlue.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                        padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                        child: SelectableText(
                          gift.code ?? '',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                          ClipboardData(text: gift.code ?? ''),
                        );
                        ToastHelper().showSuccessToast(
                          localization.giftRedeemHistoryCodeCopied,
                        );
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                              .withValues(alpha: 0.1),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightOutlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Image.asset(
                          PngAssets.commonGiftCopyIcon,
                          color: isDark ? AppColors.mainSoftBlue : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${localization.giftRedeemHistoryCreatedAt} $formattedDate',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder.withValues(alpha: 0.5),
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isRedeemed ? AppColors.warning : AppColors.success)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isRedeemed
                                ? Icons.check_circle_outline_rounded
                                : Icons.redeem_rounded,
                            size: 13,
                            color: isRedeemed ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isRedeemed
                                ? localization.giftRedeemHistoryClaimed
                                : localization.giftRedeemHistoryClaimable,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isRedeemed ? AppColors.warning : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(double.tryParse(gift.amount ?? '0') ?? 0.0).toStringAsFixed(calculateDecimals)} $currency',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: AppSpacing.md);
        },
        itemCount: transactions.length,
      ),
    );
  }
}
