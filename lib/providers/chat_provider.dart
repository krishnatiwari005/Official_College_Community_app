import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_model.dart';
import '../services/post_service.dart';

const String chatApiUrl = 'https://college-community-app-backend.onrender.com';

final chatGroupsProvider = FutureProvider<List<ChatGroup>>((ref) async {
  final token = PostService.authToken;

  print('📥 Fetching chat groups...');

  if (token == null || token.isEmpty) {
    print('❌ No token');
    return [];
  }

  try {
    final endpoints = [
      '$chatApiUrl/api/chat/groups',          
      '$chatApiUrl/api/chat',         
    ];

    for (String endpoint in endpoints) {
      try {
        print('🔍 Trying endpoint: $endpoint');

        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        print('📊 Status: ${response.statusCode} for $endpoint');

        if (response.body.contains('<!DOCTYPE html>') || 
            response.body.contains('<html')) {
          print('⚠️ Got HTML response, trying next endpoint...');
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          List<ChatGroup> groups = [];

          if (data is List) {
            groups = data.map((g) => ChatGroup.fromJson(g)).toList();
          } else if (data['groups'] != null) {
            groups = (data['groups'] as List)
                .map((g) => ChatGroup.fromJson(g))
                .toList();
          } else if (data['data'] != null) {
            final List<dynamic> groupsData = data['data'];
            groups = groupsData.map((g) => ChatGroup.fromJson(g)).toList();
          }

          print('✅ ${groups.length} groups fetched from $endpoint');
          return groups;
        }
      } catch (e) {
        print('❌ Error with $endpoint: $e');
        continue;
      }
    }

    print('❌ No working endpoint found');
    return [];
  } catch (e) {
    print('❌ Exception: $e');
    return [];
  }
});

final chatGroupProvider = FutureProvider.family<ChatGroup, String>((ref, groupId) async {
  final token = PostService.authToken;

  print('📥 Fetching chat group: $groupId');

  if (token == null || token.isEmpty) {
    print('❌ No token');
    return ChatGroup.empty();
  }

  try {
    final response = await http.get(
      Uri.parse('$chatApiUrl/api/chat/group/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('📊 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final groupData = data['data'] ?? data;
      final group = ChatGroup.fromJson(groupData);

      print('✅ Chat group loaded: ${group.chatName}');
      return group;
    } else {
      print('❌ Failed: ${response.statusCode}');
      return ChatGroup.empty();
    }
  } catch (e) {
    print('❌ Error: $e');
    return ChatGroup.empty();
  }
});

void refreshChatGroups(WidgetRef ref) {
  ref.refresh(chatGroupsProvider);
  print('🔄 Chat groups refreshed');
}

void refreshChatGroup(WidgetRef ref, String groupId) {
  ref.refresh(chatGroupProvider(groupId));
  print('🔄 Chat group refreshed: $groupId');
}
