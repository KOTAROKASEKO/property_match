import 'package:go_router/go_router.dart';
import 'package:re_conver/3-shared/common_feature/chat/view/chatThreadScreen.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/1_profile/view/agent_profile_view.dart';
import 'package:re_conver/3-shared/features/1_agent_feature/2_tenant_list/view/tenant_list_view.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/discover_screen.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/3_profile/view/profile_screen.dart';
import 'package:re_conver/3-shared/features/authentication/login_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/authentication/role_selection_screen.dart';


final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPlaceholderScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'chat_thread',
          builder: (BuildContext context, GoRouterState state) {
            return const ChatThreadsScreen();
          },
        ),GoRoute(
          path: 'role_selection',
          builder: (BuildContext context, GoRouterState state) {
            return const RoleSelectionScreen();
          },
        ),
        GoRoute(
          path: 'discover',
          builder: (BuildContext context, GoRouterState state) {
            return const DiscoverScreen();
          },
        ),
        GoRoute(
          path: 'tenant_profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: 'tenant_list',
          builder: (BuildContext context, GoRouterState state) {
            return const TenantListView();
          },
        ),
        GoRoute(
          path: 'agent_profile',
          builder: (BuildContext context, GoRouterState state) {
            return MyProfilePage();
          },
        ),
      ],
    ),
  ],
);