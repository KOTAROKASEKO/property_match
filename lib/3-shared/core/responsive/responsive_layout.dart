import 'package:flutter/material.dart';
import 'package:shared_data/shared_data.dart';
import '../../agent_main_scaffold.dart';
import 'tablet_scaffold.dart';
import '../../tenant_main_scaffold.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
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