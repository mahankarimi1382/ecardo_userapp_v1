import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

import '../../../../../../../l10n/app_localizations.dart';

class PaymentAccountFilterBottomSheet extends StatefulWidget {
  final PaymentAccountController controller;

  const PaymentAccountFilterBottomSheet({super.key, required this.controller});

  @override
  State<PaymentAccountFilterBottomSheet> createState() =>
      _PaymentAccountFilterBottomSheetState();
}

class _PaymentAccountFilterBottomSheetState
    extends State<PaymentAccountFilterBottomSheet> {
  final TextEditingController _currencyController = TextEditingController();
  CurrenciesData? _selectedCurrency;
  bool _isSubmitting = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _findById(
      widget.controller.fiatCurrencies,
      widget.controller.selectedCurrencyIdFilter.value,
    );
    _currencyController.text =
        _selectedCurrency?.code ??
        _selectedCurrency?.name ??
        widget.controller.selectedCurrencyLabel.value;
  }

  @override
  void dispose() {
    _currencyController.dispose();
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
                  localization.filterPaymentAccount,
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
            _buildCurrencyField(localization),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: 'Reset',
                    isLoading: _isResetting,
                    loadingColor: AppColors.lightPrimary,
                    backgroundColor: AppColors.transparent,
                    textColor: AppColors.lightTextPrimary,
                    borderColor: AppColors.lightPrimary.withValues(alpha: 0.6),
                    borderWidth: 1.4,
                    onPressed: _isSubmitting ? null : _onReset,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CommonButton(
                    text: 'Submit',
                    isLoading: _isSubmitting,
                    onPressed: _isResetting ? null : _onSubmit,
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

  Widget _buildCurrencyField(AppLocalizations localization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.fiatCurrency,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _openCurrencyDropdown,
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
                    _currencyController.text.isEmpty
                        ? localization.selectFiatCurrency
                        : _currencyController.text,
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

  Future<void> _openCurrencyDropdown() async {
    if (widget.controller.fiatCurrencies.isEmpty) {
      await widget.controller.fetchFiatCurrencies();
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
        title: localization.createNewWalletSelectCurrency,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: _currencyController.text,
        currentlySelectedValue: _currencyController.text,
        textController: _currencyController,
        bottomSheetHeight: 420.h,
        notFoundText: localization.noFiatCurrencyFound,
        onValueSelected: (value) {
          final index = items.indexOf(value.toString());
          if (index < 0 || index >= entries.length) return;
          setState(() {
            _selectedCurrency = entries[index].currency;
            _currencyController.text = items[index];
          });
        },
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting || _isResetting || _selectedCurrency?.id == null) return;
    setState(() {
      _isSubmitting = true;
    });
    await widget.controller.applyCurrencyFilter(_selectedCurrency);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });
    Get.back();
  }

  Future<void> _onReset() async {
    if (_isSubmitting || _isResetting) return;
    setState(() {
      _isResetting = true;
      _selectedCurrency = null;
      _currencyController.clear();
    });
    await widget.controller.clearCurrencyFilter();
    if (!mounted) return;
    setState(() {
      _isResetting = false;
    });
    Get.back();
  }

  CurrenciesData? _findById(List<CurrenciesData> list, int? id) {
    if (id == null) return null;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }
}
