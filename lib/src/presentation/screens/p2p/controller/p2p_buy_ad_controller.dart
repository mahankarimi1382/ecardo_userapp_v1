import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/ad_details_response_model.dart'
    as ad_details;
import 'package:qunzo_user/src/presentation/screens/p2p/model/ad_payment_method_response_model.dart'
    as ad_payment_method;
import 'package:qunzo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/p2p_order_details_screen.dart';

class P2pBuyAdController extends GetxController {
  final int adId;
  final bool isSellMode;

  P2pBuyAdController({required this.adId, this.isSellMode = false});

  final RxBool isPageLoading = false.obs;
  final RxBool isPaymentMethodsLoading = false.obs;
  final RxBool isSubmittingOrder = false.obs;
  final Rxn<ad_details.AdDetailsResponseModel> adDetailsResponse =
      Rxn<ad_details.AdDetailsResponseModel>();
  final Rxn<ad_details.Data> adData = Rxn<ad_details.Data>();

  final RxList<AdPaymentOption> paymentOptions = <AdPaymentOption>[].obs;
  final RxnInt selectedPaymentOptionId = RxnInt();

  final TextEditingController payController = TextEditingController();
  final TextEditingController receiveController = TextEditingController();

  bool _isAmountSyncing = false;
  String _lastValidPayText = '';
  String _lastValidReceiveText = '';

  @override
  void onInit() {
    super.onInit();
    fetchAdDetails();
    fetchAdPaymentMethods();
  }

  @override
  void onClose() {
    payController.dispose();
    receiveController.dispose();
    super.onClose();
  }

  String get fiatCode => adData.value?.fiatCurrency?.code ?? '-';
  String get fiatSymbol => adData.value?.fiatCurrency?.symbol ?? '';
  String get assetCode => adData.value?.assetCurrency?.code ?? '-';
  String get assetSymbol => adData.value?.assetCurrency?.symbol ?? '';
  String get adType => adData.value?.adType ?? 'Buy';
  String get primaryCode => isSellMode ? assetCode : fiatCode;
  String get primarySymbol => isSellMode ? assetSymbol : fiatSymbol;
  String get secondaryCode => isSellMode ? fiatCode : assetCode;
  String get secondarySymbol => isSellMode ? fiatSymbol : assetSymbol;
  String get screenActionText => isSellMode ? 'Sell' : 'Buy';
  String get buttonText =>
      '$screenActionText ${assetCode == '-' ? '' : assetCode}'.trim();
  String get firstAmountFieldLabel => isSellMode ? 'You Sell' : 'You Pay';
  bool get isFiatFieldOnPayInput => !isSellMode;
  double? get minOrderLimit =>
      _parseNumericValue(adData.value?.rawOrderLimit?.min);
  double? get maxOrderLimit =>
      _parseNumericValue(adData.value?.rawOrderLimit?.max);

  double get rawPrice {
    final raw = adData.value?.rawPrice ?? '';
    final sanitized = raw.replaceAll(',', '').trim();
    final parsed =
        double.tryParse(sanitized) ??
        double.tryParse(
          RegExp(r'-?\d+(\.\d+)?').firstMatch(sanitized)?.group(0) ?? '',
        );
    return (parsed == null || parsed <= 0) ? 0 : parsed;
  }

