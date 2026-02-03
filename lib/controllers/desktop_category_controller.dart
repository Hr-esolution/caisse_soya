import 'package:get/get.dart';
import '../models/category_model.dart';
import '../repos/local_category_repo.dart';
import '../services/sync_service.dart';

class DesktopCategoryController extends GetxController {
  final LocalCategoryRepo localCategoryRepo = Get.find();
  final SyncService syncService = Get.find();

  var categories = <Category>[].obs;
  var isLoading = false.obs;
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // Load all categories from local database
  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.assignAll(await localCategoryRepo.getAll());
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new category
  Future<Category?> createCategory(Category category) async {
    try {
      final createdCategory = await localCategoryRepo.create(category);
      categories.add(createdCategory);
      return createdCategory;
    } catch (e) {
      print("Error creating category: $e");
      return null;
    }
  }

  // Update an existing category
  Future<Category?> updateCategory(Category category) async {
    try {
      final updatedCategory = await localCategoryRepo.update(category);
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        categories[index] = updatedCategory;
      }
      return updatedCategory;
    } catch (e) {
      print("Error updating category: $e");
      return null;
    }
  }

  // Delete a category (soft delete)
  Future<void> deleteCategory(int id) async {
    try {
      await localCategoryRepo.delete(id);
      categories.removeWhere((c) => c.id == id);
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  // Import categories from backend
  Future<void> importCategoriesFromBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncFromBackend();
      await loadCategories();
    } catch (e) {
      print("Error importing categories from backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Manually sync to backend
  Future<void> syncToBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncToBackend();
      await loadCategories();
    } catch (e) {
      print("Error syncing categories to backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Get category by ID
  Category? getCategoryById(int id) {
    return categories.firstWhereOrNull((category) => category.id == id);
  }

  // Get all categories with sync status
  List<Map<String, dynamic>> getCategoriesWithSyncStatus() {
    return categories.map((category) => {
      'category': category,
      'syncStatus': category.isSynced ? 'Synced' : 'Pending',
      'syncIcon': category.isSynced ? '🟢' : '🟡',
    }).toList();
  }
}