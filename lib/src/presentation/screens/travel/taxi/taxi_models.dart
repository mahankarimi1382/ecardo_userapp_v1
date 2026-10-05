import 'package:flutter/material.dart';

/// Service ride types supported by eCardo Airport Transfer & Taxi
enum TaxiRideType {
  airportTransfer,
  cityRide,
  intercity,
}

/// Airport transfer travel direction
enum AirportTransferDirection {
  fromAirport, // Flight arrival — meet passenger at airport
  toAirport,   // Flight departure — drop passenger at airport terminal
}

/// State enum covering all 14 mandatory UI states
enum TaxiUiState {
  defaultState,
  loading,
  skeleton,
  empty,
  partial,
  success,
  error,
  validationError,
  offline,
  unauthorized,
  processing,
  completed,
  cancelled,
  expired,
}

/// Ride booking operational status
enum RideBookingStatus {
  requested,
  findingDriver,
  driverAssigned,
  driverEnRoute,
  arrivedAtPickup,
  inProgress,
  completed,
  cancelled,
  expired;

  String get displayNameEn {
    switch (this) {
      case RideBookingStatus.requested:
        return 'Requested';
      case RideBookingStatus.findingDriver:
        return 'Matching Driver';
      case RideBookingStatus.driverAssigned:
        return 'Driver Assigned';
      case RideBookingStatus.driverEnRoute:
        return 'Driver En Route';
      case RideBookingStatus.arrivedAtPickup:
        return 'Driver Arrived';
      case RideBookingStatus.inProgress:
        return 'In Progress';
      case RideBookingStatus.completed:
        return 'Completed';
      case RideBookingStatus.cancelled:
        return 'Cancelled';
      case RideBookingStatus.expired:
        return 'Expired';
    }
  }

  String get displayNameFa {
    switch (this) {
      case RideBookingStatus.requested:
        return 'ثبت شده';
      case RideBookingStatus.findingDriver:
        return 'در حال تخصیص راننده';
      case RideBookingStatus.driverAssigned:
        return 'راننده مشخص شد';
      case RideBookingStatus.driverEnRoute:
        return 'راننده در مسیر مبدأ';
      case RideBookingStatus.arrivedAtPickup:
        return 'راننده به مبدأ رسید';
      case RideBookingStatus.inProgress:
        return 'در حال سفر';
      case RideBookingStatus.completed:
        return 'پایان سفر';
      case RideBookingStatus.cancelled:
        return 'لغو شده';
      case RideBookingStatus.expired:
        return 'منقضی شده';
    }
  }
}

/// Location / Airport / Saved place model
class RidePlace {
  final String id;
  final String title;
  final String titleFa;
  final String subtitle;
  final String subtitleFa;
  final String address;
  final double? latitude;
  final double? longitude;
  final String type; // airport, terminal, saved, recent, generic
  final String? iataCode;

  const RidePlace({
    required this.id,
    required this.title,
    this.titleFa = '',
    required this.subtitle,
    this.subtitleFa = '',
    required this.address,
    this.latitude,
    this.longitude,
    this.type = 'generic',
    this.iataCode,
  });

  String get localizedTitle => titleFa.isNotEmpty ? titleFa : title;
  String get localizedSubtitle => subtitleFa.isNotEmpty ? subtitleFa : subtitle;

  factory RidePlace.fromJson(Map<String, dynamic> json) {
    return RidePlace(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      titleFa: json['title_fa']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['city']?.toString() ?? '',
      subtitleFa: json['subtitle_fa']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['lat'] ?? json['latitude']) != null
          ? double.tryParse(json['lat']?.toString() ?? json['latitude']?.toString() ?? '')
          : null,
      longitude: (json['lng'] ?? json['longitude']) != null
          ? double.tryParse(json['lng']?.toString() ?? json['longitude']?.toString() ?? '')
          : null,
      type: json['type']?.toString() ?? 'generic',
      iataCode: json['iata_code']?.toString() ?? json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'title_fa': titleFa,
    'subtitle': subtitle,
    'subtitle_fa': subtitleFa,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'type': type,
    'iata_code': iataCode,
  };

