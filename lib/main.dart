import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'screens/rent_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/due_notification_screen.dart';
import 'screens/device_controller_screen.dart';
import 'services/api_service.dart';
import 'models/rent_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIS AC Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF00897B),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF00897B),
          secondary: Color(0xFF26A69A),
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF00897B),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00897B),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: MainNavigationScreen(),
    );
  }
}

// New Main Navigation Screen that handles bottom navigation
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    RentScreen(),
    PaymentHistoryScreen(),
    DueNotificationScreen(),
    DeviceControllerScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF00897B),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Rent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Dues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Devices',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> devices = [];
  RentRecord? rentRecord;
  List<Map<String, dynamic>> pendingPayments = [];
  
  // Sample data for demonstration
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
      
      // Fetch devices
      final deviceList = await ApiService.getDevices();
      
      // Fetch rent data
      final rents = await ApiService.getRentsByTenantId("tenant001");
      RentRecord? record;
      if (rents.isNotEmpty) {
        record = RentRecord.fromJson(rents.first);
      }
      
      setState(() {
        devices = deviceList;
        rentRecord = record;
        isLoading = false;
        
        // Calculate stats
        activeDevices = devices.where((d) => d["status"] == true).length;
        
        // Calculate total outstanding rent
        if (rentRecord != null) {
          totalRentDue = rentRecord!.pendingPayments.fold(0, 
            (sum, payment) => sum + payment.amountPaid);
            
          // Calculate electricity usage (mock data for demo)
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
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 120,
                  backgroundColor: Color(0xFF00897B),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'MIS AC Dashboard',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
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
                      icon: Icon(Icons.refresh),
                      onPressed: _fetchData,
                      tooltip: "Refresh Data",
                    ),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Profile view not implemented"))
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
                        // Status Cards
                        _buildStatusCards(isTabletOrDesktop),
                        
                        SizedBox(height: 24),
                        
                        // Electricity Usage Chart
                        _buildElectricityChart(),
                        
                        SizedBox(height: 24),
                        
                        // Rent Payment Chart
                        _buildRentPaymentChart(),
                        
                        SizedBox(height: 24),
                        
                        // Active Devices Section
                        _buildDeviceSection(),
                        
                        // Removed navigation cards as they're now in the bottom navigation bar
                        SizedBox(height: 40), // Extra padding at the bottom for scrolling
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
          Expanded(child: _buildStatusCard('Active Devices', activeDevices.toString(), Icons.devices, Colors.blue)),
          SizedBox(width: 16),
          Expanded(child: _buildStatusCard('Due Rent', 'NPR ${totalRentDue.toStringAsFixed(0)}', Icons.payments, Colors.orange)),
          SizedBox(width: 16),
          Expanded(child: _buildStatusCard('Energy Usage', '${electricityUsage.toStringAsFixed(1)} kWh', Icons.bolt, Colors.purple)),
        ],
      );
    } else {
      return Column(
        children: [
          _buildStatusCard('Active Devices', activeDevices.toString(), Icons.devices, Colors.blue),
          SizedBox(height: 12),
          _buildStatusCard('Due Rent', 'NPR ${totalRentDue.toStringAsFixed(0)}', Icons.payments, Colors.orange),
          SizedBox(height: 12),
          _buildStatusCard('Energy Usage', '${electricityUsage.toStringAsFixed(1)} kWh', Icons.bolt, Colors.purple),
        ],
      );
    }
  }
  
  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildElectricityChart() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Energy Usage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  'This Week',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 60,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipMargin: 10,
                  getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)} kWh',
                      TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0: return Text('M', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 1: return Text('T', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 2: return Text('W', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 3: return Text('T', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 4: return Text('F', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 5: return Text('S', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        case 6: return Text('S', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                        default: return Text('');
                      }
                    },
                    reservedSize: 20,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: weeklyUsage.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: Color(0xFF7366FF),
                      width: 16,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRentPaymentChart() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rent Payments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  'Past 6 Months',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int valueInt = value.toInt();
                      if (valueInt >= 0 && valueInt < months.length) {
                        return Text(months[valueInt], style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      }
                      return Text('');
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return Text('0', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      if (value == 5000) return Text('5K', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      if (value == 10000) return Text('10K', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      if (value == 15000) return Text('15K', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                      return Text('');
                    },
                    reservedSize: 32,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: 20000,
              lineBarsData: [
                LineChartBarData(
                  spots: rentPayments.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: Color(0xFF00897B),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Color(0xFF00897B).withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.8),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      return LineTooltipItem(
                        'NPR ${flSpot.y.toStringAsFixed(0)}',
                        TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDeviceSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Use navigation to navigate to specific tab index instead
                  final _MainNavigationScreenState? navigationState = 
                      context.findAncestorStateOfType<_MainNavigationScreenState>();
                  if (navigationState != null) {
                    navigationState.setState(() {
                      navigationState._currentIndex = 4; // Index for Device Controller
                    });
                  }
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF00897B)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          devices.isEmpty 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Icon(Icons.devices_other, size: 48, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text('No devices connected', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: devices.length > 3 ? 3 : devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: device["status"] ? Color(0xFF00897B).withOpacity(0.1) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.devices,
                              color: device["status"] ? Color(0xFF00897B) : Colors.grey,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Power: ${device["power"]}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: device["status"],
                            activeColor: Color(0xFF00897B),
                            onChanged: (value) async {
                              setState(() {
                                device["status"] = value;
                                // Recalculate active devices count
                                activeDevices = devices.where((d) => d["status"] == true).length;
                                // Update electricity usage (mock)
                                electricityUsage = devices.fold(0, 
                                  (sum, device) => device["status"] ? sum + 2.5 : sum);
                              });
                              
                              try {
                                await ApiService.updateDevice(device);
                              } catch (e) {
                                print("Error updating device: $e");
                                setState(() {
                                  device["status"] = !value;
                                  // Revert counts
                                  activeDevices = devices.where((d) => d["status"] == true).length;
                                  electricityUsage = devices.fold(0, 
                                    (sum, device) => device["status"] ? sum + 2.5 : sum);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}