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
  final String? exchangeCode; // NYSE, NASDAQ, HKEX, LSE, TSE

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
    this.exchangeCode,
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
      exchangeCode: json['exchange_code']?.toString(),
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

/// Stock Order Model representing international equities transactions.
/// Supports MARKET, LIMIT, and STOP_LOSS orders with T+2 settlement.
class StockOrderModel {
  final String orderNo;
  final String ticker;
  final String nameFa;
  final String side; // BUY, SELL
  final String type; // MARKET, LIMIT, STOP_LOSS
  final double qty;
  final double limitPrice;
  final double stopPrice;
  final String marketCurrency;
  final String payCurrency;
  final double payAmount;
  final double executedFxRate;
  final double avgExecPrice;
  final double commissionAmount;
  final String status; // SUBMITTED, PENDING_BROKER, EXECUTED, PARTIALLY_FILLED, CANCELLED, REJECTED
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
    this.stopPrice = 0.0,
    required this.marketCurrency,
    required this.payCurrency,
    required this.payAmount,
    required this.executedFxRate,
    required this.avgExecPrice,
    this.commissionAmount = 0.0,
    required this.status,
    this.brokerRef,
    this.settlementDays = 2,
    this.createdAt,
  });

  double get price => avgExecPrice > 0 ? avgExecPrice : (limitPrice > 0 ? limitPrice : stopPrice);
  double get totalAmount => payAmount;
  String get currency => payCurrency;

  bool get isBuy => side.toUpperCase() == 'BUY';
  bool get isSell => side.toUpperCase() == 'SELL';
  bool get isMarket => type.toUpperCase() == 'MARKET';
  bool get isLimit => type.toUpperCase() == 'LIMIT';
  bool get isStopLoss => type.toUpperCase() == 'STOP_LOSS';

  DateTime get settlementDate {
    final base = createdAt ?? DateTime.now();
    return base.add(Duration(days: settlementDays));
  }

  factory StockOrderModel.fromJson(Map<String, dynamic> json) {
    return StockOrderModel(
      orderNo: json['order_no']?.toString() ?? '',
      ticker: json['ticker']?.toString() ?? '',
      nameFa: json['name_fa']?.toString() ?? '',
      side: json['side']?.toString() ?? 'BUY',
      type: json['type']?.toString() ?? 'MARKET',
      qty: (json['qty'] is num) ? (json['qty'] as num).toDouble() : 0.0,
      limitPrice: (json['limit_price'] is num) ? (json['limit_price'] as num).toDouble() : 0.0,
      stopPrice: (json['stop_price'] is num) ? (json['stop_price'] as num).toDouble() : 0.0,
      marketCurrency: json['market_currency']?.toString() ?? 'IRR',
      payCurrency: json['pay_currency']?.toString() ?? 'IRR',
      payAmount: (json['pay_amount'] is num) ? (json['pay_amount'] as num).toDouble() : 0.0,
      executedFxRate: (json['executed_fx_rate'] is num) ? (json['executed_fx_rate'] as num).toDouble() : 1.0,
      avgExecPrice: (json['avg_exec_price'] is num) ? (json['avg_exec_price'] as num).toDouble() : 0.0,
      commissionAmount: (json['commission_amount'] is num) ? (json['commission_amount'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? 'SUBMITTED',
      brokerRef: json['broker_ref']?.toString(),
      settlementDays: (json['settlement_days'] is num) ? (json['settlement_days'] as num).toInt() : 2,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

/// Model representing a single stock holding in user's portfolio.
class StockHoldingModel {
  final String ticker;
  final String nameFa;
  final String nameEn;
  final double shares;
  final double averageCost; // Average execution purchase price
  final double currentPrice;
  final String currency;
  final String exchangeCode;
  final double realizedPnl;

  const StockHoldingModel({
    required this.ticker,
    required this.nameFa,
    required this.nameEn,
    required this.shares,
    required this.averageCost,
    required this.currentPrice,
    this.currency = 'USD',
    this.exchangeCode = 'NASDAQ',
    this.realizedPnl = 0.0,
  });

  String get name => nameFa.isNotEmpty ? nameFa : nameEn;

  /// Current valuation of the holding in base currency
  double get currentValue => shares * currentPrice;

  /// Total capital invested in this position
  double get costBasis => shares * averageCost;

  /// Unrealized profit or loss in base currency
  double get unrealizedPnl => currentValue - costBasis;

  /// Unrealized profit or loss percentage
  double get unrealizedPnlPercent {
    if (costBasis <= 0) return 0.0;
    return (unrealizedPnl / costBasis) * 100;
  }

  /// Total profit or loss (unrealized + realized)
  double get totalPnl => unrealizedPnl + realizedPnl;

  bool get isProfitable => unrealizedPnl >= 0;

  factory StockHoldingModel.fromJson(Map<String, dynamic> json) {
    return StockHoldingModel(
      ticker: json['ticker']?.toString() ?? '',
      nameFa: json['name_fa']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      shares: (json['shares'] is num) ? (json['shares'] as num).toDouble() : 0.0,
      averageCost: (json['average_cost'] is num) ? (json['average_cost'] as num).toDouble() : 0.0,
      currentPrice: (json['current_price'] is num) ? (json['current_price'] as num).toDouble() : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      exchangeCode: json['exchange_code']?.toString() ?? 'NASDAQ',
      realizedPnl: (json['realized_pnl'] is num) ? (json['realized_pnl'] as num).toDouble() : 0.0,
    );
  }
}

/// Currency exposure breakdown for international multi-currency portfolios.
class CurrencyExposureModel {
  final String currency;
  final double amountInCurrency;
  final double amountInUsd;
  final double percentage; // 0.0 to 100.0

  const CurrencyExposureModel({
    required this.currency,
    required this.amountInCurrency,
    required this.amountInUsd,
    required this.percentage,
  });

  factory CurrencyExposureModel.fromJson(Map<String, dynamic> json) {
    return CurrencyExposureModel(
      currency: json['currency']?.toString() ?? 'USD',
      amountInCurrency: (json['amount_in_currency'] is num) ? (json['amount_in_currency'] as num).toDouble() : 0.0,
      amountInUsd: (json['amount_in_usd'] is num) ? (json['amount_in_usd'] as num).toDouble() : 0.0,
      percentage: (json['percentage'] is num) ? (json['percentage'] as num).toDouble() : 0.0,
    );
  }
}

/// Portfolio summary with comprehensive P&L and currency exposures.
class StockPortfolioSummaryModel {
  final double totalValueUsd;
  final double totalCostBasisUsd;
  final double totalRealizedPnlUsd;
  final List<StockHoldingModel> holdings;
  final List<CurrencyExposureModel> currencyExposures;

  const StockPortfolioSummaryModel({
    required this.totalValueUsd,
    required this.totalCostBasisUsd,
    this.totalRealizedPnlUsd = 0.0,
    this.holdings = const [],
    this.currencyExposures = const [],
  });

  /// Total unrealized profit/loss across all holdings
  double get totalUnrealizedPnlUsd => totalValueUsd - totalCostBasisUsd;

  /// Overall portfolio return percentage
  double get totalReturnPercent {
    if (totalCostBasisUsd <= 0) return 0.0;
    return (totalUnrealizedPnlUsd / totalCostBasisUsd) * 100;
  }

  /// Total P&L including realized and unrealized
  double get netTotalPnlUsd => totalUnrealizedPnlUsd + totalRealizedPnlUsd;

  bool get isPositive => totalUnrealizedPnlUsd >= 0;

  factory StockPortfolioSummaryModel.fromJson(Map<String, dynamic> json) {
    final holdingsRaw = json['holdings'] as List?;
    final exposuresRaw = json['currency_exposures'] as List?;

    return StockPortfolioSummaryModel(
      totalValueUsd: (json['total_value_usd'] is num) ? (json['total_value_usd'] as num).toDouble() : 0.0,
      totalCostBasisUsd: (json['total_cost_basis_usd'] is num) ? (json['total_cost_basis_usd'] as num).toDouble() : 0.0,
      totalRealizedPnlUsd: (json['total_realized_pnl_usd'] is num) ? (json['total_realized_pnl_usd'] as num).toDouble() : 0.0,
      holdings: holdingsRaw != null
          ? holdingsRaw.map((e) => StockHoldingModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
      currencyExposures: exposuresRaw != null
          ? exposuresRaw.map((e) => CurrencyExposureModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
    );
  }
}

/// Compliance Risk Assessment Option.
class RiskQuestionOptionModel {
  final String key;
  final String labelFa;
  final String labelEn;
  final int score;

  const RiskQuestionOptionModel({
    required this.key,
    required this.labelFa,
    required this.labelEn,
    required this.score,
  });

  factory RiskQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return RiskQuestionOptionModel(
      key: json['key']?.toString() ?? '',
      labelFa: json['label_fa']?.toString() ?? '',
      labelEn: json['label_en']?.toString() ?? '',
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
    );
  }
}

/// Mandatory 6-Question Risk Assessment Model for Compliance.
class RiskQuestionModel {
  final String id;
  final String questionFa;
  final String questionEn;
  final String category;
  final List<RiskQuestionOptionModel> options;

  const RiskQuestionModel({
    required this.id,
    required this.questionFa,
    required this.questionEn,
    required this.category,
    required this.options,
  });

  factory RiskQuestionModel.fromJson(Map<String, dynamic> json) {
    final optsRaw = json['options'] as List?;
    return RiskQuestionModel(
      id: json['id']?.toString() ?? '',
      questionFa: json['question_fa']?.toString() ?? '',
      questionEn: json['question_en']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      options: optsRaw != null
          ? optsRaw.map((e) => RiskQuestionOptionModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
    );
  }
}

/// Result of evaluating the 6-question compliance assessment.
class RiskProfileResult {
  final String tier; // CONSERVATIVE, BALANCED, GROWTH, AGGRESSIVE
  final String labelFa;
  final String labelEn;
  final int totalScore;
  final bool isApprovedForTrading;
  final String maxLeverage;

  const RiskProfileResult({
    required this.tier,
    required this.labelFa,
    required this.labelEn,
    required this.totalScore,
    required this.isApprovedForTrading,
    required this.maxLeverage,
  });

  static RiskProfileResult evaluate(int score) {
    if (score >= 80) {
      return const RiskProfileResult(
        tier: 'AGGRESSIVE',
        labelFa: 'جسورانه و پرریسک',
        labelEn: 'Aggressive Growth',
        totalScore: 85,
        isApprovedForTrading: true,
        maxLeverage: '1:5',
      );
    } else if (score >= 55) {
      return const RiskProfileResult(
        tier: 'GROWTH',
        labelFa: 'رشد و بازدهی',
        labelEn: 'Growth Oriented',
        totalScore: 65,
        isApprovedForTrading: true,
        maxLeverage: '1:2',
      );
    } else if (score >= 35) {
      return const RiskProfileResult(
        tier: 'BALANCED',
        labelFa: 'متعادل (توصیه‌شده)',
        labelEn: 'Balanced / Moderate',
        totalScore: 45,
        isApprovedForTrading: true,
        maxLeverage: '1:1',
      );
    } else {
      return const RiskProfileResult(
        tier: 'CONSERVATIVE',
        labelFa: 'محافظه‌کارانه',
        labelEn: 'Conservative',
        totalScore: 25,
        isApprovedForTrading: true,
        maxLeverage: 'Cash Only (1:1)',
      );
    }
  }
}
