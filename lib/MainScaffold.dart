import 'package:flutter/material.dart';
import 'package:re_conver/agent_main_scaffold.dart';
import 'package:re_conver/features/authentication/userdata.dart';
import 'package:re_conver/tenant_main_scaffold.dart';
import 'package:re_conver/app/debug_print.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isAgent = userData.role == Roles.agent;
    pr('Current role is ${userData.role}. isAgent is: $isAgent');

    if (isAgent) {
      return const AgentMainScaffold();
    } else {
      return const TenantMainScaffold();
    }
  }
}