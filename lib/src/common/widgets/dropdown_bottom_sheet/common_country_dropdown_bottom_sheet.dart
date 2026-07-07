import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class CommonCountryDropdownBottomSheet extends StatefulWidget {
  final String title;
  final double bottomSheetHeight;
  final List<String> dropdownItems;
  final RxString selectedItem;
  final TextEditingController textController;
  final List<String>? countryImage;
  final List<String>? countryCode;
  final List<String>? countryDialCode;
  final dynamic controller;
  final bool isFocused;
  final VoidCallback? clearFunction;

  const CommonCountryDropdownBottomSheet({
    super.key,
    required this.dropdownItems,
    required this.selectedItem,
    required this.textController,
    required this.title,
    required this.bottomSheetHeight,
    this.countryImage,
    this.countryCode,
    this.controller,
    this.countryDialCode,
    this.isFocused = false,
    this.clearFunction,
  });

  @override
  State<CommonCountryDropdownBottomSheet> createState() =>
      _CommonCountryDropdownBottomSheetState();
}

class _CommonCountryDropdownBottomSheetState
    extends State<CommonCountryDropdownBottomSheet> {
  late TextEditingController _searchController;
  late List<MapEntry<int, String>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.dropdownItems.asMap().entries.toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.dropdownItems
          .asMap()
          .entries
          .where(
            (entry) => entry.value.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final Color borderColor = widget.isFocused
        ? AppColors.lightPrimary.withValues(alpha: 0.60)
        : AppColors.lightTextPrimary.withValues(alpha: 0.20);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: widget.bottomSheetHeight,
      margin: EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12),
          Container(
            width: 45,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          SizedBox(height: 25),
          Container(
            margin: EdgeInsetsDirectional.only(
              start: 18,
              end: 18,
              bottom: 20,
            ),
            height: 52,
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: AppColors.transparent,
                hintText: localization.commonCountryDropdownSearchHint,
                hintStyle: TextStyle(
                  color: AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0,
                  height: 1.1,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor, width: 1.5),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 6,
                    top: 14,
                    bottom: 14,
                  ),
                  child: Image(
                    image: AssetImage(PngAssets.searchCommonIcon),
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.44),
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextPrimary,
                letterSpacing: 0,
                height: 1.1,
              ),
            ),
          ),
          _filteredItems.isEmpty ? _buildEmptyState() : _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Expanded(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
        padding: EdgeInsetsDirectional.only(
          start: 18,
          end: 18,
          bottom: 18,
        ),
        itemBuilder: (context, index) {
          final entry = _filteredItems[index];
          final item = entry.value;
          final originalIndex = entry.key;
          final isSelected = widget.selectedItem.value == item;
          final flag =
              widget.countryImage != null &&
                  originalIndex < widget.countryImage!.length
              ? widget.countryImage![originalIndex]
              : null;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.lightPrimary.withValues(alpha: 0.06)
                  : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: AppColors.lightPrimary.withValues(alpha: 0.20),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                highlightColor: AppColors.transparent,
                onTap: () {
                  toggleWalletSelection(item, originalIndex);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      if (flag != null) ...[
                        Image.network(flag, width: 24, fit: BoxFit.cover),
                        SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.lightPrimary
                                : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Image.asset(
                          PngAssets.commonDropdownTickIcon,
                          width: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: _filteredItems.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    final localization = AppLocalizations.of(context)!;

    return Expanded(
      child: Center(
        child: Column(
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
              localization.commonCountryDropdownNotFound,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleWalletSelection(String item, int index) {
    widget.selectedItem.value = item;
    widget.textController.text = item;

    if (widget.controller != null &&
        widget.countryCode != null &&
        index < widget.countryCode!.length &&
        widget.countryDialCode != null &&
        index < widget.countryDialCode!.length) {
      widget.controller.countryCode.value = widget.countryCode![index];
      widget.controller.countryDialCode.value = widget.countryDialCode![index];
    }

    if (widget.clearFunction != null) {
      widget.clearFunction!();
    }

    Get.back();
  }
}
