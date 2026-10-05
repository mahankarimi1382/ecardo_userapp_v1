// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/foundation.dart';
import '../../local/models/experience_contracts.dart';

enum BoatCategory {
  yacht,
  catamaran,
  speedboat,
  diving,
  jetski,
  cruise;

  String get wireName {
    switch (this) {
      case BoatCategory.yacht:
        return 'yacht';
      case BoatCategory.catamaran:
        return 'catamaran';
      case BoatCategory.speedboat:
        return 'speedboat';
      case BoatCategory.diving:
        return 'diving';
      case BoatCategory.jetski:
        return 'jetski';
      case BoatCategory.cruise:
        return 'cruise';
    }
  }

  static BoatCategory fromWireName(String? name) {
    switch (name?.toLowerCase()) {
      case 'catamaran':
        return BoatCategory.catamaran;
      case 'speedboat':
        return BoatCategory.speedboat;
      case 'diving':
        return BoatCategory.diving;
      case 'jetski':
        return BoatCategory.jetski;
      case 'cruise':
        return BoatCategory.cruise;
      case 'yacht':
      default:
        return BoatCategory.yacht;
    }
  }
}

@immutable
class BoatAddon {
  final String id;
  final String title;
  final double price;
  final String unit;
  final String icon;
  final int maxQuantity;

  const BoatAddon({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.icon,
    this.maxQuantity = 10,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'unit': unit,
        'icon': icon,
        'max_quantity': maxQuantity,
      };

  factory BoatAddon.fromJson(Map<String, dynamic> json) {
    return BoatAddon(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'هر نفر',
      icon: json['icon'] as String? ?? 'scuba',
      maxQuantity: json['max_quantity'] as int? ?? 10,
    );
  }
}

@immutable
class BoatExperienceModel {
  final String schemaVersion;
  final String id;
  final String title;
  final String marinaName;
  final String city;
  final BoatCategory category;
  final double hourlyRate;
  final double childRate;
  final String currency;
  final int minPassengers;
  final int maxPassengers;
  final double lengthMeters;
  final double rating;
  final int reviewsCount;
  final String captainName;
  final List<String> images;
  final List<String> features;
  final List<String> availableSlots;
  final List<BoatAddon> addons;
  final String description;
  final ExperiencePricingType pricingType;
  final ExperienceCancellationPolicy cancellationPolicy;
  final String pierDockNumber;
  final String seaConditionsAdvisory;
  final String fuelPolicy;
  final bool instantConfirmation;

  const BoatExperienceModel({
    this.schemaVersion = '1.0',
    required this.id,
    required this.title,
    required this.marinaName,
    required this.city,
    required this.category,
    required this.hourlyRate,
    this.childRate = 0.0,
    required this.currency,
    this.minPassengers = 1,
    required this.maxPassengers,
    required this.lengthMeters,
    required this.rating,
    required this.reviewsCount,
    required this.captainName,
    required this.images,
    required this.features,
    required this.availableSlots,
    required this.addons,
    required this.description,
    this.pricingType = ExperiencePricingType.perHour,
    this.cancellationPolicy = const ExperienceCancellationPolicy(
      freeCancellationHours: 24,
      lateCancelPenaltyPercent: 30.0,
    ),
    this.pierDockNumber = 'Dock C - Berthing #14',
    this.seaConditionsAdvisory = 'شرایط آب‌وهوایی مساعد، موج سبک (Calm Seas)',
    this.fuelPolicy = 'سوخت و حق لنگراندازی در مارینا شامل قیمت است',
    this.instantConfirmation = true,
  });

  String get categoryLabel {
    switch (category) {
      case BoatCategory.yacht:
        return 'یویات لوکس (Luxury Yacht)';
      case BoatCategory.catamaran:
        return 'کاتاماران (Catamaran)';
      case BoatCategory.speedboat:
        return 'قایق تندرو (Speedboat)';
      case BoatCategory.diving:
        return 'غواصی و ماهیگیری (Diving)';
      case BoatCategory.jetski:
        return 'جت‌اسکی (Jet Ski)';
      case BoatCategory.cruise:
        return 'کروز دریایی (Sea Cruise)';
    }
  }

