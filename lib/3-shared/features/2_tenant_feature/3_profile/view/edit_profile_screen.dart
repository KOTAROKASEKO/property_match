// lib/3-shared/features/2_tenant_feature/3_profile/view/edit_profile_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:re_conver/3-shared/core/responsive/responsive_layout.dart';
import 'package:re_conver/l10n/app_localizations.dart'; // ★ Import
import '../models/profile_model.dart' show UserProfile;
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final bool isNewUser;
  final String skipOption;
  const EditProfileScreen({
    super.key,
    required this.skipOption,
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
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() => _imageFile = selectedImage);
    }
  }

  Future<void> _saveProfile() async {
    if (_preferredAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one preferred living area.')), // 必要に応じて多言語化してください
      );
      return; // 処理を中断
    }

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
            SnackBar(content: Text('Failed to upload image: $e')), // Ideally localize too
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
          const SnackBar(content: Text('Profile updated successfully!')), // Ideally localize
        );

        if (widget.isNewUser) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
            (route) => false,
          );
        } else {
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
    final l = AppLocalizations.of(context)!; // ★ Localization

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          title: Text(widget.isNewUser ? l.profile_createProfile : l.common_editProfile),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(widget.skipOption == 'Save' ? l.common_save : l.profile_skip,
                  style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWideLayout(l);
              } else {
                return _buildNarrowLayout(l);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        children: [
          if (widget.isNewUser) ...[
            _buildInfoBanner(l),
            const SizedBox(height: 24),
          ],
          _buildAvatarSection(),
          const SizedBox(height: 32),
          _buildPersonalInfoSection(l),
          const SizedBox(height: 24),
          _buildPreferencesSection(l),
          const SizedBox(height: 32),
          _buildSaveButton(l),
          if (widget.isNewUser) _buildSkipButton(l),
        ],
      ),
    );
  }

  Widget _buildWideLayout(AppLocalizations l) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 60),
          child: Column(
            children: [
              if (widget.isNewUser) ...[
                _buildInfoBanner(l),
                const SizedBox(height: 32),
              ],
              _buildAvatarSection(),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPersonalInfoSection(l)),
                  const SizedBox(width: 32),
                  Expanded(child: _buildPreferencesSection(l)),
                ],
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    _buildSaveButton(l),
                    if (widget.isNewUser) _buildSkipButton(l),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 56,
              backgroundImage: _imageFile != null
                  ? (kIsWeb
                      ? NetworkImage(_imageFile!.path)
                      : FileImage(File(_imageFile!.path))) as ImageProvider
                  : (_profileImageUrl.isNotEmpty
                      ? NetworkImage(_profileImageUrl)
                      : const AssetImage('assets/default_avatar.png')) as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0, right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(AppLocalizations l) {
    return _buildSectionCard(
      title: l.profile_personalInfo,
      icon: Icons.person_outline,
      children: [
        _buildTextField(
          label: l.profile_displayName,
          initialValue: _displayName,
          onSaved: (val) => _displayName = val!,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return l.profile_required; // "Required"
            }
            if (double.tryParse(val) == null) {
              return 'Invalid number';
            }
            return null;
          },
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: l.tenantFilter_nationality,
          initialValue: _nationality,
          onSaved: (val) => _nationality = val!,
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: l.profile_selfIntroduction,
          initialValue: _selfIntroduction,
          onSaved: (val) => _selfIntroduction = val!,
          maxLines: 3,
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: l.profile_occupation,
          initialValue: _occupation,
          onSaved: (val) => _occupation = val!,
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: l.profile_workLocation,
          initialValue: _location,
          onSaved: (val) => _location = val!,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 24),
        _buildSlider(
          label: 'Age',
          value: _age.toDouble(),
          min: 18, max: 80, divisions: 62,
          onChanged: (val) => setState(() => _age = val.round()),
          displayValue: l.profile_ageYears(_age),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(AppLocalizations l) {
    return _buildSectionCard(
      title: l.profile_preferences,
      icon: Icons.home_work_outlined,
      children: [
        _buildDropdown(
          label: l.discover_gender,
          value: _gender,
          items: [
            {'value': 'Male', 'label': l.tenantFilter_genderMale},
            {'value': 'Female', 'label': l.tenantFilter_genderFemale},
            {'value': 'Mix', 'label': l.tenantFilter_genderMix},
            {'value': 'Not specified', 'label': l.profile_notSpecified},
          ],
          onChanged: (val) => setState(() => _gender = val!),
          icon: Icons.people_outline,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today, color: Colors.grey),
          title: Text(l.tenantFilter_moveInDate, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            _moveInDate == null ? l.profile_notSet : DateFormat.yMMMd().format(_moveInDate!),
            style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
          onTap: () => _selectMoveInDate(context),
        ),
        const Divider(),
        const SizedBox(height: 16),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.profile_preferredLivingAreas, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      hintText: l.profile_addAreaHint,
                      border: const UnderlineInputBorder(),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        setState(() { _preferredAreas.add(val.trim()); _areaController.clear(); });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  onPressed: () {
                    if (_areaController.text.isNotEmpty) {
                      setState(() { _preferredAreas.add(_areaController.text.trim()); _areaController.clear(); });
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
          label: l.profile_allowPets,
          value: _pets,
          items: [
            {'value': 'Yes', 'label': l.profile_yes},
            {'value': 'No', 'label': l.profile_no},
          ],
          onChanged: (val) => setState(() => _pets = val!),
          icon: Icons.pets_outlined,
        ),
        const SizedBox(height: 24),
        _buildSlider(
          label: l.profile_numberOfPax,
          value: _pax.toDouble(),
          min: 1, max: 10, divisions: 9,
          onChanged: (val) => setState(() => _pax = val.round()),
          displayValue: l.profile_paxCount(_pax), // ★★★ ここを修正 ★★★
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: l.profile_monthlyBudget,
          value: _budget,
          min: 500, max: 5000, divisions: 90,
          onChanged: (val) => setState(() => _budget = val),
          displayValue: l.placeholder_rmPerMonth(_budget.toStringAsFixed(0)),
        ),
        const SizedBox(height: 24),
        _buildDropdown(
          label: l.discover_roomType,
          value: _roomType,
          items: [
            {'value': 'Single', 'label': l.tenantFilter_roomSingle},
            {'value': 'Middle', 'label': l.tenantFilter_roomMiddle},
            {'value': 'Master', 'label': l.tenantFilter_roomMaster},
            {'value': 'Any', 'label': l.profile_any},
          ],
          onChanged: (val) => setState(() => _roomType = val!),
          icon: Icons.bed_outlined,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: l.profile_propertyPreference,
          value: _propertyType,
          items: [
            {'value': 'Condominium', 'label': l.propertyType_condo},
            {'value': 'Apartment', 'label': l.propertyType_apartment},
            {'value': 'Landed House', 'label': l.propertyType_landed},
            {'value': 'Studio', 'label': l.propertyType_studio},
          ],
          onChanged: (val) => setState(() => _propertyType = val!),
          icon: Icons.apartment_outlined,
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l) {
    return SizedBox(
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
            : Text(l.profile_saveProfile, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSkipButton(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: TextButton(
          onPressed: _skipProfile,
          child: Text(
            l.profile_skip,
            style: const TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.profile_benefitBanner,
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
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
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0),
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
    TextInputType? keyboardType, // ★ 追加: キーボードタイプ
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType, // ★ 追加
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: onChanged,
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