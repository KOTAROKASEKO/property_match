import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import '../../agent_main_scaffold.dart';
import 'tablet_scaffold.dart';
import '../../tenant_main_scaffold.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    pr('responsive layout was called');
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          pr('responseive_layout.dart : tablet scaffold was called');
          return const TabletScaffold();
        } else {
          if (userData.role == Roles.agent) {
            return const AgentMainScaffold();
          } else {
            return const TenantMainScaffold();
          }
        }
      },
    );
  }
}