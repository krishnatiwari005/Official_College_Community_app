import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/post_service.dart';
import 'dart:convert';

class SocketService {
  static IO.Socket? _socket;
  static const String serverUrl = 'https://college-community-app-backend.onrender.com';
  static String? _currentUserId;
  static List<String> _pendingRooms = [];
  
  static bool get isConnected => _socket?.connected ?? false;
  static IO.Socket? get socket => _socket;

  static String? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final decodedToken = jsonDecode(decoded);
      
      return decodedToken['userId'] ?? 
             decodedToken['id'] ?? 
             decodedToken['_id'] ?? 
             decodedToken['sub'];
    } catch (e) {
      print('❌ Error extracting user ID: $e');
      return null;
    }
  }

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      print('✅ Socket already connected');
      return;
    }

    final token = PostService.authToken;
    
    if (token == null || token.isEmpty) {
      print('❌ No token - cannot connect');
      return;
    }

    _currentUserId = _getUserIdFromToken(token);
    print('🔑 User ID: $_currentUserId');
    print('🔌 Connecting to socket...');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected! ID: ${_socket!.id}');
      
      // Setup event
      _socket!.emit('setup', {'token': token});
      print('📤 Setup emitted');
      
      // Join personal room
      if (_currentUserId != null) {
        _socket!.emit('join chat', _currentUserId);
        print('📤 Joined personal room: $_currentUserId');
      }
      
      // Join pending rooms
      if (_pendingRooms.isNotEmpty) {
        for (var roomId in _pendingRooms) {
          _socket!.emit('join chat', roomId);
          print('📤 Joined pending room: $roomId');
        }
        _pendingRooms.clear();
      }
    });

    _socket!.on('connected', (_) {
      print('✅ Setup confirmed - ready to chat');
    });

    _socket!.on('error', (error) {
      print('❌ Socket error: $error');
    });

    _socket!.onDisconnect((reason) {
      print('❌ Disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ Connection error: $error');
    });

    _socket!.on('reconnect', (attemptNumber) {
      print('🔄 Reconnected after $attemptNumber attempts');
      _socket!.emit('setup', {'token': token});
      if (_currentUserId != null) {
        _socket!.emit('join chat', _currentUserId);
      }
    });

    _socket!.connect();
  }

  static void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _currentUserId = null;
      _pendingRooms.clear();
    }
  }

  static void joinRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      print('🚪 Joining room: $roomId');
      _socket!.emit('join chat', roomId);
    } else {
      print('⏳ Queueing room: $roomId');
      if (!_pendingRooms.contains(roomId)) {
        _pendingRooms.add(roomId);
      }
    }
  }

  static void sendMessage({
    required String roomId,
    required String message,
  }) {
    if (_socket != null && _socket!.connected) {
      print('📤 Sending to $roomId: ${message.substring(0, message.length > 30 ? 30 : message.length)}...');
      
      _socket!.emit('sendMessage', {
        'roomId': roomId,
        'message': message,
      });
    } else {
      print('❌ Not connected - cannot send');
    }
  }

  static void onNewMessage(Function(dynamic) callback) {
    print('👂 Listening for newMessage events...');
    _socket?.on('newMessage', callback);
  }

  static void off(String event) {
    _socket?.off(event);
  }

  static void removeAllListeners() {
    print('🗑️ Removing listeners');
    _socket?.off('newMessage');
  }
}
