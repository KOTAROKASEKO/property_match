// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_main_layout.dart
import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';
import 'ai_chat_sidebar.dart';

class AIChatMainLayout extends StatefulWidget {
  const AIChatMainLayout({super.key});

  @override
  State<AIChatMainLayout> createState() => _AIChatMainLayoutState();
}

class _AIChatMainLayoutState extends State<AIChatMainLayout> {
  String? _selectedChatId; // null なら「新規チャット」画面

  void _onChatSelected(String? chatId) {
    setState(() {
      _selectedChatId = chatId;
    });
    // モバイルの場合、ドロワーを閉じる
    if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  void _onChatCreated(String newId) {
    setState(() {
      _selectedChatId = newId;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面幅でレイアウトを切り替え
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        // チャット画面本体
        final chatScreen = AIChatScreen(
          // keyを変えることで、ID変更時にViewModelを作り直させる
          key: ValueKey(_selectedChatId), 
          chatId: _selectedChatId,
          onChatCreated: _onChatCreated,
        );

        if (isDesktop) {
          // --- PC/タブレット: 左サイドバー固定 ---
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: AIChatSidebar(
                    onChatSelected: _onChatSelected,
                    selectedChatId: _selectedChatId,
                  ),
                ),
                Expanded(child: chatScreen),
              ],
            ),
          );
        } else {
          // --- モバイル: ドロワー ---
          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Agent'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            drawer: Drawer(
              backgroundColor: const Color(0xFF171717),
              child: SafeArea(
                child: AIChatSidebar(
                  onChatSelected: _onChatSelected,
                  selectedChatId: _selectedChatId,
                ),
              ),
            ),
            body: chatScreen,
          );
        }
      },
    );
  }
}