// lib/2_tenant_feature/4_chat/repo/TemplateRepo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:re_conver/2_tenant_feature/4_chat/model/template_model.dart';
import 'package:re_conver/authentication/userdata.dart';

class TemplateRepo {
  final Roles userRole;
  late final Box<TemplateModel> _templateBox;
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  // コンストラクタでユーザーの役割を受け取り、Box名を決定する
  TemplateRepo({required this.userRole}) {
    final boxName = userRole == Roles.agent ? 'agentMessageTemplates' : 'tenantMessageTemplates';
    _templateBox = Hive.box<TemplateModel>(boxName);
  }

  // 役割に応じてFirestoreのコレクション名を変更
  DocumentReference _getDocRef() {
    final userId = userData.userId;
    if (userId.isEmpty) {
      throw Exception("User not logged in, cannot access templates.");
    }
    final collectionName = userRole == Roles.agent ? 'agent_message_templates' : 'tenant_message_templates';
    return _instance.collection(collectionName).doc(userId);
  }

  Future<List<String>> getTemplates() async {
    if (_templateBox.isNotEmpty) {
      return _templateBox.values.map((e) => e.templateMessage).toList();
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
      print("Error fetching templates from Firestore: $e");
    }

    final defaultTemplates = userRole == Roles.agent
      ? [ // Default for agent
        'Hello! Thank you for your inquiry about the property. Would you like to schedule a viewing?',
        'Yes, the property is still available. If you have any questions, please feel free to ask.',
        'Thank you for your inquiry. I will get back to you after confirming the details.',
        ]
      : [ // Default for tenant
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
    await _templateBox.clear();
    for (int i = 0; i < templates.length; i++) {
      _templateBox.add(TemplateModel(id: i, templateMessage: templates[i]));
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