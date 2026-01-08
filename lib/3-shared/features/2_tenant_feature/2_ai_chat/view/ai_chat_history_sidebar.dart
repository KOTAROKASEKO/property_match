// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_history_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ai_chat_room_model.dart';
import '../viewmodel/ai_chat_list_viewmodel.dart';

class AIChatHistorySidebar extends StatelessWidget {
  final Function(String chatId) onChatSelected;
  final VoidCallback onNewChat;
  final String? selectedChatId;

  const AIChatHistorySidebar({
    super.key,
    required this.onChatSelected,
    required this.onNewChat,
    this.selectedChatId,
  });

  @override
  Widget build(BuildContext context) {
    // サイドバー内でListViewModelを使う
    return ChangeNotifierProvider(
      create: (_) => AIChatListViewModel(),
      child: Consumer<AIChatListViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                // New Chat Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onNewChat,
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // History List
                Expanded(
                  child: StreamBuilder<List<AIChatRoomModel>>(
                    stream: viewModel.chatRoomsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No history"));
                      }

                      final chatRooms = snapshot.data!;
                      return ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final room = chatRooms[index];
                          final isSelected = room.id == selectedChatId;
                          
                          return ListTile(
                            title: Text(
                              room.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.deepPurple : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                            onTap: () => onChatSelected(room.id),
                            trailing: isSelected 
                                ? const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.deepPurple)
                                : null,
                            // 削除機能などをここに追加してもOK
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}