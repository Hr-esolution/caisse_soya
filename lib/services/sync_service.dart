import 'package:get/get.dart';
import '../repos/local_category_repo.dart';
import '../repos/local_product_repo.dart';
import '../repos/local_user_repo.dart';
import '../repos/local_restaurant_repo.dart';
import '../repos/local_order_repo.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../models/order_model.dart';
import '../repos/category_repo.dart';
import '../repos/product_repo.dart';
import '../repos/user_repo.dart';
import '../repos/restaurant_repo.dart';
import '../repos/order_repo.dart';

class SyncService extends GetxService {
  final LocalCategoryRepo localCategoryRepo = Get.find();
  final LocalProductRepo localProductRepo = Get.find();
  final LocalUserRepo localUserRepo = Get.find();
  final LocalRestaurantRepo localRestaurantRepo = Get.find();
  final LocalOrderRepo localOrderRepo = Get.find();

  final CategoryRepo categoryRepo = Get.find();
  final ProductRepo productRepo = Get.find();
  final UserRepo userRepo = Get.find();
  final RestaurantRepo restaurantRepo = Get.find();
  final OrderRepo orderRepo = Get.find();

  // Backend -> Desktop sync
  Future<bool> syncFromBackend() async {
    try {
      // Sync categories
      await _syncCategoriesFromBackend();
      
      // Sync products
      await _syncProductsFromBackend();
      
      // Sync users
      await _syncUsersFromBackend();
      
      // Sync restaurants
      await _syncRestaurantsFromBackend();
      
      return true;
    } catch (e) {
      print("Error syncing from backend: $e");
      return false;
    }
  }

  // Desktop -> Backend sync
  Future<bool> syncToBackend() async {
    try {
      // Sync categories
      await _syncCategoriesToBackend();
      
      // Sync products
      await _syncProductsToBackend();
      
      // Sync users
      await _syncUsersToBackend();
      
      // Sync orders
      await _syncOrdersToBackend();
      
      return true;
    } catch (e) {
      print("Error syncing to backend: $e");
      return false;
    }
  }

  // Full two-way sync
  Future<bool> syncBothWays() async {
    try {
      // First sync from backend to desktop to get latest changes
      await syncFromBackend();
      
      // Then sync from desktop to backend to send local changes
      await syncToBackend();
      
      return true;
    } catch (e) {
      print("Error during full sync: $e");
      return false;
    }
  }

