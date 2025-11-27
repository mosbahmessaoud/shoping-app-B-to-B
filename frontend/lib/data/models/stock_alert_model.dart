class StockAlert {
  final int id;
  final int productId;
  final String alertType;
  final String message;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  StockAlert({
    required this.id,
    required this.productId,
    required this.alertType,
    required this.message,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) => StockAlert(
        id: json['id'],
        productId: json['product_id'],
        alertType: json['alert_type'],
        message: json['message'],
        isResolved: json['is_resolved'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'alert_type': alertType,
        'message': message,
        'is_resolved': isResolved,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}

class StockAlertWithProduct extends StockAlert {
  final String productName;
  final int quantityInStock;
  final int minimumStockLevel;
  final String categoryName;

  StockAlertWithProduct({
    required super.id,
    required super.productId,
    required super.alertType,
    required super.message,
    required super.isResolved,
    required super.createdAt,
    super.resolvedAt,
    required this.productName,
    required this.quantityInStock,
    required this.minimumStockLevel,
    required this.categoryName,
  });

  factory StockAlertWithProduct.fromJson(Map<String, dynamic> json) =>
      StockAlertWithProduct(
        id: json['id'],
        productId: json['product_id'],
        alertType: json['alert_type'],
        message: json['message'],
        isResolved: json['is_resolved'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'])
            : null,
        productName: json['product_name'],
        quantityInStock: json['quantity_in_stock'],
        minimumStockLevel: json['minimum_stock_level'],
        categoryName: json['category_name'],
      );
}

class StockAlertSummary {
  final int totalAlerts;
  final int unresolvedAlerts;
  final int resolvedAlerts;
  final int criticalProducts;

  StockAlertSummary({
    required this.totalAlerts,
    required this.unresolvedAlerts,
    required this.resolvedAlerts,
    required this.criticalProducts,
  });

  factory StockAlertSummary.fromJson(Map<String, dynamic> json) =>
      StockAlertSummary(
        totalAlerts: json['total_alerts'],
        unresolvedAlerts: json['unresolved_alerts'],
        resolvedAlerts: json['resolved_alerts'],
        criticalProducts: json['critical_products'],
      );
}