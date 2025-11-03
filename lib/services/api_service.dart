import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  /// Fetch emotions for a given user (by email and password)
  /// Returns a list of emotion names
  static Future<List<String>> fetchEmotions({required String email, required String password}) async {
    try {
      final url = Uri.parse('$baseUrl/emotions/api/emotions/?Email=$email&Password=$password');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['success'] == true) {
          final List results = jsonResponse['results'] as List? ?? [];
          return results
              .map((e) => (e as Map<String, dynamic>)['emotion_name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch emotions: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  /// Create a new user
  /// Returns the created user model or throws an exception
  static Future<UserModel> createUser(UserModel user) async {
    try {
      final url = Uri.parse('$baseUrl/api/create-user/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse);
      } else {
        // Try to parse error message
        String errorMessage = 'Registration failed';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? 
                        errorJson['error'] ?? 
                        errorJson.toString();
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Registration failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Login user with email and password
  /// Returns the user model or throws an exception
  static Future<UserModel> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/login/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Email': email,
          'Password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        // Debug: Print the response to see what we're getting
        print('Login API Response: $jsonResponse');
        final user = UserModel.fromJson(jsonResponse);
        print('Parsed User Name: ${user.userName}');
        return user;
      } else {
        // Try to parse error message
        String errorMessage = 'Login failed';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? 
                        errorJson['error'] ?? 
                        errorJson.toString();
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Login failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Update user's plan type
  /// Returns the updated user model or throws an exception
  static Future<UserModel> updateUserPlanType(int userId, String planType) async {
    try {
      final url = Uri.parse('$baseUrl/api/update-user/$userId/');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Plan_Type': planType,
          'Updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return UserModel.fromJson(jsonResponse);
      } else {
        String errorMessage = 'Failed to update plan type';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['message'] ?? 
                        errorJson['error'] ?? 
                        errorJson.toString();
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Update failed with status ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

