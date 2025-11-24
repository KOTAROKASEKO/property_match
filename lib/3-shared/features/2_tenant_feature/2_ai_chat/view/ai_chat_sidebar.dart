// lib/3-shared/features/2_tenant_feature/2_ai_chat/view/ai_chat_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ai_chat_room_model.dart';
import '../viewmodel/ai_chat_list_viewmodel.dart';

class AIChatSidebar extends StatelessWidget {
  final Function(String? chatId) onChatSelected;
  final String? selectedChatId;

  const AIChatSidebar({
    super.key,
    required this.onChatSelected,
    this.selectedChatId,
  });

  @override
  Widget build(BuildContext context) {
    // サイドバー専用に ListViewModel を提供
    return ChangeNotifierProvider(
      create: (_) => AIChatListViewModel(),
      child: Consumer<AIChatListViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            color: Colors.deepPurple,// GPT風の暗い背景（お好みで調整）
            child: Column(
              children: [
                // --- New Chat Button ---
                Padding(padding: EdgeInsetsGeometry.all(10),
                child: Image.asset('logo1.png',width: 70,height: 70,),),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => onChatSelected(null), // null = 新規チャット
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('New Chat', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
                
                // --- History List ---
                Expanded(
                  child: StreamBuilder<List<AIChatRoomModel>>(
                    stream: viewModel.chatRoomsStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final chats = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final isSelected = chat.id == selectedChatId;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white10 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                chat.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              onTap: () => onChatSelected(chat.id),
                              trailing: isSelected 
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 18),
                                    onPressed: () => viewModel.deleteChatRoom(chat.id),
                                  )
                                : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // --- User Info / Settings (Optional) ---
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Divider(color: Colors.white24),
                ),
                // 必要ならここにユーザー情報を表示
              ],
            ),
          );
        },
      ),
    );
  }
}