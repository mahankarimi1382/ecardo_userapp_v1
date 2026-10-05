import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 1. Train Categories & Types (DB Navigator & Trainline European Patterns)
// ---------------------------------------------------------------------------

enum TrainCategory {
  highSpeed,   // ICE / TGV / Frecciarossa / High-Speed
  express,     // IC / EC / Express
  regional,    // RE / RB / Regional
  nightSleeper // Nightjet / Euronight / Sleeper
}

extension TrainCategoryExt on TrainCategory {
  String get code => switch (this) {
        TrainCategory.highSpeed => 'high_speed',
        TrainCategory.express => 'express',
        TrainCategory.regional => 'regional',
        TrainCategory.nightSleeper => 'night_sleeper',
      };

  IconData get icon => switch (this) {
        TrainCategory.highSpeed => Icons.bolt_rounded,
        TrainCategory.express => Icons.speed_rounded,
        TrainCategory.regional => Icons.train_rounded,
        TrainCategory.nightSleeper => Icons.bedtime_rounded,
      };

  String localizedLabel(BuildContext context, {required bool isRtl}) {
    return switch (this) {
      TrainCategory.highSpeed =>
        isRtl ? 'قطار تندرو (High-Speed)' : 'High-Speed Rail',
      TrainCategory.express =>
        isRtl ? 'اکسپرس بین‌شهری (Express)' : 'InterCity Express',
      TrainCategory.regional =>
        isRtl ? 'محلی و منطقه‌ای (Regional)' : 'Regional Rail',
      TrainCategory.nightSleeper =>
        isRtl ? 'شب‌رو خواب‌دار (Night Sleeper)' : 'Night Sleeper',
    };
  }
}

// ---------------------------------------------------------------------------
// 2. Sleeper Berths (European Couchette & Sleeper Standards)
// ---------------------------------------------------------------------------

enum SleeperBerthType {
  none,            // Standard seating
  couchette6,      // 6-berth shared couchette (DB / Nightjet style)
  couchette4,      // 4-berth comfort couchette
  doubleSleeper,   // 2-bed private sleeper cabin with washbasin
  singleDeluxe,    // 1-bed private deluxe coupe with private shower/WC
}

extension SleeperBerthTypeExt on SleeperBerthType {
  String get code => switch (this) {
        SleeperBerthType.none => 'none',
        SleeperBerthType.couchette6 => 'couchette_6',
        SleeperBerthType.couchette4 => 'couchette_4',
        SleeperBerthType.doubleSleeper => 'double_sleeper',
        SleeperBerthType.singleDeluxe => 'single_deluxe',
      };

  int get maxOccupants => switch (this) {
        SleeperBerthType.none => 1,
        SleeperBerthType.couchette6 => 6,
        SleeperBerthType.couchette4 => 4,
        SleeperBerthType.doubleSleeper => 2,
        SleeperBerthType.singleDeluxe => 1,
      };

  IconData get icon => switch (this) {
        SleeperBerthType.none => Icons.airline_seat_recline_normal_rounded,
        SleeperBerthType.couchette6 => Icons.hotel_rounded,
        SleeperBerthType.couchette4 => Icons.bed_rounded,
        SleeperBerthType.doubleSleeper => Icons.king_bed_rounded,
        SleeperBerthType.singleDeluxe => Icons.meeting_room_rounded,
      };

  String localizedTitle({required bool isRtl}) => switch (this) {
        SleeperBerthType.none =>
          isRtl ? 'صندلی سالنی معمولی' : 'Standard Seating',
        SleeperBerthType.couchette6 =>
          isRtl ? 'کوپه‌ای ۶ تخته (Couchette 6)' : '6-Berth Couchette',
        SleeperBerthType.couchette4 =>
          isRtl ? 'کوپه‌ای ۴ تخته (Couchette 4)' : '4-Berth Comfort Couchette',
        SleeperBerthType.doubleSleeper =>
          isRtl ? 'کوپه دو تخته اختصاصی (Double)' : 'Double Sleeper Cabin',
        SleeperBerthType.singleDeluxe =>
          isRtl ? 'کوپه تک‌نفره لوکس (Single Deluxe)' : 'Single Deluxe Coupe',
      };

