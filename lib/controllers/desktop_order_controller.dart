import 'package:get/get.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../repos/local_order_repo.dart';
import '../services/sync_service.dart';

class DesktopOrderController extends GetxController {
  final LocalOrderRepo localOrderRepo = Get.find();
  final SyncService syncService = Get.find();

  var orders = <Order>[].obs;
  var cartItems = <OrderDetail>[].obs;
  var currentTotal = 0.0.obs;
  var isLoading = false.obs;
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Load all orders from local database
  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      orders.assignAll(await localOrderRepo.getAll());
    } catch (e) {
      print("Error loading orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add item to cart
  void addToCart(Product product, int quantity) {
    // Check if product already exists in cart
    final existingItemIndex = cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingItemIndex != -1) {
      // Update quantity if product already exists
      final existingItem = cartItems[existingItemIndex];
      cartItems[existingItemIndex] = OrderDetail(
        id: existingItem.id,
        productId: existingItem.productId,
        quantity: existingItem.quantity + quantity,
        price: existingItem.price,
        total: (existingItem.quantity + quantity) * existingItem.price,
        product: existingItem.product,
      );
    } else {
      // Add new item to cart
      final orderDetail = OrderDetail(
        productId: product.id,
        quantity: quantity,
        price: product.price,
        total: quantity * product.price,
        product: product,
      );
      cartItems.add(orderDetail);
    }
    
    calculateTotal();
  }

  // Remove item from cart
  void removeFromCart(int productId) {
    cartItems.removeWhere((item) => item.productId == productId);
    calculateTotal();
  }

  // Update item quantity in cart
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }
    
    final itemIndex = cartItems.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      final item = cartItems[itemIndex];
      cartItems[itemIndex] = OrderDetail(
        id: item.id,
        productId: item.productId,
        quantity: newQuantity,
        price: item.price,
        total: newQuantity * item.price,
        product: item.product,
      );
      calculateTotal();
    }
  }

  // Calculate total amount
  void calculateTotal() {
    currentTotal.value = cartItems.fold(0, (sum, item) => sum + item.total);
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
    currentTotal.value = 0.0;
  }

  // Create a new order
  Future<Order?> createOrder({
    required int userId,
    required int restaurantId,
    required String customerName,
    required String customerPhone,
    String fulfillmentType = 'on_site',
    String? deliveryAddress,
    String? tableNumber,
    String? note,
  }) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Cannot create order with empty cart');
      }

      final order = Order(
        userId: userId,
        restaurantId: restaurantId,
        customerName: customerName,
        customerPhone: customerPhone,
        fulfillmentType: fulfillmentType,
        deliveryAddress: deliveryAddress,
        tableNumber: tableNumber,
        note: note,
        orderDetails: List.from(cartItems),
        totalPrice: currentTotal.value,
        isSynced: false, // Mark as unsynced initially
        updatedAt: DateTime.now(),
      );

      final createdOrder = await localOrderRepo.create(order);
      orders.add(createdOrder);

      // Clear the cart after creating the order
      clearCart();

      return createdOrder;
    } catch (e) {
      print("Error creating order: $e");
      return null;
    }
  }

  // Update an existing order
  Future<Order?> updateOrder(Order order) async {
    try {
      final updatedOrder = await localOrderRepo.update(order);
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = updatedOrder;
      }
      return updatedOrder;
    } catch (e) {
      print("Error updating order: $e");
      return null;
    }
  }

  // Delete an order (soft delete)
  Future<void> deleteOrder(int id) async {
    try {
      await localOrderRepo.delete(id);
      orders.removeWhere((o) => o.id == id);
    } catch (e) {
      print("Error deleting order: $e");
    }
  }

  // Manually sync orders to backend
  Future<void> syncOrdersToBackend() async {
    try {
      isSyncing.value = true;
      await syncService.syncToBackend();
      await loadOrders();
    } catch (e) {
      print("Error syncing orders to backend: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  // Get order by ID
  Order? getOrderById(int id) {
    return orders.firstWhereOrNull((order) => order.id == id);
  }

  // Get orders by user ID
  List<Order> getOrderByUserId(int userId) {
    return orders.where((order) => order.userId == userId).toList();
  }

  // Get pending orders
  List<Order> getPendingOrders() {
    return orders.where((order) => order.status == 'pending').toList();
  }

  // Get completed orders
  List<Order> getCompletedOrders() {
    return orders.where((order) => order.status == 'completed').toList();
  }

  // Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await localOrderRepo.updateStatus(orderId, newStatus);
      final order = orders.firstWhereOrNull((o) => o.id == orderId);
      if (order != null) {
        order.status = newStatus;
        update(); // Refresh the UI
      }
    } catch (e) {
      print("Error updating order status: $e");
    }
  }

  // Get all orders with sync status
  List<Map<String, dynamic>> getOrdersWithSyncStatus() {
    return orders.map((order) => {
      'order': order,
      'syncStatus': order.isSynced ? 'Synced' : 'Pending',
      'syncIcon': order.isSynced ? '🟢' : '🟡',
    }).toList();
  }
}