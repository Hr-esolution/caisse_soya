import 'package:get/get.dart';
import '../models/order_model.dart';
import 'package:isar/isar.dart';

class LocalOrderRepo extends GetxService {
  late Isar isar;

  Future<LocalOrderRepo> init(Isar isarInstance) async {
    isar = isarInstance;
    return this;
  }

  // Create a new order
  Future<Order> create(Order order) async {
    await isar.writeTxn(() async {
      order.updatedAt = DateTime.now();
      return await isar.orders.put(order);
    });
    return order;
  }

  // Update an existing order
  Future<Order> update(Order order) async {
    await isar.writeTxn(() async {
      order.updatedAt = DateTime.now();
      return await isar.orders.put(order);
    });
    return order;
  }

  // Soft delete an order
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final order = await isar.orders.get(id);
      if (order != null) {
        order.deletedAt = DateTime.now();
        order.updatedAt = DateTime.now();
        await isar.orders.put(order);
      }
    });
  }

  // Get all orders (excluding soft-deleted ones)
  Future<List<Order>> getAll() async {
    return await isar.orders.filter().deletedAtIsNull().findAll();
  }

  // Get an order by ID
  Future<Order?> getById(int id) async {
    return await isar.orders.get(id);
  }

  // Get all unsynced orders
  Future<List<Order>> getUnsynced() async {
    return await isar.orders.filter().isSyncedEquals(false).findAll();
  }

  // Mark an order as synced
  Future<void> markAsSynced(int id, int? serverId) async {
    await isar.writeTxn(() async {
      final order = await isar.orders.get(id);
      if (order != null) {
        order.isSynced = true;
        order.serverId = serverId;
        order.updatedAt = DateTime.now();
        await isar.orders.put(order);
      }
    });
  }

  // Get all orders including soft-deleted ones
  Future<List<Order>> getAllWithDeleted() async {
    return await isar.orders.where().findAll();
  }

  // Hard delete an order (remove from local database)
  Future<void> hardDelete(int id) async {
    await isar.writeTxn(() async {
      await isar.orders.delete(id);
    });
  }

  // Restore a soft-deleted order
  Future<void> restore(int id) async {
    await isar.writeTxn(() async {
      final order = await isar.orders.get(id);
      if (order != null) {
        order.deletedAt = null;
        order.updatedAt = DateTime.now();
        await isar.orders.put(order);
      }
    });
  }

  // Get orders that were modified after a specific date
  Future<List<Order>> getModifiedAfter(DateTime dateTime) async {
    return await isar.orders.filter()
        .updatedAtGreaterThan(dateTime)
        .findAll();
  }

  // Get orders by user ID
  Future<List<Order>> getByUserId(int userId) async {
    return await isar.orders.filter()
        .userIdEquals(userId)
        .deletedAtIsNull()
        .findAll();
  }

  // Get orders by status
  Future<List<Order>> getByStatus(String status) async {
    return await isar.orders.filter()
        .statusEquals(status)
        .deletedAtIsNull()
        .findAll();
  }

  // Get pending orders
  Future<List<Order>> getPendingOrders() async {
    return await isar.orders.filter()
        .statusEquals('pending')
        .deletedAtIsNull()
        .findAll();
  }

  // Get completed orders
  Future<List<Order>> getCompletedOrders() async {
    return await isar.orders.filter()
        .statusEquals('completed')
        .deletedAtIsNull()
        .findAll();
  }

  // Update order status
  Future<void> updateStatus(int id, String status) async {
    await isar.writeTxn(() async {
      final order = await isar.orders.get(id);
      if (order != null) {
        order.status = status;
        order.updatedAt = DateTime.now();
        await isar.orders.put(order);
      }
    });
  }
}