  /// Common international airport hubs in the region
  static const List<RidePlace> popularAirportPlaces = [
    RidePlace(
      id: 'apt-ika-t1',
      title: 'Tehran Imam Khomeini Int. Airport (IKA) - T1',
      titleFa: 'فرودگاه بین‌المللی امام خمینی (ره) - ترمینال ۱',
      subtitle: 'Main International Terminal',
      subtitleFa: 'ترمینال اصلی پروازهای خارجی',
      address: 'Tehran-Qom Highway, km 30',
      latitude: 35.4161,
      longitude: 51.1522,
      type: 'airport',
      iataCode: 'IKA',
    ),
    RidePlace(
      id: 'apt-ika-cip',
      title: 'IKA International Airport - CIP Terminal',
      titleFa: 'فرودگاه امام خمینی - سالن اختصاصی تشریفات CIP',
      subtitle: 'VIP & CIP Fast Track Terminal',
      subtitleFa: 'جایگاه اختصاصی تشریفات تجاری',
      address: 'IKA Airport, CIP Dedicated Gate',
      latitude: 35.4190,
      longitude: 51.1600,
      type: 'airport',
      iataCode: 'IKA',
    ),
    RidePlace(
      id: 'apt-thr-t12',
      title: 'Tehran Mehrabad Airport (THR) - T1 & T2',
      titleFa: 'فرودگاه مهرآباد - ترمینال ۱ و ۲ (کیش‌ایر، زاگرس، آتا)',
      subtitle: 'Domestic Departure/Arrival',
      subtitleFa: 'پروازهای داخلی',
      address: 'Tehran, Meraj Blvd',
      latitude: 35.6892,
      longitude: 51.3134,
      type: 'airport',
      iataCode: 'THR',
    ),
    RidePlace(
      id: 'apt-thr-t46',
      title: 'Tehran Mehrabad Airport (THR) - T4 & T6',
      titleFa: 'فرودگاه مهرآباد - ترمینال ۴ و ۶ (ایران‌ایر، ماهان، آسمان)',
      subtitle: 'Domestic Main Departure & Arrival',
      subtitleFa: 'پروازهای داخلی ایران‌ایر و ماهان',
      address: 'Tehran, Meraj Blvd, North Terminals',
      latitude: 35.6920,
      longitude: 51.3150,
      type: 'airport',
      iataCode: 'THR',
    ),
    RidePlace(
      id: 'apt-dxb',
      title: 'Dubai International Airport (DXB)',
      titleFa: 'فرودگاه بین‌المللی دبی (DXB)',
      subtitle: 'Terminal 1, 2 & 3 Transfer',
      subtitleFa: 'ترمینال‌های ۱، ۲ و ۳ دبی',
      address: 'Dubai, United Arab Emirates',
      latitude: 25.2532,
      longitude: 55.3657,
      type: 'airport',
      iataCode: 'DXB',
    ),
    RidePlace(
      id: 'apt-ist',
      title: 'Istanbul Airport (IST)',
      titleFa: 'فرودگاه استانبول (IST)',
      subtitle: 'European Side Hub',
      subtitleFa: 'بخش اروپایی استانبول',
      address: 'Tayakadın, Istanbul, Turkey',
      latitude: 41.2753,
      longitude: 28.7519,
      type: 'airport',
      iataCode: 'IST',
    ),
  ];
}

/// Vehicle class definition from backend api/ride/vehicle-types
class TaxiVehicleClass {
  final String id;
  final String title;
  final String titleFa;
  final String titleEn;
  final String exampleModels;
  final int maxPassengers;
  final int maxLuggage;
  final int basePrice;
  final IconData icon;
  final List<String> features;
  final String? imageUrl;
  final bool hasChildSeatOption;
  final bool isVip;

  const TaxiVehicleClass({
    required this.id,
    required this.title,
    required this.titleFa,
    required this.titleEn,
    required this.exampleModels,
    required this.maxPassengers,
    required this.maxLuggage,
    required this.basePrice,
    required this.icon,
    this.features = const [],
    this.imageUrl,
    this.hasChildSeatOption = true,
    this.isVip = false,
  });

