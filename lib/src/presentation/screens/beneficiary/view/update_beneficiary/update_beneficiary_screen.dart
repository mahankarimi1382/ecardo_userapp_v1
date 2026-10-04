import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/update_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class UpdateBeneficiaryScreen extends StatefulWidget {
  const UpdateBeneficiaryScreen({super.key});

  @override
  State<UpdateBeneficiaryScreen> createState() =>
      _UpdateBeneficiaryScreenState();
}

class _UpdateBeneficiaryScreenState extends State<UpdateBeneficiaryScreen> {
  late final UpdateBeneficiaryController controller;
  late final String accountUser;
  late final String beneficiaryId;
  late final Beneficiaries beneficiaryData;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UpdateBeneficiaryController>();
    accountUser = Get.arguments?["account_user"] ?? "";
    beneficiaryId = Get.arguments?["beneficiary_id"] ?? "";
    beneficiaryData = Get.arguments["beneficiary_data"];
    controller.nickNameController.text = beneficiaryData.nickname ?? "";
    controller.nickNameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.nickNameController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String displayName = controller.nickNameController.text.trim().isEmpty
        ? (beneficiaryData.nickname ?? accountUser)
        : controller.nickNameController.text.trim();
    final String accountNumber = beneficiaryData.accountNumber ?? "";

    final String titleSuffix = accountUser == "Merchant"
        ? localizations.accountUserMerchant
        : accountUser == "Beneficiary"
        ? localizations.accountUserBeneficiary
        : accountUser == "Agent"
        ? localizations.accountUserAgent
        : "";

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              CommonAppBar(
                title: "${localizations.updateBeneficiaryTitle} $titleSuffix",
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.page,
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
                        blurRadius: AppSpacing.lg,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Monogram Hero Preview Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.darkSurfaceVariant,
                                      AppColors.darkSurface,
                                    ]
                                  : [
                                      AppColors.lightSecondaryContainer,
                                      AppColors.lightSurfaceVariant,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              MonogramAvatar(
                                name: displayName,
                                imageUrl: beneficiaryData.receiver?.avatar,
                                size: 54,
                                isVerified: true,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (accountNumber.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        accountNumber,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localizations.updateBeneficiaryNickName,
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.nickNameController,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
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
                        const SizedBox(height: AppSpacing.xl),
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
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
