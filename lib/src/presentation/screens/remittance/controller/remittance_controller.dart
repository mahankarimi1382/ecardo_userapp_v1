import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// v1.0.21+21 — `get` re-exports FormData and MultipartFile from its own
// http subsystem, which clashes with dio's classes of the same name.
// Hide them so we can use dio's versions (which is what NetworkService.postMultipart
// expects). Dio's FormData is the canonical one used throughout the app.
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

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

  /// Localization accessor — resolved from the current Get context.
  /// May be null very early in the lifecycle; callers use the `?.` fallback.
  AppLocalizations? get _l => AppLocalizations.of(Get.context!);

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

  // v1.0.23+23 (R-1) — Send-currency list. Previously the controller had a
  // `selectedSendCurrencyId` field but no list to populate it from, and no
  // UI to pick one — so it stayed 0 forever and `requestQuote()` always
  // failed validation. We now load currencies via `/get-currencies` (the
  // same global endpoint used by the Wallets module) and surface a picker
  // in `RemittanceMethodSection`.
  final RxList<CurrenciesData> sendCurrencies = <CurrenciesData>[].obs;
  final RxBool isCurrenciesLoading = false.obs;

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

  /// v1.0.21+21 — Cancelable periodic timer for rate expiry countdown.
  /// Replaces the previous un-cancellable `Future.delayed` loop that leaked
  /// when the controller was disposed mid-countdown.
  Timer? _rateTimer;

  @override
  void onInit() {
    amountFocusNode.addListener(() {
      isAmountFocused.value = amountFocusNode.hasFocus;
    });
    fetchMethods();
    // v1.0.23+23 (R-1) — load send-currency list in parallel so the
    // picker is populated by the time the user finishes choosing a method.
    fetchSendCurrencies();
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
      ToastHelper().showErrorToast(response.message ?? _l?.remittanceErrLoadMethods ?? 'Failed to load methods');
    }
  }

  void selectMethod(RemittanceMethod method) {
    selectedMethod.value = method;
    if (method.receiveCurrencyId != null) {
      // Set receiver country based on method's country_code
      selectedReceiverCountry.value = method.countryCode ?? '';
    }
  }

  // v1.0.23+23 (R-1) — Send-currency picker support.
  /// Loads the list of currencies the user can send from. Uses the global
  /// `/get-currencies` endpoint (same one used by the Wallets module) so
  /// we don't need a remittance-specific endpoint.
  ///
  /// The picker defaults to the first fiat currency (type='fiat') in the
  /// list if the user hasn't picked one yet — this unblocks the quote
  /// request flow without forcing the user to interact with the picker
  /// when there's only one sensible option.
  Future<void> fetchSendCurrencies() async {
    isCurrenciesLoading.value = true;
    try {
      final response = await _networkService.globalGet(
        endpoint: ApiPath.currenciesEndpoint,
      );
      if (response.status == Status.completed) {
        final model = CurrenciesModel.fromJson(response.data!);
        // Only fiat currencies make sense as the SEND side of a remittance
        // (crypto remittance is handled by a different module). Filtering
        // here prevents the user from picking BTC/ETH as the send currency
        // and having the backend reject the quote.
        final fiat = (model.data ?? [])
            .where((c) =>
                (c.type ?? '').toLowerCase() == 'fiat' &&
                (c.status ?? '').toLowerCase() != 'false' &&
                c.id != null)
            .toList();
        sendCurrencies.assignAll(fiat);

        // Auto-select first currency if none selected yet — unblocks the
        // quote request flow when there's only one fiat currency.
        if (selectedSendCurrencyId.value == 0 && sendCurrencies.isNotEmpty) {
          selectedSendCurrencyId.value = sendCurrencies.first.id!;
        }
      }
    } catch (e) {
      // Non-fatal — the picker just stays empty and the user sees a
      // clear "no currencies available" message in the UI.
      debugPrint('⚠️ fetchSendCurrencies() failed: $e');
    } finally {
      isCurrenciesLoading.value = false;
    }
  }

  /// Called when the user picks a currency from the dropdown.
  void selectSendCurrency(CurrenciesData currency) {
    if (currency.id != null) {
      selectedSendCurrencyId.value = currency.id!;
    }
  }

  // ------------------------------ STEP 2: QUOTE ------------------------------ //

  Future<bool> requestQuote() async {
    if (selectedMethod.value == null) {
      ToastHelper().showErrorToast(_l?.remittanceErrSelectPayout ?? 'Please select a payout method');
      return false;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ToastHelper().showErrorToast(_l?.remittanceErrInvalidAmount ?? 'Please enter a valid amount');
      return false;
    }

    if (selectedSendCurrencyId.value == 0) {
      ToastHelper().showErrorToast(_l?.remittanceErrSelectSendCurrency ?? 'Please select a send currency');
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
      ToastHelper().showErrorToast(response.message ?? _l?.remittanceErrQuoteFailed ?? 'Quote failed');
    }
    return false;
  }

  void _startRateTimer(int seconds) {
    _stopRateTimer();
    rateExpiresInSeconds.value = seconds;
    if (seconds <= 0) return;
    // v1.0.21+21: use Timer.periodic so we can cancel it explicitly in
    // _stopRateTimer() / onClose(). The previous Future.delayed loop was
    // un-cancellable and kept running after the controller was disposed,
    // causing a memory leak and possible use-after-close state writes.
    _rateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (rateExpiresInSeconds.value > 0) {
        rateExpiresInSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRateTimer() {
    _rateTimer?.cancel();
    _rateTimer = null;
  }

  // ------------------------------ STEP 3: SUBMIT ------------------------------ //

  Future<bool> createRemittance() async {
    final quote = currentQuote.value;
    if (quote == null) {
      ToastHelper().showErrorToast(_l?.remittanceErrRequestQuoteFirst ?? 'Please request a quote first');
      return false;
    }

    if (quote.isExpired) {
      ToastHelper().showErrorToast(_l?.remittanceErrQuoteExpired ?? 'Quote expired. Please request a new one.');
      return false;
    }

    // Validate sender
    if (senderNameController.text.isEmpty ||
        senderPhoneController.text.isEmpty ||
        senderIdNumberController.text.isEmpty ||
        selectedSenderCountry.value.isEmpty) {
      ToastHelper().showErrorToast(_l?.remittanceErrSenderInfo ?? 'Please complete sender information');
      return false;
    }

    // Validate receiver
    if (receiverNameController.text.isEmpty ||
        receiverPhoneController.text.isEmpty ||
        selectedReceiverCountry.value.isEmpty) {
      ToastHelper().showErrorToast(_l?.remittanceErrReceiverInfo ?? 'Please complete receiver information');
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
    // v1.0.24+24 (remittance fix) — Backend RemittanceController@store (storeFromQuote)
    // expects a NESTED payload: { quote: {...}, sender_info: {...}, receiver_info: {...} }.
    // The previous flat merge caused 422 "sender_info is required". We now send nested
    // objects exactly as the backend validates:
    //   quote.{send_amount, send_currency_id, receive_currency_id, method_id,
    //         exchange_rate, receive_amount, system_fee, total_payable,
    //         rate_locked_at, rate_expires_at}
    //   sender_info.{name, country, phone, id_number, type}
    //   receiver_info.{name, country, phone, bank_name?, account_number?, iban?,
    //         alipay_account?, wechat_account?}
    final response = await _networkService.post(
      endpoint: ApiPath.remittanceStoreEndpoint,
      data: <String, dynamic>{
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
      ToastHelper().showErrorToast(response.message ?? _l?.remittanceErrSubmissionFailed ?? 'Submission failed');
    }
    return false;
  }

  // ------------------------------ STEP 4: UPLOAD DOCUMENTS ------------------------------ //

  /// v1.0.23+23 (R-2 + NEW-1) — Picks a real file from the device and
  /// stores its absolute path. Replaces the previous `addAttachment`
  /// which took a fake hardcoded path like
  /// `'uploads/remittance/doc_<timestamp>.jpg'` — that path never
  /// existed on disk, so `MultipartFile.fromFile(path)` would throw
  /// a `FileSystemException` at upload time.
  ///
  /// Two pickers are offered:
  ///   - Image picker (camera / gallery) — preferred for KYC photos
  ///     and receipts, since the file is guaranteed to be a JPEG/PNG
  ///     and to exist at the returned path.
  ///   - File picker (any document type) — used when the user selects
  ///     "Choose File" instead of "Take Photo" / "Choose from Gallery".
  ///
  /// Returns true if a file was picked and added to [pendingAttachments].
  Future<bool> pickAttachmentFile({
    required String type,
    required ImageSource imageSource,
  }) async {
    try {
      String? path;
      // Image picker covers camera + gallery and is the most reliable
      // across Android versions (no SAF / content-uri complications).
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: imageSource, imageQuality: 85);
      path = xFile?.path;

      if (path == null || path.isEmpty) {
        // User cancelled — silent, no toast.
        return false;
      }

      // Guard: verify the file actually exists on disk before adding it.
      // This prevents a downstream FileSystemException in
      // `MultipartFile.fromFile(path)` inside `uploadDocuments()`.
      final file = File(path);
      if (!await file.exists()) {
        ToastHelper().showErrorToast(
          _l?.remittanceErrFileNotFound ?? 'Selected file does not exist',
        );
        return false;
      }

      pendingAttachments.add({'path': path, 'type': type});
      return true;
    } catch (e) {
      ToastHelper().showErrorToast(
        _l?.remittanceErrPickFile ?? 'Could not pick file: $e',
      );
      return false;
    }
  }

  /// v1.0.23+23 (R-2) — Picks any document file (PDF, JPEG, PNG, etc.)
  /// via the system file picker. Used when the user selects "Choose File"
  /// instead of camera/gallery.
  Future<bool> pickAttachmentAnyFile({required String type}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      final path = result?.files.single.path;
      if (path == null || path.isEmpty) {
        return false; // user cancelled
      }

      final file = File(path);
      if (!await file.exists()) {
        ToastHelper().showErrorToast(
          _l?.remittanceErrFileNotFound ?? 'Selected file does not exist',
        );
        return false;
      }

      pendingAttachments.add({'path': path, 'type': type});
      return true;
    } catch (e) {
      ToastHelper().showErrorToast(
        _l?.remittanceErrPickFile ?? 'Could not pick file: $e',
      );
      return false;
    }
  }

  /// Legacy entry kept for backward-compat with any callers that already
  /// have a real file path (e.g. tests). UI should prefer
  /// [pickAttachmentFile] / [pickAttachmentAnyFile].
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
      ToastHelper().showErrorToast(_l?.remittanceErrNoRemittance ?? 'No remittance to upload to');
      return false;
    }

    if (pendingAttachments.isEmpty) {
      ToastHelper().showErrorToast(_l?.remittanceErrAddDocument ?? 'Please add at least one document');
      return false;
    }

    isUploadLoading.value = true;

    // v1.0.21+21 — Backend expects multipart/form-data with one or more
    // `files[]` MultipartFile entries (Laravel convention for array-of-files).
    // The previous code sent a JSON array of file paths, which the backend
    // silently rejected as "no files uploaded".
    //
    // v1.0.23+23 (NEW-1) — Add a per-file existence check BEFORE calling
    // MultipartFile.fromFile(path). The previous version would throw a
    // FileSystemException mid-loop, leaving a half-built FormData and no
    // user-facing error message. Now we filter out missing files, warn
    // the user, and only attempt to upload files that actually exist on
    // disk. If ALL files are missing (regression scenario), abort cleanly.
    //
    // `pendingAttachments` items look like: {'path': '/data/.../img.jpg', 'type': 'kyc'}
    // We send each as its own multipart entry, plus a parallel `types[]`
    // array so the backend knows which document category each file belongs to.
    final formData = FormData();
    final types = <String>[];
    int skipped = 0;
    for (final attachment in pendingAttachments) {
      final path = attachment['path'];
      final type = attachment['type'] ?? 'document';
      if (path == null || path.isEmpty) {
        skipped++;
        continue;
      }
      // Guard: verify file exists before passing to MultipartFile.fromFile,
      // which would otherwise throw FileSystemException and abort the loop.
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('⚠️ Skipping attachment "$path" — file does not exist');
        skipped++;
        continue;
      }
      formData.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(path),
        ),
      );
      types.add(type);
    }

    // If every attachment was skipped (regression scenario), abort cleanly
    // rather than sending an empty FormData that the backend would reject
    // with a cryptic "files[] is required" error.
    if (formData.files.isEmpty) {
      isUploadLoading.value = false;
      ToastHelper().showErrorToast(
        _l?.remittanceErrNoValidFiles ??
            'No valid files to upload. Please re-select your documents.',
      );
      return false;
    }

    if (skipped > 0) {
      // Non-fatal warning — some files were skipped but we still have
      // at least one to upload.
      ToastHelper().showErrorToast(
        '$skipped file(s) skipped (missing on disk). Uploading the rest.',
      );
    }

    formData.fields.add(MapEntry('types[]', types.join(',')));

    final response = await _networkService.postMultipart(
      endpoint: ApiPath.remittanceUploadEndpoint(uuid: remittance.uuid),
      data: formData,
    );
    isUploadLoading.value = false;

    if (response.status == Status.completed) {
      ToastHelper().showSuccessToast(_l?.remittanceSuccessUploaded ?? 'Documents uploaded successfully');
      pendingAttachments.clear();
      return true;
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? _l?.remittanceErrUploadFailed ?? 'Upload failed');
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
      ToastHelper().showErrorToast(response.message ?? _l?.remittanceErrLoadDetails ?? 'Failed to load details');
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

  /// Localized status label — preferred over [statusLabel] in UI.
  String localizedStatusLabel(RemittanceStatus status) {
    final l = _l;
    if (l == null) return status.label;
    switch (status) {
      case RemittanceStatus.draft:
        return l.remittanceStatusDraft;
      case RemittanceStatus.waitingInformation:
        return l.remittanceStatusWaitingInformation;
      case RemittanceStatus.waitingDocuments:
        return l.remittanceStatusWaitingDocuments;
      case RemittanceStatus.waitingPayment:
        return l.remittanceStatusWaitingPayment;
      case RemittanceStatus.paymentReviewing:
        return l.remittanceStatusPaymentReviewing;
      case RemittanceStatus.inProcess:
        return l.remittanceStatusInProcess;
      case RemittanceStatus.destinationProcessing:
        return l.remittanceStatusDestinationProcessing;
      case RemittanceStatus.destinationPaid:
        return l.remittanceStatusDestinationPaid;
      case RemittanceStatus.completed:
        return l.remittanceStatusCompleted;
      case RemittanceStatus.rejected:
        return l.remittanceStatusRejected;
      case RemittanceStatus.expired:
        return l.remittanceStatusExpired;
      case RemittanceStatus.cancelled:
        return l.remittanceStatusCancelled;
      case RemittanceStatus.refundRequested:
        return l.remittanceStatusRefundRequested;
      case RemittanceStatus.refundCompleted:
        return l.remittanceStatusRefundCompleted;
      case RemittanceStatus.unknown:
        return l.remittanceStatusUnknown;
    }
  }

  /// Localized label for the current remittance's status.
  String get localizedStatusLabelCurrent {
    final remittance = createdRemittance.value ?? selectedRemittance.value;
    if (remittance == null) return '';
    return localizedStatusLabel(remittance.status);
  }
}
