// lib/3-shared/features/2_tenant_feature/3_profile/view/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/3-shared/core/responsive/responsive_layout.dart';
import '../models/profile_model.dart' show UserProfile;
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final bool isNewUser;
  const EditProfileScreen({
    super.key,
    required this.userProfile,
    this.isNewUser = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  late String _displayName;
  late String _profileImageUrl;
  XFile? _imageFile;
  late int _age;
  late String _occupation;
  late String _location;
  late String _pets;
  late int _pax;
  late double _budget;
  late String _roomType;
  late String _propertyType;
  late String _gender;
  late String _nationality;
  late String _selfIntroduction;
  late DateTime? _moveInDate;
  late List<String> _hobbies;
  final _hobbyController = TextEditingController();
  late List<String> _preferredAreas;
  final _areaController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userProfile.displayName;
    _profileImageUrl = widget.userProfile.profileImageUrl;
    _age = widget.userProfile.age;
    _occupation = widget.userProfile.occupation;
    _location = widget.userProfile.location;
    _pets = widget.userProfile.pets;
    _pax = widget.userProfile.pax;
    _budget = widget.userProfile.budget;
    _roomType = widget.userProfile.roomType;
    _propertyType = widget.userProfile.propertyType;
    _nationality = widget.userProfile.nationality;
    _selfIntroduction = widget.userProfile.selfIntroduction;
    _moveInDate = widget.userProfile.moveinDate;
    _gender = widget.userProfile.gender;
    _hobbies = List<String>.from(widget.userProfile.hobbies);
    _preferredAreas = List<String>.from(widget.userProfile.preferredAreas);
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
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

      String newProfileImageUrl = _profileImageUrl;
      if (_imageFile != null) {
        try {
          newProfileImageUrl = await _userService.uploadProfileImage(
            widget.userProfile.uid,
            _imageFile!,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      final updatedProfile = UserProfile(
        uid: widget.userProfile.uid,
        email: widget.userProfile.email,
        displayName: _displayName,
        profileImageUrl: newProfileImageUrl,
        age: _age,
        occupation: _occupation,
        location: _location,
        pets: _pets,
        pax: _pax,
        budget: _budget,
        roomType: _roomType,
        propertyType: _propertyType,
        nationality: _nationality,
        selfIntroduction: _selfIntroduction,
        moveinDate: _moveInDate,
        gender: _gender,
        hobbies: _hobbies,
        preferredAreas: _preferredAreas,
      );

      try {
        await _userService.updateUserProfileWithGeo(updatedProfile);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        if (widget.isNewUser) {
          // 新規ユーザーの場合はホーム画面へ遷移
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
            (route) => false,
          );
        } else {
          // 編集の場合は前の画面に戻る
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _skipProfile() {
    // プロフィール作成をスキップしてホームへ
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
      (route) => false,
    );
  }

  Future<void> _selectMoveInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _moveInDate) {
      setState(() {
        _moveInDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50], // 全体の背景色を明るいグレーに
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          title: Text(widget.isNewUser ? 'Create Profile' : 'Edit Profile'),
          elevation: 0,
          actions: [
            // 保存ボタンをアイコン化（オプション）
            TextButton(onPressed: _isLoading ? null : _saveProfile, 
            child: Text('Skip for now', style: TextStyle(color: Colors.white),))
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              // ★ 1. 新規ユーザー向けの説明バナー
              if (widget.isNewUser) ...[
                _buildInfoBanner(),
                const SizedBox(height: 24),
              ],

              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : (_profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ★ 2. セクション: Personal Info
              _buildSectionCard(
                title: 'Personal Info',
                icon: Icons.person_outline,
                children: [
                  _buildTextField(
                    label: 'Display Name',
                    initialValue: _displayName,
                    onSaved: (val) => _displayName = val!,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildHobbiesInput(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Nationality',
                    initialValue: _nationality,
                    onSaved: (val) => _nationality = val!,
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Self Introduction',
                    initialValue: _selfIntroduction,
                    onSaved: (val) => _selfIntroduction = val!,
                    maxLines: 3,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Occupation',
                    initialValue: _occupation,
                    onSaved: (val) => _occupation = val!,
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Work/Study Location',
                    initialValue: _location,
                    onSaved: (val) => _location = val!,
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildSlider(
                    label: 'Age',
                    value: _age.toDouble(),
                    min: 18,
                    max: 80,
                    divisions: 62,
                    onChanged: (val) => setState(() => _age = val.round()),
                    displayValue: '$_age years',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ★ 3. セクション: Preferences
              _buildSectionCard(
                title: 'Preferences',
                icon: Icons.home_work_outlined,
                children: [
                  _buildDropdown(
                    label: 'Gender',
                    value: _gender,
                    items: ['Male', 'Female', 'Mix', 'Not specified'],
                    onChanged: (val) => setState(() => _gender = val!),
                    icon: Icons.people_outline,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Colors.grey),
                    title: const Text('Move-in Date', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      _moveInDate == null ? 'Not set' : DateFormat.yMMMd().format(_moveInDate!),
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                    onTap: () => _selectMoveInDate(context),
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Preferred Areas Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preferred Living Areas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _areaController,
                              decoration: const InputDecoration(
                                hintText: 'Add area (e.g. Bangsar)',
                                border: UnderlineInputBorder(),
                              ),
                              onSubmitted: (val) {
                                if (val.isNotEmpty) {
                                  setState(() {
                                    _preferredAreas.add(val.trim());
                                    _areaController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                            onPressed: () {
                              if (_areaController.text.isNotEmpty) {
                                setState(() {
                                  _preferredAreas.add(_areaController.text.trim());
                                  _areaController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _preferredAreas.map((area) => Chip(
                          label: Text(area),
                          backgroundColor: Colors.deepPurple.shade50,
                          labelStyle: const TextStyle(color: Colors.deepPurple),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.deepPurple),
                          onDeleted: () => setState(() => _preferredAreas.remove(area)),
                        )).toList(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildDropdown(
                    label: 'Allow Pets?',
                    value: _pets,
                    items: ['Yes', 'No'],
                    onChanged: (val) => setState(() => _pets = val!),
                    icon: Icons.pets_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildSlider(
                    label: 'Number of Pax',
                    value: _pax.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (val) => setState(() => _pax = val.round()),
                    displayValue: '$_pax pax',
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(
                    label: 'Monthly Budget',
                    value: _budget,
                    min: 500,
                    max: 5000,
                    divisions: 90,
                    onChanged: (val) => setState(() => _budget = val),
                    displayValue: 'RM ${_budget.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    label: 'Room Type',
                    value: _roomType,
                    items: ['Single', 'Middle', 'Master'],
                    onChanged: (val) => setState(() => _roomType = val!),
                    icon: Icons.bed_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Property Type',
                    value: _propertyType,
                    items: ['Condominium', 'Apartment', 'Landed House', 'Studio'],
                    onChanged: (val) => setState(() => _propertyType = val!),
                    icon: Icons.apartment_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              // ★ 4. スキップボタン（新規ユーザーのみ）
              if (widget.isNewUser) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _skipProfile,
                    child: const Text(
                      'Skip creating profile as of now',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'If you create profile, agent who has your ideal room can find you!',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      // border: Border.all(color: Colors.grey.shade200), // Optional border
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildHobbiesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _hobbyController,
          decoration: InputDecoration(
            labelText: 'Tags / Hobbies',
            hintText: 'e.g. Cooking, Gaming',
            prefixIcon: const Icon(Icons.tag, color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: () {
                final hobby = _hobbyController.text.trim(); // ケースは維持
                if (hobby.isNotEmpty && !_hobbies.contains(hobby)) {
                  setState(() {
                    _hobbies.add(hobby);
                    _hobbyController.clear();
                  });
                }
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onFieldSubmitted: (value) {
            final hobby = value.trim();
            if (hobby.isNotEmpty && !_hobbies.contains(hobby)) {
              setState(() {
                _hobbies.add(hobby);
                _hobbyController.clear();
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _hobbies.map((hobby) => Chip(
            label: Text(hobby),
            backgroundColor: Colors.deepPurple.shade50,
            labelStyle: const TextStyle(color: Colors.deepPurple),
            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.deepPurple),
            onDeleted: () {
              setState(() {
                _hobbies.remove(hobby);
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.deepPurple,
            inactiveTrackColor: Colors.deepPurple.shade100,
            thumbColor: Colors.deepPurple,
            overlayColor: Colors.deepPurple.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}