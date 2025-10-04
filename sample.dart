// lib/1_agent_feature/2_profile/viewmodel/create_post_viewmodel.dart

Future<bool> submitPost() async {
  if (!formKey.currentState!.validate() || !canSubmit) {
    return false;
  }

  _isPosting = true;
  notifyListeners();

  try {
    List<String> imageUrls = [];
    if (_selectedImages.isNotEmpty) {
      // Upload images and get their download URLs
      imageUrls = await uploadFiles(_selectedImages);
    }

    // Create the new post document in Firestore
    await _postService.createPost(
      description: _description,
      imageUrls: imageUrls,
      condominiumName: _condominiumName,
      rent: _rent,
      roomType: _roomType,
      gender: _gender,
      manualTags: [],
    );

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