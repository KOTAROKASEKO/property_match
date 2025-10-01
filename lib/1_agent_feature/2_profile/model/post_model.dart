import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String description;
  final List<String> imageUrls;
  final int likeCount;
  final String userId;
  final String username;
  final DateTime timestamp;
  final String gender;
  final String roomType;
  final double rent;
  final String condominiumName;

  Post({
    required this.id,
    required this.description,
    required this.imageUrls,
    required this.likeCount,
    required this.userId,
    required this.username,
    required this.timestamp,
    required this.gender,
    required this.roomType,
    required this.rent,
    required this.condominiumName,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likeCount: data['likeCount'] ?? 0,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      gender: data['gender'] ?? 'Mix',
      roomType: data['roomType'] ?? 'Middle',
      rent: (data['rent'] as num?)?.toDouble() ?? 0.0,
      condominiumName: data['condominiumName'] ?? '',
    );
  }
}