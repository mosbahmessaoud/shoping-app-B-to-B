import 'bill_item_model.dart';

class Bill {
  final int id;
  final int clientId;
  final String billNumber;
  final double totalAmount;
  final double totalPaid;
  final double totalRemaining;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool notificationSent;

  Bill({
    required this.id,
    required this.clientId,
    required this.billNumber,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalRemaining,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationSent,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        clientId: json['client_id'],
        billNumber: json['bill_number'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalRemaining: (json['total_remaining'] as num).toDouble(),
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        notificationSent: json['notification_sent'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'bill_number': billNumber,
        'total_amount': totalAmount,
        'total_paid': totalPaid,
        'total_remaining': totalRemaining,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'notification_sent': notificationSent,
      };
}

class BillWithItems extends Bill {
  final List<BillItem> items;

  BillWithItems({
    required super.id,
    required super.clientId,
    required super.billNumber,
    required super.totalAmount,
    required super.totalPaid,
    required super.totalRemaining,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.notificationSent,
    required this.items,
  });

  factory BillWithItems.fromJson(Map<String, dynamic> json) => BillWithItems(
        id: json['id'],
        clientId: json['client_id'],
        billNumber: json['bill_number'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalRemaining: (json['total_remaining'] as num).toDouble(),
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        notificationSent: json['notification_sent'] ?? false,
        items: (json['items'] as List)
            .map((item) => BillItem.fromJson(item))
            .toList(),
      );
}

class BillWithClient extends BillWithItems {
  final String clientName;
  final String clientEmail;
  final String? clientPhone;

  BillWithClient({
    required super.id,
    required super.clientId,
    required super.billNumber,
    required super.totalAmount,
    required super.totalPaid,
    required super.totalRemaining,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.notificationSent,
    required super.items,
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
  });

  factory BillWithClient.fromJson(Map<String, dynamic> json) => BillWithClient(
        id: json['id'],
        clientId: json['client_id'],
        billNumber: json['bill_number'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalRemaining: (json['total_remaining'] as num).toDouble(),
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        notificationSent: json['notification_sent'] ?? false,
        items: (json['items'] as List)
            .map((item) => BillItem.fromJson(item))
            .toList(),
        clientName: json['client_name'],
        clientEmail: json['client_email'],
        clientPhone: json['client_phone'],
      );
}

class BillSummary {
  final int totalBills;
  final double totalRevenue;
  final double totalPaid;
  final double totalPending;
  final int paidBills;
  final int unpaidBills;

  BillSummary({
    required this.totalBills,
    required this.totalRevenue,
    required this.totalPaid,
    required this.totalPending,
    required this.paidBills,
    required this.unpaidBills,
  });

  factory BillSummary.fromJson(Map<String, dynamic> json) => BillSummary(
        totalBills: json['total_bills'],
        totalRevenue: (json['total_revenue'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalPending: (json['total_pending'] as num).toDouble(),
        paidBills: json['paid_bills'],
        unpaidBills: json['unpaid_bills'],
      );
}