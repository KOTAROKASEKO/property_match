import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/model/PostModel.dart';
import '../repo/profile_repository.dart';
import 'agent_create_post_screen.dart';
import 'edit_agent_profile_view.dart';
import '../viewmodel/agent_profile_viewmodel.dart';
import '../../../authentication/auth_service.dart';
import '../../../authentication/login_placeholder.dart';
import '../../../authentication/userdata.dart';
import '../../../notifications/view/notification_screen.dart';
import '../../../notifications/viewmodel/notification_viewmodel.dart';

import 'post_details_card.dart';

class MyProfilePage extends StatelessWidget {

  MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(FirestoreProfileRepository())
        ..fetchAgentData(userData.userId),
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Log out'),
                onTap: () async {
                  Navigator.pop(context);
                  await showSignOutModal(context);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const LoginPlaceholderScreen(),
                  ));
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
           actions: [ // ★ actions プロパティを追加
            Consumer<NotificationViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: Badge(
                    label: Text(viewModel.unreadCount.toString()),
                    isLabelVisible: viewModel.unreadCount > 0,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: const NotificationsScreen(),
                      ),
                    ));
                  },
                );
              },
            ),
          ],
          title: const Text('My Profile',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.agentProfile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.errorMessage != null &&
                viewModel.agentProfile == null) {
              return Center(child: Text(viewModel.errorMessage!));
            }
            if (viewModel.agentProfile == null) {
              return const Center(child: Text("Profile not found."));
            }
            return RefreshIndicator(
              onRefresh: () => viewModel.fetchAgentData(userData.userId),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _ProfileHeader(viewModel: viewModel)),
                  SliverToBoxAdapter(child: _ActionButtons()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'My Listings (${viewModel.posts.length})',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _PostList(posts: viewModel.posts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- UI Helper Widgets ---

class _ProfileHeader extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _ProfileHeader({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            // ViewModelから実際の画像URLを取得
             backgroundImage: viewModel.agentProfileImageUrl.isNotEmpty
                ? CachedNetworkImageProvider(viewModel.agentProfileImageUrl) // ★★★ 変更 ★★★
                : null,
            backgroundColor: Colors.grey[200],
            child: viewModel.agentProfileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            // ViewModelから実際の名前を取得
            viewModel.agentName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            // ViewModelから実際のBioを取得
            viewModel.agentBio,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(count: viewModel.totalListings, label: 'Listings'),
              _StatItem(count: viewModel.totalLikes, label: 'Total Likes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined),
              onPressed: viewModel.agentProfile == null
                  ? null
                  : () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAgentProfileScreen(
                                agentProfile: viewModel.agentProfile!,
                              )),
                      );
                      if (result == true) {
                        context
                            .read<ProfileViewModel>()
                            .fetchAgentData(viewModel.agentProfile!.uid);
                      }
                    },
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
              label: const Text('Add Listing'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final List<PostModel> posts;
  const _PostList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              "You haven't posted any listings yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = posts[index];
          return PostDetailsCard(
            post: post,
            onDelete: () {
              context.read<ProfileViewModel>().deletePost(post.id);
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostScreen(post: post),
                ),
              );
            },
          );
        },
        childCount: posts.length,
      ),
    );
  }
}