// lib/core/model/PostModel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_data/shared_data.dart';

class PostModel {
  final double securityDeposit; // 敷金 (例: 家賃の2ヶ月分なら 2.0)
  final double utilityDeposit;
  final String condominiumName_searchKey;
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
  final GeoPoint? position;
  final String location;
  final DateTime? durationStart;
  final DateTime? moveInDate;
  final int? durationMonths;
  final String phoneNumber;

  PostModel({
    this.securityDeposit = 2.0, // デフォルト値 (マレーシア等の慣習に合わせて調整)
    this.utilityDeposit = 0.5,
    this.moveInDate,
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
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
    this.position,
    this.location = '',
    this.condominiumName_searchKey = '',
    this.durationStart,
    this.durationMonths,
    this.phoneNumber = '',
  });

  bool get isLikedByCurrentUser {
    return likedBy.contains(userData.userId);
  }

  List<String> get allTags => manualTags;

  factory PostModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    bool isSaved = false,
  }) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Post data is null for document ${doc.id}");
    }
    final positionData = data['position'] as Map<String, dynamic>?;
    GeoPoint? postPosition;
    if (positionData != null) {
      final geopoint = positionData['geopoint'] as GeoPoint?;
      if (geopoint != null) {
        postPosition = GeoPoint(geopoint.latitude, geopoint.longitude);
      }
    }

    return PostModel(
      securityDeposit: (data?['securityDeposit'] as num?)?.toDouble() ?? 2.0,
      utilityDeposit: (data?['utilityDeposit'] as num?)?.toDouble() ?? 0.5,
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userProfileImageUrl: data['userProfileImageUrl'] ?? '',
      description: data['description'] ?? data['caption'] ?? '',
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
      condominiumName_searchKey: data['condominiumName_searchKey'] ?? '',
      rent: (data['rent'] as num?)?.toDouble() ?? 0.0,
      condominiumName: data['condominiumName'] ?? '',
      position: postPosition,
      location: data['location'] as String? ?? '',
      durationStart: (data['durationStart'] as Timestamp?)?.toDate(),
      durationMonths: data['durationMonths'] as int? ?? 12,
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  factory PostModel.fromAlgolia(Map<String, dynamic> hit) {
    GeoPoint geoPoint = const GeoPoint(0, 0);
    if (hit['_geoloc'] != null &&
        hit['_geoloc']['lat'] != null &&
        hit['_geoloc']['lng'] != null) {
      geoPoint = GeoPoint(
        (hit['_geoloc']['lat'] as num).toDouble(),
        (hit['_geoloc']['lng'] as num).toDouble(),
      );
    }

    Timestamp safeTimestamp(dynamic ts) {
      if (ts is num) {
        return Timestamp.fromMillisecondsSinceEpoch(ts.toInt()); // ★ 修正: * 1000 を削除
      }
      return Timestamp.now();
    }

    return PostModel(
      securityDeposit: (hit['securityDeposit'] as num?)?.toDouble() ?? 2.0,
      utilityDeposit: (hit['utilityDeposit'] as num?)?.toDouble() ?? 0.5,
      id: hit['objectID'] ?? '',
      userId: hit['userId'] ?? '',
      username: hit['username'] ?? 'Anonymous',
      userProfileImageUrl: hit['userProfileImageUrl'] ?? '',
      description: hit['description'] ?? hit['caption'] ?? '',
      imageUrls: List<String>.from(hit['imageUrls'] ?? []),
      timestamp: safeTimestamp(hit['timestamp']),
      likeCount: (hit['likeCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.from(hit['likedBy'] ?? []),
      isSaved: false,
      manualTags: List<String>.from(hit['manualTags'] ?? []),
      status: hit['status'] ?? 'open',
      reportedBy: List<String>.from(hit['reportedBy'] ?? []),
      gender: hit['gender'] ?? 'Mix',
      roomType: hit['roomType'] ?? 'Middle',
      condominiumName_searchKey: hit['condominiumName_searchKey'] ?? '',
      rent: (hit['rent'] as num?)?.toDouble() ?? 0.0,
      condominiumName: hit['condominiumName'] ?? '',
      location: hit['location'] ?? '',
      position: geoPoint,
      durationStart: safeTimestamp(hit['durationStart']).toDate(),
      durationMonths: hit['durationMonths'] as int?,
      phoneNumber: hit['phoneNumber'] ?? '',
    );
  }
}