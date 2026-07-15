import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/travel_controller.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TravelController controller = Get.put(TravelController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('eCardo Travel Operating System'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover banner
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flight_takeoff, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Explore the World with eCardo',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Hotels • Flights • eSIM & Connectivity',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Our Services',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Menu Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildServiceCard(context, 'Hotels', Icons.hotel, Colors.green, () {
                    Get.snackbar('Hotels', 'Hotel booking is active under Hotel Engine.');
                  }),
                  _buildServiceCard(context, 'eSIM & SIM', Icons.wifi, Colors.blue, () {
                    controller.loadCountries();
                    _showEsimBottomSheet(context, controller);
                  }),
                  _buildServiceCard(context, 'Flights', Icons.flight, Colors.orange, () {
                    _showFlightBottomSheet(context, controller);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showEsimBottomSheet(BuildContext context, TravelController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Your Destination Country', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.countries.length,
                  itemBuilder: (context, index) {
                    var c = controller.countries[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ActionChip(
                        avatar: Image.network(c['flag'], width: 24, height: 24),
                        label: Text(c['name']),
                        onPressed: () {
                          controller.loadPackages(c['code']);
                          Get.back();
                          _showPackagesDialog(context, controller);
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPackagesDialog(BuildContext context, TravelController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Available Packages'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SizedBox(
            width: double.maxFinite,
            height: 250,
            child: ListView.builder(
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                var p = controller.products[index];
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.description),
                  trailing: Text('\$${p.sellingPrice}'),
                  onTap: () {
                    Get.back();
                    Get.snackbar('Purchase Success', 'SIM order placed successfully in background.');
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showFlightBottomSheet(BuildContext context, TravelController controller) {
    final originController = TextEditingController(text: 'THR');
    final destController = TextEditingController(text: 'SYZ');
    final dateController = TextEditingController(text: '2026-07-20');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Search Live GDS Flights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: originController, decoration: const InputDecoration(labelText: 'Origin Airport')),
            TextField(controller: destController, decoration: const InputDecoration(labelText: 'Destination Airport')),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), minimumSize: const Size(double.infinity, 45)),
              onPressed: () {
                controller.searchFlights(originController.text, destController.text, dateController.text);
                Get.back();
                _showFlightsDialog(context, controller);
              },
              child: const Text('Search Flights', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlightsDialog(BuildContext context, TravelController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Live Flight Options (Primary GDS)'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.flights.isEmpty) {
            return const Text('No active flight options returned in sandbox mode.');
          }
          return SizedBox(
            width: double.maxFinite,
            height: 250,
            child: ListView.builder(
              itemCount: controller.flights.length,
              itemBuilder: (context, index) {
                var f = controller.flights[index];
                return ListTile(
                  title: Text('Flight ${f.flightNumber} (${f.airlineName})'),
                  subtitle: Text('${f.departureAirport} ➔ ${f.arrivalAirport}'),
                  trailing: Text('\$${f.finalPrice}'),
                  onTap: () {
                    Get.back();
                    Get.snackbar('Booking Placed', 'PNR generated. Operations team will ticket in +48h.');
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
