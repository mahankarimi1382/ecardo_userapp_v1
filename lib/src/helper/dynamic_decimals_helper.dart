class DynamicDecimalsHelper {
  static const Set<String> _zeroDecimalCurrencies = {
    'IRR',
    'IRT',
    'TOMAN',
    'TMN',
    'RLS',
    'RIAL',
    'JPY',
    'CLP',
    'KRW',
    'VND',
    'IDR',
  };

  static const Set<String> _twoDecimalCurrencies = {
    'USD',
    'EUR',
    'CNY',
    'RMB',
    'YUAN',
    'GBP',
    'AED',
    'TRY',
    'CAD',
    'AUD',
    'CHF',
  };

  static bool isZeroDecimal(String currencyCode) {
    return _zeroDecimalCurrencies.contains(currencyCode.toUpperCase().trim());
  }

  static bool isRtlCurrency(String currencyCode) {
    const rtlSet = {'IRR', 'IRT', 'TOMAN', 'TMN', 'RLS', 'RIAL'};
    return rtlSet.contains(currencyCode.toUpperCase().trim());
  }

  int getDynamicDecimals({
    required String currencyCode,
    required String siteCurrencyCode,
    required String? siteCurrencyDecimals,
    required bool isCrypto,
  }) {
    final upperCode = currencyCode.toUpperCase().trim();
    if (_zeroDecimalCurrencies.contains(upperCode)) {
      return 0;
    }
    if (_twoDecimalCurrencies.contains(upperCode)) {
      return 2;
    }

    final bool dynamicDecimal = currencyCode == siteCurrencyCode;

    if (dynamicDecimal) {
      return int.tryParse(siteCurrencyDecimals ?? "") ?? 2;
    } else {
      return isCrypto ? 8 : 2;
    }
  }
}
