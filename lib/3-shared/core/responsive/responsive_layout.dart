import 'package:flutter/material.dart';
import '../../agent_main_scaffold.dart';
import 'tablet_scaffold.dart';
import '../../features/authentication/userdata.dart';
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