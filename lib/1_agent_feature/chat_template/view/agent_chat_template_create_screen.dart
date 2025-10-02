import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/chat_template/property_template.dart';
import 'package:re_conver/1_agent_feature/chat_template/viewmodel/agent_template_viewmodel.dart';

class ManageAgentTemplatesScreen extends StatelessWidget {
  const ManageAgentTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen now consumes the globally provided AgentTemplateViewModel
    final viewModel = context.watch<AgentTemplateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Templates'),
      ),
      body: viewModel.templates.isEmpty
          ? const Center(
              child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No templates yet. Tap the + button to create your first property template.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: viewModel.templates.length,
              itemBuilder: (context, index) {
                final template = viewModel.templates[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => viewModel.deleteTemplate(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AgentTemplateViewModel>().clearSelection();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<AgentTemplateViewModel>(),
                child: const CreateAgentTemplateScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Separate screen for creating/editing a template
class CreateAgentTemplateScreen extends StatefulWidget {
  const CreateAgentTemplateScreen({super.key});

  @override
  _CreateAgentTemplateScreenState createState() =>
      _CreateAgentTemplateScreenState();
}

class _CreateAgentTemplateScreenState extends State<CreateAgentTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rentController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'Any');

  String _roomType = 'Middle';
  String _gender = 'Mix';

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgentTemplateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Property Template'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        final newTemplate = PropertyTemplate(
                          name: _nameController.text,
                          rent: double.tryParse(_rentController.text) ?? 0,
                          location: _locationController.text,
                          description: _descriptionController.text,
                          nationality: _nationalityController.text,
                          gender: _gender,
                          roomType: _roomType,
                          photoUrls: [],
                        );
                        viewModel.saveTemplate(newTemplate).then((_) {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    },
              child: viewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SAVE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionCard(
              title: 'Property Details',
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Property Name*'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rentController,
                  decoration: const InputDecoration(labelText: 'Rent (RM)*'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a rent amount' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location*'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a location' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      hintText: 'Add details about the property...'),
                  maxLines: 4,
                ),
              ],
            ),
            _buildSectionCard(
              title: 'Tenant Preferences',
              children: [
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Preferred Gender'),
                  value: _gender,
                  items: ['Male', 'Female', 'Mix'].map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) => setState(() => _gender = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Room Type'),
                  value: _roomType,
                  items: ['Master', 'Middle', 'Single'].map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) => setState(() => _roomType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nationalityController,
                  decoration:
                      const InputDecoration(labelText: 'Preferred Nationality'),
                ),
              ],
            ),
            _buildSectionCard(
              title: 'Photos',
              children: [
                _buildImagePicker(viewModel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(AgentTemplateViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(viewModel.selectedImages[index],
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: IconButton(
                          icon: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child:
                                Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                          onPressed: () => viewModel.removeImage(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => viewModel.pickImages(),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add Images'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}