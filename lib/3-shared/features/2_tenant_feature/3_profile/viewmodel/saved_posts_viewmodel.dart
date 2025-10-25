import 'package:shared_data/shared_data.dart';

import '../../../../common_feature/post_actions_viewmodel.dart';
import '../../../../core/model/PostModel.dart';
import '../../1_discover/viewmodel/post_service.dart';

class SavedPostsViewModel extends PostActionsViewModel {
  final PostService _postService = PostService();

  List<PostModel> _savedPosts = [];
  bool _isLoading = false;

  List<PostModel> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;

  SavedPostsViewModel() {
    fetchSavedPosts();
  }

  Future<void> fetchSavedPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _savedPosts = await _postService.getSavedPosts(userData.userId);
    } catch (e) {
      print("Error fetching saved posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void toggleLike(String postId) {
    final postIndex = _savedPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _savedPosts[postIndex];
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
    });
  }

  @override
  Future<void> savePost(String postId) async {
    // 保存済みリストでは、保存ボタンは「保存解除」を意味します
    final postIndex = _savedPosts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _savedPosts.removeAt(postIndex);
    notifyListeners();

    try {
      await _postService.toggleSavePost(postId);
    } catch (e) {
      // エラーが発生した場合はリストに戻します
      _savedPosts.insert(postIndex, post);
      notifyListeners();
      print("Error unsaving post: $e");
    }
  }
}