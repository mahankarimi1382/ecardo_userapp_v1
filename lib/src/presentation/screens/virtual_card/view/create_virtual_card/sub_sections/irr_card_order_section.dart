import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_product_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class IrrCardOrderSection extends StatelessWidget {
  const IrrCardOrderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateVirtualCardController controller = Get.find();

    return Obx(() {
      final product = controller.selectedCardProduct.value;
      if (product == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name ?? 'IRR Card',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
          if (product.issuer != null) ...[
            SizedBox(height: 8.h),
            Text(
              [
                product.issuer?.name,
                product.issuer?.countryCode,
                product.issuer?.network,
              ].whereType<String>().where((value) => value.isNotEmpty).join(' · '),
              style: TextStyle(
                color: AppColors.lightTextTertiary,
                fontSize: 13.sp,
              ),
            ),
            if ((product.issuer?.disclosure ?? '').isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                product.issuer!.disclosure!,
                style: TextStyle(
                  color: product.issuer!.isExternallyUsable
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
          SizedBox(height: 6.h),
          Text(
            'Issue fee: ${_formatIrr(product.creationFee)} IRR',
            style: TextStyle(
              color: AppColors.lightTextTertiary,
              fontSize: 13.sp,
            ),
          ),
          if ((product.maintenanceMessage ?? '').isNotEmpty) ...[
            SizedBox(height: 12.h),
            _MessageBox(
              message: product.maintenanceMessage!,
              color: AppColors.error,
            ),
          ],
          SizedBox(height: 16.h),
          CommonRequiredLabelAndDynamicField(
            labelText: 'Initial load (IRR)',
            isLabelRequired: true,
            dynamicField: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextInputField(
                  hintText: 'Enter initial load',
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 6.h),
                Text(
                  '${_formatIrr(product.minimumInitialLoad)} - '
                  '${_formatIrr(product.maximumInitialLoad)} IRR',
                  style: TextStyle(
                    color: AppColors.lightTextTertiary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ...product.applicationFields.map(
            (field) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _ApplicationField(
                field: field,
                controller: controller,
              ),
            ),
          ),
          _FundingSourceSection(product: product, controller: controller),
          if (product.capabilities?.canRequestPhysical == true) ...[
            SizedBox(height: 16.h),
            CommonRequiredLabelAndDynamicField(
              labelText:
                  'Request physical card '
                  '(${_formatIrr(product.physicalCardFee)} IRR)',
              dynamicField: _BooleanChoice(
                value: controller.requestPhysical.value,
                onChanged: (value) {
                  controller.requestPhysical.value = value;
                },
              ),
            ),
          ],
          if ((product.terms ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              product.terms!,
              style: TextStyle(
                color: AppColors.lightTextTertiary,
                fontSize: 12.sp,
              ),
            ),
          ],
          SizedBox(height: 20.h),
        ],
      );
    });
  }

  static String _formatIrr(num value) {
    return NumberFormat.decimalPattern().format(value);
  }
}

class _ApplicationField extends StatelessWidget {
  final CardApplicationField field;
  final CreateVirtualCardController controller;

  const _ApplicationField({
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (field.type == 'boolean') {
      return Obx(
        () => CommonRequiredLabelAndDynamicField(
          labelText: field.label,
          isLabelRequired: field.required,
          dynamicField: _BooleanChoice(
            value:
                controller.applicationBooleanValues[field.name]?.value ?? false,
            onChanged: (value) {
              controller.applicationBooleanValues[field.name]?.value = value;
            },
          ),
        ),
      );
    }

    final textController = controller.applicationFieldControllers[field.name];
    if (field.type == 'date') {
      return CommonRequiredLabelAndDynamicField(
        labelText: field.label,
        isLabelRequired: field.required,
        dynamicField: CommonSingleDatePicker(
          hintText: '',
          suffixIcon: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              AppColors.lightTextTertiary,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              PngAssets.calenderCommonIcon,
            ),
          ),
          suffixIconWidth: 25,
          suffixIconHeight: 25,
          onDateSelected: (date) {
            textController?.text = DateFormat('yyyy-MM-dd').format(date);
          },
        ),
      );
    }

    return CommonRequiredLabelAndDynamicField(
      labelText: field.label,
      isLabelRequired: field.required,
      dynamicField: CommonTextInputField(
        hintText: '',
        controller: textController,
        keyboardType: field.type == 'number'
            ? TextInputType.number
            : TextInputType.text,
      ),
    );
  }
}

class _FundingSourceSection extends StatelessWidget {
  final CardProductData product;
  final CreateVirtualCardController controller;

  const _FundingSourceSection({
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final capabilities = product.capabilities;
    final supportsWallet = capabilities?.canFundFromIrrWallet == true;
    final supportsGateway = capabilities?.canFundFromGateway == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (supportsWallet && supportsGateway) ...[
          _FundingSourceTabs(controller: controller),
          SizedBox(height: 16.h),
        ],
        if (controller.fundingSource.value == 'irr_wallet')
          CommonRequiredLabelAndDynamicField(
            labelText: 'IRR wallet',
            isLabelRequired: true,
            dynamicField: CommonTextInputField(
              hintText: 'Select IRR wallet',
              controller: controller.irrWalletController,
              readOnly: true,
              suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
              onTap: () {
                Get.bottomSheet(
                  CommonDropdownBottomSheetThree<Wallets>(
                    items: controller.irrWallets,
                    selectedItem: controller.selectedIrrWallet.value,
                    bottomSheetHeight: 400.h,
                    isShowTitle: true,
                    title: 'Select IRR Wallet',
                    notFoundText: 'No IRR wallet found',
                    getDisplayText: _walletText,
                    areItemsEqual: (first, second) => first.id == second.id,
                    onItemSelected: controller.selectIrrWallet,
                    onItemUnSelected: controller.clearIrrWallet,
                    getItemSubtitle: (wallet) =>
                        wallet.accountNo?.isNotEmpty == true
                        ? wallet.accountNo
                        : wallet.code,
                  ),
                );
              },
            ),
          ),
        if (controller.fundingSource.value == 'gateway')
          CommonRequiredLabelAndDynamicField(
            labelText: 'Payment gateway',
            isLabelRequired: true,
            dynamicField: CommonTextInputField(
              hintText: 'Select payment gateway',
              controller: controller.gatewayController,
              readOnly: true,
              suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
              onTap: () {
                Get.bottomSheet(
                  CommonDropdownBottomSheetThree<CardGatewayData>(
                    items: product.gateways,
                    selectedItem: controller.selectedGateway.value,
                    bottomSheetHeight: 400.h,
                    isShowTitle: true,
                    title: 'Select Payment Gateway',
                    notFoundText: 'No payment gateway found',
                    getDisplayText: _gatewayText,
                    areItemsEqual: (first, second) => first.id == second.id,
                    onItemSelected: controller.selectGateway,
                    onItemUnSelected: controller.clearGateway,
                    getItemSubtitle: (gateway) {
                      final currency = gateway.currency ?? 'IRR';
                      return '${gateway.minimumDeposit} - '
                          '${gateway.maximumDeposit} $currency';
                    },
                  ),
                );
              },
            ),
          ),
        if (supportsWallet &&
            controller.fundingSource.value == 'irr_wallet' &&
            controller.irrWallets.isEmpty) ...[
          SizedBox(height: 8.h),
          const _MessageBox(
            message: 'No IRR wallet is available for this account.',
            color: AppColors.error,
          ),
        ],
      ],
    );
  }

  static String _walletText(Wallets wallet) {
    return '${wallet.name ?? 'IRR'} - '
        '${wallet.formattedBalance ?? wallet.balance ?? '0'}';
  }

  static String _gatewayText(CardGatewayData gateway) {
    return gateway.name ?? gateway.gatewayCode ?? '';
  }
}

class _FundingSourceTabs extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _FundingSourceTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton(
              borderRadius: 12,
              height: 42,
              width: double.infinity,
              fontSize: 11,
              text: 'IRR Wallet',
              backgroundColor: controller.fundingSource.value == 'irr_wallet'
                  ? AppColors.lightPrimary
                  : AppColors.white,
              textColor: controller.fundingSource.value == 'irr_wallet'
                  ? AppColors.white
                  : AppColors.lightTextPrimary.withValues(alpha: 0.8),
              onPressed: () {
                controller.selectFundingSource('irr_wallet');
              },
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CommonButton(
              borderRadius: 12,
              height: 42,
              width: double.infinity,
              fontSize: 11,
              text: 'Payment Gateway',
              backgroundColor: controller.fundingSource.value == 'gateway'
                  ? AppColors.lightPrimary
                  : AppColors.white,
              textColor: controller.fundingSource.value == 'gateway'
                  ? AppColors.white
                  : AppColors.lightTextPrimary.withValues(alpha: 0.8),
              onPressed: () {
                controller.selectFundingSource('gateway');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BooleanChoice extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BooleanChoice({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            height: 42,
            borderRadius: 12,
            text: 'No',
            backgroundColor: value ? AppColors.white : AppColors.lightPrimary,
            textColor: value ? AppColors.lightTextPrimary : AppColors.white,
            borderColor: value
                ? AppColors.lightTextPrimary.withValues(alpha: 0.15)
                : null,
            onPressed: () => onChanged(false),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CommonButton(
            height: 42,
            borderRadius: 12,
            text: 'Yes',
            backgroundColor: value ? AppColors.lightPrimary : AppColors.white,
            textColor: value ? AppColors.white : AppColors.lightTextPrimary,
            borderColor: value
                ? null
                : AppColors.lightTextPrimary.withValues(alpha: 0.15),
            onPressed: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final Color color;

  const _MessageBox({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(message, style: TextStyle(color: color, fontSize: 13.sp)),
    );
  }
}
