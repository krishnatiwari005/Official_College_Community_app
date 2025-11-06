import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/post_service.dart';

const String apiUrl = 'https://college-community-app-backend.onrender.com';

final postsProvider = FutureProvider<List<dynamic>>((ref) async {
  print('📥 Fetching posts...');

  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api/posts'),
      headers: {'Accept': 'application/json'},
    );

    print('📊 Status: ${response.statusCode}');

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

      posts = posts.map((post) {
        if (post is Map) {
          Map<String, dynamic> updatedPost = Map.from(post);

          if (updatedPost['mediaUrl'] != null) {
            String url = updatedPost['mediaUrl'].toString().trim();
            
            if (url.isEmpty || url == 'undefined' || url == 'null') {
              updatedPost['mediaUrl'] = null;
              print('⚠️ Skipped invalid URL: $url');
            } else if (url.startsWith('/')) {
              try {
                final fullUrl = Uri.parse(apiUrl).resolve(url).toString();
                updatedPost['mediaUrl'] = fullUrl;
                print('✅ Media URL: $fullUrl');
              } catch (e) {
                print('❌ URL error: $e');
                updatedPost['mediaUrl'] = null;
              }
            }
          }

          return updatedPost;
        }
        return post;
      }).toList();

      print('✅ ${posts.length} posts fetched');
      return posts;
    } else {
      print('❌ Failed: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('❌ Error: $e');
    return [];
  }
});
