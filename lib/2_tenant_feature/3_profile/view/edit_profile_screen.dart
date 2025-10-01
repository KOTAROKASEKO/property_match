import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_conver/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/2_tenant_feature/3_profile/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  const EditProfileScreen({super.key, required this.userProfile});

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
  late String _nationality; // Added
  late String _selfIntroduction; // Added
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
    _nationality = widget.userProfile.nationality; // Added
    _selfIntroduction = widget.userProfile.selfIntroduction; // Added
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
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
              widget.userProfile.uid, _imageFile!);
        } catch (e) {
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
        nationality: _nationality, // Added
        selfIntroduction: _selfIntroduction, // Added
      );

      try {
        await _userService.updateUserProfile(updatedProfile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path))
                          : (_profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : const AssetImage('assets/default_avatar.png'))
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.deepPurple,
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Personal Info'),
              TextFormField(
                initialValue: _displayName,
                decoration: const InputDecoration(labelText: 'Display Name'),
                onSaved: (value) => _displayName = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a display name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _nationality,
                decoration: const InputDecoration(labelText: 'Nationality'),
                onSaved: (value) => _nationality = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your nationality' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _selfIntroduction,
                decoration:
                    const InputDecoration(labelText: 'Self Introduction'),
                onSaved: (value) => _selfIntroduction = value!,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _occupation,
                decoration: const InputDecoration(labelText: 'Occupation'),
                onSaved: (value) => _occupation = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an occupation' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration:
                    const InputDecoration(labelText: 'Work/Study Location'),
                onSaved: (value) => _location = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _pets,
                decoration: const InputDecoration(labelText: 'Allow Pets?'),
                items: ['Yes', 'No'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _pets = newValue!),
              ),
              const SizedBox(height: 16),
              _buildSlider(
                label: 'Age',
                value: _age.toDouble(),
                min: 18,
                max: 80,
                divisions: 62,
                onChanged: (val) => setState(() => _age = val.round()),
                displayValue: _age.toString(),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Housing Preferences'),
              _buildSlider(
                label: 'Number of Pax',
                value: _pax.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (val) => setState(() => _pax = val.round()),
                displayValue: _pax.toString(),
              ),
              const SizedBox(height: 16),
              _buildSlider(
                label: 'Monthly Budget (RM)',
                value: _budget,
                min: 500,
                max: 5000,
                divisions: 90,
                onChanged: (val) => setState(() => _budget = val),
                displayValue: _budget.toStringAsFixed(0),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _roomType,
                decoration: const InputDecoration(labelText: 'Room Type'),
                items: ['Single', 'Middle', 'Master'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _roomType = newValue!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: const InputDecoration(labelText: 'Property Type'),
                items: ['Condominium', 'Apartment', 'Landed House', 'Studio']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _propertyType = newValue!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
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
        Text('$label: $displayValue', style: const TextStyle(fontSize: 16)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: displayValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}