class DynamicDecimalsHelper {
  int getDynamicDecimals({
    required String currencyCode,
    required String siteCurrencyCode,
    required String? siteCurrencyDecimals,
    required bool isCrypto,
  }) {
    final bool dynamicDecimal = currencyCode == siteCurrencyCode;

    if (dynamicDecimal) {
      return int.tryParse(siteCurrencyDecimals!) ?? 2;
    } else {
      return isCrypto ? 8 : 2;
    }
  }
}
