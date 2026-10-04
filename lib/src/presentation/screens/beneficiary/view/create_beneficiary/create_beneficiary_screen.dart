import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';

class CreateBeneficiaryScreen extends StatefulWidget {
  const CreateBeneficiaryScreen({super.key});

  @override
  State<CreateBeneficiaryScreen> createState() =>
      _CreateBeneficiaryScreenState();
}

class _CreateBeneficiaryScreenState extends State<CreateBeneficiaryScreen> {
  late final CreateBeneficiaryController controller;
  late final String accountUser;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateBeneficiaryController>();
    accountUser = Get.arguments?["account_user"] ?? "";
    controller.accountNumberController.addListener(_onTextChanged);
    controller.nickNameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.accountNumberController.removeListener(_onTextChanged);
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

    final String previewName = controller.nickNameController.text.trim().isEmpty
        ? (accountUser.isNotEmpty ? accountUser : localizations.createBeneficiaryTitle)
        : controller.nickNameController.text.trim();
    final String previewAccount =
        controller.accountNumberController.text.trim().isEmpty
            ? "•••• •••• ••••"
            : controller.accountNumberController.text.trim();

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
                title: "${localizations.createBeneficiaryTitle} $titleSuffix",
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
                                name: previewName,
                                size: 54,
                                isVerified: true,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      previewName,
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
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      previewAccount,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        CommonRequiredLabelAndDynamicField(
                          labelText:
                              "$accountUser ${localizations.createBeneficiaryAccountNumber}",
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.accountNumberController,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localizations.createBeneficiaryNickName,
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            hintText: "",
                            controller: controller.nickNameController,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
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
              visible: controller.isCreateBeneficiaryLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
