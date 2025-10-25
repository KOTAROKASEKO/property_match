// lib/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';

//Used by tenant and agent
class MessagetemplateViewmodel extends ChangeNotifier {
  late TemplateRepo _templateRepo;
  List<String> _templates = [];
  bool _isLoading = false;

  List<String> get templates => _templates;
  bool get isLoading => _isLoading;

  MessagetemplateViewmodel({required Roles userRole}) {
    _templateRepo = TemplateRepo(userRole: userRole);
  }

  Future<void> loadTemplates() async {
    //add logic to hanle when the box is not opened
    _isLoading = true;
    notifyListeners();
    _templates = await _templateRepo.getTemplates();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTemplate(int index, String newMessage) async {
    if (index < 0 || index >= _templates.length) return;
    _templates[index] = newMessage;
    await _templateRepo.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> addTemplate(String newMessage) async {
    _templates.add(newMessage);
    await _templateRepo.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    if (index < 0 || index >= _templates.length) return;
    _templates.removeAt(index);
    await _templateRepo.saveTemplates(_templates);
    notifyListeners();
  }
}