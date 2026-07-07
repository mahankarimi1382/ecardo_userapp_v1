import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_categories_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_country_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_product_details_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_product_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_success_section.dart';

class GiftCardController extends GetxController {
  // Global Variables
  final RxBool isGiftCardLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isGiftCardLoadingMore = false.obs;
  final RxBool isGiftCardDetailsLoading = false.obs;
  final RxBool isBuyNowGiftCardLoading = false.obs;
  final RxInt selectedScreen = 0.obs;
  final RxInt selectedAmount = 0.obs;
  final RxInt count = 1.obs;
  final Rxn<Map<String, dynamic>> successGiftCardOrderData =
      Rxn<Map<String, dynamic>>();
  final localization = AppLocalizations.of(Get.context!);

  // Gift Card Products
  final Rx<GiftCardProductModel> giftCardProductModel =
      GiftCardProductModel().obs;
  final RxList<Content> giftCardProductList = <Content>[].obs;

  // Gift Card Product Details
  final Rx<GiftCardProductDetailsData> giftCardProductDetails =
      GiftCardProductDetailsData().obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final FocusNode amountFocusNode = FocusNode();
  final amountController = TextEditingController();

  // Email
  final RxBool isEmailFocused = false.obs;
  final FocusNode emailFocusNode = FocusNode();
  final emailController = TextEditingController();

  // Country
  final RxBool isCountryFocused = false.obs;
  final FocusNode countryFocusNode = FocusNode();
  final countryController = TextEditingController();
  final Rx<CountryData> selectedCountry = CountryData().obs;

  // Phone
  final RxBool isPhoneFocused = false.obs;
  final FocusNode phoneFocusNode = FocusNode();
  final phoneController = TextEditingController();

  // Name
  final RxBool isNameFocused = false.obs;
  final FocusNode nameFocusNode = FocusNode();
  final nameController = TextEditingController();

  // Gift Card
  final RxBool isGiftCardFocused = false.obs;
  final FocusNode giftCardFocusNode = FocusNode();
  final giftCardController = TextEditingController();

  // Gift Card Country
  final RxBool isGiftCardCountryFocused = false.obs;
  final FocusNode giftCardCountryFocusNode = FocusNode();
  final giftCardCountryController = TextEditingController();
  final RxList<GiftCardCountryData> giftCardCountryList =
      <GiftCardCountryData>[].obs;
  final Rx<GiftCardCountryData> selectedGiftCardCountry =
      GiftCardCountryData().obs;

