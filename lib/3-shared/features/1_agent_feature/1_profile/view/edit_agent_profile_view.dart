// lib/3-shared/features/1_agent_feature/1_profile/view/edit_agent_profile_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart'; // ★ 追加: これをインポートしてください
import '../model/agent_profile_model.dart';
import '../viewmodel/agent_profile_viewmodel.dart';

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
  
  String _countryCode = '+60'; 
  late String _phoneBody;

  @override
  void initState() {
    super.initState();
    _displayName = widget.agentProfile.displayName;
    _profileImageUrl = widget.agentProfile.profileImageUrl;
    _bio = widget.agentProfile.bio;
    
    // 既存の番号を解析して初期値をセット
    String currentPhone = widget.agentProfile.phoneNumber;
    if (currentPhone.startsWith('+')) {
      // "+6012345" のような形式を想定し、簡易的に国番号を抽出するロジック
      // (厳密にやるなら libphonenumber が必要ですが、簡易版として)
      if(currentPhone.startsWith('+60')) {
         _countryCode = '+60';
         _phoneBody = currentPhone.substring(3);
      } else if (currentPhone.startsWith('+81')) {
         _countryCode = '+81';
         _phoneBody = currentPhone.substring(3);
      } else {
        // マッチしない場合は、デフォルト+60にして、全体をbodyに入れるなどのフォールバック
        // 実際には保存されている形式に合わせて調整してください
        _countryCode = '+60'; 
        _phoneBody = currentPhone.replaceAll('+60', ''); 
      }
    } else {
      _phoneBody = currentPhone;
    }
  }

  // ... (途中省略: _pickImage, _saveProfile などは変更なし) ...
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      // 国番号と本文を結合
      String finalCountryCode = _countryCode.trim();
      if (!finalCountryCode.startsWith('+')) {
        finalCountryCode = '+$finalCountryCode';
      }
      final String fullPhoneNumber = '$finalCountryCode${_phoneBody.trim()}';

      final updatedProfile = AgentProfile(
        uid: widget.agentProfile.uid,
        email: widget.agentProfile.email,
        displayName: _displayName,
        profileImageUrl: newProfileImageUrl,
        bio: _bio,
        phoneNumber: fullPhoneNumber,
      );

      try {
        await viewModel.updateUserProfile(updatedProfile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
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
        foregroundColor: Colors.white,
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
            // ... (アバター部分は変更なし) ...
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
            
            const Text(
              'WhatsApp Number',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ★★★ 国番号選択部分 (変更箇所) ★★★
                SizedBox(
                  width: 90, // 国番号用の幅を指定 (80〜100くらいが適切)
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        countryListTheme: CountryListThemeData(
                          borderRadius: BorderRadius.circular(16),
                          inputDecoration: InputDecoration(
                            labelText: 'Search',
                            hintText: 'Start typing to search',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onSelect: (Country country) {
                          setState(() {
                            _countryCode = '+${country.phoneCode}';
                          });
                        },
                      );
                    },
                    // InputDecorator
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      ),
                      child: Text(
                        _countryCode,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 電話番号本体入力欄 (ほぼ変更なし)
                Expanded(
                  child: TextFormField(
                    initialValue: _phoneBody,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '123456789',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _phoneBody = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter phone number';
                      if (!RegExp(r'^\d+$').hasMatch(value.replaceAll(' ', ''))) {
                        return 'Digits only';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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