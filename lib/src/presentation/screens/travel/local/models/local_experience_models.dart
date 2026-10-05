// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/foundation.dart';
import 'experience_contracts.dart';

enum LocalServiceType {
  tourGuide,
  photographer,
  chauffeur,
  meetAndGreet,
  translator,
  attractionTicket;

  String get wireName {
    switch (this) {
      case LocalServiceType.tourGuide:
        return 'tour_guide';
      case LocalServiceType.photographer:
        return 'photographer';
      case LocalServiceType.chauffeur:
        return 'chauffeur';
      case LocalServiceType.meetAndGreet:
        return 'meet_and_greet';
      case LocalServiceType.translator:
        return 'translator';
      case LocalServiceType.attractionTicket:
        return 'attraction_ticket';
    }
  }

  static LocalServiceType fromWireName(String? name) {
    switch (name) {
      case 'photographer':
        return LocalServiceType.photographer;
      case 'chauffeur':
        return LocalServiceType.chauffeur;
      case 'meet_and_greet':
        return LocalServiceType.meetAndGreet;
      case 'translator':
        return LocalServiceType.translator;
      case 'attraction_ticket':
        return LocalServiceType.attractionTicket;
      case 'tour_guide':
      default:
        return LocalServiceType.tourGuide;
    }
  }
}

@immutable
class LocalExperienceItemModel {
  final String schemaVersion;
  final String id;
  final String title;
  final String subtitle;
  final String providerName;
  final String city;
  final LocalServiceType type;
  final double price;
  final double childPrice;
  final String currency;
  final ExperiencePricingType pricingType;
  final String durationLabel;
  final int durationMinutes;
  final List<String> languages;
  final double rating;
  final int reviewsCount;
  final List<String> highlights;
  final String meetingPoint;
  final String description;
  final List<String> images;
  final int minGuests;
  final int maxGuests;
  final int remainingCapacity;
  final List<String> availableTimeSlots;
  final bool skipTheLine;
  final bool freeCancellation;
  final ExperienceCancellationPolicy cancellationPolicy;

  const LocalExperienceItemModel({
    this.schemaVersion = '1.0',
    required this.id,
    required this.title,
    required this.subtitle,
    required this.providerName,
    required this.city,
    required this.type,
    required this.price,
    this.childPrice = 0.0,
    required this.currency,
    this.pricingType = ExperiencePricingType.perPerson,
    required this.durationLabel,
    this.durationMinutes = 240,
    required this.languages,
    required this.rating,
    required this.reviewsCount,
    required this.highlights,
    required this.meetingPoint,
    required this.description,
    this.images = const [],
    this.minGuests = 1,
    this.maxGuests = 12,
    this.remainingCapacity = 8,
    this.availableTimeSlots = const ['09:00', '11:00', '14:00', '16:30'],
    this.skipTheLine = false,
    this.freeCancellation = true,
    this.cancellationPolicy = const ExperienceCancellationPolicy(
      freeCancellationHours: 24,
      lateCancelPenaltyPercent: 0.0,
    ),
  });

  String get typeLabel {
    switch (type) {
      case LocalServiceType.tourGuide:
        return 'راهنمای تور محلی (Tour Guide)';
      case LocalServiceType.photographer:
        return 'عکاس حرفه‌ای سفر (Photographer)';
      case LocalServiceType.chauffeur:
        return 'راننده منتسب اختصاصی (Chauffeur)';
      case LocalServiceType.meetAndGreet:
        return 'همراهی فرودگاه (Meet & Greet)';
      case LocalServiceType.translator:
        return 'مترجم همزمان تجاری (Interpreter)';
      case LocalServiceType.attractionTicket:
        return 'بلیت جاذبه و موزه (Attraction Ticket)';
    }
  }

  bool hasCapacityFor(int adults, int children) =>
      (adults + children) <= remainingCapacity && (adults + children) >= minGuests;

  /// perPerson → (adult*price + child*childPrice) ; perGroup → flat price.
  double calculateTotal({required int adults, int children = 0}) {
    if (pricingType == ExperiencePricingType.perGroup ||
        type == LocalServiceType.photographer ||
        type == LocalServiceType.chauffeur) {
      return price;
    }
    final effectiveChildPrice = childPrice > 0 ? childPrice : price * 0.5;
    return price * adults + effectiveChildPrice * children;
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'provider_name': providerName,
        'city': city,
        'type': type.wireName,
        'price': price,
        'child_price': childPrice,
        'currency': currency,
        'pricing_type': pricingType.wireName,
        'duration_label': durationLabel,
        'duration_minutes': durationMinutes,
        'languages': languages,
        'rating': rating,
        'reviews_count': reviewsCount,
        'highlights': highlights,
        'meeting_point': meetingPoint,
        'description': description,
        'images': images,
        'min_guests': minGuests,
        'max_guests': maxGuests,
        'remaining_capacity': remainingCapacity,
        'available_time_slots': availableTimeSlots,
        'skip_the_line': skipTheLine,
        'free_cancellation': freeCancellation,
        'cancellation_policy': cancellationPolicy.toJson(),
      };

