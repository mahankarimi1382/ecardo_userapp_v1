import 'package:flutter/material.dart';
import '../core/models/travel_models.dart';

/// Flight trip types supported by International-grade booking.
enum FlightTripType {
  roundTrip,
  oneWay,
  multiCity;

  String get label {
    switch (this) {
      case FlightTripType.roundTrip:
        return 'Round-trip';
      case FlightTripType.oneWay:
        return 'One-way';
      case FlightTripType.multiCity:
        return 'Multi-city';
    }
  }

  String localizedLabel(String languageCode) {
    if (languageCode == 'fa') {
      switch (this) {
        case FlightTripType.roundTrip:
          return 'رفت و برگشت';
        case FlightTripType.oneWay:
          return 'یک‌طرفه';
        case FlightTripType.multiCity:
          return 'چند مسیره';
      }
    } else if (languageCode == 'ar') {
      switch (this) {
        case FlightTripType.roundTrip:
          return 'ذهاب وعودة';
        case FlightTripType.oneWay:
          return 'اتجاه واحد';
        case FlightTripType.multiCity:
          return 'مدن متعددة';
      }
    }
    return label;
  }
}

/// Cabin classes per IATA standard.
enum FlightCabinClass {
  economy,
  premiumEconomy,
  business,
  firstClass;

  String get key {
    switch (this) {
      case FlightCabinClass.economy:
        return 'economy';
      case FlightCabinClass.premiumEconomy:
        return 'premium_economy';
      case FlightCabinClass.business:
        return 'business';
      case FlightCabinClass.firstClass:
        return 'first';
    }
  }

  String get label {
    switch (this) {
      case FlightCabinClass.economy:
        return 'Economy';
      case FlightCabinClass.premiumEconomy:
        return 'Premium Economy';
      case FlightCabinClass.business:
        return 'Business';
      case FlightCabinClass.firstClass:
        return 'First Class';
    }
  }

  String localizedLabel(String languageCode) {
    if (languageCode == 'fa') {
      switch (this) {
        case FlightCabinClass.economy:
          return 'اکونومی (اقتصادی)';
        case FlightCabinClass.premiumEconomy:
          return 'پرمیوم اکونومی';
        case FlightCabinClass.business:
          return 'بیزینس (تجاری)';
        case FlightCabinClass.firstClass:
          return 'فرست کلاس (درجه یک)';
      }
    } else if (languageCode == 'ar') {
      switch (this) {
        case FlightCabinClass.economy:
          return 'الدرجة السياحية';
        case FlightCabinClass.premiumEconomy:
          return 'السياحية الممتازة';
        case FlightCabinClass.business:
          return 'درجة رجال الأعمال';
        case FlightCabinClass.firstClass:
          return 'الدرجة الأولى';
      }
    }
    return label;
  }

  static FlightCabinClass fromString(String value) {
    switch (value.toLowerCase()) {
      case 'premium_economy':
      case 'premiumeconomy':
        return FlightCabinClass.premiumEconomy;
      case 'business':
        return FlightCabinClass.business;
      case 'first':
      case 'firstclass':
        return FlightCabinClass.firstClass;
      default:
        return FlightCabinClass.economy;
    }
  }
}

/// Fare families offered by carriers (Basic, Standard, Flex).
enum FareFamily {
  basic,
  standard,
  flex;

  String get label {
    switch (this) {
      case FareFamily.basic:
        return 'Basic';
      case FareFamily.standard:
        return 'Standard';
      case FareFamily.flex:
        return 'Flex';
    }
  }

  String localizedLabel(String languageCode) {
    if (languageCode == 'fa') {
      switch (this) {
        case FareFamily.basic:
          return 'پایه (Basic)';
        case FareFamily.standard:
          return 'استاندارد (Standard)';
        case FareFamily.flex:
          return 'منعطف (Flex)';
      }
    } else if (languageCode == 'ar') {
      switch (this) {
        case FareFamily.basic:
          return 'أساسي (Basic)';
        case FareFamily.standard:
          return 'قياسي (Standard)';
        case FareFamily.flex:
          return 'مرن (Flex)';
      }
    }
    return label;
  }

