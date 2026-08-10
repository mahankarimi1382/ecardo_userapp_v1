import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

/// Controller for the Remittance (international money transfer) module.
///
/// Workflow:
///   1. fetchMethods() — load available payout methods
///   2. requestQuote() — get a rate quote (locked for 15 minutes)
///   3. createRemittance() — submit sender + receiver info
///   4. uploadDocuments() — upload KYC + payment receipt
///   5. trackRemittance() — view status + audit log
///
/// v1.0.4+5 — aligned with backend RemittanceService v3.8
class RemittanceController extends GetxController {
  final NetworkService _networkService = Get.find<NetworkService>();

  // Loading states
  final RxBool isMethodsLoading = false.obs;
  final RxBool isQuoteLoading = false.obs;
  final RxBool isSubmitLoading = false.obs;
  final RxBool isHistoryLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isUploadLoading = false.obs;

  // Data
  final RxList<RemittanceMethod> methods = <RemittanceMethod>[].obs;
  final Rxn<RemittanceQuote> currentQuote = Rxn<RemittanceQuote>();
  final Rxn<Remittance> createdRemittance = Rxn<Remittance>();
  final RxList<Remittance> history = <Remittance>[].obs;
  final Rxn<Remittance> selectedRemittance = Rxn<Remittance>();

  // Form state — Step 1: Method & Amount
  final Rxn<RemittanceMethod> selectedMethod = Rxn<RemittanceMethod>();
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  final RxBool isAmountFocused = false.obs;
  final RxInt selectedSendCurrencyId = 0.obs;

  // Form state — Step 2: Sender Info
  final senderNameController = TextEditingController();
  final senderPhoneController = TextEditingController();
  final senderIdNumberController = TextEditingController();
  final RxString selectedSenderCountry = ''.obs;
  final RxString selectedSenderType = 'individual'.obs; // individual | business

  // Form state — Step 3: Receiver Info
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final receiverBankNameController = TextEditingController();
  final receiverAccountNumberController = TextEditingController();
  final receiverIbanController = TextEditingController();
  final receiverAlipayController = TextEditingController();
  final receiverWechatController = TextEditingController();
  final RxString selectedReceiverCountry = ''.obs;

  // Form state — Documents
  final RxList<Map<String, String>> pendingAttachments =
      <Map<String, String>>[].obs;

  // Stepper
  final RxInt currentStep = 0.obs;
  // 0: Method+Amount, 1: Sender, 2: Receiver, 3: Review, 4: Success
  final int totalSteps = 5;

  // Pagination for history
  final RxInt historyCurrentPage = 1.obs;
  final RxInt historyLastPage = 1.obs;
  final RxBool historyHasMore = false.obs;

  // Rate expiry countdown
  final RxInt rateExpiresInSeconds = 0.obs;
  int? _rateTimerId;

  @override
  void onInit() {
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    fetchMethods();
    super.onInit();
  }

  @override
  void onClose() {
    amountController.dispose();
    amountFocusNode.dispose();
    senderNameController.dispose();
    senderPhoneController.dispose();
    senderIdNumberController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    receiverBankNameController.dispose();
    receiverAccountNumberController.dispose();
    receiverIbanController.dispose();
    receiverAlipayController.dispose();
    receiverWechatController.dispose();
    _stopRateTimer();
    super.onClose();
  }

  // ------------------------------ STEP 1: METHODS ------------------------------ //

