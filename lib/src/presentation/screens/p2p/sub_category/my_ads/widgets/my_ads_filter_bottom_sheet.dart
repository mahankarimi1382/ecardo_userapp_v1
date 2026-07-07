import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

import '../../../../../../../l10n/app_localizations.dart';

class MyAdsFilterBottomSheet extends StatefulWidget {
  final MyAdsController controller;

  const MyAdsFilterBottomSheet({super.key, required this.controller});

  @override
  State<MyAdsFilterBottomSheet> createState() => _MyAdsFilterBottomSheetState();
}

class _MyAdsFilterBottomSheetState extends State<MyAdsFilterBottomSheet> {
  late String _selectedStatus;
  late String _selectedType;
  CurrenciesData? _selectedFiat;
  CurrenciesData? _selectedAsset;

  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _fiatController = TextEditingController();
  final TextEditingController _assetController = TextEditingController();
  bool _isSearching = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.controller.selectedStatusFilter.value;
    _selectedType = widget.controller.selectedTypeFilter.value;
    _statusController.text = _capitalize(_selectedStatus);
    _typeController.text = _capitalize(_selectedType);

    if (widget.controller.fiatCurrencies.isNotEmpty &&
        widget.controller.selectedFiatCurrencyIdFilter.value != null) {
      _selectedFiat = _findCurrencyById(
        widget.controller.fiatCurrencies,
        widget.controller.selectedFiatCurrencyIdFilter.value,
      );
    }
    if (widget.controller.assetCurrencies.isNotEmpty &&
        widget.controller.selectedAssetCurrencyIdFilter.value != null) {
      _selectedAsset = _findCurrencyById(
        widget.controller.assetCurrencies,
        widget.controller.selectedAssetCurrencyIdFilter.value,
      );
    }

