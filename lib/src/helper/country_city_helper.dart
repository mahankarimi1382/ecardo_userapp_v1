/// Helper class providing city data per country for dropdown selection in User Settings.
class CountryCityHelper {
  static const Map<String, List<String>> _countryCities = {
    // Iran (Islamic Republic of)
    'IR': [
      'Tehran',
      'Mashhad',
      'Isfahan',
      'Karaj',
      'Shiraz',
      'Tabriz',
      'Qom',
      'Ahvaz',
      'Kermanshah',
      'Urmia',
      'Rasht',
      'Zahedan',
      'Hamedan',
      'Kerman',
      'Yazd',
      'Ardabil',
      'Bandar Abbas',
      'Arak',
      'Zanjan',
      'Sanandaj',
      'Qazvin',
      'Khorramabad',
      'Gorgan',
      'Sari',
      'Shahrekord',
      'Semnan',
      'Bojnurd',
      'Ilam',
      'Bushehr',
      'Birjand',
      'Yasuj',
      'Kish',
      'Qeshm',
      'Kashan',
      'Neyshabur',
      'Abadan',
      'Dezful',
      'Amol',
      'Babol',
    ],

    // Turkey
    'TR': [
      'Istanbul',
      'Ankara',
      'Izmir',
      'Bursa',
      'Antalya',
      'Adana',
      'Konya',
      'Gaziantep',
      'Sanliurfa',
      'Mersin',
      'Diyarbakir',
      'Kayseri',
      'Eskisehir',
      'Trabzon',
      'Samsun',
      'Denizli',
      'Bodrum',
    ],

    // United Arab Emirates
    'AE': [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
      'Ras Al Khaimah',
      'Fujairah',
      'Umm Al Quwain',
      'Al Ain',
    ],

    // United Kingdom
    'GB': [
      'London',
      'Manchester',
      'Birmingham',
      'Edinburgh',
      'Glasgow',
      'Liverpool',
      'Bristol',
      'Leeds',
      'Sheffield',
      'Newcastle',
      'Belfast',
      'Cardiff',
    ],

    // United States
    'US': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'Philadelphia',
      'San Antonio',
      'San Diego',
      'Dallas',
      'San Jose',
      'Austin',
      'San Francisco',
      'Seattle',
      'Miami',
      'Boston',
      'Denver',
      'Atlanta',
      'Washington, D.C.',
    ],

    // Germany
    'DE': [
      'Berlin',
      'Munich',
      'Frankfurt',
      'Hamburg',
      'Cologne',
      'Stuttgart',
      'Dusseldorf',
      'Dortmund',
      'Essen',
      'Leipzig',
      'Bremen',
      'Dresden',
      'Hanover',
      'Nuremberg',
    ],

    // Canada
    'CA': [
      'Toronto',
      'Montreal',
      'Vancouver',
      'Calgary',
      'Edmonton',
      'Ottawa',
      'Winnipeg',
      'Quebec City',
      'Hamilton',
      'Halifax',
      'Victoria',
    ],

    // France
    'FR': [
      'Paris',
      'Marseille',
      'Lyon',
      'Toulouse',
      'Nice',
      'Nantes',
      'Strasbourg',
      'Montpellier',
      'Bordeaux',
      'Lille',
      'Rennes',
      'Reims',
    ],

    // China
    'CN': [
      'Beijing',
      'Shanghai',
      'Guangzhou',
      'Shenzhen',
      'Chengdu',
      'Hangzhou',
      'Wuhan',
      'Xi\'an',
      'Chongqing',
      'Tianjin',
      'Nanjing',
      'Suzhou',
      'Changsha',
      'Qingdao',
    ],

    // Russia
    'RU': [
      'Moscow',
      'Saint Petersburg',
      'Novosibirsk',
      'Yekaterinburg',
      'Kazan',
      'Nizhny Novgorod',
      'Chelyabinsk',
      'Samara',
      'Omsk',
      'Rostov-on-Don',
      'Ufa',
      'Krasnoyarsk',
      'Voronezh',
      'Perm',
      'Volgograd',
      'Sochi',
    ],

    // Iraq
    'IQ': [
      'Baghdad',
      'Basra',
      'Erbil',
      'Sulaymaniyah',
      'Najaf',
      'Karbala',
      'Mosul',
      'Kirkuk',
      'Duhok',
      'Nasiriyah',
      'Amarah',
      'Hillah',
    ],

