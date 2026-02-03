import 'package:get/get.dart';
import '../config/api_client.dart';

class CategoryRepo extends GetxService {
  final ApiClient apiClient;
  CategoryRepo({required this.apiClient});

  Future<Response> getCategoriesList() async {
    return await apiClient.get("/api/categories");
  }

  Future<Response> getProductsForCategory(int categoryId) async {
    return await apiClient.get("/api/categories/$categoryId/products");
  }
  
  Future<Response> getCategoryAssortiments() async {
    return await apiClient.get("/api/category/assortiments/products");
  }
  
  Future<Response> getDailyOffer() async {
    return await apiClient.get("/api/category/daily-offer/products");
  }
  
  // Additional methods for sync
  Future<Response> createCategory(Map<String, dynamic> categoryData) async {
    return await apiClient.postData("/api/categories", categoryData);
  }
  
  Future<Response> updateCategory(int id, Map<String, dynamic> categoryData) async {
    return await apiClient.putData("/api/categories/$id", categoryData);
  }
}