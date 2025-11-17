// lib/3-shared/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../1_profile/repo/profile_repository.dart';

class AgentTemplateViewModel extends ChangeNotifier {
  // ★ 1. BoxをNull許容に変更し、コンストラクタでの初期化を削除
  Box<PropertyTemplate>? _propertyTemplateBox;
  final ProfileRepository _profileRepository = FirestoreProfileRepository();

  List<PropertyTemplate> _templates = [];
  bool _isLoading = false;

  List<PropertyTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  AgentTemplateViewModel() {
    // ★ 2. 非同期の初期化メソッドを呼び出す
    _initializeAndLoad();
  }

  // ★ 3. Boxの初期化とリスナー設定、初回ロードを行う非同期メソッド
  Future<void> _initializeAndLoad() async {
    // まずBoxを安全に開く（または取得する）
    await _safeOpenBox();
    
    // Boxが開かれたことを確認してからリスナーをセット
    // （Boxがnullでなく、かつ開いていることを確認）
    if (_propertyTemplateBox != null && _propertyTemplateBox!.isOpen) {
      _propertyTemplateBox!.listenable().addListener(_loadTemplates);
    } else {
      pr('❌ [AgentTemplateViewModel] Box is not open. Listener not attached.');
    }
    
    // テンプレートをロード
    _loadTemplates();
  }

  // ★ 4. Boxを安全に開くためのヘルパーメソッド (MessagetemplateViewmodelと同様)
  Future<void> _safeOpenBox() async {
    // 既に開いていてインスタンスがあれば何もしない
    if (_propertyTemplateBox != null && _propertyTemplateBox!.isOpen) {
      return;
    }
    
    try {
      if (!Hive.isBoxOpen(propertyTemplateBox)) {
        pr('[AgentTemplateViewModel] Box "$propertyTemplateBox" is not open. Opening...');
        _propertyTemplateBox = await Hive.openBox<PropertyTemplate>(propertyTemplateBox);
      } else {
        pr('[AgentTemplateViewModel] Box "$propertyTemplateBox" was open. Getting instance.');
        _propertyTemplateBox = Hive.box<PropertyTemplate>(propertyTemplateBox);
      }
    } catch (e) {
      pr('❌ [AgentTemplateViewModel] Failed to open box: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. _loadTemplates を更新し、Boxがnullでないことを確認
  void _loadTemplates() async {
    // Boxが初期化されていないか、開いていない場合は安全に開くのを試みる
    if (_propertyTemplateBox == null || !_propertyTemplateBox!.isOpen) {
      pr('[AgentTemplateViewModel] _loadTemplates called, but box is not ready. Awaiting _safeOpenBox...');
      await _safeOpenBox();
      // それでもBoxがnull（エラー）なら、ここで停止
      if (_propertyTemplateBox == null) {
         pr('❌ [AgentTemplateViewModel] _loadTemplates failed, box could not be opened.');
         _isLoading = false; // ★ ローディングを停止
         notifyListeners(); // ★ UIに通知
        return;
      }
    }

    _templates = _propertyTemplateBox!.values.toList().cast<PropertyTemplate>();
    
    if (_templates.isEmpty) {
      _isLoading = true;
      notifyListeners();
      try {
        // ★ ユーザーIDが空の場合はFirestoreから取得しない
        if (userData.userId.isEmpty) {
          pr('[AgentTemplateViewModel] User is logged out. Skipping template restore from Firestore.');
          _isLoading = false;
          notifyListeners();
          return;
        }

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
            // ★ 6. _propertyTemplateBox! を使用
            await _propertyTemplateBox!.add(template);
          }
        }
        
        _templates = _propertyTemplateBox!.values.toList().cast<PropertyTemplate>();

      } catch (e) {
        print("Error fetching posts to restore templates: $e");
      } finally {
        _isLoading = false;
      }
    }
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    // ★ 7. 安全チェック
    if (_propertyTemplateBox == null) return;
    if (index < 0 || index >= _templates.length) return;
    final keyToDelete = _propertyTemplateBox!.keyAt(index);
    await _propertyTemplateBox!.delete(keyToDelete);
  }

  @override
  void dispose() {
    // ★ 8. リスナーを安全に解除
    _propertyTemplateBox?.listenable().removeListener(_loadTemplates);
    super.dispose();
  }
}