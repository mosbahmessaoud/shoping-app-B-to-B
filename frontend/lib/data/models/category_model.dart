class Category {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };
}

class CategoryWithCount extends Category {
  final int productCount;

  CategoryWithCount({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    required this.productCount,
  });

  factory CategoryWithCount.fromJson(Map<String, dynamic> json) =>
      CategoryWithCount(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
        productCount: json['product_count'],
      );
}