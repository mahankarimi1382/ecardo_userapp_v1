/// Car Rental Service models — Car-Rental-Service-Flow.md

class CarModel {
  final int id;
  final String ownerType;
  final String title;
  final String? brand;
  final String? model;
  final String category;
  final String? transmission;
  final double dailyPrice;
  final double depositAmount;
  final int dailyKmLimit;
  final double extraKmRate;
  final int minAge;
  final int minLicenseYears;
  final List<Map<String, dynamic>> insuranceTiers;
  final String? pickupLocation;
  final List<dynamic> photos;
  final List<dynamic> features;
  final bool isActive;

  const CarModel({
    required this.id,
    required this.ownerType,
    required this.title,
    this.brand,
    this.model,
    required this.category,
    this.transmission,
    required this.dailyPrice,
    required this.depositAmount,
    required this.dailyKmLimit,
    required this.extraKmRate,
    required this.minAge,
    required this.minLicenseYears,
    required this.insuranceTiers,
    this.pickupLocation,
    required this.photos,
    required this.features,
    required this.isActive,
  });

  bool get isFleet => ownerType == 'FLEET';

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      ownerType: json['owner_type']?.toString() ?? 'FLEET',
      title: json['title']?.toString() ?? '',
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      category: json['category']?.toString() ?? 'ECONOMY',
      transmission: json['transmission']?.toString(),
      dailyPrice: (json['daily_price'] as num?)?.toDouble() ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      dailyKmLimit: (json['daily_km_limit'] as num?)?.toInt() ?? 200,
      extraKmRate: (json['extra_km_rate'] as num?)?.toDouble() ?? 0,
      minAge: (json['min_age'] as num?)?.toInt() ?? 21,
      minLicenseYears: (json['min_license_years'] as num?)?.toInt() ?? 1,
      insuranceTiers: ((json['insurance_tiers'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      pickupLocation: json['pickup_location']?.toString(),
      photos: (json['photos'] as List?) ?? [],
      features: (json['features'] as List?) ?? [],
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class DriverDocModel {
  final int id;
  final String driverRole;
  final String status;
  final String? reviewerNote;
  final String? licenseRef;

  const DriverDocModel({
    required this.id,
    required this.driverRole,
    required this.status,
    this.reviewerNote,
    this.licenseRef,
  });

  factory DriverDocModel.fromJson(Map<String, dynamic> json) {
    return DriverDocModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      driverRole: json['driver_role']?.toString() ?? 'PRIMARY',
      status: json['status']?.toString() ?? 'PENDING',
      reviewerNote: json['reviewer_note']?.toString(),
      licenseRef: json['license_ref']?.toString(),
    );
  }
}

class RentalDepositModel {
  final int id;
  final double amount;
  final String currency;
  final String status;
  final double releasedAmount;
  final double consumedAmount;

  const RentalDepositModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.releasedAmount,
    required this.consumedAmount,
  });

  double get balance => amount - releasedAmount - consumedAmount;

  factory RentalDepositModel.fromJson(Map<String, dynamic> json) {
    return RentalDepositModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'IRT',
      status: json['status']?.toString() ?? 'LOCKED',
      releasedAmount: (json['released_amount'] as num?)?.toDouble() ?? 0,
      consumedAmount: (json['consumed_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RentalHandoverModel {
  final int id;
  final String phase;
  final int odometer;
  final int fuelPct;
  final int? cleanlinessPct;
  final int? signedByRenter;
  final int? signedByHost;
  final List<Map<String, dynamic>> diffReport;

  const RentalHandoverModel({
    required this.id,
    required this.phase,
    required this.odometer,
    required this.fuelPct,
    this.cleanlinessPct,
    this.signedByRenter,
    this.signedByHost,
    required this.diffReport,
  });

  bool get isSignedByBoth => signedByRenter != null && signedByHost != null;

  factory RentalHandoverModel.fromJson(Map<String, dynamic> json) {
    return RentalHandoverModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phase: json['phase']?.toString() ?? 'PICKUP',
      odometer: (json['odometer'] as num?)?.toInt() ?? 0,
      fuelPct: (json['fuel_pct'] as num?)?.toInt() ?? 100,
      cleanlinessPct: (json['cleanliness_pct'] as num?)?.toInt(),
      signedByRenter: (json['signed_by_renter'] as num?)?.toInt(),
      signedByHost: (json['signed_by_host'] as num?)?.toInt(),
      diffReport: ((json['diff_report'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class DamageClaimModel {
  final int id;
  final String byRole;
  final String type;
  final double amount;
  final String status;

  const DamageClaimModel({
    required this.id,
    required this.byRole,
    required this.type,
    required this.amount,
    required this.status,
  });

  factory DamageClaimModel.fromJson(Map<String, dynamic> json) {
    return DamageClaimModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      byRole: json['by_role']?.toString() ?? 'HOST',
      type: json['type']?.toString() ?? 'damage',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'OPEN',
    );
  }
}

class RentalBookingModel {
  final int id;
  final String bookingNo;
  final CarModel? car;
  final DateTime? pickupAt;
  final DateTime? returnAt;
  final String? pickupLocation;
  final Map<String, dynamic>? extras;
  final String insuranceTier;
  final double rentalTotal;
  final double extrasTotal;
  final String status;
  final DateTime? priceLockExpiresAt;
  final RentalDepositModel? deposit;
  final List<DriverDocModel> driverDocs;
  final List<RentalHandoverModel> handovers;
  final List<DamageClaimModel> claims;
  final List<RentalEventModel> events;

  const RentalBookingModel({
    required this.id,
    required this.bookingNo,
    this.car,
    this.pickupAt,
    this.returnAt,
    this.pickupLocation,
    this.extras,
    required this.insuranceTier,
    required this.rentalTotal,
    required this.extrasTotal,
    required this.status,
    this.priceLockExpiresAt,
    this.deposit,
    this.driverDocs = const [],
    this.handovers = const [],
    this.claims = const [],
    required this.events,
  });

  double get grandTotal => rentalTotal + extrasTotal;

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) {
    return RentalBookingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingNo: json['booking_no']?.toString() ?? '',
      car: json['car'] is Map<String, dynamic>
          ? CarModel.fromJson(json['car'] as Map<String, dynamic>)
          : null,
      pickupAt: json['pickup_at'] != null ? DateTime.tryParse(json['pickup_at'].toString()) : null,
      returnAt: json['return_at'] != null ? DateTime.tryParse(json['return_at'].toString()) : null,
      pickupLocation: json['pickup_location']?.toString(),
      extras: json['extras'] is Map<String, dynamic>
          ? json['extras'] as Map<String, dynamic>
          : null,
      insuranceTier: json['insurance_tier']?.toString() ?? 'BASIC',
      rentalTotal: (json['rental_total'] as num?)?.toDouble() ?? 0,
      extrasTotal: (json['extras_total'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      priceLockExpiresAt: json['price_lock_expires_at'] != null
          ? DateTime.tryParse(json['price_lock_expires_at'].toString())
          : null,
      deposit: json['deposit'] is Map<String, dynamic>
          ? RentalDepositModel.fromJson(json['deposit'] as Map<String, dynamic>)
          : null,
      driverDocs: ((json['driver_docs'] as List?) ?? [])
          .map((e) => DriverDocModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      handovers: ((json['handovers'] as List?) ?? [])
          .map((e) => RentalHandoverModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      claims: ((json['claims'] as List?) ?? [])
          .map((e) => DamageClaimModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      events: ((json['events'] as List?) ?? [])
          .map((e) => RentalEventModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class RentalEventModel {
  final int id;
  final String actorRole;
  final String? reason;
  final DateTime? createdAt;

  const RentalEventModel({
    required this.id,
    required this.actorRole,
    this.reason,
    this.createdAt,
  });

  factory RentalEventModel.fromJson(Map<String, dynamic> json) {
    return RentalEventModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      actorRole: json['actor_role']?.toString() ?? 'SYSTEM',
      reason: json['reason']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
