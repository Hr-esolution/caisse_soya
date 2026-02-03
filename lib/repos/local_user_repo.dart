import 'package:get/get.dart';
import '../models/user_model.dart';
import 'package:isar/isar.dart';

class LocalUserRepo extends GetxService {
  late Isar isar;

  Future<LocalUserRepo> init(Isar isarInstance) async {
    isar = isarInstance;
    return this;
  }

  // Create a new user
  Future<User> create(User user) async {
    await isar.writeTxn(() async {
      user.updatedAt = DateTime.now();
      return await isar.users.put(user);
    });
    return user;
  }

  // Update an existing user
  Future<User> update(User user) async {
    await isar.writeTxn(() async {
      user.updatedAt = DateTime.now();
      return await isar.users.put(user);
    });
    return user;
  }

  // Soft delete a user
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final user = await isar.users.get(id);
      if (user != null) {
        user.deletedAt = DateTime.now();
        user.updatedAt = DateTime.now();
        await isar.users.put(user);
      }
    });
  }

  // Get all users (excluding soft-deleted ones)
  Future<List<User>> getAll() async {
    return await isar.users.filter().deletedAtIsNull().findAll();
  }

  // Get a user by ID
  Future<User?> getById(int id) async {
    return await isar.users.get(id);
  }

  // Get all unsynced users
  Future<List<User>> getUnsynced() async {
    return await isar.users.filter().isSyncedEquals(false).findAll();
  }

  // Mark a user as synced
  Future<void> markAsSynced(int id, int? serverId) async {
    await isar.writeTxn(() async {
      final user = await isar.users.get(id);
      if (user != null) {
        user.isSynced = true;
        user.serverId = serverId;
        user.updatedAt = DateTime.now();
        await isar.users.put(user);
      }
    });
  }

  // Get all users including soft-deleted ones
  Future<List<User>> getAllWithDeleted() async {
    return await isar.users.where().findAll();
  }

  // Hard delete a user (remove from local database)
  Future<void> hardDelete(int id) async {
    await isar.writeTxn(() async {
      await isar.users.delete(id);
    });
  }

  // Restore a soft-deleted user
  Future<void> restore(int id) async {
    await isar.writeTxn(() async {
      final user = await isar.users.get(id);
      if (user != null) {
        user.deletedAt = null;
        user.updatedAt = DateTime.now();
        await isar.users.put(user);
      }
    });
  }

  // Get users that were modified after a specific date
  Future<List<User>> getModifiedAfter(DateTime dateTime) async {
    return await isar.users.filter()
        .updatedAtGreaterThan(dateTime)
        .findAll();
  }

  // Find user by phone number
  Future<User?> findByPhone(String phone) async {
    return await isar.users.filter()
        .phoneEquals(phone)
        .findFirst();
  }

  // Find user by PIN code for local authentication
  Future<User?> findByPinCode(String pinCode) async {
    return await isar.users.filter()
        .pinCodeEquals(pinCode)
        .findFirst();
  }
}