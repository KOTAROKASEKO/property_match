// lib/2_tenant_feature/4_chat/repo/TemplateRepo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/template_model.dart';
import 'package:re_conver/authentication/userdata.dart';

class TemplateRepo {
  final Box<TemplateModel> _templateBox = Hive.box<TemplateModel>('templateBox');
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  DocumentReference _getDocRef() {
    final userId = userData.userId;
    if (userId.isEmpty) {
      throw Exception("User not logged in, cannot access templates.");
    }
    return _instance.collection('message_templates').doc(userId);
  }

  Future<List<String>> getTemplates() async {
    // 1. Try to get from Hive
    if (_templateBox.isNotEmpty) {
      return _templateBox.values.map((e) => e.templateMessage).toList();
    }

    // 2. If Hive is empty, get from Firestore
    try {
      final doc = await _getDocRef().get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final templatesFromFs = List<String>.from(data['templates'] ?? []);
        if (templatesFromFs.isNotEmpty) {
          // Save to Hive and return
          await _saveTemplatesToHive(templatesFromFs);
          return templatesFromFs;
        }
      }
    } catch (e) {
      print("Error fetching templates from Firestore: $e");
    }

    // 3. If Firestore is also empty or fails, return and save a default list
    final defaultTemplates = [
      '''Hi, I'm interested in your property.
Name: 
Occupation: 
Age: 
Nationality:''',
      'Is this property still available for viewing?',
      'What are the included amenities?',
      'Could you please provide more details about the lease terms?',
    ];
    await saveTemplates(defaultTemplates); // Save to both Hive and Firestore
    return defaultTemplates;
  }

  Future<void> _saveTemplatesToHive(List<String> templates) async {
    await _templateBox.clear();
    for (int i = 0; i < templates.length; i++) {
      _templateBox.add(TemplateModel(id: i, templateMessage: templates[i]));
    }
  }

  Future<void> saveTemplates(List<String> templates) async {
    // Save to Hive
    await _saveTemplatesToHive(templates);
    // Save to Firestore
    try {
      await _getDocRef().set({'templates': templates});
    } catch (e) {
      print("Error saving templates to Firestore: $e");
    }
  }
}