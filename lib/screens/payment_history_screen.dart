import 'package:flutter/material.dart';
import '../models/rent_model.dart';
import '../services/api_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String tenantId;

  const PaymentHistoryScreen({Key? key, this.tenantId = "tenant001"}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentHistory> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    try {
      final rents = await ApiService.getRentsByTenantId(widget.tenantId);
      final rentRecords = rents.map((r) => RentRecord.fromJson(r)).toList();

      if (rentRecords.isNotEmpty) {
        setState(() {
          _payments = rentRecords.first.paymentHistory
              .where((payment) => payment.paymentStatus == 'paid') // Filter out unpaid and due payments
              .toList();
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
        _error = "Failed to load payment history: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _payments.isEmpty
                  ? Center(child: Text("No paid payments available"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _payments.length,
                      itemBuilder: (context, index) {
                        final payment = _payments[index];

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text("Rs. ${payment.amountPaid.toStringAsFixed(2)}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Month: ${payment.month}"),
                                Text("Due: ${payment.dueDate}"),
                                if (payment.paymentDate != null && payment.paymentDate!.isNotEmpty)
                                  Text("Paid on: ${payment.paymentDate}"),
                                if (payment.receiptNumber != null)
                                  Text("Receipt: ${payment.receiptNumber}"),
                              ],
                            ),
                            trailing: Text(
                              payment.paymentStatus.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
