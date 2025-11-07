// lib/features/1_agent_feature/1_profile/viewmodel/agent_create_post_viewmodel.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../core/model/PostModel.dart';
import '../repo/profile_repository.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class CreatePostViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  // Use the concrete type FirestoreProfileRepository if getCondoSuggestions is specific to it
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
  int? _durationMonths;
  bool _isPosting = false;
  bool _hasUnsavedChanges = false;
  List<String> _hobbies = [];

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
      _durationMonths = _editingPost.durationMonths;
      _hobbies = List.from(_editingPost.hobbies);
    }
  }

  Future<Iterable<String>> getCondoSuggestions(String query) async {
    if (query.length < 2) {
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
  int? get durationMonths => _durationMonths;
  bool get isPosting => _isPosting;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  List<String> get hobbies => _hobbies;
  bool get isEditing => _editingPost != null;

  bool get canSubmit =>
      (formKey.currentState?.validate() ?? false) && !_isPosting;

  set description(String value) {
    if (_description != value) {
      _description = value;
      _updateUnsavedChangesFlag();
    }
  }

  set condominiumName(String value) {
    if (_condominiumName != value) {
      _condominiumName = value;
      _updateUnsavedChangesFlag();
    }
  }

  set rent(double value) {
    if (_rent != value) {
      _rent = value;
      _updateUnsavedChangesFlag();
    }
  }

  set roomType(String value) {
    if (_roomType != value) {
      _roomType = value;
      _updateUnsavedChangesFlag(); // Also notify for dropdown changes
    }
  }

  set gender(String value) {
    if (_gender != value) {
      _gender = value;
      _updateUnsavedChangesFlag(); // Also notify for dropdown changes
    }
  }

  set location(String value) {
    if (_location != value) {
      _location = value;
      _updateUnsavedChangesFlag();
    }
  }

  set durationStart(DateTime? value) {
    if (_durationStart != value) {
      _durationStart = value;
      _updateUnsavedChangesFlag();
    }
  }

  set durationMonths(int? value) {
    if (_durationMonths != value) {
      _durationMonths = value;
      _updateUnsavedChangesFlag();
    }
  }

void addHobby(String hobby) {
    final trimmedHobby = hobby.trim().toLowerCase(); 
    if (trimmedHobby.isNotEmpty && !_hobbies.contains(trimmedHobby)) {
      _hobbies.add(trimmedHobby);
      _updateUnsavedChangesFlag();
    }
  }

  void removeHobby(String hobby) {
    final trimmedHobby = hobby.trim().toLowerCase();
    if (_hobbies.contains(trimmedHobby)) {
      _hobbies.remove(trimmedHobby);
      _updateUnsavedChangesFlag();
    }
  }

  void _updateUnsavedChangesFlag() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<bool> submitPost() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    _isPosting = true;
    notifyListeners();

    try {
      pr('breakpoint1');
      // 1. Geocode the location to get coordinates
      await _geocodeLocation(); // This might set _position to null

      pr('breakpoint2');

      // 2. Upload images and get their URLs
      final imageUrls = await uploadFiles(_selectedImages);

      pr('breakpoint3');

      // 3. Create the search key
      final searchKey = _condominiumName.replaceAll(' ', '').toLowerCase();

      pr('breakpoint3');

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
        'position': _position != null
            ? GeoFirePoint(
                GeoPoint(_position!.latitude, _position!.longitude),
              ).data
            : null,
        'durationStart': _durationStart != null
            ? Timestamp.fromDate(_durationStart!)
            : null,
        'durationMonths': _durationMonths != null
            ? durationMonths!
            : null,
        'hobbies': _hobbies,
      };

      pr('post data is null? : ${postData}');

      if (isEditing) {
        if (_editingPost == null) {
          throw Exception(
            "Attempting to update post, but editing post data is null.",
          );
        }
        await _postService.updatePost(
          postId: _editingPost.id, // Safe now due to check above
          data: postData,
        );
        // Pass _editingPost directly, null check already happened
        await _updatePropertyTemplate(_editingPost, imageUrls);
      } else {
        // createPost now correctly receives the full postData map
        final newPostId = await _postService.createPost(postData: postData);
        await _saveAsPropertyTemplate(newPostId, imageUrls);
      }

      _hasUnsavedChanges = false;
      return true;
    } catch (e) {
      pr("Post submission failed: $e");
      return false;
    } finally {
      _isPosting = false;
      notifyListeners();
    }
  }

  Future<void> _saveAsPropertyTemplate(
    String postId,
    List<String> imageUrls,
  ) async {
    try {
      final template = PropertyTemplate(
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
      // Use the imported constant for the box name
      final box = Hive.box<PropertyTemplate>(propertyTemplateBox);
      await box.add(template);
      pr("Successfully saved post as a property template.");
    } catch (e) {
      pr("Failed to save property template: $e");
      // Handle or log error appropriately
    }
  }

  Future<void> _updatePropertyTemplate(
    PostModel editedModel,
    List<String> imageUrls,
  ) async {
    try {
      // Use the imported constant for the box name
      final box = Hive.box<PropertyTemplate>(propertyTemplateBox);
      // Find the key associated with the postId
      final keys = box.keys;
      dynamic
      templateKey; // Use dynamic as key type isn't specified (int or String)
      for (var key in keys) {
        final template = box.get(key);
        if (template?.postId == editedModel.id) {
          templateKey = key;
          break;
        }
      }

      if (templateKey != null) {
        final template = box.get(templateKey);
        if (template != null) {
          // Update fields
          template.name = _condominiumName;
          template.rent = _rent;
          template.location = _location;
          template.description = _description;
          template.roomType = _roomType;
          template.gender = _gender;
          template.photoUrls = imageUrls;
          // template.nationality remains 'Any' or update if available
          await template.save(); // Save the updated template back to Hive
          print(
            "Successfully updated property template with key: $templateKey",
          );
        } else {
          pr(
            "Warning: Template key found but template data is null for key: $templateKey",
          );
          // Optionally handle this case, e.g., by creating a new template
          await _saveAsPropertyTemplate(editedModel.id, imageUrls);
        }
      } else {
        // If no existing template found, create a new one
        pr(
          "No existing template found for postId ${editedModel.id}, creating new.",
        );
        await _saveAsPropertyTemplate(editedModel.id, imageUrls);
      }
    } catch (e) {
      pr("Failed to update or save property template: $e");
    }
  }

  Future<void> _geocodeLocation() async {
    if (_location.isEmpty) {
      _position = null;
      pr('🟡 Geocoding skipped: Location is empty.');
      return;
    }

    // 編集時に location が変更されていない、かつ _position が既に存在するならスキップ
    if (isEditing && _location == _editingPost?.location && _position != null) {
      pr(
        '🟡 Skipping geocoding: Location unchanged and position already exists.',
      );
      return;
    }

    pr('🔍 Attempting to geocode location: "$_location"');

    try {
      if (!(kIsWeb ||
          Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS)) {
        pr('⚪ Geocoding skipped: Unsupported platform (e.g., Windows).');
        _position = null;
        return;
      }

      const apiKey =
          'AIzaSyBSrv_NciH-II4WVLSoAdWVXSAFxHpS9jU';
      final encodedAddress = Uri.encodeComponent(_location);
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        pr('❌ HTTP request failed with status: ${response.statusCode}');
        _position = null;
        return;
      }

      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        _position = GeoPoint(lat, lng);
        pr('✅ Geocoding successful: $_position');
      } else {
        final errorMessage = data['error_message'] ?? 'No results found';
        pr('⚠️ Geocoding failed: ${data['status']} ($errorMessage)');
        _position = null;
      }
    } catch (e, stack) {
      pr('🚨 Exception during geocoding: $e');
      print(stack);
      _position = null;
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        // Add newly picked images. Decide whether to use File or XFile based on platform.
        if (kIsWeb) {
          _selectedImages.addAll(images); // Keep as XFile for web
        } else {
          _selectedImages.addAll(
            images.map((xfile) => File(xfile.path)),
          ); // Convert to File for mobile
        }
        _updateUnsavedChangesFlag();
      }
    } catch (e) {
      pr("Error picking images: $e");
      // Optionally show an error message to the user
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _updateUnsavedChangesFlag();
    }
  }

  Future<List<String>> uploadFiles(List<dynamic> files) async {
    List<String> imageUrls = [];
    int imageIndex = 0; // To create unique file names

    for (var fileOrUrl in files) {
      if (fileOrUrl is String) {
        // It's an existing URL, just add it
        imageUrls.add(fileOrUrl);
      } else if (fileOrUrl is XFile || fileOrUrl is File) {
        // It's a new file to upload
        // Create a unique file name using timestamp and index
        final String fileExtension = fileOrUrl is XFile
            ? (fileOrUrl.mimeType?.split('/').last ??
                  'jpg') // Get extension from mime type for XFile
            : (fileOrUrl.path.split('.').last ??
                  'jpg'); // Get extension from path for File
        final String fileName =
            'posts/${DateTime.now().millisecondsSinceEpoch}_${imageIndex++}.$fileExtension'; // Use original extension initially
        final ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask;

        try {
          if (kIsWeb && fileOrUrl is XFile) {
            final Uint8List data = await fileOrUrl.readAsBytes();
            final mimeType = fileOrUrl.mimeType;
            String contentType = 'image/webp';
            if (mimeType != null &&
                (mimeType == 'image/jpeg' || mimeType == 'image/png')) {
              contentType =
                  mimeType;
            } else if (mimeType != null) {
              contentType = mimeType;
            }
            pr("Uploading to web with Content-Type: $contentType");
            uploadTask = ref.putData(
              data,
              SettableMetadata(contentType: contentType),
            );
          } else if (!kIsWeb && (fileOrUrl is File || fileOrUrl is XFile)) {
            File fileToUpload = (fileOrUrl is File)
                ? fileOrUrl
                : File(fileOrUrl.path);

            try {
              // Attempt compression to WebP only on mobile
              final compressedFile = await compressAndConvertToWebP(
                fileToUpload,
              );
              // Update ref to use .webp extension if compression is successful
              final webpRef = FirebaseStorage.instance.ref().child(
                fileName.replaceAll(RegExp(r'\.\w+$'), '.webp'),
              );
              pr("Uploading compressed WebP to mobile: ${webpRef.fullPath}");
              uploadTask = webpRef.putFile(compressedFile);
            } catch (compressError) {
              pr(
                "Image compression failed, uploading original: $compressError",
              );
              // Fallback to uploading the original file if compression fails
              pr("Uploading original file to mobile: ${ref.fullPath}");
              uploadTask = ref.putFile(fileToUpload);
            }
          } else {
            // Handle cases like Web with File input (shouldn't normally happen with picker)
            pr(
              "Warning: Unsupported file type or platform combination. Skipping upload for: $fileOrUrl",
            );
            continue; // Skip this file
          }

          final snapshot = await uploadTask.whenComplete(() => {});
          final downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
          pr("Upload successful: $downloadUrl");
        } catch (uploadError) {
          pr("Error uploading file ($fileName): $uploadError");
          // Optionally add error handling, like adding a placeholder URL or skipping
        }
      } else {
        pr(
          "Warning: Unknown item type in selectedImages list: ${fileOrUrl.runtimeType}",
        );
      }
    }
    return imageUrls;
  }


  Future<File> compressAndConvertToWebP(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

    pr("Compressing ${file.path} to $targetPath");
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      format: CompressFormat.webp,
    );
    if (result == null) {
      throw Exception("Image compression failed, result is null.");
    }
    pr("Compression successful, output: ${result.path}");
    return File(result.path);
  }

  void clearDraft() {
    _selectedImages = [];
    _description = '';
    _condominiumName = '';
    _rent = 0;
    _location = '';
    _position = null;
    _durationStart = null;
    _durationMonths = null;
    _hasUnsavedChanges = false;
    _hobbies = [];
    notifyListeners();
  }
}
