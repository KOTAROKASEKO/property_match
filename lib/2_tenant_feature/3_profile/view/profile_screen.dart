// lib/2_tenant_feature/3_profile/view/profilescreen.dart
import 'package:flutter/material.dart';
import 'package:re_conver/2_tenant_feature/3_profile/models/profile_model.dart';
import 'package:re_conver/2_tenant_feature/3_profile/services/user_service.dart';
import 'edit_profile_screen.dart'; // We will create this next

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    setState(() {
      _userProfileFuture = _userService.getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('User profile not found.'));
          }

          final userProfile = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadUserProfile(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(userProfile),
                const SizedBox(height: 24),
                _buildProfileDetailsCard(userProfile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile userProfile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: userProfile.profileImageUrl.isNotEmpty
              ? NetworkImage(userProfile.profileImageUrl)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          child: userProfile.profileImageUrl.isEmpty
              ? Text(
                  userProfile.displayName.isNotEmpty ? userProfile.displayName[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40, color: Colors.deepPurple.shade800),
                )
              : null,
        ),
        const SizedBox(height: 16),
        // Display the user's display name
        Text(
          userProfile.displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Display the user's email
        Text(
          userProfile.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            // Navigate to Edit screen and wait for a result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(userProfile: userProfile),
              ),
            );
            // If the profile was updated, refresh the data
            if (result == true) {
              _loadUserProfile();
            }
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetailsCard(UserProfile userProfile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _ProfileDetailRow(
              icon: Icons.cake_outlined,
              title: 'Age',
              value: '${userProfile.age} years old',
            ),
            _ProfileDetailRow(
              icon: Icons.work_outline,
              title: 'Occupation',
              value: userProfile.occupation,
            ),
            _ProfileDetailRow(
              icon: Icons.location_on_outlined,
              title: 'Work/Study Location',
              value: userProfile.location,
            ),
            _ProfileDetailRow(
              icon: Icons.pets_outlined,
              title: 'Pets',
              value: userProfile.pets,
            ),
            const Divider(indent: 16, endIndent: 16),
             _ProfileDetailRow(
              icon: Icons.group_outlined,
              title: 'Number of Pax',
              value: '${userProfile.pax} person(s)',
            ),
            _ProfileDetailRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budget',
              value: 'RM ${userProfile.budget.toStringAsFixed(0)} / month',
            ),
             _ProfileDetailRow(
              icon: Icons.bed_outlined,
              title: 'Room Preference',
              value: userProfile.roomType,
            ),
            _ProfileDetailRow(
              icon: Icons.apartment_outlined,
              title: 'Property Preference',
              value: userProfile.propertyType,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

// A helper widget for a consistent row style
class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _ProfileDetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, isLast ? 12 : 0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          )
        ],
      ),
    );
  }
}