class DynamicDecimalsHelper {
  static const Set<String> _zeroDecimalCurrencies = {
    'IRR',
    'IRT',
    'JPY',
    'CLP',
    'KRW',
  };

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

    final bool dynamicDecimal = currencyCode == siteCurrencyCode;

    if (dynamicDecimal) {
      return int.tryParse(siteCurrencyDecimals ?? "") ?? 2;
    } else {
      return isCrypto ? 8 : 2;
    }
  }
}
