import 'package:isar/isar.dart';

part 'restaurant_model.g.dart';

@collection
class Restaurant {
  Id id = Isar.autoIncrement; // auto-incrementing id
  int? serverId; // original server id
  String name;
  String address;
  String phone;
  bool isActive;
  bool isSynced;
  DateTime updatedAt;
  DateTime? deletedAt;

  Restaurant({
    this.id = Isar.autoIncrement,
    this.serverId,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
    required this.isSynced,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      serverId: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['is_active'] ?? false,
      isSynced: json['is_synced'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
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
      'address': address,
      'phone': phone,
      'is_active': isActive,
    };
  }
}