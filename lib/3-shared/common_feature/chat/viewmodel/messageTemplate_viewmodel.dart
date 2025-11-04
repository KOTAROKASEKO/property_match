// lib/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ★ Hive をインポート
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';

//Used by tenant and agent
class MessagetemplateViewmodel extends ChangeNotifier {
  // late TemplateRepo _templateRepo; // ★ 変更
  TemplateRepo? _templateRepo; // ★ 1. Null許容に変更
  final Roles _userRole; // ★ 2. ロールを保持する変数
  List<String> _templates = [];
  bool _isLoading = false;

  List<String> get templates => _templates;
  bool get isLoading => _isLoading;

  MessagetemplateViewmodel({required Roles userRole})
      : _userRole = userRole; // ★ 3. コンストラクタではロールを保存するだけ

  // ★ 4. Repoを安全に初期化する非同期メソッドを追加
  Future<void> _initializeRepo() async {
    if (_templateRepo != null) return; // 既に初期化済み

    try {
      final boxName = _userRole == Roles.agent
          ? agentTemplateMessageBoxName
          : tenanTemplateMessageBoxName;

      // ★ 5. ご提案の「Boxが開いているか」チェック
      if (!Hive.isBoxOpen(boxName)) {
        print(
            'Warning: Hive box "$boxName" was closed or not found. Re-opening...');
        await Hive.openBox<TemplateModel>(boxName);
        print('✅ Hive box "$boxName" re-opened.');
      }

      // Boxが安全に開かれたことを確認してからRepoを作成
      _templateRepo = TemplateRepo();
    } catch (e) {
      print("Error initializing TemplateRepo: $e");
      // エラーが発生した場合、ローディングを停止
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTemplates() async {
    _isLoading = true;
    notifyListeners();

    // ★ 6. テンプレートをロードする前に、まずRepoを初期化する
    await _initializeRepo();
    if (_templateRepo == null) {
      pr("Failed to load templates: Repo not initialized due to error.");
      _isLoading = false;
      notifyListeners();
      return;
    }
    _templates = await _templateRepo!.getTemplates();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTemplate(int index, String newMessage) async {
    if (_templateRepo == null) return; // ★ 7. 安全チェック
    if (index < 0 || index >= _templates.length) return;
    _templates[index] = newMessage;
    await _templateRepo!.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> addTemplate(String newMessage) async {
    if (_templateRepo == null) return; // ★ 7. 安全チェック
    _templates.add(newMessage);
    await _templateRepo!.saveTemplates(_templates);
    notifyListeners();
  }

  Future<void> deleteTemplate(int index) async {
    if (_templateRepo == null) return; // ★ 7. 安全チェック
    if (index < 0 || index >= _templates.length) return;
    _templates.removeAt(index);
    await _templateRepo!.saveTemplates(_templates);
    notifyListeners();
  }
}