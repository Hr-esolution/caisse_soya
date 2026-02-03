import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repos/local_user_repo.dart';
import '../services/sync_service.dart';

class DesktopUserController extends GetxController {
  final LocalUserRepo localUserRepo = Get.find();
  final SyncService syncService = Get.find();

  var users = <User>[].obs;
  var currentUser = Rxn<User>();
  var isLoading = false.obs;
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // Load all users from local database
  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      users.assignAll(await localUserRepo.getAll());
    } catch (e) {
      print("Error loading users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Set current user
  void setCurrentUser(User? user) {
    currentUser.value = user;
  }

  // Authenticate user with PIN
  Future<bool> authenticateWithPin(String pin) async {
    try {
      final user = await localUserRepo.findByPinCode(pin);
      if (user != null && user.isActive) {
        setCurrentUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print("Error authenticating user with PIN: $e");
      return false;
    }
  }

  // Create a new user
  Future<User?> createUser(User user) async {
    try {
      final createdUser = await localUserRepo.create(user);
      users.add(createdUser);
      return createdUser;
    } catch (e) {
      print("Error creating user: $e");
      return null;
    }
  }

  // Update an existing user
  Future<User?> updateUser(User user) async {
    try {
      final updatedUser = await localUserRepo.update(user);
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }
      return updatedUser;
    } catch (e) {
      print("Error updating user: $e");
      return null;
    }
  }

  // Delete a user (soft delete)
  Future<void> deleteUser(int id) async {
    try {
      await localUserRepo.delete(id);
      users.removeWhere((u) => u.id == id);
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  // Import users from backend
  Future<void> importUsersFromBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncFromBackend();
      await loadUsers();
    } catch (e) {
      print("Error importing users from backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Manually sync to backend
  Future<void> syncToBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncToBackend();
      await loadUsers();
    } catch (e) {
      print("Error syncing users to backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Get user by ID
  User? getUserById(int id) {
    return users.firstWhereOrNull((user) => user.id == id);
  }

  // Find user by phone
  User? findUserByPhone(String phone) {
    return users.firstWhereOrNull((user) => user.phone == phone);
  }

  // Get all users with sync status
  List<Map<String, dynamic>> getUsersWithSyncStatus() {
    return users.map((user) => {
      'user': user,
      'syncStatus': user.isSynced ? 'Synced' : 'Pending',
      'syncIcon': user.isSynced ? '🟢' : '🟡',
    }).toList();
  }

  // Lock the session (clear current user)
  void lockSession() {
    setCurrentUser(null);
  }

  // Check if session is locked
  bool get isSessionLocked {
    return currentUser.value == null;
  }
}