class Payment {
  final int id;
  final int billId;
  final int adminId;
  final double amountPaid;
  final String paymentMethod;
  final String? notes;
  final DateTime paymentDate;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.billId,
    required this.adminId,
    required this.amountPaid,
    required this.paymentMethod,
    this.notes,
    required this.paymentDate,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        billId: json['bill_id'],
        adminId: json['admin_id'],
        amountPaid: (json['amount_paid'] as num).toDouble(),
        paymentMethod: json['payment_method'],
        notes: json['notes'],
        paymentDate: DateTime.parse(json['payment_date']),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bill_id': billId,
        'admin_id': adminId,
        'amount_paid': amountPaid,
        'payment_method': paymentMethod,
        'notes': notes,
        'payment_date': paymentDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

class PaymentHistory {
  final int billId;
  final String billNumber;
  final double totalAmount;
  final double totalPaid;
  final double totalRemaining;
  final List<Payment> payments;

  PaymentHistory({
    required this.billId,
    required this.billNumber,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalRemaining,
    required this.payments,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
        billId: json['bill_id'],
        billNumber: json['bill_number'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalRemaining: (json['total_remaining'] as num).toDouble(),
        payments: (json['payments'] as List)
            .map((payment) => Payment.fromJson(payment))
            .toList(),
      );
}