import 'package:get/get.dart';
import '../models/product_model.dart';
import '../repos/local_product_repo.dart';
import '../services/sync_service.dart';

class DesktopProductController extends GetxController {
  final LocalProductRepo localProductRepo = Get.find();
  final SyncService syncService = Get.find();

  var products = <Product>[].obs;
  var isLoading = false.obs;
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Load all products from local database
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.assignAll(await localProductRepo.getAll());
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new product
  Future<Product?> createProduct(Product product) async {
    try {
      final createdProduct = await localProductRepo.create(product);
      products.add(createdProduct);
      return createdProduct;
    } catch (e) {
      print("Error creating product: $e");
      return null;
    }
  }

  // Update an existing product
  Future<Product?> updateProduct(Product product) async {
    try {
      final updatedProduct = await localProductRepo.update(product);
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = updatedProduct;
      }
      return updatedProduct;
    } catch (e) {
      print("Error updating product: $e");
      return null;
    }
  }

  // Delete a product (soft delete)
  Future<void> deleteProduct(int id) async {
    try {
      await localProductRepo.delete(id);
      products.removeWhere((p) => p.id == id);
    } catch (e) {
      print("Error deleting product: $e");
    }
  }

  // Import products from backend
  Future<void> importProductsFromBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncFromBackend();
      await loadProducts();
    } catch (e) {
      print("Error importing products from backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Manually sync to backend
  Future<void> syncToBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncToBackend();
      await loadProducts();
    } catch (e) {
      print("Error syncing products to backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Get product by ID
  Product? getProductById(int id) {
    return products.firstWhereOrNull((product) => product.id == id);
  }

  // Get products by category ID
  List<Product> getProductsByCategoryId(int categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  // Search products by name
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return products.toList();
    return products.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get all products with sync status
  List<Map<String, dynamic>> getProductsWithSyncStatus() {
    return products.map((product) => {
      'product': product,
      'syncStatus': product.isSynced ? 'Synced' : 'Pending',
      'syncIcon': product.isSynced ? '🟢' : '🟡',
    }).toList();
  }
}