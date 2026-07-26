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

class TravelHotelSearch {
  final String city;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int adultCount;
  final int childCount;

  const TravelHotelSearch({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.adultCount,
    required this.childCount,
  });
}

class TravelFlightSearch {
  final String? origin;
  final String? destination;
  final DateTime? departureDate;
  final int adultCount;
  final int childCount;

  const TravelFlightSearch({
    this.origin,
    this.destination,
    this.departureDate,
    this.adultCount = 1,
    this.childCount = 0,
  });
}

enum TravelOrderStatus {
  pending,
  confirmed,
  active,
  completed,
  refunded,
  failed,
}

class TravelBookingDetails {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int roomCount;
  final int adultCount;
  final int childCount;

  const TravelBookingDetails({
    this.checkInDate,
    this.checkOutDate,
    this.roomCount = 1,
    this.adultCount = 1,
    this.childCount = 0,
  });
}

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
  final DateTime createdAt;
  final Map<String, String> details;

  const TravelOrder({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.reference,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.details,
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
