// lib/3-shared/features/ai_chat/view/ai_chat_screen.dart
// (新規作成)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import '../viewmodel/ai_chat_viewmodel.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIChatViewModel(),
      child: const _AIChatView(),
    );
  }
}

class _AIChatView extends StatefulWidget {
  const _AIChatView();

  @override
  State<_AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<_AIChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(AIChatViewModel viewModel) {
    if (_textController.text.trim().isNotEmpty) {
      viewModel.sendMessage(_textController.text.trim());
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AIChatViewModel>();
    // ViewModelのメッセージリストが更新されたら、スクロールする
    if (viewModel.messages.isNotEmpty) {
      _scrollToBottom();
    }
    
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
          // 検索実行ボタン
          TextButton(
            onPressed: () {
              // ViewModelからFilterOptionsを生成して前の画面に返す
              final filters = viewModel.generateFilterOptions();
              Navigator.of(context).pop(filters);
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        // ★ 要件: 背景画像を設定
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/ai_chat_background.png"), // ★ パス
            fit: BoxFit.cover,
            opacity: 0.1, // 少し薄くする
          ),
        ),
        child: Column(
          children: [
            // メッセージリスト
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: viewModel.messages.length,
                itemBuilder: (context, index) {
                  final message = viewModel.messages[index];
                  return _buildMessageBubble(message.text, message.isUser);
                },
              ),
            ),
            
            // ローディングインジケーター
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),

            // 入力欄
            _buildTextInput(viewModel),
          ],
        ),
      ),
    );
  }

  // メッセージ入力欄
  Widget _buildTextInput(AIChatViewModel viewModel) {
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
                onSubmitted: (_) => _sendMessage(viewModel),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
              onPressed: viewModel.isLoading ? null : () => _sendMessage(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  // メッセージバブル
  Widget _buildMessageBubble(String text, bool isUser) {
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}