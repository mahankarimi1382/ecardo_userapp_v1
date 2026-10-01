import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'taxi_models.dart';

class TaxiController extends GetxController {
  final Rx<TaxiRideType> selectedRideType = TaxiRideType.airportTransfer.obs;
  final Rx<DateTime> pickupDate = DateTime.now().add(const Duration(days: 1)).obs;
  final RxString pickupTime = '10:00'.obs;
  final RxInt passengerCount = 1.obs;
  final RxInt luggageCount = 1.obs;
  final RxBool meetAndGreet = true.obs;

  final originController = TextEditingController(text: 'فرودگاه امام خمینی (IKA)');
  final destinationController = TextEditingController(text: 'تهران، میدان ونک');
  final flightNumberController = TextEditingController(text: 'W5-115');
  final passengerNameController = TextEditingController();
  final passengerPhoneController = TextEditingController();
  final notesController = TextEditingController();

  final RxList<TaxiVehicleClass> availableVehicles = <TaxiVehicleClass>[].obs;
  final Rxn<TaxiVehicleClass> selectedVehicle = Rxn<TaxiVehicleClass>();
  final Rxn<TaxiBookingInfo> activeBooking = Rxn<TaxiBookingInfo>();

  final RxBool isLoadingVehicles = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isServiceUnavailable = false.obs;
  final RxnString errorMessage = RxnString();

  static const List<TaxiVehicleClass> defaultVehicles = [
    TaxiVehicleClass(
      id: 'economy',
      title: 'Economy Sedan',
      titleFa: 'سواری اقتصادی',
      titleEn: 'Economy Sedan',
      exampleModels: 'پژو پارس / سمند سورن / رنو تندر',
      maxPassengers: 3,
      maxLuggage: 2,
      basePrice: 650000,
      icon: Icons.directions_car_rounded,
      features: ['کولر و تهویه فعال', 'امکان پیگیری آنلاین', 'بیمه سرنشین'],
    ),
    TaxiVehicleClass(
      id: 'comfort',
      title: 'Comfort Sedan',
      titleFa: 'سواری کامفورت',
      titleEn: 'Comfort Sedan',
      exampleModels: 'تویوتا کرولا / کمری / هیوندای النترا',
      maxPassengers: 4,
      maxLuggage: 3,
      basePrice: 1100000,
      icon: Icons.airport_shuttle_rounded,
      features: ['صندلی راحت', 'راننده تشریفات', 'آب معدنی رایگان', 'وای‌فای'],
    ),
    TaxiVehicleClass(
      id: 'vip',
      title: 'VIP Executive',
      titleFa: 'تشریفات VIP',
      titleEn: 'VIP Executive',
      exampleModels: 'مرسدس بنز E-Class / ب‌ام‌و سری ۵',
      maxPassengers: 3,
      maxLuggage: 3,
      basePrice: 2400000,
      icon: Icons.stars_rounded,
      features: ['ناوگان تشریفاتی لوکس', 'پذیرایی ویژه', 'تابلو استقبال اختصاصی', 'راننده مسلط به زبان'],
    ),
    TaxiVehicleClass(
      id: 'van',
      title: 'Family Minivan',
      titleFa: 'ون خانوادگی (۷ نفره)',
      titleEn: 'Family Minivan',
      exampleModels: 'تویوتا هایس / هیوندای H1',
      maxPassengers: 7,
      maxLuggage: 6,
      basePrice: 1850000,
      icon: Icons.directions_bus_rounded,
      features: ['فضای جادار چمدان‌ها', 'مناسب سفرهای گروهی', 'صندلی کودک در صورت درخواست'],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    availableVehicles.assignAll(defaultVehicles);
    selectedVehicle.value = defaultVehicles[1]; // Comfort by default
  }

  @override
  void onClose() {
    originController.dispose();
    destinationController.dispose();
    flightNumberController.dispose();
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> fetchVehicleEstimates() async {
    isLoadingVehicles.value = true;
    isServiceUnavailable.value = false;
    errorMessage.value = null;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      availableVehicles.assignAll(defaultVehicles);
    } catch (e) {
      isServiceUnavailable.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  int calculateTotalFare(TaxiVehicleClass vehicle) {
    var fare = vehicle.basePrice;
    if (meetAndGreet.value) {
      fare += 150000;
    }
    if (selectedRideType.value == TaxiRideType.intercity) {
      fare = (fare * 1.6).toInt();
    }
    return fare;
  }

  Future<TaxiBookingInfo?> createBooking() async {
    final vehicle = selectedVehicle.value ?? defaultVehicles.first;
    isSubmitting.value = true;
    try {
      final ref = TravelServiceRequest.generateReference();
      final total = calculateTotalFare(vehicle);
      final booking = TaxiBookingInfo(
        id: 'taxi-${DateTime.now().microsecondsSinceEpoch}',
        reference: ref,
        rideType: selectedRideType.value,
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        pickupDate: pickupDate.value,
        pickupTime: pickupTime.value,
        flightNumber: flightNumberController.text.trim(),
        passengerName: passengerNameController.text.trim().isNotEmpty
            ? passengerNameController.text.trim()
            : 'مسافر محترم',
        passengerPhone: passengerPhoneController.text.trim(),
        passengerCount: passengerCount.value,
        luggageCount: luggageCount.value,
        vehicle: vehicle,
        totalFare: total,
        meetAndGreet: meetAndGreet.value,
        notes: notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to local travel request store for auditing
      final request = TravelServiceRequest(
        id: booking.id,
        serviceKey: 'taxi',
        title: '${booking.origin} ← ${booking.destination}',
        subtitle: '${vehicle.titleFa} · ${booking.pickupTime}',
        amountLabel: '$total IRR',
        reference: ref,
        createdAt: DateTime.now(),
        details: {
          'Origin': booking.origin,
          'Destination': booking.destination,
          'Pickup Time': '${booking.pickupDate.toIso8601String().split('T').first} ${booking.pickupTime}',
          'Vehicle Class': vehicle.titleFa,
          'Passenger': booking.passengerName,
          'Phone': booking.passengerPhone,
          'Flight Number': booking.flightNumber,
          'Meet & Greet': booking.meetAndGreet ? 'بله' : 'خیر',
        },
      );
      await TravelServiceRequestStore.add(request);

      activeBooking.value = booking;
      return booking;
    } finally {
      isSubmitting.value = false;
    }
  }
}
