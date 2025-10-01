import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/agent_profile_model.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/post_model.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  // 抽象クラスであるProfileRepositoryに依存
  final ProfileRepository _repository;

  // コンストラクタで具象クラス(FirestoreProfileRepository)を受け取る
  ProfileViewModel(this._repository);

  // Private state variables
  AgentProfile? _agentProfile;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters to expose state to the View
  AgentProfile? get agentProfile => _agentProfile;
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // agentProfileからデータを取得するゲッター
  String get agentName => _agentProfile?.displayName ?? 'New Agent';
  String get agentProfileImageUrl => _agentProfile?.profileImageUrl ?? '';
  String get agentBio => _agentProfile?.bio ?? '';
  int get totalListings => _posts.length;
  int get totalLikes {
    if (_posts.isEmpty) return 0;
    return _posts.map((post) => post.likeCount).reduce((a, b) => a + b);
  }

  // --- Business Logic ---
  Future<void> fetchAgentData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // プロフィールと投稿を並行して取得
      final results = await Future.wait([
        _repository.fetchAgentProfile(userId),
        _repository.fetchAgentPosts(userId),
      ]);
      _agentProfile = results[0] as AgentProfile?;
      _posts = results[1] as List<Post>;
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
      // 成功したらローカルのプロフィール情報も更新
      _agentProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      print("Failed to update profile: $e");
      // UIにエラーを伝えるため、例外を再スロー
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
}