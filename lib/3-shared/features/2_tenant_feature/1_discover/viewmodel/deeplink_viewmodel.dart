import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/common_feature/chat/view/providerIndividualChat.dart';
import 'package:re_conver/3-shared/common_feature/post_actions_viewmodel.dart';
import 'package:re_conver/3-shared/core/model/PostModel.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/post_card.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/view/post_detail_bottomsheet.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/viewmodel/post_service.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';

class DeepLinkViewModel extends PostActionsViewModel {
  final PostService _postService = PostService();
  PostModel? post;

  void setPost(PostModel p) {
    post = p;
    notifyListeners();
  }

  @override
  void toggleLike(String postId) {
    if (post == null || post!.id != postId) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid ?? userData.userId;
    if (userId.isEmpty) return;

    final isLiked = post!.likedBy.contains(userId);
    if (isLiked) {
      post!.likeCount--;
      post!.likedBy.remove(userId);
    } else {
      post!.likeCount++;
      post!.likedBy.add(userId);
    }
    notifyListeners();
    _postService.toggleLike(postId);
  }

  @override
  Future<void> savePost(String postId) async {
    if (post == null || post!.id != postId) return;
    post!.isSaved = !post!.isSaved;
    notifyListeners();
    await _postService.toggleSavePost(postId);
  }
}

/// PostCardを表示するための画面
class DeepLinkPostView extends StatefulWidget {
  final String postId;
  const DeepLinkPostView({super.key, required this.postId});

  @override
  State<DeepLinkPostView> createState() => _DeepLinkPostViewState();
}

class _DeepLinkPostViewState extends State<DeepLinkPostView> {
  late DeepLinkViewModel _viewModel;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewModel = DeepLinkViewModel();
    _loadPost();

    // 画面表示後にログインチェック -> 未ログインならモーダル表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        showSignInModal(context).then((loggedIn) {
          if (loggedIn == true) {
             // ログインしたら画面をリロード（いいね状態などの反映のため）
            _loadPost();
          }
        });
      }
    });
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
      if (doc.exists) {
        // ログイン済みなら保存状態も確認する
        bool isSaved = false;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
             final savedDoc = await FirebaseFirestore.instance
                 .collection('users')
                 .doc(user.uid)
                 .collection('savedPosts')
                 .doc(widget.postId)
                 .get();
             isSaved = savedDoc.exists;
             
             // userDataも念のため更新
             userData.setUser(user);
        }

        final post = PostModel.fromFirestore(doc, isSaved: isSaved);
        _viewModel.setPost(post);
      } else {
        setState(() => _error = "This listing is no longer available.");
      }
    } catch (e) {
      setState(() => _error = "Failed to load listing: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // チャット開始ロジック (DiscoverScreenから流用)
  void _startChat(BuildContext context, PostModel post) {
    if (FirebaseAuth.instance.currentUser == null) {
      showSignInModal(context);
      return;
    }

    List<String> uids = [userData.userId, post.userId];
    uids.sort();
    final chatThreadId = uids.join('_');
    
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
    
    // ボトムシートが開いていたら閉じる
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

  // 詳細ボトムシート表示 (DiscoverScreenから流用)
  void _showPostDetails(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider<PostActionsViewModel>.value(
          value: _viewModel,
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: PostDetailBottomSheet(
                  post: post,
                  onStartChat: (p) => _startChat(context, p),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listing Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // 戻るボタンでホームに戻るようにする
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)))
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      // PostCardを表示するためにViewModelを提供
                      child: ChangeNotifierProvider<PostActionsViewModel>.value(
                        value: _viewModel,
                        child: Consumer<PostActionsViewModel>(
                          builder: (context, model, child) {
                            // ViewModel内のpostを使用
                            final post = (_viewModel as DeepLinkViewModel).post!;
                            return PostCard(
                              post: post,
                              onToggleLike: _viewModel.toggleLike,
                              onToggleSave: _viewModel.savePost,
                              onStartChat: (p) => _startChat(context, p),
                              onTap: () => _showPostDetails(context, post),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}