  String localizedDescription({required bool isRtl}) => switch (this) {
        SleeperBerthType.none =>
          isRtl ? 'صندلی ارگونومیک با زاویه خواب' : 'Reclining seat with tray table',
        SleeperBerthType.couchette6 =>
          isRtl ? 'تخت، ملحفه و بالش تمیز، اقتصادی' : 'Bunks with clean linen, blanket & pillow',
        SleeperBerthType.couchette4 =>
          isRtl ? 'فضای بازتر، ۴ تخت، پذیرایی سبک' : 'Spacious 4 berths with mineral water',
        SleeperBerthType.doubleSleeper =>
          isRtl ? 'دو تخت راحت، روشویی اختصاصی، صبحانه' : '2 beds, private washbasin & breakfast',
        SleeperBerthType.singleDeluxe =>
          isRtl ? 'کابین کاملاً مستقل با سرویس بهداشتی و دوش' : 'En-suite WC/shower, premium amenity kit',
      };

  int pricePremium() => switch (this) {
        SleeperBerthType.none => 0,
        SleeperBerthType.couchette6 => 65000,
        SleeperBerthType.couchette4 => 140000,
        SleeperBerthType.doubleSleeper => 320000,
        SleeperBerthType.singleDeluxe => 580000,
      };
}

// ---------------------------------------------------------------------------
// 3. Compartment Gender Rules
// ---------------------------------------------------------------------------

enum CompartmentGenderRule {
  mixed,       // General / Mixed gender
  femaleOnly,  // Dedicated women-only compartment
  maleOnly,    // Dedicated men-only compartment
  privateCoupe // Entire coupe reserved for family/private use
}

extension CompartmentGenderRuleExt on CompartmentGenderRule {
  String get code => switch (this) {
        CompartmentGenderRule.mixed => 'mixed',
        CompartmentGenderRule.femaleOnly => 'female_only',
        CompartmentGenderRule.maleOnly => 'male_only',
        CompartmentGenderRule.privateCoupe => 'private_coupe',
      };

  IconData get icon => switch (this) {
        CompartmentGenderRule.mixed => Icons.people_alt_rounded,
        CompartmentGenderRule.femaleOnly => Icons.female_rounded,
        CompartmentGenderRule.maleOnly => Icons.male_rounded,
        CompartmentGenderRule.privateCoupe => Icons.lock_outline_rounded,
      };

  String localizedTitle({required bool isRtl}) => switch (this) {
        CompartmentGenderRule.mixed =>
          isRtl ? 'کوپه عمومی (آقا و بانو)' : 'Mixed Compartment',
        CompartmentGenderRule.femaleOnly =>
          isRtl ? 'کوپه ویژه بانوان' : 'Women-Only Compartment',
        CompartmentGenderRule.maleOnly =>
          isRtl ? 'کوپه ویژه آقایان' : 'Men-Only Compartment',
        CompartmentGenderRule.privateCoupe =>
          isRtl ? 'کوپه دربست (خانواده / خصوصی)' : 'Private Coupe (Entire)',
      };

  String localizedBadge({required bool isRtl}) => switch (this) {
        CompartmentGenderRule.mixed => isRtl ? 'عمومی' : 'Mixed',
        CompartmentGenderRule.femaleOnly => isRtl ? 'ویژه بانوان' : 'Women Only',
        CompartmentGenderRule.maleOnly => isRtl ? 'ویژه آقایان' : 'Men Only',
        CompartmentGenderRule.privateCoupe => isRtl ? 'دربست' : 'Private',
      };
}

// ---------------------------------------------------------------------------
// 4. Intermediate Stop Timeline Model (DB Navigator Timetable pattern)
// ---------------------------------------------------------------------------

class IntermediateStop {
  final String stationName;
  final String stationCode;
  final String arrivalTime;
  final String departureTime;
  final String platform;
  final int stopDurationMinutes;
  final bool isMajorHub;
  final bool isPassed;

  const IntermediateStop({
    required this.stationName,
    required this.stationCode,
    required this.arrivalTime,
    required this.departureTime,
    required this.platform,
    required this.stopDurationMinutes,
    this.isMajorHub = false,
    this.isPassed = false,
  });
}

// ---------------------------------------------------------------------------
// 5. Connection Safety Alert (European Railway Transfer Safety Rule)
// ---------------------------------------------------------------------------

enum ConnectionSafetyLevel {
  tight('Tight', Icons.timer_rounded, Colors.red),      // < 15 min
  moderate('Moderate', Icons.info_rounded, Colors.orange), // 15 - 19 min
  safe('Safe', Icons.check_circle_rounded, Colors.green); // >= 20 min

  final String displayName;
  final IconData icon;
  final Color color;

