import 'package:flutter/material.dart';
import 'package:re_conver/agent_main_scaffold.dart';
import 'package:re_conver/responsive/tablet_scaffold.dart';
import 'package:re_conver/tenant_main_scaffold.dart';
import 'package:re_conver/authentication/userdata.dart';

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