import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/bill_countries_model.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/pay_bill_service_model.dart';

class AirtimeController extends GetxController {
  // Variables
  final RxBool isLoading = false.obs;
  final RxBool isPayBillServiceLoading = false.obs;
  final RxBool isSubmitLoading = false.obs;
  final RxDouble payableAmount = 0.0.obs;
  final RxString chargeText = "".obs;
  final RxString rateText = "".obs;
  final localization = AppLocalizations.of(Get.context!);

  // Stepper
  final RxInt currentStep = 0.obs;

  // Steps
  final List<String> steps = ['Amount', 'Review'];

  // Country
  final RxBool isCountryFocused = false.obs;
  final FocusNode countryFocusNode = FocusNode();
  final countryController = TextEditingController();
  final Rx<BillCountriesModel> billCountriesModel = BillCountriesModel().obs;

  // Service
  final RxBool isServiceFocused = false.obs;
  final FocusNode serviceFocusNode = FocusNode();
  final serviceController = TextEditingController();
  final Rxn<PayBillServiceData> serviceData = Rxn<PayBillServiceData>();
  final RxList<PayBillServiceData> payBillServiceList =
      <PayBillServiceData>[].obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final FocusNode amountFocusNode = FocusNode();
  final RxString amountText = "".obs;
  final amountController = TextEditingController();

  // Dynamic Fields
  final RxBool isDynamicFieldFocused = false.obs;
  final FocusNode dynamicFieldsFocusNode = FocusNode();
  final RxMap<String, TextEditingController> dynamicFieldControllers =
      <String, TextEditingController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    countryFocusNode.addListener(() {
      isCountryFocused.value = countryFocusNode.hasFocus;
    });
    serviceFocusNode.addListener(() {
      isServiceFocused.value = serviceFocusNode.hasFocus;
    });
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    dynamicFieldsFocusNode.addListener(() {
      isDynamicFieldFocused.value = dynamicFieldsFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    super.onClose();
    countryFocusNode.dispose();
    countryController.dispose();
    serviceFocusNode.dispose();
    serviceController.dispose();
    amountFocusNode.dispose();
    amountController.dispose();
    dynamicFieldsFocusNode.dispose();
  }

  // Fetch Bill Countries
  Future<void> fetchBillCountries() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.getBillCountriesEndpoint}/airtime",
      );

      if (response.status == Status.completed) {
        billCountriesModel.value = BillCountriesModel();
        billCountriesModel.value = BillCountriesModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Pay Bill Services
  Future<void> fetchPayBillServices() async {
    isPayBillServiceLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.getPayBillServicesEndpoint}/${countryController.text}/airtime",
      );
      if (response.status == Status.completed) {
        final payBillServiceModel = PayBillServiceModel.fromJson(
          response.data!,
        );
        payBillServiceList.clear();
        payBillServiceList.assignAll(payBillServiceModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchPayBillServices() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isPayBillServiceLoading.value = false;
    }
  }

  Future<void> submitPayBill() async {
    isSubmitLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "service_id": serviceData.value!.id.toString(),
        "amount": amountText.value,
        "data": [
          dynamicFieldControllers.map(
            (key, controller) => MapEntry(key, controller.text),
          ),
        ],
      };
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.payBillEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        resetFields();
      }
    } finally {
      isSubmitLoading.value = false;
    }
  }

  void setupDynamicFields(List<String>? fields) {
    dynamicFieldControllers.forEach((key, controller) => controller.dispose());
    dynamicFieldControllers.clear();
    if (fields != null) {
      for (var field in fields) {
        dynamicFieldControllers[field] = TextEditingController();
      }
    }
  }

  // Next Step Function
  void nextStepWithValidation() {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      reviewCalculate();
    } else {
      currentStep.value = 0;
    }
  }

  // Validate Form
  bool validateAmountStep() {
    // Validate Country
    if (countryController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.airtimeCountryRequired);
      return false;
    }

    // Validate Service
    if (serviceController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.airtimeServiceRequired);
      return false;
    }

    // Validate Amount
    if (amountText.value.isEmpty && amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.airtimeAmountRequired);
      return false;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      ToastHelper().showErrorToast(localization!.airtimeAmountValid);
      return false;
    }

    // Validate Dynamic Fields
    for (var entry in dynamicFieldControllers.entries) {
      final fieldName = entry.key;
      final fieldData = entry.value;

      if (fieldData.text.trim().isEmpty) {
        ToastHelper().showErrorToast(
          localization!.airtimeDynamicFieldRequired(fieldName),
        );
        return false;
      }
    }

    return true;
  }

  void reviewCalculate() {
    final settings = Get.find<SettingsService>();
    final int decimals =
        int.tryParse(
          settings.getSetting("site_currency_decimals")?.toString() ?? "2",
        ) ??
        2;
    final String currency =
        settings.getSetting("site_currency")?.toString() ?? "";
    final amount = double.tryParse(amountController.text) ?? 0.0;

    double charge;
    if (serviceData.value!.chargeType == 'fixed') {
      charge = serviceData.value!.charge!.toDouble();
    } else {
      charge = (amount / 100) * (serviceData.value!.charge!.toDouble());
    }
    final payable = serviceData.value!.rate! > 0
        ? ((amount / serviceData.value!.rate!) + charge)
        : 0.0;
    payableAmount.value = payable;
    chargeText.value = '${charge.toStringAsFixed(decimals)} $currency';
    rateText.value =
        '1 $currency = ${serviceData.value!.rate!.toInt()} ${serviceData.value!.currency}';
  }

  void resetFields() {
    // Variables
    payableAmount.value = 0.0;
    chargeText.value = "";
    rateText.value = "";

    // Stepper
    currentStep.value = 0;

    // Country
    isCountryFocused.value = false;
    countryController.clear();
    billCountriesModel.value = BillCountriesModel();

    // Service
    isServiceFocused.value = false;
    serviceController.clear();
    serviceData.value = null;
    payBillServiceList.clear();

    // Amount
    isAmountFocused.value = false;
    amountText.value = "";
    amountController.clear();

    // Dynamic Fields
    isDynamicFieldFocused.value = false;
    dynamicFieldControllers.clear();
  }
}
