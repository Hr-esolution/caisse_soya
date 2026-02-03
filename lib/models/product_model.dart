import 'package:isar/isar.dart';
import 'category_model.dart';

part 'product_model.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement; // auto-incrementing id
  int? serverId; // original server id
  String name;
  num price;
  String? offer;
  String description;
  int? categoryId;
  String? image;
  bool isSynced;
  DateTime updatedAt;
  DateTime? deletedAt;
  Category? category;

  Product({
    this.id = Isar.autoIncrement,
    this.serverId,
    required this.name,
    required this.price,
    this.offer,
    required this.description,
    this.categoryId,
    this.image,
    required this.isSynced,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      serverId: json['id'],
      name: json['name'] ?? '',
      price: json['price'] is String
          ? num.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0),
      offer: json['offer']?.toString(),
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'],
      image: json['image']?.toString(),
      isSynced: json['is_synced'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'name': name,
      'price': price,
      'offer': offer,
      'description': description,
      'category_id': categoryId,
      'image': image,
      'is_synced': isSynced,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'category': category?.toJson(),
    };
  }

  // Convert to API format for backend sync
  Map<String, dynamic> toApiFormat() {
    return {
      'id': serverId,
      'name': name,
      'price': price,
      'offer': offer,
      'description': description,
      'category_id': categoryId,
      'image': image,
    };
  }
}