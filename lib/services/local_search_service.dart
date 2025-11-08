
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocalSearchService {
  static const String userListUrl = 'https://college-community-app-backend.onrender.com/api/users/all';

  static Future<List<dynamic>> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(userListUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['users'] ?? [];
      } else {
        print('Error fetching users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching users: $e');
      return [];
    }
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    final users = await fetchAllUsers();
    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      return name.contains(lowerQuery) || email.contains(lowerQuery);
    }).toList();
  }
}
