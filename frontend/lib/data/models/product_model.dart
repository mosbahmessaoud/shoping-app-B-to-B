class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int quantityInStock;
  final int minimumStockLevel;
  final String? imageUrl;
  final int categoryId;
  final int adminId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.quantityInStock,
    required this.minimumStockLevel,
    this.imageUrl,
    required this.categoryId,
    required this.adminId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        quantityInStock: json['quantity_in_stock'],
        minimumStockLevel: json['minimum_stock_level'],
        imageUrl: json['image_url'],
        categoryId: json['category_id'],
        adminId: json['admin_id'],
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'quantity_in_stock': quantityInStock,
        'minimum_stock_level': minimumStockLevel,
        'image_url': imageUrl,
        'category_id': categoryId,
        'admin_id': adminId,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ProductWithCategory extends Product {
  final String categoryName;

  ProductWithCategory({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.quantityInStock,
    required super.minimumStockLevel,
    super.imageUrl,
    required super.categoryId,
    required super.adminId,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required this.categoryName,
  });

  factory ProductWithCategory.fromJson(Map<String, dynamic> json) =>
      ProductWithCategory(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        quantityInStock: json['quantity_in_stock'],
        minimumStockLevel: json['minimum_stock_level'],
        imageUrl: json['image_url'],
        categoryId: json['category_id'],
        adminId: json['admin_id'],
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        categoryName: json['category_name'],
      );
}

class ProductStockStatus {
  final int id;
  final String name;
  final int quantityInStock;
  final int minimumStockLevel;
  final bool isLowStock;
  final double stockPercentage;

  ProductStockStatus({
    required this.id,
    required this.name,
    required this.quantityInStock,
    required this.minimumStockLevel,
    required this.isLowStock,
    required this.stockPercentage,
  });

  factory ProductStockStatus.fromJson(Map<String, dynamic> json) =>
      ProductStockStatus(
        id: json['id'],
        name: json['name'],
        quantityInStock: json['quantity_in_stock'],
        minimumStockLevel: json['minimum_stock_level'],
        isLowStock: json['is_low_stock'],
        stockPercentage: (json['stock_percentage'] as num).toDouble(),
      );
}