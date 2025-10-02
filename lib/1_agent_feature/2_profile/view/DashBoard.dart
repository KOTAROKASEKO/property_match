import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';
import 'package:re_conver/1_agent_feature/2_profile/view/create_post_screen.dart';
import 'package:re_conver/1_agent_feature/2_profile/view/edit_agent_profile_view.dart';
import 'package:re_conver/1_agent_feature/2_profile/viewmodel/profile_viewmodel.dart';
import 'package:re_conver/Common_model/PostModel.dart';
import 'package:re_conver/authentication/auth_service.dart';
import 'package:re_conver/authentication/login_placeholder.dart';

import 'post_details_card.dart';

class MyProfilePage extends StatelessWidget {
  // 本来は認証情報から取得するユーザーID
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ??
      "VRcmznTkWNTTrxxOvRBFA6jVCPvn2"; // Fallback for testing

  MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ViewModelにRepositoryのインスタンスを渡す
      create: (_) => ProfileViewModel(FirestoreProfileRepository())
        ..fetchAgentData(currentUserId), // ViewModel作成時にデータを取得
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
          title: const Text('My Profile',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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
              onRefresh: () => viewModel.fetchAgentData(currentUserId),
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
                ? NetworkImage(viewModel.agentProfileImageUrl)
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
              _StatItem(count: 12, label: 'Clients'), // Dummy data
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
    // listen: true にして、プロフィール更新後にUIが再描画されるようにする
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
                      // 編集画面から戻ってきたときにリフレッシュする可能性があるため、結果を受け取る
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditAgentProfileScreen(
                                  // ViewModelが持つAgentProfileを渡す
                                  agentProfile: viewModel.agentProfile!,
                                )),
                      );
                      //もし更新があれば再フェッチ (更新成功時に true を返すようにEditAgentProfileScreenを修正)
                      if (result == true) {
                        // ViewModelのメソッドを直接呼ぶのではなく、Provider経由でアクセス
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
              label: const Text('New Post'),
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