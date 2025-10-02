import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:re_conver/1_agent_feature/chat_template/property_template.dart';

class AgentTemplateViewModel extends ChangeNotifier {
  final Box<PropertyTemplate> _propertyTemplateBox = Hive.box<PropertyTemplate>('propertyTemplateBox');
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<PropertyTemplate> _templates = [];
  List<File> _selectedImages = [];
  bool _isLoading = false;

  List<PropertyTemplate> get templates => _templates;
  List<File> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading;

  AgentTemplateViewModel() {
    loadTemplates();
  }

  void loadTemplates() {
    _templates = _propertyTemplateBox.values.toList();
    notifyListeners();
  }

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }
  
  void clearSelection(){
    _selectedImages.clear();
    notifyListeners();
  }

    Future<void> saveTemplate(PropertyTemplate template) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedImages.isNotEmpty) {
        final imageUrls = await _uploadImages(_selectedImages);
        template.photoUrls = imageUrls;
      }
      
      await _propertyTemplateBox.add(template);
      clearSelection(); // Clear the selected images
      loadTemplates(); // Reload the templates to update the UI

    } catch (e) {
      print("Error saving template: $e");
      // TODO: Notify the user of the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteTemplate(int index) async {
     if (index < 0 || index >= _templates.length) return;
    final templateToDelete = _templates[index];
    await templateToDelete.delete();
    loadTemplates();
  }


  Future<List<String>> _uploadImages(List<File> files) async {
    List<String> imageUrls = [];
    for (var file in files) {
      final fileName = 'property_templates/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }
}