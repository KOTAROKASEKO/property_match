import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:re_conver/1_agent_feature/2_profile/model/agent_profile_model.dart';
import 'package:re_conver/1_agent_feature/2_profile/viewmodel/profile_viewmodel.dart';

class EditAgentProfileScreen extends StatefulWidget {
  final AgentProfile agentProfile;
  const EditAgentProfileScreen({super.key, required this.agentProfile});

  @override
  State<EditAgentProfileScreen> createState() => _EditAgentProfileScreenState();
}

class _EditAgentProfileScreenState extends State<EditAgentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late String _displayName;
  late String _profileImageUrl;
  late String _bio;
  XFile? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayName = widget.agentProfile.displayName;
    _profileImageUrl = widget.agentProfile.profileImageUrl;
    _bio = widget.agentProfile.bio;
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      final viewModel = context.read<ProfileViewModel>();
      String newProfileImageUrl = _profileImageUrl;

      if (_imageFile != null) {
        try {
          newProfileImageUrl = await viewModel.uploadProfileImage(widget.agentProfile.uid, _imageFile!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      final updatedProfile = AgentProfile(
        uid: widget.agentProfile.uid,
        email: widget.agentProfile.email,
        displayName: _displayName,
        profileImageUrl: newProfileImageUrl,
        bio: _bio,
      );

      try {
        await viewModel.updateUserProfile(updatedProfile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Edit Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : (_profileImageUrl.isNotEmpty
                            ? NetworkImage(_profileImageUrl)
                            : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: _displayName,
              decoration: const InputDecoration(labelText: 'Display Name'),
              onSaved: (value) => _displayName = value!,
              validator: (value) => value!.isEmpty ? 'Please enter a display name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _bio,
              decoration: const InputDecoration(labelText: 'Bio'),
              onSaved: (value) => _bio = value!,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}