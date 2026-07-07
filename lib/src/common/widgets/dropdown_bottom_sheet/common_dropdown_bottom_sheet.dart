import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class CommonDropdownBottomSheet extends StatefulWidget {
  final double bottomSheetHeight;
  final List<String> dropdownItems;
  final String selectedItem;
  final TextEditingController textController;
  final List<String>? selectedValue;
  final Function(dynamic)? onValueSelected;
  final Function? onValueUnSelected;
  final String currentlySelectedValue;
  final bool showSearch;
  final bool? isUnselectedValue;
  final String? searchHint;
  final String notFoundText;
  final bool isFocused;
  final String? title;
  final bool? isShowTitle;

  const CommonDropdownBottomSheet({
    super.key,
    required this.dropdownItems,
    required this.selectedItem,
    required this.textController,
    required this.bottomSheetHeight,
    this.selectedValue,
    this.onValueSelected,
    required this.currentlySelectedValue,
    this.showSearch = false,
    this.searchHint,
    this.onValueUnSelected,
    this.isUnselectedValue = false,
    required this.notFoundText,
    this.isFocused = false,
    this.title,
    this.isShowTitle = false,
  });

  @override
  State<CommonDropdownBottomSheet> createState() =>
      _CommonDropdownBottomSheetState();
}

class _CommonDropdownBottomSheetState extends State<CommonDropdownBottomSheet> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.dropdownItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.dropdownItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
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
      margin: EdgeInsets.symmetric(horizontal: 12),
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
          if (widget.isShowTitle == true) ...[
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title!,
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
          ],
          if (widget.showSearch) ...[
            Container(
              margin: EdgeInsetsDirectional.only(
                start: 18,
                end: 18,
                top: 20,
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
                  hintText: localization.commonDropdownSearchHint,
                  hintStyle: TextStyle(
                    color: AppColors.lightTextTertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: _getBorderRadius(context),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: _getBorderRadius(context),
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
          ],
          _filteredItems.isEmpty
              ? Expanded(
                  child: _buildEmptyState(notFoundText: widget.notFoundText),
                )
              : _buildItemsList(),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: 18,
          end: 18,
          bottom: 18,
          top: 20,
        ),
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final isSelected = widget.currentlySelectedValue == item;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.lightPrimary.withValues(alpha: 0.06)
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
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                highlightColor: AppColors.transparent,
                onTap: () {
                  toggleWalletSelection(item);
                  Get.back();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.lightPrimary
                                : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Image.asset(
                          PngAssets.commonDropdownTickIcon,
                          width: 18,
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

  Widget _buildEmptyState({required String notFoundText}) {
    return SizedBox(
      width: double.infinity,
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
            notFoundText,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  void toggleWalletSelection(String item) {
    if (widget.selectedItem == item) {
      widget.textController.clear();
      if (widget.isUnselectedValue == true) {
        widget.onValueUnSelected?.call();
      } else {
        widget.onValueSelected?.call("");
      }
    } else {
      widget.textController.text = item;
      if (widget.selectedValue != null) {
        int originalIndex = widget.dropdownItems.indexOf(item);
        if (originalIndex != -1 &&
            originalIndex < widget.selectedValue!.length) {
          widget.onValueSelected?.call(widget.selectedValue![originalIndex]);
        } else {
          widget.onValueSelected?.call(item);
        }
      } else {
        widget.onValueSelected?.call(item);
      }
    }
  }

  BorderRadius _getBorderRadius(BuildContext context) {
    return BorderRadius.circular(16);
  }
}
