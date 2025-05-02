import 'package:flutter/material.dart';

class RentScreen extends StatefulWidget {
  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  // Dummy list of rented items for now
  final List<Map<String, String>> rentedItems = [
    {"item": "Apartment 1B", "price": "NPR 15,000", "dueDate": "2025-05-10", "status": "Unpaid"},
    {"item": "Motorbike", "price": "NPR 5,000", "dueDate": "2025-05-15", "status": "Unpaid"},
    {"item": "Car", "price": "NPR 20,000", "dueDate": "2025-06-01", "status": "Unpaid"},
  ];

  // Function to mark rent as paid
  void markAsPaid(int index) {
    setState(() {
      rentedItems[index]["status"] = "Paid";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rent Show"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: rentedItems.length,
            itemBuilder: (context, index) {
              final item = rentedItems[index];
              return _RentCard(item: item, onMarkPaid: () => markAsPaid(index));
            },
          ),
        ),
      ),
    );
  }
}

class _RentCard extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onMarkPaid;

  const _RentCard({required this.item, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["item"] ?? "Item Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Price: ${item['price']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Due Date: ${item['dueDate']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              "Status: ${item['status']}",
              style: TextStyle(fontSize: 16, color: item['status'] == 'Paid' ? Colors.green : Colors.red),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: item['status'] == 'Paid' ? null : onMarkPaid,
              child: Text(item['status'] == 'Paid' ? "Already Paid" : "Mark as Paid"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
