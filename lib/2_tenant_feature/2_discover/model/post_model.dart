// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:re_conver/authentication/userdata.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String userProfileImageUrl;
  final String description;
  final List<String> imageUrls;
  final Timestamp timestamp;
  final List<String> manualTags;
  final String status;
  final List<String> reportedBy;
  final String gender;
  final String roomType;
  final double rent;
  final String condominiumName;
  int likeCount;
  List<String> likedBy;
  bool isSaved;

  String caption;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
    required this.caption,
    this.description = '',
    this.imageUrls = const [],
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
    this.isSaved = false,
    this.manualTags = const [],
    this.status = 'open',
    this.reportedBy = const [],
    this.gender = 'Mix',
    this.roomType = 'Middle',
    this.rent = 0.0,
    this.condominiumName = '',
  });

  bool get isLikedByCurrentUser {
    return likedBy.contains(userData.userId);
  }

  List<String> get allTags => manualTags;

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, {bool isSaved = false}) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Post data is null for document ${doc.id}");
    }

    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likeCount: data['likeCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      isSaved: isSaved,
      manualTags: List<String>.from(data['manualTags'] ?? []),
      status: data['status'] ?? 'open',
      reportedBy: List<String>.from(data['reportedBy'] ?? []),
      gender: data['gender'] ?? 'Mix',
      roomType: data['roomType'] ?? 'Middle',
      rent: (data['rent'] as num?)?.toDouble() ?? 0.0,
      condominiumName: data['condominiumName'] ?? '',
      caption: data['caption'] ?? '',
    );
  }
}