import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';

class ExchangeAmountStepSection extends StatefulWidget {
  const ExchangeAmountStepSection({super.key});

  @override
  State<ExchangeAmountStepSection> createState() =>
      _ExchangeAmountStepSectionState();
}

class _ExchangeAmountStepSectionState extends State<ExchangeAmountStepSection> {
  final ExchangeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
      padding: const EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        bottom: 24,
        top: 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CommonRequiredLabelAndDynamicField(
            labelText: localizations.exchangeAmount,
            isLabelRequired: true,
            dynamicField: Obx(
              () => CommonTextInputField(
                focusNode: controller.amountFocusNode,
                isFocused: controller.isAmountFocused.value,
                isSuffixIconCompact: false,
                suffixIcon: Center(
                  child: Text(
                    controller.fromWallet.value!.code!,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.40),
                    ),
                  ),
                ),
                borderRadius: 16,
                backgroundColor: AppColors.transparent,
                hintText: "",
                controller: controller.amountController,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.fromExchangeWalletsList.isNotEmpty,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Text(
                  "${localizations.exchangeMin} ${controller.fromWallet.value!.exchangeLimit!.min} "
                  "${controller.fromWallet.value!.code} ${localizations.exchangeMax} "
                  "${controller.fromWallet.value!.exchangeLimit!.max} "
                  "${controller.fromWallet.value!.code}",
                  style: const TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          CommonButton(
            borderRadius: 16,
            width: double.infinity,

            text: localizations.exchangeButton,
            onPressed: () {
              controller.nextStepWithValidation();
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
