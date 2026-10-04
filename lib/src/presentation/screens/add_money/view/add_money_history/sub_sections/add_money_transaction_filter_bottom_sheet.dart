import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_history_controller.dart';

class AddMoneyTransactionFilterBottomSheet extends StatefulWidget {
  const AddMoneyTransactionFilterBottomSheet({super.key});

  @override
  State<AddMoneyTransactionFilterBottomSheet> createState() =>
      _AddMoneyTransactionFilterBottomSheetState();
}

class _AddMoneyTransactionFilterBottomSheetState
    extends State<AddMoneyTransactionFilterBottomSheet> {
  final AddMoneyHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOutQuart,
      height: 400,
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: AppSpacing.xxl,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.page,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                      : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.addMoneyFilterTransactionId,
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
              const SizedBox(height: AppSpacing.lg),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.addMoneyFilterStatus,
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

                                  Color getStatusColor(String s) {
                                    switch (s.toLowerCase()) {
                                      case 'success':
                                        return AppColors.success;
                                      case 'pending':
                                        return AppColors.warning;
                                      case 'failed':
                                        return AppColors.error;
                                      default:
                                        return isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lightPrimary;
                                    }
                                  }

                                  final statusColor = getStatusColor(status);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
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
                                      duration: AppDurations.fast,
                                      alignment: Alignment.center,
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                        color: isSelected
                                            ? statusColor
                                            : isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.lightBackground,
                                        border: Border.all(
                                          color: isSelected
                                              ? statusColor
                                              : isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder,
                                        ),
                                      ),
                                      child: Text(
                                        StatusLabelHelper.localize(
                                          localizations,
                                          status,
                                        ),
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontSize: 13,
                                          color: isSelected
                                              ? AppColors.white
                                              : isDark
                                              ? AppColors.darkTextSecondary
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
              const SizedBox(height: AppSpacing.xxxl),
              Obx(
                () => CommonButton(
                  isLoading: controller.isTransactionsLoading.value,
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    controller.updateStatusFilter();
                    await controller.fetchDynamicTransactions();
                    Get.back();
                  },
                  width: double.infinity,
                  text: localizations.addMoneyFilterButton,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
