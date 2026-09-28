import 'package:flutter/material.dart';

import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_spec.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';

/// Per-service presentation for the catalog-based extra travel services.
/// Titles/icons reuse the dashboard tile getters; detail rows and form
/// fields are resolved per item against the active localization.
const _heroPurple = Color(0xFF7B2FBE);
const _heroTeal = Color(0xFF0E7C7B);
const _heroIndigo = Color(0xFF3949AB);
const _heroGreen = Color(0xFF1B7A43);
const _heroOrange = Color(0xFFD97836);
const _heroRose = Color(0xFFB23A62);
const _heroCocoa = Color(0xFF6D4C41);
const _heroNavy = Color(0xFF1A3A6B);
const _heroSteel = Color(0xFF456A8C);
const _heroPlum = Color(0xFF6A1B4D);

ExtraServiceConfig extraServiceConfig(String key) => switch (key) {
  'carRental' => _carRental,
  'tour' => _tour,
  'boat' => _boat,
  'restaurant' => _restaurant,
  'food' => _food,
  'supermarket' => _supermarket,
  'store' => _store,
  'local' => _local,
  'insurance' => _insurance,
  'translator' => _translator,
  _ => throw ArgumentError.value(key, 'key', 'Unknown extra service'),
};

final _carRental = ExtraServiceConfig(
  key: 'carRental',
  icon: Icons.directions_car_rounded,
  heroStart: _heroSteel,
  heroEnd: TravelTheme.blue,
  title: (localization) => localization.travelServiceCarRental,
  heroTitle: (localization) => localization.travelCarRentalHero,
  priceUnit: (localization) => localization.travelCatalogPerDay,
  items: (localization) => mockCarRentalItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelCarAgency, item.subtitle),
    MapEntry(localization.travelCarSeats, item.extra['seats'] ?? ''),
    MapEntry(
      localization.travelCarTransmission,
      item.extra['transmission'] == 'automatic'
          ? localization.travelCarAutomatic
          : localization.travelCarManual,
    ),
    MapEntry(localization.travelCarDeposit, item.extra['deposit'] ?? ''),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'pickup_date',
      label: () => localization.travelCarPickupDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_available_rounded,
    ),
    TravelFormFieldSpec(
      key: 'return_date',
      label: () => localization.travelCarReturnDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_repeat_rounded,
    ),
    TravelFormFieldSpec(
      key: 'pickup_location',
      label: () => localization.travelOrigin,
      type: TravelFormFieldType.text,
      icon: Icons.location_on_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _tour = ExtraServiceConfig(
  key: 'tour',
  icon: Icons.tour_rounded,
  heroStart: _heroPurple,
  heroEnd: TravelTheme.purple,
  title: (localization) => localization.travelServiceTour,
  heroTitle: (localization) => localization.travelTourHero,
  priceUnit: (localization) => localization.travelCatalogPerPerson,
  items: (localization) => mockTourItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelTourDays, item.extra['days'] ?? ''),
    MapEntry(localization.travelTourStars, item.extra['stars'] ?? ''),
    MapEntry(localization.travelTourCapacity, item.extra['capacity'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'departure_date',
      label: () => localization.travelTourDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'travelers',
      label: () => localization.travelAdults,
      type: TravelFormFieldType.number,
      icon: Icons.people_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
    TravelFormFieldSpec(
      key: 'note',
      label: () => localization.travelFieldNote,
      type: TravelFormFieldType.textarea,
      icon: Icons.notes_rounded,
      required: false,
    ),
  ],
);

final _boat = ExtraServiceConfig(
  key: 'boat',
  icon: Icons.directions_boat_rounded,
  heroStart: _heroIndigo,
  heroEnd: TravelTheme.blue,
  title: (localization) => localization.travelServiceBoat,
  heroTitle: (localization) => localization.travelBoatHero,
  priceUnit: (localization) => localization.travelCatalogPerPerson,
  items: (localization) => mockBoatItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelBoatDuration, item.extra['duration'] ?? ''),
    MapEntry(localization.travelBoatCapacity, item.extra['capacity'] ?? ''),
    MapEntry(localization.travelBoatClass, item.extra['class'] ?? ''),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'travel_date',
      label: () => localization.travelDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.calendar_month_rounded,
    ),
    TravelFormFieldSpec(
      key: 'passengers',
      label: () => localization.travelAdults,
      type: TravelFormFieldType.number,
      icon: Icons.people_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _restaurant = ExtraServiceConfig(
  key: 'restaurant',
  icon: Icons.restaurant_rounded,
  heroStart: _heroRose,
  heroEnd: TravelTheme.red,
  title: (localization) => localization.travelServiceRestaurant,
  heroTitle: (localization) => localization.travelRestaurantHero,
  priceUnit: (localization) => localization.travelCatalogPerPerson,
  items: (localization) => mockRestaurantItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelRestaurantCuisine, item.extra['cuisine'] ?? ''),
    MapEntry(localization.travelRestaurantHours, item.extra['hours'] ?? ''),
    MapEntry(localization.travelRestaurantCapacity, item.extra['capacity'] ?? ''),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'reserve_date',
      label: () => localization.travelCheckIn,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'reserve_time',
      label: () => localization.travelFieldTime,
      type: TravelFormFieldType.time,
      icon: Icons.schedule_rounded,
    ),
    TravelFormFieldSpec(
      key: 'guests',
      label: () => localization.travelRestaurantGuests,
      type: TravelFormFieldType.number,
      icon: Icons.people_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _food = ExtraServiceConfig(
  key: 'food',
  icon: Icons.delivery_dining_rounded,
  heroStart: _heroOrange,
  heroEnd: TravelTheme.warning,
  title: (localization) => localization.travelServiceFood,
  heroTitle: (localization) => localization.travelFoodHero,
  priceUnit: (localization) => localization.travelCatalogPerItem,
  items: (localization) => mockFoodItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelFoodPreparation, item.extra['preparation'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'quantity',
      label: () => localization.travelFieldQuantity,
      type: TravelFormFieldType.number,
      icon: Icons.countertops_rounded,
    ),
    TravelFormFieldSpec(
      key: 'delivery_time',
      label: () => localization.travelFieldTime,
      type: TravelFormFieldType.time,
      icon: Icons.schedule_rounded,
    ),
    TravelFormFieldSpec(
      key: 'address',
      label: () => localization.travelFieldAddress,
      type: TravelFormFieldType.text,
      icon: Icons.location_on_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
    TravelFormFieldSpec(
      key: 'note',
      label: () => localization.travelFieldNote,
      type: TravelFormFieldType.textarea,
      icon: Icons.notes_rounded,
      required: false,
    ),
  ],
);

final _supermarket = ExtraServiceConfig(
  key: 'supermarket',
  icon: Icons.storefront_rounded,
  heroStart: _heroGreen,
  heroEnd: TravelTheme.green,
  title: (localization) => localization.travelServiceSupermarket,
  heroTitle: (localization) => localization.travelSupermarketHero,
  priceUnit: (localization) => localization.travelCatalogPerItem,
  items: (localization) => mockSupermarketItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelSupermarketUnit, item.extra['unit'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'quantity',
      label: () => localization.travelFieldQuantity,
      type: TravelFormFieldType.number,
      icon: Icons.countertops_rounded,
    ),
    TravelFormFieldSpec(
      key: 'delivery_date',
      label: () => localization.travelDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'address',
      label: () => localization.travelFieldAddress,
      type: TravelFormFieldType.text,
      icon: Icons.location_on_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _store = ExtraServiceConfig(
  key: 'store',
  icon: Icons.shopping_bag_rounded,
  heroStart: _heroPlum,
  heroEnd: TravelTheme.purple,
  title: (localization) => localization.travelServiceStore,
  heroTitle: (localization) => localization.travelStoreHero,
  priceUnit: (localization) => localization.travelCatalogPerItem,
  items: (localization) => mockStoreItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelStoreBrand, item.extra['brand'] ?? ''),
    MapEntry(localization.travelStoreWarranty, item.extra['warranty'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'quantity',
      label: () => localization.travelFieldQuantity,
      type: TravelFormFieldType.number,
      icon: Icons.countertops_rounded,
    ),
    TravelFormFieldSpec(
      key: 'address',
      label: () => localization.travelFieldAddress,
      type: TravelFormFieldType.text,
      icon: Icons.location_on_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _local = ExtraServiceConfig(
  key: 'local',
  icon: Icons.place_rounded,
  heroStart: _heroTeal,
  heroEnd: TravelTheme.green,
  title: (localization) => localization.travelServiceLocal,
  heroTitle: (localization) => localization.travelLocalHero,
  priceUnit: (localization) => localization.travelCatalogPerService,
  items: (localization) => mockLocalServiceItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelLocalDuration, item.extra['duration'] ?? ''),
    MapEntry(localization.travelLocalLanguages, item.extra['languages'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'service_date',
      label: () => localization.travelDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'city',
      label: () => localization.travelDestination,
      type: TravelFormFieldType.text,
      icon: Icons.location_city_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
    TravelFormFieldSpec(
      key: 'note',
      label: () => localization.travelFieldNote,
      type: TravelFormFieldType.textarea,
      icon: Icons.notes_rounded,
      required: false,
    ),
  ],
);

final _insurance = ExtraServiceConfig(
  key: 'insurance',
  icon: Icons.health_and_safety_rounded,
  heroStart: _heroCocoa,
  heroEnd: TravelTheme.green,
  title: (localization) => localization.travelServiceInsurance,
  heroTitle: (localization) => localization.travelInsuranceHero,
  priceUnit: (localization) => localization.travelCatalogPerPerson,
  items: (localization) => mockInsuranceItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelInsuranceCoverage, item.extra['coverage'] ?? ''),
    MapEntry(localization.travelInsuranceDuration, item.extra['duration'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'start_date',
      label: () => localization.travelDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'travelers',
      label: () => localization.travelAdults,
      type: TravelFormFieldType.number,
      icon: Icons.people_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'passport_number',
      label: () => localization.travelVisaPassportNumber,
      type: TravelFormFieldType.text,
      icon: Icons.badge_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
  ],
);

final _translator = ExtraServiceConfig(
  key: 'translator',
  icon: Icons.translate_rounded,
  heroStart: _heroNavy,
  heroEnd: TravelTheme.blue,
  title: (localization) => localization.travelServiceTranslator,
  heroTitle: (localization) => localization.travelTranslatorHero,
  priceUnit: (localization) => localization.travelCatalogPerDay,
  items: (localization) => mockTranslatorItems,
  detailRows: (item, localization) => [
    MapEntry(localization.travelTranslatorLanguages, item.extra['languages'] ?? ''),
    MapEntry(localization.travelTranslatorExperience, item.extra['experience'] ?? ''),
    MapEntry(localization.travelIncluded, item.subtitle),
  ],
  formFields: (item, localization) => [
    TravelFormFieldSpec(
      key: 'service_date',
      label: () => localization.travelDepartureDate,
      type: TravelFormFieldType.date,
      icon: Icons.event_rounded,
    ),
    TravelFormFieldSpec(
      key: 'city',
      label: () => localization.travelDestination,
      type: TravelFormFieldType.text,
      icon: Icons.location_city_rounded,
    ),
    TravelFormFieldSpec(
      key: 'full_name',
      label: () => localization.travelFieldName,
      type: TravelFormFieldType.text,
      icon: Icons.person_outline_rounded,
    ),
    TravelFormFieldSpec(
      key: 'phone',
      label: () => localization.travelFieldPhone,
      type: TravelFormFieldType.phone,
      icon: Icons.phone_rounded,
    ),
    TravelFormFieldSpec(
      key: 'note',
      label: () => localization.travelFieldNote,
      type: TravelFormFieldType.textarea,
      icon: Icons.notes_rounded,
      required: false,
    ),
  ],
);
