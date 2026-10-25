import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

class CommonDropdownWalletBottomSheet extends StatefulWidget {
  final double bottomSheetHeight;
  final List<dynamic> dropdownItems;
  final String? currentlySelectedValue;
  final Function(String) onItemSelected;
  final String notFoundText;

  const CommonDropdownWalletBottomSheet({
    super.key,
    required this.dropdownItems,
    required this.bottomSheetHeight,
    this.currentlySelectedValue,
    required this.onItemSelected,
    required this.notFoundText,
  });

  @override
  State<CommonDropdownWalletBottomSheet> createState() =>
      _CommonDropdownWalletBottomSheetState();
}

class _CommonDropdownWalletBottomSheetState
    extends State<CommonDropdownWalletBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? AppColors.darkSurface : AppColors.white;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final handleColor = (isDark ? AppColors.warmWhite : AppColors.lightTextPrimary)
        .withValues(alpha: 0.2);

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: widget.bottomSheetHeight,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(24),
            topEnd: Radius.circular(24),
          ),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.commonDropdownWalletTitle,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      color: titleColor,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.back(),
                    child: Tooltip(
                      message: l10nPick(context, en: 'Close', fa: 'بستن'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: 1,
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder.withValues(alpha: 0.4),
            ),
            widget.dropdownItems.isEmpty
                ? _buildEmptyState(notFoundText: widget.notFoundText, isDark: isDark)
                : _buildItemsList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String notFoundText,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            notFoundText,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(bool isDark) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: 18,
          end: 18,
          bottom: AppSpacing.bottomSafe(context, 18),
          top: 16,
        ),
        itemCount: widget.dropdownItems.length,
        itemBuilder: (context, index) {
          final item = widget.dropdownItems[index];
          final String name = item.name?.toString() ?? item.code?.toString() ?? '';
          final String code = item.code?.toString() ?? '';
          final String symbol = item.symbol?.toString() ?? code;
          final String balance = item.formattedBalance?.toString() ??
              item.balance?.toString() ??
              '0';
          final String? iconUrl = item.icon?.toString();
          final bool isDefault = item.isDefault == true;

          final isSelected = widget.currentlySelectedValue == name ||
              widget.currentlySelectedValue == item.id?.toString();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.16)
                      : AppColors.lightPrimary.withValues(alpha: 0.08))
                  : (isDark
                      ? AppColors.darkCard
                      : AppColors.lightBackground),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                    : (isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder.withValues(alpha: 0.3)),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                    .withValues(alpha: 0.1),
                highlightColor: Colors.transparent,
                onTap: () {
                  widget.onItemSelected(name);
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Wallet Icon or Default Badge
                            isDefault
                                ? Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.mainSoftBlue.withValues(alpha: 0.2)
                                          : AppColors.lightPrimary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        symbol.isNotEmpty ? symbol : '\$',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          color: isDark
                                              ? AppColors.mainSoftBlue
                                              : AppColors.lightPrimary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : AppColors.lightSecondaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: (iconUrl != null &&
                                            iconUrl.isNotEmpty &&
                                            iconUrl.startsWith('http'))
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              iconUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Center(
                                                child: Text(
                                                  code.isNotEmpty ? code[0] : 'W',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? AppColors.darkTextPrimary
                                                        : AppColors.lightTextPrimary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              code.isNotEmpty ? code[0] : 'W',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.lightTextPrimary,
                                              ),
                                            ),
                                          ),
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontSize: 15,
                                            color: isSelected
                                                ? (isDark
                                                    ? AppColors.mainSoftBlue
                                                    : AppColors.lightPrimary)
                                                : (isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.lightTextPrimary),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (isDefault) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            l10nPick(
                                              context,
                                              en: 'DEFAULT',
                                              fa: 'اصلی',
                                              ar: 'افتراضي',
                                              tr: 'Varsayılan',
                                              ru: 'Основной',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "$balance $code",
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.lightPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
