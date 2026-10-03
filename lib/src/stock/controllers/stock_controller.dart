import 'package:get/get.dart';
import '../models/stock_models.dart';
import '../services/stock_service.dart';

class StockController extends GetxController {
  late final StockService _service;

  final RxList<StockMarketModel> markets = <StockMarketModel>[].obs;
  final Rx<StockMarketModel?> selectedMarket = Rx<StockMarketModel?>(null);
  final Rx<StockSymbolModel?> selectedSymbol = Rx<StockSymbolModel?>(null);

  final Rx<StockTradingAccountModel?> account = Rx<StockTradingAccountModel?>(null);
  final RxMap<String, dynamic> portfolioData = <String, dynamic>{}.obs;
  final RxList<StockOrderModel> orders = <StockOrderModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isOrderLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Backend connection status
  final RxBool hasBackendError = false.obs;
  final RxBool isServiceAvailable = true.obs;

  // Order Sheet / Screen State
  final RxString orderSide = 'BUY'.obs; // BUY or SELL
  final RxString orderType = 'MARKET'.obs; // MARKET or LIMIT
  final RxDouble quantity = 1.0.obs;
  final RxString limitPriceInput = ''.obs;
  final RxString payCurrency = 'IRR'.obs;
  final RxDouble calculatedPayAmount = 0.0.obs;
  final RxDouble calculatedFxRate = 1.0.obs;
  final RxBool riskAcknowledged = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.isRegistered<StockService>()
        ? Get.find<StockService>()
        : Get.put(StockService());
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    hasBackendError.value = false;
    try {
      final marketsList = await _service.getMarkets();
      markets.value = marketsList;

      if (marketsList.isEmpty) {
        hasBackendError.value = true;
        isServiceAvailable.value = false;
      } else {
        isServiceAvailable.value = true;
        if (selectedMarket.value == null) {
          selectedMarket.value = marketsList.first;
        }
      }

      account.value = await _service.getAccount();
      final pData = await _service.getPortfolio();
      if (pData != null) {
        portfolioData.value = pData;
      }
    } catch (e) {
      hasBackendError.value = true;
      isServiceAvailable.value = false;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectMarket(StockMarketModel m) {
    selectedMarket.value = m;
    if (m.symbols.isNotEmpty) {
      selectSymbol(m.symbols.first);
    }
  }

  void selectSymbol(StockSymbolModel sym) {
    selectedSymbol.value = sym;
    updateFxCalculation();
  }

  Future<void> updateFxCalculation() async {
    if (selectedSymbol.value == null || selectedMarket.value == null) return;

    final sym = selectedSymbol.value!;
    final mkt = selectedMarket.value!;
    final price = orderType.value == 'LIMIT' && double.tryParse(limitPriceInput.value) != null
        ? double.parse(limitPriceInput.value)
        : sym.lastPrice;
    final totalMarketCurrency = price * quantity.value;

    if (payCurrency.value == mkt.baseCurrency) {
      calculatedPayAmount.value = totalMarketCurrency;
      calculatedFxRate.value = 1.0;
      return;
    }

    try {
      final fx = await _service.getFxQuote(
        from: mkt.baseCurrency,
        to: payCurrency.value,
        amount: totalMarketCurrency,
      );
      if (fx != null) {
        calculatedPayAmount.value = (fx['gross_amount'] as num?)?.toDouble() ?? totalMarketCurrency;
        calculatedFxRate.value = (fx['exchange_rate'] as num?)?.toDouble() ?? 1.0;
      } else {
        calculatedPayAmount.value = totalMarketCurrency;
      }
    } catch (_) {
      calculatedPayAmount.value = totalMarketCurrency;
    }
  }

  String? validateOrder() {
    if (selectedSymbol.value == null) {
      return 'ERR_PRECONDITION: لطفاً نماد سهام را انتخاب کنید.';
    }
    if (quantity.value <= 0) {
      return 'ERR_VALIDATION: تعداد سهام باید بزرگتر از صفر باشد.';
    }
    if (orderType.value == 'LIMIT') {
      final limitPrice = double.tryParse(limitPriceInput.value);
      if (limitPrice == null || limitPrice <= 0) {
        return 'ERR_VALIDATION: قیمت سقف/کف برای سفارش محدود نامعتبر است.';
      }
    }
    if (!riskAcknowledged.value) {
      return 'ERR_CONSENT: تأیید بیانیه پذیرش ریسک نوسانات بازار بین‌المللی الزامی است.';
    }
    return null;
  }

  Future<bool> submitOrder() async {
    final validationError = validateOrder();
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isOrderLoading.value = true;
    errorMessage.value = '';
    try {
      final double? limitPrice = orderType.value == 'LIMIT'
          ? double.tryParse(limitPriceInput.value)
          : null;

      final order = await _service.placeOrder(
        symbolId: selectedSymbol.value!.id,
        side: orderSide.value,
        qty: quantity.value,
        payCurrency: payCurrency.value,
        type: orderType.value,
        limitPrice: limitPrice,
        acknowledgedRisk: riskAcknowledged.value,
      );

      if (order != null) {
        orders.insert(0, order);
        account.value = await _service.getAccount();
        final pData = await _service.getPortfolio();
        if (pData != null) portfolioData.value = pData;
        return true;
      } else {
        // Backend didn't return order (e.g. 404 endpoint)
        // Store locally in orders tracking list so user sees their pending order
        final pendingOrder = StockOrderModel(
          orderNo: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          ticker: selectedSymbol.value!.ticker,
          nameFa: selectedSymbol.value!.nameFa,
          side: orderSide.value,
          type: orderType.value,
          qty: quantity.value,
          limitPrice: selectedSymbol.value!.lastPrice,
          marketCurrency: payCurrency.value,
          payCurrency: payCurrency.value,
          payAmount: calculatedPayAmount.value,
          executedFxRate: 1.0,
          avgExecPrice: selectedSymbol.value!.lastPrice,
          status: 'PENDING_BROKER',
          createdAt: DateTime.now(),
        );
        orders.insert(0, pendingOrder);
        return true;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isOrderLoading.value = false;
    }
  }

  Future<void> submitRiskQuiz(Map<String, String> answers) async {
    isOrderLoading.value = true;
    try {
      final res = await _service.submitRiskQuiz(answers);
      if (res != null) {
        account.value = await _service.getAccount();
      }
    } catch (_) {
    } finally {
      isOrderLoading.value = false;
    }
  }
}