  /// Accurate calculation respecting duration, adults, children, and selected add-ons.
  double calculateTotal({
    required int hours,
    required int adults,
    int children = 0,
    List<String> selectedAddonIds = const [],
  }) {
    double base;
    if (pricingType == ExperiencePricingType.perHour) {
      base = hourlyRate * hours;
    } else {
      final effectiveChildRate = childRate > 0 ? childRate : hourlyRate * 0.5;
      base = (hourlyRate * adults + effectiveChildRate * children) * hours;
    }

    double addonsTotal = 0.0;
    for (final addonId in selectedAddonIds) {
      final addon = addons.cast<BoatAddon?>().firstWhere(
            (a) => a?.id == addonId,
            orElse: () => null,
          );
      if (addon != null) {
        if (addon.unit.contains('نفر')) {
          addonsTotal += addon.price * (adults + children);
        } else {
          addonsTotal += addon.price;
        }
      }
    }
    return base + addonsTotal;
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'id': id,
        'title': title,
        'marina_name': marinaName,
        'city': city,
        'category': category.wireName,
        'hourly_rate': hourlyRate,
        'child_rate': childRate,
        'currency': currency,
        'min_passengers': minPassengers,
        'max_passengers': maxPassengers,
        'length_meters': lengthMeters,
        'rating': rating,
        'reviews_count': reviewsCount,
        'captain_name': captainName,
        'images': images,
        'features': features,
        'available_slots': availableSlots,
        'addons': addons.map((a) => a.toJson()).toList(),
        'description': description,
        'pricing_type': pricingType.wireName,
        'cancellation_policy': cancellationPolicy.toJson(),
        'pier_dock_number': pierDockNumber,
        'sea_conditions_advisory': seaConditionsAdvisory,
        'fuel_policy': fuelPolicy,
        'instant_confirmation': instantConfirmation,
      };

