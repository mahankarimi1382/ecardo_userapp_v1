import 'package:flutter/material.dart';

enum TaxiRideType {
  airportTransfer,
  cityRide,
  intercity,
}

class TaxiVehicleClass {
  final String id;
  final String title;
  final String titleFa;
  final String titleEn;
  final String exampleModels;
  final int maxPassengers;
  final int maxLuggage;
  final int basePrice;
  final IconData icon;
  final List<String> features;

  const TaxiVehicleClass({
    required this.id,
    required this.title,
    required this.titleFa,
    required this.titleEn,
    required this.exampleModels,
    required this.maxPassengers,
    required this.maxLuggage,
    required this.basePrice,
    required this.icon,
    this.features = const [],
  });
}

class TaxiBookingInfo {
  final String id;
  final String reference;
  final TaxiRideType rideType;
  final String origin;
  final String destination;
  final DateTime pickupDate;
  final String pickupTime;
  final String flightNumber;
  final String passengerName;
  final String passengerPhone;
  final int passengerCount;
  final int luggageCount;
  final TaxiVehicleClass vehicle;
  final int totalFare;
  final bool meetAndGreet;
  final String notes;
  final DateTime createdAt;
  final String status;

  const TaxiBookingInfo({
    required this.id,
    required this.reference,
    required this.rideType,
    required this.origin,
    required this.destination,
    required this.pickupDate,
    required this.pickupTime,
    required this.flightNumber,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerCount,
    required this.luggageCount,
    required this.vehicle,
    required this.totalFare,
    required this.meetAndGreet,
    required this.notes,
    required this.createdAt,
    this.status = 'CONFIRMED',
  });
}
