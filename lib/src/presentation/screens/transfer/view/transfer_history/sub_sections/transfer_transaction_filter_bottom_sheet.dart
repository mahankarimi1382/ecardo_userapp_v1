import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_history_controller.dart';

class TransferTransactionFilterBottomSheet extends StatefulWidget {
  const TransferTransactionFilterBottomSheet({super.key});

  @override
  State<TransferTransactionFilterBottomSheet> createState() =>
      _TransferTransactionFilterBottomSheetState();
}

class _TransferTransactionFilterBottomSheetState
    extends State<TransferTransactionFilterBottomSheet> {
  final TransferHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 400,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 20),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.transferTransactionFilterTransactionId,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.transactionIdController,
                    focusNode: controller.transactionIdFocusNode,
                    isFocused: controller.isTransactionIdFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(height: 15),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.transferTransactionFilterStatus,
                isLabelRequired: false,
                dynamicField: SizedBox(
                  height: 38,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemCount = controller.statusList.length;
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth,
                            child: Obx(() {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(itemCount, (index) {
                                  final status = controller.statusList[index];
                                  final isSelected =
                                      controller.selectedStatusIndex.value ==
                                      index;

                                  Color getStatusColor(String status) {
                                    switch (status.toLowerCase()) {
                                      case 'success':
                                        return AppColors.success;
                                      case 'pending':
                                        return AppColors.warning;
                                      case 'failed':
                                        return AppColors.error;
                                      default:
                                        return AppColors.lightTextPrimary;
                                    }
                                  }

                                  final statusColor = getStatusColor(status);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      if (controller
                                              .selectedStatusIndex
                                              .value ==
                                          index) {
                                        controller.selectedStatusIndex.value =
                                            -1;
                                      } else {
                                        controller.selectedStatusIndex.value =
                                            index;
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: isSelected
                                            ? statusColor
                                            : AppColors.lightBackground,
                                        border: Border.all(
                                          color: isSelected
                                              ? statusColor
                                              : AppColors.lightTextPrimary
                                                    .withValues(alpha: 0.06),
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontSize: 14,
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.lightTextTertiary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
              CommonButton(
                onPressed: () {
                  controller.updateStatusFilter();
                  controller.fetchDynamicTransactions();
                  Get.back();
                },
                width: double.infinity,

                text: localization.transferTransactionFilterApplyButton,
              ),
              const SizedBox(height: 10),
              CommonButton(
                backgroundColor: AppColors.error,
                onPressed: () {
                  controller.resetFilters();
                  Get.back();
                },
                width: double.infinity,

                text: localization.transferTransactionFilterResetButton,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
