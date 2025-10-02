import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';
import 'package:re_conver/Common_model/PostModel.dart';

class CreatePostViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final FirestoreProfileRepository _postService = FirestoreProfileRepository();
  final ImagePicker _picker = ImagePicker();
  final PostModel? _editingPost;

  List<dynamic> _selectedImages = [];
  String _description = '';
  String _condominiumName = '';
  double _rent = 0;
  String _roomType = 'Master';
  String _gender = 'Mix';
  bool _isPosting = false;
  bool _hasUnsavedChanges = false;

  CreatePostViewModel(this._editingPost) {
    if (_editingPost != null) {
      _description = _editingPost.description;
      _condominiumName = _editingPost.condominiumName;
      _rent = _editingPost.rent;
      _roomType = _editingPost.roomType;
      _gender = _editingPost.gender;
      _selectedImages = List.from(_editingPost.imageUrls);
    }
  }

  List<dynamic> get selectedImages => _selectedImages;
  String get description => _description;
  String get condominiumName => _condominiumName;
  double get rent => _rent;
  String get roomType => _roomType;
  String get gender => _gender;
  bool get isPosting => _isPosting;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isEditing => _editingPost != null;

  bool get canSubmit =>
      (_description.isNotEmpty || _selectedImages.isNotEmpty) && !_isPosting;

  set description(String value) {
    _description = value;
    _updateUnsavedChangesFlag();
  }

  set condominiumName(String value) {
    _condominiumName = value;
    _updateUnsavedChangesFlag();
  }

  set rent(double value) {
    _rent = value;
    _updateUnsavedChangesFlag();
  }

  set roomType(String value) {
    _roomType = value;
    notifyListeners();
  }

  set gender(String value) {
    _gender = value;
    notifyListeners();
  }

  void _updateUnsavedChangesFlag() {
    _hasUnsavedChanges = _selectedImages.isNotEmpty ||
        _description.isNotEmpty ||
        _condominiumName.isNotEmpty ||
        _rent > 0;
    notifyListeners();
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      _updateUnsavedChangesFlag();
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _updateUnsavedChangesFlag();
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
      quality: 88,
      format: CompressFormat.webp,
    );
    if (result == null) {
      throw Exception("Image compression failed.");
    }
    return File(result.path);
  }

  Future<bool> submitPost() async {
    if (!formKey.currentState!.validate() || !canSubmit) {
      return false;
    }

    _isPosting = true;
    notifyListeners();

    try {
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await uploadFiles(_selectedImages);
      }

      if (isEditing) {
        // Update existing post
        // This functionality needs to be added to the repository
      } else {
        await _postService.createPost(
          description: _description,
          imageUrls: imageUrls,
          condominiumName: _condominiumName,
          rent: _rent,
          roomType: _roomType,
          gender: _gender,
          manualTags: [], // Kept for compatibility, can be removed if not needed
        );
      }

      _hasUnsavedChanges = false;
      return true;
    } catch (e) {
      print("Post submission failed: $e");
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  Future<List<String>> uploadFiles(List<dynamic> files) async {
    List<String> imageUrls = [];
    for (var file in files) {
      if (file is String) {
        imageUrls.add(file);
      } else if (file is File) {
        final compressedFile = await compressAndConvertToWebP(file);
        final fileName =
            'posts/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.webp';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        final uploadTask = ref.putFile(compressedFile);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }
    return imageUrls;
  }

  void clearDraft() {
    _selectedImages = [];
    _description = '';
    _condominiumName = '';
    _rent = 0;
    _hasUnsavedChanges = false;
    notifyListeners();
  }
}