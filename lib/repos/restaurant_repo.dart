import 'package:get/get.dart';
import '../config/api_client.dart';

class RestaurantRepo extends GetxService {
  final ApiClient apiClient;
  RestaurantRepo({required this.apiClient});

  Future<Response> getAllRestaurants() async {
    return await apiClient.get('/api/restaurants');
  }
  
  // Additional methods for sync
  Future<Response> createRestaurant(Map<String, dynamic> restaurantData) async {
    return await apiClient.postData('/api/restaurants', restaurantData);
  }
  
  Future<Response> updateRestaurant(int id, Map<String, dynamic> restaurantData) async {
    return await apiClient.putData('/api/restaurants/$id', restaurantData);
  }
}