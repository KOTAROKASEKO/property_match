// features/3_discover/viewmodel/profile_viewmodel.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/agent_profile_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/repo/agent_profile_repo.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UserProfile _userProfile = UserProfile.empty();
  UserProfile get userProfile => _userProfile;

  List<Post> _myPosts = [];
  List<Post> get myPosts => _myPosts;
  final ImagePicker _picker = ImagePicker();

  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingMorePosts = false;
  bool get isLoadingMorePosts => _isLoadingMorePosts;

  bool _hasMorePosts = true;

  // ✅ MODIFIED CONSTRUCTOR
  ProfileViewModel({String? userId}) {
    if (userId != null) {
      loadProfileById(userId);
    } else {
      loadProfile();
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> dataToUpdate = {
        'displayName': displayName,
        'bio': bio,
      };
      
      await _repository.updateUserProfile(dataToUpdate);
      
      await loadProfile();
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final File imageFile = File(image.path);
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _uploadProfileImage(imageFile);
      await _repository.updateUserProfile({'profileImageUrl': imageUrl});
      await loadProfile();
    } catch (e) {
      print("Error updating profile image: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File> compressAndConvertToWebP(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 77,
      format: CompressFormat.webp,
    );
    // resultがnullの場合を考慮
    if (result == null) {
      throw Exception("Image compression failed.");
    }
    return File(result.path);
  }

  Future<String> _uploadProfileImage(File file) async {
    final userId = _repository.getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    final compressedFile = await compressAndConvertToWebP(file);
    final fileName = 'profile_images/$userId.webp';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = ref.putFile(compressedFile);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    final cachedProfile = await _repository.getCachedUserProfile();
    if (cachedProfile != null) {
      _userProfile = cachedProfile;
      notifyListeners();
    }

    try {
      _userProfile = await _repository.getUserProfile();
      await fetchMyPosts(isInitial: true);
    } catch (e) {
      print("Error in ViewModel loading profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyPosts({bool isInitial = false, String? userId}) async {
    if (_isLoadingMorePosts) return;

    final targetUserId = userId ?? _repository.getCurrentUserId();
    if (targetUserId == null || targetUserId.isEmpty) {
      _myPosts = [];
      _isLoadingMorePosts = false;
      notifyListeners();
      return;
    }

    if (isInitial) {
      _myPosts = [];
      _lastDocument = null;
      _hasMorePosts = true;
    }

    if (!_hasMorePosts) return;

    _isLoadingMorePosts = true;

    try {
      final newPosts =
          await _repository.getUserPosts(targetUserId, lastDocument: _lastDocument);

      if (newPosts.isNotEmpty) {
        final lastPostId = newPosts.last.id;
        _lastDocument =
            await FirebaseFirestore.instance.collection('posts').doc(lastPostId).get();
      }

      if (newPosts.length < 12) {
        _hasMorePosts = false;
      }

      _myPosts.addAll(newPosts);
    } catch (e) {
      print("Error fetching user posts: $e");
    } finally {
      _isLoadingMorePosts = false;
      notifyListeners();
    }
  }

  Future<void> loadProfileById(String userId) async {
  _isLoading = true;
  notifyListeners();

  try {
    _userProfile = await _repository.getUserProfileById(userId);
    await fetchMyPosts(isInitial: true, userId: userId);
  } catch (e) {
    print("Error in ViewModel loading profile: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}