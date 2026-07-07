import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_two.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/controller/sign_up_status_controller.dart';

class SignUpStatusScreen extends StatefulWidget {
  const SignUpStatusScreen({super.key});

  @override
  State<SignUpStatusScreen> createState() => _SignUpStatusScreenState();
}

class _SignUpStatusScreenState extends State<SignUpStatusScreen> {
  final SignUpStatusController controller = Get.find();
  final bool isPasswordSetup = Get.arguments?["is_password_set_up"] ?? false;
  final bool isPersonalInfo = Get.arguments?["is_personal_info"] ?? false;
  final bool isIdVerification = Get.arguments?["is_id_verification"] ?? false;
  final bool isLogInState = Get.arguments?["is_login_state"] ?? false;
  final RxBool emailVerified = false.obs;
  final RxBool setUpPassword = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadEmailVerified();
    await loadSetUpPassword();
    if (isPasswordSetup || isPersonalInfo || isIdVerification || isLogInState) {
      await controller.fetchUser();
    }
  }

  // Load Email Verified for current user
  Future<void> loadEmailVerified() async {
    final isEmailVerified = await SettingsService.getEmailVerified();
    if (isEmailVerified != null) {
      emailVerified.value = isEmailVerified;
    }
  }

  // Load Set Up Password for current user
  Future<void> loadSetUpPassword() async {
    final isSetUpPassword = await SettingsService.getSetUpPassword();
    if (isSetUpPassword != null) {
      setUpPassword.value = isSetUpPassword;
    }
  }

  // Check if all steps are completed
  bool get allStepsCompleted {
    final personalInfoCompleted =
        controller.userModel.value.data?.boardingSteps?.personalInfo == true;
    final idVerificationCompleted =
        controller.userModel.value.data?.boardingSteps?.idVerification == false;
    final isKycVerification = controller.userModel.value.data?.kyc == 2;

    return getEmailVerificationStatus() &&
        getPasswordSetupStatus() &&
        personalInfoCompleted &&
        idVerificationCompleted &&
        isKycVerification;
  }

  // Get current status
  bool getEmailVerificationStatus() {
    if (isLogInState || isPersonalInfo || isIdVerification) {
      return controller
              .userModel
              .value
              .data
              ?.boardingSteps
              ?.emailVerification ==
          true;
    } else {
      return emailVerified.value;
    }
  }

  bool getPasswordSetupStatus() {
    if (isLogInState || isPersonalInfo || isIdVerification) {
      return controller.userModel.value.data?.boardingSteps?.passwordSetup ==
          true;
    } else {
      return setUpPassword.value;
    }
  }

  // Get ID verification
  String? get idVerificationStatusText {
    final localizations = AppLocalizations.of(context)!;

    final idVerification =
        controller.userModel.value.data?.boardingSteps?.idVerification;
    final kycVerification = controller.userModel.value.data?.kyc;
    return (idVerification == false && kycVerification == 2)
        ? localizations.signUpStatusInReview
        : (idVerification == false && kycVerification == 3)
        ? localizations.signUpStatusRejected
        : null;
  }

  // Next Step
  Future<void> _handleNextStep() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final emailVerificationDone = getEmailVerificationStatus();
      final passwordSetupDone = getPasswordSetupStatus();
      final personalInfoDone =
          controller.userModel.value.data?.boardingSteps?.personalInfo == true;
      final kycStatus = controller.userModel.value.data?.kyc;

      if (emailVerificationDone &&
          passwordSetupDone &&
          personalInfoDone &&
          kycStatus == 3) {
        await _handleIdVerification();
      } else if (emailVerificationDone &&
          passwordSetupDone &&
          personalInfoDone) {
        await _handleIdVerification();
      } else if (emailVerificationDone && passwordSetupDone) {
        Get.toNamed(BaseRoute.personalInfo);
      } else if (emailVerificationDone) {
        Get.toNamed(BaseRoute.setUpPassword);
      }
    } catch (e) {
      ToastHelper().showErrorToast(localizations.signUpStatusErrorProcessing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        showExitApplicationAlertDialog();
      },
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => controller.fetchUser(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderSection(context),
                    _buildMainContent(context),
                  ],
                ),
              ),
            ),
            Obx(
              () =>
                  controller.isKycLoading.value ||
                      controller.isFcmTokenLoading.value
                  ? const CommonLoading()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SizedBox(
      height: 0.30.sh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Image.asset(PngAssets.splashFrame, fit: BoxFit.cover),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(PngAssets.appLogo, fit: BoxFit.contain, width: 105.w),
              SizedBox(height: 20.h),
              Text(
                localizations.signUpStatusTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w900,
                  fontSize: 24.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                child: Text(
                  localizations.signUpStatusSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Obx(() {
      return Container(
        constraints: BoxConstraints(minHeight: 0.70.sh),
        margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(30.r),
            topEnd: Radius.circular(30.r),
          ),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 0),
              blurRadius: 40.r,
              color: AppColors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: controller.isLoading.value
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.lightPrimary,
                  size: 50,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  _buildStep(
                    step: 1,
                    title: localizations.signUpStatusEmailVerification,
                    isCompleted: getEmailVerificationStatus(),
                    icon: SvgAssets.commonMailIcon,
                  ),
                  _buildStep(
                    step: 2,
                    title: localizations.signUpStatusSetupPassword,
                    isCompleted: getPasswordSetupStatus(),
                    icon: SvgAssets.commonSetupPasswordIcon,
                  ),
                  _buildStep(
                    step: 3,
                    title: localizations.signUpStatusPersonalInfo,
                    isCompleted:
                        controller
                            .userModel
                            .value
                            .data
                            ?.boardingSteps
                            ?.personalInfo ==
                        true,
                    icon: SvgAssets.commonPersonalInfoIcon,
                  ),
                  _buildStep(
                    step: 4,
                    title: localizations.signUpStatusVerification,
                    isCompleted:
                        controller
                            .userModel
                            .value
                            .data
                            ?.boardingSteps
                            ?.idVerification ==
                        true,
                    icon: SvgAssets.commonIdVerificationIcon,
                    statusText: idVerificationStatusText,
                    statusColor: AppColors.warning,
                  ),
                  if (controller.userModel.value.data?.kyc == 3)
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 30),
                      child: Text(
                        (controller.userModel.value.data?.rejectionReason !=
                                    null &&
                                controller.userModel.value.data?.rejectionReason
                                        ?.trim()
                                        .isNotEmpty ==
                                    true)
                            ? controller
                                      .userModel
                                      .value
                                      .data!
                                      .rejectionReason ??
                                  ""
                            : localizations.signUpStatusNoReason,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 13,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  SizedBox(height: 20.h),
                  _buildActionButton(context),
                ],
              ),
      );
    });
  }

  Widget _buildActionButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Obx(() {
      final userData = controller.userModel.value.data;
      final boardingSteps = userData?.boardingSteps;
      final isCompleted = boardingSteps?.completed ?? false;
      final isPersonalInfo = boardingSteps?.personalInfo ?? false;
      final isReview = controller.userModel.value.data?.kyc == 2;
      final isRejected = controller.userModel.value.data?.kyc == 3;

      return Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: Column(
          children: [
            if (!allStepsCompleted && !isCompleted) ...[
              Obx(
                () => CommonButton(
                  onPressed: _handleNextStep,
                  width: double.infinity,

                  text: controller.userModel.value.data?.kyc == 3
                      ? localizations.signUpStatusSubmitAgain
                      : localizations.signUpStatusNextStep,
                ),
              ),
            ],

            if (isCompleted)
              CommonButton(
                onPressed: () => controller.postFcmNotification(),
                width: double.infinity,

                text: localizations.signUpStatusDashboard,
              ),

            if (isPersonalInfo && !(isReview || isRejected || isCompleted)) ...[
              SizedBox(height: 15.h),
              CommonIconButton(
                backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.04),
                borderWidth: 2,
                borderColor: AppColors.lightPrimary.withValues(alpha: 0.50),
                text: localizations.signUpStatusBack,
                icon: PngAssets.reviewArrowBackCommonIcon,
                iconWidth: 16,
                iconHeight: 16,
                iconAndTextSpace: 8,
                iconColor: AppColors.lightTextPrimary,
                textColor: AppColors.lightTextPrimary,
                onPressed: () {
                  Get.toNamed(
                    BaseRoute.personalInfo,
                    arguments: {"is_personal_info_edit": true},
                  );
                },
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _handleIdVerification() async {
    final localizations = AppLocalizations.of(context)!;

    try {
      await controller.fetchUserKyc();

      if (controller.userKycList.isNotEmpty) {
        Get.bottomSheet(
          CommonDropdownBottomSheetTwo(
            isNavigationPop: false,
            notFoundText:
                localizations.signUpStatusDropdownTwoVerificationNotFound,
            dropdownItems: controller.userKycList
                .map((item) => item.name.toString())
                .toList(),
            bottomSheetHeight: 300.h,
            currentlySelectedValue: controller.typeName.value,
            onItemSelected: (value) {
              controller.typeName.value = value;

              final selectedKyc = controller.userKycList.firstWhere(
                (item) => item.name == value,
              );

              if (selectedKyc.fields != null) {
                Get.back();
                Get.toNamed(
                  BaseRoute.authIdVerification,
                  arguments: {
                    "fields": selectedKyc.fields,
                    "kyc_id": selectedKyc.id.toString(),
                  },
                );
              }
            },
          ),
        );
      } else {
        ToastHelper().showErrorToast(
          localizations.signUpStatusVerificationTypeEmpty,
        );
      }
    } catch (e) {
      ToastHelper().showErrorToast(localizations.signUpStatusErrorLoadingTypes);
    }
  }

  Widget _buildStep({
    required int step,
    required String title,
    required bool isCompleted,
    required String icon,
    String? statusText,
    Color? statusColor,
  }) {
    final bool isIdVerificationInReview =
        step == 4 &&
        controller.userModel.value.data?.boardingSteps?.idVerification ==
            false &&
        (controller.userModel.value.data?.kyc == 2);
    final bool isIdVerificationRejected =
        step == 4 &&
        controller.userModel.value.data?.boardingSteps?.idVerification ==
            false &&
        (controller.userModel.value.data?.kyc == 3);
    final localizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 30.w),
              child: Column(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isIdVerificationInReview
                          ? AppColors.warning.withValues(alpha: 0.06)
                          : isIdVerificationRejected
                          ? AppColors.error.withValues(alpha: 0.06)
                          : isCompleted
                          ? AppColors.success
                          : AppColors.lightTextPrimary.withValues(alpha: 0.06),
                    ),
                    child: isCompleted
                        ? (isIdVerificationInReview || isIdVerificationRejected
                              ? Padding(
                                  padding: EdgeInsets.all(5.r),
                                  child: SvgPicture.asset(
                                    SvgAssets.commonReviewIcon,
                                    colorFilter: ColorFilter.mode(
                                      isIdVerificationInReview
                                          ? AppColors.warning
                                          : AppColors.error,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Image.asset(
                                    PngAssets.stepperCheckCommonIcon,
                                  ),
                                ))
                        : Padding(
                            padding: EdgeInsets.all(9.w),
                            child: SvgPicture.asset(
                              icon,
                              colorFilter: ColorFilter.mode(
                                isIdVerificationInReview
                                    ? AppColors.warning.withValues(alpha: 0.40)
                                    : isIdVerificationRejected
                                    ? AppColors.error.withValues(alpha: 0.40)
                                    : isCompleted
                                    ? AppColors.success.withValues(alpha: 0.40)
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.40,
                                      ),
                                BlendMode.srcIn,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                  SizedBox(height: 10.h),
                  if (step != 4)
                    Container(
                      width: 2.5.w,
                      height: 38.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.lightTextPrimary.withValues(
                                alpha: 0.15,
                              ),
                      ),
                    ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Transform.translate(
              offset: const Offset(0, -5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${localizations.signUpStatusStep} $step",
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isCompleted
                          ? AppColors.lightTextPrimary
                          : AppColors.lightTextPrimary.withValues(alpha: 0.60),
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (statusText != null) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(end: 30.w),
            child: Text(
              statusText,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: isIdVerificationInReview
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void showExitApplicationAlertDialog() {
    final localizations = AppLocalizations.of(context)!;

    Get.bottomSheet(
      CommonAlertBottomSheet(
        title: localizations.exitApplicationTitle,
        message: localizations.exitApplicationMessage,
        onConfirm: () async {
          await Get.find<TokenService>().clearToken();
          exit(0);
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}
