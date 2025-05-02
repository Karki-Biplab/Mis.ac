import 'package:flutter/material.dart';
// import '../services/api_service.dart';

class DueNotificationScreen extends StatefulWidget {
  @override
  _DueNotificationScreenState createState() => _DueNotificationScreenState();
}

class _DueNotificationScreenState extends State<DueNotificationScreen> {
  // Dummy due notification data
  final List<Map<String, String>> dueNotifications = [
    {
      "date": "2025-05-10",
      "amount": "Rs. 1500",
      "status": "Upcoming"
    },
    {
      "date": "2025-04-10",
      "amount": "Rs. 1500",
      "status": "Overdue"
    },
    {
      "date": "2025-03-10",
      "amount": "Rs. 1500",
      "status": "Overdue"
    },
  ];

  // Future<List<String>> _fetchDueNotifications() async {
  //   return await ApiService.getDueNotifications();
  // }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      case 'Paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Upcoming':
        return Icons.notifications_active;
      case 'Overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Due Notifications'), backgroundColor: Colors.deepOrange),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dueNotifications.length,
        itemBuilder: (context, index) {
          final due = dueNotifications[index];
          final statusColor = _getStatusColor(due["status"]!);
          final statusIcon = _getStatusIcon(due["status"]!);

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(statusIcon, color: statusColor),
              title: Text(due["amount"]!, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Due Date: ${due["date"]}"),
              trailing: Text(
                due["status"]!,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