  String get baggageCabin => '1 × 7 kg cabin bag';
  String get baggageChecked {
    switch (this) {
      case FareFamily.basic:
        return 'Not included';
      case FareFamily.standard:
        return '1 × 23 kg checked bag';
      case FareFamily.flex:
        return '2 × 23 kg checked bags';
    }
  }

  bool get seatSelectionIncluded => this != FareFamily.basic;
  bool get changeAllowed => this != FareFamily.basic;
  bool get refundAllowed => this == FareFamily.flex;
}

/// Stops count classification.
enum FlightStopsFilter {
  all,
  direct,
  oneStop,
  twoPlusStops;

  String get label {
    switch (this) {
      case FlightStopsFilter.all:
        return 'All Stops';
      case FlightStopsFilter.direct:
        return 'Direct';
      case FlightStopsFilter.oneStop:
        return '1 Stop';
      case FlightStopsFilter.twoPlusStops:
        return '2+ Stops';
    }
  }

  String localizedLabel(String languageCode) {
    if (languageCode == 'fa') {
      switch (this) {
        case FlightStopsFilter.all:
          return 'همه پروازها';
        case FlightStopsFilter.direct:
          return 'مستقیم';
        case FlightStopsFilter.oneStop:
          return '۱ توقف';
        case FlightStopsFilter.twoPlusStops:
          return '۲+ توقف';
      }
    } else if (languageCode == 'ar') {
      switch (this) {
        case FlightStopsFilter.all:
          return 'جميع الرحلات';
        case FlightStopsFilter.direct:
          return 'مباشر';
        case FlightStopsFilter.oneStop:
          return 'توقف واحد';
        case FlightStopsFilter.twoPlusStops:
          return 'توقفين أو أكثر';
      }
    }
    return label;
  }
}

/// Airport data record with IATA code and location details.
class AirportItem {
  final String code;
  final String city;
  final String name;
  final String country;
  final String countryCode;

  const AirportItem({
    required this.code,
    required this.city,
    required this.name,
    required this.country,
    required this.countryCode,
  });

  String get displayFull => '$city ($code) - $name';
  String get displayShort => '$city ($code)';

  static const List<AirportItem> popularAirports = [
    AirportItem(
      code: 'DXB',
      city: 'Dubai',
      name: 'Dubai International Airport',
      country: 'United Arab Emirates',
      countryCode: 'AE',
    ),
    AirportItem(
      code: 'IKA',
      city: 'Tehran',
      name: 'Imam Khomeini International Airport',
      country: 'Iran',
      countryCode: 'IR',
    ),
    AirportItem(
      code: 'IST',
      city: 'Istanbul',
      name: 'Istanbul Airport',
      country: 'Turkey',
      countryCode: 'TR',
    ),
    AirportItem(
      code: 'DOH',
      city: 'Doha',
      name: 'Hamad International Airport',
      country: 'Qatar',
      countryCode: 'QA',
    ),
    AirportItem(
      code: 'LHR',
      city: 'London',
      name: 'Heathrow Airport',
      country: 'United Kingdom',
      countryCode: 'GB',
    ),
    AirportItem(
      code: 'CDG',
      city: 'Paris',
      name: 'Charles de Gaulle Airport',
      country: 'France',
      countryCode: 'FR',
    ),
    AirportItem(
      code: 'FRA',
      city: 'Frankfurt',
      name: 'Frankfurt am Main Airport',
      country: 'Germany',
      countryCode: 'DE',
    ),
    AirportItem(
      code: 'AMS',
      city: 'Amsterdam',
      name: 'Schiphol Airport',
      country: 'Netherlands',
      countryCode: 'NL',
    ),
    AirportItem(
      code: 'JFK',
      city: 'New York',
      name: 'John F. Kennedy International Airport',
      country: 'United States',
      countryCode: 'US',
    ),
    AirportItem(
      code: 'SIN',
      city: 'Singapore',
      name: 'Changi Airport',
      country: 'Singapore',
      countryCode: 'SG',
    ),
    AirportItem(
      code: 'HND',
      city: 'Tokyo',
      name: 'Haneda Airport',
      country: 'Japan',
      countryCode: 'JP',
    ),
    AirportItem(
      code: 'AUH',
      city: 'Abu Dhabi',
      name: 'Zayed International Airport',
      country: 'United Arab Emirates',
      countryCode: 'AE',
    ),
    AirportItem(
      code: 'RUH',
      city: 'Riyadh',
      name: 'King Khalid International Airport',
      country: 'Saudi Arabia',
      countryCode: 'SA',
    ),
    AirportItem(
      code: 'JED',
      city: 'Jeddah',
      name: 'King Abdulaziz International Airport',
      country: 'Saudi Arabia',
      countryCode: 'SA',
    ),
    AirportItem(
      code: 'MCT',
      city: 'Muscat',
      name: 'Muscat International Airport',
      country: 'Oman',
      countryCode: 'OM',
    ),
    AirportItem(
      code: 'CAI',
      city: 'Cairo',
      name: 'Cairo International Airport',
      country: 'Egypt',
      countryCode: 'EG',
    ),
    AirportItem(
      code: 'SYD',
      city: 'Sydney',
      name: 'Kingsford Smith Airport',
      country: 'Australia',
      countryCode: 'AU',
    ),
    AirportItem(
      code: 'BKK',
      city: 'Bangkok',
      name: 'Suvarnabhumi Airport',
      country: 'Thailand',
      countryCode: 'TH',
    ),
    AirportItem(
      code: 'ZRH',
      city: 'Zurich',
      name: 'Zurich Airport',
      country: 'Switzerland',
      countryCode: 'CH',
    ),
    AirportItem(
      code: 'FCO',
      city: 'Rome',
      name: 'Leonardo da Vinci–Fiumicino Airport',
      country: 'Italy',
      countryCode: 'IT',
    ),
  ];

