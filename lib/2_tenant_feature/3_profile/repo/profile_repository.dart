// features/3_discover/repo/profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';
import 'package:re_conver/authentication/userdata.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userProfileBoxName = 'userProfileBox';

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

   String _getCacheKey(String userId, Roles role) {
    // enumの.nameプロパティで文字列に変換
    return '${userId}_${role.name}';
  }
  
  Future<UserProfile> getUserProfile() async {
    final userId = userData.userId;
    final currentRole = userData.role;
    
    final box = Hive.box<UserProfile>(_userProfileBoxName);
    final cacheKey = _getCacheKey(userId, currentRole);

    try {
      final collectionPath = currentRole == Roles.agent ? 'agents_prof' : 'users_prof';
      final userDoc =
          await _firestore.collection(collectionPath).doc(userId).get();
      final userDataFromDoc = userDoc.data();

      final postCountQuery = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      final postCount = postCountQuery.count ?? 0;

      final userProfile = UserProfile(
        uid: userId,
        displayName:
            userDataFromDoc?['displayName'] ??
                _auth.currentUser?.displayName ??
                'No Name',
        username: userDataFromDoc?['username'] ?? 'username',
        bio: userDataFromDoc?['bio'] ?? '',
        profileImageUrl: userDataFromDoc?['profileImageUrl'] ?? '',
        postCount: postCount,
      );

      await box.put(cacheKey, userProfile);
      return userProfile;
    } catch (e) {
      print("Error fetching profile from Firestore: $e");
      final cachedProfile = box.get(cacheKey);
      if (cachedProfile != null) return cachedProfile;
      throw Exception("Failed to load profile and no cache available.");
    }
  }

  Future<UserProfile?> getCachedUserProfile() async {
    final userId = userData.userId;
    final currentRole = userData.role;

    if (userId == "") return null;
    final box = Hive.box<UserProfile>(_userProfileBoxName);
    final cacheKey = _getCacheKey(userId, currentRole);
    return box.get(cacheKey);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final userId = userData.userId;
    if (userId == "") throw Exception("User not logged in");
    await _firestore.collection('users_prof').doc(userId).set(data, SetOptions(merge: true));

    final Map<String, dynamic> postUpdates = {};
    if (data.containsKey('displayName')) {
      postUpdates['username'] = data['displayName'];
    }
    if (data.containsKey('profileImageUrl')) {
      postUpdates['userProfileImageUrl'] = data['profileImageUrl'];
    }

    if (postUpdates.isNotEmpty) {
      await updateUserProfileInPosts(userId, postUpdates);
    }
  }

  Future<void> updateUserProfileInPosts(String userId, Map<String, dynamic> dataToUpdate) async {
    final postsQuery = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    if (postsQuery.docs.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final doc in postsQuery.docs) {
      batch.update(doc.reference, dataToUpdate);
    }
    await batch.commit();
  }

  Future<List<Post>> getMyPosts(
      {DocumentSnapshot? lastDocument, int limit = 12}) async {
    final userId = userData.userId;
    if (userId == "") return [];
    return getUserPosts(userId, lastDocument: lastDocument, limit: limit);
  }

  Future<List<Post>> getUserPosts(String userId,
      {DocumentSnapshot? lastDocument, int limit = 12}) async {
    if (userId.isEmpty) return [];

    Query query = _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) =>
            Post.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  Future<UserProfile> getUserProfileById(String userId) async {
  final box = Hive.box<UserProfile>(_userProfileBoxName);

  try {
    final userDoc =
        await _firestore.collection('users_prof').doc(userId).get();
    final userData = userDoc.data();

    final postCountQuery = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .count()
        .get();

    final postCount = postCountQuery.count ?? 0;

    final userProfile = UserProfile(
      uid: userId,
      displayName:
          userData?['displayName'] ??
              _auth.currentUser?.displayName ??
              'No Name',
      username: userData?['username'] ?? 'username',
      bio: userData?['bio'] ?? '',
      profileImageUrl: userData?['profileImageUrl'] ?? '',
      postCount: postCount,
    );

    await box.put(userId, userProfile);
    return userProfile;
  } catch (e) {
    print("Error fetching profile from Firestore: $e");
    final cachedProfile = box.get(userId);
    if (cachedProfile != null) return cachedProfile;
    throw Exception("Failed to load profile and no cache available.");
  }
}
}