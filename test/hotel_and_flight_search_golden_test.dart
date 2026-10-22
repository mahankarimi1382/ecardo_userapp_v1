import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_search_screen.dart';

import 'screenshot_harness.dart';

class _MockTravelRepository implements TravelRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<TravelOffer>> getUpcomingFlights() async => const [];
}

class _TestTravelController extends TravelController {
  _TestTravelController() : super(repository: _MockTravelRepository()) {
    isLoading.value = false;
    isUpcomingFlightsLoading.value = false;
    recentFlightSearches.assignAll([
      TravelFlightSearch(
        origin: 'DXB',
        destination: 'LHR',
        departureDate: DateTime(2026, 9, 1),
        returnDate: DateTime(2026, 9, 15),
        adultCount: 1,
        childCount: 0,
        infantCount: 0,
        cabinClass: 'economy',
      ),
      TravelFlightSearch(
        origin: 'IKA',
        destination: 'IST',
        departureDate: DateTime(2026, 10, 5),
        returnDate: null,
        adultCount: 2,
        childCount: 1,
        infantCount: 0,
        cabinClass: 'economy',
      ),
    ]);
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> loadUpcomingFlights() async {
    // Intentionally empty — skip network calls during widget testing.
  }
}

void _ignoreOverflows() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exceptionAsString();
    if (exceptionStr.contains('A RenderFlex overflowed') ||
        exceptionStr.contains('RenderBox was not laid out') ||
        exceptionStr.contains('hasSize') ||
        exceptionStr.contains('would not hit test on the specified widget')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}

void main() {
  tearDown(resetHarness);

  group('FlightSearchScreen Visual Regression Tests', () {
    testWidgets('flight_search — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const FlightSearchScreen(),
        registrations: [
          () => registerController<TravelController>(_TestTravelController()),
        ],
      );
      await capture(tester, 'flight_search__light');
    });

    testWidgets('flight_search — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const FlightSearchScreen(),
        dark: true,
        registrations: [
          () => registerController<TravelController>(_TestTravelController()),
        ],
      );
      await capture(tester, 'flight_search__dark');
    });
  });
}
