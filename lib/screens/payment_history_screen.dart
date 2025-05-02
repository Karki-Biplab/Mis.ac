import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment History')),
      body: FutureBuilder<List<String>>(
        future: ApiService.getPaymentHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Failed to load history'));
          }
          return ListView(
            children: snapshot.data!
                .map((entry) => ListTile(title: Text(entry)))
                .toList(),
          );
        },
      ),
    );
  }
}