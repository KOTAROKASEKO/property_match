// lib/2_tenant_feature/4_chat/view/template_carousel_widget.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/2_tenant_feature/4_chat/view/manage_templates_screen.dart';
import 'package:re_conver/2_tenant_feature/4_chat/viewmodel/messageTemplate_viewmodel.dart';

class TemplateCarouselWidget extends StatelessWidget {
  final Function(String template)? onTemplateSelected;
  final bool isFullScreen;

  const TemplateCarouselWidget({
    super.key,
    this.onTemplateSelected,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MessagetemplateViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.templates.isEmpty) {
          return const Center(child: Text("No message templates found."));
        }

        final colors = [
          Colors.deepPurple.shade100,
          Colors.teal.shade100,
          Colors.orange.shade100,
          Colors.blue.shade100,
        ];

        Widget carousel = CarouselSlider.builder(
          itemCount: viewModel.templates.length,
          itemBuilder: (context, index, realIndex) {
            final template = viewModel.templates[index];
            final color = colors[index % colors.length];
            return GestureDetector(
              onTap: () {
                if (onTemplateSelected != null) {
                  onTemplateSelected!(template);
                } else {
                  Clipboard.setData(ClipboardData(text: template)).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Template copied to clipboard!')),
                    );
                  });
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      onTemplateSelected != null
                          ? 'Tap to use'
                          : 'Tap to copy',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          template,
                          style: const TextStyle(
                            fontSize: 16, 
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 220,
            enlargeCenterPage: true,
            autoPlay: false,
            viewportFraction: 0.8,
          ),
        );

        if (isFullScreen) {
          // Layout for the main chat screen (when no messages)
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the chat!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              carousel,
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const ManageTemplatesScreen(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Manage Templates'),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Layout for the bottom sheet
          return SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select a Template',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                carousel,
              ],
            ),
          );
        }
      },
    );
  }
}