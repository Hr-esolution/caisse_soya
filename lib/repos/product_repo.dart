import 'package:get/get.dart';
import '../config/api_client.dart';

class ProductRepo {
  final ApiClient apiClient;

  ProductRepo({required this.apiClient});

  Future<Response> getProductsList() async {
    return await apiClient.get('/api/products');
  }
  
  Future<Response> getMostselled() async {
    return await apiClient.get('/api/most-ordered-products');
  }
  
  // Additional methods for sync
  Future<Response> createProduct(Map<String, dynamic> productData) async {
    return await apiClient.postData('/api/products', productData);
  }
  
  Future<Response> updateProduct(int id, Map<String, dynamic> productData) async {
    return await apiClient.putData('/api/products/$id', productData);
  }
}