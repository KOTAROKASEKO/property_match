
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/shared_data.dart'; // userDataのため
import 'package:template_hive/template_hive.dart'; // PropertyTemplateのため
import '../../../../core/model/PostModel.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
// ↓ SuggestedPostCard を使うため (提供されたファイルパスに合わせてください)
import '../../../../common_feature/chat/view/suggestion/suggested_post_card.dart'; 
import '../viewmodel/ai_chat_viewmodel.dart';
import '../model/ai_chat_message.dart';

class AIChatScreen extends StatefulWidget {
  // ★★★ 修正 (1/3): chatId をコンストラクタで受け取る ★★★
  final String chatId;
  const AIChatScreen({super.key, required this.chatId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  late AIChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AIChatViewModel(chatId: widget.chatId); // 修正
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _startChatWithAgent(PostModel post) {
    // チャットID生成ロジック (共通化しても良い)
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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _AIChatViewWithLogic(), // ロジックを渡すためにウィジェットを分離
    );
  }
}

// ... (以降の _AIChatViewWithLogic, _MessageBubble, _MessageInput ウィジェットは変更なし) ...
// ( ... _AIChatViewWithLogic ... )
// ( ... _MessageBubble ... )
// ( ... _MessageInput ... )
class _AIChatViewWithLogic extends StatelessWidget {
  const _AIChatViewWithLogic();

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_AIChatScreenState>();
    final viewModel = context.watch<AIChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 8),
            Text('AI Search Assistant', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              final filters = await viewModel.getLatestFilterOptions();
              if (filters != null) {
                Navigator.of(context).pop(filters);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("AIがまだ検索条件を確定していません。")),
                );
              }
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/ai_chat_background.png"), // パス修正
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                // controller: ... (必要なら追加)
                padding: const EdgeInsets.all(8.0),
                itemCount: viewModel.messages.length,
                itemBuilder: (context, index) {
                  final message = viewModel.messages[index];
                  return _MessageBubble(
                    message: message, 
                    onPostTap: (post) => parentState?._startChatWithAgent(post),
                  );
                },
              ),
            ),
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            _MessageInput(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}

// ★★★ 修正: メッセージバブルを別ウィジェット化して物件リストを表示 ★★★
class _MessageBubble extends StatelessWidget {
  final AIChatMessage message;
  final Function(PostModel)? onPostTap;

  const _MessageBubble({required this.message, this.onPostTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.deepPurple[400] : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
      bottomRight: isUser ? Radius.zero : const Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // テキスト部分
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
            ),
          ),

          // ★★★ 物件リスト部分 (AIのメッセージかつ物件がある場合) ★★★
          if (!isUser && message.suggestedPosts.isNotEmpty)
            Container(
              height: 280, // カードの高さ
              margin: const EdgeInsets.only(bottom: 8, left: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: message.suggestedPosts.length,
                itemBuilder: (context, index) {
                  final post = message.suggestedPosts[index];
                  return SizedBox(
                    width: 200, // カードの幅
                    child: SuggestedPostCard( // 既存のSuggestedPostCardを再利用
                      post: post,
                      onTap: () => onPostTap?.call(post),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final AIChatViewModel viewModel;
  const _MessageInput({required this.viewModel});

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      widget.viewModel.sendMessage(_textController.text.trim());
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'e.g. "I want a single room..."',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
              onPressed: widget.viewModel.isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}