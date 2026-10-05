// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/foundation.dart';
import '../../local/models/experience_contracts.dart';

enum DiningServiceMode {
  airportGatePickup,
  loungeDelivery,
  tableReservation,
  chefTastingExperience;

  String get wireName {
    switch (this) {
      case DiningServiceMode.airportGatePickup:
        return 'airport_gate_pickup';
      case DiningServiceMode.loungeDelivery:
        return 'lounge_delivery';
      case DiningServiceMode.tableReservation:
        return 'table_reservation';
      case DiningServiceMode.chefTastingExperience:
        return 'chef_tasting_experience';
    }
  }

  static DiningServiceMode fromWireName(String? name) {
    switch (name) {
      case 'lounge_delivery':
        return DiningServiceMode.loungeDelivery;
      case 'table_reservation':
        return DiningServiceMode.tableReservation;
      case 'chef_tasting_experience':
        return DiningServiceMode.chefTastingExperience;
      case 'airport_gate_pickup':
      default:
        return DiningServiceMode.airportGatePickup;
    }
  }

  String get labelFa {
    switch (this) {
      case DiningServiceMode.airportGatePickup:
        return 'تحویل درب گیت پرواز (Gate Pickup)';
      case DiningServiceMode.loungeDelivery:
        return 'سرو اختصاصی در لانژ (Lounge Service)';
      case DiningServiceMode.tableReservation:
        return 'رزرو قطعی میز رستوران (Table Reserve)';
      case DiningServiceMode.chefTastingExperience:
        return 'تجربه مزه‌گردی سرآشپز (Tasting Menu)';
    }
  }
}

@immutable
class MenuItemModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String? imageUrl;
  final bool isHalal;
  final bool isVegan;
  final bool isGlutenFree;
  final int calories;
  final int prepMinutes;
  final int spicyLevel;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.isHalal = true,
    this.isVegan = false,
    this.isGlutenFree = false,
    required this.calories,
    required this.prepMinutes,
    this.spicyLevel = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'currency': currency,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_halal': isHalal,
        'is_vegan': isVegan,
        'is_gluten_free': isGlutenFree,
        'calories': calories,
        'prep_minutes': prepMinutes,
        'spicy_level': spicyLevel,
      };

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      imageUrl: json['image_url'] as String?,
      isHalal: json['is_halal'] as bool? ?? true,
      isVegan: json['is_vegan'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      calories: json['calories'] as int? ?? 450,
      prepMinutes: json['prep_minutes'] as int? ?? 15,
      spicyLevel: json['spicy_level'] as int? ?? 0,
    );
  }
}

@immutable
class RestaurantModel {
  final String schemaVersion;
  final String id;
  final String name;
  final String terminalLocation;
  final String city;
  final String cuisineType;
  final double rating;
  final int reviewsCount;
  final String openingHours;
  final List<DiningServiceMode> availableModes;
  final List<MenuItemModel> menu;
  final double minOrderAmount;
  final String currency;
  final double tableReservationDeposit;
  final ExperienceCancellationPolicy cancellationPolicy;
  final List<String> dietaryOptions;
  final int avgPrepMinutes;

