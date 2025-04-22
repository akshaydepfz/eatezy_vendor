import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  String? userToken;

  ChatProvider() {
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('token');
    notifyListeners();
  }

  Future<int> getUnreadCount(String chatId) async {
    if (userToken == null) return 0;

    final messages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderToken', isNotEqualTo: userToken)
        .get();

    return messages.docs.length;
  }

  Future<void> sendDummyMessage() async {
    final dummyMessage = "Hello from the other side!";
    final timestamp = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc('FfKvM00wNorG7OJjdK98_dummy_user')
        .collection('messages')
        .add({
      'text': dummyMessage,
      'senderToken': "other_person_token",
      'timestamp': timestamp,
      'isRead': false,
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc('FfKvM00wNorG7OJjdK98_dummy_user')
        .update({
      'lastMessage': dummyMessage,
      'lastMessageTime': timestamp,
    });
  }

  Stream<QuerySnapshot> getChatStream() {
    if (userToken == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: userToken)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String chatId) async {
    if (userToken == null) return;

    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderToken', isNotEqualTo: userToken)
        .get();

    if (unreadMessages.docs.isNotEmpty) {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty || userToken == null) return;

    final messageData = {
      'text': text.trim(),
      'senderToken': userToken,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.collection('messages').add(messageData);
    await chatRef.update({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