  factory BoatExperienceModel.fromJson(Map<String, dynamic> json) {
    return BoatExperienceModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      marinaName: json['marina_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      category: BoatCategory.fromWireName(json['category'] as String?),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      childRate: (json['child_rate'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      minPassengers: json['min_passengers'] as int? ?? 1,
      maxPassengers: json['max_passengers'] as int? ?? 10,
      lengthMeters: (json['length_meters'] as num?)?.toDouble() ?? 10.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      captainName: json['captain_name'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      availableSlots:
          (json['available_slots'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => BoatAddon.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
      pricingType: ExperiencePricingType.fromWireName(json['pricing_type'] as String?),
      cancellationPolicy: json['cancellation_policy'] != null
          ? ExperienceCancellationPolicy.fromJson(
              Map<String, dynamic>.from(json['cancellation_policy'] as Map))
          : const ExperienceCancellationPolicy(),
      pierDockNumber: json['pier_dock_number'] as String? ?? '',
      seaConditionsAdvisory: json['sea_conditions_advisory'] as String? ?? '',
      fuelPolicy: json['fuel_policy'] as String? ?? '',
      instantConfirmation: json['instant_confirmation'] as bool? ?? true,
    );
  }
}

@immutable
class BoatBookingModel {
  final String schemaVersion;
  final String bookingId;
  final String boatId;
  final String boatTitle;
  final String marinaName;
  final DateTime date;
  final String timeSlot;
  final int durationHours;
  final int passengersCount;
  final int childrenCount;
  final List<String> selectedAddonIds;
  final double totalAmount;
  final double penaltyAmount;
  final double refundedAmount;
  final String currency;
  final String refundDestinationWalletCurrency;
  final String captainPhone;
  final String pierDockNumber;
  final String status; // confirmed, active, completed, cancelled, refunded
  final String? cancellationReason;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final ExperienceCancellationPolicy cancellationPolicy;
  final String voucherCode;
  final String qrPayload;

  const BoatBookingModel({
    this.schemaVersion = '1.0',
    required this.bookingId,
    required this.boatId,
    required this.boatTitle,
    required this.marinaName,
    required this.date,
    required this.timeSlot,
    required this.durationHours,
    required this.passengersCount,
    this.childrenCount = 0,
    required this.selectedAddonIds,
    required this.totalAmount,
    this.penaltyAmount = 0.0,
    this.refundedAmount = 0.0,
    required this.currency,
    String? refundDestinationWalletCurrency,
    required this.captainPhone,
    required this.pierDockNumber,
    required this.status,
    this.cancellationReason,
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationPolicy = const ExperienceCancellationPolicy(),
    String? voucherCode,
    String? qrPayload,
  })  : refundDestinationWalletCurrency = refundDestinationWalletCurrency ?? currency,
        voucherCode = voucherCode ?? bookingId,
        qrPayload = qrPayload ?? 'ECARDO-MARINE-PASS-$bookingId-$boatId-$status';

  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get canCancel => !isCancelled && status != 'completed';

  ExperienceRefundCalculation calculateCancellationRefund({DateTime? atTime}) {
    return cancellationPolicy.calculateRefund(
      scheduledAt: date,
      totalAmount: totalAmount,
      currency: currency,
      requestTime: atTime,
    );
  }

  BoatBookingModel copyWithCancelled({
    required double penalty,
    required double refund,
    required String reason,
  }) {
    return BoatBookingModel(
      schemaVersion: schemaVersion,
      bookingId: bookingId,
      boatId: boatId,
      boatTitle: boatTitle,
      marinaName: marinaName,
      date: date,
      timeSlot: timeSlot,
      durationHours: durationHours,
      passengersCount: passengersCount,
      childrenCount: childrenCount,
      selectedAddonIds: selectedAddonIds,
      totalAmount: totalAmount,
      penaltyAmount: penalty,
      refundedAmount: refund,
      currency: currency,
      refundDestinationWalletCurrency: refundDestinationWalletCurrency,
      captainPhone: captainPhone,
      pierDockNumber: pierDockNumber,
      status: 'cancelled',
      cancellationReason: reason,
      bookedAt: bookedAt,
      cancelledAt: DateTime.now(),
      cancellationPolicy: cancellationPolicy,
      voucherCode: voucherCode,
      qrPayload: 'ECARDO-MARINE-PASS-$bookingId-$boatId-cancelled',
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'booking_id': bookingId,
        'boat_id': boatId,
        'boat_title': boatTitle,
        'marina_name': marinaName,
        'date': date.toIso8601String(),
        'time_slot': timeSlot,
        'duration_hours': durationHours,
        'passengers_count': passengersCount,
        'children_count': childrenCount,
        'selected_addon_ids': selectedAddonIds,
        'total_amount': totalAmount,
        'penalty_amount': penaltyAmount,
        'refunded_amount': refundedAmount,
        'currency': currency,
        'refund_destination_wallet_currency': refundDestinationWalletCurrency,
        'captain_phone': captainPhone,
        'pier_dock_number': pierDockNumber,
        'status': status,
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        'booked_at': bookedAt.toIso8601String(),
        if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
        'cancellation_policy': cancellationPolicy.toJson(),
        'voucher_code': voucherCode,
        'qr_payload': qrPayload,
      };

  factory BoatBookingModel.fromJson(Map<String, dynamic> json) {
    return BoatBookingModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      bookingId: json['booking_id'] as String? ?? '',
      boatId: json['boat_id'] as String? ?? '',
      boatTitle: json['boat_title'] as String? ?? '',
      marinaName: json['marina_name'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      timeSlot: json['time_slot'] as String? ?? '',
      durationHours: json['duration_hours'] as int? ?? 1,
      passengersCount: json['passengers_count'] as int? ?? 1,
      childrenCount: json['children_count'] as int? ?? 0,
      selectedAddonIds:
          (json['selected_addon_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              const [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refunded_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      refundDestinationWalletCurrency:
          json['refund_destination_wallet_currency'] as String? ?? 'USD',
      captainPhone: json['captain_phone'] as String? ?? '',
      pierDockNumber: json['pier_dock_number'] as String? ?? '',
      status: json['status'] as String? ?? 'confirmed',
      cancellationReason: json['cancellation_reason'] as String?,
      bookedAt: json['booked_at'] != null
          ? DateTime.parse(json['booked_at'] as String)
          : DateTime.now(),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationPolicy: json['cancellation_policy'] != null
          ? ExperienceCancellationPolicy.fromJson(
              Map<String, dynamic>.from(json['cancellation_policy'] as Map))
          : const ExperienceCancellationPolicy(),
      voucherCode: json['voucher_code'] as String?,
      qrPayload: json['qr_payload'] as String?,
    );
  }
}
