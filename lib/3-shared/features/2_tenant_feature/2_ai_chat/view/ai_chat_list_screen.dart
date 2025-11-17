// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/3-shared/features/2_tenant_feature/1_discover/model/filter_options.dart';
import '../model/ai_chat_room_model.dart';
import '../viewmodel/ai_chat_list_viewmodel.dart';
import 'ai_chat_screen.dart'; // 既存のチャット画面

class AIChatListScreen extends StatelessWidget {
  const AIChatListScreen({super.key});

  // フィルター画面に戻るためのヘルパー
  void _popWithFilters(BuildContext context, FilterOptions? filters) {
    if (filters != null) {
      Navigator.of(context).pop(filters);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, AIChatListViewModel viewModel, AIChatRoomModel room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: Text('Are you sure you want to delete "${room.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await viewModel.deleteChatRoom(room.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIChatListViewModel(),
      child: Consumer<AIChatListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Chat History'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            body: StreamBuilder<List<AIChatRoomModel>>(
              stream: viewModel.chatRoomsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No AI chats yet. Tap + to start!',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final chatRooms = snapshot.data!;

                return ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = chatRooms[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      // ★★★ 変更: GestureDetector でラップして右クリック (onSecondaryTap) に対応 ★★★
                      child: GestureDetector(
                        onSecondaryTap: () => _confirmDelete(context, viewModel, room),
                        child: ListTile(
                          leading: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                          title: Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            room.lastMessageText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          // ★★★ 追加: 長押し (onLongPress) に対応 ★★★
                          onLongPress: () => _confirmDelete(context, viewModel, room),
                          onTap: () async {
                            final filters = await Navigator.push<FilterOptions>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AIChatScreen(chatId: room.id),
                              ),
                            );
                            _popWithFilters(context, filters);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final newChatId = await viewModel.createNewChatRoom();
                if (!context.mounted) return;
                
                final filters = await Navigator.push<FilterOptions>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AIChatScreen(chatId: newChatId),
                  ),
                );
                _popWithFilters(context, filters);
              },
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}