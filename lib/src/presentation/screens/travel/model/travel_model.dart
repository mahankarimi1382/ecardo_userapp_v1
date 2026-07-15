class SimProduct {
  final int id;
  final String title;
  final String description;
  final String countryCode;
  final bool isEsim;
  final String type;
  final double providerCost;
  final double sellingPrice;
  final List<SimPackage> packages;

  SimProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.countryCode,
    required this.isEsim,
    required this.type,
    required this.providerCost,
    required this.sellingPrice,
    required this.packages,
  });

  factory SimProduct.fromJson(Map<String, dynamic> json) {
    var pkgsList = json['packages'] as List? ?? [];
    List<SimPackage> pkgs = pkgsList.map((i) => SimPackage.fromJson(i)).toList();

    return SimProduct(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      countryCode: json['country_code'] ?? '',
      isEsim: json['is_esim'] == 1 || json['is_esim'] == true,
      type: json['type'] ?? 'data',
      providerCost: double.tryParse(json['provider_cost']?.toString() ?? '0') ?? 0.0,
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
      packages: pkgs,
    );
  }
}

class SimPackage {
  final int id;
  final String name;
  final int? dataGb;
  final int? voiceMinutes;
  final int? smsCount;
  final int durationDays;
  final double price;

  SimPackage({
    required this.id,
    required this.name,
    this.dataGb,
    this.voiceMinutes,
    this.smsCount,
    required this.durationDays,
    required this.price,
  });

  factory SimPackage.fromJson(Map<String, dynamic> json) {
    return SimPackage(
      id: json['id'],
      name: json['name'] ?? '',
      dataGb: json['data_gb'],
      voiceMinutes: json['voice_minutes'],
      smsCount: json['sms_count'],
      durationDays: json['duration_days'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class FlightOption {
  final String flightId;
  final String flightNumber;
  final String airlineCode;
  final String airlineName;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final double baseCost;
  final double finalPrice;

  FlightOption({
    required this.flightId,
    required this.flightNumber,
    required this.airlineCode,
    required this.airlineName,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.baseCost,
    required this.finalPrice,
  });

  factory FlightOption.fromJson(Map<String, dynamic> json) {
    return FlightOption(
      flightId: json['flight_id'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      airlineCode: json['airline_code'] ?? '',
      airlineName: json['airline_name'] ?? '',
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      departureTime: DateTime.parse(json['departure_time'] ?? DateTime.now().toString()),
      baseCost: double.tryParse(json['base_cost']?.toString() ?? '0') ?? 0.0,
      finalPrice: double.tryParse(json['final_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