  Future<void> fetchAdDetails() async {
    isPageLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.p2pMarketPlaceEndpoint}/$adId',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = ad_details.AdDetailsResponseModel.fromJson(
          response.data!,
        );
        adDetailsResponse.value = model;
        adData.value = model.data;
        if (paymentOptions.isEmpty) {
          _loadPaymentOptionsFromDetailsFallback();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchAdDetails() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to load ad details');
    } finally {
      isPageLoading.value = false;
    }
  }

  Future<void> fetchAdPaymentMethods() async {
    isPaymentMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.adPaymentMethodEndpoint(adId: '$adId'),
      );

      if (response.status != Status.completed || response.data == null) {
        _loadPaymentOptionsFromDetailsFallback();
        return;
      }

      final model = ad_payment_method.AdPaymentMethodResponseModel.fromJson(
        response.data!,
      );
      final methods =
          model.data?.paymentMethods ??
          <ad_payment_method.PaymentMethodElement>[];

      final options = methods
          .map((method) {
            final id = method.paymentMethod?.id ?? method.id ?? 0;
            final name = method.paymentMethod?.name ?? 'Method';
            final fields = method.fields ?? <ad_payment_method.Field>[];
            final accountInfo = fields.isNotEmpty
                ? (fields.first.value ?? '')
                : '';
            return AdPaymentOption(
              id: id,
              name: name,
              accountInfo: accountInfo,
            );
          })
          .where((item) => item.id > 0)
          .toList();

      if (options.isEmpty) {
        _loadPaymentOptionsFromDetailsFallback();
        return;
      }

      paymentOptions
        ..clear()
        ..addAll(options);
      selectedPaymentOptionId.value = paymentOptions.first.id;
    } catch (e, stackTrace) {
      debugPrint('fetchAdPaymentMethods() error: $e');
      debugPrint('StackTrace: $stackTrace');
      _loadPaymentOptionsFromDetailsFallback();
    } finally {
      isPaymentMethodsLoading.value = false;
    }
  }

  void _loadPaymentOptionsFromDetailsFallback() {
    final detailsMethods =
        adData.value?.paymentMethods ?? <ad_details.PaymentMethodElement>[];
    if (detailsMethods.isEmpty) {
      paymentOptions.clear();
      selectedPaymentOptionId.value = null;
      return;
    }

    final fallbackOptions = detailsMethods
        .map((method) {
          final id = method.paymentMethodId ?? method.id ?? 0;
          final name = method.paymentMethod?.name ?? 'Method';
          final fields = method.fields ?? <ad_details.Field>[];
          final accountInfo = fields.isNotEmpty
              ? (fields.first.value ?? '')
              : '';
          return AdPaymentOption(id: id, name: name, accountInfo: accountInfo);
        })
        .where((item) => item.id > 0)
        .toList();

    paymentOptions
      ..clear()
      ..addAll(fallbackOptions);
    selectedPaymentOptionId.value = paymentOptions.isNotEmpty
        ? paymentOptions.first.id
        : null;
  }

  AdPaymentOption? get selectedPaymentOption {
    final selectedId = selectedPaymentOptionId.value;
    if (selectedId == null) return null;
    for (final item in paymentOptions) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  void onPaymentMethodSelected(int id) {
    selectedPaymentOptionId.value = id;
  }

  void onPayAmountChanged(String value) {
    if (_isAmountSyncing) return;
    _isAmountSyncing = true;

    final payAmount = double.tryParse(value.trim()) ?? 0;
    if (payAmount <= 0 || rawPrice <= 0) {
      receiveController.text = '';
      _lastValidPayText = value.trim();
      _lastValidReceiveText = '';
      _isAmountSyncing = false;
      return;
    }

    final receiveAmount = isSellMode
        ? payAmount * rawPrice
        : payAmount / rawPrice;
    final receiveText = _formatAmount(receiveAmount);
    receiveController.text = receiveText;
    _lastValidPayText = value.trim();
    _lastValidReceiveText = receiveText;
    _isAmountSyncing = false;
  }

  void onReceiveAmountChanged(String value) {
    if (_isAmountSyncing) return;
    _isAmountSyncing = true;

    final receiveAmount = double.tryParse(value.trim()) ?? 0;
    if (receiveAmount <= 0 || rawPrice <= 0) {
      payController.text = '';
      _lastValidPayText = '';
      _lastValidReceiveText = value.trim();
      _isAmountSyncing = false;
      return;
    }

    final payAmount = isSellMode
        ? receiveAmount / rawPrice
        : receiveAmount * rawPrice;
    final payText = _formatAmount(payAmount);
    payController.text = payText;
    _lastValidPayText = payText;
    _lastValidReceiveText = value.trim();
    _isAmountSyncing = false;
  }

  String _formatAmount(double value) {
    if (value <= 0) return '0';
    final fixed = value.toStringAsFixed(8);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double? _parseNumericValue(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final sanitized = value.replaceAll(',', '').trim();
    final parsed =
        double.tryParse(sanitized) ??
        double.tryParse(
          RegExp(r'-?\d+(\.\d+)?').firstMatch(sanitized)?.group(0) ?? '',
        );
    return parsed;
  }

  bool _isPayAmountWithinOrderLimit(double payAmount) {
    final min = minOrderLimit;
    final max = maxOrderLimit;

    if (min != null && payAmount < min) return false;
    if (max != null && payAmount > max) return false;
    return true;
  }

  bool validatePayAmountRangeForSubmit() {
    final fiatAmount =
        double.tryParse(
          isFiatFieldOnPayInput
              ? payController.text.trim()
              : receiveController.text.trim(),
        ) ??
        0;

    if (fiatAmount <= 0) {
      ToastHelper().showErrorToast('Please enter amount');
      return false;
    }
    if (!_isPayAmountWithinOrderLimit(fiatAmount)) {
      _restoreLastValidAmountsWithError(showMinMessage: true);
      return false;
    }
    return true;
  }

  void _restoreLastValidAmountsWithError({required bool showMinMessage}) {
    final min = minOrderLimit;
    final max = maxOrderLimit;
    if (showMinMessage && min != null && max != null) {
      ToastHelper().showErrorToast(
        'Amount must be between ${_formatAmount(min)} and ${_formatAmount(max)} ${fiatCode == '-' ? '' : fiatCode}',
      );
    } else if (showMinMessage && min != null) {
      ToastHelper().showErrorToast(
        'Amount must be at least ${_formatAmount(min)} ${fiatCode == '-' ? '' : fiatCode}',
      );
    } else if (max != null) {
      ToastHelper().showErrorToast(
        'Amount must be at most ${_formatAmount(max)} ${fiatCode == '-' ? '' : fiatCode}',
      );
    }

    payController.text = _lastValidPayText;
    payController.selection = TextSelection.fromPosition(
      TextPosition(offset: _lastValidPayText.length),
    );

    receiveController.text = _lastValidReceiveText;
    receiveController.selection = TextSelection.fromPosition(
      TextPosition(offset: _lastValidReceiveText.length),
    );
  }

  String get assetAmountTextForOrder {
    return isSellMode
        ? payController.text.trim()
        : receiveController.text.trim();
  }

  String get fiatAmountTextForOrder {
    return isSellMode
        ? receiveController.text.trim()
        : payController.text.trim();
  }

  Future<void> submitOrderAndOpenDetails() async {
    if (!validatePayAmountRangeForSubmit()) return;
    final selectedMethodId = selectedPaymentOptionId.value;
    if (selectedMethodId == null) {
      ToastHelper().showErrorToast('Please select payment method');
      return;
    }

    final assetAmount = double.tryParse(assetAmountTextForOrder) ?? 0;
    if (assetAmount <= 0) {
      ToastHelper().showErrorToast('Please enter valid asset amount');
      return;
    }

    isSubmittingOrder.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.getMyOrdersEndPoint,
        data: <String, dynamic>{
          'ad_id': adId,
          'asset_amount': assetAmountTextForOrder,
          'fiat_amount': fiatAmountTextForOrder,
          'payment_method_id': selectedMethodId,
        },
      );

      if (response.status != Status.completed || response.data == null) {
        return;
      }

      final model = order_details.OrderDetailsResponseModel.fromJson(
        response.data!,
      );
      final orderId = model.data?.id;
      if (orderId == null) {
        ToastHelper().showErrorToast('Order created but details id missing');
        return;
      }

      Get.to(() => P2pOrderDetailsScreen(orderId: orderId));
    } catch (e, stackTrace) {
      debugPrint('submitOrderAndOpenDetails() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to create order');
    } finally {
      isSubmittingOrder.value = false;
    }
  }
}

class AdPaymentOption {
  final int id;
  final String name;
  final String accountInfo;

  const AdPaymentOption({
    required this.id,
    required this.name,
    required this.accountInfo,
  });

  String get label {
    return name;
  }
}
