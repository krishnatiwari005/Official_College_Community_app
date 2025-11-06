import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';
  static String? authToken;

  static void setAuthToken(String? token) {
    authToken = token;
    print('✅ PostService.authToken set: ${token?.substring(0, 20) ?? "null"}...');
  }

  static void clearAuthToken() {
    authToken = null;
    print('🗑️ PostService.authToken cleared');
  }

  static String? getAuthToken() {
    return authToken;
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String description,
    required String category,
    File? mediaFile,
  }) async {
    try {
      print('🚀 Creating post...');
      print('--> URL: $baseUrl/api/posts/create');
      print('--> title: $title, description: $description, category: $category');
      print('--> Token: ${authToken?.substring(0, 20) ?? "null"}...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/posts/create'),
      );

      if (authToken != null && authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
        print('🔐 Auth token included');
      }

      request.headers['Accept'] = 'application/json';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (mediaFile != null) {
        int fileSize = await mediaFile.length();
        double fileSizeMB = fileSize / (1024 * 1024);
        if (fileSizeMB > 10) {
          return {'success': false, 'message': 'File too large (max 10MB)'};
        }
        String fileName = mediaFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath('media', mediaFile.path, filename: fileName),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Post created!',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> getAllPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
        if (data is Map) {
          if (data['posts'] != null) return data['posts'];
          if (data['data'] != null) return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }
}