  const ConnectionSafetyLevel(this.displayName, this.icon, this.color);

  ConnectionTransferInfo createTransferInfo(int minutes, String arrPlatform, String depPlatform, String nextName, String nextNumber) {
    return ConnectionTransferInfo(
      stationName: 'Station Hub',
      stationCode: 'HUB',
      transferMinutes: minutes,
      arrivalPlatform: arrPlatform,
      departurePlatform: depPlatform,
      nextTrainName: nextName,
      nextTrainNumber: nextNumber,
    );
  }
}

class ConnectionTransferInfo {
  final String stationName;
  final String stationCode;
  final int transferMinutes;
  final String arrivalPlatform;
  final String departurePlatform;
  final String nextTrainName;
  final String nextTrainNumber;

  const ConnectionTransferInfo({
    required this.stationName,
    required this.stationCode,
    required this.transferMinutes,
    required this.arrivalPlatform,
    required this.departurePlatform,
    required this.nextTrainName,
    required this.nextTrainNumber,
  });

  ConnectionSafetyLevel get safetyLevel {
    if (transferMinutes < 15) return ConnectionSafetyLevel.tight;
    if (transferMinutes < 20) return ConnectionSafetyLevel.moderate;
    return ConnectionSafetyLevel.safe;
  }

  String localizedTitle({required bool isRtl}) => switch (safetyLevel) {
        ConnectionSafetyLevel.tight => isRtl
            ? 'هشدار تعویض قطار: زمان فشرده ($transferMinutes دقیقه)'
            : 'Tight Connection Alert ($transferMinutes min)',
        ConnectionSafetyLevel.moderate => isRtl
            ? 'تعویض قطار معمولی ($transferMinutes دقیقه)'
            : 'Moderate Connection ($transferMinutes min)',
        ConnectionSafetyLevel.safe => isRtl
            ? 'تعویض قطار ایمن و راحت ($transferMinutes دقیقه)'
            : 'Safe Connection ($transferMinutes min)',
      };

  String localizedMessage({required bool isRtl}) => switch (safetyLevel) {
        ConnectionSafetyLevel.tight => isRtl
            ? 'فرصت انتقال سکو کمتر از ۱۵ دقیقه است. در صورت تأخیر احتمالی قطار اول، ممکن است به قطار بعدی نرسید.'
            : 'Transfer window is under 15 min. Minor delays on leg 1 may cause a missed connection. Recommended only with light luggage.',
        ConnectionSafetyLevel.moderate => isRtl
            ? 'زمان استاندارد انتقال بین سکوی $arrivalPlatform و سکوی $departurePlatform. لطفاً بی‌درنگ به سمت سکوی بعدی حرکت نمایید.'
            : 'Standard transfer window between Platform $arrivalPlatform and Platform $departurePlatform. Walk directly to your departure platform.',
        ConnectionSafetyLevel.safe => isRtl
            ? 'فرصت کافی و مطمئن برای جابجایی بین سکوها، حمل بار و استفاده از خدمات ایستگاه.'
            : 'Generous transfer buffer (> 20 min). Ample time for platform navigation, luggage transit, and station amenities.',
      };
}

// ---------------------------------------------------------------------------
// 6. Mobile Ticket Voucher Barcode Standards (UIC 918.3 Aztec & QR)
// ---------------------------------------------------------------------------

enum RailPassVoucherType {
  aztec, // European Rail Standard (UIC 918-3 / DB Navigator / SNCF)
  qrCode, // Standard ISO QR Code
}

// ---------------------------------------------------------------------------
// 7. Enhanced Rail Journey / Trip Model
// ---------------------------------------------------------------------------

class RailJourney {
  final String id;
  final String operator;
  final String trainName;
  final String trainNumber;
  final TrainCategory category;
  final String origin;
  final String destination;
  final String originStation;
  final String destinationStation;
  final int departMinutes; // minutes after midnight
  final int durationMinutes;
  final int basePrice;
  final int seatsAvailable;
  final String departurePlatform;
  final String arrivalPlatform;
  final bool isDirect;
  final ConnectionTransferInfo? transferInfo;
  final List<IntermediateStop> intermediateStops;
  final List<String> amenities;
  final double onTimePunctuality; // e.g. 0.94 for 94%
  final List<SleeperBerthType> availableSleepers;
  final List<CompartmentGenderRule> availableGenderRules;
  final RailPassVoucherType voucherType;

