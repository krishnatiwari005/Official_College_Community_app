import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authTokenProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null);

  void setToken(String token) {
    state = token;
    print('✅ Riverpod token updated: ${token.substring(0, 20)}...');
  }

  void clearToken() {
    state = null;
    print('🗑️ Token cleared from Riverpod');
  }

  bool isLoggedIn() {
    return state != null && state!.isNotEmpty;
  }
}