    _fiatController.text =
        _selectedFiat?.code ?? widget.controller.selectedFiatFilterLabel.value;
    _assetController.text =
        _selectedAsset?.code ??
        widget.controller.selectedAssetFilterLabel.value;
  }

  @override
  void dispose() {
    _statusController.dispose();
    _typeController.dispose();
    _fiatController.dispose();
    _assetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.filterMyAds,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 20.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: AppColors.lightTextPrimary.withValues(alpha: 0.10)),
            SizedBox(height: 12.h),
            _buildDropdownField(
              label: localization.status,
              valueController: _statusController,
              onTap: _openStatusDropdown,
              localizations: localization,
            ),
            SizedBox(height: 14.h),
            _buildDropdownField(
              label: localization.type,
              valueController: _typeController,
              onTap: _openTypeDropdown,
              localizations: localization,
            ),
            SizedBox(height: 14.h),
            _buildDropdownField(
              label: localization.fiatCurrency,
              valueController: _fiatController,
              onTap: _openFiatDropdown,
              localizations: localization,
            ),
            SizedBox(height: 14.h),
            _buildDropdownField(
              label: localization.assetCurrency,
              valueController: _assetController,
              onTap: _openAssetDropdown,
              localizations: localization,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: localization.reset,
                    isLoading: _isResetting,
                    backgroundColor: AppColors.transparent,
                    textColor: AppColors.lightTextPrimary,
                    borderColor: AppColors.lightPrimary.withValues(alpha: 0.6),
                    borderWidth: 1.4,
                    onPressed: _isSearching ? null : _resetFilters,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CommonButton(
                    text: localization.search,
                    isLoading: _isSearching,
                    onPressed: _isResetting ? null : _applyFilters,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController valueController,
    required VoidCallback onTap,
    required AppLocalizations localizations,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueController.text.isEmpty
                        ? '${localizations.select} $label'
                        : valueController.text,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.w,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openStatusDropdown() {
    final items = widget.controller.statusFilterOptions
        .map(_capitalize)
        .toList();
    final localization = AppLocalizations.of(context)!;
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.selectStatus,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _statusController.text,
        currentlySelectedValue: _statusController.text,
        textController: _statusController,
        bottomSheetHeight: 360.h,
        notFoundText: localization.noStatusFound,
        onValueSelected: (value) {
          final status = value.toString().toLowerCase();
          setState(() {
            _selectedStatus = status;
            _statusController.text = _capitalize(status);
          });
        },
      ),
    );
  }

  void _openTypeDropdown() {
    final items = widget.controller.typeFilterOptions.map(_capitalize).toList();
    final localization = AppLocalizations.of(context)!;
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.selectType,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _typeController.text,
        currentlySelectedValue: _typeController.text,
        textController: _typeController,
        bottomSheetHeight: 320.h,
        notFoundText: localization.noTypeFound,
        onValueSelected: (value) {
          final type = value.toString().toLowerCase();
          setState(() {
            _selectedType = type;
            _typeController.text = _capitalize(type);
          });
        },
      ),
    );
  }

  Future<void> _openFiatDropdown() async {
    if (widget.controller.fiatCurrencies.isEmpty) {
      await widget.controller.fetchFilterCurrencies();
    }
    final localization = AppLocalizations.of(Get.context!)!;
    final entries = widget.controller.fiatCurrencies
        .map(
          (item) =>
              (label: (item.code ?? item.name ?? '').trim(), currency: item),
        )
        .where((entry) => entry.label.isNotEmpty)
        .toList();
    final items = entries.map((entry) => entry.label).toList();

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.selectFiatCurrency,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _fiatController.text,
        currentlySelectedValue: _fiatController.text,
        textController: _fiatController,
        bottomSheetHeight: 420.h,
        notFoundText: localization.noFiatCurrencyFound,
        onValueSelected: (value) {
          final index = items.indexOf(value.toString());
          if (index < 0 || index >= entries.length) return;
          setState(() {
            _selectedFiat = entries[index].currency;
            _fiatController.text = items[index];
          });
        },
      ),
    );
  }

  Future<void> _openAssetDropdown() async {
    if (widget.controller.assetCurrencies.isEmpty) {
      await widget.controller.fetchFilterCurrencies();
    }
    final localization = AppLocalizations.of(Get.context!)!;
    final entries = widget.controller.assetCurrencies
        .map(
          (item) =>
              (label: (item.code ?? item.name ?? '').trim(), currency: item),
        )
        .where((entry) => entry.label.isNotEmpty)
        .toList();
    final items = entries.map((entry) => entry.label).toList();

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.selectAssetCurrency,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _assetController.text,
        currentlySelectedValue: _assetController.text,
        textController: _assetController,
        bottomSheetHeight: 420.h,
        notFoundText: localization.noAssetCurrencyFound,
        onValueSelected: (value) {
          final index = items.indexOf(value.toString());
          if (index < 0 || index >= entries.length) return;
          setState(() {
            _selectedAsset = entries[index].currency;
            _assetController.text = items[index];
          });
        },
      ),
    );
  }

  Future<void> _applyFilters() async {
    if (_isSearching || _isResetting) return;
    setState(() {
      _isSearching = true;
    });
    await widget.controller.applyFilters(
      status: _selectedStatus,
      type: _selectedType,
      fiatCurrencyId: _selectedFiat?.id,
      fiatLabel: _fiatController.text.trim(),
      assetCurrencyId: _selectedAsset?.id,
      assetLabel: _assetController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _isSearching = false;
    });
    Get.back();
  }

  Future<void> _resetFilters() async {
    if (_isSearching || _isResetting) return;
    setState(() {
      _isResetting = true;
    });
    setState(() {
      _selectedStatus = '';
      _selectedType = '';
      _selectedFiat = null;
      _selectedAsset = null;
      _statusController.clear();
      _typeController.clear();
      _fiatController.clear();
      _assetController.clear();
    });
    await widget.controller.clearFilters();
    if (!mounted) return;
    setState(() {
      _isResetting = false;
    });
    Get.back();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  CurrenciesData? _findCurrencyById(List<CurrenciesData> list, int? id) {
    if (id == null) return null;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }
}