  const RailJourney({
    required this.id,
    required this.operator,
    required this.trainName,
    required this.trainNumber,
    required this.category,
    required this.origin,
    required this.destination,
    required this.originStation,
    required this.destinationStation,
    required this.departMinutes,
    required this.durationMinutes,
    required this.basePrice,
    required this.seatsAvailable,
    required this.departurePlatform,
    required this.arrivalPlatform,
    this.isDirect = true,
    this.transferInfo,
    this.intermediateStops = const [],
    this.amenities = const [],
    this.onTimePunctuality = 0.95,
    this.availableSleepers = const [SleeperBerthType.none],
    this.availableGenderRules = const [CompartmentGenderRule.mixed],
    this.voucherType = RailPassVoucherType.aztec,
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

  int get minPrice => basePrice;
}

// ---------------------------------------------------------------------------
// 8. Generator for Realistic Rail Journeys (European & Iran Network Patterns)
// ---------------------------------------------------------------------------

List<RailJourney> generateRailJourneys({
  required String origin,
  required String destination,
  required DateTime departureDate,
}) {
  final seed = (origin.hashCode ^ destination.hashCode ^ departureDate.day ^ departureDate.month).abs();
  final _ = _SeedRandom(seed);

  final operators = [
    'Fadak (فدک)',
    'Raja Rail (رجا)',
    'Noor-ol-Reza (نورالرضا)',
    'DB ICE European Partner',
    'Safir Rail (سفیر)',
  ];

  final journeys = <RailJourney>[];

  // 1. Premium High-Speed Morning train
  journeys.add(
    RailJourney(
      id: 'rail-hs-1',
      operator: operators[0],
      trainName: 'Fadak High-Speed Express',
      trainNumber: 'ICE-504',
      category: TrainCategory.highSpeed,
      origin: origin,
      destination: destination,
      originStation: '$origin Central Hub (HBF)',
      destinationStation: '$destination Terminal 1',
      departMinutes: 390, // 06:30
      durationMinutes: 285, // 4h 45m
      basePrice: 540000,
      seatsAvailable: 34,
      departurePlatform: 'Platform 4',
      arrivalPlatform: 'Platform 7',
      isDirect: true,
      amenities: ['High-speed Wi-Fi', 'Onboard Bistro', '220V Outlets', 'Quiet Zone'],
      onTimePunctuality: 0.96,
      availableSleepers: const [
        SleeperBerthType.none,
        SleeperBerthType.couchette4,
        SleeperBerthType.doubleSleeper,
      ],
      availableGenderRules: const [
        CompartmentGenderRule.mixed,
        CompartmentGenderRule.femaleOnly,
        CompartmentGenderRule.privateCoupe,
      ],
      intermediateStops: [
        IntermediateStop(
          stationName: '$origin Central Station',
          stationCode: 'HBF',
          arrivalTime: '—',
          departureTime: '06:30',
          platform: '4',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Qom West Interchange',
          stationCode: 'QOM-W',
          arrivalTime: '07:45',
          departureTime: '07:48',
          platform: '2',
          stopDurationMinutes: 3,
          isMajorHub: false,
        ),
        const IntermediateStop(
          stationName: 'Kashan Central',
          stationCode: 'KSH',
          arrivalTime: '08:50',
          departureTime: '08:54',
          platform: '1',
          stopDurationMinutes: 4,
          isMajorHub: false,
        ),
        IntermediateStop(
          stationName: '$destination Terminal 1',
          stationCode: 'DST',
          arrivalTime: '11:15',
          departureTime: '—',
          platform: '7',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
      ],
      voucherType: RailPassVoucherType.aztec,
    ),
  );

  // 2. InterCity with Safe Connection (>20 min transfer)
  journeys.add(
    RailJourney(
      id: 'rail-transfer-safe',
      operator: operators[3],
      trainName: 'EuroConnect InterCity + RE',
      trainNumber: 'IC-2190',
      category: TrainCategory.express,
      origin: origin,
      destination: destination,
      originStation: '$origin Main Station',
      destinationStation: '$destination South Station',
      departMinutes: 480, // 08:00
      durationMinutes: 360, // 6h 00m
      basePrice: 420000,
      seatsAvailable: 19,
      departurePlatform: 'Platform 8',
      arrivalPlatform: 'Platform 3',
      isDirect: false,
      transferInfo: ConnectionTransferInfo(
        stationName: 'Semnan Central Interchange',
        stationCode: 'SMN-HBF',
        transferMinutes: 28, // SAFE: >20 min
        arrivalPlatform: 'Platform 4',
        departurePlatform: 'Platform 9',
        nextTrainName: 'Regional Express Connect',
        nextTrainNumber: 'RE-8841',
      ),
      amenities: ['Power Outlets', 'Bicycle Space', 'Snack Bar'],
      onTimePunctuality: 0.91,
      availableSleepers: const [
        SleeperBerthType.none,
        SleeperBerthType.couchette6,
        SleeperBerthType.couchette4,
      ],
      availableGenderRules: const [
        CompartmentGenderRule.mixed,
        CompartmentGenderRule.femaleOnly,
        CompartmentGenderRule.maleOnly,
      ],
      intermediateStops: [
        IntermediateStop(
          stationName: '$origin Main Station',
          stationCode: 'ORI',
          arrivalTime: '—',
          departureTime: '08:00',
          platform: '8',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Semnan Central Interchange',
          stationCode: 'SMN-HBF',
          arrivalTime: '10:35',
          departureTime: '11:03',
          platform: '4 → 9',
          stopDurationMinutes: 28,
          isMajorHub: true,
        ),
        IntermediateStop(
          stationName: '$destination South Station',
          stationCode: 'DST-S',
          arrivalTime: '14:00',
          departureTime: '—',
          platform: '3',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
      ],
      voucherType: RailPassVoucherType.aztec,
    ),
  );

  // 3. Fast Train with Tight Connection (<15 min transfer alert)
  journeys.add(
    RailJourney(
      id: 'rail-transfer-tight',
      operator: operators[1],
      trainName: 'Raja Speedlink + Local Rail',
      trainNumber: 'RJ-712',
      category: TrainCategory.express,
      origin: origin,
      destination: destination,
      originStation: '$origin North Gate',
      destinationStation: '$destination Terminal',
      departMinutes: 630, // 10:30
      durationMinutes: 310, // 5h 10m
      basePrice: 385000,
      seatsAvailable: 9,
      departurePlatform: 'Platform 2',
      arrivalPlatform: 'Platform 5',
      isDirect: false,
      transferInfo: const ConnectionTransferInfo(
        stationName: 'Garmsar Junction',
        stationCode: 'GMS',
        transferMinutes: 11, // TIGHT ALERT: <15 min!
        arrivalPlatform: 'Platform 1',
        departurePlatform: 'Platform 6B',
        nextTrainName: 'Shuttle Express',
        nextTrainNumber: 'SH-302',
      ),
      amenities: ['Free Water', 'Air Conditioning'],
      onTimePunctuality: 0.88,
      availableSleepers: const [
        SleeperBerthType.none,
        SleeperBerthType.couchette6,
      ],
      availableGenderRules: const [
        CompartmentGenderRule.mixed,
        CompartmentGenderRule.femaleOnly,
      ],
      intermediateStops: [
        IntermediateStop(
          stationName: '$origin North Gate',
          stationCode: 'ORI-N',
          arrivalTime: '—',
          departureTime: '10:30',
          platform: '2',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Garmsar Junction',
          stationCode: 'GMS',
          arrivalTime: '12:45',
          departureTime: '12:56',
          platform: '1 → 6B',
          stopDurationMinutes: 11,
          isMajorHub: true,
        ),
        IntermediateStop(
          stationName: '$destination Terminal',
          stationCode: 'DST',
          arrivalTime: '15:40',
          departureTime: '—',
          platform: '5',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
      ],
      voucherType: RailPassVoucherType.qrCode,
    ),
  );

  // 4. Night Sleeper Train (Nightjet European Pattern with Full Sleeper Berths)
  journeys.add(
    RailJourney(
      id: 'rail-night-sleeper',
      operator: operators[2],
      trainName: 'Noor Deluxe Night Sleeper',
      trainNumber: 'NJ-490',
      category: TrainCategory.nightSleeper,
      origin: origin,
      destination: destination,
      originStation: '$origin Main Railway Station',
      destinationStation: '$destination Central Station',
      departMinutes: 1320, // 22:00
      durationMinutes: 570, // 9h 30m (Overnight)
      basePrice: 620000,
      seatsAvailable: 42,
      departurePlatform: 'Platform 11',
      arrivalPlatform: 'Platform 2',
      isDirect: true,
      amenities: [
        'Full Sleeper Couchettes',
        'Bedding & Pillow Kit',
        'Morning Breakfast Included',
        'Shower Access (Deluxe)',
        'Private Lockable Coupe',
      ],
      onTimePunctuality: 0.98,
      availableSleepers: const [
        SleeperBerthType.couchette6,
        SleeperBerthType.couchette4,
        SleeperBerthType.doubleSleeper,
        SleeperBerthType.singleDeluxe,
      ],
      availableGenderRules: const [
        CompartmentGenderRule.mixed,
        CompartmentGenderRule.femaleOnly,
        CompartmentGenderRule.maleOnly,
        CompartmentGenderRule.privateCoupe,
      ],
      intermediateStops: [
        IntermediateStop(
          stationName: '$origin Main Railway Station',
          stationCode: 'ORI-C',
          arrivalTime: '—',
          departureTime: '22:00',
          platform: '11',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Shahr-e Rey Depot',
          stationCode: 'REY',
          arrivalTime: '22:38',
          departureTime: '22:42',
          platform: '3',
          stopDurationMinutes: 4,
          isMajorHub: false,
        ),
        const IntermediateStop(
          stationName: 'Semnan Terminal',
          stationCode: 'SMN',
          arrivalTime: '01:15',
          departureTime: '01:25',
          platform: '2',
          stopDurationMinutes: 10,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Damghan Junction',
          stationCode: 'DMG',
          arrivalTime: '03:10',
          departureTime: '03:15',
          platform: '1',
          stopDurationMinutes: 5,
          isMajorHub: false,
        ),
        const IntermediateStop(
          stationName: 'Shahroud Station',
          stationCode: 'SHR',
          arrivalTime: '04:40',
          departureTime: '04:55',
          platform: '2',
          stopDurationMinutes: 15,
          isMajorHub: true,
        ),
        IntermediateStop(
          stationName: '$destination Central Station',
          stationCode: 'DST-C',
          arrivalTime: '07:30',
          departureTime: '—',
          platform: '2',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
      ],
      voucherType: RailPassVoucherType.aztec,
    ),
  );

  // 5. Regional Train (Frequent & Economic)
  journeys.add(
    RailJourney(
      id: 'rail-reg-5',
      operator: operators[4],
      trainName: 'Safir Regional Commuter',
      trainNumber: 'RB-140',
      category: TrainCategory.regional,
      origin: origin,
      destination: destination,
      originStation: '$origin Suburban Rail',
      destinationStation: '$destination Local Station',
      departMinutes: 840, // 14:00
      durationMinutes: 410, // 6h 50m
      basePrice: 295000,
      seatsAvailable: 55,
      departurePlatform: 'Platform 3B',
      arrivalPlatform: 'Platform 1',
      isDirect: true,
      amenities: ['Luggage Racks', 'Bicycle Area', 'USB Chargers'],
      onTimePunctuality: 0.93,
      availableSleepers: const [SleeperBerthType.none],
      availableGenderRules: const [CompartmentGenderRule.mixed],
      intermediateStops: [
        IntermediateStop(
          stationName: '$origin Suburban Rail',
          stationCode: 'ORI-SUB',
          arrivalTime: '—',
          departureTime: '14:00',
          platform: '3B',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
        const IntermediateStop(
          stationName: 'Varamin Central',
          stationCode: 'VRM',
          arrivalTime: '14:42',
          departureTime: '14:45',
          platform: '1',
          stopDurationMinutes: 3,
          isMajorHub: false,
        ),
        const IntermediateStop(
          stationName: 'Pishva Station',
          stationCode: 'PSH',
          arrivalTime: '15:10',
          departureTime: '15:13',
          platform: '2',
          stopDurationMinutes: 3,
          isMajorHub: false,
        ),
        const IntermediateStop(
          stationName: 'Garmsar West',
          stationCode: 'GMS-W',
          arrivalTime: '16:05',
          departureTime: '16:10',
          platform: '1',
          stopDurationMinutes: 5,
          isMajorHub: false,
        ),
        IntermediateStop(
          stationName: '$destination Local Station',
          stationCode: 'DST-LOC',
          arrivalTime: '20:50',
          departureTime: '—',
          platform: '1',
          stopDurationMinutes: 0,
          isMajorHub: true,
        ),
      ],
      voucherType: RailPassVoucherType.qrCode,
    ),
  );

  return journeys;
}

// ---------------------------------------------------------------------------
// Pseudorandom generator for deterministic reproducible data
// ---------------------------------------------------------------------------

class _SeedRandom {
  int _state;
  _SeedRandom(this._state);

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }
}
