import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  // Base URL for API requests
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

  // Sign up method
  Future<Map<String, dynamic>> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
    {String role = 'ROLE_USER'} // Default role is USER, but can be overridden
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to sign up');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Sign in method
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('accessToken')) {
          await prefs.setString('auth_token', data['accessToken']);
        } else if (data.containsKey('access_token')) {
          await prefs.setString('auth_token', data['access_token']);
        }
        
        // Extract and save user role
        if (data.containsKey('user') && data['user'] is Map && data['user'].containsKey('role')) {
          await prefs.setString('user_role', data['user']['role']);
        }
        
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to sign in');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // Sign out method
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }
  
  // Create admin user
  Future<Map<String, dynamic>> createAdmin(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    return signUp(firstName, lastName, email, password, role: 'ADMIN');
  }
  
  // Get current user role
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'USER';
  }
  
  // Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'ROLE_ADMIN' || role == 'ADMIN';
  }
  
  // Save user role to shared preferences
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }
}
