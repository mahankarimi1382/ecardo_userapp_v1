
class TourModel {
  final int id;
  final String title;
  final String slug;
  final String countryCode;
  final String city;
  final String category;
  final String description;
  final int durationDays;
  final int durationNights;
  final double basePrice;
  final String currency;
  final bool depositAllowed;
  final double depositPercent;
  final double ratingAvg;
  final int ratingCount;
  final String? featuredImage;
  final List<String> gallery;
  final List<String> tags;
  final List<String> executionModels;
  final List<String> hotelTiers;
  final List<TourItineraryDay> itinerary;
  final List<String> includedServices;
  final List<String> excludedServices;
  final List<TourDeparture> departures;
  final List<TourHotel> hotels;
  final List<TourActivity> activities;
  final int? matchPercentage;

  TourModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.countryCode,
    required this.city,
    required this.category,
    required this.description,
    required this.durationDays,
    required this.durationNights,
    required this.basePrice,
    required this.currency,
    required this.depositAllowed,
    required this.depositPercent,
    required this.ratingAvg,
    required this.ratingCount,
    this.featuredImage,
    this.gallery = const [],
    this.tags = const [],
    this.executionModels = const ['group', 'private'],
    this.hotelTiers = const ['ECO', 'STD', 'LUX'],
    this.itinerary = const [],
    this.includedServices = const [],
    this.excludedServices = const [],
    this.departures = const [],
    this.hotels = const [],
    this.activities = const [],
    this.matchPercentage,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      durationDays: int.tryParse('${json['duration_days']}') ?? 1,
      durationNights: int.tryParse('${json['duration_nights']}') ?? 0,
      basePrice: double.tryParse('${json['base_price']}') ?? 0.0,
      currency: json['currency']?.toString() ?? 'IRT',
      depositAllowed: json['deposit_allowed'] == true || json['deposit_allowed'] == 1,
      depositPercent: double.tryParse('${json['deposit_percent']}') ?? 30.0,
      ratingAvg: double.tryParse('${json['rating_avg']}') ?? 5.0,
      ratingCount: int.tryParse('${json['rating_count']}') ?? 0,
      featuredImage: json['featured_image']?.toString(),
      gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      executionModels: (json['execution_models'] as List?)?.map((e) => e.toString()).toList() ?? ['group', 'private'],
      hotelTiers: (json['hotel_tiers'] as List?)?.map((e) => e.toString()).toList() ?? ['ECO', 'STD', 'LUX'],
      itinerary: (json['itinerary'] as List?)
              ?.map((e) => TourItineraryDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      includedServices:
          (json['included_services'] as List?)?.map((e) => e.toString()).toList() ?? [],
      excludedServices:
          (json['excluded_services'] as List?)?.map((e) => e.toString()).toList() ?? [],
      departures: (json['departures'] as List?)
              ?.map((e) => TourDeparture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hotels: (json['hotels'] as List?)
              ?.map((e) => TourHotel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activities: (json['activities'] as List?)
              ?.map((e) => TourActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      matchPercentage: json['match_percentage'] is int
          ? json['match_percentage']
          : int.tryParse('${json['match_percentage']}'),
    );
  }
}

class TourItineraryDay {
  final int dayNo;
  final String title;
  final String description;
  final List<String> meals;
  final List<String> activities;

  TourItineraryDay({
    required this.dayNo,
    required this.title,
    required this.description,
    this.meals = const [],
    this.activities = const [],
  });

  factory TourItineraryDay.fromJson(Map<String, dynamic> json) {
    return TourItineraryDay(
      dayNo: int.tryParse('${json['day_no'] ?? json['day']}') ?? 1,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      meals: (json['meals'] as List?)?.map((e) => e.toString()).toList() ?? [],
      activities: (json['activities'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TourDeparture {
  final int id;
  final String departDate;
  final String returnDate;
  final int capacity;
  final int availableSeats;
  final String status;
  final double priceMultiplier;

  TourDeparture({
    required this.id,
    required this.departDate,
    required this.returnDate,
    required this.capacity,
    required this.availableSeats,
    required this.status,
    required this.priceMultiplier,
  });

  factory TourDeparture.fromJson(Map<String, dynamic> json) {
    return TourDeparture(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      departDate: json['depart_date']?.toString() ?? '',
      returnDate: json['return_date']?.toString() ?? '',
      capacity: int.tryParse('${json['capacity']}') ?? 20,
      availableSeats: int.tryParse('${json['available_seats']}') ?? 0,
      status: json['status']?.toString() ?? 'open',
      priceMultiplier: double.tryParse('${json['price_multiplier']}') ?? 1.0,
    );
  }
}

class TourHotel {
  final int id;
  final String name;
  final String tier;
  final String tierLabel;
  final double priceDelta;
  final double rating;
  final List<String> amenities;

  TourHotel({
    required this.id,
    required this.name,
    required this.tier,
    required this.tierLabel,
    required this.priceDelta,
    required this.rating,
    this.amenities = const [],
  });

  factory TourHotel.fromJson(Map<String, dynamic> json) {
    return TourHotel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'STD',
      tierLabel: json['tier_label']?.toString() ?? 'استاندارد',
      priceDelta: double.tryParse('${json['price_delta']}') ?? 0.0,
      rating: double.tryParse('${json['rating']}') ?? 4.0,
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TourActivity {
  final int id;
  final int dayNo;
  final String title;
  final double durationHours;
  final double price;

  TourActivity({
    required this.id,
    required this.dayNo,
    required this.title,
    required this.durationHours,
    required this.price,
  });

  factory TourActivity.fromJson(Map<String, dynamic> json) {
    return TourActivity(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      dayNo: int.tryParse('${json['day_no']}') ?? 1,
      title: json['title']?.toString() ?? '',
      durationHours: double.tryParse('${json['duration_hours']}') ?? 2.0,
      price: double.tryParse('${json['price']}') ?? 0.0,
    );
  }
}

class TourBookingModel {
  final int id;
  final String bookingNo;
  final String tourTitle;
  final String tourCity;
  final String? tourImage;
  final String? departDate;
  final String? returnDate;
  final String model;
  final String tier;
  final String? roomType;
  final int travelersCount;
  final int adultsCount;
  final int childrenCount;
  final double basePrice;
  final double hotelDelta;
  final double activitiesTotal;
  final double totalPrice;
  final double paidAmount;
  final double remainingBalance;
  final String paymentMode;
  final String currency;
  final String status;
  final String statusLabel;
  final String? voucherCode;
  final String? guideName;
  final String? guidePhone;
  final String? meetingPoint;
  final String? depositDeadline;
  final List<TourTravelerModel> travelers;
  final String? createdAt;

  TourBookingModel({
    required this.id,
    required this.bookingNo,
    required this.tourTitle,
    required this.tourCity,
    this.tourImage,
    this.departDate,
    this.returnDate,
    this.model = 'group',
    this.tier = 'STD',
    this.roomType,
    required this.travelersCount,
    this.adultsCount = 1,
    this.childrenCount = 0,
    required this.basePrice,
    this.hotelDelta = 0.0,
    this.activitiesTotal = 0.0,
    required this.totalPrice,
    this.paidAmount = 0.0,
    this.remainingBalance = 0.0,
    this.paymentMode = 'FULL',
    this.currency = 'IRT',
    required this.status,
    required this.statusLabel,
    this.voucherCode,
    this.guideName,
    this.guidePhone,
    this.meetingPoint,
    this.depositDeadline,
    this.travelers = const [],
    this.createdAt,
  });

  factory TourBookingModel.fromJson(Map<String, dynamic> json) {
    final tour = json['tour'] as Map<String, dynamic>?;
    final dep = json['departure'] as Map<String, dynamic>?;

    return TourBookingModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      bookingNo: json['booking_no']?.toString() ?? 'TR-${json['id']}',
      tourTitle: tour?['title']?.toString() ?? json['tour_title']?.toString() ?? 'تور مسافرتی',
      tourCity: tour?['city']?.toString() ?? json['tour_city']?.toString() ?? '',
      tourImage: tour?['featured_image']?.toString(),
      departDate: dep?['depart_date']?.toString() ?? json['depart_date']?.toString(),
      returnDate: dep?['return_date']?.toString() ?? json['return_date']?.toString(),
      model: json['model']?.toString() ?? 'group',
      tier: json['tier']?.toString() ?? 'STD',
      roomType: json['room_type']?.toString(),
      travelersCount: int.tryParse('${json['travelers_count']}') ?? 1,
      adultsCount: int.tryParse('${json['adults_count']}') ?? 1,
      childrenCount: int.tryParse('${json['children_count']}') ?? 0,
      basePrice: double.tryParse('${json['base_price']}') ?? 0.0,
      hotelDelta: double.tryParse('${json['hotel_delta']}') ?? 0.0,
      activitiesTotal: double.tryParse('${json['activities_total']}') ?? 0.0,
      totalPrice: double.tryParse('${json['total_price']}') ?? 0.0,
      paidAmount: double.tryParse('${json['paid_amount']}') ?? 0.0,
      remainingBalance: double.tryParse('${json['remaining_balance']}') ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? 'FULL',
      currency: json['currency']?.toString() ?? 'IRT',
      status: json['status']?.toString() ?? 'DRAFT',
      statusLabel: json['status_label']?.toString() ?? 'پیش‌نویس',
      voucherCode: json['voucher_code']?.toString(),
      guideName: json['guide_name']?.toString(),
      guidePhone: json['guide_phone']?.toString(),
      meetingPoint: json['meeting_point']?.toString(),
      depositDeadline: json['deposit_deadline']?.toString(),
      travelers: (json['travelers'] as List?)
              ?.map((e) => TourTravelerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at']?.toString(),
    );
  }
}

class TourTravelerModel {
  final String firstNameLatin;
  final String lastNameLatin;
  final String passportNumber;
  final String passportExpiry;
  final String? birthDate;
  final String type;

  TourTravelerModel({
    required this.firstNameLatin,
    required this.lastNameLatin,
    required this.passportNumber,
    required this.passportExpiry,
    this.birthDate,
    this.type = 'ADULT',
  });

  factory TourTravelerModel.fromJson(Map<String, dynamic> json) {
    return TourTravelerModel(
      firstNameLatin: json['first_name_latin']?.toString() ?? '',
      lastNameLatin: json['last_name_latin']?.toString() ?? '',
      passportNumber: json['passport_number']?.toString() ?? '',
      passportExpiry: json['passport_expiry']?.toString() ?? '',
      birthDate: json['birth_date']?.toString(),
      type: json['type']?.toString() ?? 'ADULT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name_latin': firstNameLatin,
      'last_name_latin': lastNameLatin,
      'passport_number': passportNumber,
      'passport_expiry': passportExpiry,
      if (birthDate != null) 'birth_date': birthDate,
      'type': type,
    };
  }
}

