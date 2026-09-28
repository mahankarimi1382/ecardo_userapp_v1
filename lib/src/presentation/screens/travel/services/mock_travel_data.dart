import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';

import 'service_form_spec.dart';

/// Curated demo catalogs for the extra travel services. Everything here is
/// deterministic in-app data (no backend contract yet) — the same search
/// always produces the same results, prices are plausible and stable, and
/// submissions land in the local request book with the `underReview` state.
String formatMockAmount(int amount) {
  return NumberFormat.decimalPattern('en').format(amount);
}

class MockCatalogItem {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  final String rating;
  final IconData icon;
  final Map<String, String> extra;

  const MockCatalogItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    this.rating = '',
    this.extra = const {},
  });
}

class ExtraServiceConfig {
  final String key;
  final IconData icon;
  final Color heroStart;
  final Color heroEnd;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) heroTitle;
  final List<MockCatalogItem> Function(AppLocalizations) items;
  final String Function(AppLocalizations) priceUnit;
  final List<MapEntry<String, String>> Function(
    MockCatalogItem item,
    AppLocalizations localization,
  )?
  detailRows;
  final List<TravelFormFieldSpec> Function(
    MockCatalogItem item,
    AppLocalizations localization,
  )
  formFields;

  const ExtraServiceConfig({
    required this.key,
    required this.icon,
    required this.heroStart,
    required this.heroEnd,
    required this.title,
    required this.heroTitle,
    required this.items,
    required this.priceUnit,
    this.detailRows,
    required this.formFields,
  });
}

// ---------------------------------------------------------------------------
// Deterministic pseudo-random helpers (same search ⇒ same results).
// ---------------------------------------------------------------------------

class _DeterministicRandom {
  int _state;

  _DeterministicRandom(int seed) : _state = seed & 0x7fffffff;

  int nextInt(int maximum) {
    _state = (_state * 48271) % 0x7fffffff;
    return _state % maximum;
  }
}

int _seedFrom(List<Object?> parts) =>
    parts.map((part) => part.toString()).join('|').hashCode & 0x7fffffff;

// ---------------------------------------------------------------------------
// Shared demo pools
// ---------------------------------------------------------------------------

const mockIranCities = [
  'تهران',
  'مشهد',
  'اصفهان',
  'شیراز',
  'تبریز',
  'اهواز',
  'قم',
  'کرج',
  'بندرعباس',
  'یزد',
];

const mockIntlCities = [
  'دبی',
  'استانبول',
  'ایروان',
  'تفلیس',
  'باکو',
  'آنتالیا',
  'کوالالامپور',
  'دهلی نو',
];

const mockTrainOperators = ['فدک', 'رجا', 'نورالرضا', 'پنج‌ستاره', 'سپاهان'];

const mockCarRentalAgencies = [
  'ایجنتینا رنت',
  'آوانتا کار',
  'رنت‌اکس',
  'سفر کار',
];

const mockCuisines = ['ایرانی', 'ایرانی', 'فست‌فود', 'بین‌المللی', 'گیاهی'];
const mockTourHotelStars = ['۳ ستاره', '۴ ستاره', '۵ ستاره'];

// ---------------------------------------------------------------------------
// Train
// ---------------------------------------------------------------------------

class TrainClassOption {
  final String code; // economy | coupe | vip
  final int price;
  final int seatsLeft;

  const TrainClassOption({
    required this.code,
    required this.price,
    required this.seatsLeft,
  });
}

class TrainTrip {
  final String id;
  final String operator;
  final String trainName;
  final String trainNumber;
  final int departMinutes; // minutes after midnight
  final int durationMinutes;
  final List<TrainClassOption> classes;

  const TrainTrip({
    required this.id,
    required this.operator,
    required this.trainName,
    required this.trainNumber,
    required this.departMinutes,
    required this.durationMinutes,
    required this.classes,
  });

