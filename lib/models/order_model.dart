import 'package:isar/isar.dart';
import 'product_model.dart';

part 'order_model.g.dart';

@collection
class OrderDetail {
  Id id = Isar.autoIncrement;
  int? productId;
  int quantity;
  num price;
  num total;
  Product? product;

  OrderDetail({
    this.id = Isar.autoIncrement,
    this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    this.product,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      productId: json['product_id'] ?? json['productId'],
      quantity: json['quantity'] ?? 0,
      price: json['price'] is String
          ? num.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0),
      total: json['total'] is String
          ? num.tryParse(json['total']) ?? 0
          : (json['total'] ?? 0),
      product: json['product'] != null && json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'product': product?.toJson(),
    };
  }
}

@collection
class Order {
  Id id = Isar.autoIncrement; // auto-incrementing id
  int? serverId; // original server id
  int userId;
  int restaurantId;
  String customerName;
  String customerPhone;
  String fulfillmentType; // 'delivery', 'pickup', 'on_site'
  String channel;
  double totalPrice;
  String status;
  String? deliveryAddress;
  String? tableNumber;
  String? note;
  List<OrderDetail> orderDetails;
  bool isSynced;
  DateTime updatedAt;
  DateTime? deletedAt;

  Order({
    this.id = Isar.autoIncrement,
    this.serverId,
    required this.userId,
    required this.restaurantId,
    required this.customerName,
    required this.customerPhone,
    required this.fulfillmentType,
    this.channel = 'api',
    required this.totalPrice,
    this.status = 'pending',
    this.deliveryAddress,
    this.tableNumber,
    this.note,
    required this.orderDetails,
    required this.isSynced,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      serverId: json['id'],
      userId: json['user_id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      fulfillmentType: json['fulfillment_type'] ?? 'pickup',
      channel: json['channel'] ?? 'api',
      totalPrice: _parseDouble(json['total_price']),
      status: json['status'] ?? 'pending',
      deliveryAddress: json['delivery_address'],
      tableNumber: json['table_number'],
      note: json['note'],
      orderDetails: (json['details'] as List?)
              ?.map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isSynced: json['is_synced'] ?? false,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// 🔹 Conversion Objet → JSON pour envoi API
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'fulfillment_type': fulfillmentType,
      'channel': channel,
      'total_price': totalPrice,
      'status': status,
      'delivery_address': deliveryAddress,
      'table_number': tableNumber,
      'note': note,
      'details': orderDetails.map((e) => e.toJson()).toList(),
      'is_synced': isSynced,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Convert to API format for backend sync
  Map<String, dynamic> toApiFormat() {
    return {
      'restaurant_id': restaurantId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'fulfillment_type': fulfillmentType,
      'delivery_address': deliveryAddress,
      'note': note,
      'items': orderDetails.map((e) => {
        'product_id': e.productId,
        'quantity': e.quantity,
        'price': e.price,
      }).toList(),
    };
  }
}