  const RestaurantModel({
    this.schemaVersion = '1.0',
    required this.id,
    required this.name,
    required this.terminalLocation,
    required this.city,
    required this.cuisineType,
    required this.rating,
    required this.reviewsCount,
    required this.openingHours,
    required this.availableModes,
    required this.menu,
    this.minOrderAmount = 10.0,
    this.currency = 'USD',
    this.tableReservationDeposit = 5.0,
    this.cancellationPolicy = const ExperienceCancellationPolicy(
      freeCancellationHours: 2,
      lateCancelPenaltyPercent: 50.0,
    ),
    this.dietaryOptions = const ['حلال (Halal)', 'گزینه گیاهی (Vegan Option)'],
    this.avgPrepMinutes = 15,
  });

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'id': id,
        'name': name,
        'terminal_location': terminalLocation,
        'city': city,
        'cuisine_type': cuisineType,
        'rating': rating,
        'reviews_count': reviewsCount,
        'opening_hours': openingHours,
        'available_modes': availableModes.map((m) => m.wireName).toList(),
        'menu': menu.map((m) => m.toJson()).toList(),
        'min_order_amount': minOrderAmount,
        'currency': currency,
        'table_reservation_deposit': tableReservationDeposit,
        'cancellation_policy': cancellationPolicy.toJson(),
        'dietary_options': dietaryOptions,
        'avg_prep_minutes': avgPrepMinutes,
      };

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      terminalLocation: json['terminal_location'] as String? ?? '',
      city: json['city'] as String? ?? '',
      cuisineType: json['cuisine_type'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      openingHours: json['opening_hours'] as String? ?? '24/7',
      availableModes: (json['available_modes'] as List<dynamic>?)
              ?.map((e) => DiningServiceMode.fromWireName(e.toString()))
              .toList() ??
          [DiningServiceMode.airportGatePickup],
      menu: (json['menu'] as List<dynamic>?)
              ?.map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 10.0,
      currency: json['currency'] as String? ?? 'USD',
      tableReservationDeposit:
          (json['table_reservation_deposit'] as num?)?.toDouble() ?? 5.0,
      cancellationPolicy: json['cancellation_policy'] != null
          ? ExperienceCancellationPolicy.fromJson(
              Map<String, dynamic>.from(json['cancellation_policy'] as Map))
          : const ExperienceCancellationPolicy(freeCancellationHours: 2),
      dietaryOptions:
          (json['dietary_options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              const [],
      avgPrepMinutes: json['avg_prep_minutes'] as int? ?? 15,
    );
  }
}

class DiningOrderItem {
  final MenuItemModel item;
  int quantity;
  String? specialInstructions;

  DiningOrderItem({
    required this.item,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get subtotal => item.price * quantity;

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'quantity': quantity,
        if (specialInstructions != null) 'special_instructions': specialInstructions,
        'subtotal': subtotal,
      };

  factory DiningOrderItem.fromJson(Map<String, dynamic> json) {
    return DiningOrderItem(
      item: MenuItemModel.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      quantity: json['quantity'] as int? ?? 1,
      specialInstructions: json['special_instructions'] as String?,
    );
  }
}

@immutable
class DiningOrderModel {
  final String schemaVersion;
  final String orderId;
  final String restaurantId;
  final String restaurantName;
  final String terminalLocation;
  final DiningServiceMode mode;
  final String? flightNumber;
  final String? gateOrTable;
  final String pickupTime;
  final List<DiningOrderItem> items;
  final double totalAmount;
  final double penaltyAmount;
  final double refundedAmount;
  final String currency;
  final String refundDestinationWalletCurrency;
  final String status; // preparing, ready_for_pickup, completed, cancelled, refunded
  final String? cancellationReason;
  final DateTime orderedAt;
  final DateTime? cancelledAt;
  final ExperienceCancellationPolicy cancellationPolicy;
  final String voucherCode;
  final String qrPayload;

  const DiningOrderModel({
    this.schemaVersion = '1.0',
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.terminalLocation,
    required this.mode,
    this.flightNumber,
    this.gateOrTable,
    required this.pickupTime,
    required this.items,
    required this.totalAmount,
    this.penaltyAmount = 0.0,
    this.refundedAmount = 0.0,
    required this.currency,
    String? refundDestinationWalletCurrency,
    required this.status,
    this.cancellationReason,
    required this.orderedAt,
    this.cancelledAt,
    this.cancellationPolicy = const ExperienceCancellationPolicy(freeCancellationHours: 2),
    String? voucherCode,
    String? qrPayload,
  })  : refundDestinationWalletCurrency = refundDestinationWalletCurrency ?? currency,
        voucherCode = voucherCode ?? orderId,
        qrPayload = qrPayload ?? 'ECARDO-DINING-PASS-$orderId-$restaurantId-$status';

  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get canCancel => !isCancelled && status != 'completed';

