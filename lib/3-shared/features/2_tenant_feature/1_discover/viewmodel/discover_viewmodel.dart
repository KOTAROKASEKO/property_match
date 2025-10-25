// lib/features/2_tenant_feature/1_discover/viewmodel/discover_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_data/shared_data.dart';
import '../../../../common_feature/post_actions_viewmodel.dart';
import '../../../../core/model/PostModel.dart';
import '../model/filter_options.dart';
import 'post_service.dart';

class DiscoverViewModel extends PostActionsViewModel  {
  final PostService _postService = PostService();

  // --- (1) REMOVED: _allFetchedPosts is no longer needed. ---
  // List<PostModel> _allFetchedPosts = []; 
  
  List<PostModel> _posts = [];
  SortOrder _sortOrder = SortOrder.byDate;
  FilterOptions _filterOptions = FilterOptions();
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;

  List<PostModel> get posts => _posts;
  SortOrder get sortOrder => _sortOrder;
  FilterOptions get filterOptions => _filterOptions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  String _searchQuery = '';
  List<String> _blockedUserIds = [];
  
  DiscoverViewModel() {
    _fetchBlockedUsersAndThenPosts();
  }

  Future<void> _fetchBlockedUsersAndThenPosts() async {
    await _fetchBlockedUsers();
    fetchInitialPosts();
  }

  Future<void> _fetchBlockedUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users_prof')
          .doc(userData.userId)
          .collection('blockedUsers')
          .get();
      _blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error fetching blocked users: $e");
    }
  }

  // --- (2) REMOVED: _applyFilter method is no longer needed. ---
  /*
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _posts = _allFetchedPosts;
    } else {
      final query = _searchQuery.toLowerCase();
      _posts = _allFetchedPosts.where((post) {
        final descriptionMatch = post.description.toLowerCase().contains(query);
        final tagMatch = post.allTags.any((tag) => tag.toLowerCase().contains(query));
        return descriptionMatch || tagMatch;
      }).toList();
    }
    notifyListeners();
  }
  */

  Future<void> fetchInitialPosts() async {
    _isLoading = true;
    _hasMorePosts = true;
    _lastDocument = null;
    notifyListeners();

    try {
      final result = await _postService.getPosts(
        sortOrder: _sortOrder,
        filters: _filterOptions,
        searchQuery: _searchQuery, // The searchQuery is correctly passed here
      );
      _posts = result.posts.where((post) => !_blockedUserIds.contains(post.userId)).toList();
      _lastDocument = result.lastDocument;
      if (result.posts.length < 10) {
        _hasMorePosts = false;
      }
    } catch (e) {
      print("Error fetching initial posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _postService.getPosts(
        sortOrder: _sortOrder,
        filters: _filterOptions,
        searchQuery: _searchQuery,
        lastDocument: _lastDocument,
      );
      // Filter blocked users from the newly fetched posts before adding them
      final newPosts = result.posts.where((post) => !_blockedUserIds.contains(post.userId));
      _posts.addAll(newPosts);
      
      _lastDocument = result.lastDocument;
      if (result.posts.length < 10) {
        _hasMorePosts = false;
      }
    } catch (e) {
      print("Error fetching more posts: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // --- (3) FIXED: This is the core of the fix. ---
  // Instead of calling the local _applyFilter, we now call fetchInitialPosts
  // to trigger a new query to Firestore with the search term.
  Future<void> applySearchQuery(String query) async {
    _searchQuery = query;
    await fetchInitialPosts();
  }

  Future<void> applyFilters(FilterOptions filters) async {
    _filterOptions = filters;
    await fetchInitialPosts();
  }

  Future<void> deletePost(String postId) async {
    try {
      _posts.removeWhere((post) => post.id == postId);
      await _postService.deletePost(postId);
      notifyListeners();
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
      notifyListeners();
      print("Error toggling like: $e");
    });
  }
}