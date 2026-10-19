import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

/// Centralized API service for THE NEW HOTPOT backend communication.
class ApiService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8000';
  static String baseUrl = defaultBaseUrl;

  // ==========================================
  // CUSTOMER / PUBLIC ENDPOINTS
  // ==========================================

  /// Fetch all available foods for customers (optionally filtered by category).
  static Future<List<Food>> getFoods({String? category}) async {
    Uri uri = Uri.parse('$baseUrl/foods');
    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim() != 'All') {
      uri = uri.replace(queryParameters: {'category': category.trim()});
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((item) => Food.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load menu (Status: ${response.statusCode})');
    }
  }

  /// Create a new customer order.
  static Future<Map<String, dynamic>> createOrder({
    required String name,
    required String phone,
    required String address,
    required int total,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/orders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'address': address,
            'total': total,
            'items': items,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to place order (Status: ${response.statusCode})');
    }
  }

  /// Track order by orderId and customer phone.
  static Future<Map<String, dynamic>> trackOrder({
    required String orderId,
    required String phone,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/orders/track'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'order_id': orderId, 'phone': phone}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Order not found');
    }
  }

  /// Submit customer feedback.
  static Future<void> submitFeedback({
    required String? customerName,
    required String message,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/feedback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'customer_name': customerName, 'message': message}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to submit feedback');
    }
  }

  // ==========================================
  // ADMIN AUTH & DASHBOARD ENDPOINTS
  // ==========================================

  /// Admin login returning bearer token.
  static Future<String?> loginAdmin({
    required String username,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/admin/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String?;
    }
    return null;
  }

  /// Admin fetch all food dishes (both available and sold out).
  static Future<List<Food>> getAdminFoods({
    required String token,
    String? category,
  }) async {
    Uri uri = Uri.parse('$baseUrl/admin/foods');
    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim() != 'All') {
      uri = uri.replace(queryParameters: {'category': category.trim()});
    }

    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((item) => Food.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Admin session expired.');
    } else {
      throw Exception(
        'Failed to fetch admin menu (Status: ${response.statusCode})',
      );
    }
  }

  /// Admin create a new food dish.
  static Future<Food> createFood({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/admin/foods'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(
        err['detail'] ??
            'Failed to create dish (Status: ${response.statusCode})',
      );
    }
  }

  /// Admin update an existing food dish.
  static Future<Food> updateFood({
    required String token,
    required int foodId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/admin/foods/$foodId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Food.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Failed to update dish');
    }
  }

  /// Admin delete an existing food dish.
  static Future<bool> deleteFood({
    required String token,
    required int foodId,
  }) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/admin/foods/$foodId'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['detail'] ?? 'Failed to delete dish');
    }
  }

  /// Admin fetch all orders.
  static Future<List<Map<String, dynamic>>> getOrders({
    required String token,
  }) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/orders'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load orders (Status: ${response.statusCode})');
    }
  }

  /// Admin update order status.
  static Future<void> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/orders/$orderId/status',
    ).replace(queryParameters: {'status': status});

    final response = await http
        .patch(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }
}
