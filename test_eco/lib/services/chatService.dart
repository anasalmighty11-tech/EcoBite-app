import 'package:dio/dio.dart';

// --- Models ---
class Conversation {
  final String id;
  final String userName;
  final String lastMessage;
  final String time;
  final String avatarUrl;

  Conversation({required this.id, required this.userName, required this.lastMessage, required this.time, required this.avatarUrl});

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    userName: json['userName'],
    lastMessage: json['lastMessage'],
    time: json['time'],
    avatarUrl: json['avatarUrl'],
  );
}

class Message {
  final String content;
  final bool isMe;
  final DateTime timestamp;

  Message({required this.content, required this.isMe, required this.timestamp});
}

// --- Dio Service ---
class ChatService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080/api")); // Use 10.0.2.2 for Android Emulator

  Future<List<Conversation>> getConversations() async {
    try {
      // Mocked for UI development; replace with actual endpoint
      // final response = await _dio.get('/conversations');
      return [
        Conversation(id: "1", userName: "Ahmed", lastMessage: "Is the bread still available?", time: "10:30 AM", avatarUrl: ""),
        Conversation(id: "2", userName: "Sarah", lastMessage: "I can pick it up at 5", time: "Yesterday", avatarUrl: ""),
      ];
    } catch (e) {
      throw Exception("Failed to load conversations");
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      // final response = await _dio.get('/messages/$conversationId');
      return [
        Message(content: "Hello! Is the food still available?", isMe: false, timestamp: DateTime.now()),
        Message(content: "Yes, it is!", isMe: true, timestamp: DateTime.now()),
      ];
    } catch (e) {
      throw Exception("Failed to load messages");
    }
  }

  Future<void> sendMessage(String conversationId, String message) async {
    await _dio.post('/messages', data: {
      "conversationId": conversationId,
      "content": message,
    });
  }
}