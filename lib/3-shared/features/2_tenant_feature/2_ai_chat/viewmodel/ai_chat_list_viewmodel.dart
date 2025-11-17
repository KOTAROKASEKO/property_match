// lib/3-shared/features/2_tenant_feature/2_ai_chat/viewmodel/ai_chat_list_viewmodel.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_data/shared_data.dart';
import '../model/ai_chat_room_model.dart';

class AIChatListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<List<AIChatRoomModel>> chatRoomsStream;

  AIChatListViewModel() {
    chatRoomsStream = _getChatRoomsStream();
  }

  // AIチャットルームのリストをリアルタイムで取得
  Stream<List<AIChatRoomModel>> _getChatRoomsStream() {
    if (userData.userId.isEmpty) return Stream.value([]);
    
    pr('Initializing AI Chat Stream for user: ${userData.userId}');

    return _firestore
        .collection('ai_chat_rooms')
        .where('userId', isEqualTo: userData.userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AIChatRoomModel.fromFirestore(doc))
          .toList();
    });
    
  }
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // 1. メッセージの削除 (サブコレクションではなくトップレベルなのでクエリで取得して削除)
      final messagesSnapshot = await _firestore
          .collection('ai_chat_messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // 2. ルーム自体の削除
      final roomRef = _firestore.collection('ai_chat_rooms').doc(chatRoomId);
      batch.delete(roomRef);

      await batch.commit();
    } catch (e) {
      print("Error deleting chat room: $e");
      rethrow;
    }
  }

  Future<String> createNewChatRoom() async {
    if (userData.userId.isEmpty) throw Exception("User not logged in");

    final now = Timestamp.now();
    final newChatDoc = _firestore.collection('ai_chat_rooms').doc();

    final newRoomData = {
      'userId': userData.userId,
      'title': 'New Chat - ${DateFormat.yMd().format(now.toDate())}',
      'createdAt': now,
      'lastMessageText': 'welcome to the ai agent!',
      'lastMessageTimestamp': now,
      'latestConditions': {},
    };

    await newChatDoc.set(newRoomData);
    await _firestore.collection('ai_chat_messages').add({
      'chatRoomId': newChatDoc.id,
      'text': 'hello! How may I help you?',
      'isUser': false,
      'timestamp': FieldValue.serverTimestamp(),
      'isProcessed': true,
      'recommendedProperties': [],
    });

    return newChatDoc.id;
  }
}