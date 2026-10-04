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
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';

class ExchangeTransactionFilterBottomSheet extends StatefulWidget {
  const ExchangeTransactionFilterBottomSheet({super.key});

  @override
  State<ExchangeTransactionFilterBottomSheet> createState() =>
      _ExchangeTransactionFilterBottomSheetState();
}

class _ExchangeTransactionFilterBottomSheetState
    extends State<ExchangeTransactionFilterBottomSheet> {
  final ExchangeHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = ExchangeDesignTokens.isDark(context);

    return AnimatedContainer(
      duration: AppSpacing.normal,
      curve: Curves.easeOutQuart,
      height: 410,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ExchangeDesignTokens.cardSurface(context),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : AppColors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: ExchangeDesignTokens.textPrimary(context)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.exchangeFilterTransactionId,
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
                labelText: localizations.exchangeFilterStatus,
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
                                        return isDark
                                            ? AppColors.mainSoftBlue
                                            : AppColors.lightPrimary;
                                    }
                                  }

                                  final statusColor = getStatusColor(status);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      if (controller
                                              .selectedStatusIndex.value ==
                                          index) {
                                        controller.selectedStatusIndex.value =
                                            -1;
                                      } else {
                                        controller.selectedStatusIndex.value =
                                            index;
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: AppSpacing.fast,
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
                                            : (isDark
                                                ? AppColors.darkSurfaceVariant
                                                : AppColors.lightBackground),
                                        border: Border.all(
                                          color: isSelected
                                              ? statusColor
                                              : ExchangeDesignTokens.cardBorder(
                                                  context,
                                                ),
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
                                              : ExchangeDesignTokens
                                                  .textTertiary(context),
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
              CommonButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.updateStatusFilter();
                  controller.fetchDynamicTransactions();
                  Get.back();
                },
                width: double.infinity,
                backgroundColor: isDark
                    ? AppColors.mainSoftBlue
                    : AppColors.lightPrimary,
                textColor: isDark ? AppColors.deepBlack : AppColors.white,
                text: localizations.exchangeFilterButton,
              ),
              const SizedBox(height: AppSpacing.md),
              CommonButton(
                backgroundColor: AppColors.error,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.resetFilters();
                  Get.back();
                },
                width: double.infinity,
                text: localizations.exchangeFilterReset,
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
