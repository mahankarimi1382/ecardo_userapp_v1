class StockSymbolModel {
  final int id;
  final String ticker;
  final String nameFa;
  final String nameEn;
  final String? industry;
  final double lastPrice;
  final double prevClose;
  final double dayHigh;
  final double dayLow;
  final int volume24h;
  final bool highVolatility;
  final bool isTradeable;

  const StockSymbolModel({
    required this.id,
    required this.ticker,
    required this.nameFa,
    required this.nameEn,
    this.industry,
    required this.lastPrice,
    this.prevClose = 0.0,
    this.dayHigh = 0.0,
    this.dayLow = 0.0,
    this.volume24h = 0,
    this.highVolatility = false,
    this.isTradeable = true,
  });

  double get changePercent {
    if (prevClose <= 0) return 0.0;
    return ((lastPrice - prevClose) / prevClose) * 100;
  }

  String get name => nameFa.isNotEmpty ? nameFa : nameEn;
  double get dailyChangePct => changePercent;

  factory StockSymbolModel.fromJson(Map<String, dynamic> json) {
    return StockSymbolModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ticker: json['ticker']?.toString() ?? '',
      nameFa: json['name_fa']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      industry: json['industry']?.toString(),
      lastPrice: (json['last_price'] is num) ? (json['last_price'] as num).toDouble() : double.tryParse(json['last_price']?.toString() ?? '') ?? 0.0,
      prevClose: (json['prev_close'] is num) ? (json['prev_close'] as num).toDouble() : double.tryParse(json['prev_close']?.toString() ?? '') ?? 0.0,
      dayHigh: (json['day_high'] is num) ? (json['day_high'] as num).toDouble() : 0.0,
      dayLow: (json['day_low'] is num) ? (json['day_low'] as num).toDouble() : 0.0,
      volume24h: (json['volume_24h'] is num) ? (json['volume_24h'] as num).toInt() : 0,
      highVolatility: json['high_volatility'] == true || json['high_volatility'] == 1,
      isTradeable: json['is_tradeable'] != false,
    );
  }
}

class StockMarketModel {
  final int id;
  final String code;
  final String countryCode;
  final String nameFa;
  final String nameEn;
  final String baseCurrency;
  final int settlementDays;
  final double commissionPct;
  final int quotesDelayMin;
  final List<StockSymbolModel> symbols;

  const StockMarketModel({
    required this.id,
    required this.code,
    required this.countryCode,
    required this.nameFa,
    required this.nameEn,
    required this.baseCurrency,
    this.settlementDays = 2,
    this.commissionPct = 0.35,
    this.quotesDelayMin = 15,
    this.symbols = const [],
  });

  String get name => nameFa.isNotEmpty ? nameFa : nameEn;

  factory StockMarketModel.fromJson(Map<String, dynamic> json) {
    final symsRaw = json['symbols'] as List?;
    return StockMarketModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? 'TSE',
      countryCode: json['country_code']?.toString() ?? 'IRN',
      nameFa: json['name_fa']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      baseCurrency: json['base_currency']?.toString() ?? 'IRR',
      settlementDays: (json['settlement_days'] is num) ? (json['settlement_days'] as num).toInt() : 2,
      commissionPct: (json['commission_pct'] is num) ? (json['commission_pct'] as num).toDouble() : 0.35,
      quotesDelayMin: (json['quotes_delay_min'] is num) ? (json['quotes_delay_min'] as num).toInt() : 15,
      symbols: symsRaw != null
          ? symsRaw.map((e) => StockSymbolModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
    );
  }
}

class StockTradingAccountModel {
  final String accountNo;
  final String riskProfile;
  final String riskProfileLabel;
  final String kycStatus;
  final String status;
  final List<Map<String, dynamic>> balances;

  const StockTradingAccountModel({
    required this.accountNo,
    required this.riskProfile,
    required this.riskProfileLabel,
    this.kycStatus = 'VERIFIED',
    this.status = 'ACTIVE',
    this.balances = const [],
  });

  String get accountNumber => accountNo;
  String get riskTier => riskProfile;
  double get totalPortfolioValueUsd {
    if (balances.isEmpty) return 0.0;
    for (final b in balances) {
      if (b['currency'] == 'USD') {
        return (b['amount'] is num) ? (b['amount'] as num).toDouble() : 0.0;
      }
    }
    final first = balances.first;
    return (first['amount'] is num) ? (first['amount'] as num).toDouble() : 0.0;
  }

  factory StockTradingAccountModel.fromJson(Map<String, dynamic> json) {
    final balancesRaw = json['balances'] as List?;
    return StockTradingAccountModel(
      accountNo: json['account_no']?.toString() ?? 'TRD-DEFAULT',
      riskProfile: json['risk_profile']?.toString() ?? 'BALANCED',
      riskProfileLabel: json['risk_profile_label']?.toString() ?? 'متعادل',
      kycStatus: json['kyc_status']?.toString() ?? 'VERIFIED',
      status: json['status']?.toString() ?? 'ACTIVE',
      balances: balancesRaw != null
          ? balancesRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : const [],
    );
  }
}

class StockOrderModel {
  final String orderNo;
  final String ticker;
  final String nameFa;
  final String side; // BUY, SELL
  final String type; // MARKET, LIMIT
  final double qty;
  final double limitPrice;
  final String marketCurrency;
  final String payCurrency;
  final double payAmount;
  final double executedFxRate;
  final double avgExecPrice;
  final String status;
  final String? brokerRef;
  final int settlementDays;
  final DateTime? createdAt;

  const StockOrderModel({
    required this.orderNo,
    required this.ticker,
    required this.nameFa,
    required this.side,
    required this.type,
    required this.qty,
    required this.limitPrice,
    required this.marketCurrency,
    required this.payCurrency,
    required this.payAmount,
    required this.executedFxRate,
    required this.avgExecPrice,
    required this.status,
    this.brokerRef,
    this.settlementDays = 2,
    this.createdAt,
  });

  double get price => avgExecPrice > 0 ? avgExecPrice : limitPrice;
  double get totalAmount => payAmount;
  String get currency => payCurrency;

  factory StockOrderModel.fromJson(Map<String, dynamic> json) {
    return StockOrderModel(
      orderNo: json['order_no']?.toString() ?? '',
      ticker: json['ticker']?.toString() ?? '',
      nameFa: json['name_fa']?.toString() ?? '',
      side: json['side']?.toString() ?? 'BUY',
      type: json['type']?.toString() ?? 'MARKET',
      qty: (json['qty'] is num) ? (json['qty'] as num).toDouble() : 0.0,
      limitPrice: (json['limit_price'] is num) ? (json['limit_price'] as num).toDouble() : 0.0,
      marketCurrency: json['market_currency']?.toString() ?? 'IRR',
      payCurrency: json['pay_currency']?.toString() ?? 'IRR',
      payAmount: (json['pay_amount'] is num) ? (json['pay_amount'] as num).toDouble() : 0.0,
      executedFxRate: (json['executed_fx_rate'] is num) ? (json['executed_fx_rate'] as num).toDouble() : 1.0,
      avgExecPrice: (json['avg_exec_price'] is num) ? (json['avg_exec_price'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? 'SUBMITTED',
      brokerRef: json['broker_ref']?.toString(),
      settlementDays: (json['settlement_days'] is num) ? (json['settlement_days'] as num).toInt() : 2,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}