  String get departLabel {
    final hour = (departMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (departMinutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get arrivalLabel {
    final total = departMinutes + durationMinutes;
    final hour = ((total ~/ 60) % 24).toString().padLeft(2, '0');
    final minute = (total % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  int get minPrice =>
      classes.map((option) => option.price).reduce(
        (a, b) => a < b ? a : b,
      );
}

List<TrainTrip> generateTrainTrips(
  String origin,
  String destination,
  DateTime date,
) {
  final random = _DeterministicRandom(
    _seedFrom([origin, destination, date.day, date.month]),
  );
  final count = 5 + random.nextInt(4);
  final trips = <TrainTrip>[];
  for (var index = 0; index < count; index++) {
    final operator =
        mockTrainOperators[random.nextInt(mockTrainOperators.length)];
    final departMinutes = 300 + index * 105 + random.nextInt(55);
    final durationMinutes = 330 + random.nextInt(420);
    final economyPrice = (380000 + random.nextInt(42) * 10000);
    final classes = <TrainClassOption>[
      TrainClassOption(
        code: 'economy',
        price: economyPrice,
        seatsLeft: 6 + random.nextInt(40),
      ),
    ];
    if (random.nextInt(10) > 2) {
      classes.add(
        TrainClassOption(
          code: 'coupe',
          price: (economyPrice * 1.35).round(),
          seatsLeft: 4 + random.nextInt(24),
        ),
      );
    }
    if (operator == 'فدک' || random.nextInt(10) > 6) {
      classes.add(
        TrainClassOption(
          code: 'vip',
          price: (economyPrice * 1.8).round(),
          seatsLeft: 2 + random.nextInt(14),
        ),
      );
    }
    trips.add(
      TrainTrip(
        id: 'train-$index-$departMinutes',
        operator: operator,
        trainName: 'قطار $operator',
        trainNumber: '${100 + random.nextInt(800)}',
        departMinutes: departMinutes,
        durationMinutes: durationMinutes,
        classes: classes,
      ),
    );
  }
  trips.sort((a, b) => a.departMinutes.compareTo(b.departMinutes));
  return trips;
}

// ---------------------------------------------------------------------------
// Visa
// ---------------------------------------------------------------------------

class VisaCountry {
  final String name;
  final String flagEmoji;
  final int touristPrice;
  final int businessPrice;
  final int processingDays;

  const VisaCountry({
    required this.name,
    required this.flagEmoji,
    required this.touristPrice,
    required this.businessPrice,
    required this.processingDays,
  });
}

const mockVisaCountries = [
  VisaCountry(
    name: 'امارات',
    flagEmoji: '🇦🇪',
    touristPrice: 3200000,
    businessPrice: 4800000,
    processingDays: 4,
  ),
  VisaCountry(
    name: 'ترکیه',
    flagEmoji: '🇹🇷',
    touristPrice: 2100000,
    businessPrice: 3300000,
    processingDays: 6,
  ),
  VisaCountry(
    name: 'ارمنستان',
    flagEmoji: '🇦🇲',
    touristPrice: 1500000,
    businessPrice: 2400000,
    processingDays: 5,
  ),
  VisaCountry(
    name: 'گرجستان',
    flagEmoji: '🇬🇪',
    touristPrice: 1400000,
    businessPrice: 2200000,
    processingDays: 5,
  ),
  VisaCountry(
    name: 'آذربایجان',
    flagEmoji: '🇦🇿',
    touristPrice: 1650000,
    businessPrice: 2600000,
    processingDays: 7,
  ),
  VisaCountry(
    name: 'هند',
    flagEmoji: '🇮🇳',
    touristPrice: 1900000,
    businessPrice: 3100000,
    processingDays: 8,
  ),
  VisaCountry(
    name: 'چین',
    flagEmoji: '🇨🇳',
    touristPrice: 3800000,
    businessPrice: 5200000,
    processingDays: 10,
  ),
  VisaCountry(
    name: 'روسیه',
    flagEmoji: '🇷🇺',
    touristPrice: 4200000,
    businessPrice: 6000000,
    processingDays: 12,
  ),
];

const mockVisaDocuments = [
  'اسکن پاسپورت با حداقل ۶ ماه اعتبار',
  'عکس پرسنلی ۳×۴ پس‌زمینه سفید',
  'رزرو هتل یا دعوت‌نامه',
  'گردش حساب سه‌ماهه اخیر',
  'بیمه مسافرتی معتبر',
];

// ---------------------------------------------------------------------------
// Generic catalogs
// ---------------------------------------------------------------------------

final List<MockCatalogItem> mockCarRentalItems = [
  const MockCatalogItem(
    id: 'car-1',
    title: 'پژو ۲۰۷ اتوماتیک — مدل ۱۴۰۲',
    subtitle: 'ایجنتینا رنت · تهران فرودگاه مهرآباد',
    price: 1850000,
    rating: '4.7',
    icon: Icons.directions_car_rounded,
    extra: {'seats': '5', 'transmission': 'automatic', 'deposit': '8000000'},
  ),
  const MockCatalogItem(
    id: 'car-2',
    title: 'بنز E200 — مدل ۱۴۰۱',
    subtitle: 'آوانتا کار · تهران سعادت‌آباد',
    price: 6200000,
    rating: '4.9',
    icon: Icons.directions_car_rounded,
    extra: {'seats': '5', 'transmission': 'automatic', 'deposit': '30000000'},
  ),
  const MockCatalogItem(
    id: 'car-3',
    title: 'کوییک R — مدل ۱۴۰۳',
    subtitle: 'رنت‌اکس · مشهد بلوار وکیل‌آباد',
    price: 1500000,
    rating: '4.5',
    icon: Icons.directions_car_rounded,
    extra: {'seats': '5', 'transmission': 'manual', 'deposit': '5000000'},
  ),
  const MockCatalogItem(
    id: 'car-4',
    title: 'هوندا CRV — مدل ۲۰۲۲',
    subtitle: 'سفر کار · کیش دریا',
    price: 7400000,
    rating: '4.8',
    icon: Icons.directions_car_rounded,
    extra: {'seats': '5', 'transmission': 'automatic', 'deposit': '35000000'},
  ),
  const MockCatalogItem(
    id: 'car-5',
    title: 'وانت نیسان — مدل ۱۳۹۹',
    subtitle: 'سفر کار · بندرعباس',
    price: 2100000,
    rating: '4.2',
    icon: Icons.local_shipping_rounded,
    extra: {'seats': '2', 'transmission': 'manual', 'deposit': '7000000'},
  ),
  const MockCatalogItem(
    id: 'car-6',
    title: 'کمری GL — مدل ۱۴۰۰',
    subtitle: 'آوانتا کار · اصفهان چهارباغ',
    price: 3400000,
    rating: '4.6',
    icon: Icons.directions_car_rounded,
    extra: {'seats': '5', 'transmission': 'automatic', 'deposit': '15000000'},
  ),
];

final List<MockCatalogItem> mockTourItems = [
  const MockCatalogItem(
    id: 'tour-1',
    title: 'تور کیش — ۳ شب و ۴ روز',
    subtitle: 'هتل ۵ ستاره · پرواز چارتر · ترانسفر',
    price: 8900000,
    rating: '4.8',
    icon: Icons.tour_rounded,
    extra: {'stars': '۵ ستاره', 'days': '۳ شب / ۴ روز', 'capacity': '۲۴ نفر'},
  ),
  const MockCatalogItem(
    id: 'tour-2',
    title: 'تور استانبول — ۴ شب',
    subtitle: 'هتل ۴ ستاره · گشت شهری · لیدر فارسی‌زبان',
    price: 32500000,
    rating: '4.9',
    icon: Icons.tour_rounded,
    extra: {'stars': '۴ ستاره', 'days': '۴ شب / ۵ روز', 'capacity': '۲۰ نفر'},
  ),
  const MockCatalogItem(
    id: 'tour-3',
    title: 'تور مشهد زمینی — ۲ شب',
    subtitle: 'قطار ۵ ستاره · هتل نزدیک حرم',
    price: 5400000,
    rating: '4.6',
    icon: Icons.tour_rounded,
    extra: {'stars': '۴ ستاره', 'days': '۲ شب / ۳ روز', 'capacity': '۳۰ نفر'},
  ),
  const MockCatalogItem(
    id: 'tour-4',
    title: 'تور قشم — ۳ شب',
    subtitle: 'هتل ۳ ستاره · بازدید جزایر',
    price: 6700000,
    rating: '4.4',
    icon: Icons.tour_rounded,
    extra: {'stars': '۳ ستاره', 'days': '۳ شب / ۴ روز', 'capacity': '۲۵ نفر'},
  ),
  const MockCatalogItem(
    id: 'tour-5',
    title: 'تور ایروان زمینی — ۳ شب',
    subtitle: 'اتوبوس VIP · هتل مرکز شهر',
    price: 14800000,
    rating: '4.7',
    icon: Icons.tour_rounded,
    extra: {'stars': '۴ ستاره', 'days': '۳ شب / ۴ روز', 'capacity': '۲۸ نفر'},
  ),
];

final List<MockCatalogItem> mockBoatItems = [
  const MockCatalogItem(
    id: 'boat-1',
    title: 'کیش ← بندرلنگه',
    subtitle: 'کشتی ایمن‌دریا · هر روز ساعت ۰۹:۰۰ و ۱۷:۰۰',
    price: 850000,
    rating: '4.5',
    icon: Icons.directions_boat_rounded,
    extra: {'duration': '۲ ساعت', 'capacity': '۳۲۰ نفر', 'class': 'صندلی معمولی'},
  ),
  const MockCatalogItem(
    id: 'boat-2',
    title: 'بندرعباس ← قشم',
    subtitle: 'کاتاماران سرعت‌رو · ساعتی',
    price: 480000,
    rating: '4.3',
    icon: Icons.directions_boat_rounded,
    extra: {'duration': '۴۵ دقیقه', 'capacity': '۱۸۰ نفر', 'class': 'صندلی معمولی'},
  ),
  const MockCatalogItem(
    id: 'boat-3',
    title: 'کیش ← شیرازه (تفریحی)',
    subtitle: 'یخت اختصاصی · گروهی',
    price: 4200000,
    rating: '4.9',
    icon: Icons.directions_boat_rounded,
    extra: {'duration': '۵ ساعت', 'capacity': '۱۲ نفر', 'class': 'VIP'},
  ),
  const MockCatalogItem(
    id: 'boat-4',
    title: 'چابهار ← جزایر متعدد',
    subtitle: 'لنج توریستی · شنبه‌ها',
    price: 1600000,
    rating: '4.4',
    icon: Icons.directions_boat_rounded,
    extra: {'duration': '۳ ساعت', 'capacity': '۴۰ نفر', 'class': 'عادی'},
  ),
];

final List<MockCatalogItem> mockRestaurantItems = [
  const MockCatalogItem(
    id: 'rest-1',
    title: 'رستوران شاطر عباس',
    subtitle: 'ایرانی · کیش میدان امیرکبیر',
    price: 950000,
    rating: '4.6',
    icon: Icons.restaurant_rounded,
    extra: {'cuisine': 'ایرانی', 'hours': '۱۲:۰۰ تا ۲۳:۳۰', 'capacity': '۸۰ نفر'},
  ),
  const MockCatalogItem(
    id: 'rest-2',
    title: 'کافه لوند',
    subtitle: 'بین‌المللی · تهران زعفرانیه',
    price: 780000,
    rating: '4.5',
    icon: Icons.restaurant_rounded,
    extra: {'cuisine': 'بین‌المللی', 'hours': '۰۹:۰۰ تا ۲۴:۰۰', 'capacity': '۴۵ نفر'},
  ),
  const MockCatalogItem(
    id: 'rest-3',
    title: 'رستوران سنتی گرجی تفلیس',
    subtitle: 'بین‌المللی · تفلیس خیابان روستاولی',
    price: 1100000,
    rating: '4.8',
    icon: Icons.restaurant_rounded,
    extra: {'cuisine': 'بین‌المللی', 'hours': '۱۲:۰۰ تا ۲۳:۰۰', 'capacity': '۶۰ نفر'},
  ),
  const MockCatalogItem(
    id: 'rest-4',
    title: 'فست‌فود برگرلند',
    subtitle: 'فست‌فود · مشهد احمدآباد',
    price: 420000,
    rating: '4.2',
    icon: Icons.fastfood_rounded,
    extra: {'cuisine': 'فست‌فود', 'hours': '۱۱:۰۰ تا ۲۴:۰۰', 'capacity': '۳۵ نفر'},
  ),
  const MockCatalogItem(
    id: 'rest-5',
    title: 'رستوران گیاهی سبزینه',
    subtitle: 'گیاهی · اصفهان خیابان چهارباغ',
    price: 560000,
    rating: '4.4',
    icon: Icons.restaurant_rounded,
    extra: {'cuisine': 'گیاهی', 'hours': '۱۰:۰۰ تا ۲۲:۰۰', 'capacity': '۴۰ نفر'},
  ),
];

final List<MockCatalogItem> mockFoodItems = [
  const MockCatalogItem(
    id: 'food-1',
    title: 'چلوکباب کوبیده (دو سیخ)',
    subtitle: 'شاطر عباس · ارسال ۳۰ دقیقه‌ای',
    price: 480000,
    rating: '4.6',
    icon: Icons.delivery_dining_rounded,
    extra: {'preparation': '۲۵ دقیقه'},
  ),
  const MockCatalogItem(
    id: 'food-2',
    title: 'پیتزا مخصوص لارج',
    subtitle: 'پیتزا پالazzo · ارسال ۴۵ دقیقه‌ای',
    price: 620000,
    rating: '4.3',
    icon: Icons.local_pizza_rounded,
    extra: {'preparation': '۳۵ دقیقه'},
  ),
  const MockCatalogItem(
    id: 'food-3',
    title: 'قورمه‌سبزی خانواده',
    subtitle: 'آشپزخانه مامان‌بزرگ · ارسال ۴۰ دقیقه‌ای',
    price: 390000,
    rating: '4.7',
    icon: Icons.delivery_dining_rounded,
    extra: {'preparation': '۳۰ دقیقه'},
  ),
  const MockCatalogItem(
    id: 'food-4',
    title: 'ساندویچ شاویarma عربی',
    subtitle: 'شاورما پلس · ارسال ۲۵ دقیقه‌ای',
    price: 310000,
    rating: '4.4',
    icon: Icons.delivery_dining_rounded,
    extra: {'preparation': '۲۰ دقیقه'},
  ),
  const MockCatalogItem(
    id: 'food-5',
    title: 'سالاد سزار + سوپ مخصوص',
    subtitle: 'کافه لوند · ارسال ۳۵ دقیقه‌ای',
    price: 340000,
    rating: '4.5',
    icon: Icons.lunch_dining_rounded,
    extra: {'preparation': '۲۵ دقیقه'},
  ),
];

final List<MockCatalogItem> mockSupermarketItems = [
  const MockCatalogItem(
    id: 'sm-1',
    title: 'آب معدنی دماوند — بسته ۶ عددی',
    subtitle: 'سوپرمارکت افق · کیش',
    price: 145000,
    icon: Icons.storefront_rounded,
    extra: {'unit': 'بسته'},
  ),
  const MockCatalogItem(
    id: 'sm-2',
    title: 'میوه فصل — سبد ۳ کیلویی',
    subtitle: 'میوه‌فروشی سنتر · مشهد',
    price: 520000,
    icon: Icons.shopping_basket_rounded,
    extra: {'unit': 'سبد'},
  ),
  const MockCatalogItem(
    id: 'sm-3',
    title: 'نان تازه لواش — ۵ عدد',
    subtitle: 'نانوایی حضرت · تهران',
    price: 85000,
    icon: Icons.bakery_dining_rounded,
    extra: {'unit': 'بسته'},
  ),
  const MockCatalogItem(
    id: 'sm-4',
    title: 'تن‌ماهی آبگوشت‌ساز — ۴ قوطی',
    subtitle: 'سوپرمارکت افق · کیش',
    price: 320000,
    icon: Icons.storefront_rounded,
    extra: {'unit': 'بسته'},
  ),
  const MockCatalogItem(
    id: 'sm-5',
    title: 'پک صبحانه هتلی',
    subtitle: 'مارکت سفر · برای اتاق هتل',
    price: 410000,
    icon: Icons.emoji_food_beverage_rounded,
    extra: {'unit': 'پک'},
  ),
];

final List<MockCatalogItem> mockStoreItems = [
  const MockCatalogItem(
    id: 'store-1',
    title: 'هدفون بی‌سیم پرو‌ماکس',
    subtitle: 'گجت استور · گارانتی ۱۸ ماه',
    price: 2450000,
    rating: '4.5',
    icon: Icons.headphones_rounded,
    extra: {'warranty': '۱۸ ماه', 'brand': 'ProMax'},
  ),
  const MockCatalogItem(
    id: 'store-2',
    title: 'ادکلن مردانه بلک‌ود — ۱۰۰ml',
    subtitle: 'پرفیوم لند · اورجینال',
    price: 3900000,
    rating: '4.7',
    icon: Icons.spa_rounded,
    extra: {'warranty': 'اصالت کالا', 'brand': 'BlackOud'},
  ),
  const MockCatalogItem(
    id: 'store-3',
    title: 'کیف چرم دست‌دوز',
    subtitle: 'چرم درسا · تبریز',
    price: 2800000,
    rating: '4.8',
    icon: Icons.shopping_bag_rounded,
    extra: {'warranty': 'دوخت و چرم', 'brand': 'Dorsa'},
  ),
  const MockCatalogItem(
    id: 'store-4',
    title: 'پاوربانک ۲۰٬۰۰۰ میلی‌آمپر',
    subtitle: 'گجت استور · شارژ سریع',
    price: 1650000,
    rating: '4.4',
    icon: Icons.battery_charging_full_rounded,
    extra: {'warranty': '۱۲ ماه', 'brand': 'Anker'},
  ),
];

final List<MockCatalogItem> mockLocalServiceItems = [
  const MockCatalogItem(
    id: 'local-1',
    title: 'راهنمای تور محلی — استانبول',
    subtitle: 'فارسی‌زبان · نیم‌روز شهری',
    price: 2200000,
    rating: '4.8',
    icon: Icons.place_rounded,
    extra: {'duration': '۴ ساعت', 'languages': 'فارسی، ترکی'},
  ),
  const MockCatalogItem(
    id: 'local-2',
    title: 'عکاس سفر حرفه‌ای',
    subtitle: 'دو ساعت عکاسی + ۳۰ رتوش‌شده',
    price: 3100000,
    rating: '4.9',
    icon: Icons.photo_camera_rounded,
    extra: {'duration': '۲ ساعت', 'languages': 'فارسی، انگلیسی'},
  ),
  const MockCatalogItem(
    id: 'local-3',
    title: 'همراه فرودگاه (Meet & Greet)',
    subtitle: 'پذیرش و همراهی از در هواپیما',
    price: 1750000,
    rating: '4.6',
    icon: Icons.support_agent_rounded,
    extra: {'duration': 'تا خروج از فرودگاه', 'languages': 'فارسی، انگلیسی'},
  ),
  const MockCatalogItem(
    id: 'local-4',
    title: 'راننده منتسب روزانه',
    subtitle: '۸ ساعت در شهر — سوخت با راننده',
    price: 2800000,
    rating: '4.5',
    icon: Icons.local_taxi_rounded,
    extra: {'duration': '۸ ساعت', 'languages': 'فارسی'},
  ),
];

final List<MockCatalogItem> mockInsuranceItems = [
  const MockCatalogItem(
    id: 'ins-1',
    title: 'بیمه مسافرتی پایه — اروپا/شنگن',
    subtitle: 'پوشش ۳۰٬۰۰۰ یورو · سامان',
    price: 890000,
    rating: '4.6',
    icon: Icons.health_and_safety_rounded,
    extra: {'coverage': '۳۰٬۰۰۰ یورو', 'duration': 'تا ۳۰ روز'},
  ),
  const MockCatalogItem(
    id: 'ins-2',
    title: 'بیمه مسافرتی کامل — شنگن',
    subtitle: 'پوشش ۵۰٬۰۰۰ یورو · سامان',
    price: 1350000,
    rating: '4.8',
    icon: Icons.health_and_safety_rounded,
    extra: {'coverage': '۵۰٬۰۰۰ یورو', 'duration': 'تا ۳۰ روز'},
  ),
  const MockCatalogItem(
    id: 'ins-3',
    title: 'بیمه سفر داخلی',
    subtitle: 'پوشش پزشکی و تأخیر پرواز',
    price: 320000,
    rating: '4.3',
    icon: Icons.health_and_safety_rounded,
    extra: {'coverage': '۵۰٬۰۰۰٬۰۰۰ تومان', 'duration': 'تا ۱۴ روز'},
  ),
  const MockCatalogItem(
    id: 'ins-4',
    title: 'بیمه سالانه چندسفره',
    subtitle: 'مناسب مسافران پرتردد · ۱۲ ماه',
    price: 5600000,
    rating: '4.9',
    icon: Icons.verified_user_rounded,
    extra: {'coverage': '۱۰۰٬۰۰۰ یورو', 'duration': '۱۲ ماه'},
  ),
];

final List<MockCatalogItem> mockTranslatorItems = [
  const MockCatalogItem(
    id: 'tr-1',
    title: 'سارا محمدی — مترجم همراه',
    subtitle: 'ترکی استانبولی · استانبول',
    price: 2400000,
    rating: '4.8',
    icon: Icons.translate_rounded,
    extra: {'languages': 'فارسی، ترکی، انگلیسی', 'experience': '۶ سال'},
  ),
  const MockCatalogItem(
    id: 'tr-2',
    title: 'آرش کریمی — مترجم تجاری',
    subtitle: 'انگلیسی · دبی',
    price: 3200000,
    rating: '4.7',
    icon: Icons.translate_rounded,
    extra: {'languages': 'فارسی، انگلیسی، عربی', 'experience': '۹ سال'},
  ),
  const MockCatalogItem(
    id: 'tr-3',
    title: 'مینا احدی — مترجم پزشکی',
    subtitle: 'انگلیسی · تفلیس',
    price: 2900000,
    rating: '4.6',
    icon: Icons.translate_rounded,
    extra: {'languages': 'فارسی، انگلیسی', 'experience': '۷ سال'},
  ),
  const MockCatalogItem(
    id: 'tr-4',
    title: 'دانیال رستمی — مترجم روسی',
    subtitle: 'روسی · ایروان',
    price: 2600000,
    rating: '4.5',
    icon: Icons.translate_rounded,
    extra: {'languages': 'فارسی، روسی', 'experience': '۵ سال'},
  ),
];

const mockEmergencyContacts = [
  ('اورژانس کشور (ایران)', '۱۱۵'),
  ('پلیس (ایران)', '۱۱۰'),
  ('اورژانس بین‌المللی (اکسپدیا)', '+41 22 929 70 00'),
  ('حمایت کنسولی وزارت خارجه', '+98 21 6115 4000'),
];

// ---------------------------------------------------------------------------
// Form-only quick services
// ---------------------------------------------------------------------------

const mockTaxiClasses = ['شهرской عادی', 'اسنپ‌استایل', 'VIP فرودگاهی'];

const mockSimOperators = ['همراه اول', 'ایرانسل', 'رایتل', 'مخابرات'];

const mockSimTopUpAmounts = [100000, 200000, 500000, 1000000];

const mockEmergencySubjects = [
  'گم‌شدن پاسپورت',
  'مراجعه پزشکی',
  'تصادف و حادثه',
  'مشکل قانونی',
];

const mockWalletTopUpAmounts = [500000, 1000000, 2000000, 5000000];
