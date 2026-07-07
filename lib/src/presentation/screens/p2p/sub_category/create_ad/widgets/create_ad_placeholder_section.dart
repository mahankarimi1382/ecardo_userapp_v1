import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/controller/create_ad_controller.dart';

class CreateAdPlaceholderSection extends StatelessWidget {
  final CreateAdController controller;

  const CreateAdPlaceholderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildStepsIndicator(),
        SizedBox(height: 30.h),
        _buildBuySellToggle(),
        SizedBox(height: 18.h),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(18.w, 18.h, 18.w, 24.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(30.r),
                topEnd: Radius.circular(30.r),
              ),
            ),
            child: Obx(
              () => Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildStepContent(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      if (controller.currentStep.value > 0) ...[
                        Expanded(
                          child: CommonButton(
                            onPressed: controller.goToPreviousStep,
                            width: 80.w,
                            text: localization.p2pBack,
                            backgroundColor: AppColors.transparent,
                            textColor: AppColors.lightTextPrimary,
                            borderColor: AppColors.lightTextPrimary.withValues(
                              alpha: 0.16,
                            ),
                            borderWidth: 1.2,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(child: _buildPrimaryButton()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsIndicator() {
    return Obx(
      () => Row(
        children: List.generate(controller.stepTitles.length, (index) {
          final isActive = controller.isStepActive(index);
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.goToStep(index),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  children: [
                    Text(
                      _stepTitles[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: isActive
                            ? AppColors.lightPrimary
                            : AppColors.lightTextPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.lightPrimary
                            : AppColors.lightTextPrimary.withValues(
                                alpha: 0.16,
                              ),
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBuySellToggle() {
    return Obx(
      () => Container(
        height: 44.h,
        padding: EdgeInsets.all(5.w),
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTradeToggleOption(
                label: AppLocalizations.of(Get.context!)!.p2pIWantToBuy,
                isActive: controller.isBuySelected.value,
                activeColor: AppColors.success,
                inactiveTextColor: AppColors.lightTextPrimary,
                onTap: () => controller.toggleTradeType(true),
              ),
            ),
            Expanded(
              child: _buildTradeToggleOption(
                label: AppLocalizations.of(Get.context!)!.p2pIWantToSell,
                isActive: !controller.isBuySelected.value,
                activeColor: AppColors.error,
                inactiveTextColor: AppColors.error,
                onTap: () => controller.toggleTradeType(false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeToggleOption({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: isActive ? AppColors.white : inactiveTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStepOne();
      case 1:
        return _buildStepTwo();
      default:
        return _buildStepThree();
    }
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLabeledDropdownField(
                label: localization.p2pAsset,
                value: controller.selectedAsset.value,
                onTap: _openAssetDropdown,
                isRequired: true,
              ),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: _buildLabeledDropdownField(
                label: localization.p2pWithFiat,
                value: controller.selectedFiat.value,
                onTap: _openFiatDropdown,
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        _buildLabeledDropdownField(
          label: localization.p2pPriceType,
          value: controller.selectedPriceType.value,
          fullWidth: true,
          onTap: _openPriceTypeDropdown,
          isRequired: true,
        ),
        SizedBox(height: 30.h),
        Obx(
          () => Text(
            controller.selectedPriceType.value.isEmpty
                ? localization.p2pPrice
                : controller.selectedPriceType.value,
            style: _labelStyle,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: _inputDecoration(),
          child: Row(
            children: [
              GestureDetector(
                onTap: controller.decreasePrice,
                child: Icon(
                  Icons.remove_rounded,
                  size: 22.w,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Expanded(
                child: Obx(
                  () => TextField(
                    controller: controller.priceController,
                    keyboardType: controller.priceKeyboardType,
                    inputFormatters: controller.priceInputFormatters,
                    onChanged: controller.onPriceChanged,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.increasePrice,
                child: Icon(
                  Icons.add_rounded,
                  size: 22.w,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        Obx(
          () => _buildInfoText(
            '${localization.p2pYourPrice}:',
            '${controller.enteredPrice.value} ${controller.selectedFiat.value.isEmpty ? '-' : controller.selectedFiat.value}',
          ),
        ),
        SizedBox(height: 6.h),
        Obx(
          () => _buildInfoText(
            '${localization.p2pHighestOrderPrice}:',
            '${controller.highestOrderPrice.value} ${controller.selectedFiat.value.isEmpty ? '-' : controller.selectedFiat.value}',
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _buildLabeledInputField(
            label: localization.p2pTotalAmount,
            suffix: controller.selectedAsset.value.isEmpty
                ? '-'
                : controller.selectedAsset.value,
            controller: controller.totalAmountController,
            isRequired: true,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => _buildApproxText(controller.totalAmountApproxText.value)),
        SizedBox(height: 30.h),
        Obx(
          () => _buildLabeledInputField(
            label: localization.p2pOrderLimit,
            suffix: controller.selectedFiat.value.isEmpty
                ? '-'
                : controller.selectedFiat.value,
            controller: controller.minOrderLimitController,
            isRequired: true,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => _buildApproxText(controller.minAmountApproxText.value)),
        SizedBox(height: 30.h),
        Obx(
          () => _buildLabeledInputField(
            label: '',
            suffix: controller.selectedFiat.value.isEmpty
                ? '-'
                : controller.selectedFiat.value,
            controller: controller.maxOrderLimitController,
            hideLabel: true,
            isRequired: true,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => _buildApproxText(controller.maxAmountApproxText.value)),
        SizedBox(height: 30.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: localization.p2pPaymentMethod,
                          style: _labelStyle,
                        ),
                        TextSpan(
                          text: ' *',
                          style: _labelStyle.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    localization.p2pSelectAtLeastOnePaymentMethod,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _openPaymentMethodBottomSheet,
              child: Container(
                height: 36.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: AppColors.lightPrimary.withValues(alpha: 0.30),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 22.w,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      localization.p2pAdd,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.selectedPaymentMethodNames.isEmpty) {
            return const SizedBox.shrink();
          }

          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: controller.selectedPaymentMethodNames
                .map(
                  (name) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        }),
        SizedBox(height: 30.h),
        _buildLabeledInputField(
          label: localization.p2pPaymentTimeLimit,
          suffix: localization.p2pMinutes,
          controller: controller.paymentTimeLimitController,
          keyboardType: TextInputType.number,
          isRequired: true,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildStepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledTextArea(
          label: localization.p2pTerms,
          controller: controller.termsController,
          isRequired: true,
        ),
        SizedBox(height: 30.h),
        _buildLabeledTextArea(
          label: localization.p2pAutomaticReply,
          controller: controller.autoReplyController,
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  Widget _buildLabeledDropdownField({
    required String label,
    required String value,
    bool fullWidth = false,
    VoidCallback? onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: label, style: _labelStyle),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: _labelStyle.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: fullWidth ? double.infinity : null,
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: _inputDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
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

  void _openAssetDropdown() {
    if (controller.assetCurrencies.isEmpty) {
      controller.fetchCurrencies(type: 'crypto');
    }

    final items = controller.assetCurrencies
        .map((e) => e.code ?? e.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pSelectAsset,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: controller.selectedAsset.value,
        currentlySelectedValue: controller.selectedAsset.value,
        textController: controller.assetCurrencyController,
        bottomSheetHeight: 420.h,
        notFoundText: AppLocalizations.of(Get.context!)!.p2pNoAssetsFound,
        onValueSelected: (value) {
          final selectedIndex = controller.assetCurrencies.indexWhere(
            (e) => (e.code ?? e.name ?? '') == value.toString(),
          );
          if (selectedIndex != -1) {
            controller.onAssetSelected(
              controller.assetCurrencies[selectedIndex],
            );
          }
        },
      ),
    );
  }

  void _openFiatDropdown() {
    if (controller.fiatCurrencies.isEmpty) {
      controller.fetchCurrencies(type: 'fiat');
    }

    final items = controller.fiatCurrencies
        .map((e) => e.code ?? e.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pSelectFiat,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: controller.selectedFiat.value,
        currentlySelectedValue: controller.selectedFiat.value,
        textController: controller.fiatCurrencyController,
        bottomSheetHeight: 420.h,
        notFoundText: AppLocalizations.of(
          Get.context!,
        )!.p2pNoFiatCurrenciesFound,
        onValueSelected: (value) {
          final selectedIndex = controller.fiatCurrencies.indexWhere(
            (e) => (e.code ?? e.name ?? '') == value.toString(),
          );
          if (selectedIndex != -1) {
            controller.onFiatSelected(controller.fiatCurrencies[selectedIndex]);
          }
        },
      ),
    );
  }

  void _openPriceTypeDropdown() {
    final localization = AppLocalizations.of(Get.context!)!;
    final items = ["Fixed", "Float"];
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.p2pSelectPriceType,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: controller.selectedPriceType.value,
        currentlySelectedValue: controller.selectedPriceType.value,
        textController: TextEditingController(
          text: controller.selectedPriceType.value,
        ),
        bottomSheetHeight: 300.h,
        notFoundText: localization.p2pNoPriceTypeFound,
        onValueSelected: (value) {
          controller.onPriceTypeSelected(value.toString());
        },
      ),
    );
  }

  Future<void> _openPaymentMethodBottomSheet() async {
    await controller.fetchPaymentMethodsByFiat();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: 500.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(20.r),
              topEnd: Radius.circular(20.r),
            ),
          ),
          child: Column(
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
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.p2pSelectPaymentMethod,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: Get.back,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Divider(
                height: 1,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPaymentMethodsLoading.value) {
                    return Center(child: CommonLoading());
                  }

                  if (controller.availablePaymentAccounts.isEmpty) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.p2pNoPaymentMethodFound,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.56,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(18.w),
                    itemCount: controller.availablePaymentAccounts.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final account =
                          controller.availablePaymentAccounts[index];
                      final isSelected = controller.selectedPaymentMethodIds
                          .contains(account.id);

                      return GestureDetector(
                        onTap: () {
                          controller.togglePaymentMethodSelection(account);
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.lightPrimary.withValues(alpha: 0.10)
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.lightPrimary.withValues(
                                      alpha: 0.30,
                                    )
                                  : AppColors.lightTextPrimary.withValues(
                                      alpha: 0.10,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  account.paymentMethod?.name ?? '',
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 20.w,
                                color: isSelected
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.45,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(18.w, 0, 18.w, 20.h),
                child: CommonButton(
                  text: AppLocalizations.of(Get.context!)!.p2pDone,
                  onPressed: Get.back,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildLabeledInputField({
    required String label,
    required String suffix,
    required TextEditingController controller,
    bool hideLabel = false,
    bool isRequired = false,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideLabel) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: label, style: _labelStyle),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: _labelStyle.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: _inputDecoration(),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledTextArea({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: label, style: _labelStyle),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: _labelStyle.copyWith(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          height: 90.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: _inputDecoration(),
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

  Widget _buildInfoText(String left, String right) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$left ',
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          TextSpan(
            text: right,
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
  }

  Widget _buildApproxText(String value) {
    return Text(
      value,
      style: TextStyle(
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return CommonButton(
      text: controller.currentStep.value == controller.stepTitles.length - 1
          ? AppLocalizations.of(Get.context!)!.p2pSubmit
          : AppLocalizations.of(Get.context!)!.p2pNext,
      onPressed: controller.goToNextStep,
      width: double.infinity,
      backgroundColor: AppColors.lightPrimary,
      textColor: AppColors.white,
    );
  }

  AppLocalizations get localization => AppLocalizations.of(Get.context!)!;

  List<String> get _stepTitles => <String>[
    'Set Type &\nPrice',
    'Set Amount &\nMethod',
    'Set\nConditions',
  ];

  TextStyle get _labelStyle => TextStyle(
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    fontSize: 12.sp,
    color: AppColors.lightTextPrimary,
  );

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: AppColors.lightBackground,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: AppColors.lightTextPrimary.withValues(alpha: 0.13),
      ),
    );
  }
}
