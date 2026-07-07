import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/model/beneficiary_model.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/beneficiary/controller/update_beneficiary_controller.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class UpdateBeneficiaryScreen extends StatefulWidget {
  const UpdateBeneficiaryScreen({super.key});

  @override
  State<UpdateBeneficiaryScreen> createState() =>
      _UpdateBeneficiaryScreenState();
}

class _UpdateBeneficiaryScreenState extends State<UpdateBeneficiaryScreen> {
  final UpdateBeneficiaryController controller = Get.put(
    UpdateBeneficiaryController(),
  );
  final String accountUser = Get.arguments?["account_user"] ?? "";
  final String beneficiaryId = Get.arguments?["beneficiary_id"] ?? "";
  final Beneficiaries beneficiaryData = Get.arguments["beneficiary_data"];

  @override
  void initState() {
    super.initState();
    controller.nickNameController.text = beneficiaryData.nickname ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              CommonAppBar(
                title:
                    "${localizations.updateBeneficiaryTitle} ${accountUser == "Merchant"
                        ? localizations.accountUserMerchant
                        : accountUser == "Beneficiary"
                        ? localizations.accountUserBeneficiary
                        : accountUser == "Agent"
                        ? localizations.accountUserAgent
                        : ""}",
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localizations.updateBeneficiaryNickName,
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.nickNameController,
                          ),
                        ),
                        SizedBox(height: 40),
                        CommonButton(
                          onPressed: () {
                            if (controller.nickNameController.text.isEmpty) {
                              ToastHelper().showErrorToast(
                                localizations
                                    .updateBeneficiaryValidationNickName,
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
                              controller.updateBeneficiary(
                                beneficiaryId: beneficiaryId,
                              );
                            }
                          },
                          width: double.infinity,
                          text: localizations.updateBeneficiaryUpdateButton,
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
              visible: controller.isBeneficiaryUpdateLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
