import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/agent_profile_model.dart';
import 'package:re_conver/Common_model/PostModel.dart';
import 'package:re_conver/app/debug_print.dart';

abstract class ProfileRepository {
  Future<AgentProfile?> fetchAgentProfile(String userId);
  Future<List<PostModel>> fetchAgentPosts(String userId);
  Future<void> updateUserProfile(AgentProfile updatedProfile);
  Future<String> uploadProfileImage(String userId, XFile imageFile);
  Future<void> createPost({
    required String description,
    required List<String> imageUrls,
    required String condominiumName,
    required double rent,
    required String roomType,
    required String gender,
    required List<String> manualTags,
  });
  Future<void> deletePost(String postId);
}

// Firestoreに対する具体的な実装クラス
class FirestoreProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      return querySnapshot.docs.map((doc) => PostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    } catch (e) {
      print("Failed to fetch posts: ${e.toString()}");
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(AgentProfile updatedProfile) async {
    pr('updating user profile');
    try {
      await _firestore
          .collection('users_prof')
          .doc(updatedProfile.uid)
          .update(updatedProfile.toJson());
    } catch (e) {
      print("Failed to update profile: $e");
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> createPost({
    required String description,
    required List<String> imageUrls,
    required String condominiumName,
    required double rent,
    required String roomType,
    required String gender,
    required List<String> manualTags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");
      final userDoc =
          await _firestore.collection('users_prof').doc(user.uid).get();
      final username = userDoc.data()?['displayName'] ?? 'Anonymous';
      final userProfileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

      await _firestore.collection('posts').add({
        'description': description,
        'imageUrls': imageUrls,
        'condominiumName': condominiumName,
        'rent': rent,
        'roomType': roomType,
        'gender': gender,
        'userId': user.uid,
        'username': username,
        'userProfileImageUrl': userProfileImageUrl,
        'likeCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'manualTags': manualTags,
        'status': 'open',
        'reportedBy': [],
      });
    } catch (e) {
      print("Error creating post: $e");
      rethrow;
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
}