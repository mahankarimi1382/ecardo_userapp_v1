import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class PersonalInfoController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isSubmitLoading = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final RxList<CountryData> countryList = <CountryData>[].obs;

  // First Name
  final RxBool isFirstNameFocused = false.obs;
  final FocusNode firstNameFocusNode = FocusNode();
  final firstNameController = TextEditingController();

  // Last Name
  final RxBool isLastNameFocused = false.obs;
  final FocusNode lastNameFocusNode = FocusNode();
  final lastNameController = TextEditingController();

  // User Name
  final RxBool isUserNameFocused = false.obs;
  final FocusNode userNameFocusNode = FocusNode();
  final userNameController = TextEditingController();

  // Country
  final RxBool isCountryFocused = false.obs;
  final FocusNode countryFocusNode = FocusNode();
  final RxString country = "".obs;
  final RxString countryCode = "".obs;
  final RxString countryDialCode = "".obs;
  final countryController = TextEditingController();

  // Phone No
  final RxBool isPhoneNoFocused = false.obs;
  final FocusNode phoneFocusNode = FocusNode();
  final phoneNoController = TextEditingController();

  // Referral Code
  final RxBool isReferralCodeFocused = false.obs;
  final FocusNode referralFocusNode = FocusNode();
  final referralCodeController = TextEditingController();

  // Gender
  final RxString gender = "".obs;
  final RxBool isGenderFocused = false.obs;
  final FocusNode genderFocusNode = FocusNode();
  final genderController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    firstNameFocusNode.addListener(_handleFirstNameFocusChange);
    lastNameFocusNode.addListener(_handleLastNameFocusChange);
    userNameFocusNode.addListener(_handleUserNameFocusChange);
    countryFocusNode.addListener(_handleCountryFocusChange);
    phoneFocusNode.addListener(_handlePhoneFocusChange);
    referralFocusNode.addListener(_handleReferralFocusChange);
    genderFocusNode.addListener(_handleGenderFocusChange);
  }

  @override
  void onClose() {
    firstNameFocusNode.removeListener(_handleFirstNameFocusChange);
    lastNameFocusNode.removeListener(_handleLastNameFocusChange);
    userNameFocusNode.removeListener(_handleUserNameFocusChange);
    countryFocusNode.removeListener(_handleCountryFocusChange);
    phoneFocusNode.removeListener(_handlePhoneFocusChange);
    referralFocusNode.removeListener(_handleReferralFocusChange);
    genderFocusNode.removeListener(_handleGenderFocusChange);
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    userNameFocusNode.dispose();
    countryFocusNode.dispose();
    phoneFocusNode.dispose();
    referralFocusNode.dispose();
    genderFocusNode.dispose();
    super.onClose();
  }

  // First name focus change handler
  void _handleFirstNameFocusChange() {
    isFirstNameFocused.value = firstNameFocusNode.hasFocus;
  }

  // Last name focus change handler
  void _handleLastNameFocusChange() {
    isLastNameFocused.value = lastNameFocusNode.hasFocus;
  }

  // User name focus change handler
  void _handleUserNameFocusChange() {
    isUserNameFocused.value = userNameFocusNode.hasFocus;
  }

  // Country focus change handler
  void _handleCountryFocusChange() {
    isCountryFocused.value = countryFocusNode.hasFocus;
  }

  // Phone focus change handler
  void _handlePhoneFocusChange() {
    isPhoneNoFocused.value = phoneFocusNode.hasFocus;
  }

  // Referral focus change handler
  void _handleReferralFocusChange() {
    isReferralCodeFocused.value = referralFocusNode.hasFocus;
  }

  // Gender focus change handler
  void _handleGenderFocusChange() {
    isGenderFocused.value = genderFocusNode.hasFocus;
  }

  // Fetch User
  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Fetch Countries
  Future<void> fetchCountries() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.countriesEndpoint,
      );
      if (response.status == Status.completed) {
        final countryModel = CountryModel.fromJson(response.data!);
        countryList.clear();
        countryList.value = countryModel.data ?? [];
        final findCountry = countryList.firstWhere(
          (item) => item.code == countryCode.value,
        );
        country.value = findCountry.name ?? "";
        countryController.text = findCountry.name ?? "";
        countryCode.value = findCountry.code ?? "";
        countryDialCode.value = findCountry.dialCode ?? "";
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCountries() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  // Submit Personal Info
  Future<void> submitPersonalInfo() async {
    isSubmitLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
      };

      if (userNameController.text.isNotEmpty) {
        requestBody["username"] = userNameController.text;
      }

      if (phoneNoController.text.isNotEmpty) {
        requestBody["phone"] = phoneNoController.text;
      }

      if (countryController.text.isNotEmpty) {
        requestBody["country"] = "$countryDialCode:${countryCode.value}";
      }

      if (referralCodeController.text.isNotEmpty) {
        requestBody["invite"] = referralCodeController.text;
      }

      if (genderController.text.isNotEmpty) {
        requestBody["gender"] = gender.value == "Male"
            ? "male"
            : gender.value == "Female"
            ? "female"
            : "other";
      }

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.personalInfoEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_personal_info": true},
        );
        resetFields();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitPersonalInfo() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isSubmitLoading.value = false;
    }
  }

  void resetFields() {
    // First Name
    firstNameController.clear();

    // Last Name
    lastNameController.clear();

    // User Name
    userNameController.clear();

    // Country
    country.value = "";
    countryCode.value = "";
    countryDialCode.value = "";
    countryController.clear();

    // Phone No
    phoneNoController.clear();

    // Referral Code
    referralCodeController.clear();

    // Gender
    gender.value = "";
    genderController.clear();
  }
}