  factory TaxiVehicleClass.fromJson(Map<String, dynamic> json) {
    IconData pickIcon(String? iconKey) {
      switch (iconKey?.toLowerCase()) {
        case 'van':
        case 'bus':
        case 'minivan':
          return Icons.directions_bus_rounded;
        case 'vip':
        case 'luxury':
        case 'star':
          return Icons.stars_rounded;
        case 'shuttle':
        case 'comfort':
          return Icons.airport_shuttle_rounded;
        case 'economy':
        case 'car':
        default:
          return Icons.directions_car_rounded;
      }
    }

    return TaxiVehicleClass(
      id: json['id']?.toString() ?? 'economy',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Sedan',
      titleFa: json['title_fa']?.toString() ?? json['name_fa']?.toString() ?? 'سواری',
      titleEn: json['title_en']?.toString() ?? json['name_en']?.toString() ?? 'Sedan',
      exampleModels: json['example_models']?.toString() ?? json['models']?.toString() ?? '',
      maxPassengers: int.tryParse(json['max_passengers']?.toString() ?? '') ?? 4,
      maxLuggage: int.tryParse(json['max_luggage']?.toString() ?? '') ?? 2,
      basePrice: int.tryParse(json['base_price']?.toString() ?? '') ?? 0,
      icon: pickIcon(json['icon']?.toString() ?? json['code']?.toString()),
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      imageUrl: json['image_url']?.toString(),
      hasChildSeatOption: json['has_child_seat'] == true || json['child_seat_available'] == true,
      isVip: json['is_vip'] == true || json['code']?.toString().toLowerCase() == 'vip',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'title_fa': titleFa,
    'title_en': titleEn,
    'example_models': exampleModels,
    'max_passengers': maxPassengers,
    'max_luggage': maxLuggage,
    'base_price': basePrice,
    'features': features,
    'image_url': imageUrl,
    'has_child_seat': hasChildSeatOption,
    'is_vip': isVip,
  };
}

/// Specific quote for a vehicle class
class RideVehicleQuote {
  final TaxiVehicleClass vehicleClass;
  final int baseFare;
  final int meetAndGreetFee;
  final int childSeatFee;
  final int totalFare;
  final String currency;
  final int estimatedArrivalMins;
  final bool isGuaranteedFixedRate;

  const RideVehicleQuote({
    required this.vehicleClass,
    required this.baseFare,
    required this.meetAndGreetFee,
    required this.childSeatFee,
    required this.totalFare,
    this.currency = 'IRR',
    this.estimatedArrivalMins = 15,
    this.isGuaranteedFixedRate = true,
  });

