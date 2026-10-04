import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/transaction_type_list.dart';

/// Ultra-clean Neo-Fintech Transaction Filter Bottom Sheet.
///
/// Features:
/// - Direction flow chips: All, Income, Expense, Transfer.
/// - Status selection pills with visual color-coded badges.
/// - Popular category / type selection chips with localization.
/// - Transaction ID search input field with clear button.
/// - Full dark mode adaptation and RTL safe insets.
class TransactionFilterBottomSheet extends StatefulWidget {
  final int initialDirFilter;
  final ValueChanged<int>? onDirectionChanged;

  const TransactionFilterBottomSheet({
    super.key,
    this.initialDirFilter = 0,
    this.onDirectionChanged,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  final TransactionsController controller = Get.find();
  late int _selectedDir;

  // Key quick transaction types for filter sheet
  static const List<String> _popularTypes = [
    'All',
    'Deposit',
    'Withdraw',
    'Send Money',
    'Receive Money',
    'Exchange',
    'Pay Bill',
    'Cash Out',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDir = widget.initialDirFilter;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = AppSpacing.bottomSafe(context, AppSpacing.lg);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.lg,
            end: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: bottomInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkOutline
                        : AppColors.lightOutlineVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Header: Title & Reset Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      en: 'Filter Transactions',
                      fa: 'فیلتر تراکنش‌ها',
                      ar: 'تصفية المعاملات',
                    ),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedDir = 0);
                      widget.onDirectionChanged?.call(0);
                      controller.resetFilters();
                      Get.back();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: AppSpacing.iconXs,
                      color: AppColors.error,
                    ),
                    label: Text(
                      localization.transactionFilterResetButton,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Flow Direction Filter Chips (All, Income, Expense, Transfer)
              Text(
                l10nPick(
                  context,
                  en: 'Transaction Direction',
                  fa: 'جهت تراکنش',
                  ar: 'اتجاه المعاملة',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildDirectionChips(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 4. Status Filter Chips
              Text(
                localization.transactionFilterStatus,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildStatusChips(localization, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 5. Popular Types Chips
              Text(
                l10nPick(
                  context,
                  en: 'Category / Type',
                  fa: 'نوع تراکنش',
                  ar: 'نوع المعاملة',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeChips(context, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 6. Transaction ID Search Field
              Text(
                localization.transactionFilterTransactionId,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(
                () => CommonTextInputField(
                  hintText: l10nPick(
                    context,
                    en: 'e.g. TXN12345678',
                    fa: 'مثال: TXN12345678',
                    ar: 'مثال: TXN12345678',
                  ),
                  controller: controller.transactionIdController,
                  focusNode: controller.transactionIdFocusNode,
                  isFocused: controller.isTransactionIdFocused.value,
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 7. Action Button
              CommonButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  widget.onDirectionChanged?.call(_selectedDir);
                  controller.updateStatusFilter();
                  controller.isFilter.value = true;
                  controller.fetchDynamicTransactions();
                  Get.back();
                },
                width: double.infinity,
                text: localization.transactionFilterApplyButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionChips(BuildContext context, bool isDark) {
    final items = [
      {'label': l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل'), 'val': 0, 'icon': Icons.swap_vert_rounded, 'color': AppColors.mainSoftBlue},
      {'label': l10nPick(context, en: 'Income (+)', fa: 'ورودی (+)', ar: 'وارد (+)'), 'val': 1, 'icon': Icons.arrow_downward_rounded, 'color': AppColors.success},
      {'label': l10nPick(context, en: 'Expense (-)', fa: 'خروجی (-)', ar: 'صادر (-)'), 'val': 2, 'icon': Icons.arrow_upward_rounded, 'color': AppColors.error},
      {'label': l10nPick(context, en: 'Transfer', fa: 'انتقال', ar: 'تحويل'), 'val': 3, 'icon': Icons.sync_alt_rounded, 'color': AppColors.mutedBlue},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        final val = item['val'] as int;
        final isSelected = _selectedDir == val;
        final color = item['color'] as Color;

        return InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDir = val;
              if (val == 3) {
                // Pre-select 'Send Money' if available
                final idx = controller.typesList.indexOf('Send Money');
                if (idx != -1) {
                  controller.selectedTypeIndex.value = idx;
                  controller.selectedType.value = 'Send Money';
                }
              }
            });
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.28 : 0.15)
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: AppSpacing.iconXs,
                  color: isSelected ? color : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  item['label'] as String,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppColors.darkTextPrimary : color)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusChips(AppLocalizations localization, bool isDark) {
    return Obx(() {
      final selectedIndex = controller.selectedStatusIndex.value;

      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          // All Statuses Chip
          _buildChip(
            label: l10nPick(context, en: 'All Statuses', fa: 'همه وضعیت‌ها', ar: 'جميع الحالات'),
            isSelected: selectedIndex == -1,
            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectedStatusIndex.value = -1;
            },
          ),
          // Specific Status Chips
          ...List.generate(controller.statusList.length, (index) {
            final status = controller.statusList[index];
            final isSelected = selectedIndex == index;

            Color statusColor;
            switch (status.toLowerCase()) {
              case 'success':
                statusColor = AppColors.success;
                break;
              case 'pending':
                statusColor = AppColors.warning;
                break;
              case 'failed':
                statusColor = AppColors.error;
                break;
              default:
                statusColor = AppColors.mainSoftBlue;
            }

            return _buildChip(
              label: StatusLabelHelper.localize(localization, status),
              isSelected: isSelected,
              color: statusColor,
              isDark: isDark,
              onTap: () {
                HapticFeedback.selectionClick();
                if (controller.selectedStatusIndex.value == index) {
                  controller.selectedStatusIndex.value = -1;
                } else {
                  controller.selectedStatusIndex.value = index;
                }
              },
            );
          }),
        ],
      );
    });
  }

  Widget _buildTypeChips(BuildContext context, bool isDark) {
    return Obx(() {
      final selectedType = controller.selectedType.value;

      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _popularTypes.map((type) {
          final isSelected = (type == 'All' && selectedType.isEmpty) ||
              selectedType.toLowerCase() == type.toLowerCase();
          final localizedLabel = TransactionTypeList.localizeType(context, type);

          return _buildChip(
            label: localizedLabel,
            isSelected: isSelected,
            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              final idx = controller.typesList.indexOf(type);
              if (idx != -1) {
                controller.selectedTypeIndex.value = idx;
              }
              if (type == 'All') {
                controller.selectedType.value = '';
              } else {
                controller.selectedType.value = type;
              }
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.28 : 0.15)
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.darkTextPrimary : color)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
