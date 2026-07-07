import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class CommonDropdownBottomSheetTwo extends StatefulWidget {
  final double bottomSheetHeight;
  final List<String> dropdownItems;
  final String? currentlySelectedValue;
  final Function(String) onItemSelected;
  final String? searchHint;
  final bool showSearch;
  final String notFoundText;
  final bool isFocused;
  final bool? isNavigationPop;

  const CommonDropdownBottomSheetTwo({
    super.key,
    required this.dropdownItems,
    required this.bottomSheetHeight,
    this.currentlySelectedValue,
    required this.onItemSelected,
    this.searchHint,
    this.showSearch = false,
    required this.notFoundText,
    this.isFocused = false,
    this.isNavigationPop = true,
  });

  @override
  State<CommonDropdownBottomSheetTwo> createState() =>
      _CommonDropdownBottomSheetTwoState();
}

class _CommonDropdownBottomSheetTwoState
    extends State<CommonDropdownBottomSheetTwo> {
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
  void didUpdateWidget(CommonDropdownBottomSheetTwo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dropdownItems != widget.dropdownItems) {
      _searchController.clear();
      _filteredItems = widget.dropdownItems;
    }
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
            width: 45,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          SizedBox(height: 25),
          if (widget.showSearch) ...[
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
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: AppColors.transparent,
                  hintText: localization.commonDropdownTwoSearchHint,
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
            fontSize: 16,
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
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
        ),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final isSelected = widget.currentlySelectedValue == item;

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
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                splashColor: AppColors.lightPrimary.withValues(alpha: 0.06),
                highlightColor: Colors.transparent,
                onTap: () {
                  widget.onItemSelected(item);
                  if (widget.isNavigationPop == true) {
                    Get.back();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          width: 16,
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

  BorderRadius _getBorderRadius(BuildContext context) {
    return BorderRadius.circular(10);
  }
}
