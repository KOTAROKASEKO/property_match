import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/model/property_template.dart';

class AgentTemplateViewModel extends ChangeNotifier {
  final Box<PropertyTemplate> _propertyTemplateBox =
      Hive.box<PropertyTemplate>('propertyTemplateBox');

  List<PropertyTemplate> _templates = [];
  bool _isLoading = false;

  List<PropertyTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  AgentTemplateViewModel() {
    _loadTemplates();
    // ★★★ Hiveボックスの変更を監視するリスナーを追加 ★★★
    _propertyTemplateBox.listenable().addListener(_loadTemplates);
  }

  // loadTemplatesをプライベートメソッドに変更
  void _loadTemplates() {
    _templates = _propertyTemplateBox.values.toList().cast<PropertyTemplate>();
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    if (index < 0 || index >= _templates.length) return;
    final keyToDelete = _propertyTemplateBox.keyAt(index);
    await _propertyTemplateBox.delete(keyToDelete);
    // リスナーが自動でリストを更新します
  }

  @override
  void dispose() {
    // ★★★ ViewModel破棄時にリスナーを解除 ★★★
    _propertyTemplateBox.listenable().removeListener(_loadTemplates);
    super.dispose();
  }
}