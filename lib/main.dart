import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'screens/rent_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/due_notification_screen.dart';
import 'screens/device_controller_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIS AC App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<_DashboardCard> _cards = [
    _DashboardCard(
      title: 'Rent Info',
      icon: LucideIcons.home,
      color: Colors.teal,
      navigateTo: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RentScreen()),
      ),
    ),
    _DashboardCard(
      title: 'Payment History',
      icon: LucideIcons.fileText,
      color: Colors.indigo,
      navigateTo: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentHistoryScreen()),
      ),
    ),
    _DashboardCard(
      title: 'Due Notification',
      icon: LucideIcons.bell,
      color: Colors.deepOrange,
      navigateTo: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DueNotificationScreen()),
      ),
    ),
    _DashboardCard(
      title: 'Device Controller',
      icon: LucideIcons.zap,
      color: Colors.purple,
      navigateTo: (context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DeviceControllerScreen()),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // For Web and Mobile responsiveness
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('MIS AC Dashboard'),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: width > 600 // If screen width is large, use a Grid layout for Web
              ? GridView.count(
                  crossAxisCount: 4, // 4 cards in a row for large screens (Web)
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: _cards,
                )
              : ListView(
                  children: _cards, // Stack the cards vertically for Mobile
                ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) navigateTo;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.navigateTo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => navigateTo(context),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
