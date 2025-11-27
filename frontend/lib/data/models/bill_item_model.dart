class BillItem {
  final int id;
  final int billId;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final DateTime createdAt;

  BillItem({
    required this.id,
    required this.billId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.createdAt,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        id: json['id'],
        billId: json['bill_id'],
        productId: json['product_id'],
        productName: json['product_name'],
        unitPrice: (json['unit_price'] as num).toDouble(),
        quantity: json['quantity'],
        subtotal: (json['subtotal'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'bill_id': billId,
        'product_id': productId,
        'product_name': productName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'subtotal': subtotal,
        'created_at': createdAt.toIso8601String(),
      };
}