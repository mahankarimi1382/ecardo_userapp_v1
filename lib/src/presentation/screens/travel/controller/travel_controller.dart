import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/travel_model.dart';

class TravelController extends GetxController {
  var isLoading = false.obs;
  var countries = <Map<String, dynamic>>[].obs;
  var products = <SimProduct>[].obs;
  var flights = <FlightOption>[].obs;

  final String apiBaseUrl = 'https://trip.ecardo.ir/api/v1';

  // Fetch supported countries
  Future<void> loadCountries() async {
    try {
      isLoading(true);
      final response = await GetConnect().get('$apiBaseUrl/sim/countries');
      if (response.status.isOk && response.body['status'] == 'success') {
        countries.value = List<Map<String, dynamic>>.from(response.body['data']);
      }
    } catch (e) {
      debugPrint("Load countries error: $e");
    } finally {
      isLoading(false);
    }
  }

  // Fetch packages for a country
  Future<void> loadPackages(String countryCode) async {
    try {
      isLoading(true);
      final response = await GetConnect().get('$apiBaseUrl/sim/products', query: {'country_code': countryCode});
      if (response.status.isOk && response.body['status'] == 'success') {
        var list = response.body['data'] as List;
        products.value = list.map((i) => SimProduct.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint("Load packages error: $e");
    } finally {
      isLoading(false);
    }
  }

  // Search flights
  Future<void> searchFlights(String origin, String destination, String date) async {
    try {
      isLoading(true);
      final response = await GetConnect().post('$apiBaseUrl/flight/search', {
        'origin': origin,
        'destination': destination,
        'departure_date': date,
      });
      if (response.status.isOk && response.body['status'] == 'success') {
        var list = response.body['data'] as List? ?? [];
        flights.value = list.map((i) => FlightOption.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint("Search flights error: $e");
    } finally {
      isLoading(false);
    }
  }
}
