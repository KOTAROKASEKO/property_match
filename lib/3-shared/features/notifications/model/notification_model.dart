import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String actorName;
  final String actorImageUrl;
  final String type;
  final String postId;
  final String postSnippet;
  final bool isRead;
  final Timestamp timestamp;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.actorName,
    required this.actorImageUrl,
    required this.type,
    required this.postId,
    required this.postSnippet,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      actorName: data['actorName'] ?? 'Someone',
      actorImageUrl: data['actorImageUrl'] ?? '',
      type: data['type'] ?? '',
      postId: data['postId'] ?? '',
      postSnippet: data['postSnippet'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}