  factory RideVehicleQuote.fromJson(Map<String, dynamic> json, TaxiVehicleClass vehicle) {
    return RideVehicleQuote(
      vehicleClass: vehicle,
      baseFare: int.tryParse(json['base_fare']?.toString() ?? '') ?? vehicle.basePrice,
      meetAndGreetFee: int.tryParse(json['meet_greet_fee']?.toString() ?? '') ?? 0,
      childSeatFee: int.tryParse(json['child_seat_fee']?.toString() ?? '') ?? 0,
      totalFare: int.tryParse(json['total_fare']?.toString() ?? '') ?? vehicle.basePrice,
      currency: json['currency']?.toString() ?? 'IRR',
      estimatedArrivalMins: int.tryParse(json['eta_minutes']?.toString() ?? '') ?? 15,
      isGuaranteedFixedRate: json['fixed_rate'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicleClass.id,
    'base_fare': baseFare,
    'meet_greet_fee': meetAndGreetFee,
    'child_seat_fee': childSeatFee,
    'total_fare': totalFare,
    'currency': currency,
    'eta_minutes': estimatedArrivalMins,
    'fixed_rate': isGuaranteedFixedRate,
  };
}

/// Result of api/ride/quote
class RideQuote {
  final String quoteId;
  final double distanceKm;
  final int durationMinutes;
  final List<RideVehicleQuote> vehicleQuotes;
  final DateTime expiresAt;
  final String currency;
  final bool isFixedPrice;

  const RideQuote({
    required this.quoteId,
    required this.distanceKm,
    required this.durationMinutes,
    required this.vehicleQuotes,
    required this.expiresAt,
    this.currency = 'IRR',
    this.isFixedPrice = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory RideQuote.fromJson(
    Map<String, dynamic> json,
    List<TaxiVehicleClass> availableVehicles,
  ) {
    final vehicleMap = {for (final v in availableVehicles) v.id: v};
    final quotesJson = json['quotes'] as List? ?? [];

    final quotes = <RideVehicleQuote>[];
    for (final q in quotesJson) {
      if (q is Map<String, dynamic>) {
        final vId = q['vehicle_id']?.toString() ?? '';
        final vehicle = vehicleMap[vId] ??
            TaxiVehicleClass.fromJson(q['vehicle'] as Map<String, dynamic>? ?? {});
        quotes.add(RideVehicleQuote.fromJson(q, vehicle));
      }
    }

    return RideQuote(
      quoteId: json['quote_id']?.toString() ?? 'quote-${DateTime.now().millisecondsSinceEpoch}',
      distanceKm: (double.tryParse(json['distance_km']?.toString() ?? '') ?? 45.0),
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 45,
      vehicleQuotes: quotes,
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
          DateTime.now().add(const Duration(minutes: 15)),
      currency: json['currency']?.toString() ?? 'IRR',
      isFixedPrice: json['is_fixed_price'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'quote_id': quoteId,
    'distance_km': distanceKm,
    'duration_minutes': durationMinutes,
    'quotes': vehicleQuotes.map((e) => e.toJson()).toList(),
    'expires_at': expiresAt.toIso8601String(),
    'currency': currency,
    'is_fixed_price': isFixedPrice,
  };
}

/// Assigned Driver & Vehicle Details
class RideDriverInfo {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final int totalTrips;
  final String vehicleModel;
  final String licensePlate;
  final String? color;
  final String? photoUrl;
  final double? currentLatitude;
  final double? currentLongitude;

  const RideDriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.rating = 4.95,
    this.totalTrips = 840,
    required this.vehicleModel,
    required this.licensePlate,
    this.color = 'سفید (White)',
    this.photoUrl,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory RideDriverInfo.fromJson(Map<String, dynamic> json) {
    return RideDriverInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 4.9,
      totalTrips: int.tryParse(json['total_trips']?.toString() ?? '') ?? 100,
      vehicleModel: json['vehicle_model']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      color: json['color']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      currentLatitude: double.tryParse(json['lat']?.toString() ?? ''),
      currentLongitude: double.tryParse(json['lng']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'rating': rating,
    'total_trips': totalTrips,
    'vehicle_model': vehicleModel,
    'license_plate': licensePlate,
    'color': color,
    'photo_url': photoUrl,
    'lat': currentLatitude,
    'lng': currentLongitude,
  };
}

/// Cancellation Policy Information
class RideCancellationPolicy {
  final DateTime freeCancellationDeadline;
  final double penaltyPercent;
  final int refundableAmount;
  final String refundWalletCurrency;
  final String policySummaryEn;
  final String policySummaryFa;

  const RideCancellationPolicy({
    required this.freeCancellationDeadline,
    required this.penaltyPercent,
    required this.refundableAmount,
    required this.refundWalletCurrency,
    required this.policySummaryEn,
    required this.policySummaryFa,
  });

  factory RideCancellationPolicy.standard({
    required DateTime pickupTime,
    required int totalFare,
    required String currency,
  }) {
    final now = DateTime.now();
    final freeCancelUntil = pickupTime.subtract(const Duration(hours: 24));
    final halfRefundUntil = pickupTime.subtract(const Duration(hours: 4));

    double penalty = 0.0;
    if (now.isAfter(halfRefundUntil)) {
      penalty = 1.0; // 100% penalty within 4h
    } else if (now.isAfter(freeCancelUntil)) {
      penalty = 0.5; // 50% penalty between 24h and 4h
    }

    final refundable = (totalFare * (1.0 - penalty)).toInt();

    return RideCancellationPolicy(
      freeCancellationDeadline: freeCancelUntil,
      penaltyPercent: penalty * 100,
      refundableAmount: refundable,
      refundWalletCurrency: currency,
      policySummaryEn: penalty == 0.0
          ? 'Free cancellation with 100% refund up to 24h before pickup.'
          : (penalty == 0.5
              ? '50% cancellation fee applies within 24h of pickup.'
              : 'Non-refundable within 4h of scheduled departure.'),
      policySummaryFa: penalty == 0.0
          ? 'لغو کاملاً رایگان با استرداد ۱۰۰٪ کرایه تا ۲۴ ساعت پیش از اعزام.'
          : (penalty == 0.5
              ? '۵۰٪ جریمه کنسلی در بازه ۲۴ تا ۴ ساعت مانده به سفر.'
              : 'غیرقابل استرداد در صورت لغو کمتر از ۴ ساعت مانده به پرواز.'),
    );
  }
}

/// Rating submission model
class RideRatingSubmission {
  final String rideId;
  final int stars; // 1 to 5
  final List<String> tags;
  final String comment;

  const RideRatingSubmission({
    required this.rideId,
    required this.stars,
    this.tags = const [],
    this.comment = '',
  });

  Map<String, dynamic> toJson() => {
    'ride_id': rideId,
    'rating': stars,
    'tags': tags,
    'comment': comment,
  };
}

/// Customer support ticket model
class RideSupportTicket {
  final String rideId;
  final String reference;
  final String subject;
  final String message;
  final String priority;

  const RideSupportTicket({
    required this.rideId,
    required this.reference,
    required this.subject,
    required this.message,
    this.priority = 'high',
  });

  Map<String, dynamic> toJson() => {
    'ride_id': rideId,
    'reference': reference,
    'subject': subject,
    'message': message,
    'priority': priority,
  };
}

/// Comprehensive Booking Entity
class TaxiBookingInfo {
  final String id;
  final String reference;
  final TaxiRideType rideType;
  final AirportTransferDirection transferDirection;
  final String origin;
  final String destination;
  final DateTime pickupDate;
  final String pickupTime;
  final String flightNumber;
  final String terminal;
  final String passengerName;
  final String passengerPhone;
  final int passengerCount;
  final int luggageCount;
  final int childSeatCount;
  final TaxiVehicleClass vehicle;
  final int totalFare;
  final String currency;
  final bool meetAndGreet;
  final String notes;
  final DateTime createdAt;
  final String status;
  final RideBookingStatus operationalStatus;
  final RideDriverInfo? driver;
  final String? walletTransactionId;
  final bool isFixedPrice;

  const TaxiBookingInfo({
    required this.id,
    required this.reference,
    required this.rideType,
    this.transferDirection = AirportTransferDirection.fromAirport,
    required this.origin,
    required this.destination,
    required this.pickupDate,
    required this.pickupTime,
    required this.flightNumber,
    this.terminal = '',
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerCount,
    required this.luggageCount,
    this.childSeatCount = 0,
    required this.vehicle,
    required this.totalFare,
    this.currency = 'IRR',
    required this.meetAndGreet,
    required this.notes,
    required this.createdAt,
    this.status = 'CONFIRMED',
    this.operationalStatus = RideBookingStatus.driverAssigned,
    this.driver,
    this.walletTransactionId,
    this.isFixedPrice = true,
  });

  factory TaxiBookingInfo.fromJson(
    Map<String, dynamic> json,
    TaxiVehicleClass vehicleFallback,
  ) {
    TaxiRideType parseRideType(String? raw) {
      switch (raw?.toLowerCase()) {
        case 'cityride':
        case 'city_ride':
          return TaxiRideType.cityRide;
        case 'intercity':
        case 'inter_city':
          return TaxiRideType.intercity;
        case 'airporttransfer':
        case 'airport_transfer':
        default:
          return TaxiRideType.airportTransfer;
      }
    }

    RideBookingStatus parseOperationalStatus(String? raw) {
      switch (raw?.toLowerCase()) {
        case 'requested':
        case 'pending':
          return RideBookingStatus.requested;
        case 'finding_driver':
        case 'searching':
          return RideBookingStatus.findingDriver;
        case 'driver_assigned':
        case 'confirmed':
          return RideBookingStatus.driverAssigned;
        case 'driver_en_route':
        case 'en_route':
          return RideBookingStatus.driverEnRoute;
        case 'arrived':
        case 'at_pickup':
          return RideBookingStatus.arrivedAtPickup;
        case 'in_progress':
        case 'on_trip':
          return RideBookingStatus.inProgress;
        case 'completed':
        case 'finished':
          return RideBookingStatus.completed;
        case 'cancelled':
        case 'rejected':
          return RideBookingStatus.cancelled;
        case 'expired':
          return RideBookingStatus.expired;
        default:
          return RideBookingStatus.driverAssigned;
      }
    }

    final vehicleJson = json['vehicle'];
    final vehicle = vehicleJson is Map<String, dynamic>
        ? TaxiVehicleClass.fromJson(vehicleJson)
        : vehicleFallback;

    final driverJson = json['driver'];
    final driver = driverJson is Map<String, dynamic>
        ? RideDriverInfo.fromJson(driverJson)
        : null;

    return TaxiBookingInfo(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      rideType: parseRideType(json['ride_type']?.toString()),
      transferDirection: json['direction']?.toString() == 'toAirport'
          ? AirportTransferDirection.toAirport
          : AirportTransferDirection.fromAirport,
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      pickupDate: DateTime.tryParse(json['pickup_date']?.toString() ?? '') ?? DateTime.now(),
      pickupTime: json['pickup_time']?.toString() ?? '10:00',
      flightNumber: json['flight_number']?.toString() ?? '',
      terminal: json['terminal']?.toString() ?? '',
      passengerName: json['passenger_name']?.toString() ?? 'مسافر',
      passengerPhone: json['passenger_phone']?.toString() ?? '',
      passengerCount: int.tryParse(json['passenger_count']?.toString() ?? '') ?? 1,
      luggageCount: int.tryParse(json['luggage_count']?.toString() ?? '') ?? 1,
      childSeatCount: int.tryParse(json['child_seat_count']?.toString() ?? '') ?? 0,
      vehicle: vehicle,
      totalFare: int.tryParse(json['total_fare']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'IRR',
      meetAndGreet: json['meet_and_greet'] == true,
      notes: json['notes']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'CONFIRMED',
      operationalStatus: parseOperationalStatus(json['operational_status']?.toString()),
      driver: driver,
      walletTransactionId: json['wallet_txn_id']?.toString(),
      isFixedPrice: json['is_fixed_price'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'ride_type': rideType.name,
    'direction': transferDirection.name,
    'origin': origin,
    'destination': destination,
    'pickup_date': pickupDate.toIso8601String(),
    'pickup_time': pickupTime,
    'flight_number': flightNumber,
    'terminal': terminal,
    'passenger_name': passengerName,
    'passenger_phone': passengerPhone,
    'passenger_count': passengerCount,
    'luggage_count': luggageCount,
    'child_seat_count': childSeatCount,
    'vehicle': vehicle.toJson(),
    'total_fare': totalFare,
    'currency': currency,
    'meet_and_greet': meetAndGreet,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'status': status,
    'operational_status': operationalStatus.name,
    'driver': driver?.toJson(),
    'wallet_txn_id': walletTransactionId,
    'is_fixed_price': isFixedPrice,
  };

  TaxiBookingInfo copyWith({
    String? id,
    String? reference,
    TaxiRideType? rideType,
    AirportTransferDirection? transferDirection,
    String? origin,
    String? destination,
    DateTime? pickupDate,
    String? pickupTime,
    String? flightNumber,
    String? terminal,
    String? passengerName,
    String? passengerPhone,
    int? passengerCount,
    int? luggageCount,
    int? childSeatCount,
    TaxiVehicleClass? vehicle,
    int? totalFare,
    String? currency,
    bool? meetAndGreet,
    String? notes,
    DateTime? createdAt,
    String? status,
    RideBookingStatus? operationalStatus,
    RideDriverInfo? driver,
    String? walletTransactionId,
    bool? isFixedPrice,
  }) {
    return TaxiBookingInfo(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      rideType: rideType ?? this.rideType,
      transferDirection: transferDirection ?? this.transferDirection,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      flightNumber: flightNumber ?? this.flightNumber,
      terminal: terminal ?? this.terminal,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerCount: passengerCount ?? this.passengerCount,
      luggageCount: luggageCount ?? this.luggageCount,
      childSeatCount: childSeatCount ?? this.childSeatCount,
      vehicle: vehicle ?? this.vehicle,
      totalFare: totalFare ?? this.totalFare,
      currency: currency ?? this.currency,
      meetAndGreet: meetAndGreet ?? this.meetAndGreet,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      driver: driver ?? this.driver,
      walletTransactionId: walletTransactionId ?? this.walletTransactionId,
      isFixedPrice: isFixedPrice ?? this.isFixedPrice,
    );
  }
}
