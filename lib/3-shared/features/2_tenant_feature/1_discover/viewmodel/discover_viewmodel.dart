// lib/features/2_tenant_feature/1_discover/viewmodel/discover_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // ★★★ ADDED FOR Function(PostModel) ★★★
import 'package:shared_data/shared_data.dart';
import '../../../../common_feature/post_actions_viewmodel.dart';
import '../../../../core/model/PostModel.dart'; // ★★★ ADDED FOR PostModel ★★★
import '../model/filter_options.dart';
import 'post_service.dart';

class DiscoverViewModel extends PostActionsViewModel  {
  final PostService _postService = PostService();
  
  List<PostModel> _posts = [];
  SortOrder _sortOrder = SortOrder.byDate;
  int _currentPage = 0;
  FilterOptions _filterOptions = FilterOptions();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;

  // ★★★ ADDED THIS FUNCTION PROPERTY ★★★
  // This will be assigned by _DiscoverViewState
  Function(PostModel)? onStartChat;
  // ★★★ ----------------------------- ★★★

  List<PostModel> get posts => _posts;
  SortOrder get sortOrder => _sortOrder;
  FilterOptions get filterOptions => _filterOptions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  String _searchQuery = ''; // ★ トップの検索バー（ロケーション用）
  List<String> _blockedUserIds = [];
  bool _isDisposed = false;
  
  DiscoverViewModel() {
    _fetchBlockedUsersAndThenPosts();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

Future<void> _fetchBlockedUsersAndThenPosts() async {
    await _fetchBlockedUsers();
    // ★★★ 3. 破棄されていない場合のみ実行 ★★★
    if (!_isDisposed) {
      fetchInitialPosts();
    }
  }

  Future<void> _fetchBlockedUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blockedList')
          .doc(userData.userId)
          .collection('blockedUsers')
          .get();
      _blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching blocked users: $e");
    }
  }

  // --- (2) REMOVED: _applyFilter method (ローカルフィルタリング) は不要 ---

  Future<void> fetchInitialPosts() async {
    _isLoading = true;
    _hasMorePosts = true; 
    _currentPage = 0; 
    notifyListeners();

    try {
      // ★★★ 変更点 ★★★
      // _searchQuery (ロケーション用) と _filterOptions (その他フィルター用) を渡す
      final result = await _postService.getPosts(
        locationQuery: _searchQuery, // ★ 変更 (searchQuery -> locationQuery)
        filters: _filterOptions,     // ★ 追加
        page: _currentPage,
      );
      // ★★★ ------- ★★★

      _posts = result.posts
          .where((post) => !_blockedUserIds.contains(post.userId))
          .toList();
      _hasMorePosts = result.hasMore; 
    } catch (e) {
      print("Error fetching initial posts: $e");
      _hasMorePosts = false; 
    } finally {
      _isLoading = false;
      // ★★★ FIX: REMOVE REDUNDANT CALL AND WRAP IN SAFETY CHECK ★★★
      if (!_isDisposed) {
        notifyListeners();
      }
      // ★★★ END FIX ★★★
    }
    
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    _isLoadingMore = true;
    _currentPage++; 
    notifyListeners();

    try {
      // ★★★ 変更点 ★★★
      final result = await _postService.getPosts(
        locationQuery: _searchQuery, // ★ 変更 (searchQuery -> locationQuery)
        filters: _filterOptions,     // ★ 追加
        page: _currentPage,
      );
      // ★★★ ------- ★★★
      
      final newPosts = result.posts
          .where((post) => !_blockedUserIds.contains(post.userId));
      _posts.addAll(newPosts);
      _hasMorePosts = result.hasMore;
    } catch (e) {
      print("Error fetching more posts: $e");
      _hasMorePosts = false; 
    } finally {
      _isLoadingMore = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }
  
  // --- (3) FIXED: 検索とフィルターの適用 ---
  // フィルターパネルや検索バーから呼び出された際、
  // fetchInitialPosts() を呼ぶことで Algolia に新しいクエリが飛ぶ

  Future<void> applySearchQuery(String query) async {
    // これはトップの検索バー（ロケーション用）
    _searchQuery = query;
    await fetchInitialPosts();
  }

  Future<void> applyFilters(FilterOptions filters) async {
    // これはフィルターパネル（家賃、性別、コンドミニアム名など）
    _filterOptions = filters;
    await fetchInitialPosts();
  }

  Future<void> deletePost(String postId) async {
    try {
      _posts.removeWhere((post) => post.id == postId);
      await _postService.deletePost(postId);
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  Future<void> reportPost(String postId) async {
    try {
      await _postService.reportPost(postId);
      print("Post reported: $postId");
    } catch (e) {
      print("Error reporting post: $e");
    }
  }
  
  @override
  Future<void> savePost(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) {
      return;
    }

    final post = _posts[postIndex];
    final originalSaveState = post.isSaved;

    post.isSaved = !post.isSaved;
    notifyListeners();

    try {
      await _postService.toggleSavePost(postId);
    } catch (e) {
      print("Error saving post: $e");
      post.isSaved = originalSaveState;
      notifyListeners();
    }
  }

  @override
  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.likedBy.contains(userData.userId);

    if (isLiked) {
      post.likeCount--;
      post.likedBy.remove(userData.userId);
    } else {
      post.likeCount++;
      post.likedBy.add(userData.userId);
    }

    notifyListeners();

    _postService.toggleLike(postId).catchError((e) {
      if (isLiked) {
        post.likeCount++;
        post.likedBy.add(userData.userId);
      } else {
        post.likeCount--;
        post.likedBy.remove(userData.userId);
      }
      if (!_isDisposed) {
        notifyListeners();
      }
      print("Error toggling like: $e");
    });
  }
}