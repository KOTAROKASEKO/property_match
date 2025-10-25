import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../1_profile/repo/profile_repository.dart';

class AgentTemplateViewModel extends ChangeNotifier {
  final Box<PropertyTemplate> _propertyTemplateBox =
      Hive.box<PropertyTemplate>('propertyTemplateBox');
  final ProfileRepository _profileRepository = FirestoreProfileRepository();

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
  void _loadTemplates() async {
    // まずHiveから読み込む
    _templates = _propertyTemplateBox.values.toList().cast<PropertyTemplate>();
    
    // もしHiveが空だったら、Firestoreから復元を試みる
    if (_templates.isEmpty) {
      _isLoading = true;
      notifyListeners();
      try {
        final posts = await _profileRepository.fetchAgentPosts(userData.userId);
        
        final newTemplates = posts.map((post) => PropertyTemplate(
              postId: post.id,
              name: post.condominiumName,
              rent: post.rent,
              location: post.location,
              description: post.description,
              roomType: post.roomType,
              gender: post.gender,
              photoUrls: post.imageUrls,
              nationality: 'Any',
            )).toList();

        for (var template in newTemplates) {
          if (!_templates.any((t) => t.postId == template.postId)) {
            await _propertyTemplateBox.add(template);
          }
        }
        
        _templates = _propertyTemplateBox.values.toList().cast<PropertyTemplate>();

      } catch (e) {
        print("Error fetching posts to restore templates: $e");
      } finally {
        _isLoading = false;
      }
    }
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