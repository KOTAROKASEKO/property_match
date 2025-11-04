// lib/2_tenant_feature/4_chat/view/add_edit_viewing_note_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatrepo_interface/chatrepo_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_data/shared_data.dart';
import '../viewmodel/chat_service.dart'; 
import 'dart:typed_data';

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
        if (kIsWeb) {
          // On web, add the XFile objects directly
          _images.addAll(pickedFiles);
        } else {
          // On mobile, convert to File objects
          _images.addAll(pickedFiles.map((file) => File(file.path)));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    pr('submit method was called');
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
              child: image is String // It's a URL
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade300),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : kIsWeb // It's a selected file on the Web (must be XFile)
                      ? FutureBuilder<Uint8List>(
                          // ★★★ FIX: Only call readAsBytes on XFile ★★★
                          future: (image is XFile)
                              ? image.readAsBytes()
                              // Provide a fallback future if it's not an XFile (shouldn't happen with image_picker)
                              : Future.value(Uint8List(0)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done &&
                                snapshot.hasData &&
                                // ★★★ Add check for non-empty bytes ★★★
                                snapshot.data!.isNotEmpty) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            } else if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && (snapshot.data == null || snapshot.data!.isEmpty))) {
                              // ★★★ Show an error if reading failed or bytes are empty ★★★
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
                              );
                            }
                            // Show loading indicator
                            return Container(color: Colors.grey.shade300, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
                          },
                        )
                      : Image.file( // It's a selected file on Mobile (must be File)
                          image as File, // Assume File on mobile if not String
                          fit: BoxFit.cover,
                        ),
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