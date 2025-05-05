import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/rent_model.dart'; // Import the model we created
import 'package:intl/intl.dart';

class RentScreen extends StatefulWidget {
  // This could be passed in from a login screen or stored in a user session
  final String tenantId;
  
  // For demo, we're hardcoding a tenant ID, but in a real app this would come from authentication
  const RentScreen({Key? key, this.tenantId = "tenant001"}) : super(key: key);

  @override
  _RentScreenState createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> with SingleTickerProviderStateMixin {
  RentRecord? rentRecord;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchTenantRents();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch rents for the specific tenant
  void fetchTenantRents() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      // Get rent records for this tenant
      final rents = await ApiService.getRentsByTenantId(widget.tenantId);
      
      if (rents.isNotEmpty) {
        setState(() {
          rentRecord = RentRecord.fromJson(rents.first);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No rent records found for this tenant";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load rent data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Rent Details"),
        backgroundColor: Colors.teal,
        elevation: 0,
        bottom: isLoading || errorMessage != null || rentRecord == null ? null : TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Overview"),
            Tab(text: "Payments"),
            Tab(text: "Details"),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading 
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
            : rentRecord == null
              ? Center(child: Text("No rent records found"))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPaymentsTab(),
                    _buildDetailsTab(),
                  ],
                ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final pendingPayments = rentRecord!.pendingPayments;
    final isCurrentMonthPaid = rentRecord!.isCurrentMonthPaid;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTenantInfoCard(),
          SizedBox(height: 20),
          
          // Payment status summary
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Status",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  
                  // Current month status
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentMonthPaid ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          isCurrentMonthPaid ? Icons.check : Icons.access_time,
                          color: isCurrentMonthPaid ? Colors.green.shade700 : Colors.orange.shade700,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Month",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              isCurrentMonthPaid
                                  ? "Payment completed"
                                  : "Payment pending",
                              style: TextStyle(
                                color: isCurrentMonthPaid
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "NPR ${rentRecord!.rentAmount}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Pending payments summary
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: pendingPayments.isEmpty
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          pendingPayments.isEmpty ? Icons.check_circle : Icons.warning,
                          color: pendingPayments.isEmpty
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pending Payments",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              pendingPayments.isEmpty
                                  ? "All payments up to date"
                                  : "${pendingPayments.length} ${pendingPayments.length == 1 ? 'payment' : 'payments'} pending",
                              style: TextStyle(
                                color: pendingPayments.isEmpty
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pendingPayments.isNotEmpty)
                        Text(
                          "NPR ${pendingPayments.fold<double>(0, (sum, item) => sum + item.amountPaid)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Action buttons
          if (!isCurrentMonthPaid || pendingPayments.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // Navigate to payment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Payment feature not implemented yet")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Make Payment",
                style: TextStyle(fontSize: 16),
              ),
            ),
            
          SizedBox(height: 12),
          
          OutlinedButton(
            onPressed: () {
              _tabController.animateTo(1); // Go to payments tab
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.teal),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              "View Payment History",
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rentRecord!.tenantName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Room ${rentRecord!.room}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    rentRecord!.tenantName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow("Monthly Rent", "NPR ${rentRecord!.rentAmount}"),
            _buildInfoRow("Security Deposit", "NPR ${rentRecord!.securityDeposit}"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    final payments = rentRecord!.paymentHistory;
    
    // Sort payment history by month/date (most recent first)
    payments.sort((a, b) {
      final aDate = a.paymentDate != null ? DateTime.parse(a.paymentDate!) : DateTime.now();
      final bDate = b.paymentDate != null ? DateTime.parse(b.paymentDate!) : DateTime.now();
      return bDate.compareTo(aDate);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...payments.map((payment) => _buildPaymentCard(payment)).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lease Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Tenant ID", rentRecord!.tenantId),
                  _buildInfoRow("Room", rentRecord!.room),
                  _buildInfoRow("Monthly Rent", "NPR ${rentRecord!.rentAmount}"),
                  _buildInfoRow("Lease Start", _formatDate(rentRecord!.leaseStart)),
                  _buildInfoRow("Lease End", _formatDate(rentRecord!.leaseEnd)),
                  _buildInfoRow("Security Deposit", "NPR ${rentRecord!.securityDeposit}"),
                  if (rentRecord!.notes != null && rentRecord!.notes!.isNotEmpty)
                    _buildInfoRow("Notes", rentRecord!.notes!),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            "Contact Landlord",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.teal),
                    title: Text("Call Landlord"),
                    subtitle: Text("+977-9812345678"),
                    onTap: () {
                      // Open phone dialer
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Phone call feature not implemented")),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.message, color: Colors.teal),
                    title: Text("Send Message"),
                    subtitle: Text("via SMS or WhatsApp"),
                    onTap: () {
                      // Open messaging app
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Messaging feature not implemented")),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.teal),
                    title: Text("Email Landlord"),
                    subtitle: Text("landlord@example.com"),
                    onTap: () {
                      // Open email app
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email feature not implemented")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentHistory payment) {
    final isPaid = payment.paymentStatus == 'paid';
    final isUnpaid = payment.paymentStatus == 'unpaid';
    final isDue = payment.paymentStatus == 'due';
    
    // Format dates
    String dueDate = "N/A";
    String paidDate = "Not paid yet";
    
    if (payment.dueDate.isNotEmpty) {
      final parsed = DateTime.parse(payment.dueDate);
      dueDate = DateFormat('MMM d, yyyy').format(parsed);
    }
    
    if (payment.paymentDate != null) {
      final parsed = DateTime.parse(payment.paymentDate!);
      paidDate = DateFormat('MMM d, yyyy').format(parsed);
    }

    Color statusColor = isDue ? Colors.orange : (isPaid ? Colors.green : Colors.red);
    IconData statusIcon = isDue ? Icons.access_time : (isPaid ? Icons.check_circle : Icons.cancel);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              payment.month,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                SizedBox(width: 4),
                Text(
                  payment.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          "Due: $dueDate",
          style: TextStyle(fontSize: 14),
        ),
        trailing: Text(
          "NPR ${payment.amountPaid}",
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: isPaid ? Colors.green.shade700 : Colors.black54,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPaid) ...[
                  _buildPaymentInfoRow("Paid on", paidDate),
                  _buildPaymentInfoRow("Receipt Number", payment.receiptNumber ?? "N/A"),
                  _buildPaymentInfoRow("Payment Method", (payment.paymentMethod ?? "N/A").toUpperCase()),
                ],
                if (isDue || isUnpaid) ...[
                  SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // This would navigate to a payment screen in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Payment feature not implemented yet"),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: Text("Make Payment"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}