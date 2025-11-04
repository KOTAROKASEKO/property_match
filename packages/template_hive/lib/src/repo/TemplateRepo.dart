import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../models/template_model.dart';
import 'package:shared_data/src/database_path.dart';

class TemplateRepo {
  // ✅ [変更点 1]
  // 状態（userRole）をクラス内に保持しない。
  // final Roles userRole; // <-- 削除

  // ✅ [変更点 2]
  // Box のキャッシュも削除。_getBox() が常に正しいBoxを返すようにする。
  // Box<TemplateModel>? _templateBox; // <-- 削除

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ [変更点 3]
  // シンプルなプライベートコンストラクタ
  TemplateRepo._internal();

  // ✅ [変更点 4]
  // 単一のインスタンスを作成（ロールの情報は持たない）
  static final TemplateRepo _instance = TemplateRepo._internal();

  // ✅ [変更点 5]
  // 正しいファクトリコンストラクタ
  factory TemplateRepo() {
    return _instance;
  }

  // この関数は main.dart のリスナーから呼ばれる（変更なし）
  Future<void> initializeUserDatabases() async {
    try {
      pr('✅ Initializing user databases...');

      // ★★★ 修正 ★★★
      // ボックスを開くときは、必ず「型」を指定する。
      // また、二重に開かないように isBoxOpen でチェックする。

      if (!Hive.isBoxOpen(propertyTemplateBox)) {
        await Hive.openBox<PropertyTemplate>(propertyTemplateBox);
      }
      if (!Hive.isBoxOpen(agentTemplateMessageBoxName)) {
        await Hive.openBox<TemplateModel>(agentTemplateMessageBoxName);
      }
      if (!Hive.isBoxOpen(tenanTemplateMessageBoxName)) {
        await Hive.openBox<TemplateModel>(tenanTemplateMessageBoxName);
      }
      // ★★★ 修正完了 ★★★
      
      pr('✅ All user databases opened successfully.');
    } catch (e) {
      pr('❌ Error opening user databases: $e');
    }
  }
  
  DocumentReference _getDocRef() {
    final userId = userData.userId;
    if (userId.isEmpty) {
      throw Exception("User not logged in, cannot access templates.");
    }

    // ✅ [変更点 6]
    // メンバー変数 `userRole` ではなく、
    // グローバルな `userData.role` から現在のロールを取得
    final collectionName = userData.role == Roles.agent
        ? agentTemplateMessageBoxName
        : tenanTemplateMessageBoxName;

    return _firestore.collection(collectionName).doc(userId);
  }

  // ★ 4. Boxを安全に取得または開くための非同期ヘルパーメソッド
  Future<Box<TemplateModel>> _getBox() async {
    // ✅ [変更点 7]
    // グローバルな `userData.role` から現在のロールを取得

    final boxName = userData.role == Roles.agent
        ? agentTemplateMessageBoxName
        : tenanTemplateMessageBoxName;

    // ✅ [変更点 8]
    // メンバー変数にキャッシュせず、常に正しいBoxを返す
    if (Hive.isBoxOpen(boxName)) {
      pr('[TemplateRepo] _getBox() was called but TemplateRepo: Box "$boxName" is already open. skip opening the box');
      return Hive.box<TemplateModel>(boxName);
    } else {
      pr('[TemplateRepo] getBox() was called but the TemplateRepo: Box "$boxName" was not open. Awaiting openBox...');
      return await Hive.openBox<TemplateModel>(boxName);
    }
  }

  Future<List<String>> getTemplates() async {
    // ★ 5. 安全なヘルパーを経由してBoxを取得
    final box = await _getBox();

    if (box.isNotEmpty) {
      pr('templateRepo.dart/ template box is not empty');
      return box.values.map((e) => e.templateMessage).toList();
    }

    try {
      final doc = await _getDocRef().get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final templatesFromFs = List<String>.from(data['templates'] ?? []);
        if (templatesFromFs.isNotEmpty) {
          await _saveTemplatesToHive(templatesFromFs);
          return templatesFromFs;
        }
      }
    } catch (e) {
      pr("Error fetching templates from Firestore: $e");
    }

    // ✅ [変更点 9]
    // グローバルな `userData.role` から現在のロールを取得
    final defaultTemplates = userData.role == Roles.agent
        ? [
            // Default for agent
            'Hello! Thank you for your inquiry about the property. Would you like to schedule a viewing?',
            'Yes, the property is still available. If you have any questions, please feel free to ask.',
            'Thank you for your inquiry. I will get back to you after confirming the details.',
          ]
        : [
            // Default for tenant
            '''Hello, I am interested in this property.
  Name: 
  Occupation: 
  Age: 
  Nationality:''',
            'Is this property still available for viewing?',
            'What furniture and appliances are included?',
            'Could you please provide more details about the contract terms?',
          ];
    await saveTemplates(defaultTemplates);
    return defaultTemplates;
  }

  Future<void> _saveTemplatesToHive(List<String> templates) async {
    // ★ 6. 安全なヘルパーを経由してBoxを取得
    final box = await _getBox();
    await box.clear();
    for (int i = 0; i < templates.length; i++) {
      box.add(TemplateModel(id: i, templateMessage: templates[i]));
    }
  }

  Future<void> saveTemplates(List<String> templates) async {
    await _saveTemplatesToHive(templates);
    try {
      await _getDocRef().set({'templates': templates});
    } catch (e) {
      print("Error saving templates to Firestore: $e");
    }
  }
}