  static AirportItem findByCode(String code) {
    final uppercase = code.trim().toUpperCase();
    for (final airport in popularAirports) {
      if (airport.code == uppercase) return airport;
    }
    return AirportItem(
      code: uppercase,
      city: uppercase,
      name: '$uppercase Airport',
      country: 'International',
      countryCode: 'INT',
    );
  }
}

/// Leg of a multi-city journey.
class MultiCitySegmentQuery {
  String origin;
  String destination;
  DateTime date;

  MultiCitySegmentQuery({
    required this.origin,
    required this.destination,
    required this.date,
  });
}

/// Passenger age counts.
class PassengerBreakdown {
  final int adults; // 12+ years
  final int children; // 2-11 years
  final int infants; // under 2 years

  const PassengerBreakdown({
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
  });

  int get totalPassengers => adults + children + infants;
  int get seatedPassengers => adults + children;

  PassengerBreakdown copyWith({
    int? adults,
    int? children,
    int? infants,
  }) {
    return PassengerBreakdown(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
    );
  }

  String summaryText(String lang) {
    if (lang == 'fa') {
      final parts = <String>['$adults بزرگسال'];
      if (children > 0) parts.add('$children کودک');
      if (infants > 0) parts.add('$infants نوزاد');
      return parts.join('، ');
    } else if (lang == 'ar') {
      final parts = <String>['$adults بالغ'];
      if (children > 0) parts.add('$children طفل');
      if (infants > 0) parts.add('$infants رضيع');
      return parts.join('، ');
    }
    final parts = <String>['$adults Adult${adults > 1 ? 's' : ''}'];
    if (children > 0) parts.add('$children Child${children > 1 ? 'ren' : ''}');
    if (infants > 0) parts.add('$infants Infant${infants > 1 ? 's' : ''}');
    return parts.join(', ');
  }
}

/// Detailed Flight Leg Segment.
class FlightLegSegment {
  final String flightNumber;
  final String carrierCode;
  final String carrierName;
  final String carrierLogoUrl;
  final String originCode;
  final String originCity;
  final String originAirportName;
  final String originTerminal;
  final String destinationCode;
  final String destinationCity;
  final String destinationAirportName;
  final String destinationTerminal;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String durationText;
  final String aircraftType;
  final String cabinClassName;
  final List<String> amenities;
  final String baggageCabin;
  final String baggageChecked;

