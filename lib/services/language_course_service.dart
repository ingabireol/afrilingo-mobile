import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/language.dart';
import '../models/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCourseService {
  // Use localhost for emulator or your computer's IP for physical device
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      // Add more detailed error logging
      print('SharedPreferences error details: ${e.toString()}');
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
      // Check if server is available first
      final isAvailable = await isServerAvailable();
      if (!isAvailable) {
        print('Server unavailable, using mock languages');
        return _getMockLanguages();
      }
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/languages'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Handle different response formats
        final dynamic responseData = json.decode(response.body);
        List<dynamic> jsonData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          jsonData = responseData['data'];
        } else if (responseData is List) {
          jsonData = responseData;
        } else {
          print('Unexpected response format, using mock languages');
          return _getMockLanguages();
        }
        
        final languages = jsonData.map((json) => Language.fromJson(json)).toList();
        return languages.isNotEmpty ? languages : _getMockLanguages();
      } else {
        print('Failed to load languages: ${response.statusCode} - ${response.body}');
        return _getMockLanguages(); // Fallback to mock data
      }
    } catch (e) {
      print('Exception in getAllLanguages: $e');
      return _getMockLanguages(); // Fallback to mock data
    }
  }

  // Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      // Check if server is available first
      final isAvailable = await isServerAvailable();
      if (!isAvailable) {
        print('Server unavailable, using mock courses');
        // Combine mock courses for all languages
        final mockLanguages = _getMockLanguages();
        List<Course> allCourses = [];
        for (var language in mockLanguages) {
          allCourses.addAll(_getMockCourses(language.id));
        }
        return allCourses;
      }
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Handle different response formats
        final dynamic responseData = json.decode(response.body);
        List<dynamic> jsonData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          jsonData = responseData['data'];
        } else if (responseData is List) {
          jsonData = responseData;
        } else {
          print('Unexpected response format, using mock courses');
          // Fallback to mock data
          final mockLanguages = _getMockLanguages();
          List<Course> allCourses = [];
          for (var language in mockLanguages) {
            allCourses.addAll(_getMockCourses(language.id));
          }
          return allCourses;
        }
        
        final courses = jsonData.map((json) => Course.fromJson(json)).toList();
        if (courses.isNotEmpty) {
          return courses;
        } else {
          // If no courses returned, use mock data
          final mockLanguages = _getMockLanguages();
          List<Course> allCourses = [];
          for (var language in mockLanguages) {
            allCourses.addAll(_getMockCourses(language.id));
          }
          return allCourses;
        }
      } else {
        print('Failed to load courses: ${response.statusCode} - ${response.body}');
        // Combine mock courses for all languages
        final mockLanguages = _getMockLanguages();
        List<Course> allCourses = [];
        for (var language in mockLanguages) {
          allCourses.addAll(_getMockCourses(language.id));
        }
        return allCourses;
      }
    } catch (e) {
      print('Exception in getAllCourses: $e');
      // Combine mock courses for all languages
      final mockLanguages = _getMockLanguages();
      List<Course> allCourses = [];
      for (var language in mockLanguages) {
        allCourses.addAll(_getMockCourses(language.id));
      }
      return allCourses;
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
        // Handle different response formats
        final dynamic responseData = json.decode(response.body);
        List<dynamic> jsonData;
        
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          jsonData = responseData['data'];
        } else if (responseData is List) {
          jsonData = responseData;
        } else {
          print('Unexpected response format, using mock courses');
          return _getMockCourses(languageId);
        }
        
        final courses = jsonData.map((json) => Course.fromJson(json)).toList();
        return courses.isNotEmpty ? courses : _getMockCourses(languageId);
      } else {
        print('Failed to load courses: ${response.statusCode} - ${response.body}');
        return _getMockCourses(languageId); // Fallback to mock data
      }
    } catch (e) {
      print('Exception in getCoursesByLanguageId: $e');
      return _getMockCourses(languageId); // Fallback to mock data
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
  
  // Mock data for languages when server is unavailable
  List<Language> _getMockLanguages() {
    return [
      Language(
        id: 1,
        name: 'Kinyarwanda',
        code: 'rw',
        description: 'The official language of Rwanda',
        flagImage: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Flag_of_Rwanda.svg',
      ),
      Language(
        id: 2,
        name: 'Swahili',
        code: 'sw',
        description: 'A widely spoken language in East Africa',
        flagImage: 'https://upload.wikimedia.org/wikipedia/commons/4/49/Flag_of_Kenya.svg',
      ),
      Language(
        id: 3,
        name: 'Yoruba',
        code: 'yo',
        description: 'A language spoken in West Africa, primarily in Nigeria',
        flagImage: 'https://upload.wikimedia.org/wikipedia/commons/7/79/Flag_of_Nigeria.svg',
      ),
    ];
  }
  
  // Mock data for courses when server is unavailable
  List<Course> _getMockCourses(int languageId) {
    final languages = _getMockLanguages();
    final language = languages.firstWhere(
      (lang) => lang.id == languageId,
      orElse: () => languages.first,
    );
    
    if (languageId == 1) { // Kinyarwanda courses
      return [
        Course(
          id: 1,
          title: 'Kinyarwanda Basics',
          description: 'Learn the fundamentals of Kinyarwanda language',
          imageUrl: 'https://images.unsplash.com/photo-1489367874814-f5d040621dd8',
          language: language,
          difficulty: 'BEGINNER',
        ),
        Course(
          id: 2,
          title: 'Kinyarwanda Conversations',
          description: 'Practice everyday conversations in Kinyarwanda',
          imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac',
          language: language,
          difficulty: 'INTERMEDIATE',
        ),
      ];
    } else if (languageId == 2) { // Swahili courses
      return [
        Course(
          id: 3,
          title: 'Swahili for Beginners',
          description: 'Start your journey with Swahili language',
          imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5',
          language: language,
          difficulty: 'BEGINNER',
        ),
      ];
    } else if (languageId == 3) { // Yoruba courses
      return [
        Course(
          id: 4,
          title: 'Introduction to Yoruba',
          description: 'Learn the basics of Yoruba language and culture',
          imageUrl: 'https://images.unsplash.com/photo-1534531173927-aeb928d54385',
          language: language,
          difficulty: 'BEGINNER',
        ),
      ];
    }
    return []; // Return empty list for unknown language ID
  }
}