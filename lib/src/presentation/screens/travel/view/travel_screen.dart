import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/travel_controller.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({Key? key}) : super(key: key);

  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TravelController controller = Get.put(TravelController());

  // Form Controllers
  final originController = TextEditingController(text: 'THR');
  final destController = TextEditingController(text: 'SYZ');
  final dateController = TextEditingController(text: '2026-07-20');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 1. Alitrip/Fliggy Vibrant Orange Gradient Top Header
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF8C00), Color(0xFFFFB900)], // Fliggy Signature Yellow/Orange
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '飞猪旅行 Fliggy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'eCardo Global Travel Operating System',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white30,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Central Alitrip Styled Booking Card
            Padding(
              padding: const EdgeInsets.only(top: 130.0, left: 16, right: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab Selector (Hotels, Flights, eSIM)
                        TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFFFF8C00),
                          labelColor: const Color(0xFFFF8C00),
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: const [
                            Tab(icon: Icon(Icons.hotel), text: 'Hotels / 酒店'),
                            Tab(icon: Icon(Icons.flight), text: 'Flights / 机票'),
                            Tab(icon: Icon(Icons.wifi), text: 'eSIM / 流量'),
                          ],
                        ),
                        
                        // Tab Content Area
                        SizedBox(
                          height: 230,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildHotelTab(),
                              _buildFlightTab(context),
                              _buildEsimTab(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Recommended / Flash Sale Packages Section (Alitrip style)
                  const SizedBox(height: 24),
                  _buildFlashSalesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFormRow(Icons.location_on, 'Destination', 'Tehran, Iran / 德黑兰'),
          const Divider(height: 24),
          _buildFormRow(Icons.calendar_today, 'Check-in / Out', '2026-07-20 ➔ 2026-07-25'),
          const SizedBox(height: 20),
          _buildSearchButton('Search Hotels / 🔍 立即搜索', () {
            Get.snackbar('Hotels', 'GDS Hotel availability check triggered.');
          }),
        ],
      ),
    );
  }

  Widget _buildFlightTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFormRow(Icons.flight_takeoff, 'From', originController.text)),
              const Icon(Icons.swap_horiz, color: Color(0xFFFF8C00)),
              Expanded(child: _buildFormRow(Icons.flight_land, 'To', destController.text)),
            ],
          ),
          const Divider(height: 24),
          _buildFormRow(Icons.calendar_today, 'Departure Date', dateController.text),
          const SizedBox(height: 20),
          _buildSearchButton('Search Flights / 🔍 立即搜索', () {
            controller.searchFlights(originController.text, destController.text, dateController.text);
            _showFlightsDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _buildEsimTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildFormRow(Icons.public, 'Select Destination', 'China, Iran, Global Coverage'),
          const SizedBox(height: 35),
          _buildSearchButton('Configure eSIM / 🔍 立即搜索', () {
            controller.loadCountries();
            _showEsimBottomSheet(context);
          }),
        ],
      ),
    );
  }

  Widget _buildFormRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        )
      ],
    );
  }

  Widget _buildSearchButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF8C00), // Fliggy Orange
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 50),
        elevation: 4,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFlashSalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Fliggy Flash Sales / 飞猪爆款特惠',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              'View All',
              style: TextStyle(color: Color(0xFFFF8C00), fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFlashCard('China Local eSIM', '5G High Speed', '¥ 45', 'https://flagcdn.com/w320/cn.png'),
              _buildFlashCard('Tehran Luxury Hotel', '5 Star Espinas', '¥ 1280', 'https://flagcdn.com/w320/ir.png'),
              _buildFlashCard('IKA Airport SIM', 'Physical Handover', '¥ 68', 'https://flagcdn.com/w320/ir.png'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFlashCard(String title, String subtitle, String price, String flagUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(flagUrl, width: 32, height: 20),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const Spacer(),
            Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
          ],
        ),
      ),
    );
  }

  void _showEsimBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Fliggy Global eSIM / 飞猪境外上网', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
                        backgroundColor: const Color(0xFFFFF2E6),
                        avatar: Image.network(c['flag'], width: 24, height: 24),
                        label: Text(c['name'], style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
                        onPressed: () {
                          controller.loadPackages(c['code']);
                          Get.back();
                          _showPackagesDialog(context);
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

  void _showPackagesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Fliggy eSIM Packages / 飞猪境外流量'),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.description),
                    trailing: Text('\$${p.sellingPrice}', style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
                    onTap: () {
                      Get.back();
                      Get.snackbar('Purchase Success', 'SIM order placed successfully. Balance deducted from your Credit Line.');
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showFlightsDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Primary GDS Flight Finder / 飞猪机票'),
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
                return Card(
                  child: ListTile(
                    title: Text('Flight ${f.flightNumber} (${f.airlineName})'),
                    subtitle: Text('${f.departureAirport} ➔ ${f.arrivalAirport}'),
                    trailing: Text('\$${f.finalPrice}', style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold)),
                    onTap: () {
                      Get.back();
                      Get.snackbar('Booking Placed', 'PNR generated. Operations team will ticket in +48h.');
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
