
import '../../../../core/model/PostModel.dart';
import '../../../1_agent_feature/1_profile/model/agent_profile_model.dart';
import '../../../1_agent_feature/1_profile/repo/profile_repository.dart';
import '../../../../common_feature/post_actions_viewmodel.dart';
import 'post_service.dart';
import '../../../authentication/userdata.dart';

class PublicAgentProfileViewModel extends PostActionsViewModel {
  final ProfileRepository _profileRepository = FirestoreProfileRepository();
  final PostService _postService = PostService();
  final String agentId;

  AgentProfile? _agentProfile;
  List<PostModel> _posts = [];
  bool _isLoading = false;

  AgentProfile? get agentProfile => _agentProfile;
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  PublicAgentProfileViewModel(this.agentId) {
    fetchAgentData();
  }

  Future<void> fetchAgentData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _profileRepository.fetchAgentProfile(agentId),
        _profileRepository.fetchAgentPosts(agentId),
      ]);
      _agentProfile = results[0] as AgentProfile?;
      _posts = results[1] as List<PostModel>;
    } catch (e) {
      print("Error fetching agent data: $e");
    } finally {
      _isLoading = false;
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
      // Revert on error
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
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    post.isSaved = !post.isSaved;
    notifyListeners();

    try {
      await _postService.toggleSavePost(postId);
    } catch (e) {
      // Revert on error
      post.isSaved = !post.isSaved;
      notifyListeners();
    }
  }
}