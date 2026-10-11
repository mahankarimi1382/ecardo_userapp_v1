class ConverterModel {
  String? status;
  String? message;
  ConverterData? data;

  ConverterModel({this.status, this.message, this.data});

  ConverterModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ConverterData.fromJson(json['data']) : null;
  }
}

class ConverterData {
  String? baseCurrency;
  String? targetCurrency;
  String? baseAmount;
  String? convertedAmount;
  String? rate;
  bool? thousandSeparatorRemove;

  ConverterData({
    this.baseCurrency,
    this.targetCurrency,
    this.baseAmount,
    this.convertedAmount,
    this.rate,
    this.thousandSeparatorRemove,
  });

  ConverterData.fromJson(Map<String, dynamic> json) {
    baseCurrency = json['base_currency']?.toString();
    targetCurrency = json['target_currency']?.toString();
    baseAmount = json['base_amount']?.toString();
    convertedAmount = json['converted_amount']?.toString();
    rate = json['rate']?.toString();
    thousandSeparatorRemove = json['thousandSeparatorRemove'] is bool
        ? json['thousandSeparatorRemove']
        : json['thousandSeparatorRemove']?.toString() == 'true';
  }
}
