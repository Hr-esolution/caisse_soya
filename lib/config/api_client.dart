import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiClient extends GetxService {
  final String baseUrl;
  String? token;

  ApiClient(this.baseUrl);

  // Set authorization token
  void setToken(String? newToken) {
    token = newToken;
  }

  // Generic method to handle API requests
  Future<http.Response> makeRequest(Uri uri, String method, {dynamic body}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return response;
  }

  // GET request
  Future<Response> get(String uri) async {
    try {
      final url = Uri.parse('$baseUrl$uri');
      final response = await makeRequest(url, 'GET');
      return Response(
        statusCode: response.statusCode,
        body: response.body.isNotEmpty ? jsonDecode(response.body) : null,
        headers: response.headers,
      );
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('Could not download data');
    } on FormatException {
      throw Exception('Bad response format');
    }
  }

  // POST request
  Future<Response> postData(String uri, dynamic body) async {
    try {
      final url = Uri.parse('$baseUrl$uri');
      final response = await makeRequest(url, 'POST', body: body);
      return Response(
        statusCode: response.statusCode,
        body: response.body.isNotEmpty ? jsonDecode(response.body) : null,
        headers: response.headers,
      );
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('Could not post data');
    } on FormatException {
      throw Exception('Bad response format');
    }
  }

  // PUT request
  Future<Response> putData(String uri, dynamic body) async {
    try {
      final url = Uri.parse('$baseUrl$uri');
      final response = await makeRequest(url, 'PUT', body: body);
      return Response(
        statusCode: response.statusCode,
        body: response.body.isNotEmpty ? jsonDecode(response.body) : null,
        headers: response.headers,
      );
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('Could not update data');
    } on FormatException {
      throw Exception('Bad response format');
    }
  }

  // DELETE request
  Future<Response> deleteData(String uri) async {
    try {
      final url = Uri.parse('$baseUrl$uri');
      final response = await makeRequest(url, 'DELETE');
      return Response(
        statusCode: response.statusCode,
        body: response.body.isNotEmpty ? jsonDecode(response.body) : null,
        headers: response.headers,
      );
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException {
      throw Exception('Could not delete data');
    } on FormatException {
      throw Exception('Bad response format');
    }
  }
}

// Custom Response class to match GetX expectations
class Response {
  final int statusCode;
  final dynamic body;
  final Map<String, String>? headers;

  Response({
    required this.statusCode,
    this.body,
    this.headers,
  });
}