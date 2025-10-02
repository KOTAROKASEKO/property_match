import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/agent_profile_model.dart';
import 'package:re_conver/1_agent_feature/2_profile/repo/profile_repository.dart';
import 'package:re_conver/1_agent_feature/2_profile/viewmodel/profile_viewmodel.dart';
import 'package:re_conver/2_tenant_feature/2_discover/view/post_card.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/providerIndividualChat.dart';
import 'package:re_conver/authentication/userdata.dart';

class AgentProfileScreen extends StatelessWidget {
  final String agentId;

  const AgentProfileScreen({Key? key, required this.agentId}) : super(key: key);

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

    @override
  Widget build(BuildContext context) {
    print("Building AgentProfileScreen for agentId: $agentId");
    
    // FIXED: Change the provider type back to the concrete class
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(FirestoreProfileRepository())
        ..fetchAgentData(agentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Profile'),
        ),
        body: Consumer<ProfileViewModel>( // This Consumer will now find its provider
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.agentProfile == null) {
              return const Center(child: Text('Agent not found.'));
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeader(
                    agentProfile: viewModel.agentProfile!,
                    onStartChat: () {
                      final chatThreadId = _generateChatThreadId(
                          userData.userId, viewModel.agentProfile!.uid);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IndividualChatScreenWithProvider(
                            otherUserUid: viewModel.agentProfile!.uid,
                            otherUserName: viewModel.agentProfile!.displayName,
                            otherUserPhotoUrl:
                                viewModel.agentProfile!.profileImageUrl,
                            chatThreadId: chatThreadId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = viewModel.posts[index];
                      // This PostCard will correctly find the provider as PostActionsViewModel
                      return PostCard(
                        post: post,
                        onToggleLike: viewModel.toggleLike,
                        onToggleSave: viewModel.savePost,
                      );
                    },
                    childCount: viewModel.posts.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AgentProfile agentProfile;
  final VoidCallback onStartChat;

  const _ProfileHeader(
      {Key? key, required this.agentProfile, required this.onStartChat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: agentProfile.profileImageUrl.isNotEmpty
                ? NetworkImage(agentProfile.profileImageUrl)
                : null,
            child: agentProfile.profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            agentProfile.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            agentProfile.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onStartChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}