import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class CreateBeneficiaryScreen extends StatelessWidget {
  const CreateBeneficiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final CreateBeneficiaryController controller = Get.put(
      CreateBeneficiaryController(),
    );
    final String accountUser = Get.arguments?["account_user"] ?? "";

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              CommonAppBar(
                title:
                    "${localizations.createBeneficiaryTitle} ${accountUser == "Merchant"
                        ? localizations.accountUserMerchant
                        : accountUser == "Beneficiary"
                        ? localizations.accountUserBeneficiary
                        : accountUser == "Agent"
                        ? localizations.accountUserAgent
                        : ""}",
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 18,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        CommonRequiredLabelAndDynamicField(
                          labelText:
                              "$accountUser ${localizations.createBeneficiaryAccountNumber}",
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.accountNumberController,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localizations.createBeneficiaryNickName,
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.nickNameController,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CommonButton(
                          onPressed: () {
                            if (controller
                                .accountNumberController
                                .text
                                .isEmpty) {
                              ToastHelper().showErrorToast(
                                localizations
                                    .createBeneficiaryValidationAccountNumber,
                              );
                            } else if (controller
                                .nickNameController
                                .text
                                .isEmpty) {
                              ToastHelper().showErrorToast(
                                localizations
                                    .createBeneficiaryValidationNickName,
                              );
                            } else {
                              controller.onBeneficiaryCreated = () {
                                if (accountUser == "Merchant") {
                                  Get.find<MakePaymentController>()
                                      .fetchBeneficiary();
                                } else if (accountUser == "Beneficiary") {
                                  Get.find<TransferController>()
                                      .fetchBeneficiary();
                                } else if (accountUser == "Agent") {
                                  Get.find<CashOutController>()
                                      .fetchBeneficiary();
                                }
                              };
                              controller.createBeneficiary();
                            }
                          },
                          width: double.infinity,
                          text: localizations.createBeneficiaryCreateButton,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isCreateBeneficiaryLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