  // Categories sync methods
  Future<void> _syncCategoriesFromBackend() async {
    try {
      final response = await categoryRepo.getCategoriesList();
      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> categoriesData = response.body['data'] ?? response.body;
        
        for (var categoryData in categoriesData) {
          final backendCategory = Category.fromJson(categoryData);
          
          // Check if category exists locally
          final localCategory = await localCategoryRepo.getById(backendCategory.serverId ?? 0);
          
          if (localCategory == null) {
            // New category, create it
            final newCategory = Category(
              serverId: backendCategory.serverId,
              name: backendCategory.name,
              image: backendCategory.image,
              isSynced: true,
              updatedAt: backendCategory.updatedAt,
              deletedAt: backendCategory.deletedAt,
            );
            await localCategoryRepo.create(newCategory);
          } else {
            // Existing category, check for conflicts based on updated_at
            if (backendCategory.updatedAt.isAfter(localCategory.updatedAt)) {
              // Backend version is newer, update local
              localCategory.name = backendCategory.name;
              localCategory.image = backendCategory.image;
              localCategory.isSynced = true;
              localCategory.updatedAt = backendCategory.updatedAt;
              localCategory.deletedAt = backendCategory.deletedAt;
              await localCategoryRepo.update(localCategory);
            }
          }
        }
      }
    } catch (e) {
      print("Error syncing categories from backend: $e");
    }
  }

  Future<void> _syncCategoriesToBackend() async {
    try {
      final unsyncedCategories = await localCategoryRepo.getUnsynced();
      
      for (var category in unsyncedCategories) {
        try {
          // Determine if this is a create or update operation
          if (category.serverId == null) {
            // This is a new category, create it on backend
            final response = await categoryRepo.createCategory(category.toApiFormat());
            if (response.statusCode == 201 || response.statusCode == 200) {
              final createdCategory = Category.fromJson(response.body['data'] ?? response.body);
              await localCategoryRepo.markAsSynced(category.id, createdCategory.serverId);
            }
          } else {
            // This is an update operation
            final response = await categoryRepo.updateCategory(category.serverId!, category.toApiFormat());
            if (response.statusCode == 200) {
              await localCategoryRepo.markAsSynced(category.id, category.serverId);
            }
          }
        } catch (e) {
          print("Error syncing category ${category.id} to backend: $e");
        }
      }
    } catch (e) {
      print("Error syncing categories to backend: $e");
    }
  }

  // Products sync methods
  Future<void> _syncProductsFromBackend() async {
    try {
      final response = await productRepo.getProductsList();
      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> productsData = response.body['data'] ?? response.body;
        
        for (var productData in productsData) {
          final backendProduct = Product.fromJson(productData);
          
          // Check if product exists locally
          final localProduct = await localProductRepo.getById(backendProduct.serverId ?? 0);
          
          if (localProduct == null) {
            // New product, create it
            final newProduct = Product(
              serverId: backendProduct.serverId,
              name: backendProduct.name,
              price: backendProduct.price,
              offer: backendProduct.offer,
              description: backendProduct.description,
              categoryId: backendProduct.categoryId,
              image: backendProduct.image,
              isSynced: true,
              updatedAt: backendProduct.updatedAt,
              deletedAt: backendProduct.deletedAt,
            );
            await localProductRepo.create(newProduct);
          } else {
            // Existing product, check for conflicts based on updated_at
            if (backendProduct.updatedAt.isAfter(localProduct.updatedAt)) {
              // Backend version is newer, update local
              localProduct.name = backendProduct.name;
              localProduct.price = backendProduct.price;
              localProduct.offer = backendProduct.offer;
              localProduct.description = backendProduct.description;
              localProduct.categoryId = backendProduct.categoryId;
              localProduct.image = backendProduct.image;
              localProduct.isSynced = true;
              localProduct.updatedAt = backendProduct.updatedAt;
              localProduct.deletedAt = backendProduct.deletedAt;
              await localProductRepo.update(localProduct);
            }
          }
        }
      }
    } catch (e) {
      print("Error syncing products from backend: $e");
    }
  }

  Future<void> _syncProductsToBackend() async {
    try {
      final unsyncedProducts = await localProductRepo.getUnsynced();
      
      for (var product in unsyncedProducts) {
        try {
          // Determine if this is a create or update operation
          if (product.serverId == null) {
            // This is a new product, create it on backend
            final response = await productRepo.createProduct(product.toApiFormat());
            if (response.statusCode == 201 || response.statusCode == 200) {
              final createdProduct = Product.fromJson(response.body['data'] ?? response.body);
              await localProductRepo.markAsSynced(product.id, createdProduct.serverId);
            }
          } else {
            // This is an update operation
            final response = await productRepo.updateProduct(product.serverId!, product.toApiFormat());
            if (response.statusCode == 200) {
              await localProductRepo.markAsSynced(product.id, product.serverId);
            }
          }
        } catch (e) {
          print("Error syncing product ${product.id} to backend: $e");
        }
      }
    } catch (e) {
      print("Error syncing products to backend: $e");
    }
  }

  // Users sync methods
  Future<void> _syncUsersFromBackend() async {
    try {
      final response = await userRepo.getUserInfo();
      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> usersData = response.body['data'] ?? response.body;
        
        for (var userData in usersData) {
          final backendUser = User.fromJson(userData);
          
          // Check if user exists locally
          final localUser = await localUserRepo.getById(backendUser.serverId ?? 0);
          
          if (localUser == null) {
            // New user, create it
            final newUser = User(
              serverId: backendUser.serverId,
              name: backendUser.name,
              phone: backendUser.phone,
              pinCode: backendUser.pinCode,
              isActive: backendUser.isActive,
              email: backendUser.email,
              role: backendUser.role,
              restaurantId: backendUser.restaurantId,
              isSynced: true,
              updatedAt: backendUser.updatedAt,
              deletedAt: backendUser.deletedAt,
            );
            await localUserRepo.create(newUser);
          } else {
            // Existing user, check for conflicts based on updated_at
            if (backendUser.updatedAt.isAfter(localUser.updatedAt)) {
              // Backend version is newer, update local
              localUser.name = backendUser.name;
              localUser.phone = backendUser.phone;
              localUser.pinCode = backendUser.pinCode;
              localUser.isActive = backendUser.isActive;
              localUser.email = backendUser.email;
              localUser.role = backendUser.role;
              localUser.restaurantId = backendUser.restaurantId;
              localUser.isSynced = true;
              localUser.updatedAt = backendUser.updatedAt;
              localUser.deletedAt = backendUser.deletedAt;
              await localUserRepo.update(localUser);
            }
          }
        }
      }
    } catch (e) {
      print("Error syncing users from backend: $e");
    }
  }

  Future<void> _syncUsersToBackend() async {
    try {
      final unsyncedUsers = await localUserRepo.getUnsynced();
      
      for (var user in unsyncedUsers) {
        try {
          // Determine if this is a create or update operation
          if (user.serverId == null) {
            // This is a new user, create it on backend
            final response = await userRepo.createUser(user.toApiFormat());
            if (response.statusCode == 201 || response.statusCode == 200) {
              final createdUser = User.fromJson(response.body['data'] ?? response.body);
              await localUserRepo.markAsSynced(user.id, createdUser.serverId);
            }
          } else {
            // This is an update operation
            final response = await userRepo.updateUser(user.serverId!, user.toApiFormat());
            if (response.statusCode == 200) {
              await localUserRepo.markAsSynced(user.id, user.serverId);
            }
          }
        } catch (e) {
          print("Error syncing user ${user.id} to backend: $e");
        }
      }
    } catch (e) {
      print("Error syncing users to backend: $e");
    }
  }

  // Restaurants sync methods
  Future<void> _syncRestaurantsFromBackend() async {
    try {
      final response = await restaurantRepo.getAllRestaurants();
      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> restaurantsData = response.body['data'] ?? response.body;
        
        for (var restaurantData in restaurantsData) {
          final backendRestaurant = Restaurant.fromJson(restaurantData);
          
          // Check if restaurant exists locally
          final localRestaurant = await localRestaurantRepo.getById(backendRestaurant.serverId ?? 0);
          
          if (localRestaurant == null) {
            // New restaurant, create it
            final newRestaurant = Restaurant(
              serverId: backendRestaurant.serverId,
              name: backendRestaurant.name,
              address: backendRestaurant.address,
              phone: backendRestaurant.phone,
              isActive: backendRestaurant.isActive,
              isSynced: true,
              updatedAt: backendRestaurant.updatedAt,
              deletedAt: backendRestaurant.deletedAt,
            );
            await localRestaurantRepo.create(newRestaurant);
          } else {
            // Existing restaurant, check for conflicts based on updated_at
            if (backendRestaurant.updatedAt.isAfter(localRestaurant.updatedAt)) {
              // Backend version is newer, update local
              localRestaurant.name = backendRestaurant.name;
              localRestaurant.address = backendRestaurant.address;
              localRestaurant.phone = backendRestaurant.phone;
              localRestaurant.isActive = backendRestaurant.isActive;
              localRestaurant.isSynced = true;
              localRestaurant.updatedAt = backendRestaurant.updatedAt;
              localRestaurant.deletedAt = backendRestaurant.deletedAt;
              await localRestaurantRepo.update(localRestaurant);
            }
          }
        }
      }
    } catch (e) {
      print("Error syncing restaurants from backend: $e");
    }
  }

  Future<void> _syncRestaurantsToBackend() async {
    try {
      final unsyncedRestaurants = await localRestaurantRepo.getUnsynced();
      
      for (var restaurant in unsyncedRestaurants) {
        try {
          // Determine if this is a create or update operation
          if (restaurant.serverId == null) {
            // This is a new restaurant, create it on backend
            final response = await restaurantRepo.createRestaurant(restaurant.toApiFormat());
            if (response.statusCode == 201 || response.statusCode == 200) {
              final createdRestaurant = Restaurant.fromJson(response.body['data'] ?? response.body);
              await localRestaurantRepo.markAsSynced(restaurant.id, createdRestaurant.serverId);
            }
          } else {
            // This is an update operation
            final response = await restaurantRepo.updateRestaurant(restaurant.serverId!, restaurant.toApiFormat());
            if (response.statusCode == 200) {
              await localRestaurantRepo.markAsSynced(restaurant.id, restaurant.serverId);
            }
          }
        } catch (e) {
          print("Error syncing restaurant ${restaurant.id} to backend: $e");
        }
      }
    } catch (e) {
      print("Error syncing restaurants to backend: $e");
    }
  }

  // Orders sync methods
  Future<void> _syncOrdersToBackend() async {
    try {
      final unsyncedOrders = await localOrderRepo.getUnsynced();
      
      for (var order in unsyncedOrders) {
        try {
          // Orders are always created on the desktop and sent to backend
          final response = await orderRepo.placeOrder(order.toApiFormat());
          if (response.statusCode == 201 || response.statusCode == 200) {
            // Get the server-generated ID and update local record
            final createdOrder = Order.fromJson(response.body['data'] ?? response.body);
            await localOrderRepo.markAsSynced(order.id, createdOrder.serverId);
          }
        } catch (e) {
          print("Error syncing order ${order.id} to backend: $e");
        }
      }
    } catch (e) {
      print("Error syncing orders to backend: $e");
    }
  }

  // Helper method to check if online
  Future<bool> isOnline() async {
    // This would typically check for network connectivity
    // For now, we'll return true to indicate online status
    // In a real implementation, you would use a package like connectivity_plus
    return true;
  }
}