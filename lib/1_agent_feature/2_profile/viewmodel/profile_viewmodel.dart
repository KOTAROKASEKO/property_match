import 'package:image_picker/image_picker.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/agent_profile_model.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';
import 'package:re_conver/2_tenant_feature/2_discover/viewmodel/post_service.dart';
import 'package:re_conver/Common_model/PostModel.dart';
import 'package:re_conver/Common_model/post_actions_viewmodel.dart';
import 'package:re_conver/app/debug_print.dart';
import 'package:re_conver/authentication/userdata.dart';

class ProfileViewModel extends PostActionsViewModel {
  final PostService _postService = PostService();
  final ProfileRepository _repository;

  ProfileViewModel(this._repository);

  AgentProfile? _agentProfile;
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  AgentProfile? get agentProfile => _agentProfile;
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get agentName => _agentProfile?.displayName ?? 'New Agent';
  String get agentProfileImageUrl => _agentProfile?.profileImageUrl ?? '';
  String get agentBio => _agentProfile?.bio ?? '';
  int get totalListings => _posts.length;
  int get totalLikes {
    if (_posts.isEmpty) return 0;
    return _posts.map((post) => post.likeCount).reduce((a, b) => a + b);
  }

  Future<void> fetchAgentData(String userId) async {
    pr('Fetching agent data for userId: $userId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchAgentProfile(userId),
        _repository.fetchAgentPosts(userId),
      ]);
      _agentProfile = results[0] as AgentProfile?;
      _posts = results[1] as List<PostModel>;
    } catch (e) {
      _errorMessage = "Failed to fetch data: ${e.toString()}";
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(AgentProfile updatedProfile) async {
    try {
      await _repository.updateUserProfile(updatedProfile);
      _agentProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print("Failed to update profile: $e");
      rethrow;
    }
  }

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      return await _repository.uploadProfileImage(userId, imageFile);
    } catch (e) {
      print("Failed to upload image: $e");
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete post: ${e.toString()}";
      print(_errorMessage);
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

  @override
  Future<void> savePost(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

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
}