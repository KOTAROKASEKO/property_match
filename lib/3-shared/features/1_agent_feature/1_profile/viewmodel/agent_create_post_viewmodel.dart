// lib/features/1_agent_feature/1_profile/viewmodel/agent_create_post_viewmodel.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/model/PostModel.dart';
import '../../chat_template/model/property_template.dart';
import '../repo/profile_repository.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';


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
  String _location = '';
  GeoPoint? _position;
  DateTime? _durationStart;
  DateTime? _durationEnd;
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
      _location = _editingPost.location;
      _durationStart = _editingPost.durationStart;
      _durationEnd = _editingPost.durationEnd;
    }
  }
    Future<Iterable<String>> getCondoSuggestions(String query) async {
    if (query.length < 2) { // Don't search for less than 2 characters
      return const Iterable<String>.empty();
    }
    return await _postService.getCondoNameSuggestions(query);
  }

  List<dynamic> get selectedImages => _selectedImages;
  String get description => _description;
  String get condominiumName => _condominiumName;
  double get rent => _rent;
  String get roomType => _roomType;
  String get gender => _gender;
  String get location => _location;
  DateTime? get durationStart => _durationStart;
  DateTime? get durationEnd => _durationEnd;
  bool get isPosting => _isPosting;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isEditing => _editingPost != null;

  bool get canSubmit =>
      (formKey.currentState?.validate() ?? false) && !_isPosting;

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

  set location(String value) {
    _location = value;
    _updateUnsavedChangesFlag();
  }

  set durationStart(DateTime? value) {
    _durationStart = value;
    _updateUnsavedChangesFlag();
  }

  set durationEnd(DateTime? value) {
    _durationEnd = value;
    _updateUnsavedChangesFlag();
  }

  void _updateUnsavedChangesFlag() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  Future<bool> submitPost() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    _isPosting = true;
    notifyListeners();

    try {
      // 1. Geocode the location to get coordinates
      await _geocodeLocation();
      
      // 2. Upload images and get their URLs
      final imageUrls = await uploadFiles(_selectedImages);

      // 3. Create the search key
      final searchKey = _condominiumName.replaceAll(' ', '').toLowerCase();

      // 4. Create a single, consistent data map for both create and update
      final postData = {
        'description': _description,
        'imageUrls': imageUrls,
        'condominiumName': _condominiumName,
        'condominiumName_searchKey': searchKey,
        'rent': _rent,
        'roomType': _roomType,
        'gender': _gender,
        'location': _location,
        'position': _position != null ? GeoFirePoint(_position!).data : null,
        'durationStart': _durationStart,
        'durationEnd': _durationEnd,
      };

      // 5. Decide whether to create or update
      if (isEditing) {
        await _postService.updatePost(
          postId: _editingPost!.id,
          data: postData,
        );
        await _updatePropertyTemplate(_editingPost, imageUrls);
      } else {
        // createPost now correctly receives the full postData map
        final newPostId = await _postService.createPost(postData: postData);
        await _saveAsPropertyTemplate(newPostId, imageUrls);
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
  
  Future<void> _saveAsPropertyTemplate(String postId, List<String> imageUrls) async {
    try {
      final template = PropertyTemplate(
        // ★★★ 4. 受け取った postId を使う ★★★
        postId: postId,
        name: _condominiumName,
        rent: _rent,
        location: _location,
        description: _description,
        roomType: _roomType,
        gender: _gender,
        photoUrls: imageUrls,
        nationality: 'Any',
      );
      final box = Hive.box<PropertyTemplate>('propertyTemplateBox');
      await box.add(template);
      print("Successfully saved post as a property template.");
    } catch (e) {
      print("Failed to save property template: $e");
    }
  }

  Future<void> _updatePropertyTemplate(PostModel editedModel, List<String> imageUrls) async {
    try {
      final box = Hive.box<PropertyTemplate>('propertyTemplateBox');
      final templateKey = box.keys.firstWhere(
          (key) => box.get(key)?.postId == _editingPost!.id,
          orElse: () => null);

      if (templateKey != null) {
        final template = box.get(templateKey);
        if (template != null) {
          template.name = _condominiumName;
          template.rent = _rent;
          template.location = _location;
          template.description = _description;
          template.roomType = _roomType;
          template.gender = _gender;
          template.photoUrls = imageUrls;
          await template.save();
          print("Successfully updated property template.");
        }
      } else {
        await _saveAsPropertyTemplate(_editingPost!.id, imageUrls);
      }
    } catch (e) {
      print("Failed to update property template: $e");
    }
  }

  Future<void> _geocodeLocation() async {
    if (_location.isEmpty) {
      _position = null;
      return;
    }
    try {
      List<Location> locations = await locationFromAddress(_location);
      if (locations.isNotEmpty) {
        _position =
            GeoPoint(locations.first.latitude, locations.first.longitude);
      }
    } on Exception catch (e) {
      print('Failed to geocode address: $e');
      _position = null;
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      _updateUnsavedChangesFlag();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _updateUnsavedChangesFlag();
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
    _location = '';
    _durationStart = null;
    _durationEnd = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }
}