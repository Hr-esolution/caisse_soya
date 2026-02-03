import 'package:isar/isar.dart';
import 'product_model.dart';

part 'category_model.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement; // auto-incrementing id
  int? serverId; // original server id
  String name;
  String? image;
  bool isSynced;
  DateTime updatedAt;
  DateTime? deletedAt;

  Category({
    this.id = Isar.autoIncrement,
    this.serverId,
    required this.name,
    this.image,
    this.isSynced = false,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      serverId: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      isSynced: json['is_synced'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'name': name,
      'image': image,
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
      'image': image,
    };
  }
}