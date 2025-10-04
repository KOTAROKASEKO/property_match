import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/core/model/PostModel.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/model/agent_profile_model.dart';
import 'package:re_conver/features/1_agent_feature/1_profile/repo/profile_repository.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/model/property_template.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/app/debug_print.dart';

// PostActionsViewModelの継承をやめて、いいね・保存ロジックを削除
class ProfileViewModel extends ChangeNotifier {
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
      await fetchAgentData(updatedProfile.uid);
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
      
      final box = Hive.box<PropertyTemplate>('propertyTemplateBox');
      box.delete(postId);
      // Note: Hive key might not be postId. This needs careful implementation.
      // Assuming a relationship exists to find the right key.
      // For now, we remove the post from the UI list.
      
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete post: ${e.toString()}";
      print(_errorMessage);
      notifyListeners();
    }
  }
}