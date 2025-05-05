class RentRecord {
  final String id;
  final String tenantId;
  final String tenantName;
  final String room;
  final double rentAmount;
  final List<PaymentHistory> paymentHistory;
  final String leaseStart;
  final String leaseEnd;
  final double securityDeposit;
  final String? notes;

  RentRecord({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.room,
    required this.rentAmount,
    required this.paymentHistory,
    required this.leaseStart,
    required this.leaseEnd,
    required this.securityDeposit,
    this.notes,
  });

  factory RentRecord.fromJson(Map<String, dynamic> json) {
    List<PaymentHistory> payments = [];
    if (json['payment_history'] != null) {
      payments = List<PaymentHistory>.from(
        (json['payment_history'] as List).map(
          (payment) => PaymentHistory.fromJson(payment),
        ),
      );
    }

    return RentRecord(
      id: json['id'],
      tenantId: json['tenant_id'],
      tenantName: json['tenant_name'],
      room: json['room'],
      rentAmount: (json['rent_amount'] is int) 
          ? (json['rent_amount'] as int).toDouble() 
          : json['rent_amount'],
      paymentHistory: payments,
      leaseStart: json['lease_start'],
      leaseEnd: json['lease_end'],
      securityDeposit: (json['security_deposit'] is int) 
          ? (json['security_deposit'] as int).toDouble() 
          : json['security_deposit'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'room': room,
      'rent_amount': rentAmount,
      'payment_history': paymentHistory.map((payment) => payment.toJson()).toList(),
      'lease_start': leaseStart,
      'lease_end': leaseEnd,
      'security_deposit': securityDeposit,
      'notes': notes,
    };
  }

  // Get upcoming or overdue payments
  List<PaymentHistory> get pendingPayments {
    return paymentHistory.where((payment) => 
      payment.paymentStatus == 'due' || payment.paymentStatus == 'unpaid'
    ).toList();
  }
  
  // Check if current month is paid
  bool get isCurrentMonthPaid {
    final now = DateTime.now();
    final currentMonth = '${_getMonthName(now.month)} ${now.year}';
    
    final currentMonthPayment = paymentHistory.firstWhere(
      (payment) => payment.month == currentMonth,
      orElse: () => PaymentHistory(
        month: currentMonth,
        dueDate: '',
        paymentDate: null,
        amountPaid: 0,
        paymentStatus: 'unknown',
        paymentMethod: null,
        receiptNumber: null,
      ),
    );
    
    return currentMonthPayment.paymentStatus == 'paid';
  }
  
  // Helper method to get month name
  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}

class PaymentHistory {
  final String month;
  final String dueDate;
  final String? paymentDate;
  final double amountPaid;
  final String paymentStatus;  // 'paid', 'unpaid', 'due'
  final String? paymentMethod;
  final String? receiptNumber;

  PaymentHistory({
    required this.month,
    required this.dueDate,
    this.paymentDate,
    required this.amountPaid,
    required this.paymentStatus,
    this.paymentMethod,
    this.receiptNumber,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      month: json['month'],
      dueDate: json['due_date'],
      paymentDate: json['payment_date'],
      amountPaid: (json['amount_paid'] is int) 
          ? (json['amount_paid'] as int).toDouble() 
          : json['amount_paid'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      receiptNumber: json['receipt_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'due_date': dueDate,
      'payment_date': paymentDate,
      'amount_paid': amountPaid,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'receipt_number': receiptNumber,
    };
  }
  
  // Check if payment is overdue
  bool get isOverdue {
    if (paymentStatus == 'paid') return false;
    
    final due = DateTime.parse(dueDate);
    final now = DateTime.now();
    
    return now.isAfter(due);
  }
}