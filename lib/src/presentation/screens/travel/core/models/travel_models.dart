enum TravelProductType { hotel, flight, esim }

class TravelBootstrap {
  final String currency;
  final String locale;
  final List<TravelServiceConfig> services;

  const TravelBootstrap({
    required this.currency,
    required this.locale,
    required this.services,
  });

  TravelServiceConfig? serviceFor(TravelProductType type) {
    for (final service in services) {
      if (service.type == type) return service;
    }
    return null;
  }
}

class TravelServiceConfig {
  final TravelProductType type;
  final String displayName;
  final String description;
  final String iconKey;
  final String accentColor;
  final List<String> capabilities;
  final List<TravelSearchField> searchFields;
  final Map<String, dynamic> presentation;
  final String dataMode;

  const TravelServiceConfig({
    required this.type,
    required this.displayName,
    required this.description,
    required this.iconKey,
    required this.accentColor,
    required this.capabilities,
    required this.searchFields,
    required this.presentation,
    required this.dataMode,
  });
}

class TravelSearchField {
  final String key;
  final String type;
  final String label;
  final String? hint;
  final bool required;
  final num? defaultValue;
  final num? minimum;
  final num? maximum;

  const TravelSearchField({
    required this.key,
    required this.type,
    required this.label,
    this.hint,
    required this.required,
    this.defaultValue,
    this.minimum,
    this.maximum,
  });
}

class TravelSuggestion {
  final String id;
  final String value;
  final String title;
  final String subtitle;
  final String kind;
  final Map<String, dynamic> metadata;

  const TravelSuggestion({
    required this.id,
    required this.value,
    required this.title,
    this.subtitle = '',
    this.kind = '',
    this.metadata = const {},
  });
}

class TravelHotelSearch {
  final String city;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int adultCount;
  final int childCount;
  final List<TravelRoomOccupancy> roomOccupancies;

  const TravelHotelSearch({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.adultCount,
    required this.childCount,
    this.roomOccupancies = const [],
  });

  Map<String, dynamic> toJson() => {
    'city': city,
    'check_in': checkInDate.toIso8601String(),
    'check_out': checkOutDate.toIso8601String(),
    'rooms': roomCount,
    'adults': adultCount,
    'children': childCount,
    if (roomOccupancies.isNotEmpty)
      'room_occupancies': roomOccupancies.map((room) => room.toJson()).toList(),
  };

