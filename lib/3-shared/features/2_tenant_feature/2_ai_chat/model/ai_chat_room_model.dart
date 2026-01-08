// lib/3-shared/features/2_tenant_feature/2_ai_chat/model/ai_chat_room_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AIChatRoomModel {
  final String id;
  final String userId;
  final String title;
  final String lastMessageText;
  final Timestamp lastMessageTimestamp;
  final Timestamp createdAt;

  AIChatRoomModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.lastMessageText,
    required this.lastMessageTimestamp,
    required this.createdAt,
  });

  factory AIChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AIChatRoomModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'AI Chat',
      lastMessageText: data['lastMessageText'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}