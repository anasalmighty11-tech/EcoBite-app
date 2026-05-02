import 'package:flutter/material.dart';
import 'package:test_eco/services/chatService.dart';

import 'ChatDetailPage.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  final Color primaryGreen = const Color(0xFF084D0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _chatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final convos = snapshot.data ?? [];
          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final convo = convos[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryGreen.withOpacity(0.1),
                  child: Icon(Icons.person, color: primaryGreen),
                ),
                title: Text(convo.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(convo.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(convo.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatDetailPage(conversation: convo)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}