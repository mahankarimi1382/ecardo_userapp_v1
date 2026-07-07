import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_ads/model/my_ads_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';

import '../../../../../../../l10n/app_localizations.dart';

class EditMyAdBottomSheet extends StatefulWidget {
  final Ad ad;
  final MyAdsController controller;

  const EditMyAdBottomSheet({
    super.key,
    required this.ad,
    required this.controller,
  });

  @override
  State<EditMyAdBottomSheet> createState() => _EditMyAdBottomSheetState();
}

class _EditMyAdBottomSheetState extends State<EditMyAdBottomSheet> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final TextEditingController _paymentDurationController =
      TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _autoReplyController = TextEditingController();

  final List<PaymentAccount> _paymentAccounts = <PaymentAccount>[];
  final Set<int> _selectedPaymentMethodIds = <int>{};

  bool _isLoadingPaymentMethods = false;
  bool _isSubmitting = false;

  String get _assetCode => widget.ad.assetCurrency?.code ?? '';
  String get _fiatCode => widget.ad.fiatCurrency?.code ?? '';

  @override
  void initState() {
    super.initState();
    _setInitialValues();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _totalAmountController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _paymentDurationController.dispose();
    _termsController.dispose();
    _autoReplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(Get.context!)!;
    return AnimatedContainer(
      height: Get.size.height * 0.9,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 45.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.edit_my_ad,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 22.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            width: double.infinity,
            height: 1,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInput(
                    label:
                        '${localization.amount} (${_fiatCode.isEmpty ? '-' : _fiatCode})',
                    controller: _priceController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  SizedBox(height: 14.w),
                  _buildInput(
                    label:
                        '${localization.total_amount} (${_assetCode.isEmpty ? '-' : _assetCode})',
                    controller: _totalAmountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _buildInput(
                    label:
                        '${localization.min_amount} (${_fiatCode.isEmpty ? '-' : _fiatCode})',
                    controller: _minAmountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  SizedBox(height: 14.w),
                  _buildInput(
                    label:
                        '${localization.max_amount} (${_fiatCode.isEmpty ? '-' : _fiatCode})',
                    controller: _maxAmountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _buildInput(
                    label: localization.payment_duration,
                    controller: _paymentDurationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    localization.payment_method,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildPaymentMethodSection(localization),
                  SizedBox(height: 16.h),
                  _buildTextArea(
                    label: localization.terms,
                    controller: _termsController,
                  ),
                  SizedBox(height: 16.h),
                  _buildTextArea(
                    label: localization.auto_response,
                    controller: _autoReplyController,
                  ),
                  SizedBox(height: 20.h),
                  CommonButton(
                    text: localization.update,
                    width: double.infinity,
                    isLoading: _isSubmitting,
                    onPressed: () => _submitUpdate(localization),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
    List<TextInputFormatter>? inputFormatters,
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
        Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(14.r),

            border: Border.all(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
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
        Container(
          width: double.infinity,
          height: 90.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(AppLocalizations localization) {
    if (_isLoadingPaymentMethods) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.lightPrimary,
            size: 32.sp,
          ),
        ),
      );
    }

    if (_paymentAccounts.isEmpty) {
      return Text(
        localization.no_payment_method,
        style: TextStyle(
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          fontSize: 13.sp,
          color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
        ),
      );
    }

    return Wrap(
      spacing: 16.w,
      runSpacing: 10.h,
      children: _paymentAccounts.map((account) {
        final accountId = account.id;
        if (accountId == null) return const SizedBox.shrink();
        final isSelected = _selectedPaymentMethodIds.contains(accountId);
        final methodName = account.paymentMethod?.name ?? 'Method';
        final label = methodName;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedPaymentMethodIds.remove(accountId);
              } else {
                _selectedPaymentMethodIds.add(accountId);
              }
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightPrimary : AppColors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.lightPrimary
                        : AppColors.lightTextPrimary.withValues(alpha: 0.20),
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 14.w,
                        color: AppColors.white,
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _loadPaymentMethods() async {
    final fiatId = widget.ad.fiatCurrency?.id;
    if (fiatId == null) return;

    setState(() {
      _isLoadingPaymentMethods = true;
    });

    final accounts = await widget.controller.fetchPaymentAccountsByFiat(
      fiatCurrencyId: fiatId,
    );

    final existingPaymentMethodIds =
        (widget.ad.paymentMethods ?? <PaymentMethodElement>[])
            .map((method) => method.paymentMethodId)
            .whereType<int>()
            .toSet();

    if (!mounted) return;
    setState(() {
      _paymentAccounts
        ..clear()
        ..addAll(accounts.where((account) => account.id != null));

      _selectedPaymentMethodIds.clear();
      for (final account in _paymentAccounts) {
        final accountId = account.id;
        final paymentMethodId = account.paymentMethod?.id;
        if (accountId == null) continue;
        if (paymentMethodId != null &&
            existingPaymentMethodIds.contains(paymentMethodId)) {
          _selectedPaymentMethodIds.add(accountId);
        }
      }

      _isLoadingPaymentMethods = false;
    });
  }

  void _setInitialValues() {
    final price = _parseNumber(widget.ad.price);
    final totalAmount = _parseNumber(widget.ad.totalAmount);
    final orderLimits = _parseOrderLimits(widget.ad.orderLimit);

    _priceController.text = price.toStringAsFixed(2);
    _totalAmountController.text = totalAmount.toStringAsFixed(8);
    _minAmountController.text = orderLimits.$1.toStringAsFixed(2);
    _maxAmountController.text = orderLimits.$2.toStringAsFixed(2);
    _paymentDurationController.text = '${widget.ad.paymentDuration ?? ''}';
    _termsController.text = widget.ad.description ?? '';
    _autoReplyController.text = widget.ad.autoResponseMessage ?? '';
  }

  double _parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final sanitized = value.replaceAll(',', '');
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(sanitized);
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  (double, double) _parseOrderLimits(String? value) {
    if (value == null || value.trim().isEmpty) return (0, 0);
    final sanitized = value.replaceAll(',', '');
    final matches = RegExp(r'-?\d+(\.\d+)?')
        .allMatches(sanitized)
        .map((match) => double.tryParse(match.group(0) ?? '') ?? 0)
        .toList();

    if (matches.isEmpty) return (0, 0);
    if (matches.length == 1) return (matches.first, matches.first);
    return (matches[0], matches[1]);
  }

  Future<void> _submitUpdate(AppLocalizations localization) async {
    if (_isSubmitting) return;

    final adId = widget.ad.id;
    final assetCurrencyId = widget.ad.assetCurrency?.id;
    final fiatCurrencyId = widget.ad.fiatCurrency?.id;
    final type = widget.ad.adType?.trim().toLowerCase();

    final price = double.tryParse(_priceController.text.trim());
    final totalAmount = double.tryParse(_totalAmountController.text.trim());
    final minAmount = double.tryParse(_minAmountController.text.trim());
    final maxAmount = double.tryParse(_maxAmountController.text.trim());
    final paymentDuration = int.tryParse(
      _paymentDurationController.text.trim(),
    );
    final terms = _termsController.text.trim();
    final autoReply = _autoReplyController.text.trim();

    if (adId == null ||
        assetCurrencyId == null ||
        fiatCurrencyId == null ||
        type == null ||
        type.isEmpty) {
      ToastHelper().showErrorToast(localization.error_ad_invalid);
      return;
    }
    if (price == null || price <= 0) {
      ToastHelper().showErrorToast(localization.error_amount_zero);
      return;
    }
    if (totalAmount == null || totalAmount <= 0) {
      ToastHelper().showErrorToast(localization.error_total_amount_zero);
      return;
    }
    if (minAmount == null || minAmount <= 0) {
      ToastHelper().showErrorToast(localization.error_min_zero);
      return;
    }
    if (maxAmount == null || maxAmount <= 0) {
      ToastHelper().showErrorToast(localization.error_max_zero);
      return;
    }
    if (minAmount > maxAmount) {
      ToastHelper().showErrorToast(localization.error_min_greater);
      return;
    }
    if (paymentDuration == null || paymentDuration <= 0) {
      ToastHelper().showErrorToast(localization.error_payment_duration_zero);
      return;
    }
    if (_selectedPaymentMethodIds.isEmpty) {
      ToastHelper().showErrorToast(localization.error_select_payment);
      return;
    }
    if (terms.isEmpty) {
      ToastHelper().showErrorToast(localization.error_terms_empty);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final isUpdated = await widget.controller.updateAd(
      adId: adId.toString(),
      assetCurrencyId: assetCurrencyId,
      fiatCurrencyId: fiatCurrencyId,
      type: type,
      minAmount: minAmount,
      maxAmount: maxAmount,
      price: price,
      totalAmount: totalAmount,
      paymentDuration: paymentDuration,
      description: terms,
      autoResponseMessage: autoReply,
      paymentMethodIds: _selectedPaymentMethodIds.toList(),
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (isUpdated) {
      Get.back();
    }
  }
}
