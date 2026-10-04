import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/model/gift_history_model.dart';

class GiftHistory extends StatefulWidget {
  const GiftHistory({super.key});

  @override
  State<GiftHistory> createState() => _GiftHistoryState();
}

class _GiftHistoryState extends State<GiftHistory> {
  final GiftHistoryController controller = Get.find<GiftHistoryController>();
  final SettingsService settingsService = Get.find<SettingsService>();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Stack(
        children: [
          Obx(() {
            final gifts = controller.allGifts;

            // 1. Loading
            if (controller.isLoading.value && gifts.isEmpty) {
              return const Center(child: CommonLoading());
            }

            // 2. Empty
            if (gifts.isEmpty) {
              return Center(
                child: EcardoEmptyState(
                  iconData: Icons.redeem_rounded,
                  title: 'No Gift Codes Created',
                  description: 'You have not generated any gift vouchers yet. Tap create to send one to a friend.',
                  primaryActionLabel: localizations.noInternetConnectionRetryButton,
                  onPrimaryAction: _onRefresh,
                ),
              );
            }

            // 3. Content
            return RefreshIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
              onRefresh: _onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsetsDirectional.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xxxl,
                  start: AppSpacing.lg,
                  end: AppSpacing.lg,
                ),
                itemBuilder: (context, index) {
                  final Gifts gift = gifts[index];
                  final currency = gift.currency ?? 'USD';
                  final isCrypto = gift.isCrypto ?? false;

                  final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
                    currencyCode: currency,
                    siteCurrencyCode: settingsService.getSetting('site_currency') ?? 'USD',
                    siteCurrencyDecimals:
                        settingsService.getSetting('site_currency_decimals') ?? '2',
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
                      color: isDark ? AppColors.darkCard : const Color(0xFFFFFDF9),
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
                                  localizations.giftHistoryCodeCopied,
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
                          '${localizations.giftHistoryCreatedAt} $formattedDate',
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
                                        ? localizations.giftHistoryClaimed
                                        : localizations.giftHistoryClaimable,
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
                itemCount: gifts.length,
              ),
            );
          }),
          Obx(
            () => Visibility(
              visible: controller.isLoadingMore.value,
              child: const Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
