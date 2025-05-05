// lib/models/due_payment.dart
class DuePayment {
  final String amountPaid;
  final String dueDate;
  final String status;
  final String amountDue;

  DuePayment({
    required this.amountPaid,
    required this.dueDate,
    required this.status,
    required this.amountDue,
  });
}
