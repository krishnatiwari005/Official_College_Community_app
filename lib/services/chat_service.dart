import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_service.dart';

const String chatApiUrl = 'https://college-community-app-backend.onrender.com';

class ChatService {
  static Future<Map<String, dynamic>> createGroup({
    required String chatName,
    required List<String> users,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('📤 Creating group: $chatName');
      print('👥 Users: $users');

      final userIds = users.map((id) => id.toString()).toList();
      print('👥 User IDs (converted): $userIds');

      final requestBody = {
        'name': chatName, 
        'users': userIds,
      };

      print('📮 Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/chat/group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Group created successfully');
        return {'success': true, 'message': 'Group created'};
      } else {
        try {
          final error = jsonDecode(response.body);
          final errorMsg = error['message'] ?? 'Failed to create group';
          print('❌ Error: $errorMsg');
          return {
            'success': false,
            'message': errorMsg,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('📤 Adding user to group: $groupId');
      print('👤 User: $userId');

      final requestBody = {
        'chatId': groupId,
        'userId': userId.toString(),
      };

      print('📮 Request body: $requestBody');

      final response = await http.put(
        Uri.parse('$chatApiUrl/api/chat/group/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User added to group');
        return {'success': true, 'message': 'User added'};
      } else {
        try {
          final error = jsonDecode(response.body);
          final errorMsg = error['message'] ?? 'Failed to add user';
          print('❌ Error: $errorMsg');
          return {
            'success': false,
            'message': errorMsg,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String groupId,
    required String content,
  }) async {
    try {
      final token = PostService.authToken;
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      print('📤 Sending message to group: $groupId');

      final response = await http.post(
        Uri.parse('$chatApiUrl/api/chat/group/$groupId/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'content': content}),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Message sent');
        return {'success': true, 'message': 'Message sent'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed'};
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<List<dynamic>> getChatGroups() async {
    try {
      final token = PostService.authToken;
      if (token == null) return [];

      print('📥 Fetching chat groups...');

      final response = await http.get(
        Uri.parse('$chatApiUrl/api/chat/group'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          print('✅ ${data.length} groups fetched');
          return data;
        } else if (data['groups'] != null) {
          print('✅ ${data['groups'].length} groups fetched');
          return data['groups'];
        } else if (data['data'] != null) {
          print('✅ ${data['data'].length} groups fetched');
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getChatGroup(String groupId) async {
    try {
      final token = PostService.authToken;
      if (token == null) return null;

      print('📥 Fetching group: $groupId');

      final response = await http.get(
        Uri.parse('$chatApiUrl/api/chat/group/$groupId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Group loaded');
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
}
