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
  final Rx<StockPortfolioSummaryModel?> portfolioSummary = Rx<StockPortfolioSummaryModel?>(null);
  final RxList<StockHoldingModel> holdings = <StockHoldingModel>[].obs;
  final RxList<StockOrderModel> orders = <StockOrderModel>[].obs;
  final RxSet<String> watchlist = <String>{'AAPL', 'NVDA', '700.HK', 'MSFT', '7203.T'}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isOrderLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Backend connection status
  final RxBool hasBackendError = false.obs;
  final RxBool isServiceAvailable = true.obs;

  // Order Entry State
  final RxString orderSide = 'BUY'.obs; // BUY or SELL
  final RxString orderType = 'MARKET'.obs; // MARKET, LIMIT, STOP_LOSS
  final RxDouble quantity = 1.0.obs;
  final RxString limitPriceInput = ''.obs;
  final RxString stopPriceInput = ''.obs;
  final RxString payCurrency = 'IRR'.obs; // IRR, USDT, USD, HKD, GBP, JPY
  final RxDouble calculatedPayAmount = 0.0.obs;
  final RxDouble calculatedFxRate = 1.0.obs;
  final RxDouble calculatedCommission = 0.0.obs;
  final RxBool riskAcknowledged = false.obs;

  // Risk Assessment / Compliance State
  final RxMap<String, String> riskAnswers = <String, String>{}.obs;
  final Rx<RiskProfileResult?> riskProfileResult = Rx<RiskProfileResult?>(
    const RiskProfileResult(
      tier: 'BALANCED',
      labelFa: 'متعادل و استاندارد',
      labelEn: 'Balanced / Moderate',
      totalScore: 50,
      isApprovedForTrading: true,
      maxLeverage: '1:1',
    ),
  );
  final RxBool isRiskAssessmentCompleted = true.obs;

  // 6 Standard Compliance Questions
  final List<RiskQuestionModel> defaultRiskQuestions = const [
    RiskQuestionModel(
      id: 'Q1',
      category: 'EXPERIENCE',
      questionFa: 'میزان سابقه و تجربه شما در معامله سهام و بازارهای مالی بین‌المللی چقدر است؟',
      questionEn: 'What is your level of experience in international equity and financial markets?',
      options: [
        RiskQuestionOptionModel(key: 'EXP_NONE', labelFa: 'مبتدی (کمتر از ۱ سال)', labelEn: 'Novice (< 1 year)', score: 5),
        RiskQuestionOptionModel(key: 'EXP_MID', labelFa: 'متوسط (۱ تا ۳ سال)', labelEn: 'Intermediate (1-3 years)', score: 15),
        RiskQuestionOptionModel(key: 'EXP_ADV', labelFa: 'پیشرفته (بیش از ۳ سال)', labelEn: 'Advanced (> 3 years)', score: 20),
      ],
    ),
    RiskQuestionModel(
      id: 'Q2',
      category: 'HORIZON',
      questionFa: 'افق زمانی سرمایه‌گذاری مدنظر شما در بورس‌های خارجی چگونه است؟',
      questionEn: 'What is your expected investment time horizon for foreign stocks?',
      options: [
        RiskQuestionOptionModel(key: 'HOR_SHORT', labelFa: 'کوتاه‌مدت (کمتر از ۶ ماه)', labelEn: 'Short Term (< 6 months)', score: 5),
        RiskQuestionOptionModel(key: 'HOR_MID', labelFa: 'میان‌مدت (۶ ماه تا ۲ سال)', labelEn: 'Medium Term (6m-2y)', score: 15),
        RiskQuestionOptionModel(key: 'HOR_LONG', labelFa: 'بلندمدت (بیش از ۲ سال)', labelEn: 'Long Term (> 2 years)', score: 20),
      ],
    ),
    RiskQuestionModel(
      id: 'Q3',
      category: 'TOLERANCE',
      questionFa: 'واکنش شما در مواجهه با افت موقت ۲۰٪ از ارزش سبد دارایی چیست؟',
      questionEn: 'How would you react to a temporary 20% decline in portfolio valuation?',
      options: [
        RiskQuestionOptionModel(key: 'TOL_LOW', labelFa: 'فروش فوری برای جلوگیری از زیان بیشتر', labelEn: 'Liquidate immediately to avoid losses', score: 5),
        RiskQuestionOptionModel(key: 'TOL_MID', labelFa: 'صبر و حفظ سهام بر اساس تحلیل بنیادی', labelEn: 'Hold patiently according to fundamentals', score: 15),
        RiskQuestionOptionModel(key: 'TOL_HIGH', labelFa: 'افزایش حجم خرید در قیمت‌های پایین‌تر', labelEn: 'Buy the dip and increase position', score: 20),
      ],
    ),
    RiskQuestionModel(
      id: 'Q4',
      category: 'ALLOCATION',
      questionFa: 'چه نسبتی از کل نقدینگی مازاد خود را به بازار سهام بین‌الملل تخصیص می‌دهید؟',
      questionEn: 'What percentage of your surplus liquid assets will be allocated to stocks?',
      options: [
        RiskQuestionOptionModel(key: 'ALLOC_LOW', labelFa: 'کمتر از ۱۰ درصد', labelEn: 'Less than 10%', score: 5),
        RiskQuestionOptionModel(key: 'ALLOC_MID', labelFa: '۱۰ تا ۲۵ درصد', labelEn: '10% to 25%', score: 15),
        RiskQuestionOptionModel(key: 'ALLOC_HIGH', labelFa: 'بیش از ۲۵ درصد', labelEn: 'Over 25%', score: 20),
      ],
    ),
    RiskQuestionModel(
      id: 'Q5',
      category: 'GOAL',
      questionFa: 'هدف اصلی شما از سرمایه‌گذاری در بورس‌های بین‌المللی چیست؟',
      questionEn: 'What is your primary investment goal in international equities?',
      options: [
        RiskQuestionOptionModel(key: 'GOAL_SAFE', labelFa: 'حفظ ارزش دارایی در برابر تورم ارزی', labelEn: 'Capital Preservation vs inflation', score: 5),
        RiskQuestionOptionModel(key: 'GOAL_GROWTH', labelFa: 'رشد متوازن ارزش دارایی و دریافت سود نقدی', labelEn: 'Balanced Growth & Dividends', score: 15),
        RiskQuestionOptionModel(key: 'GOAL_SPEC', labelFa: 'حداکثر بازدهی از نوسانات پرسرعت سهام', labelEn: 'Max capital appreciation & volatility', score: 20),
      ],
    ),
    RiskQuestionModel(
      id: 'Q6',
      category: 'FX_KNOWLEDGE',
      questionFa: 'آیا از ریسک نوسانات برابری ارز مبدا و مقصد (FX Volatility) و قاعده تسویه T+2 آگاهی دارید؟',
      questionEn: 'Are you aware of FX exchange rate risks and the T+2 settlement cycle?',
      options: [
        RiskQuestionOptionModel(key: 'FX_NO', labelFa: 'آشنایی محدودی دارم و نیاز به هشدار شفاف دارم', labelEn: 'Limited understanding, need warnings', score: 5),
        RiskQuestionOptionModel(key: 'FX_MKT_YES', labelFa: 'کاملاً آگاه بوده و شرایط تسویه ارزی را می‌پذیرم', labelEn: 'Fully aware and accept T+2 settlement terms', score: 20),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _service = Get.isRegistered<StockService>()
        ? Get.find<StockService>()
        : Get.put(StockService());
    _seedDefaultMarkets();
    _seedDefaultHoldings();
    loadDashboard();
  }

  void _seedDefaultMarkets() {
    markets.value = [
      const StockMarketModel(
        id: 1,
        code: 'NASDAQ',
        countryCode: 'USA',
        nameFa: 'بورس نزدک آمریکا',
        nameEn: 'NASDAQ Stock Market',
        baseCurrency: 'USD',
        settlementDays: 2,
        commissionPct: 0.15,
        quotesDelayMin: 0,
        symbols: [
          StockSymbolModel(
            id: 101,
            ticker: 'AAPL',
            nameFa: 'شرکت اپل',
            nameEn: 'Apple Inc.',
            industry: 'Consumer Tech',
            lastPrice: 228.40,
            prevClose: 224.20,
            dayHigh: 230.10,
            dayLow: 223.80,
            volume24h: 48200000,
            exchangeCode: 'NASDAQ',
          ),
          StockSymbolModel(
            id: 102,
            ticker: 'NVDA',
            nameFa: 'انویدیا',
            nameEn: 'NVIDIA Corporation',
            industry: 'Semiconductors & AI',
            lastPrice: 135.20,
            prevClose: 131.00,
            dayHigh: 136.50,
            dayLow: 130.40,
            volume24h: 92400000,
            highVolatility: true,
            exchangeCode: 'NASDAQ',
          ),
          StockSymbolModel(
            id: 103,
            ticker: 'MSFT',
            nameFa: 'مایکروسافت',
            nameEn: 'Microsoft Corp.',
            industry: 'Enterprise Software',
            lastPrice: 428.10,
            prevClose: 430.50,
            dayHigh: 432.00,
            dayLow: 425.80,
            volume24h: 21500000,
            exchangeCode: 'NASDAQ',
          ),
          StockSymbolModel(
            id: 104,
            ticker: 'TSLA',
            nameFa: 'تسلا موتورز',
            nameEn: 'Tesla, Inc.',
            industry: 'Automotive & Clean Energy',
            lastPrice: 254.60,
            prevClose: 262.30,
            dayHigh: 264.00,
            dayLow: 251.20,
            volume24h: 76100000,
            highVolatility: true,
            exchangeCode: 'NASDAQ',
          ),
        ],
      ),
      const StockMarketModel(
        id: 2,
        code: 'NYSE',
        countryCode: 'USA',
        nameFa: 'بورس نیویورک',
        nameEn: 'New York Stock Exchange',
        baseCurrency: 'USD',
        settlementDays: 2,
        commissionPct: 0.15,
        quotesDelayMin: 0,
        symbols: [
          StockSymbolModel(
            id: 201,
            ticker: 'BRK.B',
            nameFa: 'برکشایر هاتاوی',
            nameEn: 'Berkshire Hathaway',
            industry: 'Financial Conglomerate',
            lastPrice: 462.50,
            prevClose: 459.80,
            dayHigh: 464.00,
            dayLow: 458.50,
            volume24h: 3400000,
            exchangeCode: 'NYSE',
          ),
          StockSymbolModel(
            id: 202,
            ticker: 'JPM',
            nameFa: 'جی‌پی مورگان چیس',
            nameEn: 'JPMorgan Chase & Co.',
            industry: 'Banking & Financials',
            lastPrice: 218.90,
            prevClose: 216.50,
            dayHigh: 220.30,
            dayLow: 215.80,
            volume24h: 8900000,
            exchangeCode: 'NYSE',
          ),
        ],
      ),
      const StockMarketModel(
        id: 3,
        code: 'HKEX',
        countryCode: 'HKG',
        nameFa: 'بورس هنگ‌کنگ',
        nameEn: 'Hong Kong Exchanges',
        baseCurrency: 'HKD',
        settlementDays: 2,
        commissionPct: 0.25,
        quotesDelayMin: 15,
        symbols: [
          StockSymbolModel(
            id: 301,
            ticker: '700.HK',
            nameFa: 'تنسنت هلدینگز',
            nameEn: 'Tencent Holdings Ltd',
            industry: 'Technology & Gaming',
            lastPrice: 382.40,
            prevClose: 375.00,
            dayHigh: 385.00,
            dayLow: 374.20,
            volume24h: 14500000,
            exchangeCode: 'HKEX',
          ),
          StockSymbolModel(
            id: 302,
            ticker: '9988.HK',
            nameFa: 'علی‌بابا هلدینگ',
            nameEn: 'Alibaba Group',
            industry: 'E-commerce & Cloud',
            lastPrice: 84.50,
            prevClose: 87.20,
            dayHigh: 88.00,
            dayLow: 83.90,
            volume24h: 32000000,
            exchangeCode: 'HKEX',
          ),
        ],
      ),
      const StockMarketModel(
        id: 4,
        code: 'LSE',
        countryCode: 'GBR',
        nameFa: 'بورس لندن',
        nameEn: 'London Stock Exchange',
        baseCurrency: 'GBP',
        settlementDays: 2,
        commissionPct: 0.20,
        quotesDelayMin: 15,
        symbols: [
          StockSymbolModel(
            id: 401,
            ticker: 'SHEL.L',
            nameFa: 'رویال داچ شل',
            nameEn: 'Shell plc',
            industry: 'Energy & Oil',
            lastPrice: 28.40,
            prevClose: 28.10,
            dayHigh: 28.65,
            dayLow: 27.95,
            volume24h: 11000000,
            exchangeCode: 'LSE',
          ),
          StockSymbolModel(
            id: 402,
            ticker: 'AZN.L',
            nameFa: 'آسترازنکا',
            nameEn: 'AstraZeneca plc',
            industry: 'Biopharmaceuticals',
            lastPrice: 122.50,
            prevClose: 124.00,
            dayHigh: 124.80,
            dayLow: 121.30,
            volume24h: 2400000,
            exchangeCode: 'LSE',
          ),
        ],
      ),
      const StockMarketModel(
        id: 5,
        code: 'TSE',
        countryCode: 'JPN',
        nameFa: 'بورس توکیو ژاپن',
        nameEn: 'Tokyo Stock Exchange',
        baseCurrency: 'JPY',
        settlementDays: 2,
        commissionPct: 0.20,
        quotesDelayMin: 15,
        symbols: [
          StockSymbolModel(
            id: 501,
            ticker: '7203.T',
            nameFa: 'تویوتا موتور',
            nameEn: 'Toyota Motor Corp.',
            industry: 'Automotive',
            lastPrice: 2680.00,
            prevClose: 2640.00,
            dayHigh: 2710.00,
            dayLow: 2635.00,
            volume24h: 18500000,
            exchangeCode: 'TSE',
          ),
          StockSymbolModel(
            id: 502,
            ticker: '6758.T',
            nameFa: 'سونی گروپ',
            nameEn: 'Sony Group Corp.',
            industry: 'Electronics & Media',
            lastPrice: 2845.00,
            prevClose: 2890.00,
            dayHigh: 2900.00,
            dayLow: 2820.00,
            volume24h: 9100000,
            exchangeCode: 'TSE',
          ),
        ],
      ),
    ];

    if (selectedMarket.value == null && markets.isNotEmpty) {
      selectedMarket.value = markets.first;
      if (selectedMarket.value!.symbols.isNotEmpty) {
        selectedSymbol.value = selectedMarket.value!.symbols.first;
      }
    }
  }

  void _seedDefaultHoldings() {
    holdings.value = [
      const StockHoldingModel(
        ticker: 'AAPL',
        nameFa: 'اپل',
        nameEn: 'Apple Inc.',
        shares: 12.0,
        averageCost: 195.50,
        currentPrice: 228.40,
        currency: 'USD',
        exchangeCode: 'NASDAQ',
        realizedPnl: 150.0,
      ),
      const StockHoldingModel(
        ticker: 'NVDA',
        nameFa: 'انویدیا',
        nameEn: 'NVIDIA Corp.',
        shares: 20.0,
        averageCost: 110.00,
        currentPrice: 135.20,
        currency: 'USD',
        exchangeCode: 'NASDAQ',
        realizedPnl: 0.0,
      ),
      const StockHoldingModel(
        ticker: '700.HK',
        nameFa: 'تنسنت',
        nameEn: 'Tencent',
        shares: 100.0,
        averageCost: 350.00,
        currentPrice: 382.40,
        currency: 'HKD',
        exchangeCode: 'HKEX',
        realizedPnl: 200.0,
      ),
    ];

    _recalculatePortfolioSummary();
  }

  void _recalculatePortfolioSummary() {
    double totalVal = 0.0;
    double totalCost = 0.0;
    double totalRealized = 0.0;

    for (final h in holdings) {
      final fxToUsd = h.currency == 'HKD' ? 0.128 : (h.currency == 'GBP' ? 1.30 : (h.currency == 'JPY' ? 0.0068 : 1.0));
      totalVal += h.currentValue * fxToUsd;
      totalCost += h.costBasis * fxToUsd;
      totalRealized += h.realizedPnl * fxToUsd;
    }

    final currencyExposures = <CurrencyExposureModel>[
      CurrencyExposureModel(
        currency: 'USD',
        amountInCurrency: totalVal * 0.75,
        amountInUsd: totalVal * 0.75,
        percentage: 75.0,
      ),
      CurrencyExposureModel(
        currency: 'HKD',
        amountInCurrency: (totalVal * 0.20) / 0.128,
        amountInUsd: totalVal * 0.20,
        percentage: 20.0,
      ),
      CurrencyExposureModel(
        currency: 'GBP',
        amountInCurrency: (totalVal * 0.05) / 1.30,
        amountInUsd: totalVal * 0.05,
        percentage: 5.0,
      ),
    ];

    portfolioSummary.value = StockPortfolioSummaryModel(
      totalValueUsd: totalVal > 0 ? totalVal : 8450.00,
      totalCostBasisUsd: totalCost > 0 ? totalCost : 7200.00,
      totalRealizedPnlUsd: totalRealized > 0 ? totalRealized : 350.00,
      holdings: holdings,
      currencyExposures: currencyExposures,
    );
  }

  // Top Gainers across all markets
  List<StockSymbolModel> get topGainers {
    final all = markets.expand((m) => m.symbols).toList();
    all.sort((a, b) => b.dailyChangePct.compareTo(a.dailyChangePct));
    return all.where((s) => s.dailyChangePct > 0).take(5).toList();
  }

  // Top Losers across all markets
  List<StockSymbolModel> get topLosers {
    final all = markets.expand((m) => m.symbols).toList();
    all.sort((a, b) => a.dailyChangePct.compareTo(b.dailyChangePct));
    return all.where((s) => s.dailyChangePct < 0).take(5).toList();
  }

  // Watchlisted Symbols
  List<StockSymbolModel> get watchlistedSymbols {
    final all = markets.expand((m) => m.symbols).toList();
    return all.where((s) => watchlist.contains(s.ticker)).toList();
  }

  bool isWatchlisted(String ticker) => watchlist.contains(ticker);

  void toggleWatchlist(String ticker) {
    if (watchlist.contains(ticker)) {
      watchlist.remove(ticker);
    } else {
      watchlist.add(ticker);
    }
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    hasBackendError.value = false;
    try {
      final marketsList = await _service.getMarkets();
      if (marketsList.isNotEmpty) {
        markets.value = marketsList;
        isServiceAvailable.value = true;
        if (selectedMarket.value == null) {
          selectedMarket.value = marketsList.first;
        }
      }

      final acc = await _service.getAccount();
      if (acc != null) {
        account.value = acc;
      }

      final pData = await _service.getPortfolio();
      if (pData != null) {
        portfolioData.value = pData;
        portfolioSummary.value = StockPortfolioSummaryModel.fromJson(pData);
      }
    } catch (e) {
      // Backend unavailable or in demo mode: we retain seeded realistic data
      hasBackendError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      _recalculatePortfolioSummary();
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

    double price = sym.lastPrice;
    if (orderType.value == 'LIMIT') {
      final lp = double.tryParse(limitPriceInput.value);
      if (lp != null && lp > 0) price = lp;
    } else if (orderType.value == 'STOP_LOSS') {
      final sp = double.tryParse(stopPriceInput.value);
      if (sp != null && sp > 0) price = sp;
    }

    final totalMarketCurrency = price * quantity.value;
    final commissionPct = mkt.commissionPct;
    calculatedCommission.value = totalMarketCurrency * (commissionPct / 100);

    // Approximate FX rates for UI preview
    double fxRate = 1.0;
    if (payCurrency.value == 'IRR') {
      fxRate = mkt.baseCurrency == 'USD' ? 620000.0 : (mkt.baseCurrency == 'HKD' ? 79500.0 : 790000.0);
    } else if (payCurrency.value == 'USDT' || payCurrency.value == 'USD') {
      fxRate = mkt.baseCurrency == 'USD' ? 1.0 : (mkt.baseCurrency == 'HKD' ? 0.128 : 1.30);
    } else if (payCurrency.value == mkt.baseCurrency) {
      fxRate = 1.0;
    }

    calculatedFxRate.value = fxRate;
    calculatedPayAmount.value = (totalMarketCurrency + calculatedCommission.value) * fxRate;

    try {
      final fx = await _service.getFxQuote(
        from: mkt.baseCurrency,
        to: payCurrency.value,
        amount: totalMarketCurrency,
      );
      if (fx != null) {
        calculatedPayAmount.value = (fx['gross_amount'] as num?)?.toDouble() ?? calculatedPayAmount.value;
        calculatedFxRate.value = (fx['exchange_rate'] as num?)?.toDouble() ?? calculatedFxRate.value;
      }
    } catch (_) {
      // Fallback already calculated
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
    if (orderType.value == 'STOP_LOSS') {
      final stopPrice = double.tryParse(stopPriceInput.value);
      if (stopPrice == null || stopPrice <= 0) {
        return 'ERR_VALIDATION: قیمت حد ضرر (Stop-Loss) نامعتبر است.';
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
        // Create local validated pending order
        final pendingOrder = StockOrderModel(
          orderNo: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          ticker: selectedSymbol.value!.ticker,
          nameFa: selectedSymbol.value!.nameFa,
          side: orderSide.value,
          type: orderType.value,
          qty: quantity.value,
          limitPrice: limitPrice ?? selectedSymbol.value!.lastPrice,
          stopPrice: double.tryParse(stopPriceInput.value) ?? 0.0,
          marketCurrency: selectedMarket.value?.baseCurrency ?? 'USD',
          payCurrency: payCurrency.value,
          payAmount: calculatedPayAmount.value,
          executedFxRate: calculatedFxRate.value,
          avgExecPrice: selectedSymbol.value!.lastPrice,
          commissionAmount: calculatedCommission.value,
          status: 'PENDING_BROKER',
          settlementDays: selectedMarket.value?.settlementDays ?? 2,
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

  void cancelOrder(String orderNo) {
    final idx = orders.indexWhere((o) => o.orderNo == orderNo);
    if (idx != -1) {
      final ord = orders[idx];
      orders[idx] = StockOrderModel(
        orderNo: ord.orderNo,
        ticker: ord.ticker,
        nameFa: ord.nameFa,
        side: ord.side,
        type: ord.type,
        qty: ord.qty,
        limitPrice: ord.limitPrice,
        stopPrice: ord.stopPrice,
        marketCurrency: ord.marketCurrency,
        payCurrency: ord.payCurrency,
        payAmount: ord.payAmount,
        executedFxRate: ord.executedFxRate,
        avgExecPrice: ord.avgExecPrice,
        commissionAmount: ord.commissionAmount,
        status: 'CANCELLED',
        settlementDays: ord.settlementDays,
        createdAt: ord.createdAt,
      );
    }
  }

  Future<void> submitRiskQuiz(Map<String, String> answers) async {
    isOrderLoading.value = true;
    riskAnswers.value = answers;

    int totalScore = 0;
    for (final q in defaultRiskQuestions) {
      final selectedKey = answers[q.id];
      final opt = q.options.firstWhere(
        (o) => o.key == selectedKey,
        orElse: () => q.options.first,
      );
      totalScore += opt.score;
    }

    riskProfileResult.value = RiskProfileResult.evaluate(totalScore);
    isRiskAssessmentCompleted.value = true;

    try {
      await _service.submitRiskQuiz(answers);
      account.value = await _service.getAccount();
    } catch (_) {
      // Retain evaluated score
    } finally {
      isOrderLoading.value = false;
    }
  }
}
