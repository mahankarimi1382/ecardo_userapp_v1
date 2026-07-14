import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_product_model.dart';

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
          if (controller.cardProducts.length > 1) ...[
            DropdownButtonFormField<int>(
              initialValue: product.id,
              decoration: const InputDecoration(
                labelText: 'Card product',
                border: OutlineInputBorder(),
              ),
              items: controller.cardProducts
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name ?? item.code ?? 'IRR Card'),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                final selected = controller.cardProducts.firstWhereOrNull(
                  (item) => item.id == id,
                );
                if (selected != null) controller.selectCardProduct(selected);
              },
            ),
            SizedBox(height: 16.h),
          ],
          Text(
            product.name ?? 'IRR Card',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
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
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Initial load (IRR)',
              helperText:
                  '${_formatIrr(product.minimumInitialLoad)} - '
                  '${_formatIrr(product.maximumInitialLoad)} IRR',
              border: const OutlineInputBorder(),
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
            SizedBox(height: 8.h),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: controller.requestPhysical.value,
              title: Text(
                'Request physical card '
                '(${_formatIrr(product.physicalCardFee)} IRR)',
              ),
              onChanged: (value) {
                controller.requestPhysical.value = value == true;
              },
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
          CommonButton(
            width: double.infinity,
            text: 'Create IRR Card',
            isLoading: controller.isCreateVirtualCardLoading.value,
            onPressed: controller.createIrrCard,
          ),
          SizedBox(height: 30.h),
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
        () => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${field.label}${field.required ? ' *' : ''}'),
          value: controller.applicationBooleanValues[field.name]?.value ?? false,
          onChanged: (value) {
            controller.applicationBooleanValues[field.name]?.value = value;
          },
        ),
      );
    }

    final textController = controller.applicationFieldControllers[field.name];
    return TextField(
      controller: textController,
      readOnly: field.type == 'date',
      onTap: field.type == 'date'
          ? () async {
              final selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                initialDate: DateTime.now(),
              );
              if (selectedDate != null) {
                textController?.text = DateFormat('yyyy-MM-dd').format(
                  selectedDate,
                );
              }
            }
          : null,
      keyboardType: field.type == 'number'
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        suffixIcon: field.type == 'date'
            ? const Icon(Icons.calendar_month_outlined)
            : null,
        border: const OutlineInputBorder(),
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
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'irr_wallet',
                label: Text('IRR Wallet'),
              ),
              ButtonSegment(
                value: 'gateway',
                label: Text('Payment Gateway'),
              ),
            ],
            selected: {controller.fundingSource.value},
            onSelectionChanged: (values) {
              controller.fundingSource.value = values.first;
            },
          ),
          SizedBox(height: 16.h),
        ],
        if (controller.fundingSource.value == 'irr_wallet')
          DropdownButtonFormField<int>(
            initialValue: controller.selectedIrrWallet.value?.id,
            decoration: const InputDecoration(
              labelText: 'IRR wallet',
              border: OutlineInputBorder(),
            ),
            items: controller.irrWallets
                .map(
                  (wallet) => DropdownMenuItem(
                    value: wallet.id,
                    child: Text(
                      '${wallet.name ?? 'IRR'} - '
                      '${wallet.formattedBalance ?? wallet.balance ?? '0'}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              controller.selectedIrrWallet.value =
                  controller.irrWallets.firstWhereOrNull(
                (wallet) => wallet.id == id,
              );
            },
          ),
        if (controller.fundingSource.value == 'gateway')
          DropdownButtonFormField<int>(
            initialValue: controller.selectedGateway.value?.id,
            decoration: const InputDecoration(
              labelText: 'Payment gateway',
              border: OutlineInputBorder(),
            ),
            items: product.gateways
                .map(
                  (gateway) => DropdownMenuItem(
                    value: gateway.id,
                    child: Text(gateway.name ?? gateway.gatewayCode ?? ''),
                  ),
                )
                .toList(),
            onChanged: (id) {
              controller.selectedGateway.value =
                  product.gateways.firstWhereOrNull(
                (gateway) => gateway.id == id,
              );
            },
          ),
        if (supportsWallet &&
            controller.fundingSource.value == 'irr_wallet' &&
            controller.irrWallets.isEmpty)
          const _MessageBox(
            message: 'No IRR wallet is available for this account.',
            color: AppColors.error,
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