  factory LocalExperienceItemModel.fromJson(Map<String, dynamic> json) {
    return LocalExperienceItemModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      type: LocalServiceType.fromWireName(json['type'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      childPrice: (json['child_price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      pricingType: ExperiencePricingType.fromWireName(json['pricing_type'] as String?),
      durationLabel: json['duration_label'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 240,
      languages:
          (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      highlights:
          (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      meetingPoint: json['meeting_point'] as String? ?? '',
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      minGuests: json['min_guests'] as int? ?? 1,
      maxGuests: json['max_guests'] as int? ?? 12,
      remainingCapacity: json['remaining_capacity'] as int? ?? 8,
      availableTimeSlots: (json['available_time_slots'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['09:00', '11:00', '14:00'],
      skipTheLine: json['skip_the_line'] as bool? ?? false,
      freeCancellation: json['free_cancellation'] as bool? ?? true,
      cancellationPolicy: json['cancellation_policy'] != null
          ? ExperienceCancellationPolicy.fromJson(
              Map<String, dynamic>.from(json['cancellation_policy'] as Map))
          : const ExperienceCancellationPolicy(lateCancelPenaltyPercent: 0.0),
    );
  }
}

@immutable
class LocalBookingModel {
  final String schemaVersion;
  final String bookingId;
  final String serviceId;
  final String serviceTitle;
  final String providerName;
  final String city;
  final DateTime serviceDate;
  final String serviceTime;
  final int guestsCount;
  final int childrenCount;
  final double totalAmount;
  final double penaltyAmount;
  final double refundedAmount;
  final String currency;
  final String refundDestinationWalletCurrency;
  final String meetingPoint;
  final String providerPhone;
  final String status; // confirmed, active, completed, cancelled, refunded
  final String? cancellationReason;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final ExperienceCancellationPolicy cancellationPolicy;
  final String voucherCode;
  final String qrPayload;

  const LocalBookingModel({
    this.schemaVersion = '1.0',
    required this.bookingId,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerName,
    required this.city,
    required this.serviceDate,
    required this.serviceTime,
    required this.guestsCount,
    this.childrenCount = 0,
    required this.totalAmount,
    this.penaltyAmount = 0.0,
    this.refundedAmount = 0.0,
    required this.currency,
    String? refundDestinationWalletCurrency,
    required this.meetingPoint,
    required this.providerPhone,
    required this.status,
    this.cancellationReason,
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationPolicy = const ExperienceCancellationPolicy(
      freeCancellationHours: 24,
      lateCancelPenaltyPercent: 0.0,
    ),
    String? voucherCode,
    String? qrPayload,
  })  : refundDestinationWalletCurrency = refundDestinationWalletCurrency ?? currency,
        voucherCode = voucherCode ?? bookingId,
        qrPayload = qrPayload ?? 'ECARDO-LOCAL-PASS-$bookingId-$serviceId-$status';

  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get canCancel => !isCancelled && status != 'completed';

  DateTime get scheduledDateTime =>
      serviceDate.add(Duration(hours: int.tryParse(serviceTime.split(':').first) ?? 9));

  ExperienceRefundCalculation calculateCancellationRefund({DateTime? atTime}) {
    return cancellationPolicy.calculateRefund(
      scheduledAt: scheduledDateTime,
      totalAmount: totalAmount,
      currency: currency,
      requestTime: atTime,
    );
  }

  LocalBookingModel copyWithCancelled({
    required double penalty,
    required double refund,
    required String reason,
  }) {
    return LocalBookingModel(
      schemaVersion: schemaVersion,
      bookingId: bookingId,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      providerName: providerName,
      city: city,
      serviceDate: serviceDate,
      serviceTime: serviceTime,
      guestsCount: guestsCount,
      childrenCount: childrenCount,
      totalAmount: totalAmount,
      penaltyAmount: penalty,
      refundedAmount: refund,
      currency: currency,
      refundDestinationWalletCurrency: refundDestinationWalletCurrency,
      meetingPoint: meetingPoint,
      providerPhone: providerPhone,
      status: 'cancelled',
      cancellationReason: reason,
      bookedAt: bookedAt,
      cancelledAt: DateTime.now(),
      cancellationPolicy: cancellationPolicy,
      voucherCode: voucherCode,
      qrPayload: 'ECARDO-LOCAL-PASS-$bookingId-$serviceId-cancelled',
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'booking_id': bookingId,
        'service_id': serviceId,
        'service_title': serviceTitle,
        'provider_name': providerName,
        'city': city,
        'service_date': serviceDate.toIso8601String(),
        'service_time': serviceTime,
        'guests_count': guestsCount,
        'children_count': childrenCount,
        'total_amount': totalAmount,
        'penalty_amount': penaltyAmount,
        'refunded_amount': refundedAmount,
        'currency': currency,
        'refund_destination_wallet_currency': refundDestinationWalletCurrency,
        'meeting_point': meetingPoint,
        'provider_phone': providerPhone,
        'status': status,
        if (cancellationReason != null) 'cancellation_reason': cancellationReason,
        'booked_at': bookedAt.toIso8601String(),
        if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
        'cancellation_policy': cancellationPolicy.toJson(),
        'voucher_code': voucherCode,
        'qr_payload': qrPayload,
      };

  factory LocalBookingModel.fromJson(Map<String, dynamic> json) {
    return LocalBookingModel(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      bookingId: json['booking_id'] as String? ?? '',
      serviceId: json['service_id'] as String? ?? '',
      serviceTitle: json['service_title'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      serviceDate: json['service_date'] != null
          ? DateTime.parse(json['service_date'] as String)
          : DateTime.now(),
      serviceTime: json['service_time'] as String? ?? '09:00',
      guestsCount: json['guests_count'] as int? ?? 1,
      childrenCount: json['children_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refunded_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      refundDestinationWalletCurrency:
          json['refund_destination_wallet_currency'] as String? ?? 'USD',
      meetingPoint: json['meeting_point'] as String? ?? '',
      providerPhone: json['provider_phone'] as String? ?? '',
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
          : const ExperienceCancellationPolicy(lateCancelPenaltyPercent: 0.0),
      voucherCode: json['voucher_code'] as String?,
      qrPayload: json['qr_payload'] as String?,
    );
  }
}
