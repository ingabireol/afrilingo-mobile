import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';

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

      print('Sign-in Response status: ${response.statusCode}');
      print('Sign-in Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Authentication failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> signUp(
      String firstName, String lastName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
          'role': 'ROLE_USER', // Ensure this matches your Postman request
        }),
      );

      print('Sign-up Response status: ${response.statusCode}');
      print('Sign-up Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
