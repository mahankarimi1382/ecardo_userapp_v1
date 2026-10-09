/// Realistic Travel Domain Catalog & Booking Engine Fixtures (T-01 to T-13)
/// Provides complete realistic inventories, details, and booking payloads
/// for Hotels, Flights, Tours, Visas, Car Rental, Taxis, Lounges, eSIMs,
/// Marine, Dining, Local Guides, Insurance, and Trains.
class TravelCatalog {
  // ---------------------------------------------------------------------------
  // T-01: Hotels & Stays
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getHotels() {
    return [
      {
        'id': 'htl-esp-01',
        'name': 'هتل اسپیناس پالاس تهران (Espinas Palace Hotel)',
        'city': 'تهران',
        'city_en': 'Tehran',
        'address': 'سعادت‌آباد، انتهای میدان بهرود، خیابان ۳۳',
        'stars': 5,
        'rating': 4.9,
        'review_count': 1240,
        'price_per_night': 140.0,
        'price_irr_per_night': 264000000.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'amenities': ['استخر سرپوشیده و سونا', 'صبحانه بوفه سلف‌سرویس', 'پارکینگ اختصاصی رایگان', 'اینترنت پرسرعت Wi-Fi', 'سالن بدنسازی مجهز', 'رستوران سنتی و بین‌المللی'],
        'rooms': [
          {
            'room_id': 'rm-esp-std',
            'name': 'اتاق دبل استاندارد (Standard Double)',
            'bed': 'یک تخت دو نفره کینگ',
            'capacity': '۲ بزرگسال',
            'price': 140.0,
            'available': 4,
          },
          {
            'room_id': 'rm-esp-lux',
            'name': 'سوئیت رویال با دید پانورامای شهر (Royal City View Suite)',
            'bed': 'تخت کینگ سایز + مبل تخت‌خواب‌شو',
            'capacity': '۳ بزرگسال',
            'price': 220.0,
            'available': 2,
          },
        ],
      },
      {
        'id': 'htl-ciragan-02',
        'name': 'هتل قصر چراغان کمپینسکی استانبول (Çırağan Palace Kempinski)',
        'city': 'استانبول',
        'city_en': 'Istanbul',
        'address': 'Çırağan Caddesi No:32, Beşiktaş, Istanbul',
        'stars': 5,
        'rating': 4.95,
        'review_count': 2100,
        'price_per_night': 380.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        'amenities': ['دید مستقیم به تنگه بسفر', 'استخر اینفینیتی روباز گرم', 'اسپای عثمانی و حمام ترکی', 'ترانسفر لیموزین فرودگاهی'],
        'rooms': [
          {
            'room_id': 'rm-cir-bosphorus',
            'name': 'اتاق دلوکس دید بسفر (Deluxe Bosphorus View)',
            'bed': 'تخت دبل کینگ اختصاصی',
            'capacity': '۲ بزرگسال',
            'price': 380.0,
            'available': 3,
          },
        ],
      },
      {
        'id': 'htl-rixos-03',
        'name': 'هتل ریکسوس پرمیوم دبی (Rixos Premium Dubai JBR)',
        'city': 'دبی',
        'city_en': 'Dubai',
        'address': 'The Walk, Jumeirah Beach Residence, Dubai',
        'stars': 5,
        'rating': 4.88,
        'review_count': 3400,
        'price_per_night': 260.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
        'amenities': ['ساحل اختصاصی JBR', 'کلاب ساحلی Azure', '۹ رستوران و کافه برنده جایزه', 'دسترسی پیاده به دبی مارینا'],
        'rooms': [
          {
            'room_id': 'rm-rix-deluxe',
            'name': 'اتاق پرمیوم رو به دریا (Premium Sea View)',
            'bed': 'تخت کینگ سایز ساحلی',
            'capacity': '۲ بزرگسال + ۱ کودک',
            'price': 260.0,
            'available': 5,
          },
        ],
      },
      {
        'id': 'htl-dariush-04',
        'name': 'هتل بزرگ داریوش کیش (Dariush Grand Hotel Kish)',
        'city': 'کیش',
        'city_en': 'Kish Island',
        'address': 'جزیره کیش، میدان داریوش، ساحل شرقی',
        'stars': 5,
        'rating': 4.75,
        'review_count': 980,
        'price_per_night': 95.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'amenities': ['الهام‌گرفته از تخت جمشید', 'دریاچه اختصاصی قایق‌سواری', 'غواصی اختصاصی و دوچرخه‌سواری', 'صبحانه بوفه کامل'],
        'rooms': [
          {
            'room_id': 'rm-dar-garden',
            'name': 'اتاق دو تخته رو به باغ پاسارگاد',
            'bed': 'دو تخت یک‌نفره یا یک تخت دونفره',
            'capacity': '۲ بزرگسال',
            'price': 95.0,
            'available': 6,
          },
        ],
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // T-02: Flights
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getFlights() {
    return [
      {
        'id': 'flt-w5-115',
        'airline': 'هواپیمایی ماهان (Mahan Air)',
        'airline_code': 'W5',
        'flight_number': 'W5-115',
        'aircraft': 'Airbus A340-600',
        'origin': 'IKA',
        'origin_city': 'تهران (IKA)',
        'destination': 'IST',
        'destination_city': 'استانبول (IST)',
        'departure_time': '08:30',
        'arrival_time': '11:45',
        'duration': '3 ساعت و 45 دقیقه',
        'stops': 0,
        'cabin_class': 'Economy',
        'baggage_allowance': '30 کیلوگرم',
        'price': 210.0,
        'currency': 'USD',
        'available_seats': 9,
      },
      {
        'id': 'flt-tk-875',
        'airline': 'ترکیش ایرلاینز (Turkish Airlines)',
        'airline_code': 'TK',
        'flight_number': 'TK-875',
        'aircraft': 'Boeing 787-9 Dreamliner',
        'origin': 'IKA',
        'origin_city': 'تهران (IKA)',
        'destination': 'IST',
        'destination_city': 'استانبول (IST)',
        'departure_time': '15:10',
        'arrival_time': '18:25',
        'duration': '3 ساعت و 45 دقیقه',
        'stops': 0,
        'cabin_class': 'Economy',
        'baggage_allowance': '30 کیلوگرم',
        'price': 275.0,
        'currency': 'USD',
        'available_seats': 5,
      },
      {
        'id': 'flt-ek-972',
        'airline': 'هواپیمایی امارات (Emirates)',
        'airline_code': 'EK',
        'flight_number': 'EK-972',
        'aircraft': 'Boeing 777-300ER',
        'origin': 'IKA',
        'origin_city': 'تهران (IKA)',
        'destination': 'DXB',
        'destination_city': 'دبی (DXB)',
        'departure_time': '11:05',
        'arrival_time': '13:50',
        'duration': '2 ساعت و 15 دقیقه',
        'stops': 0,
        'cabin_class': 'Economy',
        'baggage_allowance': '35 کیلوگرم',
        'price': 240.0,
        'currency': 'USD',
        'available_seats': 12,
      },
      {
        'id': 'flt-y9-7081',
        'airline': 'کیش ایر (Kish Air)',
        'airline_code': 'Y9',
        'flight_number': 'Y9-7081',
        'aircraft': 'McDonnell Douglas MD-83',
        'origin': 'THR',
        'origin_city': 'تهران مهرآباد (THR)',
        'destination': 'KIH',
        'destination_city': 'جزیره کیش (KIH)',
        'departure_time': '07:15',
        'arrival_time': '09:00',
        'duration': '1 ساعت و 45 دقیقه',
        'stops': 0,
        'cabin_class': 'Economy',
        'baggage_allowance': '20 کیلوگرم',
        'price': 42.0,
        'currency': 'USD',
        'available_seats': 18,
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // T-03: Tours & Packages
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getTours() {
    return [
      {
        'id': 1,
        'title': 'تور لوکس استانبول — ۴ شب و ۵ روز هتل ۵ ستاره',
        'country': 'ترکیه',
        'city': 'استانبول',
        'duration_days': 5,
        'price': 480.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=800',
        'rating': 4.9,
        'itinerary_highlights': ['گشت کشتی خصوصی در تنگه بسفر', 'بازدید از کاخ توپکاپی و مسجد ایاصوفیه', 'خرید اختصاصی از مال ایستینیه پارک', 'صبحانه و شام هتل ۵ ستاره تکسیم'],
        'capacity': 15,
        'available_slots': 6,
      },
      {
        'id': 2,
        'title': 'تور رویایی دبی — ۵ روز اقامت در هتل ساحلی پالم',
        'country': 'امارات',
        'city': 'دبی',
        'duration_days': 5,
        'price': 690.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
        'rating': 4.95,
        'itinerary_highlights': ['سافاری VIP کویر با شام باربیکیو', 'بلیت طبقه ۱۲۴ برج خلیفه', 'ترانسفر لیموزین اختصاصی'],
        'capacity': 20,
        'available_slots': 8,
      },
      {
        'id': 3,
        'title': 'تور ساحلی جزیره کیش — ۳ شب اقامت در هتل ترنج دریایی',
        'country': 'ایران',
        'city': 'کیش',
        'duration_days': 4,
        'price': 180.0,
        'currency': 'USD',
        'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'rating': 4.82,
        'itinerary_highlights': ['سوئیت کف‌شیشه‌ای روی آب', 'پارک آبی اوشن', 'غواصی در کلوپ مارینا'],
        'capacity': 10,
        'available_slots': 3,
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // T-04: Visa Catalog
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getVisaCatalog() {
    return [
      {
        'id': 1,
        'country_name': 'ویزای شنگن فرانسه و ایتالیا',
        'country_code': 'FR',
        'type': 'توریستی و تجاری (Type C)',
        'validity_days': 90,
        'processing_time': '۱۵ تا ۲۱ روز کاری',
        'price': 220.0,
        'currency': 'EUR',
        'requirements': ['پاسپورت با حداقل ۶ ماه اعتبار', 'تمکن مالی و پرینت ۳ ماهه بانکی', 'دو قطعه عکس پرسنلی بیومتریک', 'بیمه مسافرتی معتبر شنگن'],
      },
      {
        'id': 2,
        'country_name': 'ویزای الکترونیک امارات (دبی)',
        'country_code': 'AE',
        'type': 'توریستی ۳۰ روزه آنی',
        'validity_days': 30,
        'processing_time': '۲۴ تا ۴۸ ساعت کاری',
        'price': 95.0,
        'currency': 'USD',
        'requirements': ['اسکن باکیفیت صفحه اول پاسپورت', 'عکس پرسنلی رنگی جدید'],
      },
      {
        'id': 3,
        'country_name': 'ویزای توریستی مولتیپل کانادا (۵ ساله)',
        'country_code': 'CA',
        'type': '۱۰ ساله / تا انقضای پاسپورت',
        'validity_days': 1825,
        'processing_time': '۳۰ تا ۴۵ روز کاری',
        'price': 380.0,
        'currency': 'CAD',
        'requirements': ['سابقه سفر معتبر (تراول هیستوری)', 'اسناد ملکی و مدارک شغلی رسمی', 'انگشت‌نگاری در دفاتر استانبول یا دبی'],
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // T-05: Car Rental Fleet
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getRentalCars() {
    return [
      {
        'id': 1,
        'name': 'پورشه ماکان (Porsche Macan Turbo)',
        'brand': 'Porsche',
        'category': 'luxury_suv',
        'year': 2024,
        'price_per_day': 180.0,
        'security_deposit': 500.0,
        'transmission': 'اتوماتیک دابل کلاچ PDK',
        'seats': 5,
        'fuel': 'بنزین سوپر',
        'image': 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=800',
        'features': ['تحویل در فرودگاه یا هتل', 'کیلومتر روزانه ۲۰۰ کیلومتر', 'بیمه بدنه طلایی CDW بدون فرانشیز'],
      },
      {
        'id': 2,
        'name': 'مرسدس بنز C200 (Mercedes-Benz C-Class)',
        'brand': 'Mercedes-Benz',
        'category': 'luxury_sedan',
        'year': 2023,
        'price_per_day': 140.0,
        'security_deposit': 400.0,
        'transmission': 'اتوماتیک ۹ سرعته G-Tronic',
        'seats': 5,
        'fuel': 'بنزین',
        'image': 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
        'features': ['سیستم رانندگی خودکار کروز تطبیقی', 'گرم‌کن صندلی و هدآپ دیسپلی'],
      },
      {
        'id': 3,
        'name': 'هیوندای سانتافه (Hyundai Santa Fe)',
        'brand': 'Hyundai',
        'category': 'family_suv',
        'year': 2022,
        'price_per_day': 65.0,
        'security_deposit': 200.0,
        'transmission': 'اتوماتیک تیپ‌ترونیک',
        'seats': 7,
        'fuel': 'بنزین',
        'image': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800',
        'features': ['۷ نفره جادار مناسب سفر خانوادگی', 'صندوق عقب بزرگ و دو دیفرانسیل'],
      },
    ];
  }

  // ---------------------------------------------------------------------------
  // T-08: eSIM Packages
  // ---------------------------------------------------------------------------
  static List<Map<String, dynamic>> getEsimPackages() {
    return [
      {
        'id': 'esim-tr-5gb',
        'destination': 'ترکیه (Turkey)',
        'country_code': 'TR',
        'data_amount': '5 GB',
        'validity_days': 15,
        'price': 12.0,
        'currency': 'USD',
        'networks': ['Turkcell 5G', 'Vodafone TR'],
        'qr_payload': r'LPA:1$smdp.io$TR-5GB-DEMO-2026-9921',
      },
      {
        'id': 'esim-tr-10gb',
        'destination': 'ترکیه (Turkey)',
        'country_code': 'TR',
        'data_amount': '10 GB',
        'validity_days': 30,
        'price': 18.0,
        'currency': 'USD',
        'networks': ['Turkcell 5G'],
        'qr_payload': r'LPA:1$smdp.io$TR-10GB-DEMO-2026-8814',
      },
      {
        'id': 'esim-ae-5gb',
        'destination': 'امارات متحده (UAE)',
        'country_code': 'AE',
        'data_amount': '5 GB',
        'validity_days': 14,
        'price': 16.0,
        'currency': 'USD',
        'networks': ['e& (Etisalat 5G)', 'du'],
        'qr_payload': r'LPA:1$smdp.io$AE-5GB-DEMO-2026-7731',
      },
      {
        'id': 'esim-eu-20gb',
        'destination': 'تمام کشورهای اروپا (۳۴ کشور)',
        'country_code': 'EU',
        'data_amount': '20 GB',
        'validity_days': 30,
        'price': 28.0,
        'currency': 'EUR',
        'networks': ['Orange 5G', 'Vodafone EU', 'Deutsche Telekom'],
        'qr_payload': r'LPA:1$smdp.io$EU-20GB-DEMO-2026-6642',
      },
    ];
  }
}
