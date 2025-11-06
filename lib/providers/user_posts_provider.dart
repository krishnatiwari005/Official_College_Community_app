import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/post_service.dart';

final userPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = PostService.authToken;
  
  print('📥 Fetching user posts with token: ${token?.substring(0, 20) ?? "null"}...');
  
  if (token == null || token.isEmpty) {
    return [];
  }

  try {
    final response = await http.get(
      Uri.parse('https://college-community-app-backend.onrender.com/api/posts/my-posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('📊 User Posts Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> posts = [];

      if (data is List) {
        posts = data;
      } else if (data['posts'] != null) {
        posts = data['posts'];
      } else if (data['data'] != null) {
        posts = data['data'];
      }

      print('✅ ${posts.length} user posts fetched');
      return posts;
    } else if (response.statusCode == 404) {
      print('ℹ️ No posts found');
      return [];
    } else {
      print('❌ Failed: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});

void refreshUserPosts(WidgetRef ref) {
  ref.refresh(userPostsProvider);
  print('🔄 User posts refreshed');
}
