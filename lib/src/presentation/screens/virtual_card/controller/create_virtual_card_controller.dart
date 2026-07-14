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
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_product_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:qunzo_user/src/presentation/widgets/web_view_screen.dart';

class CreateVirtualCardController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isCardHolderLoading = false.obs;
  final RxBool isCreateVirtualCardLoading = false.obs;
  final RxBool selectedTab = true.obs;
  final RxString creationMode = 'product'.obs;
  final RxnString selectedCreationOption = RxnString();
  final localization = AppLocalizations.of(Get.context!);

  // Card Provider Controller
  final RxBool isCardProviderFocused = false.obs;
  final FocusNode cardProviderFocusNode = FocusNode();
  final cardProviderController = TextEditingController();
  final Rxn<CardProviderData> selectedCardProvider = Rxn<CardProviderData>();
  final RxList<CardProviderData> cardProvidersList = <CardProviderData>[].obs;

  final RxList<CardProductData> cardProducts = <CardProductData>[].obs;
  final Rxn<CardProductData> selectedCardProduct = Rxn<CardProductData>();
  final RxBool isCardProductsLoading = false.obs;
  final RxBool hasLoadedCardProducts = false.obs;
  final RxString cardProductsError = ''.obs;
  final RxList<Wallets> irrWallets = <Wallets>[].obs;
  final Rxn<Wallets> selectedIrrWallet = Rxn<Wallets>();
  final Rxn<CardGatewayData> selectedGateway = Rxn<CardGatewayData>();
  final RxString fundingSource = 'irr_wallet'.obs;
  final RxBool requestPhysical = false.obs;
  final amountController = TextEditingController();
  final irrWalletController = TextEditingController();
  final gatewayController = TextEditingController();
  final Map<String, TextEditingController> applicationFieldControllers = {};
  final Map<String, RxBool> applicationBooleanValues = {};

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
    amountController.dispose();
    irrWalletController.dispose();
    gatewayController.dispose();
    for (final controller in applicationFieldControllers.values) {
      controller.dispose();
    }
  }

  Future<void> fetchCardProducts() async {
    isCardProductsLoading.value = true;
    hasLoadedCardProducts.value = false;
    cardProductsError.value = '';
    cardProducts.clear();
    selectedCardProduct.value = null;
    selectedGateway.value = null;
    gatewayController.clear();
    irrWallets.clear();
    selectedIrrWallet.value = null;
    irrWalletController.clear();

    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getCardProductsEndpoint,
      );
      if (response.status != Status.completed || response.data == null) {
        cardProductsError.value =
            response.message ?? 'Unable to load IRR card products.';
        return;
      }

      final model = CardProductModel.fromJson(response.data!);
      cardProducts.assignAll(
        model.data.where(
          (product) =>
              product.currency?.toUpperCase() == 'IRR' &&
              product.capabilities?.canCreateVirtual == true,
        ),
      );
      if (cardProducts.isNotEmpty) {
        selectCardProduct(cardProducts.first);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCardProducts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      cardProductsError.value = 'Unable to load IRR card products.';
    } finally {
      hasLoadedCardProducts.value = true;
      isCardProductsLoading.value = false;
    }
  }

  Future<void> retryCardProducts() async {
    await fetchCardProducts();
    if (cardProducts.isNotEmpty) {
      await fetchIrrWallets();
      await selectCreationOption('product:${cardProducts.first.id}');
    }
  }

  Future<void> initializeCreationSelection() async {
    if (cardProducts.isNotEmpty) {
      await selectCreationOption('product:${cardProducts.first.id}');
      return;
    }

    final provider = cardProvidersList.firstOrNull;
    if (provider?.code != null) {
      await selectCreationOption('legacy:${provider!.code}');
    }
  }

  Future<void> selectCreationOption(String value) async {
    selectedCreationOption.value = value;

    if (value.startsWith('product:')) {
      final productId = int.tryParse(value.substring('product:'.length));
      final product = cardProducts.firstWhereOrNull(
        (item) => item.id == productId,
      );
      if (product == null) return;

      creationMode.value = 'product';
      selectCardProduct(product);
      cardProviderController.text = product.name ?? product.code ?? '';
      return;
    }

    if (!value.startsWith('legacy:')) return;
    final providerCode = value.substring('legacy:'.length);
    final provider = cardProvidersList.firstWhereOrNull(
      (item) => item.code == providerCode,
    );
    if (provider == null) return;

    creationMode.value = 'legacy';
    selectedTab.value = true;
    selectedCardProvider.value = provider;
    cardProviderController.text = provider.name ?? provider.code ?? '';
    cardHolderList.clear();
    cardHolderController.clear();
    selectedCardHolder.value = null;
    await fetchCardHolders();
  }

  void selectCardProduct(CardProductData product) {
    selectedCardProduct.value = product;
    requestPhysical.value = false;
    _syncApplicationFields();

    final capabilities = product.capabilities;
    if (capabilities?.canFundFromIrrWallet == true) {
      fundingSource.value = 'irr_wallet';
    } else {
      fundingSource.value = 'gateway';
    }
    selectedGateway.value = product.gateways.firstOrNull;
    gatewayController.text = _gatewayDisplayText(selectedGateway.value);
  }

  void _syncApplicationFields() {
    final fields = selectedCardProduct.value?.applicationFields ?? [];
    final names = fields.map((field) => field.name).toSet();

    applicationFieldControllers.removeWhere((name, controller) {
      if (names.contains(name)) return false;
      controller.dispose();
      return true;
    });
    applicationBooleanValues.removeWhere((name, _) => !names.contains(name));

    for (final field in fields) {
      if (field.type == 'boolean') {
        applicationBooleanValues.putIfAbsent(field.name, () => false.obs);
      } else {
        applicationFieldControllers.putIfAbsent(
          field.name,
          TextEditingController.new,
        );
      }
    }
  }

  Future<void> fetchIrrWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );
      if (response.status != Status.completed) return;

      final model = WalletsModel.fromJson(response.data!);
      irrWallets.assignAll(
        (model.data?.wallets ?? []).where(
          (wallet) => wallet.code?.toUpperCase() == 'IRR',
        ),
      );
      selectedIrrWallet.value = irrWallets.firstOrNull;
      irrWalletController.text = _walletDisplayText(selectedIrrWallet.value);
    } catch (e, stackTrace) {
      debugPrint('❌ fetchIrrWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  void selectFundingSource(String source) {
    fundingSource.value = source;
  }

  void selectIrrWallet(Wallets wallet) {
    selectedIrrWallet.value = wallet;
    irrWalletController.text = _walletDisplayText(wallet);
  }

  void clearIrrWallet() {
    selectedIrrWallet.value = null;
    irrWalletController.clear();
  }

  void selectGateway(CardGatewayData gateway) {
    selectedGateway.value = gateway;
    gatewayController.text = _gatewayDisplayText(gateway);
  }

  void clearGateway() {
    selectedGateway.value = null;
    gatewayController.clear();
  }

  String _walletDisplayText(Wallets? wallet) {
    if (wallet == null) return '';
    return '${wallet.name ?? 'IRR'} - '
        '${wallet.formattedBalance ?? wallet.balance ?? '0'}';
  }

  String _gatewayDisplayText(CardGatewayData? gateway) {
    return gateway?.name ?? gateway?.gatewayCode ?? '';
  }

  Future<void> createIrrCard() async {
    if (!validateIrrCardFields()) return;

    isCreateVirtualCardLoading.value = true;
    try {
      final product = selectedCardProduct.value!;
      final amount = int.parse(amountController.text.replaceAll(',', ''));
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.postCardOrdersEndpoint,
        data: {
          'card_product_id': product.id,
          'funding_source': fundingSource.value,
          'wallet_id': fundingSource.value == 'irr_wallet'
              ? selectedIrrWallet.value?.id
              : null,
          'gateway_method_id': fundingSource.value == 'gateway'
              ? selectedGateway.value?.id
              : null,
          'amount': amount,
          'request_physical': requestPhysical.value,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone_number': phoneNumberController.text.trim(),
          'address': addressController.text.trim(),
          'country': selectedCountry.value?.code,
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'postal_code': postalCodeController.text.trim(),
          'application_data': _applicationData(product.applicationFields),
        },
      );
      if (response.status != Status.completed) return;

      final responseData = response.data!['data'];
      final data = responseData is Map
          ? responseData.cast<String, dynamic>()
          : <String, dynamic>{};
      final redirectUrl = data['redirect_url']?.toString();
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        await Get.to<Map<String, dynamic>>(
          () => WebViewScreen(paymentUrl: redirectUrl),
        );
      }

      await Get.find<VirtualCardController>().fetchVirtualCards();
      final initialOrderData = data['order'];
      final initialOrder = initialOrderData is Map
          ? initialOrderData.cast<String, dynamic>()
          : <String, dynamic>{};
      final orderId = initialOrder['id']?.toString();
      final order = orderId == null
          ? initialOrder
          : await _fetchCardOrder(orderId) ?? initialOrder;
      final status = order['status']?.toString().toLowerCase() ?? '';
      final failureMessage = order['failure_message']?.toString();
      if (status == 'provisioning_failed' ||
          status == 'failed' ||
          status == 'cancelled') {
        ToastHelper().showErrorToast(
          failureMessage ?? 'The card order could not be completed.',
        );
        return;
      }

      ToastHelper().showSuccessToast(
        response.data!['message']?.toString() ??
            _cardOrderStatusMessage(status),
      );
      clearFields();
      Get.back();
    } catch (e, stackTrace) {
      debugPrint('❌ createIrrCard() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isCreateVirtualCardLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchCardOrder(String orderId) async {
    final response = await Get.find<NetworkService>().get(
      endpoint: '${ApiPath.getCardOrdersEndpoint}/$orderId',
    );
    if (response.status != Status.completed) return null;

    final responseData = response.data!['data'];
    if (responseData is! Map) return null;
    final data = responseData.cast<String, dynamic>();
    final orderData = data['order'];
    return orderData is Map
        ? orderData.cast<String, dynamic>()
        : data;
  }

  Map<String, dynamic> _applicationData(
    List<CardApplicationField> fields,
  ) {
    return {
      for (final field in fields)
        field.name: switch (field.type) {
          'boolean' => applicationBooleanValues[field.name]?.value ?? false,
          'number' =>
            num.tryParse(
              applicationFieldControllers[field.name]?.text.trim() ?? '',
            ),
          _ => applicationFieldControllers[field.name]?.text.trim() ?? '',
        },
    };
  }

  bool validateIrrCardFields() {
    final product = selectedCardProduct.value;
    if (product == null) {
      ToastHelper().showErrorToast('Card product is unavailable.');
      return false;
    }

    final amount = int.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ToastHelper().showErrorToast('Enter a valid amount in Iranian rials.');
      return false;
    }
    if (product.minimumInitialLoad > 0 &&
        amount < product.minimumInitialLoad) {
      ToastHelper().showErrorToast(
        'The minimum initial load is ${product.minimumInitialLoad} IRR.',
      );
      return false;
    }
    if (product.maximumInitialLoad > 0 &&
        amount > product.maximumInitialLoad) {
      ToastHelper().showErrorToast(
        'The maximum initial load is ${product.maximumInitialLoad} IRR.',
      );
      return false;
    }
    if (fundingSource.value == 'irr_wallet' &&
        selectedIrrWallet.value == null) {
      ToastHelper().showErrorToast('Select an IRR wallet.');
      return false;
    }
    if (fundingSource.value == 'gateway' && selectedGateway.value == null) {
      ToastHelper().showErrorToast('Select a payment gateway.');
      return false;
    }
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty ||
        selectedCountry.value?.code == null ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        postalCodeController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ToastHelper().showErrorToast('Complete the cardholder information.');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      ToastHelper().showErrorToast(localization!.createEmailInvalid);
      return false;
    }

    for (final field in product.applicationFields) {
      if (!field.required || field.type == 'boolean') continue;
      final value = applicationFieldControllers[field.name]?.text.trim() ?? '';
      if (value.isEmpty) {
        ToastHelper().showErrorToast('${field.label} is required.');
        return false;
      }
      if (field.type == 'number' && num.tryParse(value) == null) {
        ToastHelper().showErrorToast('${field.label} must be a number.');
        return false;
      }
    }
    return true;
  }

  String _cardOrderStatusMessage(String status) {
    return switch (status) {
      'payment_pending' => 'Card order created and awaiting payment.',
      'pending' || 'provisioning' => 'Card provisioning is in progress.',
      'active' || 'completed' => 'Your card is ready.',
      _ => 'Card order created.',
    };
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

    amountController.clear();
    irrWalletController.text = _walletDisplayText(selectedIrrWallet.value);
    gatewayController.text = _gatewayDisplayText(selectedGateway.value);
    requestPhysical.value = false;
    for (final controller in applicationFieldControllers.values) {
      controller.clear();
    }
    for (final value in applicationBooleanValues.values) {
      value.value = false;
    }
  }
}
