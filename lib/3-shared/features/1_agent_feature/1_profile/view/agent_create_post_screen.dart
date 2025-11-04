// lib/features/1_agent_feature/1_profile/view/agent_create_post_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Explicitly import kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/model/PostModel.dart';
import '../viewmodel/agent_create_post_viewmodel.dart';
import '../../../authentication/auth_service.dart';

class CreatePostScreen extends StatelessWidget {
  final PostModel? post;
  const CreatePostScreen({super.key, this.post});

  Future<bool> _onWillPop(
      BuildContext context, CreatePostViewModel viewModel) async {
    if (!viewModel.hasUnsavedChanges || viewModel.isPosting) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Listing?'),
        content: const Text("If you go back now, you'll lose your draft."),
        actions: <Widget>[
          TextButton(
            child: const Text('Keep editing'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
            onPressed: () {
              viewModel.clearDraft();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePostViewModel(post),
      child: Consumer<CreatePostViewModel>(
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () => _onWillPop(context, viewModel),
            child: Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: Text(viewModel.isEditing ? 'Edit Listing' : 'Create New Listing'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    if (await _onWillPop(context, viewModel)) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: ElevatedButton(
                      onPressed: viewModel.canSubmit
                          ? () async {
                              if (FirebaseAuth.instance.currentUser == null) {
                                showSignInModal(context);
                              } else {
                                final success = await viewModel.submitPost();
                                if (success && context.mounted) {
                                  Navigator.of(context).pop();
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to save listing. Please try again.'
                                          ),
                                        ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: viewModel.isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(viewModel.isEditing ? 'Save' : 'Post'),
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Property Details',
                        children: [
                          Autocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              return viewModel.getCondoSuggestions(textEditingValue.text);
                            },
                            onSelected: (String selection) {
                              // Let the fieldViewBuilder's controller listener handle the update
                              // viewModel.condominiumName = selection;
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              // Sync initial value from view model
                              if (viewModel.condominiumName.isNotEmpty && fieldTextEditingController.text.isEmpty) {
                                  fieldTextEditingController.text = viewModel.condominiumName;
                              }
                              // Use a listener to keep the view model updated
                              // Remove previous listener if exists to avoid duplicates
                              fieldTextEditingController.removeListener(() {
                                 viewModel.condominiumName = fieldTextEditingController.text;
                              });
                              fieldTextEditingController.addListener(() {
                                 viewModel.condominiumName = fieldTextEditingController.text;
                              });

                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: const InputDecoration(
                                    labelText: 'Condominium Name'),
                                // onChanged is handled by the listener
                                validator: (value) =>
                                    value!.isEmpty ? 'Please enter a name' : null,
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final String option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: ListTile(
                                            title: Text(option),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                              TextFormField(
                                initialValue: viewModel.location,
                                decoration: const InputDecoration(labelText: 'Location / Address'),
                                onChanged: (value) => viewModel.location = value,
                                validator: (value) =>
                                    value!.isEmpty ? 'Please enter a location' : null,
                              ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: viewModel.rent > 0 ? viewModel.rent.toStringAsFixed(0) : '',
                            decoration: const InputDecoration(
                                labelText: 'Monthly Rent (RM)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                viewModel.rent = double.tryParse(value) ?? 0,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  (double.tryParse(value) ?? 0) <= 0) {
                                return 'Please enter a valid rent amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDateRangePicker(context, viewModel),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Room & Tenant Details',
                        children: [
                          DropdownButtonFormField<String>(
                            decoration:
                                const InputDecoration(labelText: 'Room Type'),
                            value: viewModel.roomType,
                            items:
                                ['Master', 'Middle', 'Single'].map((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                            onChanged: (value) => viewModel.roomType = value!,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                                labelText: 'Preferred Gender'),
                            value: viewModel.gender,
                            items:
                                ['Male', 'Female', 'Mix'].map((String value) {
                              return DropdownMenuItem<String>(
                                  value: value, child: Text(value));
                            }).toList(),
                            onChanged: (value) => viewModel.gender = value!,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Description',
                        children: [
                          TextFormField(
                            initialValue: viewModel.description,
                            decoration: const InputDecoration(
                              hintText:
                                  'Add a detailed description of the property, rules, and available amenities...',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => viewModel.description = value,
                            maxLines: 5,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a description'
                                : null,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Photos',
                        children: [
                          _buildImageGrid(context, viewModel),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, CreatePostViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: viewModel.durationStart ?? DateTime.now(),
                firstDate: DateTime.now(), // 今日より前の日付は選択不可
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                // ViewModel の durationStart を更新
                viewModel.durationStart = pickedDate;
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Available From',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              child: Text(
                viewModel.durationStart != null
                    // 日付が選択されていればフォーマットして表示
                    ? DateFormat.yMMMd().format(viewModel.durationStart!)
                    : 'Select Date', // 未選択時のプレースホルダー
                style: TextStyle(
                  // プレースホルダーのテキストをグレーにする
                  color: viewModel.durationStart != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
        initialValue: viewModel.durationMonths != null
            ? viewModel.durationMonths.toString()
            : '',
        decoration: const InputDecoration(
          labelText: 'Duration (months)',
          border: OutlineInputBorder(),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          viewModel.durationMonths = int.tryParse(value);
        },
        validator: (value) {
          final v = int.tryParse(value ?? '');
          if (v == null || v <= 0) return 'Please enter duration in months';
          return null;
        },
          ),
        ),
      ],
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

 // ★ 修正された Image Grid Widget
 Widget _buildImageGrid(BuildContext context, CreatePostViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: viewModel.selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.selectedImages.length) {
          // --- Add Button ---
          return GestureDetector(
            onTap: () => viewModel.pickImages(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        }

        // --- Image Display Logic ---
        final imageItem = viewModel.selectedImages[index];
        Widget imageWidget;

        if (imageItem is String) {
          // Existing URL (String)
          imageWidget = CachedNetworkImage(
            imageUrl: imageItem,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey.shade300),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        } else if (kIsWeb && imageItem is XFile) {
           // Web: Picked file (XFile) -> Use Image.memory
           imageWidget = FutureBuilder<Uint8List>(
             future: imageItem.readAsBytes(),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                 return Image.memory(snapshot.data!, fit: BoxFit.cover);
               } else if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && (snapshot.data == null || snapshot.data!.isEmpty))) {
                 return Container(
                   color: Colors.grey.shade200,
                   child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
                 );
               }
               return Container(
                 color: Colors.grey.shade300,
                 child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
               );
             },
           );
         } else if (!kIsWeb && (imageItem is File || imageItem is XFile)) {
           // Mobile: Picked file (File or XFile) -> Use Image.file
           // The assertion error points here, ensure this branch is ONLY hit on mobile
           // The error stack trace indicates line 398 caused the issue, let's assume imageWidget = Image.file(...) is roughly there.
           final filePath = (imageItem is File) ? imageItem.path : (imageItem as XFile).path;
           imageWidget = Image.file(File(filePath), fit: BoxFit.cover); // This line must only run if !kIsWeb
         }
        else {
          // Fallback for unexpected type
          imageWidget = Container(
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.help_outline, color: Colors.grey)),
          );
        }

        // --- Stack for Image and Delete Button ---
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageWidget, // Display the determined image widget
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => viewModel.removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}