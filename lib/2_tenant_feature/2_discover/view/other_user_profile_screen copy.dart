// features/3_discover/view/other_user_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/post_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/model/user_profile_model.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/post_card.dart';
import 'package:re_conver/2_tenant_feature/2_discover/viewmodel/discover_viewmodel.dart';
import 'package:re_conver/2_tenant_feature/3_profile/viewmodel/profile_viewmodel.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/providerIndividualChat.dart';
import 'package:re_conver/authentication/auth_service.dart';
import 'package:re_conver/authentication/userdata.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final String userId;
  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ MODIFIED: Pass userId to the ViewModel
        ChangeNotifierProvider(create: (_) => ProfileViewModel(userId: userId)),
        ChangeNotifierProvider(create: (_) => DiscoverViewModel()),
      ],
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String userId;
  const _ProfileView({required this.userId});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  // ✅ REMOVED: No longer need initState to load data
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              viewModel.userProfile.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                    child: _ProfileHeader(
                  userProfile: viewModel.userProfile,
                )),
              ];
            },
            body: _MyPostsGrid(
              posts: viewModel.myPosts,
              viewModel: viewModel,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  const _ProfileHeader({required this.userProfile});

  String _generateChatThreadId(String uid1, String uid2) {
    print('${userData.userId}');
    List<String> uids = [uid1, uid2];
    uids.sort();
    
    return uids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: userProfile.profileImageUrl.isNotEmpty
                    ? NetworkImage(userProfile.profileImageUrl)
                    : null,
                child: userProfile.profileImageUrl.isEmpty
                    ? Icon(Icons.person,
                        size: 40, color: Colors.grey.shade600)
                    : null,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Posts", userProfile.postCount.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userProfile.displayName.isNotEmpty)
                Text(
                  userProfile.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              if (userProfile.bio.isNotEmpty)
                Text(
                  userProfile.bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if(FirebaseAuth.instance.currentUser == null){
                showSignInModal(context);
              }else{
                final chatThreadId = _generateChatThreadId(userData.userId, userProfile.uid);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => IndividualChatScreenWithProvider(
                    chatThreadId: chatThreadId,
                    otherUserUid: userProfile.uid,
                    otherUserName: userProfile.username,
                  ),
                ));
              }
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _MyPostsGrid extends StatelessWidget {
  final List<Post> posts;
  final ProfileViewModel viewModel;

  const _MyPostsGrid({required this.posts, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Posts Yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchMyPosts(isInitial: true),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final Post post = posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}