  Future<void> fetchMethods() async {
    isMethodsLoading.value = true;
    final response = await _networkService.get(
      endpoint: ApiPath.remittanceMethodsEndpoint,
    );
    isMethodsLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'];
      if (data is List) {
        methods.value = data
            .map((e) => RemittanceMethod.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Failed to load methods');
    }
  }

  void selectMethod(RemittanceMethod method) {
    selectedMethod.value = method;
    if (method.receiveCurrencyId != null) {
      // Set receiver country based on method's country_code
      selectedReceiverCountry.value = method.countryCode ?? '';
    }
  }

  // ------------------------------ STEP 2: QUOTE ------------------------------ //

  Future<bool> requestQuote() async {
    if (selectedMethod.value == null) {
      ToastHelper().showErrorToast('Please select a payout method');
      return false;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ToastHelper().showErrorToast('Please enter a valid amount');
      return false;
    }

    if (selectedSendCurrencyId.value == 0) {
      ToastHelper().showErrorToast('Please select a send currency');
      return false;
    }

    isQuoteLoading.value = true;
    final response = await _networkService.post(
      endpoint: ApiPath.remittanceQuoteEndpoint,
      data: {
        'send_amount': amount,
        'send_currency_id': selectedSendCurrencyId.value,
        'method_id': selectedMethod.value!.id,
      },
    );
    isQuoteLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        currentQuote.value = RemittanceQuote.fromJson(data);
        _startRateTimer(currentQuote.value!.rateExpiresInSeconds);
        return true;
      }
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Quote failed');
    }
    return false;
  }

  void _startRateTimer(int seconds) {
    _stopRateTimer();
    rateExpiresInSeconds.value = seconds;
    // Simple second-by-second countdown
    Future<void> tick() async {
      while (rateExpiresInSeconds.value > 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (!isClosed) {
          rateExpiresInSeconds.value--;
        } else {
          break;
        }
      }
    }
    tick();
  }

  void _stopRateTimer() {
    // The future loop auto-stops when value reaches 0 or controller is closed
  }

  // ------------------------------ STEP 3: SUBMIT ------------------------------ //

  Future<bool> createRemittance() async {
    final quote = currentQuote.value;
    if (quote == null) {
      ToastHelper().showErrorToast('Please request a quote first');
      return false;
    }

    if (quote.isExpired) {
      ToastHelper().showErrorToast('Quote expired. Please request a new one.');
      return false;
    }

    // Validate sender
    if (senderNameController.text.isEmpty ||
        senderPhoneController.text.isEmpty ||
        senderIdNumberController.text.isEmpty ||
        selectedSenderCountry.value.isEmpty) {
      ToastHelper().showErrorToast('Please complete sender information');
      return false;
    }

    // Validate receiver
    if (receiverNameController.text.isEmpty ||
        receiverPhoneController.text.isEmpty ||
        selectedReceiverCountry.value.isEmpty) {
      ToastHelper().showErrorToast('Please complete receiver information');
      return false;
    }

    final sender = RemittanceSenderInfo(
      name: senderNameController.text.trim(),
      country: selectedSenderCountry.value,
      phone: senderPhoneController.text.trim(),
      idNumber: senderIdNumberController.text.trim(),
      type: selectedSenderType.value,
    );

    final receiver = RemittanceReceiverInfo(
      name: receiverNameController.text.trim(),
      country: selectedReceiverCountry.value,
      phone: receiverPhoneController.text.trim(),
      bankName: receiverBankNameController.text.trim().isEmpty
          ? null
          : receiverBankNameController.text.trim(),
      accountNumber: receiverAccountNumberController.text.trim().isEmpty
          ? null
          : receiverAccountNumberController.text.trim(),
      iban: receiverIbanController.text.trim().isEmpty
          ? null
          : receiverIbanController.text.trim(),
      alipayAccount: receiverAlipayController.text.trim().isEmpty
          ? null
          : receiverAlipayController.text.trim(),
      wechatAccount: receiverWechatController.text.trim().isEmpty
          ? null
          : receiverWechatController.text.trim(),
    );

    isSubmitLoading.value = true;
    final response = await _networkService.post(
      endpoint: ApiPath.remittanceStoreEndpoint,
      data: {
        'quote': quote.toJson(),
        'sender_info': sender.toJson(),
        'receiver_info': receiver.toJson(),
      },
    );
    isSubmitLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        createdRemittance.value = Remittance.fromJson(data);
        return true;
      }
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Submission failed');
    }
    return false;
  }

  // ------------------------------ STEP 4: UPLOAD DOCUMENTS ------------------------------ //

  void addAttachment(String path, String type) {
    pendingAttachments.add({'path': path, 'type': type});
  }

  void removeAttachmentAt(int index) {
    if (index >= 0 && index < pendingAttachments.length) {
      pendingAttachments.removeAt(index);
    }
  }

  Future<bool> uploadDocuments() async {
    final remittance = createdRemittance.value;
    if (remittance == null) {
      ToastHelper().showErrorToast('No remittance to upload to');
      return false;
    }

    if (pendingAttachments.isEmpty) {
      ToastHelper().showErrorToast('Please add at least one document');
      return false;
    }

    isUploadLoading.value = true;
    final response = await _networkService.post(
      endpoint: ApiPath.remittanceUploadEndpoint(uuid: remittance.uuid),
      data: {
        'files': pendingAttachments.toList(),
      },
    );
    isUploadLoading.value = false;

    if (response.status == Status.completed) {
      ToastHelper().showSuccessToast('Documents uploaded successfully');
      pendingAttachments.clear();
      return true;
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Upload failed');
    }
    return false;
  }

  // ------------------------------ HISTORY ------------------------------ //

  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      historyCurrentPage.value = 1;
    }
    isHistoryLoading.value = true;

    final response = await _networkService.get(
      endpoint: ApiPath.remittanceHistoryEndpoint,
    );
    isHistoryLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'];
      final meta = response.data?['meta'] ?? {};
      final pagination = meta is Map ? meta['pagination'] : null;

      if (data is List) {
        final items = data
            .map((e) => Remittance.fromJson(e as Map<String, dynamic>))
            .toList();
        if (refresh) {
          history.value = items;
        } else {
          history.addAll(items);
        }
      }

      if (pagination is Map) {
        historyCurrentPage.value = pagination['current_page'] as int? ?? 1;
        historyLastPage.value = pagination['last_page'] as int? ?? 1;
        historyHasMore.value = (pagination['has_more'] as bool?) ?? false;
      }
    }
  }

  Future<void> loadMoreHistory() async {
    if (!historyHasMore.value || isHistoryLoading.value) return;
    historyCurrentPage.value++;
    await fetchHistory();
  }

  // ------------------------------ DETAILS ------------------------------ //

  Future<void> fetchDetails(String uuid) async {
    isDetailsLoading.value = true;
    final response = await _networkService.get(
      endpoint: ApiPath.remittanceShowEndpoint(uuid: uuid),
    );
    isDetailsLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        selectedRemittance.value = Remittance.fromJson(data);
      }
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Failed to load details');
    }
  }

  // ------------------------------ UI HELPERS ------------------------------ //

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void resetForm() {
    currentStep.value = 0;
    currentQuote.value = null;
    createdRemittance.value = null;
    selectedMethod.value = null;
    amountController.clear();
    selectedSendCurrencyId.value = 0;
    senderNameController.clear();
    senderPhoneController.clear();
    senderIdNumberController.clear();
    selectedSenderCountry.value = '';
    selectedSenderType.value = 'individual';
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverBankNameController.clear();
    receiverAccountNumberController.clear();
    receiverIbanController.clear();
    receiverAlipayController.clear();
    receiverWechatController.clear();
    selectedReceiverCountry.value = '';
    pendingAttachments.clear();
    rateExpiresInSeconds.value = 0;
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  String get statusLabel {
    final remittance = createdRemittance.value ?? selectedRemittance.value;
    return remittance?.status.label ?? '';
  }
}
