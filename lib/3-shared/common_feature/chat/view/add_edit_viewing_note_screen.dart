// lib/2_tenant_feature/4_chat/view/add_edit_viewing_note_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/1-mobile-lib/data/chat_thread.dart';
import '../viewmodel/chat_service.dart'; 

class AddEditViewingNoteScreen extends StatefulWidget {
  final ChatThread thread;
  final int viewingIndex;

  const AddEditViewingNoteScreen({
    super.key, 
    required this.thread,
    required this.viewingIndex,
  });

  @override
  State<AddEditViewingNoteScreen> createState() => _AddEditViewingNoteScreenState();
}

class _AddEditViewingNoteScreenState extends State<AddEditViewingNoteScreen> {
  late final TextEditingController _noteController;
  final List<dynamic> _images = []; 
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;

@override
void initState() {
  super.initState();
  _noteController = TextEditingController(
      text: widget.thread.viewingNotes.length > widget.viewingIndex
          ? widget.thread.viewingNotes[widget.viewingIndex]
          : '');

  if (widget.thread.viewingImageUrls.length > widget.viewingIndex) {
    final imageUrlsJson = widget.thread.viewingImageUrls[widget.viewingIndex];
    if (imageUrlsJson.isNotEmpty) {
      // Decode the json and handle both single and double encoding
      var decoded = jsonDecode(imageUrlsJson);
      if (decoded is String) {
        // If the decoded value is a string, decode it again
        decoded = jsonDecode(decoded);
      }
      if (decoded is List) {
        _images.addAll(List<String>.from(decoded));
      }
    }
  }
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
      await _chatService.updateViewingDetails(
        threadId: widget.thread.id,
        note: _noteController.text.trim(),
        images: _images,
        viewingIndex: widget.viewingIndex,
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
        title: const Text('Viewing Details'),
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
                hintText: 'e.g., great lighting, noisy neighbours...',
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