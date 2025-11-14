import 'dart:convert';
import 'package:community_app/services/socket_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://college-community-app-backend.onrender.com';
  static String? authToken;

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String branch,
    required String year,
    List<String>? interests,
  }) async {
    try {
      print('📝 Registering user...');

      Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'branch': branch,
        'year': year,
        'interests': interests ?? [],
      };

      print('📤 Request: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          authToken = data['token'];
          print('✅ Token stored: $authToken');
        }

        return {
          'success': true,
          'message': 'Registration successful!',
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    print('🔐 Logging in...');

    Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
    };

    print('📤 Request: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));

    print('📊 Status: ${response.statusCode}');
    print('📥 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['token'] != null) {
        authToken = data['token'];
        print('✅ Login successful - Token stored: $authToken');
        
        // ✅ SAVE USER ID TO SHAREDPREFERENCES
        final prefs = await SharedPreferences.getInstance();
        
        // Try different possible field names from your API response
        String? userId = data['userId'] ?? 
                        data['user']?['_id'] ?? 
                        data['user']?['id'] ?? 
                        data['_id'] ?? 
                        data['id'];
        
        if (userId != null) {
          await prefs.setString('userId', userId);
          print('✅ User ID saved: $userId');
        } else {
          // If userId is not in response, decode it from token
          try {
            // Decode JWT to get user ID (requires jwt_decoder package)
            final parts = authToken!.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decoded = utf8.decode(base64Url.decode(normalized));
              final decodedToken = jsonDecode(decoded);
              
              userId = decodedToken['userId'] ?? 
                      decodedToken['_id'] ?? 
                      decodedToken['id'] ?? 
                      decodedToken['sub'];
              
              if (userId != null) {
                await prefs.setString('userId', userId);
                print('✅ User ID extracted from token: $userId');
              }
            }
          } catch (e) {
            print('⚠️ Could not extract user ID from token: $e');
          }
        }
        
        // Also save the token to SharedPreferences for persistence
        await prefs.setString('authToken', authToken!);
      }

      return {
        'success': true,
        'message': 'Login successful!',
        'data': data,
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Login failed',
      };
    }
  } catch (e) {
    print('❌ Error: $e');
    return {
      'success': false,
      'message': 'Connection error: $e',
    };
  }
}


  static void logout() {
  SocketService.disconnect();
  
  authToken = null;
  
  print('👋 Logged out - Token cleared');
  print('🔌 WebSocket disconnected');
}
  static String? getAuthToken() {
    return authToken;
  }
}
