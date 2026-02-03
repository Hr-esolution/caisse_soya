import 'package:get/get.dart';
import '../models/restaurant_model.dart';
import 'package:isar/isar.dart';

class LocalRestaurantRepo extends GetxService {
  late Isar isar;

  Future<LocalRestaurantRepo> init(Isar isarInstance) async {
    isar = isarInstance;
    return this;
  }

  // Create a new restaurant
  Future<Restaurant> create(Restaurant restaurant) async {
    await isar.writeTxn(() async {
      restaurant.updatedAt = DateTime.now();
      return await isar.restaurants.put(restaurant);
    });
    return restaurant;
  }

  // Update an existing restaurant
  Future<Restaurant> update(Restaurant restaurant) async {
    await isar.writeTxn(() async {
      restaurant.updatedAt = DateTime.now();
      return await isar.restaurants.put(restaurant);
    });
    return restaurant;
  }

  // Soft delete a restaurant
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final restaurant = await isar.restaurants.get(id);
      if (restaurant != null) {
        restaurant.deletedAt = DateTime.now();
        restaurant.updatedAt = DateTime.now();
        await isar.restaurants.put(restaurant);
      }
    });
  }

  // Get all restaurants (excluding soft-deleted ones)
  Future<List<Restaurant>> getAll() async {
    return await isar.restaurants.filter().deletedAtIsNull().findAll();
  }

  // Get a restaurant by ID
  Future<Restaurant?> getById(int id) async {
    return await isar.restaurants.get(id);
  }

  // Get all unsynced restaurants
  Future<List<Restaurant>> getUnsynced() async {
    return await isar.restaurants.filter().isSyncedEquals(false).findAll();
  }

  // Mark a restaurant as synced
  Future<void> markAsSynced(int id, int? serverId) async {
    await isar.writeTxn(() async {
      final restaurant = await isar.restaurants.get(id);
      if (restaurant != null) {
        restaurant.isSynced = true;
        restaurant.serverId = serverId;
        restaurant.updatedAt = DateTime.now();
        await isar.restaurants.put(restaurant);
      }
    });
  }

  // Get all restaurants including soft-deleted ones
  Future<List<Restaurant>> getAllWithDeleted() async {
    return await isar.restaurants.where().findAll();
  }

  // Hard delete a restaurant (remove from local database)
  Future<void> hardDelete(int id) async {
    await isar.writeTxn(() async {
      await isar.restaurants.delete(id);
    });
  }

  // Restore a soft-deleted restaurant
  Future<void> restore(int id) async {
    await isar.writeTxn(() async {
      final restaurant = await isar.restaurants.get(id);
      if (restaurant != null) {
        restaurant.deletedAt = null;
        restaurant.updatedAt = DateTime.now();
        await isar.restaurants.put(restaurant);
      }
    });
  }

  // Get restaurants that were modified after a specific date
  Future<List<Restaurant>> getModifiedAfter(DateTime dateTime) async {
    return await isar.restaurants.filter()
        .updatedAtGreaterThan(dateTime)
        .findAll();
  }

  // Find active restaurants
  Future<List<Restaurant>> findActive() async {
    return await isar.restaurants.filter()
        .isActiveTrue()
        .deletedAtIsNull()
        .findAll();
  }
}