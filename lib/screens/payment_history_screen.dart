import 'package:flutter/material.dart';
// import '../services/api_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  // Dummy payment history data
  final List<Map<String, String>> paymentHistory = [
    {
      "date": "2025-05-01",
      "amount": "Rs. 1500",
      "status": "Paid"
    },
    {
      "date": "2025-04-01",
      "amount": "Rs. 1500",
      "status": "Paid"
    },
    {
      "date": "2025-03-01",
      "amount": "Rs. 1500",
      "status": "Overdue"
    },
  ];

  // Future<List<String>> _fetchHistory() async {
  //   return await ApiService.getPaymentHistory();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment History'), backgroundColor: Colors.teal),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: paymentHistory.length,
        itemBuilder: (context, index) {
          final payment = paymentHistory[index];
          final isPaid = payment["status"] == "Paid";

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                isPaid ? Icons.check_circle : Icons.error,
                color: isPaid ? Colors.green : Colors.red,
              ),
              title: Text(payment["amount"]!),
              subtitle: Text("Date: ${payment["date"]}"),
              trailing: Text(
                payment["status"]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
