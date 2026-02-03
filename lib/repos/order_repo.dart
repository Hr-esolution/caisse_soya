import 'package:get/get.dart';
import '../config/api_client.dart';

class OrderRepo {
  final ApiClient apiClient;

  OrderRepo({required this.apiClient});

  Future<Response> placeOrder(Map<String, dynamic> payload) async {
    return await apiClient.postData('/api/orders', payload);
  }

  Future<Response> fetchUserOrders() async {
    return await apiClient.get('/api/user/orders');
  }

  Future<Response> getOrderDetails(String orderId) async {
    return await apiClient.get('/api/orders/$orderId/details');
  }
}