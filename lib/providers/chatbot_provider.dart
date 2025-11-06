import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    state = [
      ChatMessage(
        text: "Hi! I'm your AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
  }

  static const String chatbotUrl = 'https://fastapi-1-4ew5.onrender.com/chat';

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    state = [
      ...state,
      ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    try {
      final response = await http.post(
        Uri.parse(chatbotUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['response'] ?? 'No response received';

        state = [
          ...state,
          ChatMessage(
            text: botReply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      } else {
        _addErrorMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _addErrorMessage('Connection error. Please try again.');
    }
  }

  void _addErrorMessage(String error) {
    state = [
      ...state,
      ChatMessage(
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ),
    ];
  }

  void clearChat() {
    state = [
      ChatMessage(
        text: "Hi! I'm your AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

final chatLoadingProvider = StateProvider<bool>((ref) => false);
