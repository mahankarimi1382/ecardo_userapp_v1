import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';

/// Modern Total Net Worth Hero Banner with privacy mode toggle,
/// multi-currency breakdown, and animated balance presentation.
class NetWorthBanner extends StatelessWidget {
  const NetWorthBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletsController controller = Get.find<WalletsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isPrivacy = controller.isPrivacyMode.value;
      final formattedTotal = controller.formattedNetWorth;
      final totalWallets = controller.allCount;
      final fiatCount = controller.fiatCount;
      final cryptoCount = controller.cryptoCount;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF222220),
                    const Color(0xFF191917),
                    const Color(0xFF141412),
                  ]
                : [
                    AppColors.white,
                    const Color(0xFFF9F8F7),
                    const Color(0xFFF1EFEB),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? const Color(0x33D5CBC8)
                : const Color(0x26161614),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Caption & Privacy Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.deepBlack)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.deepBlack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10nPick(
                        context,
                        en: 'Total Net Worth',
                        fa: 'ارزش کل دارایی‌ها',
                        ar: 'إجمالي صافي القيمة',
                        tr: 'Toplam Net Değer',
                        ru: 'Общая стоимость активов',
                        zh: '总净资产',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                // Privacy Mode Toggle Eye Button
                Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: isPrivacy
                        ? l10nPick(
                            context,
                            en: 'Show balance',
                            fa: 'نمایش موجودی',
                            ar: 'إظهار الرصيد',
                            tr: 'Bakiyeyi göster',
                            ru: 'Показать баланс',
                            zh: '显示余额',
                          )
                        : l10nPick(
                            context,
                            en: 'Hide balance',
                            fa: 'مخفی کردن موجودی',
                            ar: 'إخفاء الرصيد',
                            tr: 'Bakiyeyi gizle',
                            ru: 'Скрыть баланс',
                            zh: '隐藏余额',
                          ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.togglePrivacyMode();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isPrivacy
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Animated Big Balance Display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: isPrivacy
                  ? Text(
                      '••••••••',
                      key: const ValueKey('privacy_hidden'),
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    )
                  : FittedBox(
                      key: const ValueKey('privacy_visible'),
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart.resolve(
                        Directionality.of(context),
                      ),
                      child: Text(
                        formattedTotal,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Bottom Row: Multi-currency breakdown chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStatPill(
                    context,
                    label: l10nPick(
                      context,
                      en: 'All Wallets',
                      fa: 'همه کیف‌پول‌ها',
                      ar: 'جميع المحافظ',
                      tr: 'Tüm Cüzdanlar',
                      ru: 'Все кошельки',
                      zh: '所有钱包',
                    ),
                    count: totalWallets,
                    isSelected: controller.activeFilter.value == WalletFilterType.all,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setFilter(WalletFilterType.all);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildStatPill(
                    context,
                    label: l10nPick(
                      context,
                      en: 'Fiat',
                      fa: 'فیات',
                      ar: 'عملات ورقية',
                      tr: 'İtibari',
                      ru: 'Фиат',
                      zh: '法定货币',
                    ),
                    count: fiatCount,
                    isSelected: controller.activeFilter.value == WalletFilterType.fiat,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setFilter(WalletFilterType.fiat);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildStatPill(
                    context,
                    label: l10nPick(
                      context,
                      en: 'Crypto',
                      fa: 'کریپتو',
                      ar: 'عملات مشفرة',
                      tr: 'Kripto',
                      ru: 'Крипто',
                      zh: '加密货币',
                    ),
                    count: cryptoCount,
                    isSelected: controller.activeFilter.value == WalletFilterType.crypto,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.setFilter(WalletFilterType.crypto);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatPill(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeBg = isDark
        ? AppColors.mainSoftBlue.withValues(alpha: 0.20)
        : AppColors.deepBlack.withValues(alpha: 0.10);
    final activeBorder = isDark
        ? AppColors.mainSoftBlue.withValues(alpha: 0.5)
        : AppColors.deepBlack.withValues(alpha: 0.3);
    final activeTextColor = isDark
        ? AppColors.mainSoftBlue
        : AppColors.deepBlack;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? activeBg
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeBorder
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? activeTextColor
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeTextColor.withValues(alpha: 0.18)
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? activeTextColor
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
