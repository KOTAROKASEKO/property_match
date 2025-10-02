import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/comment_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/paginated_post.dart';
import 'package:re_conver/Common_model/PostModel.dart';
import 'package:re_conver/authentication/userdata.dart';

// Sort order enum
enum SortOrder { byDate, byPopularity }

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'posts';
  final CollectionReference _postsCollection = FirebaseFirestore.instance.collection('posts');
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');


  Future<PaginatedPosts> getPosts({
    required SortOrder sortOrder,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _firestore.collection(_collectionPath).where('status', isEqualTo: 'open');

    if (sortOrder == SortOrder.byPopularity) {
      query = query.orderBy('likeCount', descending: true);
    } else {
      query = query.orderBy('timestamp', descending: true);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final snapshot = await query.get();

    final posts = snapshot.docs
        .map((doc) => PostModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();

    final DocumentSnapshot? newLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return PaginatedPosts(posts: posts, lastDocument: newLastDocument);
  }

  Future<List<PostModel>> getSavedPosts(String userId) async {
    try {
      // 1. Get the IDs of all saved posts.
      final savedPostsSnapshot =
          await _usersCollection.doc(userId).collection('savedPosts').get();

      if (savedPostsSnapshot.docs.isEmpty) {
        return []; // The user has no saved posts.
      }

      final savedPostIds = savedPostsSnapshot.docs.map((doc) => doc.id).toList();

      final postsSnapshot = await _postsCollection
          .where(FieldPath.documentId, whereIn: savedPostIds)
          .where('status', isEqualTo: 'open')
          .get();

      final savedPosts = postsSnapshot.docs
          .map((doc) => PostModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              isSaved: true))
          .toList();

      return savedPosts;
    } catch (e) {
      print("Error fetching saved posts: $e");
      return [];
    }
  }

  Future<void> createPost({
    required String caption,
    required List<String> imageUrls,
    required List<String> manualTags
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");
      final userDoc = await _firestore.collection('users_prof').doc(user.uid).get();
      final username = userDoc.data()?['displayName'] ?? 'Anonymous';
      final userProfileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

      await _firestore.collection('posts').add({
        'caption': caption,
        'imageUrls': imageUrls,
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

  Future<void> toggleLike(String postId) async {
    final String userId = userData.userId;
    final DocumentReference postRef = _postsCollection.doc(postId);

    return _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception("Post does not exist!");
      }

      final List<String> likedBy = List<String>.from(snapshot.get('likedBy') ?? []);

      if (likedBy.contains(userId)) {
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId])
        });
      }
    });
  }

 // 2_discover/viewmodel/post_service.dart

Future<void> addComment({
  required String postId,
  required String text,
  String? parentCommentId,
}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 修正箇所：'users' を 'users_prof' に、'username' を 'displayName' に変更
    final userDoc = await _firestore.collection('users_prof').doc(user.uid).get();
    final username = userDoc.data()?['displayName'] ?? 'Anonymous';
    final userProfileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';

    final commentData = {
      'text': text,
      'userId': user.uid,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (parentCommentId != null) {
      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(parentCommentId)
          .collection('replies')
          .add(commentData);
    } else {
      await _postsCollection.doc(postId).collection('comments').add(commentData);
    }
  } catch (e) {
    print("Error adding comment: $e");
    rethrow;
  }
}

  Stream<List<Comment>> getComments(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }

  Stream<List<Comment>> getReplies(String postId, String commentId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }

  Future<void> deletePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not logged in.");
    }

    final postRef = _postsCollection.doc(postId);

    final doc = await postRef.get();
    if (!doc.exists) {
      throw Exception("Post does not exist.");
    }
    await postRef.delete();
  }

  Future<void> reportPost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User is not logged in.");
    }
    await _postsCollection.doc(postId).update({
      'reportedBy': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> toggleSavePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("User is not logged in.");
      }

      final savedPostRef =
          _usersCollection.doc(userId).collection('savedPosts').doc(postId);

      final doc = await savedPostRef.get();

      if (doc.exists) {
        await savedPostRef.delete();
      } else {
        await savedPostRef.set({'timestamp': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      print("Error toggling save state: $e");
      rethrow;
    }
  }

  Stream<List<Comment>> getLatestComment(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
}