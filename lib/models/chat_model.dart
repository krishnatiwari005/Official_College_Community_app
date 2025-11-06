class ChatGroup {
  final String id;
  final String chatName;
  final bool isGroupChat;
  final List<ChatUser> users;
  final ChatUser groupAdmin;
  final List<ChatMessage> messages;
  final String createdAt;
  final String updatedAt;

  ChatGroup({
    required this.id,
    required this.chatName,
    required this.isGroupChat,
    required this.users,
    required this.groupAdmin,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatGroup.empty() {
    return ChatGroup(
      id: '',
      chatName: '',
      isGroupChat: false,
      users: [],
      groupAdmin: ChatUser.empty(),
      messages: [],
      createdAt: '',
      updatedAt: '',
    );
  }

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['_id'] ?? '',
      chatName: json['chatName'] ?? json['name'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      users: (json['users'] as List?)
              ?.map((u) => ChatUser.fromJson(u))
              .toList() ??
          [],
      groupAdmin: json['groupAdmin'] != null
          ? ChatUser.fromJson(json['groupAdmin'])
          : ChatUser.empty(),
      messages: (json['messages'] as List?)
              ?.map((m) => ChatMessage.fromJson(m))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String branch;
  final List<String> interests;
  final String year;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.branch,
    required this.interests,
    required this.year,
  });

  factory ChatUser.empty() {
    return ChatUser(
      id: '',
      name: '',
      email: '',
      branch: '',
      interests: [],
      year: '',
    );
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      branch: json['branch'] ?? '',
      interests: (json['interests'] as List?)?.cast<String>() ?? [],
      year: json['year'] ?? '',
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['sender']?['_id'] ?? '',
      senderName: json['sender']?['name'] ?? 'Unknown',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
