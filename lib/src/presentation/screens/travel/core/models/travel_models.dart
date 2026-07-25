enum TravelProductType { hotel, flight, esim }

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
  final TravelMoney total;
  final double rating;
  final List<String> featureKeys;
  final Map<String, String> metadata;

  const TravelOffer({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
    required this.total,
    required this.rating,
    required this.featureKeys,
    required this.metadata,
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
