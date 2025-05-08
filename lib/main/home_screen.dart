import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<Map<String, dynamic>> pendingPayments = [];
  
  double totalRentDue = 0;
  int activeDevices = 0;
  double electricityUsage = 0;
  List<double> weeklyUsage = [42, 38, 47, 35, 53, 46, 41];
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  List<double> rentPayments = [15000, 14000, 15000, 15000, 15000, 15000];
  
  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  
  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final deviceList = await ApiService.getDevices();
      final rents = await ApiService.getRentsByTenantId("tenant001");
      RentRecord? record;
      if (rents.isNotEmpty) {
        record = RentRecord.fromJson(rents.first);
      }
      
      setState(() {
        devices = deviceList;
        rentRecord = record;
        isLoading = false;
        activeDevices = devices.where((d) => d["status"] == true).length;
        
        if (rentRecord != null) {
          totalRentDue = rentRecord!.pendingPayments.fold(0, 
            (sum, payment) => sum + payment.amountPaid);
          electricityUsage = devices.fold(0, 
            (sum, device) => device["status"] ? sum + 2.5 : sum);
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
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
          : CustomScrollView(
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
                          colors: [Color(0xFF00897B), Color(0xFF00695C)],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _fetchData,
                      tooltip: "Refresh Data",
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile view not implemented"))
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
                        RentPaymentChart(months: months, rentPayments: rentPayments),
                        const SizedBox(height: 24),
                        DeviceSection(
                          devices: devices, 
                          activeDevices: activeDevices, 
                          onDeviceToggle: _onDeviceToggle, 
                          onViewAll: _onViewAll
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
  
  Widget _buildStatusCards(bool isTabletOrDesktop) {
    if (isTabletOrDesktop) {
      return Row(
        children: [
          Expanded(child: StatusCard('Active Devices', activeDevices.toString(), Icons.devices, Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: StatusCard('Due Rent', 'NPR ${totalRentDue.toStringAsFixed(0)}', Icons.payments, Colors.orange)),
          const SizedBox(width: 16),
          Expanded(child: StatusCard('Energy Usage', '${electricityUsage.toStringAsFixed(1)} kWh', Icons.bolt, Colors.purple)),
        ],
      );
    } else {
      return Column(
        children: [
          StatusCard('Active Devices', activeDevices.toString(), Icons.devices, Colors.blue),
          const SizedBox(height: 12),
          StatusCard('Due Rent', 'NPR ${totalRentDue.toStringAsFixed(0)}', Icons.payments, Colors.orange),
          const SizedBox(height: 12),
          StatusCard('Energy Usage', '${electricityUsage.toStringAsFixed(1)} kWh', Icons.bolt, Colors.purple),
        ],
      );
    }
  }

  void _onDeviceToggle(Map<String, dynamic> device, bool value) async {
    setState(() {
      device["status"] = value;
      activeDevices = devices.where((d) => d["status"] == true).length;
      electricityUsage = devices.fold(0, 
        (sum, device) => device["status"] ? sum + 2.5 : sum);
    });
    
    try {
      await ApiService.updateDevice(device);
    } catch (e) {
      print("Error updating device: $e");
      setState(() {
        device["status"] = !value;
        activeDevices = devices.where((d) => d["status"] == true).length;
        electricityUsage = devices.fold(0, 
          (sum, device) => device["status"] ? sum + 2.5 : sum);
      });
    }
  }

  void _onViewAll(BuildContext context) {
    // Find the ancestor MainNavigationScreenState and update its currentIndex
    final MainNavigationScreenState? navigationState = 
      context.findAncestorStateOfType<MainNavigationScreenState>();
    if (navigationState != null) {
      // Use the public setter method to update the index
      navigationState.setCurrentIndex(4);
    }
  }
}