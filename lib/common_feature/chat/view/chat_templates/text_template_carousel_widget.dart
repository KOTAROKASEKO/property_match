import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/common_feature/chat/view/chat_templates/manage_text_template_screen.dart';
import 'package:re_conver/common_feature/chat/viewmodel/messageTemplate_viewmodel.dart';

class TextTemplateCarouselWidget extends StatelessWidget {
  final Function(String template) onTemplateSelected;

  const TextTemplateCarouselWidget({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MessagetemplateViewmodel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Message Templates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                   Navigator.of(context).push(
                    MaterialPageRoute(
                      // We can pass the existing ViewModel to the new screen
                      builder: (_) => ChangeNotifierProvider.value(
                        value: viewModel,
                        child: const ManageTenantTemplatesScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Manage'),
              )
            ],
          ),
        ),
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.templates.isEmpty
                  ? const Center(child: Text("No message templates found."))
                  : ListView.builder(
                      itemCount: viewModel.templates.length,
                      itemBuilder: (context, index) {
                        final template = viewModel.templates[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(template,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.add),
                            onTap: () => onTemplateSelected(template),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}