  const FlightLegSegment({
    required this.flightNumber,
    required this.carrierCode,
    required this.carrierName,
    this.carrierLogoUrl = '',
    required this.originCode,
    required this.originCity,
    required this.originAirportName,
    this.originTerminal = '1',
    required this.destinationCode,
    required this.destinationCity,
    required this.destinationAirportName,
    this.destinationTerminal = '2',
    required this.departureTime,
    required this.arrivalTime,
    required this.durationText,
    required this.aircraftType,
    required this.cabinClassName,
    this.amenities = const ['Wi-Fi', 'USB In-seat Power', 'Complimentary Meal', 'Entertainment Screen'],
    this.baggageCabin = '1 × 7 kg',
    this.baggageChecked = '1 × 23 kg',
  });
}

/// Layover details between flight legs.
class FlightLayoverInfo {
  final String airportCode;
  final String airportCity;
  final String durationText;
  final bool terminalChange;

  const FlightLayoverInfo({
    required this.airportCode,
    required this.airportCity,
    required this.durationText,
    this.terminalChange = false,
  });
}

/// Seat map seat items.
enum CabinSeatPosition {
  window,
  middle,
  aisle;

  String localizedLabel(String lang) {
    if (lang == 'fa') {
      switch (this) {
        case CabinSeatPosition.window:
          return 'کنار پنجره';
        case CabinSeatPosition.middle:
          return 'صندلی وسط';
        case CabinSeatPosition.aisle:
          return 'کنار راهرو';
      }
    } else if (lang == 'ar') {
      switch (this) {
        case CabinSeatPosition.window:
          return 'نافذة';
        case CabinSeatPosition.middle:
          return 'وسط';
        case CabinSeatPosition.aisle:
          return 'ممر';
      }
    }
    switch (this) {
      case CabinSeatPosition.window:
        return 'Window';
      case CabinSeatPosition.middle:
        return 'Middle';
      case CabinSeatPosition.aisle:
        return 'Aisle';
    }
  }
}

enum CabinSeatFeature {
  standard,
  exitRow,
  extraLegroom,
  bulkhead;

  String localizedLabel(String lang) {
    if (lang == 'fa') {
      switch (this) {
        case CabinSeatFeature.standard:
          return 'استاندارد';
        case CabinSeatFeature.exitRow:
          return 'ردیف اضطراری (فضای پای بیشتر)';
        case CabinSeatFeature.extraLegroom:
          return 'فضای پای بیشتر';
        case CabinSeatFeature.bulkhead:
          return 'ردیف اول بخش (Bulkhead)';
      }
    } else if (lang == 'ar') {
      switch (this) {
        case CabinSeatFeature.standard:
          return 'قياسي';
        case CabinSeatFeature.exitRow:
          return 'مخرج طوارئ (مساحة إضافية)';
        case CabinSeatFeature.extraLegroom:
          return 'مساحة أرجل إضافية';
        case CabinSeatFeature.bulkhead:
          return 'الصف الأمامي';
      }
    }
    switch (this) {
      case CabinSeatFeature.standard:
        return 'Standard';
      case CabinSeatFeature.exitRow:
        return 'Exit Row';
      case CabinSeatFeature.extraLegroom:
        return 'Extra Legroom';
      case CabinSeatFeature.bulkhead:
        return 'Bulkhead';
    }
  }
}

enum CabinSeatState {
  available,
  selected,
  occupied;

  String localizedLabel(String lang) {
    if (lang == 'fa') {
      switch (this) {
        case CabinSeatState.available:
          return 'در دسترس';
        case CabinSeatState.selected:
          return 'انتخاب شده';
        case CabinSeatState.occupied:
          return 'رزرو شده';
      }
    } else if (lang == 'ar') {
      switch (this) {
        case CabinSeatState.available:
          return 'متاح';
        case CabinSeatState.selected:
          return 'تم الاختيار';
        case CabinSeatState.occupied:
          return 'محجوز';
      }
    }
    switch (this) {
      case CabinSeatState.available:
        return 'Available';
      case CabinSeatState.selected:
        return 'Selected';
      case CabinSeatState.occupied:
        return 'Occupied';
    }
  }
}

