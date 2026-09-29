import 'dart:convert';

class LicenseProductItem {
  final int id;
  final String name;
  final String slug;
  final String category;
  final String? vendor;
  final String? description;
  final List<String> editions;
  final List<int> durationsMonths;
  final double priceUsd;
  final Map<String, dynamic> editionPricing;
  final Map<String, dynamic> durationMultipliers;
  final String? activationGuide;
  final String? refundPolicy;
  final String? featuredImage;
  final bool isInStock;
  final int stockCount;

  LicenseProductItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    this.vendor,
    this.description,
    required this.editions,
    required this.durationsMonths,
    required this.priceUsd,
    this.editionPricing = const {},
    this.durationMultipliers = const {},
    this.activationGuide,
    this.refundPolicy,
    this.featuredImage,
    required this.isInStock,
    required this.stockCount,
  });

  factory LicenseProductItem.fromJson(Map<String, dynamic> json) {
    return LicenseProductItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? 'software',
      vendor: json['vendor'],
      description: json['description'],
      editions: (json['editions'] as List?)?.map((e) => e.toString()).toList() ?? ['Standard'],
      durationsMonths: (json['durations_months'] as List?)?.map((e) => int.tryParse('$e') ?? 12).toList() ?? [12],
      priceUsd: double.tryParse('${json['price_usd']}') ?? 0.0,
      editionPricing: json['edition_pricing'] is Map ? Map<String, dynamic>.from(json['edition_pricing']) : {},
      durationMultipliers: json['duration_multipliers'] is Map ? Map<String, dynamic>.from(json['duration_multipliers']) : {},
      activationGuide: json['activation_guide'],
      refundPolicy: json['refund_policy'],
      featuredImage: json['featured_image'],
      isInStock: json['is_in_stock'] == true,
      stockCount: json['stock_count'] is int ? json['stock_count'] : int.tryParse('${json['stock_count']}') ?? 0,
    );
  }

  double calculatePrice(String edition, int months) {
    double base = priceUsd;
    if (editionPricing.containsKey(edition)) {
      base = double.tryParse('${editionPricing[edition]}') ?? base;
    }
    double mult = 1.0;
    if (durationMultipliers.containsKey(months.toString())) {
      mult = double.tryParse('${durationMultipliers[months.toString()]}') ?? mult;
    }
    return double.parse((base * mult).toStringAsFixed(2));
  }
}

class LicenseOrderItem {
  final int id;
  final String orderNo;
  final String? productName;
  final String edition;
  final int durationMonths;
  final double priceUsd;
  final String payRoute;
  final String payRouteLabel;
  final String status;
  final String statusLabel;
  final String? priceLockExpiresAt;
  final int priceLockRemainingSeconds;
  final String? paymentDeadline;
  final String? keyMasked;
  final String? licenseKey;
  final String? keyExpiresAt;
  final String? cryptoNetwork;
  final String? cryptoWalletAddress;
  final double? cryptoExpectedAmount;

  LicenseOrderItem({
    required this.id,
    required this.orderNo,
    this.productName,
    required this.edition,
    required this.durationMonths,
    required this.priceUsd,
    required this.payRoute,
    required this.payRouteLabel,
    required this.status,
    required this.statusLabel,
    this.priceLockExpiresAt,
    this.priceLockRemainingSeconds = 0,
    this.paymentDeadline,
    this.keyMasked,
    this.licenseKey,
    this.keyExpiresAt,
    this.cryptoNetwork,
    this.cryptoWalletAddress,
    this.cryptoExpectedAmount,
  });

  factory LicenseOrderItem.fromJson(Map<String, dynamic> json) {
    final keyData = json['delivered_key'] is Map ? json['delivered_key'] : null;
    final cryptoData = json['crypto_payment'] is Map ? json['crypto_payment'] : null;
    final prodData = json['product'] is Map ? json['product'] : null;

    return LicenseOrderItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      orderNo: json['order_no'] ?? '',
      productName: prodData?['name'],
      edition: json['edition'] ?? 'Standard',
      durationMonths: json['duration_months'] is int ? json['duration_months'] : int.tryParse('${json['duration_months']}') ?? 12,
      priceUsd: double.tryParse('${json['price_usd']}') ?? 0.0,
      payRoute: json['pay_route'] ?? 'CRYPTO_WALLET',
      payRouteLabel: json['pay_route_label'] ?? '',
      status: json['status'] ?? 'DRAFT',
      statusLabel: json['status_label'] ?? '',
      priceLockExpiresAt: json['price_lock_expires_at'],
      priceLockRemainingSeconds: json['price_lock_remaining_seconds'] is int ? json['price_lock_remaining_seconds'] : int.tryParse('${json['price_lock_remaining_seconds']}') ?? 0,
      paymentDeadline: json['payment_deadline'],
      keyMasked: keyData?['key_masked'],
      licenseKey: keyData?['license_key'],
      keyExpiresAt: keyData?['expires_at'],
      cryptoNetwork: cryptoData?['network'],
      cryptoWalletAddress: cryptoData?['wallet_address'],
      cryptoExpectedAmount: double.tryParse('${cryptoData?['expected_amount']}'),
    );
  }
}

class LicenseKeyItem {
  final int id;
  final String orderNo;
  final String productName;
  final String edition;
  final int durationMonths;
  final String licenseKey;
  final String keyMasked;
  final String? issuedAt;
  final String? expiresAt;
  final bool isExpired;
  final int? daysRemaining;
  final String? activationGuide;

  LicenseKeyItem({
    required this.id,
    required this.orderNo,
    required this.productName,
    required this.edition,
    required this.durationMonths,
    required this.licenseKey,
    required this.keyMasked,
    this.issuedAt,
    this.expiresAt,
    this.isExpired = false,
    this.daysRemaining,
    this.activationGuide,
  });

  factory LicenseKeyItem.fromJson(Map<String, dynamic> json) {
    return LicenseKeyItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      orderNo: json['order_no'] ?? '',
      productName: json['product_name'] ?? '',
      edition: json['edition'] ?? 'Standard',
      durationMonths: json['duration_months'] is int ? json['duration_months'] : int.tryParse('${json['duration_months']}') ?? 12,
      licenseKey: json['license_key'] ?? '',
      keyMasked: json['key_masked'] ?? '',
      issuedAt: json['issued_at'],
      expiresAt: json['expires_at'],
      isExpired: json['is_expired'] == true,
      daysRemaining: json['days_remaining'] is int ? json['days_remaining'] : int.tryParse('${json['days_remaining']}'),
      activationGuide: json['activation_guide'],
    );
  }
}
