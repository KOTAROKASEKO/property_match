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
import 'package:mime/mime.dart'; 

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
  int? _durationMonths;
  bool _isPosting = false;
  bool _hasUnsavedChanges = false;
  double _securityDeposit = 2.0; 
  double _utilityDeposit = 0.5;

  // ★ Added: List to hold manual tags
  List<String> _manualTags = [];

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
      _securityDeposit = _editingPost.securityDeposit;
      _utilityDeposit = _editingPost.utilityDeposit;
      
      // ★ Added: Load existing manual tags when editing
      _manualTags = List.from(_editingPost.manualTags);

      if (_editingPost.position != null) {
        _position = GeoPoint(_editingPost.position!.latitude,_editingPost.position!.longitude); 
      }
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
  bool get isEditing => _editingPost != null;
  double get securityDeposit => _securityDeposit;
  double get utilityDeposit => _utilityDeposit;
  
  // ★ Added: Getter for manual tags
  List<String> get manualTags => _manualTags;

  bool get canSubmit =>
      (formKey.currentState?.validate() ?? false) && !_isPosting;

  
  set securityDeposit(double value) {
    if (_securityDeposit != value) {
      _securityDeposit = value;
      _updateUnsavedChangesFlag();
    }
  }
  
  set utilityDeposit(double value) {
    if (_utilityDeposit != value) {
      _utilityDeposit = value;
      _updateUnsavedChangesFlag();
    }
  }

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
      _updateUnsavedChangesFlag(); 
    }
  }

  set gender(String value) {
    if (_gender != value) {
      _gender = value;
      _updateUnsavedChangesFlag(); 
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

  // ★ Added: Methods to add/remove tags
  void addTag(String tag) {
    if (tag.trim().isNotEmpty && !_manualTags.contains(tag.trim())) {
      _manualTags.add(tag.trim());
      _updateUnsavedChangesFlag();
    }
  }

  void removeTag(String tag) {
    _manualTags.remove(tag);
    _updateUnsavedChangesFlag();
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
      pr('breakpoint1: Geocoding location...');
      await _geocodeLocation(); 

      pr('breakpoint2: Creating search key...');
      final searchKey = _condominiumName.replaceAll(' ', '').toLowerCase();

      final postData = {
        'securityDeposit': _securityDeposit,
        'utilityDeposit': _utilityDeposit,
        'description': _description,
        'imageUrls': _editingPost?.imageUrls ?? [], 
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
        'durationMonths': _durationMonths != null ? durationMonths! : null,
        
        // ★ Added: Include manualTags in the post data
        'manualTags': _manualTags,
      };

      String postId;

      if (isEditing) {
        if (_editingPost == null) {
          throw Exception("Editing post data is null.");
        }
        postId = _editingPost.id;
        pr('breakpoint3 (Edit): Updating post document $postId...');
        await _postService.updatePost(
          postId: postId,
          data: postData,
        );
      } else {
        pr('breakpoint3 (New): Creating new post document...');
        postId = await _postService.createPost(postData: postData);
        pr('breakpoint4 (New): Created post with ID: $postId');
      }

      pr('breakpoint5: Uploading images for post ID: $postId...');
      final imageUrls = await uploadFiles(_selectedImages, postId); 

      pr('breakpoint6: Updating post $postId with new image URLs...');
      await _postService.updatePost(
        postId: postId,
        data: {'imageUrls': imageUrls}, 
      );

      if (isEditing) {
        await _updatePropertyTemplate(_editingPost!, imageUrls);
      } else {
        await _saveAsPropertyTemplate(postId, imageUrls);
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
      final box = Hive.box<PropertyTemplate>(propertyTemplateBox);
      await box.add(template);
      pr("Successfully saved post as a property template.");
    } catch (e) {
      pr("Failed to save property template: $e");
    }
  }

  Future<void> _updatePropertyTemplate(
    PostModel editedModel,
    List<String> imageUrls,
  ) async {
    try {
      final box = Hive.box<PropertyTemplate>(propertyTemplateBox);
      final keys = box.keys;
      dynamic templateKey;
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
          template.name = _condominiumName;
          template.rent = _rent;
          template.location = _location;
          template.description = _description;
          template.roomType = _roomType;
          template.gender = _gender;
          template.photoUrls = imageUrls;
          await template.save();
          print(
            "Successfully updated property template with key: $templateKey",
          );
        } else {
          pr(
            "Warning: Template key found but template data is null for key: $templateKey",
          );
          await _saveAsPropertyTemplate(editedModel.id, imageUrls);
        }
      } else {
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
      const String apiKey = String.fromEnvironment('GEO_CODE_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('GEO_CODE_API_KEY not found in environment variables');
      }
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
        if (kIsWeb) {
          _selectedImages.addAll(images);
        } else {
          _selectedImages.addAll(
            images.map((xfile) => File(xfile.path)),
          );
        }
        _updateUnsavedChangesFlag();
      }
    } catch (e) {
      pr("Error picking images: $e");
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _updateUnsavedChangesFlag();
    }
  }


  Future<List<String>> uploadFiles(List<dynamic> files, String postId) async {
    List<String> imageUrls = [];
    int imageIndex = 0;

    for (var fileOrUrl in files) {
      if (fileOrUrl is String) {
        imageUrls.add(fileOrUrl);
      } else if (fileOrUrl is XFile || fileOrUrl is File) {
        
        final String fileExtension = fileOrUrl is XFile
            ? (fileOrUrl.mimeType?.split('/').last ?? 'jpg')
            : (fileOrUrl.path.split('.').last ?? 'jpg');
        
        final String fileName =
            'posts/$postId/image_${imageIndex++}.$fileExtension'; 
            
        final ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask;

        try {
          if (kIsWeb && fileOrUrl is XFile) {
            final Uint8List data = await fileOrUrl.readAsBytes();
            final mimeType = fileOrUrl.mimeType;
            String contentType = 'image/webp';
            if (mimeType != null &&
                (mimeType == 'image/jpeg' || mimeType == 'image/png')) {
              contentType = mimeType;
            } else if (mimeType != null) {
              contentType = mimeType;
            }
            pr("Uploading to web with Content-Type: $contentType (Path: $fileName)");
            uploadTask = ref.putData(
              data,
              SettableMetadata(contentType: contentType),
            );
          } else if (!kIsWeb && (fileOrUrl is File || fileOrUrl is XFile)) {
            File fileToUpload = (fileOrUrl is File)
                ? fileOrUrl
                : File(fileOrUrl.path);
                
            final String? mimeType = lookupMimeType(fileToUpload.path);
            final contentType = mimeType ?? 'image/jpeg';
            pr("Uploading from mobile with Content-Type: $contentType (Path: $fileName)");

            try {
              final compressedFile = await compressAndConvertToWebP(
                fileToUpload,
              );
              final webpRef = FirebaseStorage.instance.ref().child(
                fileName.replaceAll(RegExp(r'\.\w+$'), '.webp'),
              );
              pr("Uploading compressed WebP to mobile: ${webpRef.fullPath}");
              uploadTask = webpRef.putFile(
                compressedFile,
                SettableMetadata(contentType: 'image/webp'),
              );
            } catch (compressError) {
              pr(
                "Image compression failed, uploading original: $compressError",
              );
              pr("Uploading original file to mobile: ${ref.fullPath}");
              uploadTask = ref.putFile(
                fileToUpload,
                SettableMetadata(contentType: contentType),
              );
            }
          } else {
            pr(
              "Warning: Unsupported file type or platform combination. Skipping upload for: $fileOrUrl",
            );
            continue;
          }

          final snapshot = await uploadTask.whenComplete(() => {});
          final downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
          pr("Upload successful: $downloadUrl");
        } catch (uploadError) {
          pr("Error uploading file ($fileName): $uploadError");
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
    _manualTags = []; // Clear tags
    notifyListeners();
  }
}