class CabinSeatModel {
  final String id;
  final int row;
  final String col;
  final CabinSeatPosition position;
  final CabinSeatFeature feature;
  final FlightCabinClass cabinClass;
  final CabinSeatState state;
  final double extraPrice;
  final String legroomPitch;

  const CabinSeatModel({
    required this.id,
    required this.row,
    required this.col,
    required this.position,
    required this.feature,
    required this.cabinClass,
    this.state = CabinSeatState.available,
    this.extraPrice = 0.0,
    this.legroomPitch = '31 in / 79 cm',
  });

  String get seatCode => '$row$col';
  bool get isAvailable => state == CabinSeatState.available;
  bool get isOccupied => state == CabinSeatState.occupied;
  bool get isSelected => state == CabinSeatState.selected;
  bool get isExitRow => feature == CabinSeatFeature.exitRow;
  bool get hasExtraLegroom =>
      feature == CabinSeatFeature.extraLegroom || isExitRow;

  CabinSeatModel copyWith({
    CabinSeatState? state,
  }) {
    return CabinSeatModel(
      id: id,
      row: row,
      col: col,
      position: position,
      feature: feature,
      cabinClass: cabinClass,
      state: state ?? this.state,
      extraPrice: extraPrice,
      legroomPitch: legroomPitch,
    );
  }
}

/// Passenger checkout input model.
class InternationalPassengerForm {
  final int index;
  final String passengerType; // 'adult', 'child', 'infant'
  String title; // 'Mr', 'Mrs', 'Ms', 'Dr'
  String firstName;
  String lastName;
  DateTime? dateOfBirth;
  String nationality;
  String passportNumber;
  DateTime? passportExpiry;
  String frequentFlyerAirline;
  String frequentFlyerNumber;
  String mealPreference;
  String specialAssistance;
  CabinSeatModel? assignedSeat;

  InternationalPassengerForm({
    required this.index,
    required this.passengerType,
    this.title = 'Mr',
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth,
    this.nationality = 'AE',
    this.passportNumber = '',
    this.passportExpiry,
    this.frequentFlyerAirline = '',
    this.frequentFlyerNumber = '',
    this.mealPreference = 'Standard Meal',
    this.specialAssistance = 'None',
    this.assignedSeat,
  });

  bool get isComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      dateOfBirth != null &&
      nationality.trim().isNotEmpty &&
      passportNumber.trim().isNotEmpty &&
      passportExpiry != null &&
      passportExpiry!.isAfter(DateTime.now());

  TravelPassenger toTravelPassenger() {
    return TravelPassenger(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      birthDate: dateOfBirth,
      gender: (title == 'Mr') ? 'male' : 'female',
      nationalityCode: nationality.trim().toUpperCase(),
      passportNumber: passportNumber.trim().toUpperCase(),
      passportExpiry: passportExpiry,
      type: passengerType,
    );
  }
}

/// Digital Boarding Pass data.
class DigitalBoardingPass {
  final String pnr;
  final String eTicketNumber;
  final String passengerName;
  final String flightNumber;
  final String carrierName;
  final String carrierCode;
  final String originIata;
  final String originCity;
  final String originTerminal;
  final String destinationIata;
  final String destinationCity;
  final String destinationTerminal;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String gate;
  final String terminal;
  final String boardingGroup;
  final String seatNumber;
  final String cabinClass;
  final String flightStatus; // 'On Time', 'Boarding', 'Delayed', 'Departed'
  final String barcodePayload;

  const DigitalBoardingPass({
    required this.pnr,
    required this.eTicketNumber,
    required this.passengerName,
    required this.flightNumber,
    required this.carrierName,
    required this.carrierCode,
    required this.originIata,
    required this.originCity,
    this.originTerminal = '3',
    required this.destinationIata,
    required this.destinationCity,
    this.destinationTerminal = '2',
    required this.departureTime,
    required this.arrivalTime,
    required this.gate,
    required this.terminal,
    required this.boardingGroup,
    required this.seatNumber,
    required this.cabinClass,
    this.flightStatus = 'On Time',
    required this.barcodePayload,
  });
}
