// lib/features/2_tenant_feature/1_discover/viewmodel/post_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_data/shared_data.dart';
import '../../../../core/model/PostModel.dart';
import '../model/comment_model.dart';
import '../model/paginated_post.dart';
import '../model/filter_options.dart';

enum SortOrder { byDate, byPopularity }

class PostService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<Map<String, double>?> getLatLng(String address) async {
    try {
      // ★ .env（dart-define）からAPIキーを読む（Web / Mobile 共通）
      const apiKey = String.fromEnvironment('GEO_CODE_API_KEY');

      if (apiKey.isEmpty) {
        throw Exception('GEO_CODE_API_KEY not found in .env');
      }

      pr('Using API KEY: $apiKey');

      // ★ ここから Web / Mobile の分岐
      if (kIsWeb) {
        // -------------------------
        // Web version (existing)
        // -------------------------
        final encodedAddress = Uri.encodeComponent(address);
        final url =
            'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          pr('${response.body}');
          if (data['status'] == 'OK') {
            final loc = data['results'][0]['geometry']['location'];
            return {'lat': loc['lat'], 'lng': loc['lng']};
          } else {
            print('Google API Error: $data');
          }
        } else {
          print('HTTP Error: ${response.statusCode}');
        }
      } else {
        // -------------------------
        // Mobile version (NEW!)
        // -------------------------
        final encodedAddress = Uri.encodeComponent(address);
        final url =
            'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'OK') {
            final loc = data['results'][0]['geometry']['location'];
            return {
              'lat': loc['lat'],
              'lng': loc['lng'],
            };
          } else {
            print('Google API Error (Mobile): $data');
          }
        } else {
          print('HTTP Error (Mobile): ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Geocoding failed: $e');
    }

    return null;
  }

  final SearchClient _algoliaClient = SearchClient(
    appId: '86BOLZBS9Q', // ★ あなたのApp ID
    apiKey: '5da01cabd95ead996a8c0002b09c4b63',
  );

  Future<PaginatedPosts> getPosts({
    required String locationQuery, // ★ (場所) メイン検索バーから
    required FilterOptions filters, // ★ (雰囲気 + その他) フィルターパネルから
    int page = 0,
    int limit = 10,
  }) async {
    const String indexName = 'bilik_match_index';

    try {
      // ================================
      // 1️⃣ 住所→座標変換 (from locationQuery)
      // ================================
      String? aroundLatLng;
      if (locationQuery.isNotEmpty) {
        // ★ メイン検索バー (場所) のテキストで座標を検索
        final coords = await getLatLng(locationQuery);
        if (coords != null) {
          aroundLatLng = '${coords['lat']},${coords['lng']}';
          pr('Searching near $aroundLatLng (for "$locationQuery")');
        } else {
          pr(
              '[WARN] Geocoding failed for "$locationQuery". Proceeding without location bias.');
        }
      } else {
        pr('[DEBUG] No location query provided.');
      }

      final List<String> filterStrings = [];
      final List<List<String>> facetFilters = [];

      // --- Rent Filter ---
      if (filters.minRent != null && filters.minRent! > 0) {
        filterStrings.add('rent >= ${filters.minRent}');
      }
      if (filters.maxRent != null && filters.maxRent! < 5000) {
        filterStrings.add('rent <= ${filters.maxRent}');
      }

      if (filters.gender != null && filters.gender != 'Any') {
        pr('added gender to query string list');
        filterStrings.add('gender:${filters.gender}');
      }

      if (filters.roomType != null && filters.roomType!.isNotEmpty) {
        final roomFilters =
            filters.roomType!.map((type) => 'roomType:$type').toList();
        filterStrings.add('(${roomFilters.join(' OR ')})');
      }

      if (filters.durationStart != null) {
        final startTimestamp =
            filters.durationStart!.millisecondsSinceEpoch ~/ 1000;
        filterStrings.add('availableFromTimestamp >= $startTimestamp');
      }

      if (filters.durationMonth != null && filters.durationMonth! > 0) {
        filterStrings.add('durationMonths = ${filters.durationMonth}');
      }

      if (filters.hobbies != null && filters.hobbies!.isNotEmpty) {
        final hobbyFacets = filters.hobbies!
            .map((hobby) => 'hobbies:${hobby.trim().toLowerCase()}')
            .toList();
        facetFilters.add(hobbyFacets); // OR条件で追加
      }

      final String algoliaFilters = filterStrings.join(' AND ');
      if (algoliaFilters.isNotEmpty) {
        pr('Algolia Filters:$algoliaFilters');
      }

      // ================================
      // 3️⃣ Algolia クエリ作成
      // ================================
      final query = SearchForHits(
        indexName: indexName,
        query: filters.semanticQuery ?? '', // ★★★ AI検索クエリ（雰囲気）をここに設定 ★★★
        page: page,
        hitsPerPage: limit,
        aroundLatLng: aroundLatLng, // ★★★ 場所のクエリ（座標）をここに設定 ★★★
        aroundRadius: aroundLatLng != null ? 20000 : null, // 20km圏内
        filters: algoliaFilters.isNotEmpty ? algoliaFilters : null,
        facetFilters: facetFilters.isNotEmpty ? facetFilters : null,
      );

      // ================================
      // 4️⃣ Algolia 検索実行
      // ================================
      final response = await _algoliaClient.searchIndex(request: query);

      // ★★★ デバッグログを修正 ★★★
      pr(
          '[DEBUG ALGOLIA RESPONSE] Query: "${filters.semanticQuery ?? ''}", Location: "${locationQuery}", Filters: "$algoliaFilters"');
      if (facetFilters.isNotEmpty) {
        pr('[DEBUG ALGOLIA RESPONSE] FacetFilters: ${facetFilters.toString()}');
      }
      pr('[DEBUG ALGOLIA RESPONSE] nbHits: ${response.nbHits}');
      pr('[DEBUG ALGOLIA RESPONSE] page: ${response.page}/${response.nbPages}');

      if (response.hits.isEmpty) {
        response.facets?.forEach((key, value) {
          print('[DEBUG ALGOLIA RESPONSE] Facet $key: $value');
        });
        print('[DEBUG ALGOLIA RESPONSE] No hits found.');
      }

      final posts = response.hits.map((hit) {
        // 1. 'hit' オブジェクトは Map のように振る舞うため、
        //    まずドキュメントのフィールドを新しいMapにコピーします。
        final Map<String, dynamic> docData = Map<String, dynamic>.from(hit);

        // 2. 'objectID' は 'hit' の直接のプロパティなので、
        //    手動で 'objectID' キーとしてMapに追加します。
        docData['objectID'] = hit.objectID;

        // 3. すべてのデータ（objectID + ドキュメント）を含む
        //    この新しい "フラットな" Map をファクトリに渡します。
        return PostModel.fromAlgolia(docData);
      }).toList();

      posts.forEach((post) {
        pr('post id in algolia search: ${post.id}');
      });

      final bool hasMore = response.page! < (response.nbPages! - 1);

      return PaginatedPosts(posts: posts, hasMore: hasMore);
    } catch (e, st) {
      print('[ERROR] Algolia location search failed: $e\n$st');
      return PaginatedPosts(posts: [], hasMore: false);
    }
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
      'reportedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<List<PostModel>> getSavedPosts(String userId) async {
    try {
      final savedPostsSnapshot = await _usersCollection
          .doc(userId)
          .collection('savedPosts')
          .get();

      if (savedPostsSnapshot.docs.isEmpty) {
        return [];
      }

      final savedPostIds =
          savedPostsSnapshot.docs.map((doc) => doc.id).toList();

      final postsSnapshot = await _postsCollection
          .where(FieldPath.documentId, whereIn: savedPostIds)
          .where('status', isEqualTo: 'open')
          .get();

      final savedPosts = postsSnapshot.docs
          .map(
            (doc) => PostModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              isSaved: true,
            ),
          )
          .toList();

      return savedPosts;
    } catch (e) {
      pr("Error fetching saved posts: $e");
      return [];
    }
  }

  Future<void> toggleLike(String postId) async {
    final String userId = userData.userId;
    pr('user id : $userId');
    final DocumentReference postRef = _postsCollection.doc(postId);

    return _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception("Post does not exist!");
      }

      final List<String> likedBy = List<String>.from(
        snapshot.get('likedBy') ?? [],
      );

      if (likedBy.contains(userId)) {
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
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
      final userDoc =
          await _firestore.collection('users_prof').doc(user.uid).get();
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
        await _postsCollection
            .doc(postId)
            .collection('comments')
            .add(commentData);
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
          .map(
            (doc) => Comment.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
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
          .map(
            (doc) => Comment.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
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
          .map(
            (doc) => Comment.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();
    });
  }
}