  factory TravelHotelSearch.fromJson(Map<String, dynamic> json) {
    return TravelHotelSearch(
      city: json['city']?.toString() ?? '',
      checkInDate:
          DateTime.tryParse(json['check_in']?.toString() ?? '') ??
          DateTime.now(),
      checkOutDate:
          DateTime.tryParse(json['check_out']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      roomCount: int.tryParse(json['rooms']?.toString() ?? '') ?? 1,
      adultCount: int.tryParse(json['adults']?.toString() ?? '') ?? 1,
      childCount: int.tryParse(json['children']?.toString() ?? '') ?? 0,
      roomOccupancies: (json['room_occupancies'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (room) =>
                TravelRoomOccupancy.fromJson(Map<String, dynamic>.from(room)),
          )
          .toList(),
    );
  }
}

class TravelRoomOccupancy {
  final int adults;
  final int children;

  const TravelRoomOccupancy({this.adults = 1, this.children = 0});

  Map<String, dynamic> toJson() => {'adults': adults, 'children': children};

  factory TravelRoomOccupancy.fromJson(Map<String, dynamic> json) =>
      TravelRoomOccupancy(
        adults: int.tryParse(json['adults']?.toString() ?? '') ?? 1,
        children: int.tryParse(json['children']?.toString() ?? '') ?? 0,
      );
}

class TravelFlightSearch {
  final String? origin;
  final String? destination;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final String cabinClass;

  const TravelFlightSearch({
    this.origin,
    this.destination,
    this.departureDate,
    this.returnDate,
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
    this.cabinClass = '',
  });

  Map<String, dynamic> toJson() => {
    'origin': origin,
    'destination': destination,
    'departure': departureDate?.toIso8601String(),
    'return': returnDate?.toIso8601String(),
    'adults': adultCount,
    'children': childCount,
    'infants': infantCount,
    'cabin_class': cabinClass,
  };

  factory TravelFlightSearch.fromJson(Map<String, dynamic> json) {
    return TravelFlightSearch(
      origin: json['origin']?.toString(),
      destination: json['destination']?.toString(),
      departureDate: DateTime.tryParse(json['departure']?.toString() ?? ''),
      returnDate: DateTime.tryParse(json['return']?.toString() ?? ''),
      adultCount: int.tryParse(json['adults']?.toString() ?? '') ?? 1,
      childCount: int.tryParse(json['children']?.toString() ?? '') ?? 0,
      infantCount: int.tryParse(json['infants']?.toString() ?? '') ?? 0,
      cabinClass: json['cabin_class']?.toString() ?? '',
    );
  }

  bool get isRoundTrip => returnDate != null;
}

enum TravelOrderStatus {
  paymentPending,
  paymentProcessing,
  paymentReceived,
  supplierPending,
  confirmed,
  issued,
  active,
  completed,
  cancellationPending,
  refundPending,
  cancelled,
  refunded,
  failed,
  expired,
  unknown,
}

enum TravelOrderGroup { attention, upcoming, completed, cancellation }

TravelOrderStatus travelOrderStatusFromRaw(String rawStatus) {
  return switch (rawStatus.trim().toLowerCase()) {
    'quoted' || 'pending_payment' => TravelOrderStatus.paymentPending,
    'wallet_processing' ||
    'wallet_locked' => TravelOrderStatus.paymentProcessing,
    'paid_pending_admin_approval' ||
    'paid_pending_operations_check' => TravelOrderStatus.paymentReceived,
    'pending_purchase' ||
    'pending_operator' ||
    'manual_review' ||
    'provider_processing' ||
    'reserved' ||
    'paid_pending_operations_check' ||
    'processing' ||
    'pending' => TravelOrderStatus.supplierPending,
    'booked' || 'confirmed' => TravelOrderStatus.confirmed,
    'voucher_generated' ||
    'ticketed' ||
    'issued' ||
    'ready' => TravelOrderStatus.issued,
    'active' => TravelOrderStatus.active,
    'completed' => TravelOrderStatus.completed,
    'cancel_requested' ||
    'cancellation_requested' => TravelOrderStatus.cancellationPending,
    'refund_requested' ||
    'refund_pending' ||
    'refund_processing' => TravelOrderStatus.refundPending,
    'cancelled' || 'canceled' => TravelOrderStatus.cancelled,
    'refunded' => TravelOrderStatus.refunded,
    'failed' || 'rejected' => TravelOrderStatus.failed,
    'expired' ||
    'payment_expired' ||
    'reservation_expired' => TravelOrderStatus.expired,
    _ => TravelOrderStatus.unknown,
  };
}

class TravelBookingDetails {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int roomCount;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final String roomId;
  final String roomName;
  final String returnOfferId;
  final String cabinClass;
  final String beneficiaryType;
  final String beneficiaryName;
  final List<TravelPassenger> passengers;
  final TravelNotificationContact? notificationContact;
  final List<TravelRoomOccupancy> roomOccupancies;
  final List<TravelSelectedRoom> selectedRooms;
  final List<TravelRoomGuest> roomGuests;
  final String specialRequests;

  const TravelBookingDetails({
    this.checkInDate,
    this.checkOutDate,
    this.roomCount = 1,
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
    this.roomId = '',
    this.roomName = '',
    this.returnOfferId = '',
    this.cabinClass = '',
    this.beneficiaryType = 'self',
    this.beneficiaryName = '',
    this.passengers = const [],
    this.notificationContact,
    this.roomOccupancies = const [],
    this.selectedRooms = const [],
    this.roomGuests = const [],
    this.specialRequests = '',
  });

  TravelBookingDetails copyWith({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? roomCount,
    int? adultCount,
    int? childCount,
    int? infantCount,
    String? roomId,
    String? roomName,
    String? returnOfferId,
    String? cabinClass,
    String? beneficiaryType,
    String? beneficiaryName,
    List<TravelPassenger>? passengers,
    TravelNotificationContact? notificationContact,
    List<TravelRoomOccupancy>? roomOccupancies,
    List<TravelSelectedRoom>? selectedRooms,
    List<TravelRoomGuest>? roomGuests,
    String? specialRequests,
  }) {
    return TravelBookingDetails(
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      roomCount: roomCount ?? this.roomCount,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      infantCount: infantCount ?? this.infantCount,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      returnOfferId: returnOfferId ?? this.returnOfferId,
      cabinClass: cabinClass ?? this.cabinClass,
      beneficiaryType: beneficiaryType ?? this.beneficiaryType,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      passengers: passengers ?? this.passengers,
      notificationContact: notificationContact ?? this.notificationContact,
      roomOccupancies: roomOccupancies ?? this.roomOccupancies,
      selectedRooms: selectedRooms ?? this.selectedRooms,
      roomGuests: roomGuests ?? this.roomGuests,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }
}

class TravelSelectedRoom {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String currency;

  const TravelSelectedRoom({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    'room_id': id,
    'room_name': name,
    'quantity': quantity,
    'unit_price': unitPrice,
    'currency': currency,
  };
}

class TravelRoomGuest {
  final String roomId;
  final int roomIndex;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  const TravelRoomGuest({
    required this.roomId,
    required this.roomIndex,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  bool get isComplete =>
      firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    'room_id': roomId,
    'room_index': roomIndex,
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    if (phone.trim().isNotEmpty) 'phone': phone.trim(),
    if (email.trim().isNotEmpty) 'email': email.trim(),
  };
}

class TravelPassenger {
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String gender;
  final String nationalityCode;
  final String passportNumber;
  final DateTime? passportExpiry;
  final String type;

  const TravelPassenger({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.nationalityCode,
    required this.passportNumber,
    required this.passportExpiry,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    if (birthDate != null) 'birth_date': _travelDate(birthDate!),
    if (gender.isNotEmpty) 'gender': gender,
    'nationality_code': nationalityCode.toUpperCase(),
    'passport_number': passportNumber,
    if (passportExpiry != null) 'passport_expiry': _travelDate(passportExpiry!),
    'type': type,
  };

  String get fullName => '$firstName $lastName'.trim();

  bool get isComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      birthDate != null &&
      nationalityCode.trim().length == 2 &&
      passportNumber.trim().isNotEmpty &&
      passportExpiry?.isAfter(DateTime.now()) == true &&
      {'adult', 'child', 'infant'}.contains(type);
}

class TravelTravelerProfile {
  final bool complete;
  final TravelPassenger? passenger;
  final String phone;

  const TravelTravelerProfile({
    required this.complete,
    this.passenger,
    this.phone = '',
  });
}

class TravelNotificationContact {
  final String phone;
  final String email;

  const TravelNotificationContact({this.phone = '', this.email = ''});

  bool get isValid => phone.trim().isNotEmpty || email.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    if (phone.trim().isNotEmpty) 'phone': phone.trim(),
    if (email.trim().isNotEmpty) 'email': email.trim(),
  };
}

String _travelDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class TravelMoney {
  final double amount;
  final String currency;

  const TravelMoney({required this.amount, required this.currency});
}

class TravelOffer {
  final String id;
  final TravelProductType type;
  final String titleKey;
  final String subtitleKey;
  final String badgeKey;
  final String imageUrl;
  final TravelMoney total;
  final double rating;
  final List<String> featureKeys;
  final Map<String, String> metadata;
  final Map<String, dynamic> product;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> policies;
  final List<Map<String, dynamic>> actions;
  final List<Map<String, dynamic>> pricingComponents;

  const TravelOffer({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
    this.imageUrl = '',
    required this.total,
    required this.rating,
    required this.featureKeys,
    required this.metadata,
    this.product = const {},
    this.attributes = const {},
    this.policies = const {},
    this.actions = const [],
    this.pricingComponents = const [],
  });
}

class TravelEsimPackage {
  final String id;
  final String destinationCode;
  final String dataLabel;
  final int validityDays;
  final TravelMoney total;
  final bool isPopular;

  const TravelEsimPackage({
    required this.id,
    required this.destinationCode,
    required this.dataLabel,
    required this.validityDays,
    required this.total,
    this.isPopular = false,
  });
}

class TravelTraveler {
  final String id;
  final String fullName;
  final String passportNumber;
  final String nationalityCode;

  const TravelTraveler({
    required this.id,
    required this.fullName,
    required this.passportNumber,
    required this.nationalityCode,
  });
}

class TravelOrder {
  final String id;
  final TravelProductType type;
  final String titleKey;
  final String reference;
  final TravelMoney total;
  final TravelOrderStatus status;
  final String rawStatus;
  final DateTime createdAt;
  final Map<String, String> details;

  const TravelOrder({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.reference,
    required this.total,
    required this.status,
    this.rawStatus = '',
    required this.createdAt,
    required this.details,
  });

  String get effectiveRawStatus {
    if (rawStatus.isNotEmpty) return rawStatus;
    return details['raw_status']?.trim().toLowerCase() ?? '';
  }

  bool get hasIssuedVoucher {
    if (type == TravelProductType.esim) return false;
    if ({
      TravelOrderStatus.cancellationPending,
      TravelOrderStatus.refundPending,
      TravelOrderStatus.cancelled,
      TravelOrderStatus.refunded,
      TravelOrderStatus.failed,
      TravelOrderStatus.expired,
      TravelOrderStatus.unknown,
    }.contains(status)) {
      return false;
    }
    return status == TravelOrderStatus.issued ||
        details['voucher_number']?.trim().isNotEmpty == true;
  }

  bool get canRequestCancellation =>
      type != TravelProductType.esim &&
      {'booked', 'voucher_generated'}.contains(effectiveRawStatus);

  bool get hasReadyEsimActivation =>
      type == TravelProductType.esim &&
      {
        TravelOrderStatus.issued,
        TravelOrderStatus.active,
        TravelOrderStatus.completed,
      }.contains(status);

  TravelOrderGroup get group => switch (status) {
    TravelOrderStatus.paymentPending ||
    TravelOrderStatus.paymentProcessing ||
    TravelOrderStatus.paymentReceived ||
    TravelOrderStatus.supplierPending ||
    TravelOrderStatus.failed ||
    TravelOrderStatus.expired ||
    TravelOrderStatus.unknown => TravelOrderGroup.attention,
    TravelOrderStatus.confirmed ||
    TravelOrderStatus.issued ||
    TravelOrderStatus.active => TravelOrderGroup.upcoming,
    TravelOrderStatus.completed => TravelOrderGroup.completed,
    TravelOrderStatus.cancellationPending ||
    TravelOrderStatus.refundPending ||
    TravelOrderStatus.cancelled ||
    TravelOrderStatus.refunded => TravelOrderGroup.cancellation,
  };
}

class TravelReservation {
  final String id;
  final String orderNumber;
  final String title;
  final TravelProductType type;
  final TravelMoney total;
  final DateTime expiresAt;

  const TravelReservation({
    required this.id,
    required this.orderNumber,
    required this.title,
    required this.type,
    required this.total,
    required this.expiresAt,
  });
}

class TravelActivity {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final TravelMoney amount;
  final bool isCredit;
  final DateTime createdAt;
  final TravelProductType? type;

  const TravelActivity({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.amount,
    required this.isCredit,
    required this.createdAt,
    this.type,
  });
}
