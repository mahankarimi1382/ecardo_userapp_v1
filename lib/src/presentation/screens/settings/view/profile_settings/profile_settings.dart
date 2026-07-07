import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:qunzo_user/src/common/controller/image_picker/image_picker_controller.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/profile_settings_controller.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final ProfileSettingsController controller = Get.find();
  final ImagePickerController imagePickerController = Get.put(
    ImagePickerController(),
  );
  final localization = AppLocalizations.of(Get.context!)!;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchUser();
    final user = controller.userModel.value.data;
    controller.firstNameController.text = user?.firstName ?? "";
    controller.lastNameController.text = user?.lastName ?? "";
    controller.userNameController.text = user?.username ?? "";
    controller.gender.value = user?.gender == "male"
        ? localization.profileSettingsGenderMale
        : localization.profileSettingsGenderFemale;
    controller.genderController.text = controller.gender.value;
    controller.dateOfBirth.value = user?.dateOfBirth ?? "";
    controller.emailAddressController.text = user?.email ?? "";
    controller.phoneController.text = user?.phone ?? "";
    controller.countryCode.value = user?.country ?? "";
    controller.cityController.text = user?.city ?? "";
    controller.zipCodeController.text = user?.zipCode ?? "";
    controller.addressController.text = user?.address ?? "";
    controller.addressController.text = user?.address ?? "";
    controller.joiningDateController.text = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).format(DateTime.parse(user?.createdAt ?? ""));
    await controller.fetchCountries();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              CommonAppBar(title: localization.profileSettingsScreenTitle),
              SizedBox(height: 30),
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      imagePickerController.pickImageFromGallery();
                    },
                    child: Obx(() {
                      final userData = controller.userModel.value.data;
                      final hasSelectedImage =
                          imagePickerController.selectedImage.value != null;
                      final hasAvatarPath =
                          userData?.avatarPath?.isNotEmpty == true;

                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: !hasSelectedImage && !hasAvatarPath
                              ? Border.all(
                                  color: AppColors.black.withValues(
                                    alpha: 0.10,
                                  ),
                                )
                              : Border.fromBorderSide(BorderSide.none),
                          image: hasSelectedImage
                              ? DecorationImage(
                                  image: FileImage(
                                    imagePickerController.selectedImage.value!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : hasAvatarPath
                              ? DecorationImage(
                                  image: NetworkImage(userData!.avatarPath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasSelectedImage && !hasAvatarPath
                            ? Center(
                                child: Text(
                                  "${userData?.firstName?.trim().isNotEmpty == true ? userData!.firstName!.trim()[0].toUpperCase() : ''}"
                                  "${userData?.lastName?.trim().isNotEmpty == true ? userData!.lastName!.trim()[0].toUpperCase() : ''}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 40,
                                    color: AppColors.lightPrimary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              )
                            : null,
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: () {
                      imagePickerController.pickImageFromGallery();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: EdgeInsets.all(7),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.white,
                        ),
                        child: SvgPicture.asset(
                          SvgAssets.commonCameraIcon,
                          colorFilter: ColorFilter.mode(
                            AppColors.lightPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  padding: EdgeInsetsDirectional.only(
                    start: 20,
                    end: 20,
                    bottom: 24,
                    top: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return CommonLoading();
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsFirstName,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.firstNameFocusNode,
                                isFocused: controller.isFirstNameFocused.value,
                                backgroundColor: AppColors.transparent,
                                keyboardType: TextInputType.name,
                                hintText: "",
                                controller: controller.firstNameController,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsLastName,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.lastNameFocusNode,
                                isFocused: controller.isLastNameFocused.value,
                                backgroundColor: AppColors.transparent,
                                keyboardType: TextInputType.name,
                                hintText: "",
                                controller: controller.lastNameController,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsUserName,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.userNameFocusNode,
                                isFocused: controller.isUserNameFocused.value,
                                backgroundColor: AppColors.transparent,
                                keyboardType: TextInputType.name,
                                hintText: "",
                                controller: controller.userNameController,
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsGender,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.genderFocusNode,
                                isFocused: controller.isGenderFocused.value,
                                backgroundColor: AppColors.transparent,
                                onTap: () {
                                  Get.bottomSheet(
                                    CommonDropdownBottomSheet(
                                      title: localization
                                          .profileSettingsGenderTitle,
                                      isShowTitle: true,
                                      notFoundText: localization
                                          .profileSettingsGenderNotFound,
                                      textController:
                                          controller.genderController,
                                      dropdownItems: [
                                        localization.profileSettingsGenderMale,
                                        localization
                                            .profileSettingsGenderFemale,
                                        localization.profileSettingsGenderOther,
                                      ],
                                      selectedValue: [
                                        localization.profileSettingsGenderMale,
                                        localization
                                            .profileSettingsGenderFemale,
                                        localization.profileSettingsGenderOther,
                                      ],
                                      selectedItem: controller.gender.value,
                                      bottomSheetHeight: 400,
                                      currentlySelectedValue:
                                          controller.gender.value,
                                      onValueSelected: (value) {
                                        controller.gender.value = value;
                                        controller.genderController.text =
                                            value;
                                      },
                                    ),
                                  );
                                },
                                hintText:
                                    localization.profileSettingsSelectGender,
                                controller: controller.genderController,
                                suffixIconColor: AppColors.lightTextTertiary,
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsDateOfBirth,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonSingleDatePicker(
                                focusNode: controller.dateOfBirthFocusNode,
                                isFocused:
                                    controller.isDateOfBirthFocused.value,
                                fillColor: AppColors.transparent,
                                suffixIcon: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    controller.isDateOfBirthFocused.value
                                        ? AppColors.lightPrimary
                                        : AppColors.lightTextTertiary,
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    PngAssets.calenderCommonIcon,
                                  ),
                                ),
                                suffixIconWidth: 25,
                                suffixIconHeight: 25,
                                onDateSelected: (DateTime value) {
                                  final dateFormat = DateFormat(
                                    "dd/MM/yyyy",
                                  ).format(value);
                                  controller.dateOfBirth.value = dateFormat;
                                },
                                initialDate:
                                    controller.dateOfBirth.value.isNotEmpty
                                    ? DateTime.tryParse(
                                        controller.dateOfBirth.value,
                                      )
                                    : null,
                                hintText: "",
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsEmailAddress,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.emailAddressFocusNode,
                                isFocused:
                                    controller.isEmailAddressFocused.value,
                                backgroundColor: AppColors.transparent,
                                keyboardType: TextInputType.emailAddress,
                                hintText: "",
                                controller: controller.emailAddressController,
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsPhone,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.phoneFocusNode,
                                isFocused: controller.isPhoneFocused.value,
                                backgroundColor: AppColors.transparent,
                                hintText: "",
                                controller: controller.phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsCountry,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.countryFocusNode,
                                isFocused: controller.isCountryFocused.value,
                                backgroundColor: AppColors.transparent,
                                onTap: () {
                                  Get.bottomSheet(
                                    CommonDropdownBottomSheet(
                                      title: localization
                                          .profileSettingsCountryTitle,
                                      isShowTitle: true,
                                      showSearch: true,
                                      notFoundText: localization
                                          .profileSettingsCountryNotFound,
                                      onValueSelected: (value) {
                                        int index = controller.countryList
                                            .indexWhere(
                                              (item) => item.name == value,
                                            );

                                        if (index != -1) {
                                          final selectedCountry =
                                              controller.countryList[index];
                                          controller.countryController.text =
                                              selectedCountry.name ?? "";
                                          controller.countryCode.value =
                                              selectedCountry.code ?? "";
                                          controller.countryDialCode.value =
                                              selectedCountry.dialCode ?? "";
                                        }
                                      },
                                      selectedValue: controller.countryList
                                          .map((item) => item.name.toString())
                                          .toList(),
                                      dropdownItems: controller.countryList
                                          .map((item) => item.name.toString())
                                          .toList(),
                                      selectedItem:
                                          controller.countryController.text,
                                      textController:
                                          controller.countryController,
                                      currentlySelectedValue:
                                          controller.countryController.text,
                                      bottomSheetHeight: 500,
                                    ),
                                  );
                                },
                                hintText:
                                    localization.profileSettingsSelectCountry,
                                controller: controller.countryController,
                                suffixIconColor: AppColors.lightTextTertiary,
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsCity,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.cityFocusNode,
                                isFocused: controller.isCityFocused.value,
                                backgroundColor: AppColors.transparent,
                                hintText: "",
                                controller: controller.cityController,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsZipCode,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.zipCodeFocusNode,
                                isFocused: controller.isZipCodeFocused.value,
                                backgroundColor: AppColors.transparent,
                                hintText: "",
                                controller: controller.zipCodeController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),

                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsJoiningDate,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                focusNode: controller.joiningDateFocusNode,
                                isFocused:
                                    controller.isJoiningDateFocused.value,
                                backgroundColor: AppColors.transparent,
                                hintText: "",
                                controller: controller.joiningDateController,
                                keyboardType: TextInputType.datetime,
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.profileSettingsAddress,
                            isLabelRequired: false,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightTextTertiary,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLine: 4,
                                focusNode: controller.addressFocusNode,
                                isFocused: controller.isAddressFocused.value,
                                backgroundColor: AppColors.transparent,
                                hintText: "",
                                controller: controller.addressController,
                                keyboardType: TextInputType.streetAddress,
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          CommonButton(
                            onPressed: () => controller.submitUpdateProfile(),
                            width: double.infinity,

                            text: localization.profileSettingsSaveChangesButton,
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          Obx(
            () => Visibility(
              visible: controller.isProfileUpdateLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
