// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_screen.dart
import 'package:flutter/material.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import 'ai_chat_history_sidebar.dart';
import 'ai_chat_screen.dart';

class AIChatMainScreen extends StatefulWidget {
  const AIChatMainScreen({super.key});

  @override
  State<AIChatMainScreen> createState() => _AIChatMainScreenState();
}

class _AIChatMainScreenState extends State<AIChatMainScreen> {
  String? _selectedChatId; // null = New Chat

  void _selectChat(String chatId) {
    setState(() {
      _selectedChatId = chatId;
    });
    // モバイルの場合、ドロワーを閉じる
    if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop(); 
    }
  }

  void _startNewChat() {
    setState(() {
      _selectedChatId = null;
    });
    // モバイルの場合、ドロワーを閉じる
    if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  // チャットが生成されたときに呼ばれるコールバック
  void _onChatCreated(String newId) {
    // IDを更新するが、再描画は不要（同じ画面を使い続けるため）
    // ただし、履歴リストの選択状態を更新するためにセットする
    setState(() {
      _selectedChatId = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;

        // サイドバーウィジェット
        final sidebar = SizedBox(
          width: 300,
          child: AIChatHistorySidebar(
            selectedChatId: _selectedChatId,
            onChatSelected: _selectChat,
            onNewChat: _startNewChat,
          ),
        );

        // メインチャットエリア
        // KeyにIDを渡すことで、IDが変わったときにウィジェットを再構築させる
        final chatArea = AIChatScreen(
          key: ValueKey(_selectedChatId), 
          chatId: _selectedChatId,
          onChatCreated: _onChatCreated, // 新規チャット作成時のコールバック
        );

        if (isWideScreen) {
          // PC/タブレット: 横並び
          return Scaffold(
            body: Row(
              children: [
                sidebar,
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: chatArea),
              ],
            ),
          );
        } else {
          // モバイル: ドロワー
          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Assistant'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              // leadingは自動的にハンバーガーメニューになる
            ),
            drawer: Drawer(
              width: 300,
              child: SafeArea(child: sidebar), // SafeAreaで包む
            ),
            body: chatArea,
          );
        }
      },
    );
  }
}