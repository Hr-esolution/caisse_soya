import 'package:isar/isar.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../models/order_model.dart';

class IsarConfig {
  static late Isar isar;

  static Future<void> initializeIsar() async {
    isar = await Isar.open([
      CategorySchema,
      ProductSchema,
      UserSchema,
      RestaurantSchema,
      OrderSchema,
      OrderDetailSchema,
    ], inspector: true); // Enable inspector for debugging
  }

  static Isar get db => isar;
}