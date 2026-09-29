import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/stock_models.dart';
import '../services/stock_service.dart';

class StockController extends GetxController {
  final StockService _service = Get.put(StockService());

  final RxList<StockMarketModel> markets = <StockMarketModel>[].obs;
  final Rx<StockMarketModel?> selectedMarket = Rx<StockMarketModel?>(null);
  final Rx<StockSymbolModel?> selectedSymbol = Rx<StockSymbolModel?>(null);

  final Rx<StockTradingAccountModel?> account = Rx<StockTradingAccountModel?>(null);
  final RxMap<String, dynamic> portfolioData = <String, dynamic>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isOrderLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Order Sheet State
  final RxString orderSide = 'BUY'.obs;
  final RxString orderType = 'MARKET'.obs;
  final RxDouble quantity = 1.0.obs;
  final RxString payCurrency = 'IRR'.obs;
  final RxDouble calculatedPayAmount = 0.0.obs;
  final RxDouble calculatedFxRate = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final marketsList = await _service.getMarkets();
      markets.value = marketsList;
      if (markets.isNotEmpty) {
        selectedMarket.value = markets.first;
      }

      account.value = await _service.getAccount();
      final pData = await _service.getPortfolio();
      if (pData != null) {
        portfolioData.value = pData;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectMarket(StockMarketModel m) {
    selectedMarket.value = m;
  }

  Future<void> updateFxCalculation() async {
    if (selectedSymbol.value == null || selectedMarket.value == null) return;

    final sym = selectedSymbol.value!;
    final mkt = selectedMarket.value!;
    final totalMarketCurrency = sym.lastPrice * quantity.value;

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
      }
    } catch (_) {
      calculatedPayAmount.value = totalMarketCurrency;
    }
  }

  Future<bool> submitOrder({bool acknowledgedRisk = false}) async {
    if (selectedSymbol.value == null) return false;

    isOrderLoading.value = true;
    errorMessage.value = '';
    try {
      final order = await _service.placeOrder(
        symbolId: selectedSymbol.value!.id,
        side: orderSide.value,
        qty: quantity.value,
        payCurrency: payCurrency.value,
        type: orderType.value,
        acknowledgedRisk: acknowledgedRisk,
      );

      if (order != null) {
        // Refresh account and portfolio
        account.value = await _service.getAccount();
        final pData = await _service.getPortfolio();
        if (pData != null) portfolioData.value = pData;
        return true;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isOrderLoading.value = false;
    }
    return false;
  }

  Future<void> submitRiskQuiz(Map<String, String> answers) async {
    isOrderLoading.value = true;
    try {
      final res = await _service.submitRiskQuiz(answers);
      if (res != null) {
        account.value = await _service.getAccount();
      }
    } finally {
      isOrderLoading.value = false;
    }
  }
}