import 'package:ecardo_user/src/helper/jalali_date_helper.dart';

class TransactionsModel {
  String? status;
  String? message;
  TransactionsData? data;

  TransactionsModel({this.status, this.message, this.data});

  TransactionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? TransactionsData.fromJson(json['data']) : null;
  }
}

class TransactionsData {
  List<Transactions>? transactions;
  Meta? meta;

  TransactionsData({this.transactions, this.meta});

  TransactionsData.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}

class Transactions {
  String? description;
  String? tnx;
  bool? isPlus;
  String? type;
  String? amount;
  String? charge;
  String? finalAmount;
  String? status;
  String? method;
  String? createdAt;
  String? payCurrency;
  String? payAmount;
  String? walletType;
  bool? isCrypto;
  String? trxCurrency;
  String? trxCurrencySymbol;
  String? trxCurrencyCode;

  Transactions({
    this.description,
    this.tnx,
    this.isPlus,
    this.type,
    this.amount,
    this.charge,
    this.finalAmount,
    this.status,
    this.method,
    this.createdAt,
    this.payCurrency,
    this.payAmount,
    this.walletType,
    this.isCrypto,
    this.trxCurrency,
    this.trxCurrencySymbol,
    this.trxCurrencyCode,
  });

  Transactions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    tnx = json['tnx'];
    isPlus = json['is_plus'];
    type = json['type'];
    amount = json['amount'];
    charge = json['charge'];
    finalAmount = json['final_amount'];
    status = json['status'];
    method = json['method'];
    createdAt = json['created_at'];
    payCurrency = json['pay_currency'];
    payAmount = json['pay_amount'];
    walletType = json['wallet_type'];
    isCrypto = json['is_crypto'];
    trxCurrency = json['trx_currency'];
    trxCurrencySymbol = json['trx_currency_symbol'];
    trxCurrencyCode = json['trx_currency_code'];
  }

  /// Resolved currency code or symbol
  String? get currency => trxCurrencyCode ?? trxCurrency ?? '';

  /// Parsed DateTime from [createdAt] timestamp
  DateTime? get parsedDate => JalaliDateHelper.tryParse(createdAt);

  /// Normalized lowercase status string
  String get normalizedStatus => (status ?? '').trim().toLowerCase();

  /// Whether the transaction is in a successful state
  bool get isSuccess =>
      normalizedStatus == 'success' ||
      normalizedStatus == 'approved' ||
      normalizedStatus == 'completed' ||
      normalizedStatus == 'complete' ||
      normalizedStatus == '1';

  /// Whether the transaction is currently pending/processing
  bool get isPending =>
      normalizedStatus == 'pending' ||
      normalizedStatus == 'processing' ||
      normalizedStatus == '2';

  /// Whether the transaction has failed/rejected/cancelled
  bool get isFailed =>
      !isSuccess &&
      !isPending &&
      normalizedStatus.isNotEmpty &&
      normalizedStatus != '0';

  /// Monogram initials (1-2 characters) from description, counterparty or type.
  String get initials {
    final text = (description ?? '').trim();
    if (text.isNotEmpty) {
      final words =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.length >= 2) {
        final firstChar = words[0].isNotEmpty ? words[0].substring(0, 1) : '';
        final secondChar = words[1].isNotEmpty ? words[1].substring(0, 1) : '';
        return '$firstChar$secondChar'.toUpperCase();
      } else if (words.isNotEmpty && words[0].isNotEmpty) {
        return words[0].substring(0, 1).toUpperCase();
      }
    }
    final t = (type ?? '').trim();
    if (t.isNotEmpty) {
      return t.substring(0, 1).toUpperCase();
    }
    return 'TX';
  }

  /// Parsed numerical amount
  double get numericAmount {
    if (amount == null) return 0.0;
    final cleaned = amount!.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
