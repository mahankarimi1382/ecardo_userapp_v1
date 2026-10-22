import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/controller/country_controller.dart';
import 'package:ecardo_user/src/common/controller/register_fields_controller.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_country_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/personal_info_controller.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final bool isPersonalInfoEdit =
      Get.arguments?["is_personal_info_edit"] ?? false;
  late final PersonalInfoController controller;
  late final CountryController countryController;
  late final RegisterFieldsController registerFieldsController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PersonalInfoController>()
        ? Get.find<PersonalInfoController>()
        : Get.put(PersonalInfoController());
    countryController = Get.isRegistered<CountryController>()
        ? Get.find<CountryController>()
        : Get.put(CountryController());
    registerFieldsController = Get.isRegistered<RegisterFieldsController>()
        ? Get.find<RegisterFieldsController>()
        : Get.put(RegisterFieldsController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPersonalInfoEdit == true) {
        loadPersonalData();
      } else {
        loadData();
      }
    });
  }

  Future<void> loadPersonalData() async {
    controller.isLoading.value = true;
    await controller.fetchUser();
    await registerFieldsController.fetchRegisterFields();
    final user = controller.userModel.value.data;
    controller.firstNameController.text = user?.firstName ?? "";
    controller.lastNameController.text = user?.lastName ?? "";
    controller.userNameController.text = user?.username ?? "";
    controller.gender.value = user?.gender == "male"
        ? "Male"
        : user?.gender == "female"
        ? "Female"
        : "Other";
    controller.genderController.text = controller.gender.value;
    controller.phoneNoController.text = user?.phone ?? "";
    controller.countryCode.value = user?.country ?? "";
    await controller.fetchCountries();
    controller.isLoading.value = false;
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await registerFieldsController.fetchRegisterFields();
    if (registerFieldsController.registerFields["country_show"] == "1") {
      await countryController.fetchCountries();
      _setSelectedCountry();
    }
    controller.isLoading.value = false;
  }

  void _setSelectedCountry() {
    final selectedCountry =
        countryController.countryList.firstWhereOrNull(
          (country) => country.selected == true,
        ) ??
        countryController.countryList.firstWhereOrNull(
          (country) => country.code == 'IR',
        ) ??
        countryController.countryList.firstOrNull;

    if (selectedCountry != null) {
      controller.countryController.text = selectedCountry.name ?? "";
      controller.countryCode.value = selectedCountry.code ?? "";
      controller.countryDialCode.value = selectedCountry.dialCode ?? "";
      controller.country.value = selectedCountry.name ?? "";
      controller.phoneNoController.text = selectedCountry.dialCode ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextTertiary;

    final cardBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: AmbientAuthBackground(
        child: Obx(
          () => controller.isLoading.value
              ? const CommonLoading()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 0.30.sh,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (!isDark)
                                  Positioned.fill(
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 20,
                                        sigmaY: 20,
                                      ),
                                      child: Image.asset(
                                        PngAssets.splashFrame,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      PngAssets.appLogo,
                                      fit: BoxFit.contain,
                                      width: 155.w,
                                    ),
                                    SizedBox(height: 20.h),
                                    Text(
                                      localizations.personalInfoTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24.sp,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Padding(
                                      padding: EdgeInsetsDirectional.symmetric(
                                        horizontal: 18.w,
                                      ),
                                      child: Text(
                                        localizations.personalInfoSubtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsetsDirectional.symmetric(
                              horizontal: 18.w,
                            ),
                            padding: EdgeInsetsDirectional.only(
                              top: 3.h,
                              start: 18.w,
                              end: 18.w,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(30.r),
                                topEnd: Radius.circular(30.r),
                              ),
                              color: cardBg,
                              border: isDark
                                  ? Border.all(color: cardBorder, width: 1.2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 0),
                                  blurRadius: 40.r,
                                  color: AppColors.black.withValues(
                                    alpha: isDark ? 0.35 : 0.06,
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),
                                CommonRequiredLabelAndDynamicField(
                                  isLabelRequired: true,
                                  labelText:
                                      localizations.personalInfoFirstName,
                                  dynamicField: Obx(
                                    () => Semantics(
                                      label:
                                          localizations.personalInfoFirstName,
                                      textField: true,
                                      child: CommonAuthTextInputField(
                                        controller:
                                            controller.firstNameController,
                                        keyboardType: TextInputType.name,
                                        hintText: "",
                                        isFocused:
                                            controller.isFirstNameFocused.value,
                                        focusNode:
                                            controller.firstNameFocusNode,
                                        textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          color: primaryTextColor,
                                          letterSpacing: 0,
                                          height: 1.1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        hintStyle: TextStyle(
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.sp,
                                        ),
                                        suffixIcon: Obx(
                                          () => Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: 6.w,
                                              top: 14.h,
                                              bottom: 14.h,
                                            ),
                                            child: Image(
                                              image: const AssetImage(
                                                PngAssets.fullNameCommonIcon,
                                              ),
                                              color:
                                                  controller
                                                      .isFirstNameFocused
                                                      .value
                                                  ? (isDark
                                                        ? AppColors.darkAccent
                                                        : AppColors.brandViolet)
                                                  : secondaryTextColor
                                                        .withValues(
                                                          alpha: 0.60,
                                                        ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                CommonRequiredLabelAndDynamicField(
                                  isLabelRequired: true,
                                  labelText: localizations.personalInfoLastName,
                                  dynamicField: Obx(
                                    () => Semantics(
                                      label: localizations.personalInfoLastName,
                                      textField: true,
                                      child: CommonAuthTextInputField(
                                        controller:
                                            controller.lastNameController,
                                        focusNode: controller.lastNameFocusNode,
                                        isFocused:
                                            controller.isLastNameFocused.value,
                                        keyboardType: TextInputType.name,
                                        hintText: "",
                                        textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          color: primaryTextColor,
                                          letterSpacing: 0,
                                          height: 1.1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        hintStyle: TextStyle(
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.sp,
                                        ),
                                        suffixIcon: Obx(
                                          () => Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: 6.w,
                                              top: 14.h,
                                              bottom: 14.h,
                                            ),
                                            child: Image(
                                              image: const AssetImage(
                                                PngAssets.fullNameCommonIcon,
                                              ),
                                              color:
                                                  controller
                                                      .isLastNameFocused
                                                      .value
                                                  ? (isDark
                                                        ? AppColors.darkAccent
                                                        : AppColors.brandViolet)
                                                  : secondaryTextColor
                                                        .withValues(
                                                          alpha: 0.60,
                                                        ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      registerFieldsController
                                          .registerFields["username_show"] ==
                                      "1",
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CommonRequiredLabelAndDynamicField(
                                        labelText:
                                            localizations.personalInfoUserName,
                                        isLabelRequired:
                                            registerFieldsController
                                                .registerFields["username_validation"] ==
                                            "1",
                                        dynamicField: Obx(
                                          () => Semantics(
                                            label: localizations
                                                .personalInfoUserName,
                                            textField: true,
                                            child: CommonAuthTextInputField(
                                              controller:
                                                  controller.userNameController,
                                              keyboardType: TextInputType.name,
                                              hintText: "",
                                              focusNode:
                                                  controller.userNameFocusNode,
                                              isFocused: controller
                                                  .isUserNameFocused
                                                  .value,
                                              textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                color: primaryTextColor,
                                                letterSpacing: 0,
                                                height: 1.1,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              hintStyle: TextStyle(
                                                color: secondaryTextColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                              ),
                                              suffixIcon: Obx(
                                                () => Padding(
                                                  padding:
                                                      EdgeInsetsDirectional.only(
                                                        start: 6.w,
                                                        top: 14.h,
                                                        bottom: 14.h,
                                                      ),
                                                  child: Image(
                                                    image: const AssetImage(
                                                      PngAssets
                                                          .fullNameCommonIcon,
                                                    ),
                                                    color:
                                                        controller
                                                            .isUserNameFocused
                                                            .value
                                                        ? (isDark
                                                              ? AppColors
                                                                    .darkAccent
                                                              : AppColors
                                                                    .brandViolet)
                                                        : secondaryTextColor
                                                              .withValues(
                                                                alpha: 0.60,
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      registerFieldsController
                                          .registerFields["country_show"] ==
                                      "1",
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CommonRequiredLabelAndDynamicField(
                                        labelText:
                                            localizations.personalInfoCountry,
                                        isLabelRequired:
                                            registerFieldsController
                                                .registerFields["country_validation"] ==
                                            "1",
                                        dynamicField: Semantics(
                                          button: true,
                                          label:
                                              localizations.personalInfoCountry,
                                          child: CommonAuthTextInputField(
                                            controller:
                                                controller.countryController,
                                            keyboardType: TextInputType.none,
                                            focusNode:
                                                controller.countryFocusNode,
                                            isFocused: controller
                                                .isCountryFocused
                                                .value,
                                            readOnly: true,
                                            onTap: () {
                                              Get.bottomSheet(
                                                CommonCountryDropdownBottomSheet(
                                                  countryDialCode:
                                                      countryController
                                                          .countryList
                                                          .map(
                                                            (item) =>
                                                                item.dialCode ??
                                                                "",
                                                          )
                                                          .toList(),
                                                  controller: controller,
                                                  countryCode: countryController
                                                      .countryList
                                                      .map(
                                                        (item) =>
                                                            item.code ?? "",
                                                      )
                                                      .toList(),
                                                  countryImage:
                                                      countryController
                                                          .countryList
                                                          .map(
                                                            (item) =>
                                                                item.flag ?? "",
                                                          )
                                                          .toList(),
                                                  title: localizations
                                                      .personalInfoSelectCountry,
                                                  dropdownItems:
                                                      countryController
                                                          .countryList
                                                          .map(
                                                            (item) =>
                                                                item.name ?? "",
                                                          )
                                                          .toList(),
                                                  selectedItem:
                                                      controller.country,
                                                  textController: controller
                                                      .countryController,
                                                  bottomSheetHeight: 450.h,
                                                  clearFunction: () {
                                                    controller.phoneNoController
                                                        .clear();
                                                    controller
                                                        .phoneNoController
                                                        .text = controller
                                                        .countryDialCode
                                                        .value;
                                                  },
                                                ),
                                              );
                                            },
                                            hintText: localizations
                                                .personalInfoSelectCountry,
                                            textStyle: TextStyle(
                                              fontSize: 15.sp,
                                              color: primaryTextColor,
                                              letterSpacing: 0,
                                              height: 1.1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            hintStyle: TextStyle(
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                            suffixIcon: Obx(
                                              () => Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                      start: 6.w,
                                                      top: 16.h,
                                                      bottom: 16.h,
                                                    ),
                                                child: Image(
                                                  image: const AssetImage(
                                                    PngAssets
                                                        .arrowDownCommonIcon,
                                                  ),
                                                  color:
                                                      controller
                                                          .isCountryFocused
                                                          .value
                                                      ? (isDark
                                                            ? AppColors
                                                                  .darkAccent
                                                            : AppColors
                                                                  .brandViolet)
                                                      : secondaryTextColor
                                                            .withValues(
                                                              alpha: 0.60,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      registerFieldsController
                                          .registerFields["phone_show"] ==
                                      "1",
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CommonRequiredLabelAndDynamicField(
                                        labelText:
                                            localizations.personalInfoPhoneNo,
                                        isLabelRequired:
                                            registerFieldsController
                                                .registerFields["phone_validation"] ==
                                            "1",
                                        dynamicField: Semantics(
                                          label:
                                              localizations.personalInfoPhoneNo,
                                          textField: true,
                                          child: CommonAuthTextInputField(
                                            controller:
                                                controller.phoneNoController,
                                            hintText: "",
                                            keyboardType: TextInputType.phone,
                                            focusNode:
                                                controller.phoneFocusNode,
                                            isFocused: controller
                                                .isPhoneNoFocused
                                                .value,
                                            textStyle: TextStyle(
                                              fontSize: 15.sp,
                                              color: primaryTextColor,
                                              letterSpacing: 0,
                                              height: 1.1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            hintStyle: TextStyle(
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                            suffixIcon: Obx(
                                              () => Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                      start: 6.w,
                                                      top: 14.h,
                                                      bottom: 14.h,
                                                    ),
                                                child: Image(
                                                  image: const AssetImage(
                                                    PngAssets.phoneCommonIcon,
                                                  ),
                                                  color:
                                                      controller
                                                          .isPhoneNoFocused
                                                          .value
                                                      ? (isDark
                                                            ? AppColors
                                                                  .darkAccent
                                                            : AppColors
                                                                  .brandViolet)
                                                      : secondaryTextColor
                                                            .withValues(
                                                              alpha: 0.60,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      registerFieldsController
                                          .registerFields["referral_code_show"] ==
                                      "1",
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CommonRequiredLabelAndDynamicField(
                                        isLabelRequired:
                                            registerFieldsController
                                                .registerFields["referral_code_validation"] ==
                                            "1",
                                        labelText: localizations
                                            .personalInfoReferralCode,
                                        dynamicField: Obx(
                                          () => Semantics(
                                            label: localizations
                                                .personalInfoReferralCode,
                                            textField: true,
                                            child: CommonAuthTextInputField(
                                              controller: controller
                                                  .referralCodeController,
                                              keyboardType: TextInputType.text,
                                              hintText: "",
                                              focusNode:
                                                  controller.referralFocusNode,
                                              isFocused: controller
                                                  .isReferralCodeFocused
                                                  .value,
                                              textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                color: primaryTextColor,
                                                letterSpacing: 0,
                                                height: 1.1,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              hintStyle: TextStyle(
                                                color: secondaryTextColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                              ),
                                              suffixIcon: Obx(
                                                () => Padding(
                                                  padding:
                                                      EdgeInsetsDirectional.only(
                                                        start: 6.w,
                                                        top: 14.h,
                                                        bottom: 14.h,
                                                      ),
                                                  child: Image(
                                                    image: const AssetImage(
                                                      PngAssets
                                                          .commonReferralIcon,
                                                    ),
                                                    color:
                                                        controller
                                                            .isReferralCodeFocused
                                                            .value
                                                        ? (isDark
                                                              ? AppColors
                                                                    .darkAccent
                                                              : AppColors
                                                                    .brandViolet)
                                                        : secondaryTextColor
                                                              .withValues(
                                                                alpha: 0.60,
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      registerFieldsController
                                          .registerFields["gender_show"] ==
                                      "1",
                                  child: Column(
                                    children: [
                                      SizedBox(height: 16.h),
                                      CommonRequiredLabelAndDynamicField(
                                        labelText:
                                            localizations.commonDropdownGender,
                                        isLabelRequired:
                                            registerFieldsController
                                                .registerFields["gender_validation"] ==
                                            "1",

                                        dynamicField: Semantics(
                                          button: true,
                                          label: localizations
                                              .commonDropdownGender,
                                          child: CommonAuthTextInputField(
                                            focusNode:
                                                controller.genderFocusNode,
                                            isFocused: controller
                                                .isGenderFocused
                                                .value,
                                            onTap: () {
                                              Get.bottomSheet(
                                                CommonDropdownBottomSheet(
                                                  title: localizations
                                                      .commonDropdownGender,
                                                  isShowTitle: true,
                                                  notFoundText: localizations
                                                      .commonDropdownGenderNotFound,
                                                  textController: controller
                                                      .genderController,
                                                  dropdownItems: [
                                                    localizations
                                                        .commonDropdownMale,
                                                    localizations
                                                        .commonDropdownFemale,
                                                    localizations
                                                        .commonDropdownOther,
                                                  ],
                                                  selectedValue: [
                                                    localizations
                                                        .commonDropdownMale,
                                                    localizations
                                                        .commonDropdownFemale,
                                                    localizations
                                                        .commonDropdownOther,
                                                  ],
                                                  selectedItem:
                                                      controller.gender.value,
                                                  bottomSheetHeight: 400.h,
                                                  currentlySelectedValue:
                                                      controller.gender.value,
                                                  onValueSelected: (value) {
                                                    controller.gender.value =
                                                        value;
                                                    controller
                                                            .genderController
                                                            .text =
                                                        value;
                                                  },
                                                ),
                                              );
                                            },
                                            hintText: localizations
                                                .commonDropdownSelectGender,
                                            controller:
                                                controller.genderController,
                                            textStyle: TextStyle(
                                              fontSize: 15.sp,
                                              color: primaryTextColor,
                                              letterSpacing: 0,
                                              height: 1.1,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            hintStyle: TextStyle(
                                              color: secondaryTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                            suffixIcon: Obx(
                                              () => Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                      start: 6.w,
                                                      top: 16.h,
                                                      bottom: 16.h,
                                                    ),
                                                child: Image(
                                                  image: const AssetImage(
                                                    PngAssets
                                                        .arrowDownCommonIcon,
                                                  ),
                                                  color:
                                                      controller
                                                          .isGenderFocused
                                                          .value
                                                      ? (isDark
                                                            ? AppColors
                                                                  .darkAccent
                                                            : AppColors
                                                                  .brandViolet)
                                                      : secondaryTextColor
                                                            .withValues(
                                                              alpha: 0.60,
                                                            ),
                                                ),
                                              ),
                                            ),
                                            readOnly: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                CommonButton(
                                  height: 52.h,
                                  borderRadius: 16.r,
                                  onPressed: () => validateFields(),
                                  width: double.infinity,
                                  text: localizations.personalInfoContinue,
                                ),

                                SizedBox(height: 50.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.isSubmitLoading.value,
                        child: const CommonLoading(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void validateFields() async {
    final localizations = AppLocalizations.of(context)!;

    final validations = [
      _ValidationCheck(
        condition: controller.firstNameController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationFirstNameRequired,
      ),
      _ValidationCheck(
        condition: controller.lastNameController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationLastNameRequired,
      ),
      _ValidationCheck(
        condition:
            registerFieldsController.registerFields["username_validation"] ==
                "1" &&
            controller.userNameController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationUserNameRequired,
      ),
      _ValidationCheck(
        condition:
            registerFieldsController.registerFields["country_validation"] ==
                "1" &&
            controller.countryController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationCountryRequired,
      ),
      _ValidationCheck(
        condition:
            registerFieldsController.registerFields["phone_validation"] ==
                "1" &&
            controller.phoneNoController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationPhoneRequired,
      ),
      _ValidationCheck(
        condition:
            registerFieldsController
                    .registerFields["referral_code_validation"] ==
                "1" &&
            controller.referralCodeController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationReferralCodeRequired,
      ),
      _ValidationCheck(
        condition:
            registerFieldsController.registerFields["gender_validation"] ==
                "1" &&
            controller.genderController.text.isEmpty,
        errorMessage: localizations.personalInfoValidationGenderRequired,
      ),
    ];

    for (final validation in validations) {
      if (validation.condition) {
        ToastHelper().showErrorToast(validation.errorMessage);
        return;
      }
    }

    await controller.submitPersonalInfo();
  }
}

class _ValidationCheck {
  final bool condition;
  final String errorMessage;

  _ValidationCheck({required this.condition, required this.errorMessage});
}
