import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';
import '../models/course.dart';

class AdminService {
  // Base URL for API requests
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }
  
  // Headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create a new language
  Future<Language> createLanguage(Language language) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/languages'),
        headers: headers,
        body: json.encode(language.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic> languageData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          languageData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          languageData = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return Language.fromJson(languageData);
      } else {
        throw Exception('Failed to create language: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating language: $e');
    }
  }

  // Update an existing language
  Future<Language> updateLanguage(int id, Language language) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/languages/$id'),
        headers: headers,
        body: json.encode(language.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic> languageData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          languageData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          languageData = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return Language.fromJson(languageData);
      } else {
        throw Exception('Failed to update language: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating language: $e');
    }
  }

  // Delete a language
  Future<bool> deleteLanguage(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/languages/$id'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting language: $e');
    }
  }

  // Create a new course
  Future<Course> createCourse(Course course) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: headers,
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic> courseData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          courseData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          courseData = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return Course.fromJson(courseData);
      } else {
        throw Exception('Failed to create course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating course: $e');
    }
  }

  // Update an existing course
  Future<Course> updateCourse(int id, Course course) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/courses/$id'),
        headers: headers,
        body: json.encode(course.toJson()),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic> courseData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          courseData = responseData['data'];
        } else if (responseData is Map<String, dynamic>) {
          courseData = responseData;
        } else {
          throw Exception('Unexpected response format');
        }
        
        return Course.fromJson(courseData);
      } else {
        throw Exception('Failed to update course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating course: $e');
    }
  }

  // Delete a course
  Future<bool> deleteCourse(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/courses/$id'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting course: $e');
    }
  }

  // JSON template for creating an admin user
  static String getAdminUserJsonTemplate() {
    return '''
{
  "firstName": "Admin",
  "lastName": "User",
  "email": "admin@afrilingo.com",
  "password": "Admin@123",
  "role": "ADMIN"
}
''';
  }
}