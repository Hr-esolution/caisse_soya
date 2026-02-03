import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement; // auto-incrementing id
  int? serverId; // original server id
  String name;
  String phone;
  String? pinCode;
  bool isActive;
  String? email;
  String role;
  int? restaurantId;
  bool isSynced;
  DateTime updatedAt;
  DateTime? deletedAt;

  User({
    this.id = Isar.autoIncrement,
    this.serverId,
    required this.name,
    required this.phone,
    this.pinCode,
    required this.isActive,
    this.email,
    required this.role,
    this.restaurantId,
    required this.isSynced,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      serverId: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      pinCode: json['pin_code'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      email: json['email'],
      role: json['role'] ?? 'client',
      restaurantId: json['restaurant_id'],
      isSynced: json['is_synced'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'name': name,
      'phone': phone,
      'pin_code': pinCode,
      'is_active': isActive,
      'email': email,
      'role': role,
      'restaurant_id': restaurantId,
      'is_synced': isSynced,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Convert to API format for backend sync
  Map<String, dynamic> toApiFormat() {
    return {
      'id': serverId,
      'name': name,
      'phone': phone,
      'pin_code': pinCode,
      'is_active': isActive,
      'email': email,
      'role': role,
      'restaurant_id': restaurantId,
    };
  }
}