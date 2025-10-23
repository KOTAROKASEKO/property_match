// lib/features/2_tenant_feature/1_discover/viewmodel/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../../core/model/PostModel.dart';
import '../model/comment_model.dart';
import '../model/filter_options.dart';
import '../model/paginated_post.dart';
import '../../../authentication/userdata.dart';

enum SortOrder { byDate, byPopularity }

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'posts';
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<PaginatedPosts> getPosts({
    required SortOrder sortOrder,
    FilterOptions? filters,
    String? searchQuery,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    CollectionReference<Map<String, dynamic>> collectionRef =
        _firestore.collection(_collectionPath).withConverter<Map<String, dynamic>>(
              fromFirestore: (snapshot, _) => snapshot.data()!,
              toFirestore: (data, _) => data,
            );
            
    Query query = collectionRef.where('status', isEqualTo: 'open');
    List<String>? geoQueriedIds;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(searchQuery);
        if (locations.isNotEmpty) {
          final center = GeoFirePoint(
              GeoPoint(locations.first.latitude, locations.first.longitude));
          const radiusInKm = 15.0; 

          final geoQuery = GeoCollectionReference(collectionRef).fetchWithin(
            center: center,
            radiusInKm: radiusInKm,
            field: 'position',
            geopointFrom: (data) {
              final position = (data)['position'] as Map<String, dynamic>;
              return position['geopoint'] as GeoPoint;
            },
          );

          final querySnapshot = await geoQuery.asStream().first;
          geoQueriedIds = querySnapshot.map((doc) => doc.id).toList();

          if (geoQueriedIds.isEmpty) {
            return PaginatedPosts(posts: [], lastDocument: null);
          }
        }
      } on Exception {
        query = query
            .where('condominiumName', isGreaterThanOrEqualTo: searchQuery)
            .where('condominiumName',
                isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }
    }
    
    if (geoQueriedIds != null) {
      if (geoQueriedIds.length > 10) {
        query = query.where(FieldPath.documentId, whereIn: geoQueriedIds.sublist(0, 10));
      } else {
        query = query.where(FieldPath.documentId, whereIn: geoQueriedIds);
      }
    }

    if (filters != null) {
      if (filters.gender != 'Any' && filters.gender != null) {
        query = query.where('gender', isEqualTo: filters.gender);
      }
      if (filters.roomType != null && filters.roomType!.isNotEmpty) {
        query = query.where('roomType', whereIn: filters.roomType);
      }
      if (filters.condoName != null && filters.condoName!.isNotEmpty) {
        query = query.where('condominiumName', isEqualTo: filters.condoName);
      }
      if (filters.minRent != null) {
        query = query.where('rent', isGreaterThanOrEqualTo: filters.minRent);
      }
      if (filters.maxRent != null && filters.maxRent! < 5000) {
        query = query.where('rent', isLessThanOrEqualTo: filters.maxRent);
      }
      // Duration filter
      if (filters.durationStart != null) {
        query = query.where('durationStart', isGreaterThanOrEqualTo: Timestamp.fromDate(filters.durationStart!));
      }
      if (filters.durationEnd != null) {
        query = query.where('durationStart', isLessThanOrEqualTo: Timestamp.fromDate(filters.durationEnd!));
      }
    }

    // Apply sorting
    bool hasDurationFilter = filters?.durationStart != null || filters?.durationEnd != null;
    if (hasDurationFilter) {
      // If filtering by duration, the first orderBy must be on the same field.
      query = query.orderBy('durationStart');
    } else if (sortOrder == SortOrder.byPopularity) {
      query = query.orderBy('likeCount', descending: true);
    } else if (geoQueriedIds == null) {
      query = query.orderBy('timestamp', descending: true);
    }


    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final snapshot = await query.get();

    final posts = snapshot.docs
        .map((doc) => PostModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();

    final DocumentSnapshot? newLastDocument =
        snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    return PaginatedPosts(posts: posts, lastDocument: newLastDocument);
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

    Future<List<PostModel>> getSavedPosts(String userId) async {
    try {
      final savedPostsSnapshot =
          await _usersCollection.doc(userId).collection('savedPosts').get();

      if (savedPostsSnapshot.docs.isEmpty) {
        return [];
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

Future<void> addComment({
  required String postId,
  required String text,
  String? parentCommentId,
}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
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