import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: widget.bottomSheetHeight,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12),
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.commonDropdownWalletTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 28,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18),
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightTextPrimary.withValues(alpha: 0.1),
                  AppColors.white,
                ],
              ),
            ),
          ),
          widget.dropdownItems.isEmpty
              ? _buildEmptyState(notFoundText: widget.notFoundText)
              : _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required String notFoundText}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 40,
          color: AppColors.lightTextTertiary,
        ),
        SizedBox(height: 5),
        Text(
          notFoundText,
          style: TextStyle(
            letterSpacing: 0,
            fontSize: 16,
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: 16);
        },
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: 18,
          end: 18,
          bottom: 18,
          top: 20,
        ),
        itemCount: widget.dropdownItems.length,
        itemBuilder: (context, index) {
          final item = widget.dropdownItems[index];
          final isSelected = widget.currentlySelectedValue == item.name;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.lightPrimary.withValues(alpha: 0.10)
                  : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: AppColors.lightPrimary.withValues(alpha: 0.20),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                highlightColor: Colors.transparent,
                onTap: () {
                  widget.onItemSelected(item.name!);
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            item.isDefault == true
                                ? Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.symbol!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          color: AppColors.lightPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Image.network(
                                        item.icon!,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                PngAssets.commonErrorIcon,
                                                color: AppColors.error
                                                    .withValues(alpha: 0.7),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name!,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 18,
                                    color: isSelected
                                        ? AppColors.lightPrimary
                                        : AppColors.lightTextPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${item.formattedBalance!} ${item.code}",
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Image.asset(
                          PngAssets.commonDropdownTickIcon,
                          width: 20,
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
