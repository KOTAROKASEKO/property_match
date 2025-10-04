// lib/1_agent_feature/chat_template/view/manage_agent_message_template_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageTemplate_viewmodel.dart';

class ManageAgentMessageTemplateScreen extends StatelessWidget {
  const ManageAgentMessageTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MessagetemplateViewmodel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manage Message Templates'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.templates.length,
        itemBuilder: (context, index) {
          final template = viewModel.templates[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              title: Text(
                template,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.edit_outlined, color: Colors.blueGrey[600]),
                    onPressed: () =>
                        _showAddEditDialog(context, viewModel, index: index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                    onPressed: () =>
                        _showDeleteConfirmation(context, viewModel, index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, viewModel),
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add new template',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddEditDialog(
      BuildContext context, MessagetemplateViewmodel viewModel,
      {int? index}) async {
    final bool isEditing = index != null;
    final String initialText = isEditing ? viewModel.templates[index] : '';
    final controller = TextEditingController(text: initialText);

    final newTemplateText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Edit Template' : 'Add New Template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Enter your message template...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTemplateText != null) {
      if (isEditing) {
        viewModel.updateTemplate(index, newTemplateText);
      } else {
        viewModel.addTemplate(newTemplateText);
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, MessagetemplateViewmodel viewModel, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Template?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      viewModel.deleteTemplate(index);
    }
  }
}