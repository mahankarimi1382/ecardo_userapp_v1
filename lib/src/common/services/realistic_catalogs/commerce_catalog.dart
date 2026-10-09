/// Realistic Commerce Domain Catalog & Investment Fixtures (C-01 to C-07)
/// Covers International Stock Trading, Escrow Deals, Bank Guarantees,
/// Commercial Loans, Digital License Keys, and Crowdfunding.
class CommerceCatalog {
  // ---------------------------------------------------------------------------
  // C-01: Stock Trading Markets & Symbols
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getStockMarkets() {
    return [
      {
        'id': 1,
        'code': 'NASDAQ',
        'name_fa': 'بورس نزدک آمریکا',
        'name_en': 'NASDAQ Stock Market',
        'country_code': 'USA',
        'base_currency': 'USD',
        'settlement_days': 2,
        'commission_pct': 0.15,
        'quotes_delay_min': 0,
        'symbols': [
          {
            'id': 101,
            'ticker': 'AAPL',
            'name_fa': 'شرکت اپل',
            'name_en': 'Apple Inc.',
            'industry': 'Consumer Technology',
            'last_price': 228.40,
            'prev_close': 224.20,
            'day_high': 230.10,
            'day_low': 223.80,
            'volume_24h': 48200000,
            'high_volatility': false,
            'exchange_code': 'NASDAQ',
          },
          {
            'id': 102,
            'ticker': 'NVDA',
            'name_fa': 'شرکت انویدیا',
            'name_en': 'NVIDIA Corporation',
            'industry': 'Semiconductors & AI',
            'last_price': 135.20,
            'prev_close': 131.00,
            'day_high': 136.50,
            'day_low': 130.40,
            'volume_24h': 92400000,
            'high_volatility': true,
            'exchange_code': 'NASDAQ',
          },
          {
            'id': 103,
            'ticker': 'MSFT',
            'name_fa': 'شرکت مایکروسافت',
            'name_en': 'Microsoft Corp.',
            'industry': 'Enterprise Cloud & Software',
            'last_price': 428.10,
            'prev_close': 430.50,
            'day_high': 432.00,
            'day_low': 426.30,
            'volume_24h': 21000000,
            'high_volatility': false,
            'exchange_code': 'NASDAQ',
          },
          {
            'id': 104,
            'ticker': 'TSLA',
            'name_fa': 'تسلا موتورز',
            'name_en': 'Tesla Inc.',
            'industry': 'Electric Vehicles & Energy',
            'last_price': 242.80,
            'prev_close': 238.10,
            'day_high': 245.00,
            'day_low': 236.50,
            'volume_24h': 64000000,
            'high_volatility': true,
            'exchange_code': 'NASDAQ',
          },
        ],
      },
      {
        'id': 2,
        'code': 'HKEX',
        'name_fa': 'بورس هنگ کنگ',
        'name_en': 'Hong Kong Stock Exchange',
        'country_code': 'HKG',
        'base_currency': 'HKD',
        'settlement_days': 2,
        'commission_pct': 0.20,
        'quotes_delay_min': 15,
        'symbols': [
          {
            'id': 201,
            'ticker': '700.HK',
            'name_fa': 'تنسنت هلدینگز',
            'name_en': 'Tencent Holdings Ltd',
            'industry': 'Gaming & Cloud Tech',
            'last_price': 382.40,
            'prev_close': 375.00,
            'day_high': 385.00,
            'day_low': 374.20,
            'volume_24h': 14500000,
            'exchange_code': 'HKEX',
          },
        ],
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // C-02: Commercial Escrow Deals
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getEscrowOrders() {
    return [
      {
        'id': 1,
        'contract_no': 'ESC-2026-99120',
        'title': 'خرید و ترخیص تجهیزات شبکه سیسکو (Cisco Enterprise Routers)',
        'buyer_name': 'شرکت فناوری نوین',
        'seller_name': 'صنایع ارتباطات دبی',
        'amount': '12500.00',
        'currency': 'USD',
        'fee': '62.50',
        'fee_payer': 'split', // 50/50
        'inspection_hours': 72,
        'status': 'funded', // funded, inspecting, completed, disputed
        'inspection_ends_at': DateTime.now().add(const Duration(hours: 48)).toIso8601String(),
        'milestones': [
          {'title': 'تحویل در گمرک و بررسی اصالت سریال‌ها', 'percentage': 40, 'released': true},
          {'title': 'تست گرم و راه‌اندازی در دیتاسنتر', 'percentage': 60, 'released': false},
        ],
        'created_at': '2026-10-02 11:30:00',
      },
      {
        'id': 2,
        'contract_no': 'ESC-2026-88041',
        'title': 'قرارداد توسعه اختصاصی موتور هوش مصنوعی فین‌تک',
        'buyer_name': 'کاربر دمو و تست کیفیت',
        'seller_name': 'تیم نرم‌افزاری زاگرس',
        'amount': '4500.00',
        'currency': 'USDT',
        'fee': '22.50',
        'fee_payer': 'buyer',
        'inspection_hours': 48,
        'status': 'completed',
        'created_at': '2026-09-20 09:15:00',
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // C-04: Commercial Loans & Financing
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getLoanProducts() {
    return [
      {
        'id': 1,
        'title': 'تسهیلات خرید تجهیزات بازرگانی و فناوری',
        'min_amount': '1000.0',
        'max_amount': '25000.0',
        'currency': 'USD',
        'annual_interest_rate': 6.5,
        'tenure_months': [6, 12, 24, 36],
        'grace_period_months': 1,
        'collateral_ratio_pct': 30.0,
        'features': ['محاسبه اقساط متساوی استاندارد فرانسه', 'واریز آنی به کیف پول دلاری پس از تایید ضمانت'],
      },
      {
        'id': 2,
        'title': 'خط اعتباری سرمایه در گردش ارزی (Working Capital)',
        'min_amount': '5000.0',
        'max_amount': '100000.0',
        'currency': 'USDT',
        'annual_interest_rate': 8.0,
        'tenure_months': [3, 6, 12],
        'grace_period_months': 0,
        'collateral_ratio_pct': 50.0,
        'features': ['بازپرداخت منعطف بدون جریمه تسویه زودهنگام'],
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // C-05: Digital License Key Store
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getLicenseProducts() {
    return [
      {
        'id': 1,
        'title': 'Microsoft Windows 11 Pro — لایسنس مادام‌العمر دیجیتال',
        'category': 'operating_system',
        'price': '18.00',
        'currency': 'USD',
        'sample_key': 'W269N-WFGWX-YVC9B-4J6C9-T83GX',
        'stock': 45,
        'instant_delivery': true,
        'icon': 'https://ecardo.ir/icons/win11.png',
      },
      {
        'id': 2,
        'title': 'Microsoft 365 Family — اشتراک یک‌ساله ۶ کاربره',
        'category': 'office_productivity',
        'price': '35.00',
        'currency': 'USD',
        'sample_key': 'MS365-FAM-2026-99214-XX881',
        'stock': 28,
        'instant_delivery': true,
        'icon': 'https://ecardo.ir/icons/office.png',
      },
      {
        'id': 3,
        'title': 'Steam Wallet Global — گیفت کد ۵۰ دلاری استیم',
        'category': 'gaming',
        'price': '50.00',
        'currency': 'USD',
        'sample_key': 'ST-GLB-50USD-4481-9920-1142',
        'stock': 120,
        'instant_delivery': true,
        'icon': 'https://ecardo.ir/icons/steam.png',
      },
    ];
  }
}
