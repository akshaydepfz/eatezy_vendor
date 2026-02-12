import 'package:eatezy_vendor/view/chat/screens/chat_view_screen.dart';
import 'package:eatezy_vendor/view/chat/services/chat_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (chatProvider.userToken == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: width,
                height: height * .07,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, size: 25),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search your customers'),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: chatProvider.getChatStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No chats yet."));
                    }

                    final chats = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, i) {
                        final chat = chats[i];
                        final chatId = chat.id;
                        final lastMessage = chat['lastMessage'] ?? '';
                        final timestamp = chat['lastMessageTime']?.toDate();
                        final timeString = timestamp != null
                            ? TimeOfDay.fromDateTime(timestamp).format(context)
                            : "";
                        final participants =
                            List<String>.from(chat['participants'] ?? []);
                        final customerId = participants.length == 2
                            ? participants.firstWhere(
                                (p) => p != chatProvider.userToken,
                                orElse: () => '')
                            : '';

                        return FutureBuilder<int>(
                          future: chatProvider.getUnreadCount(chatId),
                          builder: (context, unreadSnapshot) {
                            if (unreadSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(); // Show skeleton shimmer maybe
                            }

                            final unreadCount = unreadSnapshot.data ?? 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatViewScreen(
                                      chatId: chatId,
                                      customerId: customerId.isNotEmpty
                                          ? customerId
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              child: ChatTile(
                                image: chat['customer_image']?.toString(),
                                width: width,
                                height: height,
                                name: chat['customer_name'] ?? '',
                                message: lastMessage,
                                time: timeString,
                                unreadCount: unreadCount,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chatProvider.sendDummyMessage(),
        child: const Icon(Icons.message),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile(
      {Key? key,
      required this.width,
      required this.height,
      required this.name,
      required this.message,
      required this.time,
      required this.unreadCount,
      this.image})
      : super(key: key);

  final double width;
  final double height;
  final String name;
  final String message;
  final String time;
  final String? image;
  final int unreadCount;

  static bool _isValidNetworkImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: width,
      height: height * .11,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircleAvatar(
                  backgroundImage: _isValidNetworkImageUrl(image)
                      ? NetworkImage(image!)
                      : null,
                  child: _isValidNetworkImageUrl(image)
                      ? null
                      : Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              Text(
                time,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          )
        ],
      ),
    );
  }
}
