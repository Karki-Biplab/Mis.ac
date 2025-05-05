import 'package:flutter/material.dart';
import '../models/due_payment.dart'; // New DuePayment model
import '../models/rent_model.dart'; // RentRecord model with payment history
import '../services/api_service.dart'; // API service to fetch rent data

class DueNotificationScreen extends StatefulWidget {
  final String tenantId;

  const DueNotificationScreen({Key? key, this.tenantId = "tenant001"}) : super(key: key);

  @override
  _DueNotificationScreenState createState() => _DueNotificationScreenState();
}

class _DueNotificationScreenState extends State<DueNotificationScreen> {
  List<DuePayment> _duePayments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDuePayments();
  }

  // Function to fetch due payments
  Future<void> _fetchDuePayments() async {
    try {
      final rents = await ApiService.getRentsByTenantId(widget.tenantId);
      final rentRecords = rents.map((r) => RentRecord.fromJson(r)).toList();

      if (rentRecords.isNotEmpty) {
        setState(() {
          _duePayments = rentRecords.first.paymentHistory.where((payment) {
            // Filter unpaid payments (upcoming or overdue)
            if (payment.paymentStatus != 'paid') {
              DateTime dueDate = DateTime.parse(payment.dueDate);
              DateTime now = DateTime.now();
              String status = payment.paymentStatus == 'unpaid'
                  ? (dueDate.isBefore(now) ? 'Overdue' : 'Upcoming')
                  : 'Paid';

              return status != 'Paid'; // Exclude paid ones
            }
            return false;
          }).map((payment) {
            // Determine the status based on due date and payment status
            String status = payment.paymentStatus != 'paid'
                ? (DateTime.parse(payment.dueDate).isBefore(DateTime.now()) ? 'Overdue' : 'Upcoming')
                : 'Paid';

            return DuePayment(
              amountPaid: payment.amountPaid.toString(),
              dueDate: payment.dueDate,
              status: status,
              amountDue: payment.amountPaid.toString(),
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "No rent record found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load due payments: $e";
        _isLoading = false;
      });
    }
  }

  // Function to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Function to get the icon based on status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Upcoming':
        return Icons.notifications_active;
      case 'Overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Due Payments'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : _error != null
              ? Center(child: Text(_error!)) // Show error message if API call fails
              : _duePayments.isEmpty
                  ? Center(child: Text("No due payments available")) // No due payments
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _duePayments.length,
                      itemBuilder: (context, index) {
                        final payment = _duePayments[index];
                        final statusColor = _getStatusColor(payment.status);
                        final statusIcon = _getStatusIcon(payment.status);

                        // Build the card for each due payment notification
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(statusIcon, color: statusColor),
                            title: Text(
                              payment.amountPaid,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Due Date: ${payment.dueDate}"),
                            trailing: Text(
                              payment.status,
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
