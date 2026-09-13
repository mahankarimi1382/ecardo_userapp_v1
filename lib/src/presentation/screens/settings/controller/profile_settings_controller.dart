import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/controller/image_picker/image_picker_controller.dart';
import 'package:ecardo_user/src/common/model/country_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class ProfileSettingsController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isProfileUpdateLoading = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final ImagePickerController imagePickerController = Get.put(
    ImagePickerController(),
  );
  // PAYMENT-FIX (P-1): the manual `tokenService` bearer header was removed —
  // NetworkService's interceptor now attaches Authorization from the same
  // TokenService singleton.

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

  // Gender
  final RxString gender = "".obs;
  final RxBool isGenderFocused = false.obs;
  final FocusNode genderFocusNode = FocusNode();
  final genderController = TextEditingController();

  // Date Of Birth
  final RxBool isDateOfBirthFocused = false.obs;
  final FocusNode dateOfBirthFocusNode = FocusNode();
  final RxString dateOfBirth = "".obs;

  // Email Address
  final RxBool isEmailAddressFocused = false.obs;
  final FocusNode emailAddressFocusNode = FocusNode();
  final emailAddressController = TextEditingController();

  // Phone
  final RxBool isPhoneFocused = false.obs;
  final FocusNode phoneFocusNode = FocusNode();
  final phoneController = TextEditingController();

  // Country
  final RxBool isCountryFocused = false.obs;
  final FocusNode countryFocusNode = FocusNode();
  final RxString country = "".obs;
  final RxString countryCode = "".obs;
  final RxString countryDialCode = "".obs;
  final countryController = TextEditingController();
  final RxList<CountryData> countryList = <CountryData>[].obs;

  // City
  final RxBool isCityFocused = false.obs;
  final FocusNode cityFocusNode = FocusNode();
  final cityController = TextEditingController();

  // Zip Code
  final RxBool isZipCodeFocused = false.obs;
  final FocusNode zipCodeFocusNode = FocusNode();
  final zipCodeController = TextEditingController();

  // Address
  final RxBool isAddressFocused = false.obs;
  final FocusNode addressFocusNode = FocusNode();
  final addressController = TextEditingController();

  // Joining Date
  final RxBool isJoiningDateFocused = false.obs;
  final FocusNode joiningDateFocusNode = FocusNode();
  final joiningDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    firstNameFocusNode.addListener(_handleFirstNameFocusChange);
    lastNameFocusNode.addListener(_handleLastNameFocusChange);
    userNameFocusNode.addListener(_handleUserNameFocusChange);
    genderFocusNode.addListener(_handleGenderFocusChange);
    dateOfBirthFocusNode.addListener(_handleDateOfBirthFocusChange);
    emailAddressFocusNode.addListener(_handleEmailAddressFocusChange);
    phoneFocusNode.addListener(_handlePhoneFocusChange);
    countryFocusNode.addListener(_handleCountryFocusChange);
    cityFocusNode.addListener(_handleCityFocusChange);
    zipCodeFocusNode.addListener(_handleZipCodeFocusChange);
    addressFocusNode.addListener(_handleAddressFocusChange);
    joiningDateFocusNode.addListener(_handleJoiningDateFocusChange);
  }

  @override
  void onClose() {
    firstNameFocusNode.removeListener(_handleFirstNameFocusChange);
    lastNameFocusNode.removeListener(_handleLastNameFocusChange);
    userNameFocusNode.removeListener(_handleUserNameFocusChange);
    genderFocusNode.removeListener(_handleGenderFocusChange);
    dateOfBirthFocusNode.removeListener(_handleDateOfBirthFocusChange);
    emailAddressFocusNode.removeListener(_handleEmailAddressFocusChange);
    phoneFocusNode.removeListener(_handlePhoneFocusChange);
    countryFocusNode.removeListener(_handleCountryFocusChange);
    cityFocusNode.removeListener(_handleCityFocusChange);
    zipCodeFocusNode.removeListener(_handleZipCodeFocusChange);
    addressFocusNode.removeListener(_handleAddressFocusChange);
    joiningDateFocusNode.removeListener(_handleJoiningDateFocusChange);

    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    userNameFocusNode.dispose();
    genderFocusNode.dispose();
    dateOfBirthFocusNode.dispose();
    emailAddressFocusNode.dispose();
    phoneFocusNode.dispose();
    countryFocusNode.dispose();
    cityFocusNode.dispose();
    zipCodeFocusNode.dispose();
    addressFocusNode.dispose();
    joiningDateFocusNode.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    genderController.dispose();
    emailAddressController.dispose();
    phoneController.dispose();
    countryController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    addressController.dispose();
    joiningDateController.dispose();

    super.onClose();
  }

  // First Name focus change handler
  void _handleFirstNameFocusChange() {
    isFirstNameFocused.value = firstNameFocusNode.hasFocus;
  }

  // Last Name focus change handler
  void _handleLastNameFocusChange() {
    isLastNameFocused.value = lastNameFocusNode.hasFocus;
  }

  // User Name focus change handler
  void _handleUserNameFocusChange() {
    isUserNameFocused.value = userNameFocusNode.hasFocus;
  }

  // Gender focus change handler
  void _handleGenderFocusChange() {
    isGenderFocused.value = genderFocusNode.hasFocus;
  }

  // Email address change handler
  void _handleEmailAddressFocusChange() {
    isEmailAddressFocused.value = emailAddressFocusNode.hasFocus;
  }

  // Date of birth change handler
  void _handleDateOfBirthFocusChange() {
    isDateOfBirthFocused.value = dateOfBirthFocusNode.hasFocus;
  }

  // Phone change handler
  void _handlePhoneFocusChange() {
    isPhoneFocused.value = phoneFocusNode.hasFocus;
  }

  // Country change handler
  void _handleCountryFocusChange() {
    isCountryFocused.value = countryFocusNode.hasFocus;
  }

  // City change handler
  void _handleCityFocusChange() {
    isCityFocused.value = cityFocusNode.hasFocus;
  }

  // Zip code change handler
  void _handleZipCodeFocusChange() {
    isZipCodeFocused.value = zipCodeFocusNode.hasFocus;
  }

  // Address change handler
  void _handleAddressFocusChange() {
    isAddressFocused.value = addressFocusNode.hasFocus;
  }

  // Joining Date change handler
  void _handleJoiningDateFocusChange() {
    isJoiningDateFocused.value = joiningDateFocusNode.hasFocus;
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

  Future<void> submitUpdateProfile() async {
    isProfileUpdateLoading.value = true;
    try {
      final imageFile = imagePickerController.selectedImage.value;

      String formattedDob;
      try {
        formattedDob = DateFormat(
          "yyyy-MM-dd",
        ).format(DateFormat("dd/MM/yyyy").parse(dateOfBirth.value));
      } catch (e) {
        formattedDob = dateOfBirth.value;
      }
      // v1.0.24 (gender overwrite fix): compare against the LOCALIZED labels
      // (dropdown values are localized). The old `== "Male"` compared a
      // Persian/Arabic label with an English literal and silently rewrote
      // every non-English profile to "female"; "Other" also became "female".
      final loc = AppLocalizations.of(Get.context!)!;
      final genderLabel = gender.value;
      final String genderCode;
      if (genderLabel == loc.profileSettingsGenderMale) {
        genderCode = 'male';
      } else if (genderLabel == loc.profileSettingsGenderFemale) {
        genderCode = 'female';
      } else if (genderLabel == loc.profileSettingsGenderOther) {
        genderCode = 'other';
      } else {
        final l = genderLabel.toLowerCase();
        // v1.0.24: unknown labels fall back to 'other' — the old fallback
        // silently rewrote unknown values to 'female'.
        genderCode = l == 'male' || l == 'm'
            ? 'male'
            : l == 'female' || l == 'f'
                ? 'female'
                : 'other';
      }
      final formData = dio.FormData.fromMap({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'username': userNameController.text,
        'gender': genderCode,
        if (dateOfBirth.isNotEmpty) 'date_of_birth': formattedDob,
        'email': emailAddressController.text,
        'phone': phoneController.text,
        'country': countryCode.value,
        'city': cityController.text,
        'zip_code': zipCodeController.text,
        'address': addressController.text,
        if (imageFile != null)
          'avatar': await dio.MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });
      // PAYMENT-FIX (P-1): was a raw `dio.Dio()` POST (no timeout, no
      // 401-refresh, and a `e.response!` force-unwrap in the 422 handler).
      // Same avatar multipart payload is now routed through
      // NetworkService.postMultipart — timeouts, interceptors and 422 error
      // toasts come from the shared network layer; the Authorization header
      // is attached by its interceptor (same token).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: ApiPath.updateProfileEndpoint,
        data: formData,
      );

      if (response.status == Status.completed) {
        final message = response.data?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
        Get.back();
        await Get.find<HomeController>().fetchDashboard();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitUpdateProfile() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isProfileUpdateLoading.value = false;
    }
  }
}
