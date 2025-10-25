// lib/features/1_agent_feature/1_profile/viewmodel/agent_profile_viewmodel.dart
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_data/shared_data.dart';
import 'package:shared_data/src/database_path.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../core/model/PostModel.dart';
import '../model/agent_profile_model.dart';
import '../repo/profile_repository.dart';
import 'package:flutter/material.dart';

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
      pr('Deleting listing with postId: $postId');
      // First, delete the post from Firestore
      await _repository.deletePost(postId);
      // Then, remove the post from the local list
      _posts.removeWhere((post) => post.id == postId);

      // Now, find and delete the corresponding template from Hive
      final box = Hive.box<PropertyTemplate>(propertyTemplateBox);
      // Find the key of the template that has the matching postId
      final templateKey = box.keys.firstWhere(
          (key) => box.get(key)?.postId == postId,
          orElse: () => null);

      if (templateKey != null) {
        await box.delete(templateKey);
        pr('✅ Property template with postId $postId deleted from Hive.');
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to delete post: ${e.toString()}";
      print(_errorMessage);
      notifyListeners();
    }
  }
}