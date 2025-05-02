import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RentScreen extends StatefulWidget {
  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  String rentAmount = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchRent();
  }

  void fetchRent() async {
    final data = await ApiService.getRent();
    setState(() => rentAmount = data ?? 'Failed to load');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rent Info')),
      body: Center(child: Text('Current Rent: $rentAmount')),
    );
  }
}