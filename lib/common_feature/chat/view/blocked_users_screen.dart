// common_feature/chat/view/blocked_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/viewmodel/blocked_users_viemodel.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlockedUsersViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Blocked Users'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<BlockedUsersViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.blockedUsers.isEmpty) {
              return const Center(
                child: Text(
                  'No blocked users.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: viewModel.blockedUsers.length,
              itemBuilder: (context, index) {
                final userId = viewModel.blockedUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('User ID: $userId'), // Placeholder for user display name
                    trailing: viewModel.isUnblocking?
                    CircularProgressIndicator()
                    :
                     TextButton(
                      onPressed: () => viewModel.unblockUser(userId),
                      child: const Text('Unblock', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}