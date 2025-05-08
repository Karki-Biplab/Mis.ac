import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../screens/rent_screen.dart';
import '../screens/payment_history_screen.dart';
import '../screens/due_notification_screen.dart';
import '../screens/device_controller_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  MainNavigationScreenState createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Public getter and setter for currentIndex
  int get currentIndex => _currentIndex;
  
  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
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
              offset: const Offset(0, -5),
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
          selectedItemColor: const Color(0xFF00897B),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
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