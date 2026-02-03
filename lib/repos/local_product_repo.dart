import 'package:get/get.dart';
import '../models/product_model.dart';
import 'package:isar/isar.dart';

class LocalProductRepo extends GetxService {
  late Isar isar;

  Future<LocalProductRepo> init(Isar isarInstance) async {
    isar = isarInstance;
    return this;
  }

  // Create a new product
  Future<Product> create(Product product) async {
    await isar.writeTxn(() async {
      product.updatedAt = DateTime.now();
      return await isar.products.put(product);
    });
    return product;
  }

  // Update an existing product
  Future<Product> update(Product product) async {
    await isar.writeTxn(() async {
      product.updatedAt = DateTime.now();
      return await isar.products.put(product);
    });
    return product;
  }

  // Soft delete a product
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final product = await isar.products.get(id);
      if (product != null) {
        product.deletedAt = DateTime.now();
        product.updatedAt = DateTime.now();
        await isar.products.put(product);
      }
    });
  }

  // Get all products (excluding soft-deleted ones)
  Future<List<Product>> getAll() async {
    return await isar.products.filter().deletedAtIsNull().findAll();
  }

  // Get a product by ID
  Future<Product?> getById(int id) async {
    return await isar.products.get(id);
  }

  // Get all unsynced products
  Future<List<Product>> getUnsynced() async {
    return await isar.products.filter().isSyncedEquals(false).findAll();
  }

  // Mark a product as synced
  Future<void> markAsSynced(int id, int? serverId) async {
    await isar.writeTxn(() async {
      final product = await isar.products.get(id);
      if (product != null) {
        product.isSynced = true;
        product.serverId = serverId;
        product.updatedAt = DateTime.now();
        await isar.products.put(product);
      }
    });
  }

  // Get all products including soft-deleted ones
  Future<List<Product>> getAllWithDeleted() async {
    return await isar.products.where().findAll();
  }

  // Hard delete a product (remove from local database)
  Future<void> hardDelete(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  // Restore a soft-deleted product
  Future<void> restore(int id) async {
    await isar.writeTxn(() async {
      final product = await isar.products.get(id);
      if (product != null) {
        product.deletedAt = null;
        product.updatedAt = DateTime.now();
        await isar.products.put(product);
      }
    });
  }

  // Get products that were modified after a specific date
  Future<List<Product>> getModifiedAfter(DateTime dateTime) async {
    return await isar.products.filter()
        .updatedAtGreaterThan(dateTime)
        .findAll();
  }

  // Get products by category ID
  Future<List<Product>> getByCategoryId(int categoryId) async {
    return await isar.products.filter()
        .categoryIdEquals(categoryId)
        .deletedAtIsNull()
        .findAll();
  }

  // Search products by name
  Future<List<Product>> searchByName(String name) async {
    return await isar.products.filter()
        .nameContains(name, caseSensitive: false)
        .deletedAtIsNull()
        .findAll();
  }
}