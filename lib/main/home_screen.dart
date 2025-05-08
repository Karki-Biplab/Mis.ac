import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/rent_model.dart';
import 'status_card.dart';
import 'electricity_chart.dart';
import 'rent_payment_chart.dart';
import 'device_section.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> devices = [];
  RentRecord? rentRecord;
  List<double> weeklyUsage = [42, 38, 47, 35, 53, 46, 41];
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  List<double> rentPayments = [15000, 14000, 15000, 15000, 15000, 15000];

  int activeDevices = 0;
  double totalRentDue = 0.0;
  double totalPowerKW = 0.0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => isLoading = true);

      final deviceList = await ApiService.getDevices();
      final rents = await ApiService.getRentsByTenantId("tenant001");
      RentRecord? record;
      if (rents.isNotEmpty) {
        record = RentRecord.fromJson(rents.first);
      }

      setState(() {
        devices = deviceList;
        rentRecord = record;
        activeDevices = devices.where((d) => d["status"] == true).length;
        _calculateTotalPowerKW();

        if (rentRecord != null) {
          totalRentDue = rentRecord!.pendingPayments.fold(
            0,
            (sum, payment) => sum + payment.amountPaid,
          );
        }

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void _calculateTotalPowerKW() {
  totalPowerKW = devices.where((d) => d["status"] == true).fold(0.0, (sum, d) {
    final rawPower = d["power"];

    if (rawPower == null) return sum;

    // Parse power value: "2000W" → 2000
    final powerStr = rawPower.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    final powerWatts = double.tryParse(powerStr) ?? 0.0;

    return sum + (powerWatts / 1000.0);
  });
}


  void _onDeviceToggle(Map<String, dynamic> device, bool value) async {
    setState(() {
      device["status"] = value;
      activeDevices = devices.where((d) => d["status"] == true).length;
      _calculateTotalPowerKW();
    });

    try {
      await ApiService.updateDevice(device);
    } catch (e) {
      print("Error updating device: $e");
      setState(() {
        device["status"] = !value;
        activeDevices = devices.where((d) => d["status"] == true).length;
        _calculateTotalPowerKW();
      });
    }
  }

  void _onViewAll(BuildContext context) {
    final MainNavigationScreenState? navigationState =
        context.findAncestorStateOfType<MainNavigationScreenState>();
    if (navigationState != null) {
      navigationState.setCurrentIndex(4);
    }
  }

  Widget _buildStatusCards(bool isTabletOrDesktop) {
    final statusCards = [
      StatusCard('Active Devices', activeDevices.toString(),
          Icons.devices, Colors.blue),
      StatusCard('Due Rent', 'NPR ${totalRentDue.toStringAsFixed(0)}',
          Icons.payments, Colors.orange),
      StatusCard('Power Usage', '${totalPowerKW.toStringAsFixed(1)} kW',
          Icons.bolt, Colors.purple),
    ];

    if (isTabletOrDesktop) {
      return Row(
        children: statusCards
            .map((card) => Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: card,
            )))
            .toList(),
      );
    } else {
      return Column(
        children: statusCards
            .map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _fetchData,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 120,
                      backgroundColor: const Color(0xFF00897B),
                      flexibleSpace: FlexibleSpaceBar(
                        title: const Text(
                          'MIS AC Dashboard',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF00897B),
                                Color(0xFF00695C)
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            final MainNavigationScreenState? navState =
                                context.findAncestorStateOfType<
                                    MainNavigationScreenState>();
                            if (navState != null) {
                              navState.setCurrentIndex(3);
                            }
                          },
                          tooltip: "View Notifications",
                        ),
                        IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Profile view not implemented")),
                            );
                          },
                          tooltip: "View Profile",
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusCards(isTabletOrDesktop),
                            const SizedBox(height: 24),
                            ElectricityChart(weeklyUsage: weeklyUsage),
                            const SizedBox(height: 24),
                            RentPaymentChart(
                              months: months,
                              rentPayments: rentPayments,
                            ),
                            const SizedBox(height: 24),
                            DeviceSection(
                              devices: devices,
                              activeDevices: activeDevices,
                              onDeviceToggle: _onDeviceToggle,
                              onViewAll: _onViewAll,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
