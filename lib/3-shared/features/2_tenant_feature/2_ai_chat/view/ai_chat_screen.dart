// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/authentication/auth_service.dart';
import 'package:shared_data/shared_data.dart';
import 'package:template_hive/template_hive.dart';
import '../../../../core/model/PostModel.dart';
import '../../../../common_feature/chat/view/providerIndividualChat.dart';
import '../../../../common_feature/chat/view/suggestion/suggested_post_card.dart';
import '../viewmodel/ai_chat_viewmodel.dart';
import '../model/ai_chat_message.dart';

class AIChatScreen extends StatefulWidget {
  final String? chatId;
  final Function(String newId)? onChatCreated;

  const AIChatScreen({super.key, this.chatId, this.onChatCreated});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  late AIChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AIChatViewModel(chatId: widget.chatId);
  }

  @override
  void didUpdateWidget(covariant AIChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatId != oldWidget.chatId) {
      _viewModel.dispose();
      _viewModel = AIChatViewModel(chatId: widget.chatId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // エージェントとのチャット開始ロジック（既存）
  void _startChatWithAgent(PostModel post) {
    if(FirebaseAuth.instance.currentUser == null){
      showSignInModal(context);
      return;
    }
    List<String> uids = [userData.userId, post.userId];
    uids.sort();
    final chatThreadId = uids.join('_');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => IndividualChatScreenWithProvider(
      chatThreadId: chatThreadId,
      otherUserUid: post.userId,
      otherUserName: post.username,
      otherUserPhotoUrl: post.userProfileImageUrl,
      initialPropertyTemplate: PropertyTemplate(
        postId: post.id, name: post.condominiumName, rent: post.rent, location: post.location,
        description: post.description, roomType: post.roomType, gender: post.gender,
        photoUrls: post.imageUrls, nationality: 'Any'
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: _AIChatViewWithLogic(
        onChatCreated: widget.onChatCreated,
        onPostTap: _startChatWithAgent,
      ),
    );
  }
}

class _AIChatViewWithLogic extends StatelessWidget {
  final Function(String newId)? onChatCreated;
  final Function(PostModel) onPostTap;

  const _AIChatViewWithLogic({
    required this.onChatCreated,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AIChatViewModel>();
    final bool showWelcome = viewModel.messages.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white, // ChatGPTライクな白背景
      body: showWelcome
          ? _buildWelcomeView(context, viewModel)
          : _buildActiveChatView(context, viewModel),
    );
  }

  // ★ 1. Welcome View (画面中央に入力フィールド)
  Widget _buildWelcomeView(BuildContext context, AIChatViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), // PCで見やすくなるよう幅制限
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ロゴ / アイコン
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 5)
                  ],
                ),
                child: const Icon(Icons.auto_awesome, size: 48, color: Colors.deepPurple),
              ),
              const SizedBox(height: 32),
              
              // 挨拶テキスト
              const Text(
                "What's on the agenda today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // ★ 入力フィールド (中央配置)
              _MessageInput(
                viewModel: viewModel,
                onChatCreated: onChatCreated,
                isCentered: true, // デザイン切り替え用フラグ
              ),
              
              const SizedBox(height: 24),
              // Suggestion Chips (Optional)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip(context, "A room that has some restaurant near there", viewModel),
                  _buildSuggestionChip(context, "Cheaper than 1000rm, but clean room", viewModel),
                  _buildSuggestionChip(context, "1 to 3 station away from bukit jalil with supermarket", viewModel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text, AIChatViewModel viewModel) {
    return ActionChip(
      label: Text(text),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        viewModel.sendMessage(text).then((newId) {
          if (newId != null && onChatCreated != null) onChatCreated!(newId);
        });
      },
    );
  }

  // ★ 2. Active Chat View (通常のチャット画面)
  Widget _buildActiveChatView(BuildContext context, AIChatViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            itemCount: viewModel.messages.length,
            itemBuilder: (context, index) {
              final message = viewModel.messages[index];
              return _MessageBubble(
                message: message,
                onPostTap: onPostTap,
              );
            },
          ),
        ),
        if (viewModel.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(backgroundColor: Colors.transparent),
          ),
        
        // ★ 入力フィールド (下部配置)
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: _MessageInput(
              viewModel: viewModel,
              onChatCreated: onChatCreated,
              isCentered: false,
            ),
          ),
        ),
      ],
    );
  }
}

// _MessageBubble は前回と同じため省略（変更なし）
class _MessageBubble extends StatelessWidget {
  // ... 既存の実装 (前回提供のコード) をそのまま使用
  final AIChatMessage message;
  final Function(PostModel)? onPostTap;
  const _MessageBubble({required this.message, this.onPostTap});
  
  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            decoration: BoxDecoration(
              color: isUser ? Colors.grey[100] : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: MarkdownBody(data: message.text, selectable: true),
          ),
          if (!isUser && message.suggestedPosts.isNotEmpty)
            Container(
              height: 290,
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: message.suggestedPosts.length,
                itemBuilder: (context, index) {
                  return SizedBox(width: 240, child: Padding(padding: const EdgeInsets.only(right: 12), child: SuggestedPostCard(post: message.suggestedPosts[index], onTap: () => onPostTap?.call(message.suggestedPosts[index]))));
                },
              ),
            ),
        ],
      ),
    );
  }
}


// ★ 3. Input Field (共通コンポーネント)
class _MessageInput extends StatefulWidget {
  final AIChatViewModel viewModel;
  final Function(String)? onChatCreated;
  final bool isCentered; // 中央表示モードかどうか

  const _MessageInput({
    required this.viewModel,
    this.onChatCreated,
    required this.isCentered,
  });

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() async {
    if (_textController.text.trim().isNotEmpty) {
      final text = _textController.text.trim();
      _textController.clear();

      // メッセージ送信
      final newId = await widget.viewModel.sendMessage(text);

      // 新規チャットだった場合、IDを親に通知
      if (newId != null && widget.onChatCreated != null) {
        widget.onChatCreated!(newId);
      }
      
      // フォーカス維持
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // デザインの微調整
    final double elevation = widget.isCentered ? 4 : 0;
    final Color fillColor = widget.isCentered ? Colors.white : Colors.grey[100]!;
    final Color borderColor = widget.isCentered ? Colors.transparent : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: elevation,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          minLines: 1,
          textInputAction: TextInputAction.newline, // Enterで改行したい場合
          decoration: InputDecoration(
            hintText: 'a room convenient to commute APU and nearby supermarket',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                onPressed: widget.viewModel.isLoading ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: _textController.text.isEmpty ? Colors.grey[200] : Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[200],
                  disabledForegroundColor: Colors.grey[400],
                ),
              ),
            ),
          ),
          onChanged: (val) => setState(() {}),
        ),
      ),
    );
  }
}