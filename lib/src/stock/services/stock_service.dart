import 'package:ecardo_user/src/network/response/status.dart';
import 'package:get/get.dart' as getx;
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/stock_models.dart';

class StockService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Fetch 6 fixed risk assessment questions
  Future<List<Map<String, dynamic>>> getRiskQuestions() async {
    final response = await _network.get(endpoint: '/stock/risk-quiz');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['questions'] as List?;
      if (list != null) {
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return [];
  }

  /// Submit risk assessment quiz answers
  Future<Map<String, dynamic>?> submitRiskQuiz(Map<String, String> answers) async {
    final response = await _network.post(endpoint: '/stock/risk-quiz', data: {'answers': answers});
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Get user's trading account & balances
  Future<StockTradingAccountModel?> getAccount() async {
    final response = await _network.get(endpoint: '/stock/account');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return StockTradingAccountModel.fromJson(data);
      }
    }
    return null;
  }

  /// List all international markets
  Future<List<StockMarketModel>> getMarkets() async {
    final response = await _network.get(endpoint: '/stock/markets');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data'] as List?;
      if (list != null) {
        return list.map((e) => StockMarketModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// Get live FX conversion quote
  Future<Map<String, dynamic>?> getFxQuote({
    required String from,
    required String to,
    required double amount,
  }) async {
    final response = await _network.get(endpoint: '/stock/fx-quote?from=$from&to=$to&amount=$amount');
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Place buy / sell stock order
  Future<StockOrderModel?> placeOrder({
    required dynamic symbolId,
    required String side,
    required double qty,
    required String payCurrency,
    String type = 'MARKET',
    double? limitPrice,
    bool acknowledgedRisk = false,
  }) async {
    final response = await _network.post(endpoint: '/stock/orders',
      data: {
        'symbol_id': symbolId,
        'side': side,
        'qty': qty,
        'type': type,
        if (limitPrice != null) 'limit_price': limitPrice,
        'pay_currency': payCurrency,
        'acknowledged_risk': acknowledgedRisk,
      },
    );

    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return StockOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Get user's portfolio holdings
  Future<Map<String, dynamic>?> getPortfolio() async {
    final response = await _network.get(endpoint: '/stock/portfolio');
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }
}