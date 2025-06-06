import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:afrilingo/features/language/models/language.dart';
import 'package:afrilingo/features/courses/models/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCourseService {
  // Use localhost for emulator or your computer's IP for physical device
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Check if token is expired by decoding it
      try {
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception('Invalid token format');
        }
        
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
        );
        
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (DateTime.now().isAfter(expirationTime)) {
          // Token is expired, remove it
          await prefs.remove('auth_token');
          throw Exception('Token has expired');
        }
      } catch (e) {
        print('Error checking token expiration: $e');
        // If we can't decode the token, assume it's invalid
        await prefs.remove('auth_token');
        throw Exception('Invalid authentication token');
      }
      
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      rethrow;
    }
  }
  
  // Headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await _getAuthToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Authentication required. Please log in again.');
    }
  }

  // Check if server is available
  Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Server availability check failed: $e');
      return false;
    }
  }

  // Get all languages
  Future<List<Language>> getAllLanguages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          List<dynamic> jsonData;
          
          if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
            if (responseData['data'] is List) {
              jsonData = responseData['data'];
            } else {
              throw FormatException('Server response data is not a list');
            }
          } else if (responseData is List) {
            jsonData = responseData;
          } else {
            throw FormatException('Unexpected response format from server');
          }

          return jsonData.map((json) {
            if (json is! Map<String, dynamic>) {
              throw FormatException('Invalid language object format');
            }
            return Language.fromJson(json);
          }).toList();
        } catch (e) {
          print('Error parsing language data: $e');
          throw FormatException('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Clear the stored token on authentication errors
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Authentication required. Please log in again.');
      } else {
        throw Exception('Failed to load languages: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching languages from server: $e');
      if (e.toString().contains('Token has expired') || 
          e.toString().contains('Authentication required')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          List<dynamic> jsonData;
          
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') && responseData['data'] is List) {
              jsonData = responseData['data'];
            } else if (responseData.containsKey('courses') && responseData['courses'] is List) {
              jsonData = responseData['courses'];
            } else {
              throw FormatException('Server response does not contain valid course data');
            }
          } else if (responseData is List) {
            jsonData = responseData;
          } else {
            throw FormatException('Unexpected response format from server');
          }

          return jsonData.map((json) {
            if (json is! Map<String, dynamic>) {
              throw FormatException('Invalid course object format');
            }
            return Course.fromJson(json);
          }).toList();
        } catch (e) {
          print('Error parsing course data: $e');
          throw FormatException('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in again.');
      } else {
        throw Exception('Failed to load courses: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching courses from server: $e');
      if (e.toString().contains('Token has expired') || 
          e.toString().contains('Authentication required')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get courses by language ID
  Future<List<Course>> getCoursesByLanguageId(int languageId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/courses/language/$languageId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          List<dynamic> jsonData;
          
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') && responseData['data'] is List) {
              jsonData = responseData['data'];
            } else if (responseData.containsKey('courses') && responseData['courses'] is List) {
              jsonData = responseData['courses'];
            } else {
              throw FormatException('Server response does not contain valid course data');
            }
          } else if (responseData is List) {
            jsonData = responseData;
          } else {
            throw FormatException('Unexpected response format from server');
          }

          return jsonData.map((json) {
            if (json is! Map<String, dynamic>) {
              throw FormatException('Invalid course object format');
            }
            return Course.fromJson(json);
          }).toList();
        } catch (e) {
          print('Error parsing course data: $e');
          throw FormatException('Failed to parse server response: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in again.');
      } else {
        throw Exception('Failed to load courses: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching courses by language ID: $e');
      if (e.toString().contains('Token has expired') || 
          e.toString().contains('Authentication required')) {
        throw Exception('Authentication required. Please log in again.');
      }
      throw Exception('Failed to connect to server: $e');
    }
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
        } else {
          languageData = responseData;
        }
        
        return Language.fromJson(languageData);
      } else {
        throw Exception('Failed to create language: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
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
        } else {
          courseData = responseData;
        }
        
        return Course.fromJson(courseData);
      } else {
        throw Exception('Failed to create course: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}