// lib/2_tenant_feature/4_chat/view/add_edit_general_note_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/common_feature/chat/model/chat_thread.dart';
import 'package:re_conver/common_feature/chat/viewmodel/chat_service.dart';

class AddEditGeneralNoteScreen extends StatefulWidget {
  final ChatThread thread;

  const AddEditGeneralNoteScreen({
    super.key,
    required this.thread,
  });

  @override
  State<AddEditGeneralNoteScreen> createState() =>
      _AddEditGeneralNoteScreenState();
}

class _AddEditGeneralNoteScreenState extends State<AddEditGeneralNoteScreen> {
  late final TextEditingController _noteController;
  final List<dynamic> _images = [];
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.thread.generalNote ?? '');
    _images.addAll(widget.thread.generalImageUrls);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await _chatService.updateGeneralNoteAndImages(
        thread: widget.thread,
        note: _noteController.text.trim(),
        images: _images,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Note & Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImagePickerGrid(),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'e.g., general reminders, topics to discuss...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == _images.length) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_a_photo_outlined, size: 40),
            ),
          );
        }
        final image = _images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image is String
                  ? Image.network(image, fit: BoxFit.cover)
                  : Image.file(image as File, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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