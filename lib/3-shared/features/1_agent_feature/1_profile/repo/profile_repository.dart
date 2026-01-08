// lib/features/1_agent_feature/1_profile/repo/profile_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_data/shared_data.dart';
import '../../../../core/model/PostModel.dart';
import '../model/agent_profile_model.dart';

abstract class ProfileRepository {
  Future<AgentProfile?> fetchAgentProfile(String userId);
  Future<List<PostModel>> fetchAgentPosts(String userId);
  Future<void> updateUserProfile(AgentProfile updatedProfile);
  Future<String> uploadProfileImage(String userId, XFile imageFile);
  Future<String> createPost({required Map<String, dynamic> postData});

  Future<void> deletePost(String postId);
   Future<void> updatePost({ 
    required String postId,
    required Map<String, dynamic> data,
  });
}

class FirestoreProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> getCondoNameSuggestions(String query) async {
  if (query.isEmpty) {
    return [];
  }

  try {
    final searchQuery = query.replaceAll(' ', '').toLowerCase();
    final querySnapshot = await _firestore
        .collection('posts')
        .where('condominiumName_searchKey', isGreaterThanOrEqualTo: searchQuery)
        .where('condominiumName_searchKey', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .limit(10)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    final suggestions = <String>{};
    for (var doc in querySnapshot.docs) {
      final post = PostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      suggestions.add(post.condominiumName); 
    }

    return suggestions.toList();
  } catch (e) {
    print("Error fetching condo name suggestions: $e");
    return [];
  }
}

  @override
  Future<String> createPost({required Map<String, dynamic> postData}) async {
    try {
      if (userData.userId == '') throw Exception("User not logged in");
      final userDoc =
          await _firestore.collection('users_prof').doc(userData.userId).get();
      final username = userDoc.data()?['displayName'] ?? 'Anonymous';
      final userProfileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';
      final phoneNumber = userDoc.data()?['phoneNumber'] ?? '';

      postData.addAll({
        'userId': userData.userId,
        'username': username,
        'userProfileImageUrl': userProfileImageUrl,
        'likeCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        // ★ Removed 'manualTags': [], so the passed tags are used
        'status': 'open',
        'reportedBy': [],
        'phoneNumber': phoneNumber,
      });

      if (!postData.containsKey('manualTags')) {
        postData['manualTags'] = [];
      }

      final docRef = await _firestore.collection('posts').add(postData);
      return docRef.id;
    } catch (e) {
      print("Error creating post: $e");
      rethrow;
    }
  }

  @override
  Future<AgentProfile?> fetchAgentProfile(String userId) async {
    pr('fetching agent profile for userId: $userId');
    try {
      final doc = await _firestore.collection('users_prof').doc(userId).get();
      if (doc.exists) {
        return AgentProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Failed to fetch agent profile: $e");
      throw Exception('Failed to fetch agent profile: $e');
    }
  }

  @override
  Future<List<PostModel>> fetchAgentPosts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print("Failed to fetch posts: ${e.toString()}");
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(AgentProfile updatedProfile) async {
    pr('updating user profile');
    try {
      final WriteBatch batch = _firestore.batch();
      final userRef =
          _firestore.collection('users_prof').doc(updatedProfile.uid);
      batch.update(userRef, updatedProfile.toJson());

      final postsQuery = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: updatedProfile.uid)
          .get();

      for (final postDoc in postsQuery.docs) {
        batch.update(postDoc.reference, {
          'username': updatedProfile.displayName,
          'userProfileImageUrl': updatedProfile.profileImageUrl,
          'phoneNumber': updatedProfile.phoneNumber, 
        });
      }
      await batch.commit();
    } catch (e) {
      print("Failed to update profile and posts: $e");
      throw Exception('Failed to update profile and posts: $e');
    }
  }

  @override 
  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List data = await imageFile.readAsBytes();
        uploadTask = ref.putData(data, SettableMetadata(contentType: imageFile.mimeType ?? 'image/jpeg')); 
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading profile image: $e"); 
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
      rethrow;
    }
  }

    @override
  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update(data);
    } catch (e) {
      print("Error updating post: $e");
      rethrow;
    }
  }
}