  ExperienceRefundCalculation calculateCancellationRefund({DateTime? atTime}) {
    final now = atTime ?? DateTime.now();
    // In-transit dining orders: if preparing/ready, 50% penalty unless cancelled within 5 mins of order
    final minsSinceOrder = now.difference(orderedAt).inMinutes;
    if (minsSinceOrder <= 5) {
      return ExperienceRefundCalculation(
        originalAmount: totalAmount,
        refundableAmount: totalAmount,
        penaltyAmount: 0.0,
        currency: currency,
        refundDestinationWalletCurrency: refundDestinationWalletCurrency,
        isFreeCancellation: true,
        policySummary: 'Immediate cancellation (within 5 min). 100% refunded to $currency wallet.',
      );
    }

    final penalty = (totalAmount * 0.5).clamp(0.0, totalAmount);
    final refundable = totalAmount - penalty;
    return ExperienceRefundCalculation(
      originalAmount: totalAmount,
      refundableAmount: refundable,
      penaltyAmount: penalty,
      currency: currency,
      refundDestinationWalletCurrency: refundDestinationWalletCurrency,
      isFreeCancellation: false,
      policySummary:
          'Kitchen preparation began. 50% meal preparation fee applied. Remaining 50% refunded to $currency wallet.',
    );
  }

  DiningOrderModel copyWithCancelled({
    required double penalty,
    required double refund,
    required String reason,
  }) {
    return DiningOrderModel(
      schemaVersion: schemaVersion,
      orderId: orderId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      terminalLocation: terminalLocation,
      mode: mode,
      flightNumber: flightNumber,
      gateOrTable: gateOrTable,
      pickupTime: pickupTime,
      items: items,
      totalAmount: totalAmount,
      penaltyAmount: penalty,
      refundedAmount: refund,
      currency: currency,
      refundDestinationWalletCurrency: refundDestinationWalletCurrency,
      status: 'cancelled',
      cancellationReason: reason,
      orderedAt: orderedAt,
      cancelledAt: DateTime.now(),
      cancellationPolicy: cancellationPolicy,
      voucherCode: voucherCode,
      qrPayload: 'ECARDO-DINING-PASS-$orderId-$restaurantId-cancelled',
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'order_id': orderId,
        'restaurant_id': restaurantId,
        'restaurant_name': restaurantName,
        'terminal_location': terminalLocation,
        'mode': mode.wireName,
        if (flightNumber != null) 'flight_number': flightNumber,
        if (gateOrTable != null) 'gate_or_table': gateOrTable,
        'pickup_time': pickupTime,
        'items': items.map((i) => i.toJson()).toList(),
        'total_amount': totalAmount,
        'penalty_amount': penaltyAmount,
        'refunded_amount': refundedAmount,
        'currency': currency,
        'refund_destination_wallet_currency': refundDestinationWalletCurrency,
        'status': status,
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        'ordered_at': orderedAt.toIso8601String(),
        if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
        'cancellation_policy': cancellationPolicy.toJson(),
        'voucher_code': voucherCode,
        'qr_payload': qrPayload,
      };

  factory DiningOrderModel.fromJson(Map<String, dynamic> json) {
    return DiningOrderModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      orderId: json['order_id'] as String? ?? '',
      restaurantId: json['restaurant_id'] as String? ?? '',
      restaurantName: json['restaurant_name'] as String? ?? '',
      terminalLocation: json['terminal_location'] as String? ?? '',
      mode: DiningServiceMode.fromWireName(json['mode'] as String?),
      flightNumber: json['flight_number'] as String?,
      gateOrTable: json['gate_or_table'] as String?,
      pickupTime: json['pickup_time'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => DiningOrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refunded_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      refundDestinationWalletCurrency:
          json['refund_destination_wallet_currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'preparing',
      cancellationReason: json['cancellation_reason'] as String?,
      orderedAt: json['ordered_at'] != null
          ? DateTime.parse(json['ordered_at'] as String)
          : DateTime.now(),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationPolicy: json['cancellation_policy'] != null
          ? ExperienceCancellationPolicy.fromJson(
              Map<String, dynamic>.from(json['cancellation_policy'] as Map))
          : const ExperienceCancellationPolicy(freeCancellationHours: 2),
      voucherCode: json['voucher_code'] as String?,
      qrPayload: json['qr_payload'] as String?,
    );
  }
}
