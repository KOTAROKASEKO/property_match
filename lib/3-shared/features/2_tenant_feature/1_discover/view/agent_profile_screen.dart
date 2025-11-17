// lib/3-shared/features/2_tenant_feature/1_discover/view/agent_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/post_actions_viewmodel.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../1_agent_feature/1_profile/model/agent_profile_model.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import 'post_card.dart';
import '../viewmodel/public_agent_profile_viewmodel.dart';

// ★ 1. discover_screen.dart から _showPostDetails を持ってくるためインポート
import '../../../../core/model/PostModel.dart';
import 'post_detail_bottomsheet.dart';


class AgentProfileScreen extends StatelessWidget {
  final String agentId;

  const AgentProfileScreen({Key? key, required this.agentId}) : super(key: key);

  String _generateChatThreadId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // ★ 2. _showPostDetails メソッドを discover_screen.dart からコピー＆適応
  // (ViewModel を引数で受け取るように変更)
  void _showPostDetails(
    BuildContext context,
    PostModel post,
    PublicAgentProfileViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // ViewModel をボトムシートに提供
        // ▼▼▼ 修正: <PostActionsViewModel> を明示的に指定 ▼▼▼
        return ChangeNotifierProvider<PostActionsViewModel>.value(
          value: viewModel, // viewModel は PublicAgentProfileViewModel
          // ▲▲▲ 修正 ▲▲▲
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                // onStartChat パラメータを渡す
                child: PostDetailBottomSheet(
                  post: post,
                  onStartChat: (PostModel postFromSheet) {
                    _startChat(context, postFromSheet, viewModel);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
  // ★ 3. _startChat メソッドを discover_screen.dart からコピー＆適応
  // (ViewModel を引数で受け取るように変更)
  void _startChat(
    BuildContext context,
    PostModel post,
    PublicAgentProfileViewModel viewModel,
  ) {
    // Authチェックは discover_screen 同様、ここでは不要
    // (この画面に来る時点で認証済みのはず)
    
    final chatThreadId = _generateChatThreadId(userData.userId, post.userId);
    final propertyTemplate = PropertyTemplate(
      postId: post.id,
      name: post.condominiumName,
      rent: post.rent,
      location: post.location,
      description: post.description,
      roomType: post.roomType,
      gender: post.gender,
      photoUrls: post.imageUrls,
      nationality: 'Any',
    );

    // ボトムシートが開いていれば閉じる (PostDetailBottomSheetから呼ばれる場合)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndividualChatScreenWithProvider(
          chatThreadId: chatThreadId,
          otherUserUid: post.userId,
          otherUserName: post.username,
          otherUserPhotoUrl: post.userProfileImageUrl,
          initialPropertyTemplate: propertyTemplate,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PublicAgentProfileViewModel>(
      create: (_) => PublicAgentProfileViewModel(agentId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Profile'),
          // ★ AppBarのスタイルを他の画面と統一
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<PublicAgentProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.agentProfile == null) {
              return const Center(child: Text('Agent not found.'));
            }

            // ★ 4. CustomScrollView の slivers を LayoutBuilder でラップ
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
                
                // ★ 5. LayoutBuilder を SliverLayoutBuilder に変更
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    const double gridBreakpoint = 600.0;
                    final bool useGridView = constraints.asBoxConstraints().maxWidth >= gridBreakpoint;

                    if (viewModel.posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Text(
                              "This agent hasn't posted any listings yet.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    if (useGridView) {
                      // ★ 6. _buildPostGrid を呼び出し
                      return _buildPostGrid(context, viewModel);
                    } else {
                      // ★ 7. _buildPostList を呼び出し
                      return _buildPostList(context, viewModel);
                    }
                  }
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ★ 8. _buildPostGrid メソッドを追加 (agent_profile_view.dart から適応)
  Widget _buildPostGrid(BuildContext context, PublicAgentProfileViewModel viewModel) {
     // 画面幅に基づいて列数を計算 (例)
    final screenWidth = MediaQuery.of(context).size.width;
    // 最小幅350px、最大4列として列数を計算
    final crossAxisCount = (screenWidth / 350).floor().clamp(1, 4);

    return SliverPadding(
      padding: const EdgeInsets.all(16.0), // Gridの外側の余白
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // 計算した列数
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.70, // PostCard の比率に合わせる
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final post = viewModel.posts[index];
            return PostCard( // ★ AgentPostGridCard ではなく PostCard を使う
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: (post) => _startChat(context, post, viewModel),
              onTap: () => _showPostDetails(context, post, viewModel),
            );
          },
          childCount: viewModel.posts.length,
        ),
      ),
    );
  }

  // ★ 9. _buildPostList メソッドを追加 (agent_profile_view.dart から適応)
  Widget _buildPostList(BuildContext context, PublicAgentProfileViewModel viewModel) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = viewModel.posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // リスト表示時の左右の余白
            child: PostCard( // ★ PostCard を使う
              post: post,
              onToggleLike: viewModel.toggleLike,
              onToggleSave: viewModel.savePost,
              onStartChat: (post) => _startChat(context, post, viewModel),
              onTap: () => _showPostDetails(context, post, viewModel),
            ),
          );
        },
        childCount: viewModel.posts.length,
      ),
    );
  }
}

// _ProfileHeader は変更なし
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
            // ★ スタイルを他のボタンと統一
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}