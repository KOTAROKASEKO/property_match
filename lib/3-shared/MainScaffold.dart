// lib/MainScaffold.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'agent_main_scaffold.dart';
import 'app/database_path.dart';
import 'common_feature/chat/model/template_model.dart';
import 'features/1_agent_feature/chat_template/model/property_template.dart';
import 'features/authentication/userdata.dart';
import 'tenant_main_scaffold.dart';
import 'app/debug_print.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _openBoxes();
  }

  Future<void> _openBoxes() async {
    pr('Opening Hive boxes for MainScaffold...');
    if (!Hive.isBoxOpen(tenanTemplateMessageBoxName)) {
      await Hive.openBox<TemplateModel>(tenanTemplateMessageBoxName);
      pr('✅ Tenant message template box opened.');
    }
    if (!Hive.isBoxOpen(agentTemplateMessageBoxName)) {
      await Hive.openBox<TemplateModel>(agentTemplateMessageBoxName);
      pr('✅ Agent message template box opened.');
    }
    if (!Hive.isBoxOpen(propertyTemplateBox)) {
      await Hive.openBox<PropertyTemplate>(propertyTemplateBox);
      pr('✅ Property template box opened.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing app: ${snapshot.error}'),
            ),
          );
        }

        final bool isAgent = userData.role == Roles.agent;
        pr('Current role is ${userData.role}. isAgent is: $isAgent');

        if (isAgent) {
          return const AgentMainScaffold();
        } else {
          return const TenantMainScaffold();
        }
      },
    );
  }
}