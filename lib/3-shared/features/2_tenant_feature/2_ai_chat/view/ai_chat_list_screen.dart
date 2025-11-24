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
                  return _buildEmptyState(context, viewModel);
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
  
  Widget _buildEmptyState(BuildContext context, AIChatListViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. アイキャッチアイコン
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 64, color: Colors.deepPurple),
            ),
            const SizedBox(height: 24),

            // 2. キャッチコピー
            const Text(
              "Your Personal Rental Concierge",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 3. 機能説明 (Why)
            const Text(
              "Stop endless scrolling. Just tell the AI your budget, location, and vibe.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // 4. メリットの箇条書き
            _buildFeatureRow(Icons.check, "Fun and close to APU"),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.check, "Room with nice accessibility to Sunway uni"),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.check, "Around 900rm, and fun place, close to APU"),

            const SizedBox(height: 32),

            // 5. アクションボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startNewChat(context, viewModel),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Start AI Chat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
  
  Future<void> _startNewChat(
      BuildContext context, AIChatListViewModel viewModel) async {
    final newChatId = await viewModel.createNewChatRoom();
    if (!context.mounted) return;

    final filters = await Navigator.push<FilterOptions>(
      context,
      MaterialPageRoute(
        builder: (_) => AIChatScreen(chatId: newChatId),
      ),
    );
    
    if (context.mounted && filters != null) {
      Navigator.of(context).pop(filters);
    }
  }
}