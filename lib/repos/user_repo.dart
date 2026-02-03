import 'package:get/get.dart';
import '../config/api_client.dart';

class UserRepo {
  final ApiClient apiClient;
  UserRepo({required this.apiClient});
  
  Future<Response> getUserInfo() async {
    return await apiClient.get('/api/users');
  }
  
  // Additional methods for sync
  Future<Response> createUser(Map<String, dynamic> userData) async {
    return await apiClient.postData('/api/users', userData);
  }
  
  Future<Response> updateUser(int id, Map<String, dynamic> userData) async {
    return await apiClient.putData('/api/users/$id', userData);
  }
}