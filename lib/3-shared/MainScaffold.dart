// lib/MainScaffold.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_data/shared_data.dart';
import 'package:shared_data/src/database_path.dart';
import 'package:template_hive/template_hive.dart';
import 'agent_main_scaffold.dart';
import 'tenant_main_scaffold.dart';

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
    print('Opening Hive boxes for MainScaffold...');
    if (!Hive.isBoxOpen(tenanTemplateMessageBoxName)) {
      await Hive.openBox<TemplateModel>(tenanTemplateMessageBoxName);
      print('✅ Tenant message template box opened.');
    }
    if (!Hive.isBoxOpen(agentTemplateMessageBoxName)) {
      await Hive.openBox<TemplateModel>(agentTemplateMessageBoxName);
      print('✅ Agent message template box opened.');
    }
    if (!Hive.isBoxOpen(propertyTemplateBox)) {
      await Hive.openBox<PropertyTemplate>(propertyTemplateBox);
      print('✅ Property template box opened.');
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
        print('Current role is ${userData.role}. isAgent is: $isAgent');

        if (isAgent) {
          return const AgentMainScaffold();
        } else {
          return const TenantMainScaffold();
        }
      },
    );
  }
}