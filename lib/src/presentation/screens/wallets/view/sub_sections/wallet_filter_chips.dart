import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';

/// Smooth animated filter chips: [All] [Fiat] [Crypto]
/// with responsive badge counters and micro-haptic feedback.
class WalletFilterChips extends StatelessWidget {
  const WalletFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletsController controller = Get.find<WalletsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final active = controller.activeFilter.value;
      final allCount = controller.allCount;
      final fiatCount = controller.fiatCount;
      final cryptoCount = controller.cryptoCount;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1C)
                : const Color(0xFFECEAE8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0x2BD5CBC8)
                  : const Color(0x1F000000),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildChip(
                  context,
                  label: l10nPick(
                    context,
                    en: 'All',
                    fa: 'همه',
                    ar: 'الكل',
                    tr: 'Tümü',
                    ru: 'Все',
                    zh: '全部',
                  ),
                  count: allCount,
                  isSelected: active == WalletFilterType.all,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.setFilter(WalletFilterType.all);
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildChip(
                  context,
                  label: l10nPick(
                    context,
                    en: 'Fiat',
                    fa: 'فیات',
                    ar: 'فيات',
                    tr: 'İtibari',
                    ru: 'Фиат',
                    zh: '法币',
                  ),
                  count: fiatCount,
                  isSelected: active == WalletFilterType.fiat,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.setFilter(WalletFilterType.fiat);
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildChip(
                  context,
                  label: l10nPick(
                    context,
                    en: 'Crypto',
                    fa: 'کریپتو',
                    ar: 'مشفر',
                    tr: 'Kripto',
                    ru: 'Крипто',
                    zh: '加密',
                  ),
                  count: cryptoCount,
                  isSelected: active == WalletFilterType.crypto,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.setFilter(WalletFilterType.crypto);
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkSurface : AppColors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? AppColors.mainSoftBlue.withValues(alpha: 0.22)
                        : AppColors.deepBlack.withValues(alpha: 0.08))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.deepBlack)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
