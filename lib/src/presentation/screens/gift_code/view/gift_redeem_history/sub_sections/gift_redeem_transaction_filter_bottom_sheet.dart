import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_history_controller.dart';

class GiftRedeemTransactionFilterBottomSheet extends StatefulWidget {
  const GiftRedeemTransactionFilterBottomSheet({super.key});

  @override
  State<GiftRedeemTransactionFilterBottomSheet> createState() =>
      _GiftRedeemTransactionFilterBottomSheetState();
}

class _GiftRedeemTransactionFilterBottomSheetState
    extends State<GiftRedeemTransactionFilterBottomSheet> {
  final GiftRedeemHistoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 300,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
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
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
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
                labelText: localizations.giftRedeemFilterCode,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.codeController,
                    focusNode: controller.codeFocusNode,
                    isFocused: controller.isCodeFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(height: 40),
              CommonButton(
                onPressed: () {
                  controller.fetchDynamicTransactions();
                  Get.back();
                },
                width: double.infinity,

                text: localizations.giftRedeemFilterButton,
              ),
              const SizedBox(height: 10),
              CommonButton(
                backgroundColor: AppColors.error,
                onPressed: () {
                  controller.resetFilters();
                  Get.back();
                },
                width: double.infinity,

                text: localizations.giftRedeemFilterReset,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
