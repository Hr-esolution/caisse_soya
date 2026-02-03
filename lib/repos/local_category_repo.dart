import 'package:get/get.dart';
import '../models/category_model.dart';
import 'package:isar/isar.dart';

class LocalCategoryRepo extends GetxService {
  late Isar isar;

  Future<LocalCategoryRepo> init(Isar isarInstance) async {
    isar = isarInstance;
    return this;
  }

  // Create a new category
  Future<Category> create(Category category) async {
    await isar.writeTxn(() async {
      category.updatedAt = DateTime.now();
      return await isar.categories.put(category);
    });
    return category;
  }

  // Update an existing category
  Future<Category> update(Category category) async {
    await isar.writeTxn(() async {
      category.updatedAt = DateTime.now();
      return await isar.categories.put(category);
    });
    return category;
  }

  // Soft delete a category
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final category = await isar.categories.get(id);
      if (category != null) {
        category.deletedAt = DateTime.now();
        category.updatedAt = DateTime.now();
        await isar.categories.put(category);
      }
    });
  }

  // Get all categories (excluding soft-deleted ones)
  Future<List<Category>> getAll() async {
    return await isar.categories.filter().deletedAtIsNull().findAll();
  }

  // Get a category by ID
  Future<Category?> getById(int id) async {
    return await isar.categories.get(id);
  }

  // Get all unsynced categories
  Future<List<Category>> getUnsynced() async {
    return await isar.categories.filter().isSyncedEquals(false).findAll();
  }

  // Mark a category as synced
  Future<void> markAsSynced(int id, int? serverId) async {
    await isar.writeTxn(() async {
      final category = await isar.categories.get(id);
      if (category != null) {
        category.isSynced = true;
        category.serverId = serverId;
        category.updatedAt = DateTime.now();
        await isar.categories.put(category);
      }
    });
  }

  // Get all categories including soft-deleted ones
  Future<List<Category>> getAllWithDeleted() async {
    return await isar.categories.where().findAll();
  }

  // Hard delete a category (remove from local database)
  Future<void> hardDelete(int id) async {
    await isar.writeTxn(() async {
      await isar.categories.delete(id);
    });
  }

  // Restore a soft-deleted category
  Future<void> restore(int id) async {
    await isar.writeTxn(() async {
      final category = await isar.categories.get(id);
      if (category != null) {
        category.deletedAt = null;
        category.updatedAt = DateTime.now();
        await isar.categories.put(category);
      }
    });
  }

  // Get categories that were modified after a specific date
  Future<List<Category>> getModifiedAfter(DateTime dateTime) async {
    return await isar.categories.filter()
        .updatedAtGreaterThan(dateTime)
        .findAll();
  }
}