  // Gift Card Categories
  final RxBool isGiftCardCategoryFocused = false.obs;
  final FocusNode giftCardCategoryFocusNode = FocusNode();
  final giftCardCategoryController = TextEditingController();
  final RxList<GiftCardCategoriesData> giftCardCategoryList =
      <GiftCardCategoriesData>[].obs;
  final Rx<GiftCardCategoriesData> selectedGiftCardCategory =
      GiftCardCategoriesData().obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      isEmailFocused.value = emailFocusNode.hasFocus;
    });
    countryFocusNode.addListener(() {
      isCountryFocused.value = countryFocusNode.hasFocus;
    });
    phoneFocusNode.addListener(() {
      isPhoneFocused.value = phoneFocusNode.hasFocus;
    });
    nameFocusNode.addListener(() {
      isNameFocused.value = nameFocusNode.hasFocus;
    });
    giftCardFocusNode.addListener(() {
      isGiftCardFocused.value = giftCardFocusNode.hasFocus;
    });
    giftCardCountryFocusNode.addListener(() {
      isGiftCardCountryFocused.value = giftCardCountryFocusNode.hasFocus;
    });
    giftCardCategoryFocusNode.addListener(() {
      isGiftCardCategoryFocused.value = giftCardCategoryFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    amountFocusNode.removeListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    amountFocusNode.dispose();
    amountController.dispose();
    emailFocusNode.removeListener(() {
      isEmailFocused.value = emailFocusNode.hasFocus;
    });
    emailFocusNode.dispose();
    emailController.dispose();
    countryFocusNode.removeListener(() {
      isCountryFocused.value = countryFocusNode.hasFocus;
    });
    countryFocusNode.dispose();
    countryController.dispose();
    phoneFocusNode.removeListener(() {
      isPhoneFocused.value = phoneFocusNode.hasFocus;
    });
    phoneFocusNode.dispose();
    phoneController.dispose();
    nameFocusNode.removeListener(() {
      isNameFocused.value = nameFocusNode.hasFocus;
    });
    nameFocusNode.dispose();
    nameController.dispose();
    giftCardFocusNode.removeListener(() {
      isGiftCardFocused.value = giftCardFocusNode.hasFocus;
    });
    giftCardFocusNode.dispose();
    giftCardController.dispose();
    giftCardCountryFocusNode.removeListener(() {
      isGiftCardCountryFocused.value = giftCardCountryFocusNode.hasFocus;
    });
    giftCardCountryFocusNode.dispose();
    giftCardCountryController.dispose();
    giftCardCategoryFocusNode.removeListener(() {
      isGiftCardCategoryFocused.value = giftCardCategoryFocusNode.hasFocus;
    });
    giftCardCategoryFocusNode.dispose();
    giftCardCategoryController.dispose();

    super.onClose();
  }

  // Get Gift Card Products
  Future<void> getGiftCardProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      resetPagination();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (currentPage.value == 1) {
      isGiftCardLoading.value = true;
    } else {
      isGiftCardLoadingMore.value = true;
    }

    try {
      final queryParams = _buildQueryParameters();
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getGiftCardProductsEndpoint}?$queryParams",
      );

      if (response.status == Status.completed) {
        final model = GiftCardProductModel.fromJson(response.data!);
        final newGiftCardProductList = model.data?.content ?? [];

        if (isRefresh) {
          giftCardProductList.clear();
        }
        giftCardProductList.addAll(newGiftCardProductList);
        giftCardProductModel.value = model;

        if (newGiftCardProductList.length < perPage.value) {
          hasMoreData.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getGiftCardProducts() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isGiftCardLoading.value = false;
      isGiftCardLoadingMore.value = false;
    }
  }

  // Load more gift card products
  Future<void> loadMoreGiftCardProducts() async {
    if (!isGiftCardLoadingMore.value && hasMoreData.value) {
      await getGiftCardProducts();
    }
  }

  // Apply filter
  void applyFilter() {
    getGiftCardProducts(isRefresh: true);
    giftCardController.clear();
  }

  // Build query parameters
  String _buildQueryParameters() {
    List<String> params = [
      'page=${currentPage.value}',
      'page_size=${perPage.value}',
    ];

    // Gift card search
    if (giftCardController.text.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(giftCardController.text)}');
    }

    // Country filter
    if (selectedGiftCardCountry.value.isoName != null &&
        selectedGiftCardCountry.value.isoName!.isNotEmpty) {
      params.add('country_code=${selectedGiftCardCountry.value.isoName}');
    }

    // Category filter
    if (selectedGiftCardCategory.value.id != null) {
      params.add('category_id=${selectedGiftCardCategory.value.id}');
    }

    return params.join('&');
  }

  // Get Gift Card Country
  Future<void> getGiftCardCountry() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getGiftCardCountriesEndpoint,
      );
      if (response.status == Status.completed) {
        final giftCardCountryModel = GiftCardCountryModel.fromJson(
          response.data!,
        );
        giftCardCountryList.clear();
        giftCardCountryList.assignAll(giftCardCountryModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getGiftCardCountry() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Get Gift Card Category
  Future<void> getGiftCardCategory() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.getGiftCardCategoriesEndpoint,
      );
      if (response.status == Status.completed) {
        final giftCardCategoryModel = GiftCardCategoriesModel.fromJson(
          response.data!,
        );
        giftCardCategoryList.clear();
        giftCardCategoryList.assignAll(giftCardCategoryModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getGiftCardCategory() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Get Gift Card Product Details
  Future<void> getGiftCardProductDetails({required String giftCardId}) async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getGiftCardProductDetailsEndpoint}/$giftCardId",
      );
      if (response.status == Status.completed) {
        final giftCardProductDetailsModel =
            GiftCardProductDetailsModel.fromJson(response.data!);
        giftCardProductDetails.value = giftCardProductDetailsModel.data!;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getGiftCardProductDetails() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Post Buy Now Gift Card
  Future<void> postBuyNowGiftCard({
    required String productId,
    required String denominationType,
    required String minRecipientDenomination,
    required String maxRecipientDenomination,
    required GiftCardProductDetailsData cardDetails,
  }) async {
    isBuyNowGiftCardLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.postGiftCardOrderEndpoint,
        data: {
          'product_id': productId,
          'unit_price': denominationType == 'FIXED'
              ? selectedAmount.value
              : denominationType == 'RANGE'
              ? amountController.text
              : "",
          'quantity': count.value,
          'recipient_email': emailController.text.trim(),
          'sender_name': nameController.text,
          'phone_number':
              "${selectedCountry.value.dialCode}${phoneController.text}",
          'country_code': selectedCountry.value.code,
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data?["message"]);
        clearData();
        successGiftCardOrderData.value = response.data?['data'];
        Get.off(GiftCardSuccessSection());
      }
    } finally {
      isBuyNowGiftCardLoading.value = false;
    }
  }

  void clearData() {
    amountController.clear();
    emailController.clear();
    countryController.clear();
    phoneController.clear();
    nameController.clear();
    selectedCountry.value = CountryData();
    count.value = 1;
    giftCardProductDetails.value = GiftCardProductDetailsData();
  }

  // Validate Amount Step
  bool validateAmountStep({
    required String denominationType,
    required String minRecipientDenomination,
    required String maxRecipientDenomination,
  }) {
    // Validate Amount
    if (denominationType == 'RANGE' && amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.giftCardAmountRequired);
      return false;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (denominationType == 'RANGE' && amount <= 0) {
      ToastHelper().showErrorToast(localization!.giftCardAmountInvalid);
      return false;
    }

    if (denominationType == 'RANGE' &&
        double.tryParse(minRecipientDenomination)! > 0 &&
        amount < double.tryParse(minRecipientDenomination)!) {
      ToastHelper().showErrorToast(
        localization!.giftCardAmountMinError(minRecipientDenomination),
      );
      return false;
    }

    if (denominationType == 'RANGE' &&
        double.tryParse(maxRecipientDenomination)! > 0 &&
        amount > double.tryParse(maxRecipientDenomination)!) {
      ToastHelper().showErrorToast(
        localization!.giftCardAmountMaxError(maxRecipientDenomination),
      );
      return false;
    }

    // Validate Email
    if (emailController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.giftCardEmailRequired);
      return false;
    }

    if (emailController.text.isNotEmpty && !emailController.text.isEmail) {
      ToastHelper().showErrorToast(localization!.giftCardEmailInvalid);
      return false;
    }

    // Validate Country
    if (countryController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.giftCardCountryRequired);
      return false;
    }

    // Validate Phone
    if (phoneController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.giftCardPhoneRequired);
      return false;
    }

    // Validate Name
    if (nameController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.giftCardNameRequired);
      return false;
    }

    return true;
  }

  // Unit Price
  double get unitPrice {
    final details = giftCardProductDetails.value;

    final double rate =
        double.tryParse(
          details.recipientCurrencyToSenderCurrencyExchangeRate.toString(),
        ) ??
        0;

    if (rate == 0) return 0;

    // FIXED
    if (details.denominationType == "FIXED") {
      if (selectedAmount.value <= 0) return 0;
      return selectedAmount.value * rate;
    }

    // RANGE
    if (details.denominationType == "RANGE") {
      final double amount = double.tryParse(amountController.text.trim()) ?? 0;
      if (amount <= 0) return 0;
      return amount * rate;
    }

    return 0;
  }

  // Sub Total
  double get subTotal {
    if (count.value <= 0) return 0;
    return count.value * unitPrice;
  }

  // Total Fee
  double get totalFee {
    final details = giftCardProductDetails.value;

    final double senderFee = double.tryParse(details.senderFee.toString()) ?? 0;

    final double orderCharge =
        double.tryParse(details.orderCharge.toString()) ?? 0;

    if (count.value <= 0) return 0;

    return (senderFee + orderCharge) * count.value;
  }

  // Total Amount
  double get total {
    return subTotal + totalFee;
  }

  void clearInitialData() {
    // Global Variables
    selectedScreen.value = 0;
    selectedAmount.value = 0;
    count.value = 1;
    successGiftCardOrderData.value = null;

    // Gift Card Products
    giftCardProductList.clear();

    // Gift Card Product Details
    giftCardProductDetails.value = GiftCardProductDetailsData();

    // Amount
    isAmountFocused.value = false;
    amountController.clear();

    // Email
    isEmailFocused.value = false;
    emailController.clear();

    // Country
    isCountryFocused.value = false;
    countryController.clear();
    selectedCountry.value = CountryData();

    // Phone
    isPhoneFocused.value = false;
    phoneController.clear();

    // Name
    isNameFocused.value = false;
    nameController.clear();

    // Gift Card
    isGiftCardFocused.value = false;
    giftCardController.clear();

    // Gift Card Country
    isGiftCardCountryFocused.value = false;
    giftCardCountryController.clear();
    selectedGiftCardCountry.value = GiftCardCountryData();

    // Gift Card Category
    isGiftCardCategoryFocused.value = false;
    giftCardCategoryController.clear();
    selectedGiftCardCategory.value = GiftCardCategoriesData();

    // Pagination
    currentPage.value = 1;
    hasMoreData.value = true;
  }

  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
    giftCardProductList.clear();
  }

  void initGiftCardFilterDefaults() {
    final allOption = localization?.giftCardFilterAllOption ?? "All";

    // Gift Card
    giftCardController.clear();

    // Country
    if (giftCardCountryController.text.isEmpty) {
      giftCardCountryController.text = allOption;
    }
    selectedGiftCardCountry.value = GiftCardCountryData();

    // Category
    if (giftCardCategoryController.text.isEmpty) {
      giftCardCategoryController.text = allOption;
    }
    selectedGiftCardCategory.value = GiftCardCategoriesData();
  }
}