    // Saudi Arabia
    'SA': [
      'Riyadh',
      'Jeddah',
      'Mecca',
      'Medina',
      'Dammam',
      'Khobar',
      'Tabuk',
      'Dhahran',
      'Taif',
      'Abha',
      'Jubail',
      'Yanbu',
    ],

    // Qatar
    'QA': [
      'Doha',
      'Al Rayyan',
      'Al Wakrah',
      'Al Khor',
      'Lusail',
      'Umm Salal',
      'Mesaieed',
    ],

    // Oman
    'OM': [
      'Muscat',
      'Salalah',
      'Sohar',
      'Nizwa',
      'Sur',
      'Seeb',
      'Barka',
    ],

    // Kuwait
    'KW': [
      'Kuwait City',
      'Hawalli',
      'Salmiya',
      'Al Ahmadi',
      'Farwaniya',
      'Jahra',
    ],

    // Bahrain
    'BH': [
      'Manama',
      'Riffa',
      'Muharraq',
      'Hamad Town',
      'A\'ali',
      'Isa Town',
    ],

    // Armenia
    'AM': [
      'Yerevan',
      'Gyumri',
      'Vanadzor',
      'Vagharshapat',
      'Abovyan',
      'Kapan',
      'Dilijan',
    ],

    // Georgia
    'GE': [
      'Tbilisi',
      'Batumi',
      'Kutaisi',
      'Rustavi',
      'Gori',
      'Zugdidi',
      'Poti',
    ],

    // Azerbaijan
    'AZ': [
      'Baku',
      'Ganja',
      'Sumqayit',
      'Mingachevir',
      'Shirvan',
      'Nakhchivan',
      'Lankaran',
      'Shaki',
    ],

    // Afghanistan
    'AF': [
      'Kabul',
      'Herat',
      'Mazar-i-Sharif',
      'Kandahar',
      'Jalalabad',
      'Kunduz',
      'Ghazni',
    ],

    // India
    'IN': [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Pune',
      'Ahmedabad',
      'Jaipur',
      'Surat',
    ],

    // Pakistan
    'PK': [
      'Karachi',
      'Lahore',
      'Islamabad',
      'Rawalpindi',
      'Faisalabad',
      'Multan',
      'Peshawar',
      'Quetta',
    ],

    // Malaysia
    'MY': [
      'Kuala Lumpur',
      'George Town',
      'Johor Bahru',
      'Kota Kinabalu',
      'Kuching',
      'Ipoh',
      'Malacca City',
    ],
  };

  /// Returns a list of cities for a given country code (e.g. 'IR', 'TR', 'AE').
  /// Also checks case-insensitively and by country name if code doesn't match directly.
  static List<String> getCities(String? countryCode, {String? countryName}) {
    if (countryCode == null || countryCode.trim().isEmpty) {
      if (countryName != null && countryName.trim().isNotEmpty) {
        return _getCitiesByName(countryName.trim());
      }
      return const [];
    }

    final code = countryCode.trim().toUpperCase();
    if (_countryCities.containsKey(code)) {
      return List<String>.from(_countryCities[code]!);
    }

    if (countryName != null && countryName.trim().isNotEmpty) {
      return _getCitiesByName(countryName.trim());
    }

    return const [];
  }

  static List<String> _getCitiesByName(String name) {
    final lower = name.toLowerCase();
    for (final entry in _countryCities.entries) {
      if (entry.key == 'IR' && (lower.contains('iran') || lower.contains('ایران'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'TR' && (lower.contains('turkey') || lower.contains('türkiye') || lower.contains('ترکیه'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'AE' && (lower.contains('emirates') || lower.contains('uae') || lower.contains('امارات'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'GB' && (lower.contains('united kingdom') || lower.contains('britain') || lower.contains('انگلیس'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'US' && (lower.contains('united states') || lower.contains('usa') || lower.contains('آمریکا'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'DE' && (lower.contains('germany') || lower.contains('deutschland') || lower.contains('آلمان'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'CA' && (lower.contains('canada') || lower.contains('کانادا'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'FR' && (lower.contains('france') || lower.contains('فرانسه'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'CN' && (lower.contains('china') || lower.contains('چین'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'RU' && (lower.contains('russia') || lower.contains('روسیه'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'IQ' && (lower.contains('iraq') || lower.contains('عراق'))) {
        return List<String>.from(entry.value);
      }
      if (entry.key == 'SA' && (lower.contains('saudi') || lower.contains('عربستان'))) {
        return List<String>.from(entry.value);
      }
    }
    return const [];
  }
}
