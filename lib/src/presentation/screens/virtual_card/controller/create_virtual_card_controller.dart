import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_holder_model.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_provider_model.dart';

class CreateVirtualCardController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isCardHolderLoading = false.obs;
  final RxBool isCreateVirtualCardLoading = false.obs;
  final RxBool selectedTab = true.obs;
  final localization = AppLocalizations.of(Get.context!);

  // Card Provider Controller
  final RxBool isCardProviderFocused = false.obs;
  final FocusNode cardProviderFocusNode = FocusNode();
  final cardProviderController = TextEditingController();
  final Rxn<CardProviderData> selectedCardProvider = Rxn<CardProviderData>();
  final RxList<CardProviderData> cardProvidersList = <CardProviderData>[].obs;

  // Card Holder Controller
  final RxBool isCardHolderFocused = false.obs;
  final FocusNode cardHolderFocusNode = FocusNode();
  final cardHolderController = TextEditingController();
  final Rxn<CardHolderData> selectedCardHolder = Rxn<CardHolderData>();
  final RxList<CardHolderData> cardHolderList = <CardHolderData>[].obs;

  // Name Controller
  final RxBool isNameFocused = false.obs;
  final FocusNode nameFocusNode = FocusNode();
  final nameController = TextEditingController();

  // Email Controller
  final RxBool isEmailFocused = false.obs;
  final FocusNode emailFocusNode = FocusNode();
  final emailController = TextEditingController();

  // Phone Number Controller
  final RxBool isPhoneNumberFocused = false.obs;
  final FocusNode phoneNumberFocusNode = FocusNode();
  final phoneNumberController = TextEditingController();

  // Country Controller
  final RxBool isCountryFocused = false.obs;
  final FocusNode countryFocusNode = FocusNode();
  final countryController = TextEditingController();
  final Rxn<CountryData> selectedCountry = Rxn<CountryData>();
  final RxList<CountryData> countryList = <CountryData>[].obs;

  // City Controller
  final RxBool isCityFocused = false.obs;
  final FocusNode cityFocusNode = FocusNode();
  final cityController = TextEditingController();

  // State Controller
  final RxBool isStateFocused = false.obs;
  final FocusNode stateFocusNode = FocusNode();
  final stateController = TextEditingController();

  // Postal Code Controller
  final RxBool isPostalCodeFocused = false.obs;
  final FocusNode postalCodeFocusNode = FocusNode();
  final postalCodeController = TextEditingController();

  // Address Controller
  final RxBool isAddressFocused = false.obs;
  final FocusNode addressFocusNode = FocusNode();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cardProviderFocusNode.addListener(() {
      isCardProviderFocused.value = cardProviderFocusNode.hasFocus;
    });
    cardHolderFocusNode.addListener(() {
      isCardHolderFocused.value = cardHolderFocusNode.hasFocus;
    });
    nameFocusNode.addListener(() {
      isNameFocused.value = nameFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      isEmailFocused.value = emailFocusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      isPhoneNumberFocused.value = phoneNumberFocusNode.hasFocus;
    });
    countryFocusNode.addListener(() {
      isCountryFocused.value = countryFocusNode.hasFocus;
    });
    cityFocusNode.addListener(() {
      isCityFocused.value = cityFocusNode.hasFocus;
    });
    stateFocusNode.addListener(() {
      isStateFocused.value = stateFocusNode.hasFocus;
    });
    postalCodeFocusNode.addListener(() {
      isPostalCodeFocused.value = postalCodeFocusNode.hasFocus;
    });
    addressFocusNode.addListener(() {
      isAddressFocused.value = addressFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    super.onClose();
    cardProviderFocusNode.dispose();
    cardProviderController.dispose();
    cardHolderFocusNode.dispose();
    cardHolderController.dispose();
    nameFocusNode.dispose();
    nameController.dispose();
    emailFocusNode.dispose();
    emailController.dispose();
    phoneNumberFocusNode.dispose();
    phoneNumberController.dispose();
    countryFocusNode.dispose();
    countryController.dispose();
    cityFocusNode.dispose();
    cityController.dispose();
    stateFocusNode.dispose();
    stateController.dispose();
    postalCodeFocusNode.dispose();
    postalCodeController.dispose();
    addressFocusNode.dispose();
    addressController.dispose();
  }

  // Fetch Card Providers
  Future<void> fetchCardProviders() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getCardProvidersEndpoint,
      );
      if (response.status == Status.completed) {
        final cardProvidersModel = CardProviderModel.fromJson(response.data!);
        cardProvidersList.clear();
        cardProvidersList.assignAll(cardProvidersModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCardProviders() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Fetch Card Holders
  Future<void> fetchCardHolders() async {
    isCardHolderLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.getCardHoldersEndpoint}?provider=${selectedCardProvider.value?.code}",
      );
      if (response.status == Status.completed) {
        final cardHoldersModel = CardHolderModel.fromJson(response.data!);
        cardHolderList.clear();
        cardHolderList.assignAll(cardHoldersModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCardHolders() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isCardHolderLoading.value = false;
    }
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
        countryList.assignAll(countryModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCountries() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Create Virtual Card
  Future<void> createVirtualCard() async {
    if (!validateFields()) return;

    isCreateVirtualCardLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        'provider_code': selectedCardProvider.value?.code.toString(),
        'type': selectedTab.value == true
            ? 'existing_one'
            : selectedTab.value == false
            ? "new_one"
            : null,
        if (selectedTab.value == true)
          'cardholder_id': selectedCardHolder.value?.id,
      };
      if (selectedTab.value == false) {
        requestBody.addAll({
          'name': nameController.text,
          'email': emailController.text,
          'phone_number': phoneNumberController.text,
          'country': selectedCountry.value?.code,
          'city': cityController.text,
          'state': stateController.text,
          'postal_code': postalCodeController.text,
          'address': addressController.text,
        });
      }

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.getVirtualCardsEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        clearFields();
        Get.back();
        await Get.find<VirtualCardController>().fetchVirtualCards();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ createVirtualCard() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isCreateVirtualCardLoading.value = false;
    }
  }

  bool validateFields() {
    if (cardProviderController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.createCardProviderRequired);
      return false;
    }

    if (selectedTab.value == true) {
      if (cardHolderController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createCardHolderRequired);
        return false;
      }
    }

    if (selectedTab.value == false) {
      if (nameController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createNameRequired);
        return false;
      }

      if (emailController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createEmailRequired);
        return false;
      }

      if (!GetUtils.isEmail(emailController.text)) {
        ToastHelper().showErrorToast(localization!.createEmailInvalid);
        return false;
      }

      if (phoneNumberController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createPhoneNumberRequired);
        return false;
      }

      if (countryController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createCountryRequired);
        return false;
      }

      if (cityController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createCityRequired);
        return false;
      }

      if (stateController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createStateRequired);
        return false;
      }

      if (postalCodeController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createPostalCodeRequired);
        return false;
      }

      if (addressController.text.isEmpty) {
        ToastHelper().showErrorToast(localization!.createAddressRequired);
        return false;
      }
    }

    return true;
  }

  void clearFields() {
    // Card Provider Controller
    isCardProviderFocused.value = false;
    cardProviderController.clear();
    selectedCardProvider.value = CardProviderData();

    // Card Holder Controller
    isCardHolderFocused.value = false;
    cardHolderController.clear();
    selectedCardHolder.value = CardHolderData();

    // Name Controller
    isNameFocused.value = false;
    nameController.clear();

    // Email Controller
    isEmailFocused.value = false;
    emailController.clear();

    // Phone Number Controller
    isPhoneNumberFocused.value = false;
    phoneNumberController.clear();

    // Country Controller
    isCountryFocused.value = false;
    countryController.clear();
    selectedCountry.value = CountryData();

    // City Controller
    isCityFocused.value = false;
    cityController.clear();

    // State Controller
    isStateFocused.value = false;
    stateController.clear();

    // Postal Code Controller
    isPostalCodeFocused.value = false;
    postalCodeController.clear();

    // Address Controller
    isAddressFocused.value = false;
    addressController.clear();
  }
}
