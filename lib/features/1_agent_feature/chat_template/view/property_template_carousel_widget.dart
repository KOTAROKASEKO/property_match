// lib/1_agent_feature/chat_template/view/property_template_carousel_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/model/property_template.dart';
import 'package:re_conver/features/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';

class PropertyTemplateCarouselWidget extends StatelessWidget {
  final Function(PropertyTemplate template) onTemplateSelected;

  const PropertyTemplateCarouselWidget({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgentTemplateViewModel>();

    Widget content;

    if (viewModel.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (viewModel.templates.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No property templates found."),
            const SizedBox(height: 20),
            
          ],
        ),
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: viewModel.templates.length,
        itemBuilder: (context, index) {
          final template = viewModel.templates[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: template.photoUrls.isNotEmpty
                    ? Image.network(
                        template.photoUrls.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.apartment, size: 30),
                      ),
              ),
              title: Text(template.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'RM ${template.rent.toStringAsFixed(0)} - ${template.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onTemplateSelected(template),
            ),
          );
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Property template to Send',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
            ],
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}