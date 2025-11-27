class Client {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.address,
    this.city,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        phoneNumber: json['phone_number'],
        address: json['address'],
        city: json['city'],
        isActive: json['is_active'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'city': city,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ClientSummary {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? city;
  final int totalBills;
  final double totalDebt;
  final bool isActive;

  ClientSummary({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.city,
    required this.totalBills,
    required this.totalDebt,
    required this.isActive,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) => ClientSummary(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        phoneNumber: json['phone_number'],
        city: json['city'],
        totalBills: json['total_bills'],
        totalDebt: (json['total_debt'] as num).toDouble(),
        isActive: json['is_active'],
      );
}